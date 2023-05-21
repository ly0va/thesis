import '@typechain/hardhat';
import '@nomiclabs/hardhat-ethers';
import { HardhatUserConfig, task } from 'hardhat/config';
import fs from 'fs';
import path from 'path';

task("mimc7", "Generates the MiMC7 hasher contract").setAction(async () => {
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

const config: HardhatUserConfig = {
  solidity: {
    version: "0.7.6"
  },
};

export default config;
