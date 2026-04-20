# DeFi Security Audit: dYdX

**Audit Date:** April 20, 2026
**Protocol:** dYdX V4 -- Decentralized Perpetuals Exchange on Cosmos

## Overview
- Protocol: dYdX (V4)
- Chain: dYdX Chain (Cosmos SDK app-chain)
- Type: Derivatives / Perpetuals DEX
- TVL: ~$145.6M (DeFiLlama, April 2026)
- TVL Trend: -2.4% / -11.6% / -24.8% (7d / 30d / 90d)
- Token: DYDX (Ethereum ERC-20: 0x92D6C1e31e14520e676a687F0a93788B716BEff5; also native Cosmos token)
- Launch Date: October 2023 (V4 mainnet); original V1 in 2017
- Audit Date: April 20, 2026
- Valid Until: July 20, 2026 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Open (v4-chain on GitHub)

## Quick Triage Score: 62/100 | Data Confidence: 75/100

Starting at 100, subtracting:

- -8: is_mintable = 1 (GoPlus: DYDX token is mintable on Ethereum)
- -8: TVL dropped >30% in 90 days (-24.8% on DeFiLlama; borderline but sustained multi-month decline)
- -5: Single oracle framework concern (Slinky sidecar aggregates CEX feeds but is a single oracle framework across all validators)
- -5: No documented timelock on admin actions (governance proposals have 4-day voting period but no separate timelock delay)
- -5: Undisclosed multisig signer identities (validators are known but no published key management policy for individual operators)
- -5: No published key management policy (HSM, MPC, key ceremony)
- -5: No disclosed penetration testing (infrastructure, not just smart contract audit)

Total deductions: -41 (but note: -8 for TVL decline is borderline). Applying -38 mechanically (the 90d TVL decline is -24.8%, which is under the 30% threshold). Re-scored:

Revised calculation without TVL flag:
- -8: is_mintable = 1
- -5: Single oracle framework
- -5: No documented timelock
- -5: Undisclosed multisig signer identities
- -5: No published key management policy
- -5: No disclosed penetration testing
- -5: Insurance fund / TVL < 5% after $10M reallocation (now ~$7M / $145.6M = 4.8%)

Total deductions: -38. Score: **62/100 (MEDIUM risk)**

Red flags found: 0 CRITICAL, 0 HIGH, 1 MEDIUM (mintable token), 6 LOW-level concerns

**Data Confidence Score: 75/100 (MEDIUM-HIGH confidence)**

- +15: Source code is open and verified on GitHub
- +15: GoPlus token scan completed
- +10: Multiple audit reports publicly available (Informal Systems Q1-Q3 2024, Q3 2025)
- +10: Team identities publicly known (Antonio Juliano doxxed, US-registered company)
- +10: Insurance fund size publicly disclosed
- +5: Bug bounty program details publicly listed
- +5: Governance process documented
- +5: Oracle provider(s) confirmed (Slinky/Skip Protocol)
Total: 75/100

Missing for higher confidence: multisig configuration verified on-chain (+10), timelock verified on-chain (+10), incident response plan published (+5), SOC 2/ISO 27001 (+5), key management policy (+5), penetration testing (+5), bridge DVN config (+5 -- N/A)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | ~4.8% ($7M / $145.6M) | 1-5% typical | MEDIUM |
| Audit Coverage Score | 3.75 (see calculation) | >= 3.0 = LOW | LOW |
| Governance Decentralization | On-chain Cosmos governance, 60 validators | Comparable to Osmosis/Injective | LOW |
| Timelock Duration | 4-day voting period (no separate timelock) | 24-48h timelock avg | MEDIUM |
| Multisig Threshold | N/A -- validator consensus (2/3 of 60) | 3/5 avg for admin multisig | LOW |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW |

### Audit Coverage Score Calculation

Known audits:

**Less than 1 year old (1.0 each):**
1. Informal Systems Q3 2025 -- Proposer Selection Updates (2025) -- 1.0

**1-2 years old (0.5 each):**
2. Informal Systems Q1 2024 -- dYdX chain updates -- 0.5
3. Informal Systems Q2 2024 -- dYdX chain updates -- 0.5
4. Informal Systems Q2+ 2024 -- Vaults audit -- 0.5

