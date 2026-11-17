// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ProtocolConstants
/// @notice Global constants and bounds for the GrantFlow protocol
library ProtocolConstants {
    uint256 internal constant WAD = 1e18;
    uint256 internal constant MAX_FEE_BPS = 500; // 5% max fee cap
    uint256 internal constant BPS_DENOMINATOR = 10_000;
    uint256 internal constant MIN_CHALLENGE_WINDOW = 3 days;
    uint256 internal constant DEFAULT_CHALLENGE_WINDOW = 7 days;
    uint256 internal constant MIN_REGISTRATION_WINDOW = 1 days;
    uint256 internal constant MIN_DONATION_WINDOW = 3 days;
    uint256 internal constant DEFAULT_PUBLISHER_BOND = 1 ether;
}
