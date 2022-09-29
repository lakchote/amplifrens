// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
import {SBTLogic} from "./libraries/logic/SBTLogic.sol";
import {PseudoModifier} from "./libraries/guards/PseudoModifier.sol";
import {IAmpliFrensSBT} from "./interfaces/IAmpliFrensSBT.sol";
import {DataTypes} from "./libraries/types/DataTypes.sol";
import {TokenURI} from "./libraries/helpers/TokenURI.sol";
import {Status} from "./libraries/helpers/Status.sol";

/**
 * @title AmpliFrensSBT
 * @author Lucien Akchoté
 *
 * @notice This is the smart contract that handles the Soulbound Token minting
 * @dev Implements the EIP-4671 standard which is subject to change
 * @custom:security-contact lakchote@icloud.com
 * @custom:oz-upgrades-unsafe-allow external-library-linking
 */
contract AmpliFrensSBT is IERC165, IAmpliFrensSBT {
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

    /// @dev Contract initialization with facade's proxy address precomputed
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
    function revoke(uint256 tokenId) external {
        PseudoModifier.addressEq(facadeProxy, msg.sender);
        PseudoModifier.isNotOutOfBounds(tokenId, _tokenIdCounter);
        SBTLogic.revoke(tokenId, _tokens, _validTokensForAddress);
    }

    /// @inheritdoc IAmpliFrensSBT
    function setBaseURI(string calldata uri) external {
        PseudoModifier.addressEq(facadeProxy, msg.sender);
        baseURI = uri;
    }

    /// @inheritdoc IAmpliFrensSBT
    function isMintingIntervalMet() external view returns (bool) {
        return SBTLogic.isMintingIntervalMet(mintingParams.lastBlockTimestamp, mintingParams.mintInterval);
    }

    /// @inheritdoc IAmpliFrensSBT
    function balanceOf(address owner) external view returns (uint256 balance) {
        return _validTokensForAddress[owner];
    }

    /// @inheritdoc IAmpliFrensSBT
    function ownerOf(uint256 tokenId) external view returns (address owner) {
        PseudoModifier.isNotOutOfBounds(tokenId, _tokenIdCounter);

        return SBTLogic.ownerOf(tokenId, _tokens);
    }

    /// @inheritdoc IAmpliFrensSBT
    function isValid(uint256 tokenId) external view returns (bool) {
        PseudoModifier.isNotOutOfBounds(tokenId, _tokenIdCounter);

        return SBTLogic.isValid(tokenId, _tokens);
    }

    /// @inheritdoc IAmpliFrensSBT
    function hasValid(address owner) external view returns (bool) {
        return _validTokensForAddress[owner] > 0;
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
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        PseudoModifier.isNotOutOfBounds(index, _tokenIdCounter);

        return SBTLogic.tokenOfOwnerByIndex(owner, index, _tokensForAddress);
    }

    /// @inheritdoc IAmpliFrensSBT
    function tokenById(uint256 id) external view returns (DataTypes.Contribution memory) {
        PseudoModifier.isNotOutOfBounds(id, _tokenIdCounter);

        return SBTLogic.tokenById(id, _tokens);
    }

    /// @inheritdoc IAmpliFrensSBT
    function getStatus(address _address) external view returns (DataTypes.FrenStatus) {
        return Status.getStatus(_validTokensForAddress[_address]);
    }

    /**
     *  @notice Get the last block timestamp when minting occured
     *
     *  @dev if minting happened at least once otherwise it's the contract initialization timestamp
     */
    function lastBlockTimestamp() external view returns (uint256) {
        return mintingParams.lastBlockTimestamp;
    }

    /**
     * @notice Gets the token URI for token with id `tokenId`
     *
     * @param tokenId The token id to retrieve the URI
     */
    function tokenURI(uint256 tokenId) external view returns (string memory uri) {
        PseudoModifier.isNotOutOfBounds(tokenId, _tokenIdCounter);

        uri = TokenURI.concatBaseURITokenIdJsonExt(tokenId, baseURI);
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
    function tokenByIndex(uint256 index) external pure returns (uint256) {
        return index; /// @dev index == tokenId
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure override(IERC165) returns (bool) {
        return type(IAmpliFrensSBT).interfaceId == interfaceId || type(IERC165).interfaceId == interfaceId;
    }
}
