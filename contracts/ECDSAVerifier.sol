// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ECDSA Signature Verifier Adaptado
/// @notice Alinha a estrutura de verificação com os contratos M1_ECDSA e Custody
contract ECDSAVerifier {

    /// @notice Gera o hash da mensagem original com base nos parâmetros
    function getMessageHash(
        address _sender,
        address _recipient,
        string memory _balanceType,
        uint256 _amount,
        uint256 _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_sender, _recipient, _balanceType, _amount, _nonce));
    }

    /// @notice Aplica o prefixo Ethereum Signed Message no hash gerado
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    /// @notice Verifica se a assinatura é válida para os dados fornecidos
    function verify(
        address signer,
        address sender,
        address recipient,
        string memory balanceType,
        uint256 amount,
        uint256 nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(sender, recipient, balanceType, amount, nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == signer;
    }

    /// @notice Recupera o endereço do signatário a partir de um hash assinado e assinatura
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    /// @notice Separa a assinatura ECDSA nos componentes r, s e v
    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "Assinatura inválida: comprimento incorreto");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
