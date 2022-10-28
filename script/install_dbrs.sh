#!/bin/bash

BASE_DIR=$(dirname "$0")

bash deployment/mysql/install.sh
bash deployment/kafka-connect/install.sh
bash deployment/kafka/install.sh
bash deployment/kafka-ui/install.sh
bash deployment/mariadb/install.sh
bash deployment/schema-registry/install.sh