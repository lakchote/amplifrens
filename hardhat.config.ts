import dotenv from "dotenv";
import glob from "glob";
import path from "path";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-solhint";
import "@openzeppelin/hardhat-upgrades";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "@graphprotocol/hardhat-graph";

dotenv.config();

/**
 * We can't load the task files that require typechain when it hasn't been created yet.
 * Otherwise an error will be thrown.
 * We use the SKIP_LOAD env var to require it when everything has been created.
 * See the logic in the compile script present in package.json to fully understand the logic beneath.
 */
if (!process.env.SKIP_LOAD) {
  glob.sync("./tasks/**/*.ts").forEach(function (file) {
    require(path.resolve(file));
  });
}

const {
  POLYGON_MUMBAI_RPC_PROVIDER,
  POLYGON_MAINNET_RPC_PROVIDER,
  POLYGONSCAN_API_KEY,
  COINMARKETCAP_API_KEY,
  REPORT_GAS,
  DEPLOYER_WALLET_PRIVATE_KEY,
} = process.env;

const config = {
  networks: {
    mumbai: {
      url: POLYGON_MUMBAI_RPC_PROVIDER,
      accounts: [DEPLOYER_WALLET_PRIVATE_KEY!],
    },
    matic: {
      url: POLYGON_MAINNET_RPC_PROVIDER,
      accounts: [DEPLOYER_WALLET_PRIVATE_KEY!],
    },
    localhost: {
      url: "http://localhost:8545",
    },
    hardhat: {},
  },
  solidity: {
    version: "0.8.16",
    settings: {
      optimizer: {
        enabled: true,
        runs: 365,
      },
    },
  },
  gasReporter: {
    enabled: REPORT_GAS ? true : false,
    currency: "USD",
    gasPrice: 21,
    outputFile: "gas_report.txt",
    noColors: true,
    token: "MATIC",
    coinmarketcap: COINMARKETCAP_API_KEY,
  },
  etherscan: {
    apiKey: POLYGONSCAN_API_KEY,
  },
  subgraph: {
    name: "amplifrens",
  },
  paths: {
    subgraph: "./subgraph",
  },
};

export default config;
