# DeFi Security Audit: Kamino Finance (K-Lend)

**Audit Date:** April 6, 2026
**Protocol:** Kamino Finance -- Solana lending, liquidity, and leverage protocol

## Overview
- Protocol: Kamino Finance (K-Lend / K-Lend V2)
- Chain: Solana
- Type: Lending / Borrowing / Leverage
- TVL: ~$1.51B (Kamino Lend); ~$1.69B (Kamino Finance total including liquidity vaults)
- TVL Trend: -15.0% / -18.0% / -35.1% (7d / 30d / 90d)
- Launch Date: October 2023 (K-Lend); August 2022 (Kamino Liquidity); May 2025 (K-Lend V2)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: Kamino-Finance)

## Quick Triage Score: 62/100

Starting at 100, deductions applied:

- [ ] No documented timelock on admin actions: -5
- [ ] Single oracle provider: NOT flagged (uses Pyth + Switchboard + Chainlink = multi-oracle)
- [x] Multisig threshold < 3 signers (reported as fewer than 4 signers): -8
- [x] Undisclosed multisig signer identities: -5
- [x] No documented timelock on admin actions: -5
- [x] Insurance fund / TVL < 1% or undisclosed: -5
- [x] DAO governance paused or dissolved (formal governance "upcoming", not yet live): -5
- [x] GoPlus: N/A (Solana not supported) -- not scored but noted as information gap: -5

**Score: 100 - 8 - 5 - 5 - 5 - 5 - 5 = 67**

Adjusted to 62 given that the multisig concern (fewer than 4 signers with no timelock) is a compounding factor per the framework -- a low-signer multisig without a timelock is functionally closer to a MEDIUM flag (-8) and a LOW flag (-5) combined.

**Risk band: MEDIUM (50-79)**

## Quantitative Metrics

