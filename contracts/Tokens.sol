// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Tokens {
    mapping(address => uint256) public balances;

    function sendToken(address token, address to, uint256 amount) public {
        IERC20(token).transfer(to, amount);
    }
}  