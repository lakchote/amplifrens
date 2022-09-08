// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title AmpliFrensNFT
 * @author Lucien Akchoté
 *
 * @notice NFTs for early adopters and contributors of the project that will give exclusive benefits in the future
 * @dev Implements the ERC721 standard and some of its extensions to suit business logic
 * @custom:security-contact lakchote@icloud.com
 */
contract AmpliFrensNFT is ERC721, ERC721Royalty, ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;

    using Strings for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public constant MAX_SUPPLY = 15;

    Counters.Counter private _tokenIdCounter;

    mapping(address => bool) public ownerAddresses;

    string public baseURI;

    /// @dev Guard to ensure supply limit is enforced
    modifier hasSupply() {
        require(_tokenIdCounter.current() <= MAX_SUPPLY, "Max NFT supply has been reached.");
        _;
    }

    /**
     * @dev Only one NFT per address is allowed
     *
     * @param recipient The address to verify its NFT balance
     */
    modifier isNotAlreadyOwner(address recipient) {
        require(!ownerAddresses[recipient], "User can only have one NFT.");
        _;
    }

    /// @dev Constructor for contract initialization
    constructor() ERC721("AmpliFrens", "AFREN") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _tokenIdCounter.increment(); /// @dev Set default token id as 1
    }

    /**
     * @notice Mint the token to address `to` with URI `uri``
     *
     * @param to The recipient of the token
     * @param uri The URI of the token
     */
    function safeMint(address to, string memory uri) external onlyRole(MINTER_ROLE) hasSupply {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    /**
     * @notice Transfers the token `tokenId` from address `from`to address `to`
     *
     * @param from The current owner's address for the token
     * @param to The recipient of the token
     * @param tokenId The ID of the token
     */
    function transferNFT(
        address from,
        address to,
        uint256 tokenId
    ) external isNotAlreadyOwner(to) {
        ownerAddresses[to] = true;
        safeTransferFrom(from, to, tokenId);
    }

    /**
     * @notice Defines the royalties to go to address `receiver` with fee set to `feeNumerator`
     * (divided by denominator expressed in basis points i.e 10000)
     * @dev Royalties are not enforced and depend on the different exchanges policies
     *  Marketplaces supporting the EIP-2981 royalty standard will use it for royalty payment
     *
     * @param receiver The address to receive royalties
     * @param feeNumerator The royalty fees
     */
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(receiver != address(0), "Receiver address cannot be null.");
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    /// @dev Burn functionality is not allowed
    function _burn(uint256) internal pure virtual override(ERC721, ERC721Royalty, ERC721URIStorage) {
        revert("Burn functionality is not implemented.");
    }

    /**
     * @notice Sets the base uri `uri` for tokens, it should end with a "/"
     *
     * @param uri The base URI
     */
    function setBaseURI(string calldata uri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = uri;
    }

    /// @notice Function to return a blank string or the `baseURI` if it's set
    function _baseURI() internal view override returns (string memory) {
        if (bytes(baseURI).length == 0) {
            return "";
        }

        return baseURI;
    }

    /**
     * @notice Gets the token URI for token with id `tokenId`
     *
     * @param tokenId The token id to retrieve the URI
     */
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        require(tokenId >= 1 && tokenId < MAX_SUPPLY, "TokenId is out of supply range.");
        return string(abi.encodePacked(_baseURI(), Strings.toString(tokenId), ".json"));
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Royalty, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
