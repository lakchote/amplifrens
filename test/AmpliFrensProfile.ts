import { AmpliFrensProfile } from "../typechain-types";
import { AmpliFrensProfile__factory } from "../typechain-types/factories/contracts/AmpliFrensProfile__factory";
import { ethers } from "hardhat";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("Profiles", async () => {
  let profileContract: AmpliFrensProfile;
  let accounts: SignerWithAddress[];

  // The following consts will be used for default profile params
  const username = ethers.utils.formatBytes32String("satoshi");
  const lensHandle = ethers.utils.formatBytes32String("d3legatecall.lens");
  const discordHandle = ethers.utils.formatBytes32String("d3legatecall.lens");
  const twitterHandle = ethers.utils.formatBytes32String("Luc#8673");
  const email = ethers.utils.formatBytes32String("lakchote@icloud.com");
  const websiteUrl = "https://www.twitter.com/profile/alphaMaker";

  beforeEach(async () => {
    accounts = await ethers.getSigners();

    const profileContractFactory = (await ethers.getContractFactory("AmpliFrensProfile")) as AmpliFrensProfile__factory;
    profileContract = await profileContractFactory.deploy();
    await profileContract.deployed();

    const createProfileTx = await profileContract.createProfile(
      accounts[0].address,
      username,
      lensHandle,
      discordHandle,
      twitterHandle,
      email,
      websiteUrl
    );
    await createProfileTx.wait();
  });

  describe("Creation", async () => {
    it("Should update the profiles count correctly", async () => {
      expect(await profileContract.profilesCount()).to.be.eq(1);
      const createProfileTx = await profileContract.createProfile(
        accounts[1].address,
        ethers.utils.formatBytes32String("afren.lens"),
        ethers.utils.formatBytes32String("Luc#1337"),
        ethers.utils.formatBytes32String("d3legateCall"),
        ethers.utils.formatBytes32String("abcde"),
        ethers.utils.formatBytes32String("foo@bar.xyz"),
        websiteUrl
      );
      await createProfileTx.wait();
      expect(await profileContract.profilesCount()).to.eq(2);
    });
    it("Should update the profiles addresses", async () => {
      expect(await profileContract.hasProfile(accounts[0].address)).to.eq(true);
    });
    it("Should throw an error if the username chosen already exists", async () => {
      await expect(
        profileContract.createProfile(
          accounts[1].address,
          username,
          lensHandle,
          discordHandle,
          twitterHandle,
          email,
          websiteUrl
        )
      ).to.be.revertedWith("Username exist");
    });
    it("Should throw an error if the email chosen already exists", async () => {
      await expect(
        profileContract.createProfile(
          accounts[1].address,
          ethers.utils.formatBytes32String("abcde"),
          lensHandle,
          discordHandle,
          twitterHandle,
          email,
          websiteUrl
        )
      ).to.be.revertedWith("Email exist");
    });
    it("Should throw an error if the Discord handle already exists", async () => {
      await expect(
        profileContract.createProfile(
          accounts[1].address,
          ethers.utils.formatBytes32String(""),
          lensHandle,
          discordHandle,
          twitterHandle,
          ethers.utils.formatBytes32String(""),
          websiteUrl
        )
      ).to.be.revertedWith("Discord ID exist");
    });
    it("Should throw an error if the Twitter handle already exists", async () => {
      await expect(
        profileContract.createProfile(
          accounts[1].address,
          ethers.utils.formatBytes32String(""),
          lensHandle,
          ethers.utils.formatBytes32String(""),
          twitterHandle,
          ethers.utils.formatBytes32String(""),
          websiteUrl
        )
      ).to.be.revertedWith("Twitter ID exist");
    });
    it("Should throw an error if the Lens handle already exists", async () => {
      await expect(
        profileContract.createProfile(
          accounts[1].address,
          ethers.utils.formatBytes32String(""),
          lensHandle,
          ethers.utils.formatBytes32String("abcdeghi#1337"),
          ethers.utils.formatBytes32String("cz_binance"),
          ethers.utils.formatBytes32String(""),
          websiteUrl
        )
      ).to.be.revertedWith("Lens ID exist");
    });

    it("Should throw an error if the user is not an admin", async () => {
      await expect(
        profileContract
          .connect(accounts[1])
          .createProfile(
            accounts[1].address,
            ethers.utils.formatBytes32String("abcde"),
            lensHandle,
            discordHandle,
            twitterHandle,
            email,
            websiteUrl
          )
      ).to.be.reverted;
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
      await expect(profileContract.deleteProfile(accounts[2].address)).to.be.revertedWith("No profile");
    });
    it("Should throw an error if the user is not an admin", async () => {
      await expect(
        profileContract
          .connect(accounts[1])
          .createProfile(
            accounts[1].address,
            ethers.utils.formatBytes32String("abcde"),
            lensHandle,
            discordHandle,
            twitterHandle,
            email,
            websiteUrl
          )
      ).to.be.reverted;
    });
  });

  describe("Events", async () => {
    it("Should trigger a Blacklisted event when a user is blacklisted", async () => {
      await expect(profileContract.blacklist(accounts[0].address, ethers.utils.formatBytes32String("Spam")))
        .to.emit(profileContract, "Blacklisted")
        .withArgs(
          accounts[0].address,
          ethers.utils.formatBytes32String("Spam"),
          (
            await ethers.provider.getBlock("latest")
          ).timestamp
        );
    });
    it("Should trigger a ProfileCreated event when a user profile is created", async () => {
      await expect(
        profileContract.createProfile(
          accounts[1].address,
          ethers.utils.formatBytes32String("afren.lens"),
          ethers.utils.formatBytes32String("Luc#1337"),
          ethers.utils.formatBytes32String("d3legateCall"),
          ethers.utils.formatBytes32String("abcde"),
          ethers.utils.formatBytes32String("foo@bar.xyz"),
          websiteUrl
        )
      )
        .to.emit(profileContract, "ProfileCreated")
        .withArgs(accounts[1].address, (await ethers.provider.getBlock("latest")).timestamp);
    });
    it("Should trigger a ProfileUpdated event when a user profile is updated", async () => {
      await expect(
        profileContract.updateProfile(
          accounts[0].address,
          ethers.utils.formatBytes32String("afren.lens"),
          ethers.utils.formatBytes32String("Luc#1337"),
          ethers.utils.formatBytes32String("d3legateCall"),
          ethers.utils.formatBytes32String("abcde"),
          ethers.utils.formatBytes32String("foo@bar.xyz"),
          websiteUrl
        )
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
      const updateTx = await profileContract.updateProfile(
        accounts[0].address,
        ethers.utils.formatBytes32String("myNewUsername"),
        ethers.utils.formatBytes32String("myNewUsername.lens"),
        ethers.utils.formatBytes32String("myNewUsername#1234"),
        ethers.utils.formatBytes32String("myNewUsernameOnCT"),
        ethers.utils.formatBytes32String("myNewUsername@gmail.com"),
        "https://anon.mirror.xyz"
      );
      await updateTx.wait();
      const profile = await profileContract.getProfileByDiscordHandle(
        ethers.utils.formatBytes32String("myNewUsername#1234")
      );
      expect(await profile.username).to.eq(ethers.utils.formatBytes32String("myNewUsername"));
      expect(await profile.lensHandle).to.eq(ethers.utils.formatBytes32String("myNewUsername.lens"));
      expect(await profile.discordHandle).to.eq(ethers.utils.formatBytes32String("myNewUsername#1234"));
      expect(await profile.twitterHandle).to.eq(ethers.utils.formatBytes32String("myNewUsernameOnCT"));
      expect(await profile.email).to.eq(ethers.utils.formatBytes32String("myNewUsername@gmail.com"));
      expect(await profile.websiteUrl).to.eq("https://anon.mirror.xyz");
    });
    it("Should throw an error if the profile doesn't exist", async () => {
      await expect(
        profileContract.updateProfile(
          accounts[2].address,
          ethers.utils.formatBytes32String("myNewUsername"),
          ethers.utils.formatBytes32String("myNewUsername.lens"),
          ethers.utils.formatBytes32String("myNewUsername#1234"),
          ethers.utils.formatBytes32String("myNewUsernameOnCT"),
          ethers.utils.formatBytes32String("myNewUsername@gmail.com"),
          "https://anon.mirror.xyz"
        )
      ).to.be.revertedWith("No profile");
    });

    it("Should throw an error if the user is not an admin", async () => {
      await expect(profileContract.connect(accounts[1]).deleteProfile(accounts[2].address)).to.be.reverted;
    });
  });

  describe("Blacklist", async () => {
    it("Should remove the user from the profiles list", async () => {
      expect(await profileContract.hasProfile(accounts[0].address)).to.eq(true);
      const blacklistTx = await profileContract.blacklist(
        accounts[0].address,
        ethers.utils.formatBytes32String("Spam")
      );
      await blacklistTx.wait();
      expect(await profileContract.hasProfile(accounts[0].address)).to.eq(false);
    });
    it("Should give the reason of the blacklisting or throw an error if the address is not blacklisted", async () => {
      const blacklistTx = await profileContract.blacklist(
        accounts[0].address,
        ethers.utils.formatBytes32String("Spam")
      );
      await blacklistTx.wait();
      const blacklistReason = await profileContract.getBlacklistReason(accounts[0].address);
      expect(blacklistReason).to.eq(ethers.utils.formatBytes32String("Spam"));
      await expect(profileContract.getBlacklistReason(accounts[2].address)).to.be.revertedWith("Not blacklisted");
    });
    it("Should update the profiles count correctly", async () => {
      expect(await profileContract.profilesCount()).to.be.eq(1);
      const deleteTx = await profileContract.deleteProfile(accounts[0].address);
      await deleteTx.wait();
      expect(await profileContract.profilesCount()).to.be.eq(0);
    });
    it("Should throw an error if the user is not an admin", async () => {
      await expect(
        profileContract.connect(accounts[1]).blacklist(accounts[0].address, ethers.utils.formatBytes32String("Spam"))
      ).to.be.reverted;
    });
    it("Should throw an error if the address is not in profiles list", async () => {
      await expect(
        profileContract.blacklist(accounts[2].address, ethers.utils.formatBytes32String("Spam"))
      ).to.be.revertedWith("No profile");
    });
    it("Should throw an error if the user is not an admin", async () => {
      await expect(
        profileContract.connect(accounts[1]).blacklist(accounts[2].address, ethers.utils.formatBytes32String("Spam"))
      ).to.be.reverted;
    });
  });

  describe("Read", async () => {
    it("Should return the correct information of a profile", async () => {
      const profile = await profileContract.getProfileByDiscordHandle(discordHandle);
      expect(await profile.username).to.eq(username);
      expect(await profile.lensHandle).to.eq(lensHandle);
      expect(await profile.discordHandle).to.eq(discordHandle);
      expect(await profile.twitterHandle).to.eq(twitterHandle);
      expect(await profile.email).to.eq(email);
      expect(await profile.websiteUrl).to.eq(websiteUrl);
    });
    it("Should retrieve correctly an user by its username", async () => {
      const profile = await profileContract.getProfileByUsername(username);
      expect(await profile.username).to.eq(username);
    });
    it("Should retrieve correctly an user by its Lens handle", async () => {
      const profile = await profileContract.getProfileByLensHandle(lensHandle);
      expect(await profile.lensHandle).to.eq(lensHandle);
    });
    it("Should retrieve correctly an user by its Discord handle", async () => {
      const profile = await profileContract.getProfileByDiscordHandle(discordHandle);
      expect(await profile.discordHandle).to.eq(discordHandle);
    });
    it("Should retrieve correctly an user by its Twitter handle", async () => {
      const profile = await profileContract.getProfileByTwitterHandle(twitterHandle);
      expect(await profile.twitterHandle).to.eq(twitterHandle);
    });
    it("Should retrieve correctly an user by its email", async () => {
      const profile = await profileContract.getProfileByEmail(email);
      expect(await profile.email).to.eq(email);
    });
    it("Should throw an error if the profile by username doesn't exist", async () => {
      await expect(profileContract.getProfileByUsername(ethers.utils.formatBytes32String("afren"))).to.be.revertedWith(
        "No user"
      );
    });
    it("Should throw an error if the profile by email doesn't exist", async () => {
      await expect(
        profileContract.getProfileByEmail(ethers.utils.formatBytes32String("afren@gmail.com"))
      ).to.be.revertedWith("No user");
    });
    it("Should throw an error if the profile by Discord handle doesn't exist", async () => {
      await expect(
        profileContract.getProfileByDiscordHandle(ethers.utils.formatBytes32String("afren#1234"))
      ).to.be.revertedWith("No user");
    });
    it("Should throw an error if the profile by Twitter handle doesn't exist", async () => {
      await expect(
        profileContract.getProfileByTwitterHandle(ethers.utils.formatBytes32String("afrenOnCT"))
      ).to.be.revertedWith("No user");
    });
    it("Should throw an error if the profile by Lens handle doesn't exist", async () => {
      await expect(
        profileContract.getProfileByUsername(ethers.utils.formatBytes32String("afren.lens"))
      ).to.be.revertedWith("No user");
    });
    it("Should throw an error if the user is not an admin", async () => {
      await expect(
        profileContract.connect(accounts[1]).getProfileByUsername(ethers.utils.formatBytes32String("afren.lens"))
      ).to.be.reverted;
    });
  });
});
