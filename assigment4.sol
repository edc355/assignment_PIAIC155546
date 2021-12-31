// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract TheToken is ERC721 { 
    
    uint public saleStartTime;
    uint internal salePeriod;
    uint internal saleEndTime;
    uint private NFTPrice;
    uint internal NFTMaxSupply;
    uint internal tokenID;
    uint public currentSupply;
    uint public fundRaised;
    uint public lastTokenID;
    
    constructor() {
        
        saleStartTime = block.timestamp + 1;
        salePeriod = 2592000;  
        saleEndTime = saleStartTime + salePeriod ;
        NFTMaxSupply = 100;
        tokenID = 0;
        currentSupply = 0;
        lastTokenID = tokenID;
        
    }

    fallback() external payable {}
    receive() external payable {}
    
    modifier isSaleStart(){
        require(saleStartTime < block.timestamp, "TheToken: sale yet to start");
        require(NFTPrice > 0,"TheToken: NFT price is not yet set");
        require(bytes(baseURI_).length > 0,"TheToken: baseURI need to be decleared");
        _;
    }
    
     modifier isSaleEnd(){
        require(block.timestamp < saleEndTime, "TheToken: sale ended");
        _;
    }
    
    modifier maxSupply(){
        require(currentSupply < NFTMaxSupply ,"Max Supply achived");
        _;
    }   
   

   function setNFTPrice(uint _NFTPrice) public onlyOwner() {
       NFTPrice = _NFTPrice  * 10 ** 18;       
    }
   
   function getNFTPrice() public view returns(uint) {
       return NFTPrice;
    }
   
   
   
   
   function setBaseURI(string memory BaseURI) public onlyOwner() {
       baseURI_ = BaseURI;          /*     https://floydnft.com/token/&quot    */
    }
   
   

        
    function buyToken(address to) public payable
        isSaleStart
        isSaleEnd
        maxSupply
        returns(uint totalFunds){
        
        require(msg.value == NFTPrice && msg.sender != address(0),"TheToken: unrequired value");
        
        payable(address(this)).transfer(msg.value);
        fundRaised = fundRaised + msg.value;
        
        tokenID += 1;
        lastTokenID = tokenID;
        currentSupply +=1;
        _mint(to, tokenID);
        
        return fundRaised;
    }



    function killingContract()external payable onlyOwner() returns(bool){
        require(block.timestamp > saleEndTime,"TheToken: sale in progress");
        
        emit Transfer(address(this), owner(), fundRaised);    
        selfdestruct(payable(owner()));
        return true;
    }
}
    
