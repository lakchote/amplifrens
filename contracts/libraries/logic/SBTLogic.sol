// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import {DataTypes} from "../types/DataTypes.sol";
import {Errors} from "../helpers/Errors.sol";

/**
 * @title SBTLogic
 * @author Lucien Akchoté
 *
 * @notice A library that implements the logic of soulbound token (SBT) related functions
 */
library SBTLogic {
    using Counters for Counters.Counter;

    /// @dev See `IAmpliFrensSBT` for descriptions
    event Minted(address indexed owner, uint256 indexed tokenId, uint256 timestamp);
    event Revoked(address indexed owner, uint256 indexed tokenId, uint256 timestamp);

    /**
     * @notice Mints the Soulbound Token to recipient `DataTypes.Contribution.author`
     *
     * @param contribution Contribution of the day data contained in struct `DataTypes.Contribution`
     * @param _tokens The total soulbound tokens mapped to contributions
     * @param _tokensForAddress The total tokens by addresses
     * @param _validTokensForAddress Counter of valid tokens for addresses
     * @param mintingParams Container with related minting parameters to comply with
     * @param _tokenIdCounter Number of tokens emitted
     * @param _holdersCounter Number of different token holders
     */
    function mint(
        DataTypes.Contribution calldata contribution,
        mapping(uint256 => DataTypes.Contribution) storage _tokens,
        mapping(address => uint256[]) storage _tokensForAddress,
        mapping(address => uint256) storage _validTokensForAddress,
        DataTypes.MintingInterval storage mintingParams,
        Counters.Counter storage _tokenIdCounter,
        Counters.Counter storage _holdersCounter
    ) external {
        if (!isMintingIntervalMet(mintingParams.lastBlockTimestamp, mintingParams.mintInterval)) {
            revert Errors.MintingIntervalNotMet();
        }

        _tokenIdCounter.increment();
        uint256 currentTokenId = _tokenIdCounter.current();
        _tokens[currentTokenId] = DataTypes.Contribution(
            contribution.author,
            contribution.category,
            true, /// @dev contribution is valid by default
            contribution.timestamp,
            contribution.votes,
            contribution.title,
            contribution.url
        );

        if (_tokensForAddress[contribution.author].length == 0) {
            _holdersCounter.increment();
        }

        _tokensForAddress[contribution.author].push(currentTokenId);
        _validTokensForAddress[contribution.author] += 1;
        mintingParams.lastBlockTimestamp = block.timestamp;

        emit Minted(contribution.author, currentTokenId, block.timestamp);
    }

    /**
     * @notice Revoke the token id `tokenId` in case of abuse or error
     *
     * @param tokenId The token ID to revoke
     * @param _tokens The total soulbound tokens mapped to contributions
     * @param _validTokensForAddress Counter of valid tokens for addresses
     */
    function revoke(
        uint256 tokenId,
        mapping(uint256 => DataTypes.Contribution) storage _tokens,
        mapping(address => uint256) storage _validTokensForAddress
    ) external {
        _tokens[tokenId].valid = false;
        _validTokensForAddress[_tokens[tokenId].author] -= 1;
        emit Revoked(_tokens[tokenId].author, tokenId, block.timestamp);
    }

    /**
     * @notice Get the corresponding token id at index `index` for address `owner`
     *
     * @param owner The address to query the token id for
     * @param index The index to retrieve
     * @param _tokensForAddress The total tokens by addresses
     * @return The token id
     */
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index,
        mapping(address => uint256[]) storage _tokensForAddress
    ) external view returns (uint256) {
        uint256[] memory tokenIds = _tokensForAddress[owner];

        return tokenIds[index];
    }

    /**
     * @notice Get the owner of the token with id `tokenId`
     *
     * @param tokenId Identifier of the token
     * @param _tokens The total soulbound tokens mapped to contributions
     * @return Address of the owner of `tokenId`
     */
    function ownerOf(uint256 tokenId, mapping(uint256 => DataTypes.Contribution) storage _tokens)
        external
        view
        returns (address)
    {
        return _tokens[tokenId].author;
    }

    function isMintingIntervalMet(uint256 lastBlockTimestamp, uint256 mintInterval) internal view returns (bool) {
        return block.timestamp - lastBlockTimestamp > mintInterval;
    }

    /**
     * @notice Check if the token with id `tokenId` hasn't been revoked
     *
     * @param tokenId Identifier of the token
     * @param _tokens The total soulbound tokens mapped to contributions
     * @return True if the token is valid, false otherwise
     */
    function isValid(uint256 tokenId, mapping(uint256 => DataTypes.Contribution) storage _tokens)
        external
        view
        returns (bool)
    {
        return _tokens[tokenId].valid;
    }

    /**
     * @notice Get the contribution associated with the token of id `tokenId`
     *
     * @param tokenId Identifier of the token
     * @param _tokens The total soulbound tokens mapped to contributions
     * @return Contribution of type `DataTypes.Contribution`
     */
    function tokenById(uint256 tokenId, mapping(uint256 => DataTypes.Contribution) storage _tokens)
        external
        view
        returns (DataTypes.Contribution memory)
    {
        return _tokens[tokenId];
    }
}
