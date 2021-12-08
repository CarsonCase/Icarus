interface IReserve{
    function getToken() external returns(address);
    function stake(address, uint) external;
    function unstake(address, uint) external;
}
