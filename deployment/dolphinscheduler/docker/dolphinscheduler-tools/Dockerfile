FROM apache/dolphinscheduler-tools:3.2.0

# https://dlcdn.apache.org/zookeeper/zookeeper-3.8.3/apache-zookeeper-3.8.3-bin.tar.gz
COPY apache-zookeeper-3.8.3-bin.tar.gz /opt/dolphinscheduler/tools/libs/
RUN tar zxvf tools/libs/apache-zookeeper-3.8.3-bin.tar.gz --directory tools/libs/
RUN rm tools/libs/apache-zookeeper-3.8.3-bin.tar.gz
# https://jar-download.com/artifacts/org.springframework.boot/spring-boot-actuator-autoconfigure/2.7.11/source-code
COPY spring-boot-actuator-autoconfigure-2.7.11.tar /opt/dolphinscheduler/tools/libs/
RUN tar zxvf tools/libs/spring-boot-actuator-autoconfigure-2.7.11.tar --directory tools/libs/ 
RUN rm tools/libs/spring-boot-actuator-autoconfigure-2.7.11.tar

RUN ls tools/libs/
# fix CVE
RUN rm tools/libs/zookeeper-3.8.0.jar




