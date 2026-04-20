# DeFi Security Audit: Hyperliquid

**Audit Date:** April 20, 2026
**Protocol:** Hyperliquid -- L1 Perpetual Futures and Spot DEX
**Previous Audit:** April 6, 2026

## Overview
- Protocol: Hyperliquid
- Chain: Hyperliquid L1 (custom HyperBFT consensus), bridged via Arbitrum
- Type: Perpetual futures DEX / Spot DEX / L1 blockchain
- TVL: ~$4.87B (bridge: $3.36B on Arbitrum, $1.51B on Hyperliquid L1)
- TVL Trend: -2.5% / +2.6% / +8.0% (7d / 30d / 90d)
- Launch Date: Late 2022 (testnet); mainnet alpha 2023; HyperEVM February 2025
- Audit Date: April 20, 2026
- Valid Until: July 20, 2026 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Partial (bridge contract open source on GitHub; L1 node code closed source, distributed as precompiled binaries)

### Changes Since Previous Audit (April 6, 2026)

- TVL decreased slightly from ~$4.79B to ~$4.87B (Arbitrum bridge balance down from $3.77B to $3.36B; Hyperliquid L1 TVL up from $1.02B to $1.51B, reflecting migration toward native USDC on HyperEVM)
- Assistance Fund HYPE burn formally approved: ~37.5M HYPE (~$912M) permanently removed from circulation; tokens are mathematically irretrievable without a hard fork
- December 2025 reverse-engineering report alleged $362M shortfall and "CoreWriter godmode" -- Hyperliquid denied insolvency, explaining native USDC on HyperEVM was excluded from the researcher's accounting
- CoreWriter and 8 broadcaster addresses confirmed as system-level infrastructure; Hyperliquid states CoreWriter cannot mint tokens or move user funds without authorization -- UNVERIFIED independently
- No new audits of L1, clearinghouse, or bridge beyond the 2023 Zellic bridge audits
- Bridge hot/cold validator sets still 4 addresses each -- no expansion despite consensus validator set growing to ~21
- L1 node code remains closed source
- Bug bounty program details now documented: Critical <$1M USDC, High <$50K USDC (self-hosted, not on Immunefi)
- Post-JELLY improvements confirmed: on-chain validator voting for asset delisting, margin tiers (May 2025), liquidator vault isolation

## Quick Triage Score: 55/100 | Data Confidence: 45/100

### Quick Triage Score Calculation

- Red flags found: 7

Start at 100:
  - HIGH: Closed-source L1 node code (-15)
  - LOW: No documented timelock on admin actions (-5)
  - LOW: Custom in-house oracle with no independent fallback (-5)
  - LOW: Undisclosed bridge multisig signer identities (-5)
  - LOW: No published key management policy (HSM, MPC, key ceremony) (-5)
  - LOW: No disclosed penetration testing (-5)
  - LOW: No third-party security certification (SOC 2 / ISO 27001) -- reclassified from N/A (-5)

Score: 100 - 15 - 5 - 5 - 5 - 5 - 5 - 5 = **55**

Score meaning: 50-79 = MEDIUM risk

Note: Previous audit scored 60/100. The decrease reflects newly identified gaps: no published key management policy, no penetration testing disclosure, and no third-party security certification. The bug bounty program is now documented (removing previous -5 penalty) but the new off-chain controls flags more than offset this improvement.

### Data Confidence Score Calculation

Start at 0:
  - [ ] +15  Source code is open and verified on block explorer -- PARTIAL (bridge only, not L1)
  - [ ] +15  GoPlus token scan completed -- N/A (native L1 token)
  - [x] +10  At least 1 audit report publicly available (Zellic bridge audit)
  - [ ] +10  Multisig configuration verified on-chain -- NO (bridge validator identities undisclosed)
  - [ ] +10  Timelock duration verified on-chain or in docs -- NO (no timelock)
  - [x] +10  Team identities publicly known (doxxed) -- YES (Jeff Yan)
  - [ ] +10  Insurance fund size publicly disclosed -- PARTIAL (HLP TVL visible; AF burned)
  - [x] +5   Bug bounty program details publicly listed -- YES (Critical <$1M, High <$50K)
  - [ ] +5   Governance process documented -- PARTIAL (HIPs exist but no formal DAO)
  - [x] +5   Oracle provider(s) confirmed -- YES (8 CEX weighted median)
  - [ ] +5   Incident response plan published -- NO
  - [ ] +5   SOC 2 Type II or ISO 27001 certification verified -- NO
  - [ ] +5   Published key management policy -- NO
  - [ ] +5   Regular penetration testing disclosed -- NO
  - [ ] +5   Bridge DVN/verifier configuration publicly documented -- PARTIAL

