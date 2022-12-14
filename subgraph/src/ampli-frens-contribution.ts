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
  Status,
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
  contribution.bestContribution = false;

  const profile = Profile.load(event.params.from.toHexString());
  if (profile) {
    contribution.hasProfile = true;
    contribution.username = profile.username;
  }

  const fromStatus = Status.load(event.params.from.toHexString());
  contribution.fromStatus = fromStatus ? fromStatus.status : 0;

  contribution.save();
}

export function handleContributionDownvoted(event: ContributionDownvotedEvent): void {
  let entity = new ContributionDownvoted(
    event.params.contributionId.toString() + "-" + event.params.from.toHexString()
  );
  entity.from = event.params.from;
  entity.contributionId = event.params.contributionId;
  entity.timestamp = event.params.timestamp;
  entity.save();

  let contributionUpvoted = ContributionUpvoted.load(
    event.params.contributionId.toString() + "-" + event.params.from.toHexString()
  );
  if (contributionUpvoted) {
    contributionUpvoted.from = deadAddress;
    contributionUpvoted.save();
  }

  let contribution = Contribution.load(event.params.contributionId.toString());
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
  let entity = new ContributionUpvoted(event.params.contributionId.toString() + "-" + event.params.from.toHexString());
  entity.from = event.params.from;
  entity.contributionId = event.params.contributionId;
  entity.timestamp = event.params.timestamp;
  entity.save();

  let contributionDownvoted = ContributionDownvoted.load(
    event.params.contributionId.toString() + "-" + event.params.from.toHexString()
  );
  if (contributionDownvoted) {
    contributionDownvoted.from = deadAddress;
    contributionDownvoted.save();
  }

  let contribution = Contribution.load(event.params.contributionId.toString());
  contribution!.votes = contribution!.votes.plus(BigInt.fromI32(1));
  contribution!.save();
}
