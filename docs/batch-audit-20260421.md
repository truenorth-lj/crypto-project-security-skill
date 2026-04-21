# Batch Audit Report -- 2026-04-21: DeFiLlama Top-100 Gap Fill

**Scope:** 15 uncovered DeFi protocols from the DeFiLlama top 100 by TVL, grouped by category. CEX and canonical L2 bridges were excluded from scope.

**Method:** Sequential application of the `defi-security-audit` skill (v1.2.0). No parallelization. Each audit completed all 9 workflow steps (triage, governance, oracle, economic mechanism, smart contract security, cross-chain, operational, on-chain verification, hack pattern matching).

**Result:** 1 LOW | 9 MEDIUM | 5 HIGH | 0 CRITICAL

---

## Summary Table

| # | Protocol | Category | TVL | Rating | Report |
|---|----------|----------|-----|--------|--------|
| 1 | BlackRock BUIDL | RWA/Treasuries | $3.04B | **HIGH** | [Report](examples/blackrock-buidl-rwa.md) |
| 2 | Sanctum Validator LSTs | Liquid Staking | $1.15B | **HIGH** | [Report](examples/sanctum-validator-lsts.md) |
| 3 | Concrete | Capital Allocator | $1.04B | **HIGH** | [Report](examples/concrete-allocator.md) |
| 4 | Jupiter Lend | Lending | $0.88B | **HIGH** | [Report](examples/jupiter-lend.md) |
| 5 | Jupiter Perpetual | Perps | $0.70B | **HIGH** | [Report](examples/jupiter-perpetual.md) |
| 6 | Binance staked ETH (WBETH) | Liquid Staking | $8.52B | MEDIUM | [Report](examples/binance-staked-eth-lsd.md) |
| 7 | USDT0 | Bridge/Stablecoin | $3.79B | MEDIUM | [Report](examples/usdt0-bridge.md) |
| 8 | Steakhouse Financial | Risk Curator | $1.72B | MEDIUM | [Report](examples/steakhouse-financial.md) |
| 9 | Jito Liquid Staking | Liquid Staking | $0.94B | MEDIUM | [Report](examples/jito-liquid-staking.md) |
| 10 | StakeWise V2 | Liquid Staking | $0.90B | MEDIUM | [Report](examples/stakewise-v2-staking.md) |
| 11 | Liquid Collective | Liquid Staking | $0.81B | MEDIUM | [Report](examples/liquid-collective-staking.md) |
| 12 | Lombard LBTC | BTC Restaking | $0.77B | MEDIUM | [Report](examples/lombard-lbtc.md) |
| 13 | Kinetiq kHYPE | Liquid Staking | $0.76B | MEDIUM | [Report](examples/kinetiq-khype.md) |
| 14 | Lista Lending | Lending | $0.56B | MEDIUM | [Report](examples/lista-lending.md) |
| 15 | Spark Savings | Yield/CDP | $1.70B | **LOW** | [Report](examples/spark-savings.md) |

## Key Themes Observed Across the Batch

### 1. DeFiLlama audit-registry gap

Four of the 15 protocols (Sanctum, Jupiter Lend, Kinetiq, Jupiter Perp) show `audits: "0"` on DeFiLlama despite having real audits in existence. This is a systemic transparency problem: automated risk dashboards under-count true audit coverage, and teams do not submit reports to DeFiLlama's registry. Users relying on quick-scan tools will misprice risk.

### 2. Opaque multisig thresholds remain industry-wide

Across all 15 protocols, multisig threshold (N/M) is UNVERIFIED from public sources in most cases. On-chain verification sometimes resolves this (USDT0 confirmed 3/5 on Etherscan), but most teams do not document governance authority clearly. This is the single weakest disclosure dimension.

### 3. Short timelocks on high-TVL protocols

Lombard LBTC operates with a 1-hour upgrade timelock on a $770M protocol. Industry standard is 24-48 hours, and best-in-class (Lido, Sky, Aave) is 4-12 days. A 1-hour window is effectively no human-response buffer if a malicious upgrade is proposed.

### 4. New Solana lending at scale with audit-coverage gap

Jupiter Lend ($0.88B) has the most audits of any new Solana lender (OtterSec x2, Offside x3, MixBytes, Zenith, Code4rena, Certora FV) but its public surface (documentation, DeFiLlama registry) makes it look under-audited. This information asymmetry is itself a risk signal.

### 5. 250x perps with 0% insurance fund

Jupiter Perpetual offers leverage up to 250x against a pool that has no dedicated insurance fund, while a 2023 OtterSec HIGH-severity keeper finding has no public remediation record. At 250x, a 0.4% adverse move wipes a position; even if the keeper finding is resolved, the leverage-to-backstop ratio is structurally aggressive.

### 6. RWA audit publication falls short of DeFi norms

BlackRock BUIDL has no public audit report published for a $3B+ tokenized US Treasury product. Peers in the same category (Ondo with 20+ audits, Circle USYC with public reviews) publish more. Regulatory recourse via the SEC-registered transfer agent (Securitize) partially compensates, but institutional brand does not substitute for public security disclosure.

### 7. CEX-operated LSDs are structurally centralized

Binance staked ETH (WBETH) matches 5-6 of 7 Drift-type governance red flags -- not because Binance is malicious, but because any CEX-operated LSD is by design single-entity-controlled. Users should understand WBETH is custodial, not trust-minimized.

### 8. Risk curators face real loss events

Steakhouse Financial demonstrated in March 2026 (Resolv USR depeg) that "reputable curator" status does not prevent depositor losses. Curator allocator power (instant reallocation authority without depositor consent) is a real attack surface, and market-selection error produced actual user harm.

---

## Methodology Notes

- Protocols were selected by TVL rank (top 100 on DeFiLlama as of 2026-04-21) minus already-covered protocols, CEX listings, and canonical L2 bridges.
- Each report follows the template in `SKILL.md` Step 9: Overview, Quantitative Metrics, Risk Summary with Overall Rating, Detailed Findings, Hack Pattern Check, Information Gaps, Audit Date, Disclaimer.
- Risk ratings use the repo's 4-level scale: LOW / MEDIUM / HIGH / CRITICAL. Ratings reflect the mechanical triage score plus qualitative judgment calibrated against existing audits.
- Unverified claims are marked UNVERIFIED. Absence of public information is treated as a risk signal.

**Disclaimer:** These are research-based security assessments, not formal smart contract audits. Findings reflect public information available as of 2026-04-21. Always DYOR.
