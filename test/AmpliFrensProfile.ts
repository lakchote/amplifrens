import { AmpliFrensProfile, Errors } from "../typechain-types";
import { AmpliFrensProfile__factory } from "../typechain-types/factories/contracts/AmpliFrensProfile__factory";
import { ethers } from "hardhat";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("Profiles", async () => {
  let profileContract: AmpliFrensProfile;
  let accounts: SignerWithAddress[];
  let errorsLib: Errors;

  // The following consts will be used for default profile params
  const username = "satoshi";
  const lensHandle = "d3legatecall.lens";
  const discordHandle = "d3legatecall.lens";
  const twitterHandle = "Luc#8673";
  const email = "lakchote@icloud.com";
  const websiteUrl = "https://www.twitter.com/profile/alphaMaker";

  beforeEach(async () => {
    accounts = await ethers.getSigners();

    const profileLogicLib = await (await (await ethers.getContractFactory("ProfileLogic")).deploy()).deployed();
    const pseudoModifierLib = await (await (await ethers.getContractFactory("PseudoModifier")).deploy()).deployed();
    errorsLib = (await (await (await ethers.getContractFactory("Errors")).deploy()).deployed()) as Errors;

    const profileContractFactory = (await ethers.getContractFactory("AmpliFrensProfile", {
      libraries: {
        ProfileLogic: profileLogicLib.address,
        PseudoModifier: pseudoModifierLib.address,
      },
    })) as AmpliFrensProfile__factory;

    // Should be the facade's address, test for this access control use case is in AmpliFrensFacade.ts
    profileContract = await profileContractFactory.deploy(accounts[0].address);
    await profileContract.deployed();

    const createProfileTx = await profileContract.createProfile({
      username: username,
      lensHandle: lensHandle,
      discordHandle: discordHandle,
      twitterHandle: twitterHandle,
      email: email,
      websiteUrl: websiteUrl,
      valid: true,
    });
    await createProfileTx.wait();
  });

  describe("Creation", async () => {
    it("Should update the profiles count correctly", async () => {
      expect(await profileContract.profilesCount()).to.be.eq(1);
      const createProfileTx = await profileContract.createProfile({
        username: "abc",
        lensHandle: "abc.lens",
        discordHandle: "abc#1234",
        twitterHandle: "abc",
        email: "test@test.com",
        websiteUrl: websiteUrl,
        valid: true,
      });
      await createProfileTx.wait();
      expect(await profileContract.profilesCount()).to.eq(2);
    });

    it("Should update the profiles addresses", async () => {
      expect(await profileContract.hasProfile(accounts[0].address)).to.eq(true);
    });

    it("Should throw an error if username is empty", async () => {
      await expect(
        profileContract.createProfile({
          username: "",
          lensHandle: lensHandle,
          discordHandle: discordHandle,
          twitterHandle: twitterHandle,
          email: email,
          websiteUrl: websiteUrl,
          valid: true,
        })
      ).to.be.revertedWithCustomError(errorsLib, "EmptyUsername");
    });

    it("Should throw an error if the username chosen already exists", async () => {
      await expect(
        profileContract.createProfile({
          username: username,
          lensHandle: lensHandle,
          discordHandle: discordHandle,
          twitterHandle: twitterHandle,
          email: email,
          websiteUrl: websiteUrl,
          valid: true,
        })
      ).to.be.revertedWithCustomError(errorsLib, "UsernameExist");
    });
  });

  describe("Deletion", async () => {
    it("Should remove the address from the profiles list", async () => {
      expect(await profileContract.hasProfile(accounts[0].address)).to.eq(true);
      const deleteTx = await profileContract.deleteProfile(accounts[0].address);
      await deleteTx.wait();
      expect(await profileContract.hasProfile(accounts[0].address)).to.eq(false);
    });

    it("Should update the profiles count correctly", async () => {
      expect(await profileContract.profilesCount()).to.be.eq(1);
      const deleteTx = await profileContract.deleteProfile(accounts[0].address);
      await deleteTx.wait();
      expect(await profileContract.profilesCount()).to.be.eq(0);
    });

    it("Should throw an error if the address supplied doesn't exist in the profiles list", async () => {
      await expect(profileContract.deleteProfile(accounts[2].address)).to.be.revertedWithCustomError(
        errorsLib,
        "NoProfileWithAddress"
      );
    });
  });

  describe("Events", async () => {
    it("Should trigger a ProfileBlacklisted event when a user is blacklisted", async () => {
      await expect(profileContract.blacklist(accounts[0].address, "Spam"))
        .to.emit(profileContract, "ProfileBlacklisted")
        .withArgs(accounts[0].address, "Spam", (await ethers.provider.getBlock("latest")).timestamp);
    });

    it("Should trigger a ProfileCreated event when a user profile is created", async () => {
      await expect(
        profileContract.createProfile({
          username: "ethernal",
          lensHandle: "ethernal.lens",
          discordHandle: "ethernal#1337",
          twitterHandle: "ethernal",
          email: "ethern@l.com",
          websiteUrl: websiteUrl,
          valid: true,
        })
      )
        .to.emit(profileContract, "ProfileCreated")
        .withArgs(accounts[0].address, (await ethers.provider.getBlock("latest")).timestamp, "ethernal");
    });

    it("Should trigger a ProfileUpdated event when a user profile is updated", async () => {
      await expect(
        profileContract.updateProfile({
          username: "ethernal",
          lensHandle: "ethernal.lens",
          discordHandle: "ethernal#1337",
          twitterHandle: "ethernal",
          email: "ethern@l.com",
          websiteUrl: websiteUrl,
          valid: true,
        })
      )
        .to.emit(profileContract, "ProfileUpdated")
        .withArgs(accounts[0].address, (await ethers.provider.getBlock("latest")).timestamp);
    });

    it("Should trigger a ProfileDeleted event when a user profile is deleted", async () => {
      await expect(profileContract.deleteProfile(accounts[0].address))
        .to.emit(profileContract, "ProfileDeleted")
        .withArgs(accounts[0].address, (await ethers.provider.getBlock("latest")).timestamp);
    });
  });

  describe("Update", async () => {
    it("Should update the profile's data correctly", async () => {
      const updateTx = await profileContract.updateProfile({
        username: "ethernal",
        lensHandle: "ethernal.lens",
        discordHandle: "ethernal#1337",
        twitterHandle: "ethernal",
        email: "ethern@l.com",
        websiteUrl: "https://anon.mirror.xyz",
        valid: true,
      });
      await updateTx.wait();
      const profile = await profileContract.getProfile(accounts[0].address);
      expect(await profile.username).to.eq("ethernal");
      expect(await profile.lensHandle).to.eq("ethernal.lens");
      expect(await profile.discordHandle).to.eq("ethernal#1337");
      expect(await profile.twitterHandle).to.eq("ethernal");
      expect(await profile.email).to.eq("ethern@l.com");
      expect(await profile.websiteUrl).to.eq("https://anon.mirror.xyz");
    });

    it("Should not update the profile's username if it's empty", async () => {
      const updateTx = await profileContract.updateProfile({
        username: "",
        lensHandle: "ethernal.lens",
        discordHandle: "ethernal#1337",
        twitterHandle: "ethernal",
        email: "ethern@l.com",
        websiteUrl: "https://anon.mirror.xyz",
        valid: true,
      });
      await updateTx.wait();
      const profile = await profileContract.getProfile(accounts[0].address);
      expect(await profile.username).to.not.eq("");
    });

    it("Should throw an error if the profile doesn't exist", async () => {
      await expect(
        profileContract.connect(accounts[1]).updateProfile({
          username: "ethernal",
          lensHandle: "ethernal.lens",
          discordHandle: "ethernal#1337",
          twitterHandle: "ethernal",
          email: "ethern@l.com",
          websiteUrl: "https://anon.mirror.xyz",
          valid: true,
        })
      ).to.be.revertedWithCustomError(errorsLib, "NoProfileWithAddress");
    });

    it("Should throw an error if the user is not an admin", async () => {
      await expect(profileContract.deleteProfile(accounts[2].address)).to.be.reverted;
    });
  });

  describe("Blacklist", async () => {
    it("Should remove the user from the profiles list", async () => {
      expect(await profileContract.hasProfile(accounts[0].address)).to.eq(true);
      const blacklistTx = await profileContract.blacklist(accounts[0].address, "Spam");
      await blacklistTx.wait();
      expect(await profileContract.hasProfile(accounts[0].address)).to.eq(false);
    });

    it("Should give the reason of the blacklisting or throw an error if the address is not blacklisted", async () => {
      const blacklistTx = await profileContract.blacklist(accounts[0].address, "Spam");
      await blacklistTx.wait();
      const blacklistReason = await profileContract.getBlacklistReason(accounts[0].address);
      expect(blacklistReason).to.eq("Spam");
      await expect(profileContract.getBlacklistReason(accounts[2].address)).to.be.revertedWithCustomError(
        errorsLib,
        "NotBlacklisted"
      );
    });

    it("Should update the profiles count correctly", async () => {
      expect(await profileContract.profilesCount()).to.be.eq(1);
      const deleteTx = await profileContract.deleteProfile(accounts[0].address);
      await deleteTx.wait();
      expect(await profileContract.profilesCount()).to.be.eq(0);
    });

    it("Should throw an error if the user is not an admin", async () => {
      await expect(
        profileContract.connect(accounts[2]).blacklist(accounts[0].address, "Spam")
      ).to.be.revertedWithCustomError(errorsLib, "Unauthorized");
    });

    it("Should throw an error if the address is not in profiles list", async () => {
      await expect(profileContract.blacklist(accounts[2].address, "Spam")).to.be.revertedWithCustomError(
        errorsLib,
        "NoProfileWithAddress"
      );
    });
  });

  describe("Read", async () => {
    it("Should retrieve correctly an existing user by its address", async () => {
      const profile = await profileContract.getProfile(accounts[0].address);
      expect(profile.username).to.eq(username);
    });

    it("Should throw an error if the address is not in profiles list", async () => {
      await expect(profileContract.getProfile(accounts[3].address)).to.be.revertedWithCustomError(
        errorsLib,
        "NoProfileWithAddress"
      );
    });

    it("Should retrieve correctly an user by its username", async () => {
      const profile = await profileContract.getProfileByUsername(username);
      expect(await profile.username).to.eq(username);
    });

    it("Should throw an error if the profile by username doesn't exist", async () => {
      await expect(profileContract.getProfileByUsername("afren")).to.be.revertedWithCustomError(
        errorsLib,
        "NoProfileWithSocialHandle"
      );
    });

    describe("Interfaces", async () => {
      it("Should support IAmpliFrensProfile", async () => {
        expect(await profileContract.supportsInterface("0xbc10100c")).to.be.true;
      });

      it("Should support IERC165", async () => {
        expect(await profileContract.supportsInterface("0x01ffc9a7")).to.be.true;
      });
    });
  });
});
