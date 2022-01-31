// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.8.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol';

contract BirbToken is ERC721{
    address _contractOwner;
    
    constructor () ERC721("BirbCoin", "Birb"){
        _mint(msg.sender, 1);
        _contractOwner = msg.sender;
    }
    
    // Function to mint coins
    function mint(address _to, uint _tokenId) public {
        
        _safeMint(_to, _tokenId);
        
    }
    
    // function to check the balance of current contract
    function checkCOntractBalance() public view returns(uint){
        return address(this).balance;   ///function that sends ether using "transfer" instead of sender as it shows exception
    }
    
} // contract end


contract Approved_Seller{
    BirbToken obj;
        constructor(address _address){
            obj = BirbToken(_address);
    }
    
    function mintTokens(uint _tokenId) external payable{
        obj.mint(msg.sender, _tokenId);
    }
    
    function transferTokenFromOwner(address _to, uint _tokenId) external payable{
        
        require(msg.value == 5 ether, "Should be equal to 5 ether");
            address _ownerOfToken = obj.ownerOf(_tokenId);
                obj.safeTransferFrom(_ownerOfToken, _to, _tokenId);
                  payable (_ownerOfToken).transfer(address(this).balance);
        
    }
    
    function checkBalanceofTokens(address accountaddress)  view external returns(uint256){
      return obj.balanceOf(accountaddress);
        
    }
    
    function OwnerOFToken(uint256 tokenID) view external returns(address){
        address _OwnerOFToken = obj.ownerOf(tokenID);
          return _OwnerOFToken;
    }
    
}//end of contract



// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";

contract NFT is Ownable, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address private _royaltiesReceiver;
    // Percentage of each sale to pay as royalties
    uint256 public constant royaltiesPercentage = 5;

    constructor(address initialRoyaltiesReceiver) ERC721("Metaverse", "METT") {
        _royaltiesReceiver = initialRoyaltiesReceiver;
    }

    function createToken(string memory tokenURI) public returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(_royaltiesReceiver, true);
        return newItemId;
    }

    function royaltiesReceiver() external returns(address) {
        return _royaltiesReceiver;
    }

    function setRoyaltiesReceiver(address newRoyaltiesReceiver)
    external onlyOwner {
        require(newRoyaltiesReceiver != _royaltiesReceiver); // dev: Same address
        _royaltiesReceiver = newRoyaltiesReceiver;
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view
    returns (address receiver, uint256 royaltyAmount) {
        uint256 _royalties = (_salePrice * royaltiesPercentage) / 100;
        return (_royaltiesReceiver, _royalties);
    }
}
