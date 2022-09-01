// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @notice NFTs for early adopters and contributors of the project that will give exclusive benefits in the future
/// @dev Implements the ERC721 standard and some of its extensions to suit business logic
/// @custom:security-contact lakchote@icloud.com
contract AmpliFrensNFT is
    ERC721,
    ERC721Royalty,
    ERC721URIStorage,
    AccessControl
{
    using Counters for Counters.Counter;

    using Strings for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public constant MAX_SUPPLY = 100;

    Counters.Counter private _tokenIdCounter;

    mapping(address => bool) minterAddresses;

    string public baseURI;

    /// @dev Guard to ensure supply limit is enforced
    modifier hasSupply() {
        require(
            _tokenIdCounter.current() < MAX_SUPPLY,
            "Max NFT supply has been reached."
        );
        _;
    }

    /// @dev Only one NFT per address is allowed
    modifier isNotAlreadyOwner(address _recipient) {
        require(!minterAddresses[_recipient], "User can only have one NFT.");
        _;
    }

    constructor() ERC721("AmpliFrens", "AFREN") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _tokenIdCounter.increment(); /// @dev Set default token id as 1
    }

    function safeMint(address to, string memory uri)
        public
        onlyRole(MINTER_ROLE)
        isNotAlreadyOwner(to)
        hasSupply
    {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        minterAddresses[to] = true;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    /**
     *  @dev Royalties are not enforced and depend on the different exchanges policies
     *  Marketplaces supporting the EIP-2981 royalty standard will use it for royalty payment
     */
    function setDefaultRoyalty(address receiver, uint96 feeNumerator)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(receiver != address(0), "Receiver address cannot be null.");
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function _burn(uint256)
        internal
        pure
        virtual
        override(ERC721, ERC721Royalty, ERC721URIStorage)
    {
        revert("Burn functionality is not implemented.");
    }

    function setBaseURI(string calldata uri)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        baseURI = uri;
    }

    function _baseURI() internal view override returns (string memory) {
        if (bytes(baseURI).length == 0) {
            return "";
        }

        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(
            tokenId >= 1 && tokenId < MAX_SUPPLY,
            "TokenId is out of supply range."
        );
        return
            string(
                abi.encodePacked(_baseURI(), Strings.toString(tokenId), ".json")
            );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Royalty, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
