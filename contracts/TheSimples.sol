//Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TheSimples is ERC721, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdsCounter;

    uint public constant MAX_SUPPLY = 1111;
    uint public constant MAX_EXTERNAL_MINTS = 1056;
    uint public constant MAX_TREASURY_MINTS = 55;

    uint public constant maxGenesisClaims = 1;
    uint public constant maxOgsWlMints = 2;
    uint public constant maxWlMints = 1;
    uint public constant maxPublicMints = 2;

    uint public constant price = 0.11 ether;

    address private constant splitAddress = 0x6F957b0f6BeE061AC1aa66248E70f94389Cf9908;
    address private constant treasuryAddress = 0xe3e4775D8b220f1046B3070Ab5ED09135F0E3F8f;

    bool public isPresaleActive = false;
    bool public isPublicActive = false;

    mapping(address => uint) genesisClaims;
    mapping(address => uint) ogMints;
    mapping(address => uint) whitelistMintsCount;
    mapping(address => uint) publicMintCount;

    uint public treasuryMintCounter = 0;
    uint public externalMintCounter = 0;

    bytes32 private genesisRoot;
    bytes32 private ogsRoot;
    bytes32 private whitelistRoot;

    string private _customBaseURI;

    constructor(
        string memory initialBaseURI,
        bytes32 _genesisRoot,
        bytes32 _ogsRoot,
        bytes32 _whitelistRoot
    ) ERC721("The Simples 1111", "TS1") {
        setBaseTokenURI(initialBaseURI);
        genesisRoot = _genesisRoot;
        ogsRoot = _ogsRoot;
        whitelistRoot = _whitelistRoot;

    }

    function genesisClaim(bytes32[] calldata _proof) public
    withValidStage(isPresaleActive)
    withValidProof(genesisRoot, _proof)
    mintCountNotExceeded(genesisClaims, 1, maxGenesisClaims)
    notSoldOut(1)
    callerIsUser
    nonReentrant {
        genesisClaims[msg.sender]++;
        externalMintCounter++;
        mint(msg.sender);
    }

    function ogsMint(bytes32[] calldata _proof, uint _quantity) public payable
    withValidStage(isPresaleActive)
    withValidProof(ogsRoot, _proof)
    mintCountNotExceeded(ogMints, _quantity, maxOgsWlMints)
    withValidAmount(_quantity)
    notSoldOut(_quantity)
    callerIsUser
    nonReentrant {
        for (uint i = 0; i < _quantity; i++) {
            ogMints[msg.sender]++;
            externalMintCounter++;
            mint(msg.sender);
        }
    }

    function whitelistMint(bytes32[] calldata _proof) public payable
    withValidStage(isPresaleActive)
    withValidProof(whitelistRoot, _proof)
    mintCountNotExceeded(whitelistMintsCount, 1, maxWlMints)
    withValidAmount(1)
    notSoldOut(1)
    callerIsUser
    nonReentrant {
        whitelistMintsCount[msg.sender]++;
        externalMintCounter++;
        mint(msg.sender);
    }

    function publicMint(uint _quantity) public payable
    withValidStage(isPublicActive)
    mintCountNotExceeded(publicMintCount, _quantity, maxPublicMints)
    withValidAmount(_quantity)
    notSoldOut(_quantity)
    callerIsUser
    nonReentrant {
        for (uint i = 0; i < _quantity; i++) {
            publicMintCount[msg.sender]++;
            externalMintCounter++;
            mint(msg.sender);
        }
    }

    function treasuryMint(uint _quantity) public onlyOwner {
        require(treasuryMintCounter + _quantity <= MAX_TREASURY_MINTS, "Minted out");
        for (uint i = 0; i < _quantity; i++) {
            treasuryMintCounter++;
            mint(treasuryAddress);
        }
    }

    function mint(address to) internal {
        _tokenIdsCounter.increment();
        uint256 tokenId = _tokenIdsCounter.current();
        _safeMint(to, tokenId);
    }

    modifier notSoldOut(uint _quantity){
        require(externalMintCounter + _quantity <= MAX_EXTERNAL_MINTS, "Sold out");
        _;
    }

    modifier mintCountNotExceeded(mapping(address => uint) storage _mintedCount, uint _quantity, uint _maxMints){
        require(_mintedCount[msg.sender] + _quantity <= _maxMints, "Max mints exceeded");
        _;
    }

    modifier withValidAmount(uint _quantity){
        require(msg.value >= price * _quantity, "Not enough ether sent");
        _;
    }

    modifier withValidProof(bytes32 root, bytes32[] calldata _proof){
        require(MerkleProof.verify(_proof, root, keccak256(abi.encodePacked(msg.sender))), "Invalid proof");
        _;
    }

    modifier withValidStage(bool isStageActive){
        require(isStageActive, "Stage inactive");
        _;
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIdsCounter.current();
    }

    function setBaseTokenURI(string memory baseURI) public onlyOwner {
        _customBaseURI = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _customBaseURI;
    }

    function togglePresaleMint() external onlyOwner {
        isPresaleActive = !isPresaleActive;
    }

    function togglePublicMint() external onlyOwner {
        isPublicActive = !isPublicActive;
    }

    function setGenesisRoot(bytes32 _root) external onlyOwner {
        genesisRoot = _root;
    }

    function setOgRoot(bytes32 _root) external onlyOwner {
        ogsRoot = _root;
    }

    function setWhitelistRoot(bytes32 _root) external onlyOwner {
        whitelistRoot = _root;
    }

    function withdrawFunds() external onlyOwner nonReentrant {
        uint balance = address(this).balance;
        uint splitAmount = balance * 58 / 1000;
        uint teamAmount = balance - splitAmount;
        require(payable(splitAddress).send(splitAmount), "split transfer failed");
        require(payable(msg.sender).send(teamAmount), "transfer failed");

    }

}

