#!/bin/bash

BASE_DIR=$(dirname "$0")

VERSION="3.2.0"

docker build -t omygod613/dolphinscheduler-api:${VERSION} $BASE_DIR/.
