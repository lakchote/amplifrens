// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import {DataTypes} from "../libraries/types/DataTypes.sol";

/**
 * @title IAmpliFrensHub
 * @author Lucien Akchoté
 *
 * @notice Interface for the main entrypoint of the contract
 */
interface IAmpliFrensFacade {
    /**
     * //////////////////////////////////////////////////
     * @dev Start of Keeper (cron-like) related functions
     * //////////////////////////////////////////////////
     *
     *  @notice Check if automated minting of soulbound tokens
     *  for the contribution of the day needs to be done
     *
     *  @dev Used by Chainlink Keeper to know if keeper needs to be triggered
     */
    function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

    /**
     *  @notice Perform the automated minting of soulbound tokens
     *  for the contribution of the day
     *
     *  @dev Used by Chainlink Keeper to perform cron logic
     *  (in our case: automated minting of soulbound tokens)
     */
    function performUpkeep(bytes calldata performData) external;

    /**
     * /////////////////////////////////////////////////////
     * @dev Start of Soulbound token (SBT) related functions
     * /////////////////////////////////////////////////////
     *
     * @notice Set the Soulbound token base URI
     *
     * @param uri The new base uri for the Soulbound tokens
     */
    function setSBTBaseURI(string calldata uri) external;

    /**
     * @notice Get the contribution associated with token of id `id`
     *
     * @param id The token id
     * @return Contribution of type `DataTypes.Contribution`
     */
    function getSBTById(uint256 id) external view returns (DataTypes.Contribution memory);

    /// @return emittedCount Number of soulbound tokens emitted
    function totalSBTs() external view returns (uint256);

    /// @return holdersCount Number of token holders
    function totalSBTHolders() external view returns (uint256);

    /**
     * @notice Check if minting interval has been met
     *
     * @return True or false
     */
    function isMintingIntervalMet() external view returns (bool);

    /**
     * @notice Get the URI of Soulbound token with id `id`
     *
     * @param id The id of the Soulbound token to query URI for
     *
     * @return The NFT's URI
     */
    function uriSBT(uint256 id) external view returns (string memory);

    /**
     * @notice Count all valid soulbound tokens assigned to an owner
     *
     * @param _address Address for whom to query the balance
     * @return Number of tokens owned by `owner`
     */
    function balanceOfSBT(address _address) external view returns (uint256);

    /**
     * @notice Get the owner of a soulbound oken
     *
     * @param token Identifier of the token
     * @return Address of the owner of `tokenId`
     */
    function ownerOfSBT(uint256 token) external view returns (address);

    /**
     * @notice Get the id of a token with the index `index` in the owner's list
     *
     * @param owner Address for whom to get the token
     * @param index Index of the token
     * @return tokenId of the token
     */
    function idSBTOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * ///////////////////////////////////////
     * @dev Start of profile related functions
     * ///////////////////////////////////////
     *
     * @notice Create a profile for address `msg.sender`
     *
     * @param profile `DataTypes.Profile` containing the profile data
     */
    function createUserProfile(DataTypes.Profile calldata profile) external;

    /**
     * @notice Update the profile of address `msg.sender`
     *
     * @param profile `DataTypes.Profile` containing the profile data
     */
    function updateUserProfile(DataTypes.Profile calldata profile) external;

    /**
     * @notice Delete the profile of address `_address`
     *
     * @param _address The address's profile to delete
     */
    function deleteUserProfile(address _address) external;

    /**
     * @notice Blacklist a profile with address `_address`
     *
     * @param _address The profile's address to blacklist
     * @param reason The reason of the blacklist
     */
    function blacklistUserProfile(address _address, bytes32 reason) external;

    /**
     * @notice Get the profile if applicable for address `_address`
     *
     * @return `DataTypes.Profile` data
     */
    function getUserProfile(address _address) external view returns (DataTypes.Profile memory);

    /**
     * @notice Get the blacklist reason for address `_address`
     *
     * @param _address The profile's address to query
     * @return The reason of the blacklist
     */
    function getProfileBlacklistReason(address _address) external view returns (bytes32);

    /**
     * @notice Check if address `_address` has a profile
     *
     * @return True or false
     */
    function hasUserProfile(address _address) external view returns (bool);

    /**
     * ////////////////////////////////////////////
     * @dev Start of contribution related functions
     * ////////////////////////////////////////////
     *
     * @notice Upvote the contribution with id `contributionId`
     *
     * @param contributionId The contribution to upvote
     */
    function upvoteContribution(uint256 contributionId) external;

    /**
     * @notice Downvote the contribution with id `contributionId`
     *
     * @param contributionId The contribution id to downvote
     */
    function downvoteContribution(DataTypes.Contribution calldata contributionId) external;

    /**
     * @notice Post the contribution with id `contributionId`
     *
     * @param contribution Contribution containing data of type `DataTypes.Contribution`
     */
    function createContribution(DataTypes.Contribution calldata contribution) external;

    /**
     * @notice Remove the contribution with id `contributionId`
     *
     * @param contributionId The contribution id to upvote
     */
    function removeContribution(uint256 contributionId) external;

    /**
     * @notice Update the contribution with id `contributionId`
     *
     * @param contributionId The contribution id to update
     * @param contribution The updated contribution data
     */
    function updateContribution(uint256 contributionId, DataTypes.Contribution calldata contribution) external;

    /// @notice Reset the contributions
    function resetContributions() external;

    /**
     * @notice Get the total contributions
     *
     * @return Total contributions of type `DataTypes.Contribution`
     */
    function getContributions() external view returns (DataTypes.Contribution[] memory);

    /**
     * @notice Get the contribution with id `contributionId`
     *
     * @param contributionId The id of the contribution to retrieve
     * @return Contribution with id `contributionId` of type `DataTypes.Contribution`
     */
    function getContribution(uint256 contributionId) external view returns (DataTypes.Contribution memory);

    /**
     * @notice Get today's most upvoted contribution
     *
     * @return `DataTypes.Contribution`
     */
    function topContribution() external view returns (DataTypes.Contribution memory);

    /**
     * @notice Return the total number of contributions
     *
     * @return Number of contributions
     */
    function totalContributions() external view returns (uint256);

    /**
     * ///////////////////////////////////
     * @dev Start of NFT related functions
     * ///////////////////////////////////
     *
     * @notice Mint an NFT for address `to`
     *
     * @param to The address to mint the NFT
     * @param uri The URI of the NFT
     */
    function mintNft(address to, string memory uri) external;

    /**
     * @notice Set the NFT base URI
     *
     * @param uri The new base uri for the NFTs
     */
    function setNFTBaseURI(string calldata uri) external;

    /**
     * @notice Set the default royalty for entire NFT collection
     *
     * @dev Warning : not enforceable, it depends on the exchange policies where NFTs are traded
     *
     * @param receiver The address to receive royalty fees
     * @param feeNumerator The royalty fee
     */
    function setNFTGlobalRoyalties(address receiver, uint96 feeNumerator) external;

    /**
     * @notice Get the URI of NFT with id `id`
     *
     * @param id The id of the NFT to get the URI for
     *
     * @return The NFT's URI
     */
    function uriNft(uint256 id) external view returns (string memory);

    /**
     * //////////////////////////////////////////////////
     * @dev Start of contract lifecycle related functions
     * //////////////////////////////////////////////////
     *
     *  @notice Pause critical functions
     */
    function pause() external;

    /**
     *  @notice Perform the automated minting of soulbound tokens for the contribution of the day
     */
    function unpause() external;
}
