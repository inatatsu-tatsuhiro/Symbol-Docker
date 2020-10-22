const fs = require('fs').promises;
const axios = require('axios');
const { read } = require('fs');
const yaml = require('yaml');

const ENV_PATH = '/.env';
const ENV_BASE_PATH = '/.env.sample';
const YML_PATH = '/addresses.yml';
// To LatestCatapult(symbol)
const GENERATION_HASH_URL = 'http://host.docker.internal:3000/blocks/1';

// To catapultv0.8.0.1
// const GENERATION_HASH_URL = 'http://host.docker.internal:3000/block/1';

const readFile = (path) => fs.readFile(path).then((buf) => buf.toString());

const proc = async () => {
    const addresses = yaml.parse(await readFile(YML_PATH));

    const masterAccount = addresses.nemesisSigner;
    const storeAccount = addresses.mosaics.currency[1];

    let config = await readFile(ENV_BASE_PATH);

    config += `STORE_ADDR=${storeAccount.address}\n`;
    config += `STORE_PUB_KEY=${storeAccount.publicKey}\n`;
    config += `STORE_PRIV_KEY=${storeAccount.privateKey}\n`;
    config += `MASTER_ADDR=${masterAccount.address}\n`;
    config += `MASTER_PUB_KEY=${masterAccount.publicKey}\n`;
    config += `MASTER_PRIV_KEY=${masterAccount.privateKey}\n`;

    const { data } = await axios.get(GENERATION_HASH_URL);
    if (data?.meta?.generationHash) {
        config += `GENERATION_HASH=${data.meta.generationHash}\n`;
    } else {
        console.error('NEMブロックチェーンのGenerationHash取得に失敗しました。');
        console.error(
            GENERATION_HASH_URL,
            でGenerationHashが取得できることを確認してください,
        );
    }

    fs.writeFile(ENV_PATH, config);
};

proc();
