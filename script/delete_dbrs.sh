#!/bin/bash

kubectl config set-context --current --namespace dev

helm uninstall dbrep-kafka -n dev
helm uninstall dbrep-kafka-connect -n dev
helm uninstall dbrep-kafka-connect-ui -n dev
helm uninstall dbrep-mariadb -n dev
kubectl delete -f deployment/minio/minio-dev.yaml -n dev
helm uninstall dbrep-mssql -n dev
helm uninstall dbrep-mysql -n dev
helm uninstall dbrep-oracle -n dev