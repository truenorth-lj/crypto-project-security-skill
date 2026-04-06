# DeFi Security Audit: Hyperliquid

**Audit Date:** April 6, 2026
**Protocol:** Hyperliquid -- L1 Perpetual Futures and Spot DEX

## Overview
- Protocol: Hyperliquid
- Chain: Hyperliquid L1 (custom HyperBFT consensus), bridged via Arbitrum
- Type: Perpetual futures DEX / Spot DEX / L1 blockchain
- TVL: ~$4.79B (bridge: $3.77B on Arbitrum, $1.02B on Hyperliquid L1)
- TVL Trend: +1.7% / +13.3% / +15.5% (7d / 30d / 90d)
- Launch Date: Late 2022 (testnet); mainnet alpha 2023; HyperEVM February 2025
- Audit Date: April 6, 2026
- Source Code: Partial (bridge contract open source on GitHub; L1 node code closed source, distributed as precompiled binaries)

## Quick Triage Score: 60/100

- Red flags found: 6
  - HIGH: Closed-source L1 node code (-15)
  - LOW: No documented timelock on admin actions (-5)
  - LOW: Custom in-house oracle with no independent fallback (-5)
  - LOW: Insurance fund / TVL ratio not precisely disclosed (-5)
  - LOW: Undisclosed bridge multisig signer identities (-5)
  - LOW: No Immunefi bug bounty for core L1/bridge protocol (-5)

Score: 100 - 15 - 5 - 5 - 5 - 5 - 5 = **60**

Score meaning: 50-79 = MEDIUM risk

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | ~8-10% (HLP ~$500M + AF ~$920M vs $4.8B TVL) | >5% healthy | LOW |
| Audit Coverage Score | 0.50 (2 Zellic bridge audits from 2023, >2yr old) | 3.0+ (GMX: 17 audits) | HIGH |
| Governance Decentralization | Foundation-controlled; no on-chain DAO voting | dYdX: 60 validators + DAO | HIGH |
| Timelock Duration | 0h (no documented timelock) | GMX: 24h; dYdX: governance vote | HIGH |
| Multisig Threshold | ~3/4 (2/3 stake-weighted, 4 hot validators) | GMX: community multisig; dYdX: 60 validators | MEDIUM |
| GoPlus Risk Flags | N/A (native L1 token, not EVM) | -- | N/A |

### Audit Coverage Score Calculation
- Zellic bridge audit (August 2023): >2 years old = 0.25
- Zellic bridge patch review (November 2023): >2 years old = 0.25
- **Total: 0.50** -- HIGH risk (threshold: >= 3.0 = LOW, 1.5-2.99 = MEDIUM, < 1.5 = HIGH)

Note: Only the bridge contract has been audited. The L1 consensus code (HyperBFT), the clearinghouse, the liquidation engine, and the oracle system have no publicly disclosed audits.

## GoPlus Token Security

**N/A** -- HYPE is a native L1 token on the Hyperliquid chain, which is not an EVM chain supported by GoPlus. The token does not have an ERC-20 representation on Ethereum or Arbitrum that can be scanned. GoPlus token security analysis cannot be performed.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **HIGH** | Foundation-controlled with no timelock, no DAO, 4-validator hot set controls bridge | Partial |
| Oracle & Price Feeds | **MEDIUM** | Custom validator-published oracle from CEX feeds; no independent fallback | Partial |
| Economic Mechanism | **MEDIUM** | HLP vault has absorbed multiple manipulation attacks; ADL socialized loss mechanism | Partial |
| Smart Contract | **HIGH** | L1 code closed source; only bridge audited (2023); no core protocol audit | N |
| Token Contract (GoPlus) | **N/A** | Native L1 token; GoPlus not applicable | N/A |
| Cross-Chain & Bridge | **HIGH** | $3.77B in single bridge contract; 4 team-controlled validators; no independent bridge audit since 2023 | Partial |
| Operational Security | **MEDIUM** | Doxxed founder; small team (~11 people); DPRK reconnaissance activity in Dec 2024 | Partial |
| **Overall Risk** | **MEDIUM** | **Massive TVL with strong product-market fit, but significant centralization risk in bridge, validator set, and governance. Multiple market manipulation incidents in 2025.** | |

## Detailed Findings

### 1. Governance & Admin Key

**Risk: HIGH**

