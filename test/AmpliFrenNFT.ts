describe("NFT", async () => {
  describe("Minting", async () => {
    it("Should revert if max supply is reached and minting is triggered", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should revert if an EOA tries to mint more than one NFT", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should be called by the MINTER_ROLE only", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
  });
  describe("Royalties", async () => {
    it("Should be able to set a new receiver address", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should be called by the ADMIN_ROLE only", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should revert if new receiver is address(0)", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should set the royalty amount as 5%", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
  });
  describe("Interfaces", async () => {
    it("Should support IERC721", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should support IERC721Metadata", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should support IERC2981", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
  });
  describe("Token URI", async () => {
    it("Should set the Token URI correctly", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should revert if an invalid token URI parameter is provided", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
  });
});
