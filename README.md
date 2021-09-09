# docker-compose-mariadb
Simple Docker Compose stack to run a mariadb database with custom configuration and automated backup script. 

* uses Docker secrets based on file mounts
* backup script & container creates configurable daily backups of all databases
