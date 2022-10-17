import { BigInt } from "@graphprotocol/graph-ts";
import {
  SBTBestContribution as SBTBestContributionEvent,
  SBTMinted as SBTMintedEvent,
  SBTRevoked as SBTRevokedEvent,
} from "../generated/AmpliFrensSBT/AmpliFrensSBT";
import { SBTBestContribution, SBTLeaderboard, SBTMinted, SBTRevoked } from "../generated/schema";

export function handleSBTBestContribution(event: SBTBestContributionEvent): void {
  let entity = new SBTBestContribution(event.transaction.hash.toHex() + "-" + event.logIndex.toString());

  entity.from = event.params.from;
  entity.timestamp = event.params.timestamp;
  entity.category = event.params.category;
  entity.title = event.params.title;
  entity.url = event.params.url;
  entity.save();
}

export function handleSBTMinted(event: SBTMintedEvent): void {
  let entity = new SBTMinted(event.transaction.hash.toHex() + "-" + event.logIndex.toString());
  entity.owner = event.params.owner;
  entity.tokenId = event.params.tokenId;
  entity.timestamp = event.params.timestamp;
  entity.save();

  let sbtLeaderboard = SBTLeaderboard.load(event.params.owner.toHexString());
  if (!sbtLeaderboard) {
    sbtLeaderboard = new SBTLeaderboard(event.params.owner.toHexString());
    sbtLeaderboard.topContributionsCount = BigInt.fromI32(1);
  } else {
    sbtLeaderboard.topContributionsCount = sbtLeaderboard.topContributionsCount.plus(BigInt.fromI32(1));
  }
  sbtLeaderboard.save();
}

export function handleSBTRevoked(event: SBTRevokedEvent): void {
  let entity = new SBTRevoked(event.transaction.hash.toHex() + "-" + event.logIndex.toString());
  entity.owner = event.params.owner;
  entity.tokenId = event.params.tokenId;
  entity.timestamp = event.params.timestamp;
  entity.save();
}
