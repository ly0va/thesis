import { expect } from "chai";
import { ethers } from "hardhat";
import { ContractInterface, BigNumber } from "ethers";
import { IHasher, MerkleTreeWithHistory } from "../typechain-types";
import hre from "hardhat";

// @ts-ignore
import { buildMimc7 } from "circomlibjs";

const MAX_TREE_DEPTH = 31;

describe("Hasher", function () {
    let hasherContract: { abi: ContractInterface; bytecode: string };
    let hasher: IHasher;
    let tree: MerkleTreeWithHistory;

    before("should deploy MiMC7 hasher", async () => {
        hasherContract = await hre.run("mimc7");
        const [signer] = await ethers.getSigners();
        const hasherFactory = new ethers.ContractFactory(hasherContract.abi, hasherContract.bytecode, signer);
        hasher = await hasherFactory.deploy() as IHasher;
        await hasher.deployed();
    });

    it("should deploy the Merkle Tree contract", async () => {
        const treeFactory = await ethers.getContractFactory("MerkleTreeWithHistory");
        tree = await treeFactory.deploy(MAX_TREE_DEPTH, hasher.address);
        await tree.deployed();
        expect(await tree.hasher()).to.equal(hasher.address);
    });

    it("should test empty hashes", async () => {
        const mimc7 = await buildMimc7();
        let zero = await tree.ZERO_VALUE();

        for (let i = 0; i <= MAX_TREE_DEPTH; i++) {
            expect(await tree.zeros(i)).to.equal(zero);
            zero = BigNumber.from(mimc7.F.toString(mimc7.multiHash([zero, zero])));
        }
    });

    it ("should test root value", async () => {
        expect(await tree.roots(0)).to.equal(await tree.zeros(MAX_TREE_DEPTH - 1));
    });
});
