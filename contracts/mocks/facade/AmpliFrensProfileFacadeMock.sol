// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../../interfaces/IAmpliFrensProfile.sol";

/// @notice This is a contract to test specific events are triggered
/// @dev Enables facade forwarding tests
contract AmpliFrensProfileFacadeMock is IAmpliFrensProfile {
    event ProfileContract();

    function createProfile(DataTypes.Profile calldata, address) external override {
        emit ProfileContract();
    }

    function getProfile(address) external pure override returns (DataTypes.Profile memory) {
        return
            DataTypes.Profile(
                "d3legateCall.lens",
                "randomuser#1234",
                "d3legateCall",
                "d3legateCall",
                "anon@mirror.xyz",
                "https://www.anon.xyz",
                true
            );
    }

    function updateProfile(DataTypes.Profile calldata, address) external override {
        emit ProfileContract();
    }

    function deleteProfile(address, address) external override {
        emit ProfileContract();
    }

    function blacklist(
        address,
        address,
        string calldata
    ) external override {
        emit ProfileContract();
    }

    function getBlacklistReason(address) external pure override returns (string memory) {
        return "IAmpliFrensProfile";
    }

    function getProfileByUsername(string calldata) external pure override returns (DataTypes.Profile memory) {
        return
            DataTypes.Profile(
                "d3legateCall.lens",
                "randomuser#1234",
                "d3legateCall",
                "d3legateCall",
                "anon@mirror.xyz",
                "https://www.anon.xyz",
                true
            );
    }

    function hasProfile(address) external pure override returns (bool) {
        return true;
    }
}
