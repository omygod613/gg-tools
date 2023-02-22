#!/bin/bash

curl -sLo ./helm.tar.gz https://get.helm.sh/helm-v3.9.3-linux-amd64.tar.gz \
    && tar -zxvf helm.tar.gz linux-amd64/helm \
    --strip-components 1 && sudo mv ./helm /usr/local/bin/ \
    && rm ./helm.tar.gz