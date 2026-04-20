# DeFi Security Audit: Vertex Protocol

**Audit Date:** April 20, 2026
**Protocol:** Vertex Protocol -- Cross-chain perpetual DEX (SHUT DOWN)

## Overview
- Protocol: Vertex Protocol
- Chain: Arbitrum (primary), Base, Mantle, Sei, Sonic, Avalanche, Abstract (all ceased operations)
- Type: Derivatives (Perpetual DEX + Spot + Money Market)
- TVL: ~$50 (effectively $0 -- protocol shut down August 14, 2025)
- TVL Trend: -100% / -100% / -100% (7d / 30d / 90d vs. pre-shutdown)
- Launch Date: April 2023
- Audit Date: April 20, 2026
- Valid Until: N/A -- protocol is shut down; this is a historical audit
- Source Code: Open (GitHub: vertex-protocol/vertex-contracts, Solidity)

**CRITICAL NOTICE**: Vertex Protocol ceased all trading operations on August 14, 2025 after its team was acquired by the Ink Foundation (Kraken-backed L2). The VRTX token has been sunset. TVL dropped from ~$66M (June 2025) to $0. This audit serves as a historical record. Any residual funds on-chain should be withdrawn immediately.

## Quick Triage Score: 19/100 | Data Confidence: 60/100

**Triage Score Calculation (start at 100):**
- [-25] TVL = $0 (protocol shut down) -- CRITICAL
- [-15] Zero audits listed on DeFiLlama (audits exist but not registered on DeFiLlama) -- HIGH
- [-8] GoPlus: is_proxy = 1 AND no verified timelock on upgrades -- MEDIUM
- [-8] No third-party security certification (SOC 2 / ISO 27001) -- MEDIUM
- [-5] No documented timelock on admin actions -- LOW
- [-5] Insurance fund / TVL < 1% or undisclosed -- LOW
- [-5] Undisclosed multisig signer identities -- LOW
- [-5] DAO governance paused or dissolved -- LOW
- [-5] No published key management policy (HSM, MPC, key ceremony) -- LOW
- [-5] No disclosed penetration testing -- LOW
- **Score: 19 (CRITICAL)**

Red flags found: 10 (listed above)

**Data Confidence Score Calculation (start at 0):**
- [+15] Source code is open and verified on block explorer
- [+15] GoPlus token scan completed (partial -- many fields null due to proxy)
- [+10] At least 1 audit report publicly available (OtterSec, Three Sigma)
- [+10] Team identities publicly known (doxxed)
- [+5] Bug bounty program details publicly listed (HackenProof, up to $500K)
- [+5] Oracle provider(s) confirmed (Stork + Chainlink)
- **Score: 60 (MEDIUM confidence)**

Data points verified: 6 / 15

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed / $0 TVL | GMX ~1-2%, dYdX ~1% | CRITICAL |
| Audit Coverage Score | 1.25 (OtterSec 2023 = 0.25, Three Sigma 2024 = 1.0) | GMX ~3.0, dYdX ~4.0 | HIGH |
| Governance Decentralization | Team-controlled, DAO dissolved | GMX multisig, dYdX validator DAO | CRITICAL |
| Timelock Duration | Undisclosed / UNVERIFIED | GMX 12h, dYdX 7d (long) | HIGH |
| Multisig Threshold | UNVERIFIED | GMX Guardian multisig, dYdX 60 validators | HIGH |
| GoPlus Risk Flags | 0 HIGH / 1 MED (proxy) | -- | LOW |

## GoPlus Token Security (VRTX on Arbitrum: 0x95146881b86B3ee99e63705eC87AfE29Fcc044D9)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | N/A (not returned) | UNVERIFIED |
| Open Source | Yes (1) | -- |
| Proxy | Yes (1) | MEDIUM |
| Mintable | N/A (not returned) | UNVERIFIED |
| Owner Can Change Balance | N/A (not returned) | UNVERIFIED |
| Hidden Owner | N/A (not returned) | UNVERIFIED |
| Selfdestruct | N/A (not returned) | UNVERIFIED |
| Transfer Pausable | N/A (not returned) | UNVERIFIED |
| Blacklist | N/A (not returned) | UNVERIFIED |
| Slippage Modifiable | N/A (not returned) | UNVERIFIED |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 16,590 | -- |
| Trust List | N/A (not returned) | UNVERIFIED |
| Creator Honeypot History | No (0) | -- |

