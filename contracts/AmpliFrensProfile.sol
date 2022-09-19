// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import {IAmpliFrensProfile} from "./interfaces/IAmpliFrensProfile.sol";
import {DataTypes} from "./libraries/types/DataTypes.sol";
import {ProfileLogic} from "./libraries/logic/ProfileLogic.sol";
import {PseudoModifier} from "./libraries/guards/PseudoModifier.sol";

/**
 * @title AmpliFrensProfile
 * @author Lucien Akchoté
 *
 * @notice Handles profile operations for AmpliFrens
 * @custom:security-contact lakchote@icloud.com
 */
contract AmpliFrensProfile is IAmpliFrensProfile {
    using Counters for Counters.Counter;

    mapping(address => DataTypes.Profile) private _profiles;
    mapping(bytes32 => address) private _usernames;
    mapping(bytes32 => address) private _discordHandles;
    mapping(bytes32 => address) private _twitterHandles;
    mapping(bytes32 => address) private _lensHandles;
    mapping(bytes32 => address) private _emails;
    mapping(address => bytes32) private _blacklistedAddresses;

    Counters.Counter public profilesCount;

    address public immutable facadeProxy;

    constructor(address _facadeProxy) {
        facadeProxy = _facadeProxy;
    }

    /// @inheritdoc IAmpliFrensProfile
    function blacklist(address _address, bytes32 reason) external {
        PseudoModifier.addressEq(facadeProxy, msg.sender);
        ProfileLogic.blackList(_address, reason, _blacklistedAddresses, _profiles, profilesCount);
    }

    /// @inheritdoc IAmpliFrensProfile
    function getBlacklistReason(address _address) external view returns (bytes32 reason) {
        reason = ProfileLogic.getBlacklistReason(_address, _blacklistedAddresses);
    }

    /// @inheritdoc IAmpliFrensProfile
    function createProfile(address _address, DataTypes.Profile calldata profile) external {
        PseudoModifier.addressEq(facadeProxy, msg.sender);
        ProfileLogic.createProfile(
            _address,
            profile,
            _profiles,
            _usernames,
            _emails,
            _discordHandles,
            _lensHandles,
            _twitterHandles,
            profilesCount
        );
    }

    /// @inheritdoc IAmpliFrensProfile
    function deleteProfile(address _address) external {
        PseudoModifier.addressEq(facadeProxy, msg.sender);
        ProfileLogic.deleteProfile(_address, _profiles, profilesCount);
    }

    /// @inheritdoc IAmpliFrensProfile
    function updateProfile(address _address, DataTypes.Profile calldata profile) external {
        PseudoModifier.addressEq(facadeProxy, msg.sender);
        ProfileLogic.updateProfile(
            _address,
            profile,
            _profiles,
            _usernames,
            _emails,
            _discordHandles,
            _lensHandles,
            _twitterHandles
        );
    }

    /// @inheritdoc IAmpliFrensProfile
    function getProfile(address _address) external view returns (DataTypes.Profile memory profile) {
        profile = ProfileLogic.getProfile(_address, _profiles);
    }

    /// @inheritdoc IAmpliFrensProfile
    function getProfileByUsername(bytes32 username) external view returns (DataTypes.Profile memory profile) {
        profile = ProfileLogic.getProfileByUsername(username, _usernames, _profiles);
    }

    /// @inheritdoc IAmpliFrensProfile
    function getProfileByEmail(bytes32 email) external view returns (DataTypes.Profile memory profile) {
        profile = ProfileLogic.getProfileByEmail(email, _emails, _profiles);
    }

    /// @inheritdoc IAmpliFrensProfile
    function getProfileByTwitterHandle(bytes32 twitterHandle) external view returns (DataTypes.Profile memory profile) {
        profile = ProfileLogic.getProfileByTwitterHandle(twitterHandle, _twitterHandles, _profiles);
    }

    /// @inheritdoc IAmpliFrensProfile
    function getProfileByDiscordHandle(bytes32 discordHandle) external view returns (DataTypes.Profile memory profile) {
        profile = ProfileLogic.getProfileByDiscordHandle(discordHandle, _discordHandles, _profiles);
    }

    /// @inheritdoc IAmpliFrensProfile
    function getProfileByLensHandle(bytes32 lensHandle) external view returns (DataTypes.Profile memory profile) {
        profile = ProfileLogic.getProfileByLensHandle(lensHandle, _lensHandles, _profiles);
    }

    /// @inheritdoc IAmpliFrensProfile
    function hasProfile(address _address) external view returns (bool) {
        return _profiles[_address].valid;
    }
}
