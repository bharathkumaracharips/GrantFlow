# Protocol Invariants & Formal Specifications

## 1. Overview

This document formally specifies the invariants that the **Quadratic Funding Protocol** must maintain at all times across all contract execution states and off-chain calculation outputs.

---

## 2. Financial Invariants

### Invariant F1: Matching Vault Conservation
The total matching funds paid out to all projects across all rounds plus pending unspent balances must never exceed the total deposited matching capital minus approved sponsor refunds:
$$\sum_{r \in \mathcal{R}} \sum_{p \in \mathcal{P}_r} \text{PaidMatching}(r, p) + \text{MatchingVault.balance} \equiv \sum_{r \in \mathcal{R}} \text{DepositedMatching}(r) - \text{RefundedMatching}(r)$$
**Enforcement**: `MatchingVault.sol` only allows withdrawals requested by `DistributionManager.sol` backed by a validated `claim` or by `MatchingPool.sol` under approved cancellation.

### Invariant F2: Direct Donation Conservation
For any funding round $r$ and project $p$:
$$\sum_{p \in \mathcal{P}_r} \text{DirectDonationsDisbursed}(r, p) \le \text{DonationVault.balanceForRound}(r)$$
Direct donations cannot be transferred to any address other than the verified project owner's `payoutAddress` or the original donor in the event of round cancellation/disqualification.

### Invariant F3: Exact Allocation Reconciled to Pool
Let $M_r$ be the total matching pool capital allocated for round $r$, and let $A(p)$ be the calculated matching allocation for project $p \in \mathcal{P}_r$. Then:
$$\sum_{p \in \mathcal{P}_r} A(p) \le M_r$$
$$\text{Remainder Dust} = M_r - \sum_{p \in \mathcal{P}_r} A(p) < |\mathcal{P}_r| \times 10^{-18}$$
Any residual dust due to integer division truncation must be handled deterministically (assigned to the top-ranked project or retained in the round reserve).

---

## 3. Mathematical & Sybil Invariants

### Invariant M1: Identity-Level Aggregation Uniqueness
For round $r$, project $p$, and verified identity nullifier $\mathcal{N}$:
$$\text{EligibleContributions}(r, p, \mathcal{N}) \text{ is represented as a single aggregate value } C_{\mathcal{N}, p} = \sum_{k} c_{k}$$
The quadratic match for project $p$ is strictly evaluated as:
$$\text{RawScore}(p) = \left( \sum_{\mathcal{N} \in \mathcal{I}_{r, p}} \sqrt{C_{\mathcal{N}, p}} \right)^2$$
An identity splitting their donation across $k$ separate wallet addresses will obtain the exact same quadratic matching contribution as a single transaction of $\sum c_k$.

### Invariant M2: Deterministic Calculation Reproducibility
Given canonical input state $S = (\text{Donations}, \text{Identities}, \text{RoundConfig})$:
$$\text{Calculate}(S) \to (\text{Allocations}, \text{MerkleRoot})$$
is a pure, deterministic function. Execution on Linux, macOS, or EVM reference implementations produces bitwise identical Merkle roots.

---

## 4. Lifecycle & Timing Invariants

### Invariant L1: Strict Chronological Monotonicity
For any funding round $r$:
$$0 < T_{\text{reg\_start}} < T_{\text{reg\_end}} \le T_{\text{round\_start}} < T_{\text{round\_end}} < T_{\text{challenge\_end}} \le T_{\text{distribution\_start}}$$
- No donations can be executed if $\text{block.timestamp} < T_{\text{round\_start}}$ or $\text{block.timestamp} > T_{\text{round\_end}}$.
- No matching results can be finalized before $T_{\text{challenge\_end}}$.
- No matching claims can be executed before finalization.

### Invariant L2: Idempotency of Payout Claims
For round $r$ and project $p$:
$$\text{ClaimsExecuted}(r, p) \in \{0, 1\}$$
Once claimed, subsequent invocations of `claimProjectPayout(r, p, ...)` must revert with `AlreadyClaimed()`.

---

## 5. Security & Emergency Invariants

### Invariant S1: Circuit Breaker Non-Custodial Guarantee
Triggering `pause()` stops state modifications (donations, pool deposits, claims), but under no circumstance gives the emergency administrator permission to alter project payout addresses or reassign matching balances arbitrarily.

### Invariant S2: Governance Timelock Enforcement
All changes to protocol fees, whitelisted tokens, implementation upgrades, or contract parameters must be scheduled through `GovernanceTimelock` with a delay $D \ge 172800$ seconds (48 hours), guaranteeing users the ability to exit prior to execution of any breaking changes.
