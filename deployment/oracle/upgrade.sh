#!/bin/bash

BASE_DIR=$(dirname "$0")

# helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/

kubectl delete secrets regcred
helm upgrade --install isliao-oracle $BASE_DIR/oracle