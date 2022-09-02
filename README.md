# AmpliFrens

![Tests coverage](https://img.shields.io/badge/Coverage-100%25-brightgreen "Tests coverage")
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)

Stay up to date with latest crypto news, make frens, and earn special perks by contributing.

## Features
- Soulbound Token (*contracts/AmpliFrensSBT.sol*):
    - [EIP-4671](https://eips.ethereum.org/EIPS/eip-4671) draft with the following extensions
        - [IERC4671Enumerable](https://eips.ethereum.org/EIPS/eip-4671#enumerable)
        - [IERC4671Metadata](https://eips.ethereum.org/EIPS/eip-4671#metadata)
    - [UUPS](https://eips.ethereum.org/EIPS/eip-1822) draft to allow contract upgradeability
    - Custom logic
        - Minting once per day only
- [ERC721](https://ethereum.org/en/developers/docs/standards/tokens/erc-721/) compliant NFT(*contracts/AmpliFrensNFT.sol*):
    - [EIP-2891](https://eips.ethereum.org/EIPS/eip-2981) draft implementation for royalties
    - Custom logic
        - Max supply : 100
        - Only one per person allowed

## External contracts and libraries

The following contracts and libraries are from [OpenZeppelin](https://www.openzeppelin.com/)

### Contracts:
- [ERC721](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol)
- [ERC721URIStorage](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol)
- [ERC721Royalty](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Royalty.sol)
- [AccessControl](https://docs.openzeppelin.com/contracts/4.x/api/access)

### For ugpradeability: 
- [PausableUpgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/security/PausableUpgradeable.sol)
- [AccessControlUpgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/access/AccessControlUpgradeable.sol)
- [Initializable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/proxy/utils/Initializable.sol)
- [UUPSUpgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/proxy/utils/UUPSUpgradeable.sol)

### Libraries:
- [Strings](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol)
- [Counters](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol)

## Install

1. Install dependencies

`yarn install`

2. Compile smart contracts

`yarn hardhat compile`

3. Run tests

`yarn hardhat test`

## Coverage
100% of the smart contracts are covered by tests.

To check the coverage of the code run the command

`yarn hardhat coverage`