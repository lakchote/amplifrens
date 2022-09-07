// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title AmpliFrensSBT
 * @author Lucien Akchoté
 *
 * @notice This is a mock to make upgradeability of AmpliFrensSBT contract fail
 * @dev Upgradeability test with wrong storage layout
 * @custom:security-contact lakchote@icloud.com
 * @custom:oz-upgrades-unsafe-allow external-library-linking
 */
contract AmpliFrensSBTWrongUpgradeMock is UUPSUpgradeable {
    /// @notice Interval to ensure minting can occur at specific period
    /// @dev Mint interval that will be compared with two timestamps : `lastBlockTimeStamp` and `block.timestamp`
    uint256 public mintInterval;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __UUPSUpgradeable_init();
        mintInterval = 1 days;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        virtual
        override
    {}
}
