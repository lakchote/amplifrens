// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import {DataTypes} from "../types/DataTypes.sol";

/**
 * @title Statuses
 * @author Lucien Akchoté
 *
 * @notice Handles the statuses calculation
 */
library Status {
    /**
     * @notice Get the corresponding status for amount of tokens `totalTokens`
     *
     * @return The corresponding status of type `DataTypes.FrenStatus`
     */
    function getStatus(uint256 totalTokens) external pure returns (DataTypes.FrenStatus) {
        if (totalTokens >= 34) {
            return DataTypes.FrenStatus.Oracle;
        }
        if (totalTokens >= 21) {
            return DataTypes.FrenStatus.Aggregatoor;
        }
        if (totalTokens >= 13) {
            return DataTypes.FrenStatus.Contributoor;
        }
        if (totalTokens >= 5) {
            return DataTypes.FrenStatus.Pepe;
        }
        if (totalTokens == 1) {
            return DataTypes.FrenStatus.Degen;
        }

        return DataTypes.FrenStatus.Anon;
    }
}