GoPlus assessment: **MEDIUM RISK**. The token is open source and a proxy (upgradeable). Many GoPlus fields returned null, likely because the token contract is a proxy and GoPlus could not fully analyze the implementation. No honeypot history from creator. Zero buy/sell tax. Note: VRTX token is being sunset -- holders should claim INK airdrop per migration terms.

**Top holder concentration**: Top 5 holders control ~47.6% of supply. All top 5 are contracts (likely treasury, staking, vesting). Top EOA holder (rank 7) holds ~4.4%. High concentration in protocol-controlled contracts, which is typical but becomes a risk when governance is dissolved.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **CRITICAL** | Protocol shut down; team joined Ink Foundation; DAO dissolved; VRTX sunset | S/O | Partial |
| Oracle & Price Feeds | **MEDIUM** | Dual oracle (Stork + Chainlink) was reasonable; moot since shutdown | S | Partial |
| Economic Mechanism | **HIGH** | Insurance fund size undisclosed; socialized loss mechanism existed | S | N |
| Smart Contract | **MEDIUM** | 2 audits (OtterSec, Three Sigma); open source; critical findings fixed | S/H | Y |
| Token Contract (GoPlus) | **MEDIUM** | Proxy contract; many GoPlus fields null; token being sunset | S | Partial |
| Cross-Chain & Bridge | **HIGH** | Edge sequencer centralized; 7+ chain deployments all shut down simultaneously | S/O | Partial |
| Off-Chain Security | **HIGH** | No SOC 2, no published key management, no pentest disclosure | O | N |
| Operational Security | **HIGH** | Doxxed team but abrupt shutdown; sequencer was single point of failure | S/H/O | Partial |
| **Overall Risk** | **CRITICAL** | **Protocol is shut down. TVL = $0. VRTX token sunset. No active operations.** | | |

**Overall Risk aggregation**: Governance & Admin = CRITICAL (counts 2x) -> automatic CRITICAL overall. Additionally, 3 categories at HIGH further confirms CRITICAL rating.

## Detailed Findings

### 1. Governance & Admin Key -- CRITICAL

**Pre-shutdown state:**
- VRTX governance token enabled voting on protocol parameters, fee structures, market listings, and treasury allocations
- xVRTX (staked VRTX) represented voting power with 3-week minimum lockup
- Contracts used EIP-1967 Beacon Proxy pattern; owner role could change implementation the beacon points to, upgrading all proxies
- Owner/manager accounts could upgrade or pause contracts -- specific multisig configuration UNVERIFIED
- No publicly documented timelock duration on admin actions

**Post-shutdown state (current):**
- Team joined Ink Foundation (July 8, 2025)
- VRTX token sunset; holders eligible for 1% of INK token supply airdrop
- All trading ceased across 9 EVM chain deployments by August 14, 2025
- DAO governance effectively dissolved
- Remaining on-chain contracts still exist but are non-operational

**Key risk**: The Beacon Proxy pattern means an owner can upgrade all contracts simultaneously. With governance dissolved and the team at Ink Foundation, residual contract ownership represents an unmonitored admin key surface area.

### 2. Oracle & Price Feeds -- MEDIUM

**Architecture (pre-shutdown):**
- Primary: Stork Network -- sub-second, high-fidelity market data for low-latency price referencing across long-tail assets
- Secondary: Chainlink DON -- used alongside Stork to secure liquidations, funding rates, and P&L calculations
- Dual-oracle approach provided redundancy
- Off-chain sequencer consumed oracle data and matched orders at 10-30ms latency

**Risk factors:**
- Stork is a relatively newer oracle provider compared to Chainlink/Pyth
- Oracle admin configuration (who could change oracle sources) is UNVERIFIED
- The off-chain sequencer's oracle consumption was centralized (single sequencer node)

