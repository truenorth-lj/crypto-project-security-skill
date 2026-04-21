# DeFi Security Audit: Jito Liquid Staking (JitoSOL)

**Audit Date:** 2026-04-21
**Protocol:** Jito Liquid Staking -- Largest Solana LSD with MEV rewards

## Overview
- Protocol: Jito Liquid Staking (JitoSOL)
- Chain: Solana
- Type: Liquid Staking Derivative (SPL stake pool with MEV capture)
- TVL: ~$0.94B (DeFiLlama)
- TVL Trend: Stable; JitoSOL is the largest Solana LSD by TVL and is integrated broadly across Solana DeFi (Kamino, Drift, Marginfi, Orca).
- Launch Date: November 2022 (JitoSOL), built on Solana SPL stake-pool program
- Audit Date: 2026-04-21
- Source Code: Open (github.com/jito-foundation)

## Quick Triage Score: 78/100
- Red flags found: Multisig-managed StakePoolManager; manager can update validator list and fee config; no on-chain DAO vote for routine ops.
- Historical attack pattern adjacency: This is a Solana protocol; Drift-hack (January 2026) occurred on the same chain. Pattern checking is directly applicable.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | No dedicated insurance fund | 1-5% | MEDIUM |
| Audit Coverage Score | 2 firms (Neodyme + SPL stake-pool audits) | 1-3 avg | LOW risk |
| Governance Decentralization | JTO DAO (governance live since 2024); manager multisig for operational actions | DAO + multisig avg | MEDIUM risk |
| Timelock Duration | UNVERIFIED; StakePoolManager multisig has no public timelock on validator-list / fee updates | 24-48h avg | MEDIUM risk |
| Multisig Threshold | Jito Foundation multisig (threshold UNVERIFIED) | 3/5 avg | MEDIUM risk |
| GoPlus Risk Flags | N/A (Solana, GoPlus EVM-focused) | -- | -- |

## Token Security Notes (Solana)

JitoSOL is an SPL token (mint: `J1toso1uCk3RLmjorhTtrVwY9HJ7X8V9yYac6Y7kGCPn`). GoPlus EVM token scanner is not applicable; risk assessment is based on on-chain program analysis and audit reports.

| Check | Result | Risk |
|-------|--------|------|
| Mint Authority | StakePoolManager PDA (program-controlled) | LOW (no EOA mint) |
| Freeze Authority | Not set (standard stake pool) | LOW |
| Mint/Burn gated by staking program | Yes (SPL stake-pool program) | LOW |
| Upgradable Program | Yes (Jito-maintained fork of SPL stake-pool) | MEDIUM |
| Program Upgrade Authority | Jito Foundation multisig (UNVERIFIED exact signer set) | MEDIUM |

Assessment: **LOW-MEDIUM RISK** at the token level. The token mint is controlled by a Solana program (not an EOA), standard for SPL stake pools. The main risk vector is the program upgrade authority.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | JTO DAO exists but StakePoolManager multisig controls operational parameters | Y |
| Oracle & Price Feeds | **LOW** | Exchange rate derived on-chain from SPL stake-pool state | Y |
| Economic Mechanism | **LOW** | Non-rebasing, SPL stake-pool accounting; permissionless withdrawals | Y |
| Smart Contract | **LOW-MEDIUM** | Fork of audited SPL stake-pool + Neodyme audit; limited secondary audits | Y |
| Token Contract | **LOW** | No freeze authority; mint authority is a program PDA | Y |
| Operational Security | **LOW** | Established team (Jito Labs); strong reputation; JTO DAO transparency | Y |
| **Overall Risk** | **MEDIUM** | **Well-engineered Solana LSD with a multisig-managed operational layer** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**JTO DAO:**
- Jito launched the JTO governance token in December 2023; the DAO votes on high-level protocol decisions (fee changes, strategic direction, treasury allocations).
- Governance forum and voting happen via Realms (Solana governance framework).

**StakePoolManager (operational control):**
- JitoSOL is built on a fork of the SPL stake-pool program. Each stake pool has a "manager" account with authority to:
  - Update the validator list
  - Change the pool fee (subject to SPL stake-pool program-level limits)
  - Update the manager or staker account
  - Set the stake deposit and SOL deposit authorities
- The Jito StakePoolManager is a multisig controlled by the Jito Foundation. Exact signer set and threshold are UNVERIFIED from this audit's sources.

**Validator Selection:**
- Jito uses StakeNet, an on-chain validator performance scoring system, to select and re-balance validators in the pool.
- Validator list rebalances are executed by the Jito team (staker authority) based on StakeNet scores.

