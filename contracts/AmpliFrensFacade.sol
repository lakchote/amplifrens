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
    IAmpliFrensContribution internal immutable _contribution;
    IAmpliFrensProfile internal immutable _profile;
    IAmpliFrensNFT internal immutable _nft;
    IAmpliFrensSBT internal immutable _sbt;

    /// @dev Contract initialization with interfaces of the subsystem
    constructor(
        IAmpliFrensContribution contribution,
        IAmpliFrensProfile profile,
        IAmpliFrensNFT nft,
        IAmpliFrensSBT sbt
    ) {
        _contribution = contribution;
        _profile = profile;
        _nft = nft;
        _sbt = sbt;
    }

    /**
     * @notice Initialize the implementation and grant the admin role to `adminAddress`
     *
     * @dev To be called by the proxy
     * @param adminAddress The address to grant the admin role
     */
    function initialize(address adminAddress) public initializer {
        __Pausable_init();
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, adminAddress);
    }

    /// @inheritdoc IAmpliFrensFacade
    function mintSBT(DataTypes.Contribution calldata contribution) external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        _sbt.mint(contribution);
    }

    /// @inheritdoc IAmpliFrensFacade
    function setSBTBaseURI(string calldata uri) external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        _sbt.setBaseURI(uri);
    }

    /// @inheritdoc IAmpliFrensFacade
    function createUserProfile(DataTypes.Profile calldata profile) external whenNotPaused {
        _profile.createProfile(profile);
    }

    /// @inheritdoc IAmpliFrensFacade
    function updateUserProfile(DataTypes.Profile calldata profile) external whenNotPaused {
        _profile.updateProfile(profile);
    }

    /// @inheritdoc IAmpliFrensFacade
    function deleteUserProfile(address _address) external whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        _profile.deleteProfile(_address);
    }

    /// @inheritdoc IAmpliFrensFacade
    function blacklistUserProfile(address _address, string calldata reason)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {
        _profile.blacklist(_address, reason);
    }

    /// @inheritdoc IAmpliFrensFacade
    function upvoteContribution(uint256 contributionId) external whenNotPaused {
        _contribution.upvote(contributionId);
    }

    /// @inheritdoc IAmpliFrensFacade
    function downvoteContribution(uint256 contributionId) external whenNotPaused {
        _contribution.downvote(contributionId);
    }

    /// @inheritdoc IAmpliFrensFacade
    function removeContribution(uint256 contributionId) external whenNotPaused {
        _contribution.remove(contributionId);
    }

    /// @inheritdoc IAmpliFrensFacade
    function updateContribution(uint256 contributionId, DataTypes.Contribution calldata contribution)
        external
        whenNotPaused
    {
        _contribution.update(contributionId, contribution.category, contribution.title, contribution.url);
    }

    /// @inheritdoc IAmpliFrensFacade
    function createContribution(DataTypes.Contribution calldata contribution) external whenNotPaused {
        _contribution.create(contribution.category, contribution.title, contribution.url);
    }

    /// @inheritdoc IAmpliFrensFacade
    function resetContributions() external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        _contribution.reset();
    }

    /// @inheritdoc IAmpliFrensFacade
    function mintNFT(address to, string memory uri) external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        _nft.mint(to, uri);
    }

    /// @inheritdoc IAmpliFrensFacade
    function transferNFT(
        address from,
        address to,
        uint256 tokenId
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _nft.transferNFT(from, to, tokenId);
    }

    /// @inheritdoc IAmpliFrensFacade
    function setNFTBaseURI(string calldata uri) external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        _nft.setBaseURI(uri);
    }

    /// @inheritdoc IAmpliFrensFacade
    function setNFTGlobalRoyalties(address receiver, uint96 feeNumerator)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {
        _nft.setDefaultRoyalty(receiver, feeNumerator);
    }

    /// @inheritdoc IAmpliFrensFacade
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /// @inheritdoc IAmpliFrensFacade
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /// @inheritdoc IAmpliFrensFacade
    function uriSBT(uint256 id) external view returns (string memory) {
        return _sbt.tokenURI(id);
    }

    /// @inheritdoc IAmpliFrensFacade
    function getUserProfile(address _address) external view returns (DataTypes.Profile memory) {
        return _profile.getProfile(_address);
    }

    /// @inheritdoc IAmpliFrensFacade
    function getContribution(uint256 contributionId) external view returns (DataTypes.Contribution memory) {
        return _contribution.getContribution(contributionId);
    }

    /// @inheritdoc IAmpliFrensFacade
    function uriNft(uint256 id) external view returns (string memory) {
        return _nft.tokenURI(id);
    }

    /// @inheritdoc IAmpliFrensFacade
    function balanceOfSBT(address _address) external view returns (uint256) {
        return _sbt.balanceOf(_address);
    }

    /// @inheritdoc IAmpliFrensFacade
    function ownerOfSBT(uint256 token) external view returns (address) {
        return _sbt.ownerOf(token);
    }

    /// @inheritdoc IAmpliFrensFacade
    function idSBTOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        return _sbt.tokenOfOwnerByIndex(owner, index);
    }

    /// @inheritdoc IAmpliFrensFacade
    function getSBTById(uint256 id) external view returns (DataTypes.Contribution memory) {
        return _sbt.tokenById(id);
    }

    /// @inheritdoc IAmpliFrensFacade
    function totalSBTs() external view returns (uint256) {
        return _sbt.emittedCount();
    }

    /// @inheritdoc IAmpliFrensFacade
    function totalSBTHolders() external view returns (uint256) {
        return _sbt.holdersCount();
    }

    /// @inheritdoc IAmpliFrensFacade
    function getProfileBlacklistReason(address _address) external view returns (string memory) {
        return _profile.getBlacklistReason(_address);
    }

    /// @inheritdoc IAmpliFrensFacade
    function hasUserProfile(address _address) external view returns (bool) {
        return _profile.hasProfile(_address);
    }

    /// @inheritdoc IAmpliFrensFacade
    function totalContributions() external view returns (uint256) {
        return _contribution.contributionsCount();
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override(AccessControlUpgradeable, IERC165)
        returns (bool)
    {
        return
            type(IAmpliFrensFacade).interfaceId == interfaceId ||
            type(IERC165).interfaceId == interfaceId ||
            type(IAccessControlUpgradeable).interfaceId == interfaceId;
    }
}
