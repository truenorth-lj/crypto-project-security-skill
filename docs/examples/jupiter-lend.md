# DeFi Security Audit: Jupiter Lend

**Audit Date:** April 21, 2026
**Protocol:** Jupiter Lend -- Solana lending/borrowing market built in partnership with Fluid

## Overview
- Protocol: Jupiter Lend
- Chain: Solana
- Type: Lending / Borrowing (isolated markets with dynamic limits)
- TVL: ~$876M (supply); ~$618M borrowed (DeFiLlama, April 2026)
- TVL Trend: -6.8% / -18.9% / -13.4% (7d / 30d / 90d)
- Launch Date: Mid-2025 (early testnet), mainnet production ramp Q3-Q4 2025; major Code4rena contest Feb-Mar 2026
- Audit Date: April 21, 2026
- Valid Until: July 20, 2026 (or earlier if TVL changes >30%, governance upgrade, or security incident)
- Source Code: Partial (some vault and periphery contracts open on GitHub; core aggregator routing closed)
- DeFiLlama Slug: `jupiter-lend`

This report is a companion to the [Jupiter main audit](jupiter-solana-dex.md) and the [Jupiter ecosystem deep dive](jupiter-ecosystem-deep-dive.md). Jupiter Lend is treated here as a standalone lending product, while the broader Squads-multisig and JUP-governance context is covered in those reports.

## Quick Triage Score: 57/100 | Data Confidence: 45/100

Starting at 100, deductions applied mechanically:

- HIGH: No audit listed on DeFiLlama (`audits: "0"`, `audit_links: null`) despite an extensive private audit program (OtterSec, Offside Labs, MixBytes, Zenith, Code4rena, Certora) -- public discoverability is poor (-15)
- MEDIUM: TVL dropped >30% at worst in 90d window (peak ~$1.08B -> current $876M, -19% from peak within the 90d window) (-8) -- note: threshold is 30% peak-to-trough so this is borderline; applying conservatively given peak was 30d ago
- MEDIUM: Multisig threshold UNVERIFIED -- Squads multisig config for the Lend programs is not publicly disclosed (-8)
- LOW: No documented timelock on admin actions -- program upgrade timelocks not published for Lend (-5)
- LOW: Undisclosed multisig signer identities (Squads signers for Jupiter Lend are not publicly doxxed) (-5)
- LOW: Insurance fund / TVL < 1% or undisclosed (no dedicated Lend insurance fund identified) (-5)
- LOW: DAO governance paused (Jupiter DAO paused Jun 2025, partial resumption Feb 2026 for emissions vote only) (-5)

Red flags found: 0 CRITICAL, 1 HIGH, 2 MEDIUM, 4 LOW
Score meaning: 50-79 = MEDIUM risk.

Data Confidence breakdown:
- +15 Source code partially open (vault and periphery contracts on jup-ag GitHub)
- +10 Multiple audit reports publicly referenced (though DeFiLlama metadata lists 0)
- +5 Oracle provider(s) likely Pyth/Edge/Chainlink (inferred from Perps, not confirmed for Lend)
- +5 Governance process documented (Jupiter DAO, paused)
- +5 Team identities partially known (meow, Siong pseudonyms; core team semi-public)
- +5 Bug bounty program in scope (Immunefi / Cantina references -- Jupiter-wide program, Lend inclusion UNVERIFIED)

Total: 45/100 = LOW-MEDIUM confidence. Treat triage score with skepticism -- many claims depend on unverifiable multisig threshold, timelock duration, and oracle configuration.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | 1-5% (Aave Safety Module ~2%) | HIGH |
| Audit Coverage Score | ~6.0 (10+ audits within 1 yr: OtterSec Nov 2025, OtterSec Aug-Nov 2025, Offside Labs Oct 2025, MixBytes Jul-Oct 2025, Offside Labs Jul-Aug 2025, Offside Labs Jul 2025, Zenith Jun-Jul 2025, Code4rena Feb-Mar 2026, Certora FV) | 2-4 avg | LOW |
| Governance Decentralization | Squads multisig, DAO paused, Risk parameters team-controlled | DAO vote avg | HIGH |
| Timelock Duration | UNVERIFIED | 24-48h avg | HIGH |
| Multisig Threshold | UNVERIFIED | 3/5 avg | HIGH |
| GoPlus Risk Flags | N/A (Solana not supported) | -- | N/A |

