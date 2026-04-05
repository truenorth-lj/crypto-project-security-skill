# DeFi Security Audit: EigenLayer

**Audit Date:** April 5, 2026
**Protocol:** EigenLayer (now branded EigenCloud) -- Ethereum restaking protocol

## Overview
- Protocol: EigenLayer
- Chain: Ethereum
- Type: Restaking
- TVL: ~$8.26B (DeFiLlama, April 2026)
- TVL Trend: Down from peak of ~$28.6B in mid-2025; currently stabilized around $8B
- Launch Date: June 2023 (mainnet Stage 1)
- Audit Date: April 5, 2026
- Source Code: Open (GitHub -- Layr-Labs organization)

## Quick Triage Score: 72/100
- Red flags found: 1 (systemic cascading risk from AVS slashing model)
- GoPlus token security: 0 HIGH / 1 MEDIUM flag (proxy contract only)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Not disclosed | 1-5% | UNVERIFIED |
| Audit Coverage Score | 14+ audits (high recency, multiple firms) | 1-3 avg | LOW risk |
| Governance Decentralization | Protocol Council + Community Multisig + Operations Multisig | Multisig avg | LOW risk |
| Timelock Duration | 10-day minimum (primary timelock) | 24-48h avg | LOW risk |
| Multisig Threshold | 9/13 (Community), 3/5 (Protocol Council), 3/6 (Operations) | 3/5 avg | LOW risk |
| Bug Bounty | $2M via Immunefi | $250K avg | LOW risk |
| GoPlus Risk Flags | 0 HIGH / 1 MED | -- | LOW risk |

## GoPlus Token Security (EIGEN on Ethereum)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | Yes (upgradeable) | MEDIUM |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Transfer Tax | 0% | -- |
| Cannot Buy | No | -- |
| Cannot Sell All | No | -- |
| Hidden Owner | No (owner_address empty) | -- |
| Creator Honeypot History | No | -- |
| CEX Listed | Binance, Coinbase | -- |
| Holders | 224,404 | -- |
| Top Holder Concentration | ~10.6% (top holder) | -- |
| Total Supply | 1,810,657,584 EIGEN | -- |

GoPlus assessment: **LOW RISK**. The only flag is the proxy (upgradeable) pattern, which is expected for a governance-controlled protocol. No honeypot, no hidden owner, no trading taxes, no trading restrictions. Token is listed on Binance and Coinbase. Holder distribution is moderately concentrated with the largest holder at ~10.6%, consistent with smart contract addresses (likely staking/vesting contracts).

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **LOW** | 3-tier multisig (9/13, 3/5, 3/6) with 10-day timelock; emergency override exists | Y |
| Oracle & Price Feeds | **LOW** | Not a lending protocol; no price oracle dependency for core restaking | Y |
| Economic Mechanism | **HIGH** | AVS slashing model introduces cascading risk; AVS-defined slashing conditions | Partial |
| Smart Contract | **LOW** | 14+ audits from SigmaPrime, Certora, Hexens, Dedaub, Consensys, Code4rena; $2M bounty | Y |
| Token Contract (GoPlus) | **LOW** | Proxy only (governance-controlled); no honeypot, no hidden owner, no tax | Y |
| Operational Security | **MEDIUM** | $5.7M email phishing incident (Oct 2024); team doxxed; strong response | Y |
| **Overall Risk** | **MEDIUM** | **Strong governance and audit coverage offset by novel systemic slashing risk** | |

## Detailed Findings

### 1. Governance & Admin Key -- LOW

EigenLayer employs a robust three-tier governance architecture:

- **Community Multisig:** 9-of-13 threshold composed of Ethereum community members. Acts primarily as an observer/emergency override. Can execute emergency upgrades or replace the timelock in the event of private key compromise.
- **Protocol Council:** 3-of-5 Gnosis Safe that executes routine upgrades through the primary timelock (0xC06Fd4F821eaC1fF1ae8067b36342899b57BAa2d) with a mandatory 10-day delay on all safety-critical functions.
- **Operations Multisig:** 3-of-6 multisig operated by Eigen Labs for proposing routine upgrades and pausing functionality in emergencies. Holds canceler role on the timelock, providing a check on Protocol Council actions.

The ELIP (EigenLayer Improvement Proposal) process governs protocol changes through the Eigen Foundation.

