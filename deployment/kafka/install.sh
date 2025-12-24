#!/bin/bash

BASE_DIR=$(dirname "$0")

# Kafka 4.0 with KRaft mode (no Zookeeper required)
# helm repo add bitnami https://charts.bitnami.com/bitnami
helm install isliao-kafka $BASE_DIR/kafka -f $BASE_DIR/values-kraft.yaml