#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE:-$0}"); pwd)

cd $SCRIPT_DIR/../

echo "Symbolの設定ファイルをダウンロードします。"

git clone https://github.com/inatatsu-tatsuhiro/symbol-bootstrap.git

wait

$SCRIPT_DIR/symbol-up.sh

start_time=`date +%s`

curl -s -X GET http://localhost:3000/chain/info > /dev/null

while [ $? != 0 ]
do
    sleep 5
    end_time=`date +%s`
    run_time=$((end_time - start_time))
    if [ 60 -lt $run_time ] ; then
        echo "NEM Symbolの起動に失敗しました。"
        exit
    fi
    echo "NEM Symbolの起動を待機しています"
    curl -s -X GET http://localhost:3000/chain/info > /dev/null

done
echo "NEM Symbolが起動しました"

sleep 5

echo "NEM Symbolを初期化"

docker build -t symbol-cli ./build/symbol-cli

sleep 5
cp /dev/null symbol-cli.config.json
echo "{}" > symbol-cli.config.json

NETWORK=TEST_NET
SYMBOL_HOST=http://host.docker.internal:3000
MASTER_PW=1234567890
SYMBOL_USER=master

ADDRESSES_FILE=$SCRIPT_DIR/../symbol-bootstrap/target/config/generated-addresses/addresses.yml
MASTER_PRIV=$(cat $ADDRESSES_FILE | ./cmds/yq.sh r - 'nemesisSigner.privateKey' )
echo -ne '\n' | $SCRIPT_DIR/symbol-cli.sh profile import -p $MASTER_PW -P $MASTER_PRIV -n $NETWORK -u $SYMBOL_HOST --profile $SYMBOL_USER -d
echo "masterアカウントの読込が完了しました。"

MOSAIC_ID=$(echo -ne '\n' | $SCRIPT_DIR/../cmds/symbol-cli.sh transaction mosaic --profile $SYMBOL_USER --non-expiring --divisibility 0 --restrictable --supply-mutable --transferable --amount 10000000 --max-fee 0 -p $MASTER_PW | grep 'Mosaic Id:' | grep 'Inner tx. 1' | awk '{print $10}')

echo "masterを有効化しました。"

echo "MOSAICを発行しました. MOSAIC_ID: $MOSAIC_ID"

cp /dev/null .env

echo "MOSAIC=$MOSAIC_ID" >> .env
