// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IDonationVault {
    function deposit(uint256 roundId, uint256 projectId, address token, uint256 amount) external;
    function release(uint256 roundId, uint256 projectId, address token, address recipient, uint256 amount) external;
    function getProjectDonationBalance(uint256 roundId, uint256 projectId) external view returns (uint256);
}
