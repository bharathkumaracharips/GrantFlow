# Quadratic Funding Protocol — Threat Model & Security Architecture

## 1. Scope & Objective

This document analyzes adversaries, vulnerability vectors, and mitigation controls across the Quadratic Funding Platform. The platform combines economic incentive models, off-chain calculation pipelines, cryptographic attestations, and on-chain EVM contracts.

---

## 2. Threat Actor Taxonomy

1. **Sybil Farmer**: Deploys automated scripts with multiple funded EVM addresses to split a large donation into micro-donations across synthetic personas, artificially inflating quadratic matching.
2. **Collusive Project / Donor Ring**: A project owner who bribes participants or donates to their own project via coordinated wallets to capture matching capital (Kickback / Recycling attack).
3. **Malicious Calculation Publisher**: Submits a fraudulent Merkle root or manipulated quadratic calculation to divert matching funds to colluding projects.
4. **Griefing Challenger**: Spams frivolous calculation or project disputes to lock funds, delay payouts, or exhaust reviewer bandwidth.
5. **Flash-Loan Governance Attacker**: Borrows protocol voting power within a single transaction or block window to alter parameters, whitelist malicious tokens, or pass drain proposals.
6. **Smart Contract Exploiter**: Attempts reentrancy, integer anomalies, double claims, or cross-chain replay attacks.

---

## 3. Attack Vectors & Mitigations

### 3.1. Sybil Attacks & False Contributor Multipliers
- **Attack Vector**: In standard Quadratic Funding, $N$ donations of $\$1$ yield an unscaled score of $\left(N \times 1\right)^2 = N^2$, whereas $1$ donation of $\$N$ yields score $N$. An attacker splitting $\$1000$ into 1000 $\$1$ donations attempts to drain matching funds.
- **Mitigations**:
  1. **Attestation & Identity Nullifiers**: Each contributor must present a verifiable credential (e.g., Gitcoin Passport score $\ge \tau$, EAS attestation signed by trusted issuer).
  2. **Per-Round Project Nullifier Mapping**: Each identity credential yields a cryptographic nullifier:
     $$\mathcal{N} = \text{keccak256}(\text{IdentitySecret}, \text{RoundId}, \text{ProjectId})$$
     Even if an attacker uses multiple EVM addresses, the matching engine deduplicates by nullifier. If multiple contributions from the same nullifier to the same project occur, their values are aggregated into a single contribution prior to the square root operation:
     $$c_{i, P} = \sum_{k} c_{i, k, P} \implies \sqrt{c_{i, P}}$$
  3. **Minimum Contribution Floor**: Enforce a round-specific minimum donation (e.g., $\$1.00$ equivalent) below which donations do not trigger quadratic amplification.

### 3.2. Contribution Recycling & Bribery (Collusion)
- **Attack Vector**: Project creator donates $\$10,000$ to themselves using real verified identities (or friends) to extract $\$30,000$ in matching funds.
- **Mitigations**:
  1. **Project Matching Caps**: No single project may receive more than a parameterized percentage (e.g., $10\% - 20\%$) of the total matching pool for that round.
  2. **Pairwise Bounded QF (CLR Enhancement)**: Penalize pairs or clusters of donors who share identical donation patterns across projects.
  3. **Dispute and Review Verification**: Projects must undergo community review (`ProjectReviewManager`). Community challenges with slashed bonds can disqualify bad actors prior to distribution.

### 3.3. Malicious Calculation Engine & Merkle Fraud
- **Attack Vector**: The off-chain matching engine submits a fraudulent Merkle root to `MatchingResultManager.sol` allocating 90% of the pool to an accomplice.
- **Mitigations**:
  1. **Publisher Staking & Slashing**: The publisher must post an on-chain security bond (e.g., 5 ETH or 10,000 USDC) upon submitting the Merkle root.
  2. **Canonical Input Hash**: The publisher must commit to the deterministic hash of the contribution snapshot `inputSnapshotHash = keccak256(canonicalContributions)`.
  3. **Optimistic Challenge Window**: A mandatory timelock (e.g., 7 days) opens before finalization. Any verifier running the open-source Rust engine can recompute allocations and submit an on-chain dispute proof.
  4. **Slashing Incentive**: Successful challengers receive a portion of the publisher's slashed bond; remaining bond is refunded to the matching pool.

### 3.4. Double Claim & Reentrancy Exploits
- **Attack Vector**: An attacker repeatedly submits the same Merkle leaf proof or calls the claim function reentrantly to drain the vault.
- **Mitigations**:
  1. **Bitmask / Mapping Claim Tracking**: On-chain tracking `hasClaimed[roundId][projectId] = true` set **before** any external ERC-20 transfer.
  2. **OpenZeppelin ReentrancyGuard**: Both `MatchingVault` and `DistributionManager` employ `nonReentrant` modifiers.
  3. **SafeERC20**: Safe token wrappers prevent missing return values or token callback hijacks (e.g., ERC-777).

### 3.5. Flash-Loan & Governance Hijacking
- **Attack Vector**: Attacker borrows governance tokens via Aave/Uniswap flash loans to force quorum and execute malicious proposals.
- **Mitigations**:
  1. **ERC-20 Votes Checkpoints**: `FundingGovernor` uses historical block-checkpointed voting power (`ERC20Votes`), preventing flash loans from acquiring voting power within the same block as proposal creation or execution.
  2. **Governance Timelock**: All enacted proposals must spend a minimum delay (e.g., 48–72 hours) in `GovernanceTimelock` before execution, allowing emergency guardian multisigs to veto malicious transactions.

---

## 4. Threat Matrix Summary

| Threat Category | Severity | Likelihood | Primary Defense Layer |
| :--- | :--- | :--- | :--- |
| Sybil Sub-division | Critical | High | Identity nullifiers + aggregation before square root |
| Calculation Merkle Tampering | Critical | Medium | Publisher bond + optimistic challenge window |
| Project Collusion / Self-Funding | High | High | Project allocation caps + community review dispute |
| Reentrancy Vault Drain | Critical | Low | `ReentrancyGuard` + Checks-Effects-Interactions |
| Flash Loan Governance Takeover | High | Low | `ERC20Votes` snapshotting + TimelockController |
| Malicious Token Callback | Medium | Low | `SafeERC20` + strict token whitelisting |
