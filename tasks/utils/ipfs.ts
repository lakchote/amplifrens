import { config } from "dotenv";
import pinataSDK from "@pinata/sdk";
import fse from "fs-extra";

config();

const { PINATA_API_KEY, PINATA_API_SECRET } = process.env;
const pinata = pinataSDK(PINATA_API_KEY!, PINATA_API_SECRET!);

export async function deployCollectionToIpfs(
  dirAbsolutePath: string,
  collectionDescription: string,
  collectionName: string
): Promise<string> {
  console.log("Uploading images to IPFS with Pinata...");

  const pinNFTsImages = await pinata.pinFromFS(dirAbsolutePath!);

  const metadataPath = dirAbsolutePath + "/metadata";
  console.log(`Creating metadata JSON files in ${metadataPath} dir...`);

  for (let i = 1; i <= 15; i++) {
    const jsonBody = {
      description: collectionDescription,
      image: `ipfs://${pinNFTsImages.IpfsHash}/${i}.jpeg`,
      name: collectionName,
    };
    const fileName = `${metadataPath}/${i}.json`;
    try {
      await fse.outputJSON(fileName, jsonBody);
    } catch (e) {
      console.error("There was en error generating JSON files for NFT metadata.");
      throw e;
    }
  }
  console.log("Uploading NFTs metadata to IPFS with Pinata...");

  const pinNFTsMetadata = await pinata.pinFromFS(metadataPath!);

  return pinNFTsMetadata.IpfsHash;
}
