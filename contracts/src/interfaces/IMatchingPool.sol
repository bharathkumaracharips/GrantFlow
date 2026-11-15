// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IMatchingPool {
    struct SponsorContribution {
        address sponsor;
        uint256 amount;
        uint64 timestamp;
    }

    function depositMatchingFunds(uint256 roundId, uint256 amount) external;
    function getRoundMatchingBalance(uint256 roundId) external view returns (uint256);
    function refundSponsorsIfCancelled(uint256 roundId) external;
}
