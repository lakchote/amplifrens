import { task } from "hardhat/config";
import addressesJson from "../addresses.json";

task("graph-generate", "Init, update, or add subgraph on deployed contracts").setAction(async (args, hre) => {
  const contracts = addressesJson["contracts"];

  await hre.run("graph", { contractName: "AmpliFrensNFT", address: contracts.AmpliFrensNFT });
  await hre.run("graph", { contractName: "AmpliFrensSBT", address: contracts.AmpliFrensSBT });
  await hre.run("graph", { contractName: "AmpliFrensContribution", address: contracts.AmpliFrensContribution });
  await hre.run("graph", { contractName: "AmpliFrensProfile", address: contracts.AmpliFrensProfile });
  await hre.run("graph", { contractName: "AmpliFrensFacade", address: contracts.facade.Proxy });
});
