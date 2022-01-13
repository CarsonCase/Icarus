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
    
    function balanceOf(address _user) public view override returns(uint256){
        uint sBalUser = super.balanceOf(_user);
        uint sBalThis = super.balanceOf(address(this));
        uint sBalTotal = super.totalSupply();
        if(sBalThis == 0){
            return sBalUser;
        }
        // 100 in contract
        // 200 in user
        // 300 total
        // should be 300 for user
        return(sBalUser + 
                (sBalThis * ( sBalTotal * sBalUser / (sBalTotal - sBalThis)) / sBalTotal)
                );
    }

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