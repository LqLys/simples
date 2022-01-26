<script>
    import {ethers} from "ethers";
    import SecretStuff from "./artifacts/contracts/SecretStuff.sol/SecretStuff.json";
    import {onDestroy, onMount} from "svelte";

    const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
    let isPresaleMintActive = false;
    let isPublicMintActive = false;
    let currentAccount;
    let currentAddressRole;

    onMount(async () => {
        if (typeof window.ethereum === "undefined") {
            setTimeout(() => {
                alert("You need to have Metamask installed.");
            }, 1000)

        } else {

            try {
                isPresaleMintActive = await isPresaleActive();
                isPublicMintActive = await isPublicActive();
                console.log(isPresaleMintActive)
            } catch (err) {
                console.log(err);
            }
            setTimeout(() => {
                if (window.ethereum.networkVersion !== '1') {
                    alert('Change network to mainnet')
                }
            }, 1000)

            window.ethereum.on("chainChanged", handleChainChanged)
            window.ethereum.on("accountsChanged", handleAccountsChanged)
            window.ethereum.on("disconnect", handleDisconnect)
        }
    })

    onDestroy(() => {
        window.ethereum.removeListener("chainChanged", handleChainChanged)
        window.ethereum.removeListener("accountsChanged", handleAccountsChanged)
        window.ethereum.removeListener("disconnect", handleDisconnect)
    })

    const handleAccountsChanged = async () => {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const addresses = await provider.listAccounts();
        if (addresses.length === 0) {
            console.log("Please connect to Metamask");
            currentAccount = null;
        } else if (addresses[0] !== currentAccount) {
            currentAccount = addresses[0];
            currentAddressRole = await getRole(currentAccount);
        }
    };

    const handleChainChanged = () => {
        window.location.reload();
    }

    const handleDisconnect = () => {
        currentAccount = null;
        window.location.reload();
    }

    async function requestAccount() {
        await window.ethereum.request({method: "eth_requestAccounts"});
    }

    const genesisFreeClaim = async () => {
        if (typeof window.ethereum !== "undefined") {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const contract = new ethers.Contract(contractAddress, SecretStuff.abi, signer);
            const mmAddress = await signer.getAddress();
            const proofForAddress = await getProofForRoleAndAddress(mmAddress.toLowerCase(), currentAddressRole);
            if (proofForAddress) {
                try {
                    const transaction = await contract.genesisMint(proofForAddress)
                    await transaction.wait();
                } catch (err) {
                    const errMsg = err.data?.message;
                    if (errMsg?.includes("Max mints exceeded")) {
                        alert("You have already claimed your token")
                    }
                    console.log(err?.data?.message);
                }
            } else {
                alert("This wallet address is not eligible for presale")
            }
        }
    }

    const genesisWhitelistMint = async () => {

        if (typeof window.ethereum !== "undefined") {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const contract = new ethers.Contract(contractAddress, SecretStuff.abi, signer);
            const mmAddress = await signer.getAddress();
            const proofForAddress = await getProofForRoleAndAddress(mmAddress.toLowerCase(), 'wl');
            if (proofForAddress) {
                try {
                    const options = {
                        value: ethers.utils.parseEther("0.11")
                    }
                    const transaction = await contract.whitelistMint([...proofForAddress], options)
                    await transaction.wait();
                } catch (err) {
                    console.log(err)
                    const errMsg = err.data?.message;
                    if (errMsg.includes("Max mints exceeded")) {
                        alert("You have already minted your token")
                    }
                    console.log(err?.data?.message);
                }
            } else {
                alert("This wallet address is not eligible for presale")
            }
        }
    };

    const earlyBirdMint = async () => {

        if (typeof window.ethereum !== "undefined") {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const contract = new ethers.Contract(contractAddress, SecretStuff.abi, signer);
            const mmAddress = await signer.getAddress();
            const proofForAddress = await getProofForRoleAndAddress(mmAddress.toLowerCase(), currentAddressRole);
            if (proofForAddress) {
                console.log(proofForAddress);
                try {
                    const options = {
                        value: ethers.utils.parseEther("0.055")
                    }
                    console.log('proof', proofForAddress);

                    const transaction = await contract.earlyBirdMint([...proofForAddress], options)
                    await transaction.wait();
                    // console.log(`${1} successfully minted`);
                    // console.log("transaction: ", transaction);
                } catch (err) {
                    console.log(err)
                    const errMsg = err.data?.message;
                    if (errMsg?.includes("Max mints exceeded")) {
                        alert("You have already minted your token")
                    }
                    console.log(err?.data?.message);
                }
            } else {
                alert("This wallet address is not eligible for presale")
            }
        }
    }

    const whitelistMint = async () => {

        if (typeof window.ethereum !== "undefined") {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const contract = new ethers.Contract(contractAddress, SecretStuff.abi, signer);
            const mmAddress = await signer.getAddress();
            const proofForAddress = await getProofForRoleAndAddress(mmAddress.toLowerCase(), currentAddressRole);
            if (proofForAddress) {
                console.log(proofForAddress);
                try {
                    const options = {
                        value: ethers.utils.parseEther("0.11")
                    }
                    console.log('proof', proofForAddress);

                    const transaction = await contract.whitelistMint([...proofForAddress], options)
                    await transaction.wait();
                } catch (err) {
                    console.log(err)
                    const errMsg = err.data?.message;
                    if (errMsg?.includes("Max mints exceeded")) {
                        alert("You have already minted your token")
                    }
                    console.log(err?.data?.message);
                }
            } else {
                alert("This wallet address is not eligible for presale")
            }
        }
    }
    const publicMint = async () => {
        if (typeof window.ethereum !== "undefined") {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const contract = new ethers.Contract(contractAddress, SecretStuff.abi, signer);
            try {
                const options = {
                    value: ethers.utils.parseEther("0.11")
                }
                const transaction = await contract.publicMint(options)
                await transaction.wait();
            } catch (err) {
                console.log(err)
                const errMsg = err.data?.message;
                if (errMsg?.includes("Max mints exceeded")) {
                    alert("You have already minted your token")
                }
                console.log(err?.data?.message);
            }
        } else {
            alert("This wallet address is not eligible for presale")
        }

    }


    async function togglePresaleMint() {
        if (typeof window.ethereum !== "undefined") {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const contract = new ethers.Contract(contractAddress, SecretStuff.abi, signer);
            const transaction = await contract.togglePresaleMint();
            await transaction.wait();

        }
    }

    async function togglePublicMint() {
        if (typeof window.ethereum !== "undefined") {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const contract = new ethers.Contract(contractAddress, SecretStuff.abi, signer);
            const transaction = await contract.togglePublicMint();
            await transaction.wait();
        }
    }

    async function isPresaleActive() {
        if (typeof window.ethereum !== "undefined") {
            try {
                const provider = new ethers.providers.Web3Provider(window.ethereum);
                const signer = provider.getSigner();
                const contract = new ethers.Contract(contractAddress, SecretStuff.abi, signer);
                return await contract.isPresaleActive();
            } catch (err) {
                return false;
            }

        }
    }

    async function isPublicActive() {
        if (typeof window.ethereum !== "undefined") {
            try {
                const provider = new ethers.providers.Web3Provider(window.ethereum);
                const signer = provider.getSigner();
                const contract = new ethers.Contract(contractAddress, SecretStuff.abi, signer);
                return await contract.isPublicActive();
            } catch (err) {
                return false;
            }

        }
    }

    const connectWallet = async () => {
        try {
            const accounts = await window.ethereum.request({method: "eth_requestAccounts"});
            currentAccount = accounts[0];
            currentAddressRole = await getRole(currentAccount);
        } catch (err) {
            console.log(err);
        }

    }

    const getRole = async address => {
        try {
            const response = await fetch(`http://localhost:8080/api/role/${address}`)
            const roleJson = await response.json();
            return roleJson.role;
        } catch (err) {
            console.log(err);
            return "none"
        }
    }

    const getProofForRoleAndAddress = async (address, role) => {
        try {
            const response = await fetch(`http://localhost:8080/api/proof?wallet=${address}&role=${role}`)
            const proofJson = await response.json();
            console.log("proof: ", proofJson)
            return proofJson.proof;
        } catch (err) {
            console.log(err);
            return [];
        }
    }

    const disconnectWallet = () => {
        currentAccount = null;
    };