**Admin Key Surface Area:**
- The Hyperliquid Protocol Foundation controls the bridge contract proxy admin, which can change the bridge implementation at will. This is an extremely powerful privilege over $3.77B in bridged assets.
- The "Cold Validator Set" (4 addresses controlled by the Foundation) has authority to change system parameters and invalidate withdrawals. In practice, this functions as a team-controlled governance multisig.
- There is no documented timelock on any admin actions. Parameter changes, bridge upgrades, and emergency actions can be executed immediately.
- The Foundation can delist tokens (as demonstrated in the JELLY incident in March 2025) and settle positions at arbitrary prices through validator consensus.

**Multisig Configuration:**
- Hot Validator Set: 4 addresses for signing withdrawals (2/3 stake-weighted threshold required)
- Cold Validator Set: 4 addresses for administrative actions
- Both sets are controlled by the Hyperliquid team/Foundation
- Signer identities are not publicly disclosed -- UNVERIFIED

**Governance Process:**
- No on-chain DAO governance exists. Hyperliquid Improvement Proposals (HIPs) are discussed informally and implemented by the team.
- Validator votes have been used for specific proposals (e.g., the token burn proposal), but this is not a general-purpose governance mechanism.
- The validator set expanded to 21 permissionless nodes in April 2025, but the Foundation's stake still gives it dominant control.

**Timelock Bypass:**
- There is no timelock to bypass. The team can act immediately on all protocol parameters.

**Token Concentration:**
- HYPE distribution was via a large community airdrop (no VC allocation). However, the Assistance Fund holds ~40M HYPE ($920M+) and the Foundation controls additional allocations.
- Staking is live, but the Foundation's self-delegated stake likely represents a dominant share of the validator set.

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
- Validators all run the same oracle code -- a bug in the oracle implementation would affect all validators simultaneously.
- Admin (Foundation) can change oracle sources without a timelock or governance vote -- UNVERIFIED.

**Collateral/Market Listing:**
- HIP-3 (October 2025) made perpetual market deployment permissionless with a 500K HYPE staking requirement.
- This permissionless listing creates risk of illiquid markets being created that are susceptible to manipulation.

### 3. Economic Mechanism

**Risk: MEDIUM**

**Liquidation Mechanism:**
- Liquidations are handled by the HLP (Hyperliquidity Provider) vault, which acts as the primary counterparty for liquidated positions.
- When HLP cannot absorb losses, Auto-Deleveraging (ADL) is triggered, which socializes losses by force-closing profitable positions starting with the highest-leverage, highest-profit traders.
- ADL was activated for the first time in November 2025 during the POPCAT incident.

**Bad Debt History (2025):**
- March 2025: JELLY token manipulation resulted in ~$12M in potential losses. Validators intervened by delisting JELLY and settling at $0.0095 instead of the manipulated $0.50 price. This intervention was effective but raised concerns about centralized emergency powers.
- November 2025: POPCAT manipulation caused ~$4.9M in bad debt absorbed by HLP. The protocol responded by reducing max leverage from 50x to 25-40x for major assets.
- September 2025: $700K exploit.
- Multiple incidents demonstrate that the market manipulation attack vector is structural and recurring.

**Insurance/Safety Net:**
- HLP vault: ~$500M TVL (community-deposited liquidity)
- Assistance Fund: ~$920M in HYPE tokens (used for buybacks, proposed to be burned)
- Combined reserves are substantial relative to TVL, but the Assistance Fund is denominated in HYPE (correlated risk -- drops in a crisis when most needed).
- HLP depositors bear first-loss risk from manipulation attacks, which has already materialized multiple times.

**Funding Rate Model:**
- Standard funding rate mechanism for perpetual futures. No specific concerns identified beyond the general risk of extreme rates during volatile markets.

### 4. Smart Contract Security

**Risk: HIGH**

**Audit History:**
- 2 Zellic audits of the bridge contract only (August 2023 initial assessment + November 2023 patch review)
- No publicly disclosed audits of: L1 consensus code (HyperBFT), clearinghouse, liquidation engine, oracle system, or HyperEVM integration
- The bridge audits are over 2 years old, and the protocol has undergone significant upgrades since (Bridge2, HyperEVM launch)
- DeFiLlama lists "2" audits, all scoped to bridge contracts

**Bug Bounty:**
- Hyperliquid maintains its own bug bounty program (not on Immunefi) with rewards in USDC on Hyperliquid.
- Maximum payout and scope are not clearly documented publicly -- UNVERIFIED.
- Felix (a lending protocol on Hyperliquid) has an Immunefi bounty up to $100K, but this is a third-party protocol, not Hyperliquid core.
- By comparison, GMX offers up to $5M on Immunefi.

