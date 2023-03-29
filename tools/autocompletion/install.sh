#!/bin/bash

BASE_DIR=$(dirname "$0")

sudo apt-get install bash-completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'source /usr/share/bash-completion/bash_completion' >> ~/.bashrc
source ~/.bashrc