#!/bin/bash

BASE_DIR=$(dirname "$0")

VERSION="3.2.0-1"

docker build -t omygod613/dolphinscheduler-alert-server:${VERSION} $BASE_DIR/.
