// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import {DataTypes} from "./DataTypes.sol";

/**
 * @title Statuses
 * @author Lucien Akchoté
 *
 * @notice Handles the statuses calculation
 */
library Statuses {
    function getStatus(uint256 totalTokens) external pure returns (string memory) {
        if (totalTokens >= 5 && totalTokens < 10) {
            return "Anon";
        }
        if (totalTokens >= 10 && totalTokens < 15) {
            return "Degen";
        }
        if (totalTokens >= 15 && totalTokens < 30) {
            return "Pepe";
        }
        if (totalTokens >= 30 && totalTokens < 60) {
            return "Contributoor";
        }
        if (totalTokens >= 60 && totalTokens < 100) {
            return "Aggregatoor";
        }

        return "Oracle";
    }

    function getAnonIndex() external pure returns (uint8) {
        return uint8(DataTypes.FrenStatus.Anon);
    }

    function getDegenIndex() external pure returns (uint8) {
        return uint8(DataTypes.FrenStatus.Degen);
    }

    function getPepeIndex() external pure returns (uint8) {
        return uint8(DataTypes.FrenStatus.Pepe);
    }

    function getContributoorIndex() external pure returns (uint8) {
        return uint8(DataTypes.FrenStatus.Contributoor);
    }

    function getAggregatoorIndex() external pure returns (uint8) {
        return uint8(DataTypes.FrenStatus.Aggregatoor);
    }
}