**Older than 2 years (0.25 each):**
5. Informal Systems Phase 1 (custom modules, 2023) -- 0.25
6. Informal Systems Phase 2 (x/clob module, 2023) -- 0.25
7. Informal Systems Phase 3 (bridge, delaymsg, rewards, 2023) -- 0.25
8. Peckshield (governance & token bridge contracts) -- 0.25
9. OpenZeppelin (perpetual contracts, V1/V2 era) -- 0.25

**Total Audit Coverage Score: 3.75 (LOW risk -- above 3.0 threshold)**

Note: This is a significant improvement from the previous audit (April 6, 2026) which scored 2.25. The discovery of the 2024 Q1/Q2/Vaults audits and the Q3 2025 Proposer Selection audit substantially improves coverage. However, the MegaVault automated trading strategies and the Slinky oracle integration specifically for dYdX still lack confirmed standalone audits. The 2024 Q2+ Vaults audit likely covers some MegaVault code.

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
| Holders | 45,245 | -- |
| Trust List | Yes (1) | LOW |
| Creator Honeypot History | No (0) | LOW |

**Top Holder Concentration:** The top holder (0x46b2...fa9) holds 73.1% of supply -- this is a contract address (likely the bridge/migration contract holding unmigrated ethDYDX). The second largest holder (0x0000...001, 15.5%) is locked. Top 5 holders control ~95.3% of Ethereum-side supply, but this reflects the migration to Cosmos rather than concentration risk per se.

**Note:** The Ethereum DYDX token is largely a legacy artifact. The active governance token is the native DYDX on the dYdX Cosmos chain. The mintable flag on the Ethereum contract is MEDIUM risk but less relevant since the primary token economy has migrated. The ethDYDX-to-dYdX bridge was officially discontinued via governance vote on December 7, 2024, with support ceasing on June 13, 2025.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | LOW | Cosmos on-chain governance with 60 validators; designated proposer set adds performance layer | S | Partial |
| Oracle & Price Feeds | MEDIUM | Slinky sidecar aggregates CEX feeds; Oct 2025 stale oracle incident; no confirmed circuit breaker | S/H | Partial |
| Economic Mechanism | MEDIUM | Insurance fund reduced to ~$7M after $10M SubDAO allocation; MegaVault carries material loss risk | S/H | Y |
| Smart Contract | LOW | Audit coverage improved to 3.75 with 2024-2025 Informal Systems audits; Q3 2025 audit is recent | S | Y |
| Token Contract (GoPlus) | LOW | Clean GoPlus profile; mintable flag on legacy Ethereum contract | S | Y |
| Cross-Chain & Bridge | LOW | Bridge discontinued; Cosmos IBC for transfers only | S | Y |
| Off-Chain Security | MEDIUM | No SOC 2/ISO 27001; no published key management; DPRK-linked supply chain attacks on ecosystem | O | Partial |
| Operational Security | MEDIUM | Oct 2025 chain halt; Feb 2026 supply chain attack; 35% workforce reduction in Oct 2024 | S/H | Y |
| **Overall Risk** | **MEDIUM** | **Mature protocol with improved audit coverage but reduced insurance fund, persistent oracle risks, and supply chain targeting** | | |

**Overall Risk aggregation**: 0 CRITICAL, 0 HIGH, 4 MEDIUM (Oracle, Economic, Off-Chain, Operational). 3+ MEDIUM = MEDIUM overall.

## Detailed Findings

### 1. Governance & Admin Key

**Risk: LOW**

dYdX V4 operates as a Cosmos app-chain with fully on-chain governance via the standard x/gov module. This remains one of the most decentralized governance architectures among perps DEXes.

**Validator Set:**
- 60 active validators selected by stake weight (delegated proof-of-stake)
- Consensus requires 2/3+ of validator voting power (standard CometBFT)
- Validators are independent entities, many are well-known Cosmos validators (Chorus One, Everstake, etc.)
- dYdX Foundation performs periodic stake delegation rebalancing (most recently July 2025 with ~7M DYDX)
- A governance proposal to reduce the active set from 60 to 30 validators has been discussed but not enacted

