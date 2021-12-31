const hre = require("hardhat");

async function main() {

  const Oracle = await hre.ethers.getContractFactory("PriceOracle");
  const oracle = await Oracle.deploy();

  const Reserve = await hre.ethers.getContractFactory("Reserve");
  const reserve = await Reserve.deploy(oracle.address, oracle.address);

  await greeter.deployed();

  console.log("Greeter deployed to:", greeter.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
