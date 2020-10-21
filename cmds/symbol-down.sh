#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE:-$0}"); pwd)

echo "Symbolを終了しています"

cd $SCRIPT_DIR/../symbol-bootstrap/target/docker && docker-compose down