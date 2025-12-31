# ORACLE
# sid: ORCLCDB
# sys/oracle

# SYS AS SYSDBA

alter session set "_ORACLE_SCRIPT"=true;
create user root identified by root_password;
grant all PRIVILEGES to root;
grant dba to root;
# root/root_password

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

# ===== ORACLE DEBEZIUM CDC SETUP =====
# Connect as SYS to CDB (ORCLCDB)
# sqlplus sys/oracle@localhost:1521/ORCLCDB as sysdba

# Create Debezium common user (CDB level)
alter session set "_ORACLE_SCRIPT"=true;
CREATE USER c##dbzuser IDENTIFIED BY dbz DEFAULT TABLESPACE users QUOTA UNLIMITED ON users CONTAINER=ALL;

# Grant LogMiner privileges (CDB level)
GRANT CREATE SESSION TO c##dbzuser CONTAINER=ALL;
GRANT SET CONTAINER TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$DATABASE TO c##dbzuser CONTAINER=ALL;
GRANT FLASHBACK ANY TABLE TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ANY TABLE TO c##dbzuser CONTAINER=ALL;
GRANT SELECT_CATALOG_ROLE TO c##dbzuser CONTAINER=ALL;
GRANT EXECUTE_CATALOG_ROLE TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ANY TRANSACTION TO c##dbzuser CONTAINER=ALL;
GRANT LOGMINING TO c##dbzuser CONTAINER=ALL;
GRANT CREATE TABLE TO c##dbzuser CONTAINER=ALL;
GRANT LOCK ANY TABLE TO c##dbzuser CONTAINER=ALL;
GRANT CREATE SEQUENCE TO c##dbzuser CONTAINER=ALL;
GRANT EXECUTE ON DBMS_LOGMNR TO c##dbzuser CONTAINER=ALL;
GRANT EXECUTE ON DBMS_LOGMNR_D TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$LOG TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$LOG_HISTORY TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$LOGMNR_LOGS TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$LOGMNR_CONTENTS TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$LOGMNR_PARAMETERS TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$LOGFILE TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$ARCHIVED_LOG TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$ARCHIVE_DEST_STATUS TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$TRANSACTION TO c##dbzuser CONTAINER=ALL;

# Connect to PDB (ORCLPDB1)
# sqlplus sys/oracle@localhost:1521/ORCLPDB1 as sysdba
ALTER SESSION SET CONTAINER=ORCLPDB1;

# Create DEMO schema in PDB
CREATE USER DEMO IDENTIFIED BY demo123 DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
GRANT CONNECT, RESOURCE TO DEMO;
GRANT CREATE SESSION TO DEMO;

# Create SOURCE_ORDERS table
CREATE TABLE DEMO.SOURCE_ORDERS (
    ID NUMBER(10) NOT NULL PRIMARY KEY,
    ORDER_NO VARCHAR2(50) NOT NULL,
    CUSTOMER_NAME VARCHAR2(100) NOT NULL,
    AMOUNT NUMBER(15,2) NOT NULL,
    STATUS VARCHAR2(20) DEFAULT 'PENDING' NOT NULL,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    MODIFIED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

# Enable supplemental logging for the table (required for Debezium)
ALTER TABLE DEMO.SOURCE_ORDERS ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;

# Insert test data
INSERT INTO DEMO.SOURCE_ORDERS(ID, ORDER_NO, CUSTOMER_NAME, AMOUNT, STATUS) VALUES(1, 'ORD-001', 'Alice', 1500.00, 'PENDING');
INSERT INTO DEMO.SOURCE_ORDERS(ID, ORDER_NO, CUSTOMER_NAME, AMOUNT, STATUS) VALUES(2, 'ORD-002', 'Bob', 2300.50, 'COMPLETED');
INSERT INTO DEMO.SOURCE_ORDERS(ID, ORDER_NO, CUSTOMER_NAME, AMOUNT, STATUS) VALUES(3, 'ORD-003', 'Charlie', 890.00, 'PENDING');
INSERT INTO DEMO.SOURCE_ORDERS(ID, ORDER_NO, CUSTOMER_NAME, AMOUNT, STATUS) VALUES(4, 'ORD-004', 'Diana', 4200.75, 'SHIPPED');
COMMIT;

# Test update (for CDC testing)
# UPDATE DEMO.SOURCE_ORDERS SET STATUS='COMPLETED', MODIFIED_AT=CURRENT_TIMESTAMP WHERE ID=1;
# COMMIT;



# SQL SERVER
kubectl exec -it dbrep-mssql-mssql-latest- -- bash
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
kubectl exec -it dbrep-mysql-0 -- bash
mysql -h dbrep-mysql.devns3.svc.cluster.local -uroot -proot_password

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
kubectl exec -it dbrep-mariadb-0 bash
mysql -h dbrep-mariadb.devns3.svc.cluster.local -uroot -proot_password

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

CREATE TABLE `target_database`.`target_users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(20) NOT NULL,
  `nickname` VARCHAR(20) NOT NULL,
  `modified_at` DATETIME NOT NULL DEFAULT Now(),
  PRIMARY KEY (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

# ===== Oracle CDC Sink (target_orders) =====
# Note: With auto.create=true in sink connector, table is created automatically.
# Below is the expected schema for reference:
CREATE TABLE `target_database`.`target_orders` (
  `ID` INT NOT NULL,
  `ORDER_NO` VARCHAR(50) NOT NULL,
  `CUSTOMER_NAME` VARCHAR(100) NOT NULL,
  `AMOUNT` DECIMAL(15,2) NOT NULL,
  `STATUS` VARCHAR(20) NOT NULL,
  `CREATED_AT` DATETIME(6) NOT NULL,
  `MODIFIED_AT` DATETIME(6) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

# Verify CDC replication
# select * from target_database.target_orders;

update source_database.source_users set username='gogo', modified_at=Now() where id=1;

select * from source_database.source_users;

#  MiniIO
# minioadmin | minioadmin





#datahub