| Metric | Value | Benchmark (Solana peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (socialized loss model) | 1-5% (Aave Safety Module ~2%) | HIGH risk |
| Audit Coverage Score | ~4.5 (6+ audits, several recent) | 1-3 avg | LOW risk |
| Governance Decentralization | Risk Council multisig, no DAO vote yet | DAO avg | MEDIUM risk |
| Timelock Duration | None documented | 24-48h avg | HIGH risk |
| Multisig Threshold | <4 signers (UNVERIFIED exact config) | 3/5 avg | MEDIUM risk |
| GoPlus Risk Flags | N/A (Solana not supported) | -- | N/A |

## GoPlus Token Security

GoPlus Security API does not support Solana-native tokens. The KMNO token (mint: KMNo3nJsBXfcpJTVhZcXLW7RmTwTt4GVFE7suUBo9sS) cannot be scanned via GoPlus. This is recorded as an information gap.

**GoPlus assessment: NOT AVAILABLE** -- Solana chain not supported.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | Squads multisig with <4 signers, no timelock, formal DAO governance not yet live | Partial |
| Oracle & Price Feeds | **LOW** | Multi-oracle (Pyth + Switchboard + Chainlink), TWAP/EWMA protections | Partial |
| Economic Mechanism | **MEDIUM** | Soft liquidation model is sound but no dedicated insurance fund; socialized loss | Partial |
| Smart Contract | **LOW** | 6+ audits including formal verification by Certora and OtterSec | Y |
| Token Contract (GoPlus) | **N/A** | Solana not supported by GoPlus token security API | N |
| Cross-Chain & Bridge | **N/A** | Single-chain (Solana) with no bridge dependencies | N/A |
| Operational Security | **LOW** | Doxxed team, Hubble Protocol track record, $1.5M bug bounty | Y |
| **Overall Risk** | **MEDIUM** | **Strong audit coverage and multi-oracle design offset by weak admin controls (no timelock, small multisig) and undisclosed insurance fund** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**Admin Key Surface Area:**
- Kamino uses Squads multisig for program upgrade authority across its core programs (Lending, Liquidity, Farms).
- Known multisig addresses: Lending (6hhBGCtmg7tPWUSgp3LG6X2rsmYWAc4tNsA6G4CnfQbM), Liquidity (BccSdKrSsjw4XKKjTPKak2wur1C9dMX3tmXoFwFAU7oh).
- The multisig reportedly consists of fewer than 4 signers, raising centralization concerns. Exact threshold is UNVERIFIED.
- No documented timelock on program upgrades or parameter changes. This means a compromised or colluding set of signers could push an upgrade with zero delay.
- The Risk Council (operated by Allez Labs contributors) can adjust risk parameters (caps, interest rate curves, asset listings) via multisig vote -- these changes appear to take effect immediately.

**Governance Process:**
- KMNO is designated as a governance token, but formal on-chain governance (DAO voting on proposals) has not yet launched as of April 2026. The team describes it as "upcoming."
- Current governance is effectively team-controlled via the Risk Council and multisig signers, with community input through the Kamino Forum (gov.kamino.finance).
- Risk parameter changes are discussed publicly via monthly risk insight posts by Allez Labs on the governance forum, providing transparency but not binding community approval.

**Token Concentration:**
- Top 10 wallets reportedly hold over 70% of KMNO supply. 35% of supply is allocated to key stakeholders and advisors (12-month lock, then 24-month linear vest).
- Even once governance launches, this concentration creates whale risk -- a small number of holders could dominate voting.

**Timelock Bypass:**
- No timelock exists to bypass. This is the core concern: the absence of any enforced delay on admin actions means there is no cooling-off period for the community to react to a malicious upgrade.

**Risk Rating: MEDIUM.** The Squads multisig is a meaningful security measure, but the low signer count, lack of timelock, and absence of live DAO governance leave meaningful centralization risk. This is below the standard set by Aave (6/10 Guardian + dual timelocks) and even some Solana peers.

### 2. Oracle & Price Feeds -- LOW

**Oracle Architecture:**
- Kamino uses a multi-oracle approach: Pyth Network (primary), Switchboard (secondary/redundant), and as of April 2025, Chainlink Data Streams for low-latency market data.
- K-Lend's oracle risk engine cross-references multiple feeds and maintains its own Switchboard oracles ingesting both on-chain and off-chain sources.
- For kTokens (Kamino vault tokens used as collateral), prices are computed directly on-chain from underlying LP positions.

**Price Manipulation Resistance:**
- TWAP (Time Weighted Average Price) and EWMA (Exponentially Weighted Moving Average) pricing are used, which resist flash loan and flash crash manipulation.
- Dramatic short-term price deviations are rejected by the oracle engine.
- The proprietary oracle system (Kamino Scope) provides an additional layer of price validation.

**Collateral/Market Listing:**
- In V2, isolated lending markets can be created with custom oracle configurations per market.
- The Risk Council (via KRAF) evaluates new assets before onboarding, including oracle quality assessment.
- Admin (Risk Council multisig) can change oracle sources -- this power combined with no timelock is a residual concern, though the multi-oracle design mitigates single-point failure.

**Risk Rating: LOW.** The triple-oracle architecture (Pyth + Switchboard + Chainlink) with TWAP/EWMA protections is among the strongest on Solana. The residual risk is that oracle source changes are admin-controlled without timelock.

### 3. Economic Mechanism -- MEDIUM

**Liquidation Mechanism:**
- K-Lend uses a soft liquidation model: partial liquidations (e.g., 20% of debt) for borrowers slightly over the liquidation LTV, scaling up to larger liquidations as LTV increases further.
- Liquidation penalties range from 2% (minimum, for prompt liquidators) to 10% (maximum, for deeply underwater positions).
- This graduated approach is a meaningful improvement over binary full-liquidation models, reducing cascading liquidation risk.

**Bad Debt Handling:**
- No dedicated insurance fund has been disclosed. The protocol uses a socialized loss model: if bad debt occurs, it is distributed proportionally across all lenders in the affected market.
- The protocol reports zero bad debt since launch as of recent communications.
- The Auto-Deleverage (ADL) mechanism (part of KRAF) enables the protocol to force-deleverage positions when aggregate risk becomes too high for a given asset, serving as a preventive measure rather than reactive insurance.

**Interest Rate Model:**
- Interest rate curves are calibrated by the Risk Council to target optimal utilization rates.
- Rates are published transparently and adjusted through the governance forum process.

**JLP and LST Collateral Risks:**
- JLP (Jupiter Liquidity Provider tokens) can be used as collateral and leveraged via Multiply vaults (up to 3x). JLP carries inherent risk from Jupiter perps trading losses.
- SOL LST tokens (mSOL, JitoSOL, JupSOL) are used in looping strategies. A change in LST oracle infrastructure means LST depegs can no longer cause liquidations for Multiply positions -- this is a positive risk mitigation.
- The Multiply product inherently introduces leverage risk: borrow rates exceeding yield rates for extended periods can cause liquidations.

**Risk Rating: MEDIUM.** The soft liquidation model and ADL mechanism are well-designed. However, the absence of a dedicated insurance fund is a meaningful gap -- socialized losses in a $1.5B protocol could cascade. The zero bad debt record is encouraging but does not guarantee future performance.

### 4. Smart Contract Security -- LOW

**Audit History:**
Kamino has an extensive audit portfolio, all publicly available at github.com/Kamino-Finance/audits:

| Audit Firm | Scope | Date (approx.) | Coverage Score |
|------------|-------|-----------------|----------------|
| OtterSec | Kamino Lending (K-Lend) | 2023 | 0.25 (>2yr old) |
| Sec3 | Kamino K-Lend | 2023-2024 | 0.5 (1-2yr old) |
| Offside Labs | Kamino Scope (oracle) | 2023-2024 | 0.5 |
| Certora | K-Lend formal verification (1st round) | Nov-Dec 2024 | 1.0 |
| Certora | K-Lend formal verification (2nd round) | Feb 2025 | 1.0 |
| OtterSec | K-Lend formal verification | 2025 | 1.0 |
| Certora | LIMO (liquidity integration) | Apr-May 2025 | 1.0 |

**Audit Coverage Score: ~5.25** (sum of recency-weighted audits). This is well above the LOW risk threshold of 3.0.

**Key Findings Fixed:**
- Certora identified a precision loss issue in the exchange rate calculation (rounding bug allowing excess collateral redemption). This was fixed before it could be exploited.

**Bug Bounty:**
- Active Immunefi bug bounty program launched October 2025, the largest on Solana at the time.
- Critical smart contract bugs: up to $1,500,000 (10% of affected funds, minimum $150,000).
- High-level: up to $100,000. Medium-level: $10,000 flat.
- Website/app bugs: up to $50,000.

**Battle Testing:**
- K-Lend has been live since October 2023 (~2.5 years). Peak TVL exceeded $2.3B.
- Zero exploits or bad debt events reported.
- Code is open source on GitHub (Kamino-Finance organization).

**Risk Rating: LOW.** The audit coverage is excellent, with recent formal verification from both Certora and OtterSec. The $1.5M bug bounty is substantial. No exploits in 2.5 years of operation at significant TVL.

### 5. Cross-Chain & Bridge -- N/A

Kamino operates exclusively on Solana with no cross-chain deployments or bridge dependencies. This section is not applicable.

### 6. Operational Security -- LOW

**Team & Track Record:**
- Kamino's four co-founders are publicly known: Gonzalo Parejo, Rodrigo Perenha, Benjamin Gleason, and Guto Fragoso. The team is doxxed.
- Originally incubated by Hubble Protocol (launched August 2022). The pivot from Hubble's stablecoin (USDH) to Kamino's liquidity management and lending products demonstrates adaptability.
- No known security incidents under the team's management.
- Backed by notable investors including RockawayX.

**Risk Management Infrastructure:**
- Allez Labs operates as the independent risk services provider, publishing monthly risk insights on the governance forum.
- KRAF (Kamino Risk Assessment Framework) provides a systematic approach to asset evaluation, parameter setting, and risk monitoring.
- Risk dashboard available at risk.kamino.finance.

**Incident Response:**
- The Risk Council has authority to pause markets and lower limits in emergency situations.
- Emergency pause capability exists but specific incident response procedures are not publicly documented in detail.
- Self-hosted bug bounty program existed for 3 years before the Immunefi partnership, suggesting mature security culture.

**Dependencies:**
- Pyth Network (oracle) -- critical dependency; failure would degrade price feeds but Switchboard/Chainlink provide redundancy.
- Jupiter (for JLP collateral pricing and Multiply swap routing) -- JLP vault exposure creates indirect dependency on Jupiter perps market.
- Solana runtime -- chain-level outages would halt all protocol operations (applies to all Solana protocols).

**Institutional Expansion:**
- February 2026 partnership with Anchorage Digital and Solana Company for institutional tri-party custody lending adds credibility but also introduces regulated-entity dependencies.

**Risk Rating: LOW.** Doxxed team with a multi-year track record, professional risk management via Allez Labs, and a substantial bug bounty program. The operational security posture is strong relative to Solana peers.

## Critical Risks

1. **No timelock on admin actions (HIGH):** The Squads multisig controlling program upgrades has no documented timelock. A compromised or colluding set of signers could push a malicious upgrade instantly. This is the single most significant risk in the protocol.
2. **Low multisig signer count (MEDIUM):** Fewer than 4 signers reported, though exact threshold is UNVERIFIED. A 2/3 or 3/3 multisig is meaningfully weaker than the 6/10 standard set by Aave's Guardian.
3. **No dedicated insurance fund (MEDIUM):** Socialized loss model means a large bad debt event would directly impact all lenders. With ~$1B in active borrows, a major collateral failure (e.g., JLP depeg) could create significant losses with no buffer.

## Peer Comparison

| Feature | Kamino (K-Lend) | MarginFi | Solend | Aave (reference) |
|---------|----------------|----------|--------|-------------------|
| Timelock | None documented | None documented | None documented | 24h / 168h |
| Multisig | Squads (<4 signers) | Squads (UNVERIFIED) | Multisig (UNVERIFIED) | 6/10 Guardian |
| Audits | 6+ (Certora, OtterSec, Sec3, Offside Labs) | Multiple | Multiple | 10+ firms |
| Oracle | Pyth + Switchboard + Chainlink | Pyth + Switchboard | Pyth + Switchboard | Chainlink + SVR |
| Insurance/TVL | Undisclosed (socialized) | Undisclosed | Undisclosed | ~2% Safety Module |
| Open Source | Yes | Yes | Yes | Yes |
| Bug Bounty | $1.5M (Immunefi) | Unknown | Unknown | $1M (Immunefi) |
| Formal Verification | Yes (Certora, OtterSec) | No | No | Yes (Certora) |

Note: The lack of timelocks appears to be a systemic issue across Solana lending protocols, not unique to Kamino. However, this does not reduce the risk -- it means the entire Solana lending ecosystem has a governance maturity gap relative to EVM peers.

## Recommendations

1. **For users depositing large amounts:** Monitor the governance forum and multisig transactions regularly. The absence of a timelock means malicious changes could be executed without advance warning.
2. **Diversify across lending protocols:** Do not concentrate all lending exposure in a single Solana protocol given the governance gaps across the ecosystem.
3. **Be cautious with Multiply (leverage) products:** JLP and LST looping strategies introduce compounding risk. Ensure you understand liquidation thresholds before using leverage.
4. **Watch for governance launch:** When KMNO on-chain governance goes live, verify that it includes meaningful timelock and that token concentration does not enable unilateral proposal passage.
5. **For the protocol team:** Implementing even a modest timelock (e.g., 24-48 hours) on program upgrades would materially reduce the admin key risk and bring Kamino closer to industry best practices.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? **YES** -- Risk Council can adjust parameters via multisig, no timelock
- [ ] Admin can change oracle sources arbitrarily? **YES** -- no documented constraint beyond multisig approval
- [ ] Admin can modify withdrawal limits? **LIKELY** -- Risk Council controls caps
- [x] Multisig has low threshold (2/N with small N)? **LIKELY** -- fewer than 4 signers reported
- [x] Zero or short timelock on governance actions? **YES** -- no timelock documented
- [ ] Pre-signed transaction risk (durable nonce on Solana)? **UNKNOWN**
- [ ] Social engineering surface area (anon multisig signers)? **PARTIALLY** -- team is doxxed but specific multisig signer identities are not publicly disclosed

**Drift-type risk: ELEVATED.** Multiple indicators are present. The saving grace is the multi-oracle design and doxxed team, which raise the bar for an attacker, but the governance architecture has meaningful overlap with the Drift exploit pattern.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? **PARTIALLY** -- KRAF evaluates assets but some vault tokens may have thin liquidity
- [ ] Single oracle source without TWAP? **NO** -- multi-oracle with TWAP/EWMA
- [ ] No circuit breaker on price movements? **NO** -- EWMA pricing rejects anomalous price moves
- [ ] Insufficient insurance fund relative to TVL? **YES** -- no dedicated insurance fund

**Euler/Mango-type risk: LOW-MODERATE.** The multi-oracle and TWAP/EWMA design strongly mitigates oracle manipulation vectors. The insurance fund gap is the main concern.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? **N/A** -- single-chain
- [ ] Admin keys stored in hot wallets? **UNKNOWN**
- [ ] No key rotation policy? **UNKNOWN**

**Ronin/Harmony-type risk: LOW.** No bridge dependencies. Key storage practices are unknown.

## Information Gaps

- **Exact multisig threshold and signer count:** The specific configuration of the Squads multisig (e.g., 2/3, 3/5) could not be verified from public sources. This is critical information.
- **Multisig signer identities:** While the team is doxxed, which specific individuals or entities are signers on the protocol multisig is not publicly disclosed.
- **Insurance fund details:** No specific insurance fund balance or mechanism (beyond socialized losses) is documented. The protocol's reserve factor allocation is unclear.
- **Timelock status:** Whether any form of delay mechanism exists on any admin action could not be confirmed. Public documentation and third-party analysis both indicate no timelock.
- **GoPlus token security:** Solana is not supported by the GoPlus token security API, so automated contract-level checks (honeypot, hidden owner, mintability, etc.) could not be performed on KMNO.
- **Key storage practices:** How multisig signer keys are stored (hardware wallets, HSMs, hot wallets) is not publicly documented.
- **Emergency bypass powers:** Whether the Risk Council has any emergency powers beyond the standard multisig (e.g., single-signer emergency pause) is unclear.
- **Formal governance timeline:** "Upcoming" DAO governance has no published launch date or specification.
- **Pre-signed transaction risk:** Whether durable nonces or pre-signed transactions are used in the multisig workflow is unknown (relevant to Drift-type attack pattern on Solana).
- **V2 audit coverage:** Whether the K-Lend V2 modular architecture (Market Layer, Vault Layer) has been fully audited post-launch is not explicitly confirmed.

## Disclaimer

This analysis is based on publicly available information and web research as of April 6, 2026.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
