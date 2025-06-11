// Módulo 1: Assinaturas digitais e Prova de Trabalho
pragma solidity ^0.8.0;

contract M1_ECDSA {
    function verifySignature(address signer, bytes32 messageHash, bytes memory signature) public pure returns (bool) {
        return recoverSigner(messageHash, signature) == signer;
    }

    function recoverSigner(bytes32 messageHash, bytes memory signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        return ecrecover(messageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}  