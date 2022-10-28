#!/bin/bash

helm uninstall isliao-mariadb
kubectl delete pvc data-isliao-mariadb-0