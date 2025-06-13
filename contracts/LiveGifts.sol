// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./GiftRegistry.sol";
import "./GiftBadgeNFT.sol";
import "./GiftUtilsLib.sol";

/// @title LiveGifts
/// @notice Contrato unificado de envio de presentes com NFT e registro público
contract LiveGifts {
    using GiftUtilsLib for address;
    using GiftUtilsLib for uint256;
    using GiftUtilsLib for string;

    GiftRegistry public registry;
    GiftBadgeNFT public nft;

    address public owner;
    uint256 public minGiftValue = 0.001 ether;

    event GiftCompleted(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 giftId,
        uint256 nftId
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Apenas o dono pode executar");
        _;
    }

    constructor(address _registry, address _nft) {
        owner = msg.sender;
        registry = GiftRegistry(_registry);
        nft = GiftBadgeNFT(_nft);
    }

    /// @notice Envia um presente com ETH, registra no GiftRegistry e emite NFT simbólico
    /// @param to Endereço do destinatário
    /// @param message Mensagem personalizada do presente
    /// @param tokenURI URI do NFT simbólico
    function sendLiveGift(
        address to,
        string calldata message,
        string calldata tokenURI
    ) external payable {
        require(to.isValidAddress(), "Endereço inválido");
        require(msg.value >= minGiftValue, "Presente muito pequeno");

        // Registro do presente
        registry.sendGift{value: msg.value}(to, message);

        // Mint do NFT simbólico
        uint256 nftId = nft.giftBadge(to, tokenURI);

        emit GiftCompleted(msg.sender, to, msg.value, registry.giftCount() - 1, nftId);
    }

    /// @notice Atualiza o valor mínimo de presente
    function setMinGiftValue(uint256 newValue) external onlyOwner {
        minGiftValue = newValue;
    }

    /// @notice Atualiza os contratos externos
    function updateContracts(address _registry, address _nft) external onlyOwner {
        registry = GiftRegistry(_registry);
        nft = GiftBadgeNFT(_nft);
    }

    /// @notice Retira fundos travados (emergencial)
    function emergencyWithdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}

