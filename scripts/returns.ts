// This script aims to calculate rough projected returns
// of deploying the Tornado Cash protocol with Aave integration
// and `flashLoan` method enabled.

import { ethers } from 'hardhat';
import got from 'got';
import fs from 'fs';

const TORNADO_CASH: { [coin: string]: string } = {
    '0.1': "0x12D66f87A04A9E220743712cE6d9bB1B5616B8Fc",
    '1': "0x47CE0C6eD5B0Ce3d3A51fdb1C52DC66a7c3c2936",
    '10': "0x910Cbd523D972eb0a6f4cAe4618aD62622b39DbF",
    '100': "0xA160cdAB225685dA1d56aa342Ad8841c3b53f291",
}

const AAVE_ADDRESS = '0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9';

const url = 'https://api.etherscan.io/api';
const API_KEY = process.env.ETHERSCAN_API_KEY;

async function fetchEventsFromBlocks(fromBlock: number, toBlock: number, address: string, topic?: string) {
    let events = [];
    let over = false;
    for (let page = 1; !over; page++) {
        const chunk: any = await got(url, {
            searchParams: {
                module: 'logs',
                action: 'getLogs',
                fromBlock,
                toBlock,
                address,
                topic0: topic,
                page,
                offset: 1000,
                apiKey: API_KEY
            }
        }).json();

        console.log(`Fetched something, message: ${chunk.message}`);
        console.log(`Fetched ${chunk.result.length} more events`);
        events.push(...chunk.result);
        over = chunk.result.length < 1000;
    };
    return events;
}

async function fetchTornadoEvents() {
    const fromBlock = 9116900; // First Tornado deployed
    const toBlock = 17350000;

    for (const key of Object.keys(TORNADO_CASH)) {
        let events = [];
        const step = 200_000;
        for (let block = fromBlock; block < toBlock; block += step) {
            const chunk = await fetchEventsFromBlocks(block, block + step - 1, TORNADO_CASH[key]);
            events.push(...chunk);
        }
        console.log(`Fetched a total of ${events.length} events for ${key} ETH contract`);
        fs.writeFileSync(`events-${key}.json`, JSON.stringify(events));
    }
}

async function fetchAaveEvents() {
    const flashLoan = new ethers.utils.Interface([`event FlashLoan(
        address indexed target,
        address indexed initiator,
        address indexed asset,
        uint256 amount,
        uint256 premium,
        uint16 referralCode
    )`]);

    const lastBlock = 17350000;
    const yearAgo = lastBlock - 365 * 24 * 60 * 5;

    let events = [];
    const step = 100_000;
    for (let block = yearAgo; block < lastBlock; block += step) {
        const chunk = await fetchEventsFromBlocks(
            block,
            block + step - 1,
            AAVE_ADDRESS,
            flashLoan.getEventTopic('FlashLoan')
        );
        events.push(...chunk);
    }
    console.log(`Fetched a total of ${events.length} flashLoan events`);
    fs.writeFileSync(`flashloans.json`, JSON.stringify(events));
}

async function main() {
    const deposit = ethers.utils.id("Deposit(bytes32,uint32,uint256)");
    const withdrawal = ethers.utils.id("Withdrawal(address,bytes32,address,uint256)");
    for (const key of Object.keys(TORNADO_CASH)) {
        console.log(`\nAnalyzing ${key}-ETH contract`);
        const events = JSON.parse(fs.readFileSync(`events-${key}.json`).toString());
        const deposits = events.filter((e: any) => e.topics[0] === deposit).length;
        let ethSecs = 0;
        let balance = 0;
        let prevTime = parseInt(events[0].timeStamp, 16);
        for (const event of events) {
            if (event.topics[0] == deposit) {
                balance += +key;
            } else if (event.topics[0] == withdrawal) {
                balance -= +key;
            }
            let curTime = parseInt(event.timeStamp, 16);
            ethSecs += balance * (curTime - prevTime);
            prevTime = curTime;
        }
        console.log('Currently in contract:', balance.toFixed(1), 'ETH');

        const profit = ethSecs * 0.02 / 365 / 24 / 60 / 60;
        console.log('Expected total profit with 2% yearly', profit.toFixed(3));
        console.log('Expected profit per depositor', (profit / deposits).toFixed(5));
    }
}

main().catch(error => {
    console.error(error);
    process.exit(1);
})
