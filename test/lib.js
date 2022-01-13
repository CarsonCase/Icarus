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

async function getPadding(reserve){
    let ratioVars = await reserve.getRatioVars();
    return ethers.BigNumber.from(ratioVars[0]).add(ethers.BigNumber.from(ratioVars[1]).sub(ethers.BigNumber.from(ratioVars[2])));
}

function toWei(bn){
    return bn.mul(ethers.BigNumber.from("1000000000000000000"));
}

function fromWei(bn){
    return ethers.utils.parseEther(bn);
}

module.exports = {
    deployContracts,
    getPadding,
    toWei,
    fromWei
}