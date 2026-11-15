use crate::math::{mul_wad, sqrt_wad, WAD};
use crate::merkle::{MerkleLeafData, MerkleTree};
use primitive_types::U256;
use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, HashMap};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RawContribution {
    pub donor_address: [u8; 20],
    pub identity_nullifier: [u8; 32],
    pub project_id: u64,
    pub amount_wad: U256,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProjectSummary {
    pub project_id: u64,
    pub payout_address: [u8; 20],
    pub direct_total_wad: U256,
    pub matching_demand_wad: U256,
    pub matching_allocation_wad: U256,
    pub unique_contributors: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QFResult {
    pub round_id: u64,
    pub total_direct_wad: U256,
    pub total_matching_pool_wad: U256,
    pub total_matching_distributed_wad: U256,
    pub project_summaries: Vec<ProjectSummary>,
    pub merkle_root: [u8; 32],
    pub leaves: Vec<MerkleLeafData>,
}

pub struct QFEngine;

impl QFEngine {
    /// Computes Quadratic Funding matching allocations and builds a canonical Merkle tree
    pub fn calculate_round_matching(
        round_id: u64,
        matching_pool_wad: U256,
        max_matching_cap_bps: u64, // e.g. 2000 = 20%
        payout_addresses: &HashMap<u64, [u8; 20]>,
        contributions: &[RawContribution],
    ) -> QFResult {
        // Step 1: Group and aggregate contributions by Project -> Nullifier (Sybil protection)
        // Uses BTreeMap for deterministic sorting
        let mut project_identity_totals: BTreeMap<u64, BTreeMap<[u8; 32], U256>> = BTreeMap::new();
        let mut total_direct_wad = U256::zero();

        for c in contributions {
            total_direct_wad = total_direct_wad.saturating_add(c.amount_wad);
            let id_map = project_identity_totals.entry(c.project_id).or_default();
            let current = id_map.entry(c.identity_nullifier).or_insert(U256::zero());
            *current = current.saturating_add(c.amount_wad);
        }

        // Step 2: Compute Direct Totals and Matching Demands per Project
        let mut summaries: Vec<ProjectSummary> = Vec::new();
        let mut total_matching_demand_wad = U256::zero();

        for (&project_id, id_map) in &project_identity_totals {
            let mut direct_wad = U256::zero();
            let mut sum_sqrt_wad = U256::zero();

            for (&_nullifier, &amount_wad) in id_map {
                direct_wad = direct_wad.saturating_add(amount_wad);
                sum_sqrt_wad = sum_sqrt_wad.saturating_add(sqrt_wad(amount_wad));
            }

            // Raw Score = (sum_sqrt)^2
            let raw_score_wad = mul_wad(sum_sqrt_wad, sum_sqrt_wad);
            let matching_demand_wad = if raw_score_wad > direct_wad {
                raw_score_wad - direct_wad
            } else {
                U256::zero()
            };

            total_matching_demand_wad = total_matching_demand_wad.saturating_add(matching_demand_wad);

            let payout_address = payout_addresses
                .get(&project_id)
                .cloned()
                .unwrap_or([0u8; 20]);

            summaries.push(ProjectSummary {
                project_id,
                payout_address,
                direct_total_wad: direct_wad,
                matching_demand_wad,
                matching_allocation_wad: U256::zero(),
                unique_contributors: id_map.len(),
            });
        }

        // Step 3: Proportional Allocation & Project Matching Caps
        let mut total_distributed_wad = U256::zero();

        if !matching_pool_wad.is_zero() && !total_matching_demand_wad.is_zero() {
            let max_cap = if max_matching_cap_bps > 0 && max_matching_cap_bps <= 10_000 {
                (matching_pool_wad * U256::from(max_matching_cap_bps)) / U256::from(10_000)
            } else {
                matching_pool_wad
            };

            for summary in summaries.iter_mut() {
                if !summary.matching_demand_wad.is_zero() {
                    let mut share = (matching_pool_wad * summary.matching_demand_wad)
                        / total_matching_demand_wad;
                    if share > max_cap {
                        share = max_cap;
                    }
                    summary.matching_allocation_wad = share;
                    total_distributed_wad = total_distributed_wad.saturating_add(share);
                }
            }

            // Step 4: Deterministic Remainder Dust Rebalancing
            if total_distributed_wad < matching_pool_wad && !summaries.is_empty() {
                let dust = matching_pool_wad - total_distributed_wad;
                // Allocate remaining dust to top matching demand project
                summaries[0].matching_allocation_wad =
                    summaries[0].matching_allocation_wad.saturating_add(dust);
                total_distributed_wad = matching_pool_wad;
            }
        }

        // Step 5: Build Canonical Merkle Leaves and Tree
        let mut leaves_data: Vec<MerkleLeafData> = Vec::new();
        let mut leaf_hashes: Vec<[u8; 32]> = Vec::new();

        for s in &summaries {
            let leaf = MerkleLeafData {
                round_id,
                project_id: s.project_id,
                payout_address: s.payout_address,
                direct_amount: s.direct_total_wad,
                matching_amount: s.matching_allocation_wad,
            };
            leaf_hashes.push(leaf.compute_leaf_hash());
            leaves_data.push(leaf);
        }

        let tree = MerkleTree::new(leaf_hashes);

        QFResult {
            round_id,
            total_direct_wad,
            total_matching_pool_wad: matching_pool_wad,
            total_matching_distributed_wad: total_distributed_wad,
            project_summaries: summaries,
            merkle_root: tree.root(),
            leaves: leaves_data,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_single_contributor_zero_matching_demand() {
        let pool = WAD * 1000;
        let mut payouts = HashMap::new();
        payouts.insert(1, [1u8; 20]);

        let contributions = vec![RawContribution {
            donor_address: [10u8; 20],
            identity_nullifier: [100u8; 32],
            project_id: 1,
            amount_wad: WAD * 50,
        }];

        let result = QFEngine::calculate_round_matching(1, pool, 0, &payouts, &contributions);
        assert_eq!(result.project_summaries.len(), 1);
        assert_eq!(result.project_summaries[0].matching_demand_wad, U256::zero());
        assert_eq!(result.project_summaries[0].matching_allocation_wad, U256::zero());
    }

    #[test]
    fn test_multiple_contributors_quadratic_amplification() {
        let pool = WAD * 10_000;
        let mut payouts = HashMap::new();
        payouts.insert(1, [1u8; 20]); // Project 1: Many small contributors (10 donors x 1 WAD)
        payouts.insert(2, [2u8; 20]); // Project 2: One big contributor (1 donor x 10 WAD)

        let mut contributions = Vec::new();

        // Project 1: 10 separate donors of 1 WAD
        for i in 1..=10 {
            let mut nullifier = [0u8; 32];
            nullifier[0] = i as u8;
            contributions.push(RawContribution {
                donor_address: [i as u8; 20],
                identity_nullifier: nullifier,
                project_id: 1,
                amount_wad: WAD,
            });
        }

        // Project 2: 1 donor of 10 WAD
        contributions.push(RawContribution {
            donor_address: [99u8; 20],
            identity_nullifier: [99u8; 32],
            project_id: 2,
            amount_wad: WAD * 10,
        });

        let result = QFEngine::calculate_round_matching(1, pool, 0, &payouts, &contributions);
        assert_eq!(result.project_summaries.len(), 2);

        // Project 1 should receive 100% of the matching pool because Project 2 has only 1 contributor (0 demand)
        let p1 = result.project_summaries.iter().find(|p| p.project_id == 1).unwrap();
        let p2 = result.project_summaries.iter().find(|p| p.project_id == 2).unwrap();

        assert_eq!(p1.direct_total_wad, WAD * 10);
        assert_eq!(p2.direct_total_wad, WAD * 10);
        assert!(p1.matching_allocation_wad > U256::zero());
        assert_eq!(p2.matching_allocation_wad, U256::zero());
        assert_eq!(result.total_matching_distributed_wad, pool);
    }

    #[test]
    fn test_sybil_nullifier_aggregation() {
        let pool = WAD * 1000;
        let mut payouts = HashMap::new();
        payouts.insert(1, [1u8; 20]);

        // Same nullifier splitting 10 WAD into two 5 WAD donations from different donor addresses
        let same_nullifier = [77u8; 32];
        let contributions = vec![
            RawContribution {
                donor_address: [1u8; 20],
                identity_nullifier: same_nullifier,
                project_id: 1,
                amount_wad: WAD * 5,
            },
            RawContribution {
                donor_address: [2u8; 20],
                identity_nullifier: same_nullifier,
                project_id: 1,
                amount_wad: WAD * 5,
            },
        ];

        let result = QFEngine::calculate_round_matching(1, pool, 0, &payouts, &contributions);
        // It aggregates into 1 single contributor of 10 WAD -> matching demand is 0
        assert_eq!(result.project_summaries[0].unique_contributors, 1);
        assert_eq!(result.project_summaries[0].matching_demand_wad, U256::zero());
    }
}
