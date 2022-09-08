import { AmpliFrensProfile } from "../typechain-types";
import { AmpliFrensProfile__factory } from "../typechain-types/factories/contracts/AmpliFrensProfile__factory";
import { ethers } from "hardhat";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("Profiles", async () => {
  let profileContract: AmpliFrensProfile;
  let accounts: SignerWithAddress[];

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    const profileContractFactory = (await ethers.getContractFactory("AmpliFrensProfile")) as AmpliFrensProfile__factory;
    profileContract = await profileContractFactory.deploy();
    await profileContract.deployed();
  });

  describe("Creation", async () => {
    it("Should create a profile and add it to the profiles list", async () => {
      throw new Error("Not implemented.");
    });
    it("Should throw an error if the user's address has been blacklisted", async () => {
      throw new Error("Not implemented.");
    });
    it("Should throw an error if the user already has a profile", async () => {
      throw new Error("Not implemented.");
    });
  });

  describe("Deletion", async () => {
    it("Should throw an error if the user doesn't have the role to delete profiles", async () => {
      throw new Error("Not implemented.");
    });
    it("Should throw an error if the address supplied doesn't exist in the profiles list", async () => {
      throw new Error("Not implemented.");
    });
    it("Should remove the address from the profiles list", async () => {
      throw new Error("Not implemented.");
    });
    it("Should update the profiles count correctly", async () => {
      throw new Error("Not implemented.");
    });
    it("Should throw an error if the user's address has been blacklisted", async () => {
      throw new Error("Not implemented.");
    });
  });

  describe("Update", async () => {
    it("Should throw an error if somebody tries to modify someone's else profile", async () => {
      throw new Error("Not implemented.");
    });
    it("Should throw an error if the user's address has been blacklisted", async () => {
      throw new Error("Not implemented.");
    });
    it("Should remove the address from the profiles list", async () => {
      throw new Error("Not implemented.");
    });
    it("Should update the profile's data correctly", async () => {
      throw new Error("Not implemented.");
    });
  });

  describe("Read", async () => {
    it("Should return the correct information of a profile", async () => {
      throw new Error("Not implemented.");
    });
    it("Should throw an error if the user's address has been blacklisted", async () => {
      throw new Error("Not implemented.");
    });
    it("Should throw an error if the profile doesn't exist", async () => {
      throw new Error("Not implemented.");
    });
  });
});
