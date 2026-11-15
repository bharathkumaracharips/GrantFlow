// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IIdentityVerifier} from "../interfaces/IIdentityVerifier.sol";
import {Errors} from "../libraries/Errors.sol";

/// @title IdentityVerifier
/// @notice Adaptable Sybil verification adapter validating cryptographic proofs or attester signatures
contract IdentityVerifier is IIdentityVerifier {
    address public admin;
    address public trustedSigner;
    uint256 public minScoreThreshold;

    mapping(bytes32 => bool) public usedNullifiers;

    event TrustedSignerUpdated(address indexed newSigner);
    event ScoreThresholdUpdated(uint256 newThreshold);

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Errors.Unauthorized();
        _;
    }

    constructor(address _admin, address _trustedSigner, uint256 _minScoreThreshold) {
        if (_admin == address(0)) revert Errors.ZeroAddress();
        admin = _admin;
        trustedSigner = _trustedSigner;
        minScoreThreshold = _minScoreThreshold;
    }

    function setTrustedSigner(address _signer) external onlyAdmin {
        trustedSigner = _signer;
        emit TrustedSignerUpdated(_signer);
    }

    function setMinScoreThreshold(uint256 _threshold) external onlyAdmin {
        minScoreThreshold = _threshold;
        emit ScoreThresholdUpdated(_threshold);
    }

    /// @notice Validates ECDSA signature from the trusted identity attester
    /// @dev proof format: abi.encode(uint256 score, uint64 expiry, bytes signature)
    function verifyIdentity(
        address account,
        bytes32 identityNullifier,
        bytes calldata proof
    ) external view override returns (bool isValid, uint256 score) {
        if (trustedSigner == address(0)) {
            // Permissive test mode when no trusted signer is configured
            return (true, 100);
        }

        if (proof.length < 96) return (false, 0);

        (uint256 attestationScore, uint64 expiry, bytes memory signature) = abi.decode(proof, (uint256, uint64, bytes));

        if (block.timestamp > expiry) return (false, 0);
        if (attestationScore < minScoreThreshold) return (false, attestationScore);

        // Recover signer from digest
        bytes32 messageHash = keccak256(abi.encodePacked(account, identityNullifier, attestationScore, expiry, block.chainid));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

        address recovered = _recoverSigner(ethSignedMessageHash, signature);
        if (recovered == trustedSigner) {
            return (true, attestationScore);
        }

        return (false, 0);
    }

    function _recoverSigner(bytes32 hash, bytes memory sig) internal pure returns (address) {
        if (sig.length != 65) return address(0);
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return ecrecover(hash, v, r, s);
    }
}
