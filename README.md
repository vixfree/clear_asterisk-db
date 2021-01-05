---
EN:
---------------------------------------------------------------------------------------------
Script for automatic cleaning of logs in the MySQL database and call records of Asterisk PBX.

# manual script  values

db_host="localhost";          # host mysql
db_name="cdr";                # name database
db_login="admindb";           # login for database
db_pass="passdb";             # pass for login

email="admin@mydomen.ru";     # mail address for notification


type="month";                 # time interval (SECOND,MINUTE,HOUR,DAY,MONTH,YEAR)
num="3";                      # saze (the number 3 months)
records="/home/calls";        # call recording directory
typerec="mp3";                # file type records (mp3 & wav)
arh_path="/home/backup/arh";  # archive of previous calls and database
sw_backup="1";                # automatic create or not create backup 1-yes,0-no

---
RU:
---------------------------------------------------------------------------------------------
Скрипт автоматической чистки логов в базе данных MySQL и записей звонков Asterisk АТС

# необходимые параметры для скрипта

db_host="localhost";          # хост сервера mysql
db_name="cdr";                # имя базы данных
db_login="admindb";           # логин пользователя
db_pass="passdb";             # пароль пользователя

email="admin@mydomen.ru";     # адрес для отправки уведомлений


type="month";                 # время интервала (SECOND,MINUTE,HOUR,DAY,MONTH,YEAR)
num="3";                      # количество (the number 3 months)
records="/home/calls";        # папка хранения звонков
typerec="mp3";                # формат записи (mp3 & wav)
arh_path="/home/backup/arh";  # папка сохранения данных перед чисткой
sw_backup="1";                # параметр указывающий создавать backup перед чисткой или нет
