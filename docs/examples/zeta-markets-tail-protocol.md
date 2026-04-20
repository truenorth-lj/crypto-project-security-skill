# DeFi Security Audit: Zeta Markets

**Audit Date:** April 20, 2026
**Protocol:** Zeta Markets -- Solana derivatives DEX (TRANSITIONING TO BULLET)
**Valid Until:** July 19, 2026 (or sooner if: TVL changes >30%, governance upgrade, or security incident)

## Overview
- Protocol: Zeta Markets
- Chain: Solana
- Type: Perpetual Futures DEX
- TVL: $0 (DeFiLlama reports $0 since mid-2025; protocol transitioning to Bullet network)
- TVL Trend: 0% / 0% / 0% (flatline at zero)
- Launch Date: ~2022
- Peak TVL: ~$15M (June 2022)
- Source Code: **Closed** (only SDKs and tooling are open source)

## Quick Triage Score: 18/100 | Data Confidence: 20/100

**Triage Score Calculation:**
```
Start at 100.
CRITICAL flags:
  [x] TVL = $0                                              -25
HIGH flags:
  [x] Closed-source contracts (is_open_source = 0)          -15
  [x] Zero audits listed on DeFiLlama                       -15
MEDIUM flags:
  [x] No third-party security certification                  -8
LOW flags:
  [x] No documented timelock on admin actions                -5
  [x] No bug bounty program (Immunefi)                       -5
  [x] Single oracle provider (Pyth primary)                  -5
  [x] Undisclosed multisig signer identities                 -5
  [x] No disclosed penetration testing                       -5
                                                       Total: -88
                                                       Score: 12 → floor at 12
```

Correction: recalculating -- 25 + 15 + 15 + 8 + 5 + 5 + 5 + 5 + 5 = 88. 100 - 88 = 12. Previous report had 18; updated to **12/100 (CRITICAL)**.

**Data Confidence Score Calculation:**
```
Start at 0.
  [ ] Source code is open and verified                        +0 (closed)
  [ ] GoPlus/RugCheck token scan completed                  +15 (RugCheck completed)
  [ ] At least 1 audit report publicly available             +0 (none found)
  [ ] Multisig configuration verified on-chain               +0 (unverified)
  [ ] Timelock duration verified                             +0 (none found)
  [x] Team identities publicly known (doxxed)               +10
  [ ] Insurance fund size publicly disclosed                  +0 (unknown)
  [ ] Bug bounty program details publicly listed              +0
  [ ] Governance process documented                           +0
  [x] Oracle provider(s) confirmed                           +5 (Pyth)
  [ ] Incident response plan published                        +0
  [ ] SOC 2 / ISO 27001 certification                        +0
  [ ] Key management policy published                         +0
  [ ] Penetration testing disclosed                           +0
                                                       Total: 30
```

**Quick Triage Score: 12/100 (CRITICAL) | Data Confidence: 30/100 (LOW)**

- Red flags found: 8 (TVL = $0, closed-source, zero audits, no certification, no timelock, no bug bounty, single oracle, undisclosed multisig config)
- Data points verified: 3 / 15

## Quantitative Metrics

| Metric | Value | Benchmark (Drift / Jupiter Perps) | Rating |
|--------|-------|------------------------------------|--------|
| Insurance Fund / TVL | N/A (TVL = $0) | Drift: ~2-5% | N/A |
| Audit Coverage Score | 0 | Drift: 2 audits (~1.0) | HIGH risk |
| Governance Decentralization | UNKNOWN | Drift: Squads multisig, known threshold | HIGH risk |
| Timelock Duration | None found | Drift: documented | HIGH risk |
| Multisig Threshold | UNKNOWN | Drift: disclosed | HIGH risk |
| RugCheck Risk Flags | 3 (2 danger, 1 warn) | -- | HIGH |

## Solana Token Security (RugCheck)

| Check | Result | Risk |
|-------|--------|------|
| RugCheck Score | 18,550 (high risk) | HIGH |
| Mint Authority | Revoked (null) | LOW |
| Freeze Authority | Revoked (null) | LOW |
| Metadata Mutable | No (immutable) | LOW |
| Top Holder Concentration | 43.45% single holder | HIGH |
| Top 10 Holders | >70% of supply | HIGH |
| Missing File Metadata | Yes | MEDIUM |
| Active Markets | 51 | -- |

