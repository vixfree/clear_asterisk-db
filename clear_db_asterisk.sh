#!/bin/bash
# script clear asterisk database calls (mysql/mariadb)
# for Debian OS Linux - version 9,10
# athor: Koshuba V.O. - (c) 2021
# script version: 1.0.1
# license: GPL 2.0
# email: master@qbpro.ru

## - control manual values
# - connect data
db_host="localhost";                                                           # host mysql
db_name="cdr";                                                                 # name database
db_login="admindb";                                                            # login for database
db_pass="passdb";                                                              # pass for login

# - admin email
email="admin@mydomen.ru";                                                      # mail address for notification
# - clear values
type="month";                                                                  # time interval (SECOND,MINUTE,HOUR,DAY,MONTH,YEAR)
num="3";                                                                       # saze (the number 3 months)
records="/home/calls";                                                         # call recording directory
typerec="mp3";                                                                 # file type records (mp3 & wav)
arh_path="/home/backup/arh";                                                   # archive of previous calls and database
sw_backup="1";                                                                 # create or not create backup 1-yes,0-no

## - script values
get_tools=( "mysql" "mysqlcheck" "mysqldump" "pigz" "locale" );                # tools for script
set_lang="0";                                                                  # locale (ru & en )
flock="/tmp/cleardb_asterisk.lock";
log="/var/log/clear_asterisk-db.log";                                          # temporary log file
cdate="$(date +%c)";                                                           # current date for log
msg_dat=(
     '"Cleanup of the database and call records before the specified period was successful!" "Чистка базы данных и записей звонков до указанного периода выполнена успешно!"'
     '"The script stopped working due to:" "Остановлена работа скрипта по причине:"'
     '"create full backup database and calls before a given period" "создана резервная копия всей базы и записей звонков до заданного периода"'
     '"An error occurred while creating a backup, the cleaning process was stopped." "Ошибка при создании резервной копии, процесс чистки остановлен."'
     '"Found lock file:/tmp/cleardb_asterisk.lock!" "Найден файл блокировки:/tmp/cleardb_asterisk.lock!"'
     '"not found:" "файл не найден:"'
     '"found ok:" "файл найден:"'
     '"process mysqldump failed executed!" "процесс mysqldump не выполнен!"'
     '"no call recording files to save in the database were found!" "файлы записей звонков для сохранения в базе данных не найдены!"'
     '"not found for delete:" "файл для удаления не найден:"'
     '"delete ok:" "файл удален успешно:"'
     '"no call recording files to delete in the database were found!" "файлы записей звонков для удаления в базе данных не найдены!"'
);                                                                             # messages array
report=();                                                                     # reports array


