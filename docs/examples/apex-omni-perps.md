# DeFi Security Audit: ApeX Omni (ApeX Protocol)

## Overview
- Protocol: ApeX Omni (formerly ApeX Pro)
- Chain: Ethereum, BNB Chain, Arbitrum, Base, Mantle (via zkLink X)
- Type: Perpetual DEX (orderbook-based, up to 100x leverage)
- TVL: $36.8M (DeFiLlama, "apex-omni" slug)
- TVL Trend: -0.2% (7d) / +0.2% (30d) / -11.6% (90d)
- Launch Date: April 2022 (ApeX Pro); June 2024 (ApeX Omni rebrand on zkLink X)
- Audit Date: 2026-04-20
- Valid Until: 2026-07-19 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Partial (core contracts on GitHub, but trading engine and zkLink settlement layer are not fully open)
- Token: APEX (ERC-20, Ethereum: 0x52A8845DF664D76C69d2EEa607CD793565aF42B8)
- Backing: Incubated by Davion Labs (Bybit-affiliated crypto incubator)

## Quick Triage Score: 24/100 | Data Confidence: 40/100

### Triage Score Calculation (start at 100, subtract mechanically)

CRITICAL flags: none applied (0)

HIGH flags (-15 each):
- [x] Zero audits listed on DeFiLlama (-15)
- [x] No multisig verified on-chain (governance structure undisclosed) (-15)

MEDIUM flags (-8 each):
- [x] No third-party security certification (SOC 2 / ISO 27001) for off-chain operations (-8)
- [x] GoPlus: is_mintable = 1 (-8)

LOW flags (-5 each):
- [x] No documented timelock on admin actions (-5)
- [x] No bug bounty program on Immunefi (-5)
- [x] Undisclosed multisig signer identities (-5)
- [x] Insurance fund / TVL undisclosed (-5)
- [x] No disclosed penetration testing (-5)
- [x] No published key management policy (-5)

**Score: 100 - 15 - 15 - 8 - 8 - 5 - 5 - 5 - 5 - 5 - 5 = 24 (HIGH risk, mechanical)**

Rounding note: Score is 24 before floor check. Final = **24/100**.

### Data Confidence Score Calculation (start at 0, add verified points)

- [x] +15  Source code is open and verified on block explorer (token contract verified; core repo on GitHub, but trading engine partially closed)
- [x] +15  GoPlus token scan completed
- [ ] +10  At least 1 audit report publicly available (Secure3 audit referenced but not on DeFiLlama; report PDF exists on GitHub but not independently verified)
- [ ] +10  Multisig configuration verified on-chain
- [ ] +10  Timelock duration verified on-chain or in docs
- [ ] +10  Team identities publicly known (partially -- Davion Labs affiliation known, but core team mostly undoxxed)
- [ ] +10  Insurance fund size publicly disclosed
- [ ] +5   Bug bounty program details publicly listed
- [x] +5   Governance process documented (APEX token governance referenced in docs)
- [x] +5   Oracle provider(s) confirmed (Chainlink Data Streams)
- [ ] +5   Incident response plan published
- [ ] +5   SOC 2 Type II or ISO 27001 certification verified
- [ ] +5   Published key management policy
- [ ] +5   Regular penetration testing disclosed
- [ ] +5   Bridge DVN/verifier configuration publicly documented

**Confidence: 15 + 15 + 5 + 5 = 40/100 (LOW confidence)**

**Interpretation: Triage 24/100 (HIGH risk) with Confidence 40/100 (LOW). Many critical governance and operational details could not be verified from public sources, making this score potentially optimistic.**

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | GMX ~5-8%, dYdX ~2-3% | HIGH |
| Audit Coverage Score | 0.5 (1 audit >2yr old, 1 ref ~1yr) | GMX ~3.5, dYdX ~4.0 | HIGH |
| Governance Decentralization | Low (no on-chain timelock, no verified multisig) | dYdX: timelock + governance, GMX: multisig + timelock | HIGH |
| Timelock Duration | Undisclosed / None documented | dYdX 48h, GMX 24h | HIGH |
| Multisig Threshold | UNVERIFIED | dYdX 4/6, GMX 4/6 | HIGH |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW |

