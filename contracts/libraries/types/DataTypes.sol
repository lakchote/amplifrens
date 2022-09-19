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
     *  @notice Contains the basic information of a contribution
     *
     *  @dev Use tight packing to save up on storage cost
     *  4 storage slots used (string takes up 64 bytes or 2 slots in the storage)
     */
    struct Contribution {
        address author; /// @dev 20 bytes
        ContributionCategory category; /// @dev 1 byte
        bool valid; /// @dev 1 byte
        uint64 timestamp; /// @dev 8 bytes
        uint16 votes; /// @dev 2 bytes
        bytes32 title; /// @dev 32 bytes
        string url; /// @dev 64 bytes
    }

    /// @notice Contains the basic information of a profile
    struct Profile {
        bytes32 lensHandle;
        bytes32 discordHandle;
        bytes32 twitterHandle;
        bytes32 username;
        bytes32 email;
        string websiteUrl;
        bool valid;
    }

    /// @dev These time-related variables are used in conjunction to determine when minting function can be called
    struct MintingInterval {
        uint256 lastBlockTimestamp;
        uint256 mintInterval;
    }
}
