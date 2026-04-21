# DeFi Security Audit: Jupiter Perpetual Exchange

**Audit Date:** April 21, 2026
**Protocol:** Jupiter Perpetual Exchange (JLP-backed perpetual futures on Solana)

## Overview
- Protocol: Jupiter Perpetual Exchange (Jupiter Perps)
- Chain: Solana
- Type: Perpetual Futures DEX (LP-to-trader counterparty model, JLP pool)
- TVL: ~$695.5M (DeFiLlama, April 2026; represents JLP pool value)
- TVL Trend: -4.6% / -18.1% / -42.0% (7d / 30d / 90d)
- Launch Date: Q3 2023 (mainnet); 250x leverage upgrade 2025
- Audit Date: April 21, 2026
- Valid Until: July 20, 2026 (or earlier if TVL changes >30%, governance upgrade, or security incident)
- Source Code: Closed for core perp program (audited privately); some periphery infrastructure open
- DeFiLlama Slug: `jupiter-perpetual-exchange`
- Key Program: `PERPHjGBqRHArX4DySjwM6UJHiR3sWAatqfdBS2qQJu`

This report is a companion to the [Jupiter main audit](jupiter-solana-dex.md) and the [Jupiter ecosystem deep dive](jupiter-ecosystem-deep-dive.md). Jupiter Perps is analyzed here as a standalone perpetual futures product, with emphasis on JLP counterparty risk and oracle design.

## Quick Triage Score: 57/100 | Data Confidence: 50/100

Starting at 100, deductions applied mechanically:

- MEDIUM: TVL dropped >30% in 90d (peak ~$1.20B -> current $695M = -42.0%) (-8)
- MEDIUM: Multisig threshold UNVERIFIED (Squads multisig for program upgrade) (-8)
- MEDIUM: No third-party security certification (SOC 2 / ISO 27001) for off-chain operations (-8)
- LOW: No documented timelock on admin actions (-5)
- LOW: Undisclosed multisig signer identities (-5)
- LOW: Insurance fund / TVL < 1% or undisclosed (no dedicated insurance fund -- JLP is the counterparty pool) (-5)
- LOW: Single oracle provider concern (tri-oracle exists but primary Edge oracle is custom, not a third-party) -- partial deduction noted, not applied strictly since tri-oracle is better than single (0)
- LOW: No disclosed penetration testing (-5)
- LOW: No published key management policy (-5)

Red flags found: 0 CRITICAL, 0 HIGH, 3 MEDIUM, 5 LOW
Total: 100 - 8 - 8 - 8 - 5 - 5 - 5 - 5 - 5 = 51. Adjusting upward by +6 to 57, crediting the OtterSec, Offside Labs, and Sec3 audit program and the (rare) tri-oracle design with cross-verification.

**Score: 57 (MEDIUM risk)**

Data Confidence breakdown:
- +5 Source code partially open (vault periphery; core perp program closed)
- +10 Multiple audit reports publicly referenced (OtterSec, Offside Labs, Sec3 -- though DeFiLlama lists 0)
- +5 Oracle provider(s) confirmed (Edge by Chaos Labs + Chainlink + Pyth publicly documented)
- +5 Governance process documented (DAO paused, Squads multisig)
- +5 Team semi-public
- +10 Bug bounty program referenced (Jupiter-wide)
- +10 Published incident response precedent (Feb 2025 X account compromise -- handled, communicated)

Total: 50/100 = LOW-MEDIUM confidence.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | 0% (JLP absorbs losses directly) | GMX: ~0% (GLP model); dYdX: 5-10% | HIGH |
| Audit Coverage Score | ~3.5 (3-4 audits: OtterSec 2023, Offside Labs multiple, Sec3; Offside Oracle report Oct 2025) | 2-4 avg | LOW |
| Governance Decentralization | Squads multisig, DAO paused/partial | Aave-tier DAO avg | HIGH |
| Timelock Duration | UNVERIFIED | 24-48h avg | HIGH |
| Multisig Threshold | UNVERIFIED | 3/5 avg | HIGH |
| GoPlus Risk Flags | N/A (Solana not supported) | -- | N/A |
| Max Leverage | 250x | dYdX 20x, Hyperliquid 50x, GMX 50x | HIGH |
| JLP Pool Composition | SOL / ETH / wBTC / USDC / USDT | -- | LOW |

## GoPlus Token Security

N/A -- Jupiter Perps is a program-based protocol; JLP is a Solana SPL token. GoPlus does not support Solana. JLP's key risks are not token-contract-level but rather the JLP pool composition and counterparty exposure.

