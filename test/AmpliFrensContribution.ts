import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { expect } from "chai";
import { AmpliFrensContribution, AmpliFrensContribution__factory, Errors } from "../typechain-types";

describe("Contribution", async () => {
  let contributionContract: AmpliFrensContribution;
  let accounts: SignerWithAddress[];
  let errorsLib: Errors;

  // The following consts will be used for default contribution params
  const title = ethers.utils.formatBytes32String("Gud alpha , get latest WLs here");
  const contributionCategory = 7; // Misc category
  const url = "https://www.twitter.com/profile/alphaMaker";

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    const pseudoModifierLib = await (await (await ethers.getContractFactory("PseudoModifier")).deploy()).deployed();
    const contributionLogicLib = await (
      await (await ethers.getContractFactory("ContributionLogic")).deploy()
    ).deployed();
    errorsLib = (await (await (await ethers.getContractFactory("Errors")).deploy()).deployed()) as Errors;

    const contributionContractFactory = (await ethers.getContractFactory("AmpliFrensContribution", {
      libraries: {
        PseudoModifier: pseudoModifierLib.address,
        ContributionLogic: contributionLogicLib.address,
      },
    })) as AmpliFrensContribution__factory;

    contributionContract = await contributionContractFactory.deploy(accounts[0].address);
  });

  describe("Creation", async () => {
    it("Should create a contribution successfully", async () => {
      await expect(contributionContract.create(contributionCategory, title, url)).to.not.be.reverted;
    });

    it("Should update the contributions count", async () => {
      expect(await contributionContract.contributionsCount()).to.eq(0);
      const createTx = await contributionContract.create(contributionCategory, title, url);

      await createTx.wait();
      expect(await contributionContract.contributionsCount()).to.eq(1);
    });
  });

  describe("Update", async () => {
    const newTitle = ethers.utils.formatBytes32String("Contribution updated");
    const newUrl = "https://www.test.com";
    const newCategory = 2;

    beforeEach(async () => {
      const createTx = await contributionContract.create(contributionCategory, title, url);
      await createTx.wait();
    });

    it("Should update a contribution by its id", async () => {
      let contribution = await contributionContract.getContribution(1);
      expect(await contribution.title).to.eq(title);
      const updateTx = await contributionContract.update(1, newCategory, newTitle, newUrl);
      await updateTx.wait();
      contribution = await contributionContract.getContribution(1);
      expect(await contribution.category).to.eq(newCategory);
      expect(await contribution.title).to.eq(newTitle);
      expect(await contribution.url).to.eq(newUrl);
    });

    it("Should not update a contribution's title if it's empty", async () => {
      let contribution = await contributionContract.getContribution(1);
      expect(await contribution.title).to.eq(title);
      const updateTx = await contributionContract.update(1, newCategory, ethers.utils.formatBytes32String(""), newUrl);
      await updateTx.wait();
      contribution = await contributionContract.getContribution(1);
      expect(await contribution.title).to.not.eq(ethers.utils.formatBytes32String(""));
    });

    it("Should not update a contribution's url if it's empty", async () => {
      let contribution = await contributionContract.getContribution(1);
      expect(await contribution.url).to.eq(url);
      const updateTx = await contributionContract.update(1, newCategory, newTitle, "");
      await updateTx.wait();
      contribution = await contributionContract.getContribution(1);
      expect(await contribution.url).to.not.eq("");
    });

    it("Should throw an error if an user tries to update a contribution whom he is not the author", async () => {
      await expect(
        contributionContract.connect(accounts[1]).update(1, newCategory, newTitle, newUrl)
      ).to.be.revertedWithCustomError(errorsLib, "Unauthorized");
    });

    it("Should be able to update a contribution if the user has admin role", async () => {
      const createTx = await contributionContract.connect(accounts[2]).create(contributionCategory, title, url);
      await createTx.wait();
      const updateTx = await contributionContract.update(2, newCategory, newTitle, newUrl);
      await updateTx.wait();
      const contribution = await contributionContract.getContribution(2);
      expect(await contribution.category).to.eq(newCategory);
    });

    it("Should throw an error if the index if out of bounds", async () => {
      await expect(contributionContract.remove(1337)).to.be.revertedWithCustomError(errorsLib, "OutOfBounds");
    });
  });

  describe("Delete", async () => {
    beforeEach(async () => {
      const createTx = await contributionContract.connect(accounts[1]).create(contributionCategory, title, url);
      await createTx.wait();
    });

    it("Should remove a contribution from the list", async () => {
      let contribution = await contributionContract.getContribution(1);
      expect(await contribution.title).to.eq(title);
      const removeTx = await contributionContract.connect(accounts[1]).remove(1);
      await removeTx.wait();
      await expect(contributionContract.getContribution(1)).to.be.revertedWithCustomError(errorsLib, "OutOfBounds");
    });

    it("Should update the contributions count", async () => {
      expect(await contributionContract.contributionsCount()).to.eq(1);
      const removeTx = await contributionContract.connect(accounts[1]).remove(1);
      await removeTx.wait();
      expect(await contributionContract.contributionsCount()).to.eq(0);
    });

    it("Should be able to delete a contribution if the user has admin role", async () => {
      await expect(contributionContract.remove(1)).to.not.be.revertedWithCustomError(errorsLib, "Unauthorized");
    });

    it("Should throw an error if an user tries to delete a contribution whom he is not the author", async () => {
      await expect(contributionContract.connect(accounts[2]).remove(1)).to.be.revertedWithCustomError(
        errorsLib,
        "Unauthorized"
      );
    });

    it("Should throw an error if the index if out of bounds", async () => {
      await expect(contributionContract.remove(1337)).to.be.revertedWithCustomError(errorsLib, "OutOfBounds");
    });
  });

  describe("Reset", async () => {
    it("Should remove all contributions", async () => {
      // Create contributions
      for (let i = 0; i < 2; i++) {
        const createTx = await contributionContract.create(contributionCategory, title, url);
        await createTx.wait();
      }

      // Simulate voting
      for (let i = 1; i <= 10; i++) {
        const voteTx = await contributionContract.connect(accounts[i]).upvote(Math.floor(Math.random() * 2 + 1));
        await voteTx.wait();
      }
      for (let i = 10; i <= 12; i++) {
        const voteTx = await contributionContract.connect(accounts[i]).downvote(Math.floor(Math.random() * 2 + 1));
        await voteTx.wait();
      }

      let contribution = await contributionContract.getContribution(1);
      expect(await contribution.title).to.eq(title);
      expect(await contributionContract.contributionsCount()).to.eq(2);
      const resetTx = await contributionContract.reset();
      await resetTx.wait();

      expect(await contributionContract.contributionsCount()).to.eq(0);
      await expect(contributionContract.getContribution(1)).to.be.revertedWithCustomError(errorsLib, "OutOfBounds");
    });

    it("Should be able to reset if the user has admin role only", async () => {
      await expect(contributionContract.reset()).to.not.be.revertedWithCustomError(errorsLib, "Unauthorized");
      await expect(contributionContract.connect(accounts[1]).reset()).to.be.revertedWithCustomError(
        errorsLib,
        "Unauthorized"
      );
    });
  });

  describe("Voting", async () => {
    beforeEach(async () => {
      const createTx = await contributionContract.create(contributionCategory, title, url);
      await createTx.wait();
      for (let i = 1; i <= 10; i++) {
        const voteTx = await contributionContract.connect(accounts[i]).upvote(1);
        await voteTx.wait();
      }
    });

    it("Should increase a contribution's votes on upvote", async () => {
      let contribution = await contributionContract.getContribution(1);
      expect(await contribution.votes).to.eq(10);
      const voteTx = await contributionContract.connect(accounts[11]).upvote(1);
      await voteTx.wait();
      contribution = await contributionContract.getContribution(1);
      expect(await contribution.votes).to.eq(11);
    });

    it("Should decrease a contribution's votes on downvote", async () => {
      let contribution = await contributionContract.getContribution(1);
      expect(await contribution.votes).to.eq(10);
      const voteTx = await contributionContract.connect(accounts[11]).downvote(1);
      await voteTx.wait();
      contribution = await contributionContract.getContribution(1);
      expect(await contribution.votes).to.eq(9);
    });

    it("Should be possible to upvote only once for a contribution", async () => {
      await expect(contributionContract.connect(accounts[1]).upvote(1)).to.be.revertedWithCustomError(
        errorsLib,
        "AlreadyVoted"
      );
    });

    it("Should be possible to downvote only once for a contribution", async () => {
      const voteTx = await contributionContract.connect(accounts[1]).downvote(1);
      await voteTx.wait();
      await expect(contributionContract.connect(accounts[1]).downvote(1)).to.be.revertedWithCustomError(
        errorsLib,
        "AlreadyVoted"
      );
    });

    it("Should not be possible to vote for our own contribution", async () => {
      await expect(contributionContract.upvote(1)).to.be.revertedWithCustomError(errorsLib, "Unauthorized");
    });

    it("Should not be possible to downvote our own contribution", async () => {
      await expect(contributionContract.upvote(1)).to.be.revertedWithCustomError(errorsLib, "Unauthorized");
    });

    it("Should throw an error if the index if out of bounds", async () => {
      await expect(contributionContract.upvote(1337)).to.be.revertedWithCustomError(errorsLib, "OutOfBounds");
      await expect(contributionContract.downvote(1337)).to.be.revertedWithCustomError(errorsLib, "OutOfBounds");
    });
  });

  describe("Enumeration", async () => {
    const titles = [
      ethers.utils.formatBytes32String("A"),
      ethers.utils.formatBytes32String("B"),
      ethers.utils.formatBytes32String("C"),
      ethers.utils.formatBytes32String("D"),
      ethers.utils.formatBytes32String("E"),
      ethers.utils.formatBytes32String("F"),
      ethers.utils.formatBytes32String("G"),
      ethers.utils.formatBytes32String("H"),
      ethers.utils.formatBytes32String("I"),
      ethers.utils.formatBytes32String("J"),
      ethers.utils.formatBytes32String("K"),
    ];

    beforeEach(async () => {
      for (let i = 1; i < 10; i++) {
        const createTx = await contributionContract.create(contributionCategory, titles[i], url);
        await createTx.wait();
      }
    });

    it("Should retrieve all contributions", async () => {
      const contributions = await contributionContract.getContributions();
      for (let i = 1; i <= contributions.length; i++) {
        const contribution = await contributionContract.getContribution(i);
        expect(await contribution.title).to.eq(titles[i]);
      }
      expect(contributions.length).to.eq(9);
    });

    it("Should retrieve a contribution by its id", async () => {
      const createTx = await contributionContract.create(
        0,
        ethers.utils.formatBytes32String("Alpha alert"),
        "https://www.twitter.com/ElonSecretProject"
      );
      await createTx.wait();
      const contribution = await contributionContract.getContribution(10);
      expect(await contribution.category).to.eq(0);
      expect(await contribution.title).to.eq(ethers.utils.formatBytes32String("Alpha alert"));
      expect(await contribution.url).to.eq("https://www.twitter.com/ElonSecretProject");
    });

    it("Should give the most upvoted contribution", async () => {
      for (let i = 1; i <= 5; i++) {
        const voteTx = await contributionContract.connect(accounts[i]).upvote(2);
        await voteTx.wait();
      }
      for (let i = 5; i <= 9; i++) {
        const voteTx = await contributionContract.connect(accounts[i]).upvote(i);
        await voteTx.wait();
      }
      const topContribution = await contributionContract.topContribution();
      expect(topContribution.title).to.eq(titles[2]);
    });

    it("Should throw an error if the index if out of bounds", async () => {
      await expect(contributionContract.getContribution(1337)).to.be.revertedWithCustomError(errorsLib, "OutOfBounds");
    });
  });

  describe("Interfaces", async () => {
    it("Should support IAmpliFrensContribution", async () => {
      expect(await contributionContract.supportsInterface("0x6597662d")).to.be.true;
    });

    it("Should support IERC165", async () => {
      expect(await contributionContract.supportsInterface("0x01ffc9a7")).to.be.true;
    });
  });
});