**Battle Testing:**
- Protocol has been live since 2023 with peak TVL of ~$5B.
- Has processed over $3T in cumulative trading volume.
- Multiple market manipulation incidents, but no direct smart contract exploits of the core protocol.
- The October 2025 $21M theft was a private key compromise (user-side), not a protocol vulnerability.

**Source Code:**
- L1 node code: **Closed source** (distributed as precompiled binaries `hl-visor` and `hl-node`). The team has stated it will be open-sourced "when it's secure to do so."
- Bridge contract: Open source on GitHub (hyperliquid-dex/contracts/Bridge2.sol)
- SDKs (Python, Rust): Open source
- The closed-source L1 code means independent security researchers cannot review the consensus mechanism, clearinghouse logic, or oracle implementation. This is a significant risk for a protocol holding ~$5B.

### 5. Cross-Chain & Bridge

**Risk: HIGH**

**Bridge Architecture:**
- Single bridge contract on Arbitrum (0x2df1c51e09aecf9cacb7bc98cb1742757f163df7) holds $3.77B in USDC.
- At one point, the bridge held 67% of all USDC on Arbitrum, making it a high-value target.
- Bridge uses CCTP (Cross-Chain Transfer Protocol) for native USDC minting on Hyperliquid.
- Withdrawals require 2/3 stake-weighted signatures from the Hot Validator Set.
- Deposits and withdrawals are batched and finalized exclusively by the team.

**Validator Set for Bridge:**
- Hot Validator Set: 4 addresses (team-controlled) for withdrawal signing
- Cold Validator Set: 4 addresses (team-controlled) for admin actions and withdrawal invalidation
- All validators reportedly ran the same client software on the same cloud provider (as of late 2024)
- The validator set has expanded to 21 for consensus, but bridge security still relies on the original architecture -- UNVERIFIED whether bridge validator set has expanded.

**Single Points of Failure:**
- Compromise of 3 out of 4 hot validator keys would allow unauthorized withdrawals of $3.77B.
- Single cloud provider dependency creates infrastructure concentration risk.
- No independent bridge audit since November 2023, despite Bridge2 upgrade.

**Comparison to Peers:**
- dYdX Chain: 60 validators, Cosmos-based with IBC for bridging
- GMX: Runs directly on Arbitrum (no custom bridge needed)
- Hyperliquid's bridge architecture is closer to Ronin's pre-hack design (small validator set, team-controlled) than to production-grade cross-chain infrastructure.

### 6. Operational Security

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
- As of this audit date, no DPRK exploit of Hyperliquid has materialized, but the reconnaissance activity remains a concern given Lazarus Group's history ($1.3B stolen in 2024, including Ronin and Bybit).

**Incident Response:**
- The team has demonstrated rapid incident response (JELLY delisting within hours, leverage reductions after POPCAT).
- However, the response mechanism is entirely centralized -- validators can delist assets and settle positions at arbitrary prices without governance approval.
- No published incident response plan or formal security framework.

**Dependencies:**
- Arbitrum: Bridge contract lives on Arbitrum One
- USDC/Circle: Core settlement asset
- CEX price feeds: Oracle depends on 8 centralized exchanges remaining operational and accurate
- Single cloud provider: Infrastructure concentration (UNVERIFIED if diversified since late 2024)

## Critical Risks

1. **Bridge centralization**: $3.77B held in a single bridge contract controlled by 4 team-operated validators. Compromise of 3 keys (or social engineering of the team) could drain all funds. This mirrors the Ronin Bridge attack pattern.
2. **Closed-source L1 code**: The core consensus, clearinghouse, and oracle code cannot be independently verified. For a $5B protocol, this is a significant trust assumption.
3. **No timelock on admin actions**: The Foundation can upgrade the bridge contract, change parameters, delist assets, and settle positions at arbitrary prices with no delay. There is no technical constraint on admin power.
4. **Audit gap**: Only the bridge contract was audited (2023). The L1 consensus mechanism, liquidation engine, and oracle system securing $5B have no disclosed audits.
5. **DPRK reconnaissance**: State-sponsored hackers have specifically targeted this protocol for reconnaissance. With a small validator set and single-client architecture, the attack surface is concerning.

## Peer Comparison

