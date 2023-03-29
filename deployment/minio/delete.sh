#!/bin/bash

BASE_DIR=$(dirname "$0")

kubectl delete -f $BASE_DIR/minio/minio-dev.yaml
