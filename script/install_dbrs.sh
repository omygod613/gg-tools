#!/bin/bash

BASE_DIR=$(dirname "$0")

kubectl create ns dev
kubectl config set-context --current --namespace dev

bash deployment/kafka-connect/install.sh
bash deployment/kafka-connect-ui/install.sh
bash deployment/kafka/install.sh
bash deployment/mysql/install.sh
bash deployment/mssql/install.sh
bash deployment/mariadb/install.sh
bash deployment/oracle/install.sh
bash deployment/minio/install.sh
