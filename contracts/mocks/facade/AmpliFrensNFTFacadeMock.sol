// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../../interfaces/IAmpliFrensNFT.sol";

/// @notice This is a contract to test specific events are triggered
/// @dev Enables facade forwarding tests
contract AmpliFrensNFTFacadeMock is IAmpliFrensNFT {
    event NFTContract();

    function mint(
        address,
        string memory,
        address
    ) public {
        emit NFTContract();
    }

    function transferNFT(
        address,
        address,
        uint256,
        address
    ) external {
        emit NFTContract();
    }

    function setDefaultRoyalty(
        address,
        uint96,
        address
    ) external {
        emit NFTContract();
    }

    function supportsInterface(bytes4 interfaceId) external view override returns (bool) {}

    function balanceOf(address owner) external view override returns (uint256 balance) {}

    function ownerOf(uint256 tokenId) external view override returns (address owner) {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external override {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {}

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {}

    function approve(address to, uint256 tokenId) external override {}

    function setApprovalForAll(address operator, bool _approved) external override {}

    function setBaseURI(string calldata, address) external {
        emit NFTContract();
    }

    function getApproved(uint256 tokenId) external view override returns (address operator) {}

    function isApprovedForAll(address owner, address operator) external view override returns (bool) {}

    function name() external view override returns (string memory) {}

    function symbol() external view override returns (string memory) {}

    function tokenURI(uint256) external pure override returns (string memory) {
        return "IAmpliFrensNFT";
    }
}
