#!/bin/bash

BASE_DIR=$(dirname "$0")

# helm repo add datahub https://helm.datahubproject.io/
# helm install prerequisites datahub/datahub-prerequisites
# helm install prerequisites datahub/datahub-prerequisites --values <<path-to-values-file>>
# helm install datahub datahub/datahub
helm upgrade --install isliao-datahub-prerequisites $BASE_DIR/datahub-prerequisites
helm upgrade --install isliao-datahub $BASE_DIR/datahub