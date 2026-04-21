# DeFi Security Audit: Sanctum Validator LSTs

**Audit Date:** 2026-04-21
**Protocol:** Sanctum -- Solana LST aggregator / per-validator LST infrastructure

## Overview
- Protocol: Sanctum Validator LSTs
- Chain: Solana
- Type: Liquid Staking Infrastructure (per-validator LSTs backed by the SanctumSPL stake-pool program + shared Infinity liquidity pool)
- TVL: ~$1.15B aggregated across all Sanctum-deployed LSTs (DeFiLlama)
- TVL Trend: Growing; Sanctum has become the dominant long-tail Solana LSD platform.
- Launch Date: 2024 (Sanctum; validator-LST program launches spread across 2024-2025)
- Audit Date: 2026-04-21
- Source Code: Partially open (SanctumSPL stake-pool program is a fork of SPL stake-pool; additional Sanctum programs such as Router/Infinity have varying open-source status)

## Quick Triage Score: 65/100
- Red flags found: Zero audits listed on DeFiLlama; aggregation design means a single Sanctum-level program bug can affect hundreds of LSTs.
- Governance model is opaque in public sources -- admin controls on the SanctumSPL program and Infinity pool not fully disclosed.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | No dedicated insurance fund (UNVERIFIED) | 1-5% | MEDIUM |
| Audit Coverage Score | 0 audits listed on DeFiLlama (UNVERIFIED -- team may have private audits) | 1-3 avg | HIGH risk |
| Governance Decentralization | Sanctum-team controlled program upgrade authority (UNVERIFIED multisig) | DAO or multisig avg | HIGH risk |
| Timelock Duration | UNVERIFIED for SanctumSPL program upgrades | 24-48h avg | HIGH risk |
| Multisig Threshold | UNVERIFIED | 3/5 avg | UNVERIFIED |
| GoPlus Risk Flags | N/A (Solana) | -- | -- |

## Token Security Notes (Solana)

Sanctum Validator LSTs are a family of SPL tokens, one per validator (e.g., bonkSOL, pwrSOL, laineSOL, etc.), each backed by its own stake pool deployed through the SanctumSPL stake-pool program. Additionally, the Infinity pool (INF) is a shared liquidity / LST aggregator.

| Check | Result | Risk |
|-------|--------|------|
| Mint Authority (each LST) | Validator-specific stake pool PDA | LOW (no EOA mint) |
| Freeze Authority | Not set (standard) | LOW |
| Shared Program Upgrade Authority | Sanctum-team controlled (UNVERIFIED multisig) | MEDIUM-HIGH |
| Routing Program (Sanctum Router) | Sanctum-controlled | MEDIUM |
| Infinity pool authority | Sanctum-controlled | MEDIUM |

Assessment: **MEDIUM-HIGH RISK** at the aggregate level. Individual LSTs inherit stake-pool-program semantics from SanctumSPL, but because hundreds of LSTs share the same program and Router, a compromise at that layer would affect all Sanctum LSTs simultaneously. This is a shared-kernel risk distinct from standalone LSDs like Lido or Jito.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **HIGH** | Program upgrade authority controlled by Sanctum team; aggregation shared risk | Partial |
| Oracle & Price Feeds | **LOW** | Exchange rates derived on-chain from stake pools | Y |
| Economic Mechanism | **MEDIUM** | Infinity pool peg + Router swaps introduce additional attack surface | Partial |
| Smart Contract | **MEDIUM-HIGH** | 0 public audits listed on DeFiLlama; custom SanctumSPL fork of SPL stake-pool | Y (absence) |
| Token Contract | **LOW** | Per-LST mint authority is a program PDA | Y |
| Operational Security | **MEDIUM** | Small but credible team; strong ecosystem integrations; limited public incident history | Partial |
| **Overall Risk** | **HIGH** | **Aggregation infrastructure for Solana LSTs; shared-kernel risk + no public audits listed** | |

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Program Upgrade Authority:**
- The SanctumSPL stake-pool program is a fork of the SPL stake-pool program with additions (e.g., instant unstake support via the Router).
- The upgrade authority for this program sits with Sanctum team multisig. Exact signer set, threshold, and any timelock are UNVERIFIED from public sources at time of audit.

**Router / Infinity Pool:**
- Sanctum Router enables same-epoch LST-to-LST and LST-to-SOL swaps, backed by Infinity pool liquidity.
- Router and Infinity pool are additional Sanctum-controlled programs; changes to their parameters (fees, allow-lists of LSTs) are controlled by the Sanctum team.

**Per-LST Manager:**
- Each validator LST has its own stake pool manager, usually the validator operator or Sanctum (depending on deployment track: reserve, unlimited, or free-tier).
- Managers can update validator-related parameters within the limits of the stake-pool program.

