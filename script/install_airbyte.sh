#!/bin/bash

BASE_DIR=$(dirname "$0")

kubectl create ns devns3
kubectl config set-context --current --namespace devns3

bash deployment/airbyte/install.sh
bash deployment/mysql/install.sh
bash deployment/mariadb/install.sh
bash deployment/mssql/install.sh
bash deployment/oracle/install.sh
bash deployment/minio/install.sh