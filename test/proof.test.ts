import { expect } from "chai";
import { ethers } from "hardhat";
import { ContractInterface, BigNumber } from "ethers";
import { IHasher, Tornado, TurboVerifier } from "../typechain-types";
import hre from "hardhat";

// @ts-ignore
import { buildMimc7 } from "circomlibjs";

const TREE_DEPTH = 4;
const oneEth = ethers.utils.parseEther("1");

// Deposit secrets
const secret = "0x2fbd672ed8412e12e4dca149b72b8e270c1415eac7f759bfc40c7aae4db3afb3";
const nullifier = "0x27ed7a49c35fdfd03ef8960028df4d05eeb0845a336bcd39943e9fd7c7d399ee";

describe("Private Transfer", function () {
    let hasherContract: { abi: ContractInterface; bytecode: string };
    let hasher: IHasher;
    let verifier: TurboVerifier;
    let tornado: Tornado;

    before("should deploy hasher and verifier", async () => {
        hasherContract = await hre.run("mimc7");
        const [signer] = await ethers.getSigners();
        const hasherFactory = new ethers.ContractFactory(hasherContract.abi, hasherContract.bytecode, signer);
        hasher = await hasherFactory.deploy() as IHasher;
        await hasher.deployed();

        const verifierFactory = await ethers.getContractFactory("TurboVerifier");
        verifier = await verifierFactory.deploy();
        await verifier.deployed();
    });

    it("should deploy the Tornado contract", async () => {
        const tornadoFactory = await ethers.getContractFactory("Tornado");
        tornado = await tornadoFactory.deploy(verifier.address, hasher.address, oneEth, TREE_DEPTH);
        await tornado.deployed();
        expect(await tornado.verifier()).to.equal(verifier.address);
    });

    // it("should not change root after inserting `zero_value`", async () => {
    //     const commitment = await tornado.ZERO_VALUE();
    //     await expect(tornado.deposit(commitment.toHexString(), { value: oneEth }))
    //         .to.emit(tornado, "Deposit");
    //     expect(await tornado.roots(1)).to.equal(await tornado.roots(0));
    // });

    it("should make a deposit", async () => {
        const mimc7 = await buildMimc7();
        const commitment = BigNumber.from(mimc7.F.toString(mimc7.multiHash([secret, nullifier])));
        const FIELD_SIZE = await tornado.FIELD_SIZE();

        await expect(tornado.deposit(commitment.mod(FIELD_SIZE).toHexString(), { value: oneEth }))
            .to.emit(tornado, "Deposit");
    });

});
