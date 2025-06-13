// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title GiftUtilsLib
/// @notice Biblioteca de utilidades para manipulação de presentes
library GiftUtilsLib {
    /// @notice Verifica se um endereço é válido
    function isValidAddress(address addr) internal pure returns (bool) {
        return addr != address(0);
    }

    /// @notice Verifica se um valor de presente é válido (ex: maior que zero)
    function isValidAmount(uint256 amount) internal pure returns (bool) {
        return amount > 0;
    }

    /// @notice Gera um identificador hash exclusivo para um presente
    function generateGiftHash(
        address from,
        address to,
        uint256 amount,
        string memory message,
        uint256 timestamp
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(from, to, amount, message, timestamp));
    }

    /// @notice Trunca uma string para os primeiros N caracteres
    function truncateString(string memory str, uint256 maxLength) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        if (strBytes.length <= maxLength) {
            return str;
        }
        bytes memory result = new bytes(maxLength);
        for (uint256 i = 0; i < maxLength; i++) {
            result[i] = strBytes[i];
        }
        return string(result);
    }

    /// @notice Retorna a saudação padrão personalizada
    function defaultMessage(address sender) internal pure returns (string memory) {
        return string(abi.encodePacked("Um presente enviado por: ", toAsciiString(sender)));
    }

    /// @notice Converte um address para string ASCII
    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(42);
        s[0] = "0";
        s[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i + 2] = char(hi);
            s[2 * i + 3] = char(lo);
        }
        return string(s);
    }

    /// @notice Converte um byte para caractere ASCII
    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}

