# Quadratic Funding Mathematics & Specification

## 1. Core Mathematical Formulation

Capital-constrained Quadratic Funding (Buterin, Hitzig, Weyl, 2018) allocates a central pool of matching funds $M$ among candidate public goods projects $\mathcal{P} = \{p_1, p_2, \dots, p_K\}$ based on the square of the sum of the square roots of individual contributions.

Let $c_{i, p}$ denote the total contribution made by verified human identity $i$ to project $p$.

### Step 1: Raw Quadratic Score
For each project $p$:
$$\text{RawScore}(p) = \left( \sum_{i \in \mathcal{I}_p} \sqrt{c_{i, p}} \right)^2$$
where $\mathcal{I}_p$ is the set of distinct, verified human identities who contributed to project $p$.

### Step 2: Matching Demand Calculation
The net matching demand $\Delta(p)$ represents the subsidy allocated from the matching pool, excluding direct donations:
$$\Delta(p) = \text{RawScore}(p) - \sum_{i \in \mathcal{I}_p} c_{i, p} = 2 \sum_{i < j \in \mathcal{I}_p} \sqrt{c_{i, p}} \cdot \sqrt{c_{j, p}}$$
Notice that if a project has only a single contributor $i$, $\Delta(p) = (\sqrt{c_{i, p}})^2 - c_{i, p} = 0$. Matching funds are exclusively triggered by community coordination ($|\mathcal{I}_p| \ge 2$).

### Step 3: Pool Normalization & Proportional Distribution
Let the total matching pool capital be $M_{\text{total}}$, and let the sum of all matching demands across all projects in the round be:
$$\Delta_{\text{total}} = \sum_{p \in \mathcal{P}} \Delta(p)$$

If $\Delta_{\text{total}} = 0$, no matching funds are distributed.
If $\Delta_{\text{total}} > 0$:
$$\text{Allocation}_{\text{raw}}(p) = M_{\text{total}} \times \frac{\Delta(p)}{\Delta_{\text{total}}}$$

---

## 2. Project Matching Caps & Iterative Redistribution

To prevent a single hyper-popular or collusive project from monopolizing the matching pool, rounds can enforce a project matching cap $\kappa_{\max}$ (e.g., $15\%$ of $M_{\text{total}}$):
$$\text{Cap} = M_{\text{total}} \times \kappa_{\max}$$

If any project's initial allocation exceeds $\text{Cap}$, the excess is iteratively redistributed:
1. Projects with $\text{Allocation}(p) > \text{Cap}$ are clamped to $\text{Allocation}(p) = \text{Cap}$.
2. The remaining matching pool $M' = M_{\text{total}} - \sum_{p \in \mathcal{P}_{\text{capped}}} \text{Cap}$ is re-normalized among uncapped projects.
3. This process repeats until all allocations satisfy $\text{Allocation}(p) \le \text{Cap}$.

---

## 3. Fixed-Point Arithmetic & Precision Handling

To eliminate cross-platform floating-point discrepancies, all computations are performed in **fixed-point integer arithmetic with 18 decimal places of precision** ($W = 10^{18}$).

### Fixed-Point Square Root
Given an integer $x \times 10^{18}$:
$$\text{sqrtFixed}(x \times 10^{18}) = \lfloor \sqrt{x \times 10^{18} \times 10^{18}} \rfloor = \lfloor \sqrt{x \times 10^{36}} \rfloor$$
This is computed via Babylonian integer square root (Newton-Raphson):
```rust
pub fn sqrt_wad(x: U256) -> U256 {
    if x.is_zero() {
        return U256::ZERO;
    }
    let scaled = x.saturating_mul(U256::from(10).pow(U256::from(18)));
    let mut z = (scaled + U256::from(1)) / U256::from(2);
    let mut y = scaled;
    while z < y {
        y = z;
        z = (scaled / z + z) / U256::from(2);
    }
    y
}
```

### Deterministic Remainder Rebalancing
Because integer divisions truncate, $\sum_{p} \text{Allocation}(p)$ may be slightly less than $M_{\text{total}}$ by a small remainder $D < |\mathcal{P}|$ wei.
The calculation engine sorts projects deterministically by:
1. Highest Matching Demand $\Delta(p)$ descending.
2. Lexicographical project ID ascending (tie-breaker).

The remainder dust $D$ is distributed $+1$ wei at a time to the top $D$ projects, guaranteeing:
$$\sum_{p \in \mathcal{P}} \text{FinalAllocation}(p) \equiv M_{\text{total}}$$

---

## 4. Merkle Distribution Leaf Encoding

Each project's distribution entry is hashed as a canonical Merkle tree leaf using `keccak256`:
```solidity
bytes32 leaf = keccak256(
    bytes.concat(
        keccak256(
            abi.encode(
                roundId,
                projectId,
                payoutAddress,
                directDonationsAmount,
                matchingAmount
            )
        )
    )
);
```
Double-hashing `keccak256(bytes.concat(keccak256(...)))` prevents second-preimage attacks on Merkle trees with intermediate nodes.
