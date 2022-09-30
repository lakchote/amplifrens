import { ethers } from "hardhat";
import { expect } from "chai";
import {
  AmpliFrensFacade,
  AmpliFrensFacade__factory,
  TransparentUpgradeableProxy__factory,
  AmpliFrensSBTFacadeMock,
  AmpliFrensContributionFacadeMock,
  AmpliFrensNFTFacadeMock,
  AmpliFrensProfileFacadeMock,
} from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("Facade", async () => {
  let facadeProxyContract: AmpliFrensFacade;
  let facadeImplContract: AmpliFrensFacade;
  let nftContract: AmpliFrensNFTFacadeMock;
  let sbtContract: AmpliFrensSBTFacadeMock;
  let profileContract: AmpliFrensProfileFacadeMock;
  let contributionContract: AmpliFrensContributionFacadeMock;
  let accounts: SignerWithAddress[];

  const profileCallData = {
    username: ethers.utils.formatBytes32String("ethernal"),
    lensHandle: ethers.utils.formatBytes32String("ethernal.lens"),
    discordHandle: ethers.utils.formatBytes32String("ethernal#1337"),
    twitterHandle: ethers.utils.formatBytes32String("ethernal"),
    email: ethers.utils.formatBytes32String("ethern@l.com"),
    websiteUrl: "https://www.anon.xyz",
    valid: true,
  };

  beforeEach(async () => {
    accounts = await ethers.getSigners();

    const nftContractFactory = await ethers.getContractFactory("AmpliFrensNFTFacadeMock");
    nftContract = (await (await nftContractFactory.deploy()).deployed()) as AmpliFrensNFTFacadeMock;

    const sbtContractFactory = await ethers.getContractFactory("AmpliFrensSBTFacadeMock");
    sbtContract = (await (await sbtContractFactory.deploy()).deployed()) as AmpliFrensSBTFacadeMock;

    const profileContractFactory = await ethers.getContractFactory("AmpliFrensProfileFacadeMock");
    profileContract = (await (await profileContractFactory.deploy()).deployed()) as AmpliFrensProfileFacadeMock;

    const contributionContractFactory = await ethers.getContractFactory("AmpliFrensContributionFacadeMock");
    contributionContract = (await (
      await contributionContractFactory.deploy()
    ).deployed()) as AmpliFrensContributionFacadeMock;

    const facadeImplContractFactory = await ethers.getContractFactory("AmpliFrensFacade");
    facadeImplContract = (await (
      await facadeImplContractFactory.deploy(
        contributionContract.address,
        profileContract.address,
        nftContract.address,
        sbtContract.address
      )
    ).deployed()) as AmpliFrensFacade;

    const proxyFactory = await new TransparentUpgradeableProxy__factory(accounts[0]).deploy(
      facadeImplContract.address,
      accounts[0].address,
      facadeImplContract.interface.encodeFunctionData("initialize", [accounts[1].address])
    );
    facadeProxyContract = AmpliFrensFacade__factory.connect(proxyFactory.address, accounts[1]);
  });

  describe("Upgradeability", async () => {
    it("Should be initializable once only", async () => {
      await expect(facadeProxyContract.initialize(accounts[2].address)).to.be.revertedWith(
        "Initializable: contract is already initialized"
      );
    });
  });

  describe("NFT", async () => {
    it("Should forward to IAmpliFrensNFT to mint NFT", async () => {
      await expect(await facadeProxyContract.mintNFT(accounts[2].address, "1")).to.emit(nftContract, "NFTContract");
    });

    it("Should forward to IAmpliFrensNFT to transfer NFT", async () => {
      await expect(await facadeProxyContract.transferNFT(accounts[0].address, accounts[1].address, "1")).to.emit(
        nftContract,
        "NFTContract"
      );
    });

    it("Should forward to IAmpliFrensNFT to set NFT base uri", async () => {
      await expect(await facadeProxyContract.setNFTBaseURI("https://www.amplifrens.xyz")).to.emit(
        nftContract,
        "NFTContract"
      );
    });

    it("Should forward to IAmpliFrensNFT to get NFT uri", async () => {
      expect(await facadeProxyContract.uriNft(1)).to.be.eq("IAmpliFrensNFT");
    });
  });

  describe("SBT", async () => {
    it("Should forward to IAmpliFrensSBT to check if upkeep is needed", async () => {
      // in the mock, isMintingInterval() returns true by default
      const result = await facadeProxyContract.checkUpkeep(ethers.utils.hexlify(0));
      expect(result[0]).to.eq(true);
    });

    it("Should forward to IAmpliFrensSBT to mint SBT tokens", async () => {
      await expect(await facadeProxyContract.performUpkeep(ethers.utils.hexlify(0))).to.emit(
        sbtContract,
        "SBTContract"
      );
    });

    it("Should forward to IAmpliFrensSBT to set SBT base URI", async () => {
      await expect(await facadeProxyContract.setSBTBaseURI("https://www.amplifrens.xyz")).to.emit(
        sbtContract,
        "SBTContract"
      );
    });

    it("Should forward to IAmpliFrensSBT to retrieve a SBT token", async () => {
      // in the mock, tokenById() return 1337 votes
      const contribution = await facadeProxyContract.getSBTById(0);
      expect(contribution.votes).to.eq(1337);
    });

    it("Should forward to IAmpliFrensSBT to get total SBT tokens emitted", async () => {
      // in the mock, it should return 31337 tokens
      expect(await facadeProxyContract.totalSBTs()).to.eq(31337);
    });

    it("Should forward to IAmpliFrensSBT to get total SBT tokens holders", async () => {
      // in the mock, it should return 1337 holders
      expect(await facadeProxyContract.totalSBTHolders()).to.eq(1337);
    });

    it("Should forward to IAmpliFrensSBT to get balance of SBT tokens", async () => {
      // in the mock, it should return 31337 holders
      expect(await facadeProxyContract.balanceOfSBT("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045")).to.eq(31337);
    });

    it("Should forward to IAmpliFrensSBT to get owner of SBT tokens", async () => {
      const ownerOf = await facadeProxyContract.ownerOfSBT(0);
      expect(ownerOf).to.eq("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045");
    });

    it("Should forward to IAmpliFrensSBT to get index of a SBT token for an address", async () => {
      const tokenIndex = await facadeProxyContract.idSBTOfOwnerByIndex("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045", 0);
      expect(tokenIndex).to.eq(1337);
    });

    it("Should forward to IAmpliFrensSBT to get SBT uri", async () => {
      expect(await facadeProxyContract.uriSBT(1)).to.be.eq("IAmpliFrensSBT");
    });
  });

  describe("Profile", async () => {
    it("Should forward to IAmpliFrensProfile to create profile", async () => {
      await expect(await facadeProxyContract.createUserProfile(profileCallData)).to.emit(
        profileContract,
        "ProfileContract"
      );
    });

    it("Should forward to IAmpliFrensProfile to update profile", async () => {
      await expect(await facadeProxyContract.updateUserProfile(profileCallData)).to.emit(
        profileContract,
        "ProfileContract"
      );
    });

    it("Should forward to IAmpliFrensProfile to delete profile", async () => {
      await expect(await facadeProxyContract.deleteUserProfile("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045")).to.emit(
        profileContract,
        "ProfileContract"
      );
    });

    it("Should forward to IAmpliFrensProfile to blacklist profile", async () => {
      await expect(
        await facadeProxyContract.blacklistUserProfile(
          "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
          ethers.utils.formatBytes32String("Spam")
        )
      ).to.emit(profileContract, "ProfileContract");
    });

    it("Should forward to IAmpliFrensProfile to get a profile by an address", async () => {
      const profile = await facadeProxyContract.getUserProfile("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045");
      await expect(profile.websiteUrl).to.eq("https://www.anon.xyz");
    });

    it("Should forward to IAmpliFrensProfile to get a profile's blacklist reason", async () => {
      const blacklistReason = await facadeProxyContract.getProfileBlacklistReason(
        "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
      );
      await expect(blacklistReason).to.eq(ethers.utils.formatBytes32String("IAmpliFrensProfile"));
    });

    it("Should forward to IAmpliFrensProfile to check a profile's existence", async () => {
      // in the mock, it should return true
      const hasProfile = await facadeProxyContract.hasUserProfile("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045");
      await expect(hasProfile).to.eq(true);
    });
  });

  describe("Contribution", async () => {
    it("Should forward to IAmpliFrensContribution to upvote contribution", async () => {
      await expect(await facadeProxyContract.upvoteContribution(0)).to.emit(
        contributionContract,
        "ContributionContract"
      );
    });

    it("Should forward to IAmpliFrensContribution to downvote contribution", async () => {
      await expect(await facadeProxyContract.downvoteContribution(0)).to.emit(
        contributionContract,
        "ContributionContract"
      );
    });

    it("Should forward to IAmpliFrensContribution to create contribution", async () => {
      await expect(
        await facadeProxyContract.createContribution({
          category: 1,
          title: ethers.utils.formatBytes32String("This is awesome"),
          url: "https://messari.io/report/ratio-finance-collateralized-debt-positions-on-solana",
          author: accounts[0].address,
          valid: true,
          timestamp: 1664347831,
          votes: 0,
        })
      ).to.emit(contributionContract, "ContributionContract");
    });

    it("Should forward to IAmpliFrensContribution to update contribution", async () => {
      await expect(
        await facadeProxyContract.updateContribution(0, {
          category: 1,
          title: ethers.utils.formatBytes32String("This is awesome"),
          url: "https://messari.io/report/ratio-finance-collateralized-debt-positions-on-solana",
          author: accounts[0].address,
          valid: true,
          timestamp: 1664347831,
          votes: 0,
        })
      ).to.emit(contributionContract, "ContributionContract");
    });

    it("Should forward to IAmpliFrensContribution to remove contribution", async () => {
      await expect(await facadeProxyContract.removeContribution(0)).to.emit(
        contributionContract,
        "ContributionContract"
      );
    });

    it("Should forward to IAmpliFrensContribution to reset contributions", async () => {
      await expect(await facadeProxyContract.resetContributions()).to.emit(
        contributionContract,
        "ContributionContract"
      );
    });

    it("Should forward to IAmpliFrensContribution to get contributions", async () => {
      const contributions = await facadeProxyContract.getContributions();
      await expect(contributions[0].timestamp).to.eq(1664280770);
    });

    it("Should forward to IAmpliFrensContribution to get contribution", async () => {
      const contribution = await facadeProxyContract.getContribution(0);
      await expect(contribution.timestamp).to.eq(1664280770);
    });

    it("Should forward to IAmpliFrensContribution to get top contribution", async () => {
      const topContribution = await facadeProxyContract.topContribution();
      await expect(topContribution.timestamp).to.eq(1664280770);
    });

    it("Should forward to IAmpliFrensContribution to get contributions count", async () => {
      expect(await facadeProxyContract.totalContributions()).to.eq(31337);
    });
  });

  describe("Pausing", async () => {
    it("Should prevent core features when paused", async () => {
      const pauseTx = await facadeProxyContract.pause();
      await pauseTx.wait();

      await expect(facadeProxyContract.performUpkeep(ethers.utils.hexlify(0))).to.be.revertedWith("Pausable: paused");
      await expect(facadeProxyContract.setSBTBaseURI("https://www.amplifrens.xyz")).to.be.revertedWith(
        "Pausable: paused"
      );
      await expect(facadeProxyContract.createUserProfile(profileCallData)).to.be.revertedWith("Pausable: paused");
      await expect(facadeProxyContract.updateUserProfile(profileCallData)).to.be.revertedWith("Pausable: paused");
      await expect(
        facadeProxyContract.deleteUserProfile("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045")
      ).to.be.revertedWith("Pausable: paused");
      await expect(
        facadeProxyContract.blacklistUserProfile(
          "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
          ethers.utils.formatBytes32String("Spam")
        )
      ).to.be.revertedWith("Pausable: paused");
      await expect(facadeProxyContract.upvoteContribution(1)).to.be.revertedWith("Pausable: paused");
      await expect(facadeProxyContract.downvoteContribution(1)).to.be.revertedWith("Pausable: paused");
      await expect(facadeProxyContract.removeContribution(1)).to.be.revertedWith("Pausable: paused");
      await expect(
        facadeProxyContract.updateContribution(1, {
          category: 1,
          title: ethers.utils.formatBytes32String("This is awesome"),
          url: "https://messari.io/report/ratio-finance-collateralized-debt-positions-on-solana",
          author: accounts[0].address,
          valid: true,
          timestamp: 1664347831,
          votes: 0,
        })
      ).to.be.revertedWith("Pausable: paused");
      await expect(
        facadeProxyContract.createContribution({
          category: 1,
          title: ethers.utils.formatBytes32String("This is awesome"),
          url: "https://messari.io/report/ratio-finance-collateralized-debt-positions-on-solana",
          author: accounts[0].address,
          valid: true,
          timestamp: 1664347831,
          votes: 0,
        })
      ).to.be.revertedWith("Pausable: paused");
      await expect(
        facadeProxyContract.mintNFT("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045", "https://www.amplifrens.xyz")
      ).to.be.revertedWith("Pausable: paused");
      await expect(facadeProxyContract.setNFTBaseURI("https://www.amplifrens.xyz")).to.be.revertedWith(
        "Pausable: paused"
      );
      await expect(
        facadeProxyContract.setNFTGlobalRoyalties("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045", 1000)
      ).to.be.revertedWith("Pausable: paused");
    });
    it("Should resume core features when unpaused", async () => {
      const pauseTx = await facadeProxyContract.pause();
      await pauseTx.wait();

      await expect(facadeProxyContract.performUpkeep(ethers.utils.hexlify(0))).to.be.revertedWith("Pausable: paused");

      const unpauseTx = await facadeProxyContract.unpause();
      await unpauseTx.wait();

      await expect(facadeProxyContract.performUpkeep(ethers.utils.hexlify(0))).to.not.be.revertedWith(
        "Pausable: paused"
      );
      await expect(facadeProxyContract.setSBTBaseURI("https://www.amplifrens.xyz")).to.not.be.revertedWith(
        "Pausable: paused"
      );
      await expect(facadeProxyContract.createUserProfile(profileCallData)).to.not.be.revertedWith("Pausable: paused");
      await expect(facadeProxyContract.updateUserProfile(profileCallData)).to.not.be.revertedWith("Pausable: paused");
      await expect(
        facadeProxyContract.deleteUserProfile("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045")
      ).to.not.be.revertedWith("Pausable: paused");
      await expect(
        facadeProxyContract.blacklistUserProfile(
          "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
          ethers.utils.formatBytes32String("Spam")
        )
      ).to.not.be.revertedWith("Pausable: paused");
      await expect(facadeProxyContract.upvoteContribution(1)).to.not.be.revertedWith("Pausable: paused");
      await expect(facadeProxyContract.downvoteContribution(1)).to.not.be.revertedWith("Pausable: paused");
      await expect(facadeProxyContract.removeContribution(1)).to.not.be.revertedWith("Pausable: paused");
      await expect(
        facadeProxyContract.updateContribution(1, {
          category: 1,
          title: ethers.utils.formatBytes32String("This is awesome"),
          url: "https://messari.io/report/ratio-finance-collateralized-debt-positions-on-solana",
          author: accounts[0].address,
          valid: true,
          timestamp: 1664347831,
          votes: 0,
        })
      ).to.not.be.revertedWith("Pausable: paused");
      await expect(
        facadeProxyContract.createContribution({
          category: 1,
          title: ethers.utils.formatBytes32String("This is awesome"),
          url: "https://messari.io/report/ratio-finance-collateralized-debt-positions-on-solana",
          author: accounts[0].address,
          valid: true,
          timestamp: 1664347831,
          votes: 0,
        })
      ).to.not.be.revertedWith("Pausable: paused");
      await expect(
        facadeProxyContract.mintNFT("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045", "https://www.amplifrens.xyz")
      ).to.not.be.revertedWith("Pausable: paused");
      await expect(facadeProxyContract.setNFTBaseURI("https://www.amplifrens.xyz")).to.not.be.revertedWith(
        "Pausable: paused"
      );
      await expect(
        facadeProxyContract.setNFTGlobalRoyalties("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045", 1000)
      ).to.not.be.revertedWith("Pausable: paused");
    });
  });

  describe("Access roles", async () => {
    it("Should prevent core features to be called by someone who doesn't has admin role", async () => {
      await expect(facadeProxyContract.connect(accounts[2]).setNFTBaseURI("https://www.amplifrens.xyz")).to.be.reverted;
      await expect(facadeProxyContract.connect(accounts[2]).setSBTBaseURI("https://www.amplifrens.xyz")).to.be.reverted;
      await expect(
        facadeProxyContract.connect(accounts[2]).deleteUserProfile("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045")
      ).to.be.reverted;
      await expect(
        facadeProxyContract
          .connect(accounts[2])
          .blacklistUserProfile("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045", ethers.utils.formatBytes32String("Spam"))
      ).to.be.reverted;
      await expect(facadeProxyContract.connect(accounts[2]).resetContributions()).to.be.reverted;
      await expect(
        facadeProxyContract
          .connect(accounts[2])
          .mintNFT("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045", "https://www.amplifrens.xyz")
      ).to.be.reverted;
      await expect(
        facadeProxyContract
          .connect(accounts[2])
          .setNFTGlobalRoyalties("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045", 1000)
      ).to.be.reverted;
      await expect(facadeProxyContract.connect(accounts[2]).pause()).to.be.reverted;
      await expect(facadeProxyContract.connect(accounts[2]).unpause()).to.be.reverted;
    });
  });

  describe("Interfaces", async () => {
    it("Should support IAmpliFrensFacade", async () => {
      expect(await facadeProxyContract.supportsInterface("0x9f1f0e8e")).to.be.true;
    });

    it("Should support IERC165", async () => {
      expect(await facadeProxyContract.supportsInterface("0x7965db0b")).to.be.true;
    });

    it("Should support IAccessControlUpgradeable", async () => {
      expect(await facadeProxyContract.supportsInterface("0x01ffc9a7")).to.be.true;
    });
  });
});
