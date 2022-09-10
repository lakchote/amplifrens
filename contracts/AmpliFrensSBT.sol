// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {IERC4671, IERC165} from "./interfaces/IERC4671.sol";
import {IERC4671Enumerable} from "./interfaces/IERC4671Enumerable.sol";
import {IERC4671Metadata} from "./interfaces/IERC4671Metadata.sol";
import {Constants} from "./libraries/Constants.sol";
import {Statuses} from "./libraries/Statuses.sol";
import {DataTypes} from "./libraries/DataTypes.sol";

/**
 * @title AmpliFrensSBT
 * @author Lucien Akchoté
 *
 * @notice This is the smart contract that handles the Soulbound Token minting
 * @dev Implements the EIP-4671 standard which is subject to change
 * @custom:security-contact lakchote@icloud.com
 * @custom:oz-upgrades-unsafe-allow external-library-linking
 */
contract AmpliFrensSBT is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    IERC4671,
    IERC4671Metadata,
    IERC4671Enumerable
{
    using Counters for Counters.Counter;
    using Strings for uint256;

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

    /// @dev Number of tokens minted
    uint256 private _emittedCount;

    /// @notice Interval to ensure minting can occur at a specific period
    /// @dev Mint interval that will be compared with two timestamps : `lastBlockTimeStamp` and `block.timestamp`
    uint256 public mintInterval;

    /// @notice Used in conjunction with mint interval and current block timestamp when minting function is called
    /// @dev Equals to last mint tx's block.timestamp or block.timestamp at contract initialization
    uint256 public lastBlockTimestamp;

    /// @dev Base Token URI for metadata
    string public baseURI;

    /**
     * @dev Check if the token index requested has been minted
     *
     * @param index The token id to verify existence for
     */
    modifier isNotOutOfBounds(uint256 index) {
        require(index <= _tokenIdCounter.current() && index != 0, "Out of bounds");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @dev Serves as a constructor for the proxy
    function initialize() public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(Constants.PAUSER_ROLE, msg.sender);
        _grantRole(Constants.UPGRADER_ROLE, msg.sender);
        lastBlockTimestamp = block.timestamp;
        mintInterval = 1 days;
        _tokenIdCounter.increment();
    }

    /// @dev Pause the functions "mint" and "revoke"
    function pause() external onlyRole(Constants.PAUSER_ROLE) {
        _pause();
    }

    /// @dev Unpause the functions "mint" and "revoke"
    function unpause() external onlyRole(Constants.PAUSER_ROLE) {
        _unpause();
    }

    /// @inheritdoc UUPSUpgradeable
    function _authorizeUpgrade(address) internal view override onlyRole(Constants.UPGRADER_ROLE) {}

    /**
     * @notice Mints the Soulbound Token to recipient `to` if the interval is met and functionality is not paused
     * @dev Individual params for `DataTypes.Contribution` are specified instead of providing the struct directly
     * to save gas
     *
     * @param to The recipient to mint Soulbound token
     * @param category The contribution category
     * @param timestamp Timestamp of the contribution posted
     * @param votes Number of votes for the contribution
     * @param title Title of the contribution
     * @param url URL for the contribution
     */
    function mint(
        address to,
        uint8 category,
        uint40 timestamp,
        uint40 votes,
        bytes32 title,
        string calldata url
    ) external whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        require((block.timestamp - lastBlockTimestamp) > mintInterval, "Minting interval not met");
        uint256 currentTokenId = _tokenIdCounter.current();
        _emittedCount = currentTokenId;
        _tokens[currentTokenId] = DataTypes.Contribution(
            to,
            DataTypes.ContributionCategory(category),
            true, /// @dev valid by default at the time of minting
            timestamp,
            votes,
            title,
            url
        );

        if (_tokensForAddress[to].length == 0) {
            _holdersCount.increment();
        }

        _tokensForAddress[to].push(currentTokenId);
        _validTokensForAddress[to] += 1;
        lastBlockTimestamp = block.timestamp;
        _tokenIdCounter.increment();
        emit Minted(to, currentTokenId);
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControlUpgradeable, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC4671).interfaceId ||
            interfaceId == type(IERC4671Enumerable).interfaceId ||
            interfaceId == type(IERC4671Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IERC4671
    function balanceOf(address owner) external view returns (uint256 balance) {
        balance = _tokensForAddress[owner].length;
    }

    /// @inheritdoc IERC4671
    function ownerOf(uint256 tokenId) external view isNotOutOfBounds(tokenId) returns (address) {
        return _tokens[tokenId].owner;
    }

    /// @inheritdoc IERC4671
    function isValid(uint256 tokenId) external view returns (bool) {
        return _tokens[tokenId].valid;
    }

    /// @inheritdoc IERC4671
    function hasValid(address owner) external view returns (bool) {
        return _validTokensForAddress[owner] > 0;
    }

    /// @inheritdoc IERC4671Metadata
    function name() external pure returns (string memory) {
        return Constants.SBT_TOKEN_NAME;
    }

    /// @inheritdoc IERC4671Metadata
    function symbol() external pure returns (string memory) {
        return Constants.SBT_TOKEN_SYMBOL;
    }

    /// @inheritdoc IERC4671Enumerable
    function emittedCount() external view returns (uint256) {
        return _emittedCount;
    }

    /**
     * @notice Gives the total unique holders of tokens
     *
     * @return holdersCount Number of token holders
     */
    function holdersCount() external view returns (uint256) {
        return _holdersCount.current();
    }

    /// @inheritdoc IERC4671Enumerable
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        uint256[] memory tokenIds = _tokensForAddress[owner];

        return tokenIds[index];
    }

    /// @inheritdoc IERC4671Enumerable
    function tokenByIndex(uint256 index) external view isNotOutOfBounds(index) returns (uint256) {
        return index; /// @dev index == tokenId
    }

    /**
     * @notice Get the contribution status for address `_address`
     *
     * @param _address The address to retrieve contribution status
     */
    function getStatus(address _address) external view returns (string memory) {
        require(_tokensForAddress[_address].length != 0, "0 tokens");
        return Statuses.getStatus(_tokensForAddress[_address].length);
    }

    /**
     * @notice Revokes the specified token in case of abuse or error
     *
     * @param tokenId The token ID to revoke
     */
    function revoke(uint256 tokenId) external whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) isNotOutOfBounds(tokenId) {
        _tokens[tokenId].valid = false;
        _validTokensForAddress[_tokens[tokenId].owner] -= 1;
        emit Revoked(_tokens[tokenId].owner, tokenId);
    }

    /**
     * @notice Sets the base URI `uri` for tokens, it should end with a "/"
     *
     * @param uri The base URI
     */
    function setBaseURI(string calldata uri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = uri;
    }

    /// @notice Function to return a blank string or the `baseURI` if it's set
    function _baseURI() internal view returns (string memory) {
        return (bytes(baseURI).length == 0) ? "" : baseURI;
    }

    /**
     * @notice Gets the token URI for token with id `tokenId`
     *
     * @param tokenId The token id to retrieve the URI
     */
    function tokenURI(uint256 tokenId) external view isNotOutOfBounds(tokenId) returns (string memory) {
        return string(abi.encodePacked(_baseURI(), Strings.toString(tokenId), ".json"));
    }

    /// @dev Should not allow funds except for user with role `Constants.UPGRADER_ROLE`
    receive() external payable onlyRole(Constants.UPGRADER_ROLE) {}

    /// @dev Fallback method restricted to user with role `DEFAULT_ADMIN_ROLE`
    fallback() external onlyRole(DEFAULT_ADMIN_ROLE) {}
}
