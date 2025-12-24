#!/bin/bash

BASE_DIR=$(dirname "$0")

bash $BASE_DIR/../tools/kind/install.sh
bash $BASE_DIR/../tools/autocompletion/install.sh
kubectl config set-context --current --namespace dev

# wget https://dl.pstmn.io/download/latest/linux64
# mv linux64 $BASE_DIR/../..
# tar zxvf $BASE_DIR/../../linux64 --directory $BASE_DIR/../..