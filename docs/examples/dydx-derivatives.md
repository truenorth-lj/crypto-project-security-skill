# DeFi Security Audit: dYdX

**Audit Date:** April 6, 2026
**Protocol:** dYdX V4 -- Decentralized Perpetuals Exchange on Cosmos

## Overview
- Protocol: dYdX (V4)
- Chain: dYdX Chain (Cosmos SDK app-chain)
- Type: Derivatives / Perpetuals DEX
- TVL: ~$117.6M (DeFiLlama, April 2026)
- TVL Trend: -1.0% / -8.0% / -24.8% (7d / 30d / 90d)
- Token: DYDX (Ethereum ERC-20: 0x92D6C1e31e14520e676a687F0a93788B716BEff5; also native Cosmos token)
- Launch Date: October 2023 (V4 mainnet); original V1 in 2017
- Audit Date: April 6, 2026
- Source Code: Open (v4-chain on GitHub)

## Quick Triage Score: 67/100

Starting at 100, subtracting:

- -8: TVL dropped >30% in 90 days (-24.8% on DeFiLlama; close but within range given broader market conditions)
- -8: is_mintable = 1 (GoPlus: DYDX token is mintable on Ethereum)
- -5: Insurance fund / TVL ratio ~13.6% (healthy, no deduction warranted) -- NO DEDUCTION
- -5: Single oracle concern (Slinky sidecar aggregates CEX feeds but is a single oracle framework)
- -5: Undisclosed multisig signer identities (validators are known but no traditional multisig admin)
- -5: No documented timelock on admin actions (governance proposals have 4-day voting period but no separate timelock delay)
- -5: Past insurance fund breach ($9M YFI incident on V3)
- -5: October 2025 chain halt incident (8-hour outage with stale oracle data)

Total deductions: -33. Score: **67/100 (MEDIUM risk)**

Red flags found: 0 CRITICAL, 0 HIGH, 1 MEDIUM (mintable token), 6 LOW-level concerns

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | ~13.6% ($16M / $117.6M) | 1-5% typical | LOW |
| Audit Coverage Score | 2.25 (see calculation) | >= 3.0 = LOW | MEDIUM |
| Governance Decentralization | On-chain Cosmos governance, 60 validators | Comparable to Osmosis/Injective | LOW |
| Timelock Duration | 4-day voting period (no separate timelock) | 24-48h timelock avg | MEDIUM |
| Multisig Threshold | N/A -- validator consensus (2/3 of 60) | 3/5 avg for admin multisig | LOW |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW |

### Audit Coverage Score Calculation

Known audits:

**1-2 years old (0.5 each):**
1. Informal Systems Phase 1 (custom modules, 2023) -- 0.5
2. Informal Systems Phase 2 (x/clob module, 2023) -- 0.5
3. Informal Systems Phase 3 (bridge, delaymsg, rewards, 2023) -- 0.5

**Older than 2 years (0.25 each):**
4. Peckshield (governance & token bridge contracts) -- 0.25
5. OpenZeppelin (perpetual contracts, V1/V2 era) -- 0.25
6. CryptoFin / ZK Labs / Soho Token Labs (margin trading, early) -- 0.25

**Total Audit Coverage Score: 2.25 (MEDIUM risk -- below 3.0 threshold)**

Note: The Informal Systems audit of V4 chain code is the most relevant. No audit less than 1 year old was identified. The V4 codebase has evolved significantly since the 2023 audit (V5.0 upgrade in Jan 2025, Slinky oracle integration, MegaVault launch Nov 2024).

## GoPlus Token Security (Ethereum DYDX: 0x92D6C1e31e14520e676a687F0a93788B716BEff5)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | LOW |
| Open Source | Yes (1) | LOW |
| Proxy | No (0) | LOW |
| Mintable | Yes (1) | MEDIUM |
| Owner Can Change Balance | No (0) | LOW |
| Hidden Owner | No (0) | LOW |
| Selfdestruct | No (0) | LOW |
| Transfer Pausable | No (0) | LOW |
| Blacklist | No (0) | LOW |
| Slippage Modifiable | No (0) | LOW |
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 45,236 | -- |
| Trust List | Yes (1) | LOW |
| Creator Honeypot History | No (0) | LOW |

