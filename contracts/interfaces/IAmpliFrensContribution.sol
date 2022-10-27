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
     * @notice Event that is emitted when a contribution is upvoted
     *
     * @param from The address who upvoted
     * @param contributionId The id of the contribution
     * @param timestamp The time of upvote
     */
    event ContributionUpvoted(address indexed from, uint256 indexed contributionId, uint256 timestamp);

    /**
     * @notice Event that is emitted when a contribution is downvoted
     *
     * @param from The address who downvoted
     * @param contributionId The id of the contribution
     * @param timestamp The time of downvote
     */
    event ContributionDownvoted(address indexed from, uint256 indexed contributionId, uint256 timestamp);

    /**
     * @notice Event that is emitted when a contribution is updated
     *
     * @param from The address who created the contribution
     * @param contributionId The id of the contribution
     * @param timestamp The time of the creation
     * @param category The contribution category
     * @param title The title of the contribution
     * @param url The URL of the contribution
     */
    event ContributionUpdated(
        address indexed from,
        uint256 contributionId,
        uint256 timestamp,
        DataTypes.ContributionCategory category,
        string title,
        string url
    );

    /**
     * @notice Event that is emitted when a contribution is removed
     *
     * @param from The address who removed contribution
     * @param contributionId The id of the contribution
     * @param timestamp The time of the removal
     */
    event ContributionRemoved(address indexed from, uint256 indexed contributionId, uint256 timestamp);

    /**
     * @notice Event that is emitted when a contribution is created
     *
     * @param from The address who created the contribution
     * @param contributionId The id of the contribution
     * @param timestamp The time of the creation
     * @param category The contribution category
     * @param title The title of the contribution
     * @param url The URL of the contribution
     */
    event ContributionCreated(
        address indexed from,
        uint256 contributionId,
        uint256 timestamp,
        DataTypes.ContributionCategory category,
        string title,
        string url
    );

    /**
     * @notice Upvote the contribution with id `contributionId`
     *
     * @param contributionId The contribution to upvote
     * @param from  The address `from` who initiated the transaction
     */
    function upvote(uint256 contributionId, address from) external;

    /**
     * @notice Downvote the contribution with id `contributionId`
     *
     * @param contributionId The contribution id to downvote
     * @param from  The address `from` who initiated the transaction
     */
    function downvote(uint256 contributionId, address from) external;

    /**
     * @notice Remove the contribution with id `contributionId`
     *
     * @param contributionId The contribution id to delete
     * @param from  The address `from` who initiated the transaction
     */
    function remove(uint256 contributionId, address from) external;

    /**
     * @notice Update the contribution with id `contributionId`
     *
     * @param contributionId The contribution id to update
     * @param category The contribution's updated category
     * @param title The contribution's updated title
     * @param url The contribution's updated url
     * @param from  The address `from` who initiated the transaction
     */
    function update(
        uint256 contributionId,
        DataTypes.ContributionCategory category,
        string calldata title,
        string calldata url,
        address from
    ) external;

    /**
     * @notice Create a contribution
     *
     * @param category The contribution's category
     * @param title The contribution's title
     * @param url The contribution's url
     * @param from  The address `from` who initiated the transaction
     */
    function create(
        DataTypes.ContributionCategory category,
        string calldata title,
        string calldata url,
        address from
    ) external;

    /**
     * @notice Reset the contributions
     *
     * @param from  The address `from` who initiated the transaction
     */
    function reset(address from) external;

    /**
     * @notice Increment total days elapsed since contract's creation by 1
     */
    function incrementDayCounter() external;

    /**
     * @notice Get the contribution with id `contributionId`
     *
     * @param contributionId The id of the contribution to retrieve
     *
     * @return Contribution with id `contributionId` of type `DataTypes.Contribution`
     */
    function getContribution(uint256 contributionId) external view returns (DataTypes.Contribution memory);

    /**
     * @notice Retrieve the most upvoted contribution for the current day
     *
     * @return The most upvoted contribution
     */
    function topContribution() external view returns (DataTypes.TopContribution memory);

    /**
     * @notice Return the total number of contributions
     *
     * @return Number of contributions
     */
    function contributionsCount() external view returns (uint256);
}
