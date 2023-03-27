FROM confluentinc/cp-kafka-connect:6.1.8

USER root

ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"
RUN confluent-hub install --no-prompt debezium/debezium-connector-mysql:2.0.1
RUN confluent-hub install --no-prompt debezium/debezium-connector-sqlserver:2.0.1
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.6.0
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-s3:10.4.2
RUN confluent-hub install --no-prompt confluentinc/connect-transforms:1.4.3

# Install debezium for Oracle 
RUN wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-oracle/2.1.2.Final/debezium-connector-oracle-2.1.2.Final-plugin.tar.gz
RUN tar zxvf debezium-connector-oracle-2.1.2.Final-plugin.tar.gz
RUN mv debezium-connector-oracle /usr/share/java
RUN cp /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/ojdbc8-19.7.0.0.jar /usr/share/java/debezium-connector-oracle/

# Must put the mysql, mariadb, mssql driver into jdbc folder
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.0.32.tar.gz
RUN tar zxvf mysql-connector-j-8.0.32.tar.gz
RUN mv mysql-connector-j-8.0.32/mysql-connector-j-8.0.32.jar /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib

RUN wget https://dlm.mariadb.com/2720710/Connectors/java/connector-java-3.1.2/mariadb-java-client-3.1.2.jar
RUN mv mariadb-java-client-3.1.2.jar /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib

RUN wget https://download.microsoft.com/download/a/9/1/a91534b0-ed8c-4501-b491-e1dd0a20335a/sqljdbc_12.2.0.0_enu.tar.gz
RUN tar zxvf sqljdbc_12.2.0.0_enu.tar.gz
RUN mv sqljdbc_12.2/enu/mssql-jdbc-12.2.0.jre8.jar /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib 
RUN mv sqljdbc_12.2/enu/mssql-jdbc-12.2.0.jre11.jar /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib 


# Install JMX agent
RUN mkdir /opt/jmx
# curl -so jmx_prometheus_javaagent.jar https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.15.0/jmx_prometheus_javaagent-0.15.0.jar
# ref: https://github.com/debezium/debezium-examples/blob/main/monitoring/debezium-jmx-exporter/Dockerfile
# https://thedataguy.in/monitor-debezium-mysql-connector-with-prometheus-and-grafana/
COPY jmx_prometheus_javaagent.jar /opt/jmx/jmx_prometheus_javaagent.jar
COPY config.yml /opt/jmx/config.yml
COPY connect-distributed /usr/bin/connect-distributed
