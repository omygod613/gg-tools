FROM confluentinc/cp-kafka-connect:6.1.8

USER root

ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"
RUN confluent-hub install --no-prompt debezium/debezium-connector-mysql:1.9.6
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.6.0

# Install debezium for Oracle 
RUN wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-oracle/2.1.1.Final/debezium-connector-oracle-2.1.1.Final-plugin.tar.gz
RUN tar zxvf debezium-connector-oracle-2.1.1.Final-plugin.tar.gz
RUN mv debezium-connector-oracle /usr/share/java
RUN cp /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib/ojdbc8-19.7.0.0.jar /usr/share/java/debezium-connector-oracle/

# Must put the mariadb jar into jdbc folder
RUN wget https://dlm.mariadb.com/2531428/Connectors/java/connector-java-3.0.8/mariadb-java-client-3.0.8.jar
RUN mv mariadb-java-client-3.0.8.jar /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib

# Install JMX agent
RUN mkdir /opt/jmx
# curl -so jmx_prometheus_javaagent.jar https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.15.0/jmx_prometheus_javaagent-0.15.0.jar
# ref: https://github.com/debezium/debezium-examples/blob/main/monitoring/debezium-jmx-exporter/Dockerfile
# https://thedataguy.in/monitor-debezium-mysql-connector-with-prometheus-and-grafana/
COPY jmx_prometheus_javaagent.jar /opt/jmx/jmx_prometheus_javaagent.jar
COPY config.yml /opt/jmx/config.yml
COPY connect-distributed /usr/bin/connect-distributed