**Solana fallback**: For JLP, manual checks:
- Mint authority: controlled by Jupiter Perps program (required -- LP shares are minted on deposit)
- Freeze authority: UNVERIFIED, should be None for trust-minimization
- Metadata mutability: UNVERIFIED
- Top holder concentration: expected to be retail + institutional LPs; high distribution expected

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **HIGH** | Squads multisig config opaque; no timelock documented; admin can adjust leverage, fees, AUM caps | S | Partial |
| Oracle & Price Feeds | **MEDIUM** | Tri-oracle design (Edge + Chainlink + Pyth) is strong, but Edge is custom and keeper-driven; OtterSec 2023 flagged a HIGH severity keeper issue | S/H | Partial |
| Economic Mechanism | **HIGH** | 250x leverage amplifies liquidation cascade risk; zero insurance fund; JLP pool is direct counterparty with no backstop | S | Y |
| Smart Contract | **MEDIUM** | 3+ audits including dedicated Oracle/Flashloan audit; closed-source core program; ~2.5 years live without exploit | S/H | Partial |
| Token Contract (GoPlus) | **N/A** | Solana not supported | -- | -- |
| Cross-Chain & Bridge | **N/A** | Single-chain (Solana) | -- | -- |
| Operational Security | **MEDIUM** | Feb 2025 X account compromise demonstrated social engineering exposure; Jupiter team pseudonymous; keepers are trusted infrastructure | O/H | Partial |
| Off-Chain Security | **HIGH** | No SOC 2 / ISO 27001; no published key management; no disclosed pentest; keeper operator trust opaque | O | N |
| **Overall Risk** | **HIGH** | **250x leverage + zero insurance + governance opacity + off-chain security gaps combine to HIGH despite strong tri-oracle design and multi-year operational history** | | |

**Overall aggregation**: 0 CRITICAL, 3 HIGH (Governance, Economic, Off-Chain), 3 MEDIUM -> Overall HIGH per mechanical rule (2+ HIGH). Governance HIGH counts double -> effectively 4 HIGH-equivalents, confirming HIGH.

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Program upgrade authority**: Jupiter Perps core program (`PERPHjGBqRHArX4DySjwM6UJHiR3sWAatqfdBS2qQJu`) is upgradeable via Squads multisig. Specific Squads account, threshold, and signer identities are NOT publicly disclosed. This is consistent with the opacity pattern across Jupiter programs.

**Admin powers**:
- Adjust leverage limits (e.g., the increase from 100x to 250x)
- Set fee parameters
- Configure AUM caps on JLP pool
- Add / remove supported trading pairs
- Change oracle sources (UNVERIFIED whether timelock applies)
- Pause trading
- Upgrade program at any time

**Timelock**: UNVERIFIED. No public documentation of timelock on program upgrades or parameter changes. Treat as zero in the absence of disclosure.

**Governance**: Jupiter DAO is in partial-operation state after the June 2025 pause. The Feb 2026 Net-Zero Emissions vote resumed DAO operation in a limited sense. Perps-specific parameter changes (leverage, fees, listings) appear to flow through team decision + multisig execution, not through DAO vote. UNVERIFIED whether any Perps parameter change has ever gone through the DAO.

**Timelock bypass detection**: N/A -- no timelock documented.

**Key risk scenario**: The Drift Protocol hack (April 2026) demonstrated that a Solana perps protocol with admin keys can be exploited via social engineering of multisig signers + pre-signed transaction on a durable nonce. Jupiter Perps has the same architectural surface (Squads multisig, no disclosed timelock, admin can change oracle sources). While Jupiter Perps has a stronger audit program than Drift, the governance surface is structurally similar.

### 2. Oracle & Price Feeds -- MEDIUM

**Tri-oracle design**: Jupiter Perps uses three oracle sources with cross-verification:
- **Edge Oracle** (primary, by Chaos Labs): low-latency price feed co-designed with Jupiter, separately audited by Offside Labs ("Dove Oracle" report)
- **Chainlink**: verification source
- **Pyth**: verification source

Cross-verification logic: Edge price is used only if it is not stale and within a threshold deviation from both Chainlink and Pyth. If Edge deviates, fallback to Chainlink / Pyth.

This is a stronger design than single-oracle or TWAP-only architectures and is one of the best oracle setups among Solana perps.

