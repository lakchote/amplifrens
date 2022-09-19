// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title TokenURI
 * @author Lucien Akchoté
 *
 * @notice A library that is used for reusable functions related to Token URI
 */
library TokenURI {
    using Strings for uint256;
    using Counters for Counters.Counter;

    modifier isTokenIdValid(uint256 index, Counters.Counter storage counter) {
        require(index <= counter.current(), "Invalid token id");
        _;
    }

    /**
     * @notice Concatenate `baseURI` with the `tokenId` and ".json" string
     *
     * @param tokenId The token's id
     * @param baseURI The base URI to concatenate with
     * @return A string containing `baseURI` with the `tokenId` and ".json" as URI extension
     */
    function concatBaseURITokenIdJsonExt(
        uint256 tokenId,
        string calldata baseURI,
        Counters.Counter storage _tokenIdCounter
    ) external view isTokenIdValid(tokenId, _tokenIdCounter) returns (string memory) {
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json"))
                : string(abi.encodePacked(Strings.toString(tokenId), ".json"));
    }
}
