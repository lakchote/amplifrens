// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IAmpliFrensContribution} from "./interfaces/IAmpliFrensContribution.sol";
import {DataTypes} from "./libraries/types/DataTypes.sol";
import {ContributionLogic} from "./libraries/logic/ContributionLogic.sol";

/**
 * @title AmpliFrensContribution
 * @author Lucien Akchoté
 *
 * @notice Handle the different contributions interactions
 * @custom:security-contact lakchote@icloud.com
 */
contract AmpliFrensContribution is IERC165, IAmpliFrensContribution {
    using Counters for Counters.Counter;

    Counters.Counter private _contributionsCounter;
    Counters.Counter private _daysCounter;

    DataTypes.Contributions internal contributions;

    address private immutable adminAddress;
    address private immutable facadeProxyAddress;

    /// @dev Contract initialization
    constructor(address _adminAddress, address _facadeProxyAddress) {
        adminAddress = _adminAddress;
        facadeProxyAddress = _facadeProxyAddress;
        _daysCounter.increment();
    }

    /// @inheritdoc IAmpliFrensContribution
    function upvote(uint256 contributionId, address from) external {
        ContributionLogic.upvote(contributionId, from, contributions);
    }

    /// @inheritdoc IAmpliFrensContribution
    function downvote(uint256 contributionId, address from) external {
        ContributionLogic.downvote(contributionId, from, contributions);
    }

    /// @inheritdoc IAmpliFrensContribution
    function remove(uint256 contributionId, address from) external {
        ContributionLogic.remove(contributionId, from, adminAddress, contributions, _contributionsCounter);
    }

    /// @inheritdoc IAmpliFrensContribution
    function update(
        uint256 contributionId,
        DataTypes.ContributionCategory category,
        string calldata title,
        string calldata url,
        address from
    ) external {
        ContributionLogic.update(contributionId, category, title, url, from, adminAddress, contributions);
    }

    /// @inheritdoc IAmpliFrensContribution
    function create(
        DataTypes.ContributionCategory category,
        string calldata title,
        string calldata url,
        address from
    ) external {
        ContributionLogic.create(
            category,
            title,
            url,
            from,
            facadeProxyAddress,
            contributions,
            _contributionsCounter,
            _daysCounter.current()
        );
    }

    /// @inheritdoc IAmpliFrensContribution
    function reset(address from) external {
        ContributionLogic.reset(from, adminAddress, contributions, _contributionsCounter, _daysCounter);
    }

    /// @inheritdoc IAmpliFrensContribution
    function incrementDayCounter() external {
        ContributionLogic.incrementDayCounter(_daysCounter, facadeProxyAddress);
    }

    /// @inheritdoc IAmpliFrensContribution
    function getContribution(uint256 contributionId) external view returns (DataTypes.Contribution memory) {
        return ContributionLogic.getContribution(contributionId, contributions, _contributionsCounter);
    }

    /// @inheritdoc IAmpliFrensContribution
    function topContribution() external view returns (DataTypes.TopContribution memory) {
        return ContributionLogic.topContribution(_daysCounter.current(), _daysCounter, contributions);
    }

    /// @inheritdoc IAmpliFrensContribution
    function contributionsCount() external view returns (uint256) {
        return _contributionsCounter.current();
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) external pure override(IERC165) returns (bool) {
        return type(IAmpliFrensContribution).interfaceId == interfaceId || type(IERC165).interfaceId == interfaceId;
    }
}
