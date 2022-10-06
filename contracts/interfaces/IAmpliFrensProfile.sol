// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import {DataTypes} from "../libraries/types/DataTypes.sol";

/**
 * @title IAmpliFrensProfile
 * @author Lucien Akchoté
 *
 * @notice Handles the common use cases for interacting with profiles
 */
interface IAmpliFrensProfile {
    /**
     * @notice Event that is emitted when a profile is blacklisted
     *
     * @param _address The profile's address blacklisted
     * @param reason   The reason of the blacklist
     * @param timestamp The time when blacklisting occured
     */
    event ProfileBlacklisted(address _address, string indexed reason, uint256 timestamp);

    /**
     * @notice Event that is emitted when a profile is created
     *
     * @param _address The profile's address created
     * @param timestamp The time when profile creation occurred
     * @param username The time when profile creation occurred
     */
    event ProfileCreated(address indexed _address, uint256 timestamp, string username);

    /**
     * @notice Event that is emitted when a profile is updated
     *
     * @param _address The profile's address updated
     * @param timestamp The time when profile update occurred
     */
    event ProfileUpdated(address indexed _address, uint256 timestamp);

    /**
     * @notice Event that is emitted when a profile is deleted
     *
     * @param _address The profile's address deleted
     */
    event ProfileDeleted(address indexed _address, uint256 timestamp);

    /**
     * @notice Create a profile for address `msg.sender`
     *
     * @param profile `DataTypes.Profile` containing the profile data
     */
    function createProfile(DataTypes.Profile calldata profile) external;

    /**
     * @notice Update a profile for address `msg.sender`
     *
     * @param profile `DataTypes.Profile` containing the profile data
     */
    function updateProfile(DataTypes.Profile calldata profile) external;

    /**
     * @notice Delete the profile of address `_address`
     *
     * @param _address The address's profile to delete
     */
    function deleteProfile(address _address) external;

    /**
     * @notice Get a profile if applicable for address `_address`
     *
     * @return `DataTypes.Profile` data
     */
    function getProfile(address _address) external view returns (DataTypes.Profile memory);

    /**
     * @notice Blacklist a profile with address `_address` for reason `reason`
     *
     * @param _address The profile's address to blacklist
     * @param reason The reason of the blacklist
     */
    function blacklist(address _address, string calldata reason) external;

    /**
     * @notice Get the blacklist reason for address `_address`
     *
     * @param _address The profile's address to query
     * @return The reason of the blacklist
     */
    function getBlacklistReason(address _address) external view returns (string memory);

    /**
     * @notice Get a profile by its username `username`
     *
     * @return `DataTypes.Profile` containing the profile data
     */
    function getProfileByUsername(string calldata username) external view returns (DataTypes.Profile memory);

    /**
     * @notice Check if address `_address` has a profile
     *
     * @return True or false
     */
    function hasProfile(address _address) external view returns (bool);
}
