pragma solidity ^0.7.0;

  interface IERC20{
      
      function totalSupply() external view returns(uint256);
      function balanceOf(address account) external view returns(uint256);
      function transfer(address recipient, uint256 amount) external returns (bool); 
      
     // event Transfer(address indexed _from, address indexed _to, uint256 _value);
  }
  
  
  contract SALToken is IERC20{
      
      string public  name;
      string public  symbol;
      uint8 public  decimal;
      
     
      
      
      
     // Approval event
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens); 
      // Transfer events
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    
    
    
    // balance mapping
    mapping (address => uint256) public balances;
    // allowance mapping
    mapping (address => mapping(address => uint256)) public allowed;
    
    
    uint256 _totalSupply;
    address admin;
    
    
    
    //constructor
    constructor(string memory _name, string memory _symbol, uint8 _decimal, uint256 _tsupply) public{
        name = _name;
        symbol = _symbol;
        decimal = _decimal;
        _totalSupply = _tsupply;
        admin = msg.sender;
        balances[msg.sender] = _totalSupply;
    }
    
    
    
    function totalSupply() public override view returns(uint256){
        return _totalSupply;
    }
    
     function balanceOf(address tokenOwner) public override view returns(uint256){
         return balances[tokenOwner];
     }
     
     
     // transfer function
     function transfer(address receiver, uint256 numTokens) public override returns(bool) {
        
        // the user that is transfering amount must have sufficient balance
        require(numTokens <= balances[msg.sender]);
        //subtract the amount from sender
        balances[msg.sender] -= numTokens;
        // add the amount to the receiver account
        balances[receiver] += numTokens;
        // emit
        emit Transfer(msg.sender, receiver, numTokens);
        
        return true;
        
    }

    // mint modifier
    modifier onlyAdmin{
        require(msg.sender == admin, 'only admin can mint token');
        _;
    }
    
    // mint function 
    function mint(uint256 _quantity) public onlyAdmin returns(uint256){
        _totalSupply += _quantity;
        balances[msg.sender] += _quantity;
        
        return _totalSupply;
    }
    
    
    // burn function 
    function burn(uint256 _quantity) public onlyAdmin returns(uint256){
        require(balances[msg.sender] >= _quantity, "You doest have enough balance");
        _totalSupply -= _quantity;
        balances[msg.sender] -= _quantity;
        
        return _totalSupply;
    }
    
    
    // allowance function
    function allowance(address _owner, address _spender) public view returns(uint256 remaining){
        return allowed[_owner][_spender];
        
    }
    
    // Approve function
    function Approve(address _spender, uint _value) public returns(bool success){
        // increase allowlance
        allowed[msg.sender][_spender] = _value;
        // emit
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    // Transferfrom function
    function Transferfrom(address _from, address _to, uint256 _amount) public{
       // check the balance of allowance user
       require(balances[_from] >= _amount, 'The user from which money has been dedicuted have insufficient balance');
       // check the allowance of msg.sender
       require(allowed[_from][msg.sender] >= _amount, 'The spender doest have required allowance');
       // subtract the amount from user
       balances[_from] -= _amount;
       // Add the amount to the user
       balances[_to] += _amount;
       // decrease the allowance
       allowed[_from][msg.sender] -= _amount;
       // emit Transfer
       emit Transfer(_from, _to, _amount);
    
       // emit Approve
       emit Approval(_from, msg.sender, _amount);
    
    
    }
    
    
  }
      
  
