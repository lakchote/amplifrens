// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import {DataTypes} from "../libraries/types/DataTypes.sol";

/**
 * @title IAmpliFrensContribution
 * @author Lucien Akchoté
 *
 * @notice Handles the day to day operations for interacting with contributions
 */
interface IAmpliFrensContribution {
    /**
     * @notice Event emitted when a contribution user's status changes
     *
     * @param _address The user's address
     * @param status The new status
     */
    event UserStatusChanged(address indexed _address, DataTypes.FrenStatus indexed status);

    /**
     * @notice Upvote the contribution with id `contributionId`
     *
     * @param contributionId The contribution to upvote
     */
    function upvote(uint256 contributionId) external;

    /**
     * @notice Downvote the contribution with id `contributionId`
     *
     * @param contributionId The contribution id to downvote
     */
    function downvote(DataTypes.Contribution calldata contributionId) external;

    /**
     * @notice Report the contribution with id `contributionId`
     *
     * @param contributionId The contribution id to report
     */
    function report(uint256 contributionId) external;

    /**
     * @notice Remove the contribution with id `contributionId`
     *
     * @param contributionId The contribution id to upvote
     */
    function remove(uint256 contributionId) external;

    /**
     * @notice Update the contribution with id `contributionId`
     *
     * @param contributionId The contribution id to update
     */
    function update(uint256 contributionId) external;

    /**
     * @notice Get the total contributions
     *
     * @return Total contributions of type `DataTypes.Contribution`
     */
    function getContributions() external view returns (DataTypes.Contribution[] memory);

    /**
     * @notice Get contributions with user status `status`
     *
     * @return Total contributions with status `status` of type `DataTypes.Contribution`
     */
    function getContributionsByStatus(DataTypes.FrenStatus status)
        external
        view
        returns (DataTypes.Contribution[] memory);

    /**
     * @notice Get the present most upvoted contribution
     *
     * @return `DataTypes.Contribution`
     */
    function todayBestContribution() external returns (DataTypes.Contribution memory);

    /**
     * @notice Get yesterday's most upvoted contribution
     *
     * @return `DataTypes.Contribution`
     */
    function yesterdayBestContribution() external returns (DataTypes.Contribution memory);

    /// @notice Reset the contributions
    function reset() external;
}
