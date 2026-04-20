# Batch Security Audit: Top Perp Exchanges + DeFi Protocols

**Date:** 2026-04-20
**Scope:** All major perpetual DEX exchanges (CoinGecko top 10 by OI + DeFiLlama top by TVL) + 10 high-TVL DeFi protocols not previously covered + re-audit of 7 existing perp reports
**Total audits:** 30 protocols (23 new + 7 re-runs)
**Methodology:** [DeFi Security Audit Skill](../SKILL.md) -- governance-first framework with GoPlus token scanning, DeFiLlama data, on-chain verification, and 8-category hack pattern matching

---

## Executive Summary

This batch audit covered the top perpetual DEX exchanges by open interest and filled gaps in our coverage of DeFiLlama's top DeFi protocols. The results reveal a stark security divide:

- **Perp exchanges are significantly riskier than DeFi lending/staking protocols.** Only 1 of 10 perp exchanges (Synthetix) scored MEDIUM risk. The rest were HIGH or CRITICAL.
- **Governance opacity is the dominant failure pattern** across perp DEXs. Most operate as centralized exchanges with on-chain settlement but without the governance transparency that top DeFi protocols have built over years.
- **3 protocols rated CRITICAL:** Resolv (exploited, paused), Vertex (shut down), Paradex (can drain all funds instantly).
- **The Kelp hack (April 18, 2026)** was only 2 days before this audit. Several protocols audited here share similar bridge architecture risks.

### Risk Distribution (20 new protocols)

| Risk Level | Count | Protocols |
|------------|-------|-----------|
| **CRITICAL** | 7 | Resolv, Vertex, Paradex, Variational Omni, Antarctic, Drift (post-hack), Zeta Markets |
| **HIGH** | 14 | Hyperliquid, Aster, edgeX, Lighter, GRVT, Extended, ApeX Omni, Ostium, StandX, GMX, Gains Network, Raydium, Usual, Infrared |
| **MEDIUM** | 9 | Synthetix, Jupiter, dYdX, Fluid, Aerodrome, mETH, Circle USYC, Spiko, Spark Liquidity Layer |
| **LOW** | 0 | -- |

**Zero protocols scored LOW.** This is notable -- our existing 56-protocol corpus has 7 LOW-risk protocols (Aave, Lido, Morpho, Sky, Uniswap, SparkLend, Compound). The absence of LOW-risk results in this batch reflects the fact that most mature, well-governed protocols were already covered.

**Key rating changes from re-runs:**
- Hyperliquid: MEDIUM -> **HIGH** (CoreWriter godmode, off-chain security gaps)
- GMX: MEDIUM -> **HIGH** (GoPlus flags properly scored, Kelp-type bridge risk)
- Gains Network: MEDIUM -> **HIGH** (GoPlus hidden_owner, bug bounty halved)
- Zeta Markets: HIGH -> **CRITICAL** (confirmed defunct, triage 18->12)
- Drift: CRITICAL -> **CRITICAL** (post-hack report; pre-hack predictions validated 7/7)

---

## Perp Exchange Rankings: CoinGecko OI vs DeFiLlama TVL

Rankings differ significantly between open interest (CoinGecko) and TVL (DeFiLlama). Both are shown for reference.