Score: 10 + 10 + 5 + 5 = **30** -- wait, let me recount more carefully:
  +10 (audit report) + 10 (doxxed team) + 5 (bug bounty) + 5 (oracle confirmed) = **30**

Partial credits: bridge source code (+7), insurance fund partial (+5), governance partial (+3) = +15

Total: **45/100** -- LOW confidence (most claims unverified -- treat score with skepticism)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | ~8-10% (HLP ~$400M vs $4.87B TVL; AF burned) | >5% healthy | LOW |
| Audit Coverage Score | 0.50 (2 Zellic bridge audits from 2023, >2yr old) | 3.0+ (GMX: 17 audits) | HIGH |
| Governance Decentralization | Foundation-controlled; no on-chain DAO voting; CoreWriter godmode | dYdX: 60 validators + DAO | HIGH |
| Timelock Duration | 0h (no documented timelock) | GMX: 24h; dYdX: governance vote | HIGH |
| Multisig Threshold | ~3/4 (2/3 stake-weighted, 4 hot validators) | GMX: community multisig; dYdX: 60 validators | MEDIUM |
| GoPlus Risk Flags | N/A (native L1 token, not EVM) | -- | N/A |

### Audit Coverage Score Calculation
- Zellic bridge audit (August 2023): >2 years old = 0.25
- Zellic bridge patch review (November 2023): >2 years old = 0.25
- **Total: 0.50** -- HIGH risk (threshold: >= 3.0 = LOW, 1.5-2.99 = MEDIUM, < 1.5 = HIGH)

Note: Only the bridge contract has been audited. The L1 consensus code (HyperBFT), the clearinghouse, the liquidation engine, the oracle system, HyperEVM integration, and the CoreWriter/broadcaster infrastructure have no publicly disclosed audits.

## GoPlus Token Security

**N/A** -- HYPE is a native L1 token on the Hyperliquid chain, which is not an EVM chain supported by GoPlus. The token does not have an ERC-20 representation on Ethereum or Arbitrum that can be scanned. GoPlus token security analysis cannot be performed.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **HIGH** | Foundation-controlled with no timelock, no DAO, CoreWriter godmode, 8 undocumented broadcaster addresses | S/O | Partial |
| Oracle & Price Feeds | **MEDIUM** | Custom validator-published oracle from CEX feeds; no independent fallback; manipulation demonstrated | S/H | Partial |
| Economic Mechanism | **MEDIUM** | HLP vault has absorbed multiple manipulation attacks; ADL activated; AF burned reducing reserve buffer | S/H | Partial |
| Smart Contract | **HIGH** | L1 code closed source; only bridge audited (2023); no core protocol audit; CoreWriter allegations | S | N |
| Token Contract (GoPlus) | **N/A** | Native L1 token; GoPlus not applicable | -- | N/A |
| Cross-Chain & Bridge | **HIGH** | $3.36B in single bridge contract; 4 team-controlled validators; no independent bridge audit since 2023 | S | Partial |
| Off-Chain Security | **HIGH** | No SOC 2/ISO 27001, no published key management policy, no penetration testing disclosure, small team | O | N |
| Operational Security | **MEDIUM** | Doxxed founder; small team (~11 people); DPRK reconnaissance activity; $362M insolvency FUD (resolved) | S/H/O | Partial |
| **Overall Risk** | **HIGH** | **Massive TVL with strong product-market fit, but HIGH governance (counts 2x) plus HIGH smart contract, bridge, and off-chain security risks. Multiple manipulation incidents and reverse-engineering controversies in 2025.** | | |

**Overall Risk aggregation**: Governance & Admin = HIGH (counts as 2x = 2 HIGHs). Smart Contract = HIGH. Cross-Chain & Bridge = HIGH. Off-Chain Security = HIGH. Total: 5 HIGH-equivalent ratings. Rule: 2+ HIGH = Overall HIGH.

