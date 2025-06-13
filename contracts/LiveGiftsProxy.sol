// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title LiveGiftsProxy
/// @notice Proxy para upgrade de contrato LiveGifts sem alterar o endereço externo
contract LiveGiftsProxy {
    // Endereço atual da implementação do contrato
    address public implementation;

    // Dono que pode atualizar a lógica
    address public owner;

    event Upgraded(address indexed newImplementation);

    modifier onlyOwner() {
        require(msg.sender == owner, "Apenas o dono pode executar");
        _;
    }

    constructor(address _implementation) {
        owner = msg.sender;
        implementation = _implementation;
    }

    /// @notice Atualiza o endereço da lógica do contrato LiveGifts
    function upgradeTo(address newImplementation) external onlyOwner {
        require(newImplementation != address(0), "Endereço inválido");
        implementation = newImplementation;
        emit Upgraded(newImplementation);
    }

    /// @dev Encaminha qualquer chamada para a implementação atual
    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "Nenhuma implementação definida");

        assembly {
            // Copia os dados da chamada
            calldatacopy(0, 0, calldatasize())

            // Executa delegatecall para a implementação
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)

            // Copia os dados de retorno
            returndatacopy(0, 0, returndatasize())

            // Retorna os dados ou reverte com erro
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}

