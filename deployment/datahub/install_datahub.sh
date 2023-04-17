#!/bin/bash

BASE_DIR=$(dirname "$0")

# helm repo add datahub https://helm.datahubproject.io/
# helm install prerequisites datahub/datahub-prerequisites
# helm install prerequisites datahub/datahub-prerequisites --values <<path-to-values-file>>
helm install isliao-datahub $BASE_DIR/datahub