**DAO:**
- Sanctum has issued a CLOUD governance token but the full scope of what CLOUD governs vs. what remains team-controlled is not fully codified in public docs at time of audit.

**Assessment:** This is the weakest area. Because many LSTs share a single program, the upgrade authority for that program is a concentrated failure mode. Without public timelock and multisig-signer transparency, users must trust the Sanctum team's operational security.

### 2. Oracle & Price Feeds -- LOW

**Per-LST Exchange Rate:**
- Each LST's exchange rate against SOL is computed on-chain from its stake-pool state (total SOL under management / total LST supply).
- No external oracle is required for the LST/SOL rate.

**Infinity Pool Pricing:**
- The Infinity pool uses the on-chain LST/SOL rates of its constituent LSTs to price swaps. This is internally deterministic rather than oracle-dependent.

**DeFi Integrations:**
- Lending protocols (Kamino, MarginFi) integrating Sanctum LSTs use on-chain exchange rates combined with Pyth SOL/USD feeds.

**Assessment:** Oracle design is structurally sound because exchange rates are derived from on-chain accounting rather than posted by operators. Same strength as JitoSOL.

### 3. Economic Mechanism -- MEDIUM

**Per-Validator LST Model:**
- Users stake SOL with a specific validator and receive an LST representing that stake (e.g., bonkSOL tracks Bonk validator, laineSOL tracks Laine validator).
- The LST is non-rebasing; yield accrues into the SOL/LST exchange rate.

