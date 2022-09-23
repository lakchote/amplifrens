// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import {Errors} from "../helpers/Errors.sol";

/**
 * @title PseudoModifier
 * @author Lucien Akchoté
 *
 * @notice Implements the (currently) unsupported functionality of using modifiers in libraries
 * @dev see https://github.com/ethereum/solidity/issues/12807
 */
library PseudoModifier {
    using Counters for Counters.Counter;

    /**
     * @notice Check address `expected` is equal to address `actual`
     *
     * @param expected The expected address
     * @param actual The actual address
     */
    function addressEq(address expected, address actual) external pure {
        if (expected != actual) revert Errors.Unauthorized();
    }

    /**
     * @dev Check if the index requested exist in counter
     *
     * @param index The id to verify existence for
     * @param counter The counter that holds enumeration
     */
    function isNotOutOfBounds(uint256 index, Counters.Counter storage counter) external view {
        if (index > counter.current() || index == 0) revert Errors.OutOfBounds();
    }
}