**Top Holder Concentration:** The top holder (0x46b2...fa9) holds 73.1% of supply -- this is a contract address (likely the bridge/migration contract holding unmigrated ethDYDX). The second largest holder (0x0000...001, 15.5%) is locked. Top 5 holders control ~95.3% of Ethereum-side supply, but this reflects the migration to Cosmos rather than concentration risk per se.

**Note:** The Ethereum DYDX token is largely a legacy artifact. The active governance token is the native DYDX on the dYdX Cosmos chain. The mintable flag on the Ethereum contract is MEDIUM risk but less relevant since the primary token economy has migrated. The ethDYDX-to-dYdX bridge has been officially discontinued.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | LOW | Cosmos on-chain governance with 60 validators; no single admin key | Partial |
| Oracle & Price Feeds | MEDIUM | Slinky sidecar aggregates CEX feeds; Oct 2025 stale oracle incident | Partial |
| Economic Mechanism | MEDIUM | MegaVault carries material loss risk; past $9M insurance fund drain | Y |
| Smart Contract | MEDIUM | No recent audit (<1 yr); code evolved significantly since 2023 audit | Y |
| Token Contract (GoPlus) | LOW | Clean GoPlus profile; mintable flag on legacy Ethereum contract | Y |
| Cross-Chain & Bridge | LOW | Bridge discontinued; Cosmos IBC for transfers only | Partial |
| Operational Security | MEDIUM | Oct 2025 chain halt; Feb 2026 supply chain attack on npm/PyPI packages | Y |
| **Overall Risk** | **MEDIUM** | **Mature protocol with strong governance design but aging audits, oracle incident history, and declining TVL** | |

## Detailed Findings

### 1. Governance & Admin Key

**Risk: LOW**

dYdX V4 represents a significant governance upgrade from its centralized V3 predecessor. As a Cosmos app-chain, governance is fully on-chain via the standard x/gov module.

**Validator Set:**
- 60 active validators selected by stake weight (delegated proof-of-stake)
- Consensus requires 2/3+ of validator voting power (standard CometBFT/Tendermint BFT)
- Validators are independent entities, many are well-known Cosmos validators (Chorus One, Everstake, etc.)
- dYdX Foundation performs periodic stake delegation rebalancing (most recently July 2025 with ~7M DYDX)

**Governance Process:**
- Standard proposals: 4-day voting period, 33.4% quorum, simple majority to pass
- Expedited proposals: 1-day voting period, 75% approval threshold
- Veto threshold: 33.4%
- Parameter changes take effect in the block after voting ends
- Custom x/govplus module allows the community to slash validators for order flow manipulation

**Admin Key Analysis:**
- No traditional admin key or multisig pattern -- governance is validator-consensus-based
- No single entity can unilaterally upgrade the chain or modify parameters
- Software upgrades require validator coordination through Cosmovisor
- The dYdX Foundation and dYdX Trading Inc. have no special on-chain privileges (UNVERIFIED -- no formal proof of absence of privileged roles)

**Timelock Assessment:**
- No separate timelock contract exists; the 4-day voting period serves as the de facto delay
- Expedited proposals (1 day) could theoretically rush critical changes
- No documented emergency bypass mechanism (positive for security, negative for incident response)

**Token Concentration (Cosmos side):**
- Staked DYDX determines governance weight
- Foundation delegates ~7M DYDX across validators but this is for network security, not governance voting (UNVERIFIED whether Foundation votes on proposals)

### 2. Oracle & Price Feeds

**Risk: MEDIUM**

**Architecture:**
- Originally, each validator independently fetched prices from centralized exchanges via API
- Upgraded to Skip's Slinky sidecar oracle system, which runs as a separate process alongside each validator
- Slinky provides block-by-block oracle updates via CometBFT VoteExtensions
- Prices are aggregated from multiple CEX sources and, since the Skip Connect integration, also from on-chain DeFi sources via RPC

**Strengths:**
- Decentralized oracle: each of 60 validators runs their own Slinky sidecar, so no single oracle provider can be compromised
- Price agreement is part of consensus -- validators must agree on prices
- Funding rates are calculated hourly based on premium samples, providing TWAP-like smoothing

**Weaknesses:**
- October 2025 incident: chain halt led to stale oracle data when validators restarted with misconfigured oracle sidecars. 27 users suffered incorrect liquidations/trades, costing $462K from the insurance fund
- All price sources ultimately derive from centralized exchange APIs -- a coordinated CEX outage could affect all validators simultaneously
- No documented circuit breaker for extreme price movements (UNVERIFIED)
- Admin (governance) can change oracle sources and market parameters