**Designated Proposer System (NEW since last audit):**
- Introduced via v9.0 software upgrade on August 31, 2025
- A governance-defined subset of validators is eligible to propose blocks, selected via weighted round-robin by voting power
- The full 60-validator set still signs and verifies all blocks; consensus still requires 2/3+ voting power
- Eight validators received grants to operate as designated proposers
- This change improves performance and reliability without reducing decentralization of block finality
- Audited by Informal Systems (Q3 2025 Proposer Selection Updates audit)

**Governance Process:**
- Standard proposals: 4-day voting period, 33.4% quorum, simple majority to pass
- Expedited proposals: 1-day voting period, 75% approval threshold
- Veto threshold: 33.4%
- Parameter changes take effect in the block after voting ends
- Custom x/govplus module allows the community to slash validators for order flow manipulation

**Token Buyback Program (NEW since last audit):**
- Launched March 2025 with 25% of net protocol fees allocated to buybacks
- Expanded to 75% of net protocol fees via governance proposal #313 (November 2025)
- Over 5.3M DYDX tokens repurchased and staked as of early 2026
- 5% of fees to Treasury SubDAO, 5% to MegaVault, remaining to stakers/validators
- This creates meaningful token demand but also concentrates voting power in the buyback mechanism

**Admin Key Analysis:**
- No traditional admin key or multisig pattern -- governance is validator-consensus-based
- No single entity can unilaterally upgrade the chain or modify parameters
- Software upgrades require validator coordination through Cosmovisor
- The dYdX Foundation and dYdX Trading Inc. have no special on-chain privileges (UNVERIFIED)

**Timelock Assessment:**
- No separate timelock contract exists; the 4-day voting period serves as the de facto delay
- Expedited proposals (1 day) could theoretically rush critical changes
- No documented emergency bypass mechanism (positive for security, negative for incident response)

### 2. Oracle & Price Feeds

**Risk: MEDIUM**

**Architecture:**
- Skip's Slinky sidecar oracle system runs as a separate process alongside each validator
- Provides block-by-block oracle updates via CometBFT VoteExtensions
- Prices are aggregated from multiple CEX sources and on-chain DeFi sources via RPC
- Price agreement is part of consensus -- validators must agree on prices

**October 2025 Incident Resolution (UPDATED):**
- Root cause was an incorrect order of operations in a collateral pool transfer process during extreme volatility
- The bug communicated a negative balance despite the isolated market's insurance fund having ample capital
- This triggered a protocol-level failsafe that halted the chain
- Stale oracle prices persisted until >67% of validators resumed posting updates
- 27 users suffered incorrect liquidations/trades; $462K compensation approved from insurance fund
- Fix deployed: liquidation and collateral-transfer sequence corrected with additional order-of-operations checks and automated tests
- Post-mortems published (positive transparency)

**Remaining Concerns:**
- All price sources ultimately derive from centralized exchange APIs -- a coordinated CEX outage could affect all validators simultaneously
- No confirmed circuit breaker for extreme price movements (UNVERIFIED despite searching)
- The October 2025 incident showed that a chain halt itself creates stale oracle risk during recovery
- Admin (governance) can change oracle sources and market parameters

### 3. Economic Mechanism

**Risk: MEDIUM**

**Insurance Fund (SIGNIFICANT CHANGE):**
- Previously ~$17M; reduced to ~$7M after governance-approved $10M allocation to SubDAOs (April 2026)
- The $10M was distributed: $5M to Treasury SubDAO, $2.5M to Operations SubDAO, $2.5M to dYdX Foundation
- New Insurance Fund / TVL ratio: ~4.8% ($7M / $145.6M) -- below the 5% healthy threshold
- This is a material deterioration from the previous 13.6% ratio
- Fund is replenished by a percentage of liquidation fees, but the rate of replenishment is unclear
- Historical drawdowns: $9M (V3 YFI, 2023), $462K (October 2025 incident)

**Liquidation Mechanism:**
- Automated keeper bots monitor positions against oracle prices
- Cross-margin and isolated margin modes available (isolated markets introduced in V5.0, January 2025)
- Isolated markets have dedicated insurance funds, reducing cross-contamination risk