| # (OI) | # (TVL) | Protocol | CoinGecko OI (BTC) | DeFiLlama TVL | Risk | Audit Date |
|---------|---------|----------|-------------------|---------------|------|------------|
| 1 | 1 | [Hyperliquid](examples/hyperliquid-perps.md) | 100,119 | $4,867M | **HIGH** | 2026-04-20 |
| -- | 2 | [Jupiter](examples/jupiter-solana-dex.md) | -- | $2,998M | **MEDIUM** | 2026-04-20 |
| 2 | 3 | [Aster](examples/aster-perps.md) | 26,166 | $1,142M | **HIGH** | 2026-04-20 |
| 4 | 4 | [Lighter](examples/lighter-perps.md) | 9,611 | $508M | **HIGH** | 2026-04-20 |
| 13 | 5 | [GMX](examples/gmx-derivatives.md) | 971 | $346M | **HIGH** | 2026-04-20 |
| -- | 6 | [Drift](examples/drift-protocol-post-hack-20260420.md) | -- | $242M | **CRITICAL** | 2026-04-20 |
| 3 | 7 | [edgeX](examples/edgex-perps.md) | 12,112 | $191M | **HIGH** | 2026-04-20 |
| 9 | 8 | [Extended](examples/extended-perps.md) | 4,357 | $175M | **HIGH** | 2026-04-20 |
| 14 | 9 | [dYdX](examples/dydx-derivatives.md) | 683 | $146M | **MEDIUM** | 2026-04-20 |
| 6 | 10 | [GRVT](examples/grvt-perps.md) | 6,367 | $65M | **HIGH** | 2026-04-20 |
| 9 | 11 | [Ostium](examples/ostium-perps.md) | 1,933 | $60M | **HIGH** | 2026-04-20 |
| 10 | 12 | [StandX](examples/standx-perps.md) | 1,797 | $52M | **HIGH** | 2026-04-20 |
| 17 | 13 | [Paradex](examples/paradex-perps.md) | 457 | $47M | **CRITICAL** | 2026-04-20 |
| -- | 14 | [Synthetix](examples/synthetix-perps.md) | -- | $38M | **MEDIUM** | 2026-04-20 |
| 11 | 15 | [ApeX Omni](examples/apex-omni-perps.md) | 1,680 | $37M | **HIGH** | 2026-04-20 |
| 20 | 16 | [Gains Network](examples/gains-network-perps.md) | 206 | $28M | **HIGH** | 2026-04-20 |
| 8 | 17 | [Antarctic](examples/antarctic-perps.md) | 3,676 | $10M | **CRITICAL** | 2026-04-20 |
| 5 | 18 | [Variational Omni](examples/variational-omni-perps.md) | 8,170 | $0 | **CRITICAL** | 2026-04-20 |
| -- | 19 | [Vertex](examples/vertex-perps.md) | -- | $0 (defunct) | **CRITICAL** | 2026-04-20 |
| -- | 20 | [Zeta Markets](examples/zeta-markets-tail-protocol.md) | -- | $0 (defunct) | **CRITICAL** | 2026-04-20 |

**Key insight:** OI and TVL rankings diverge sharply. Variational Omni ranks #5 by OI but has $0 TVL (off-chain model). Jupiter and Drift don't appear in CoinGecko's perp OI rankings but are #2 and #6 by TVL. GMX ranks #13 by OI but #5 by TVL.

### Perp Exchange Key Themes

**1. Governance is the #1 risk across all perp DEXs.**
Every single perp exchange (except Synthetix) scored HIGH or CRITICAL on governance. Common patterns:
- No publicly disclosed multisig configuration (edgeX, Ostium, ApeX, Aster)
- Zero timelock on admin actions (GRVT, Paradex, Lighter bypass)
- Undisclosed or anonymous multisig signers (all except Extended, Synthetix)

**2. The "DEX" label is misleading.**
Most perp "DEXs" are functionally centralized exchanges with on-chain settlement. They run centralized sequencers/matching engines, control oracle feeds, and can unilaterally upgrade contracts. Users have limited recourse if the operator acts maliciously.

**3. Drift-type attack pattern is widespread.**
7 of 10 perp exchanges triggered the Drift-type hack pattern warning (3+ of 7 indicators). This is the governance + oracle + social engineering attack vector that enabled the $285M Drift hack.

**4. Bug bounty programs are inadequate or absent.**
Only 3 of 10 have meaningful bug bounty programs (Synthetix via Immunefi, Paradex $500K, Lighter has none despite $500M TVL). For comparison, Aave offers $15.5M and GMX offers $5M.

---

## DeFi Protocol Audits

### Overview

These 10 protocols fill gaps in our coverage of DeFiLlama's top protocols by TVL and emerging DeFi categories.

