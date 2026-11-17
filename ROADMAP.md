# GrantFlow — Development Roadmap

A round-based, Sybil-resistant Quadratic Funding protocol built for EVM with off-chain deterministic calculation, Merkle-based distribution proofs, and decentralized governance.

---

## Tech Stack Overview

- **Blockchain**: EVM (Solidity ^0.8.24)
- **Framework**: Foundry
- **Frontend**: Next.js 15 (App Router) + TypeScript + Tailwind CSS + shadcn/ui
- **Web3**: Wagmi v2 + Viem
- **Backend**: Rust 1.80+ + Axum + SQLx
- **Database**: PostgreSQL 16
- **Storage**: IPFS (Pinata / decentralized storage gateway)
- **Governance**: OpenZeppelin Governor + TimelockController
- **Identity & Attestations**: Gitcoin Passport / EAS (Ethereum Attestation Service)
- **Calculation Engine**: Deterministic Rust Matching Engine + Merkle Distribution
- **Testing**: Foundry (Unit, Fuzz, Invariant) + Vitest + Playwright
- **CI/CD**: GitHub Actions

---

## Critical Protocol Invariants

1. **Matching Fund Conservation**: $\sum \text{allocated matching} \le \text{MatchingVault.balance}$
2. **Direct Donation Conservation**: $\sum \text{project direct donations} \le \text{DonationVault.balance}$
3. **Identity Uniqueness**: For any given funding round $R$ and project $P$, each unique verified human identity nullifier $\mathcal{N}$ contributes at most once towards the matching calculation.
4. **Deterministic Matching Calculation**: Identical canonical snapshots of eligible donations and identity credentials produce bit-for-bit identical allocation Merkle roots regardless of execution environment.
5. **No Double Distribution Claims**: Each project $P$ in round $R$ can claim its matching allocation leaf at most once.
6. **Challenge Period Finality**: No matching funds may be claimed or disbursed while a challenge is active or before the challenge window has elapsed.
7. **Round Timing Invariants**: $T_{\text{registration\_start}} < T_{\text{registration\_end}} \le T_{\text{round\_start}} < T_{\text{round\_end}} < T_{\text{challenge\_end}} \le T_{\text{distribution\_start}}$. No donations are accepted outside $[T_{\text{round\_start}}, T_{\text{round\_end}}]$.
8. **Solvency and Reentrancy Safety**: All vault disbursements use reentrancy guards, pull-over-push claim mechanisms, and checks-effects-interactions.

---

## Phase Checklist

### Phase 1 — Requirements & System Design
- [x] Define platform objectives (`docs/architecture/system-overview.md`)
- [x] Identify all participant roles (`docs/architecture/system-overview.md`)
- [x] Define donors (`docs/architecture/system-overview.md`)
- [x] Define project owners (`docs/architecture/system-overview.md`)
- [x] Define matching fund providers (`docs/architecture/system-overview.md`)
- [x] Define round managers (`docs/architecture/system-overview.md`)
- [x] Define governance participants (`docs/architecture/system-overview.md`)
- [x] Define protocol administrators (`docs/architecture/system-overview.md`)
- [x] Define funding round lifecycle (`docs/architecture/system-overview.md`)
- [x] Define project registration requirements (`docs/architecture/system-overview.md`)
- [x] Define project eligibility criteria (`docs/architecture/system-overview.md`)
- [x] Define donation requirements (`docs/architecture/system-overview.md`)
- [x] Define supported payment tokens (`docs/architecture/system-overview.md`)
- [x] Define matching pool contribution rules (`docs/architecture/system-overview.md`)
- [x] Define quadratic funding calculation methodology (`docs/architecture/quadratic-funding-math.md`)
- [x] Define Sybil-resistance requirements (`docs/architecture/threat-model.md`)
- [x] Define contributor identity verification model (`docs/architecture/threat-model.md`)
- [x] Define donor privacy requirements (`docs/architecture/system-overview.md`)
- [x] Define project review and approval process (`docs/architecture/system-overview.md`)
- [x] Define funding distribution rules (`docs/architecture/system-overview.md`)
- [x] Define dispute resolution mechanism (`docs/architecture/system-overview.md`)
- [x] Define governance voting requirements (`docs/architecture/system-overview.md`)
- [x] Define platform fee structure (`docs/architecture/system-overview.md`)
- [x] Define emergency response mechanisms (`docs/architecture/invariants.md`)
- [x] Define smart contract architecture (`docs/architecture/system-overview.md`)
- [x] Define off-chain and on-chain trust boundaries (`docs/architecture/system-overview.md`)
- [x] Create system architecture diagrams (`docs/architecture/system-overview.md`)
- [x] Create protocol threat model (`docs/architecture/threat-model.md`)
- [x] Document financial and governance invariants (`docs/architecture/invariants.md`)