Note: Previous audit rated Overall MEDIUM. Upgrade to HIGH driven by: (1) newly assessed Off-Chain Security category rated HIGH, (2) applying the 2x governance weight rule from the updated template, and (3) CoreWriter/broadcaster revelations increasing governance concern.

## Detailed Findings

### 1. Governance & Admin Key

**Risk: HIGH**

**Admin Key Surface Area:**
- The Hyperliquid Protocol Foundation controls the bridge contract proxy admin, which can change the bridge implementation at will. This is an extremely powerful privilege over $3.36B in bridged assets.
- The "Cold Validator Set" (4 addresses controlled by the Foundation) has authority to change system parameters, rewrite validator set lists, and invalidate withdrawals. In practice, this functions as a team-controlled governance multisig.
- There is no documented timelock on any admin actions. Parameter changes, bridge upgrades, and emergency actions can be executed immediately.
- The Foundation can delist tokens (as demonstrated in the JELLY incident in March 2025) and settle positions at arbitrary prices through validator consensus. Post-JELLY, asset delisting now requires on-chain validator voting.
- A "Locker" group of validators functions as a security committee with the ability to pause bridge operations in emergencies.

**CoreWriter and Broadcaster System (NEW):**
- December 2025 reverse-engineering revealed a "CoreWriter" interface described as having "godmode" capabilities.
- Only 8 broadcaster addresses can submit transactions to the L1; all other users route through them.
- These 8 addresses are governance-modifiable, undocumented, and do not match publicly known wallets.
- Hyperliquid states CoreWriter is a documented interface for HyperEVM smart contracts to submit standard actions (placing orders, staking) and cannot mint tokens or move user funds -- UNVERIFIED independently due to closed-source code.
- The broadcaster system introduces a centralization bottleneck: if these 8 addresses are compromised or censoring, all L1 transaction submission is affected.

**Multisig Configuration:**
- Hot Validator Set: 4 addresses for signing withdrawals (2/3 stake-weighted threshold required)
- Cold Validator Set: 4 addresses for administrative actions
- Locker Set: validators with bridge pause authority
- Finalizer Set: validators for transaction finality
- All sets are controlled by the Hyperliquid team/Foundation
- Signer identities are not publicly disclosed -- UNVERIFIED

**Governance Process:**
- No on-chain DAO governance exists. Hyperliquid Improvement Proposals (HIPs) are discussed informally and implemented by the team.
- Validator votes have been used for specific proposals (e.g., the HYPE burn proposal, JELLY delisting), but this is not a general-purpose governance mechanism.
- The validator set expanded to ~21 permissionless consensus nodes, but the Foundation's stake still gives it dominant control.
- Post-JELLY, on-chain validator voting is now required for asset delisting -- a meaningful improvement in governance for that specific action.

**Timelock Bypass:**
- There is no timelock to bypass. The team can act immediately on all protocol parameters.

**Token Concentration:**
- HYPE distribution was via a large community airdrop (no VC allocation).
- Assistance Fund HYPE (~37.5M tokens, ~$912M) has been formally burned and is mathematically irretrievable without a hard fork. This removes a potential centralization vector but also reduces the protocol's emergency reserve buffer.
- Core contributor allocation of 23.8% (238M tokens) began vesting in January 2026 over 24 months (~1.2M tokens/month, on the 6th of each month).
- Foundation's self-delegated stake likely represents a dominant share of the validator set.

### 2. Oracle & Price Feeds

**Risk: MEDIUM**

**Oracle Architecture:**
- Hyperliquid uses a custom oracle where validators publish spot prices every 3 seconds.
- Prices are computed as a weighted median from 8 centralized exchanges: Binance (weight 3), OKX (2), Bybit (2), Kraken (1), Kucoin (1), Gate IO (1), MEXC (1), and Hyperliquid spot (1).
- The final oracle price is a stake-weighted average across all validators.

**Strengths:**
- Multi-source pricing from major exchanges reduces single-point-of-failure risk.
- Weighted median is manipulation-resistant for liquid assets.
- 3-second update frequency is appropriate for a perps exchange.

