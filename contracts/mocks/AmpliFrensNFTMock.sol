// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../AmpliFrensNFT.sol";

/// @notice This is a contract to test specific AmpliFrensNFT functions
/// @dev Enables internal functions testing
contract AmpliFrensNFTMock is AmpliFrensNFT {
    address public immutable newProxy;

    constructor(address _newProxy) AmpliFrensNFT(_newProxy) {
        newProxy = _newProxy;
    }

    function burn(uint256 _tokenId) public pure {
        _burn(_tokenId);
    }
}
