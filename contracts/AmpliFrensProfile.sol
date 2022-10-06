// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
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
contract AmpliFrensProfile is IERC165, IAmpliFrensProfile {
    using Counters for Counters.Counter;

    mapping(address => DataTypes.Profile) private _profiles;
    mapping(string => address) private _usernames;
    mapping(address => string) private _blacklistedAddresses;

    Counters.Counter public profilesCount;

    address public immutable facadeProxy;

    /// @dev Contract initialization with facade's proxy address precomputed
    constructor(address _facadeProxy) {
        facadeProxy = _facadeProxy;
    }

    /// @inheritdoc IAmpliFrensProfile
    function blacklist(address _address, string calldata reason) external {
        PseudoModifier.addressEq(facadeProxy, msg.sender);
        ProfileLogic.blackList(_address, reason, _blacklistedAddresses, _profiles, profilesCount);
    }

    /// @inheritdoc IAmpliFrensProfile
    function createProfile(DataTypes.Profile calldata profile) external {
        ProfileLogic.createProfile(profile, _profiles, _usernames, profilesCount);
    }

    /// @inheritdoc IAmpliFrensProfile
    function deleteProfile(address _address) external {
        ProfileLogic.deleteProfile(_address, _profiles, profilesCount);
    }

    /// @inheritdoc IAmpliFrensProfile
    function updateProfile(DataTypes.Profile calldata profile) external {
        ProfileLogic.updateProfile(profile, _profiles, _usernames);
    }

    /// @inheritdoc IAmpliFrensProfile
    function getBlacklistReason(address _address) external view returns (string memory reason) {
        reason = ProfileLogic.getBlacklistReason(_address, _blacklistedAddresses);
    }

    /// @inheritdoc IAmpliFrensProfile
    function getProfile(address _address) external view returns (DataTypes.Profile memory profile) {
        profile = ProfileLogic.getProfile(_address, _profiles);
    }

    /// @inheritdoc IAmpliFrensProfile
    function getProfileByUsername(string calldata username) external view returns (DataTypes.Profile memory profile) {
        profile = ProfileLogic.getProfileByUsername(username, _usernames, _profiles);
    }

    /// @inheritdoc IAmpliFrensProfile
    function hasProfile(address _address) external view returns (bool) {
        return _profiles[_address].valid;
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure override(IERC165) returns (bool) {
        return type(IAmpliFrensProfile).interfaceId == interfaceId || type(IERC165).interfaceId == interfaceId;
    }
}
