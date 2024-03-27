import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "@uniswap/swap-router-contracts/contracts/interfaces/IV3SwapRouter.sol";

contract Arbitrage {
    uint256 constant MAX_UINT = 2**256 - 1;

    address private constant SWAP_ROUTER =
        0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E;

    address private constant UHKD = 0x64B6f44862E8800EBd63Cd7f1319C8BF0BC1bb99;
    address public constant USDC = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;

    IV3SwapRouter public immutable swapRouter = IV3SwapRouter(SWAP_ROUTER);

    event ArbitrageResult(uint256 amountOut);

    function doArbitrage(uint256 amountIn)
        external
        returns (uint256 amountOut)
    {
        TransferHelper.safeTransferFrom(
            UHKD,
            msg.sender,
            address(this),
            amountIn
        );

        TransferHelper.safeApprove(UHKD, address(swapRouter), amountIn);

        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter
            .ExactInputSingleParams({
                tokenIn: UHKD,
                tokenOut: USDC,
                fee: 3000, 
                recipient: address(this),
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        uint256 amountOut1 = swapRouter.exactInputSingle(params);


        emit ArbitrageResult(amountOut1);
        return amountOut1;
    }
}
