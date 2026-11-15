// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IFundingRoundManager {
    enum RoundState {
        Created,
        Registration,
        Active,
        Ended,
        Calculation,
        Finalized,
        Cancelled
    }

    struct RoundConfig {
        uint256 id;
        string title;
        address token;
        uint64 regStartTime;
        uint64 regEndTime;
        uint64 roundStartTime;
        uint64 roundEndTime;
        uint256 minDonation;
        uint256 maxDonation;
        uint256 maxMatchingCapBps; // Max % a project can receive of matching pool (e.g., 2000 = 20%)
        RoundState state;
    }

    function createRound(
        string calldata title,
        address token,
        uint64 regStart,
        uint64 regEnd,
        uint64 roundStart,
        uint64 roundEnd,
        uint256 minDonation,
        uint256 maxDonation,
        uint256 maxMatchingCapBps
    ) external returns (uint256 roundId);

    function enrollProject(uint256 roundId, uint256 projectId) external;
    function setRoundState(uint256 roundId, RoundState newState) external;
    function getRound(uint256 roundId) external view returns (RoundConfig memory);
    function isProjectEnrolled(uint256 roundId, uint256 projectId) external view returns (bool);
    function isDonationPeriodActive(uint256 roundId) external view returns (bool);
}