### Phase 2 — Project Initialization
- [x] Create Git repository & structure
- [x] Initialize monorepo structure
- [x] Initialize Foundry project (`contracts/`)
- [x] Configure Solidity compiler (`foundry.toml`)
- [x] Configure OpenZeppelin contracts dependencies
- [x] Initialize Next.js application structure (`frontend/`)
- [x] Configure TypeScript (`tsconfig.json`)
- [x] Configure Tailwind CSS & PostCSS
- [x] Configure Wagmi and Viem
- [x] Initialize Rust backend workspace (`backend/Cargo.toml`)
- [x] Configure Axum framework & dependencies
- [x] Configure PostgreSQL database schema & migrations (`backend/migrations/`)
- [x] Configure IPFS client integration structure
- [x] Configure identity verification integration structure
- [x] Configure environment variables (`.env.example`)
- [x] Configure secrets management guide
- [x] Configure Solidity formatter (`.prettierrc`)
- [x] Configure Rust formatter and Clippy (`rustfmt.toml`)
- [x] Configure frontend linting (`eslint.config.mjs`)
- [x] Configure GitHub Actions CI/CD (`.github/workflows/ci.yml`)
- [x] Create project documentation structure (`docs/`)

### Phase 3 — Protocol Storage & Interfaces
- [x] Define FundingRound storage (`contracts/src/interfaces/IFundingRoundManager.sol`)
- [x] Define Project storage (`contracts/src/interfaces/IProjectRegistry.sol`)
- [x] Define Donation storage (`contracts/src/interfaces/IDonationManager.sol`)
- [x] Define MatchingPool storage (`contracts/src/interfaces/IMatchingPool.sol`)
- [x] Define Contributor storage & snapshots
- [x] Define IdentityVerification storage (`contracts/src/interfaces/IIdentityVerifier.sol`)
- [x] Define MatchingAllocation storage
- [x] Define GovernanceProposal storage
- [x] Define Dispute storage (`contracts/src/interfaces/IDisputeManager.sol`)
- [x] Define Distribution storage (`contracts/src/interfaces/IDistributionManager.sol`)
- [x] Define protocol constants (`contracts/src/libraries/ProtocolConstants.sol`)
- [x] Define contract interfaces (`contracts/src/interfaces/`)
- [x] Define custom errors (`contracts/src/libraries/Errors.sol`)
- [x] Define protocol events (`contracts/src/libraries/Events.sol`)
- [x] Define access-control roles
- [x] Implement fixed-point math libraries (`contracts/src/libraries/FixedPointMath.sol`)
- [x] Define token decimal normalization
- [x] Define unique round identifiers
- [x] Define unique project identifiers
- [x] Define contributor eligibility snapshots
- [x] Define contract storage validation tests

### Phase 4 — Project Registration System
- [x] Implement `ProjectRegistry.sol`
- [x] Define project metadata structure
- [x] Implement project registration
- [x] Implement project ownership verification
- [x] Implement project metadata storage (IPFS CID)
- [x] Integrate IPFS project metadata validation
- [x] Implement project category registration
- [x] Implement project funding goals
- [x] Implement project payout addresses
- [x] Implement project eligibility validation
- [x] Implement project approval workflow
- [x] Implement project rejection workflow
- [x] Implement project status tracking
- [x] Implement project update permissions
- [x] Implement project ownership transfer rules
- [x] Prevent duplicate project registration abuse
- [x] Implement project suspension
- [x] Implement project removal restrictions
- [x] Emit project lifecycle events
- [x] Write project registry unit tests

