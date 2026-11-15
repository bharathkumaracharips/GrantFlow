// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IMatchingResultManager {
    struct ResultCommitment {
        bytes32 merkleRoot;
        bytes32 inputSnapshotHash;
        address publisher;
        uint256 bondAmount;
        uint64 challengeDeadline;
        bool challenged;
        bool finalized;
    }

    function submitMatchingResult(uint256 roundId, bytes32 merkleRoot, bytes32 snapshotHash) external payable;
    function challengeResult(uint256 roundId, string calldata reason) external payable;
    function resolveChallenge(uint256 roundId, bool challengerWon) external;
    function finalizeResult(uint256 roundId) external;
    function getFinalizedRoot(uint256 roundId) external view returns (bytes32);
    function isFinalized(uint256 roundId) external view returns (bool);
}
