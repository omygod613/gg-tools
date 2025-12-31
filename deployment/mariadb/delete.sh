#!/bin/bash

helm uninstall dbrep-mariadb
kubectl delete pvc data-dbrep-mariadb-0