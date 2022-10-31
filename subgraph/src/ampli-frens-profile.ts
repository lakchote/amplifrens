import { Address } from "@graphprotocol/graph-ts";
import {
  ProfileBlacklisted as ProfileBlacklistedEvent,
  ProfileCreated as ProfileCreatedEvent,
  ProfileDeleted as ProfileDeletedEvent,
  ProfileUpdated as ProfileUpdatedEvent,
} from "../generated/AmpliFrensProfile/AmpliFrensProfile";
import { Profile, ProfileBlacklisted, ProfileCreated, ProfileDeleted, ProfileUpdated } from "../generated/schema";

const deadAddress = Address.fromString("0x000000000000000000000000000000000000dEaD");

export function handleProfileBlacklisted(event: ProfileBlacklistedEvent): void {
  const id = event.params._address.toHexString();

  let entity = new ProfileBlacklisted(id);
  entity._address = event.params._address;
  entity.reason = event.params.reason;
  entity.timestamp = event.params.timestamp;
  entity.save();

  const profile = Profile.load(id);
  profile!.address = deadAddress;
  profile!.timestamp = event.params.timestamp;
  profile!.save();
}

export function handleProfileCreated(event: ProfileCreatedEvent): void {
  const id = event.params._address.toHexString();

  let entity = new ProfileCreated(id);
  entity._address = event.params._address;
  entity.timestamp = event.params.timestamp;
  entity.username = event.params.username;
  entity.save();

  const profile = new Profile(id);
  profile.address = event.params._address;
  profile.username = event.params.username;
  profile.timestamp = event.params.timestamp;
  profile.save();
}

export function handleProfileDeleted(event: ProfileDeletedEvent): void {
  const id = event.params._address.toHexString();

  let entity = new ProfileDeleted(id);
  entity._address = event.params._address;
  entity.timestamp = event.params.timestamp;
  entity.save();

  const profile = Profile.load(id);
  profile!.address = deadAddress;
  profile!.timestamp = event.params.timestamp;
  profile!.save();
}

export function handleProfileUpdated(event: ProfileUpdatedEvent): void {
  const id = event.params._address.toHexString();

  let entity = new ProfileUpdated(id);
  entity._address = event.params._address;
  entity.timestamp = event.params.timestamp;
  entity.save();

  const profile = Profile.load(id);
  profile!.username = event.params.username;
  profile!.timestamp = event.params.timestamp;
  profile!.save();
}
