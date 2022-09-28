// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../../interfaces/IAmpliFrensContribution.sol";

/// @notice This is a contract to test specific events are triggered
/// @dev Enables facade forwarding tests
contract AmpliFrensContributionFacadeMock is IAmpliFrensContribution {
    DataTypes.Contribution[] contributions;

    event ContributionContract();

    constructor() {
        contributions.push(
            DataTypes.Contribution(
                address(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045),
                DataTypes.ContributionCategory(7),
                true,
                uint64(1664280770),
                1337,
                "You won't believe this WL",
                "https://notboredapeyachtclub.com/whitelist"
            )
        );
    }

    function upvote(uint256) external override {
        emit ContributionContract();
    }

    function downvote(uint256) external override {
        emit ContributionContract();
    }

    function remove(uint256) external override {
        emit ContributionContract();
    }

    function update(
        uint256,
        DataTypes.ContributionCategory,
        bytes32,
        string calldata
    ) external override {
        emit ContributionContract();
    }

    function create(
        DataTypes.ContributionCategory,
        bytes32,
        string calldata
    ) external override {
        emit ContributionContract();
    }

    function reset() external override {
        emit ContributionContract();
    }

    function getContributions() external view override returns (DataTypes.Contribution[] memory) {
        return contributions;
    }

    function getContribution(uint256) external pure override returns (DataTypes.Contribution memory) {
        return
            DataTypes.Contribution(
                address(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045),
                DataTypes.ContributionCategory(7),
                true,
                uint64(1664280770),
                1337,
                "You won't believe this WL",
                "https://notboredapeyachtclub.com/whitelist"
            );
    }

    function topContribution() external pure override returns (DataTypes.Contribution memory) {
        return
            DataTypes.Contribution(
                address(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045),
                DataTypes.ContributionCategory(7),
                true,
                uint64(1664280770),
                1337,
                "You won't believe this WL",
                "https://notboredapeyachtclub.com/whitelist"
            );
    }

    function contributionsCount() external pure override returns (uint256) {
        return 31337;
    }
}
