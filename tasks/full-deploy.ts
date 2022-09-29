import { getContractAddress } from "@ethersproject/address";
import { task } from "hardhat/config";
import { deployCollectionToIpfs } from "./utils/ipfs";
import { config } from "dotenv";
import { TransparentUpgradeableProxy__factory } from "../typechain-types";
import fs from "fs";

config();

task("full-deploy", "Deploy the entire AmpliFrens contracts")
  .addFlag("ipfs", "IPFS deployment of NFT and SBT images")
  .setAction(async (args, hre) => {
    const ethers = hre.ethers;
    const isIpfs = args.ipfs;
    let deployer = undefined;
    let admin = undefined;
    let ipfsPath = undefined;
    if (hre.network.name === "hardhat") {
      const accounts = await ethers.getSigners();
      deployer = accounts[0];
      admin = accounts[1];
    } else {
      deployer = new ethers.Wallet(process.env.DEPLOYER_WALLET_PRIVATE_KEY!, ethers.provider);
      admin = new ethers.Wallet(process.env.ADMIN_WALLET_PRIVATE_KEY!, ethers.provider);
    }

    if (isIpfs) {
      console.log("Deploying metadata and images to IPFS...");
      ipfsPath = await deployCollectionToIpfs(
        process.env.NFTS_ABSOLUTE_PATH!,
        "A person who has contributed tremendously to AmpliFrens community.",
        "Amplifrens Inner Circle"
      );
      console.log(`\x1b[33mIPFS Metadata CID : ${ipfsPath}, SAVE it for later use ! \x1b[0m`);
      return;
    }

    console.log("Deploying libraries...");
    console.log("Deploying ContributionLogic library...");
    const contributionLogicLib = await (
      await (await ethers.getContractFactory("ContributionLogic")).deploy()
    ).deployed();
    console.log("Deploying ProfileLogic library...");
    const profileLogicLib = await (await (await ethers.getContractFactory("ProfileLogic")).deploy()).deployed();
    console.log("Deploying SBTLogic library...");
    const sbtLogicLib = await (await (await ethers.getContractFactory("SBTLogic")).deploy()).deployed();
    console.log("Deploying TokenURI library...");
    const tokenURIHelperLib = await (await (await ethers.getContractFactory("TokenURI")).deploy()).deployed();
    console.log("Deploying PseudoModifier library...");
    const pseudoModifierLib = await (await (await ethers.getContractFactory("PseudoModifier")).deploy()).deployed();
    console.log("Deploying Status library...");
    const statusLib = await (await (await ethers.getContractFactory("Status")).deploy()).deployed();

    // 0 = NFT
    // 1 = SBT
    // 2 = Profile
    // 3 = Contribution
    // 4 = Facade impl
    // 5 = Facade proxy
    const nonce = await deployer.getTransactionCount();

    const facadeProxyAddress = await getContractAddress({ from: deployer.address, nonce: nonce + 5 });

    console.log("Deploying AmpliFrensNFT...");
    const nftContractFactory = await ethers.getContractFactory("AmpliFrensNFT", {
      libraries: {
        TokenURI: tokenURIHelperLib.address,
        PseudoModifier: pseudoModifierLib.address,
      },
    });
    const nftContract = await (await nftContractFactory.deploy(facadeProxyAddress)).deployed();

    console.log("Deploying AmpliFrensSBT...");
    const sbtContractFactory = await ethers.getContractFactory("AmpliFrensSBT", {
      libraries: {
        SBTLogic: sbtLogicLib.address,
        TokenURI: tokenURIHelperLib.address,
        PseudoModifier: pseudoModifierLib.address,
        Status: statusLib.address,
      },
    });
    const sbtContract = await (await sbtContractFactory.deploy(facadeProxyAddress)).deployed();

    console.log("Deploying AmpliFrensProfile...");
    const profileContractFactory = await ethers.getContractFactory("AmpliFrensProfile", {
      libraries: {
        ProfileLogic: profileLogicLib.address,
        PseudoModifier: pseudoModifierLib.address,
      },
    });
    const profileContract = await (await profileContractFactory.deploy(facadeProxyAddress)).deployed();

    console.log("Deploying AmpliFrensContribution...");
    const contributionContractFactory = await ethers.getContractFactory("AmpliFrensContribution", {
      libraries: {
        PseudoModifier: pseudoModifierLib.address,
        ContributionLogic: contributionLogicLib.address,
      },
    });
    const contributionContract = await (await contributionContractFactory.deploy(facadeProxyAddress)).deployed();

    console.log("Deploying AmpliFrensFacade Impl...");
    const facadeImplContractFactory = await ethers.getContractFactory("AmpliFrensFacade");
    const facadeImplContract = await (
      await facadeImplContractFactory.deploy(
        contributionContract.address,
        profileContract.address,
        nftContract.address,
        sbtContract.address
      )
    ).deployed();

    console.log("Deploying AmpliFrensFacade Proxy...");
    const proxy = await (
      await new TransparentUpgradeableProxy__factory(deployer).deploy(
        facadeImplContract.address,
        deployer.address,
        facadeImplContract.interface.encodeFunctionData("initialize", [admin.address])
      )
    ).deployed();

    console.log(facadeProxyAddress);
    console.log(proxy.address);

    const addresses = {
      libraries: {
        Status: statusLib.address,
        PseudoModifier: pseudoModifierLib.address,
        TokenURI: tokenURIHelperLib.address,
        ContributionLogic: contributionLogicLib.address,
        ProfileLogic: profileLogicLib.address,
        SBTLogic: sbtLogicLib.address,
      },
      contracts: {
        AmpliFrensNFT: nftContract.address,
        AmpliFrensSBT: sbtContract.address,
        AmpliFrensContribution: contributionContract.address,
        AmpliFrensProfile: profileContract.address,
        facade: {
          Impl: facadeImplContract.address,
          Proxy: proxy.address,
        },
      },
    };
    const addressesFilename = "addresses.json";
    fs.writeFileSync(addressesFilename, JSON.stringify(addresses));
    console.log(`Deployment addresses saved to ${addressesFilename}`);
  });
