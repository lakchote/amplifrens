import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { AmpliFrensNFT } from "../typechain-types/contracts/AmpliFrensNFT";
import { AmpliFrensNFTMock } from "../typechain-types/contracts/mocks/AmpliFrensNFTMock";
import { AmpliFrensNFT__factory } from "../typechain-types/factories/contracts/AmpliFrensNFT__factory";
import { AmpliFrensNFTMock__factory } from "../typechain-types/factories/contracts/mocks/AmpliFrensNFTMock__factory";
import { ethers } from "hardhat";
import { expect } from "chai";
import { BigNumber } from "ethers";
import { Errors } from "../typechain-types";

describe("NFT", async () => {
  let nftContract: AmpliFrensNFT;
  let nftMockContract: AmpliFrensNFTMock;
  let accounts: SignerWithAddress[];
  let errorsLib: Errors;

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    const tokenURIHelperLib = await (await (await ethers.getContractFactory("TokenURI")).deploy()).deployed();
    const pseudoModifierLib = await (await (await ethers.getContractFactory("PseudoModifier")).deploy()).deployed();
    errorsLib = (await (await (await ethers.getContractFactory("Errors")).deploy()).deployed()) as Errors;

    const nftContractFactory = (await ethers.getContractFactory("AmpliFrensNFT", {
      libraries: {
        TokenURI: tokenURIHelperLib.address,
        PseudoModifier: pseudoModifierLib.address,
      },
    })) as AmpliFrensNFT__factory;
    nftContract = await nftContractFactory.deploy(accounts[0].address);
    await nftContract.deployed();
    const setBaseURITx = await nftContract.setBaseURI("https://www.example.com/");
    await setBaseURITx.wait();
    const nftMockContractFactory = (await ethers.getContractFactory("AmpliFrensNFTMock", {
      libraries: {
        TokenURI: tokenURIHelperLib.address,
        PseudoModifier: pseudoModifierLib.address,
      },
    })) as AmpliFrensNFTMock__factory;
    nftMockContract = await nftMockContractFactory.deploy(accounts[0].address);
    await nftMockContract.deployed();
  });

  describe("Minting", async () => {
    it("Should revert if max supply is reached and minting is triggered", async () => {
      const maxSupply = Number(await nftContract.MAX_SUPPLY());
      for (let i = 1; i <= maxSupply; i++) {
        const mintTx = await nftContract.mint(accounts[0].address, i.toString());
        await mintTx.wait();
      }
      expect(await nftContract.balanceOf(accounts[0].address)).to.eq(maxSupply);
      await expect(nftContract.mint(accounts[1].address, "16")).to.be.revertedWithCustomError(
        errorsLib,
        "MaxSupplyReached"
      );
    });

    it("Should assign the correct token id to address", async () => {
      for (let i = 1; i <= 3; i++) {
        const mintTx = await nftContract.mint(ethers.Wallet.createRandom().address, i.toString());
        await mintTx.wait();
      }
      const mintTx = await nftContract.mint(accounts[0].address, "4");
      await mintTx.wait();
      await expect(await nftContract.ownerOf(4)).to.eq(accounts[0].address);
    });

    it("Should be called by the MINTER_ROLE only", async () => {
      await expect(nftContract.connect(accounts[1]).mint(accounts[1].address, "http://www.example.com/1.json")).to.be
        .reverted;
    });
  });

  describe("Transfer", async () => {
    it("Should revert if the recipient already has one NFT", async () => {
      for (let i = 0; i < 2; i++) {
        const mintTx = await nftContract.mint(accounts[0].address, `http://www.example.com/${i}.json`);
        await mintTx.wait();
      }

      const transferTx = await nftContract.transferNFT(accounts[0].address, accounts[1].address, 1);
      await transferTx.wait();

      await expect(nftContract.transferNFT(accounts[0].address, accounts[1].address, 2)).to.be.revertedWithCustomError(
        nftContract,
        "AlreadyOwnNft"
      );
    });
  });

  describe("Royalties", async () => {
    beforeEach(async () => {
      const mintTx = await nftContract.mint(accounts[0].address, "http://www.example.com/1.json");
      await mintTx.wait();
    });

    it("Should be able to set a new receiver address", async () => {
      const setDefaultRoyaltyReceiverTx = await nftContract.setDefaultRoyalty(accounts[1].address, 1000);
      await setDefaultRoyaltyReceiverTx.wait();
      const [receiverAddress] = await nftContract.royaltyInfo(1, ethers.utils.parseEther("1"));
      expect(receiverAddress).to.be.eq(accounts[1].address);
    });

    it("Should be called by the DEFAULT_ADMIN_ROLE only", async () => {
      await expect(nftContract.connect(accounts[1]).setDefaultRoyalty(accounts[1].address, 1000)).to.be.reverted;
    });

    it("Should revert if new receiver is address(0)", async () => {
      await expect(
        nftContract.setDefaultRoyalty(ethers.utils.hexZeroPad("0x", 20), 1000)
      ).to.be.revertedWithCustomError(errorsLib, "AddressNull");
    });

    it("Should set the royalty amount as 5%", async () => {
      const setDefaultRoyaltyReceiverTx = await nftContract.setDefaultRoyalty(accounts[0].address, 1000);
      await setDefaultRoyaltyReceiverTx.wait();
      const [, royaltyAmount] = await nftContract.royaltyInfo(1, ethers.utils.parseEther("1"));
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

    it("Should support IERC165", async () => {
      expect(await nftContract.supportsInterface("0x01ffc9a7")).to.be.true;
    });
  });
  describe("Token URI", async () => {
    it("Should set the Token URI correctly", async () => {
      const mintTx = await nftContract.mint(accounts[1].address, "1");
      await mintTx.wait();
      const tokenURI = await nftContract.tokenURI(BigNumber.from("1"));
      expect(tokenURI).to.eq("https://www.example.com/1.json");
    });

    it("Should revert if an invalid token URI parameter is provided", async () => {
      await expect(nftContract.tokenURI("101")).to.be.revertedWithCustomError(errorsLib, "OutOfBounds");
    });

    it("Should change the base URI correctly", async () => {
      const setTokenURITx = await nftContract.setBaseURI("https://www.amplifrens.xyz/");
      await setTokenURITx.wait();
      const mintTx = await nftContract.mint(accounts[1].address, "1");
      await mintTx.wait();
      const tokenURI = await nftContract.tokenURI(BigNumber.from("1"));
      expect(tokenURI).to.eq("https://www.amplifrens.xyz/1.json");
    });
  });
  describe("Burning", async () => {
    it("Should revert as the burn functionality is not implemented", async () => {
      await expect(nftMockContract.burn(1)).to.be.revertedWithCustomError(errorsLib, "NotImplemented");
    });
  });
});