**Key strength:** The 10-day timelock is among the longest in DeFi, significantly exceeding the industry average of 24-48 hours. The three-tier separation of powers prevents any single entity from unilateral action.

**Key concern:** The Community Multisig retains emergency powers to bypass the timelock. While this is a standard pattern for critical protocols, it means 9 of 13 community signers can theoretically execute immediate upgrades.

### 2. Oracle & Price Feeds -- LOW

EigenLayer's core restaking mechanism does not rely on price oracles in the traditional sense. Unlike lending protocols, there are no liquidation thresholds triggered by price feeds. ETH is restaked at par value.

Individual AVSs (Actively Validated Services) may implement their own oracle dependencies, but these are outside EigenLayer's core protocol scope. The risk from oracle manipulation at the AVS layer does not directly threaten EigenLayer's core deposits, though it could trigger slashing events.

### 3. Economic Mechanism -- HIGH

The economic mechanism carries the highest risk in the protocol due to the novel restaking and slashing model:

- **Slashing (launched April 2025):** AVSs define their own slashing conditions and operational assumptions. Faulty logic, bugs, or overly punitive rules in any AVS could lead to unintended losses for restakers.
- **Unique Stake model:** Operators can limit exposure to specific AVSs, isolating slashing risk per-AVS. However, operators supporting multiple AVSs face compounded exposure.
- **Cascading risk:** If multiple AVSs rely on the same operator/validator set and a large validator is penalized, several services could degrade simultaneously. Critics compare this to systemic risk in traditional finance.
- **Yield layering:** Restaked assets flowing through LRT (Liquid Restaking Token) protocols and lending loops create derivative stacks where a single breach can cascade across protocols.
- **Insurance fund:** No publicly disclosed insurance fund covering slashing losses. Individual AVSs and operators bear the risk. UNVERIFIED whether Eigen Foundation maintains any backstop fund.
- **Token unlock pressure:** 29.5% allocated to investors and 25.5% to early contributors with cliff vesting. Significant unlocks continue through 2026 (e.g., 36.8M EIGEN unlocked October 2025, another 36.8M February 2026).

### 4. Smart Contract Security -- LOW

EigenLayer has one of the most extensive audit histories in DeFi:

- **14+ third-party audits** from: SigmaPrime (7+ audits), Certora (2+ formal verification audits), Hexens, Dedaub, Consensys Diligence, Code4rena
- **Audit recency:** Most recent audits in February-May 2025 (SigmaPrime, Certora, Hexens, Dedaub)
- **Bug bounty:** $2M via Immunefi
- **Open source:** Full codebase on GitHub (Layr-Labs organization)
- **Formal verification:** Certora integration for critical contract invariants

The breadth and recency of audit coverage is among the best in the industry.

### 5. Operational Security -- MEDIUM

- **Team:** Eigen Labs is a known entity. Founder Sreeram Kannan is a fully doxxed former University of Washington professor.
- **October 2024 incident:** $5.7M lost when an attacker infiltrated an email thread between an investor and custodial service, redirecting token transfers. EigenLayer confirmed the incident was isolated (email phishing, not a protocol vulnerability). SlowMist investigated. Stolen tokens were swapped via MetaMask and sent to centralized exchanges.
- **Historical incidents:** A separate ~$821K loss in 2023 and a ~$405K fake EigenLayer token rugpull in 2024 are unrelated to the core protocol.
- **Incident response:** EigenLayer engaged law enforcement and contracted SlowMist for investigation. Communication was transparent and timely.

The email phishing incident, while not a protocol vulnerability, indicates operational security gaps in token distribution workflows.

## Critical Risks

1. **AVS Slashing Cascading Risk (HIGH):** The novel AVS slashing model allows each AVS to define its own slashing conditions. A malicious or buggy AVS could trigger unintended slashing of restaked ETH. While the Unique Stake model provides isolation, the ecosystem is still young and untested at scale.

2. **Systemic Importance (MEDIUM):** At $8B+ TVL and as the dominant restaking protocol (93.9% market share), EigenLayer is a single point of systemic concern for Ethereum. A major exploit could impact staked ETH yields and LSD peg stability across the ecosystem.

## Peer Comparison

