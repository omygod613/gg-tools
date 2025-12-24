#!/bin/bash

BASE_DIR=$(dirname "$0")

kubectl create ns devns3
kubectl config set-context --current --namespace devns3

bash deployment/kafka-connect/install.sh
bash deployment/kafka-connect-ui/install.sh
bash deployment/kafka/install.sh
bash deployment/mysql/install.sh
bash deployment/mssql/install.sh
bash deployment/mariadb/install.sh
bash deployment/oracle/install.sh
bash deployment/minio/install.sh

bash deployment/datahub/install_datahub_prerequisites.sh
# bash deployment/datahub/install_datahub.sh