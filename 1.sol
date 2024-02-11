// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataTrade {
    struct Commitment {
        uint256 value1;
        uint256 value2;
        uint256 value3;
    }

    // 用于存储每个clientId对应的Commitment
    mapping(uint256 => Commitment) public commitments;

    // 接收一个clientId和三个值，并将它们存储
    function ReceiveCommitment(uint256 clientId, uint256 val1, uint256 val2, uint256 val3) public {
        // 创建一个新的Commitment结构体实例
        Commitment memory newCommitment = Commitment({
            value1: val1,
            value2: val2,
            value3: val3
        });

        // 使用给定的clientId将新创建的Commitment实例存储在commitments映射中
        commitments[clientId] = newCommitment;
    }

    // 其他合约的函数和逻辑可以在这里继续定义
}
