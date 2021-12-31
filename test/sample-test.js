const { expect } = require("chai");
const { ethers } = require("hardhat");

const {deployContracts} = require("./lib.js");

describe("First Tests", async ()=> {
  let owner, user1, user2;
  let token,
  oracle,
  reserve,
  bOHM;

  beforeEach(async ()=> {
    [owner, user1, user2] = await ethers.getSigners();
    [
      token,
      oracle,
      reserve,
      bOHM,
    ] = await deployContracts();
    await reserve.init(bOHM.address);

  });

  it("Init properly", async()=>{
    let bOhmA = await reserve.bOHM();
    expect(bOhmA).to.be.equal(bOHM.address,"bOHM address does not match reserve");
  });

  it("deposits share pool", async()=>{
    await token.approve(reserve.address, "100");
    await reserve.enter("100");
    const bal = await reserve.balanceOf(owner.address);
    expect(bal).to.equal("100");
  });

});


