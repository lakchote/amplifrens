// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../../interfaces/IAmpliFrensContribution.sol";

/// @notice This is a contract to test specific events are triggered
/// @dev Enables facade forwarding tests
contract AmpliFrensContributionFacadeMock is IAmpliFrensContribution {
    DataTypes.Contribution[] contributions;

    event ContributionContract();

    function upvote(uint256, address) external override {
        emit ContributionContract();
    }

    function downvote(uint256, address) external override {
        emit ContributionContract();
    }

    function remove(uint256, address) external override {
        emit ContributionContract();
    }

    function update(
        uint256,
        DataTypes.ContributionCategory,
        string calldata,
        string calldata,
        address
    ) external override {
        emit ContributionContract();
    }

    function create(
        DataTypes.ContributionCategory,
        string calldata,
        string calldata,
        address
    ) external override {
        emit ContributionContract();
    }

    function reset(address) external override {
        emit ContributionContract();
    }

    function getContribution(uint256) external pure override returns (DataTypes.Contribution memory) {
        return
            DataTypes.Contribution(
                address(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045),
                DataTypes.ContributionCategory(7),
                true,
                1664280770,
                1337,
                1,
                "You won't believe this WL",
                "https://notboredapeyachtclub.com/whitelist"
            );
    }

    function topContribution() external pure returns (DataTypes.Contribution memory) {
        return
            DataTypes.Contribution(
                address(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045),
                DataTypes.ContributionCategory(7),
                true,
                1664280770,
                1337,
                1,
                "The best contribution",
                "https://ethereum.org/en/whitepaper"
            );
    }

    function contributionsCount() external pure override returns (uint256) {
        return 31337;
    }

    function incrementDayCounter() external pure {}
}
