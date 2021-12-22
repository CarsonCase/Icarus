//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IPriceOracle.sol";
import "./IReserve.sol";

contract bOHM is ERC20{

    address public reserve;
    IPriceOracle public priceOracle;

    constructor(address _reserve, address _priceOracle) ERC20("bOHM", "base pegged OHM"){
        reserve = _reserve;
        priceOracle = IPriceOracle(_priceOracle);
    }

    modifier onlyReserve(){
        require(msg.sender == reserve, "only reserve may call this function");
        _;
    }
    // Not sure if I'll want this later
    // /**
    // * @dev function to enter the bOHM pool
    // * mints as many bOHM tokens as there are bOHM represented
    // * @param _user is the user to take funds from and mint bOHM to
    // * @param _amount of token to send in
    //  */
    // function enter(address _user, uint _amount) external{
    //     // send funds from user to reserve
    //     
    //     _mint(_user, tokens);
    // }
    /**
    * @dev function to enter bOHM pool and receive tokens
    * @param _user is the user to mint
    * @param _amount to mint
     */
    function mint(address _user, uint _amount) external onlyReserve{
        _mint(_user, _amount);
    }

    /**
    * @dev function to exit bOHM pool
    * @param _user is the user to burn
    * @param _amount to burn
     */
    function burn(address _user, uint _amount) external onlyReserve{
        _burn(_user, _amount);
    }
} 