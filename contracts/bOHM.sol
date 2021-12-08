//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IPriceOracle.sol";
import "./IReserve.sol";

contract bOHM is ERC20{

    IReserve public reserve;
    IPriceOracle public priceOracle;

    constructor(address _reserve, address _priceOracle) ERC20("bOHM", "base pegged OHM"){
        reserve = IReserve(_reserve);
        priceOracle = IPriceOracle(_priceOracle);
    }

    /**
    * @dev function to enter the bOHM pool
    * mints as many bOHM tokens as there are bOHM represented
    * @param _amount of token to send in
     */
    function enter(uint _amount) external{
        uint tokens = _amount / priceOracle.basePrice();
        reserve.stake(msg.sender, _amount);
        _mint(msg.sender, tokens);
    }

    /**
    * @dev function to exit bOHM pool and receive tokens for burning
    * @param _amount to exit with
     */
    function exit(uint _amount) external{
        _burn(msg.sender, _amount);
        reserve.unstake(msg.sender, _amount / priceOracle.basePrice());
    }
} 