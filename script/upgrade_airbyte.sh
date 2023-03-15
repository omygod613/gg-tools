#!/bin/bash

BASE_DIR=$(dirname "$0")

bash deployment/mysql/upgrade.sh
bash deployment/airbyte/upgrade.sh
bash deployment/mariadb/upgrade.sh