#<Fn_get-tools>
function getTools() {
for ((itools=0; itools != ${#get_tools[@]}; itools++))
 do
eval get_${get_tools[$itools]}=$(whereis -b ${get_tools[$itools]}|awk '/^'${get_tools[$itools]}':/{print $2}');
list_tools[${#list_tools[@]}]="$(whereis -b ${get_tools[$itools]}|awk '/^'${get_tools[$itools]}':/{print $2}')";
done
}

#<Fn_get-lang>
function langMsg() {
if [[ ! $($get_locale|grep 'LANG='|sed 's/\LANG=//g'|grep 'ru_RU.UTF-8'|wc -m) -eq 0 ]];
    then
        set_lang="0";
    else
        set_lang="1";
fi
for ((ilang=0; ilang != ${#msg_dat[@]}; ilang++))
 do
    eval tmsg="(" $(echo -e ${msg_dat[$ilang]}) ")"; 
    msg[$ilang]=${tmsg[$set_lang]};
done
}

#<Fn_preTest>
function preTest() {
if [ ! -f $log ];
    then
     touch $log
    else
    :>$log;
fi
if [ ! -f $flock ]
    then 
        echo "$cdate">$flock;
    else
        report=();
        report[${#report[@]}]="${msg[1]}";
        report[${#report[@]}]="${msg[4]}";
        smsg;
	exit;
fi
sqlt="use $db_name; select filename FROM cdr WHERE cdr.calldate <= DATE_SUB(NOW(),interval $num $type) and cdr.filename !='none';";
eval fdata="(" $(sudo $get_mysql -h$db_host -u$db_login -p$db_pass  -e "$(echo -e $sqlt)"|grep -v filename) ")"; 
#"
}

#<Fn_bak data>
function bakData() {
if [ $sw_backup = "1" ];
    then
	if [ ! -d $arh_path ];
	    then
		sudo mkdir -p $arh_path/db
    		sudo mkdir -p $arh_path/calls
	    else
		if [ ! -d $arh_path/db ];
		    then
		    sudo mkdir -p $arh_path/db;
		fi
		if [ ! -d $arh_path/calls ];
		    then
		    sudo mkdir -p $arh_path/calls;
		fi
	fi
	## clear old files
	sudo find $arh_path/calls -maxdepth 1 -type 'f' -name "*.$typerec" -exec rm {} \;
        sudo find $arh_path/db -maxdepth 1 -type 'f' -name "*.gz" -exec rm {} \;
        ## begin backup data
	if sudo $get_mysqldump -h$db_host -u$db_login -p$db_pass $db_name | sudo pigz -c9 > $arh_path/db/$db_name"_"$(date +%d-%m-%y).sql.gz;
	 then
	    report=();
    	    report[${#report[@]}]="$cdate clear_asterisk-db.sh: backup database - ok!";
    	    smsg;
	    if [ ${#fdata[@]} != "0" ];
		then
		    for ((dbinx=0; dbinx != ${#fdata[@]}; dbinx++))
			do
			    if [ -f $records/${fdata[$dbinx]} ];
    				then
				echo "${msg[6]}:${fdata[$dbinx]}">>$log;
				sudo cp -f $records/${fdata[$dbinx]} $arh_path/calls/${fdata[$dbinx]};
    			    else
				echo "${msg[5]}:${fdata[$dbinx]}">>$log;
			    fi
		    done
		else
		    report=();
        	    report[${#report[@]}]="$cdate clear_asterisk-db.sh:${msg[8]}";
        	    smsg;
		fi
         else
		report=();
        	report[${#report[@]}]="$cdate clear_asterisk-db.sh:${msg[1]} - ${msg[7]}";
        	smsg;
        	exit;
    	fi
fi
clrData;
}

function clrData() {
sqlt="use $db_name; DELETE FROM cdr WHERE cdr.calldate <= DATE_SUB(NOW(),interval $num $type); OPTIMIZE TABLE cdr;";
sudo $get_mysql -h$db_host -u$db_login -p$db_pass  -e "$(echo -e $sqlt)";

if [ ${#fdata[@]} != "0" ];
		then
		    for ((dbinx=0; dbinx != ${#fdata[@]}; dbinx++))
			do
			    if [ -f $records/${fdata[$dbinx]} ];
    				then
				echo "${msg[10]}:${fdata[$dbinx]}">>$log;
				sudo rm -f $records/${fdata[$dbinx]};
    			    else
				echo "${msg[9]}:${fdata[$dbinx]}">>$log;
			    fi
		    done
		else
		    report=();
        	    report[${#report[@]}]="$cdate clear_asterisk-db.sh:${msg[11]}";
        	    smsg;
fi
lockOff;
}


function smsg() {
if [ ${#report[@]} != "0" ];
    then
     for ((rpt_index=0; rpt_index != ${#report[@]}; rpt_index++))
      do
	if [[ "${report[$rpt_index]}" != "" ]];
         then
         echo -e "${report[$rpt_index]}">>$log;
         fi
     done
fi
}

## -@F function check lock file
function lockOff() {
if  [ -f $flock ];
    then
    sudo rm -f $flock;
fi
report=();
report[${#report[@]}]="$cdate clear_asterisk-db.sh:${msg[0]}";
smsg;
sudo cat $log |mail -s "asterisk clear database & records" $email
sudo systemctl restart asterisk;
exit;
}

langMsg;
getTools;
preTest;
bakData;

exit;
