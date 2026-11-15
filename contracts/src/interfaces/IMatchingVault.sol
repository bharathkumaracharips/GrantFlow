// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IMatchingVault {
    function depositFunds(uint256 roundId, address token, uint256 amount) external;
    function releaseFunds(uint256 roundId, address token, address recipient, uint256 amount) external;
    function getBalance(uint256 roundId) external view returns (uint256);
}
