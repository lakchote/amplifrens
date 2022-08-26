describe("Soulbound Token", async () => {
  describe("Minting", async () => {
    it("Should be called by the creator address only", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    describe("Ownership", async () => {
      it("Should update the token balances accordingly", async () => {
        throw new Error("Not implemented.");
        // TODO
      });
      it("Should identify properly the owner of a tokenId", async () => {
        throw new Error("Not implemented.");
        // TODO
      });
    });
  });
  describe("Enumeration", async () => {
    it("Should increase the tokens emitted count if a token has been minted", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should track the tokens holders count properly", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should be able to retrieve a tokenId using its position in an owner's list", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should return the correct tokenId for a given index", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
  });
  describe("Validity", async () => {
    it("Should identify a token as invalid if it has been revoked", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should properly check if an address owns a valid token", async () => {
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
  describe("Events", async () => {
    it("Should emit a Minted event when a token is minted", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should emit a Revoked event when a token is revoked", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
  });
  describe("Interfaces", async () => {
    it("Should support IERC4671", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should support IERC4671Metadata", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should IERC4671Enumerable", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
  });
  describe("Upgradeability", async () => {
    it("Should be able to upgrade to a new implementation contract", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
    it("Should throw an error if the storage layout order has been affected causing collisions", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
  });
  describe("Receive", async () => {
    it("Should revert if funds are sent to the contract", async () => {
      throw new Error("Not implemented.");
      // TODO
    });
  });
});
