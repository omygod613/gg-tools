#!/bin/bash

BASE_DIR=$(dirname "$0")

bash deployment/mysql/delete.sh
bash deployment/kafka-connect/delete.sh
bash deployment/kafka/delete.sh
bash deployment/kafka-ui/delete.sh
bash deployment/mariadb/delete.sh
bash deployment/schema-registry/delete.sh