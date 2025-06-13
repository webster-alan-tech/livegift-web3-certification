// Módulo 4: Interação com contratos inteligentes
pragma solidity ^0.8.20;

contract M4_ContractInteraction {
    uint public value;

    function store(uint _value) public {
        value = _value;
    }

    function retrieve() public view returns (uint) {
        return value;
    }
}  