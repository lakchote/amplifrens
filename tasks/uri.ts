import { task } from "hardhat/config";
import { config } from "dotenv";
import * as facadeJson from "../artifacts/contracts/interfaces/IAmpliFrensFacade.sol/IAmpliFrensFacade.json";
import { IAmpliFrensFacade } from "../typechain-types/contracts/interfaces/IAmpliFrensFacade";

config();

task("set-sbt-base-uri", "Set the base uri for the SBT contract")
  .addParam("proxy", "The facade's proxy address")
  .addParam("uri", "The base uri to set")
  .setAction(async (args, hre) => {
    const ethers = hre.ethers;
    if (!ethers.utils.isAddress(args.proxy)) {
      console.error(`The proxy address ${args.address} is not a valid.`);
    }
    const signer = ["hardhat", "localhost"].includes(hre.network.name)
      ? (await ethers.getSigners())[1]
      : new ethers.Wallet(process.env.ADMIN_WALLET_PRIVATE_KEY!, ethers.provider);

    const proxyContract = new ethers.Contract(args.proxy, facadeJson.abi, signer) as IAmpliFrensFacade;

    console.log("Setting base URI...");
    const setBaseURITx = await proxyContract.setSBTBaseURI(args.uri);
    await setBaseURITx.wait();
  });

task("set-nft-base-uri", "Set the base uri for the NFT contract")
  .addParam("proxy", "The facade's proxy address")
  .addParam("uri", "The base uri to set")
  .setAction(async (args, hre) => {
    const ethers = hre.ethers;
    if (!ethers.utils.isAddress(args.proxy)) {
      console.error(`The proxy address ${args.address} is not a valid.`);
    }
    const signer = ["hardhat", "localhost"].includes(hre.network.name)
      ? (await ethers.getSigners())[1]
      : new ethers.Wallet(process.env.ADMIN_WALLET_PRIVATE_KEY!, ethers.provider);

    const proxyContract = new ethers.Contract(args.proxy, facadeJson.abi, signer) as IAmpliFrensFacade;

    console.log("Setting base URI...");
    const setBaseURITx = await proxyContract.setNFTBaseURI(args.uri);
    await setBaseURITx.wait();
  });
