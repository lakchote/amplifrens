// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../AmpliFrensSBT.sol";

/// @notice This is a contract to test specific AmpliFrensSBT functions
/// @dev Enables internal functions testing
/// @custom:oz-upgrades-unsafe-allow external-library-linking
contract AmpliFrensSBTMock is AmpliFrensSBT {
    function parentBaseURI() public view returns (string memory) {
        return _baseURI();
    }
}