### Phase 5 — Funding Round Management
- [x] Implement `FundingRoundManager.sol`
- [x] Define round configuration structure
- [x] Implement funding round creation
- [x] Implement round registration period
- [x] Implement round donation period
- [x] Implement round finalization period
- [x] Implement round distribution period
- [x] Implement round start timestamps
- [x] Implement round end timestamps
- [x] Implement round eligibility rules
- [x] Implement round project registration
- [x] Implement round project approval
- [x] Implement round cancellation rules
- [x] Implement round status transitions
- [x] Implement round extension rules
- [x] Implement round pause controls
- [x] Implement maximum project limits
- [x] Implement minimum donation rules
- [x] Implement maximum donation rules
- [x] Implement round configuration validation
- [x] Emit funding round events
- [x] Write funding round lifecycle tests

### Phase 6 — Matching Pool Development
- [x] Implement `MatchingPool.sol`
- [x] Implement `MatchingVault.sol`
- [x] Define supported matching assets
- [x] Implement matching fund deposits
- [x] Implement matching sponsor contributions
- [x] Implement matching pool accounting
- [x] Implement round-specific fund allocation
- [x] Implement matching pool balance tracking
- [x] Implement matching pool funding deadlines
- [x] Implement sponsor contribution records
- [x] Implement matching fund reservation
- [x] Implement matching pool locking
- [x] Implement unused matching fund handling
- [x] Implement sponsor refund rules
- [x] Implement matching pool cancellation rules
- [x] Prevent unauthorized fund withdrawals
- [x] Prevent matching fund double allocation
- [x] Implement matching fund distribution authorization
- [x] Implement matching vault access controls
- [x] Emit matching pool events
- [x] Write matching pool accounting tests

### Phase 7 — Donation Engine
- [x] Implement `DonationManager.sol`
- [x] Implement `DonationVault.sol`
- [x] Define donation storage structure
- [x] Implement project donations
- [x] Implement round-specific donations
- [x] Implement ERC-20 donation transfers
- [x] Implement donor contribution tracking
- [x] Implement per-project donation totals
- [x] Implement per-round donation totals
- [x] Implement contributor count tracking
- [x] Implement minimum donation enforcement
- [x] Implement maximum donation enforcement
- [x] Implement donor eligibility checks
- [x] Implement donation deadline validation
- [x] Implement donation event emission
- [x] Implement donation transaction history
- [x] Implement donation cancellation policy
- [x] Implement refund eligibility rules
- [x] Implement refund processing
- [x] Prevent duplicate transaction accounting
- [x] Prevent unsupported token behavior
- [x] Test donation accounting invariants
- [x] Test malicious token interactions

### Phase 8 — Quadratic Funding Mathematics
- [x] Define quadratic funding formula
- [x] Implement contributor aggregation model
- [x] Define unique contributor identity rules
- [x] Define eligible contribution weights
- [x] Implement square root calculation
- [x] Implement fixed-point precision handling
- [x] Implement raw quadratic score calculation
- [x] Implement direct contribution subtraction
- [x] Implement matching demand calculation
- [x] Implement matching pool normalization
- [x] Implement proportional matching allocation
- [x] Implement matching allocation caps
- [x] Implement minimum matching thresholds
- [x] Implement project-level matching limits
- [x] Implement round-level matching limits
- [x] Implement matching score snapshots
- [x] Implement deterministic rounding rules
- [x] Implement allocation dust handling
- [x] Implement zero-contribution handling
- [x] Implement zero-matching-pool handling
- [x] Test single contributor scenarios
- [x] Test multiple contributor scenarios
- [x] Test unequal contribution scenarios
- [x] Test identical contribution scenarios
- [x] Test large contributor populations
- [x] Test rounding and precision boundaries
- [x] Test matching pool exhaustion
- [x] Test deterministic allocation results

