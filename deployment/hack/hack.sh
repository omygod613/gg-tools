

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
        "database.include.list": "source_database", 
        "database.history.kafka.bootstrap.servers": "isliao-kafka.devns3.svc.cluster.local:9092", 
        "database.history.kafka.topic": "schema-changes.source_database",
        "include.schema.changes": "false"
    }
}

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
        "transforms": "unwrap",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "transforms.unwrap.drop.tombstones": "false",
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter.schemas.enable": "false",
        "value.converter.schemas.enable": "false"
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

{
    "name": "target-mariadb-connector",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "tasks.max": 1,
        "connection.url": "jdbc:mysql://isliao-mariadb.devns3.svc.cluster.local:3306/target_database",
        "connection.user": "root",
        "connection.password": "root_password",
        "topics": "source.source_database.source_users",
        "auto.create": "false",
        "autoevolve": "false",
        "insert.mode.databaselevel": "true",
        "insert.mode": "upsert",
        "pk.mode": "record_key",
        "pk.fields": "id",
        "table.name.format": "target_users",
        "delete.enabled": "true",
    }
}


{
    "name": "target-mariadb-connector",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "tasks.max": 1,
        "connection.url": "jdbc:mariadb://isliao-mariadb.devns3.svc.cluster.local:3306/target_database",
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter.schema.registry.url": "http://isliao-schema-registry-cp-schema-registry.devns3.svc.cluster.local:8081",
        "value.converter": "io.confluent.connect.avro.AvroConverter",
        "key.converter.schemas.enable": "true",
        "value.converter.schemas.enable": "true",
        "config.action.reload": "restart",
        "errors.log.enable": "true",
        "errors.log.include.messages": "true",
        "connection.user": "root",
        "connection.password": "root_password",
        "topics": "source.source_database.source_users",
        "auto.create": "true",
        "insert.mode": "upsert",
        "pk.mode": "record_value",
        "pk.fields": "id",
        "table.name.format": "target_users"
    }
}

{
    "name": "target-mariadb-connector",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "tasks.max": 1,
        "connection.url": "jdbc:mariadb://isliao-mariadb.devns3.svc.cluster.local:3306/target_database",
        "connection.user": "root",
        "connection.password": "root_password",
        "topics": "source.source_database.source_users",
        "auto.create": "true",
        "insert.mode": "upsert",
        "pk.mode": "record_value",
        "pk.fields": "id",
        "table.name.format": "target_users"
    }
}

{
    "name": "target-mariadb-connector",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "tasks.max": 1,
        "connection.url": "jdbc:mariadb://isliao-mariadb.devns3.svc.cluster.local:3306/target_database",
        "key.converter.schema.registry.url": "http://isliao-schema-registry-cp-schema-registry.devns3.svc.cluster.local:8081",
        "value.converter.schema.registry.url": "http://isliao-schema-registry-cp-schema-registry.devns3.svc.cluster.local:8081",
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter.schemas.enable": "false",
        "value.converter.schemas.enable": "false",
        "config.action.reload": "restart",
        "errors.log.enable": "true",
        "errors.log.include.messages": "true",
        "connection.user": "root",
        "connection.password": "root_password",
        "topics": "source.source_database.source_users",
        "auto.create": "true",
        "insert.mode": "upsert",
        "pk.mode": "record_value",
        "pk.fields": "id",
        "table.name.format": "target_users",
        "insert.mode.databaselevel": "true"
    }
}
http://127.0.0.1:8083/connectors/target-mariadb-connector