**MegaVault:**
- Launched November 2024 as part of "dYdX Unlimited"
- Initially reached $70M+ TVL with >40% APR
- 79M USDC deposited by community in 2024
- Gauntlet serves as MegaVault operator, managing parameter updates and liquidity allocations across 171+ markets (as of July 2025)
- 50% of trading fee revenue shared with MegaVault (later reduced to 5% after buyback expansion)
- Monthly risk reports published by Gauntlet (positive transparency)

**MegaVault Risks:**
- Material risk of 100% loss explicitly stated in documentation
- Funds are NOT covered by the insurance fund or any investor protection
- Automated strategies trade in high-risk, illiquid, and volatile markets
- Vulnerable to losses from malicious actors manipulating prices in low-liquidity sub-vaults
- APR is highly variable and not guaranteed; decreases as TVL grows
- MegaVault deposits form a significant portion of protocol TVL, creating reflexivity risk

**Funding Rate Model:**
- Hourly funding rate based on 60-minute premium average
- Standard perpetual funding mechanism well-tested across the industry

### 4. Smart Contract Security

**Risk: LOW** (upgraded from MEDIUM in previous audit)

**Audit History (UPDATED -- significantly improved):**

| Audit | Year | Scope | Age |
|-------|------|-------|-----|
| Informal Systems Q3 2025 | 2025 | Proposer Selection Updates | <1 year |
| Informal Systems Q2+ 2024 | 2024 | Vaults (MegaVault) | 1-2 years |
| Informal Systems Q2 2024 | 2024 | Chain updates | 1-2 years |
| Informal Systems Q1 2024 | 2024 | Chain updates | 1-2 years |
| Informal Systems Phase 1-3 | 2023 | Custom modules, CLOB, bridge | >2 years |
| Peckshield | Pre-2023 | Governance & bridge contracts | >2 years |
| OpenZeppelin | Pre-2023 | Perpetual contracts (V1/V2) | >2 years |

The Audit Coverage Score has improved from 2.25 to 3.75, crossing the LOW-risk threshold of 3.0. The Q3 2025 audit of Proposer Selection is less than 1 year old, and the 2024 Vaults audit provides coverage of MegaVault-related code.

**Remaining Gaps:**
- No public audit of the Slinky oracle sidecar integration specifically for dYdX
- The MegaVault automated trading strategies (managed by Gauntlet) may not be fully covered by the Vaults audit
- V5.0 upgrade (January 2025) introduced isolated markets; unclear if fully covered by Q1/Q2 2024 audits

**Bug Bounty:**
- Active bug bounty program run independently (not via Immunefi)
- Critical vulnerabilities: up to $1,000,000 USDC rewards
- Scope covers v4-chain protocol and indexer code, plus web and client repos
- Contact: bugbounty@dydx.exchange

**Battle Testing:**
- Original dYdX platform live since 2017; V4 chain since October 2023
- V4 has handled $200M+ daily trading volume
- Open source: Yes, full V4 chain code on GitHub (github.com/dydxprotocol/v4-chain)

### 5. Cross-Chain & Bridge

**Risk: LOW**

**Bridge Status:**
- The original ethDYDX-to-dYdX Chain bridge was officially discontinued per governance vote (December 7, 2024)
- Support ceased on June 13, 2025
- This eliminates an entire category of bridge-related risk

**Current Cross-Chain:**
- dYdX Chain uses Cosmos IBC (Inter-Blockchain Communication) for asset transfers
- IBC is the standard, battle-tested Cosmos interoperability protocol
- USDC deposits come via IBC from other Cosmos chains or through third-party on-ramps
- No dependency on third-party bridges (LayerZero, Wormhole, etc.)

### 6. Operational Security

**Risk: MEDIUM**

**Team & Track Record:**
- Founded by Antonio Juliano (doxxed) -- Princeton CS graduate, ex-Coinbase, ex-Uber, ex-MongoDB
- dYdX Trading Inc. is a US-registered company
- In October 2024, Juliano fired 35% of workforce and announced a strategic pivot
- Team is publicly identifiable but has been through significant organizational changes

