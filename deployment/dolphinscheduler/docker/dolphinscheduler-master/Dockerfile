FROM apache/dolphinscheduler-master:3.2.0

# fix CVE
# https://dlcdn.apache.org/zookeeper/zookeeper-3.8.3/apache-zookeeper-3.8.3-bin.tar.gz
COPY zookeeper-3.8.3.jar /opt/dolphinscheduler/libs/
# https://jar-download.com/artifacts/org.springframework.boot/spring-boot-actuator-autoconfigure/2.7.11/source-code
COPY spring-boot-actuator-autoconfigure-2.7.11.jar /opt/dolphinscheduler/libs/
RUN rm libs/zookeeper-3.8.0.jar libs/spring-boot-actuator-autoconfigure-2.7.3.jar