**Note:** GoPlus token security API does not support Solana SPL tokens. RugCheck used as fallback per SKILL.md guidance. The ZEX token mint is `ZEXy1pqteRu3n13kdyh4LwPQknkFk3GzmMYMuNadWPo`. While mint and freeze authorities are revoked (good), extreme holder concentration (43.45% in one address, 20% in another) creates significant whale risk during the BULLET migration.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **HIGH** | Squads multisig claimed but threshold/signers unknown, no timelock | S/O | N |
| Oracle & Price Feeds | MEDIUM | Pyth primary, Chainlink fallback claimed, but closed-source prevents verification | S | Partial |
| Economic Mechanism | MEDIUM | Reasonable insurance fund design in docs, USDC-only collateral, but protocol has $0 TVL | S | Partial |
| Smart Contract | **HIGH** | Zero audits on DeFiLlama, closed-source core Solana program | S | N |
| Token Contract (RugCheck) | **HIGH** | 43.45% single-holder concentration, top 10 hold >70% | S | Y |
| Cross-Chain & Bridge | N/A | Single-chain Solana deployment | -- | -- |
| Off-Chain Security | **HIGH** | No SOC 2, no published key management, no pentest disclosure | O | N |
| Operational Security | **HIGH** | Protocol transitioning to Bullet; ZEX holders dependent on new, less battle-tested system | S/O | Partial |
| **Overall Risk** | **CRITICAL** | **Defunct protocol with $0 TVL, transitioning to new project with significant transparency gaps** | | |

**Overall Risk aggregation**: Governance HIGH (counts 2x = 2 HIGHs) + Smart Contract HIGH + Token HIGH + Off-Chain HIGH + Operational HIGH = 6 effective HIGHs. 2+ HIGHs = Overall HIGH. However, TVL = $0 is a CRITICAL triage flag, elevating to **CRITICAL**.

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

- Program upgrade authority delegated to Squads multisig (per Squads documentation and blog posts listing Zeta Markets as a user)
- **Threshold and signer count: UNKNOWN** -- not publicly disclosed in any documentation found
- **Timelock: No evidence found** in documentation, blog posts, or on-chain
- Admin powers: Standard Solana program upgrade authority (can modify entire program binary)
- No public constraints documented beyond the multisig requirement
- With protocol transitioning to Bullet, governance over remaining Zeta infrastructure is even less transparent

### 2. Oracle & Price Feeds -- MEDIUM

- Primary: Pyth Network (per-slot updates on Solana)
- Fallback: Chainlink claimed in earlier documentation, but closed-source prevents verification
- USDC-only collateral reduced oracle manipulation surface during operation
- **Whether admin could swap oracle sources: UNKNOWN** (closed-source)
- DeFiLlama `oracles` field: null (not listed)

### 3. Economic Mechanism -- MEDIUM

- Insurance fund funded by platform fees + 35% of liquidation incentives + initial seed (per docs)
- Permissionless liquidation (anyone can liquidate)
- Liquidator receives 30% of maintenance margin; 35% to insurance fund
- Margin-system enforced withdrawals (blocked if would cause bankruptcy)
- No documented hard withdrawal caps
- All of this is moot with $0 TVL -- no economic activity exists

### 4. Smart Contract Security -- HIGH

- **DeFiLlama audits: 0** -- no formal audit reports found on DeFiLlama or elsewhere
- CertiK Skynet score: 68.10 / BB rating (moderate, unchanged from previous report)
- CertiK notes: "Not Audited By CertiK", no third-party audits listed
- **Core Solana program is CLOSED-SOURCE**
- Only SDKs (zeta-sdk), indexers, and market-maker tools are open on GitHub
- Bug bounty: No Immunefi listing found for Zeta Markets (ZetaChain is a different project)
- "Global Bounty Program" previously existed but scope and payout unclear, no public details remain
- No known exploits before the voluntary shutdown

### 5. Operational Security -- HIGH

**Team & Track Record:**
- Tristan Frizza: Founder, publicly doxxed, LinkedIn profile active, multiple podcast appearances (Solana, Lightspeed, Blockworks)
- Team previously built Zeta Markets from ~2022, raised venture funding (Crunchbase listing exists)
- No past security incidents under their management
- Team has migrated focus to Bullet network

**Protocol Status (April 2026):**
- Zeta Markets website (zeta.markets) still displays a DEX frontend showing cumulative stats: 628M trades, $8B volume, $25B total OI
- These are cumulative/historical numbers, not current activity
- DeFiLlama reports $0 TVL consistently since mid-2025
- Protocol officially discontinued May 2025; team pivoted to Bullet
- Bullet mainnet launched February 12, 2026 for perpetual futures trading
- Bullet positions itself as a "network extension" on Solana (L2-like), not a direct continuation of Zeta's architecture
- ZEX token migrating 1:1 to BULLET token

**Off-Chain Security:**
- No SOC 2 Type II or ISO 27001 certification found
- No published key management policy (HSM, MPC, key ceremony)
- No disclosed penetration testing
- Anonymous multisig signers (beyond Tristan Frizza being publicly known as founder)

## Critical Risks

1. **TVL = $0 / Protocol Defunct**: No user funds should remain in Zeta Markets contracts. Any residual funds face governance risk from an opaque multisig.
2. **Closed-Source Contracts**: Core Solana program is not open source. Impossible to verify security claims about liquidation logic, oracle integration, or admin capabilities.
3. **Zero Audits**: No formal audit has ever been published or listed on DeFiLlama or CertiK for Zeta Markets.
4. **Token Migration Risk**: ZEX holders (with 63%+ concentrated in two addresses) are dependent on the Bullet team executing a 1:1 migration to an even newer, less battle-tested system.
5. **Unknown Multisig Configuration**: Threshold, signer count, and signer identities for the Squads multisig remain undisclosed.

