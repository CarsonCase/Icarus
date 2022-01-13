//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./OlympusLink.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IPriceOracle.sol";
import "./SharePool.sol";
import "prb-math/contracts/PRBMathUD60x18.sol";

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
    using PRBMathUD60x18 for uint256;

    uint public constant ONE_HUNDRED_PERCENT = 100 ether;

    uint stakedAmount = 0;
    uint AStaked = 0;
    uint BStaked = 0;
    uint public A_APR = 0;
    address public bOHM;
    IPriceOracle public priceOracle;

    constructor(address _olympus, address _priceOracle, address _token) SharePool(_token) OlympusLink(_olympus) Ownable(){
        priceOracle = IPriceOracle(_priceOracle);
    }

    /**
    * @dev set bOHM and sharePool addresses
     */
    function init(address _bOHM) external onlyOwner(){
        bOHM = _bOHM;
    }

    /**
    * @dev stake in the reserve with bOHM
     */
    function bOHMStake(uint _amountStable) external{
        uint toStakeOHM = 1 ether * _amountStable / priceOracle.getPriceOHM();
        uint bOHMTokens = 1 ether * _amountStable / priceOracle.basePrice();
        IMintableERC20(bOHM).mint(msg.sender, bOHMTokens);
        AStaked += toStakeOHM;
        _stake(toStakeOHM);
    }

    function enter(uint256 _amountStable) public override{
        uint toStakeOHM = 1 ether * _amountStable / priceOracle.getPriceOHM();
        super.enter(_amountStable);
        BStaked += toStakeOHM;
        _stake(toStakeOHM);
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

        require(stakeCheck(), "You are removing too many funds. This causes problems with the system. Please understand :/");
    }


    function getRatioVars() public view returns(uint,uint,uint){
        // A_b = Value of all bOHM at current base price
        // A = Value of all bOHM at market price
        // B = Value of all of share pool at market price
        uint A_b = IERC20(bOHM).totalSupply();
        uint marketPrice = priceOracle.getPriceOHM();
        uint A = AStaked * marketPrice;
        uint B = BStaked * marketPrice;
        return(A,B,A_b);
    }

    function stakeCheck() public returns(bool){
            (uint A, uint B, uint A_b) = getRatioVars();
            // rebase bOHM according to last A_APR
            /// TODO make this actually based on time
            IMintableERC20(bOHM).mint(bOHM, A_APR*IMintableERC20(bOHM).totalSupply()/ONE_HUNDRED_PERCENT);
            // update new APR
            A_APR = (((A+B) - A_b).ln());
            
            return(A+B >= A_b);
    }

    function getStakeBalance() public view returns(uint){
        return stakedAmount;
    }

    function _beforeStake(uint _amount) internal override{
        require(stakeCheck(), "There is not enough funds in share pool to insure this deposit");
        stakedAmount += _amount;
    }

    function _beforeUnstake(uint _amount) internal override{
        stakedAmount -= _amount;
    }

    
}