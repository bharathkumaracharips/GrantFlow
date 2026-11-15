use primitive_types::U256;
use serde::{Deserialize, Serialize};
use std::time::Duration;
use tracing::{info, Level};
use tracing_subscriber::FmtSubscriber;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum IndexedProtocolEvent {
    ProjectRegistered {
        project_id: u64,
        owner: String,
        payout_address: String,
        metadata_cid: String,
    },
    RoundCreated {
        round_id: u64,
        title: String,
        token: String,
        reg_start: u64,
        reg_end: u64,
        round_start: u64,
        round_end: u64,
    },
    DonationSubmitted {
        round_id: u64,
        project_id: u64,
        donor: String,
        identity_nullifier: String,
        amount_wad: U256,
        tx_hash: String,
    },
    MatchingDeposited {
        round_id: u64,
        sponsor: String,
        amount_wad: U256,
    },
    MatchingResultFinalized {
        round_id: u64,
        merkle_root: String,
    },
}

pub struct BlockchainIndexer {
    pub last_synced_block: u64,
}

impl BlockchainIndexer {
    pub fn new() -> Self {
        Self {
            last_synced_block: 0,
        }
    }

    pub async fn poll_and_index_events(&mut self) {
        info!(
            "Indexing blockchain events from block {}",
            self.last_synced_block
        );
        // Simulation of idempotent event indexing
        self.last_synced_block += 10;
    }
}

#[tokio::main]
async fn main() {
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::INFO)
        .finish();
    tracing::subscriber::set_global_default(subscriber).expect("setting default subscriber failed");

    info!("Starting Quadratic Funding Blockchain Event Indexer...");

    let mut indexer = BlockchainIndexer::new();

    // Indexer polling loop
    for _ in 0..3 {
        indexer.poll_and_index_events().await;
        tokio::time::sleep(Duration::from_millis(500)).await;
    }

    info!("Blockchain Indexer healthy and synchronized.");
}
