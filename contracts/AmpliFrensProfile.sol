// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import {IAmpliFrensProfile} from "./interfaces/IAmpliFrensProfile.sol";
import {DataTypes} from "./libraries/DataTypes.sol";

/**
 * @title AmpliFrensProfile
 * @author Lucien Akchoté
 *
 * @notice Handles profile operations for AmpliFrens
 * @custom:security-contact lakchote@icloud.com
 */
contract AmpliFrensProfile is AccessControl, IAmpliFrensProfile {
    using Counters for Counters.Counter;

    mapping(address => DataTypes.Profile) private _profiles;
    mapping(bytes32 => address) private _usernames;
    mapping(bytes32 => address) private _discordHandles;
    mapping(bytes32 => address) private _twitterHandles;
    mapping(bytes32 => address) private _lensHandles;
    mapping(bytes32 => address) private _emails;
    mapping(address => bytes32) private _blacklistedAddresses;
    mapping(address => bool) private _profileAddresses;

    Counters.Counter public profilesCount;

    modifier hasExistence(mapping(bytes32 => address) storage _handlesMap, bytes32 handle) {
        require(_handlesMap[handle] != address(0), "No user");
        _;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function blacklist(address _address, bytes32 reason) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(this.hasProfile(_address), "No profile");
        _blacklistedAddresses[_address] = reason;
        profilesCount.decrement();

        delete (_profileAddresses[_address]);
        delete (_profiles[_address]);

        emit Blacklisted(_address, reason, block.timestamp);
    }

    function getBlacklistReason(address _address) external view onlyRole(DEFAULT_ADMIN_ROLE) returns (bytes32) {
        require(bytes4(_blacklistedAddresses[_address]) != bytes4(0x00), "Not blacklisted");
        return _blacklistedAddresses[_address];
    }

    function createProfile(
        address _address,
        bytes32 username,
        bytes32 lensHandle,
        bytes32 discordHandle,
        bytes32 twitterHandle,
        bytes32 email,
        string calldata websiteUrl
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_usernames[username] == address(0), "Username exist");
        require(_emails[email] == address(0), "Email exist");
        require(_discordHandles[discordHandle] == address(0), "Discord ID exist");
        require(_twitterHandles[twitterHandle] == address(0), "Twitter ID exist");
        require(_lensHandles[lensHandle] == address(0), "Lens ID exist");

        _profiles[_address] = DataTypes.Profile(lensHandle, discordHandle, twitterHandle, username, email, websiteUrl);

        _usernames[username] = _address;
        _emails[email] = _address;
        _lensHandles[lensHandle] = _address;
        _discordHandles[discordHandle] = _address;
        _twitterHandles[twitterHandle] = _address;

        profilesCount.increment();
        _profileAddresses[_address] = true;

        emit ProfileCreated(_address, block.timestamp);
    }

    function deleteProfile(address _address) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(this.hasProfile(_address), "No profile");
        profilesCount.decrement();

        delete (_profileAddresses[_address]);
        delete (_profiles[_address]);

        emit ProfileDeleted(_address, block.timestamp);
    }

    function updateProfile(
        address _address,
        bytes32 username,
        bytes32 lensHandle,
        bytes32 discordHandle,
        bytes32 twitterHandle,
        bytes32 email,
        string calldata websiteUrl
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(this.hasProfile(_address), "No profile");
        delete (_emails[_profiles[_address].email]);
        _emails[email] = _address;
        _profiles[_address].email = email;

        delete (_lensHandles[_profiles[_address].lensHandle]);
        _lensHandles[lensHandle] = _address;
        _profiles[_address].lensHandle = lensHandle;

        delete (_discordHandles[_profiles[_address].discordHandle]);
        _discordHandles[discordHandle] = _address;
        _profiles[_address].discordHandle = discordHandle;

        delete (_twitterHandles[_profiles[_address].twitterHandle]);
        _twitterHandles[twitterHandle] = _address;
        _profiles[_address].twitterHandle = twitterHandle;

        delete (_usernames[_profiles[_address].username]);
        _usernames[twitterHandle] = _address;
        _profiles[_address].username = username;

        _profiles[_address].websiteUrl = websiteUrl;

        emit ProfileUpdated(_address, block.timestamp);
    }

    function getProfileByUsername(bytes32 username)
        external
        view
        hasExistence(_usernames, username)
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (DataTypes.Profile memory)
    {
        return _profiles[_usernames[username]];
    }

    function getProfileByEmail(bytes32 email)
        external
        view
        hasExistence(_emails, email)
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (DataTypes.Profile memory)
    {
        return _profiles[_emails[email]];
    }

    function getProfileByTwitterHandle(bytes32 twitterHandle)
        external
        view
        hasExistence(_twitterHandles, twitterHandle)
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (DataTypes.Profile memory)
    {
        return _profiles[_twitterHandles[twitterHandle]];
    }

    function getProfileByDiscordHandle(bytes32 discordHandle)
        external
        view
        hasExistence(_discordHandles, discordHandle)
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (DataTypes.Profile memory)
    {
        return _profiles[_discordHandles[discordHandle]];
    }

    function getProfileByLensHandle(bytes32 lensHandle)
        external
        view
        hasExistence(_lensHandles, lensHandle)
        returns (DataTypes.Profile memory)
    {
        return _profiles[_lensHandles[lensHandle]];
    }

    function hasProfile(address _address) external view returns (bool) {
        return _profileAddresses[_address];
    }
}