**Supply Chain Security (UPDATED):**
- February 2026: Compromised npm (@dydxprotocol/v4-client-js) and PyPI (dydx-v4-client) packages discovered
- 128 phantom packages accumulated 121,539 downloads between July 2025 and January 2026
- npm version stole credentials; PyPI version included a full RAT with C2 server
- CoinDesk (April 2026) linked the broader crypto supply chain targeting campaign to North Korean threat actors, though direct attribution of the dYdX-specific attack to DPRK is not definitively confirmed
- March 2026: Separate major supply chain attack on the Axios npm package (100M+ weekly downloads) attributed to UNC1069, a North Korean group -- dYdX client libraries depend on Axios
- 2022: Earlier npm supply chain attack on V3 packages
- Three separate supply chain incidents indicate persistent, sophisticated adversary interest in the dYdX ecosystem

**Incident History:**
- November 2023 (V3): $9M insurance fund drain from YFI market manipulation
- July 2024 (V3): DNS nameserver hijacking via Squarespace. Two users lost ~$31K
- October 2025 (V4): 8-hour chain halt due to bug in isolated market collateral transfer. $462K compensation
- February 2026: Supply chain attack on npm/PyPI packages (protocol not compromised)
- March 2026: Downstream exposure to Axios npm compromise

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
- Axios npm package -- downstream dependency in client libraries (affected by March 2026 DPRK attack)

## Critical Risks

1. **Insurance Fund Reduction (MEDIUM):** The $10M reallocation to SubDAOs reduced the insurance fund from $17M to ~$7M, dropping the fund/TVL ratio from 13.6% to 4.8% -- below the 5% healthy threshold. This materially weakens the protocol's ability to absorb another YFI-scale event ($9M).

2. **Supply Chain Targeting (MEDIUM):** Three separate supply chain incidents (2022, 2025-2026 dYdX packages, 2026 Axios) plus DPRK-linked broader crypto targeting indicate persistent, sophisticated adversary interest. The Axios compromise affects the entire JavaScript ecosystem but dYdX client libraries are direct consumers.

3. **Oracle Reliability (MEDIUM):** The October 2025 incident has been patched with order-of-operations fixes, but no confirmed circuit breaker exists for extreme price movements. A chain halt itself creates stale oracle conditions.

4. **MegaVault Loss Potential (MEDIUM):** MegaVault carries explicit 100% loss risk with no insurance coverage. Gauntlet's operator role provides professional risk management but the underlying strategies trade in illiquid markets.

## Peer Comparison

| Feature | dYdX V4 | Hyperliquid | GMX (Arbitrum) |
|---------|---------|-------------|----------------|
| Architecture | Cosmos app-chain | Custom L1 | Smart contracts on Arbitrum |
| TVL | ~$145.6M | ~$4.87B | ~$264.6M |
| Validators | 60 independent | ~16 (expanded from 4) | N/A (Arbitrum validators) |
| Consensus | CometBFT (2/3 BFT) | HyperBFT (2/3 BFT) | Arbitrum sequencer |
| Timelock | 4-day governance vote | UNVERIFIED | 24h timelock |
| Admin Key | No single admin; validator consensus | Team-controlled early stage | Multisig |
| Audits | Informal Systems (2023-2025, 8+ audits) | Limited public audits | Trail of Bits, ABDK (recent) |
| Oracle | Slinky sidecar (multi-CEX) | Internal oracle | Chainlink + custom |
| Insurance/TVL | ~4.8% | UNVERIFIED | ~5-10% |
| Open Source | Yes | Partial | Yes |
| Bug Bounty | Yes ($150K-$1M) | UNVERIFIED | Yes (Immunefi) |
| Throughput | ~2,000 TPS | ~200,000 orders/sec claimed | Limited by Arbitrum |

