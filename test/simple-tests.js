const { expect } = require("chai");
const { ethers } = require("hardhat");

const {deployContracts, getPadding, toWei, fromWei} = require("./lib.js");

const START_BACKING = 100
const START_MARKET = 300
describe("First Tests", async ()=> {
  let ONE_HUNDRED_PERCENT;
  let owner, user1, user2;
  let token,
  oracle,
  reserve,
  bOHM;

  before(async ()=> {
    [owner, user1, user2] = await ethers.getSigners();
    [
      token,
      oracle,
      reserve,
      bOHM,
    ] = await deployContracts();

    await reserve.init(bOHM.address);

    await oracle.setPrices(START_BACKING,START_MARKET);

    ONE_HUNDRED_PERCENT = await reserve.ONE_HUNDRED_PERCENT();

  });

  describe("Deployment", async()=>{

    it("has the proper bOHM address logged", async()=>{
      let bOhmA = await reserve.bOHM();
      expect(bOhmA).to.be.equal(bOHM.address,"bOHM address does not match what's in reserve");
    });

  });

  describe("Deposits", async()=>{
    let A_APR;

    before(async()=>{
      await token.approve(reserve.address, "150");
      await reserve.enter("100");
      A_APR = await reserve.A_APR();
      await reserve.bOHMStake("50");
    });

    it("Logged share pool balance correctly", async()=>{
      const bal = await reserve.balanceOf(owner.address);
      expect(bal).to.equal("100");
    });

    it("Logged bOHM balance correctly",async()=>{      
      const bal = await bOHM.balanceOf(owner.address);
      let exp = toWei(ethers.BigNumber.from("50")).div(ethers.BigNumber.from("100"));
      exp = exp.add(exp.mul(A_APR).div(ONE_HUNDRED_PERCENT));
      expect(bal).to.equal(exp);
    });

  });
  
  describe("Raio Volatility", async()=>{

    beforeEach(async()=>{
      // redeploy for these
      [
        ,
        ,
        reserve,
        bOHM,
      ] = await deployContracts();
  
      await reserve.init(bOHM.address);
  
      await oracle.setPrices(START_BACKING,START_MARKET);
  
    });

    describe("Price Changes Only", async()=>{

      describe("Market price change only", async()=>{

        it("Loses padding upon market price only falling 100",async()=>{
          await oracle.setPrices(START_BACKING, START_MARKET-100);
          const before = await getPadding(reserve);
          const after = await getPadding(reserve);
          expect(after.gt(before));
        });
    
        it("Gains padding upon market price only increasing 100",async()=>{
          await oracle.setPrices(START_BACKING, START_MARKET+100);
          const before = await getPadding(reserve);
          const after = await getPadding(reserve);
          expect(after.lt(before));
        });  

      });

      describe("Base change only", async()=>{
        it("Loses padding upon base price only falling 10",async()=>{
          await oracle.setPrices(START_BACKING-10, START_MARKET);
          const before = await getPadding(reserve);
          const after = await getPadding(reserve);
          expect(after.gt(before));
        });
    
        it("Gains padding upon base price only increasing 10",async()=>{
          await oracle.setPrices(START_BACKING+10, START_MARKET);
          const before = await getPadding(reserve);
          const after = await getPadding(reserve);
          expect(after.lt(before));
        });
    
      });

      describe("Market and base price changing", async()=>{

        describe("Expected behavior. Market moves more than base in same direction",async()=>{

          it("Loses padding upon market price falling 100 and base falling 10",async()=>{
            await oracle.setPrices(START_BACKING-10, START_MARKET-100);
            const before = await getPadding(reserve);
            const after = await getPadding(reserve);
            expect(after.gt(before));
          });
      
          it("Gains padding upon market price increasing 100 and base increasing 10",async()=>{
            await oracle.setPrices(START_BACKING+10, START_MARKET+100);
            const before = await getPadding(reserve);
            const after = await getPadding(reserve);
            expect(after.lt(before));
          });
  
        });

        describe("Unexpected behavior. Market moves more than base in opposite directions", async()=>{

          it("Loses padding upon market price falling 100 and base increasing 10",async()=>{
            await oracle.setPrices(START_BACKING-10, START_MARKET-100);
            const before = await getPadding(reserve);
            const after = await getPadding(reserve);
            expect(after.gt(before));
          });
      
          it("Gains padding upon market price increasing 100 and base falling 10",async()=>{
            await oracle.setPrices(START_BACKING+10, START_MARKET+100);
            const before = await getPadding(reserve);
            const after = await getPadding(reserve);
            expect(after.lt(before));
          });
          
        });
    
      });

    });

    describe("Deposits Only", async()=>{

    });
    
    describe("Deposits and Price Changes", async()=>{

    });

  });

});


