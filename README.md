# docker-compose-mariadb
Simple Docker Compose stack to run a mariadb database with custom configuration and automated backup script. 

* uses Docker secrets based on file mounts
* backup script & container creates configurable daily backups of all databases


## How to restore Database
* unpack sql backup file in backup directoy
* restore database: `cat MY_BACKUP_DIRECCTORY/MY_BACKUP_SQL_FILE | docker exec -i ID_OF_DOCKER_CONTAINER mysql -uroot --password=MY_ROOT_PASSWORD MY_DATABASE_NAME`
