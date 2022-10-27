import { task } from "hardhat/config";

task("increase-time", "Increase time of the EVM").setAction(async (args, hre) => {
  console.log("Increasing time for the EVM...");
  await hre.network.provider.send("evm_increaseTime", [60 * 60 * 24]);
});
