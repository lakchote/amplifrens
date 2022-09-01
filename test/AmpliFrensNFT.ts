import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { AmpliFrensNFT } from "../typechain-types/contracts/AmpliFrensNFT";
import { AmpliFrensNFTTest } from "../typechain-types/contracts/AmpliFrensNFTTest";
import { AmpliFrensNFT__factory } from "../typechain-types/factories/contracts/AmpliFrensNFT__factory";
import { AmpliFrensNFTTest__factory } from "../typechain-types/factories/contracts/AmpliFrensNFTTest__factory";
import { ethers } from "hardhat";
import { expect } from "chai";
import { BigNumber } from "ethers";

describe("NFT", async () => {
  let nftContract: AmpliFrensNFT;
  let nftTestContract: AmpliFrensNFTTest;
  let accounts: SignerWithAddress[];

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    const nftContractFactory = (await ethers.getContractFactory(
      "AmpliFrensNFT"
    )) as AmpliFrensNFT__factory;
    nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    const setBaseURITx = await nftContract.setBaseURI(
      "https://www.example.com/"
    );
    await setBaseURITx.wait();
    const nftTestContractFactory = (await ethers.getContractFactory(
      "AmpliFrensNFTTest"
    )) as AmpliFrensNFTTest__factory;
    nftTestContract = await nftTestContractFactory.deploy();
    await nftTestContract.deployed();
  });

  describe("Minting", async () => {
    it("Should revert if max supply is reached and minting is triggered", async () => {
      for (let i = 1; i <= 99; i++) {
        const mintTx = await nftContract.safeMint(
          ethers.Wallet.createRandom().address,
          i.toString()
        );
        await mintTx.wait();
      }
      await expect(
        nftContract.safeMint(accounts[1].address, "100")
      ).to.be.revertedWith("Max NFT supply has been reached.");
    });

    it("Should assign the correct token id to address", async () => {
      for (let i = 1; i <= 3; i++) {
        const mintTx = await nftContract.safeMint(
          ethers.Wallet.createRandom().address,
          i.toString()
        );
        await mintTx.wait();
      }
      const mintTx = await nftContract.safeMint(accounts[0].address, "4");
      await mintTx.wait();
      await expect(await nftContract.ownerOf(4)).to.eq(accounts[0].address);
    });

    it("Should revert if an EOA tries to mint more than one NFT", async () => {
      const firstMintTx = await nftContract.safeMint(
        accounts[0].address,
        "http://www.example.com/1.json"
      );
      await firstMintTx.wait();
      await expect(
        nftContract.safeMint(
          accounts[0].address,
          "http://www.example.com/2.json"
        )
      ).to.be.revertedWith("User can only have one NFT.");
    });

    it("Should be called by the MINTER_ROLE only", async () => {
      await expect(
        nftContract
          .connect(accounts[1])
          .safeMint(accounts[1].address, "http://www.example.com/1.json")
      ).to.be.reverted;
    });
  });

  describe("Royalties", async () => {
    beforeEach(async () => {
      const mintTx = await nftContract.safeMint(
        accounts[0].address,
        "http://www.example.com/1.json"
      );
      await mintTx.wait();
    });
    it("Should be able to set a new receiver address", async () => {
      const setDefaultRoyaltyReceiverTx = await nftContract.setDefaultRoyalty(
        accounts[1].address,
        1000
      );
      await setDefaultRoyaltyReceiverTx.wait();
      const [receiverAddress] = await nftContract.royaltyInfo(
        1,
        ethers.utils.parseEther("1")
      );
      expect(receiverAddress).to.be.eq(accounts[1].address);
    });
    it("Should be called by the DEFAULT_ADMIN_ROLE only", async () => {
      await expect(
        nftContract
          .connect(accounts[1])
          .setDefaultRoyalty(accounts[1].address, 1000)
      ).to.be.reverted;
    });
    it("Should revert if new receiver is address(0)", async () => {
      await expect(
        nftContract.setDefaultRoyalty(ethers.utils.hexZeroPad("0x", 20), 1000)
      ).to.be.reverted;
    });
    it("Should set the royalty amount as 5%", async () => {
      const setDefaultRoyaltyReceiverTx = await nftContract.setDefaultRoyalty(
        accounts[0].address,
        1000
      );
      await setDefaultRoyaltyReceiverTx.wait();
      const [, royaltyAmount] = await nftContract.royaltyInfo(
        1,
        ethers.utils.parseEther("1")
      );
      expect(ethers.utils.formatEther(royaltyAmount)).to.be.eq("0.1");
    });
  });
  describe("Interfaces", async () => {
    it("Should support IERC721", async () => {
      expect(await nftContract.supportsInterface("0x80ac58cd")).to.eq(true);
    });
    it("Should support IERC721Metadata", async () => {
      expect(await nftContract.supportsInterface("0x5b5e139f")).to.eq(true);
    });
    it("Should support IERC2981", async () => {
      expect(await nftContract.supportsInterface("0x2a55205a")).to.eq(true);
    });
  });
  describe("Token URI", async () => {
    it("Should set the Token URI correctly", async () => {
      const mintTx = await nftContract.safeMint(accounts[1].address, "50");
      await mintTx.wait();
      const tokenURI = await nftContract.tokenURI(BigNumber.from("50"));
      expect(tokenURI).to.eq("https://www.example.com/50.json");
    });
    it("Should revert if an invalid token URI parameter is provided", async () => {
      await expect(nftContract.tokenURI("101")).to.be.revertedWith(
        "TokenId is out of supply range."
      );
    });
    it("Should change the base URI correctly", async () => {
      const setTokenURITx = await nftContract.setBaseURI(
        "https://www.amplifrens.xyz/"
      );
      await setTokenURITx.wait();
      const mintTx = await nftContract.safeMint(accounts[1].address, "51");
      await mintTx.wait();
      const tokenURI = await nftContract.tokenURI(BigNumber.from("51"));
      expect(tokenURI).to.eq("https://www.amplifrens.xyz/51.json");
    });
  });
  describe("Base URI", async () => {
    it("Should return an empty string if it's not set", async () => {
      expect(await nftTestContract.parentBaseURI()).to.be.eq("");
    });
    it("Should not return an empty string when it is set", async () => {
      const baseURITx = await nftTestContract.setBaseURI(
        "https://www.new.com/"
      );
      await baseURITx.wait();
      expect(await nftTestContract.parentBaseURI()).to.be.eq(
        "https://www.new.com/"
      );
    });
  });
  describe("Burning", async () => {
    it("Should revert as the burn functionality is not implemented", async () => {
      await expect(nftTestContract.burn(1)).to.be.revertedWith(
        "Burn functionality is not implemented."
      );
    });
  });
});
