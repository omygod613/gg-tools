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
wget https://d1i4a15mxbxib1.cloudfront.net/api/plugins/confluentinc/kafka-connect-jdbc/versions/10.2.1/confluentinc-kafka-connect-jdbc-10.2.1.zip
wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.20/mysql-connector-java-8.0.20.jar
unzip confluentinc-kafka-connect-jdbc-10.2.1.zip
mkdir -p kafkaConnect/lib
# mv confluentinc-kafka-connect-jdbc-10.2.1 kafkaConnect/
# mv mysql-connector-java-8.0.20.jar kafkaConnect/lib/

mv confluentinc-kafka-connect-jdbc-10.2.1 /usr/share/confluent-hub-components
mv mysql-connector-java-8.0.20.jar /usr/share/java

[{"class":"org.apache.kafka.connect.file.FileStreamSinkConnector","type":"sink","version":"6.1.0-ccs"},
{"class":"org.apache.kafka.connect.file.FileStreamSourceConnector","type":"source","version":"6.1.0-ccs"},
{"class":"org.apache.kafka.connect.mirror.MirrorCheckpointConnector","type":"source","version":"1"},
{"class":"org.apache.kafka.connect.mirror.MirrorHeartbeatConnector","type":"source","version":"1"},
{"class":"org.apache.kafka.connect.mirror.MirrorSourceConnector","type":"source","version":"1"}]