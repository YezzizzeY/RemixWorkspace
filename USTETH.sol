// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 引入OpenZeppelin的ERC20和Ownable合约
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title USTETH
 * @dev 实现一个简单的ERC20代币，具有额外的只有所有者可以调用的铸币功能。
 */
contract USTETH is ERC20, Ownable {
    /**
     * @dev 构造函数，设置代币的名称和符号。
     */
    constructor() ERC20("USTETH", "UETH") Ownable(msg.sender) {}

    /**
     * @dev 铸造代币。
     * @param to 接收新铸造代币的地址。
     * @param amount 铸造代币的数量。
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}