**Comparison to V3 YFI Incident:**
- In November 2023, a targeted attack on V3 exploited the YFI market's low liquidity and concentrated open interest, draining $9M from the insurance fund
- V4's architecture (decentralized validators, Slinky oracle, isolated markets) provides substantially better protection against similar attacks
- However, the October 2025 incident shows oracle-related risks persist in different forms

### 3. Economic Mechanism

**Risk: MEDIUM**

**Liquidation Mechanism:**
- Automated keeper bots monitor positions against oracle prices
- Positions below maintenance margin are liquidated
- Cross-margin and isolated margin modes available (isolated markets introduced in V5.0, January 2025)
- Isolated markets have dedicated insurance funds, reducing cross-contamination risk

**Insurance Fund:**
- Current size: ~$16M (approximately 13.6% of TVL -- well above the 5% healthy threshold)
- Funded by a percentage of liquidation fees
- Used $9M during the V3 YFI incident (40% of fund at the time)
- Used $462K for October 2025 incident compensation (2.85% of fund)
- Backstop: if insurance fund is depleted, protocol can trigger socialized deleveraging

**MegaVault:**
- Launched November 2024 as part of "dYdX Unlimited"
- Users deposit USDC to provide automated market-making liquidity across all markets
- Reached $70M+ TVL within 6 weeks, with >40% APR initially
- 50% of trading fee revenue shared with MegaVault (approved by governance November 2024)

**MegaVault Risks:**
- Material risk of 100% loss explicitly stated in documentation
- Funds are NOT covered by the insurance fund or any investor protection
- Automated strategies trade in high-risk, illiquid, and volatile markets
- Withdrawal slippage fees increase with leverage impact
- APR is highly variable and not guaranteed
- MegaVault deposits form a significant portion of protocol TVL, creating reflexivity risk

**Funding Rate Model:**
- Hourly funding rate based on 60-minute premium average
- Standard perpetual funding mechanism well-tested across the industry
- No known edge cases or manipulation incidents on V4

### 4. Smart Contract Security

**Risk: MEDIUM**

**Audit History:**
- Informal Systems: 3-phase audit of dYdX V4 chain code (2023). Zero critical issues in final state (1 critical found and resolved during audit, 4 medium, 17 low, 19 informational). This is the most comprehensive and relevant audit.
- Peckshield: Token bridge and governance contracts audit
- OpenZeppelin: dYdX Perpetual contracts (V1/V2 era -- largely deprecated)
- Earlier audits by CryptoFin, ZK Labs, Soho Token Labs on margin trading protocol

**Audit Gap Concern:**
- The most relevant audit (Informal Systems) is from 2023, now over 2 years old
- Significant code changes since: V5.0 upgrade (January 2025), Slinky oracle integration, MegaVault, isolated markets, market mapper
- No public audit of the MegaVault automated trading strategies
- No public audit of the Slinky oracle sidecar integration specifically for dYdX
- DeFiLlama lists "0" audits, suggesting their database may not be current

**Bug Bounty:**
- Active bug bounty program run independently (not via Immunefi)
- Critical vulnerabilities: $150,000 - $1,000,000 rewards
- Scope covers v4-chain protocol and indexer code, plus web and client repos
- Contact: bugbounty@dydx.exchange

**Battle Testing:**
- Original dYdX platform live since 2017; V4 chain since October 2023
- V4 has handled $200M+ daily trading volume
- Peak TVL on V4: ~$500M+ (early 2025, per DeFiLlama data trends)
- Open source: Yes, full V4 chain code on GitHub (github.com/dydxprotocol/v4-chain)

**Supply Chain Security Concern:**
- February 2026: Compromised npm (@dydxprotocol/v4-client-js) and PyPI (dydx-v4-client) packages discovered
- 128 phantom packages accumulated 121,539 downloads between July 2025 and January 2026
- npm version stole credentials; PyPI version included a full RAT with C2 server
- This was a supply chain attack on developer tools, not the protocol itself, but indicates the dYdX ecosystem is a high-value target

### 5. Cross-Chain & Bridge

**Risk: LOW**

