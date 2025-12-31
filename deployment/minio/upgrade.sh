#!/bin/bash

BASE_DIR=$(dirname "$0")

kubectl apply -f $BASE_DIR/minio/minio-dev.yaml
