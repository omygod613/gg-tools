#!/bin/bash

kubectl create ns dev
kubectl config set-context --current --namespace dev

helm install dbrep-kafka deployment/kafka -f deployment/kafka/values-kraft.yaml -n dev
helm install dbrep-kafka-connect deployment/kafka-connect -f deployment/kafka-connect/values.yaml -n dev
helm install dbrep-kafka-connect-ui deployment/kafka-connect-ui -f deployment/kafka-connect-ui/values.yaml -n dev
helm install dbrep-mariadb deployment/mariadb -f deployment/mariadb/values.yaml -n dev
kubectl apply -f deployment/minio/minio-dev.yaml -n dev
helm install dbrep-mssql deployment/mssql -f deployment/mssql/values.yaml -n dev
helm install dbrep-mysql deployment/mysql -f deployment/mysql/values.yaml -n dev
helm install dbrep-oracle deployment/oracle -f deployment/oracle/values.yaml -n dev
