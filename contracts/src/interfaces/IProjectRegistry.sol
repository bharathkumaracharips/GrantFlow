// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IProjectRegistry {
    enum ProjectStatus {
        None,
        Pending,
        Approved,
        Suspended,
        Rejected
    }

    struct Project {
        uint256 id;
        address owner;
        address payoutAddress;
        string metadataCid;
        ProjectStatus status;
        uint64 createdAt;
        uint64 updatedAt;
    }

    function registerProject(address payoutAddress, string calldata metadataCid) external returns (uint256 projectId);
    function updateProject(uint256 projectId, address newPayoutAddress, string calldata newMetadataCid) external;
    function setProjectStatus(uint256 projectId, ProjectStatus status) external;
    function transferProjectOwnership(uint256 projectId, address newOwner) external;
    function getProject(uint256 projectId) external view returns (Project memory);
    function isProjectApproved(uint256 projectId) external view returns (bool);
}