| # | Protocol | Triage | Risk | TVL | Type | Key Finding | Audit Date |
|---|----------|--------|------|-----|------|-------------|------------|
| 1 | [Spark Liquidity Layer](examples/spark-liquidity-layer.md) | 69 | **MEDIUM** | $2.0B | Capital Allocator | Sky DAO governance; $5M bounty; relayer opacity | 2026-04-20 |
| 2 | [Fluid](examples/fluid-lending-dex.md) | 64 | **MEDIUM** | $476M | Lending/DEX | 7+ audits; zero exploits in 7yr; multisig undisclosed | 2026-04-20 |
| 3 | [mETH (Mantle)](examples/mantle-meth-staking.md) | 54 | **MEDIUM** | $1.3B | Liquid Staking | 16 audits from 8 firms; zero timelock on upgrades | 2026-04-20 |
| 4 | [Aerodrome](examples/aerodrome-dex.md) | 54 | **MEDIUM** | $1B+ | DEX | Immutable core; stale audits (2023); DNS hijack Nov 2025 | 2026-04-20 |
| 5 | [Circle USYC](examples/circle-usyc-rwa.md) | 52 | **MEDIUM** | $2.9B | RWA | Circle/DRW backed; no public audit report | 2026-04-20 |
| 6 | [Infrared](examples/infrared-berachain.md) | 44 | **HIGH** | $52M | PoL/Staking | 24 audits but governance opaque; TVL -97% | 2026-04-20 |
| 7 | [Spiko](examples/spiko-rwa.md) | 41 | **MEDIUM** | $1.2B | RWA | AMF regulated; Amundi partner; stale audits | 2026-04-20 |
| 8 | [Usual](examples/usual-stablecoin.md) | 41 | **HIGH** | $101M | Stablecoin | USD0++ depegged; TVL -94.6%; 75.8% token concentration | 2026-04-20 |
| 9 | [Raydium](examples/raydium-dex.md) | 34 | **HIGH** | $1B+ | DEX | Upgrade auth appears EOA; zero timelock; 2022 hack | 2026-04-20 |
| 10 | [Resolv](examples/resolv-stablecoin.md) | 16 | **CRITICAL** | $57.6M | Stablecoin | Exploited March 2026 ($25M); protocol paused | 2026-04-20 |

### DeFi Protocol Key Themes

**1. RWA protocols share structural governance opacity.**
Circle USYC and Spiko both scored MEDIUM but with low data confidence. Their centralized governance is a feature of the regulated RWA model, not a bug -- but it means users must trust the operating entity rather than on-chain verification.

**2. Audit quantity does not equal safety.**
Infrared (24 audits) and mETH (16 audits) demonstrate that even extensive audit coverage cannot compensate for governance transparency gaps. Both lack disclosed timelock configurations despite managing hundreds of millions in TVL.

**3. Stablecoin depegs are governance failures, not technical bugs.**
Both Usual (USD0++ depeg) and Resolv ($25M exploit) failed due to governance/operational issues, not smart contract vulnerabilities. Usual's depeg was caused by a unilateral team decision to change redemption rules. Resolv's exploit was an AWS KMS key compromise.

**4. Downstream composability creates systemic risk.**
Resolv's exploit created $10M+ in cascading bad debt on Morpho and Fluid -- the same Kelp-type pattern where unbacked tokens are deposited as lending collateral. Fluid was also affected by the Kelp rsETH exploit 2 days ago.

---

## Cross-Cutting Analysis

### Governance Maturity Spectrum

Across all 76 protocols now audited, a clear maturity spectrum emerges:

| Tier | Characteristics | Examples |
|------|----------------|----------|
| **Gold Standard** | On-chain DAO + 48h+ timelock + doxxed multisig + $5M+ bounty | Aave, Uniswap, Sky |
| **Mature** | Multisig + timelock + multiple audits + active bounty | Morpho, Compound, SparkLend |
| **Developing** | Multisig exists but gaps (no timelock, undisclosed signers) | Synthetix, Fluid, mETH, Aerodrome |
| **Opaque** | Governance claims unverifiable from public data | Ostium, edgeX, GRVT, ApeX, Aster |
| **Dangerous** | Provably weak governance (low threshold, zero timelock) | Paradex, Lighter bypass, Raydium |
| **Failed/Defunct** | Exploited, shut down, or abandoned | Resolv, Vertex, Drift, Notional |

### Hack Pattern Prevalence

| Pattern | Triggered (this batch) | Most Common In |
|---------|----------------------|----------------|
| Drift-type (Governance) | 14/20 (70%) | Perp exchanges |
| Kelp-type (Bridge Cascade) | 5/20 (25%) | Cross-chain protocols |
| Euler/Mango-type (Oracle) | 4/20 (20%) | Lending, stablecoins |
| Ronin-type (Key Compromise) | 3/20 (15%) | Bridge-dependent |
| UST/LUNA-type (Depeg) | 2/20 (10%) | Stablecoins |

The Drift-type governance attack pattern is by far the most prevalent risk in the current DeFi landscape. This is consistent with the thesis behind this skill: **governance architecture, not smart contract bugs, is the primary attack surface in modern DeFi.**

### Recommendations for Users

