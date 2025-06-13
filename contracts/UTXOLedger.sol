// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title UTXOLedger
/// @notice Implementa um modelo simples de UTXO (Unspent Transaction Output) em Solidity
contract UTXOLedger {
    struct UTXO {
        address owner;
        uint256 amount;
        bool spent;
    }

    uint256 public nextUtxoId = 0;
    mapping(uint256 => UTXO) public utxos;

    event UTXOCreated(uint256 indexed utxoId, address indexed owner, uint256 amount);
    event UTXOSpent(uint256 indexed utxoId, address indexed spender);
    event UTXOSplit(uint256 indexed fromUtxo, uint256[] newUtxos, address indexed spender);

    modifier onlyOwner(uint256 utxoId) {
        require(utxos[utxoId].owner == msg.sender, "Não é o dono do UTXO");
        require(!utxos[utxoId].spent, "UTXO já gasto");
        _;
    }

    /// @notice Cria um novo UTXO (ex: como em um depósito inicial)
    function createUtxo(address owner, uint256 amount) external returns (uint256) {
        uint256 utxoId = nextUtxoId++;
        utxos[utxoId] = UTXO(owner, amount, false);
        emit UTXOCreated(utxoId, owner, amount);
        return utxoId;
    }

    /// @notice Gasta um UTXO inteiro sem gerar troco
    function spendUtxo(uint256 utxoId) external onlyOwner(utxoId) {
        utxos[utxoId].spent = true;
        emit UTXOSpent(utxoId, msg.sender);
    }

    /// @notice Gasta um UTXO e cria novos UTXOs (simulando troco ou transferência parcial)
    function spendAndSplit(uint256 utxoId, address[] calldata recipients, uint256[] calldata amounts)
        external
        onlyOwner(utxoId)
        returns (uint256[] memory)
    {
        require(recipients.length == amounts.length, "Listas de tamanhos diferentes");

        uint256 totalOut = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalOut += amounts[i];
        }

        require(totalOut <= utxos[utxoId].amount, "Montante insuficiente");

        utxos[utxoId].spent = true;

        uint256[] memory newUtxos = new uint256[](recipients.length);
        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 newId = nextUtxoId++;
            utxos[newId] = UTXO(recipients[i], amounts[i], false);
            newUtxos[i] = newId;
            emit UTXOCreated(newId, recipients[i], amounts[i]);
        }

        emit UTXOSplit(utxoId, newUtxos, msg.sender);
        return newUtxos;
    }

    /// @notice Consulta se um UTXO está disponível (não gasto)
    function isUnspent(uint256 utxoId) external view returns (bool) {
        return !utxos[utxoId].spent;
    }

    /// @notice Retorna informações de um UTXO
    function getUtxo(uint256 utxoId) external view returns (address, uint256, bool) {
        UTXO memory u = utxos[utxoId];
        return (u.owner, u.amount, u.spent);
    }
}