**Weaknesses:**
- No independent fallback oracle (e.g., Chainlink, Pyth) for the core clearinghouse. While Chainlink and Pyth are available on HyperEVM for third-party dApps, the core perps engine relies solely on the custom oracle.
- For illiquid assets, the CEX price feeds can be manipulated (as demonstrated in the JELLY and POPCAT attacks).
- Validators all run the same oracle code -- a bug in the oracle implementation would affect all validators simultaneously (single-client risk).
- Admin (Foundation) can change oracle sources without a timelock or governance vote -- UNVERIFIED.

**Collateral/Market Listing:**
- HIP-3 (October 2025) made perpetual market deployment permissionless with a 500K HYPE staking requirement.
- This permissionless listing creates risk of illiquid markets being created that are susceptible to manipulation.
- Post-JELLY, margin tiers (launched May 2025) dynamically adjust maximum leverage based on position size, partially mitigating the fixed-leverage vulnerability that was exploited.

### 3. Economic Mechanism

**Risk: MEDIUM**

**Liquidation Mechanism:**
- Liquidations are handled by the HLP (Hyperliquidity Provider) vault, which acts as the primary counterparty for liquidated positions.
- When HLP cannot absorb losses, Auto-Deleveraging (ADL) is triggered, which socializes losses by force-closing profitable positions starting with the highest-leverage, highest-profit traders.
- ADL was activated for the first time in November 2025 during the POPCAT incident.
- Post-JELLY improvement: Liquidator vault is now capped to a small percentage of total HLP balance with isolated collateral, limiting cascade risk.

**Bad Debt History (2025):**
- March 2025: JELLY token manipulation resulted in ~$12M in potential losses. Validators intervened by delisting JELLY and settling at $0.0095 instead of the manipulated $0.50 price. JELLY long holders were refunded by the Foundation at $0.037555.
- September 2025: $782K Hyperdrive smart contract exploit + $3.6M HyperVault rug pull (third-party protocols on HyperEVM, not Hyperliquid core).
- October 2025: $21M theft via private key compromise (user-side incident, not protocol vulnerability).
- November 2025: POPCAT manipulation caused ~$4.9M in bad debt absorbed by HLP. The protocol responded by reducing max leverage from 50x to 25-40x for major assets.
- Multiple incidents demonstrate that the market manipulation attack vector is structural and recurring.

**Insurance/Safety Net:**
- HLP vault: ~$400M TVL (community-deposited liquidity; recovered from post-JELLY dip)
- Assistance Fund: ~37.5M HYPE formally burned (no longer available as emergency reserve). New fee revenue continues to flow as buyback-and-burn.
- The AF burn improves tokenomics but removes a potential emergency backstop. The protocol now relies primarily on HLP and ongoing fee revenue for loss absorption.
- HLP depositors bear first-loss risk from manipulation attacks, which has already materialized multiple times.

**Funding Rate Model:**
- Standard funding rate mechanism for perpetual futures. No specific concerns identified beyond the general risk of extreme rates during volatile markets.

**December 2025 Insolvency Allegations:**
- A researcher alleged a $362M gap between bridge USDC and user balances. Hyperliquid responded that the analysis omitted ~$362M in HyperEVM vault USDC and ~$59M in native USDC, fully accounting for all balances.
- The incident highlighted the complexity of cross-environment accounting and the need for better public transparency tooling.

### 4. Smart Contract Security

**Risk: HIGH**

**Audit History:**
- 2 Zellic audits of the bridge contract only (August 2023 initial assessment + November 2023 patch review)
- No publicly disclosed audits of: L1 consensus code (HyperBFT), clearinghouse, liquidation engine, oracle system, HyperEVM integration, CoreWriter/broadcaster infrastructure
- The bridge audits are over 2.5 years old, and the protocol has undergone significant upgrades since (Bridge2, HyperEVM launch, margin tiers, HIP-3)
- No new audits announced or disclosed since the previous audit

**Bug Bounty:**
- Hyperliquid maintains its own bug bounty program (not on Immunefi) with documented reward tiers:
  - Critical (loss of user funds or L1 execution invariant violation): up to $1M USDC
  - High (network downtime without incorrect state): up to $50K USDC
- Rewards paid in USDC on Hyperliquid
- The $1M critical bounty is a significant improvement over the previously undisclosed maximum, but remains below peer benchmarks (GMX: $5M on Immunefi) and is self-hosted rather than on a third-party platform

