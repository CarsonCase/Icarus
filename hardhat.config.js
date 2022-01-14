require("@nomiclabs/hardhat-waffle");
require('hardhat-dependency-compiler');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
          version: "0.8.10",
          settings: {
              metadata: {
                  bytecodeHash: "none",
              },
              optimizer: {
                  enabled: true,
                  runs: 800,
              },
          },
      },
      {
          version: "0.7.5",
          settings: {
              metadata: {
                  bytecodeHash: "none",
              },
              optimizer: {
                  enabled: true,
                  runs: 800,
              },
          },
      }
    ],
  },
  dependencyCompiler: {
    paths: [
      'olympus-contracts/contracts/OlympusERC20.sol',
      'olympus-contracts/contracts/Treasury.sol',
      'olympus-contracts/contracts/sOlympusERC20.sol',
      'olympus-contracts/contracts/StakingDistributor.sol',
      'olympus-contracts/contracts/Staking.sol',
      'olympus-contracts/contracts/OlympusAuthority.sol',
      'olympus-contracts/contracts/migration/OlympusTokenMigrator.sol',
      'olympus-contracts/contracts/governance/gOHM.sol',
    ],
  }
};