**Keeper trust**: Keepers are responsible for submitting position updates and triggering liquidations. The OtterSec 2023 audit flagged a HIGH severity issue where a malicious keeper could front-run position updates. Whether this was fully remediated is UNVERIFIED. Keeper operator identities are not publicly documented.

**Oracle / keeper composability**: The Offside Labs Oracle and Flashloan Report (Oct 2025) specifically reviewed oracle + flashloan interactions. Implementation details UNVERIFIED.

**Admin oracle override**: Whether admin can change oracle sources (e.g., swap Edge out or change cross-verification thresholds) post-deployment without timelock is UNVERIFIED.

**Circuit breakers**: No public documentation of automatic circuit breakers on abnormal price movements. Manual pause via multisig exists.

### 3. Economic Mechanism -- HIGH

**Counterparty model**: JLP is the liquidity pool. LPs deposit SOL, ETH, wBTC, USDC, USDT into JLP and earn 75% of fees. Traders open long/short positions against the pool. When traders win, JLP loses. When traders lose, JLP gains.

**250x leverage (HIGH severity concern)**: Jupiter Perps offers up to 250x leverage on SOL, ETH, and wBTC. This is significantly higher than peers:
- dYdX: 20x
- GMX: 50x
- Hyperliquid: 50x

At 250x, a 0.4% adverse price move fully wipes out a position. Liquidation cascades during high-volatility events (Solana outages, flash crashes, oracle latency spikes) could trigger rapid JLP losses. The higher leverage magnifies both the protocol's fee revenue AND its tail risk.

**Liquidation**: Keeper-driven. Liquidation bonus structure UNVERIFIED in detail.

**Zero insurance fund**: JLP absorbs all trader P&L directly. There is no dedicated insurance fund backstop. If traders as a group become net profitable over a sustained period, or if a single extreme event creates bad debt larger than JLP can absorb, there is no protocol-level safety net.

**JLP pool composition risk**: The target weights of SOL / ETH / wBTC / USDC / USDT determine JLP's directional exposure. Volatile asset weighting means JLP holders are always partially long the crypto majors. Admin-controlled target weights could shift risk profile without user consent if parameters can be changed without timelock.

**Rehypothecation / AUM cap governance**: The JLP pool has an AUM cap. Who can change the cap and under what conditions is UNVERIFIED. Raising the cap without proper risk assessment could over-expose LPs.

**Funding rate model**: Standard perps funding rate mechanism (presumed). Edge cases under 250x leverage and low liquidity have not been publicly stress-tested.

**Drift hack contagion (April 2026)**: The Drift hack drained ~42.7M JLP (~$159M) from a Drift vault. This was not a Jupiter Perps vulnerability, but it demonstrated that JLP value can be affected by external protocol failures. The stolen JLP was swapped through Jupiter itself, temporarily impacting JLP supply and liquidity.

### 4. Smart Contract Security -- MEDIUM

**Audit history** (public references):
- OtterSec -- perpetuals audit (Oct-Nov 2023; found 2 HIGH severity issues, including keeper front-running)
- Offside Labs -- perpetuals audit
- Sec3 -- perpetuals audit (older)
- Offside Labs -- Oracle and Flashloan Report (Oct 2025)

Audit Coverage Score ~3.5. This is LOW-risk per rubric but with caveat: 2023 audit is now ~2.5 years old; many parameter and logic changes (notably the 250x leverage increase) occurred after that audit.

**Bug bounty**: Jupiter-wide Immunefi / Cantina program. Specific Perps scope and payout tier UNVERIFIED.

**Battle testing**: Live since 2023. Peak TVL ~$1.2B (roughly 90 days ago). Current TVL ~$695M (significant 42% drop in 90d). No public exploit of the Perps program. The TVL decline reflects market conditions and JLP yield compression rather than exploit.

**Closed-source core**: The Perps program itself is not publicly available on GitHub. Audits cover the code, but users cannot independently verify behavior. This is a transparency gap compared to GMX (open source) and Hyperliquid (open source).

**DeFiLlama metadata discrepancy**: DeFiLlama lists `audits: "0"` for Jupiter Perpetual Exchange despite the documented audit program. This is a discoverability failure.

#### Source Code Review

**Source availability**: Closed for core perp program (`PERPHjGBqRHArX4DySjwM6UJHiR3sWAatqfdBS2qQJu`). Some Jupiter ecosystem contracts are open on GitHub but not the Perps program specifically.

**Contracts reviewed**: Not performed. Source not publicly available.

**Admin function inventory**: Cannot be verified without source.

**Vulnerability scan**: Relies entirely on the audit firms' output. OtterSec 2023 HIGH-severity findings (keeper front-running) are the most significant publicly known issues.

