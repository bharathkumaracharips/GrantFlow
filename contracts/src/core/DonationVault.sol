// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IDonationVault} from "../interfaces/IDonationVault.sol";
import {Errors} from "../libraries/Errors.sol";

interface IERC20Direct {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @title DonationVault
/// @notice Escrow custodying direct donations for all projects across active rounds
contract DonationVault is IDonationVault {
    address public admin;
    address public donationManager;
    address public distributionManager;

    mapping(uint256 => mapping(uint256 => uint256)) private _projectBalances;
    bool private _locked;

    modifier nonReentrant() {
        require(!_locked, "REENTRANCY");
        _locked = true;
        _;
        _locked = false;
    }

    modifier onlyAuthorized() {
        if (msg.sender != donationManager && msg.sender != distributionManager && msg.sender != admin) {
            revert Errors.Unauthorized();
        }
        _;
    }

    constructor(address _admin) {
        if (_admin == address(0)) revert Errors.ZeroAddress();
        admin = _admin;
    }

    function setControllers(address _donationManager, address _distributionManager) external {
        if (msg.sender != admin) revert Errors.Unauthorized();
        donationManager = _donationManager;
        distributionManager = _distributionManager;
    }

    function deposit(
        uint256 roundId,
        uint256 projectId,
        address token,
        uint256 amount
    ) external override onlyAuthorized nonReentrant {
        if (amount == 0) revert Errors.ZeroAmount();
        _projectBalances[roundId][projectId] += amount;
        bool success = IERC20Direct(token).transferFrom(msg.sender, address(this), amount);
        if (!success) revert Errors.TransferFailed();
    }

    function release(
        uint256 roundId,
        uint256 projectId,
        address token,
        address recipient,
        uint256 amount
    ) external override onlyAuthorized nonReentrant {
        if (recipient == address(0)) revert Errors.ZeroAddress();
        if (amount == 0) revert Errors.ZeroAmount();
        if (_projectBalances[roundId][projectId] < amount) revert Errors.InsufficientVaultBalance();

        _projectBalances[roundId][projectId] -= amount;
        bool success = IERC20Direct(token).transfer(recipient, amount);
        if (!success) revert Errors.TransferFailed();
    }

    function getProjectDonationBalance(uint256 roundId, uint256 projectId) external view override returns (uint256) {
        return _projectBalances[roundId][projectId];
    }
}