**Assessment:** The architecture is stronger than a pure-multisig model (DAO governs strategy + StakeNet provides objective validator selection criteria), but day-to-day operational control still resides with a multisig. No public timelock on manager actions is documented -- users rely on the Jito Foundation's discretion for time-sensitive operational changes.

### 2. Oracle & Price Feeds -- LOW

**Exchange Rate:**
- JitoSOL/SOL exchange rate is computed on-chain from the SPL stake-pool state (total SOL under management / total JitoSOL supply).
- No external oracle is needed for the exchange rate itself -- it is deterministic from on-chain accounting.

**MEV Rewards:**
- Jito captures MEV rewards via the Jito-Solana validator client (MEV tips from priority-auction block-building). These rewards flow to the stake pool, increasing the SOL balance and therefore the JitoSOL/SOL exchange rate.
- MEV accounting is done by the Jito Block Engine + tip distribution program, also audited.

**DeFi Integrations:**
- Lending protocols (Kamino, MarginFi, Drift) use on-chain JitoSOL/SOL feeds plus Pyth SOL/USD for pricing. This is a two-hop pricing model and is the industry-standard approach for LSDs on Solana.

**Assessment:** Exchange-rate oracle design is strong because it is derived from on-chain state rather than posted by an operator. This is a meaningful improvement over CEX-operated LSDs like WBETH.

### 3. Economic Mechanism -- LOW

**Staking Model:**
- Users deposit SOL, receive JitoSOL (non-rebasing, appreciating relative to SOL).
- Pool fees: ~4% on staking + MEV rewards (protocol fee goes to JTO treasury and referrer program).

**Withdrawal:**
- Users can either:
  1. Swap JitoSOL back for SOL via DEX aggregators (instant, at market rate).
  2. Withdraw directly from the stake pool, which deactivates a stake account and waits for the Solana epoch boundary (permissionless).
- This is a meaningful decentralization advantage over CEX LSDs: withdrawals are not gated by any off-chain party.

**Validator Set:**
- Large, diversified validator set (hundreds of validators), selected by StakeNet performance scoring.
- Individual validator caps limit concentration.

**MEV Capture:**
- Uses the Jito-Solana client and Block Engine. MEV captured via searcher auctions is redistributed, boosting JitoSOL yield above baseline staking.
- This is the primary economic differentiator vs. other Solana LSDs (Marinade, Sanctum-aggregated LSTs).

**Insurance:**
- No dedicated slashing insurance fund. Solana slashing is currently not live in the same form as Ethereum, so the immediate risk is bounded.
- No public JTO treasury allocation for user-loss scenarios.

**Assessment:** The economic mechanism is clean and well-understood. Permissionless withdrawals are a structural strength. The lack of dedicated insurance is a minor concern but consistent with Solana LSD peers.

### 4. Smart Contract Security -- LOW-MEDIUM

**Code Base:**
- JitoSOL uses a fork of the SPL stake-pool program, which is itself audited (audit index at spl.solana.com/stake-pool#security-audits covers multiple firms).
- Jito-specific modifications and MEV-accrual program were audited by Neodyme.

**Audits (DeFiLlama-listed):**
- SPL stake-pool program audits (multiple firms via Solana Labs / Solana Foundation).
- Neodyme -- Jito-specific audit (PDF available via DeFiLlama audit_links).

**Bug Bounty:**
- Jito runs a bug bounty (historically via Immunefi; current program scope and max payout UNVERIFIED at time of audit).

**Battle Testing:**
- Live since November 2022. No protocol-level exploit of JitoSOL contracts has been reported.
- Handled Solana's outages (Feb 2023, various) without pool-level incidents.

**Assessment:** The SPL stake-pool program is one of the most scrutinized Solana programs (many audits over multiple years across the broader stake-pool family). Jito's fork narrows the custom-code surface to the MEV accrual logic and manager-governance tweaks, which Neodyme has audited. This yields a LOW smart-contract risk at program level, bumped to LOW-MEDIUM by the single dedicated Jito-specific audit (vs. Lido's 10+).

### 5. Operational Security -- LOW

**Team:**
- Jito Labs is a well-known Solana infrastructure team led by public, doxxed founders. Also operates the Jito-Solana validator client (dominant MEV-aware Solana client).
- Strong institutional credibility: major VC backers, consistent public communication.

**Incident History:**
- No protocol-level exploits or user fund losses since launch in 2022.
- JTO token launch and airdrop proceeded without incident in December 2023.
- Temporary Jito-Solana mempool policy changes (disabling certain MEV strategies in late 2023) were handled transparently with user/validator communication.

**Transparency:**
- Open-source codebase on GitHub (Jito Foundation repos).
- Active governance forum via Realms.
- Regular StakeNet scoring publications.

**Assessment:** Operationally among the strongest Solana protocols. The combination of doxxed leadership, open-source code, live governance, and a clean incident history places Jito in the LOW-risk band for operations.

