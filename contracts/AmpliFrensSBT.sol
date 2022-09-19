// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {SBTLogic} from "./libraries/logic/SBTLogic.sol";
import {PseudoModifier} from "./libraries/guards/PseudoModifier.sol";
import {IAmpliFrensSBT} from "./interfaces/IAmpliFrensSBT.sol";
import {DataTypes} from "./libraries/types/DataTypes.sol";
import {TokenURI} from "./libraries/helpers/TokenURI.sol";

/**
 * @title AmpliFrensSBT
 * @author Lucien Akchoté
 *
 * @notice This is the smart contract that handles the Soulbound Token minting
 * @dev Implements the EIP-4671 standard which is subject to change
 * @custom:security-contact lakchote@icloud.com
 * @custom:oz-upgrades-unsafe-allow external-library-linking
 */
contract AmpliFrensSBT is IAmpliFrensSBT {
    using Counters for Counters.Counter;
    using Strings for uint256;

    /// @dev See struct's description above
    DataTypes.MintingInterval public mintingParams;

    /// @dev Number of tokens emitted
    Counters.Counter private _tokenIdCounter;

    /// @dev Number of unique holders of the token
    Counters.Counter private _holdersCount;

    /// @dev Maps token ids with the most upvoted contributions
    mapping(uint256 => DataTypes.Contribution) private _tokens;

    /// @dev Maps an EOA address with its contributions tokens
    mapping(address => uint256[]) private _tokensForAddress;

    /// @dev Counter for valid tokens for addresses
    mapping(address => uint256) private _validTokensForAddress;

    /// @dev Base Token URI for metadata
    string public baseURI;

    string public constant SBT_TOKEN_NAME = "AmpliFrens Contribution Award";

    string public constant SBT_TOKEN_SYMBOL = "AFRENCONTRIBUTION";

    address public immutable facadeProxy;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address _facadeProxy) {
        mintingParams.lastBlockTimestamp = block.timestamp;
        mintingParams.mintInterval = 1 days;
        facadeProxy = _facadeProxy;
    }

    /// @inheritdoc IAmpliFrensSBT
    function mint(DataTypes.Contribution calldata contribution) external {
        PseudoModifier.addressEq(facadeProxy, msg.sender);
        SBTLogic.mint(
            contribution,
            _tokens,
            _tokensForAddress,
            _validTokensForAddress,
            mintingParams,
            _tokenIdCounter,
            _holdersCount
        );
    }

    /// @inheritdoc IAmpliFrensSBT
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return type(IAmpliFrensSBT).interfaceId == interfaceId;
    }

    /// @inheritdoc IAmpliFrensSBT
    function balanceOf(address owner) external view returns (uint256 balance) {
        return _validTokensForAddress[owner];
    }

    /// @inheritdoc IAmpliFrensSBT
    function ownerOf(uint256 tokenId) external view returns (address owner) {
        return _tokens[tokenId].author;
    }

    /// @inheritdoc IAmpliFrensSBT
    function isValid(uint256 tokenId) external view returns (bool) {
        return _tokens[tokenId].valid;
    }

    /// @inheritdoc IAmpliFrensSBT
    function hasValid(address owner) external view returns (bool) {
        return _validTokensForAddress[owner] > 0;
    }

    /// @inheritdoc IAmpliFrensSBT
    function name() external pure returns (string memory) {
        return SBT_TOKEN_NAME;
    }

    /// @inheritdoc IAmpliFrensSBT
    function symbol() external pure returns (string memory) {
        return SBT_TOKEN_SYMBOL;
    }

    /// @inheritdoc IAmpliFrensSBT
    function emittedCount() external view returns (uint256) {
        return _tokenIdCounter.current();
    }

    /// @inheritdoc IAmpliFrensSBT
    function holdersCount() external view returns (uint256) {
        return _holdersCount.current();
    }

    /// @inheritdoc IAmpliFrensSBT
    function totalTokensForAddress(address _address) external view returns (uint256) {
        return _validTokensForAddress[_address];
    }

    /// @inheritdoc IAmpliFrensSBT
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        return SBTLogic.tokenOfOwnerByIndex(owner, index, _tokensForAddress);
    }

    /// @inheritdoc IAmpliFrensSBT
    function tokenByIndex(uint256 index) external pure returns (uint256) {
        return index; /// @dev index == tokenId
    }

    /// @inheritdoc IAmpliFrensSBT
    function revoke(uint256 tokenId) external {
        PseudoModifier.addressEq(facadeProxy, msg.sender);
        SBTLogic.revoke(tokenId, _tokens, _validTokensForAddress, _tokenIdCounter);
    }

    /**
     *  @notice Get the last block timestamp when minting occured
     * (if minting happened at least once, otherwise it is the contract's initialization timestamp)
     */
    function lastBlockTimestamp() external view returns (uint256) {
        return mintingParams.lastBlockTimestamp;
    }

    /**
     * @notice Sets the base URI `uri` for tokens, it should end with a "/"
     *
     * @param uri The base URI
     */
    function setBaseURI(string calldata uri) external {
        PseudoModifier.addressEq(facadeProxy, msg.sender);
        baseURI = uri;
    }

    /**
     * @notice Gets the token URI for token with id `tokenId`
     *
     * @param tokenId The token id to retrieve the URI
     */
    function tokenURI(uint256 tokenId) external view returns (string memory uri) {
        uri = TokenURI.concatBaseURITokenIdJsonExt(tokenId, baseURI, _tokenIdCounter);
    }
}
