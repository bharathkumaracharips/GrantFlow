// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IDisputeManager} from "../interfaces/IDisputeManager.sol";
import {IProjectRegistry} from "../interfaces/IProjectRegistry.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";

/// @title DisputeManager
/// @notice Allows community members to challenge fraudulent projects by posting bonds and submitting evidence
contract DisputeManager is IDisputeManager {
    address public admin;
    IProjectRegistry public immutable projectRegistry;
    uint256 public disputeBond = 0.5 ether;
    uint256 public nextDisputeId = 1;

    mapping(uint256 => Dispute) private _disputes;
    mapping(uint256 => mapping(uint256 => bool)) private _projectDisputed;

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Errors.Unauthorized();
        _;
    }

    constructor(address _admin, address _registry) {
        if (_admin == address(0) || _registry == address(0)) revert Errors.ZeroAddress();
        admin = _admin;
        projectRegistry = IProjectRegistry(_registry);
    }

    function setDisputeBond(uint256 newBond) external onlyAdmin {
        disputeBond = newBond;
    }

    function raiseDispute(
        uint256 roundId,
        uint256 projectId,
        string calldata evidenceCid
    ) external payable override returns (uint256 disputeId) {
        if (msg.value < disputeBond) revert Errors.InvalidBondAmount();
        if (bytes(evidenceCid).length == 0) revert Errors.ZeroAmount();

        disputeId = nextDisputeId++;
        _disputes[disputeId] = Dispute({
            id: disputeId,
            roundId: roundId,
            projectId: projectId,
            challenger: msg.sender,
            bond: msg.value,
            evidenceCid: evidenceCid,
            status: DisputeStatus.Active,
            createdAt: uint64(block.timestamp)
        });

        _projectDisputed[roundId][projectId] = true;
        emit Events.DisputeRaised(disputeId, roundId, projectId, msg.sender, msg.value);
    }

    function resolveDispute(uint256 disputeId, bool uphold) external override onlyAdmin {
        Dispute storage dispute = _disputes[disputeId];
        if (dispute.status != DisputeStatus.Active) revert Errors.InvalidStateTransition();

        address challenger = dispute.challenger;
        uint256 bond = dispute.bond;
        dispute.bond = 0;

        if (uphold) {
            dispute.status = DisputeStatus.Upheld;
            // Suspend project in registry
            projectRegistry.setProjectStatus(dispute.projectId, IProjectRegistry.ProjectStatus.Suspended);
            // Refund challenger bond
            (bool sent, ) = challenger.call{value: bond}("");
            if (!sent) revert Errors.TransferFailed();
        } else {
            dispute.status = DisputeStatus.Dismissed;
            _projectDisputed[dispute.roundId][dispute.projectId] = false;
            // Slash bond to protocol admin/treasury
            (bool sent, ) = admin.call{value: bond}("");
            if (!sent) revert Errors.TransferFailed();
        }

        emit Events.DisputeResolved(disputeId, uphold);
    }

    function isProjectDisputed(uint256 roundId, uint256 projectId) external view override returns (bool) {
        return _projectDisputed[roundId][projectId];
    }

    function getDispute(uint256 disputeId) external view returns (Dispute memory) {
        return _disputes[disputeId];
    }
}
