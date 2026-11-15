// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IDisputeManager {
    enum DisputeStatus {
        None,
        Active,
        Upheld,
        Dismissed
    }

    struct Dispute {
        uint256 id;
        uint256 roundId;
        uint256 projectId;
        address challenger;
        uint256 bond;
        string evidenceCid;
        DisputeStatus status;
        uint64 createdAt;
    }

    function raiseDispute(uint256 roundId, uint256 projectId, string calldata evidenceCid) external payable returns (uint256 disputeId);
    function resolveDispute(uint256 disputeId, bool uphold) external;
    function isProjectDisputed(uint256 roundId, uint256 projectId) external view returns (bool);
}
