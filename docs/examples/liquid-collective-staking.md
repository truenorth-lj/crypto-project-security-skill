# DeFi Security Audit: Liquid Collective (LsETH)

**Audit Date:** 2026-04-21
**Protocol:** Liquid Collective -- Institutional liquid staking protocol on Ethereum

## Overview
- Protocol: Liquid Collective (LsETH)
- Chain: Ethereum
- Type: Liquid Staking Derivative (institutional-grade, enterprise node operator consortium)
- TVL: ~$0.81B (DeFiLlama)
- TVL Trend: Stable, with deposits coming primarily from institutional platforms (Coinbase Prime, Bitcoin Suisse, Figment, Alluvial, etc.).
- Launch Date: 2023
- Token Contract (Ethereum): `0x8c1BEd5b9a0928467c9B1341Da1D7BD5e10b6549`
- Audit Date: 2026-04-21
- Source Code: Open (github.com/LiquidCollective)

## Quick Triage Score: 82/100
- Red flags found: Consortium governance (fewer node operators than Lido); proxy with council-controlled admin.
- GoPlus token security: 0 HIGH / 1 MEDIUM flag (proxy).

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Institutional operator slashing coverage (Nexus Mutual / Unslashed style, UNVERIFIED current) | 1-5% | MEDIUM |
| Audit Coverage Score | Multiple firms (audit index at liquidcollective.io/security-audits; DeFiLlama reports 2, repo lists more) | 1-3 avg | LOW risk |
| Governance Decentralization | Protocol Service Provider Council (consortium of enterprise teams) | DAO + multisig avg | MEDIUM risk |
| Timelock Duration | Upgrade timelock present (UNVERIFIED exact seconds) | 24-48h avg | LOW-MEDIUM risk |
| Multisig Threshold | Consortium-controlled multisig (UNVERIFIED threshold) | 3/5 avg | MEDIUM risk |
| GoPlus Risk Flags | 0 HIGH / 1 MED (proxy) | -- | LOW risk |

## GoPlus Token Security (LsETH on Ethereum)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | Yes (upgradeable) | MEDIUM |
| Mintable | N/A (minted via River contract on deposit) | -- |
| Owner Address | Empty in GoPlus output (council-controlled via multisig) | LOW |
| Hidden Owner | No | -- |
| Selfdestruct | No | -- |
| Transfer Pausable | Not flagged | -- |
| Blacklist | Not flagged at token level | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 910 | -- |
| Total Supply | ~317,071 LsETH | -- |

GoPlus assessment: **LOW RISK**. Standard proxy pattern governed by the Liquid Collective council. The relatively low holder count (910) reflects LsETH's institutional positioning -- LsETH is primarily held by professional custodians and platforms, not retail wallets.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | Consortium (Protocol Service Provider Council) rather than open DAO | Y |
| Oracle & Price Feeds | **LOW-MEDIUM** | Oracle committee reports validator rewards with quorum | Partial |
| Economic Mechanism | **LOW** | Non-rebasing LsETH; standard SSV / enterprise validator architecture | Y |
| Smart Contract | **LOW** | Multiple audits, open-source, live since 2023 without exploit | Y |
| Token Contract (GoPlus) | **LOW** | Proxy only; no honeypot/tax | Y |
| Operational Security | **LOW** | Consortium of well-known web3 firms (Figment, Alluvial, Coinbase, Kiln, etc.) | Y |
| **Overall Risk** | **MEDIUM** | **Institutional-grade LSD; strong operational baseline, narrower governance than Lido** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**Consortium Governance:**
- Liquid Collective is governed by a "Protocol Service Provider Council" composed of enterprise web3 firms contributing to operation (historically: Alluvial, Figment, Kiln, Coinbase Cloud, Bitcoin Suisse, Staked, Blockdaemon, Hashnote, etc.).
- This is a deliberate design choice: Liquid Collective targets institutional users who often cannot interact with permissionless DAO governance for compliance reasons.

**Admin Control:**
- Protocol upgrades and parameter changes are executed via council multisig with an associated timelock.
- Exact multisig threshold and signer set at time of audit are UNVERIFIED from public sources.

**Emergency Functions:**
- The protocol has pause capability for emergency scenarios. Scope and authority path are documented at a high level in Liquid Collective's security docs.

