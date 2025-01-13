#!/bin/bash

BASE_DIR=$(dirname "$0")

VERSION="v1.1.3-rc1"

docker build -t omygod613/duckdb:${VERSION} $BASE_DIR/.