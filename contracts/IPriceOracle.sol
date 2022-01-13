//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IPriceOracle{
    function getPriceOHM() external view returns(uint);
    function basePrice() external view returns(uint);
}