</script>

<main>
    <div align="center"><img src="00a.png" style="width: 100%;" alt="img"></div>
    <div>
        <table style="width: 80%; border-collapse: collapse; border-style: hidden; margin-left: auto; margin-right: auto;"
               border="0">
            <tbody>
            <tr>
                <td style="width: 100%;">
                    <h2 style="text-align: center;"><strong>
                        <a href="https://twitter.com/thesimplesart" target="_blank" rel="noopener">Twitter</a>&nbsp;
                        &nbsp;
                        <a href="https://www.instagram.com/thesimples.art/" target="_blank" rel="noopener">Instagram</a>&nbsp;
                        &nbsp;
                        <a href="https://discord.gg/RCn2TdchEP" target="_blank" rel="noopener">Discord</a>&nbsp; &nbsp;
                        <a href="https://opensea.io/collection/the-simples-genesis" target="_blank" rel="noopener">The
                            Simples - Genesis</a>
                    </strong></h2>
                    <br><br>
                    <div style="text-align: center;"><strong>What are The Simples? What they"re all about? Why are they?
                        <br/>What is there for me?</strong></div>
                    <br/>
                    <div>Simples are like children. Running around in all directions. Some of them are planning to go to
                        a gallery and some want to be avatars all over the internet. Big pack of Simples wants to get to
                        the real world. Some of them think to be very serious but really The Simples just want to have
                        fun and discover new interesting stuff to do. As they don"t know what they"re doing most of the
                        time, they can cause some trouble along the way. If They do, Simples always say "sorry" and then
                        get better at it! And then go back to being silly.
                    </div>
                    <div>&nbsp;</div>
                    <div style="text-align: center;"><strong>All Simples are unique, just like all of us.</strong></div>
                    <div style="text-align: center;"><strong>Simple - Freedom</strong></div>
                    <br/>
                    <div><strong>What are Simples all about?</strong> - mixing virtual world with the real one.
                        Blockchain and token NFT technology is the beautifully digital world. Simples see the future and
                        freedom in it. They want to be creative and helpful. We can feel their enthusiasm for collecting
                        meaningful experiences in digital as well as the real world.
                    </div>
                    <div style="text-align: center;"><strong>Welcome to The World of Simples!</strong></div>
                    <br/>
                    <div>{`Presale is ${isPresaleMintActive ? "active" : "inactive"}`}</div>
                    <div>{`Public is ${isPublicMintActive ? "active" : "inactive"}`}</div>
                    <div>
                        {#if !currentAccount}
                            <button on:click={connectWallet}>Connect Wallet</button>
                        {:else}
                            <div>
                                <span>{currentAccount}</span>
                                <button on:click={disconnectWallet}>Disconnect</button>
                            </div>
                            {#if isPresaleMintActive && !isPublicMintActive}
                                {#if currentAddressRole === "gen"}
                                    <div>
                                        <span>Wallet has Genesis role assigned: 1 free clam + 1 whitelist mint allowed</span>
                                    </div>
                                    <div>
                                        <button on:click={genesisFreeClaim}>Genesis claim</button>
                                        <button on:click={genesisWhitelistMint}>Whitelist Mint</button>
                                    </div>

                                {:else if currentAddressRole === "eb"}
                                    <div>
                                        <span>Wallet has Early Bird role assigned: 1 mint at half cost allowed</span>
                                    </div>
                                    <div>
                                        <button on:click={earlyBirdMint}>Early Bird Mint</button>
                                    </div>

                                {:else if currentAddressRole === "wl"}
                                    <div>
                                        <span>Wallet has Whitelist role assigned: 1 mint allowed</span>
                                    </div>
                                    <div>
                                        <button on:click={whitelistMint}>Whitelist Mint</button>
                                    </div>

                                {:else}
                                    <div>
                                        <span>This wallet is not eligible for presale</span>
                                    </div>

                                {/if}
                            {:else if isPresaleMintActive && isPublicMintActive}
                                <div>
                                    <span>Public Mint</span>
                                </div>
                                <div>
                                    <button on:click={publicMint}>Mint</button>
                                </div>
                            {/if}
                        {/if}
                    </div>
                    <button on:click={togglePresaleMint}>Toggle Presale Mint</button>
                    <button on:click={togglePublicMint}>Toggle Public Mint</button>
                    <button on:click={isPresaleActive}>Get Presale Mint status</button>
                    <button on:click={isPublicActive}>Get Public Mint status</button>
                    <div style="text-align: center;"><strong>Project starts soon! Stay tuned!</strong></div>
                    <br><br>
                    <div align="center"><img src="bottom.png" alt="img" style="width: 100%;"><br> <br> <br> The Simples
                        2021
                    </div>
                </td>
            </tr>
            </tbody>
        </table>
        <br><br><br><br>
    </div>
</main>

<style>
    main {
        text-align: center;
        padding: 1em;
        max-width: 240px;
        margin: 0 auto;
    }

    h1 {
        color: #ff3e00;
        text-transform: uppercase;
        font-size: 4em;
        font-weight: 100;
    }

    @media (min-width: 640px) {
        main {
            max-width: none;
        }
    }
</style>