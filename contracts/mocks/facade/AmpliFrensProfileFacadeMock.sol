// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../../interfaces/IAmpliFrensProfile.sol";

/// @notice This is a contract to test specific events are triggered
/// @dev Enables facade forwarding tests
contract AmpliFrensProfileFacadeMock is IAmpliFrensProfile {
    event ProfileContract();

    function createProfile(DataTypes.Profile calldata) external override {
        emit ProfileContract();
    }

    function getProfile(address) external pure override returns (DataTypes.Profile memory) {
        return
            DataTypes.Profile(
                bytes32("d3legateCall.lens"),
                bytes32("randomuser#1234"),
                bytes32("d3legateCall"),
                bytes32("d3legateCall"),
                bytes32("anon@mirror.xyz"),
                "https://www.anon.xyz",
                true
            );
    }

    function updateProfile(DataTypes.Profile calldata) external override {
        emit ProfileContract();
    }

    function deleteProfile(address) external override {
        emit ProfileContract();
    }

    function blacklist(address, bytes32) external override {
        emit ProfileContract();
    }

    function getBlacklistReason(address) external pure override returns (bytes32) {
        return bytes32("IAmpliFrensProfile");
    }

    function getProfileByUsername(bytes32) external pure override returns (DataTypes.Profile memory) {
        return
            DataTypes.Profile(
                bytes32("d3legateCall.lens"),
                bytes32("randomuser#1234"),
                bytes32("d3legateCall"),
                bytes32("d3legateCall"),
                bytes32("anon@mirror.xyz"),
                "https://www.anon.xyz",
                true
            );
    }

    function hasProfile(address) external pure override returns (bool) {
        return true;
    }
}
