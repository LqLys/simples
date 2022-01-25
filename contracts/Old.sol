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
//    uint public maxMintPerTransaction = 100;
//    uint public maxMintPerPresaleTx = 1;
//
//    uint public earlyBirdPrice = 0.05 ether;
//    uint public regularPrice = 0.1 ether;
//
//    mapping(address => uint) genesisMintsCount;
//    mapping(address => uint) earlyBirdMintsCount;
//    mapping(address => uint) whitelistMintsCount;
//
//    bytes32 public genesisRoot = 0xfbc2f54de92972c0f2c6bbd5003031662aa9b8240f4375dc03d3157d8651ec45;
//    bytes32 public earlyBirdRoot;
//    bytes32 public whitelistRoot;
//
//    constructor(string memory initialBaseURI) ERC721("SecretStuff", "S2") {
//        setBaseTokenURI(initialBaseURI);
//    }
//
//    string private _customBaseURI;
//
//
//    //    function genesisMint(uint _quantity, bytes32[] calldata _proof) public nonReentrant {
//    //        require(isPresaleActive, "Presale is not active");
//    //        require(MerkleProof.verify(_proof, genesisRoot, getMerkleLeaf()), "Invalid proof");
//    //        require(_quantity <= maxMintPerGenesisTransaction, "Quantity per transaction exceeded");
//    //        require(genesisMints[msg.sender] + _quantity <= maxMintPerWallet, "Max mints per wallet exceeded");
//    //        require(totalSupply() + _quantity <= MAX_SUPPLY, "Max supply exceeded");
//    //
//    //        for (uint i = 0; i < _quantity; i++) {
//    //            safeMint(msg.sender);
//    //        }
//    //    }
//
//    //    function earlyBirdMint(uint quantity, bytes32[] calldata _merkleProof) public payable nonReentrant {
//    //        require(isEarlyBirdSaleActive, "Presale is not active");
//    //        require(MerkleProof.verify(_merkleProof, earlyBirdMerkleRoot, getMerkleLeaf()), "Invalid proof");
//    //        require(quantity <= maxMintPerEarlyBirdTransaction, "Quantity per transaction exceeded");
//    //        require(earlyBirdMints[msg.sender] + quantity <= maxMintPerWallet, "Max mints per wallet exceeded");
//    //        require(totalSupply() + quantity <= MAX_SUPPLY, "Max supply exceeded");
//    //        require(msg.value != earlyBirdPrice * quantity, "incorrect ether amount");
//    //
//    //        for (uint i = 0; i < quantity; i++) {
//    //            safeMint(msg.sender);
//    //        }
//    //    }
//
//    //    function whitelistMint(uint quantity, bytes32[] calldata _merkleProof) public payable nonReentrant {
//    //        require(isEarlyBirdSaleActive, "Presale is not active");
//    //        require(MerkleProof.verify(_merkleProof, earlyBirdMerkleRoot, getMerkleLeaf()), "Invalid proof");
//    //        require(quantity <= maxMintPerEarlyBirdTransaction, "Quantity per transaction exceeded");
//    //        require(earlyBirdMints[msg.sender] + quantity <= maxMintPerWallet, "Max mints per wallet exceeded");
//    //        require(totalSupply() + quantity <= MAX_SUPPLY, "Max supply exceeded");
//    //        require(msg.value != regularPrice * quantity, "incorrect ether amount");
//    //
//    //        for (uint i = 0; i < quantity; i++) {
//    //            safeMint(msg.sender);
//    //        }
//    //    }
//
//    function genesisMint(uint _quantity, bytes32[] calldata _proof) public payable nonReentrant
//    presaleMintValidated(genesisRoot, _proof, _quantity, maxMintPerPresaleTx, genesisMintsCount, 0) {
//        for (uint i = 0; i < quantity; i++) {
//            safeMint(msg.sender);
//        }
//    }
//
//    function earlyBirdMint(uint _quantity, bytes32[] calldata _proof) public payable nonReentrant
//    presaleMintValidated(earlyBirdRoot, _proof, _quantity, maxMintPerPresaleTx, earlyBirdMintsCount, earlyBirdPrice) {
//        for (uint i = 0; i < quantity; i++) {
//            safeMint(msg.sender);
//        }
//    }
//
//    function whitelistMint(uint _quantity, bytes32[] calldata _proof) public payable nonReentrant
//    presaleMintValidated(whitelistRoot, _proof, _quantity, maxMintPerPresaleTx, whitelistMintsCount, regularPrice) {
//        for (uint i = 0; i < quantity; i++) {
//            safeMint(msg.sender);
//        }
//    }
//
//    modifier presaleMintValidated(bytes32 root, bytes32[] proof, uint quantity, uint maxPerTransaction, mapping(address => uint) _mintedCount, uint _mintPrice){
//        require(isPresaleActive, "Presale is not active");
//        require(MerkleProof.verify(_merkleProof, earlyBirdMerkleRoot, getMerkleLeaf()), "Invalid proof");
//        require(quantity <= maxMintPerEarlyBirdTransaction, "Quantity per transaction exceeded");
//        require(_mintedCount[msg.sender] + quantity <= maxMintPerWallet, "Max mints per wallet exceeded");
//        require(totalSupply() + quantity <= MAX_SUPPLY, "Max supply exceeded");
//        require(msg.value != _mintPrice * quantity, "incorrect ether amount");
//        _;
//    }
//
//    function publicMint(uint quantity) public payable nonReentrant {
//        require(isPublicSaleActive, "Public sale is not active");
//        require(quantity <= maxMintPerTransaction, "Max mints per transaction exceeded");
//        require(balanceOf(msg.sender) < maxMintPerWallet, "Max mints per wallet exceeded");
//        require(totalSupply() + quantity <= MAX_SUPPLY, "sold out");
//        require(msg.value != normalPrice * quantity, "incorrect ether amount");
//
//        for (uint i = 0; i < quantity; i++) {
//            safeMint(msg.sender);
//        }
//    }
//
//    function safeMint(address to) internal {
//        uint256 tokenId = _tokenIdsCounter.current();
//        _tokenIdsCounter.increment();
//        _safeMint(to, tokenId);
//    }
//
//    function getMerkleLeaf() internal view returns (bytes32){
//        return keccak256(abi.encodePacked(msg.sender));
//    }
//
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
//    function withdrawAll() external onlyOwner {
//        require(payable(msg.sender).send(address(this).balance));
//    }
//
//    function toggleGenesisMint() external onlyOwner {
//        isGenesisSaleActive = !isGenesisSaleActive;
//    }
//
//    function toggleEarlyBirdMint() external onlyOwner {
//        isEarlyBirdSaleActive = !isEarlyBirdSaleActive;
//    }
//
//    function setMaxMintsPerWallet(uint256 amount) external onlyOwner {
//        maxMintPerWallet = amount;
//    }
//
//    function setMaxMintPerTransaction(uint256 amount) external onlyOwner {
//        maxMintPerTransaction = amount;
//    }
//
//    function setGenesisMerkleRoot(bytes32 root) external onlyOwner {
//        genesisMerkleRoot = root;
//    }
//
//    function setEarlyBirdMerkleRoot(bytes32 root) external onlyOwner {
//        earlyBirdMerkleRoot = root;
//    }
//
//    function getBalance() public view returns (uint256){
//        return address(this).balance;
//    }
//}
//
