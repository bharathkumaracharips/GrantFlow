// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IProjectRegistry} from "../interfaces/IProjectRegistry.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";

/// @title ProjectRegistry
/// @notice Core registry managing decentralized project profiles, metadata CIDs, and payout addresses
contract ProjectRegistry is IProjectRegistry {
    address public admin;
    uint256 public nextProjectId = 1;

    mapping(uint256 => Project) private _projects;
    mapping(string => bool) private _registeredCids;
    mapping(address => bool) public reviewers;

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Errors.Unauthorized();
        _;
    }

    modifier onlyAdminOrReviewer() {
        if (msg.sender != admin && !reviewers[msg.sender]) revert Errors.Unauthorized();
        _;
    }

    modifier onlyProjectOwner(uint256 projectId) {
        if (_projects[projectId].owner != msg.sender) revert Errors.Unauthorized();
        _;
    }

    constructor(address _admin) {
        if (_admin == address(0)) revert Errors.ZeroAddress();
        admin = _admin;
    }

    function setReviewer(address reviewer, bool allowed) external onlyAdmin {
        reviewers[reviewer] = allowed;
    }

    function registerProject(address payoutAddress, string calldata metadataCid) external override returns (uint256 projectId) {
        if (payoutAddress == address(0)) revert Errors.ZeroAddress();
        if (bytes(metadataCid).length == 0) revert Errors.ZeroAmount();
        if (_registeredCids[metadataCid]) revert Errors.ProjectAlreadyRegistered();

        projectId = nextProjectId++;
        _registeredCids[metadataCid] = true;

        _projects[projectId] = Project({
            id: projectId,
            owner: msg.sender,
            payoutAddress: payoutAddress,
            metadataCid: metadataCid,
            status: ProjectStatus.Pending,
            createdAt: uint64(block.timestamp),
            updatedAt: uint64(block.timestamp)
        });

        emit Events.ProjectRegistered(projectId, msg.sender, payoutAddress, metadataCid);
    }

    function updateProject(
        uint256 projectId,
        address newPayoutAddress,
        string calldata newMetadataCid
    ) external override onlyProjectOwner(projectId) {
        if (newPayoutAddress == address(0)) revert Errors.ZeroAddress();
        Project storage proj = _projects[projectId];
        if (proj.status == ProjectStatus.Suspended) revert Errors.ProjectSuspended();

        proj.payoutAddress = newPayoutAddress;
        if (bytes(newMetadataCid).length > 0) {
            proj.metadataCid = newMetadataCid;
        }
        proj.updatedAt = uint64(block.timestamp);

        emit Events.ProjectUpdated(projectId, newPayoutAddress, proj.metadataCid);
    }

    function setProjectStatus(uint256 projectId, ProjectStatus status) external override onlyAdminOrReviewer {
        Project storage proj = _projects[projectId];
        if (proj.id == 0) revert Errors.ProjectNotApproved();
        proj.status = status;
        proj.updatedAt = uint64(block.timestamp);

        emit Events.ProjectStatusChanged(projectId, uint8(status));
    }

    function transferProjectOwnership(uint256 projectId, address newOwner) external override onlyProjectOwner(projectId) {
        if (newOwner == address(0)) revert Errors.ZeroAddress();
        _projects[projectId].owner = newOwner;
        _projects[projectId].updatedAt = uint64(block.timestamp);
    }

    function getProject(uint256 projectId) external view override returns (Project memory) {
        return _projects[projectId];
    }

    function isProjectApproved(uint256 projectId) external view override returns (bool) {
        return _projects[projectId].status == ProjectStatus.Approved;
    }
}
