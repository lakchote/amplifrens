import { BigInt } from "@graphprotocol/graph-ts";
import {
  AmpliFrensSBT,
  SBTBestContribution as SBTBestContributionEvent,
  SBTMinted as SBTMintedEvent,
  SBTRevoked as SBTRevokedEvent,
} from "../generated/AmpliFrensSBT/AmpliFrensSBT";
import { Contribution, Profile, SBTBestContribution, SBTLeaderboard, SBTMinted, SBTRevoked, Status } from "../generated/schema";

export function handleSBTBestContribution(event: SBTBestContributionEvent): void {
  let entity = new SBTBestContribution(event.params.topContributionId.toString());

  entity.from = event.params.from;
  entity.timestamp = event.params.timestamp;
  entity.save();

  let contribution = Contribution.load(event.params.topContributionId.toString());
  if (contribution) {
    contribution.bestContribution = true;
    contribution.save();
  }
}

export function handleSBTMinted(event: SBTMintedEvent): void {
  let entity = new SBTMinted(event.transaction.hash.toHex() + "-" + event.logIndex.toString());
  let contract = AmpliFrensSBT.bind(event.address);

  entity.owner = event.params.owner;
  entity.tokenId = event.params.tokenId;
  entity.timestamp = event.params.timestamp;
  entity.save();

  let sbtLeaderboard = SBTLeaderboard.load(event.params.owner.toHexString());
  if (!sbtLeaderboard) {
    sbtLeaderboard = new SBTLeaderboard(event.params.owner.toHexString());
    sbtLeaderboard.topContributionsCount = BigInt.fromI32(1);
    const profile = Profile.load(event.params.owner.toHexString());
    if (profile) {
      sbtLeaderboard.username = profile.username;
    }
  } else {
    sbtLeaderboard.topContributionsCount = sbtLeaderboard.topContributionsCount.plus(BigInt.fromI32(1));
  }
  const status = contract.getStatus(event.params.owner);
  let ownerStatus = Status.load(event.params.owner.toHexString());
  if (!ownerStatus) ownerStatus = new Status(event.params.owner.toHexString());
  ownerStatus.status = status;
  ownerStatus.save();

  sbtLeaderboard.save();
}

export function handleSBTRevoked(event: SBTRevokedEvent): void {
  let entity = new SBTRevoked(event.transaction.hash.toHex() + "-" + event.logIndex.toString());
  entity.owner = event.params.owner;
  entity.tokenId = event.params.tokenId;
  entity.timestamp = event.params.timestamp;
  entity.save();
}