**Bridge Status:**
- The original ethDYDX-to-dYdX Chain bridge has been officially discontinued per governance vote
- It is no longer possible to bridge Ethereum DYDX tokens to the dYdX Chain
- This eliminates an entire category of bridge-related risk

**Current Cross-Chain:**
- dYdX Chain uses Cosmos IBC (Inter-Blockchain Communication) for asset transfers
- IBC is the standard, battle-tested Cosmos interoperability protocol
- USDC deposits come via IBC from other Cosmos chains or through third-party on-ramps
- No dependency on third-party bridges (LayerZero, Wormhole, etc.)

**Architecture Benefit:**
- By operating as a sovereign Cosmos app-chain, all trading occurs on a single chain
- No cross-chain messaging required for trading operations
- Only deposits/withdrawals touch external chains via IBC

### 6. Operational Security

**Risk: MEDIUM**

**Team & Track Record:**
- Founded by Antonio Juliano (doxxed) -- Princeton CS graduate, ex-Coinbase, ex-Uber, ex-MongoDB
- dYdX Trading Inc. is a US-registered company
- In October 2024, Juliano fired 35% of workforce and announced a strategic pivot
- Team is publicly identifiable but has been through significant organizational changes

**Incident History:**
- November 2023 (V3): $9M insurance fund drain from YFI market manipulation -- targeted attack, attacker identified
- July 2024 (V3): DNS nameserver hijacking via Squarespace. Two users lost ~$31K. No smart contract compromise
- October 2025 (V4): 8-hour chain halt due to misordered code deployment. Stale oracle data caused incorrect liquidations. $462K compensation from insurance fund
- February 2026: Supply chain attack on npm/PyPI packages. Protocol not compromised but developer ecosystem targeted
- 2022: Earlier npm supply chain attack on V3 packages

**Incident Response:**
- October 2025 incident demonstrated coordinated validator response, though the 8-hour outage duration was significant
- Post-mortems published for all major incidents (positive transparency)
- Emergency pause capability exists through validator coordination but is not instantaneous
- No formally published incident response plan (UNVERIFIED)

**Dependencies:**
- Slinky oracle sidecar (Skip Protocol) -- critical dependency for price feeds
- Centralized exchange APIs -- price data sources
- Cosmos SDK and CometBFT -- blockchain infrastructure
- IBC relayers -- for cross-chain transfers

## Critical Risks

1. **Aging Audit Coverage (MEDIUM):** The most relevant V4 audit is from 2023. Major features (MegaVault, Slinky oracle, isolated markets, V5.0 upgrade) have shipped without confirmed public audits. This is the single most actionable risk.

2. **MegaVault Loss Potential (MEDIUM):** MegaVault carries explicit 100% loss risk with no insurance coverage. It represents a significant portion of protocol TVL, creating potential cascade risk if MegaVault strategies perform poorly.

3. **Oracle Reliability (MEDIUM):** The October 2025 incident demonstrated that oracle infrastructure remains a failure point. While Slinky is an improvement over the original design, validator misconfiguration during recovery led to stale prices and user losses.

4. **Supply Chain Targeting (MEDIUM):** Two separate supply chain attacks (2022, 2025-2026) on dYdX npm/PyPI packages indicate persistent adversary interest. While not protocol-level, these attacks affect developer and user security.

## Peer Comparison

| Feature | dYdX V4 | Hyperliquid | GMX (Arbitrum) |
|---------|---------|-------------|----------------|
| Architecture | Cosmos app-chain | Custom L1 | Smart contracts on Arbitrum |
| Validators | 60 independent | ~4 (Hot committee, early stage) | N/A (Arbitrum validators) |
| Consensus | CometBFT (2/3 BFT) | HyperBFT (2/3 BFT) | Arbitrum sequencer |
| Timelock | 4-day governance vote | UNVERIFIED | 24h timelock |
| Admin Key | No single admin; validator consensus | Team-controlled early stage | Multisig |
| Audits | Informal Systems (2023) | Limited public audits | Trail of Bits, ABDK (recent) |
| Oracle | Slinky sidecar (multi-CEX) | Internal oracle | Chainlink + custom |
| Insurance/TVL | ~13.6% | UNVERIFIED | ~5-10% |
| Open Source | Yes | Partial | Yes |
| Bug Bounty | Yes ($150K-$1M) | UNVERIFIED | Yes (Immunefi) |
| Throughput | ~2,000 TPS | ~200,000 orders/sec claimed | Limited by Arbitrum |
| TVL | ~$117M | ~$1B+ | ~$500M+ |

