#!/bin/bash

BASE_DIR=$(dirname "$0")

VERSION="3.2.0-1"

docker build -t omygod613/dolphinscheduler-tools:${VERSION} $BASE_DIR/.
