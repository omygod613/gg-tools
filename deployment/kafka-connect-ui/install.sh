#!/bin/bash

BASE_DIR=$(dirname "$0")

# helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
helm install dbrep-kafka-connect-ui $BASE_DIR/kafka-connect-ui