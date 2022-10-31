// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import {DataTypes} from "../libraries/types/DataTypes.sol";

/**
 * @title IAmpliFrensSBT
 * @author Lucien Akchoté
 *
 * @notice Base interface for EIP-4671 Metadata
 *
 * More details on https://eips.ethereum.org/EIPS/eip-4671
 */
interface IAmpliFrensSBT {
    /**
     *  @notice Event emitted when a token `tokenId` is minted for `owner`
     */
    event SBTMinted(address indexed owner, uint256 indexed tokenId, uint256 timestamp);

    /**
     *  @notice Event emitted when token `tokenId` of `owner` is revoked
     */
    event SBTRevoked(address indexed owner, uint256 indexed tokenId, uint256 timestamp);

    /**
     * @notice Event that is emitted when a SBT for a top contribution is minted
     *
     * @param topContributionId The ID of the contribution of the day
     * @param from The address who created the contribution
     * @param timestamp The time of the creation
     */
    event SBTBestContribution(uint256 topContributionId, address indexed from, uint256 timestamp);

    /**
     * @notice Mints the Soulbound Token to recipient `DataTypes.TopContribution.author`
     *
     * @param contribution Contribution of the day data contained in struct `DataTypes.TopContribution`
     */
    function mint(DataTypes.TopContribution calldata contribution) external;

    /**
     * @notice Revoke the token id `tokenId` in case of abuse or error
     *
     * @param tokenId The token ID to revoke
     * @param from  The address `from` who initiated the transaction
     */
    function revoke(uint256 tokenId, address from) external;

    /**
     * @notice Count all valid tokens assigned to an owner
     *
     * @param owner Address for whom to query the balance
     * @return Number of tokens owned by `owner`
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @notice Check if minting interval has been met
     *
     * @return True or false
     */
    function isMintingIntervalMet() external view returns (bool);

    /**
     * @notice Get the owner of the token with id `tokenId`
     *
     * @param tokenId Identifier of the token
     * @return Address of the owner of `tokenId`
     */
    function ownerOf(uint256 tokenId) external view returns (address);

    /**
     * @notice Check if the token with id `tokenId` hasn't been revoked
     *
     * @param tokenId Identifier of the token
     * @return True if the token is valid, false otherwise
     */
    function isValid(uint256 tokenId) external view returns (bool);

    /**
     * @notice Check if an address owns a valid token in the contract
     *
     * @param owner Address for whom to check the ownership
     * @return True if `owner` has a valid token, false otherwise
     */
    function hasValid(address owner) external view returns (bool);

    /// @return emittedCount Number of tokens emitted
    function emittedCount() external view returns (uint256);

    /// @return holdersCount Number of token holders
    function holdersCount() external view returns (uint256);

    /**
     * @notice Get the id of a token using its position in the owner's list
     *
     * @param owner Address for whom to get the token
     * @param index Index of the token
     * @return tokenId of the token
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @notice Get the contribution associated with token of id `id`
     *
     * @param id The token id
     * @return Contribution of type `DataTypes.Contribution`
     */
    function tokenById(uint256 id) external view returns (DataTypes.Contribution memory);

    /**
     * @notice Get a tokenId by it's index, where 0 <= index < total()
     *
     * @param index Index of the token
     * @return tokenId of the token
     */
    function tokenByIndex(uint256 index) external view returns (uint256);

    /// @return Descriptive name of the tokens in this contract
    function name() external view returns (string memory);

    /// @return An abbreviated name of the tokens in this contract
    function symbol() external view returns (string memory);

    /**
     * @notice URI to query to get the token's metadata
     *
     * @param tokenId Identifier of the token
     * @return URI for the token
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    /**
     * @notice Get the contribution status for address `_address`
     *
     * @param _address The address to retrieve contribution status
     */
    function getStatus(address _address) external view returns (DataTypes.FrenStatus);

    /**
     * @notice Set the base URI `uri` for tokens, it should end with a "/"
     *
     * @param uri The new base URI
     * @param from  The address `from` who initiated the transaction
     */
    function setBaseURI(string calldata uri, address from) external;
}