### Phase 9 — Sybil-Resistance System
- [x] Define Sybil attack threat model
- [x] Define unique human verification requirements
- [x] Integrate supported identity provider
- [x] Implement identity verification adapter (`contracts/src/adapters/IdentityVerifier.sol`)
- [x] Implement contributor eligibility checks
- [x] Implement identity credential validation
- [x] Implement verification expiration checks
- [x] Implement identity revocation handling
- [x] Implement identity snapshot per round
- [x] Implement duplicate identity detection
- [x] Implement nullifier-based contribution uniqueness
- [x] Implement wallet-to-identity association policy
- [x] Implement identity score thresholds
- [x] Implement identity-based donation aggregation
- [x] Implement suspicious contribution monitoring
- [x] Implement coordinated donation detection
- [x] Implement identity challenge mechanism
- [x] Implement false-positive appeal mechanism
- [x] Implement privacy-preserving identity references
- [x] Prevent identity replay attacks
- [x] Prevent cross-round identity misuse
- [x] Prevent forged verification responses
- [x] Test multiple wallets per contributor
- [x] Test identity revocation scenarios
- [x] Test Sybil farming scenarios
- [x] Test coordinated contributor attacks

### Phase 10 — Matching Calculation Engine
- [x] Implement `MatchingCalculator.sol` reference library
- [x] Define matching calculation interface
- [x] Implement deterministic calculation library
- [x] Define canonical contribution snapshot
- [x] Define canonical identity snapshot
- [x] Define matching calculation inputs
- [x] Define matching calculation output format
- [x] Implement off-chain Rust matching engine (`backend/services/matching-engine/`)
- [x] Implement contributor identity deduplication
- [x] Implement project matching score calculation
- [x] Implement total matching demand calculation
- [x] Implement normalized matching distribution
- [x] Implement allocation rounding reconciliation
- [x] Implement deterministic result serialization
- [x] Generate matching result Merkle tree
- [x] Generate allocation Merkle root
- [x] Generate matching calculation evidence
- [x] Publish calculation input commitment
- [x] Publish calculation output commitment
- [x] Implement matching result verification
- [x] Implement independent recalculation support
- [x] Compare Rust and Solidity reference calculations
- [x] Test matching calculation reproducibility
- [x] Test malformed matching results
- [x] Test manipulated allocation proofs

### Phase 11 — Matching Result Validation
- [x] Implement `MatchingResultManager.sol`
- [x] Implement matching result submission
- [x] Define authorized result publishers
- [x] Implement calculation snapshot commitment
- [x] Implement Merkle root submission
- [x] Implement matching result challenge period
- [x] Implement result publisher bonds
- [x] Implement invalid result challenges
- [x] Implement incorrect allocation challenges
- [x] Implement duplicate allocation challenges
- [x] Implement missing project challenges
- [x] Implement incorrect identity aggregation challenges
- [x] Implement challenge evidence validation
- [x] Implement challenge resolution rules
- [x] Implement result invalidation
- [x] Implement result resubmission
- [x] Implement publisher bond slashing
- [x] Implement challenger bond refunds
- [x] Implement result finalization
- [x] Prevent premature distribution
- [x] Test fraudulent result submissions
- [x] Test malicious challenge scenarios
- [x] Test unresolved challenge handling

### Phase 12 — Fund Distribution Engine
- [x] Implement `DistributionManager.sol`
- [x] Define final allocation structure
- [x] Implement finalized matching root storage
- [x] Implement project payout authorization
- [x] Implement Merkle proof verification
- [x] Implement project matching claims
- [x] Implement direct donation settlement
- [x] Implement matching fund settlement
- [x] Implement project payout accounting
- [x] Implement claimed allocation tracking
- [x] Prevent duplicate matching claims
- [x] Prevent unauthorized fund transfers
- [x] Implement project payout address validation
- [x] Implement unclaimed fund handling
- [x] Implement claim expiration rules
- [x] Implement distribution pause controls
- [x] Implement distribution completion tracking
- [x] Implement fund conservation checks
- [x] Test simultaneous project claims
- [x] Test incorrect Merkle proofs
- [x] Test duplicate payout attempts
- [x] Test distribution accounting invariants

### Phase 13 — Governance System
- [x] Implement `FundingGovernor.sol`
- [x] Implement `GovernanceTimelock.sol`
- [x] Define governance participation model
- [x] Define governance voting power
- [x] Define proposal creation requirements
- [x] Define governance quorum
- [x] Define proposal thresholds
- [x] Define voting periods
- [x] Implement governance proposals
- [x] Implement proposal voting
- [x] Implement proposal execution
- [x] Implement funding round governance
- [x] Implement project eligibility governance
- [x] Implement protocol fee governance
- [x] Implement matching parameter governance
- [x] Implement emergency parameter governance
- [x] Implement timelocked configuration changes
- [x] Implement governance event tracking
- [x] Prevent double voting
- [x] Prevent flash-loan voting manipulation
- [x] Implement governance delegation
- [x] Test governance attack scenarios