**Assessment**: Dual-oracle design was reasonable for a perpetual DEX. However, the sequencer's centralized consumption of oracle data created a single point of failure.

### 3. Economic Mechanism -- HIGH

**Liquidation mechanism:**
- Cross-margin system: account balances, unrealized PnL, and certain positions used as collateral across products
- On-chain risk engine enforced margin requirements
- Liquidation revenue partly directed to insurance fund
- If insurance fund depleted, losses socialized against other perpetual accounts in that market
- If account settled, losses socialized against all USDC holders

**Insurance fund:**
- Denominated in USDC, seeded by team, topped up from liquidation fees
- voVRTX stakers could back the insurance fund with USDC for revenue share
- Up to 50% of xVRTX holdings could be liquidated if insurance fund drained
- **Current size: UNDISCLOSED** -- no public dashboard or reporting found
- Insurance fund / TVL ratio: INCALCULABLE (TVL = $0)

**Concerns:**
- Socialized loss mechanism is aggressive -- all USDC holders at risk if insurance fund fails
- No public reporting of insurance fund size is a transparency gap
- The 50% xVRTX liquidation clause created reflexive risk (staker losses could cascade)

### 4. Smart Contract Security -- MEDIUM

**Audit history:**
- Audit #1-2: OtterSec (2023) -- focused on core protocol on-chain contracts on Arbitrum
- Audit #3: OtterSec (2024) -- ongoing collaboration
- Audit #4: Three Sigma (May 2024, 14 person-weeks) -- comprehensive audit of trading engines, orderbook, cross-margin

**Three Sigma findings (May 2024):**
- 4 HIGH severity issues found and fixed:
  1. `cumulativeDepositsMultiplierX18` could become zero/negative, causing deposit reverts or liquidation exposure
  2. `OffchainExchange::swapAmm()` accepted negative prices, enabling donation attacks to inflate LP value
  3. `ClearinghouseLiq::_finalizeSubaccount()` failed to account for LP token balances, allowing insurance fund drainage
  4. (Fourth high not detailed in public sources)
- 1 MEDIUM, 16 LOW, 1 INFORMATIONAL issues
- All critical vulnerabilities addressed before going live

**Audit Coverage Score**: 1.25 (OtterSec 2023 = 0.25 aged >2y, Three Sigma 2024 = 1.0 within 2y)
- Rating: HIGH risk (below 1.5 threshold), though quality of Three Sigma audit was thorough

**Bug bounty:**
- Platform: HackenProof (not Immunefi)
- Maximum payout: $500,000 for critical vulnerabilities
- Scope: Smart contracts + web applications (*.vertexprotocol.com, *.blitz.exchange)
- Reward tiers: Critical $50K-$500K, High $5K-$50K, Medium $2K-$5K, Low $50-$1K
- Status: UNKNOWN if still active post-shutdown

**Source code:**
- Open source: https://github.com/vertex-protocol/vertex-contracts
- Written in Solidity
- Two main projects: core (EVM Vertex core) and lba (Liquidity Bootstrap Auction)
- Contracts verified on Arbiscan

### 5. Cross-Chain & Bridge -- HIGH

**Multi-chain deployment:**
- Deployed on 7 chains: Arbitrum, Base, Mantle, Sei, Sonic, Avalanche, Abstract
- Vertex Edge: synchronous orderbook liquidity layer unifying cross-chain liquidity
- Each chain had an "instance" of the sequencer, settling on unified liquidity layer

**Edge sequencer architecture:**
- Off-chain sequencer built in Rust -- centralized single node
- Split across networks but centrally operated
- 10-30ms order matching latency (CEX-comparable)
- Fallback: "Slow-Mo Mode" using only on-chain AMM if sequencer fails

**Centralization risk:**
- The Edge sequencer was the critical single point of failure
- One centralized operator controlled order matching across all 7 chains
- If sequencer went down, only basic AMM functionality remained
- No documented decentralization plan was executed before shutdown

**Shutdown impact:**
- All 7 chain deployments ceased simultaneously when team joined Ink Foundation
- This demonstrated the centralization risk in practice -- single team decision shut down all chains
- Users had to withdraw through multi-phase process ending August 14, 2025

