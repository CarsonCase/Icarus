//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./OlympusLink.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IPriceOracle.sol";

/**
* @title Reserve
* @author Carson Case (carsonpcase@gmail.com)
* @dev Reserve contract stakes and swaps OHM. Also issues bOHM and share tokens
 */
contract Reserve is OlympusLink, Ownable{
    uint constant ONE_HUNDRED_PERCENT = 10**50;
    address token = address(0); // For now

    uint stakedAmount = 0;
    uint AStaked = 0;
    uint BStaked = 0;
    uint public A_APR = 0;
    address public bOHM;
    address public sharePool;
    IPriceOracle public priceOracle;

    constructor(address _olympus, address _priceOracle) OlympusLink(_olympus) Ownable(){
        priceOracle = IPriceOracle(_priceOracle);
    }

    /**
    * @dev set bOHM and sharePool addresses
     */
    function setAddresses(address _bOHM, address _sharePool) external onlyOwner(){
        bOHM = _bOHM;
        sharePool = _sharePool;
    }

    /**
    * @dev stake in the reserve with either bOHM of sharePool
    * TODO Change this. Enter for both pools in this contract and simply call mint in the others
     */
    function stake(address _staker, uint _amount) external{
        uint toStake = _amount / priceOracle.getPriceOHM();
        require(beforeStake(), "There is not enough funds in shrae pool to insure this deposit");
        if(msg.sender == bOHM){
            // ratio of A/B determines if there is room to enter A
            AStaked += toStake;
            _stake(toStake);
        }else if(msg.sender == sharePool){
            BStaked += toStake;
            _stake(toStake);
        }else{
            revert("Only bOHM or SharePool may call this function");
        }
    }

    function unstake(address _staker, uint _amount) external{
        uint toUnStake = _amount / priceOracle.getPriceOHM();
        require(beforeStake(), "You are removing too many funds. This causes problems with the system. Please understand :/");
        if(msg.sender == bOHM){
            _unstake(toUnStake); 
            AStaked -= toUnStake;          
        }else if(msg.sender == sharePool){
            BStaked -= toUnStake;      
            _unstake(toUnStake);
        }else{
            revert("Only bOHM or SharePool may call this function");
        }
    }

    function getRatioVars() public returns(uint,uint,uint){
            // A_b = Value of all bOHM at current base price
            // A = Value of all bOHM at market price
            // B = Value of all of share pool at market price
            uint A_b = IERC20(bOHM).totalSupply();
            uint A = AStaked * priceOracle.basePrice();
            uint B = BStaked * priceOracle.basePrice();
            return(A,B,A_b);
    }
    function beforeStake() public returns(bool){
            (uint A, uint B, uint A_b) = getRatioVars();
            if(B >= A_b || ONE_HUNDRED_PERCENT < (ONE_HUNDRED_PERCENT/10000)/A_b - B){
                A_APR = ONE_HUNDRED_PERCENT;
            }else{
                A_APR = (ONE_HUNDRED_PERCENT/10000)/A_b - B;
            }
            return(A+B >= A_b);
    }

    function getStakeBalance() public view returns(uint){
        return stakedAmount;
    }

    function _beforeStake(uint _amount) internal override{
        stakedAmount += _amount;
    }

    function _beforeUnstake(uint _amount) internal override{
        stakedAmount -= _amount;
    }

    
}