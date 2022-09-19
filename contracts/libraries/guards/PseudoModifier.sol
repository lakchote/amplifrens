// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

/**
 * @title PseudoModifier
 * @author Lucien Akchoté
 *
 * @notice Implements the (currently) unsupported functionality of using modifiers in libraries
 * @dev see https://github.com/ethereum/solidity/issues/12807
 */
library PseudoModifier {
    /**
     * @notice Check address `expected` is equal to address `actual`
     *
     * @param expected The expected address
     * @param actual The actual address
     */
    function addressEq(address expected, address actual) external pure {
        require(expected == actual, "Unauthorized");
    }
}
