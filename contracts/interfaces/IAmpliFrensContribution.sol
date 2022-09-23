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
    /// @dev Events related to contributions interaction
    event Upvoted(address indexed from, uint256 indexed contributionId, uint256 timestamp);
    event Downvoted(address indexed from, uint256 indexed contributionId, uint256 timestamp);
    event Updated(address indexed from, uint256 indexed contributionId, uint256 timestamp);

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
    function downvote(uint256 contributionId) external;

    /**
     * @notice Remove the contribution with id `contributionId`
     *
     * @param contributionId The contribution id to delete
     */
    function remove(uint256 contributionId) external;

    /**
     * @notice Update the contribution with id `contributionId`
     *
     * @param contributionId The contribution id to update
     * @param category The contribution's updated category
     * @param title The contribution's updated title
     * @param url The contribution's updated url
     */
    function update(
        uint256 contributionId,
        DataTypes.ContributionCategory category,
        bytes32 title,
        string calldata url
    ) external;

    /**
     * @notice Create a contribution
     *
     * @param category The contribution's category
     * @param title The contribution's title
     * @param url The contribution's url
     */
    function create(
        DataTypes.ContributionCategory category,
        bytes32 title,
        string calldata url
    ) external;

    /// @notice Reset the contributions
    function reset() external;

    /**
     * @notice Get the total contributions
     *
     * @return Total contributions of type `DataTypes.Contribution`
     */
    function getContributions() external view returns (DataTypes.Contribution[] memory);

    /**
     * @notice Get the contribution with id `contributionId`
     *
     * @param contributionId The id of the contribution to retrieve
     * @return Contribution with id `contributionId` of type `DataTypes.Contribution`
     */
    function getContribution(uint256 contributionId) external view returns (DataTypes.Contribution memory);

    /**
     * @notice Get the most upvoted contribution
     *
     * @return `DataTypes.Contribution`
     */
    function topContribution() external view returns (DataTypes.Contribution memory);

    /**
     * @notice Return the total number of contributions
     *
     * @return Number of contributions
     */
    function contributionsCount() external view returns (uint256);
}
