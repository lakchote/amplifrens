# AmpliFrens

![Tests coverage](https://img.shields.io/badge/Coverage-100%25-brightgreen "Tests coverage")
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)

Keep up with the latest crypto news, make frens and prove your value to others (employers, DAOs, anons).

AmpliFrens helps you in 4 ways:

- It gives you a decentralized reputation system to show off your general crypto knowledge (every day the author of the most upvoted contribution receives a soulbound token contributing to his status)
- With profiles, you can make yourself known by sharing important news.
- With statuses, you can meet people who are as deep in the crypto rabbit hole as you are.
- With news categories, you can stay updated on the news that matter to you.

## How it works

Every day, people can share crypto news and vote on the best contributions.

After 24 hours, the author of the best contribution receives a _Soulbound token_. This token proves his value and crypto knowledge thanks to the blockchain.

By gaining more and more Soulbound tokens, one can level up to a new status that will give them exclusive perks.

There are 15 NFTs to reward the most important people for the AmpliFrens community. These NFTs will give you access to a private discord group.


## Features

- Soulbound Token (_contracts/AmpliFrensSBT.sol_):
  - [EIP-4671](https://eips.ethereum.org/EIPS/eip-4671) draft with the following extensions
    - [IERC4671Enumerable](https://eips.ethereum.org/EIPS/eip-4671#enumerable)
    - [IERC4671Metadata](https://eips.ethereum.org/EIPS/eip-4671#metadata)
- [ERC721](https://ethereum.org/en/developers/docs/standards/tokens/erc-721/) compliant NFT(_contracts/AmpliFrensNFT.sol_):
  - [EIP-2891](https://eips.ethereum.org/EIPS/eip-2981) draft implementation for royalties
  - Images and metadata upload on [IPFS](https://ipfs.io/)
- Automated minting via [Chainlink Keeper](https://docs.chain.link/docs/chainlink-automation/introduction/)
- Transparent upgradeable proxy for the facade (_contracts/upgradeability/TransparentUpgradeableProxy.sol_):
  - [EIP-1967](https://eips.ethereum.org/EIPS/eip-1967)
  - [Why I chose Proxy instead of UUPS pattern](https://twitter.com/jeiwan7/status/1568911485602091009)
  - Data indexation with [The Graph](https://thegraph.com/en/)

## Coverage

**100% of the smart contracts are covered by tests.**

To check code coverage run the command:

`yarn coverage`

## Architecture

The project uses composition over inheritance.

Under the hood, it implements the [Facade design pattern](https://en.wikipedia.org/wiki/Facade_pattern) to:

- hide project complexity
- minimise tight coupling
- ease subsystem access

## Deployments

Project is deployed on:
- Mumbai
   - [Proxy](https://mumbai.polygonscan.com/address/0xDC6BA47de41736878d951CC4774eC2973f9Ca0A9)
   - [Impl](https://mumbai.polygonscan.com/address/0x10DC5b75D33955BB1a7393c5Fcf2c5ea4377e295)

## Install

1. Install dependencies

`yarn`

2. Compile smart contracts

`yarn compile`

3. Run tests

`yarn hardhat-local`
`yarn test`

## The Graph

### Prerequisites

1. Launch Docker daemon
2. Generate AssemblyScript for subgraph

   `yarn graph-codegen`

### Steps

To use The Graph use the following steps:

1. Launch Hardhat node
   `yarn hardhat-local`

2. Launch The Graph
   `yarn graph-local`

3. Deploy The Graph locally
   `yarn graph-local-deploy`

4. Access subgraph UI
   `http://127.0.0.1:8000/subgraphs/name/amplifrens/`

## NFTs

NFTs are deployed on IPFS:

- [images](https://ipfs.io/ipfs/QmQVjtxtx25WQ1tVv2AZGYkHTQbLHWhPWqbBHfKB54bjxw/)
- [metadata](https://ipfs.io/ipfs/QmcczjZpSKGSiAEPjm1VqU5xUeFLWrVtc61ZKZmwn6JDEF/)

## Room of improvements

- Use meta transactions to have a gasless experience for the user
- Use access roles in the future (example: to elect moderators voted by the community) 
