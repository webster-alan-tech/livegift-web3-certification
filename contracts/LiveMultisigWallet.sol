// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title LiveMultisigWallet
/// @notice Carteira com múltiplas assinaturas para aprovar e executar transações críticas
contract LiveMultisigWallet {
    address[] public owners;
    uint256 public requiredConfirmations;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
    }

    mapping(address => bool) public isOwner;
    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public isConfirmed;

    event Deposit(address indexed sender, uint256 amount);
    event SubmitTransaction(uint256 indexed txId, address indexed to, uint256 value);
    event ConfirmTransaction(uint256 indexed txId, address indexed by);
    event ExecuteTransaction(uint256 indexed txId);
    event RevokeConfirmation(uint256 indexed txId, address indexed by);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Não é dono");
        _;
    }

    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "Transação inexistente");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].executed, "Já executada");
        _;
    }

    modifier notConfirmed(uint256 _txId) {
        require(!isConfirmed[_txId][msg.sender], "Já confirmada");
        _;
    }

    constructor(address[] memory _owners, uint256 _requiredConfirmations) {
        require(_owners.length > 0, "Deve ter pelo menos um dono");
        require(
            _requiredConfirmations > 0 && _requiredConfirmations <= _owners.length,
            "Número inválido de confirmações"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address ownerAddr = _owners[i];
            require(ownerAddr != address(0), "Endereço inválido");
            require(!isOwner[ownerAddr], "Dono duplicado");
            isOwner[ownerAddr] = true;
            owners.push(ownerAddr);
        }

        requiredConfirmations = _requiredConfirmations;
    }

    /// @notice Recebe ETH na carteira
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Envia uma nova transação para aprovação
    function submitTransaction(address to, uint256 value, bytes calldata data) external onlyOwner {
        uint256 txId = transactions.length;

        transactions.push(Transaction({
            to: to,
            value: value,
            data: data,
            executed: false,
            confirmations: 0
        }));

        emit SubmitTransaction(txId, to, value);
    }

    /// @notice Confirma uma transação proposta
    function confirmTransaction(uint256 txId)
        external
        onlyOwner
        txExists(txId)
        notExecuted(txId)
        notConfirmed(txId)
    {
        isConfirmed[txId][msg.sender] = true;
        transactions[txId].confirmations += 1;

        emit ConfirmTransaction(txId, msg.sender);

        if (transactions[txId].confirmations >= requiredConfirmations) {
            executeTransaction(txId);
        }
    }

    /// @notice Executa a transação se tiver confirmações suficientes
    function executeTransaction(uint256 txId) public onlyOwner txExists(txId) notExecuted(txId) {
        Transaction storage txn = transactions[txId];

        require(txn.confirmations >= requiredConfirmations, "Confirmações insuficientes");

        txn.executed = true;
        (bool success, ) = txn.to.call{value: txn.value}(txn.data);
        require(success, "Falha na execução");

        emit ExecuteTransaction(txId);
    }

    /// @notice Permite revogar uma confirmação
    function revokeConfirmation(uint256 txId)
        external
        onlyOwner
        txExists(txId)
        notExecuted(txId)
    {
        require(isConfirmed[txId][msg.sender], "Transação não confirmada por você");

        isConfirmed[txId][msg.sender] = false;
        transactions[txId].confirmations -= 1;

        emit RevokeConfirmation(txId, msg.sender);
    }

    // Funções de leitura
    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(uint256 txId) external view returns (
        address to,
        uint256 value,
        bytes memory data,
        bool executed,
        uint256 confirmations
    ) {
        Transaction memory txn = transactions[txId];
        return (txn.to, txn.value, txn.data, txn.executed, txn.confirmations);
    }
}

