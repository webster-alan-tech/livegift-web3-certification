// Módulo 2: Modelo UTXO e Modelo de Conta
pragma solidity ^0.8.0;

contract M2_UTXO_Account {
    struct UTXO {
        address owner;
        uint256 amount;
    }

    mapping(bytes32 => UTXO) public utxos;
    mapping(address => uint256) public balances;

    function createUTXO(bytes32 id, address owner, uint256 amount) public {
        utxos[id] = UTXO(owner, amount);
    }

    function transferAccount(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}  