### Phase 14 — Project Review & Disputes
- [x] Implement `ProjectReviewManager.sol`
- [x] Implement `DisputeManager.sol`
- [x] Define project review criteria
- [x] Define reviewer eligibility
- [x] Implement project approval review
- [x] Implement project rejection review
- [x] Implement project challenge submission
- [x] Implement challenge evidence references
- [x] Implement project owner appeals
- [x] Implement independent review workflow
- [x] Implement dispute voting
- [x] Implement dispute resolution deadlines
- [x] Implement dispute bond requirements
- [x] Implement malicious challenge penalties
- [x] Implement reviewer conflict-of-interest checks
- [x] Implement project disqualification
- [x] Implement donation refund rules
- [x] Implement matching allocation recalculation rules
- [x] Prevent finalized payout manipulation
- [x] Test fraudulent project scenarios
- [x] Test dispute governance deadlocks

### Phase 15 — Protocol Security Controls
- [x] Implement role-based access control (`AccessControlDefaultAdminRules`)
- [x] Implement multisig administration
- [x] Implement governance timelock
- [x] Implement granular emergency pause (`Pausable`)
- [x] Implement reentrancy protection (`ReentrancyGuard`)
- [x] Implement safe ERC-20 transfers (`SafeERC20`)
- [x] Implement supported token restrictions
- [x] Implement signature replay protection (EIP-712 nonce + domain separator)
- [x] Implement domain-separated signatures
- [x] Implement round lifecycle validation
- [x] Implement donation accounting validation
- [x] Implement matching result validation
- [x] Implement identity credential validation
- [x] Implement Merkle proof security checks
- [x] Implement unauthorized payout prevention
- [x] Implement governance execution restrictions
- [x] Implement emergency fund recovery policy
- [x] Write security unit tests
- [x] Write adversarial contract tests

### Phase 16 — Frontend UI/UX Design
- [x] Create design system (Color palette, typography, status badges, components)
- [x] Design landing page
- [x] Design explore projects page
- [x] Design project details page
- [x] Design funding rounds page
- [x] Design active funding round page
- [x] Design project registration page
- [x] Design project owner dashboard
- [x] Design donor dashboard
- [x] Design donation interface
- [x] Design matching pool dashboard
- [x] Design matching sponsor interface
- [x] Design identity verification interface
- [x] Design contributor impact dashboard
- [x] Design matching estimation interface
- [x] Design matching results page
- [x] Design funding distribution page
- [x] Design governance dashboard
- [x] Design project review dashboard
- [x] Design dispute submission interface
- [x] Design transaction history page
- [x] Design protocol analytics dashboard
- [x] Design responsive mobile layouts
- [x] Design loading and error states

### Phase 17 — Frontend Development
- [x] Implement Next.js application routing (`app/` App Router)
- [x] Implement wallet connection (Wagmi + RainbowKit / Viem)
- [x] Implement network switching
- [x] Implement contract ABI integration
- [x] Implement project discovery
- [x] Implement project search and filtering
- [x] Implement project registration
- [x] Implement project metadata upload
- [x] Implement IPFS integration
- [x] Implement project owner dashboard
- [x] Implement active funding rounds
- [x] Implement donation transactions
- [x] Implement donation confirmation states
- [x] Implement donor contribution history
- [x] Implement identity verification flow
- [x] Implement matching sponsor deposits
- [x] Implement matching pool visualization
- [x] Implement quadratic matching estimates
- [x] Implement contributor impact visualization
- [x] Implement matching result display
- [x] Implement project payout claims
- [x] Implement governance proposals
- [x] Implement governance voting
- [x] Implement project review workflows
- [x] Implement dispute submission
- [x] Implement transaction simulation
- [x] Implement transaction status tracking
- [x] Implement wallet rejection handling
- [x] Implement responsive UI testing
- [x] Implement accessibility testing

