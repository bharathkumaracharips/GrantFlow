// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IMatchingResultManager} from "../interfaces/IMatchingResultManager.sol";
import {IFundingRoundManager} from "../interfaces/IFundingRoundManager.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";
import {ProtocolConstants} from "../libraries/ProtocolConstants.sol";

/// @title MatchingResultManager
/// @notice Optimistic submission, challenge dispute, and finalization of matching allocation Merkle roots
contract MatchingResultManager is IMatchingResultManager {
    address public admin;
    IFundingRoundManager public immutable roundManager;
    uint256 public publisherBondAmount = ProtocolConstants.DEFAULT_PUBLISHER_BOND;
    uint256 public challengeWindow = ProtocolConstants.DEFAULT_CHALLENGE_WINDOW;

    mapping(uint256 => ResultCommitment) private _commitments;
    mapping(uint256 => address) public challengers;
    mapping(uint256 => uint256) public challengerBonds;

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Errors.Unauthorized();
        _;
    }

    constructor(address _admin, address _roundManager) {
        if (_admin == address(0) || _roundManager == address(0)) revert Errors.ZeroAddress();
        admin = _admin;
        roundManager = IFundingRoundManager(_roundManager);
    }

    function setPublisherBond(uint256 newBond) external onlyAdmin {
        publisherBondAmount = newBond;
    }

    function setChallengeWindow(uint256 newWindow) external onlyAdmin {
        if (newWindow < ProtocolConstants.MIN_CHALLENGE_WINDOW) revert Errors.InvalidTimestamps();
        challengeWindow = newWindow;
    }

    function submitMatchingResult(
        uint256 roundId,
        bytes32 merkleRoot,
        bytes32 snapshotHash
    ) external payable override {
        if (msg.value < publisherBondAmount) revert Errors.InvalidBondAmount();
        if (merkleRoot == bytes32(0)) revert Errors.ZeroAmount();

        IFundingRoundManager.RoundConfig memory round = roundManager.getRound(roundId);
        if (round.id == 0) revert Errors.RoundNotActive();
        if (block.timestamp <= round.roundEndTime) revert Errors.RoundNotEnded();

        ResultCommitment storage commitment = _commitments[roundId];
        if (commitment.finalized) revert Errors.AlreadyFinalized();
        if (commitment.challenged) revert Errors.ResultChallenged();

        commitment.merkleRoot = merkleRoot;
        commitment.inputSnapshotHash = snapshotHash;
        commitment.publisher = msg.sender;
        commitment.bondAmount = msg.value;
        commitment.challengeDeadline = uint64(block.timestamp + challengeWindow);
        commitment.challenged = false;
        commitment.finalized = false;

        emit Events.MatchingResultCommitted(roundId, merkleRoot, snapshotHash, msg.sender, commitment.challengeDeadline);
    }

    function challengeResult(uint256 roundId, string calldata reason) external payable override {
        ResultCommitment storage commitment = _commitments[roundId];
        if (commitment.merkleRoot == bytes32(0)) revert Errors.MerkleRootNotCommitted();
        if (block.timestamp >= commitment.challengeDeadline) revert Errors.ChallengePeriodElapsed();
        if (commitment.challenged) revert Errors.ResultChallenged();
        if (msg.value < publisherBondAmount) revert Errors.InvalidBondAmount();

        commitment.challenged = true;
        challengers[roundId] = msg.sender;
        challengerBonds[roundId] = msg.value;

        emit Events.MatchingResultChallenged(roundId, msg.sender, reason);
    }

    function resolveChallenge(uint256 roundId, bool challengerWon) external override onlyAdmin {
        ResultCommitment storage commitment = _commitments[roundId];
        if (!commitment.challenged) revert Errors.InvalidStateTransition();

        address challenger = challengers[roundId];
        uint256 chBond = challengerBonds[roundId];
        address publisher = commitment.publisher;
        uint256 pubBond = commitment.bondAmount;

        if (challengerWon) {
            // Publisher slashed: challenger receives their bond back + publisher's bond reward
            delete _commitments[roundId];
            delete challengers[roundId];
            delete challengerBonds[roundId];

            (bool sent, ) = challenger.call{value: chBond + pubBond}("");
            if (!sent) revert Errors.TransferFailed();
        } else {
            // Challenger lost: challenger bond slashed to admin/treasury, publisher restored
            commitment.challenged = false;
            delete challengers[roundId];
            delete challengerBonds[roundId];

            (bool sent, ) = admin.call{value: chBond}("");
            if (!sent) revert Errors.TransferFailed();
        }
    }

    function finalizeResult(uint256 roundId) external override {
        ResultCommitment storage commitment = _commitments[roundId];
        if (commitment.merkleRoot == bytes32(0)) revert Errors.MerkleRootNotCommitted();
        if (block.timestamp < commitment.challengeDeadline) revert Errors.ChallengePeriodActive();
        if (commitment.challenged) revert Errors.ResultChallenged();
        if (commitment.finalized) revert Errors.AlreadyFinalized();

        commitment.finalized = true;

        // Refund publisher bond
        address publisher = commitment.publisher;
        uint256 bond = commitment.bondAmount;
        commitment.bondAmount = 0;

        (bool sent, ) = publisher.call{value: bond}("");
        if (!sent) revert Errors.TransferFailed();

        emit Events.MatchingResultFinalized(roundId, commitment.merkleRoot);
    }

    function getFinalizedRoot(uint256 roundId) external view override returns (bytes32) {
        ResultCommitment storage commitment = _commitments[roundId];
        if (!commitment.finalized) revert Errors.RoundNotActive();
        return commitment.merkleRoot;
    }

    function isFinalized(uint256 roundId) external view override returns (bool) {
        return _commitments[roundId].finalized;
    }

    function getCommitment(uint256 roundId) external view returns (ResultCommitment memory) {
        return _commitments[roundId];
    }
}
