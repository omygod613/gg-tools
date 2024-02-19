#!/bin/bash

BASE_DIR=$(dirname "$0")

VERSION="6.1.8-20230726"

docker build -t omygod613/cp-kafka-connect:${VERSION} $BASE_DIR/.

kind load docker-image omygod613/cp-kafka-connect:${VERSION}