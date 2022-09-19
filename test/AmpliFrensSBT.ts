import { AmpliFrensSBT } from "../typechain-types/contracts/AmpliFrensSBT";
import { ethers, network } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumber } from "ethers";

// Increase time to 1 day elapsed expressed in milliseconds
async function increaseTime() {
  await network.provider.request({
    method: "evm_increaseTime",
    params: [1000 * 60 * 60 * 24],
  });
}
describe("Soulbound Token", async () => {
  let sbtContract: AmpliFrensSBT;
  let accounts: SignerWithAddress[];
  let timestampDeployment: Number;

  // The following consts will be used for default minting params
  const title = ethers.utils.formatBytes32String("Gud alpha , get latest WLs here");
  const contributionCategory = 7; // Misc category
  const timestamp = Math.floor(Date.now() / 1000); // convert timestamp to seconds
  const votes = 140;
  const url = "https://www.twitter.com/profile/alphaMaker";

  beforeEach(async () => {
    const sbtLogicLib = await (await (await ethers.getContractFactory("SBTLogic")).deploy()).deployed();
    const tokenURIHelperLib = await (await (await ethers.getContractFactory("TokenURI")).deploy()).deployed();
    const pseudoModifierLib = await (await (await ethers.getContractFactory("PseudoModifier")).deploy()).deployed();
    const statusLib = await (await (await ethers.getContractFactory("Status")).deploy()).deployed();

    const sbtContractFactory = await ethers.getContractFactory("AmpliFrensSBT", {
      libraries: {
        SBTLogic: sbtLogicLib.address,
        TokenURI: tokenURIHelperLib.address,
        PseudoModifier: pseudoModifierLib.address,
        Status: statusLib.address,
      },
    });
    accounts = await ethers.getSigners();

    sbtContract = (await sbtContractFactory.deploy(accounts[0].address)) as AmpliFrensSBT;
    await sbtContract.deployed();
    increaseTime();
    const setBaseURITx = await sbtContract.setBaseURI("https://www.example.com/");
    await setBaseURITx.wait();

    const mintTx = await sbtContract.mint({
      author: accounts[1].address,
      category: contributionCategory,
      valid: true,
      timestamp: timestamp,
      votes: votes,
      title: title,
      url: url,
    });
    await mintTx.wait();
    timestampDeployment = await (await ethers.provider.getBlock("latest")).timestamp;
  });

  describe("Initialization", async () => {
    it("Should set the last block timestamp as of the time of the deployment", async () => {
      expect(await sbtContract.lastBlockTimestamp()).to.eq(timestampDeployment);
    });
  });

  describe("Minting", async () => {
    it("Should be called once per day only", async () => {
      await expect(
        sbtContract.mint({
          author: accounts[1].address,
          category: contributionCategory,
          valid: true,
          timestamp: timestamp,
          votes: 500,
          title: title,
          url: url,
        })
      ).to.be.revertedWith("Minting interval not met");
    });
    it("Should increase the total tokens counter for address", async () => {
      increaseTime();
      const secondMintTx = sbtContract.mint({
        author: accounts[1].address,
        category: contributionCategory,
        valid: true,
        timestamp: timestamp,
        votes: 500,
        title: title,
        url: url,
      });
      expect(await sbtContract.totalTokensForAddress(accounts[1].address)).to.be.eq(2);
    });
    it("Should be called by admin role only", async () => {
      increaseTime();
      await expect(
        sbtContract.connect(accounts[1]).mint({
          author: accounts[1].address,
          category: contributionCategory,
          valid: true,
          timestamp: timestamp,
          votes: 500,
          title: title,
          url: url,
        })
      ).to.be.revertedWith("Unauthorized");
    });

    describe("Enumeration", async () => {
      it("Should increase the tokens emitted count", async () => {
        increaseTime();
        const secondMintTx = await sbtContract.mint({
          author: accounts[1].address,
          category: contributionCategory,
          valid: true,
          timestamp: timestamp,
          votes: 500,
          title: title,
          url: url,
        });
        await secondMintTx.wait();
        expect(await sbtContract.emittedCount()).to.eq(2);
      });

      it("Should track the tokens holders count properly", async () => {
        increaseTime();
        const mintTx = await sbtContract.mint({
          author: accounts[2].address,
          category: contributionCategory,
          valid: true,
          timestamp: timestamp,
          votes: 500,
          title: title,
          url: url,
        });
        await mintTx.wait();
        increaseTime();
        const secondMintTx = await sbtContract.mint({
          author: accounts[2].address,
          category: contributionCategory,
          valid: true,
          timestamp: timestamp,
          votes: 500,
          title: title,
          url: url,
        });
        await secondMintTx.wait();
        expect(await sbtContract.holdersCount()).to.eq(2);
      });

      it("Should be able to retrieve a tokenId using its position in an owner's list", async () => {
        // Total number of tokens should be 7 counting the one in beforeEach() for accounts[1].address
        for (let i = 0; i <= 5; i++) {
          increaseTime();
          const mintTx = await sbtContract.mint({
            author: ethers.Wallet.createRandom().address,
            category: contributionCategory,
            valid: true,
            timestamp: timestamp,
            votes: 500,
            title: title,
            url: url,
          });
          await mintTx.wait();
        }
        increaseTime();
        const mintTx = await sbtContract.mint({
          author: accounts[1].address,
          category: contributionCategory,
          valid: true,
          timestamp: timestamp,
          votes: 500,
          title: title,
          url: url,
        });
        await mintTx.wait();
        expect(await sbtContract.tokenOfOwnerByIndex(accounts[1].address, 1)).to.be.eq(8);
      });

      it("Should return the correct tokenId for a given index", async () => {
        expect(await sbtContract.tokenByIndex(1)).to.eq(1);
      });
    });
  });

  describe("Ownership", async () => {
    it("Should update the token balances accordingly", async () => {
      increaseTime();
      expect(await sbtContract.balanceOf(accounts[0].address)).to.eq(0);
      expect(await sbtContract.balanceOf(accounts[1].address)).to.eq(1);
      const mintTx = await sbtContract.mint({
        author: accounts[1].address,
        category: contributionCategory,
        valid: true,
        timestamp: timestamp,
        votes: 500,
        title: title,
        url: url,
      });
      await mintTx.wait();
      expect(await sbtContract.balanceOf(accounts[1].address)).to.eq(2);
    });
    it("Should identify properly the owner of a tokenId", async () => {
      increaseTime();
      const mintTx = await sbtContract.mint({
        author: accounts[2].address,
        category: contributionCategory,
        valid: true,
        timestamp: timestamp,
        votes: 500,
        title: title,
        url: url,
      });
      await mintTx.wait();
      expect(await sbtContract.ownerOf(2)).to.be.eq(accounts[2].address);
    });
  });

  describe("Revocation", async () => {
    it("Should identify a token as invalid if it has been revoked", async () => {
      const revokeTx = await sbtContract.revoke(1);
      revokeTx.wait();
      expect(await sbtContract.isValid(1)).to.be.false;
    });
    it("Should decrease the total tokens counter for address after a revocation", async () => {
      expect(await sbtContract.hasValid(accounts[1].address)).to.be.true;
      const revokeTx = await sbtContract.revoke(1);
      revokeTx.wait();
      expect(await sbtContract.totalTokensForAddress(accounts[1].address)).to.be.eq(0);
    });
    it("Should properly check if an address owns a valid token", async () => {
      expect(await sbtContract.hasValid(accounts[1].address)).to.be.true;
      const revokeTx = await sbtContract.revoke(1);
      revokeTx.wait();
      expect(await sbtContract.hasValid(accounts[1].address)).to.be.false;
    });
    it("Should be called by admin role only", async () => {
      await expect(sbtContract.connect(accounts[1]).revoke(1)).to.be.revertedWith("Unauthorized");
    });
    it("Should revert if the token id for revocation is out of bounds", async () => {
      await expect(sbtContract.revoke(1337)).to.be.revertedWith("Out of bounds");
      await expect(sbtContract.revoke(0)).to.be.revertedWith("Out of bounds");
    });
  });
  describe("Metadata", async () => {
    it("Should return the correct name", async () => {
      expect(await sbtContract.name()).to.be.eq("AmpliFrens Contribution Award");
    });
    it("Should return the correct symbol", async () => {
      expect(await sbtContract.symbol()).to.be.eq("AFRENCONTRIBUTION");
    });
    it("Should set the Token URI correctly", async () => {
      increaseTime();
      const mintTx = await sbtContract.mint({
        author: accounts[1].address,
        category: contributionCategory,
        valid: true,
        timestamp: timestamp,
        votes: 500,
        title: title,
        url: url,
      });
      await mintTx.wait();
      const tokenURI = await sbtContract.tokenURI(BigNumber.from("2"));
      expect(tokenURI).to.eq("https://www.example.com/2.json");
    });

    it("Should revert if an invalid token URI parameter is provided", async () => {
      await expect(sbtContract.tokenURI("101")).to.be.revertedWith("Invalid token id");
    });
    it("Should change the base URI correctly", async () => {
      increaseTime();
      const setTokenURITx = await sbtContract.setBaseURI("https://www.amplifrens.xyz/");
      await setTokenURITx.wait();
      const mintTx = await sbtContract.mint({
        author: accounts[1].address,
        category: contributionCategory,
        valid: true,
        timestamp: timestamp,
        votes: 500,
        title: title,
        url: url,
      });
      await mintTx.wait();
      const tokenURI = await sbtContract.tokenURI(BigNumber.from("1"));
      expect(tokenURI).to.eq("https://www.amplifrens.xyz/1.json");
    });
  });

  describe("Status", async () => {
    it("Should get the correct status if the address has no tokens", async () => {
      expect(await sbtContract.getStatus(accounts[2].address)).to.eq(0);
    });
    it("Should get the correct status if the address has earnt 1 token", async () => {
      expect(await sbtContract.getStatus(accounts[1].address)).to.eq(1);
    });
    it("Should get the correct status if the address has earnt 5 tokens", async () => {
      for (let i = 0; i <= 4; i++) {
        increaseTime();
        const mintTx = await sbtContract.mint({
          author: accounts[2].address,
          category: contributionCategory,
          valid: true,
          timestamp: timestamp,
          votes: 500,
          title: title,
          url: url,
        });
        await mintTx.wait();
      }
      expect(await sbtContract.getStatus(accounts[2].address)).to.eq(2);
    });
    it("Should get the correct status if the address has earnt 13 tokens", async () => {
      for (let i = 0; i <= 12; i++) {
        increaseTime();
        const mintTx = await sbtContract.mint({
          author: accounts[2].address,
          category: contributionCategory,
          valid: true,
          timestamp: timestamp,
          votes: 500,
          title: title,
          url: url,
        });
        await mintTx.wait();
      }
      expect(await sbtContract.getStatus(accounts[2].address)).to.eq(3);
    });
    it("Should get the correct status if the address has earnt 21 tokens", async () => {
      for (let i = 0; i <= 20; i++) {
        increaseTime();
        const mintTx = await sbtContract.mint({
          author: accounts[2].address,
          category: contributionCategory,
          valid: true,
          timestamp: timestamp,
          votes: 500,
          title: title,
          url: url,
        });
        await mintTx.wait();
      }
      expect(await sbtContract.getStatus(accounts[2].address)).to.eq(4);
    });
    it("Should get the correct status if the address has earnt 34 tokens", async () => {
      for (let i = 0; i <= 33; i++) {
        increaseTime();
        const mintTx = await sbtContract.mint({
          author: accounts[2].address,
          category: contributionCategory,
          valid: true,
          timestamp: timestamp,
          votes: 500,
          title: title,
          url: url,
        });
        await mintTx.wait();
      }
      expect(await sbtContract.getStatus(accounts[2].address)).to.eq(5);
    });
  });

  describe("Events", async () => {
    it("Should emit a Minted event when a token is minted", async () => {
      increaseTime();
      await expect(
        sbtContract.mint({
          author: accounts[1].address,
          category: contributionCategory,
          valid: true,
          timestamp: timestamp,
          votes: 500,
          title: title,
          url: url,
        })
      )
        .to.emit(sbtContract, "Minted")
        .withArgs(accounts[1].address, 2);
    });
    it("Should emit a Revoked event when a token is revoked", async () => {
      increaseTime();
      await expect(sbtContract.revoke(1)).to.emit(sbtContract, "Revoked").withArgs(accounts[1].address, 1);
    });
  });
  describe("Interfaces", async () => {
    it("Should support IAmpliFrensSBT", async () => {
      expect(await sbtContract.supportsInterface("0xbbffdbe5")).to.be.true;
    });
  });
});
