// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import {DataTypes} from "../libraries/DataTypes.sol";

interface IAmpliFrensProfile {
    event Blacklisted(address indexed _address, bytes32 indexed reason, uint256 timestamp);
    event ProfileCreated(address indexed _address, uint256 timestamp);
    event ProfileUpdated(address indexed _address, uint256 timestamp);
    event ProfileDeleted(address indexed _address, uint256 timestamp);

    function createProfile(
        address _address,
        bytes32 username,
        bytes32 lensHandle,
        bytes32 discordHandle,
        bytes32 twitterHandle,
        bytes32 email,
        string calldata websiteUrl
    ) external;

    function deleteProfile(address _address) external;

    function blacklist(address _address, bytes32 reason) external;

    function getBlacklistReason(address _address) external view returns (bytes32);

    function updateProfile(
        address _address,
        bytes32 username,
        bytes32 lensHandle,
        bytes32 discordHandle,
        bytes32 twitterHandle,
        bytes32 email,
        string calldata websiteUrl
    ) external;

    function getProfileByUsername(bytes32 username) external view returns (DataTypes.Profile memory);

    function getProfileByEmail(bytes32 email) external view returns (DataTypes.Profile memory);

    function getProfileByTwitterHandle(bytes32 twitterHandle) external view returns (DataTypes.Profile memory);

    function getProfileByDiscordHandle(bytes32 discordHandle) external view returns (DataTypes.Profile memory);

    function getProfileByLensHandle(bytes32 lensHandle) external view returns (DataTypes.Profile memory);

    function hasProfile(address _address) external view returns (bool);
}