### Phase 18 — Rust Backend & Database
- [x] Initialize Rust Axum API (`backend/services/api/`)
- [x] Configure PostgreSQL connection pool (`sqlx::PgPool`)
- [x] Create database migrations (`backend/migrations/`)
- [x] Create project database models
- [x] Create funding round database models
- [x] Create donation database models
- [x] Create contributor database models
- [x] Create identity verification models
- [x] Create matching result models
- [x] Create governance database models
- [x] Create dispute database models
- [x] Create distribution database models
- [x] Implement blockchain event indexer (`backend/services/indexer/`)
- [x] Index project registration events
- [x] Index funding round events
- [x] Index matching pool deposit events
- [x] Index donation events
- [x] Index matching result events
- [x] Index governance voting events
- [x] Index distribution events
- [x] Implement reorganization-safe indexing
- [x] Implement idempotent event processing
- [x] Implement event replay
- [x] Implement project discovery API
- [x] Implement funding rounds API
- [x] Implement donor history API
- [x] Implement matching analytics API
- [x] Implement governance history API
- [x] Implement API pagination and filtering
- [x] Implement structured logging (`tracing` + `tracing-subscriber`)
- [x] Write backend integration tests

### Phase 19 — Identity & Anti-Fraud Backend
- [x] Implement identity provider integration (Gitcoin Passport / EAS)
- [x] Implement credential verification service
- [x] Implement credential signature validation
- [x] Implement identity expiration validation
- [x] Implement identity revocation monitoring
- [x] Implement round-specific identity snapshots
- [x] Implement contributor identity deduplication
- [x] Implement privacy-preserving identity identifiers (Nullifiers)
- [x] Implement suspicious donation pattern detection
- [x] Implement coordinated donation monitoring
- [x] Implement donor concentration analytics
- [x] Implement suspicious project activity monitoring
- [x] Implement fraud review queue
- [x] Implement contributor appeal workflow
- [x] Implement identity verification audit logs
- [x] Implement identity service rate limiting
- [x] Implement sensitive data retention policies
- [x] Test identity service failures
- [x] Test duplicate contributor scenarios
- [x] Test forged identity credentials
- [x] Test privacy and access-control boundaries

### Phase 20 — Analytics & Reporting
- [x] Implement total donations metrics
- [x] Implement total matching pool metrics
- [x] Implement active funding rounds metrics
- [x] Implement registered projects metrics
- [x] Implement verified contributor metrics
- [x] Implement unique donor metrics
- [x] Implement per-project donation totals
- [x] Implement per-project matching estimates
- [x] Implement final matching allocations
- [x] Implement donor participation analytics
- [x] Implement project funding progress
- [x] Implement donor concentration metrics
- [x] Implement matching leverage metrics
- [x] Implement matching pool utilization
- [x] Implement funding distribution analytics
- [x] Implement historical funding charts
- [x] Implement round comparison dashboards
- [x] Implement governance participation metrics
- [x] Implement Sybil detection statistics
- [x] Implement financial reconciliation reports
- [x] Implement downloadable reports (CSV / JSON)

### Phase 21 — Automation & Monitoring
- [x] Implement funding round start monitoring
- [x] Implement funding round end monitoring
- [x] Implement project registration deadline alerts
- [x] Implement matching calculation job scheduling
- [x] Implement matching result publication monitoring
- [x] Implement challenge period monitoring
- [x] Implement matching result finalization monitoring
- [x] Implement distribution deadline monitoring
- [x] Implement unclaimed fund monitoring
- [x] Implement identity verification failure alerts
- [x] Implement suspicious donation alerts
- [x] Implement governance deadline monitoring
- [x] Implement matching pool balance monitoring
- [x] Implement backend service health checks
- [x] Implement indexer synchronization alerts
- [x] Implement transaction failure monitoring
- [x] Implement automation retry mechanisms
- [x] Implement operational incident alerts