**KYC / Allow-list:**
- Deposits occur through platform integrators (Coinbase Prime, Bitcoin Suisse, etc.) that perform their own KYC. The LsETH token itself is transferable, but direct deposits into Liquid Collective are typically permissioned at the platform layer rather than the contract layer.

**Assessment:** MEDIUM. The consortium model provides strong operational accountability (each council member is a known, reputable enterprise) but is narrower than a true DAO. From a Drift-style governance-attack perspective, the attack surface is smaller (fewer signers to compromise) but signers are individually higher-quality targets for social engineering. Net: MEDIUM.

### 2. Oracle & Price Feeds -- LOW-MEDIUM

**Oracle Architecture:**
- Liquid Collective uses an Oracle Manager contract that accepts reports from an oracle committee; quorum is required to finalize validator balance updates.
- Oracle members are drawn from the Protocol Service Provider Council.

**Reporting:**
- Validator balance and reward data is posted on a regular cadence (epoch/frame based).
- Exact committee size, quorum threshold, and reporting frequency at time of audit are UNVERIFIED from the public sources reviewed.

**DeFi Integrations:**
- Chainlink-style exchange-rate feeds are used downstream by integrating protocols (where LsETH is used as collateral).

**Assessment:** LOW-MEDIUM. The committee-based oracle design is structurally sound. The MEDIUM component comes from unverified exact parameters and the fact that the oracle committee is drawn from the same set of entities as the governance council (common-mode dependency).

### 3. Economic Mechanism -- LOW

**Staking Model:**
- Users (typically institutional platforms) deposit ETH via River (the main pool contract), receive LsETH (non-rebasing, appreciating relative to ETH).
- Yield accrues into the LsETH/ETH exchange rate.

**Fees:**
- Protocol fee on rewards; split between node operators, council members, and protocol treasury. Exact split UNVERIFIED.

**Withdrawals:**
- Post-Shapella, Liquid Collective supports redemptions through a Redeem Manager contract that queues and processes exits on the Ethereum exit queue.

**Node Operator Set:**
- Institutional node operators only (members of the council + vetted partners). Smaller and more concentrated than Lido's 600+ operators, but all are reputable enterprises with strong operational practices.
- Historically uses distributed validator infrastructure (DVT, e.g., SSV Network) for some node operator setups to reduce single-operator risk.

**Insurance / Slashing Coverage:**
- Node operators contractually cover slashing via operator-level bonds and SLAs.
- Coverage through external slashing insurance partners (historical integrations with Nexus Mutual and Unslashed Finance have been discussed in Liquid Collective materials; current active coverage UNVERIFIED).

**Assessment:** LOW. Mechanically clean, institutional-grade, with explicit operator-level slashing accountability.

### 4. Smart Contract Security -- LOW

**Audit Firms:**
- Liquid Collective maintains a security audit index at liquidcollective.io/security-audits.
- Historical audit firms include Trail of Bits, Halborn, Quantstamp, and others.
- DeFiLlama lists 2 top-level audits; the vendor index at the project site references additional reports.

**Upgradeable Contracts:**
- Core contracts (River, LsETH token, Oracle Manager, Redeem Manager, etc.) are proxy-based and upgrade via council multisig + timelock.

**Bug Bounty:**
- Bug bounty program presence is referenced in Liquid Collective documentation; current platform (Immunefi) and maximum payout at time of audit are UNVERIFIED.

**Battle Testing:**
- Live since 2023. No protocol-level exploits or user fund losses publicly reported.
- Successfully executed post-Shapella withdrawals upgrade.

**Assessment:** LOW. The audit coverage is strong for a ~$0.8B LSD, the code base is open, and the operational record is clean.

### 5. Operational Security -- LOW

**Team / Council Members:**
- The Protocol Service Provider Council includes some of the most established institutional staking firms globally (Alluvial, Kiln, Figment, Coinbase Cloud, Bitcoin Suisse, Blockdaemon, Staked, and others historically).
- All council members are well-known, regulated or regulated-adjacent entities with public leadership and compliance teams.

**Incident History:**
- No publicly reported protocol-level incidents. Individual operator-level issues would be contained via operator bonds/SLAs.
- Successfully integrated with Coinbase Prime and other institutional distribution channels.

**Transparency:**
- Open-source code on GitHub.
- Public security audit index.
- Council membership publicly listed.