## GoPlus Token Security (Ethereum: 0x52A8845DF664D76C69d2EEa607CD793565aF42B8)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | 0 (No) | LOW |
| Open Source | 1 (Yes) | LOW |
| Proxy | 0 (No) | LOW |
| Mintable | 1 (Yes) | MEDIUM |
| Owner Can Change Balance | 0 (No) | LOW |
| Hidden Owner | 0 (No) | LOW |
| Selfdestruct | 0 (No) | LOW |
| Transfer Pausable | 0 (No) | LOW |
| Blacklist | 0 (No) | LOW |
| Slippage Modifiable | 0 (No) | LOW |
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 5,628 | -- |
| Trust List | N/A | -- |
| Creator Honeypot History | 0 (No) | LOW |

**Notes**: Owner address is 0x0000...dead (renounced). Token is mintable (is_mintable = 1), meaning new tokens can theoretically be created. 50% of total supply (500M of 1B) is burned to dead address. Top non-dead holders are contract addresses (likely staking/treasury). LP liquidity is thin (~$347K on UniswapV3).

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | HIGH | No verified multisig, no documented timelock, opaque admin structure | S/O | N |
| Oracle & Price Feeds | LOW | Chainlink Data Streams integrated for RWA and crypto feeds | S | Partial |
| Economic Mechanism | MEDIUM | Insurance fund undisclosed, thin on-chain liquidity for APEX token | S | N |
| Smart Contract | MEDIUM | Secure3 audit exists but not independently verified; code partially closed | S | Partial |
| Token Contract (GoPlus) | LOW | Clean scan, mintable but owner renounced | S | Y |
| Cross-Chain & Bridge | MEDIUM | Relies on zkLink X for multi-chain settlement; bridge security is a dependency | S | N |
| Off-Chain Security | HIGH | No SOC 2, no published key management, no penetration testing disclosed | O | N |
| Operational Security | MEDIUM | Bybit/Davion Labs backing adds credibility but team largely undoxxed | O | Partial |
| **Overall Risk** | **HIGH** | **Opaque governance, no verified multisig/timelock, undisclosed insurance fund** | | |

**Overall Risk aggregation**: Governance & Admin = HIGH (counts as 2x weight per methodology, so effectively 2 HIGHs). With 2+ HIGH-equivalent categories, Overall = HIGH.

## Detailed Findings

### 1. Governance & Admin Key

**Risk: HIGH**

ApeX Protocol states that APEX token holders can "submit and vote on protocol governance proposals" and that staked tokens provide "voting power." However, no on-chain governance contracts, proposal history, or voting records could be found in public sources.

**Admin key surface area**: UNVERIFIED. The protocol's admin capabilities (pause, upgrade, parameter changes, market listings) are not publicly documented. The `omni-swap-pool` GitHub repo references "multisig authorization" in its description, but no multisig address, threshold, or signer identities are published.

**Timelock**: No timelock contract has been identified or documented. This is a significant gap for a protocol handling ~$36.8M in TVL and processing ~$1.2B daily volume.

**Timelock bypass**: Cannot be assessed since no timelock exists in public documentation.

**Token concentration**: GoPlus data shows the top holder (excluding burn address) at ~24.4% (contract at 0xa3a7...6eec), followed by ~15.7% (contract at 0xd670...2694). These are likely protocol treasury/staking contracts, but their governance role is undisclosed.

**Upgrade mechanism**: The core trading engine runs on zkLink X (a ZK-rollup layer). Contract upgradeability for the settlement layer is controlled by zkLink's infrastructure, adding a dependency layer. The `omni-swap-pool` contract on EVM chains is a separate peripheral contract.

### 2. Oracle & Price Feeds

**Risk: LOW**

ApeX Omni integrated Chainlink Data Streams in 2025 to power its RWA (stock) perpetuals, providing sub-second price data across five chains (Arbitrum, Base, BNB Chain, Ethereum, Mantle). This is a strong oracle choice -- Chainlink is the industry standard for DeFi price feeds.