### 6. Operational Security -- HIGH

**Team & Track Record:**
- Co-founders: Darius Tabatabai (UBS, Credit Suisse, Merrill Lynch background, 2004-2013 derivatives trading) and Alwin Peng (youngest employee at Jump Trading, built RandomEarth on Terra)
- Team is doxxed with verifiable professional history
- Raised $8.5M in late 2021
- Originally built on Terra (pre-collapse), pivoted to Arbitrum
- Acquired by Ink Foundation (Kraken-backed) in July 2025
- **No known security incidents or exploits during operation** (April 2023 - August 2025)

**Incident response:**
- "Slow-Mo Mode" fallback existed for sequencer failures
- No published incident response plan found
- Emergency pause capability existed via owner/manager contracts
- Response time benchmark: UNKNOWN

**Dependencies:**
- Critical dependency on off-chain sequencer (centralized)
- Oracle dependencies: Stork + Chainlink
- No known downstream lending exposure (VRTX not widely used as collateral on Aave/Compound)

**Off-chain controls:**
- No SOC 2 Type II or ISO 27001 certification found
- No published key management policy (HSM, MPC, key ceremony)
- No disclosed penetration testing
- No published operational segregation details
- Rating: HIGH risk -- doxxed team but opaque operational security practices

## Critical Risks

1. **CRITICAL: Protocol is shut down** -- All trading ceased August 14, 2025. TVL = $0. VRTX token sunset. Any remaining on-chain positions or funds should be withdrawn immediately.
2. **CRITICAL: Governance dissolved** -- DAO governance no longer functional. Team at Ink Foundation. Residual contract ownership status unknown.
3. **HIGH: Unmonitored admin keys** -- Beacon Proxy contracts may still have active owner keys. With the team at a different organization, these keys represent unmonitored upgrade authority over residual contracts.
4. **HIGH: Insurance fund status unknown** -- No public reporting on whether insurance fund was fully distributed during shutdown.
5. **HIGH: Centralized sequencer proved fragile** -- Single team decision shut down all 7 chain deployments simultaneously, validating the centralization concern.

## Peer Comparison

| Feature | Vertex Protocol | GMX (V2) | dYdX (V4) |
|---------|----------------|----------|-----------|
| Status | **SHUT DOWN** | Active | Active |
| TVL | ~$0 | ~$540M | ~$280M |
| Timelock | UNVERIFIED | 12h (Arbitrum) | 7d (long timelock) |
| Multisig | UNVERIFIED | Guardian multisig | 60 validators (PoS) |
| Audits | 2 (OtterSec, Three Sigma) | 5+ (ABDK, Guardian, etc.) | 3+ (Informal Systems, etc.) |
| Oracle | Stork + Chainlink | Chainlink | Internal + Chainlink |
| Insurance/TVL | Undisclosed | ~1-2% | ~1% |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | $500K (HackenProof) | $5M (Immunefi) | $5M (Immunefi) |
| Sequencer | Centralized (off-chain) | N/A (on-chain) | Decentralized (60 validators) |
| Governance | Dissolved | Multisig + community | On-chain DAO (Cosmos gov) |

## Recommendations

1. **For current VRTX holders**: Claim INK token airdrop per migration terms. VRTX has no future utility.
2. **For users with residual on-chain positions**: Withdraw all funds immediately if any remain in Vertex contracts.
3. **For researchers studying Vertex's model**: The Edge sequencer architecture was innovative but the centralized operation proved to be an existential risk -- a single team decision shut down the entire multi-chain protocol.
4. **For protocols considering similar architecture**: Implement sequencer decentralization BEFORE multi-chain expansion. A centralized sequencer across 7+ chains is a systemic single point of failure.
5. **For the Ink Foundation**: Publish the status of Vertex's residual smart contract ownership keys. If upgrade authority still exists, either renounce it or transfer to a transparent multisig.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- UNVERIFIED, likely yes given owner powers
- [x] Admin can change oracle sources arbitrarily? -- UNVERIFIED
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED
- [x] Multisig has low threshold (2/N with small N)? -- UNVERIFIED, but no multisig confirmed
- [x] Zero or short timelock on governance actions? -- No documented timelock
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (EVM)
- [ ] Social engineering surface area (anon multisig signers)? -- Team is doxxed but multisig signers unknown