**Battle Testing:**
- Protocol has been live since 2023 with peak TVL of ~$5B.
- Has processed over $4.27 trillion in cumulative trading volume.
- 24-hour trading volume: ~$7B; open interest: ~$7.6B.
- Multiple market manipulation incidents, but no direct smart contract exploits of the core protocol.
- Third-party HyperEVM protocols (Hyperdrive, HyperVault) have been exploited, raising concerns about HyperEVM security.
- ~44% market share in decentralized perp DEX sector as of April 2026.

**Source Code:**
- L1 node code: **Closed source** (distributed as precompiled binaries `hl-visor` and `hl-node`). The team has stated it will be open-sourced "when it's secure to do so." No timeline provided.
- Bridge contract: Open source on GitHub (hyperliquid-dex/contracts/Bridge2.sol)
- SDKs (Python, Rust): Open source
- CoreWriter and broadcaster system: Functionality described by Hyperliquid but implementation not independently verifiable due to closed-source code.
- The closed-source L1 code means independent security researchers cannot review the consensus mechanism, clearinghouse logic, oracle implementation, or CoreWriter capabilities. This is a significant risk for a protocol holding ~$5B.

### 5. Cross-Chain & Bridge

**Risk: HIGH**

**Bridge Architecture:**
- Single bridge contract on Arbitrum (0x2df1c51e09aecf9cacb7bc98cb1742757f163df7) holds ~$3.36B in USDC (down from $3.77B as liquidity migrates to native USDC on HyperEVM).
- Bridge uses CCTP (Cross-Chain Transfer Protocol) for native USDC minting on Hyperliquid.
- Withdrawals require 2/3 stake-weighted signatures from the Hot Validator Set.
- Deposits and withdrawals are batched and finalized exclusively by the team.
- Hyperliquid is transitioning to support one-click deposits from any CCTP-enabled chain, reducing Arbitrum dependency over time.

**Validator Set for Bridge:**
- Hot Validator Set: **Still 4 addresses** (team-controlled) for withdrawal signing -- NO CHANGE since previous audit
- Cold Validator Set: **Still 4 addresses** (team-controlled) for admin actions and withdrawal invalidation
- Locker Set: Security committee with bridge pause authority
- All validators reportedly ran the same client software on the same cloud provider (as of late 2024) -- diversification status UNVERIFIED
- The consensus validator set has expanded to ~21, but bridge security still relies on the original 4-address architecture

**Single Points of Failure:**
- Compromise of 3 out of 4 hot validator keys would allow unauthorized withdrawals of $3.36B.
- Single cloud provider dependency creates infrastructure concentration risk.
- No independent bridge audit since November 2023, despite Bridge2 upgrade.

**Comparison to Peers:**
- dYdX Chain: 60 validators, Cosmos-based with IBC for bridging
- GMX: Runs directly on Arbitrum (no custom bridge needed)
- Hyperliquid's bridge architecture is closer to Ronin's pre-hack design (small validator set, team-controlled) than to production-grade cross-chain infrastructure.

### 6. Off-Chain Security

**Risk: HIGH**

**Third-Party Security Certifications:**
- No SOC 2 Type II, ISO 27001, or equivalent certification disclosed.
- No published security practices beyond the bug bounty program.

**Key Management:**
- No published key management policy. Whether HSMs, MPC custody, or documented key ceremony procedures are used is unknown.
- No disclosed key rotation policy for bridge validators or admin keys.

**Penetration Testing:**
- No infrastructure-level penetration testing disclosed (distinct from smart contract audits).

**Operational Segregation:**
- Unknown whether developers have production key access or whether separation of duties exists between development, deployment, and admin operations.

**Employee/Insider Threat Controls:**
- December 2025: Hyperliquid confirmed a former employee was responsible for HYPE token shorting, suggesting potential insider access issues.
- No published employee security practices (background checks, access logging, least privilege).

### 7. Operational Security

**Risk: MEDIUM**

**Team & Track Record:**
- Founded by Jeff Yan (Harvard math/CS, ex-Hudson River Trading, ex-Google). Doxxed and publicly known.
- Small team of ~11 people, bootstrapped with no VC funding (funded from Chameleon Trading profits).
- No prior security incidents under their management before Hyperliquid (trading firm background).
- The small team size is a double-edged sword: focused execution but limited security bandwidth.

