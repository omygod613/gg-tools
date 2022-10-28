kubectl get secret --namespace devns3 isliao-mysql -o jsonpath="{.data.mysql-root-password}" | base64 -d
kubectl exec -it isliao-mysql-0 -- bash
mysql -h isliao-mysql.devns3.svc.cluster.local -uroot -proot_password


# MySQL
create database `source_database` default character set utf8mb4 collate utf8mb4_unicode_ci;

use source_database;

CREATE TABLE `source_users` (
`id` INT(11) NOT NULL AUTO_INCREMENT,
`username` VARCHAR(20) NOT NULL,   
`nickname` VARCHAR(20) NOT NULL,   
PRIMARY KEY (`id`) 
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

use source_database;
INSERT INTO source_users(`username`, `nickname`) VALUES('pppp', 'polar bear');
INSERT INTO source_users(`username`, `nickname`) VALUES('llll', 'laugh');
INSERT INTO source_users(`username`, `nickname`) VALUES('dddd', 'dandan');
INSERT INTO source_users(`username`, `nickname`) VALUES('ooooo', 'xxxxx');

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

kubectl port-forward svc/isliao-kafka-connect-cp-kafka-connect 8083:8083

http://localhost:8083/connector-plugins
http://localhost:8083/connectors




curl -X POST -H 'Content-Type: application/json' -i 'http://127.0.0.1:8083/connectors' \
--data \
'{
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
}'

curl http://localhost:8083/connectors/source-mysql-connector/status
curl -X DELETE  -i 'http://127.0.0.1:8083/connectors/source-mysql-connector' 






kafka-topics.sh --bootstrap-server=localhost:9092 --list
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-mysql-source_users --from-beginning

kubectl exec -it isliao-mariadb-0 bash
mysql -h isliao-mariadb.devns3.svc.cluster.local -uroot -proot_password

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
        "database.include.list": "source_database", 
        "database.history.kafka.bootstrap.servers": "isliao-kafka.devns3.svc.cluster.local:9092", 
        "database.history.kafka.topic": "schema-changes.source_database",
        "include.schema.changes": "true"
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
        "connection.url": "jdbc:mysql://isliao-mariadb.devns3.svc.cluster.local:3306/target_database",
        "key.converter": "org.apache.kafka.connect.storage.StringConverter",
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

http://127.0.0.1:8083/connectors/target-mariadb-connector
