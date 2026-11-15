// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IDistributionManager} from "../interfaces/IDistributionManager.sol";
import {IMatchingResultManager} from "../interfaces/IMatchingResultManager.sol";
import {IDonationVault} from "../interfaces/IDonationVault.sol";
import {IMatchingVault} from "../interfaces/IMatchingVault.sol";
import {IFundingRoundManager} from "../interfaces/IFundingRoundManager.sol";
import {IProjectRegistry} from "../interfaces/IProjectRegistry.sol";
import {MerkleProofLib} from "../libraries/MerkleProofLib.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";

/// @title DistributionManager
/// @notice Verifies cryptographic Merkle proofs and disburses direct and matching payouts to verified projects
contract DistributionManager is IDistributionManager {
    address public admin;
    IMatchingResultManager public immutable resultManager;
    IDonationVault public immutable donationVault;
    IMatchingVault public immutable matchingVault;
    IFundingRoundManager public immutable roundManager;
    IProjectRegistry public immutable projectRegistry;

    // roundId => projectId => claimed
    mapping(uint256 => mapping(uint256 => bool)) private _claimed;
    bool private _locked;

    modifier nonReentrant() {
        require(!_locked, "REENTRANCY");
        _locked = true;
        _;
        _locked = false;
    }

    constructor(
        address _admin,
        address _resultManager,
        address _donationVault,
        address _matchingVault,
        address _roundManager,
        address _projectRegistry
    ) {
        if (
            _admin == address(0) ||
            _resultManager == address(0) ||
            _donationVault == address(0) ||
            _matchingVault == address(0) ||
            _roundManager == address(0) ||
            _projectRegistry == address(0)
        ) revert Errors.ZeroAddress();

        admin = _admin;
        resultManager = IMatchingResultManager(_resultManager);
        donationVault = IDonationVault(_donationVault);
        matchingVault = IMatchingVault(_matchingVault);
        roundManager = IFundingRoundManager(_roundManager);
        projectRegistry = IProjectRegistry(_projectRegistry);
    }

    function claimPayout(
        uint256 roundId,
        uint256 projectId,
        address payoutAddress,
        uint256 directDonationsAmount,
        uint256 matchingAmount,
        bytes32[] calldata merkleProof
    ) external override nonReentrant {
        if (_claimed[roundId][projectId]) revert Errors.AlreadyClaimed();

        bytes32 root = resultManager.getFinalizedRoot(roundId);

        // Verify Merkle leaf (double hashed for second-preimage safety)
        bytes32 leaf = keccak256(
            bytes.concat(
                keccak256(
                    abi.encode(
                        roundId,
                        projectId,
                        payoutAddress,
                        directDonationsAmount,
                        matchingAmount
                    )
                )
            )
        );

        if (!MerkleProofLib.verify(merkleProof, root, leaf)) {
            revert Errors.InvalidProof();
        }

        // Set claimed status before transfers
        _claimed[roundId][projectId] = true;

        IFundingRoundManager.RoundConfig memory round = roundManager.getRound(roundId);

        // Disburse direct donations if any
        if (directDonationsAmount > 0) {
            donationVault.release(roundId, projectId, round.token, payoutAddress, directDonationsAmount);
        }

        // Disburse matching allocation if any
        if (matchingAmount > 0) {
            matchingVault.releaseFunds(roundId, round.token, payoutAddress, matchingAmount);
        }

        emit Events.PayoutClaimed(roundId, projectId, payoutAddress, directDonationsAmount, matchingAmount);
    }

    function hasClaimed(uint256 roundId, uint256 projectId) external view override returns (bool) {
        return _claimed[roundId][projectId];
    }
}
