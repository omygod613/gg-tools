#!/bin/bash

BASE_DIR=$(dirname "$0")

# Kafka 4.0 with KRaft mode (no Zookeeper required)
helm upgrade --install dbrep-kafka $BASE_DIR/kafka -f $BASE_DIR/values-kraft.yaml