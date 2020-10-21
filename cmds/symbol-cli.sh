#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE:-$0}"); pwd)

docker run -i -v $SCRIPT_DIR/../symbol-cli.config.json:/root/symbol-cli.config.json symbol-cli symbol-cli $@

