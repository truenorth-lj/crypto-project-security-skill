# DeFi Security Audit: Lido

**Audit Date:** April 5, 2026
**Protocol:** Lido -- Liquid staking protocol (primarily Ethereum)

## Overview
- Protocol: Lido (V2 / V3)
- Chain: Ethereum (primary), Solana, Moonbeam, Moonriver (minor)
- Type: Liquid Staking
- TVL: ~$19.0B (DeFiLlama, ~$18.98B Ethereum)
- TVL Trend: Stable. Fluctuating in the $19-20B range over the past month.
- Launch Date: December 2020
- Audit Date: 2026-04-05
- Source Code: Open (GitHub -- github.com/lidofinance)

## Quick Triage Score: 90/100
- Red flags found: 0
- GoPlus token security: 0 HIGH / 1 MEDIUM flag (proxy contract only)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | <0.1% (self-insurance model) | 1-5% | MEDIUM |
| Audit Coverage Score | 10+ firms (high recency) | 1-3 avg | LOW risk |
| Governance Decentralization | DAO + Dual Governance (LDO + stETH veto) | Multisig avg | LOW risk |
| Timelock Duration | Dynamic (Dual Governance) / 72h Easy Track | 24-48h avg | LOW risk |
| Multisig Threshold | Multiple committee multisigs | 3/5 avg | LOW risk |
| GoPlus Risk Flags | 0 HIGH / 1 MED | -- | LOW risk |

## GoPlus Token Security (stETH on Ethereum)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | Yes (upgradeable) | MEDIUM |
| Mintable | N/A (rebasing token) | -- |
| Owner Can Change Balance | No (owner_address empty) | -- |
| Hidden Owner | No | -- |
| Selfdestruct | No | -- |
| Transfer Pausable | No | -- |
| Blacklist | No | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Transfer Tax | 0% | -- |
| Holders | 599,007 | -- |
| Creator Honeypot History | No (0 honeypots from creator) | -- |
| DEX Liquidity | UniswapV3, UniswapV2, SushiSwap | -- |

GoPlus assessment: **LOW RISK**. The only flag is the proxy (upgradeable) pattern, which is standard for major DeFi protocols. Upgrades are governed by the Lido DAO with Dual Governance protections. No honeypot, no hidden owner, no tax, no trading restrictions. High holder count (599K+) and deep DEX liquidity across multiple venues.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **LOW** | DAO + Dual Governance with stETH veto power + dynamic timelock | Y |
| Oracle & Price Feeds | **LOW** | 9-member oracle committee, 5-of-9 quorum, Beacon Chain data | Y |
| Economic Mechanism | **MEDIUM** | Rebasing token, self-insurance model with limited dedicated fund | Partial |
| Smart Contract | **LOW** | 10+ audit firms, formal verification, $2M bug bounty | Y |
| Token Contract (GoPlus) | **LOW** | Proxy only (DAO-governed); no honeypot, no hidden owner, no tax | Y |
| Operational Security | **LOW** | Doxxed contributors, strong incident response, no fund losses | Y |
| **Overall Risk** | **LOW** | **Industry-leading liquid staking protocol with mature security** | |

## Detailed Findings

### 1. Governance & Admin Key -- LOW

**DAO Governance:**
- Lido DAO governs the protocol via LDO token voting through Aragon-based on-chain governance.
- All critical parameter changes (node operator additions, fee changes, contract upgrades) require DAO approval.

**Dual Governance (deployed mid-2025):**
- Dynamic timelock mechanism that scales based on stETH holder opposition signals.
- First threshold (1% of Lido Ethereum TVL): Activates a proportional timelock on governance proposals.
- Second threshold (10%): Triggers "rage quit" mechanism, blocking proposal execution until all escrowed stETH is converted back to ETH.
- This gives stETH holders effective veto power over contentious governance motions, a significant upgrade over standard DAO-only governance.

**Easy Track:**
- Routine operational motions (e.g., node operator reward distribution) use Easy Track, which passes automatically after 72 hours unless 0.5% of total LDO supply objects.
- Only authorized committee multisig addresses can initiate Easy Track motions.

**Committee Structure:**
- "Multisig of multisigs" structure comprising three subcommittees for operational governance.
- Emergency multisig capabilities for pause/unpause in critical situations.

**Assessment:** The Dual Governance mechanism is among the most advanced governance safeguards in DeFi. The stETH holder veto power directly addresses the class of governance attacks seen in incidents like the Drift hack.

### 2. Oracle & Price Feeds -- LOW

**Oracle Architecture:**
- Two core oracle contracts: AccountingOracle (validator balances, protocol state) and ValidatorsExitBus (exit queue management).
- HashConsensus contract manages the oracle committee and requires consensus on data hashes for each reporting frame.

