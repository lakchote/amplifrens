// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import {DataTypes} from "../types/DataTypes.sol";

/**
 * @title ProfileLogic
 * @author Lucien Akchoté
 *
 * @notice A library that implements the logic of profile related functions
 */
library ProfileLogic {
    using Counters for Counters.Counter;

    modifier hasProfile(address _address, mapping(address => DataTypes.Profile) storage _profiles) {
        require(_profiles[_address].valid, "No profile");
        _;
    }

    modifier hasHandleExistence(mapping(bytes32 => address) storage _handlesMap, bytes32 handle) {
        require(_handlesMap[handle] != address(0), "No user");
        _;
    }

    /// @dev See `IAmpliFrensProfile` for descriptions
    event ProfileBlacklisted(address indexed _address, bytes32 indexed reason, uint256 timestamp);
    event ProfileCreated(address indexed _address, uint256 timestamp);
    event ProfileUpdated(address indexed _address, uint256 timestamp);
    event ProfileDeleted(address indexed _address, uint256 timestamp);

    /**
     * @notice Blacklist a profile with address `_address` for reason `reason`
     *
     * @param _address The profile's address to blacklist
     * @param reason The reason of the blacklist
     * @param _blacklistedAddresses The addresses of all blacklisted addresses
     * @param _profiles The current profiles list
     * @param profilesCount The total counter of all profiles
     */
    function blackList(
        address _address,
        bytes32 reason,
        mapping(address => bytes32) storage _blacklistedAddresses,
        mapping(address => DataTypes.Profile) storage _profiles,
        Counters.Counter storage profilesCount
    ) external hasProfile(_address, _profiles) {
        _blacklistedAddresses[_address] = reason;
        profilesCount.decrement();

        delete (_profiles[_address]);
        emit ProfileBlacklisted(_address, reason, block.timestamp);
    }

    /**
     * @notice Get the blacklist reason for address `_address`
     *
     * @param _address The profile's address to query
     * @param _blacklistedAddresses The addresses of all blacklisted addresses
     * @return The blacklist reason
     */
    function getBlacklistReason(address _address, mapping(address => bytes32) storage _blacklistedAddresses)
        external
        view
        returns (bytes32)
    {
        require(bytes1(_blacklistedAddresses[_address]) != 0x00, "Not blacklisted");
        return _blacklistedAddresses[_address];
    }

    /**
     * @notice Create a profile for address `_address`
     *
     * @param _address The profile's address to create
     * @param profile The profile data
     * @param _profiles The current profiles list
     * @param _usernames The current usernames list
     * @param _emails The current emails list
     * @param _discordHandles The current Discord handles list
     * @param _lensHandles The current Lens handles list
     * @param _twitterHandles The current Twitter handles list
     * @param profilesCount The total counter of all profiles
     */
    function createProfile(
        address _address,
        DataTypes.Profile calldata profile,
        mapping(address => DataTypes.Profile) storage _profiles,
        mapping(bytes32 => address) storage _usernames,
        mapping(bytes32 => address) storage _emails,
        mapping(bytes32 => address) storage _discordHandles,
        mapping(bytes32 => address) storage _lensHandles,
        mapping(bytes32 => address) storage _twitterHandles,
        Counters.Counter storage profilesCount
    ) external {
        require(bytes1(profile.username) != 0x00, "Empty username");
        require(_usernames[profile.username] == address(0), "Username exist");
        require(_emails[profile.email] == address(0), "Email exist");
        require(_discordHandles[profile.discordHandle] == address(0), "Discord ID exist");
        require(_twitterHandles[profile.twitterHandle] == address(0), "Twitter ID exist");
        require(_lensHandles[profile.lensHandle] == address(0), "Lens ID exist");

        _profiles[_address] = DataTypes.Profile(
            profile.lensHandle,
            profile.discordHandle,
            profile.twitterHandle,
            profile.username,
            profile.email,
            profile.websiteUrl,
            true
        );

        _usernames[profile.username] = _address;
        _emails[profile.email] = _address;
        _lensHandles[profile.lensHandle] = _address;
        _discordHandles[profile.discordHandle] = _address;
        _twitterHandles[profile.twitterHandle] = _address;

        profilesCount.increment();

        emit ProfileCreated(_address, block.timestamp);
    }

    /**
     * @notice Delete the profile of address `_address`
     *
     * @param _address The profile's address to create
     * @param _profiles The current profiles list
     * @param profilesCount The total counter of all profiles
     */
    function deleteProfile(
        address _address,
        mapping(address => DataTypes.Profile) storage _profiles,
        Counters.Counter storage profilesCount
    ) external hasProfile(_address, _profiles) {
        profilesCount.decrement();

        delete (_profiles[_address]);

        emit ProfileDeleted(_address, block.timestamp);
    }

    /**
     * @notice Update the profile for address `_address`
     *
     * @param _address The profile's address to create
     * @param profile The profile data
     * @param _profiles The current profiles list
     * @param _usernames The current usernames list
     * @param _emails The current emails list
     * @param _discordHandles The current Discord handles list
     * @param _lensHandles The current Lens handles list
     * @param _twitterHandles The current Twitter handles list
     */
    function updateProfile(
        address _address,
        DataTypes.Profile calldata profile,
        mapping(address => DataTypes.Profile) storage _profiles,
        mapping(bytes32 => address) storage _usernames,
        mapping(bytes32 => address) storage _emails,
        mapping(bytes32 => address) storage _discordHandles,
        mapping(bytes32 => address) storage _lensHandles,
        mapping(bytes32 => address) storage _twitterHandles
    ) external hasProfile(_address, _profiles) {
        if (profile.email.length > 0) {
            delete (_emails[_profiles[_address].email]);
            _emails[profile.email] = _address;
            _profiles[_address].email = profile.email;
        }

        if (profile.lensHandle.length > 0) {
            delete (_lensHandles[_profiles[_address].lensHandle]);
            _lensHandles[profile.lensHandle] = _address;
            _profiles[_address].lensHandle = profile.lensHandle;
        }

        if (profile.discordHandle.length > 0) {
            delete (_discordHandles[_profiles[_address].discordHandle]);
            _discordHandles[profile.discordHandle] = _address;
            _profiles[_address].discordHandle = profile.discordHandle;
        }

        if (profile.twitterHandle.length > 0) {
            delete (_twitterHandles[_profiles[_address].twitterHandle]);
            _twitterHandles[profile.twitterHandle] = _address;
            _profiles[_address].twitterHandle = profile.twitterHandle;
        }

        if (profile.username.length > 0) {
            delete (_usernames[_profiles[_address].username]);
            _usernames[profile.username] = _address;
            _profiles[_address].username = profile.username;
        }

        if (bytes(profile.websiteUrl).length > 0) {
            _profiles[_address].websiteUrl = profile.websiteUrl;
        }

        emit ProfileUpdated(_address, block.timestamp);
    }

    /**
     * @notice Get the profile of address `_address`
     *
     * @param _address The profile's address to create
     * @param _profiles The current profiles list
     */
    function getProfile(address _address, mapping(address => DataTypes.Profile) storage _profiles)
        external
        view
        hasProfile(_address, _profiles)
        returns (DataTypes.Profile memory)
    {
        return _profiles[_address];
    }

    /**
     * @notice Get a profile by its username `username`
     *
     * @param username The username to query
     * @param _usernames The usernames list
     * @param _profiles The profiles list
     * @return `DataTypes.Profile` containing the profile data
     */
    function getProfileByUsername(
        bytes32 username,
        mapping(bytes32 => address) storage _usernames,
        mapping(address => DataTypes.Profile) storage _profiles
    ) external view hasHandleExistence(_usernames, username) returns (DataTypes.Profile memory) {
        return _profiles[_usernames[username]];
    }

    /**
     * @notice Get a profile by its email `email`
     *
     * @param email The email to query
     * @param _emails The emails list
     * @param _profiles The profiles list
     * @return `DataTypes.Profile` containing the profile data
     */
    function getProfileByEmail(
        bytes32 email,
        mapping(bytes32 => address) storage _emails,
        mapping(address => DataTypes.Profile) storage _profiles
    ) external view hasHandleExistence(_emails, email) returns (DataTypes.Profile memory) {
        return _profiles[_emails[email]];
    }

    /**
     * @notice Get a profile by its Twitter handle `twitterHandle`
     *
     * @param twitterHandle The email to query
     * @param _twitterHandles The Twitter handles list
     * @param _profiles The profiles list
     * @return `DataTypes.Profile` containing the profile data
     */
    function getProfileByTwitterHandle(
        bytes32 twitterHandle,
        mapping(bytes32 => address) storage _twitterHandles,
        mapping(address => DataTypes.Profile) storage _profiles
    ) external view hasHandleExistence(_twitterHandles, twitterHandle) returns (DataTypes.Profile memory) {
        return _profiles[_twitterHandles[twitterHandle]];
    }

    /**
     * @notice Get a profile by its Discord handle `discordHandle`
     *
     * @param discordHandle The email to query
     * @param _discordHandles The Twitter handles list
     * @param _profiles The profiles list
     * @return `DataTypes.Profile` containing the profile data
     */
    function getProfileByDiscordHandle(
        bytes32 discordHandle,
        mapping(bytes32 => address) storage _discordHandles,
        mapping(address => DataTypes.Profile) storage _profiles
    ) external view hasHandleExistence(_discordHandles, discordHandle) returns (DataTypes.Profile memory) {
        return _profiles[_discordHandles[discordHandle]];
    }

    /**
     * @notice Get a profile by its Lens handle `lensHandle`
     *
     * @param lensHandle The email to query
     * @param _lensHandles The Twitter handles list
     * @param _profiles The profiles list
     * @return `DataTypes.Profile` containing the profile data
     */
    function getProfileByLensHandle(
        bytes32 lensHandle,
        mapping(bytes32 => address) storage _lensHandles,
        mapping(address => DataTypes.Profile) storage _profiles
    ) external view hasHandleExistence(_lensHandles, lensHandle) returns (DataTypes.Profile memory) {
        return _profiles[_lensHandles[lensHandle]];
    }
}
