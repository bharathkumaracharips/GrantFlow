// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title MerkleProofLib
/// @notice Gas-optimized cryptographic proof verification for binary Merkle trees
library MerkleProofLib {
    /// @notice Verifies a Merkle proof proving leaf membership in root
    function verify(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current, proofElement)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(proofElement, current)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}
