#!/bin/bash

BASE_DIR=$(dirname "$0")

VERSION="6.1.8-20230315"

docker build -t omygod613/cp-kafka-connect:${VERSION} $BASE_DIR/.
