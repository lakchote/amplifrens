import { task } from "hardhat/config";
import { config } from "dotenv";
import addressesJson from "../addresses.json";
import { Contract, Signer } from "ethers";

config();

task("fixtures-full", "Create full fixtures for Hardhat local node").setAction(async (args, hre) => {
  if (!["hardhat", "localhost"].includes(hre.network.name)) {
    console.error("Only hardhat and localhost networks are allowed for fixtures.");

    return 1;
  }

  const ethers = hre.ethers;
  const accounts = await ethers.getSigners();
  const contributions = [
    {
      title: "The ArtGobblers Competition",
      category: 4,
      url: "https://twitter.com/0xmisaka/status/1585032905516257280",
    },
    { title: "The Reddit NFTs Thesis", category: 0, url: "https://page1.substack.com/p/the-reddit-nfts-thesis" },
    {
      title: "Reddit avoids crypto lingo, shows how to take NFTs mainstream",
      category: 0,
      url: "https://www.theblock.co/post/179797/reddit-avoids-crypto-lingo-shows-how-to-take-nfts-mainstream",
    },
    {
      title: "Real World Assets: Finance’s bridge to crypto",
      category: 2,
      url: "https://research.thetie.io/real-world-assets/",
    },
    {
      title: "Everything you need to know about on-chain bonds",
      category: 4,
      url: "https://twitter.com/SolvProtocol/status/1585070988068548608",
    },
    { title: "The state of ETH L2s", category: 1, url: "https://alphapls.substack.com/p/the-state-of-ethereum-l2s" },
    { title: "Sui Foundation Grants", category: 1, url: "https://suifoundation.org/#grant" },
    { title: "Near Protocol’s USN Stablecoin Shut Down", category: 1, url: "https://thedefiant.io/usn-unwinds" },
    {
      title: "SAFU: Creating a Standard for Whitehats",
      category: 3,
      url: "https://jumpcrypto.com/safu-creating-a-standard-for-whitehats/",
    },
    {
      title: "Web3 Social usage and engagement",
      category: 4,
      url: "https://twitter.com/messaricrypto/status/1584916770825142273",
    },
    {
      title: "BNB chain 10M fund",
      category: 1,
      url: "https://www.coindesk.com/business/2022/10/25/bnb-chain-introduces-10m-fund-to-incentive-project-growth-on-the-blockchain/",
    },
    { title: "EIP-4844 with Dankrad", category: 6, url: "https://www.youtube.com/watch?v=F0u5BNZYhMQ" },
    {
      title: "Vyper version of the ERC-20 + EIP-2612 standards P2P NFT loan",
      category: 7,
      url: "https://github.com/pcaversaccio/snekmate/blob/main/src/tokens/ERC20.vy",
    },
    {
      title: "Burning MEV through block proposer auctions",
      category: 7,
      url: "https://ethresear.ch/t/burning-mev-through-block-proposer-auctions/14029",
    },
    { title: "Play to Die", category: 5, url: "https://davestanton.substack.com/p/new-nftcrypto-game-model-play-to" },
  ];

  const facadeFactory = await ethers.getContractFactory("AmpliFrensFacade");
  const proxyContract = facadeFactory.attach(addressesJson.contracts.facade.Proxy);

  console.log(`Creating profile for account ${accounts[3].address}...`);
  await createProfile(proxyContract, accounts[3]);

  console.log("Creating contributions...");
  let accountIndex = 0;
  for (let i = 0; i < contributions.length; i++) {
    const createContributionTx = await proxyContract
      .connect(accounts[++accountIndex])
      .createContribution(contributions[i].category, contributions[i].title, contributions[i].url);
    await createContributionTx.wait();
  }

  console.log("Upvoting contributions...");
  for (let i = 3; i < 20; i++) {
    let contributionIdToVote = Math.floor(Math.random() * 2 + 1);

    const upvoteTx = await proxyContract.connect(accounts[i]).upvoteContribution(contributionIdToVote);
    await upvoteTx.wait();
  }

  console.log("Downvoting contribution with id 1...");
  const downvoteTx = await proxyContract.connect(accounts[3]).downvoteContribution(1);
  await downvoteTx.wait();

  console.log("Updating contribution with id 1...");
  const updateContributionTx = await proxyContract
    .connect(accounts[1])
    .updateContribution(
      1,
      3,
      "Harpie launches first on-chain firewall",
      "https://twitter.com/harpieio/status/1585300270686568448"
    );
  await updateContributionTx.wait();

  console.log("Removing contribution with id 15...");
  const removeContributionTx = await proxyContract.connect(accounts[1]).removeContribution(15);
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

  console.log("Increasing EVM time to mint a SBT for the contribution of the day...");
  await hre.run("increase-time");
  await hre.run("perform-upkeep");
});

async function createProfile(proxyContract: Contract, signer: Signer) {
  const randomString = (Math.random() + 1).toString(36).substring(2);
  const createProfileTx = await proxyContract.connect(signer).createUserProfile({
    username: randomString,
    lensHandle: randomString + ".lens",
    discordHandle: randomString + "#1337",
    twitterHandle: randomString,
    email: randomString + "@gmail.com",
    websiteUrl: "https://www." + randomString + ".xyz",
    valid: true,
  });
  await createProfileTx.wait();
}
