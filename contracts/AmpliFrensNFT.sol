// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {IAmpliFrensNFT} from "./interfaces/IAmpliFrensNFT.sol";
import {TokenURI} from "./libraries/helpers/TokenURI.sol";
import {Errors} from "./libraries/helpers/Errors.sol";
import {PseudoModifier} from "./libraries/guards/PseudoModifier.sol";

/**
 * @title AmpliFrensNFT
 * @author Lucien Akchoté
 *
 * @notice NFTs for early adopters and contributors of the project that will give exclusive benefits in the future
 * @dev Implements the ERC721 standard and some of its extensions to suit business logic
 * @custom:security-contact lakchote@icloud.com
 */
contract AmpliFrensNFT is ERC721, ERC721Royalty, ERC721URIStorage, IAmpliFrensNFT {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    mapping(address => bool) public ownerAddresses;

    uint256 public constant MAX_SUPPLY = 15;
    string public baseURI;
    address public immutable facadeProxy;

    /// @dev Guard to ensure supply limit is enforced
    modifier hasSupply() {
        if (_tokenIdCounter.current() >= MAX_SUPPLY) revert Errors.MaxSupplyReached();
        _;
    }

    /**
     * @dev Only one NFT per address is allowed
     *
     * @param recipient The address to verify its NFT balance
     */
    modifier isNotAlreadyOwner(address recipient) {
        if (ownerAddresses[recipient]) revert Errors.AlreadyOwnNft();
        _;
    }

    /// @dev Constructor for contract initialization
    constructor(address _facadeProxy) ERC721("AmpliFrens", "AFREN") {
        facadeProxy = _facadeProxy;
    }

    /**
     * @notice Mint the token to address `to` with URI `uri``
     *
     * @param to The recipient of the token
     * @param uri The URI of the token
     */
    function mint(address to, string memory uri) external hasSupply {
        PseudoModifier.addressEq(facadeProxy, msg.sender);
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    /**
     * @notice Transfer the NFT with id `tokenId` from address `from` to address `to`
     */
    function transferNFT(
        address from,
        address to,
        uint256 tokenId
    ) external isNotAlreadyOwner(to) {
        ownerAddresses[to] = true;
        ERC721.safeTransferFrom(from, to, tokenId);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external {
        PseudoModifier.addressEq(facadeProxy, msg.sender);
        if (receiver == address(0)) {
            revert Errors.AddressNull();
        }
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    /// @dev Burn functionality is not allowed
    function _burn(uint256) internal pure virtual override(ERC721, ERC721Royalty, ERC721URIStorage) {
        revert Errors.NotImplemented();
    }

    /// @inheritdoc IAmpliFrensNFT
    function setBaseURI(string calldata uri) external {
        PseudoModifier.addressEq(facadeProxy, msg.sender);
        baseURI = uri;
    }

    /**
     * @notice Get the token URI for the token with id `tokenId`
     *
     * @param tokenId The token id to retrieve the URI
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage, IERC721Metadata)
        returns (string memory uri)
    {
        PseudoModifier.isNotOutOfBounds(tokenId, _tokenIdCounter);
        uri = TokenURI.concatBaseURITokenIdJsonExt(tokenId, baseURI);
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Royalty, IERC165) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
