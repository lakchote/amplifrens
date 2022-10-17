import { task } from "hardhat/config";

task("increase-time", "Increase time of the EVM").setAction(async (args, hre) => {
  await hre.network.provider.send("evm_increaseTime", [1000 * 60 * 60 * 24]);
  await hre.network.provider.send("evm_mine");
});