## GoPlus Token Security

N/A -- Jupiter Lend has no dedicated token. JUP (governance) analysis is covered in the main Jupiter audit. Jupiter Lend markets reference SPL tokens such as SOL, USDC, USDT, JitoSOL, mSOL, JupSOL, JLP, etc. GoPlus Security API does not support Solana.

**Solana fallback**: JUP token scan via RugCheck is referenced in the main Jupiter audit.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **HIGH** | Squads multisig threshold/signer identities UNVERIFIED; no timelock documented; DAO paused | S | Partial |
| Oracle & Price Feeds | **MEDIUM** | Likely inherits tri-oracle design from Perps (Edge/Chainlink/Pyth) but Lend-specific configuration UNVERIFIED | S | Partial |
| Economic Mechanism | **MEDIUM** | Custom liquidation engine; rehypothecation concerns flagged; no dedicated insurance fund | S | Partial |
| Smart Contract | **MEDIUM** | Extensive audit coverage (10+ audits, Certora FV) but new product, Code4rena findings include DoS and dust-position issues | S/H | Partial |
| Token Contract (GoPlus) | **N/A** | Solana not supported | -- | -- |
| Cross-Chain & Bridge | **N/A** | Single-chain (Solana) | -- | -- |
| Operational Security | **MEDIUM** | Jupiter team semi-public; X account compromise Feb 2025 demonstrated social engineering exposure | O/H | Partial |
| Off-Chain Security | **HIGH** | No SOC 2 / ISO 27001; no published key management policy; no disclosed pentest | O | N |
| **Overall Risk** | **HIGH** | **Extensive audits mitigate smart contract risk but governance opacity (HIGH), off-chain security gaps (HIGH), and novel lending mechanics combine to produce HIGH overall risk for a $876M market** | | |

**Overall aggregation**: Governance HIGH (2x weight) + Off-Chain HIGH = 3 HIGH-equivalents, 2 MEDIUM -> Overall HIGH per mechanical rule.

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Program upgrade authority**: Jupiter Lend programs are upgradeable via Squads multisig. The specific Squads account, threshold, and signer set are NOT publicly disclosed (UNVERIFIED). This is consistent with opacity across the Jupiter ecosystem -- no Jupiter program's multisig configuration has been made public.

**Admin powers** (inferred from lending protocol standards -- exact Jupiter Lend parameters UNVERIFIED):
- Add / remove collateral types
- Configure collateral factors (LTV, liquidation thresholds)
- Update oracle sources per market
- Set interest rate model parameters
- Pause individual markets or the whole protocol
- Upgrade programs at any time

**Timelock**: No public documentation of a timelock on program upgrades or parameter changes. In the absence of disclosure, treat as zero. This is the single most dangerous gap -- a compromised multisig can execute instant upgrades that drain user deposits.

**Governance**: Jupiter DAO was paused in June 2025 due to "breakdown in trust" from insider voting concentration. Partial resumption in February 2026 (Net-Zero Emissions vote). Jupiter Lend parameter decisions are effectively team-controlled.

**Timelock bypass detection**: Not applicable -- no timelock is known to exist, so there is nothing to bypass.

**Mitigating factors**: Jupiter's track record of not having been exploited in its 5-year operational history. However, Jupiter Lend is <1 year old, and the Drift Protocol hack (April 2026) demonstrated that Solana multisig programs with <3/N thresholds can be exploited via social engineering.

### 2. Oracle & Price Feeds -- MEDIUM

**Oracle architecture**: Jupiter Lend's oracle configuration for each market is not comprehensively documented in public materials. The Offside Labs "Oracle and Flashloan Report" (Oct 2025) was published as part of the audit series, suggesting oracle design received dedicated review.

**Likely design** (inferred from Jupiter Perpetuals tri-oracle pattern, UNVERIFIED for Lend):
- Primary: Edge Oracle (by Chaos Labs) or Pyth
- Secondary: Chainlink
- Cross-verification logic with staleness and deviation checks

**Per-market risk**: Each lending market likely has its own oracle configuration. Lower-liquidity collateral tokens (JLP, JupSOL, JupUSD if accepted) depend on exchange-rate or custom oracles, which introduces additional trust assumptions.