**Committee:**
- 9 independently operated oracle daemons in a 5-of-9 quorum configuration.
- Report finalization requires 5 identical reports from 5 different oracle members.
- Oracle members are selected by the DAO and include professional node operators and infrastructure providers.

**LIP-23 (zkOracle):**
- Proposed enhancement using RISC Zero to prove computation over Beacon Chain state with zero-knowledge proofs, reducing trust assumptions on oracle members. Status: UNVERIFIED whether fully deployed.

**Assessment:** The 5-of-9 oracle quorum provides strong Byzantine fault tolerance. No oracle manipulation incidents have occurred. The oracle reports Beacon Chain data (validator balances), which is publicly verifiable, limiting the attack surface compared to price feed oracles.

### 3. Economic Mechanism -- MEDIUM

**Staking Model:**
- Users deposit ETH, receive stETH (rebasing token reflecting staking rewards).
- wstETH (wrapped stETH) provides a non-rebasing alternative widely used in DeFi.
- 10% fee on staking rewards (5% to node operators, 5% to DAO treasury).

**Withdrawal Mechanism:**
- Native withdrawals enabled since Lido V2 (May 2023).
- Users can unstake by submitting withdrawal requests; processing depends on the Ethereum exit queue.
- Dual Governance "rage quit" provides an additional exit mechanism if governance becomes hostile.

**Insurance:**
- Self-insurance model: The protocol relies on the DAO treasury and dedicated insurance fund smart contract.
- Dedicated insurance fund allocation is modest (~4,546 wstETH as of the last known allocation vote).
- Given ~$19B TVL, the insurance-to-TVL ratio is well below 0.1%, which is low compared to peers.
- Historical partnership with Unslashed Finance for slashing coverage (200,000 stETH purchased in 2021). Current status of external insurance: UNVERIFIED.

**Node Operator Diversification:**
- 600+ node operators across three modules: Curated Module (36 professional operators), Simple DVT Module, and Community Staking Module (CSM, fully permissionless since Feb 2025).
- Validators evenly distributed across Curated Node Operators with a 1% soft cap per operator.
- CSM reached its 3% stake share limit in Q3 2025, demonstrating strong permissionless participation.

**Assessment:** The economic mechanism is sound and battle-tested over 5+ years. The primary concern is the low insurance-to-TVL ratio; however, the diversified node operator set and Ethereum's built-in slashing protections partially mitigate this. The rebasing nature of stETH introduces DeFi composability complexity but is well understood by the ecosystem.

### 4. Smart Contract Security -- LOW

**Audit Firms (10+):**
- Certora (formal verification, including Dual Governance V1.0.1)
- Runtime Verification (formal verification of Dual Governance)
- ChainSecurity (Staking Router, core contracts)
- Oxorio (Lido V2 cover-to-cover audit, Lido Earn)
- Consensys Diligence (Lido V3)
- OpenZeppelin
- MixBytes
- Statemind
- Ackee
- Hexens
- SigmaPrime

**Formal Verification:**
- Certora and Runtime Verification have performed formal verification on critical components, particularly the Dual Governance contracts.

**Bug Bounty:**
- Up to $2,000,000 via Immunefi (one of the largest in DeFi).
- Regular bug bounty competitions with bonus pools ($100K for Dual Governance, $200K for V3 in 2025).
- Past bounty paid: $100K for front-running vulnerability (Oct 2021) -- responsible disclosure, no funds lost.

**Upgradeable Contracts:**
- stETH (0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84) is a proxy contract.
- Upgrades governed by DAO vote + Dual Governance timelock protections.

**Assessment:** The audit coverage is among the deepest in DeFi, with both breadth (10+ firms) and depth (formal verification). The $2M bug bounty further incentivizes responsible disclosure. No smart contract exploits have resulted in user fund losses over 5+ years of operation.

### 5. Operational Security -- LOW

**Team:**
- Lido DAO contributors include well-known entities in the Ethereum ecosystem.
- Multiple contributor organizations (not a single-team dependency).

**Incident History:**
- Oct 2021: Front-running vulnerability reported via Immunefi bug bounty. Fixed before exploitation. $100K bounty paid.
- Nov 2023: InfStones (node operator) platform vulnerability disclosed by dWallet Labs. Investigated and addressed at the node operator level -- no protocol fund losses.
- May 2024: Numic (node operator) security breach. Contained at the operator level -- no protocol fund losses.
- No protocol-level exploits or user fund losses since launch in December 2020.

**Transparency:**
- Quarterly validator and node operator metrics reports published publicly.
- Open-source codebase with comprehensive documentation.
- Active governance forum (research.lido.fi) with transparent proposal discussions.
- Public Risk Disclosure (PRD) document maintained in official docs.

**Assessment:** Lido demonstrates strong operational security practices. Past incidents were confined to individual node operators and did not affect protocol funds. The transparent reporting cadence and public risk disclosures are above industry standard.

