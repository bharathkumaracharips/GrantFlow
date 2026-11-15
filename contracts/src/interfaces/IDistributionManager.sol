// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IDistributionManager {
    function claimPayout(
        uint256 roundId,
        uint256 projectId,
        address payoutAddress,
        uint256 directDonationsAmount,
        uint256 matchingAmount,
        bytes32[] calldata merkleProof
    ) external;

    function hasClaimed(uint256 roundId, uint256 projectId) external view returns (bool);
}
