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
    const secretStuff = await SecretStuff.deploy('https://kaszojady.herokuapp.com/api/metadata/simples/',
        '0xd61e10f708873e131de88051bec04863244816e391c541728f35c2afa429ddf4',
        '0x810c35cd24039f797f1a00269b919798eeba36e808ba9450059ba66c328cc316',
        '0x96df715e388d599f8580c6eef7c9dbedd2457ff31b5d73f1993dfc8b039365ae');

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
