////Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
//// SPDX-License-Identifier: MIT
//pragma solidity 0.8.10;
//
//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import "@openzeppelin/contracts/utils/Counters.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
//
//contract SecretStuff is ERC721, Ownable, ReentrancyGuard {
//    using Counters for Counters.Counter;
//
//    Counters.Counter private _tokenIdsCounter;
//    uint public constant MAX_SUPPLY = 1111;
//    bool public isPresaleActive = false;
//    bool public isPublicActive = false;
//
//    uint public maxMintPerWallet = 1;
//
//    uint public earlyBirdPrice = 0.055 ether;
//    uint public regularPrice = 0.11 ether;
//
//    mapping(address => uint) genesisMintsCount;
//    mapping(address => uint) earlyBirdMintsCount;
//    mapping(address => uint) whitelistMintsCount;
//
//    bytes32 public genesisRoot = 0x070e8db97b197cc0e4a1790c5e6c3667bab32d733db7f815fbe84f5824c7168d;
//    bytes32 public earlyBirdRoot = 0x7e0eefeb2d8740528b8f598997a219669f0842302d3c573e9bb7262be3387e63;
//    bytes32 public whitelistRoot = 0xa22d2d4af6076ff70babd4ffc5035bdce39be98f440f86a0ddc202e3cd935a59;
//
//    string private _customBaseURI;
//
//    constructor(string memory initialBaseURI) ERC721("SecretStuff", "S2") {
//        setBaseTokenURI(initialBaseURI);
//    }
//
//    function genesisMint(bytes32[] calldata _proof) public
//    withValidStage(isPresaleActive)
//    withValidProof(genesisRoot, _proof)
//    mintCountNotExceeded(genesisMintsCount)
//    notSoldOut
//    callerIsUser
//    nonReentrant {
//        genesisMintsCount[msg.sender]++;
//        mint(msg.sender);
//
//    }
//
//    function earlyBirdMint(bytes32[] calldata _proof) public payable
//    withValidStage(isPresaleActive)
//    withValidProof(earlyBirdRoot, _proof)
//    mintCountNotExceeded(earlyBirdMintsCount)
//    withValidAmount(earlyBirdPrice)
//    notSoldOut
//    callerIsUser
//    nonReentrant {
//        earlyBirdMintsCount[msg.sender]++;
//        mint(msg.sender);
//    }
//
//    function whitelistMint(bytes32[] calldata _proof) public payable
//    withValidStage(isPresaleActive)
//    withValidProof(whitelistRoot, _proof)
//    mintCountNotExceeded(whitelistMintsCount)
//    withValidAmount(regularPrice)
//    notSoldOut
//    callerIsUser
//    nonReentrant {
//        whitelistMintsCount[msg.sender]++;
//        mint(msg.sender);
//    }
//
//    function publicMint() public payable
//    withValidStage(isPublicActive)
//    withValidAmount(regularPrice)
//    notSoldOut
//    callerIsUser
//    nonReentrant {
//        mint(msg.sender);
//    }
//
//    function mint(address to) internal {
//        uint256 tokenId = _tokenIdsCounter.current();
//        _tokenIdsCounter.increment();
//        _safeMint(to, tokenId);
//    }
//
//    modifier notSoldOut(){
//        require(totalSupply() < MAX_SUPPLY, "Sold out");
//        _;
//    }
//
//    modifier mintCountNotExceeded(mapping(address => uint)  _mintedCount){
//        require(_mintedCount[msg.sender] < maxMintPerWallet, "Max mints exceeded");
//        _;
//    }
//
//    modifier withValidAmount(uint _mintPrice){
//        require(msg.value == _mintPrice, "incorrect ether amount");
//        _;
//    }
//
//    modifier withValidProof(bytes32 root, bytes32[] calldata _proof){
//        require(MerkleProof.verify(_proof, root, keccak256(abi.encodePacked(msg.sender))), "Invalid proof");
//        _;
//    }
//
//    modifier withValidStage(bool isStageActive){
//        require(isStageActive, "Stage inactive");
//        _;
//    }
//
//    modifier callerIsUser() {
//        require(tx.origin == msg.sender, "The caller is another contract");
//        _;
//    }
//
//    function totalSupply() public view returns (uint256) {
//        return _tokenIdsCounter.current();
//    }
//
//    function setBaseTokenURI(string memory baseURI) public onlyOwner {
//        _customBaseURI = baseURI;
//    }
//
//    function _baseURI() internal view virtual override returns (string memory) {
//        return _customBaseURI;
//    }
//
//    function togglePresaleMint() external onlyOwner {
//        isPresaleActive = !isPresaleActive;
//    }
//
//    function togglePublicMint() external onlyOwner {
//        isPublicActive = !isPresaleActive;
//    }
//
//    function setMaxMintsPerWallet(uint256 amount) external onlyOwner {
//        maxMintPerWallet = amount;
//    }
//
//    function setGenesisRoot(bytes32 _root) external onlyOwner {
//        genesisRoot = _root;
//    }
//
//    function setEarlyBirdRoot(bytes32 _root) external onlyOwner {
//        earlyBirdRoot = _root;
//    }
//
//    function setWhitelistRoot(bytes32 _root) external onlyOwner {
//        whitelistRoot = _root;
//    }
//
//    function getBalance() public view returns (uint256){
//        return address(this).balance;
//    }
//
//    function withdrawMoney() external onlyOwner nonReentrant {
//        (bool success,) = msg.sender.call{value : address(this).balance}("");
//        require(success, "Transfer failed.");
//    }
//}
//