## Critical Risks

None identified. The main concern is the absence of a public timelock on StakePoolManager multisig actions (validator list updates, fee changes), which is material for Drift-style governance-attack analysis.

## Peer Comparison

| Feature | JitoSOL | Marinade (mSOL) | Sanctum LSTs | Lido stETH |
|---------|---------|------------------|--------------|------------|
| Chain | Solana | Solana | Solana | Ethereum |
| TVL | ~$0.94B | ~$0.5B (UNVERIFIED) | ~$1.15B aggregated | ~$19B |
| Governance | JTO DAO + multisig | MNDE DAO | DAO + validator choice | DAO + Dual Governance |
| Oracle | On-chain stake-pool state | On-chain state | On-chain state | 5-of-9 committee |
| Withdrawals | Permissionless | Permissionless | Permissionless | Native (V2+) |
| MEV Capture | Yes (Jito Block Engine) | Limited | Varies per LST | No |
| Audits | SPL audits + Neodyme | Multiple | Multiple | 10+ firms + FV |
| Validator Selection | StakeNet scoring | Performance-based | User choice (LST-specific) | Curated + permissionless |

## Recommendations

1. **Publish StakePoolManager timelock**: A public, non-trivial timelock on validator-list changes and fee updates would materially reduce governance risk.
2. **Multisig signer transparency**: Publishing signer identities and threshold for the StakePoolManager multisig would improve governance auditability.
3. **Dedicated insurance**: A small JTO treasury allocation earmarked for user-loss coverage would close the insurance gap relative to EVM peers.
4. **Monitor Solana slashing rollout**: If Solana enables stricter slashing, the insurance gap becomes more material; an insurance fund should precede that activation.
5. **Users**: JitoSOL's on-chain exchange rate + permissionless withdrawal make it a structurally safe Solana LSD. Monitor JTO governance proposals for any changes to manager authority.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new validators without timelock -- **YES** (StakePoolManager can update validator list; no public timelock confirmed)
- [ ] Admin can change oracle sources arbitrarily -- **NO**, exchange rate is derived from on-chain state
- [x] Admin can modify fees -- **YES** (but capped by SPL stake-pool program limits)
- [ ] Multisig has low threshold -- **UNVERIFIED**, but Jito Foundation multisig
- [x] Zero or short timelock -- **YES / UNVERIFIED** for StakePoolManager actions
- [x] Pre-signed transaction risk -- **POSSIBLE** (Solana has this attack class, as seen in Drift hack)
- [x] Social engineering surface area -- **MEDIUM**, multisig signers at a single org

**4-5/7 flags matched** -- broadly similar architectural pattern to Drift, though Jito has a much stronger reputation and the financial impact of validator-list manipulation is bounded (cannot steal staked SOL, but could route rewards poorly or degrade pool performance).

### Euler/Mango-type (Oracle Manipulation + Economic Exploit):
- [ ] Low-liquidity collateral accepted -- **N/A**, not a lending protocol
- [ ] Single oracle source without TWAP -- **NO**, exchange rate derived on-chain
- [ ] No circuit breaker -- Pool has deposit/withdrawal limits configurable by manager
- [ ] Insufficient insurance -- Modest concern

**0-1/4 flags matched.**

### Ronin/Harmony-type (Bridge / Validator Key Compromise):
- [ ] Small validator/signer set -- **NO**, hundreds of validators in the pool
- [ ] Keys stored in hot wallets -- **N/A**, validators are third-party Solana validators
- [ ] Single point of failure in bridge -- **N/A**, no bridge
- [ ] No key rotation mechanism -- StakeNet rotates validator set based on scoring

**0/4 flags matched.**

## Information Gaps

- **StakePoolManager multisig signer set and threshold**: Exact Jito Foundation multisig composition and threshold for SPL stake-pool manager actions.
- **Timelock on manager actions**: Whether there is any mandatory delay between a fee change or validator list update and its on-chain effect.
- **Current bug bounty status**: Active program, maximum payout, and scope coverage at time of audit.
- **JTO DAO vs. multisig authority boundary**: Formal documentation of which operational actions require JTO DAO vote vs. which the multisig can execute unilaterally.
- **MEV accrual edge cases**: The exact on-chain tip-distribution mechanics and any historical discrepancies between expected and realized MEV accrual.
- **StakeNet scoring transparency**: Whether StakeNet scores and validator inclusion/exclusion decisions are fully reproducible from public data.

## Disclaimer

This is a research-based assessment, not a formal smart contract audit. It is based on publicly available information, on-chain data, DeFiLlama metrics, and publicly linked Jito audit reports as of 2026-04-21. DYOR.
