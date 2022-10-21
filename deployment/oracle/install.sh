#!/bin/bash

BASE_DIR=$(dirname "$0")

helm repo add oracle https://oracle.github.io/helm-charts
helm install isliao-oracle oracle/<chart_name> \
  --set <parameters>...
helm install isliao-debezium $BASE_DIR/debezium