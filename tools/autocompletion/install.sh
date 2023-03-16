#!/bin/bash

BASE_DIR=$(dirname "$0")

sudo apt-get install bash-completion
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
source ~/.bashrc
source /usr/share/bash-completion/bash_completion