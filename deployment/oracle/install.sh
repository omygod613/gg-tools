#!/bin/bash

BASE_DIR=$(dirname "$0")

# if [ ! -z $1 ] && [ ! -z $2 ] && [ ! -z $3 ] 
# then 
#     kubectl create secret docker-registry regcred --docker-server=container-registry.oracle.com --docker-username=$1 --docker-password=$2 --docker-email=$3
#     helm install dbrep-oracle $BASE_DIR/oracle-db
# else
#     echo "docker-username, dokcer-password, docker-email are required."
# fi

helm install dbrep-oracle $BASE_DIR/oracle-db

# helm repo add oracle https://oracle.github.io/helm-charts
# docker login container-registry.oracle.com

# https://www.oracle.com/java/technologies/downloads/
# https://www.oracle.com/database/sqldeveloper/technologies/download/
