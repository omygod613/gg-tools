#!/bin/bash

BASE_DIR=$(dirname "$0")

kubectl port-forward svc/isliao-kafka-connect-ui 80:8000