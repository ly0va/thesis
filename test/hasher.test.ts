import { expect } from "chai";
import { ethers } from "hardhat";
import { ContractInterface } from "ethers";
import { IHasher } from "../typechain-types";
import hre from "hardhat";

describe("Hasher", function () {
    let hasherContract: { abi: ContractInterface; bytecode: string };
    let hasher: IHasher;

    before(async () => {
        hasherContract = await hre.run("mimc7");
    });

    it("should deploy MiMC7 hasher", async function () {
        const [signer] = await ethers.getSigners();
        const hasherFactory = new ethers.ContractFactory(hasherContract.abi, hasherContract.bytecode, signer);
        hasher = await hasherFactory.deploy() as IHasher;
        await hasher.deployed();
        expect(await hasher.MiMCpe7(1, 2)).to.exist;
    });
});