| Feature | Hyperliquid | GMX (Arbitrum) | dYdX Chain |
|---------|-------------|----------------|------------|
| Timelock | None documented | 24h (Arbitrum) | Governance vote |
| Multisig | 4 hot validators (team) | Community multisig + Security Council | 60 validators (PoS) |
| Audits | 2 (bridge only, 2023) | 17+ (Guardian Audits ongoing) | Multiple (Informal Systems, others) |
| Oracle | Custom CEX feed median | Chainlink + custom | Skip protocol (custom) |
| Insurance/TVL | ~8-10% (HLP + AF) | GLP pool + fee reserves | Insurance fund + MegaVault |
| Open Source | Partial (bridge only) | Yes (full) | Yes (full, Cosmos SDK) |
| Bug Bounty | Self-hosted (undisclosed max) | $5M on Immunefi | $150K on Immunefi |
| Bridge Risk | HIGH ($3.77B, 4 validators) | N/A (native Arbitrum) | LOW (IBC, 60 validators) |

## Recommendations

1. **For users**: Be aware that all funds on Hyperliquid depend on the security of 4 team-controlled bridge validators. Consider limiting exposure relative to total portfolio. Use hardware wallets and monitor bridge contract activity.
2. **For the protocol**: Open-source the L1 node code as a priority. The "when it's secure to do so" rationale is understandable but inadequate for $5B in custody.
3. **For the protocol**: Commission comprehensive audits of the L1 consensus code, clearinghouse, liquidation engine, and oracle system. The 2023 bridge-only audits are insufficient.
4. **For the protocol**: Implement a timelock on bridge upgrades and admin parameter changes. Even a 24-hour delay would significantly reduce key compromise risk.
5. **For the protocol**: Expand the bridge validator set beyond 4 addresses and diversify infrastructure across multiple cloud providers and client implementations.
6. **For the protocol**: Establish a formal bug bounty on Immunefi with a payout commensurate to TVL ($1M+ for critical findings).
7. **For HLP depositors**: Understand that HLP bears first-loss risk from market manipulation attacks, which have occurred 3+ times in 2025. This is not a risk-free yield product.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- HIP-3 enables permissionless perps listing; spot listing via HIP-1 auction
- [x] Admin can change oracle sources arbitrarily? -- UNVERIFIED but likely, given Foundation control
- [x] Admin can modify withdrawal limits? -- Cold validator set can modify parameters
- [x] Multisig has low threshold (2/N with small N)? -- 3/4 effective threshold for bridge operations
- [x] Zero or short timelock on governance actions? -- No timelock documented
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- Bridge validator identities undisclosed

**Drift-type risk: HIGH** -- 5/6 applicable indicators match.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [x] Low-liquidity collateral accepted? -- HIP-3 permissionless perps on illiquid tokens
- [ ] Single oracle source without TWAP? -- Multi-source CEX median, but no TWAP
- [ ] No circuit breaker on price movements? -- Leverage limits reduced post-POPCAT; circuit breakers UNVERIFIED
- [ ] Insufficient insurance fund relative to TVL? -- Insurance adequate (~8-10%)

**Euler/Mango-type risk: MEDIUM** -- Market manipulation has occurred multiple times but insurance has absorbed losses so far.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- 4 team-controlled hot validators for $3.77B bridge
- [ ] Admin keys stored in hot wallets? -- "Hot" validator keys are online by design; cold keys for admin
- [ ] No key rotation policy? -- UNVERIFIED

**Ronin/Harmony-type risk: HIGH** -- The bridge architecture (small validator set, team-controlled, single client) closely mirrors pre-hack Ronin. The DPRK reconnaissance activity in December 2024 makes this pattern especially concerning.

## Information Gaps

- **L1 source code**: The core consensus (HyperBFT), clearinghouse, liquidation engine, and oracle implementation are closed source. Independent verification of any security claims about these components is impossible.
- **Bridge validator identities**: The 4 hot and 4 cold validator addresses are not publicly mapped to known entities or individuals.
- **Timelock existence**: No documentation confirms or denies the existence of any timelock on bridge upgrades or parameter changes. Assumed to be zero.
- **Bug bounty maximum payout**: The self-hosted bug bounty program does not publicly disclose its maximum reward.
- **Key management practices**: How validator keys are stored, whether HSMs are used, key rotation policies, and infrastructure diversity are all undisclosed.
- **Bridge validator set expansion**: It is unclear whether the bridge's hot/cold validator sets have expanded beyond the original 4 addresses, even as the consensus validator set grew to 21.
- **Emergency powers scope**: The full scope of what the Cold Validator Set can do (beyond parameter changes and withdrawal invalidation) is not comprehensively documented.
- **Cloud provider diversification**: Whether the team has diversified infrastructure across multiple cloud providers since the December 2024 DPRK incident is unknown.
- **Audit pipeline**: Whether new audits of the L1 code or updated bridge audits are in progress is not publicly disclosed.

## Disclaimer
This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
