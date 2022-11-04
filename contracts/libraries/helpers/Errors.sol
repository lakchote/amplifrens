// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

/**
 * @title Errors
 * @author Lucien Akchoté
 *
 * @notice Regroup all the different errors used throughout AmpliFrens
 * @dev Use custom errors to save gas
 */
library Errors {
    /// @dev Generic errors
    error Unauthorized();
    error OutOfBounds();
    error NotImplemented();
    error AddressNull();

    /// @dev Profile errors
    error NoProfileWithAddress();
    error NoProfileWithSocialHandle();
    error EmptyUsername();
    error UsernameExist();
    error NotBlacklisted();

    /// @dev Contribution errors
    error AlreadyVoted();
    error NotAuthorOrAdmin();
    error NotAuthor();
    error NoTopContribution();

    /// @dev NFT errors
    error MaxSupplyReached();
    error AlreadyOwnNft();

    /// @dev SBT errors
    error MintingIntervalNotMet();
}
