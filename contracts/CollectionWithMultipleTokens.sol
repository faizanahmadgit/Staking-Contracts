//TO BUY NFTs WITH DIFFERENT ERC20 TOKENS
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Collection is ERC721Enumerable, Ownable {

    struct TokenInfo {   // specific token and cost to buy nft
        IERC20 payToken;
        uint256 costValue;
    }
    TokenInfo[] public AllowedCrypto;

    using Strings for uint256;
    string public baseURI;
    string public baseExtension = ".json";

    //uint256 public cost = 0.001 ether;

    // 1 SLOT
    uint32 public maxSupply = 100000; // supports for 2 ^ 32
    uint256 public maxMintAmount = 5; 
    bool public paused = false;
    // 1 SLOT

    constructor() ERC721("NFT Collection", "N2D") {}

    function addCurrency(IERC20 _payToken, uint256 _cost) public onlyOwner {  //Add currencies to buy nfts
            AllowedCrypto.push(TokenInfo({
                payToken: _payToken,
                costValue: _cost 
            })
            );

    }
    //internal
    function _baseURI() internal view virtual override returns (string memory){
        return "";
    }

    function mint(address _to, uint256 _mintAmount, uint _pid) external payable {
        uint256 supply = totalSupply(); //from enumerable maybe;
        TokenInfo storage tokens = AllowedCrypto[_pid];
        IERC20 payToken;
        payToken = tokens.payToken;
        uint256 cost;
        cost = tokens.costValue;
        require(!paused, "contract is paused");
        require(_mintAmount > 0 && _mintAmount <= maxMintAmount, "invalid mint amount");
        require(supply + _mintAmount <= maxSupply, "amount exceeds max supply");
        
        if (msg.sender != owner()) {
            require(msg.value == cost * _mintAmount, "Need to send 0.08 ether!");
        }
        
        for (uint256 i = 1; i <= _mintAmount; i++) {
            payToken.transferFrom(msg.sender, address(this), cost);
            _safeMint(_to, supply + i);
        }
    }

    function walletOfOwner(address _owner) external view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }
    
    function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
            
        string memory currentBaseURI = baseURI;

        return bytes(currentBaseURI).length > 0 ?
            string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }

    // only owner
    function setmaxMintAmount(uint256 _newmaxMintAmount) external onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }
    
    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }
    
    function setBaseExtension(string memory _newBaseExtension) external onlyOwner {
        baseExtension = _newBaseExtension;
    }
    
    function pause(bool _state) external onlyOwner {
        paused = _state;
    }
    
    function withdraw(uint256 _pid) external payable onlyOwner { //will withdraw desired erc20 tokens
        TokenInfo storage tokens = AllowedCrypto[_pid];
        IERC20 payToken;
        payToken = tokens.payToken;
        payToken.transfer(msg.sender, payToken.balanceOf(address(this)));
        //payable(msg.sender).transfer(address(this).balance);
    }
}