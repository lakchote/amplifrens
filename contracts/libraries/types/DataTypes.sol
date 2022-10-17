// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

/**
 * @title DataTypes
 * @author Lucien Akchoté
 *
 * @notice A standard library of data types used throughout AmpliFrens
 */
library DataTypes {
    /// @notice Contain the different statuses depending on tokens earnt
    enum FrenStatus {
        Anon,
        Degen,
        Pepe,
        Contributoor,
        Aggregatoor,
        Oracle
    }

    /// @notice Contain the different contributions categories
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
     *  @notice Contain the basic information of a contribution
     *
     *  @dev Use tight packing to save up on storage cost
     *  7 storage slots used (string takes up 64 bytes or 2 slots in the storage)
     */
    struct Contribution {
        address author; /// @dev 20 bytes
        ContributionCategory category; /// @dev 1 byte
        bool valid; /// @dev 1 byte
        uint256 timestamp; /// @dev 32 bytes
        uint256 votes;
        uint256 dayCounter;
        string title;
        string url;
    }

    /**
     * @notice Contain contributions data
     *
     * @dev address[] && uint256[] are used to iterate over upvoted/downvoted mappings for reset function
     */
    struct Contributions {
        mapping(uint256 => mapping(uint256 => DataTypes.Contribution)) dayContributions;
        mapping(uint256 => uint256[]) dayContributionsIds;
        mapping(uint256 => uint256) totalDayContributions;
        mapping(uint256 => bool) validContributionIds;
        mapping(uint256 => DataTypes.Contribution) contribution;
        mapping(uint256 => mapping(address => bool)) upvoted;
        mapping(uint256 => mapping(address => bool)) downvoted;
        address[] upvoterAddresses;
        address[] downvoterAddresses;
        uint256[] upvotedIds;
        uint256[] downvotedIds;
    }

    /**
     * @notice Contain the basic information of a profile
     *
     * @see `https://docs.soliditylang.org/en/latest/types.html#bytes-and-string-as-arrays`
     */
    struct Profile {
        string lensHandle;
        string discordHandle;
        string twitterHandle;
        string username;
        string email;
        string websiteUrl;
        bool valid;
    }

    /**
     * @notice These time-related variables are used in conjunction to determine when minting function can be called
     *
     * @dev No tight packing possible, max bytes32 value(2^32-1) will be reached in 2038
     */
    struct MintingInterval {
        uint256 lastBlockTimestamp;
        uint256 mintInterval;
    }

    /**
     * @notice Contain token's URI data
     */
    struct URIStorage {
        string baseURI;
    }
}
