// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "./AmpliFrensNFT.sol";

/// @notice This is a contract to test specific AmpliFrensNFT functions
/// @dev Enables internal functions testing
contract AmpliFrensNFTTest is AmpliFrensNFT {
    function burn(uint256 _tokenId) public pure {
        _burn(_tokenId);
    }
    function parentBaseURI() public view returns(string memory) {
        return _baseURI();
    }
}