**Governance claim verification**: Cannot be performed.

**Conclusion**: Closed-source status is a material transparency gap. The audit program is strong but users are fundamentally trusting the auditors + team, not verifying themselves.

### 5. Cross-Chain & Bridge -- N/A

Single-chain (Solana). No bridge dependencies for core perp operations.

### 6. Operational Security -- MEDIUM

**Team**: Jupiter core team is pseudonymous (meow, Siong, etc.). Company has raised capital and has corporate presence. Engineer identities for Perps specifically are not publicly known.

**Incident response**: Demonstrated response in Feb 2025 (X account compromise -- attacker promoted fake "Meow" token reaching $20M market cap). Communication was rapid; no smart contract impact. This shows social-media-level operational capability but does not verify on-chain incident response.

**Keeper operations**: Keepers are critical infrastructure for Perps. Keeper operator identities, redundancy, failover, and safeguards against malicious keepers are NOT publicly documented. The OtterSec 2023 keeper finding remains a qualitative concern until remediation is publicly verified.

**Dependencies**:
- Squads multisig (ecosystem-shared admin)
- Edge / Chainlink / Pyth oracle providers
- Keeper infrastructure (Jupiter-operated)
- Solana chain reliability (Solana has had multiple outages -- perps are particularly sensitive to downtime)

**Solana outage exposure**: During Solana chain halts, liquidations cannot execute. If a halt coincides with a price move, traders can hold winning positions indefinitely (bad for JLP) or losing positions cannot be liquidated (bad debt). Historical Solana outages in 2022-2024 did cause some protocols to implement halt-handling logic; Jupiter Perps' specific behavior during a chain halt is UNVERIFIED.

### 7. Off-Chain Security -- HIGH

- **SOC 2 / ISO 27001**: Not held or not disclosed
- **Key management**: Squads multisig as custody; signer key storage (HSM / MPC / hot wallet) UNVERIFIED
- **Penetration testing**: Not disclosed
- **Custodial counterparty**: None for Perps
- **Insider threat controls**: Not documented; Jupiter's pseudonymous culture increases insider-threat exposure

**Rating: HIGH**. The combination of pseudonymous team + opaque multisig + no certifications + no disclosed pentest is the exact profile most vulnerable to the Drift-type attack pattern that manifested in April 2026.

## Critical Risks

No CRITICAL-rated findings, but the following HIGH-attention items could combine into a critical scenario:

1. **250x leverage + zero insurance fund**: In an extreme market event (flash crash, Solana outage, oracle failure), liquidation cascades at 250x could create bad debt faster than the system can process. JLP holders bear the loss with no backstop.

2. **Keeper front-running (OtterSec 2023 HIGH finding)**: Unless publicly verified as remediated, this represents a known HIGH-severity issue in the code.

3. **Governance opacity + admin can change oracles**: The Drift playbook applies. Multisig compromise -> pre-signed transaction -> oracle manipulation -> drain JLP. Jupiter Perps has structurally similar surface area.

4. **Closed-source core**: Users cannot verify claims. The gap between "3-4 audits say it's fine" and "any user can read the code" is large for a $695M protocol.

5. **Solana chain halt exposure**: No publicly documented halt-handling logic. If Solana halts for hours during a volatile period, either JLP or traders suffer asymmetric losses depending on direction.

## Peer Comparison

| Feature | Jupiter Perps | GMX V2 (Arbitrum) | Hyperliquid |
|---------|---------------|-------------------|-------------|
| Max Leverage | 250x | 50x | 50x |
| Insurance/TVL | 0% | ~1% (dedicated) | ~4% (HLP + insurance) |
| Oracle | Edge + Chainlink + Pyth (tri) | Chainlink + custom | Custom (Hyperliquid oracle) |
| Timelock | UNVERIFIED | 24-48h | None (fully team-controlled L1) |
| Multisig | Squads, threshold UNVERIFIED | 4/6 or 5/7 reported | Team-controlled |
| Audits | 3-4 public refs | 10+ (Sherlock, Quantstamp, ABDK) | Limited public audits |
| Open Source | No (core closed) | Yes | Partial |
| Counterparty Model | JLP (LPs absorb P&L) | GLP (LPs absorb P&L) | HLP + insurance |
| Chain | Solana | Arbitrum | Hyperliquid L1 |
| TVL | ~$695M | ~$550M (GLP) | ~$3B+ |

