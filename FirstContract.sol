pragma solidity ^0.7.0;

contract FirstContract{ 
    
    // In this function we declear parameters in returns
    
    function Name() public view returns(string memory a) {
        
        a = "Ali";
        
        return a;
        
    }
    
    // I this function we declear parameter in returns and Shadow
    function Shadow() public view returns(uint a){
        
        bool a = true;
        return 34;
    }
    
    // In this function we we declear multiple parameters
    function multipleReturns() public view returns(uint, bool, string memory) {
    
       uint _age = 45;
       bool _isFeePaid = true;
       string memory _name = "Ali";
       
       
        return(_age, _isFeePaid, _name);
    }
    
    
    // In this function we all the ecleared parameters value in a tupple
    function getValues() public view returns(uint, bool, string memory){
        return (45, true, "Salman");
    }
    
    // In this function we declear the parameters in return and then initialize all the veriable and make a tupple for return values.
    function returnThroughTupple() public view returns(uint a, bool b, string memory c){
        
        a = 25;
        b = true;
        c = "Ali";
      
      return(a, b, c);
        
    }

}
