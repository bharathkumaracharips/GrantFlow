// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Errors} from "../libraries/Errors.sol";

/// @title GovernanceTimelock
/// @notice Enforces mandatory execution delay on all governance and protocol parameter updates
contract GovernanceTimelock {
    address public admin;
    uint256 public constant MIN_DELAY = 2 days;
    uint256 public constant MAX_DELAY = 30 days;
    uint256 public delay;

    mapping(bytes32 => bool) public queuedTransactions;

    event TransactionQueued(bytes32 indexed txHash, address indexed target, uint256 value, string signature, bytes data, uint256 eta);
    event TransactionExecuted(bytes32 indexed txHash, address indexed target, uint256 value, string signature, bytes data, uint256 eta);
    event TransactionCancelled(bytes32 indexed txHash);

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Errors.Unauthorized();
        _;
    }

    constructor(address _admin, uint256 _delay) {
        if (_admin == address(0)) revert Errors.ZeroAddress();
        if (_delay < MIN_DELAY || _delay > MAX_DELAY) revert Errors.InvalidTimestamps();
        admin = _admin;
        delay = _delay;
    }

    function queueTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) public onlyAdmin returns (bytes32 txHash) {
        if (eta < block.timestamp + delay) revert Errors.InvalidTimestamps();

        txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = true;

        emit TransactionQueued(txHash, target, value, signature, data, eta);
    }

    function cancelTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) public onlyAdmin {
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = false;

        emit TransactionCancelled(txHash);
    }

    function executeTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) public payable onlyAdmin returns (bytes memory) {
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        if (!queuedTransactions[txHash]) revert Errors.Unauthorized();
        if (block.timestamp < eta) revert Errors.InvalidTimestamps();
        if (block.timestamp > eta + 14 days) revert Errors.ChallengePeriodElapsed();

        queuedTransactions[txHash] = false;

        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        if (!success) revert Errors.TransferFailed();

        emit TransactionExecuted(txHash, target, value, signature, data, eta);
        return returnData;
    }
}
