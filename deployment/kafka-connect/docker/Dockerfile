FROM confluentinc/cp-kafka-connect:7.6.1

USER root

ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.6.4
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-s3:10.5.12
RUN confluent-hub install --no-prompt confluentinc/connect-transforms:1.4.6
RUN confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:1.13.0

# Install debezium for Oracle 
RUN wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-oracle/2.6.1.Final/debezium-connector-oracle-2.6.1.Final-plugin.tar.gz
RUN tar zxvf debezium-connector-oracle-2.6.1.Final-plugin.tar.gz -C /usr/share/java/
RUN wget https://repo1.maven.org/maven2/com/oracle/database/xml/xdb/21.11.0.0/xdb-21.11.0.0.jar -P /usr/share/java/debezium-connector-oracle/
# Install debezium for MySQL 
RUN wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/2.6.1.Final/debezium-connector-mysql-2.6.1.Final-plugin.tar.gz
RUN tar zxvf debezium-connector-mysql-2.6.1.Final-plugin.tar.gz -C /usr/share/java/
# Install debezium for SQLServer
RUN wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-sqlserver/2.6.1.Final/debezium-connector-sqlserver-2.6.1.Final-plugin.tar.gz
RUN tar zxvf debezium-connector-sqlserver-2.6.1.Final-plugin.tar.gz -C /usr/share/java/
# Install debezium for MongoDB
RUN wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-mongodb/2.6.2.Final/debezium-connector-mongodb-2.6.2.Final-plugin.tar.gz
RUN tar zxvf debezium-connector-mongodb-2.6.2.Final-plugin.tar.gz -C /usr/share/java/

# Must put the mysql, mariadb, clickhouse, sqlserver driver into jdbc folder
## mysql
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.0.32.tar.gz
RUN tar zxvf mysql-connector-j-8.0.32.tar.gz -C /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib
## mariadb
RUN wget https://dlm.mariadb.com/2720710/Connectors/java/connector-java-3.1.2/mariadb-java-client-3.1.2.jar -P /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/
## clickhouse
RUN wget https://github.com/ClickHouse/clickhouse-java/releases/download/v0.4.6/clickhouse-jdbc-0.4.6.jar -P /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/
## sqlserver
RUN wget https://download.microsoft.com/download/9/e/9/9e97cef4-4c64-484c-bd1b-192147912c47/enu/sqljdbc_12.6.1.0_enu.tar.gz
RUN tar zxvf sqljdbc_12.6.1.0_enu.tar.gz -C /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib
RUN mv /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/sqljdbc_12.6/enu/jars/* /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/

# Install JMX agent
# ref: https://github.com/debezium/debezium-examples/blob/main/monitoring/debezium-jmx-exporter/Dockerfile
# https://thedataguy.in/monitor-debezium-mysql-connector-with-prometheus-and-grafana/
RUN mkdir /opt/jmx
RUN wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/1.0.1/jmx_prometheus_javaagent-1.0.1.jar -O /opt/jmx/jmx_prometheus_javaagent.jar
COPY config.yml /opt/jmx/config.yml
COPY connect-distributed /usr/bin/connect-distributed