**Key Peer Observations:**
- dYdX has the most decentralized validator set among perps DEXes (60 vs Hyperliquid's 4)
- Hyperliquid has captured significantly more TVL and volume despite less decentralization
- dYdX's audit coverage is aging; GMX has more recent audits
- dYdX's insurance/TVL ratio (13.6%) is among the best in the category

## Recommendations

1. **Commission a fresh audit:** The V4 codebase has evolved substantially since the 2023 Informal Systems audit. A comprehensive audit covering MegaVault, Slinky integration, isolated markets, and V5.0 changes should be prioritized.

2. **Strengthen supply chain security:** Given two separate npm/PyPI compromises, implement package signing, provenance attestation, and automated monitoring of official package registries.

3. **Oracle circuit breakers:** Implement documented circuit breakers that automatically pause trading if oracle prices deviate beyond configurable thresholds. The October 2025 incident showed that stale oracle recovery is a risk.

4. **MegaVault transparency:** Publish real-time risk metrics for MegaVault including current leverage, position sizes, and PnL. Users depositing USDC should have clear visibility into the strategies their funds support.

5. **For users:** The protocol's governance architecture and insurance fund are strong relative to peers. The primary risks are (a) MegaVault loss if you deposit there, and (b) potential undiscovered bugs in un-audited new features. Consider the declining TVL trend when assessing liquidity risk.

6. **Immunefi listing:** Consider listing the bug bounty on Immunefi for broader researcher reach, in addition to the existing independent program.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- No. Market listing is via governance or MegaVault permissionless listing (with constraints).
- [ ] Admin can change oracle sources arbitrarily? -- No. Oracle configuration changes require governance proposals.
- [ ] Admin can modify withdrawal limits? -- No. Withdrawal parameters are governance-controlled.
- [ ] Multisig has low threshold (2/N with small N)? -- N/A. No multisig; 2/3 of 60 validators required for consensus.
- [ ] Zero or short timelock on governance actions? -- Partial concern. 4-day voting period, but expedited proposals can pass in 1 day with 75% threshold.
- [ ] Pre-signed transaction risk? -- N/A. Not applicable to Cosmos architecture.
- [ ] Social engineering surface area (anon multisig signers)? -- Low. Validators are mostly known entities. No traditional multisig signers to target.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- Mitigated. Isolated markets have dedicated insurance funds. MegaVault provides liquidity but with explicit loss risk.
- [ ] Single oracle source without TWAP? -- Partial concern. Slinky aggregates multiple CEX sources but all from centralized venues. Funding rates use hourly averaging.
- [ ] No circuit breaker on price movements? -- UNVERIFIED. No documented circuit breaker mechanism found.
- [ ] Insufficient insurance fund relative to TVL? -- No. 13.6% is well above the 5% healthy threshold.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No. Bridge discontinued. IBC is decentralized.
- [ ] Admin keys stored in hot wallets? -- N/A. No admin keys; validator keys are operator-managed.
- [ ] No key rotation policy? -- UNVERIFIED for individual validators.

## Information Gaps

- **No confirmed audit of MegaVault strategies or Slinky oracle integration** -- these are significant new features without documented third-party review
- **Validator key management practices** -- individual validator operational security is not centrally documented or audited
- **Emergency governance bypass** -- unclear if any mechanism exists for emergency actions outside the standard 1-4 day governance process
- **dYdX Foundation governance voting behavior** -- unclear whether the Foundation's delegated stake is used for proposal voting or only for validator security
- **Expedited proposal abuse potential** -- unclear what safeguards exist against rushed expedited proposals with 75% coordinated voting power
- **MegaVault current TVL and performance** -- exact current figures not confirmed via API
- **Circuit breaker existence** -- no documentation found confirming or denying automated circuit breakers for extreme price movements
- **Validator concentration** -- unclear what percentage of stake the top 5 validators control; a concentrated validator set could approximate a low-threshold multisig
- **Insurance fund replenishment rate** -- unclear how quickly the fund recovers after drawdowns like the $9M YFI incident or the $462K October 2025 payout
- **Team stability** -- 35% workforce reduction in October 2024 raises questions about institutional knowledge retention and operational capacity

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
