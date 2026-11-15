// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IDonationManager {
    struct DonationRecord {
        address donor;
        uint256 projectId;
        uint256 amount;
        bytes32 identityNullifier;
        uint64 timestamp;
    }

    function donate(
        uint256 roundId,
        uint256 projectId,
        uint256 amount,
        bytes32 identityNullifier,
        bytes calldata identityProof
    ) external;

    function getDonationTotal(uint256 roundId, uint256 projectId) external view returns (uint256);
    function getDonorCount(uint256 roundId, uint256 projectId) external view returns (uint256);
}