### Phase 22 — TypeScript SDK & Developer Tools
- [x] Create TypeScript SDK package (`packages/sdk/`)
- [x] Generate typed smart contract clients
- [x] Implement project registration helpers
- [x] Implement project query helpers
- [x] Implement funding round query helpers
- [x] Implement donation helpers
- [x] Implement matching pool contribution helpers
- [x] Implement contributor eligibility helpers
- [x] Implement identity verification helpers
- [x] Implement matching estimation helpers
- [x] Implement matching result verification helpers
- [x] Implement Merkle proof helpers
- [x] Implement distribution claim helpers
- [x] Implement governance voting helpers
- [x] Implement protocol analytics helpers
- [x] Generate API documentation
- [x] Generate smart contract documentation
- [x] Create integration examples
- [x] Test SDK independently

### Phase 23 — Testing & Formal Validation
- [x] Complete smart contract unit tests
- [x] Complete contract integration tests
- [x] Complete Foundry fuzz tests
- [x] Complete stateful invariant tests
- [x] Test donation conservation
- [x] Test matching pool conservation
- [x] Test matching allocation conservation
- [x] Test contributor identity uniqueness
- [x] Test round lifecycle correctness
- [x] Test project registration restrictions
- [x] Test donation deadline enforcement
- [x] Test matching calculation determinism
- [x] Test matching score precision
- [x] Test allocation rounding boundaries
- [x] Test zero and extreme donation values
- [x] Test Sybil identity attacks
- [x] Test coordinated contribution attacks
- [x] Test malicious matching result submissions
- [x] Test fraudulent Merkle proofs
- [x] Test duplicate distribution claims
- [x] Test governance manipulation scenarios
- [x] Test reentrancy scenarios
- [x] Test malicious ERC-20 behavior
- [x] Test unauthorized fund withdrawals
- [x] Test contract pause and recovery
- [x] Run Slither static analysis
- [x] Run frontend component tests
- [x] Run backend integration tests
- [x] Run Playwright end-to-end tests
- [x] Perform gas optimization
- [x] Conduct threat model review
- [x] Resolve critical and high-severity findings
- [x] Prepare independent audit documentation

### Phase 24 — Testnet Deployment
- [x] Select final EVM testnet (Sepolia / Arbitrum Sepolia)
- [x] Configure testnet RPC endpoints
- [x] Deploy supported test payment token (`TestToken.sol`)
- [x] Deploy `ProjectRegistry`
- [x] Deploy `FundingRoundManager`
- [x] Deploy `MatchingVault`
- [x] Deploy `MatchingPool`
- [x] Deploy `DonationVault`
- [x] Deploy `DonationManager`
- [x] Deploy `MatchingResultManager`
- [x] Deploy `DistributionManager`
- [x] Deploy `FundingGovernor`
- [x] Deploy `GovernanceTimelock`
- [x] Deploy `ProjectReviewManager`
- [x] Deploy `DisputeManager`
- [x] Configure protocol permissions
- [x] Configure supported donation token
- [x] Configure identity verification provider
- [x] Configure initial funding round parameters
- [x] Configure matching pool limits
- [x] Configure governance parameters
- [x] Configure emergency administration
- [x] Verify smart contract source code
- [x] Publish contract deployment addresses
- [x] Deploy Rust backend
- [x] Deploy PostgreSQL database
- [x] Deploy blockchain indexer
- [x] Deploy matching calculation service
- [x] Deploy identity verification service
- [x] Deploy frontend application
- [x] Configure production-style monitoring

### Phase 25 — End-to-End Testnet Validation
- [x] Connect wallet to testnet
- [x] Complete contributor identity verification
- [x] Register community project
- [x] Upload project metadata to IPFS
- [x] Submit project for approval
- [x] Approve eligible project
- [x] Create funding round
- [x] Register project in funding round
- [x] Deposit matching pool capital
- [x] Start funding round
- [x] Donate to registered project
- [x] Donate to multiple projects
- [x] Verify donation accounting
- [x] Verify unique contributor aggregation
- [x] Verify real-time matching estimates
- [x] End funding round
- [x] Freeze canonical contribution snapshot
- [x] Freeze contributor eligibility snapshot
- [x] Calculate quadratic matching scores
- [x] Normalize matching allocations
- [x] Generate matching result Merkle tree
- [x] Submit matching result commitment
- [x] Verify matching result challenge period
- [x] Challenge incorrect matching result
- [x] Resolve matching result challenge
- [x] Finalize valid matching result
- [x] Claim project matching allocation
- [x] Settle direct project donations
- [x] Verify matching pool conservation
- [x] Verify project payout balances
- [x] Verify governance functionality
- [x] Verify project dispute workflow
- [x] Verify indexed transaction history
- [x] Verify analytics calculations
- [x] Verify emergency pause controls
- [x] Complete end-to-end regression testing

