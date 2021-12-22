//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./OlympusLink.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IPriceOracle.sol";
import "./SharePool.sol";

interface IMintableERC20 is IERC20{
    function mint(address,uint) external;
    function burn(address,uint) external;
}

/**
* @title Reserve
* @author Carson Case (carsonpcase@gmail.com)
* @dev Reserve contract stakes and swaps OHM. Also issues bOHM and share tokens
 */
contract Reserve is SharePool, OlympusLink, Ownable{
    uint constant ONE_HUNDRED_PERCENT = 10**50;

    uint stakedAmount = 0;
    uint AStaked = 0;
    uint BStaked = 0;
    uint public A_APR = 0;
    address public bOHM;
    address public sharePool;
    IPriceOracle public priceOracle;

    constructor(address _olympus, address _priceOracle) SharePool(address(0)) OlympusLink(_olympus) Ownable(){
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
     */
    function stake(bool _bOHM, address _staker, uint _amountStable) external{
        uint toStakeOHM = _amountStable / priceOracle.getPriceOHM();
        require(beforeStake(), "There is not enough funds in share pool to insure this deposit");
        if(_bOHM){
            uint bOHMTokens = _amountStable / priceOracle.basePrice();
            IMintableERC20(bOHM).mint(msg.sender, bOHMTokens);
            AStaked += toStakeOHM;
            _stake(toStakeOHM);
        }else{
            BStaked += toStakeOHM;
            _stake(toStakeOHM);
        }
    }

    // Leave the bar. Claim back your TOKENs.
    // Unlocks the staked + gained Token and burns xToken
    function leave(uint256 _share) public override{
        // Gets the amount of xToken in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of Token the xToken is worth

        uint256 totalStableVal =  stakedAmount * priceOracle.getPriceOHM();
        uint256 totalbOHMVal = IERC20(bOHM).totalSupply();
        uint256 stableShare = (_share * totalStableVal - totalbOHMVal / (totalShares));
        _burn(msg.sender, _share);

        // unstake the tokens and swap to send
        uint toUnStakeOHM = stableShare / priceOracle.getPriceOHM();
        BStaked -= toUnStakeOHM;
        _unstake(toUnStakeOHM);
        // SWAP for stable here
        token.transfer(msg.sender, token.balanceOf(address(this)));

        require(beforeStake(), "You are removing too many funds. This causes problems with the system. Please understand :/");
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