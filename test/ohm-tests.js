const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Olympus Tests", async ()=> {
    let alice,bob;
    let ohm, sOHM, olympusTreasury, staking, distributor;

    before(async()=>{
        const [deployer,Alice,Bob] = await ethers.getSigners();
        alice = Alice;
        bob = Bob;
        console.log("Deploying contracts with the account: " + deployer.address);
    
        const DAI = "0xB2180448f8945C8Cc8AE9809E67D6bd27d8B2f2C";
        const oldOHM = "0xC0b491daBf3709Ee5Eb79E603D73289Ca6060932";
        const oldsOHM = "0x1Fecda1dE7b6951B248C0B62CaeBD5BAbedc2084";
        const oldStaking = "0xC5d3318C0d74a72cD7C55bdf844e24516796BaB2";
        const oldwsOHM = "0xe73384f11Bb748Aa0Bc20f7b02958DF573e6E2ad";
        const sushiRouter = "0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506";
        const uniRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
        const oldTreasury = "0x0d722D813601E48b7DAcb2DF9bae282cFd98c6E7";
    
        const FRAX = "0x2f7249cb599139e560f0c81c269ab9b04799e453";
        const LUSD = "0x45754df05aa6305114004358ecf8d04ff3b84e26";
    
        const Authority = await ethers.getContractFactory("OlympusAuthority");
        const authority = await Authority.deploy(
            deployer.address,
            deployer.address,
            deployer.address,
            deployer.address
        );
    
        const Migrator = await ethers.getContractFactory("OlympusTokenMigrator");
        const migrator = await Migrator.deploy(
            oldOHM,
            oldsOHM,
            oldTreasury,
            oldStaking,
            oldwsOHM,
            sushiRouter,
            uniRouter,
            "0",
            authority.address
        );
    
        const firstEpochNumber = "550";
        const firstBlockNumber = "9505000";
    
        const OHM = await ethers.getContractFactory("OlympusERC20Token");
        ohm = await OHM.deploy(authority.address);
    
        const SOHM = await ethers.getContractFactory("sOlympus");
        sOHM = await SOHM.deploy();
    
        const GOHM = await ethers.getContractFactory("gOHM");
        gOHM = await GOHM.deploy(migrator.address, sOHM.address);
    
        await migrator.setgOHM(gOHM.address);
    
        const OlympusTreasury = await ethers.getContractFactory("OlympusTreasury");
        olympusTreasury = await OlympusTreasury.deploy(ohm.address, "0", authority.address);
        await olympusTreasury.initialize();

        await olympusTreasury.queueTimelock("0", migrator.address, migrator.address);
        await olympusTreasury.queueTimelock("8", migrator.address, migrator.address);
        await olympusTreasury.queueTimelock("2", DAI, DAI);
        await olympusTreasury.queueTimelock("2", FRAX, FRAX);
        await olympusTreasury.queueTimelock("2", LUSD, LUSD);
    
        await authority.pushVault(olympusTreasury.address, true); // replaces ohm.setVault(treasury.address)
    
        const OlympusStaking = await ethers.getContractFactory("OlympusStaking");
        staking = await OlympusStaking.deploy(
            ohm.address,
            sOHM.address,
            gOHM.address,
            "2200",
            firstEpochNumber,
            firstBlockNumber,
            authority.address
        );
    
        const Distributor = await ethers.getContractFactory("Distributor");
        distributor = await Distributor.deploy(
            olympusTreasury.address,
            ohm.address,
            staking.address,
            authority.address
        );
    
        // Initialize sohm
        await sOHM.setIndex("7675210820");
        await sOHM.setgOHM(gOHM.address);
        await sOHM.initialize(staking.address, olympusTreasury.address);
    
        await staking.setDistributor(distributor.address);
        
        await olympusTreasury.execute("0");
        await olympusTreasury.execute("1");
        await olympusTreasury.execute("2");
        await olympusTreasury.execute("3");
        await olympusTreasury.execute("4");
    
    });

    describe("Staking",async()=>{
        const amount = 1000;
        const rebasing = true;
        const claim = true;

        beforeEach(async()=>{
            const bal = await ohm.balanceOf(alice.address);
            if(bal > 0){
                await ohm.connect(alice).burn(bal);
            }

            await ohm.mint(alice.address,amount);
            await ohm.mint(bob.address, amount);
            await ohm.connect(alice).approve(staking.address,amount);
            await ohm.connect(bob).approve(staking.address,amount);
            await sOHM.connect(alice).approve(staking.address,amount);
            await sOHM.connect(bob).approve(staking.address,amount);
        });

        // it("Instant deposit, withdrawal",async()=>{
        //     let balBefore = await ohm.balanceOf(alice.address);
        //     await staking.connect(alice).stake(alice.address, amount, rebasing, claim);
        //     await staking.connect(alice).unstake(alice.address, amount, false, rebasing);
        //     let balAfter = await ohm.balanceOf(alice.address);
        //     expect(balBefore).to.equal(balAfter);
        // });

        it("gains OHM after rebase", async()=>{
            let balBefore = await ohm.balanceOf(bob.address);
            await staking.connect(alice).stake(alice.address, amount, rebasing, claim);
            await staking.connect(bob).stake(bob.address, amount, rebasing, claim);

            await staking.connect(alice).rebase();
            await staking.connect(bob).unstake(bob.address, amount, false, rebasing);
            let balAfter = await ohm.balanceOf(bob.address);
            expect(balBefore).to.be.lt(balAfter);
        });

    });

});
