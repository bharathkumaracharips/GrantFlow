use axum::{
    extract::{Path, Query},
    http::StatusCode,
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use matching_engine::{QFEngine, RawContribution};
use primitive_types::U256;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::net::SocketAddr;
use tower_http::cors::{Any, CorsLayer};
use tracing::{info, Level};
use tracing_subscriber::FmtSubscriber;

#[derive(Serialize)]
struct HealthResponse {
    status: &'static str,
    version: &'static str,
}

#[derive(Serialize, Deserialize, Clone)]
struct ProjectResponse {
    id: u64,
    title: String,
    category: String,
    payout_address: String,
    metadata_cid: String,
    status: String,
}

#[derive(Serialize, Deserialize)]
struct CalculateMatchingRequest {
    round_id: u64,
    matching_pool_wad: String,
    max_matching_cap_bps: u64,
    payout_addresses: HashMap<u64, String>,
    contributions: Vec<ContributionInput>,
}

#[derive(Serialize, Deserialize)]
struct ContributionInput {
    donor_address: String,
    identity_nullifier: String,
    project_id: u64,
    amount_wad: String,
}

#[derive(Serialize)]
struct AnalyticsResponse {
    total_rounds: usize,
    total_donations_count: usize,
    total_matching_funds_distributed_wad: String,
    verified_contributors_count: usize,
}

async fn health_check() -> impl IntoResponse {
    Json(HealthResponse {
        status: "ok",
        version: env!("CARGO_PKG_VERSION"),
    })
}

async fn list_projects() -> impl IntoResponse {
    let mock_projects = vec![
        ProjectResponse {
            id: 1,
            title: "Privacy Research DAO".to_string(),
            category: "Privacy & Cryptography".to_string(),
            payout_address: "0x1111111111111111111111111111111111111111".to_string(),
            metadata_cid: "bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi".to_string(),
            status: "Approved".to_string(),
        },
        ProjectResponse {
            id: 2,
            title: "EVM Security Tooling".to_string(),
            category: "Developer Tools".to_string(),
            payout_address: "0x2222222222222222222222222222222222222222".to_string(),
            metadata_cid: "bafybeihkoviema7g3gxyt6la7vd5ho32znq2zkj2n3cvlyqabf3oclgtqy".to_string(),
            status: "Approved".to_string(),
        },
    ];
    Json(mock_projects)
}

async fn calculate_matching(
    Json(payload): Json<CalculateMatchingRequest>,
) -> Result<impl IntoResponse, StatusCode> {
    let pool_wad = U256::from_dec_str(&payload.matching_pool_wad)
        .map_err(|_| StatusCode.BAD_REQUEST)?;

    let mut payouts = HashMap::new();
    for (pid, addr_str) in payload.payout_addresses {
        let clean = addr_str.trim_start_matches("0x");
        if let Ok(bytes) = hex::decode(clean) {
            if bytes.len() == 20 {
                let mut arr = [0u8; 20];
                arr.copy_from_slice(&bytes);
                payouts.insert(pid, arr);
            }
        }
    }

    let mut contributions = Vec::new();
    for c in payload.contributions {
        let amount = U256::from_dec_str(&c.amount_wad).map_err(|_| StatusCode.BAD_REQUEST)?;
        let mut donor = [0u8; 20];
        let mut nullifier = [0u8; 32];

        if let Ok(b) = hex::decode(c.donor_address.trim_start_matches("0x")) {
            if b.len() == 20 {
                donor.copy_from_slice(&b);
            }
        }
        if let Ok(b) = hex::decode(c.identity_nullifier.trim_start_matches("0x")) {
            if b.len() == 32 {
                nullifier.copy_from_slice(&b);
            }
        }

        contributions.push(RawContribution {
            donor_address: donor,
            identity_nullifier: nullifier,
            project_id: c.project_id,
            amount_wad: amount,
        });
    }

    let result = QFEngine::calculate_round_matching(
        payload.round_id,
        pool_wad,
        payload.max_matching_cap_bps,
        &payouts,
        &contributions,
    );

    Ok(Json(result))
}

async fn get_analytics() -> impl IntoResponse {
    Json(AnalyticsResponse {
        total_rounds: 3,
        total_donations_count: 1420,
        total_matching_funds_distributed_wad: "150000000000000000000000".to_string(), // 150,000 WAD
        verified_contributors_count: 890,
    })
}

#[tokio::main]
async fn main() {
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::INFO)
        .finish();
    tracing::subscriber::set_global_default(subscriber).expect("setting default subscriber failed");

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    let app = Router::new()
        .route("/health", get(health_check))
        .route("/api/projects", get(list_projects))
        .route("/api/matching/calculate", post(calculate_matching))
        .route("/api/analytics", get(get_analytics))
        .layer(cors);

    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    info!("GrantFlow REST API listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
