// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import {DataTypes} from "../types/DataTypes.sol";

/**
 * @title SBTLogic
 * @author Lucien Akchoté
 *
 * @notice A library that implements the logic of soulbound token (SBT) related functions
 */
library SBTLogic {
    using Counters for Counters.Counter;

    /// @dev See `IAmpliFrensSBT` for descriptions
    event Minted(address indexed owner, uint256 indexed tokenId);
    event Revoked(address indexed owner, uint256 indexed tokenId);

    /**
     * @dev Check if the token index requested has been minted
     *
     * @param index The token id to verify existence for
     */
    modifier isNotOutOfBounds(uint256 index, Counters.Counter storage counter) {
        require(index <= counter.current() && index != 0, "Out of bounds");
        _;
    }

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
        require(
            (block.timestamp - mintingParams.lastBlockTimestamp) > mintingParams.mintInterval,
            "Minting interval not met"
        );

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

        emit Minted(contribution.author, currentTokenId);
    }

    /**
     * @notice Get the corresponding token id at index `index` for address `owner`
     *
     * @param owner The address to query the token id for
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
     * @notice Revoke the token id `tokenId` in case of abuse or error
     *
     * @param tokenId The token ID to revoke
     * @param _tokens The total soulbound tokens mapped to contributions
     * @param _validTokensForAddress Counter of valid tokens for addresses
     * @param _tokenIdCounter Number of tokens emitted
     */
    function revoke(
        uint256 tokenId,
        mapping(uint256 => DataTypes.Contribution) storage _tokens,
        mapping(address => uint256) storage _validTokensForAddress,
        Counters.Counter storage _tokenIdCounter
    ) external isNotOutOfBounds(tokenId, _tokenIdCounter) {
        _tokens[tokenId].valid = false;
        _validTokensForAddress[_tokens[tokenId].author] -= 1;
        emit Revoked(_tokens[tokenId].author, tokenId);
    }
}
