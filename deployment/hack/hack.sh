# ORACLE
# sid: ORCLCDB
# sys/oracle

# SYS AS SYSDBA

alter session set "_ORACLE_SCRIPT"=true;
create user super identified by super123;
grant all PRIVILEGES to super;
# super/super123

alter session set "_ORACLE_SCRIPT"=true;
create user airbyte identified by airbyte123;
grant all PRIVILEGES to airbyte;
# airbyte/airbyte123

CREATE TABLE source_users (
id NUMBER(10) NOT NULL PRIMARY KEY,
username VARCHAR2(20) NOT NULL,   
nickname VARCHAR2(20) NOT NULL,
modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

INSERT INTO source_users(ID, username, nickname) VALUES(1, 'pppp', 'polar bear');
INSERT INTO source_users(ID, username, nickname) VALUES(2, 'llll', 'laugh');
INSERT INTO source_users(ID, username, nickname) VALUES(3, 'dddd', 'dandan');
INSERT INTO source_users(ID, username, nickname) VALUES(4, 'ooooo', 'xxxxx');



# SQL SERVER
kubectl exec -it isliao-mssql-mssql-latest- -- bash
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
apt-get update -y
apt-get install -y mssql-tools unixodbc-dev
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
sqlcmd -S localhost -U sa -P 'Toughpass1!'

USE master;  
GO 
CREATE DATABASE source_database;
CREATE DATABASE target_database;
GO
CREATE TABLE source_database.dbo.source_users (id int IDENTITY(1,1) PRIMARY KEY, username varchar(20) NOT NULL, nickname varchar(20) NOT NULL, modified_at DATETIME2 DEFAULT GETDATE() NOT NULL);
GO

INSERT INTO source_database.dbo.source_users(username, nickname) VALUES('pppp', 'polar bear');
INSERT INTO source_database.dbo.source_users(username, nickname) VALUES('llll', 'laugh');
INSERT INTO source_database.dbo.source_users(username, nickname) VALUES('dddd', 'dandan');
INSERT INTO source_database.dbo.source_users(username, nickname) VALUES('ooooo', 'xxxxx');

update source_database.dbo.source_users set username='gogo1', modified_at=GETDATE() where id=1;

select * from source_database.dbo.source_users;

# MySQL
kubectl exec -it isliao-mysql-0 -- bash
mysql -h isliao-mysql.devns3.svc.cluster.local -uroot -proot_password

create database `source_database` default character set utf8mb4 collate utf8mb4_unicode_ci;
create database `target_database` default character set utf8mb4 collate utf8mb4_unicode_ci;

CREATE TABLE `source_database`.`source_users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(20) NOT NULL,
  `nickname` VARCHAR(20) NOT NULL,
  `modified_at` DATETIME NOT NULL DEFAULT Now(),
  PRIMARY KEY (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO source_database.source_users(`username`, `nickname`) VALUES('pppp', 'polar bear');
INSERT INTO source_database.source_users(`username`, `nickname`) VALUES('llll', 'laugh');
INSERT INTO source_database.source_users(`username`, `nickname`) VALUES('dddd', 'dandan');
INSERT INTO source_database.source_users(`username`, `nickname`) VALUES('ooooo', 'xxxxx');

update source_database.source_users set username='gogo', modified_at=Now() where id=1;

select * from source_database.source_users;

# MariaDB
kubectl exec -it isliao-mariadb-0 bash
mysql -h isliao-mariadb.devns3.svc.cluster.local -uroot -proot_password

# Sink DB must create database before create DB connector (JDBC Sink Connector)
create database `source_database` default character set utf8mb4 collate utf8mb4_unicode_ci;
create database `target_database` default character set utf8mb4 collate utf8mb4_unicode_ci;

CREATE TABLE `source_database`.`source_users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(20) NOT NULL,
  `nickname` VARCHAR(20) NOT NULL,
  `modified_at` DATETIME NOT NULL DEFAULT Now(),
  PRIMARY KEY (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO source_database.source_users(`username`, `nickname`) VALUES('pppp', 'polar bear');
INSERT INTO source_database.source_users(`username`, `nickname`) VALUES('llll', 'laugh');
INSERT INTO source_database.source_users(`username`, `nickname`) VALUES('dddd', 'dandan');
INSERT INTO source_database.source_users(`username`, `nickname`) VALUES('ooooo', 'xxxxx');

update source_database.source_users set username='gogo', modified_at=Now() where id=1;

select * from source_database.source_users;

#  MiniIO
# minioadmin | minioadmin





#datahub
pip install 'acryl-datahub[kafka-connect]'