// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

/**
 * @title Constants
 * @author Lucien Akchoté
 *
 * @notice A library containing all the constants used throughout AmpliFrens
 */
library Constants {
    bytes32 internal constant PAUSER_ROLE = keccak256("AFREN_PAUSER_ROLE");

    bytes32 internal constant UPGRADER_ROLE = keccak256("AFREN_UPGRADER_ROLE");

    string public constant TOKEN_NAME = "AmpliFrens Contribution Award";

    string public constant TOKEN_SYMBOL = "AFRENCONTRIBUTION";
}
