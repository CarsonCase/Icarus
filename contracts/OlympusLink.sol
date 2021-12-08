//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract OlympusLink {
    address public immutable olympus;

    constructor(address _olympus){
        olympus = _olympus;
    }

    event Stake(uint amount);
    event Unstake(uint amount);

    /// @dev function hook to run before staking
    function _beforeStake() internal virtual{}

    /// @dev function hook to run before unstaking
    function _beforeUnstake() internal virtual{}

    /// @dev getter function for stake
    function getStake() external view returns(uint){}
    
    /// @dev stake _amount OHM in olympus for xOHM
    function _stake(uint _amount) internal{
        _beforeStake();
        emit Stake(_amount);
    }

    /// @dev unstake _amount OHM in olympus for xOHM
    function _unstake(uint _amount) internal{
        _beforeUnstake();
        emit Unstake(_amount);
    }

}
