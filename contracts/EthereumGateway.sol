
// SPDX-License-Identifier: MIT
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title EthereumGateway
/// @notice Um contrato que serve como gateway para interações com contratos como Custody ou Ledger
contract EthereumGateway {
    address public owner;

    /// @notice Endereço do contrato de custódia
    address public custodyContract;

    /// @notice Endereço do contrato de contabilidade
    address public ledgerContract;

    /// Eventos
    event CustodyContractSet(address indexed newAddress);
    event LedgerContractSet(address indexed newAddress);
    event ForwardedCall(address indexed target, bytes data, bytes result);

    /// @dev Apenas o dono pode executar
    modifier onlyOwner() {
        require(msg.sender == owner, "Apenas o dono pode executar");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Define o contrato de custódia
    function setCustodyContract(address _custody) external onlyOwner {
        require(_custody != address(0), "Endereço inválido");
        custodyContract = _custody;
        emit CustodyContractSet(_custody);
    }

    /// @notice Define o contrato de ledger
    function setLedgerContract(address _ledger) external onlyOwner {
        require(_ledger != address(0), "Endereço inválido");
        ledgerContract = _ledger;
        emit LedgerContractSet(_ledger);
    }

    /// @notice Encaminha chamada para outro contrato
    /// @param target Endereço do contrato de destino
    /// @param data Dados codificados da chamada (ABI.encodeWithSignature etc.)
    /// @return result O retorno da chamada
    function forwardCall(address target, bytes calldata data) external onlyOwner returns (bytes memory result) {
        require(target != address(0), "Endereço inválido");
        (bool success, bytes memory res) = target.call(data);
        require(success, "Chamada falhou");
        emit ForwardedCall(target, data, res);
        return res;
    }

    /// @notice Permite receber ETH
    receive() external payable {}

    /// @notice Saque de ETH pelo owner
    function withdrawETH(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Saldo insuficiente");
        payable(owner).transfer(amount);
    }
}
