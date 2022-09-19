// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

/**
 * @title IAmpliFrensNFT
 * @author Lucien Akchoté
 *
 * @notice Handles specific functions to add over the IERC721 and IERC721Metadata interfaces
 */
interface IAmpliFrensNFT is IERC721, IERC721Metadata {
    /**
     * @notice Mint an NFT for address `to`
     *
     * @param to The address to mint the NFT
     * @param uri The URI of the NFT
     */
    function mint(address to, string memory uri) external;

    /**
     * @notice Transfer an NFT from address `from` to address `to`
     *
     * @param from The current owner's address for the NFT
     * @param to The new owner's address for the NFT
     * @param tokenId The token id to transfer
     */
    function transferNFT(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @notice Set the default royalty for entire NFT collection
     *
     * @dev Warning : not enforceable, it depends on the exchange policies where NFTs are traded
     *
     * @param receiver The address to receive royalty fees
     * @param feeNumerator The royalty fee
     */
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external;
}
