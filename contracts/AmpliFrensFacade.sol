// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IAmpliFrensContribution} from "./interfaces/IAmpliFrensContribution.sol";
import {IAmpliFrensProfile} from "./interfaces/IAmpliFrensProfile.sol";
import {IAmpliFrensNFT} from "./interfaces/IAmpliFrensNFT.sol";
import {IAmpliFrensSBT} from "./interfaces/IAmpliFrensSBT.sol";
import {IAmpliFrensFacade} from "./interfaces/IAmpliFrensFacade.sol";
import {DataTypes} from "./libraries/types/DataTypes.sol";

/**
 * @title AmpliFrensFacade
 * @author Lucien Akchoté
 *
 * @notice Serves as the main entrypoint for the AmpliFrens project
 *
 * @dev Must be covered by a proxy contract as it is upgradeable
 */
contract AmpliFrensFacade is Initializable, PausableUpgradeable, AccessControlUpgradeable, IAmpliFrensFacade {
    IAmpliFrensContribution internal immutable contributions;
    IAmpliFrensProfile internal immutable profiles;
    IAmpliFrensNFT internal immutable nfts;
    IAmpliFrensSBT internal immutable sbts;

    constructor(
        IAmpliFrensContribution _contributions,
        IAmpliFrensProfile _profiles,
        IAmpliFrensNFT _nfts,
        IAmpliFrensSBT _sbts
    ) {
        contributions = _contributions;
        profiles = _profiles;
        nfts = _nfts;
        sbts = _sbts;
        _disableInitializers();
    }

    function initialize() public initializer {
        __Pausable_init();
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @inheritdoc IAmpliFrensFacade
    function checkUpkeep(bytes calldata checkData)
        external
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {}

    /// @inheritdoc IAmpliFrensFacade
    function performUpkeep(bytes calldata performData) external override whenNotPaused {}

    function balanceOfSoulboundTokens(address _address) external view override returns (uint256) {}

    function ownerOfSoulboundToken(uint256 token) external view override returns (address) {}

    function isValidSoulboundToken(uint256 tokenId) external view override returns (bool) {}

    function hasValidSoulboundToken(address owner) external view override returns (bool) {}

    function uriSoulboundTokenId(uint256 id) external override returns (string memory) {}

    function totalSoulboundTokens() external view override returns (uint256) {}

    function totalSoulboundHolders() external view override returns (uint256) {}

    function setSBTBaseURI(string calldata uri) external override onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControlUpgradeable, IAmpliFrensFacade)
        returns (bool)
    {}

    function createUserProfile(DataTypes.Profile calldata profile)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {}

    function getUserProfile(address _address) external override returns (DataTypes.Profile memory) {}

    function updateUserProfile(DataTypes.Profile calldata profile)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {}

    function deleteUserProfile(address _address) external override onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {}

    function blacklistUserProfile(address _address, bytes32 reason)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {
        profiles.blacklist(_address, reason);
    }

    function getProfileBlacklistReason(address _address) external view override returns (bytes32) {}

    function hasUserProfile(address _address) external view override returns (bool) {}

    function upvoteContribution(uint256 contributionId) external override onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {}

    function downvoteContribution(DataTypes.Contribution calldata contributionId)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {}

    function reportContribution(uint256 contributionId) external override onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {}

    function removeContribution(uint256 contributionId) external override onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {}

    function updateContribution(uint256 contributionId) external override onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {}

    function createContribution(DataTypes.Contribution calldata contribution)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {}

    function getContributions() external view override returns (DataTypes.Contribution[] memory) {}

    function todayBestContribution() external override returns (DataTypes.Contribution memory) {}

    function yesterdayBestContribution() external override returns (DataTypes.Contribution memory) {}

    function resetContributions() external override onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {}

    function mintNft(address to, string memory uri) external override onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {}

    function uriNftId(uint256 id) external override returns (string memory) {}

    function setNFTBaseURI(string calldata uri) external override onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {}

    function setGlobalNFTRoyalties(address receiver, uint96 feeNumerator) external override whenNotPaused {}

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {}

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {}
}
