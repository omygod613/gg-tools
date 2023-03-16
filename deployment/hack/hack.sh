
# SQL SERVER
kubectl exec -it isliao-mssql-mssql-latest-6549cbc9f8-jwwsq -- bash
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
GO
CREATE TABLE source_users (id int IDENTITY(1,1) PRIMARY KEY, username varchar(20) NOT NULL, nickname varchar(20) NOT NULL);
GO

INSERT INTO source_users(username, nickname) VALUES('pppp', 'polar bear');
INSERT INTO source_users(username, nickname) VALUES('llll', 'laugh');
INSERT INTO source_users(username, nickname) VALUES('dddd', 'dandan');
INSERT INTO source_users(username, nickname) VALUES('ooooo', 'xxxxx');

# MySQL
kubectl exec -it isliao-mysql-0 -- bash
mysql -h isliao-mysql.devns3.svc.cluster.local -uroot -proot_password

create database `source_database` default character set utf8mb4 collate utf8mb4_unicode_ci;

use source_database;

CREATE TABLE `source_users` (
`id` INT(11) NOT NULL AUTO_INCREMENT,
`username` VARCHAR(20) NOT NULL,   
`nickname` VARCHAR(20) NOT NULL,   
PRIMARY KEY (`id`) 
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO source_users(`username`, `nickname`) VALUES('pppp', 'polar bear');
INSERT INTO source_users(`username`, `nickname`) VALUES('llll', 'laugh');
INSERT INTO source_users(`username`, `nickname`) VALUES('dddd', 'dandan');
INSERT INTO source_users(`username`, `nickname`) VALUES('ooooo', 'xxxxx');


# MariaDB
kubectl exec -it isliao-mariadb-0 bash
mysql -h isliao-mariadb.devns3.svc.cluster.local -uroot -proot_password

# Sink DB must create database before create DB connector
create database `target_database` default character set utf8mb4 collate utf8mb4_unicode_ci;

use target_database;

CREATE TABLE `target_users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(20) NOT NULL,
  `nickname` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


kubectl exec -it isliao-kafka-connect-cp-kafka-connect-7584f4d49d-lrkph -c cp-kafka-connect-server -- bash
# https://www.confluent.io/hub/
# confluent-hub install debezium/debezium-connector-mysql:1.9.6
# confluent-hub install confluentinc/kafka-connect-jdbc:10.6.0
# confluent-hub install confluentinc/kafka-connect-oracle-cdc:2.2.2
# connect-distributed /etc/kafka-connect/kafka-connect.properties


kafka-topics.sh --bootstrap-server=localhost:9092 --list
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-mysql-source_users --from-beginning



http://localhost:8083/connector-plugins
http://localhost:8083/connectors
http://localhost:8083/connectors/source-mysql-connector/status

http://localhost:8083/connectors
{
    "name": "source-mysql-connector", 
    "config": {
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "tasks.max": "1",
        "database.hostname": "isliao-mysql.devns3.svc.cluster.local", 
        "database.port": "3306", 
        "database.user": "root", 
        "database.password": "root_password", 
        "database.server.id": "1", 
        "database.server.name": "source", 
        "database.history.kafka.bootstrap.servers": "isliao-kafka.devns3.svc.cluster.local:9092", 
        "database.history.kafka.topic": "schema-changes.source_database",
        "database.include.list": "source_database", 
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter.schemas.enable": "true",
        "value.converter.schemas.enable": "true",
        "transforms": "unwrap",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "transforms.unwrap.drop.tombstones": "false"
    }
}


http://127.0.0.1:8083/connectors/source-mysql-connector


http://localhost:8083/connectors/target-mariadb-connector/status
http://localhost:8083/connectors
{
    "name": "target-mariadb-connector",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "tasks.max": 1,
        "connection.url": "jdbc:mariadb://isliao-mariadb.devns3.svc.cluster.local:3306/target_database",
        "connection.user": "root",
        "connection.password": "root_password",
        "topics": "source.source_database.source_users",
        "table.name.format": "target_users",
        "auto.create": "false",
        "autoevolve": "false",
        "insert.mode": "upsert",
        "delete.enabled": "true",
        "pk.fields": "id",
        "pk.mode": "record_key",
        "value.converter.schema.registry.url": "http://isliao-schema-registry-cp-schema-registry.devns3.svc.cluster.local:8081",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter.schemas.enable": "true",
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter.schemas.enable": "true"
    }
}

http://127.0.0.1:8083/connectors/target-mariadb-connector
