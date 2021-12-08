//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./OlympusLink.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IPriceOracle.sol";

contract Reserve is OlympusLink, Ownable{
    address token = address(0); // For now

    uint stakedAmount = 12;
    uint public A_APR = 0;
    address public bOHM;
    address public sharePool;
    IPriceOracle public priceOracle;

    constructor(address _olympus, address _priceOracle) OlympusLink(_olympus) Ownable(){
        priceOracle = IPriceOracle(_priceOracle);
    }

    function setAddresses(address _bOHM, address _sharePool) external onlyOwner(){
        bOHM = _bOHM;
        sharePool = _sharePool;
    }

    function stake(address _staker, uint _amount) external{
        if(msg.sender == bOHM){
            (uint A, uint B, uint A_b) = getRatioVars(_amount,0);
            // ratio of A/B determines if there is room to enter A
            require(A/B >= (A_b - B) / B, "There is not enough funds in shrae pool to insure this deposit");
            stakedAmount += _amount / priceOracle.getPriceOHM();
            _stake(_amount / priceOracle.getPriceOHM());
        }else if(msg.sender == sharePool){
            _stake(_amount / priceOracle.getPriceOHM());
        }else{
            revert("Only bOHM or SharePool may call this function");
        }
    }

    function unstake(address _staker, uint _amount) external{
        if(msg.sender == bOHM){
            _unstake(_amount / priceOracle.getPriceOHM());           
        }else if(msg.sender == sharePool){
            (uint A, uint B, uint A_b) = getRatioVars(0,_amount);
            require(A_b > B && (A_b - B) / B > A/B, "You are removing too many funds. This causes problems with the system. Please understand :/");
            A_APR = ((A_b - B) / B) / (A/B);
            _unstake(_amount / priceOracle.getPriceOHM());
        }else{
            revert("Only bOHM or SharePool may call this function");
        }
    }

    function getRatioVars(uint _toAddA, uint _toRemoveB) public returns(uint,uint,uint){
            uint ASupply = IERC20(bOHM).totalSupply() + _toAddA;
            // A_b = Value of all bOHM at current base price
            // A = Value of all bOHM at market price
            // B = Value of all of share pool at market price
            uint A_b = ASupply * priceOracle.basePrice();
            uint A = ASupply * priceOracle.getPriceOHM();
            uint B = priceOracle.getPriceOHM() * getStakeBalance() + _toAddA - _toRemoveB - A;
            return(A,B,A_b);
    }

    function getStakeBalance() public view returns(uint){
        return stakedAmount;
    }

    
}