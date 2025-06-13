// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LiveGifts.sol";
import "./GiftBadgeNFT.sol";
import "./LiveToken.sol";

/// @title ContractInteraction
/// @notice Intermediário que interage com os contratos LiveGifts, NFT e Token
contract ContractInteraction {
    LiveGifts public liveGifts;
    GiftBadgeNFT public giftNFT;
    LiveToken public liveToken;

    event InteractionExecuted(address indexed user, string action);

    constructor(
        address _liveGifts,
        address _giftNFT,
        address _liveToken
    ) {
        liveGifts = LiveGifts(_liveGifts);
        giftNFT = GiftBadgeNFT(_giftNFT);
        liveToken = LiveToken(_liveToken);
    }

    /// @notice Envia presente com ETH via LiveGifts
    function sendGiftWithEth(
        address to,
        string calldata message,
        string calldata tokenURI
    ) external payable {
        liveGifts.sendLiveGift{value: msg.value}(to, message, tokenURI);
        emit InteractionExecuted(msg.sender, "GiftSentWithETH");
    }

    /// @notice Usa tokens ERC20 como meio de presente (requer integração com LiveGifts se suportado)
    function sendGiftWithTokens(
        address to,
        uint256 tokenAmount,
        string calldata message,
        string calldata tokenURI
    ) external {
        liveToken.transferFrom(msg.sender, address(this), tokenAmount);
        // Aqui, apenas transferimos para o contrato — em versões futuras, LiveGifts pode aceitar tokens diretamente
        emit InteractionExecuted(msg.sender, "GiftSentWithToken");
    }

    /// @notice Mint NFT diretamente (caso queira interações manuais)
    function mintNFTTo(address to, string calldata uri) external {
        uint256 nftId = giftNFT.mintGiftBadge(to, uri);
        emit InteractionExecuted(msg.sender, "NFTMinted");
    }

    /// @notice Aprova tokens para esse contrato interagir
    function approveTokens(uint256 amount) external {
        liveToken.approve(address(this), amount);
        emit InteractionExecuted(msg.sender, "TokenApproved");
    }

    /// @notice Retira tokens travados (função administrativa)
    function adminWithdrawTokens(address to, uint256 amount) external {
        require(msg.sender == address(0xYourMultisigOrOwner), "Somente admin");
        liveToken.transfer(to, amount);
    }
}
