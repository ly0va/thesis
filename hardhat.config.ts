import '@typechain/hardhat';
import '@nomiclabs/hardhat-ethers';
import { HardhatUserConfig, task } from 'hardhat/config';

import fs from 'fs';
import path from 'path';
import { spawnSync } from 'child_process';

task("mimc7", "Generates the MiMC7 hasher bytecode").setAction(async () => {
    const { mimc7Contract } = require('circomlibjs');
    const contract = {
        contractName: 'Hasher',
        abi: mimc7Contract.abi,
        bytecode: mimc7Contract.createCode('mimc', 91),
    }

    const output = path.join(__dirname, 'artifacts/contracts/Hasher.json');
    fs.mkdirSync(path.dirname(output), { recursive: true });
    fs.writeFileSync(output, JSON.stringify(contract, null, 2))
    return contract;
});

task("verifier", "Generates the verifier contract").setAction(async (_args, hre) => {
    if (fs.existsSync('contracts/Verifier.sol')) {
        console.log('Verifier.sol already exists, skipping');
        return;
    }
    process.chdir(path.join(__dirname, 'circuits'));
    console.log('Generating verifier contract...');
    spawnSync('nargo', ['codegen-verifier']);
    fs.renameSync('contract/plonk_vk.sol', '../contracts/Verifier.sol');
    fs.rmdirSync('contract');
    console.log('Done');
});

const config: HardhatUserConfig = {
    solidity: {
        version: "0.7.6",
        settings: {
            optimizer: { enabled: true },
        }
    },
};

export default config;