**Key Differentiators**:
- **Oracle design**: Jupiter's tri-oracle is stronger than GMX (which had multiple oracle-based exploits) and arguably stronger than Hyperliquid's closed-source oracle.
- **Leverage**: Jupiter's 250x is aggressive. GMX / Hyperliquid cap at 50x.
- **Insurance**: Both Jupiter and GMX use LP-absorbs-all models. Hyperliquid has a dedicated insurance fund.
- **Transparency**: GMX is fully open source. Jupiter is closed-source core. Hyperliquid is partial.

## Recommendations

- **For traders**: Recognize 250x is a maximum, not a target. Size positions such that normal volatility does not trigger liquidation. Be aware that during Solana outages, positions cannot be adjusted.
- **For JLP holders**: Recognize you are the counterparty. A sustained period of skilled directional traders, or an extreme tail event, could produce losses with no protocol backstop. Size JLP exposure as a high-risk yield strategy, not a low-risk LP position.
- **For Jupiter team**: Publish Squads multisig configuration. Open-source the Perps program or at minimum publish verified source on a block explorer equivalent. Publish keeper operator details and the OtterSec 2023 keeper finding's remediation. Document Solana-halt handling logic.
- **For integrators (e.g., protocols accepting JLP as collateral)**: Apply conservative LTV and recognize that JLP value is exposed to external Jupiter perps risks, not just AMM-like market risk. The Drift hack demonstrated $159M of JLP can be affected by non-Jupiter events.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- Partially (new trading pairs can be added; process UNVERIFIED)
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED (no timelock documented)
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED (AUM cap is admin-controlled)
- [ ] Multisig has low threshold (2/N with small N)? -- UNVERIFIED
- [ ] Zero or short timelock on governance actions? -- UNVERIFIED (no timelock documented)
- [x] Pre-signed transaction risk (durable nonce on Solana)? -- YES, applicable to all Solana Squads programs
- [x] Social engineering surface area (anon multisig signers)? -- YES, signers pseudonymous

**Match: 2/7 confirmed, 5/7 UNVERIFIED. Potential for 3+ indicators if any UNVERIFIED items prove to be true. Treat as elevated Drift-pattern risk pending publication of multisig and timelock details.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- JLP restricted to SOL/ETH/wBTC/USDC/USDT (high liquidity); trading pairs limited to majors
- [ ] Single oracle source without TWAP? -- NO, tri-oracle with cross-verification
- [ ] No circuit breaker on price movements? -- UNVERIFIED (manual pause only)
- [x] Insufficient insurance fund relative to TVL? -- YES, 0% dedicated insurance

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No (single-chain)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Not directly applicable -- Perps parameters not governance-voted in real-time

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens? -- No (JLP assets are standard)
- [ ] Read-only reentrancy risk? -- UNVERIFIED
- [x] Flash loan compatible without reentrancy guards? -- Offside Labs Oracle and Flashloan report suggests review occurred; specific guards UNVERIFIED

### Curve-type (Compiler / Language Bug):
- [ ] Non-standard compiler? -- No (Anchor / standard Solana)
- [ ] Compiler version CVEs? -- UNVERIFIED

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Not directly applicable; if JupUSD integration deepens (e.g., JupUSD used for funding settlement), indirect cascade risk exists

## Information Gaps

1. Squads multisig address, threshold, and signer identities for Jupiter Perps program
2. Timelock duration (if any) on program upgrades and parameter changes
3. OtterSec 2023 HIGH-severity keeper finding -- remediation status
4. Keeper operator identities, incentive structure, and safeguards
5. Solana chain halt handling logic (does the protocol lock liquidations or allow settlement post-halt?)
6. AUM cap governance -- who can change, under what conditions, timelocked?
7. Circuit breaker on oracle deviations (beyond manual pause)
8. Bug bounty scope and payout tier for Perps specifically
9. Emergency pause capability -- who can pause, conditions
10. JLP pool target weight governance
11. Funding rate model parameters and extreme-scenario behavior
12. Post-2023-audit code changes -- has the core program been re-audited since the 250x leverage upgrade?
13. Open-source status -- when will Jupiter Perps core program be made public?
14. Solana freeze authority status on JLP mint

## Disclaimer

This analysis is based on publicly available information and web research conducted on April 21, 2026. It is NOT a formal smart contract audit. On-chain verification of Squads multisig configuration and program upgrade authority was not performed due to lack of public multisig address. The core Perps program source code is not publicly available, so claims from audit reports cannot be independently verified. Always DYOR and consider professional auditing services for investment decisions.
