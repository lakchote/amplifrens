// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import {DataTypes} from "../types/DataTypes.sol";
import {Errors} from "../helpers/Errors.sol";
import {PseudoModifier} from "../guards/PseudoModifier.sol";

/**
 * @title ContributionLogic
 * @author Lucien Akchoté
 *
 * @notice A library that implements the logic of contribution related functions
 */
library ContributionLogic {
    using Counters for Counters.Counter;

    /// @dev See `IAmpliFrensContribution` for descriptions
    event ContributionUpvoted(address indexed from, uint256 indexed contributionId, uint256 timestamp);
    event ContributionDownvoted(address indexed from, uint256 indexed contributionId, uint256 timestamp);
    event ContributionRemoved(address indexed from, uint256 indexed contributionId, uint256 timestamp);
    event ContributionCreated(
        address indexed from,
        uint256 contributionId,
        uint256 timestamp,
        DataTypes.ContributionCategory category,
        string title,
        string url
    );
    event ContributionUpdated(
        address indexed from,
        uint256 contributionId,
        uint256 timestamp,
        DataTypes.ContributionCategory category,
        string title,
        string url
    );

    /**
     * @notice Ensure that `from` is not the contribution's author
     *
     *
     * @dev Prevent own upvoting/downvoting use cases
     * @param author The contribution's author address
     * @param from  The address `from` who initiated the transaction
     */
    modifier isNotAuthor(address author, address from) {
        if (author == from) revert Errors.Unauthorized();
        _;
    }

    /**
     * @notice Ensure that `from` has not voted already for a contribution
     *
     * @dev Prevent botting contributions score
     * @param hasVoted Boolean that indicates if `from` has already voted or not
     */
    modifier hasNotVotedAlready(bool hasVoted) {
        if (hasVoted) revert Errors.AlreadyVoted();
        _;
    }

    /**
     * @notice Ensure that contribution id `contributionId` exists
     */
    modifier isValidContributionId(uint256 contributionId, mapping(uint256 => bool) storage validContributionIds) {
        if (!validContributionIds[contributionId]) revert Errors.OutOfBounds();
        _;
    }

    /**
     * @notice Upvote the contribution with id `contributionId`
     *
     * @param contributionId The contribution's id
     * @param from  The address `from` who initiated the transaction
     * @param container Total contributions data
     */
    function upvote(
        uint256 contributionId,
        address from,
        DataTypes.Contributions storage container
    )
        external
        isNotAuthor(container.contribution[contributionId].author, from)
        hasNotVotedAlready(container.upvoted[contributionId][from])
        isValidContributionId(contributionId, container.validContributionIds)
    {
        DataTypes.Contribution storage contribution = container.contribution[contributionId];
        ++contribution.votes;
        container.upvoted[contributionId][from] = true;
        container.upvoterAddresses.push(from);
        container.upvotedIds.push(contributionId);

        ++container.dayContributions[contribution.dayCounter][contributionId].votes;

        emit ContributionUpvoted(from, contributionId, block.timestamp);
    }

    /**
     * @notice Downvote the contribution with id `contributionId`
     *
     * @param contributionId The contribution's id
     * @param from  The address `from` who initiated the transaction
     * @param container Total contributions data
     */
    function downvote(
        uint256 contributionId,
        address from,
        DataTypes.Contributions storage container
    )
        external
        isNotAuthor(container.contribution[contributionId].author, from)
        hasNotVotedAlready(container.downvoted[contributionId][from])
        isValidContributionId(contributionId, container.validContributionIds)
    {
        DataTypes.Contribution storage contribution = container.contribution[contributionId];
        --contribution.votes;
        container.downvoted[contributionId][from] = true;
        container.downvoterAddresses.push(from);
        container.downvotedIds.push(contributionId);

        --container.dayContributions[contribution.dayCounter][contributionId].votes;

        emit ContributionDownvoted(from, contributionId, block.timestamp);
    }

    /**
     * @notice Remove the contribution with id `contributionId`
     *
     * @param contributionId The contribution's id
     * @param from  The address `from` who initiated the transaction
     * @param adminAddress The admin's address
     * @param container Total contributions data
     * @param _contributionsCounter Number of tokens emitted
     */
    function remove(
        uint256 contributionId,
        address from,
        address adminAddress,
        DataTypes.Contributions storage container,
        Counters.Counter storage _contributionsCounter
    ) external isValidContributionId(contributionId, container.validContributionIds) {
        PseudoModifier.isAuthorOrAdmin(adminAddress, container.contribution[contributionId].author, from);

        uint256 dayCounter = container.contribution[contributionId].dayCounter;
        delete container.dayContributions[dayCounter][contributionId];
        for (uint256 i = 0; i < container.totalDayContributions[dayCounter]; ++i) {
            if (container.dayContributionsIds[dayCounter][i] == contributionId) {
                delete container.dayContributionsIds[dayCounter][i];
            }
        }
        delete container.contribution[contributionId];

        container.validContributionIds[contributionId] = false;

        _contributionsCounter.decrement();

        emit ContributionRemoved(from, contributionId, block.timestamp);
    }

    /**
     * @notice Update the contribution with id `contributionId`
     *
     * @param contributionId The contribution's id
     * @param category The contribution's category
     * @param title The contribution's title
     * @param url The contribution's url
     * @param from  The address `from` who initiated the transaction
     * @param adminAddress The admin's address
     * @param container Total contributions data
     */
    function update(
        uint256 contributionId,
        DataTypes.ContributionCategory category,
        string calldata title,
        string calldata url,
        address from,
        address adminAddress,
        DataTypes.Contributions storage container
    ) external isValidContributionId(contributionId, container.validContributionIds) {
        PseudoModifier.isAuthorOrAdmin(adminAddress, container.contribution[contributionId].author, from);

        DataTypes.Contribution storage contribution = container.contribution[contributionId];

        contribution.category = category;
        if (bytes8(bytes(title)) != 0x00) {
            contribution.title = title;
        }
        if (bytes(url).length > 0) {
            contribution.url = url;
        }

        emit ContributionUpdated(from, contributionId, block.timestamp, category, title, url);
    }

    /**
     * @notice Create a contribution of type `DataTypes.Contribution`
     *
     * @param category The contribution's category
     * @param title The contribution's title
     * @param url The contribution's url
     * @param from  The address `from` who initiated the transaction
     * @param facadeProxyAddress The address of the facade proxy
     * @param container Total contributions data
     * @param _contributionsCounter Number of tokens emitted
     * @param currentDay The current day since contract's creation
     */
    function create(
        DataTypes.ContributionCategory category,
        string calldata title,
        string calldata url,
        address from,
        address facadeProxyAddress,
        DataTypes.Contributions storage container,
        Counters.Counter storage _contributionsCounter,
        uint256 currentDay
    ) external {
        PseudoModifier.isFacadeCall(facadeProxyAddress, msg.sender);

        _contributionsCounter.increment();
        DataTypes.Contribution memory contribution = DataTypes.Contribution(
            from,
            category,
            true,
            block.timestamp,
            0,
            currentDay,
            title,
            url
        );

        container.contribution[_contributionsCounter.current()] = contribution;
        container.validContributionIds[_contributionsCounter.current()] = true;

        ++container.totalDayContributions[currentDay];
        container.dayContributions[currentDay][_contributionsCounter.current()] = contribution;
        container.dayContributionsIds[currentDay].push(_contributionsCounter.current());

        emit ContributionCreated(from, _contributionsCounter.current(), block.timestamp, category, title, url);
    }

    /**
     * @notice Increment total days elapsed since contract's creation by 1
     *
     * @param _daysCounter The total days elapsed counter since contract's creation
     */
    function incrementDayCounter(Counters.Counter storage _daysCounter, address facadeProxyAddress) external {
        PseudoModifier.isFacadeCall(facadeProxyAddress, msg.sender);

        _daysCounter.increment();
    }

    /**
     * @notice Reset all the contributions data
     *
     * @param from  The address `from` who initiated the transaction
     * @param adminAddress The admin's address
     * @param container Total contributions data
     * @param _contributionsCounter Number of tokens emitted
     * @param _daysCounter The total days elapsed counter since contract's creation
     */
    function reset(
        address from,
        address adminAddress,
        DataTypes.Contributions storage container,
        Counters.Counter storage _contributionsCounter,
        Counters.Counter storage _daysCounter
    ) external {
        PseudoModifier.addressEq(adminAddress, from);

        uint256 contributionsLength = _contributionsCounter.current();
        uint256 dayContributionsLength = _daysCounter.current();
        uint256 upvotedIds = container.upvotedIds.length;
        uint256 downvotedIds = container.downvotedIds.length;
        uint256 upvoterAddresses = container.upvoterAddresses.length;
        uint256 downvoterAddresses = container.downvoterAddresses.length;

        for (uint256 i = 1; i <= contributionsLength; ++i) {
            delete container.contribution[i];
            delete container.validContributionIds[i];
        }

        for (uint256 i = 1; i <= dayContributionsLength; ++i) {
            uint256 totalContributionsOfDay = container.totalDayContributions[i];

            for (uint256 a = 0; a < totalContributionsOfDay; ++a) {
                delete container.dayContributions[i][container.dayContributionsIds[i][a]];
            }
        }

        for (uint256 i = 1; i <= upvotedIds; ++i) {
            for (uint256 a = 0; a < upvoterAddresses; ++a) {
                if (container.upvoted[i][container.upvoterAddresses[a]]) {
                    delete container.upvoted[i][container.upvoterAddresses[a]];
                }
            }
        }
        for (uint256 i = 1; i <= downvotedIds; ++i) {
            for (uint256 a = 0; a < downvoterAddresses; ++a) {
                if (container.downvoted[i][container.downvoterAddresses[a]]) {
                    delete container.downvoted[i][container.downvoterAddresses[a]];
                }
            }
        }

        delete container.upvotedIds;
        delete container.upvoterAddresses;
        delete container.downvotedIds;
        delete container.downvoterAddresses;
        _contributionsCounter.reset();
        _daysCounter.reset();
    }

    /**
     * @notice Get the contribution with id `contributionId`
     *
     * @param contributionId The contribution's id
     * @param container Total contributions data
     * @param _contributionsCounter Number of tokens emitted
     *
     * @return Contribution of type `DataTypes.Contribution`
     */
    function getContribution(
        uint256 contributionId,
        DataTypes.Contributions storage container,
        Counters.Counter storage _contributionsCounter
    )
        external
        view
        isValidContributionId(contributionId, container.validContributionIds)
        returns (DataTypes.Contribution memory)
    {
        PseudoModifier.isNotOutOfBounds(contributionId, _contributionsCounter);

        return container.contribution[contributionId];
    }

    /**
     * @notice Retrieve the most upvoted contribution for day counter `dayCounter`
     *
     * @param day The day since contract's creation to retrieve best contribution
     * @param _daysCounter The total days elapsed counter since contract's creation
     *
     * @return The most upvoted contribution
     */
    function topContribution(
        uint256 day,
        Counters.Counter storage _daysCounter,
        DataTypes.Contributions storage container
    ) external view returns (DataTypes.Contribution memory) {
        PseudoModifier.isNotOutOfBounds(day, _daysCounter);

        uint256 topVotes = 0;
        uint256 topContributionId = 0;
        uint256 dayContributionsLength = container.totalDayContributions[day];

        for (uint256 i = 0; i < dayContributionsLength; ++i) {
            for (uint256 a = 0; a < dayContributionsLength; ++a) {
                DataTypes.Contribution memory contribution = container.dayContributions[day][
                    container.dayContributionsIds[day][a]
                ];

                if (contribution.votes > topVotes) {
                    topContributionId = container.dayContributionsIds[day][a];
                    topVotes = contribution.votes;
                }
            }
        }

        return container.contribution[topContributionId];
    }
}
