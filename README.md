EN:
-
Script for automatic cleaning of logs in the MySQL database and call records of Asterisk PBX.

* manual script  values

db_host="localhost";          # host mysql<br>
db_name="cdr";                # name database<br>
db_login="admindb";           # login for database<br>
db_pass="passdb";             # pass for login<br>

email="admin@mydomen.ru";     # mail address for notification<br>

type="month";                 # time interval (SECOND,MINUTE,HOUR,DAY,MONTH,YEAR)<br>
num="3";                      # saze (the number 3 months)<br>
records="/home/calls";        # call recording directory<br>
typerec="mp3";                # file type records (mp3 & wav)<br>
arh_path="/home/backup/arh";  # archive of previous calls and database<br>
sw_backup="1";                # automatic create or not create backup 1-yes,0-no<br>


RU:<br>
-
Скрипт автоматической чистки логов в базе данных MySQL и записей звонков Asterisk АТС <br>

* необходимые параметры для скрипта

db_host="localhost";          # хост сервера mysql<br>
db_name="cdr";                # имя базы данных<br>
db_login="admindb";           # логин пользователя<br>
db_pass="passdb";             # пароль пользователя<br>

email="admin@mydomen.ru";     # адрес для отправки уведомлений<br>

type="month";                 # время интервала (SECOND,MINUTE,HOUR,DAY,MONTH,YEAR)<br>
num="3";                      # количество (the number 3 months)<br>
records="/home/calls";        # папка хранения звонков<br>
typerec="mp3";                # формат записи (mp3 & wav)<br>
arh_path="/home/backup/arh";  # папка сохранения данных перед чисткой<br>
sw_backup="1";                # параметр указывающий создавать backup перед чисткой или нет<br>