**Infinity Pool:**
- Shared liquidity pool composed of many whitelisted LSTs. Users can deposit an LST and receive INF (the Infinity pool's LP token), or swap one LST for another.
- Fees on swaps reward INF holders and fund Sanctum operations.

**Withdrawal / Unstake:**
- Instant unstake: Router swap against Infinity pool liquidity (subject to liquidity and fees).
- Slow unstake: permissionless withdrawal from the underlying stake pool at epoch boundary.

**Risks Specific to Aggregation:**
- Infinity pool peg risk: If one constituent LST de-pegs (e.g., validator slashing, operator misbehavior), it can propagate into Infinity pool pricing and affect INF holders.
- Router arbitrage risk: Searchers can arbitrage stale exchange rates across LSTs.

**Insurance:**
- No public dedicated insurance fund identified.

**Assessment:** The per-LST economic model is clean; risk comes from the aggregation layer. Infinity pool is a structural innovation but also a structural new attack surface (pool-level accounting bugs, peg attacks). MEDIUM reflects this net.

### 4. Smart Contract Security -- MEDIUM-HIGH

**Audits:**
- DeFiLlama lists **0 audits** for Sanctum at time of review. The team may have conducted private audits that are not yet published; this is UNVERIFIED.
- The underlying SPL stake-pool program (of which SanctumSPL is a fork) has prior audits, so part of the code base has been reviewed at the upstream level.

**Custom Code Surface:**
- SanctumSPL-specific modifications (for Router/Infinity compatibility) are the highest-risk surface.
- Router program and Infinity pool accounting are additional custom-audit targets.

**Bug Bounty:**
- UNVERIFIED whether Sanctum operates a public bug bounty program at time of audit.

**Battle Testing:**
- Live since 2024, handling ~$1.15B across hundreds of LSTs with no publicly reported pool-level exploit.

**Assessment:** Zero public audits listed on DeFiLlama for a Solana LSD with $1.15B TVL is a material red flag. Even if private audits exist, the lack of published reports limits external verifiability. The inherited SPL stake-pool audit coverage is not a full substitute for Sanctum-specific audits, given the material program modifications.

### 5. Operational Security -- MEDIUM

**Team:**
- Sanctum was founded by FP Lee and team, known in the Solana ecosystem. The team is publicly visible on Twitter and at Solana events.
- Sanctum has grown into a critical piece of Solana LST infrastructure, with integrations across major Solana DeFi protocols.

**Incident History:**
- No major public incident attributable to Sanctum protocol-level bugs has been reported at time of audit.
- Minor known issues (e.g., Router pricing edge cases on specific low-liquidity LSTs) have been handled via fee adjustments and UI warnings.

**Transparency:**
- Documentation at docs.sanctum.so covers high-level mechanics.
- Specific admin key addresses, upgrade timelocks, and governance procedures are less thoroughly documented than at Lido or Jito.

**Assessment:** Operationally Sanctum has a credible team and strong ecosystem position, but the transparency around admin controls and audit posture lags top-tier LSDs.

## Critical Risks

1. **Shared-program aggregation risk**: A bug or compromise in the SanctumSPL program, Router program, or Infinity pool would simultaneously affect every Sanctum-deployed LST. This concentration is the defining risk of the protocol.
2. **Zero public audits listed**: Absence of publicly available audit reports on DeFiLlama for a $1.15B protocol is a flag that should be closed by publication or explicit acknowledgement from the team.

## Peer Comparison

| Feature | Sanctum | JitoSOL | Marinade | Lido stETH |
|---------|---------|---------|----------|------------|
| Chain | Solana | Solana | Solana | Ethereum |
| TVL | ~$1.15B (aggregated) | ~$0.94B | ~$0.5B (UNVERIFIED) | ~$19B |
| Governance | Team multisig + CLOUD (nascent) | JTO DAO + multisig | MNDE DAO | DAO + Dual Governance |
| Audit Count (public) | 0 listed | 2 | Multiple | 10+ |
| Validator Selection | Per-LST (user/validator chooses) | StakeNet scoring | Performance-based | Curated + permissionless |
| Shared Infrastructure | Yes (Router + Infinity pool) | No | No | No |
| Instant Unstake | Yes (via Infinity) | Via DEX aggregators | Via DEX | Via DEX |
| Withdrawals | Permissionless (epoch-delayed) | Permissionless | Permissionless | Native |

## Recommendations

1. **Publish audits**: Sanctum should publish any completed audits of the SanctumSPL fork, Router program, and Infinity pool. Zero public audits for $1.15B+ TVL is the single largest risk marker.
2. **Multisig and timelock disclosure**: Publish signer set, threshold, and any timelock governing the upgrade authorities of the SanctumSPL and Router programs.
3. **Establish public bug bounty**: A public Immunefi-style bounty specifically scoped to SanctumSPL, Router, and Infinity would close the incentive gap for disclosures.
4. **Infinity pool risk disclosure**: Document peg-risk scenarios (e.g., what happens if a constituent LST is slashed) and any protective parameters.
5. **Users**: Until audit coverage and admin transparency improve, treat Sanctum-aggregate exposure as higher-risk than standalone audited LSDs. Prefer LSTs with independent published audits where possible, or hold stake directly rather than via the Infinity pool.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new LSTs without timelock -- **YES** (Router/Infinity LST allow-list is team-controlled)
- [ ] Admin can change oracle sources arbitrarily -- **NO**, exchange rate derived from stake-pool state
- [x] Admin can modify fees -- **YES** (Router/Infinity fees; per-pool fees within SPL limits)
- [x] Multisig has low threshold -- **UNVERIFIED**, treated as HIGH pending disclosure
- [x] Zero or short timelock -- **UNVERIFIED**, treated as HIGH pending disclosure
- [x] Pre-signed transaction risk -- **POSSIBLE** (Solana pattern class)
- [x] Social engineering surface area -- **MEDIUM-HIGH**, small team controls critical programs

**5-6/7 flags matched**. This matches the Drift-type profile more closely than any other major Solana LSD in this audit round -- not because of malicious intent, but because the governance safeguards are underspecified publicly.

### Euler/Mango-type (Oracle Manipulation + Economic Exploit):
- [ ] Low-liquidity collateral accepted -- **N/A** at LST level, but Infinity pool accepts many long-tail LSTs
- [ ] Single oracle source without TWAP -- **NO**, on-chain derived rate
- [ ] No circuit breaker -- UNVERIFIED for Infinity pool extreme scenarios
- [x] Insufficient insurance -- No dedicated fund identified

**1-2/4 flags matched**. The long-tail validator inclusion in Infinity pool is the main Euler-adjacent exposure: a highly-weighted LST that de-pegs could cascade.

### Ronin/Harmony-type (Bridge / Validator Key Compromise):
- [ ] Small validator/signer set -- **N/A** per LST (single validator per LST is expected); aggregate pool is diversified
- [ ] Keys stored in hot wallets -- **UNVERIFIED** for Sanctum admin multisig
- [ ] Single point of failure in bridge -- **N/A**, no bridge
- [x] No key rotation mechanism -- **UNVERIFIED**, no public rotation policy

**0-1/4 flags matched**.

## Information Gaps

- **SanctumSPL upgrade authority**: Multisig signer set, threshold, and any timelock.
- **Router and Infinity pool upgrade authority**: Same as above.
- **Published audits**: Whether any completed audits exist beyond the inherited SPL stake-pool audits, and if so, the firms and dates.
- **Bug bounty program**: Current scope, platform, and maximum payout.
- **CLOUD governance scope**: Specifically what operational levers CLOUD holders can pull vs. which actions remain team-executed.
- **Infinity pool risk parameters**: Caps per LST, emergency pause mechanism, and incident-response playbook.
- **Incident history**: No known major incident, but the absence of a public postmortem log makes this hard to verify independently.

## Disclaimer

This is a research-based assessment, not a formal smart contract audit. It is based on publicly available information, DeFiLlama metrics, and Sanctum's public documentation as of 2026-04-21. DYOR. The zero-public-audit finding is based on DeFiLlama's audit metadata for `sanctum-validator-lsts` and may not reflect private audits the team has conducted but not published.
