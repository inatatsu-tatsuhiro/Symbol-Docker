#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE:-$0}"); pwd)

echo "Symbolを起動します"

cd $SCRIPT_DIR/../symbol-bootstrap/target/docker && docker-compose up -d 