**WARNING: 4+ indicators match Drift-type pattern. The undocumented admin controls and lack of verified timelock represent significant governance risk for any residual on-chain contracts.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- Primarily major assets
- [ ] Single oracle source without TWAP? -- Dual oracle (Stork + Chainlink)
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [ ] Insufficient insurance fund relative to TVL? -- Undisclosed

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- Edge sequencer is centralized
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [x] No key rotation policy? -- No published policy

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time (no snapshot)? -- Used xVRTX staking
- [ ] Flash loans can be used to acquire voting power? -- Staking lockup mitigates
- [ ] Proposal + execution in same block or short window? -- UNVERIFIED
- [ ] No minimum holding period for voting eligibility? -- 3-week lockup existed

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? -- UNVERIFIED
- [ ] Read-only reentrancy risk (cross-contract callbacks before state update)? -- Three Sigma audit addressed
- [ ] Flash loan compatible without reentrancy guards? -- UNVERIFIED
- [ ] Composability with protocols that expose callback hooks? -- Limited composability

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler (Vyper, Huff)? -- Standard Solidity
- [ ] Compiler version has known CVEs? -- UNVERIFIED
- [ ] Contracts compiled with different compiler versions? -- UNVERIFIED
- [ ] Code depends on language-specific behavior (storage layout, overflow)? -- Standard EVM

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral (own governance token)? -- No stablecoin
- [ ] Redemption mechanism creates sell pressure on collateral? -- N/A
- [ ] Oracle delay could mask depegging in progress? -- N/A
- [ ] No circuit breaker on redemption volume? -- N/A

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses a cross-chain bridge for token minting or reserve release? -- Edge sequencer, not traditional bridge
- [ ] Bridge message validation relies on a single messaging layer? -- Sequencer is centralized
- [ ] DVN/relayer/verifier configuration is not publicly documented? -- Sequencer architecture not fully documented
- [ ] Bridge can release or mint tokens without rate limiting? -- UNVERIFIED
- [ ] Bridged/wrapped token is accepted as collateral on lending protocols? -- VRTX not widely used as collateral
- [ ] No circuit breaker to pause minting if bridge-released volume exceeds normal thresholds? -- UNVERIFIED
- [ ] Emergency pause response time > 15 minutes? -- UNVERIFIED
- [ ] Bridge admin controls under different governance than core protocol? -- Same team controlled both
- [ ] Token is deployed on 5+ chains via same bridge provider? -- Yes, 7 chains via Edge sequencer

## Information Gaps

1. **Multisig configuration**: No public information found about specific multisig setup (threshold, signers) for admin/owner keys
2. **Timelock duration**: No documented timelock on contract upgrades or admin actions
3. **Insurance fund size**: Never publicly disclosed; current status post-shutdown unknown
4. **Contract ownership post-shutdown**: Unknown whether admin keys were renounced, transferred, or remain active
5. **Sequencer source code**: Off-chain sequencer (Rust) does not appear to be open source; only on-chain contracts are public
6. **GoPlus detailed flags**: Many GoPlus fields returned null for the VRTX proxy contract, leaving honeypot, mintable, hidden owner, and other checks unverified
7. **Emergency response time**: No documented response time benchmarks
8. **Key management**: No information about HSM, MPC, or key ceremony procedures
9. **Security certifications**: No SOC 2, ISO 27001, or pentest disclosures found
10. **Ink Foundation governance over residual Vertex contracts**: No documentation on how residual smart contracts are managed post-acquisition
11. **DeFiLlama audit registration**: DeFiLlama shows 0 audits despite OtterSec and Three Sigma audits existing -- protocol team never submitted audit metadata

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.

**Special note**: Vertex Protocol has ceased operations as of August 14, 2025. This audit is a historical record. The protocol is not actively maintained, governed, or operated. Any interaction with residual on-chain contracts carries elevated risk due to the absence of active team monitoring and governance.