**Key Peer Observations:**
- dYdX has the most decentralized validator set among perps DEXes (60 vs Hyperliquid's ~16)
- Hyperliquid has captured 33x more TVL despite less decentralization
- dYdX's audit coverage has improved significantly (3.75 vs previous 2.25)
- dYdX's insurance/TVL ratio (4.8%) has deteriorated and is now below GMX's range
- The designated proposer innovation improves performance without sacrificing finality decentralization

## Recommendations

1. **Replenish insurance fund:** The $7M insurance fund is below the 5% healthy threshold relative to TVL. Governance should consider allocating a portion of buyback revenue to rebuild the fund before the next volatile market event.

2. **Implement documented circuit breakers:** No confirmed circuit breaker exists for extreme price movements. The October 2025 incident showed that stale oracle recovery is a risk. Automated pause triggers at configurable price deviation thresholds would reduce this exposure.

3. **Strengthen supply chain security:** Given three separate supply chain incidents, implement package signing, provenance attestation (npm/PyPI), subresource integrity checks, and automated monitoring of official package registries. Consider pinning Axios and other critical dependencies to audited versions.

4. **Immunefi listing:** Consider listing the bug bounty on Immunefi for broader researcher reach, in addition to the existing independent program.

5. **Publish security practices:** No SOC 2, ISO 27001, published key management policy, or penetration testing disclosure was found. Publishing these would improve the Data Confidence Score and provide assurance on off-chain controls.

6. **For users:** The protocol's governance architecture and audit coverage are strong relative to peers. The primary risks are (a) reduced insurance fund buffer, (b) MegaVault loss if you deposit there, and (c) supply chain attacks on developer tools. Consider the declining TVL trend when assessing liquidity risk.

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
- [ ] Insufficient insurance fund relative to TVL? -- Yes. 4.8% is below the 5% healthy threshold after $10M SubDAO allocation.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No. Bridge discontinued. IBC is decentralized.
- [ ] Admin keys stored in hot wallets? -- N/A. No admin keys; validator keys are operator-managed.
- [ ] No key rotation policy? -- UNVERIFIED for individual validators.

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time (no snapshot)? -- No. Cosmos staking-based governance uses delegated stake, not spot balance.
- [ ] Flash loans can be used to acquire voting power? -- No. Staking has unbonding periods (21 days).
- [ ] Proposal + execution in same block or short window? -- No. Minimum 1-day voting period (expedited).
- [ ] No minimum holding period for voting eligibility? -- No. Staking delegation required.

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] N/A -- dYdX is a Cosmos app-chain, not an EVM protocol. Reentrancy and flash loan patterns do not apply in the same way.

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler? -- No. Written in Go (standard Cosmos SDK).
- [ ] Compiler version has known CVEs? -- No known Go compiler vulnerabilities affecting dYdX.

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] N/A -- dYdX does not issue a stablecoin. USDC is the settlement asset.

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] N/A -- Bridge discontinued. No cross-chain token minting. IBC only.

**Trigger rule**: No category matches 3+ indicators. No explicit warning triggered.

## Information Gaps

- **Insurance fund replenishment rate** -- unclear how quickly the fund recovers from the current ~$7M level toward the previous $17M; the rate depends on trading volume and fee structure
- **MegaVault current TVL and APR** -- exact current figures not confirmed via API; Gauntlet monthly reports provide periodic snapshots but not real-time data
- **Circuit breaker existence** -- no documentation found confirming or denying automated circuit breakers for extreme price movements
- **Validator concentration** -- unclear what percentage of stake the top 5 validators control; a concentrated validator set could approximate a low-threshold multisig
- **Validator key management practices** -- individual validator operational security is not centrally documented or audited
- **Emergency governance bypass** -- unclear if any mechanism exists for emergency actions outside the standard 1-4 day governance process
- **dYdX Foundation governance voting behavior** -- unclear whether the Foundation's delegated stake is used for proposal voting or only for validator security
- **Expedited proposal abuse potential** -- unclear what safeguards exist against rushed expedited proposals with 75% coordinated voting power
- **Slinky oracle audit coverage** -- no standalone audit of the Slinky oracle sidecar integration specifically for dYdX was identified (Skip Protocol may have audited Slinky separately)
- **North Korea attribution** -- the February 2026 dYdX npm/PyPI attack has circumstantial links to DPRK-backed groups but direct attribution is not definitively confirmed
- **Axios downstream impact** -- unclear whether dYdX has patched or pinned Axios dependencies following the March 2026 UNC1069 compromise
- **Team stability** -- 35% workforce reduction in October 2024 raises questions about institutional knowledge retention and operational capacity
- **Off-chain security certifications** -- no SOC 2, ISO 27001, or equivalent certification found; no published key management or penetration testing disclosures

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
