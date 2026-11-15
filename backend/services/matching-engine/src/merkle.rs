use primitive_types::U256;
use serde::{Deserialize, Serialize};
use tiny_keccak::{Hasher, Keccak};

pub fn keccak256(data: &[u8]) -> [u8; 32] {
    let mut hasher = Keccak::v256();
    let mut output = [0u8; 32];
    hasher.update(data);
    hasher.finalize(&mut output);
    output
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct MerkleLeafData {
    pub round_id: u64,
    pub project_id: u64,
    pub payout_address: [u8; 20],
    pub direct_amount: U256,
    pub matching_amount: U256,
}

impl MerkleLeafData {
    /// Canonical double-hash leaf encoding matching EVM:
    /// keccak256(bytes.concat(keccak256(abi.encode(roundId, projectId, payoutAddress, directAmount, matchingAmount))))
    pub fn compute_leaf_hash(&self) -> [u8; 32] {
        let mut encoded = Vec::with_capacity(32 * 5);

        // roundId (uint256, 32 bytes big-endian)
        let mut b = [0u8; 32];
        U256::from(self.round_id).to_big_endian(&mut b);
        encoded.extend_from_slice(&b);

        // projectId (uint256, 32 bytes big-endian)
        U256::from(self.project_id).to_big_endian(&mut b);
        encoded.extend_from_slice(&b);

        // payoutAddress (address padded to 32 bytes)
        let mut addr_padded = [0u8; 32];
        addr_padded[12..32].copy_from_slice(&self.payout_address);
        encoded.extend_from_slice(&addr_padded);

        // directAmount (uint256, 32 bytes big-endian)
        self.direct_amount.to_big_endian(&mut b);
        encoded.extend_from_slice(&b);

        // matchingAmount (uint256, 32 bytes big-endian)
        self.matching_amount.to_big_endian(&mut b);
        encoded.extend_from_slice(&b);

        let inner_hash = keccak256(&encoded);
        keccak256(&inner_hash)
    }
}

pub struct MerkleTree {
    pub leaves: Vec<[u8; 32]>,
    pub layers: Vec<Vec<[u8; 32]>>,
}

impl MerkleTree {
    pub fn new(leaves: Vec<[u8; 32]>) -> Self {
        if leaves.is_empty() {
            return Self {
                leaves: vec![],
                layers: vec![vec![[0u8; 32]]],
            };
        }

        let mut layers = Vec::new();
        layers.push(leaves.clone());

        let mut current_layer = leaves.clone();
        while current_layer.len() > 1 {
            let mut next_layer = Vec::new();
            for chunk in current_layer.chunks(2) {
                if chunk.len() == 2 {
                    let hash = hash_pair(&chunk[0], &chunk[1]);
                    next_layer.push(hash);
                } else {
                    next_layer.push(chunk[0]);
                }
            }
            layers.push(next_layer.clone());
            current_layer = next_layer;
        }

        Self { leaves, layers }
    }

    pub fn root(&self) -> [u8; 32] {
        if let Some(top) = self.layers.last() {
            if let Some(root) = top.first() {
                return *root;
            }
        }
        [0u8; 32]
    }

    pub fn get_proof(&self, leaf_index: usize) -> Vec<[u8; 32]> {
        let mut proof = Vec::new();
        let mut index = leaf_index;

        for layer in &self.layers[0..self.layers.len() - 1] {
            let pair_index = if index % 2 == 0 {
                index + 1
            } else {
                index - 1
            };

            if pair_index < layer.len() {
                proof.push(layer[pair_index]);
            }
            index /= 2;
        }

        proof
    }
}

pub fn hash_pair(a: &[u8; 32], b: &[u8; 32]) -> [u8; 32] {
    let mut combined = [0u8; 64];
    if a <= b {
        combined[0..32].copy_from_slice(a);
        combined[32..64].copy_from_slice(b);
    } else {
        combined[0..32].copy_from_slice(b);
        combined[32..64].copy_from_slice(a);
    }
    keccak256(&combined)
}

pub fn verify_merkle_proof(proof: &[[u8; 32]], root: &[u8; 32], leaf: &[u8; 32]) -> bool {
    let mut computed_hash = *leaf;
    for proof_element in proof {
        computed_hash = hash_pair(&computed_hash, proof_element);
    }
    &computed_hash == root
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_merkle_tree_proof_verification() {
        let leaf1 = [1u8; 32];
        let leaf2 = [2u8; 32];
        let leaf3 = [3u8; 32];
        let leaf4 = [4u8; 32];

        let tree = MerkleTree::new(vec![leaf1, leaf2, leaf3, leaf4]);
        let root = tree.root();

        for i in 0..4 {
            let proof = tree.get_proof(i);
            assert!(verify_merkle_proof(&proof, &root, &tree.leaves[i]));
        }
    }
}
