import dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-solhint";
import "@openzeppelin/hardhat-upgrades";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "./tasks/full-deploy";
import "./tasks/mint-nfts";
import "./tasks/set-nft-base-uri";

dotenv.config();

const {
  POLYGON_MUMBAI_RPC_PROVIDER,
  POLYGON_MAINNET_RPC_PROVIDER,
  POLYGONSCAN_API_KEY,
  COINMARKETCAP_API_KEY,
  REPORT_GAS,
  DEPLOYER_WALLET_PRIVATE_KEY,
} = process.env;

const config: HardhatUserConfig = {
  networks: {
    mumbai: {
      url: POLYGON_MUMBAI_RPC_PROVIDER,
      accounts: [DEPLOYER_WALLET_PRIVATE_KEY!],
    },
    matic: {
      url: POLYGON_MAINNET_RPC_PROVIDER,
      accounts: [DEPLOYER_WALLET_PRIVATE_KEY!],
    },
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
};

export default config;
