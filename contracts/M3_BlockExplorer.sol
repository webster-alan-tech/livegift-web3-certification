// Módulo 3: Explorador de Blocos
pragma solidity ^0.8.0;

contract M3_BlockExplorer {
    struct TxInfo {
        address from;
        address to;
        uint256 value;
        uint256 timestamp;
    }

    TxInfo[] public transactions;

    function logTransaction(address to, uint256 value) public {
        transactions.push(TxInfo(msg.sender, to, value, block.timestamp));
    }

    function getTransaction(uint index) public view returns (TxInfo memory) {
        return transactions[index];
    }
}  