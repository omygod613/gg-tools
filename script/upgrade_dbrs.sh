#!/bin/bash

BASE_DIR=$(dirname "$0")

# bash deployment/mysql/upgrade.sh
bash deployment/mssql/upgrade.sh
bash deployment/kafka-connect/upgrade.sh
bash deployment/kafka-connect-ui/upgrade.sh
bash deployment/kafka/upgrade.sh
bash deployment/kafka-ui/upgrade.sh
bash deployment/mariadb/upgrade.sh
# bash deployment/schema-registry/upgrade.sh