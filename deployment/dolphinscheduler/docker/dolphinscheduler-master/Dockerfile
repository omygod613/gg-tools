FROM apache/dolphinscheduler-master:3.2.0

# https://dlcdn.apache.org/zookeeper/zookeeper-3.8.3/apache-zookeeper-3.8.3-bin.tar.gz
COPY apache-zookeeper-3.8.3-bin.tar.gz /opt/dolphinscheduler/libs/
RUN tar zxvf libs/apache-zookeeper-3.8.3-bin.tar.gz --directory libs/
RUN rm libs/apache-zookeeper-3.8.3-bin.tar.gz
# https://jar-download.com/artifacts/org.springframework.boot/spring-boot-actuator-autoconfigure/2.7.11/source-code
COPY spring-boot-actuator-autoconfigure-2.7.11.tar /opt/dolphinscheduler/libs/
RUN tar zxvf libs/spring-boot-actuator-autoconfigure-2.7.11.tar --directory libs/ 
RUN rm libs/spring-boot-actuator-autoconfigure-2.7.11.tar

# fix CVE
RUN rm libs/zookeeper-3.8.0.jar libs/spring-boot-actuator-autoconfigure-2.7.3.jar




