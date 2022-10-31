import { task } from "hardhat/config";
import { config } from "dotenv";
import * as facadeJson from "../../artifacts/contracts/interfaces/IAmpliFrensFacade.sol/IAmpliFrensFacade.json";
import { IAmpliFrensFacade } from "../../typechain-types/contracts/interfaces/IAmpliFrensFacade";

config();

task("mint-nfts", "Mint NFTs for address specified")
  .addParam("to", "The address to mint NFT for")
  .addParam("proxy", "The facade's proxy address")
  .addParam("baseuri", "The base uri to set")
  .setAction(async (args, hre) => {
    const ethers = hre.ethers;
    if (!ethers.utils.isAddress(args.to)) {
      console.error(`The recipient's address ${args.to} is not a valid.`);

      return 1;
    }
    if (!ethers.utils.isAddress(args.proxy)) {
      console.error(`The proxy address ${args.address} is not a valid.`);

      return 1;
    }

    const signer = ["hardhat", "localhost"].includes(hre.network.name)
      ? (await ethers.getSigners())[1]
      : new ethers.Wallet(process.env.ADMIN_WALLET_PRIVATE_KEY!, ethers.provider);

    const proxyContract = new ethers.Contract(args.proxy, facadeJson.abi, signer) as IAmpliFrensFacade;

    console.log("Minting NFTs...");
    for (let i = 1; i <= 15; i++) {
      const mintTx = await proxyContract.mintNFT(args.to, i.toString());
      await mintTx.wait();
    }
  });
