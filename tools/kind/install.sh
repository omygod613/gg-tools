#!/bin/bash

curl -sLo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64 \
    && chmod +x ./kind \
    && sudo mv ./kind /usr/local/bin/kind

sudo pkill dockerd
sleep 5
kind create cluster