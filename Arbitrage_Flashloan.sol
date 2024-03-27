// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "@uniswap/swap-router-contracts/contracts/interfaces/IV3SwapRouter.sol";

contract FlashloanArbitrage is FlashLoanSimpleReceiverBase {
    using SafeMath for uint256;

    uint256 constant MAX_UINT = 2**256 - 1;

    address private constant SWAP_ROUTER =
        0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E;
    address private constant UHKD = 0x64B6f44862E8800EBd63Cd7f1319C8BF0BC1bb99;
    address public constant USDC = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;
    address public owner;

    IV3SwapRouter public immutable swapRouter = IV3SwapRouter(SWAP_ROUTER);

    event ArbitrageResult(uint256 amountOut);
    event BalanceTransferred(address recipient, uint256 amount);

    constructor(IPoolAddressesProvider provider)
        FlashLoanSimpleReceiverBase(provider)
    {
        owner = msg.sender;
    }

    function createFlashLoan(address asset, uint256 amount) external {
        address receiver = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(receiver, asset, amount, params, referralCode);
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        // Assume `doArbitrage` is adequately modified not to emit unnecessary logs.
        this.doArbitrage(1000000);

        uint256 amountOwing = amount.add(premium);
        IERC20(asset).approve(address(POOL), amountOwing);

        return true;
    }

    function doArbitrage(uint256 amountIn)
        external
        returns (uint256 amountOut)
    {
        IERC20(USDC).approve(address(swapRouter), MAX_UINT);
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter
            .ExactInputSingleParams({
                tokenIn: USDC,
                tokenOut: UHKD,
                fee: 3000,
                recipient: address(this),
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        uint256 amountOut1 = swapRouter.exactInputSingle(params);

        TransferHelper.safeApprove(UHKD, address(swapRouter), MAX_UINT);

        IV3SwapRouter.ExactInputSingleParams memory params2 = IV3SwapRouter
            .ExactInputSingleParams({
                tokenIn: UHKD,
                tokenOut: USDC,
                fee: 500,
                recipient: address(this),
                amountIn: amountOut1,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params2);

        emit ArbitrageResult(amountOut);
        return amountOut;
    }

    // Modifier to restrict access to the owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function transferUSDCBalance(address recipient) external onlyOwner {
        uint256 balance = IERC20(USDC).balanceOf(address(this));
        require(balance > 0, "No USDC balance to transfer");

        TransferHelper.safeTransfer(USDC, recipient, balance);

        emit BalanceTransferred(recipient, balance);
    }
}