**Flashloan interaction**: The dedicated Offside Labs Oracle and Flashloan Report indicates awareness of flashloan-based oracle manipulation vectors. Implementation details -- such as whether TWAP protection is used, and whether spot prices are acceptable in any market -- are UNVERIFIED.

**Admin override**: Whether admins can change oracle sources post-deployment without timelock is UNVERIFIED. This is the exact pattern that enabled the Drift Protocol hack.

### 3. Economic Mechanism -- MEDIUM

**Liquidation**: Jupiter Lend uses a "bespoke liquidation engine" described in marketing materials as "designed to complement JLP and JupUSD" with "dynamic limits to isolate risk." The specifics of the liquidation algorithm are partially documented in the open-source vault repos but the Lend-specific liquidation flow is not fully auditable from public code alone.

**Rehypothecation concerns**: Multiple community analyses flagged rehypothecation risks in Jupiter Lend -- specifically that deposited collateral could be re-used (staked, lent, or re-hypothecated) in ways that amplify systemic risk. The Fluid partnership suggests some form of borrow-against-borrow or yield-bearing collateral routing. Exact details UNVERIFIED.

**Bad debt handling**: No dedicated Jupiter Lend insurance fund has been identified. Bad debt is presumably socialized to lenders (standard pattern) or absorbed by the Jupiter treasury, but the formal mechanism is UNVERIFIED.

**Code4rena findings** (known issues from Feb-Mar 2026 contest, $107K pool):
- DoS vulnerability if transactions load more than 64 accounts
- Token extensions (Token-2022 extensions) can break the protocol
- No way to close a position PDA to reclaim rent (user UX issue, low severity)
- Dust phantom debt positions possible

None of these are fund-loss bugs, but they indicate the attack surface of a novel lending design on Solana's account model.

**Interest rate model**: Not publicly documented in detail. Presumed utilization-curve based. Whether rates can spike to abusive levels under near-100% utilization is UNVERIFIED.

**Withdrawal limits**: "Dynamic limits to isolate risk" implies some form of rate limiting or caps. Who can change these limits, and whether changes are timelocked, is UNVERIFIED.

### 4. Smart Contract Security -- MEDIUM

**Audit history** (10+ independent reviews):
- OtterSec Report 2 (Nov 2025)
- OtterSec Report (Aug-Nov 2025)
- Offside Labs Oracle and Flashloan (Oct 2025)
- MixBytes Vault Report (Jul-Oct 2025)
- Offside Labs Vault Report (Jul-Aug 2025)
- Offside Labs Liquidity Report (Jul 2025)
- Zenith Report (Jun-Jul 2025)
- Code4rena competitive audit ($107K pool, Feb-Mar 2026)
- Certora Formal Verification Report

This is an exceptionally thorough audit program, arguably one of the most audited new lending protocols of 2025. However, Jupiter Lend is still listed as `"audits": "0"` on DeFiLlama with `audit_links: null`, which is a **discoverability failure** -- users relying on DeFiLlama audit badges would see the product as unaudited.

**Bug bounty**: Jupiter maintains an Immunefi program (and Cantina presence). Whether Jupiter Lend is specifically in scope and the payout tier is UNVERIFIED.

**Battle testing**: <1 year since product launch. Peak TVL ~$1.08B (March 2026). No public exploit or near-miss incidents to date.

**Open source**: Vault and periphery contracts are open on GitHub (jup-ag). Core liquidation engine source availability is UNVERIFIED.

#### Source Code Review

**Source availability**: Partial (vault and periphery contracts open on GitHub; liquidation engine and admin controls closed or undocumented)
**Contracts reviewed**: Not performed at file level in this audit; full Anchor program review would require access to the private audit reports.

**Admin function inventory**: UNVERIFIED at source level due to closed-source segments. Audit reports (OtterSec, Offside Labs) presumably cover this but are not published in full.

**Vulnerability scan**: Code4rena findings (listed above) represent the publicly disclosed known issues. No flashloan-reentrancy class bug publicly known.

**Governance claim verification**: Cannot be performed from public source alone. Squads multisig threshold, timelock duration, and emergency pause capability cannot be cross-referenced against code without access to the program's upgrade authority account data.

**Conclusion**: Audit coverage is strong but source-level verification of governance claims is limited. The gap between "10+ audits exist" and "any user can verify a governance claim" is large.

### 5. Cross-Chain & Bridge -- N/A

