// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AccountLedger.sol";

/// @title Custody - Armazena e libera ETH sob controle de um custodiante
/// @notice Um contrato de custódia simples para depósitos e saques de ETH

contract Custody {
    address public owner;
    AccountLedger public ledger; 

    event Deposited(address indexed sender, uint256 amount);
    event Withdrawn(address indexed recipient, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _ledgerAddress) {
        owner = msg.sender;
        ledger = AccountLedger(_ledgerAddress);
    }

    /// @notice Recebe ETH e armazena no contrato
    receive() external payable {
        require(msg.value > 0, "Nada a depositar");

        // Atualiza o saldo do usuário no ledger
        ledger.credit(msg.sender, "eth", int256(msg.value));

        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Permite ao dono sacar ETH do contrato
    /// @param to Endereço de destino
    /// @param amount Quantia em wei
    function withdraw(address payable to, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Saldo insuficiente");

        // Atualiza o saldo no ledger
        ledger.debit(to, "eth", int256(amount));

        to.transfer(amount);
        emit Withdrawn(to, amount);
    }
    /// @notice Consulta o saldo total armazenado no contrato
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

