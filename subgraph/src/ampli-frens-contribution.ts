import { Address, BigInt } from "@graphprotocol/graph-ts";
import {
  ContributionCreated as ContributionCreatedEvent,
  ContributionDownvoted as ContributionDownvotedEvent,
  ContributionRemoved as ContributionRemovedEvent,
  ContributionUpdated as ContributionUpdatedEvent,
  ContributionUpvoted as ContributionUpvotedEvent,
} from "../generated/AmpliFrensContribution/AmpliFrensContribution";
import {
  ContributionCreated,
  ContributionDownvoted,
  ContributionRemoved,
  Contribution,
  ContributionUpdated,
  ContributionUpvoted,
  Profile,
} from "../generated/schema";

const deadAddress = Address.fromString("0x000000000000000000000000000000000000dEaD");

export function handleContributionCreated(event: ContributionCreatedEvent): void {
  const id = event.params.contributionId.toString();

  let entity = new ContributionCreated(id);
  entity.from = event.params.from;
  entity.contributionId = event.params.contributionId;
  entity.timestamp = event.params.timestamp;
  entity.category = event.params.category;
  entity.title = event.params.title;
  entity.url = event.params.url;
  entity.save();

  let contribution = new Contribution(id);
  contribution.from = event.params.from;
  contribution.contributionId = event.params.contributionId;
  contribution.timestamp = event.params.timestamp;
  contribution.category = event.params.category;
  contribution.title = event.params.title;
  contribution.url = event.params.url;
  contribution.votes = BigInt.fromI32(0);
  contribution.hasProfile = false;

  const profile = Profile.load(event.params.from.toHexString());
  if (profile) {
    contribution.hasProfile = true;
    contribution.username = profile.username;
  }

  contribution.save();
}

export function handleContributionDownvoted(event: ContributionDownvotedEvent): void {
  const id = event.params.contributionId.toString();

  let entity = new ContributionDownvoted(id);
  entity.from = event.params.from;
  entity.contributionId = event.params.contributionId;
  entity.timestamp = event.params.timestamp;
  entity.save();

  let contribution = Contribution.load(id);
  contribution!.votes = contribution!.votes.minus(BigInt.fromI32(1));
  contribution!.save();
}

export function handleContributionRemoved(event: ContributionRemovedEvent): void {
  const id = event.params.contributionId.toString();

  let entity = new ContributionRemoved(id);
  entity.from = event.params.from;
  entity.contributionId = event.params.contributionId;
  entity.timestamp = event.params.timestamp;
  entity.save();

  let contribution = Contribution.load(id);
  contribution!.from = deadAddress;
  contribution!.save();
}

export function handleContributionUpdated(event: ContributionUpdatedEvent): void {
  const id = event.params.contributionId.toString();

  let entity = new ContributionUpdated(id);
  entity.from = event.params.from;
  entity.contributionId = event.params.contributionId;
  entity.timestamp = event.params.timestamp;
  entity.category = event.params.category;
  entity.title = event.params.title;
  entity.url = event.params.url;
  entity.save();

  let contribution = Contribution.load(id);
  contribution!.timestamp = event.params.timestamp;
  contribution!.category = event.params.category;
  contribution!.title = event.params.title;
  contribution!.url = event.params.url;
  contribution!.save();
}

export function handleContributionUpvoted(event: ContributionUpvotedEvent): void {
  const id = event.params.contributionId.toString();

  let entity = new ContributionUpvoted(id);
  entity.from = event.params.from;
  entity.contributionId = event.params.contributionId;
  entity.timestamp = event.params.timestamp;
  entity.save();

  let contribution = Contribution.load(id);
  contribution!.votes = contribution!.votes.plus(BigInt.fromI32(1));
  contribution!.save();
}
