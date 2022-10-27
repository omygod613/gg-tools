#!/bin/bash

BASE_DIR=$(dirname "$0")

# helm repo add kafka-ui https://provectus.github.io/kafka-ui
helm install isliao-kafka-ui $BASE_DIR/kafka-ui