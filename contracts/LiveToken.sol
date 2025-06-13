// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title LiveToken
/// @notice Token ERC20 usado para presentear e interagir dentro da plataforma LiveGifts
contract LiveToken is ERC20, Ownable {
    uint8 private immutable _decimals;

    /// @param name Nome do token (ex: "Live Gift Token")
    /// @param symbol Símbolo do token (ex: "LGT")
    /// @param initialSupply Quantidade inicial a ser mintada para o owner
    /// @param decimals_ Quantidade de casas decimais do token
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint8 decimals_
    ) ERC20(name, symbol) {
        _decimals = decimals_;
        _mint(msg.sender, initialSupply);
    }

    /// @notice Sobrescreve os decimais (por padrão 18) se necessário
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /// @notice Permite ao dono mintar novos tokens
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /// @notice Permite ao dono queimar tokens de um endereço
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}

