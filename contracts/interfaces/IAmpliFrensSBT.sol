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
    event Minted(address owner, uint256 tokenId);

    /**
     *  @notice Event emitted when token `tokenId` of `owner` is revoked
     */
    event Revoked(address owner, uint256 tokenId);

    /**
     * @notice Mints the Soulbound Token to recipient `DataTypes.Contribution.author`
     *
     * @param contribution Contribution of the day data contained in struct `DataTypes.Contribution`
     */
    function mint(DataTypes.Contribution calldata contribution) external;

    /**
     * @notice Revoke the token id `tokenId` in case of abuse or error
     *
     * @param tokenId The token ID to revoke
     */
    function revoke(uint256 tokenId) external;

    /**
     * @notice Get the total tokens for address `_address`
     *
     * @param _address The address to get tokens length
     * @return Number of tokens for address `_address`
     */
    function totalTokensForAddress(address _address) external view returns (uint256);

    /**
     * @notice Count all tokens assigned to an owner
     *
     * @param owner Address for whom to query the balance
     * @return Number of tokens owned by `owner`
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @notice Get owner of a token
     *
     * @param tokenId Identifier of the token
     * @return Address of the owner of `tokenId`
     */
    function ownerOf(uint256 tokenId) external view returns (address);

    /**
     * @notice Check if a token hasn't been revoked
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
     * @notice Get the tokenId of a token using its position in the owner's list
     *
     * @param owner Address for whom to get the token
     * @param index Index of the token
     * @return tokenId of the token
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

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
     * @dev Return true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
