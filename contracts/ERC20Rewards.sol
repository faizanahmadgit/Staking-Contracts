// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract ERC20Rewards is ERC20, ERC20Burnable, Ownable {

  mapping(address => bool) controllers;

  mapping(address => uint256) private _balances;
  uint256 private _totalSupply; //Minted supply , but not included pre-mint supply
  uint256 private MaxUp;
  uint256 constant MAXIMUMSUPPLY = 2000000*10**18; //2Million 
  
  constructor() ERC20("ERC20Rewards", "ERCR") { 
    _mint(msg.sender, 1000000*10**18); //not added in totalsupply as we override-d, premint
  }

  function mint(address to, uint256 amount) external {
    require(controllers[msg.sender], "Only controllers can mint");
    require((MaxUp + amount) < MAXIMUMSUPPLY ,"Max Supply Reached");
    _totalSupply += amount;
    MaxUp += amount;
    _balances[to] += amount;
    _mint(to, amount);
  }

  function burnFrom(address account, uint256 amount) public override {
      if (controllers[msg.sender]) {
          _burn(account, amount);
      }
      else {
          super.burnFrom(account, amount);
      }
  }

  function addController(address controller) external onlyOwner {
    controllers[controller] = true;
  }

  function removeController(address controller) external onlyOwner {
    controllers[controller] = false;
  }

  function totalSupply() public override view returns (uint256){
    return _totalSupply;
  }
  function maxSupply() public pure returns(uint256) {
    return MAXIMUMSUPPLY;
  }
}