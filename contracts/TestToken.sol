// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20{
    constructor() ERC20("Testing Token", "TST"){
        _mint(msg.sender, 10000000000 ether);
    }
}