<script>
    import {ethers} from "ethers";
    import SecretStuff from "./artifacts/contracts/TheSimples.sol/TheSimples.json";
    import {onDestroy, onMount} from "svelte";

    const API_BASE = 'https://simples-api.herokuapp.com/api/';

    const contractAddress = "0xd0308a2CB8e786c10685b09eB20ca7c5380D4a47";
    let isPresaleMintActive = false;
    let isPublicMintActive = false;
    let currentAccount;
    let currentAddressRole;
    let ogAmountSelected = 2;
    let publicAmountSelected = 2;
    let amountMinted = 0;
    let amountMintedInterval;

    onMount(async () => {
        if (typeof window.ethereum === "undefined") {
            setTimeout(() => {
                alert("You need to have Metamask installed.");
            }, 1000)

        } else {
            try {
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
        clearInterval(amountMintedInterval);
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
                    const transaction = await contract.genesisClaim(proofForAddress)
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
                console.log()
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
            console.log('presale active: ', isPresaleMintActive)
            isPublicMintActive = await isPublicActive();
            getAmountMinted();
            amountMintedInterval = setInterval(() => {
                getAmountMinted();
            }, 10000);
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
    <div align="center">
        <img src="top-mint.jpg" style="width: 100%;" alt="img"></div>
    <div>
        <table style="width: 80%; border-collapse: collapse; border-style: hidden; margin-left: auto; margin-right: auto;"
               border="0">
            <tbody>
            <tr>
                <td style="width: 100%;">
                    <div>
                        {#if !currentAccount}
                            <p class="txt-375">Start minting</p>
                            <button class="button-l" on:click={connectWallet}><span
                                    class="txt-541">Connect Wallet</span></button>
                        {:else}

                            <div>
                                <span class="wallet-container">{currentAccount}</span>
                                <button class="button-m" on:click={disconnectWallet}><span class="txt-801">Disconnect</span></button>
                            </div>
                            <div class="amount-info-container">
                                <p class="txt-954">Minted: {amountMinted}/1111</p>
                            </div>
                            {#if isPresaleMintActive && !isPublicMintActive}

                                {#if currentAddressRole === "gen"}
                                    <p class="txt-593">
                                        You can mint <span class="txt-5932">2</span> presale Simples and claim <span
                                            class="txt-5932">1</span> for free
                                    </p>
                                    <div>
                                        <button class="button-m" on:click={genesisFreeClaim}><span class="txt-801">Free claim</span></button>
                                        <button class="button-m" on:click={ogsMint}><span class="txt-801">Mint now!</span></button>
                                        <select class="amount-selector" bind:value={ogAmountSelected}>
                                            <option value="{1}">1</option>
                                            <option value="{2}">2</option>
                                        </select>
                                    </div>

                                {:else if currentAddressRole === "eb"}
                                    <p class="txt-593">
                                        You can mint <span class="txt-5932">2</span> presale Simples
                                    </p>
                                    <div>
                                        <button class="button-m" on:click={ogsMint}><span class="txt-801">Mint now!</span></button>
                                        <select class="amount-selector" bind:value={ogAmountSelected}>
                                            <option value="{1}">1</option>
                                            <option value="{2}">2</option>
                                        </select>
                                    </div>

                                {:else if currentAddressRole === "wl"}
                                    <p class="txt-593">
                                        You can mint <span class="txt-5932">1</span> presale Simple
                                    </p>
                                    <div>
                                        <button class="button-m" on:click={whitelistMint}><span class="txt-801">Mint now!</span></button>
                                    </div>

                                {:else}
                                    <p class="txt-593">
                                        You are not allowed to mint
                                    </p>

                                {/if}
                            {:else if isPresaleMintActive && isPublicMintActive}
                                <p class="txt-593">
                                    You can mint <span class="txt-5932">1</span> Simples
                                </p>
                                <div>
                                    <button class="button-m" on:click={publicMint}><span class="txt-801">Mint now!</span></button>
                                    <select class="amount-selector" bind:value={publicAmountSelected}>
                                        <option value="{1}">1</option>
                                        <option value="{2}">2</option>
                                    </select>
                                </div>
                            {:else}
                                <div class="amount-info-container">
                                    {#if currentAddressRole === "gen"}
                                        <p class="txt-593">
                                            You can mint <span class="txt-5932">2</span> presale Simples and claim <span
                                                class="txt-5932">1</span> for free
                                        </p>
                                    {:else if currentAddressRole === "eb"}
                                        <p class="txt-593">
                                            You can mint <span class="txt-5932">2</span> presale Simples
                                        </p>
                                    {:else if currentAddressRole === "wl"}
                                        <p class="txt-593">
                                            You can mint <span class="txt-5932">1</span> presale Simple
                                        </p>
                                    {:else}
                                        <p class="txt-593">
                                            You are not allowed to mint
                                        </p>
                                    {/if}
                                </div>
                            {/if}
                        {/if}
                    </div>

                    <div align="center"><img src="simples_bottom.jpg" alt="img" style="width: 100%;"></div>
                </td>
            </tr>
            </tbody>
        </table>
    </div>
</main>

<style>
    /*@import url("https://fonts.googleapis.com/css2?family=Nunito:wght@600;800&display=swap");*/

    main {
        text-align: center;
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

    .amount-selector {
        width: 50px;
        height: 35px;
        font-size: larger;
        text-align: center;
    }

    .button-5 {
        align-items: center;
        background-clip: padding-box;
        background-color: #F47C06;
        border: 1px solid transparent;
        border-radius: .25rem;
        box-shadow: rgba(0, 0, 0, 0.02) 0 1px 3px 0;
        box-sizing: border-box;
        color: #fff;
        cursor: pointer;
        display: inline-flex;
        font-family: system-ui, -apple-system, system-ui, "Helvetica Neue", Helvetica, Arial, sans-serif;
        font-size: 16px;
        font-weight: 600;
        justify-content: center;
        line-height: 1.25;
        margin: 0;
        min-height: 3rem;
        padding: calc(.875rem - 1px) calc(1.5rem - 1px);
        position: relative;
        text-decoration: none;
        transition: all 250ms;
        user-select: none;
        -webkit-user-select: none;
        touch-action: manipulation;
        vertical-align: baseline;
        width: auto;
    }

    .button-5:hover,
    .button-5:focus {
        background-color: #F47C06;
        box-shadow: rgba(0, 0, 0, 0.1) 0 4px 12px;
    }

    .button-5:hover {
        transform: translateY(-1px);
    }

    .button-5:active {
        background-color: #F47C06;
        box-shadow: rgba(0, 0, 0, .06) 0 2px 4px;
        transform: translateY(0);
    }

    .wallet-container {
        font-family: sans-serif;
        border: 3px solid #F47C06;
        border-radius: 10px;
        padding: 12px;
        font-family: 'Roboto';
        font-weight: 900
    }

    .amount-info-container {
        font-family: 'Roboto';
        margin-top: 8px;
        margin-bottom: 8px;
        font-weight: 900;
    }

    .button-l {
        padding: 15px 39px;
        margin-bottom: 16px;
        box-sizing: border-box;
        border-radius: 80px;
        background-color: rgba(255, 126, 0, 1);
        width: fit-content;
    }

    .txt-541 {
        font-size: 24px;
        font-family: Nunito, sans-serif;
        font-weight: 800;
        letter-spacing: 0.48px;
        color: rgba(255, 255, 255, 1);
        word-wrap: break-word;
    }

    .txt-375 {
        font-size: 32px;
        font-family: Nunito, sans-serif;
        font-weight: 800;
        line-height: 125%;
        color: rgba(35, 23, 21, 1);
        text-align: center;
        word-wrap: break-word;
    }

    .txt-593 {
        font-size: 32px;
        font-family: Nunito, sans-serif;
        font-weight: 800;
        line-height: 125%;
        color: rgba(35, 23, 21, 1);
        text-align: center;
        word-wrap: break-word;
        margin-bottom: 20px;
    }

    .txt-5932 {
        color: rgba(255, 126, 0, 1);
    }

    .txt-801 {
        font-size: 16px;
        font-family: Nunito, sans-serif;
        font-weight: 800;
        letter-spacing: 0.32px;
        color: rgba(255, 255, 255, 1);
        word-wrap: break-word;
    }
    .button-m {
        padding: 11px 31px;
        box-sizing: border-box;
        border-radius: 80px;
        background-color: rgba(255, 126, 0, 1);
        height: 100%;
    }
    .txt-954 {
        font-size: 16px;
        font-family: Nunito, sans-serif;
        font-weight: 600;
        color: rgba(35, 23, 21, 0.8);
        word-wrap: break-word;
    }
</style>