#!/bin/bash

BASE_DIR=$(dirname "$0")

# helm repo add bitnami https://charts.bitnami.com/bitnami
helm install isliao-mysql $BASE_DIR/mysql