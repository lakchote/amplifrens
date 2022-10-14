// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IAmpliFrensProfile} from "./interfaces/IAmpliFrensProfile.sol";
import {DataTypes} from "./libraries/types/DataTypes.sol";
import {ProfileLogic} from "./libraries/logic/ProfileLogic.sol";

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

    address private immutable adminAddress;
    address private immutable facadeProxyAddress;

    /// @dev Contract initialization
    constructor(address _adminAddress, address _facadeProxyAddress) {
        adminAddress = _adminAddress;
        facadeProxyAddress = _facadeProxyAddress;
    }

    /// @inheritdoc IAmpliFrensProfile
    function blacklist(
        address _address,
        address from,
        string calldata reason
    ) external {
        ProfileLogic.blackList(
            _address,
            from,
            adminAddress,
            facadeProxyAddress,
            reason,
            _blacklistedAddresses,
            _profiles,
            profilesCount
        );
    }

    /// @inheritdoc IAmpliFrensProfile
    function createProfile(DataTypes.Profile calldata profile, address from) external {
        ProfileLogic.createProfile(profile, from, facadeProxyAddress, _profiles, _usernames, profilesCount);
    }

    /// @inheritdoc IAmpliFrensProfile
    function deleteProfile(address _address, address from) external {
        ProfileLogic.deleteProfile(_address, from, adminAddress, facadeProxyAddress, _profiles, profilesCount);
    }

    /// @inheritdoc IAmpliFrensProfile
    function updateProfile(DataTypes.Profile calldata profile, address from) external {
        ProfileLogic.updateProfile(profile, from, facadeProxyAddress, _profiles, _usernames);
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
