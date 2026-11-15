// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IProjectRegistry} from "../interfaces/IProjectRegistry.sol";
import {Errors} from "../libraries/Errors.sol";

/// @title ProjectReviewManager
/// @notice Handles community reviewers, approval queues, and project vetting workflows
contract ProjectReviewManager {
    address public admin;
    IProjectRegistry public immutable projectRegistry;

    mapping(address => bool) public reviewers;
    mapping(uint256 => string) public reviewNotes;

    event ReviewerStatusUpdated(address indexed reviewer, bool indexed active);
    event ProjectReviewed(uint256 indexed projectId, address indexed reviewer, bool indexed approved, string notes);

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Errors.Unauthorized();
        _;
    }

    modifier onlyReviewer() {
        if (!reviewers[msg.sender] && msg.sender != admin) revert Errors.Unauthorized();
        _;
    }

    constructor(address _admin, address _registry) {
        if (_admin == address(0) || _registry == address(0)) revert Errors.ZeroAddress();
        admin = _admin;
        projectRegistry = IProjectRegistry(_registry);
    }

    function setReviewer(address reviewer, bool active) external onlyAdmin {
        reviewers[reviewer] = active;
        emit ReviewerStatusUpdated(reviewer, active);
    }

    function reviewProject(uint256 projectId, bool approve, string calldata notes) external onlyReviewer {
        IProjectRegistry.ProjectStatus newStatus = approve ? IProjectRegistry.ProjectStatus.Approved : IProjectRegistry.ProjectStatus.Rejected;
        projectRegistry.setProjectStatus(projectId, newStatus);
        reviewNotes[projectId] = notes;

        emit ProjectReviewed(projectId, msg.sender, approve, notes);
    }
}
