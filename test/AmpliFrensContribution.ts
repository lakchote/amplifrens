import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { expect } from "chai";
import { AmpliFrensContribution, AmpliFrensContribution__factory, Errors } from "../typechain-types";

describe("Contribution", async () => {
  let contributionContract: AmpliFrensContribution;
  let accounts: SignerWithAddress[];
  let errorsLib: Errors;

  // The following consts will be used for default contribution params
  const title = "Gud alpha , get latest WLs here";
  const contributionCategory = 7; // Misc category
  const url = "https://www.twitter.com/profile/alphaMaker";

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    const pseudoModifierLib = await (await (await ethers.getContractFactory("PseudoModifier")).deploy()).deployed();
    const contributionLogicLib = await (
      await (
        await ethers.getContractFactory("ContributionLogic", {
          libraries: {
            PseudoModifier: pseudoModifierLib.address,
          },
        })
      ).deploy()
    ).deployed();
    errorsLib = (await (await (await ethers.getContractFactory("Errors")).deploy()).deployed()) as Errors;

    const contributionContractFactory = (await ethers.getContractFactory("AmpliFrensContribution", {
      libraries: {
        ContributionLogic: contributionLogicLib.address,
      },
    })) as AmpliFrensContribution__factory;

    contributionContract = await contributionContractFactory.deploy(accounts[0].address, accounts[0].address);
  });

  describe("Creation", async () => {
    it("Should create a contribution successfully", async () => {
      await expect(contributionContract.create(contributionCategory, title, url, accounts[0].address))
        .to.emit(contributionContract, "ContributionCreated")
        .withArgs(
          accounts[0].address,
          1,
          (await (await ethers.provider.getBlock("latest")).timestamp) + 1,
          contributionCategory,
          title,
          url
        );
    });

    it("Should update the contributions count", async () => {
      expect(await contributionContract.contributionsCount()).to.eq(0);
      const createTx = await contributionContract.create(contributionCategory, title, url, accounts[0].address);

      await createTx.wait();
      expect(await contributionContract.contributionsCount()).to.eq(1);
    });

    it("Should throw an error if an user tries to spoof the from address", async () => {
      await expect(
        contributionContract.connect(accounts[2]).create(contributionCategory, title, url, accounts[1].address)
      ).to.be.revertedWithCustomError(errorsLib, "Unauthorized");
    });
  });

  describe("Update", async () => {
    const newTitle = "Contribution updated";
    const newUrl = "https://www.test.com";
    const newCategory = 2;

    beforeEach(async () => {
      const createTx = await contributionContract.create(contributionCategory, title, url, accounts[0].address);
      await createTx.wait();
    });

    it("Should update a contribution by its id", async () => {
      let contribution = await contributionContract.getContribution(1);
      expect(await contribution.title).to.eq(title);
      await expect(contributionContract.update(1, newCategory, newTitle, newUrl, accounts[0].address))
        .to.emit(contributionContract, "ContributionUpdated")
        .withArgs(
          accounts[0].address,
          1,
          (
            await ethers.provider.getBlock("latest")
          ).timestamp,
          newCategory,
          newTitle,
          newUrl
        );
      contribution = await contributionContract.getContribution(1);
      expect(await contribution.category).to.eq(newCategory);
      expect(await contribution.title).to.eq(newTitle);
      expect(await contribution.url).to.eq(newUrl);
    });

    it("Should not update a contribution's title if it's empty", async () => {
      let contribution = await contributionContract.getContribution(1);
      expect(await contribution.title).to.eq(title);
      const updateTx = await contributionContract.update(1, newCategory, "", newUrl, accounts[0].address);
      await updateTx.wait();
      contribution = await contributionContract.getContribution(1);
      expect(await contribution.title).to.not.eq("");
    });

    it("Should not update a contribution's url if it's empty", async () => {
      let contribution = await contributionContract.getContribution(1);
      expect(await contribution.url).to.eq(url);
      const updateTx = await contributionContract.update(1, newCategory, newTitle, "", accounts[0].address);
      await updateTx.wait();
      contribution = await contributionContract.getContribution(1);
      expect(await contribution.url).to.not.eq("");
    });

    it("Should throw an error if an user tries to update a contribution whom he is not the author", async () => {
      await expect(
        contributionContract.update(1, newCategory, newTitle, newUrl, accounts[1].address)
      ).to.be.revertedWithCustomError(errorsLib, "Unauthorized");
    });

    it("Should be able to update a contribution if the user has admin role", async () => {
      const createTx = await contributionContract.create(contributionCategory, title, url, accounts[0].address);
      await createTx.wait();
      const updateTx = await contributionContract.update(2, newCategory, newTitle, newUrl, accounts[0].address);
      await updateTx.wait();
      const contribution = await contributionContract.getContribution(2);
      expect(await contribution.category).to.eq(newCategory);
    });

    it("Should throw an error if the index if out of bounds", async () => {
      await expect(contributionContract.remove(1337, accounts[0].address)).to.be.revertedWithCustomError(
        errorsLib,
        "OutOfBounds"
      );
    });
  });

  describe("Delete", async () => {
    beforeEach(async () => {
      for (let i = 0; i <= 5; i++) {
        const createTx = await contributionContract.create(contributionCategory, title, url, accounts[1].address);
        await createTx.wait();
      }
    });

    it("Should remove a contribution from the list", async () => {
      let contribution = await contributionContract.getContribution(1);
      expect(await contribution.title).to.eq(title);
      expect(await contributionContract.remove(1, accounts[1].address))
        .to.emit(contributionContract, "ContributionRemoved")
        .withArgs(accounts[1].address, 1, (await ethers.provider.getBlock("latest")).timestamp);
      await expect(contributionContract.getContribution(1)).to.be.revertedWithCustomError(errorsLib, "OutOfBounds");
    });

    it("Should update the contributions count", async () => {
      expect(await contributionContract.contributionsCount()).to.eq(6);
      const removeTx = await contributionContract.remove(1, accounts[0].address);
      await removeTx.wait();
      expect(await contributionContract.contributionsCount()).to.eq(5);
    });

    it("Should be able to delete a contribution if the user has admin role", async () => {
      await expect(contributionContract.remove(1, accounts[0].address)).to.not.be.revertedWithCustomError(
        errorsLib,
        "Unauthorized"
      );
    });

    it("Should throw an error if an user tries to delete a contribution whom he is not the author", async () => {
      await expect(contributionContract.remove(1, accounts[2].address)).to.be.revertedWithCustomError(
        errorsLib,
        "Unauthorized"
      );
    });

    it("Should throw an error if the index if out of bounds", async () => {
      await expect(contributionContract.remove(1337, accounts[0].address)).to.be.revertedWithCustomError(
        errorsLib,
        "OutOfBounds"
      );
    });
  });

  describe("Reset", async () => {
    it("Should remove all contributions", async () => {
      // Create contributions
      for (let i = 0; i < 2; i++) {
        const createTx = await contributionContract.create(contributionCategory, title, url, accounts[0].address);
        await createTx.wait();
      }

      // Simulate voting
      for (let i = 1; i <= 10; i++) {
        const voteTx = await contributionContract
          .connect(accounts[i])
          .upvote(Math.floor(Math.random() * 2 + 1), accounts[i].address);
        await voteTx.wait();
      }
      for (let i = 10; i <= 12; i++) {
        const voteTx = await contributionContract
          .connect(accounts[i])
          .downvote(Math.floor(Math.random() * 2 + 1), accounts[i].address);
        await voteTx.wait();
      }

      let contribution = await contributionContract.getContribution(1);
      expect(await contribution.title).to.eq(title);
      expect(await contributionContract.contributionsCount()).to.eq(2);
      const resetTx = await contributionContract.reset(accounts[0].address);
      await resetTx.wait();

      expect(await contributionContract.contributionsCount()).to.eq(0);
      await expect(contributionContract.getContribution(1)).to.be.revertedWithCustomError(errorsLib, "OutOfBounds");
    });

    it("Should be able to reset if the user has admin role only", async () => {
      await expect(contributionContract.reset(accounts[0].address)).to.not.be.revertedWithCustomError(
        errorsLib,
        "Unauthorized"
      );
      await expect(contributionContract.reset(accounts[1].address)).to.be.revertedWithCustomError(
        errorsLib,
        "Unauthorized"
      );
    });
  });

  describe("Voting", async () => {
    beforeEach(async () => {
      const createTx = await contributionContract.create(contributionCategory, title, url, accounts[0].address);
      await createTx.wait();
      for (let i = 1; i <= 10; i++) {
        const voteTx = await contributionContract.upvote(1, accounts[i].address);
        await voteTx.wait();
      }
    });

    it("Should retrieve the most upvoted contribution for a given day", async () => {
      const createTx = await contributionContract.create(
        7,
        "NEW NFT Marketplace",
        "https://www.ethernal.xyz",
        accounts[1].address
      );
      await createTx.wait();

      for (let i = 11; i <= 19; i++) {
        const voteTx = await contributionContract.upvote(2, accounts[i].address);
        await voteTx.wait();
      }

      const topContribution = await contributionContract.topContribution();
      expect(topContribution.title).to.eq(title);
      expect(topContribution.category).to.eq(contributionCategory);
      expect(topContribution.url).to.eq(url);
      expect(topContribution.author).to.eq(accounts[0].address);

      const removeContributionTx = await contributionContract.remove(1, accounts[0].address);
      await removeContributionTx.wait();

      const updatedTopContribution = await contributionContract.topContribution();
      expect(updatedTopContribution.title).to.eq("NEW NFT Marketplace");
      expect(updatedTopContribution.category).to.eq(7);
      expect(updatedTopContribution.url).to.eq("https://www.ethernal.xyz");
      expect(updatedTopContribution.author).to.eq(accounts[1].address);
    });

    it("Should increase a contribution's votes on upvote", async () => {
      let contribution = await contributionContract.getContribution(1);
      expect(await contribution.votes).to.eq(10);
      expect(await contributionContract.upvote(1, accounts[11].address))
        .to.emit(contributionContract, "ContributionUpvoted")
        .withArgs(accounts[11].address, 1, (await ethers.provider.getBlock("latest")).timestamp);
      contribution = await contributionContract.getContribution(1);
      expect(await contribution.votes).to.eq(11);
    });

    it("Should decrease a contribution's votes on downvote", async () => {
      let contribution = await contributionContract.getContribution(1);
      expect(await contribution.votes).to.eq(10);
      expect(await contributionContract.downvote(1, accounts[11].address))
        .to.emit(contributionContract, "ContributionDownvoted")
        .withArgs(accounts[11].address, 1, (await ethers.provider.getBlock("latest")).timestamp);
      contribution = await contributionContract.getContribution(1);
      expect(await contribution.votes).to.eq(9);
    });

    it("Should be possible to upvote only once for a contribution", async () => {
      await expect(contributionContract.upvote(1, accounts[1].address)).to.be.revertedWithCustomError(
        errorsLib,
        "AlreadyVoted"
      );
    });

    it("Should be possible to downvote only once for a contribution", async () => {
      const voteTx = await contributionContract.downvote(1, accounts[1].address);
      await voteTx.wait();
      await expect(contributionContract.downvote(1, accounts[1].address)).to.be.revertedWithCustomError(
        errorsLib,
        "AlreadyVoted"
      );
    });

    it("Should not be possible to vote for our own contribution", async () => {
      await expect(contributionContract.upvote(1, accounts[0].address)).to.be.revertedWithCustomError(
        errorsLib,
        "Unauthorized"
      );
    });

    it("Should not be possible to downvote our own contribution", async () => {
      await expect(contributionContract.upvote(1, accounts[0].address)).to.be.revertedWithCustomError(
        errorsLib,
        "Unauthorized"
      );
    });

    it("Should throw an error if the index if out of bounds", async () => {
      await expect(contributionContract.upvote(1337, accounts[0].address)).to.be.revertedWithCustomError(
        errorsLib,
        "OutOfBounds"
      );
      await expect(contributionContract.downvote(1337, accounts[0].address)).to.be.revertedWithCustomError(
        errorsLib,
        "OutOfBounds"
      );
    });
  });

  describe("Enumeration", async () => {
    const titles = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"];

    beforeEach(async () => {
      for (let i = 1; i < 10; i++) {
        const createTx = await contributionContract.create(contributionCategory, titles[i], url, accounts[0].address);
        await createTx.wait();
      }
    });

    it("Should retrieve a contribution by its id", async () => {
      const createTx = await contributionContract.create(
        0,
        "Alpha alert",
        "https://www.twitter.com/ElonSecretProject",
        accounts[0].address
      );
      await createTx.wait();
      const contribution = await contributionContract.getContribution(10);
      expect(await contribution.category).to.eq(0);
      expect(await contribution.title).to.eq("Alpha alert");
      expect(await contribution.url).to.eq("https://www.twitter.com/ElonSecretProject");
    });

    it("Should throw an error if the index if out of bounds", async () => {
      await expect(contributionContract.getContribution(1337)).to.be.revertedWithCustomError(errorsLib, "OutOfBounds");
    });

    it("Should be able to increase the days counter correctly", async () => {
      const firstContribution = await contributionContract.getContribution(1);
      expect(firstContribution.dayCounter).to.eq(1);
      const increaseDayCounterTx = await contributionContract.incrementDayCounter();
      await increaseDayCounterTx.wait();
      const createTx = await contributionContract.create(contributionCategory, title, url, accounts[0].address);
      await createTx.wait();
      const contribution = await contributionContract.getContribution(10);
      expect(contribution.dayCounter).to.eq(2);
    });
  });

  describe("Interfaces", async () => {
    it("Should support IAmpliFrensContribution", async () => {
      expect(await contributionContract.supportsInterface("0x81e4023e")).to.be.true;
    });

    it("Should support IERC165", async () => {
      expect(await contributionContract.supportsInterface("0x01ffc9a7")).to.be.true;
    });
  });
});
