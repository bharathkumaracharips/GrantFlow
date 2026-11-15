// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IMatchingVault} from "../interfaces/IMatchingVault.sol";
import {Errors} from "../libraries/Errors.sol";

interface IERC20Minimal {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @title MatchingVault
/// @notice Dedicated escrow vault custodying matching pool funds per round
contract MatchingVault is IMatchingVault {
    address public admin;
    address public matchingPool;
    address public distributionManager;

    mapping(uint256 => uint256) private _roundBalances;
    bool private _locked;

    modifier nonReentrant() {
        require(!_locked, "REENTRANCY");
        _locked = true;
        _;
        _locked = false;
    }

    modifier onlyAuthorized() {
        if (msg.sender != matchingPool && msg.sender != distributionManager && msg.sender != admin) {
            revert Errors.Unauthorized();
        }
        _;
    }

    constructor(address _admin) {
        if (_admin == address(0)) revert Errors.ZeroAddress();
        admin = _admin;
    }

    function setAuthorizedControllers(address _matchingPool, address _distributionManager) external {
        if (msg.sender != admin) revert Errors.Unauthorized();
        matchingPool = _matchingPool;
        distributionManager = _distributionManager;
    }

    function depositFunds(uint256 roundId, address token, uint256 amount) external override onlyAuthorized nonReentrant {
        if (amount == 0) revert Errors.ZeroAmount();
        _roundBalances[roundId] += amount;
        bool success = IERC20Minimal(token).transferFrom(msg.sender, address(this), amount);
        if (!success) revert Errors.TransferFailed();
    }

    function releaseFunds(
        uint256 roundId,
        address token,
        address recipient,
        uint256 amount
    ) external override onlyAuthorized nonReentrant {
        if (recipient == address(0)) revert Errors.ZeroAddress();
        if (amount == 0) revert Errors.ZeroAmount();
        if (_roundBalances[roundId] < amount) revert Errors.InsufficientVaultBalance();

        _roundBalances[roundId] -= amount;
        bool success = IERC20Minimal(token).transfer(recipient, amount);
        if (!success) revert Errors.TransferFailed();
    }

    function getBalance(uint256 roundId) external view override returns (uint256) {
        return _roundBalances[roundId];
    }
}
