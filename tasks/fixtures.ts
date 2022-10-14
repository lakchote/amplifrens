import { task } from "hardhat/config";
import { config } from "dotenv";
import addressesJson from "../addresses.json";
import { Contract, Signer } from "ethers";

config();

task("fixtures-full", "Create full fixtures for Hardhat local node").setAction(async (args, hre) => {
  const ethers = hre.ethers;
  const accounts = await ethers.getSigners();
  const contributions = [
    { title: "StarkNet Staking Rewards Template", category: 7 },
    { title: "Hyperapps: a primitive for a new internet", category: 4 },
    { title: "Ethan Buchman on the BSC Hack", category: 3 },
    { title: "Virtual Society, Blockchains, and The Metaverse", category: 1 },
    { title: "$BTRFLY 2.0", category: 4 },
    { title: "DeGods removing NFT royalties", category: 0 },
    { title: "Collection.xyz launch", category: 0 },
    { title: "All things NFTs with Kevin rose and Chris Dixon", category: 6 },
    { title: "Brian Armstrong reflects on Coinbase origin story", category: 6 },
    { title: "Analysis Binance Bridge hack - open questions & open points", category: 3 },
    { title: "Stablecoins are a misunderstood DeFi primitive", category: 2 },
    { title: "How a derivative project became arguably the best gaming ecosystem", category: 5 },
    { title: "X2Y2 P2P NFT loan", category: 0 },
    { title: "Celsius doxxed me", category: 7 },
    { title: "Llamalend contracts", category: 7 },
  ];

  const facadeFactory = await ethers.getContractFactory("AmpliFrensFacade");
  const proxyContract = facadeFactory.attach(addressesJson.contracts.facade.Proxy);

  console.log("Creating contributions...");
  let accountIndex = 0;
  for (let i = 0; i < contributions.length; i++) {
    const createContributionTx = await proxyContract
      .connect(accounts[++accountIndex])
      .createContribution(contributions[i].category, contributions[i].title, "https://www.dummy.xyz");
    await createContributionTx.wait();
  }

  console.log("Upvoting contributions...");
  for (let i = 3; i < 20; i++) {
    let contributionIdToVote = Math.floor(Math.random() * 2 + 1);

    const upvoteTx = await proxyContract.connect(accounts[i]).upvoteContribution(contributionIdToVote);
    await upvoteTx.wait();
  }

  console.log("Downvoting contribution with id 1...");
  const downvoteTx = await proxyContract.connect(accounts[2]).downvoteContribution(1);
  await downvoteTx.wait();

  console.log("Updating contribution with id 1...");
  const updateContributionTx = await proxyContract
    .connect(accounts[1])
    .updateContribution(1, 7, "TEST update", "https://www.test.xyz");
  await updateContributionTx.wait();

  console.log("Removing contribution with id 3...");
  const removeContributionTx = await proxyContract.connect(accounts[1]).removeContribution(3);
  await removeContributionTx.wait();

  console.log(`Creating profile for account ${accounts[2].address}...`);
  await createProfile(proxyContract, accounts[2]);

  console.log(`Updating profile ${accounts[2].address}...`);
  const updateProfileTx = await proxyContract.connect(accounts[2]).updateUserProfile({
    username: "ethernal",
    lensHandle: "ethernal.lens",
    discordHandle: "ethernal#1337",
    twitterHandle: "ethernal",
    email: "ethern@l.com",
    websiteUrl: "https://www.anon.xyz",
    valid: true,
  });
  await updateProfileTx.wait();

  console.log(`Blacklisting profile ${accounts[2].address}...`);
  const blacklistProfileTx = await proxyContract.connect(accounts[1]).blacklistUserProfile(accounts[2].address, "Spam");
  await blacklistProfileTx.wait();

  console.log(`Creating profile for account ${accounts[4].address}...`);
  await createProfile(proxyContract, accounts[4]);

  console.log(`Removing profile ${accounts[4].address}...`);
  const removeProfileTx = await proxyContract.connect(accounts[1]).deleteUserProfile(accounts[4].address);
  await removeProfileTx.wait();

  console.log(`Creating profile for account ${accounts[3].address}...`);
  await createProfile(proxyContract, accounts[3]);

  console.log("Increasing EVM time to mint a SBT for the contribution of the day...");
  await hre.network.provider.send("evm_increaseTime", [1000 * 60 * 60 * 24]);
  await hre.network.provider.send("evm_mine");

  console.log("Performing upkeep...");
  const performUpkeepTx = await proxyContract.connect(accounts[2]).performUpkeep(ethers.utils.toUtf8Bytes("0x00"));
  await performUpkeepTx.wait();
});

async function createProfile(proxyContract: Contract, signer: Signer) {
  const randomString = (Math.random() + 1).toString(36).substring(2);
  const createProfileTx = await proxyContract.connect(signer).createUserProfile({
    username: randomString,
    lensHandle: randomString + ".lens",
    discordHandle: randomString + "#1337",
    twitterHandle: randomString,
    email: randomString + "@gmail.com",
    websiteUrl: "https://www" + randomString + ".xyz",
    valid: true,
  });
  await createProfileTx.wait();
}
