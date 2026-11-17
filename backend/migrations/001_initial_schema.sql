-- PostgreSQL Schema for GrantFlow

CREATE TABLE IF NOT EXISTS projects (
    id BIGINT PRIMARY KEY,
    owner_address VARCHAR(42) NOT NULL,
    payout_address VARCHAR(42) NOT NULL,
    metadata_cid TEXT NOT NULL,
    title VARCHAR(255),
    description TEXT,
    category VARCHAR(64),
    status VARCHAR(32) NOT NULL DEFAULT 'Pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS funding_rounds (
    id BIGINT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    token_address VARCHAR(42) NOT NULL,
    reg_start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    reg_end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    round_start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    round_end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    min_donation NUMERIC(78, 0) DEFAULT 0,
    max_donation NUMERIC(78, 0) DEFAULT 0,
    max_matching_cap_bps INT DEFAULT 2000,
    matching_pool_balance NUMERIC(78, 0) DEFAULT 0,
    state VARCHAR(32) NOT NULL DEFAULT 'Registration',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS round_projects (
    round_id BIGINT REFERENCES funding_rounds(id) ON DELETE CASCADE,
    project_id BIGINT REFERENCES projects(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (round_id, project_id)
);

CREATE TABLE IF NOT EXISTS contributors (
    address VARCHAR(42) PRIMARY KEY,
    identity_nullifier VARCHAR(66) UNIQUE,
    attestation_score NUMERIC(10, 2) DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS donations (
    id BIGSERIAL PRIMARY KEY,
    round_id BIGINT REFERENCES funding_rounds(id),
    project_id BIGINT REFERENCES projects(id),
    donor_address VARCHAR(42) NOT NULL,
    identity_nullifier VARCHAR(66) NOT NULL,
    amount_wad NUMERIC(78, 0) NOT NULL,
    tx_hash VARCHAR(66) NOT NULL UNIQUE,
    block_number BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS matching_pools (
    round_id BIGINT REFERENCES funding_rounds(id),
    sponsor_address VARCHAR(42) NOT NULL,
    amount_wad NUMERIC(78, 0) NOT NULL,
    tx_hash VARCHAR(66) NOT NULL,
    block_number BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS matching_results (
    round_id BIGINT PRIMARY KEY REFERENCES funding_rounds(id),
    merkle_root VARCHAR(66) NOT NULL,
    snapshot_hash VARCHAR(66) NOT NULL,
    publisher_address VARCHAR(42) NOT NULL,
    challenge_deadline TIMESTAMP WITH TIME ZONE NOT NULL,
    is_challenged BOOLEAN DEFAULT FALSE,
    is_finalized BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS distributions (
    round_id BIGINT REFERENCES funding_rounds(id),
    project_id BIGINT REFERENCES projects(id),
    payout_address VARCHAR(42) NOT NULL,
    direct_amount_wad NUMERIC(78, 0) NOT NULL,
    matching_amount_wad NUMERIC(78, 0) NOT NULL,
    claimed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    tx_hash VARCHAR(66) NOT NULL UNIQUE,
    PRIMARY KEY (round_id, project_id)
);

CREATE TABLE IF NOT EXISTS disputes (
    id BIGINT PRIMARY KEY,
    round_id BIGINT REFERENCES funding_rounds(id),
    project_id BIGINT REFERENCES projects(id),
    challenger_address VARCHAR(42) NOT NULL,
    bond_amount_wad NUMERIC(78, 0) NOT NULL,
    evidence_cid TEXT NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_donations_round_project ON donations(round_id, project_id);
CREATE INDEX IF NOT EXISTS idx_donations_donor ON donations(donor_address);
CREATE INDEX IF NOT EXISTS idx_donations_nullifier ON donations(identity_nullifier);
