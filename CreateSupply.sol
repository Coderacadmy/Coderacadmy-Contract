// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol';

contract MyERC20Token is ERC20 {
    
    address _contractOwner;
   
    // constructor
    constructor() ERC20 ("LEOTokan", "SAL"){
       _mint(msg.sender, 1000);
       _contractOwner = msg.sender;
    }
   
     //function to check the current  contract ether balance.         
    function checkContractEtherBalance() public view returns(uint256){
        
        // function that sends ether using "transfer" instead of sender as it shows exception
        return address(this).balance; 
    
    }

  } // end  of contract


contract SalesToken {
    
    // made an instance of the above owner  contract    
    
    MyERC20Token obj;  
    
    constructor(address _address){
       obj = MyERC20Token (_address);
        
    }

    /*function for buytokens after sending ether,here i have defined that 1 ether=10 tokens, so. 0.1 ether=1tokens.
    so if i here recieve 1 ether in the msg.value then the recipient will recieve 10 ethers against it. in*/

    function buytokens (address sender, address recipient) external payable {
        
        uint256 _tokenvalue = msg.value / 0.1 ether;
        
        // function making the token tranfer.
        obj.transferFrom(sender, recipient, _tokenvalue); 
    
    }
    
    // function to check the current  contract ether balance.

    function _checkContractEtherBalance() public view returns (uint256) {
        
        // function that sends ether using "transfer" instead of sender as it shows exception
        return address(this).balance; 
    
    }

  }
