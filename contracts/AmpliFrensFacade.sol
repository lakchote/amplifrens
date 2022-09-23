// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
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
contract AmpliFrensFacade is Initializable, PausableUpgradeable, AccessControlUpgradeable, IERC165, IAmpliFrensFacade {
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
    function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData) {}

    /// @inheritdoc IAmpliFrensFacade
    function performUpkeep(bytes calldata performData) external whenNotPaused {}

    /// @inheritdoc IAmpliFrensFacade
    function setSBTBaseURI(string calldata uri) external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {}

    /// @inheritdoc IAmpliFrensFacade
    function createUserProfile(DataTypes.Profile calldata profile) external whenNotPaused {}

    /// @inheritdoc IAmpliFrensFacade
    function updateUserProfile(DataTypes.Profile calldata profile) external whenNotPaused {}

    /// @inheritdoc IAmpliFrensFacade
    function deleteUserProfile(address _address) external whenNotPaused {}

    /// @inheritdoc IAmpliFrensFacade
    function blacklistUserProfile(address _address, bytes32 reason)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {
        profiles.blacklist(_address, reason);
    }

    /// @inheritdoc IAmpliFrensFacade
    function upvoteContribution(uint256 contributionId) external whenNotPaused {}

    /// @inheritdoc IAmpliFrensFacade
    function downvoteContribution(DataTypes.Contribution calldata contributionId)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {}

    /// @inheritdoc IAmpliFrensFacade
    function removeContribution(uint256 contributionId) external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {}

    /// @inheritdoc IAmpliFrensFacade
    function updateContribution(uint256 contributionId, DataTypes.Contribution calldata contribution)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {}

    /// @inheritdoc IAmpliFrensFacade
    function createContribution(DataTypes.Contribution calldata contribution)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {}

    /// @inheritdoc IAmpliFrensFacade
    function resetContributions() external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {}

    /// @inheritdoc IAmpliFrensFacade
    function mintNft(address to, string memory uri) external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {}

    /// @inheritdoc IAmpliFrensFacade
    function setNFTBaseURI(string calldata uri) external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {}

    /// @inheritdoc IAmpliFrensFacade
    function setNFTGlobalRoyalties(address receiver, uint96 feeNumerator) external whenNotPaused {}

    /// @inheritdoc IAmpliFrensFacade
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {}

    /// @inheritdoc IAmpliFrensFacade
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {}

    /// @inheritdoc IAmpliFrensFacade
    function uriSBT(uint256 id) external view returns (string memory) {}

    /// @inheritdoc IAmpliFrensFacade
    function getUserProfile(address _address) external view returns (DataTypes.Profile memory) {}

    /// @inheritdoc IAmpliFrensFacade
    function getContribution(uint256 contributionId) external view returns (DataTypes.Contribution memory) {}

    /// @inheritdoc IAmpliFrensFacade
    function uriNft(uint256 id) external view returns (string memory) {}

    /// @inheritdoc IAmpliFrensFacade
    function balanceOfSBT(address _address) external view returns (uint256) {}

    /// @inheritdoc IAmpliFrensFacade
    function ownerOfSBT(uint256 token) external view returns (address) {}

    /// @inheritdoc IAmpliFrensFacade
    function idSBTOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {}

    /// @inheritdoc IAmpliFrensFacade
    function getSBTById(uint256 id) external view returns (DataTypes.Contribution memory) {}

    /// @inheritdoc IAmpliFrensFacade
    function isMintingIntervalMet() external view returns (bool) {}

    /// @inheritdoc IAmpliFrensFacade
    function totalSBTs() external view returns (uint256) {}

    /// @inheritdoc IAmpliFrensFacade
    function totalSBTHolders() external view returns (uint256) {}

    /// @inheritdoc IAmpliFrensFacade
    function getProfileBlacklistReason(address _address) external view returns (bytes32) {}

    /// @inheritdoc IAmpliFrensFacade
    function hasUserProfile(address _address) external view returns (bool) {}

    /// @inheritdoc IAmpliFrensFacade
    function getContributions() external view returns (DataTypes.Contribution[] memory) {}

    /// @inheritdoc IAmpliFrensFacade
    function topContribution() external view returns (DataTypes.Contribution memory) {}

    /// @inheritdoc IAmpliFrensFacade
    function totalContributions() external view returns (uint256) {}

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override(AccessControlUpgradeable, IERC165)
        returns (bool)
    {
        return
            type(IAmpliFrensSBT).interfaceId == interfaceId ||
            type(IERC165).interfaceId == interfaceId ||
            type(IAccessControlUpgradeable).interfaceId == interfaceId;
    }
}