**DPRK/Lazarus Group Activity (December 2024):**
- MetaMask security researcher Tay Monahan identified DPRK-linked wallets actively using (and losing money on) Hyperliquid.
- Monahan warned: "DPRK doesn't trade. DPRK tests." -- suggesting reconnaissance for a potential exploit.
- $256M in net outflows followed the revelation; HYPE dropped 20%.
- Hyperliquid denied any exploit occurred and stated all funds were accounted for.
- The incident highlighted the risk that 4 validators running the same code on the same infrastructure could be compromised by a sophisticated state actor.
- As of this audit date (April 2026, 16 months later), no DPRK exploit of Hyperliquid has materialized, but the reconnaissance activity remains a concern given Lazarus Group's history ($1.5B Bybit hack in February 2025).
- Monahan's offer to help Hyperliquid harden against DPRK threats reportedly remains open. It is unknown whether Hyperliquid has engaged external security assistance.

**December 2025 Controversies:**
- Reverse-engineering report alleged $362M insolvency, CoreWriter godmode, and volume manipulation. Hyperliquid denied all claims and provided on-chain evidence of solvency.
- Former employee confirmed as responsible for HYPE shorting activity.
- These incidents, while individually addressed, demonstrate the opacity that closed-source code and undisclosed infrastructure create.

**Incident Response:**
- The team has demonstrated rapid incident response (JELLY delisting within minutes via validator consensus, leverage reductions after POPCAT).
- Post-JELLY improvements: on-chain validator voting for delisting, margin tiers, liquidator vault isolation.
- However, the response mechanism is centralized -- validators can delist assets and settle positions at arbitrary prices, now requiring a validator vote but with the Foundation controlling dominant stake.
- No published incident response plan or formal security framework.

**Dependencies:**
- Arbitrum: Bridge contract lives on Arbitrum One (transitioning to multi-chain CCTP)
- USDC/Circle: Core settlement asset
- CEX price feeds: Oracle depends on 8 centralized exchanges remaining operational and accurate
- Single cloud provider: Infrastructure concentration (UNVERIFIED if diversified since late 2024)

## Critical Risks

1. **Bridge centralization**: $3.36B held in a single bridge contract controlled by 4 team-operated validators. Compromise of 3 keys (or social engineering of the team) could drain the majority of funds. This mirrors the Ronin Bridge attack pattern. **No change since previous audit.**
2. **Closed-source L1 code**: The core consensus, clearinghouse, oracle code, and CoreWriter/broadcaster infrastructure cannot be independently verified. For a $5B protocol, this is a significant trust assumption. **No change since previous audit.**
3. **No timelock on admin actions**: The Foundation can upgrade the bridge contract, change parameters, delist assets, and settle positions at arbitrary prices with no delay. Post-JELLY, delisting requires validator voting, but other admin actions remain unconstrained. **Marginal improvement only.**
4. **Audit gap**: Only the bridge contract was audited (2023, now >2.5 years old). The L1 consensus mechanism, liquidation engine, oracle system, CoreWriter, and broadcaster infrastructure securing $5B have no disclosed audits. **No change since previous audit.**
5. **DPRK reconnaissance**: State-sponsored hackers have specifically targeted this protocol. With a small validator set and single-client architecture, the attack surface is concerning. **16 months since initial detection with no exploit, but risk persists.**
6. **CoreWriter and broadcaster opacity**: 8 undocumented broadcaster addresses control all L1 transaction submission. CoreWriter's actual capabilities are unverifiable due to closed-source code. Hyperliquid's claim that it cannot mint tokens or move funds is a trust assertion.
7. **Off-chain security gap**: No SOC 2/ISO 27001, no published key management, no penetration testing -- for a $5B protocol, the absence of off-chain security controls disclosure is itself a risk signal.

## Peer Comparison

