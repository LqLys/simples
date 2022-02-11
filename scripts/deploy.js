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
    const TheSimples = await hre.ethers.getContractFactory("TheSimples");
    const theSimples = await TheSimples.deploy('https://simples-api.herokuapp.com/api/metadata/simples/',
        '0xd25414f4e1feb4a6d9eb331c5740aeb69aedf09d800c7b4910b8d98d8de13c5d',
        '0x632c01a1ccdfa4ad62c0e4554fdc2632475178bec6a1273c8503c37575be6be7',
        '0xdc4b12260b51bb09533c5c8d4bf39aa240b97a672a72fd5ea4c733e63ecb26f2');

    await theSimples.deployed();

    console.log("SecretStuff deployed to:", theSimples.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
