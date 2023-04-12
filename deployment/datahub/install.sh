#!/bin/bash

BASE_DIR=$(dirname "$0")

# helm repo add datahub https://helm.datahubproject.io/
# helm install prerequisites datahub/datahub-prerequisites
# helm install prerequisites datahub/datahub-prerequisites --values <<path-to-values-file>>
# helm install datahub datahub/datahub
kubectl create secret generic mysql-secrets --from-literal=mysql-root-password=datahub
kubectl create secret generic neo4j-secrets --from-literal=neo4j-password=datahub
helm install isliao-datahub-prerequisites $BASE_DIR/datahub-prerequisites
helm install isliao-datahub $BASE_DIR/datahub