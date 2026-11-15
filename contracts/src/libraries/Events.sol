// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Events
/// @notice Centralized event definitions for indexers and telemetry
library Events {
    // Project Registry Events
    event ProjectRegistered(uint256 indexed projectId, address indexed owner, address indexed payoutAddress, string metadataCid);
    event ProjectUpdated(uint256 indexed projectId, address indexed payoutAddress, string metadataCid);
    event ProjectStatusChanged(uint256 indexed projectId, uint8 status);

    // Funding Round Events
    event RoundCreated(uint256 indexed roundId, string title, address token, uint64 regStart, uint64 regEnd, uint64 roundStart, uint64 roundEnd);
    event RoundStateChanged(uint256 indexed roundId, uint8 newState);
    event ProjectEnrolledInRound(uint256 indexed roundId, uint256 indexed projectId);

    // Matching Pool Events
    event MatchingDeposited(uint256 indexed roundId, address indexed sponsor, uint256 amount);
    event MatchingWithdrawn(uint256 indexed roundId, address indexed recipient, uint256 amount);

    // Donation Events
    event DonationSubmitted(uint256 indexed roundId, uint256 indexed projectId, address indexed donor, bytes32 identityNullifier, uint256 amount);

    // Calculation & Result Events
    event MatchingResultCommitted(uint256 indexed roundId, bytes32 indexed merkleRoot, bytes32 snapshotHash, address indexed publisher, uint256 challengeDeadline);
    event MatchingResultChallenged(uint256 indexed roundId, address indexed challenger, string reason);
    event MatchingResultFinalized(uint256 indexed roundId, bytes32 indexed merkleRoot);

    // Distribution Events
    event PayoutClaimed(uint256 indexed roundId, uint256 indexed projectId, address indexed recipient, uint256 directAmount, uint256 matchingAmount);

    // Dispute Events
    event DisputeRaised(uint256 indexed disputeId, uint256 indexed roundId, uint256 indexed projectId, address indexed challenger, uint256 bondAmount);
    event DisputeResolved(uint256 indexed disputeId, bool indexed approved);
}
