#!/bin/bash

helm uninstall isliao-mysql
kubectl delete pvc data-isliao-mysql-0