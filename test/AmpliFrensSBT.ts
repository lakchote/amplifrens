import { AmpliFrensSBT } from "../typechain-types/contracts/AmpliFrensSBT";
import { AmpliFrensSBTTestNewImpl } from "../typechain-types/contracts/AmpliFrensSBTTestNewImpl";
import { ethers, network, upgrades } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumber } from "ethers";
import {
  AmpliFrensSBTTest,
  AmpliFrensSBTTest__factory,
} from "../typechain-types";

let sbtContract: AmpliFrensSBT;
let accounts: SignerWithAddress[];

// The following consts will be used for default minting params
const title = ethers.utils.formatBytes32String(
  "Gud alpha , get latest WLs here"
);
const contributionCategory = 7; // Misc category
const timestamp = Math.floor(Date.now() / 1000); // convert timestamp to seconds
const votes = 140;
const url = "https://www.twitter.com/profile/alphaMaker";

async function increaseTime() {
  await network.provider.request({
    method: "evm_increaseTime",
    params: [1000 * 60 * 60 * 24],
  });
}
describe("Soulbound Token", async () => {
  beforeEach(async () => {
    const sbtContractFactory = await ethers.getContractFactory("AmpliFrensSBT");
    sbtContract = (await upgrades.deployProxy(
      sbtContractFactory
    )) as AmpliFrensSBT;
    await sbtContract.deployed();
    accounts = await ethers.getSigners();
    increaseTime();
    const setBaseURITx = await sbtContract.setBaseURI(
      "https://www.example.com/"
    );
    await setBaseURITx.wait();
    const mintTx = await sbtContract.mint(
      accounts[1].address,
      contributionCategory,
      timestamp,
      votes,
      title,
      url
    );
    await mintTx.wait();
  });

  describe("Initialization", async () => {
    it("Should be initialized only once", async () => {
      await expect(sbtContract.initialize()).to.be.revertedWith(
        "Initializable: contract is already initialized"
      );
    });
    it("Should set the last block timestamp", async () => {
      await expect(sbtContract.lastBlockTimestamp()).to.not.eq(0);
    });
  });

  describe("Pausing", async () => {
    it("Should revert if it is called by an unallowed address", async () => {
      await expect(sbtContract.connect(accounts[1]).pause()).to.be.reverted;
    });

    it("Should pause minting functionality", async () => {
      increaseTime();
      const pauseTx = await sbtContract.pause();
      await pauseTx.wait();

      await expect(
        sbtContract.mint(
          accounts[1].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        )
      ).to.be.revertedWith("Pausable: paused");
    });
    it("Should pause revoke functionality", async () => {
      increaseTime();
      const pauseTx = await sbtContract.pause();
      await pauseTx.wait();

      await expect(sbtContract.revoke(1)).to.be.revertedWith(
        "Pausable: paused"
      );
    });
    it("Should be able to unpause and resume minting functionality", async () => {
      increaseTime();
      const pauseTx = await sbtContract.pause();
      await pauseTx.wait();

      await expect(
        sbtContract.mint(
          accounts[1].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        )
      ).to.be.revertedWith("Pausable: paused");

      const unpauseTx = await sbtContract.unpause();
      await unpauseTx.wait();

      await expect(
        sbtContract.mint(
          accounts[1].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        )
      ).to.not.be.reverted;
    });
    it("Should be able to unpause and resume revoke functionality", async () => {
      increaseTime();
      const pauseTx = await sbtContract.pause();
      await pauseTx.wait();

      await expect(sbtContract.revoke(1)).to.be.revertedWith(
        "Pausable: paused"
      );

      const unpauseTx = await sbtContract.unpause();
      await unpauseTx.wait();

      await expect(sbtContract.revoke(1)).to.not.be.reverted;
    });
  });

  describe("Minting", async () => {
    it("Should be called once per day only", async () => {
      await expect(
        sbtContract.mint(
          accounts[1].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        )
      ).to.be.revertedWith("Interval target for minting is not met yet.");
    });
    it("Should be called by admin role only", async () => {
      await expect(
        sbtContract
          .connect(accounts[1])
          .mint(
            accounts[1].address,
            contributionCategory,
            timestamp,
            votes,
            title,
            url
          )
      ).to.be.reverted;
    });

    describe("Enumeration", async () => {
      it("Should increase the tokens emitted count", async () => {
        increaseTime();
        const secondMintTx = await sbtContract.mint(
          accounts[1].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        );
        await secondMintTx.wait();
        expect(await sbtContract.emittedCount()).to.eq(2);
      });

      it("Should track the tokens holders count properly", async () => {
        increaseTime();
        const mintTx = await sbtContract.mint(
          accounts[1].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        );
        await mintTx.wait();
        increaseTime();
        const secondMintTx = await sbtContract.mint(
          accounts[2].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        );
        await secondMintTx.wait();
        expect(await sbtContract.holdersCount()).to.eq(2);
      });

      it("Should be able to retrieve a tokenId using its position in an owner's list", async () => {
        // Total number of tokens should be 7 counting the one in beforeEach() for accounts[1].address
        for (let i = 0; i <= 5; i++) {
          increaseTime();
          const mintTx = await sbtContract.mint(
            ethers.Wallet.createRandom().address,
            contributionCategory,
            timestamp,
            votes,
            title,
            url
          );
          await mintTx.wait();
        }
        increaseTime();
        const mintTx = await sbtContract.mint(
          accounts[1].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        );
        await mintTx.wait();
        expect(
          await sbtContract.tokenOfOwnerByIndex(accounts[1].address, 1)
        ).to.be.eq(8);
      });
      it("Should revert if the index is out of bounds", async () => {
        await expect(sbtContract.tokenByIndex(1337)).to.be.revertedWith(
          "Index is out of bounds."
        );
        await expect(sbtContract.tokenByIndex(0)).to.be.revertedWith(
          "Index is out of bounds."
        );
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
      const mintTx = await sbtContract.mint(
        accounts[1].address,
        contributionCategory,
        timestamp,
        votes,
        title,
        url
      );
      await mintTx.wait();
      expect(await sbtContract.balanceOf(accounts[1].address)).to.eq(2);
    });
    it("Should identify properly the owner of a tokenId", async () => {
      increaseTime();
      const mintTx = await sbtContract.mint(
        accounts[2].address,
        contributionCategory,
        timestamp,
        votes,
        title,
        url
      );
      await mintTx.wait();
      expect(await sbtContract.ownerOf(2)).to.be.eq(accounts[2].address);
    });
  });

  describe("Statuses", async () => {
    it("Should throw an error if an user hasn't any tokens", async () => {
      await expect(
        sbtContract.getStatus(accounts[2].address)
      ).to.be.revertedWith("The address has 0 tokens.");
    });
    it("Should get the correct status if the address has earnt 5 tokens", async () => {
      for (let i = 0; i <= 4; i++) {
        increaseTime();
        const mintTx = await sbtContract.mint(
          accounts[1].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        );
        await mintTx.wait();
      }
      expect(await sbtContract.getStatus(accounts[1].address)).to.eq("Anon");
    });
    it("Should get the correct status if the address has earnt 10 tokens", async () => {
      for (let i = 0; i <= 9; i++) {
        increaseTime();
        const mintTx = await sbtContract.mint(
          accounts[1].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        );
        await mintTx.wait();
      }
      expect(await sbtContract.getStatus(accounts[1].address)).to.eq("Degen");
    });
    it("Should get the correct status if the address has earnt 15 tokens", async () => {
      for (let i = 0; i <= 14; i++) {
        increaseTime();
        const mintTx = await sbtContract.mint(
          accounts[1].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        );
        await mintTx.wait();
      }
      expect(await sbtContract.getStatus(accounts[1].address)).to.eq("Pepe");
    });
    it("Should get the correct status if the address has earnt 30 tokens", async () => {
      for (let i = 0; i <= 29; i++) {
        increaseTime();
        const mintTx = await sbtContract.mint(
          accounts[1].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        );
        await mintTx.wait();
      }
      expect(await sbtContract.getStatus(accounts[1].address)).to.eq("Contributoor");
    });
    it("Should get the correct status if the address has earnt 60 tokens", async () => {
      for (let i = 0; i <= 59; i++) {
        increaseTime();
        const mintTx = await sbtContract.mint(
          accounts[1].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        );
        await mintTx.wait();
      }
      expect(await sbtContract.getStatus(accounts[1].address)).to.eq("Aggregatoor");
    });
    it("Should get the correct status if the address has earnt 100 tokens or more", async () => {
      for (let i = 0; i <= 99; i++) {
        increaseTime();
        const mintTx = await sbtContract.mint(
          accounts[1].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        );
        await mintTx.wait();
      }
      expect(await sbtContract.getStatus(accounts[1].address)).to.eq("Oracle");
    });
  });

  describe("Revocation", async () => {
    it("Should identify a token as invalid if it has been revoked", async () => {
      const revokeTx = await sbtContract.revoke(1);
      revokeTx.wait();
      expect(await sbtContract.isValid(1)).to.be.false;
    });
    it("Should properly check if an address owns a valid token", async () => {
      expect(await sbtContract.hasValid(accounts[1].address)).to.be.true;
      const revokeTx = await sbtContract.revoke(1);
      revokeTx.wait();
      expect(await sbtContract.hasValid(accounts[1].address)).to.be.false;
    });
    it("Should be called by admin role only", async () => {
      await expect(sbtContract.connect(accounts[1]).revoke(1)).to.be.reverted;
    });
    it("Should revert if the token id for revocation is out of bounds", async () => {
      await expect(sbtContract.revoke(1337)).to.be.revertedWith(
        "Index is out of bounds."
      );
      await expect(sbtContract.revoke(0)).to.be.revertedWith(
        "Index is out of bounds."
      );
    });
  });
  describe("Metadata", async () => {
    it("Should return the correct name", async () => {
      expect(await sbtContract.name()).to.be.eq(
        "AmpliFrens Contribution Award"
      );
    });
    it("Should return the correct symbol", async () => {
      expect(await sbtContract.symbol()).to.be.eq("AFRENCONTRIBUTION");
    });
    it("Should set the Token URI correctly", async () => {
      increaseTime();
      const mintTx = await sbtContract.mint(
        accounts[1].address,
        contributionCategory,
        timestamp,
        votes,
        title,
        url
      );
      await mintTx.wait();
      const tokenURI = await sbtContract.tokenURI(BigNumber.from("2"));
      expect(tokenURI).to.eq("https://www.example.com/2.json");
    });

    it("Should revert if an invalid token URI parameter is provided", async () => {
      await expect(sbtContract.tokenURI("101")).to.be.revertedWith(
        "Index is out of bounds."
      );
    });
    describe("Base URI", async () => {
      let testSbtContract: AmpliFrensSBTTest;
      beforeEach(async () => {
        const testSbtContractFactory = (await ethers.getContractFactory(
          "AmpliFrensSBTTest"
        )) as AmpliFrensSBTTest__factory;
        testSbtContract = (await upgrades.deployProxy(
          testSbtContractFactory
        )) as AmpliFrensSBTTest;
        await testSbtContract.deployed();
      });
      it("Should return an empty string if it's not set", async () => {
        expect(await testSbtContract.parentBaseURI()).to.be.eq("");
      });
      it("Should not return an empty string when it is set", async () => {
        const baseURITx = await testSbtContract.setBaseURI(
          "https://www.new.com/"
        );
        await baseURITx.wait();
        expect(await testSbtContract.parentBaseURI()).to.be.eq(
          "https://www.new.com/"
        );
      });
    });
    it("Should change the base URI correctly", async () => {
      increaseTime();
      const setTokenURITx = await sbtContract.setBaseURI(
        "https://www.amplifrens.xyz/"
      );
      await setTokenURITx.wait();
      const mintTx = await sbtContract.mint(
        accounts[1].address,
        contributionCategory,
        timestamp,
        votes,
        title,
        url
      );
      await mintTx.wait();
      const tokenURI = await sbtContract.tokenURI(BigNumber.from("1"));
      expect(tokenURI).to.eq("https://www.amplifrens.xyz/1.json");
    });
  });
  describe("Events", async () => {
    it("Should emit a Minted event when a token is minted", async () => {
      increaseTime();
      await expect(
        sbtContract.mint(
          accounts[1].address,
          contributionCategory,
          timestamp,
          votes,
          title,
          url
        )
      )
        .to.emit(sbtContract, "Minted")
        .withArgs(accounts[1].address, 2);
    });
    it("Should emit a Revoked event when a token is revoked", async () => {
      increaseTime();
      await expect(sbtContract.revoke(1))
        .to.emit(sbtContract, "Revoked")
        .withArgs(accounts[1].address, 1);
    });
    it("Should emit a Paused event when pause() function is called", async () => {
      expect(await sbtContract.pause())
        .to.emit(sbtContract, "Paused")
        .withArgs(accounts[0].address);
    });
    it("Should emit an Unpaused event when unpause() function is called", async () => {
      const pauseTx = await sbtContract.pause();
      await pauseTx.wait();
      expect(await sbtContract.unpause())
        .to.emit(sbtContract, "Unpaused")
        .withArgs(accounts[0].address);
    });
  });
  describe("Interfaces", async () => {
    it("Should support IERC4671", async () => {
      expect(await sbtContract.supportsInterface("0xa511533d")).to.be.true;
    });
    it("Should support IERC4671Metadata", async () => {
      expect(await sbtContract.supportsInterface("0x5b5e139f")).to.be.true;
    });
    it("Should IERC4671Enumerable", async () => {
      expect(await sbtContract.supportsInterface("0x2d57debd")).to.be.true;
    });
  });
  describe("Upgradeability", async () => {
    it("Should be able to upgrade to a new implementation contract", async () => {
      const sbtContractV2Factory = await ethers.getContractFactory(
        "AmpliFrensSBTTestNewImpl"
      );
      const sbtContractV2 = (await upgrades.upgradeProxy(
        sbtContract.address,
        sbtContractV2Factory
      )) as AmpliFrensSBTTestNewImpl;
      expect(await sbtContractV2.newFunction()).to.be.eq(
        "New function for contract v2"
      );
    });
    it("Should throw an error if the storage layout order has been affected causing collisions", async () => {
      const sbtContractV2WrongFactory = await ethers.getContractFactory(
        "AmpliFrensSBTTestWrongImpl"
      );
      await expect(
        upgrades.upgradeProxy(sbtContract.address, sbtContractV2WrongFactory)
      ).to.eventually.be.rejectedWith("New storage layout is incompatible");
    });
  });
  describe("Receive", async () => {
    it("Should revert if funds are sent to the contract by an unallowed address", async () => {
      await expect(
        accounts[1].sendTransaction({
          to: sbtContract.address,
          value: ethers.utils.parseEther("1.0"),
        })
      ).to.be.reverted;
    });

    it("Should update the contract balance accordingly if allowed address send funds", async () => {
      const previousBalance = await ethers.provider.getBalance(
        sbtContract.address
      );
      expect(previousBalance).to.be.eq("0");
      await expect(
        accounts[0].sendTransaction({
          to: sbtContract.address,
          value: ethers.utils.parseEther("1.0"),
        })
      ).to.not.be.reverted;
      const newBalance = await sbtContract.provider.getBalance(
        sbtContract.address
      );
      expect(ethers.utils.formatEther(newBalance)).to.be.eq("1.0");
    });
  });
  describe("Fallback", async () => {
    it("Should revert if it is triggered by an unallowed address", async () => {
      await expect(
        accounts[1].sendTransaction({
          to: sbtContract.address,
          data: "0x13371337",
        })
      ).to.be.reverted;
    });

    it("Should be successful if triggered by an address with the correct admin role", async () => {
      const fallBackTriggerTx = await accounts[0].sendTransaction({
        to: sbtContract.address,
        data: "0x13371337",
      });
      await expect(fallBackTriggerTx).to.not.be.reverted;
    });
  });
});
