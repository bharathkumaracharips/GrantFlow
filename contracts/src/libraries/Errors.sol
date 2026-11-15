// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Errors
/// @notice Standard custom errors for the Quadratic Funding Platform
library Errors {
    error Unauthorized();
    error ZeroAddress();
    error ZeroAmount();
    error InvalidTimestamps();
    error RoundNotActive();
    error RoundAlreadyStarted();
    error RoundNotEnded();
    error ProjectNotApproved();
    error ProjectSuspended();
    error ProjectAlreadyRegistered();
    error DonationTooLow();
    error DonationTooHigh();
    error UnsupportedToken();
    error InactiveIdentity();
    error InvalidIdentityNullifier();
    error DuplicateIdentityContribution();
    error MerkleRootNotCommitted();
    error ChallengePeriodActive();
    error ChallengePeriodElapsed();
    error AlreadyFinalized();
    error ResultChallenged();
    error InvalidProof();
    error AlreadyClaimed();
    error InsufficientVaultBalance();
    error FeeTooHigh();
    error TransferFailed();
    error InvalidBondAmount();
    error InvalidStateTransition();
}
