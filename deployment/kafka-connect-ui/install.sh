#!/bin/bash

BASE_DIR=$(dirname "$0")

# helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
helm install isliao-kafka-connect $BASE_DIR/kafka-connect