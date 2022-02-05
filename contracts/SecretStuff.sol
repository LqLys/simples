//Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SecretStuff is ERC721, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdsCounter;
    uint public constant MAX_SUPPLY = 1111;
    uint public constant MAX_EXTERNAL_MINTS = 1056;
    uint public constant MAX_TREASURY_MINTS = 55;

    bool public isPresaleActive = false;
    bool public isPublicActive = false;

    uint public maxGenesisClaims = 1;
    uint public maxOgsWlMints = 2;
    uint public maxWlMints = 1;
    uint public maxPublicMints = 2;


    uint public price = 0.11 ether;

    mapping(address => uint) genesisClaims;
    mapping(address => uint) ogMints;
    mapping(address => uint) whitelistMintsCount;
    mapping(address => uint) publicMintCount;
    uint public treasuryMintCounter = 0;

    bytes32 public genesisRoot = 0x96c4abbbb9dd027813f2b8c2c4917b15bb46b3c8d595841148f2de33d0c4d6ae;
    bytes32 public ogsRoot = 0x630d56621cf1a7e28c5373e27f73148778b52a3050a8196b0f14761c44220ece;
    bytes32 public whitelistRoot = 0x1f62655901b37227b56bc225f83198ff688bfdaf330551d424ee719d7cc877f1;

    address public treasuryAddress;

    string private _customBaseURI;

    constructor(string memory initialBaseURI) ERC721("SecretStuff", "S2") {
        setBaseTokenURI(initialBaseURI);
    }

    function genesisClaim(bytes32[] calldata _proof) public
    withValidStage(isPresaleActive)
    withValidProof(genesisRoot, _proof)
    mintCountNotExceeded(genesisClaims, 1, maxGenesisClaims)
    notSoldOut(1)
    callerIsUser
    nonReentrant {
        genesisClaims[msg.sender]++;
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
        mint(msg.sender);
    }

    function publicMint(uint _quantity) public payable
    withValidStage(isPublicActive)
    withValidAmount(_quantity)
    mintCountNotExceeded(publicMintCount, _quantity, maxPublicMints)
    notSoldOut(_quantity)
    callerIsUser
    nonReentrant {
        for (uint i = 0; i < _quantity; i++) {
            publicMintCount[msg.sender]++;
            mint(msg.sender);
        }

    }

    function treasuryMint(uint _quantity) public {
        require(msg.sender == treasuryAddress, "Sender is not treasury");
        require(treasuryMintCounter + _quantity <= MAX_TREASURY_MINTS, "Minted out");

        for (uint i = 0; i < _quantity; i++) {
            treasuryMintCounter++;
            mint(msg.sender);
        }
    }


    function mint(address to) internal {
        uint256 tokenId = _tokenIdsCounter.current();
        _tokenIdsCounter.increment();
        _safeMint(to, tokenId);
    }

    modifier notSoldOut(uint _quantity){
        require(totalSupply() + _quantity <= MAX_EXTERNAL_MINTS, "Sold out");
        _;
    }

    modifier mintCountNotExceeded(mapping(address => uint) storage _mintedCount, uint _quantity, uint _maxMints){
        require(_mintedCount[msg.sender] + _quantity <= _maxMints, "Max mints exceeded");
        _;
    }

    modifier withValidAmount(uint _quantity){
        require(msg.value == price * _quantity, "Incorrect ether amount");
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

    function getBalance() public view returns (uint256){
        return address(this).balance;
    }

    function withdrawMoney() external onlyOwner nonReentrant {
        (bool success,) = msg.sender.call{value : address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function setTreasuryAddress(address _address) external onlyOwner {
        treasuryAddress = _address;
    }
}

