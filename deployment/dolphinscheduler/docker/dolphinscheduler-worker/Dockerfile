FROM apache/dolphinscheduler-worker:3.2.0

# https://dlcdn.apache.org/zookeeper/zookeeper-3.8.3/apache-zookeeper-3.8.3-bin.tar.gz
COPY apache-zookeeper-3.8.3-bin.tar.gz /opt/dolphinscheduler/libs/
RUN tar zxvf libs/apache-zookeeper-3.8.3-bin.tar.gz --directory libs/
RUN rm libs/apache-zookeeper-3.8.3-bin.tar.gz

# https://jar-download.com/artifacts/org.springframework.boot/spring-boot-actuator-autoconfigure/2.7.11/source-code
COPY spring-boot-actuator-autoconfigure-2.7.11.tar /opt/dolphinscheduler/libs/
RUN tar zxvf libs/spring-boot-actuator-autoconfigure-2.7.11.tar --directory libs/ 
RUN rm libs/spring-boot-actuator-autoconfigure-2.7.11.tar

# https://dlcdn.apache.org//commons/text/binaries/commons-text-1.10.0-bin.tar.gz
COPY commons-text-1.10.0-bin.tar.gz /opt/dolphinscheduler/libs/
RUN tar zxvf libs/commons-text-1.10.0-bin.tar.gz --directory libs/ 
RUN rm libs/commons-text-1.10.0-bin.tar.gz

# fix CVE
RUN rm libs/zookeeper-3.8.0.jar libs/spring-boot-actuator-autoconfigure-2.7.3.jar libs/commons-text-1.8.jar




