#!/bin/bash
#
#
# Dumps all databases to seperate files.
# All files are created in a folder named by the current date.
# Folders exceeding the defined hold time are purged automatically.
# 
# #################################################
# -- How to run it ---
# 
# - make script executable
# - mount script in db container
# - mount volume backup directory to /backup
# - example for docker-compose.yml
#   ...
#   volumes:
#      - ./build/scripts/mysql-backup.sh:/usr/bin/backup-mysql.sh
#      - ./mysql-data/backup:/backup
#   ...
# - run it from host script via cronjob, e.g.: 
#   docker exec -it  DB_CONTAINER_NAME /usr/bin/backup-mysql.sh
# 
# - example crontab for running on host system directly:
# 5 1 * * * docker exec -it --env MYSQL_ROOT_PASSWORD="$(cat PATH_TO_PASSWORDFILE.txt)" MY_CONTAINER_NAME /usr/bin/backup-mysql.sh >> /tmp/backup.log 2>&1
# #################################################


# Setup.start
#

HOLD_DAYS=7 
TIMESTAMP=$(date +"%F")
BACKUP_DIR="/backup/mysql"
MYSQL_USR="root"
# password will be fetched from docker container
MYSQL_PWD=$MYSQL_ROOT_PASSWORD
MYSQL_HOST=$MYSQL_HOST
MYSQL_DEFAULT_CHARSET=utf8

# Use this inside a MySql Docker container
#
MYSQL_CMD=mysql
MYSQL_DMP=mysqldump
MYSQL_CHECK=mysqlcheck

#
# Setup.end


# Check and auto-repair all databases first
#
echo
echo "Checking all databases - this can take a while ..."
$MYSQL_CHECK -h $MYSQL_HOST  -u $MYSQL_USR --password=$MYSQL_PWD --auto-repair --all-databases

# Backup
#
echo
echo "Starting backup ..."
mkdir -p "$BACKUP_DIR/$TIMESTAMP"
databases=`$MYSQL_CMD -h $MYSQL_HOST --user=$MYSQL_USR -p$MYSQL_PWD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`
 
for db in $databases; do
  echo "Dumping $db ..."
  $MYSQL_DMP --force --opt --skip-set-charset --default-character-set=$MYSQL_DEFAULT_CHARSET -h $MYSQL_HOST --user=$MYSQL_USR -p$MYSQL_PWD --databases "$db" | gzip > "$BACKUP_DIR/$TIMESTAMP/$db.gz"
  if [[ $? -eq 0 ]]; then
     echo "$db backup successful"
  else
     echo "$db backup failed"
  fi
done

echo
echo "Cleaning up ..."
find $BACKUP_DIR -maxdepth 1 -mindepth 1 -type d -mtime +$HOLD_DAYS -exec rm -rf {} \;
echo "-- DONE!"
