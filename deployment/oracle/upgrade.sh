#!/bin/bash

BASE_DIR=$(dirname "$0")

# helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/

kubectl delete secrets regcred
helm upgrade --install dbrep-oracle $BASE_DIR/oracle