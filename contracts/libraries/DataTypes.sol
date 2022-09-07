// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

/**
 * @title DataTypes
 * @author Lucien Akchoté
 *
 * @notice A standard library of data types used throughout AmpliFrens
 */
library DataTypes {
    /// @notice Contains the different statuses depending on tokens earnt
    enum FrenStatus {
        Anon, /// @notice 5 tokens
        Degen, /// @notice 10 tokens
        Pepe, /// @notice 15 tokens
        Contributoor, /// @notice 30 tokens
        Aggregatoor, /// @notice 60 tokens
        Oracle /// @notice 100 tokens
    }

    /// @notice Contains the different contributions categories
    enum ContributionCategory {
        NFT,
        Article,
        DeFi,
        Security,
        Thread,
        GameFi,
        Video,
        Misc
    }

    /**
     *  @dev Use tight packing to save up on storage cost
     *  5 storage slots used (string takes up 64 bytes or 2 slots in the storage)
     */
    struct Contribution {
        address owner; /// @dev 20 bytes
        ContributionCategory category; /// @dev 1 byte
        bool valid; /// @dev 1 byte
        uint40 timestamp; /// @dev 5 bytes
        uint40 votes; /// @dev 5 bytes
        string title; /// @dev 64 bytes
        string url; /// @dev 64 bytes
    }
}
