import { task } from "hardhat/config";
import addressesJson from "../../addresses.json";

task("perform-upkeep", "Perform upkeep to mint contribution of the day").setAction(async (args, hre) => {
  const ethers = hre.ethers;
  const accounts = await ethers.getSigners();
  const facadeFactory = await ethers.getContractFactory("AmpliFrensFacade");
  const proxyContract = facadeFactory.attach(addressesJson.contracts.facade.Proxy);

  console.log("Performing upkeep...");
  const performUpkeepTx = await proxyContract.connect(accounts[2]).performUpkeep(ethers.utils.toUtf8Bytes("0x00"));
  await performUpkeepTx.wait();
});
