FROM apache/dolphinscheduler-tools:3.2.0

# fix CVE
# https://dlcdn.apache.org/zookeeper/zookeeper-3.8.3/apache-zookeeper-3.8.3-bin.tar.gz
COPY zookeeper-3.8.3.jar /opt/dolphinscheduler/tools/libs/
RUN rm tools/libs/zookeeper-3.8.0.jar