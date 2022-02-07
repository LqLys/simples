// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    // We get the contract to deploy
    const SecretStuff = await hre.ethers.getContractFactory("SecretStuff");
    const secretStuff = await SecretStuff.deploy('https://kaszojady.herokuapp.com/api/metadata/simples/', '0x96c4abbbb9dd027813f2b8c2c4917b15bb46b3c8d595841148f2de33d0c4d6ae',
        '0x630d56621cf1a7e28c5373e27f73148778b52a3050a8196b0f14761c44220ece', '0x1f62655901b37227b56bc225f83198ff688bfdaf330551d424ee719d7cc877f1');

    await secretStuff.deployed();

    console.log("SecretStuff deployed to:", secretStuff.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
