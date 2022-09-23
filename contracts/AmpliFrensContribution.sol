// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IAmpliFrensContribution} from "./interfaces/IAmpliFrensContribution.sol";
import {DataTypes} from "./libraries/types/DataTypes.sol";
import {PseudoModifier} from "./libraries/guards/PseudoModifier.sol";
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

    DataTypes.Contributions internal contributions;

    address public immutable facadeProxy;

    /// @dev Contract initialization with facade's proxy address precomputed
    constructor(address _facadeProxy) {
        facadeProxy = _facadeProxy;
        contributions.adminAddress = _facadeProxy;
    }

    /// @inheritdoc IAmpliFrensContribution
    function upvote(uint256 contributionId) external {
        PseudoModifier.isNotOutOfBounds(contributionId, _contributionsCounter);
        ContributionLogic.upvote(contributionId, contributions);
    }

    /// @inheritdoc IAmpliFrensContribution
    function downvote(uint256 contributionId) external {
        PseudoModifier.isNotOutOfBounds(contributionId, _contributionsCounter);
        ContributionLogic.downvote(contributionId, contributions);
    }

    /// @inheritdoc IAmpliFrensContribution
    function remove(uint256 contributionId) external {
        PseudoModifier.isNotOutOfBounds(contributionId, _contributionsCounter);
        ContributionLogic.remove(contributionId, contributions, _contributionsCounter);
    }

    /// @inheritdoc IAmpliFrensContribution
    function update(
        uint256 contributionId,
        DataTypes.ContributionCategory category,
        bytes32 title,
        string calldata url
    ) external {
        PseudoModifier.isNotOutOfBounds(contributionId, _contributionsCounter);
        ContributionLogic.update(contributionId, category, title, url, contributions);
    }

    /// @inheritdoc IAmpliFrensContribution
    function create(
        DataTypes.ContributionCategory category,
        bytes32 title,
        string calldata url
    ) external {
        ContributionLogic.create(category, title, url, contributions, _contributionsCounter);
    }

    /// @inheritdoc IAmpliFrensContribution
    function reset() external {
        PseudoModifier.addressEq(facadeProxy, msg.sender);
        ContributionLogic.reset(contributions, _contributionsCounter);
    }

    /// @inheritdoc IAmpliFrensContribution
    function getContributions() external view returns (DataTypes.Contribution[] memory) {
        return ContributionLogic.getContributions(contributions, _contributionsCounter);
    }

    /// @inheritdoc IAmpliFrensContribution
    function getContribution(uint256 contributionId) external view returns (DataTypes.Contribution memory) {
        PseudoModifier.isNotOutOfBounds(contributionId, _contributionsCounter);
        return ContributionLogic.getContribution(contributionId, contributions);
    }

    /// @inheritdoc IAmpliFrensContribution
    function topContribution() external view returns (DataTypes.Contribution memory) {
        return ContributionLogic.topContribution(contributions, _contributionsCounter);
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