**Assessment:** LOW. This is arguably the strongest operational-security profile of any LSD audited in this round, given the council's collective reputation and regulatory standing.

## Critical Risks

None identified. The governance concentration is a structural characteristic rather than a critical flaw.

## Peer Comparison

| Feature | Liquid Collective (LsETH) | Lido stETH | StakeWise V2 | Coinbase cbETH |
|---------|---------------------------|------------|--------------|-----------------|
| TVL | ~$0.81B | ~$19B | ~$0.9B | ~$5B (UNVERIFIED) |
| Governance | Consortium council + multisig | DAO + Dual Governance | SWISE DAO | Coinbase (centralized) |
| Node Operators | Curated institutional consortium | 600+ curated + permissionless | Curated | Coinbase-operated |
| Oracle | Committee quorum | 5-of-9 | Committee quorum | Coinbase-operated |
| Audits (public index) | Multiple (Trail of Bits, Halborn, etc.) | 10+ firms + formal verification | Multiple | Coinbase + external |
| Withdrawals | Yes (Redeem Manager) | Native (V2+) | Yes | Native |
| User Profile | Institutional / platform | Retail + DeFi | Retail + DeFi | Retail (Coinbase users) |

## Recommendations

1. **Publish council multisig threshold and signer list with rotation cadence**: Transparent publication of exact threshold and signers would materially improve governance auditability.
2. **Publish oracle committee composition**: Current members, quorum threshold, and rotation cadence should be explicit in public docs.
3. **Clarify slashing insurance status**: Liquid Collective has historically discussed external insurance; whether coverage is currently active and at what coverage ratio should be explicit.
4. **Maintain bug bounty visibility**: Confirm current bug-bounty platform and maximum payout.
5. **Users**: Liquid Collective's institutional positioning and consortium operators are credible strengths. Institutional users gain a well-regulated LSD choice; individual users should be aware that the consortium-governance model means fewer checks than a full DAO.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock -- **N/A**, not a lending protocol
- [ ] Admin can change oracle sources arbitrarily -- **NO**, requires council vote
- [ ] Admin can modify withdrawal limits -- **NO**, governed by Redeem Manager / Ethereum exit queue
- [x] Multisig has low threshold -- **UNVERIFIED** (council multisig threshold not published)
- [ ] Zero or short timelock -- **NO** (timelock present; exact UNVERIFIED)
- [ ] Pre-signed transaction risk -- **N/A**, EVM
- [x] Social engineering surface area -- **MEDIUM**, small council of high-profile firms is a concentrated target

**1-2/7 flags matched**. Governance architecture is solid; remaining gaps are transparency items.

### Euler/Mango-type (Oracle Manipulation + Economic Exploit):
- [ ] Low-liquidity collateral accepted -- **N/A**
- [ ] Single oracle source without TWAP -- **NO**, committee quorum
- [ ] No circuit breaker -- Pause mechanism present
- [ ] Insufficient insurance -- Operator bonds + external coverage (exact ratio UNVERIFIED)

**0-1/4 flags matched**.

### Ronin/Harmony-type (Bridge / Validator Key Compromise):
- [x] Small validator/signer set -- **BORDERLINE**, institutional operator set is smaller than Lido but enterprise-grade
- [ ] Keys stored in hot wallets -- **NO**, enterprise operators use HSM / MPC
- [ ] Single point of failure in bridge -- **N/A**, no bridge
- [ ] No key rotation mechanism -- Operator-managed, enterprise-grade

**1/4 flags matched**.

## Information Gaps

- **Council multisig threshold and current signer list**: Not publicly detailed at time of audit.
- **Exact upgrade timelock duration**: Present but duration not verified.
- **Oracle committee composition and quorum**: Current members and m-of-n threshold not verified.
- **Fee split**: Exact split between node operators, council members, and protocol treasury not verified.
- **Slashing insurance coverage**: Whether external insurance is currently active, at what coverage amount, and with which provider.
- **Bug bounty scope**: Platform, scope, and maximum payout not verified.
- **Redeem Manager queue caps**: Any withdrawal-rate limits or emergency caps not explicitly verified.

## Disclaimer

This is a research-based assessment, not a formal smart contract audit. It is based on publicly available information, on-chain data, DeFiLlama metrics, and GoPlus token security scanning as of 2026-04-21. DYOR.
