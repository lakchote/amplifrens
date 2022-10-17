// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import {DataTypes} from "../types/DataTypes.sol";
import {Errors} from "../helpers/Errors.sol";
import {PseudoModifier} from "../guards/PseudoModifier.sol";
import {TokenURI} from "../helpers/TokenURI.sol";

/**
 * @title SBTLogic
 * @author Lucien Akchoté
 *
 * @notice A library that implements the logic of soulbound token (SBT) related functions
 */
library SBTLogic {
    using Counters for Counters.Counter;

    /// @dev See `IAmpliFrensSBT` for descriptions
    event SBTMinted(address indexed owner, uint256 indexed tokenId, uint256 timestamp);
    event SBTRevoked(address indexed owner, uint256 indexed tokenId, uint256 timestamp);
    event SBTBestContribution(
        address indexed from,
        uint256 timestamp,
        DataTypes.ContributionCategory category,
        string title,
        string url
    );

    /**
     * @notice Mints the Soulbound Token to recipient `DataTypes.Contribution.author`
     *
     * @param from  The address `from` who initiated the transaction
     * @param facadeProxyAddress The facade's proxy address `facadeProxyAddress`
     * @param contribution Contribution of the day data contained in struct `DataTypes.Contribution`
     * @param _tokens The total soulbound tokens mapped to contributions
     * @param _tokensForAddress The total tokens by addresses
     * @param _validTokensForAddress Counter of valid tokens for addresses
     * @param mintingParams Container with related minting parameters to comply with
     * @param _tokenIdCounter Number of tokens emitted
     * @param _holdersCounter Number of different token holders
     */
    function mint(
        address from,
        address facadeProxyAddress,
        DataTypes.Contribution calldata contribution,
        mapping(uint256 => DataTypes.Contribution) storage _tokens,
        mapping(address => uint256[]) storage _tokensForAddress,
        mapping(address => uint256) storage _validTokensForAddress,
        DataTypes.MintingInterval storage mintingParams,
        Counters.Counter storage _tokenIdCounter,
        Counters.Counter storage _holdersCounter
    ) external {
        PseudoModifier.isFacadeCall(facadeProxyAddress, from);

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
            contribution.dayCounter,
            contribution.title,
            contribution.url
        );

        if (_tokensForAddress[contribution.author].length == 0) {
            _holdersCounter.increment();
        }

        _tokensForAddress[contribution.author].push(currentTokenId);
        _validTokensForAddress[contribution.author] += 1;
        mintingParams.lastBlockTimestamp = block.timestamp;

        emit SBTMinted(contribution.author, currentTokenId, block.timestamp);
        emit SBTBestContribution(
            contribution.author,
            block.timestamp,
            contribution.category,
            contribution.title,
            contribution.url
        );
    }

    /**
     * @notice Revoke the token id `tokenId` in case of abuse or error
     *
     * @param tokenId The token ID to revoke
     * @param from  The address `from` who initiated the transaction
     * @param adminAddress The admin's address
     * @param _tokenIdCounter Number of tokens emitted
     * @param _tokens The total soulbound tokens mapped to contributions
     * @param _validTokensForAddress Counter of valid tokens for addresses
     */
    function revoke(
        uint256 tokenId,
        address from,
        address adminAddress,
        Counters.Counter storage _tokenIdCounter,
        mapping(uint256 => DataTypes.Contribution) storage _tokens,
        mapping(address => uint256) storage _validTokensForAddress
    ) external {
        PseudoModifier.addressEq(adminAddress, from);
        PseudoModifier.isNotOutOfBounds(tokenId, _tokenIdCounter);
        _tokens[tokenId].valid = false;
        _validTokensForAddress[_tokens[tokenId].author] -= 1;

        emit SBTRevoked(_tokens[tokenId].author, tokenId, block.timestamp);
    }

    /**
     * @notice Set the base URI for the tokens
     *
     * @param uriStorage Container for URI data
     * @param uri The new base URI
     * @param from  The address `from` who initiated the transaction
     * @param adminAddress The admin's address
     */
    function setBaseURI(
        DataTypes.URIStorage storage uriStorage,
        string calldata uri,
        address from,
        address adminAddress
    ) external {
        PseudoModifier.addressEq(adminAddress, from);
        uriStorage.baseURI = uri;
    }

    /**
     * @notice Get the corresponding token id at index `index` for address `owner`
     *
     * @param owner The address to query the token id for
     * @param index The index to retrieve
     * @param _tokenIdCounter Number of tokens emitted
     * @param _tokensForAddress The total tokens by addresses
     *
     * @return The token id
     */
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index,
        Counters.Counter storage _tokenIdCounter,
        mapping(address => uint256[]) storage _tokensForAddress
    ) external view returns (uint256) {
        PseudoModifier.isNotOutOfBounds(index, _tokenIdCounter);

        uint256[] memory tokenIds = _tokensForAddress[owner];

        return tokenIds[index];
    }

    /**
     * @notice Gets the token URI for token with id `tokenId`
     *
     * @param baseURI The current base URI
     * @param tokenId The token id to retrieve the URI
     * @param _tokenIdCounter Number of tokens emitted
     *
     * @return uri The Token URI
     */
    function tokenURI(
        string calldata baseURI,
        uint256 tokenId,
        Counters.Counter storage _tokenIdCounter
    ) external view returns (string memory uri) {
        PseudoModifier.isNotOutOfBounds(tokenId, _tokenIdCounter);

        uri = TokenURI.concatBaseURITokenIdJsonExt(tokenId, baseURI);
    }

    /**
     * @notice Get the owner of the token with id `tokenId`
     *
     * @param tokenId Identifier of the token
     * @param _tokenIdCounter Number of tokens emitted
     * @param _tokens The total soulbound tokens mapped to contributions
     *
     * @return Address of the owner of `tokenId`
     */
    function ownerOf(
        uint256 tokenId,
        Counters.Counter storage _tokenIdCounter,
        mapping(uint256 => DataTypes.Contribution) storage _tokens
    ) external view returns (address) {
        PseudoModifier.isNotOutOfBounds(tokenId, _tokenIdCounter);

        return _tokens[tokenId].author;
    }

    /**
     * @notice Check if the token with id `tokenId` hasn't been revoked
     *
     * @param tokenId Identifier of the token
     * @param _tokenIdCounter Number of tokens emitted
     * @param _tokens The total soulbound tokens mapped to contributions
     *
     * @return True if the token is valid, false otherwise
     */
    function isValid(
        uint256 tokenId,
        Counters.Counter storage _tokenIdCounter,
        mapping(uint256 => DataTypes.Contribution) storage _tokens
    ) external view returns (bool) {
        PseudoModifier.isNotOutOfBounds(tokenId, _tokenIdCounter);

        return _tokens[tokenId].valid;
    }

    /**
     * @notice Get the contribution associated with the token of id `tokenId`
     *
     * @param tokenId Identifier of the token
     * @param _tokenIdCounter Number of tokens emitted
     * @param _tokens The total soulbound tokens mapped to contributions
     *
     * @return Contribution of type `DataTypes.Contribution`
     */
    function tokenById(
        uint256 tokenId,
        Counters.Counter storage _tokenIdCounter,
        mapping(uint256 => DataTypes.Contribution) storage _tokens
    ) external view returns (DataTypes.Contribution memory) {
        PseudoModifier.isNotOutOfBounds(tokenId, _tokenIdCounter);

        return _tokens[tokenId];
    }

    /**
     * @notice Check if minting interval is met to mint SBT tokens
     *
     * @param lastBlockTimestamp The last block's timestamp at the time of the mint or at contract initialization
     * @param mintInterval The delay to enforce
     *
     * @return True or false
     */
    function isMintingIntervalMet(uint256 lastBlockTimestamp, uint256 mintInterval) internal view returns (bool) {
        return block.timestamp - lastBlockTimestamp > mintInterval;
    }
}
