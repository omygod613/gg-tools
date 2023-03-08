#!/bin/bash

BASE_DIR=$(dirname "$0")

# helm repo add airbyte https://airbytehq.github.io/helm-charts
helm upgrade --install isliao-airbyte $BASE_DIR/airbyte