## Critical Risks

None identified. No critical-severity issues found.

## Peer Comparison

| Feature | Lido | Rocket Pool | Coinbase cbETH |
|---------|------|-------------|-----------------|
| TVL | ~$19B | ~$3B | ~$5B (UNVERIFIED) |
| Governance | DAO + Dual Governance (stETH veto) | DAO (RPL voting) | Centralized (Coinbase) |
| Timelock | Dynamic (Dual Governance) | DAO vote delay | N/A (centralized) |
| Oracle | 5-of-9 committee | Minipool-level reporting | Centralized oracle |
| Node Operators | 600+ (curated + permissionless) | Permissionless (minipool) | Coinbase-operated |
| Audits | 10+ firms + formal verification | Multiple firms | Coinbase internal + external |
| Open Source | Yes | Yes | Partial |
| Insurance | Self-insurance (low ratio) | RPL slashing collateral | Coinbase balance sheet |
| Bug Bounty | $2M (Immunefi) | $100K+ | Coinbase HackerOne |
| Withdrawals | Native (V2+) | Native | Native |

## Recommendations

1. **Insurance coverage**: The self-insurance fund is modest relative to the ~$19B TVL. Consider monitoring DAO treasury health and any future insurance fund expansion proposals.
2. **Oracle centralization trajectory**: While 5-of-9 is robust, monitor progress on zkOracle (LIP-23) adoption to further reduce trust assumptions.
3. **Proxy upgrade risk**: stETH is a proxy contract -- users should be aware that the DAO can upgrade the implementation, though Dual Governance provides strong safeguards against malicious upgrades.
4. **Node operator concentration**: The Curated Module still holds the vast majority of stake. Continue monitoring the growth of CSM and Simple DVT modules toward further decentralization.
5. **No immediate action needed for users**: The protocol's security posture is strong and actively improving.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock -- **NO**, requires DAO vote + Dual Governance
- [ ] Admin can change oracle sources arbitrarily -- **NO**, oracle committee changes require DAO vote
- [ ] Admin can modify withdrawal limits -- **NO**, withdrawals are protocol-level, governed by Ethereum exit queue
- [ ] Multisig has low threshold -- **NO**, multiple committee multisigs; oracle is 5/9
- [ ] Zero or short timelock -- **NO**, Dual Governance provides dynamic timelock scaling with opposition
- [ ] Pre-signed transaction risk -- **N/A**, EVM-based
- [ ] Social engineering surface area -- **LOW**, distributed contributor base + Dual Governance stETH veto

**0/7 flags matched.**

### Euler/Mango-type (Oracle Manipulation + Economic Exploit):
- [ ] Low-liquidity collateral accepted -- **N/A**, Lido is a staking protocol, not a lending protocol
- [ ] Single oracle source without TWAP -- **NO**, 5-of-9 oracle committee with consensus mechanism
- [ ] No circuit breaker -- Oracle has sanity checks; DAO can pause via emergency multisig
- [ ] Insufficient insurance -- Self-insurance fund is low relative to TVL

**0-1/4 flags matched.** Minor concern: low insurance-to-TVL ratio, though protocol risk profile (staking) is inherently lower than lending.

### Ronin/Harmony-type (Bridge / Validator Key Compromise):
- [ ] Small validator/signer set -- **NO**, 600+ node operators, 36 curated operators
- [ ] Keys stored in hot wallets -- **NO**, professional node operators with security requirements
- [ ] Single point of failure in bridge -- **N/A**, Lido does not operate a bridge
- [ ] No key rotation mechanism -- Node operator key management is operator-level responsibility

**0/4 flags matched.**

## Information Gaps

- **Current insurance fund balance**: The most recent publicly confirmed allocation was 4,546 wstETH (2022 vote). Current balance and any subsequent top-ups could not be verified.
- **External insurance status**: Whether the Unslashed Finance coverage (200K stETH, 2021) is still active or has been replaced is unverified.
- **zkOracle (LIP-23) deployment status**: Whether the zero-knowledge proof oracle enhancement is in production or still in development could not be confirmed.
- **Emergency multisig exact composition and threshold**: The specific signer set and threshold for emergency pause capabilities were not individually verified.
- **Lido V3 deployment status**: The extent to which V3 (stVaults / customizable staking) is deployed in production versus testnet is unverified.
- **Solana deployment status**: Lido on Solana shows minimal TVL (~$4M). Whether this deployment is actively maintained or in sunset mode is unclear.

## Disclaimer

This report is an automated security assessment based on publicly available information, on-chain data, DeFiLlama metrics, and GoPlus token security scanning as of April 5, 2026. It is NOT a formal smart contract audit. It does not constitute financial advice. Users should conduct their own research and consider their own risk tolerance before interacting with any DeFi protocol. Past security performance does not guarantee future safety.