For crypto perpetuals, the protocol likely uses a combination of Chainlink and internal price aggregation, though the exact architecture for crypto feeds (vs. RWA feeds) is not fully documented.

**Fallback mechanism**: UNVERIFIED. No public documentation describes what happens if Chainlink feeds fail.

**Admin oracle override**: UNVERIFIED. Whether admins can change oracle sources without governance is undisclosed.

### 3. Economic Mechanism

**Risk: MEDIUM**

**Liquidation**: ApeX uses a standard perpetual exchange liquidation model. When account net equity falls below maintenance margin, positions are taken over by the liquidation engine and executed at mark price. Up to 100x leverage is offered across 331 assets.

**Insurance fund**: The protocol operates a "Protocol Vault" where liquidation fees are collected and distributed to USDT depositors. However, the size of this insurance fund relative to open interest ($125M) or TVL ($36.8M) is not publicly disclosed. For a protocol with $1.2B daily volume and 100x leverage, the insurance fund adequacy is a critical unknown.

**Funding rate**: Standard perpetual funding rate mechanism (long/short balance). Annualized funding rates are tracked on the stats page.

**Bad debt handling**: Mechanism for socializing losses if the insurance fund is depleted is UNVERIFIED.

**APEX token liquidity risk**: On-chain liquidity for APEX token is thin (~$347K on UniswapV3 Ethereum). A large sell event could cause significant slippage, though the primary APEX trading occurs on CEXs (Bybit, etc.).

### 4. Smart Contract Security

**Risk: MEDIUM**