1. **Avoid CRITICAL-rated protocols entirely.** Resolv is paused, Vertex is shut down, and Paradex has provably dangerous admin controls.
2. **Treat perp DEX deposits as high-risk.** Only Synthetix and the previously-audited Hyperliquid/dYdX/GMX have meaningful governance controls.
3. **Check timelocks, not just audits.** mETH has 16 audits but zero timelock. Infrared has 24 audits but opaque governance. Audits protect against code bugs; timelocks protect against key compromise.
4. **Monitor bridge-dependent protocols closely.** The Kelp hack (April 18, 2026) demonstrated that bridge exploits cascade into lending protocols via collateral deposits.
5. **Demand governance transparency.** If a protocol cannot publicly disclose its multisig address, threshold, and timelock configuration, that absence is itself a risk signal.

---

## Updated Portfolio Totals

After this batch (including re-runs and 3 additional perp exchanges), the skill has audited **79 protocols** with the following distribution:

| Risk | Count | % |
|------|-------|---|
| LOW | 7 | 8.9% |
| MEDIUM | 38 | 48.1% |
| HIGH | 22 | 27.8% |
| CRITICAL | 12 | 15.2% |

### Complete Perp Exchange Coverage (20 protocols)

All major perpetual DEX exchanges are now covered, ranked by DeFiLlama TVL:

| # | Protocol | TVL | OI Rank | Risk | Triage | Audit Date |
|---|----------|-----|---------|------|--------|------------|
| 1 | [Hyperliquid](examples/hyperliquid-perps.md) | $4,867M | #1 | **HIGH** | 55 | 2026-04-20 |
| 2 | [Jupiter](examples/jupiter-solana-dex.md) | $2,998M | -- | **MEDIUM** | 62 | 2026-04-20 |
| 3 | [Aster](examples/aster-perps.md) | $1,142M | #2 | **HIGH** | 22 | 2026-04-20 |
| 4 | [Lighter](examples/lighter-perps.md) | $508M | #4 | **HIGH** | 34 | 2026-04-20 |
| 5 | [GMX](examples/gmx-derivatives.md) | $346M | #13 | **HIGH** | 4 | 2026-04-20 |
| 6 | [Drift](examples/drift-protocol-post-hack-20260420.md) | $242M | -- | **CRITICAL** | 13 | 2026-04-20 |
| 7 | [edgeX](examples/edgex-perps.md) | $191M | #3 | **HIGH** | 42 | 2026-04-20 |
| 8 | [Extended](examples/extended-perps.md) | $175M | #9 | **HIGH** | 32 | 2026-04-20 |
| 9 | [dYdX](examples/dydx-derivatives.md) | $146M | #14 | **MEDIUM** | 62 | 2026-04-20 |
| 10 | [GRVT](examples/grvt-perps.md) | $65M | #6 | **HIGH** | 21 | 2026-04-20 |
| 11 | [Ostium](examples/ostium-perps.md) | $60M | #9 | **HIGH** | 36 | 2026-04-20 |
| 12 | [StandX](examples/standx-perps.md) | $52M | #10 | **HIGH** | 9 | 2026-04-20 |
| 13 | [Paradex](examples/paradex-perps.md) | $47M | #17 | **CRITICAL** | 22 | 2026-04-20 |
| 14 | [Synthetix](examples/synthetix-perps.md) | $38M | -- | **MEDIUM** | 67 | 2026-04-20 |
| 15 | [ApeX Omni](examples/apex-omni-perps.md) | $37M | #11 | **HIGH** | 24 | 2026-04-20 |
| 16 | [Gains Network](examples/gains-network-perps.md) | $28M | #20 | **HIGH** | 19 | 2026-04-20 |
| 17 | [Antarctic](examples/antarctic-perps.md) | $10M | #8 | **CRITICAL** | 0 | 2026-04-20 |
| 18 | [Variational Omni](examples/variational-omni-perps.md) | $0 | #5 | **CRITICAL** | 0 | 2026-04-20 |
| 19 | [Vertex](examples/vertex-perps.md) | $0 | -- | **CRITICAL** | 19 | 2026-04-20 |
| 20 | [Zeta Markets](examples/zeta-markets-tail-protocol.md) | $0 | -- | **CRITICAL** | 12 | 2026-04-20 |

**Full index:** [audit-reports.md](audit-reports.md)

---

## Disclaimer

These analyses are research-based security assessments, not formal smart contract audits. They reflect publicly available information as of 2026-04-20. DeFi protocols change frequently -- governance parameters, TVL, and security posture can shift rapidly. Always DYOR and consider professional auditing services for investment decisions.
