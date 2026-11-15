// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IIdentityVerifier {
    function verifyIdentity(
        address account,
        bytes32 identityNullifier,
        bytes calldata proof
    ) external view returns (bool isValid, uint256 score);
}