| Feature | Hyperliquid | GMX (Arbitrum) | dYdX Chain |
|---------|-------------|----------------|------------|
| Timelock | None documented | 24h (Arbitrum) | Governance vote |
| Multisig | 4 hot validators (team) | Community multisig + Security Council | 60 validators (PoS) |
| Audits | 2 (bridge only, 2023) | 17+ (Guardian Audits ongoing) | Multiple (Informal Systems, others) |
| Oracle | Custom CEX feed median | Chainlink + custom | Skip protocol (custom) |
| Insurance/TVL | ~8% (HLP ~$400M / $4.87B) | GLP pool + fee reserves | Insurance fund + MegaVault |
| Open Source | Partial (bridge only) | Yes (full) | Yes (full, Cosmos SDK) |
| Bug Bounty | Self-hosted ($1M max) | $5M on Immunefi | $150K on Immunefi |
| Bridge Risk | HIGH ($3.36B, 4 validators) | N/A (native Arbitrum) | LOW (IBC, 60 validators) |
| Security Certs | None disclosed | None disclosed | None disclosed |

## Recommendations

1. **For users**: Be aware that all funds on Hyperliquid depend on the security of 4 team-controlled bridge validators. Consider limiting exposure relative to total portfolio. Use hardware wallets and monitor bridge contract activity. The CoreWriter/broadcaster system adds an additional centralization layer that is not independently auditable.
2. **For the protocol**: Open-source the L1 node code as a priority. The "when it's secure to do so" rationale has persisted for over 2 years and is inadequate for $5B in custody. At minimum, provide the code to independent auditors under NDA.
3. **For the protocol**: Commission comprehensive audits of the L1 consensus code, clearinghouse, liquidation engine, oracle system, CoreWriter, and broadcaster infrastructure. The 2023 bridge-only audits are insufficient.
4. **For the protocol**: Implement a timelock on bridge upgrades and admin parameter changes. Even a 24-hour delay would significantly reduce key compromise risk.
5. **For the protocol**: Expand the bridge validator set beyond 4 addresses and diversify infrastructure across multiple cloud providers and client implementations. The consensus validator set grew to 21 -- the bridge validator set should follow.
6. **For the protocol**: Move the bug bounty to Immunefi or another third-party platform and increase the maximum payout to be commensurate with TVL ($5M+ for critical findings).
7. **For the protocol**: Obtain SOC 2 Type II or equivalent certification and publish key management practices. For a protocol custodying $5B, off-chain security attestation is expected.
8. **For the protocol**: Document the broadcaster address system publicly, including selection criteria, rotation procedures, and censorship resistance guarantees.
9. **For HLP depositors**: Understand that HLP bears first-loss risk from market manipulation attacks, which have occurred 3+ times in 2025. The AF burn reduces the emergency backstop. This is not a risk-free yield product.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- HIP-3 enables permissionless perps listing; spot listing via HIP-1 auction
- [x] Admin can change oracle sources arbitrarily? -- UNVERIFIED but likely, given Foundation control
- [x] Admin can modify withdrawal limits? -- Cold validator set can modify parameters
- [x] Multisig has low threshold (2/N with small N)? -- 3/4 effective threshold for bridge operations
- [x] Zero or short timelock on governance actions? -- No timelock documented
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- Bridge validator identities undisclosed; 8 broadcaster addresses undocumented

**Drift-type risk: HIGH** -- 5/6 applicable indicators match. **WARNING: 3+ indicators triggered.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [x] Low-liquidity collateral accepted? -- HIP-3 permissionless perps on illiquid tokens
- [ ] Single oracle source without TWAP? -- Multi-source CEX median, but no TWAP
- [ ] No circuit breaker on price movements? -- Margin tiers added post-JELLY; full circuit breakers UNVERIFIED
- [ ] Insufficient insurance fund relative to TVL? -- Insurance adequate (~8%)

**Euler/Mango-type risk: MEDIUM** -- Market manipulation has occurred multiple times but insurance has absorbed losses. Margin tiers are a meaningful improvement.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- 4 team-controlled hot validators for $3.36B bridge
- [x] Admin keys stored in hot wallets? -- "Hot" validator keys are online by design for withdrawal signing
- [ ] No key rotation policy? -- UNVERIFIED

**Ronin/Harmony-type risk: HIGH** -- The bridge architecture (small validator set, team-controlled, single client) closely mirrors pre-hack Ronin. The DPRK reconnaissance activity makes this pattern especially concerning. **WARNING: 3+ indicators triggered** (when combined with the structural bridge design).

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time? -- No on-chain token governance exists
- [ ] Flash loans can be used to acquire voting power? -- N/A
- [ ] Proposal + execution in same block or short window? -- N/A
- [ ] No minimum holding period for voting eligibility? -- N/A

