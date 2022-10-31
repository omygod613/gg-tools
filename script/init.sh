#!/bin/bash

BASE_DIR=$(dirname "$0")

kubectl config set-context --current --namespace devns3

wget https://dl.pstmn.io/download/latest/linux64
tar zxvf postman-linux-x64.tar.gz