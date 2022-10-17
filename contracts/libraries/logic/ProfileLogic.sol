// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import {DataTypes} from "../types/DataTypes.sol";
import {Errors} from "../helpers/Errors.sol";
import {PseudoModifier} from "../guards/PseudoModifier.sol";

/**
 * @title ProfileLogic
 * @author Lucien Akchoté
 *
 * @notice A library that implements the logic of profile related functions
 */
library ProfileLogic {
    using Counters for Counters.Counter;

    /// @dev See `IAmpliFrensProfile` for descriptions
    event ProfileBlacklisted(address _address, string reason, uint256 timestamp);
    event ProfileUpdated(address indexed _address, string username, uint256 timestamp);
    event ProfileDeleted(address indexed _address, uint256 timestamp);
    event ProfileCreated(address indexed _address, uint256 timestamp, string username);

    /**
     * @notice Check if address `_address` has created a profile
     *
     * @param _address The address to check profile existence
     * @param _profiles The current profiles list
     */
    modifier hasProfile(address _address, mapping(address => DataTypes.Profile) storage _profiles) {
        if (!_profiles[_address].valid) revert Errors.NoProfileWithAddress();
        _;
    }

    /**
     * @notice Check if handle `handle` exist
     *
     * @param _handlesMap Social handles mapping with addresses
     * @param handle The handle to check existence
     */
    modifier hasHandleExistence(mapping(string => address) storage _handlesMap, string calldata handle) {
        if (_handlesMap[handle] == address(0)) revert Errors.NoProfileWithSocialHandle();
        _;
    }

    /**
     * @notice Blacklist a profile with address `_address` for reason `reason`
     *
     * @param _address The profile's address to blacklist
     * @param from  The address `from` who initiated the transaction
     * @param adminAddress The admin's address
     * @param reason The reason of the blacklist
     * @param _blacklistedAddresses The addresses of all blacklisted addresses
     * @param _profiles The current profiles list
     * @param profilesCount The total counter of all profiles
     */
    function blackList(
        address _address,
        address from,
        address adminAddress,
        address facadeProxyAddress,
        string calldata reason,
        mapping(address => string) storage _blacklistedAddresses,
        mapping(address => DataTypes.Profile) storage _profiles,
        Counters.Counter storage profilesCount
    ) external hasProfile(_address, _profiles) {
        PseudoModifier.isFacadeCall(facadeProxyAddress, msg.sender);
        PseudoModifier.addressEq(adminAddress, from);

        _blacklistedAddresses[_address] = reason;
        profilesCount.decrement();

        delete (_profiles[_address]);

        emit ProfileBlacklisted(_address, reason, block.timestamp);
    }

    /**
     * @notice Create a profile for address `from`
     *
     * @param profile The profile data
     * @param from  The address `from` who initiated the transaction
     * @param facadeProxyAddress The address of the facade proxy
     * @param _profiles The current profiles list
     * @param _usernames The current usernames list
     */
    function createProfile(
        DataTypes.Profile calldata profile,
        address from,
        address facadeProxyAddress,
        mapping(address => DataTypes.Profile) storage _profiles,
        mapping(string => address) storage _usernames,
        Counters.Counter storage profilesCount
    ) external {
        PseudoModifier.isFacadeCall(facadeProxyAddress, msg.sender);

        if (bytes8(bytes(profile.username)) == 0x00) revert Errors.EmptyUsername();
        if (_usernames[profile.username] != address(0)) revert Errors.UsernameExist();

        _profiles[from] = DataTypes.Profile(
            profile.lensHandle,
            profile.discordHandle,
            profile.twitterHandle,
            profile.username,
            profile.email,
            profile.websiteUrl,
            true
        );

        _usernames[profile.username] = from;

        profilesCount.increment();

        emit ProfileCreated(from, block.timestamp, profile.username);
    }

    /**
     * @notice Delete the profile of address `_address`
     *
     * @param _address The profile's address to create
     * @param from  The address `from` who initiated the transaction
     * @param adminAddress The admin's address
     * @param _profiles The current profiles list
     * @param profilesCount The total counter of all profiles
     */
    function deleteProfile(
        address _address,
        address from,
        address adminAddress,
        address facadeProxyAddress,
        mapping(address => DataTypes.Profile) storage _profiles,
        Counters.Counter storage profilesCount
    ) external hasProfile(_address, _profiles) {
        PseudoModifier.isFacadeCall(facadeProxyAddress, msg.sender);
        PseudoModifier.isAuthorOrAdmin(adminAddress, _address, from);

        profilesCount.decrement();

        delete (_profiles[_address]);

        emit ProfileDeleted(_address, block.timestamp);
    }

    /**
     * @notice Update the profile for address `_address`
     *
     * @param profile The profile data
     * @param from  The address `from` who initiated the transaction
     * @param facadeProxyAddress The address of the facade proxy
     * @param _profiles The current profiles list
     * @param _usernames The current usernames list
     */
    function updateProfile(
        DataTypes.Profile calldata profile,
        address from,
        address facadeProxyAddress,
        mapping(address => DataTypes.Profile) storage _profiles,
        mapping(string => address) storage _usernames
    ) external hasProfile(from, _profiles) {
        PseudoModifier.isFacadeCall(facadeProxyAddress, msg.sender);

        if (_usernames[profile.username] != address(0)) revert Errors.UsernameExist();
        if (bytes8(bytes(profile.username)) != 0x00) {
            delete (_usernames[_profiles[from].username]);
            _usernames[profile.username] = from;
            _profiles[from].username = profile.username;
        }

        _profiles[from].email = profile.email;
        _profiles[from].lensHandle = profile.lensHandle;
        _profiles[from].discordHandle = profile.discordHandle;
        _profiles[from].twitterHandle = profile.twitterHandle;
        _profiles[from].websiteUrl = profile.websiteUrl;

        emit ProfileUpdated(from, profile.username, block.timestamp);
    }

    /**
     * @notice Get the blacklist reason for address `_address`
     *
     * @param _address The profile's address to query
     * @param _blacklistedAddresses The addresses of all blacklisted addresses
     *
     * @return The blacklist reason
     */
    function getBlacklistReason(address _address, mapping(address => string) storage _blacklistedAddresses)
        external
        view
        returns (string memory)
    {
        if (bytes8(bytes(_blacklistedAddresses[_address])) == 0x00) revert Errors.NotBlacklisted();
        return _blacklistedAddresses[_address];
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
     *
     * @return `DataTypes.Profile` containing the profile data
     */
    function getProfileByUsername(
        string calldata username,
        mapping(string => address) storage _usernames,
        mapping(address => DataTypes.Profile) storage _profiles
    ) external view hasHandleExistence(_usernames, username) returns (DataTypes.Profile memory) {
        return _profiles[_usernames[username]];
    }
}
