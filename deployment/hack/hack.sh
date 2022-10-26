kubectl get secret --namespace devns3 isliao-mysql -o jsonpath="{.data.mysql-root-password}" | base64 -d
kubectl exec -it isliao-mysql-0 -- bash
mysql -h isliao-mysql.devns3.svc.cluster.local -uroot -p


# MySQL
create database `source_database` default character set utf8mb4 collate utf8mb4_unicode_ci;
create database `target_database` default character set utf8mb4 collate utf8mb4_unicode_ci;

use source_database;

CREATE TABLE `source_users` (
`id` INT(11) NOT NULL AUTO_INCREMENT,
`username` VARCHAR(20) NOT NULL,   
`nickname` VARCHAR(20) NOT NULL,   
PRIMARY KEY (`id`) 
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

use target_database;

CREATE TABLE `target_users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(20) NOT NULL,
  `nickname` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

# Kafka Connect
# wget https://d1i4a15mxbxib1.cloudfront.net/api/plugins/confluentinc/kafka-connect-jdbc/versions/10.2.1/confluentinc-kafka-connect-jdbc-10.2.1.zip
# unzip confluentinc-kafka-connect-jdbc-10.2.1.zip
# kubectl cp confluentinc-kafka-connect-jdbc-10.2.1 devns3/isliao-kafka-connect-cp-kafka-connect-7584f4d49d-lrkph:/home/appuser -c cp-kafka-connect-server 
# mkdir -p kafkaConnect/lib
# mv confluentinc-kafka-connect-jdbc-10.2.1 kafkaConnect/
# mv mysql-connector-java-8.0.20.jar kafkaConnect/lib/

# kubectl exec -it isliao-kafka-connect-cp-kafka-connect-7584f4d49d-lrkph -c cp-kafka-connect-server -- bash
# wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.20/mysql-connector-java-8.0.20.jar

# mv confluentinc-kafka-connect-jdbc-10.2.1 /usr/share/confluent-hub-components
# mv mysql-connector-java-8.0.20.jar /usr/share/java


kubectl exec -it isliao-kafka-connect-cp-kafka-connect-7584f4d49d-lrkph -c cp-kafka-connect-server -- bash
# https://www.confluent.io/hub/
# confluent-hub install debezium/debezium-connector-mysql:1.9.6
# confluent-hub install confluentinc/kafka-connect-jdbc:10.6.0
# confluent-hub install confluentinc/kafka-connect-oracle-cdc:2.2.2
# connect-distributed /etc/kafka-connect/kafka-connect.properties

kubectl port-forward svc/isliao-kafka-connect-cp-kafka-connect 8083:8083

http://127.0.0.1:8083/connector-plugins
http://localhost:8083/connectors


curl -X POST -H 'Content-Type: application/json' -i 'http://127.0.0.1:8083/connectors' \
--data \
'{
    "name": "source-mysql", 
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
        "database.history.kafka.topic": "schema-changes.source_database"
    }
}'

curl -X DELETE  -i 'http://127.0.0.1:8083/connectors/source-mysql' 


INSERT INTO source_users(`username`, `nickname`) VALUES('小熊維尼', 'polar bear');
INSERT INTO source_users(`username`, `nickname`) VALUES('大谷翔平', '笑死');
INSERT INTO source_users(`username`, `nickname`) VALUES('鄧不利多', '校長');
INSERT INTO source_users(`username`, `nickname`) VALUES('ooooo', 'xxxxx');



kafka-topics.sh --bootstrap-server=localhost:9092 --list
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-mysql-source_users --from-beginning