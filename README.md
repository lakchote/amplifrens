# AmpliFrens

![Tests coverage](https://img.shields.io/badge/Coverage-100%25-brightgreen "Tests coverage")
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)

Keep up with the latest crypto news, make frens and prove your value to others (employers, DAOs, anons).

AmpliFrens helps you in 3 ways:

- With profiles, you can make yourself known by sharing important news.
- With statuses, you can meet people who are as deep in the crypto rabbit hole as you are.
- With news categories, you can stay updated on the news that matter to you.

## How it works

Every day, people can share crypto news and vote on the best contributions.

After 24 hours, the author of the best contribution receives a _Soulbound token_. This token proves his value and crypto knowledge.

By gaining more and more Soulbound tokens, one can level up to a new status that will give them exclusive perks.

There are 15 NFTs to reward the most important people for the AmpliFrens community. These NFTs give access to a private discord group.

## Architecture

The project uses composition over inheritance.

Under the hood, it implements the [Facade design pattern](https://en.wikipedia.org/wiki/Facade_pattern) to:

- hide project complexity
- minimise tight coupling
- ease subsystem access

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

## Install

1. Install dependencies

`yarn`

2. Compile smart contracts

`yarn compile`

3. Run tests

`yarn hardhat-local`
`yarn test`

## Coverage

**100% of the smart contracts are covered by tests.**

To check code coverage run the command:

`yarn coverage`

## The Graph

To use The Graph use the following steps:

1. Launch Hardhat node
   `yarn hardhat-local`

2. Launch The Graph
   `yarn graph-local`

3. Deploy The Graph locally
   `yarn graph-local-deploy`

4. Access subgraph UI
   `http://127.0.0.1:8000/subgraphs/name/amplifrens/`
