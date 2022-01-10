# docker-compose-mariadb
Simple Docker Compose stack to run a mariadb database with custom configuration and automated backup script. 

* uses Docker secrets based on file mounts
* backup script & container creates configurable daily backups of all databases


## How to restore Database (with utf8 safe encoding)
* unpack sql backup file in backup directoy
* mount backup directory to db container
* login into db container and start a bash `docker exec -it CONTAINER_ID bash`
* `mysql -uroot -p --default-character-set=utf8mb4 --database=MY_DATABASE_NAME`
* enter root password
* `mysql > SET names 'utf8';`
* `mysql > SOURCE 'MY_MOUNTEND_BACKUP_DIRECCTORY/MY_BACKUP_SQL_FILE';`