## Peer Comparison

| Feature | Zeta Markets | Drift (Solana Perps) | Jupiter Perps (Solana) |
|---------|-------------|---------------------|----------------------|
| TVL | $0 | ~$6.4M (Drift Trade) | ~$701M |
| Timelock | None found | Documented | Unknown |
| Multisig | Squads (config unknown) | Squads (disclosed) | Unknown |
| DeFiLlama Audits | 0 | 2 | 0 |
| Oracle | Pyth (+ Chainlink claimed) | Pyth + Switchboard | Pyth |
| Insurance/TVL | N/A | Disclosed | Disclosed |
| Open Source | Closed (SDKs only) | Open | Partial |
| CertiK Score | 68.10 / BB | Higher | N/A |
| Status | Defunct (migrating to Bullet) | Active | Active |

## Recommendations

1. **Do not deposit new funds** into Zeta Markets contracts. The protocol has $0 TVL and is discontinued.
2. **If holding ZEX tokens**: Research Bullet network independently before converting. Bullet is a new, early-stage project with its own risk profile that this audit does not cover.
3. **Monitor Bullet**: The Bullet mainnet launched Feb 2026. A separate security audit of Bullet would be appropriate before using it.
4. **Withdraw any residual funds** from Zeta Markets contracts immediately if any remain.
5. **ZEX token holders** should be aware of extreme holder concentration (43.45% + 20% in top 2 addresses), which creates significant price manipulation and governance risk.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock -- USDC-only, but **no timelock found** (MEDIUM)
- [?] Admin can change oracle sources arbitrarily -- **UNKNOWN, closed-source** (HIGH)
- [?] Admin can modify withdrawal limits -- Likely via program upgrade, **no timelock** (HIGH)
- [?] Multisig has low threshold -- **UNKNOWN, not publicly disclosed** (HIGH)
- [x] Zero or short timelock -- **No evidence of any timelock** (CRITICAL)
- [ ] Pre-signed transaction risk -- Not assessed (protocol defunct)
- [x] Social engineering surface area -- Unknown signer identities beyond founder (HIGH)

**5/7 flags rated HIGH or above** -- TRIGGER WARNING: Matches Drift-type governance attack pattern. While the protocol is defunct and has $0 TVL (reducing practical exploit risk), the architectural deficiencies are significant.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted -- USDC-only (LOW)
- [ ] Single oracle source without TWAP -- Pyth has sub-second updates (MEDIUM)
- [?] No circuit breaker on price movements -- UNKNOWN (closed-source)
- [?] Insufficient insurance fund relative to TVL -- N/A (TVL = $0)

**1/4 flags -- below trigger threshold.**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency -- No bridge dependency (single-chain)
- [?] Admin keys in hot wallets -- UNKNOWN
- [?] No key rotation policy -- UNKNOWN

**0/3 confirmed flags -- below trigger threshold.**

### Beanstalk-type (Flash Loan Governance Attack):
- Not applicable -- no on-chain governance voting mechanism.

### Cream/bZx-type (Reentrancy + Flash Loan):
- Not applicable -- Solana architecture does not support reentrancy in the same way as EVM.

### Curve-type (Compiler / Language Bug):
- [?] Uses Rust/Anchor (standard for Solana) -- LOW risk
- [?] Compiler version unknown -- closed-source prevents verification

**Below trigger threshold.**

### UST/LUNA-type (Algorithmic Depeg Cascade):
- Not applicable -- no stablecoin mechanism.

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- Not applicable -- single-chain protocol with no bridge dependencies.

## Information Gaps

- **Multisig threshold and signer identities** -- UNKNOWN. Squads multisig confirmed via ecosystem docs but configuration never publicly disclosed.
- **Whether admin could override oracle sources** -- UNKNOWN. Closed-source prevents verification.
- **Timelock configuration** -- No evidence found. Likely absent.
- **Full admin key capability scope** -- Closed-source prevents verification. Standard Solana program upgrade authority allows complete program replacement.
- **Insurance fund actual balance** -- UNKNOWN. With $0 TVL, likely drained or returned.
- **Zeta Markets program ID** -- Not confirmed via on-chain check. Attempts to verify upgrade authority failed (RPC error).
- **Bullet migration timeline and mechanics** -- 1:1 ZEX-to-BULLET conversion announced, but exact timeline, snapshot date, and conversion mechanism unclear.
- **Status of Zeta Markets contracts on-chain** -- Whether programs are frozen, still upgradeable, or in any transitional state is unknown.
- **Who controls the 43.45% ZEX token holding address** -- Could be team treasury, vesting contract, or exchange. Not labeled on RugCheck.

## Disclaimer

This analysis is based on publicly available information and web research as of April 20, 2026. It is NOT a formal smart contract audit. The protocol is effectively defunct with $0 TVL, transitioning to a new project (Bullet). Always DYOR and consider professional auditing services for investment decisions. This report does NOT constitute an audit of the Bullet network, which would require a separate assessment.