### Phase 26 — Final Security & Release Review
- [x] Review smart contract permissions
- [x] Review matching calculation correctness
- [x] Review identity verification trust assumptions
- [x] Review Sybil-resistance limitations
- [x] Review donor privacy protections
- [x] Review project eligibility controls
- [x] Review governance trust assumptions
- [x] Review matching pool accounting
- [x] Review distribution settlement logic
- [x] Review economic attack surfaces
- [x] Review malicious contribution scenarios
- [x] Review matching result challenge mechanisms
- [x] Review operational incident procedures
- [x] Validate CI/CD pipelines
- [x] Validate reproducible contract builds
- [x] Validate monitoring alerts
- [x] Validate database recovery
- [x] Validate indexer recovery
- [x] Complete release acceptance checklist
- [x] Document known limitations
- [x] Freeze testnet release version

### Phase 27 — Documentation & Project Launch
- [x] Write complete project README
- [x] Publish protocol architecture diagrams
- [x] Publish smart contract architecture
- [x] Publish quadratic funding mathematics
- [x] Publish funding round lifecycle documentation
- [x] Publish project registration documentation
- [x] Publish donation lifecycle documentation
- [x] Publish matching calculation documentation
- [x] Publish Sybil-resistance methodology
- [x] Publish governance documentation
- [x] Publish security assumptions
- [x] Publish matching result verification guide
- [x] Publish contract API documentation
- [x] Publish backend API documentation
- [x] Publish SDK usage examples
- [x] Publish test coverage reports
- [x] Publish verified contract addresses
- [x] Create user onboarding guide
- [x] Record end-to-end demo video script
- [x] Publish project website
- [x] Publish GitHub repository
- [x] Prepare technical case study
- [x] Launch public testnet demonstration

### Phase 28 — Post-Launch Maintenance
- [x] Monitor funding round activity
- [x] Monitor project registration activity
- [x] Monitor matching pool balances
- [x] Monitor donation activity
- [x] Monitor matching calculation accuracy
- [x] Monitor Sybil attack indicators
- [x] Monitor identity provider availability
- [x] Monitor matching result challenges
- [x] Monitor distribution completion
- [x] Monitor governance participation
- [x] Monitor backend availability
- [x] Monitor indexer synchronization
- [x] Monitor automation execution
- [x] Fix discovered bugs
- [x] Improve matching calculation efficiency
- [x] Improve frontend usability
- [x] Maintain dependencies
- [x] Update technical documentation
- [x] Run periodic security reviews
- [x] Conduct incident response drills

### Phase 29 — Future Enhancements (Roadmap)
- [ ] Multi-chain funding rounds
- [ ] Cross-chain donations
- [ ] Multiple donation assets per round
- [ ] Stablecoin-based matching pools
- [ ] Privacy-preserving donations (Stealth addresses / ZK)
- [ ] Zero-knowledge identity verification (ZK Passport / Semaphore)
- [ ] Zero-knowledge matching proofs (ZK-SNARK / RISC Zero)
- [ ] Fully verifiable on-chain matching calculations
- [ ] Advanced Sybil-resistance models
- [ ] Reputation-based contributor weighting
- [ ] Pairwise quadratic funding (CLR)
- [ ] Retroactive public goods funding (RetroPGF)
- [ ] Continuous quadratic funding
- [ ] Streaming project payouts (Superfluid)
- [ ] Milestone-based funding distribution
- [ ] Decentralized project verification
- [ ] Decentralized matching result verification
- [ ] Community-managed matching pools
- [ ] Delegated governance
- [ ] Governance token economics
- [ ] DAO treasury integrations
- [ ] GitHub contribution-based project verification
- [ ] Public goods impact measurement
- [ ] Advanced donor analytics
- [ ] Independent smart contract audits
- [ ] Legal and regulatory assessment
- [ ] Capped mainnet pilot
- [ ] Production mainnet launch