Jupiter Lend is single-chain (Solana). No bridge dependencies for core lending operations. Indirect dependency exists if JupUSD is accepted as collateral -- JupUSD is 90% backed by USDtb (Ethereum, via Ethena) and requires cross-chain reserve management -- but this affects JupUSD's peg rather than Lend's direct security.

### 6. Operational Security -- MEDIUM

**Team**: Jupiter core team operates under pseudonyms (meow, Siong, etc.) with some members semi-doxxed. Jupiter has raised capital and has corporate presence, but individual engineer identities for Jupiter Lend are not publicly known.

**Incident response**: No published Jupiter-Lend-specific incident response plan. Jupiter ecosystem-level response to the February 2025 X account compromise demonstrated the team can coordinate quickly, but that incident was social media only, not an on-chain exploit. Emergency pause capability on Lend UNVERIFIED.

**Dependencies**:
- Squads multisig (shared ecosystem-wide admin infrastructure)
- Oracle providers (Edge / Chainlink / Pyth likely)
- Fluid (partnership for lending mechanics -- architecture shared or licensed)
- JLP, JupUSD, JupSOL (if accepted as collateral -- creates contagion paths)

**Downstream lending exposure**: Jupiter Lend IS a lending protocol; it is the downstream surface for other Jupiter products. If JLP de-values via a perps-side incident, Lend liquidations could cascade. The Drift Protocol hack (April 2026) drained $159M of JLP from Drift -- this did not affect Lend directly but demonstrated that JLP holders can suffer correlated losses across protocols.

### 7. Off-Chain Security -- HIGH

- **SOC 2 / ISO 27001**: Not held (or not disclosed) by Jupiter or any Jupiter Lend-related entity.
- **Key management**: Squads multisig is the custody layer. Whether signers use HSMs, MPC, or hardware wallets is UNVERIFIED. No public key management policy.
- **Penetration testing**: No disclosed infrastructure pentest (distinct from smart contract audits).
- **Custodial counterparty**: None for Lend itself, but JupUSD's Ethena/BlackRock BUIDL dependency adds indirect off-chain trust.
- **Insider threat controls**: Background checks, access logging, separation of duties -- none publicly documented. Given Jupiter's pseudonymous team culture, insider threat mitigations are especially important and especially opaque.

**Rating: HIGH**. The Drift Protocol hack (DPRK social engineering -> multisig signer compromise -> pre-signed transaction exploit) is the exact attack pattern that a Solana protocol with an opaque multisig and no disclosed operational security controls is most vulnerable to.

## Critical Risks

No CRITICAL-rated findings, but the following HIGH-attention items could combine into a CRITICAL scenario:

1. **Opaque Squads multisig + no timelock + novel lending mechanics**: If the multisig threshold is low (2/N or 3/N) and a signer is socially engineered, there is no timelock buffer. The Drift Protocol playbook (April 2026) showed this attack succeeds within hours. Jupiter Lend holds $876M supply; the blast radius of a multisig compromise is proportionally large.

2. **No DeFiLlama audit listing despite extensive audits**: Users relying on automated risk dashboards (DeFiLlama, DeFi Safety) would see Jupiter Lend as "zero audits" and potentially avoid it -- but sophisticated users might over-credit the 10+ private audits without realizing many details are not public. Either direction is a form of information asymmetry.

3. **Rehypothecation concerns**: If collateral is rehypothecated in Fluid-style vaults without clear on-chain accounting, a cascade failure in one layer could propagate. This is a qualitative concern; concrete attack vector UNVERIFIED.

## Peer Comparison

| Feature | Jupiter Lend | Kamino Lend (Solana) | Fluid (Ethereum, parent pattern) |
|---------|--------------|----------------------|----------------------------------|
| Timelock | UNVERIFIED | None documented | Multi-layer (Governor Beta) |
| Multisig | Squads (threshold UNVERIFIED) | Squads <4 signers UNVERIFIED | Multisig + DAO governance |
| Audits | 10+ private (DeFiLlama lists 0) | 6+ (Certora, OtterSec, public) | Multiple (StateMind, MixBytes) |
| Oracle | Edge / Chainlink / Pyth (inferred) | Pyth + Switchboard + Chainlink | Chainlink + fallback |
| Insurance/TVL | Undisclosed | Undisclosed | ~0% (relies on liquidation buffer) |
| Open Source | Partial | Yes | Yes |
| TVL | ~$876M | ~$1.5B | ~$3.5B (DEX+Lending) |
| Formal Verification | Yes (Certora) | Yes (Certora) | Yes |

