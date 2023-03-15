#!/bin/bash

curl -sLo ./docker-buildx https://github.com/docker/buildx/releases/download/v0.9.1/buildx-v0.9.1.linux-amd64 \
    && chmod +x ./docker-buildx \
    && sudo mv ./docker-buildx /usr/local/lib/docker/cli-plugins/docker-buildx