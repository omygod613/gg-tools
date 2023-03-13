#!/bin/bash

BASE_DIR=$(dirname "$0")

bash deployment/mysql/install.sh
bash deployment/airbyte/install.sh
bash deployment/mariadb/install.sh
