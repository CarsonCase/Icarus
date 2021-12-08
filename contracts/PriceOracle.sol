//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IPriceOracle.sol";

contract PriceOracle is IPriceOracle{
    uint public override basePrice = 2;
    uint public override getPriceOHM = 10;

    function setPrices(uint _base, uint _ohm) external{
        basePrice = _base;
        getPriceOHM = _ohm;
    }
}