**Beanstalk-type risk: N/A** -- No token-based governance mechanism exists.

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? -- UNVERIFIED (L1 closed source)
- [ ] Read-only reentrancy risk? -- UNVERIFIED (L1 closed source)
- [ ] Flash loan compatible without reentrancy guards? -- UNVERIFIED (L1 closed source)
- [ ] Composability with protocols that expose callback hooks? -- HyperEVM protocols interact with HyperCore

**Cream/bZx-type risk: UNVERIFIED** -- Cannot assess due to closed-source L1 code.

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler? -- Rust (standard), but binary not auditable
- [ ] Compiler version has known CVEs? -- UNVERIFIED
- [ ] Contracts compiled with different compiler versions? -- UNVERIFIED
- [ ] Code depends on language-specific behavior? -- UNVERIFIED

**Curve-type risk: UNVERIFIED** -- Cannot assess due to closed-source L1 code.

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral? -- N/A (uses USDC, not algorithmic stablecoin)
- [ ] Redemption mechanism creates sell pressure on collateral? -- N/A
- [ ] Oracle delay could mask depegging? -- N/A
- [ ] No circuit breaker on redemption volume? -- N/A

**UST/LUNA-type risk: N/A** -- Protocol uses USDC settlement, no algorithmic stablecoin.

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [x] Protocol uses a cross-chain bridge for token minting or reserve release? -- Bridge controls $3.36B USDC
- [ ] Bridge message validation relies on a single messaging layer without independent verification? -- Custom bridge, not LayerZero/Wormhole
- [ ] DVN/relayer/verifier configuration is not publicly documented? -- Bridge validator addresses are on-chain but identities undisclosed
- [ ] Bridge can release or mint tokens without rate limiting? -- UNVERIFIED
- [ ] Bridged/wrapped token is accepted as collateral on lending protocols? -- HyperEVM lending protocols accept USDC
- [ ] No circuit breaker to pause minting if bridge-released volume exceeds normal thresholds? -- Locker set can pause bridge
- [ ] Emergency pause response time > 15 minutes? -- JELLY response was within minutes
- [ ] Bridge admin controls under different governance than core protocol? -- Same team controls both
- [ ] Token deployed on 5+ chains via same bridge? -- No, single bridge Arbitrum-to-HL

**Kelp-type risk: LOW** -- Single bridge, same team controls, pause capability exists.

## Information Gaps

- **L1 source code**: The core consensus (HyperBFT), clearinghouse, liquidation engine, CoreWriter, broadcaster system, and oracle implementation are closed source. Independent verification of any security claims about these components is impossible.
- **CoreWriter capabilities**: Hyperliquid claims CoreWriter cannot mint tokens or move user funds. This is unverifiable with closed-source code. The December 2025 reverse-engineering report's "godmode" characterization remains disputed.
- **Broadcaster address identities and selection**: The 8 broadcaster addresses that control all L1 transaction submission are undocumented. Their selection criteria, rotation procedures, and censorship resistance properties are unknown.
- **Bridge validator identities**: The 4 hot and 4 cold validator addresses are not publicly mapped to known entities or individuals.
- **Timelock existence**: No documentation confirms or denies the existence of any timelock on bridge upgrades or parameter changes. Assumed to be zero.
- **Key management practices**: How validator keys are stored, whether HSMs are used, key rotation policies, and infrastructure diversity are all undisclosed. The former employee shorting incident raises questions about access controls.
- **Bridge validator set expansion**: The bridge's hot/cold validator sets remain at 4 addresses each, despite the consensus validator set growing to ~21. Whether there are plans to expand bridge validators is unknown.
- **Cloud provider diversification**: Whether the team has diversified infrastructure across multiple cloud providers since the December 2024 DPRK incident is unknown.
- **Audit pipeline**: Whether new audits of the L1 code or updated bridge audits are in progress is not publicly disclosed. Over 2.5 years without a new audit for a protocol that has undergone major upgrades.
- **Security certifications**: No SOC 2, ISO 27001, or equivalent certification exists or is planned.
- **Penetration testing**: No infrastructure-level penetration testing has been disclosed.
- **DPRK engagement**: Whether Hyperliquid has engaged external security consultants or threat intelligence firms (such as Tay Monahan's offered assistance) to address the DPRK reconnaissance threat is unknown.

## Disclaimer
This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
