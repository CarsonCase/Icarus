//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IPriceOracle.sol";

contract PriceOracle is IPriceOracle{
    uint internal _basePrice = 1;
    uint internal _getPriceOHM = 1;

    function setPrices(uint _base, uint _ohm) external{
        _basePrice = _base;
        _getPriceOHM = _ohm;
    }

    function basePrice() external override view returns(uint){
        return(_basePrice);
    }

    function getPriceOHM() external override view returns(uint){
        return(_getPriceOHM);
    }

}