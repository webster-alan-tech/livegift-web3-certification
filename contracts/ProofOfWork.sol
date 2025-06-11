
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProofOfWork {
    bytes32 public lastHash;
    uint public difficulty = 2;

    constructor() {
        lastHash = keccak256(abi.encodePacked("Genesis"));
    }

    function mine(string memory nonce) public returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked(lastHash, nonce));
        require(uint(hash) < type(uint).max / (2 ** difficulty), "Invalid proof of work");
        lastHash = hash;
        difficulty++;
        return true;
    }
}
