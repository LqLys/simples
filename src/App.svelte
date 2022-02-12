<script>
    import {ethers} from "ethers";
    import SecretStuff from "./artifacts/contracts/TheSimples.sol/TheSimples.json";
    import {onDestroy, onMount} from "svelte";

    const API_BASE = 'https://simples-api.herokuapp.com/api/';

    const contractAddress = "0x243c402D52726ADE5d742Caa23D88d8C62948E9e";
    let isPresaleMintActive = false;
    let isPublicMintActive = false;
    let currentAccount;
    let currentAddressRole;
    let ogAmountSelected = 2;
    let publicAmountSelected = 2;
    let amountMinted = 0;
    let amountMintedInterval;
    let dataLoading = true;

    onMount(async () => {
        if (typeof window.ethereum === "undefined") {
            setTimeout(() => {
                alert("You need to have Metamask installed.");
            }, 1000)

        } else {
            setTimeout(() => {
                if (window.ethereum.networkVersion !== '1') {
                    alert('Change network to mainnet')
                }
            }, 1000)

            window.ethereum.on("chainChanged", handleChainChanged)
            window.ethereum.on("accountsChanged", handleAccountsChanged)
            window.ethereum.on("disconnect", handleDisconnect)
        }

        getAmountMinted();
        amountMintedInterval = setInterval(() => {
            getAmountMinted();
        }, 10000);
    })

    onDestroy(() => {
        window.ethereum.removeListener("chainChanged", handleChainChanged)
        window.ethereum.removeListener("accountsChanged", handleAccountsChanged)
        window.ethereum.removeListener("disconnect", handleDisconnect)
        clearInterval(amountMintedInterval);
    })

    const handleAccountsChanged = async () => {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const addresses = await provider.listAccounts();
        if (addresses.length === 0) {
            console.log("Please connect to Metamask");
            currentAccount = null;
            dataLoading = true;
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
        dataLoading = true;
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
                    const transaction = await contract.genesisClaim(proofForAddress)
                    await transaction.wait();
                } catch (err) {
                    const errMsg = err.data?.message;
                    console.log(typeof err);
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

    const ogsMint = async () => {

        if (typeof window.ethereum !== "undefined") {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const contract = new ethers.Contract(contractAddress, SecretStuff.abi, signer);
            const mmAddress = await signer.getAddress();
            const proofForAddress = await getProofForRoleAndAddress(mmAddress.toLowerCase(), 'eb');

            const value = ogAmountSelected === 2 ? "0.22" : "0.11";
            if (proofForAddress) {
                try {
                    const options = {
                        value: ethers.utils.parseEther(value)
                    }
                    const transaction = await contract.ogsMint([...proofForAddress], ogAmountSelected, options)
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

    const whitelistMint = async () => {

        if (typeof window.ethereum !== "undefined") {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const contract = new ethers.Contract(contractAddress, SecretStuff.abi, signer);
            const mmAddress = await signer.getAddress();
            const proofForAddress = await getProofForRoleAndAddress(mmAddress.toLowerCase(), currentAddressRole);
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

            let value = publicAmountSelected === 2 ? "0.22" : "0.11";
            try {
                const options = {
                    value: ethers.utils.parseEther(value)
                }
                const transaction = await contract.publicMint(publicAmountSelected, options)
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

    async function getAmountMinted() {
        if (typeof window.ethereum !== "undefined") {
            try {
                const provider = new ethers.providers.Web3Provider(window.ethereum);
                const signer = provider.getSigner();
                const contract = new ethers.Contract(contractAddress, SecretStuff.abi, signer);
                amountMinted = await contract.totalSupply();
            } catch (err) {
                console.log(err);
            }
        }
    }

    const connectWallet = async () => {
        try {
            const accounts = await window.ethereum.request({method: "eth_requestAccounts"});
            currentAccount = accounts[0];
            currentAddressRole = await getRole(currentAccount);
            isPresaleMintActive = await isPresaleActive();
            isPublicMintActive = await isPublicActive();
            dataLoading = false;
        } catch (err) {
            console.log(err);
        }

    }

    const getRole = async address => {
        try {
            const response = await fetch(API_BASE + `role/${address}`)
            const roleJson = await response.json();
            return roleJson.role;
        } catch (err) {
            console.log(err);
            return "none"
        }
    }

    const getProofForRoleAndAddress = async (address, role) => {
        try {
            const response = await fetch(API_BASE + `proof?wallet=${address}&role=${role}`)
            const proofJson = await response.json();
            return proofJson.proof;
        } catch (err) {
            console.log(err);
            return [];
        }
    }

    const disconnectWallet = () => {
        currentAccount = null;
        dataLoading = true;
    };


</script>

<main class="content">
    <img class="content-header" src="header.png" srcset="header.png 1x, header@2x.png 2x" alt="The Simples by Konrad Kirpluk">
    <div class="content-inside">
        {#if !currentAccount}
            <div class="intro">
                <h1 class="intro-title">Start minting</h1>
                <button class="intro-button" on:click={connectWallet}>Connect Wallet</button>
                <div class="available-note">{amountMinted} of 1111 available</div>
            </div>
        {:else}
            <!-- TEMPLATE - MINT -->
            <div class="wallet">
                <div class="wallet-number">{currentAccount.substring(0, 6)} <span>&hellip;</span> {currentAccount.substring(currentAccount.length - 4, currentAccount.length)}</div>
                <button class="wallet-button" on:click={disconnectWallet}>Disconnect</button>
            </div>
            <div class="mint">
                {#if dataLoading}
                    <h2 class="mint-title">
                        Loading...
                    </h2>
                {:else}
                    {#if isPresaleMintActive && !isPublicMintActive}
                        {#if currentAddressRole === "gen"}
                            <h2 class="mint-title">You can mint <span>2</span> presale Simples</h2>
                            <div class="mint-now">
                                <select name="quantity" class="mint-now-quantity" bind:value={ogAmountSelected}>
                                    <option value="{1}">1</option>
                                    <option value="{2}">2</option>
                                </select>
                                <button class="mint-now-button" on:click={ogsMint}>Mint Now!</button>
                            </div>
                            <h2 class="mint-title">and claim <span>1</span> for free</h2>
                            <button class="mint-free-button" on:click={genesisFreeClaim}>Free Claim</button>

                        {:else if currentAddressRole === "eb"}
                            <h2 class="mint-title">You can mint <span>2</span> presale Simples</h2>
                            <div class="mint-now">
                                <select name="quantity" class="mint-now-quantity" bind:value={ogAmountSelected}>
                                    <option value="{1}">1</option>
                                    <option value="{2}">2</option>
                                </select>
                                <button class="mint-now-button" on:click={ogsMint}>Mint Now!</button>
                            </div>
                        {:else if currentAddressRole === "wl"}
                            <h2 class="mint-title">You can mint <span>1</span> presale Simple</h2>
                            <div class="mint-now">
                                <button class="mint-now-button" on:click={whitelistMint}>Mint Now!</button>
                            </div>
                        {:else}
                            <h2 class="mint-title">You are not allowed to mint</h2> 
                        {/if}
                    {:else if isPresaleMintActive && isPublicMintActive}
                        <h2 class="mint-title">You can mint <span>1</span> Simples</h2>
                        <div class="mint-now">
                            <select name="quantity" class="mint-now-quantity" bind:value={publicAmountSelected}>
                                <option value="{1}">1</option>
                                <option value="{2}">2</option>
                            </select>
                            <button class="mint-now-button" on:click={publicMint}>Mint Now!</button>
                        </div>
                    {:else}
                        {#if currentAddressRole === "gen"}
                            <h2 class="mint-title">
                                You can mint <span>2</span> presale Simples and claim <span>1</span> for free
                            </h2>
                        {:else if currentAddressRole === "eb"}
                            <h2 class="mint-title">
                                You can mint <span>2</span> presale Simples
                            </h2>
                        {:else if currentAddressRole === "wl"}
                            <h2 class="mint-title">
                                You can mint <span>1</span> presale Simple
                            </h2>
                        {:else}
                            <h2 class="mint-title">
                                You are not allowed to mint
                            </h2>
                        {/if}
                    {/if}
                {/if}
                <div class="available-note">{amountMinted} of 1111 available</div>
            </div>
            <!-- END TEMPLATE - MINT -->
        {/if}
    </div>
</main>
<footer class="footer">
    Follow The Simples on <a href="https://twitter.com/thesimplesart" target="_blank" rel="noopener noreferrer">Twitter</a> or <a href="https://discord.com/invite/RCn2TdchEP" target="_blank" rel="noopener noreferrer">Discord</a><br />
    <a href="https://etherscan.io/address/0x243c402d52726ade5d742caa23d88d8c62948e9e" target="_blank" rel="noopener noreferrer">Verified Smart Contract</a>
</footer>

<style>
</style>
