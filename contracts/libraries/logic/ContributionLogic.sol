// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import {DataTypes} from "../types/DataTypes.sol";
import {Errors} from "../helpers/Errors.sol";

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
    event ContributionUpdated(address indexed from, uint256 indexed contributionId, uint256 timestamp);
    event ContributionRemoved(address indexed from, uint256 indexed contributionId, uint256 timestamp);
    event ContributionCreated(
        address indexed from,
        uint256 contributionId,
        uint256 timestamp,
        DataTypes.ContributionCategory category,
        string title,
        string url
    );

    /**
     * @notice Ensure that `msg.sender` is the contribution's author or he's the admin
     *
     * @param admin The admin's address
     * @param author The contribution's author address
     */
    modifier isAuthorOrAdmin(address admin, address author) {
        if (author != msg.sender && admin != msg.sender) revert Errors.Unauthorized();
        _;
    }

    /**
     * @notice Ensure that `msg.sender` is not the contribution's author
     *
     *
     * @dev Prevent own upvoting/downvoting use cases
     * @param author The contribution's author address
     */
    modifier isNotAuthor(address author) {
        if (author == msg.sender) revert Errors.Unauthorized();
        _;
    }

    /**
     * @notice Ensure that `msg.sender` has not voted already for a contribution
     *
     * @dev Prevent botting contributions score
     * @param hasVoted Boolean that indicates if `msg.sender` has already voted or not
     */
    modifier hasNotVotedAlready(bool hasVoted) {
        if (hasVoted) revert Errors.AlreadyVoted();
        _;
    }

    /**
     * @notice Upvote the contribution with id `contributionId`
     *
     * @param contributionId The contribution's id
     * @param container Total contributions data
     */
    function upvote(uint256 contributionId, DataTypes.Contributions storage container)
        external
        isNotAuthor(container.contribution[contributionId].author)
        hasNotVotedAlready(container.upvoted[contributionId][msg.sender])
    {
        DataTypes.Contribution storage contribution = container.contribution[contributionId];
        contribution.votes++;
        container.upvoted[contributionId][msg.sender] = true;
        container.upvoterAddresses.push(msg.sender);
        container.upvotedIds.push(contributionId);

        emit ContributionUpvoted(msg.sender, contributionId, block.timestamp);
    }

    /**
     * @notice Downvote the contribution with id `contributionId`
     *
     * @param contributionId The contribution's id
     * @param container Total contributions data
     */
    function downvote(uint256 contributionId, DataTypes.Contributions storage container)
        external
        isNotAuthor(container.contribution[contributionId].author)
        hasNotVotedAlready(container.downvoted[contributionId][msg.sender])
    {
        DataTypes.Contribution storage contribution = container.contribution[contributionId];
        contribution.votes--;
        container.downvoted[contributionId][msg.sender] = true;
        container.downvoterAddresses.push(msg.sender);
        container.downvotedIds.push(contributionId);

        emit ContributionDownvoted(msg.sender, contributionId, block.timestamp);
    }

    /**
     * @notice Remove the contribution with id `contributionId`
     *
     * @param contributionId The contribution's id
     * @param container Total contributions data
     * @param _contributionsCounter Number of tokens emitted
     */
    function remove(
        uint256 contributionId,
        DataTypes.Contributions storage container,
        Counters.Counter storage _contributionsCounter
    ) external isAuthorOrAdmin(container.adminAddress, container.contribution[contributionId].author) {
        delete (container.contribution[contributionId]);
        _contributionsCounter.decrement();

        emit ContributionRemoved(msg.sender, contributionId, block.timestamp);
    }

    /**
     * @notice Update the contribution with id `contributionId`
     *
     * @param contributionId The contribution's id
     * @param category The contribution's category
     * @param title The contribution's title
     * @param url The contribution's url
     * @param container Total contributions data
     */
    function update(
        uint256 contributionId,
        DataTypes.ContributionCategory category,
        string calldata title,
        string calldata url,
        DataTypes.Contributions storage container
    ) external isAuthorOrAdmin(container.adminAddress, container.contribution[contributionId].author) {
        DataTypes.Contribution storage contribution = container.contribution[contributionId];

        contribution.category = category;
        if (bytes8(bytes(title)) != 0x00) {
            contribution.title = title;
        }
        if (bytes(url).length > 0) {
            contribution.url = url;
        }

        emit ContributionUpdated(msg.sender, contributionId, block.timestamp);
    }

    /**
     * @notice Create a contribution of type `DataTypes.Contribution`
     *
     * @param category The contribution's category
     * @param title The contribution's title
     * @param url The contribution's url
     * @param container Total contributions data
     * @param _contributionsCounter Number of tokens emitted
     */
    function create(
        DataTypes.ContributionCategory category,
        string calldata title,
        string calldata url,
        DataTypes.Contributions storage container,
        Counters.Counter storage _contributionsCounter
    ) external {
        _contributionsCounter.increment();
        DataTypes.Contribution memory contribution = DataTypes.Contribution(
            msg.sender,
            category,
            true,
            block.timestamp,
            0,
            title,
            url
        );
        container.contribution[_contributionsCounter.current()] = contribution;

        emit ContributionCreated(msg.sender, _contributionsCounter.current(), block.timestamp, category, title, url);
    }

    /**
     * @notice Get the contribution with id `contributionId`
     *
     * @param contributionId The contribution's id
     * @param container Total contributions data
     * @return Contribution of type `DataTypes.Contribution`
     */
    function getContribution(uint256 contributionId, DataTypes.Contributions storage container)
        external
        view
        returns (DataTypes.Contribution memory)
    {
        return container.contribution[contributionId];
    }

    /**
     * @notice Reset all the contributions data
     *
     * @param container Total contributions data
     * @param _contributionsCounter Number of tokens emitted
     */
    function reset(DataTypes.Contributions storage container, Counters.Counter storage _contributionsCounter) external {
        uint256 contributionsLength = _contributionsCounter.current();
        uint256 upvotedIds = container.upvotedIds.length;
        uint256 downvotedIds = container.downvotedIds.length;
        uint256 upvoterAddresses = container.upvoterAddresses.length;
        uint256 downvoterAddresses = container.downvoterAddresses.length;

        for (uint256 i = 1; i <= contributionsLength; ++i) {
            delete container.contribution[i];
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
    }
}
