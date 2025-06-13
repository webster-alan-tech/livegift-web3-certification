// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title GiftRegistry
/// @notice Registro público de presentes enviados entre usuários
contract GiftRegistry {
    uint256 public giftCount;

    struct Gift {
        address from;
        address to;
        uint256 amount;
        string message;
        uint256 timestamp;
    }

    mapping(uint256 => Gift) public gifts;
    mapping(address => uint256[]) public receivedGifts;
    mapping(address => uint256[]) public sentGifts;

    event GiftSent(
        uint256 indexed giftId,
        address indexed from,
        address indexed to,
        uint256 amount,
        string message,
        uint256 timestamp
    );

    /// @notice Envia um presente simbólico com valor (pode ser usado com Custody para envio real)
    /// @param to Destinatário do presente
    /// @param message Mensagem opcional personalizada
    function sendGift(address to, string calldata message) external payable {
        require(to != address(0), "Destinatário inválido");
        require(msg.value > 0, "Valor do presente deve ser maior que 0");

        uint256 giftId = giftCount++;
        gifts[giftId] = Gift({
            from: msg.sender,
            to: to,
            amount: msg.value,
            message: message,
            timestamp: block.timestamp
        });

        receivedGifts[to].push(giftId);
        sentGifts[msg.sender].push(giftId);

        emit GiftSent(giftId, msg.sender, to, msg.value, message, block.timestamp);
    }

    /// @notice Retorna os IDs de presentes recebidos por um endereço
    function getReceivedGifts(address user) external view returns (uint256[] memory) {
        return receivedGifts[user];
    }

    /// @notice Retorna os IDs de presentes enviados por um endereço
    function getSentGifts(address user) external view returns (uint256[] memory) {
        return sentGifts[user];
    }
}

