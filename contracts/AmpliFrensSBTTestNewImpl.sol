// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IERC4671.sol";
import "./interfaces/IERC4671Enumerable.sol";
import "./interfaces/IERC4671Metadata.sol";

/// @notice This is a test contract to check upgradeability of AmpliFrensSBT contract
/// @dev Upgradeability test for UUPS
/// @custom:security-contact lakchote@icloud.com
contract AmpliFrensSBTTestNewImpl is
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

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    string public constant TOKEN_NAME = "AmpliFrens Contribution Award";

    string public constant TOKEN_SYMBOL = "AFRENCONTRIBUTION";

    /// @notice Contains the different contributions categories
    enum ContributionCategory {
        NFT,
        Article,
        DeFi,
        Security,
        Thread,
        GameFi,
        Video,
        Misc
    }

    /**
     *  @dev Use tight packing to save up on storage cost
     *  4 storage slots used (string takes up 64 bytes or 2 slots in the storage)
     */
    struct Contribution {
        address owner; /// @dev 20 bytes
        ContributionCategory category; /// @dev 8 bytes
        uint32 timestamp; /// @dev 4 bytes
        bool valid; /// @dev 1 byte
        uint248 votes; /// @dev 31 bytes
        bytes32 title; /// @dev 32 bytes
        string url; /// @dev 64 bytes
    }

    /// @dev Maps token ids with the most upvoted contributions
    mapping(uint256 => Contribution) private _tokens;

    /// @dev Maps an EOA address with its contributions tokens
    mapping(address => uint256[]) private _tokensForAddress;

    /// @dev Counter for valid tokens for addresses
    mapping(address => uint256) private _validTokensForAddress;

    /// @notice Interval to ensure minting can occur at specific period
    /// @dev Mint interval that will be compared with two timestamps : `lastBlockTimeStamp` and `block.timestamp`
    uint256 public mintInterval;

    /// @notice Used in conjuction with mint interval and current block timestamp when minting function is called
    /// @dev Equals to last mint tx's block.timestamp or block.timestamp at contract initialization
    uint256 public lastBlockTimestamp;

    /// @dev Number of tokens minted
    uint256 private _emittedCount;

    /// @dev Base Token URI for metadata
    string public baseURI;

    /// @notice Enforces compliance with interval period when minting function is called
    modifier guardIntervalForMinting() {
        require(
            (block.timestamp - lastBlockTimestamp) > mintInterval,
            "Interval target for minting is not met yet."
        );
        _;
    }

    modifier isNotOutOfBounds(uint256 index) {
        require(
            index <= _tokenIdCounter.current() && index != 0,
            "Index is out of bounds."
        );
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function newFunction() public pure returns (string memory) {
        return "New function for contract v2";
    }

    function initialize() public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        lastBlockTimestamp = block.timestamp;
        mintInterval = 1 days;
        _tokenIdCounter.increment();
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    function mint(
        address to,
        ContributionCategory category,
        uint32 timestamp,
        uint248 votes,
        bytes32 title,
        string calldata url
    ) external guardIntervalForMinting onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 currentTokenId = _tokenIdCounter.current();
        _emittedCount = currentTokenId;
        _tokens[currentTokenId] = Contribution(
            to,
            category,
            timestamp,
            true, /// @dev valid by default at the time of minting
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
        uint256[] memory tokenIds = _tokensForAddress[owner];
        balance = tokenIds.length;
    }

    /// @inheritdoc IERC4671
    function ownerOf(uint256 tokenId)
        external
        view
        isNotOutOfBounds(tokenId)
        returns (address)
    {
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
        return TOKEN_NAME;
    }

    /// @inheritdoc IERC4671Metadata
    function symbol() external pure returns (string memory) {
        return TOKEN_SYMBOL;
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
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256)
    {
        uint256[] memory tokenIds = _tokensForAddress[owner]; /// @dev data needs to be stored in memory to be read

        return tokenIds[index];
    }

    /// @inheritdoc IERC4671Enumerable
    function tokenByIndex(uint256 index)
        external
        view
        isNotOutOfBounds(index)
        returns (uint256)
    {
        return index; /// @dev index == tokenId
    }

    function revoke(uint256 tokenId)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        isNotOutOfBounds(tokenId)
    {
        _tokens[tokenId].valid = false;
        address owner = _tokens[tokenId].owner;
        _validTokensForAddress[owner] -= 1;
        emit Revoked(owner, tokenId);
    }

    function setBaseURI(string calldata uri)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        baseURI = uri;
    }

    function _baseURI() internal view returns (string memory) {
        if (bytes(baseURI).length == 0) {
            return "";
        }

        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        external
        view
        isNotOutOfBounds(tokenId)
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(_baseURI(), Strings.toString(tokenId), ".json")
            );
    }
}