| Feature | EigenLayer | Symbiotic | Karak |
|---------|-----------|-----------|-------|
| TVL | ~$8.26B | ~$897M | ~$102M |
| Market Share | ~93.9% | ~5.5% | ~0.6% |
| Chains | Ethereum | Ethereum | Multi-chain |
| Asset Support | ETH, LSTs | Permissionless (any ERC-20) | ETH, LSTs, LPs, stablecoins |
| Slashing | Launched (April 2025), AVS-defined | Veto committees, resolvers | Not yet disclosed |
| Timelock | 10 days | UNVERIFIED | UNVERIFIED |
| Audits | 14+ | UNVERIFIED | UNVERIFIED |
| Governance | 3-tier multisig + ELIP process | Permissionless modular | UNVERIFIED |
| Open Source | Yes | Yes | Partial |

EigenLayer leads peers in TVL, audit coverage, and governance maturity. Symbiotic offers greater permissionlessness and modularity. Karak differentiates through multi-asset and multi-chain support but has the least transparent security posture.

## Recommendations

1. **For restakers:** Understand that slashing risk varies by AVS. Evaluate each AVS's slashing conditions before delegating to operators that support them. Prefer operators with conservative AVS portfolios.
2. **For operators:** Limit exposure per-AVS using the Unique Stake model. Monitor AVS slashing logic for bugs or adversarial conditions.
3. **Monitor token unlocks:** Significant EIGEN token unlocks continue through 2026. These supply events may create sell pressure.
4. **Insurance gap:** The absence of a publicly disclosed protocol-level insurance fund is a concern given the TVL size. Monitor for any Eigen Foundation backstop announcements.
5. **Operational security:** The October 2024 email phishing incident suggests custodial and token distribution workflows should be hardened with out-of-band verification.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock -- **NO**, requires Protocol Council + 10-day timelock
- [ ] Admin can change oracle sources arbitrarily -- **N/A**, core protocol does not use price oracles
- [ ] Admin can modify withdrawal limits -- **NO**, withdrawals governed by protocol logic + timelock
- [ ] Multisig has low threshold -- **NO**, 9/13 (Community), 3/5 (Protocol Council)
- [ ] Zero or short timelock -- **NO**, 10-day minimum
- [ ] Pre-signed transaction risk -- **N/A**, EVM-based
- [ ] Social engineering surface area -- **LOW**, doxxed team + high threshold (9/13)

**0/7 flags matched.**

### Euler/Mango-type (Economic Exploit / Oracle Manipulation):
- [ ] Low-liquidity collateral accepted -- **NO**, core protocol accepts only ETH and established LSTs
- [ ] Single oracle source without TWAP -- **N/A**, no price oracle dependency in core protocol
- [ ] No circuit breaker -- Operations Multisig can pause protocol
- [ ] Insufficient insurance -- **YES**, no disclosed protocol-level insurance fund

**1/4 flags matched.** Insurance fund absence is the only concern.

### Ronin/Harmony-type (Bridge / Validator Key Compromise):
- [ ] Small validator set -- **NO**, 1,500+ operators
- [ ] Validator keys stored hot -- **UNVERIFIED**, operator key management varies
- [ ] No key rotation mechanism -- **UNVERIFIED**
- [ ] Bridge dependency -- **NO**, Ethereum-native only

**0-2/4 flags matched.** Operator key management is not standardized and varies by operator.

## Information Gaps

The following could not be verified during this audit:

1. **Insurance fund details:** No public documentation of a protocol-level insurance or backstop fund covering slashing losses.
2. **Operator key management standards:** No standardized requirement for how operators store and rotate their signing keys.
3. **AVS slashing audit coverage:** Individual AVS slashing logic may not have been audited to the same standard as the core protocol.
4. **Community Multisig signer identities:** While described as "Ethereum community members," the full list of 13 signers and their identities is not publicly disclosed. UNVERIFIED.
5. **Emergency action history:** No public record of whether the Community Multisig emergency bypass has ever been used.
6. **Exact circulating supply breakdown:** Token allocation percentages vary across sources (38.5% to 45% circulating). Exact locked vs. circulating amounts are difficult to verify independently.

## Disclaimer

This report is an informational security assessment, not a formal audit. It is based on publicly available data from DeFiLlama, GoPlus Security API, EigenLayer documentation, CertiK Skynet, and web research as of April 5, 2026. It does not constitute financial advice. Smart contract interactions carry inherent risk. Users should perform their own due diligence before restaking assets. The absence of identified vulnerabilities does not guarantee protocol safety.