**Audit history**: ApeX states that "all smart contracts on ApeX Pro have been audited by Secure3." An audit report PDF exists in the GitHub repository (`ApeX-Protocol/core/docs/audit_report.pdf`). Cyberscope also lists an audit. However:
- DeFiLlama lists 0 audits for the "apex-omni" entry
- The Secure3 audit appears to cover the original ApeX Pro contracts (pre-2024), not the ApeX Omni/zkLink X architecture
- No audit date or scope is publicly clear
- Whether the zkLink X settlement layer contracts have been independently audited (separate from zkLink's own audits) is unknown

**Audit Coverage Score**: Estimating 0.5 (one audit likely >2 years old covering original contracts, partial coverage of current architecture). Threshold: <1.5 = HIGH risk.

**Bug bounty**: No ApeX Protocol listing found on Immunefi. No other bug bounty program publicly documented.

**Battle testing**: ApeX Pro launched in 2022 and has operated without known exploits. ApeX Omni launched June 2024. No rekt.news entry exists for ApeX. The protocol has handled significant volume (~$1.2B/day) without reported incidents, which provides some operational confidence.

**Open source**: The `core` repo on GitHub contains Solidity contracts (59 stars). The `omni-swap-pool` repo contains peripheral EVM contracts. However, the trading engine, matching engine, and zkLink integration code are not fully open source.

### 5. Cross-Chain & Bridge

**Risk: MEDIUM**

ApeX Omni is deployed across 5 EVM chains (Ethereum, BNB Chain, Arbitrum, Base, Mantle) via zkLink X, a multi-chain ZK-rollup infrastructure.

**zkLink X dependency**: zkLink X provides the settlement layer using zero-knowledge proofs and "multi-state synchronization powered by a light oracle network." This is a significant architectural dependency -- if zkLink X has a vulnerability, ApeX Omni's funds are at risk. zkLink X has its own security model and audit history, but ApeX's specific configuration and integration have not been independently audited (as far as publicly known).

**Bridge architecture**: Users deposit on any supported chain, and zkLink handles cross-chain settlement. The exact validator/verifier configuration of the zkLink light oracle network is not publicly documented for ApeX's deployment.

**Per-chain admin**: Whether each chain deployment has independent admin controls or a single admin key controls all is UNVERIFIED.

**Single bridge provider risk**: ApeX relies entirely on zkLink X for cross-chain functionality across 5 chains. This represents a single point of failure, though zkLink uses ZK proofs (stronger than simple message passing).

### 6. Operational Security

**Risk: MEDIUM (team) / HIGH (off-chain controls)**

**Team**: ApeX Protocol is incubated by Davion Labs, which is affiliated with Bybit (a major CEX). Tekla Iashagashvili is identified as Head of Business Development. Beyond this, the core development team is largely undoxxed. The Bybit affiliation provides indirect credibility (Bybit is a regulated exchange with significant resources), but the ApeX team itself operates with limited public accountability.

**Incident response**: No published incident response plan. Emergency pause capability is UNVERIFIED. The protocol tweets suggest active development and monitoring, but formal response procedures are not documented.

**Off-chain controls**: No SOC 2, ISO 27001, or equivalent certification. No published key management policy. No disclosed penetration testing. These are significant gaps for a protocol handling ~$36.8M TVL and ~$1.2B daily volume.

**Dependencies**: Primary dependencies are (1) zkLink X for settlement, (2) Chainlink for oracle feeds, (3) supported chains for deposit/withdrawal. Composability risk is moderate -- ApeX is primarily a standalone perps exchange, not deeply integrated into DeFi lending/borrowing protocols.

## Critical Risks

1. **No verified multisig or timelock**: Admin controls are completely opaque. Who can upgrade contracts, change parameters, or pause the protocol is unknown. This is the single largest risk factor.
2. **Undisclosed insurance fund**: With $125M open interest and 100x leverage, the insurance fund size is critical information that is not publicly available.
3. **zkLink X dependency**: The entire cross-chain settlement relies on zkLink X infrastructure. A zkLink vulnerability would directly impact all ApeX Omni funds.
4. **Partially closed source**: The trading engine and settlement integration are not fully open source, limiting independent security review.
5. **No bug bounty program**: No Immunefi or equivalent program found, reducing incentive for responsible disclosure.

## Peer Comparison

| Feature | ApeX Omni | dYdX v4 | GMX v2 |
|---------|-----------|---------|--------|
| TVL | $36.8M | ~$300M+ | ~$400M+ |
| Timelock | UNVERIFIED / None | 48h (governance) | 24h |
| Multisig | UNVERIFIED | 4/6 (Security Council) | 4/6 |
| Audits | 1 (Secure3, old) | 5+ (Trail of Bits, Quantstamp, etc.) | 3+ (Trail of Bits, Dedaub, etc.) |
| Oracle | Chainlink Data Streams | Internal + Chainlink | Chainlink |
| Insurance/TVL | Undisclosed | ~2-3% | ~5-8% |
| Open Source | Partial | Full | Full |
| Bug Bounty | None found | Immunefi ($1M+) | Immunefi ($500K+) |
| Leverage | Up to 100x | Up to 50x | Up to 100x |
| Architecture | zkLink X ZK-rollup | Cosmos appchain | On-chain (Arbitrum) |

ApeX Omni lags significantly behind both dYdX and GMX in governance transparency, audit coverage, and operational security practices. Its primary advantages are multi-chain access and high leverage, but these come without the security infrastructure that peers have established.

## Recommendations

1. **For users**: Exercise caution with large positions. The lack of verified governance controls means there is no public assurance against admin key compromise. Limit exposure and withdraw profits regularly.
2. **For the protocol**: Publish multisig addresses and threshold configurations. Implement and document a timelock on all admin actions. Commission a fresh audit of the ApeX Omni + zkLink X integration.
3. **For the protocol**: Launch a bug bounty program on Immunefi. Disclose the insurance fund size and replenishment mechanism.
4. **For the protocol**: Publish an incident response plan with emergency contact channels and expected response times.
5. **For users**: The Bybit backing provides some reputational assurance but is not a substitute for on-chain security guarantees. Bybit itself is a centralized entity and cannot guarantee ApeX smart contract safety.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- UNVERIFIED, likely yes given no documented timelock
- [x] Admin can change oracle sources arbitrarily? -- UNVERIFIED
- [x] Admin can modify withdrawal limits? -- UNVERIFIED
- [x] Multisig has low threshold (2/N with small N)? -- UNVERIFIED (no multisig documented)
- [x] Zero or short timelock on governance actions? -- YES (no timelock documented)
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- Not applicable (EVM-based)
- [x] Social engineering surface area (anon multisig signers)? -- YES (signers unknown)

**WARNING: 5+ indicators match the Drift-type pattern. Governance opacity creates a significant attack surface.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- USDT/USDC primary collateral, LOW risk
- [ ] Single oracle source without TWAP? -- Chainlink Data Streams (robust)
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [x] Insufficient insurance fund relative to TVL? -- UNVERIFIED but likely (undisclosed)

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- zkLink uses ZK proofs, better than simple validators
- [x] Admin keys stored in hot wallets? -- UNVERIFIED
- [x] No key rotation policy? -- UNVERIFIED

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time? -- UNVERIFIED
- [ ] Flash loans can be used to acquire voting power? -- UNVERIFIED
- [ ] Proposal + execution in same block? -- UNVERIFIED
- [ ] No minimum holding period for voting eligibility? -- UNVERIFIED

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens? -- No (USDT/USDC only)
- [ ] Read-only reentrancy risk? -- omni-swap-pool mentions reentrancy protection
- [ ] Flash loan compatible without guards? -- N/A for perps exchange
- [ ] Composability with callback hooks? -- Limited exposure

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard compiler? -- Solidity (standard)
- [ ] Compiler version has known CVEs? -- UNVERIFIED
- [ ] Different compiler versions? -- UNVERIFIED
- [ ] Language-specific behavior dependency? -- No

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral? -- No stablecoin product
- N/A for this protocol

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [x] Protocol uses a cross-chain bridge for token minting or reserve release? -- Yes (zkLink X)
- [ ] Bridge message validation relies on single messaging layer? -- ZK-proof based (stronger)
- [x] DVN/relayer/verifier configuration not publicly documented? -- Yes
- [ ] Bridge can release tokens without rate limiting? -- UNVERIFIED
- [ ] Bridged token accepted as collateral on lending protocols? -- APEX is not major lending collateral
- [ ] No circuit breaker for excess bridge volume? -- UNVERIFIED
- [x] Emergency pause response time > 15 minutes? -- UNVERIFIED
- [ ] Bridge admin under different governance? -- UNVERIFIED
- [x] Token deployed on 5+ chains via same bridge? -- Yes (5 chains via zkLink X)

**Trigger rule**: Drift-type pattern matches 5+ indicators -- EXPLICIT WARNING issued above.

## Information Gaps

The following questions could NOT be answered from public information. Each represents an unknown risk.

1. **Multisig configuration**: No multisig address, threshold, or signer identities published for any admin role
2. **Timelock existence**: No timelock contract address or duration documented anywhere
3. **Insurance fund size**: Neither absolute value nor ratio to TVL/OI is disclosed
4. **Full audit scope**: Whether Secure3 audited the ApeX Omni (post-June 2024) architecture or only the original ApeX Pro contracts
5. **zkLink X integration audit**: Whether the ApeX-specific deployment on zkLink X has been independently audited
6. **Admin capabilities**: What exactly admin keys can do (pause, upgrade, drain, change oracle, list markets)
7. **Emergency response time**: No SLA or documented response procedure
8. **Key management**: How admin keys are stored and managed (HSM, MPC, cold storage)
9. **Oracle fallback**: What happens if Chainlink feeds go offline
10. **Bad debt socialization**: How losses exceeding insurance fund are handled
11. **Per-chain admin independence**: Whether each chain deployment has its own admin or shares a single key
12. **Governance activity**: No evidence of any governance proposal or vote ever being executed on-chain
13. **Penetration testing**: No disclosed infrastructure security testing
14. **Team composition**: Core development team identities largely unknown beyond Davion Labs affiliation

**These 14 information gaps represent a collectively HIGH risk. The absence of basic governance transparency (multisig, timelock, insurance fund) for a protocol processing $1.2B daily volume is a significant concern.**

## Disclaimer

This analysis is based on publicly available information and web research as of 2026-04-20. It is NOT a formal smart contract audit. The audit was unable to verify many critical security parameters due to lack of public documentation from the protocol team. Always DYOR and consider professional auditing services for investment decisions. The Bybit/Davion Labs backing provides reputational context but does not constitute a security guarantee.
