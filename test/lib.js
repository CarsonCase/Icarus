const { ethers } = require("hardhat");

async function deployContracts(){
    const TestToken = await hre.ethers.getContractFactory("TestToken");
    const token = await TestToken.deploy();

    const Oracle = await hre.ethers.getContractFactory("PriceOracle");
    const oracle = await Oracle.deploy();
  
    const Reserve = await hre.ethers.getContractFactory("Reserve");
    const reserve = await Reserve.deploy(oracle.address, oracle.address, token.address);

    const BOHM = await hre.ethers.getContractFactory("bOHM");
    const bOHM = await BOHM.deploy(reserve.address, oracle.address);

    return [
        token,
        oracle,
        reserve,
        bOHM,
    ];
}

module.exports = {
    deployContracts
}