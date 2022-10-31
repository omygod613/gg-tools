#!/bin/bash

BASE_DIR=$(dirname "$0")

kubectl config set-context --current --namespace devns3

wget https://dl.pstmn.io/download/latest/linux64
mv linux64 $BASE_DIR/../..
tar zxvf $BASE_DIR/../../linux64 --directory $BASE_DIR/../..