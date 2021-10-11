// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;


interface Q3TokenInterface{
    
    function transfer( address from, address to, uint256 amount) external returns(bool);
    function mint(uint256 amount) external returns(bool);
    function balance() external returns(uint256);
}

contract Q3Token is Q3TokenInterface{
    
    
    // balance mapping
    mapping(address => uint256) internal _balances;
    
    function transfer(address from, address to, uint256 amount) override external returns(bool){
        // balance from msg.sender less by amount
        // balance to add of amount
        
        _balances[msg.sender] >= amount;
        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + amount;
        return true;
    }
    
    function mint(uint256 amount) override public returns(bool){
         _balances[msg.sender] = _balances[msg.sender] + amount;
         return true;
    }
    
    function balance() override public view returns(uint256){
        return _balances[msg.sender];
    }
    
    
}