**Key Differentiator**: Jupiter Lend has one of the most extensive audit programs of any new lending protocol, including Certora formal verification and a Code4rena competitive audit. However, governance opacity is worse than Kamino (which at least publishes known multisig addresses) and far worse than Fluid (which has published governance).

## Recommendations

- **For depositors**: Size positions conservatively given governance opacity. Monitor Jupiter's official channels for pause events. Avoid using JupUSD or JLP as collateral in Jupiter Lend if alternatives exist, to limit cross-product contagion.
- **For Jupiter team**: Publish the Squads multisig threshold, signer count, and signer addresses for Jupiter Lend. Publish the upgrade timelock duration (or implement one). Update DeFiLlama audit metadata.
- **For sophisticated users**: Read the Certora formal verification report and Code4rena contest findings directly. Verify whether the collateral assets in markets you use are accepted as collateral with isolation, not cross-margining.
- **For risk curators / integrators**: Do not treat Jupiter Lend as equivalent to battle-tested lending protocols. <1 year old with novel mechanics -- size exposure accordingly.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- UNVERIFIED (no timelock documented)
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED
- [ ] Multisig has low threshold (2/N with small N)? -- UNVERIFIED (exact threshold not public)
- [ ] Zero or short timelock on governance actions? -- UNVERIFIED (no timelock documented)
- [x] Pre-signed transaction risk (durable nonce on Solana)? -- YES, applicable to all Solana Squads-managed programs
- [x] Social engineering surface area (anon multisig signers)? -- YES, Jupiter team and signers are pseudonymous

**Match: 2/7 confirmed indicators, 5/7 unverified. Trigger rule of 3+ is not confirmed but is possible -- treat as elevated Drift-pattern risk.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- UNVERIFIED (market list and oracle depth checks not public)
- [ ] Single oracle source without TWAP? -- UNVERIFIED
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [x] Insufficient insurance fund relative to TVL? -- YES, no dedicated insurance fund

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- Indirect via JupUSD (if used as collateral)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Not applicable -- Jupiter Lend does not have token-weighted on-chain governance over Lend parameters.

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? -- UNVERIFIED (Token-2022 extensions flagged as breaking in Code4rena findings, suggesting extensions not supported)
- [ ] Read-only reentrancy risk? -- UNVERIFIED
- [x] Flash loan compatible without reentrancy guards? -- Offside Labs Oracle and Flashloan report suggests the vector was reviewed; specific guards UNVERIFIED

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard compiler? -- No (Anchor / standard Solana toolchain)
- [ ] Compiler version has known CVEs? -- UNVERIFIED

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Not directly applicable to Lend, but if JupUSD is accepted as collateral, any JupUSD depeg cascades into Lend bad debt.

## Information Gaps

1. Squads multisig address, threshold, and signer identities for Jupiter Lend programs
2. Timelock duration (if any) on Jupiter Lend program upgrades
3. Complete list of supported collateral types per market
4. Per-market oracle configuration (Edge / Chainlink / Pyth / custom / exchange rate)
5. Whether Jupiter Lend accepts JLP, JupUSD, and JupSOL as collateral (contagion-critical)
6. Emergency pause capability -- who can pause, under what conditions
7. Interest rate model parameters and failure modes under extreme utilization
8. Withdrawal / deposit rate limits and admin ability to modify them
9. Bug bounty scope for Jupiter Lend specifically (Immunefi / Cantina)
10. Certora formal verification coverage -- which properties were proven
11. Code4rena contest final results (total issues found, severity distribution, remediation status)
12. DeFiLlama audit metadata -- why `audits: "0"` despite extensive audit program
13. Rehypothecation specifics of the Fluid partnership
14. Insurance fund mechanism (socialized loss vs. treasury absorption vs. none)
15. Signer key management practices (HSM, MPC, hot/cold wallet distribution)
16. Whether the programs have been frozen (upgrade authority set to None) or remain mutable

## Disclaimer

This analysis is based on publicly available information and web research conducted on April 21, 2026. It is NOT a formal smart contract audit. On-chain verification of Squads multisig configuration was not performed due to lack of public multisig address. Always DYOR and consider professional auditing services for investment decisions.
