// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../../interfaces/IAmpliFrensSBT.sol";

/// @notice This is a contract to test specific events are triggered
/// @dev Enables facade forwarding tests
contract AmpliFrensSBTFacadeMock is IAmpliFrensSBT {
    event SBTContract();

    function mint(DataTypes.Contribution calldata) external override {
        emit SBTContract();
    }

    function revoke(uint256, address) external override {
        emit SBTContract();
    }

    function setBaseURI(string calldata, address) external {
        emit SBTContract();
    }

    function tokenByIndex(uint256 index) external view override returns (uint256) {}

    function name() external view override returns (string memory) {}

    function symbol() external view override returns (string memory) {}

    function balanceOf(address) external pure override returns (uint256) {
        return 31337;
    }

    function isMintingIntervalMet() external pure override returns (bool) {
        return true;
    }

    function ownerOf(uint256) external pure override returns (address) {
        return address(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045);
    }

    function isValid(uint256) external pure override returns (bool) {
        return true;
    }

    function hasValid(address) external pure override returns (bool) {
        return true;
    }

    function emittedCount() external pure override returns (uint256) {
        return 31337;
    }

    function holdersCount() external pure override returns (uint256) {
        return 1337;
    }

    function tokenOfOwnerByIndex(address, uint256) external pure override returns (uint256) {
        return 1337;
    }

    function tokenById(uint256) external pure override returns (DataTypes.Contribution memory) {
        return
            DataTypes.Contribution(
                address(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045),
                DataTypes.ContributionCategory(7),
                true,
                1664280770,
                1337,
                1,
                "You won't believe this WL",
                "https://notboredapeyachtclub.com/whitelist"
            );
    }

    function getStatus(address _address) external view override returns (DataTypes.FrenStatus) {}

    function tokenURI(uint256) external pure override returns (string memory) {
        return "IAmpliFrensSBT";
    }
}
