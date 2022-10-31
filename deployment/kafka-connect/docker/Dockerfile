FROM confluentinc/cp-kafka-connect:6.1.0

USER root

RUN yum install zip -y

ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"
RUN confluent-hub install --no-prompt debezium/debezium-connector-mysql:1.9.6
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.6.0
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-oracle-cdc:2.2.2

# Must put the mariadb jar into jdbc folder
RUN wget https://dlm.mariadb.com/2531428/Connectors/java/connector-java-3.0.8/mariadb-java-client-3.0.8.jar
RUN mv mariadb-java-client-3.0.8.jar /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib