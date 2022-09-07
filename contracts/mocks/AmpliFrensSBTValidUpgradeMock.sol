// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {IERC4671, IERC165} from "../interfaces/IERC4671.sol";
import {IERC4671Enumerable} from "../interfaces/IERC4671Enumerable.sol";
import {IERC4671Metadata} from "../interfaces/IERC4671Metadata.sol";
import {Constants} from "../libraries/Constants.sol";
import {Statuses} from "../libraries/Statuses.sol";
import {DataTypes} from "../libraries/DataTypes.sol";

/**
 * @title AmpliFrensSBT
 * @author Lucien Akchoté
 *
 * @notice This is a mock to check upgradeability of AmpliFrensSBT contract
 * @dev Upgradeability test for UUPS
 * @custom:security-contact lakchote@icloud.com
 * @custom:oz-upgrades-unsafe-allow external-library-linking
 */
contract AmpliFrensSBTValidUpgradeMock is
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

    /// @notice Interval to ensure minting can occur at specific period
    /// @dev Mint interval that will be compared with two timestamps : `lastBlockTimeStamp` and `block.timestamp`
    uint256 public mintInterval;

    /// @notice Used in conjuction with mint interval and current block timestamp when minting function is called
    /// @dev Equals to last mint tx's block.timestamp or block.timestamp at contract initialization
    uint256 public lastBlockTimestamp;

    /// @dev Base Token URI for metadata
    string public baseURI;

    /// @dev Check if token index requested has been minted
    modifier isNotOutOfBounds(uint256 index) {
        require(index <= _tokenIdCounter.current() && index != 0, "Out of bounds");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @dev Serves as constructor for proxy
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

    /// @dev New function added to test for upgradeability
    function newFunction() public pure returns (string memory) {
        return "New function for contract v2";
    }

    function pause() external onlyRole(Constants.PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(Constants.PAUSER_ROLE) {
        _unpause();
    }

    /// @inheritdoc UUPSUpgradeable
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(Constants.UPGRADER_ROLE) {}

    function mint(
        address to,
        uint8 category,
        uint40 timestamp,
        uint40 votes,
        string calldata title,
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
        return Constants.TOKEN_NAME;
    }

    /// @inheritdoc IERC4671Metadata
    function symbol() external pure returns (string memory) {
        return Constants.TOKEN_SYMBOL;
    }

    /// @inheritdoc IERC4671Enumerable
    function emittedCount() external view returns (uint256) {
        return _emittedCount;
    }

    /// @return holdersCount Number of token holders
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

    function getStatus(address _address) external view returns (string memory) {
        require(_tokensForAddress[_address].length != 0, "0 tokens");
        return Statuses.getStatus(_tokensForAddress[_address].length);
    }

    function revoke(uint256 tokenId) external whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) isNotOutOfBounds(tokenId) {
        _tokens[tokenId].valid = false;
        address owner = _tokens[tokenId].owner;
        _validTokensForAddress[owner] -= 1;
        emit Revoked(owner, tokenId);
    }

    function setBaseURI(string calldata uri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = uri;
    }

    function _baseURI() internal view returns (string memory) {
        return (bytes(baseURI).length == 0) ? "" : baseURI;
    }

    function tokenURI(uint256 tokenId) external view isNotOutOfBounds(tokenId) returns (string memory) {
        return string(abi.encodePacked(_baseURI(), Strings.toString(tokenId), ".json"));
    }

    receive() external payable onlyRole(Constants.UPGRADER_ROLE) {}

    fallback() external onlyRole(DEFAULT_ADMIN_ROLE) {}
}
