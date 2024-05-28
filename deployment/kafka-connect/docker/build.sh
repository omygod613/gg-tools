#!/bin/bash

BASE_DIR=$(dirname "$0")

VERSION="7.6.1-20240528"

docker build -t omygod613/cp-kafka-connect:${VERSION} $BASE_DIR/.

# kind load docker-image omygod613/cp-kafka-connect:${VERSION}