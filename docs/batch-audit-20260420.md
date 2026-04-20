# Batch Security Audit: Top Perp Exchanges + DeFi Protocols

**Date:** 2026-04-20
**Scope:** Top 10 perpetual DEX exchanges by open interest + 10 high-TVL DeFi protocols not previously covered
**Total new audits:** 20 protocols
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
| **CRITICAL** | 3 | Resolv, Vertex, Paradex |
| **HIGH** | 10 | Aster, edgeX, Lighter, GRVT, Extended, ApeX Omni, Ostium, Raydium, Usual, Infrared |
| **MEDIUM** | 7 | Synthetix, Fluid, Aerodrome, mETH, Circle USYC, Spiko, Spark Liquidity Layer |
| **LOW** | 0 | -- |

**Zero protocols scored LOW.** This is notable -- our existing 56-protocol corpus has 7 LOW-risk protocols (Aave, Lido, Morpho, Sky, Uniswap, SparkLend, Compound). The absence of LOW-risk results in this batch reflects the fact that most mature, well-governed protocols were already covered.

---

## Perp Exchange Audits

### Overview

Perpetual DEX exchanges were ranked by open interest from CoinGecko data. Previously covered perp protocols (Hyperliquid, Jupiter, GMX, dYdX, Gains Network, Drift, Zeta Markets) were excluded.

| # | Protocol | Triage Score | Risk | OI | Chain | Key Finding |
|---|----------|-------------|------|-----|-------|-------------|
| 1 | [Synthetix Perps](examples/synthetix-perps.md) | 67/100 | **MEDIUM** | -- | Multi | No timelock on pDAO; 4/8 multisig; doxxed founder (Kain Warwick); 7yr track record |
| 2 | [edgeX](examples/edgex-perps.md) | 42/100 | **HIGH** | $903M | Multi | No multisig/timelock disclosed; $10K web-only bug bounty; single Stork oracle |
| 3 | [Ostium](examples/ostium-perps.md) | 36/100 | **HIGH** | $144M | Arbitrum | 6+ audits (best in class) but governance fully opaque; no multisig addresses |
| 4 | [Lighter](examples/lighter-perps.md) | 34/100 | **HIGH** | $720M | Multi | 21d timelock bypassable to 0s by 3/6 multisig; Oct 2025 sequencer outage |
| 5 | [Extended](examples/extended-perps.md) | 32/100 | **HIGH** | $327M | Starknet | Doxxed ex-Revolut team; unverified multisig on Starknet; no bug bounty |
| 6 | [ApeX Omni](examples/apex-omni-perps.md) | 24/100 | **HIGH** | $125M | Multi | Zero governance transparency; 0 DeFiLlama audits; no bug bounty |
| 7 | [Aster](examples/aster-perps.md) | 22/100 | **HIGH** | $1.9B | Multi | Anonymous team; suspected wash trading; DeFiLlama delisted Oct 2025 |
| 8 | [Paradex](examples/paradex-perps.md) | 22/100 | **CRITICAL** | $34M | Starknet | 2/5 multisig + zero timelock; can drain all $46.9M bridged USDC instantly |
| 9 | [GRVT](examples/grvt-perps.md) | 21/100 | **HIGH** | $474M | zkSync | 2/3 multisig + 0s timelock; validium (off-chain DA); no published audits |
| 10 | [Vertex](examples/vertex-perps.md) | 19/100 | **CRITICAL** | $0 | Arbitrum | Shut down Aug 2025; team acquired by Ink Foundation; DAO dissolved |

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

| # | Protocol | Triage Score | Risk | TVL | Type | Key Finding |
|---|----------|-------------|------|-----|------|-------------|
| 1 | [Spark Liquidity Layer](examples/spark-liquidity-layer.md) | 69/100 | **MEDIUM** | $2.0B | Capital Allocator | Sky DAO governance heritage; $5M bounty; off-chain relayer opacity |
| 2 | [Fluid](examples/fluid-lending-dex.md) | 64/100 | **MEDIUM** | $476M | Lending/DEX | 7+ audits; zero exploits in 7yr; governance multisig undisclosed |
| 3 | [mETH (Mantle)](examples/mantle-meth-staking.md) | 54/100 | **MEDIUM** | $1.3B | Liquid Staking | 16 audits from 8 firms (best seen); zero timelock on upgrades |
| 4 | [Aerodrome](examples/aerodrome-dex.md) | 54/100 | **MEDIUM** | $1B+ | DEX | Immutable core contracts; stale audits (all 2023); DNS hijack Nov 2025 |
| 5 | [Circle USYC](examples/circle-usyc-rwa.md) | 52/100 | **MEDIUM** | $2.9B | RWA/Treasuries | Circle/DRW backed; no public audit report; governance opacity (RWA-structural) |
| 6 | [Infrared](examples/infrared-berachain.md) | 44/100 | **HIGH** | $52M | PoL/Staking | 24 audits but governance opaque; TVL collapsed -97% from $1.9B peak |
| 7 | [Spiko](examples/spiko-rwa.md) | 41/100 | **MEDIUM** | $1.2B | RWA/Treasuries | AMF regulated; Amundi partnership; stale Trail of Bits audit (2023) |
| 8 | [Usual](examples/usual-stablecoin.md) | 41/100 | **HIGH** | $101M | Stablecoin | USD0++ depegged to $0.87 (Jan 2025); TVL -94.6%; 75.8% token concentration |
| 9 | [Raydium](examples/raydium-dex.md) | 34/100 | **HIGH** | $1B+ | DEX | Upgrade authority appears EOA on-chain; zero timelock; 2022 key compromise |
| 10 | [Resolv](examples/resolv-stablecoin.md) | 16/100 | **CRITICAL** | $57.6M | Stablecoin | Exploited March 2026 ($25M via AWS KMS compromise); protocol paused |

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

After this batch, the skill has audited **76 protocols** with the following distribution:

| Risk | Count | % |
|------|-------|---|
| LOW | 7 | 9.2% |
| MEDIUM | 42 | 55.3% |
| HIGH | 19 | 25.0% |
| CRITICAL | 8 | 10.5% |

**Full index:** [audit-reports.md](audit-reports.md)

---

## Disclaimer

These analyses are research-based security assessments, not formal smart contract audits. They reflect publicly available information as of 2026-04-20. DeFi protocols change frequently -- governance parameters, TVL, and security posture can shift rapidly. Always DYOR and consider professional auditing services for investment decisions.
