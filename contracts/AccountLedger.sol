// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Account Ledger com múltiplos tipos de saldo por usuário
/// @author 
/// @notice Permite crédito e débito de diferentes categorias de saldo por endereço
contract AccountLedger {
    /// @dev Mapping de endereço => (tipo de saldo => saldo)
    mapping(address => mapping(string => int256)) private balances;

    /// @notice Evento emitido quando um saldo é creditado
    event BalanceCredited(address indexed account, string indexed balanceType, int256 amount);

    /// @notice Evento emitido quando um saldo é debitado
    event BalanceDebited(address indexed account, string indexed balanceType, int256 amount);

    /// @notice Consulta o saldo de um tipo específico de conta para um endereço
    function getBalance(address account, string calldata balanceType) external view returns (int256) {
        return balances[account][balanceType];
    }

    /// @notice Credita um valor positivo a um tipo específico de saldo
    function credit(address account, string calldata balanceType, int256 amount) external {
        require(amount > 0, "Valor precisa ser positivo");
        balances[account][balanceType] += amount;
        emit BalanceCredited(account, balanceType, amount);
    }

    /// @notice Debita um valor positivo de um tipo específico de saldo
    function debit(address account, string calldata balanceType, int256 amount) external {
        require(amount > 0, "Valor precisa ser positivo");
        require(balances[account][balanceType] >= amount, "Saldo insuficiente");
        balances[account][balanceType] -= amount;
        emit BalanceDebited(account, balanceType, amount);
    }

    /// @notice Consulta todos os saldos disponíveis de um endereço (não implementado pois Solidity não permite retorno de mappings aninhados)
    /// @dev Sugestão: manter uma lista de balanceTypes por usuário caso precise listar todos
}
