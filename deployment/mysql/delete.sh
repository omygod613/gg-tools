#!/bin/bash

helm uninstall dbrep-mysql
kubectl delete pvc data-dbrep-mysql-0