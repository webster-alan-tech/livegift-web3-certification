// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title BlockExplorer
/// @notice Registro e consulta de "transações" internas entre contratos
contract BlockExplorer {
    struct TxRecord {
        uint256 timestamp;
        address sender;
        address receiver;
        string action;
        uint256 value;
        string metadata;
    }

    TxRecord[] private transactions;

    event TransactionLogged(
        uint256 indexed index,
        address indexed sender,
        address indexed receiver,
        string action,
        uint256 value,
        string metadata
    );

    /// @notice Registra uma transação (pode ser chamada por qualquer contrato autorizado)
    function logTransaction(
        address receiver,
        string calldata action,
        uint256 value,
        string calldata metadata
    ) external {
        TxRecord memory record = TxRecord({
            timestamp: block.timestamp,
            sender: msg.sender,
            receiver: receiver,
            action: action,
            value: value,
            metadata: metadata
        });

        transactions.push(record);

        emit TransactionLogged(
            transactions.length - 1,
            msg.sender,
            receiver,
            action,
            value,
            metadata
        );
    }

    /// @notice Retorna uma transação por índice
    function getTransaction(uint256 index) external view returns (
        uint256 timestamp,
        address sender,
        address receiver,
        string memory action,
        uint256 value,
        string memory metadata
    ) {
        TxRecord memory txr = transactions[index];
        return (
            txr.timestamp,
            txr.sender,
            txr.receiver,
            txr.action,
            txr.value,
            txr.metadata
        );
    }

    /// @notice Retorna a quantidade total de transações registradas
    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }
}
