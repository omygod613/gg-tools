#!/bin/bash

BASE_DIR=$(dirname "$0")

kubectl port-forward svc/isliao-kafka-connect-cp-kafka-connect 8083:8083
kubectl port-forward svc/isliao-kafka-ui 8080:80
kubectl port-forward svc/isliao-kafka-connect-ui 80:80