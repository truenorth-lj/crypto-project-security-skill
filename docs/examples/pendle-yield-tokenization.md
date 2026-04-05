# DeFi Security Audit: Pendle Finance

## Overview
- Protocol: Pendle Finance
- Chain: Ethereum, Arbitrum, Base, Sonic, Mantle, Berachain, Hyperliquid L1, Binance, Avalanche, Optimism, Plasma (11 chains)
- Type: Yield Tokenization / Fixed Income
- TVL: $1,928,742,744 (as of 2026-04-05)
- TVL Trend: -7.3% (7d) / -11.6% (30d) / -48.8% (90d)
- Launch Date: June 2021 (V1); December 2022 (V2)
- Audit Date: 2026-04-05
- Source Code: Open
- Token: PENDLE (ERC-20, 0x808507121B80c02388fAd14726482e061B8da827 on Ethereum)

## Quick Triage Score: 67

Red flags found: 4

- MEDIUM: Token is mintable (is_mintable = 1) -- (-8)
- MEDIUM: Protocol age >6 months but TVL dropped ~49% in 90 days, signaling significant capital flight -- (-8)
- INFO: Single oracle listed on DeFiLlama (RedStone), though Chainlink is also integrated -- (-5)
- INFO: Multisig reported as 2/4 threshold, which is below best practices -- (-5)
- INFO: No documented timelock on admin actions (UNVERIFIED) -- (-5)
- INFO: Bug bounty max $250K is low relative to ~$1.9B TVL -- (-5) [Note: penalty is -2 as partial concern, not full -5]

Calculation: 100 - 8 - 8 - 5 - 5 - 5 - 2 = 67 (MEDIUM risk)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Not publicly disclosed | Spectra: N/A | HIGH |
| Audit Coverage Score | 2.25 (see below) | Spectra: ~1.0 | MEDIUM |
| Governance Decentralization | vePENDLE model; 2/4 multisig (UNVERIFIED) | Spectra: DAO governance | MEDIUM |
| Timelock Duration | Not documented (UNVERIFIED) | Aave: 24-48h | HIGH |
| Multisig Threshold | 2/4 (UNVERIFIED) | Aave: 6/10 | HIGH |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW |

**Audit Coverage Score Calculation:**
- Ackee Blockchain (V2, ~July 2024): 1.0 (< 2 years old)
- Dedaub (V2, ~July 2022): 0.25 (> 2 years old)
- Dingbats (V2, date unclear, est. 2023): 0.5 (1-2 years old)
- Code4rena wardens (V2, date unclear, est. 2023): 0.5 (1-2 years old)
- Total: 1.0 + 0.25 + 0.5 + 0.5 = 2.25 (MEDIUM)

## GoPlus Token Security (Ethereum, Chain ID 1)

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
| Holders | 72,653 | LOW |
| Trust List | Not whitelisted (0) | -- |
| Creator Honeypot History | No (0) | LOW |
| CEX Listed | Yes (Binance, Coinbase) | LOW |
| Owner Address | 0x8119ec16f0573b7dac7c0cb94eb504fb32456ee1 (contract, 8% supply) | -- |

**Top Holder Analysis** (from GoPlus):
- Top holder (23.9%): 0x4f30...0210 (contract) -- likely protocol treasury or vesting
- #2 (11.3%): 0x9999...4144 (contract) -- likely protocol-related contract
- #3 (9.9%): 0xa3a7...eaec (contract) -- likely staking or distribution
- #4 (8.0%): 0x8119...ee1 (contract, token owner) -- owner contract
- #5 (5.8%): 0x399b...ec9a (contract) -- likely vesting
- Top 5 holders control ~59% of supply, but all are contracts (not EOAs), reducing whale manipulation risk

**Note:** The token being mintable (is_mintable = 1) means additional PENDLE tokens can be created. This is expected for the emissions schedule but represents a centralization vector if minting authority is not properly governed.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | MEDIUM | 2/4 multisig with no documented timelock; vePENDLE governance provides decentralization | Partial |
| Oracle & Price Feeds | MEDIUM | Uses Chainlink + custom TWAP AMM oracle; RedStone on some chains; multiple oracle sources | Partial |
| Economic Mechanism | MEDIUM | TVL down ~49% in 90d from incentive-driven capital flight; no public insurance fund data | Partial |
| Smart Contract | LOW | Immutable V2 contracts; 4+ audits; open source; $250K bug bounty on Immunefi | Y |
| Token Contract (GoPlus) | LOW | Clean GoPlus report; mintable but no high-risk flags; listed on Binance and Coinbase | Y |
| Cross-Chain & Bridge | MEDIUM | 11-chain deployment via LayerZero OFT; LayerZero DVN-secured messaging | Partial |
| Operational Security | LOW | Doxxed team (TN Lee, Vu Nguyen); rapid incident response proven in Penpie hack | Y |
| **Overall Risk** | **MEDIUM** | **Well-audited, immutable core contracts with doxxed team, but multisig threshold is low, no documented timelock, and significant TVL decline signals capital flight** | |

## Detailed Findings

### 1. Governance & Admin Key

**Admin Key Surface Area:**
Pendle V2 core contracts are described as immutable, meaning the deployed market, AMM, and yield tokenization contracts cannot be upgraded after deployment. This significantly reduces admin key risk compared to upgradeable protocols.

However, the protocol still has administrative functions:
- A multisig wallet controls certain protocol parameters (UNVERIFIED exact powers)
- The multisig is reportedly a 2/4 configuration, which is below industry best practice (typically 3/5 or higher)
- No public documentation of a timelock on governance actions was found (UNVERIFIED)
- vePENDLE holders vote on incentive allocation to liquidity pools, providing decentralized governance for reward distribution
- The protocol successfully paused contracts during the Penpie exploit (September 2024), indicating an emergency pause capability exists

**Timelock Bypass Detection:**
- No timelock is publicly documented for Pendle V2 (UNVERIFIED)
- The ability to pause contracts quickly (as demonstrated during Penpie) suggests an emergency mechanism exists
- Whether this pause capability extends to other admin functions is unclear

**Upgrade Mechanism:**
- Core V2 contracts are immutable (non-upgradeable)
- New markets and SY (Standardized Yield) adapters can be deployed without upgrading core contracts
- The router contract uses immutable references for critical dependencies (WETH, data contracts)

**Governance Process:**
- vePENDLE provides vote-escrowed governance (lock PENDLE for voting power)
- Voting power decays over time unless renewed
- vePENDLE holders direct incentive allocation across pools
- On-chain governance for incentive distribution; off-chain for protocol-level decisions (UNVERIFIED)

**Token Concentration & Whale Risk:**
- Top 5 holders control ~59% of total supply, but all are smart contracts (treasury, staking, vesting)
- No single EOA holds enough to dominate governance
- The largest EOA holder (0xf977...) holds ~5.1% of supply
- vePENDLE locks reduce circulating voting supply, making governance manipulation harder

**Risk Rating: MEDIUM** -- Immutable contracts are a strong positive, but the 2/4 multisig threshold and lack of documented timelock are concerning.

### 2. Oracle & Price Feeds

**Oracle Architecture:**
- Pendle integrates Chainlink Price Feeds for liquid staking asset conversions (wstETH/stETH, rETH/ETH) on Arbitrum and Optimism
- RedStone oracle is listed as primary on DeFiLlama for certain chain deployments
- Pendle's AMM incorporates a custom time-decay pricing mechanism that makes PT prices converge toward par as maturity approaches, functioning as an implicit oracle for yield pricing
- A dedicated oracle contract (0x9a9Fa8...50C2) provides PT/YT/LP token pricing in SY or underlying asset terms

**Price Manipulation Resistance:**
- The AMM's time-decay factor provides inherent protection against short-term price manipulation
- Chainlink provides high-quality, volume-weighted, aggregated price data
- The TWAP-style mechanism in the AMM concentrates liquidity within a reasonable price range
- However, low-liquidity PT/YT markets could theoretically be manipulated

**Collateral / Market Listing:**
- New SY adapters (wrapping yield-bearing tokens) can be deployed to create new markets
- Market creation process is not fully permissionless but involves protocol curation
- The Penpie exploit demonstrated that malicious actors could create fake Pendle markets in protocols built on top of Pendle

**Risk Rating: MEDIUM** -- Multiple oracle sources (Chainlink, RedStone, custom AMM oracle) provide reasonable coverage. The custom AMM oracle with time-decay is well-designed. However, the interaction between Pendle markets and external protocols (as shown by Penpie) introduces oracle-adjacent risk.

### 3. Economic Mechanism

**Yield Tokenization Model:**
- Pendle splits yield-bearing tokens into PT (Principal Token) and YT (Yield Token)
- PT represents the principal and trades at a discount to par, converging at maturity
- YT represents future yield and decays to zero at maturity
- This is a well-understood financial mechanism (interest rate stripping) adapted for DeFi

**Boros (V3) -- Margin Yield Trading:**
- Launched on Arbitrum in early 2025
- Enables leveraged long/short positions on variable interest rates (funding rates)
- Hybrid CLOB + AMM architecture
- Maintenance margin at 66% of initial margin at max leverage
- Liquidation occurs when Net Balance falls below maintenance margin
- This introduces new risk vectors: leveraged positions, liquidation cascades, and oracle dependency for funding rates

**TVL Dynamics:**
- TVL peaked above $6B in mid-2024, now at ~$1.9B
- 90-day decline of ~49% attributed to post-airdrop capital flight
- Growth was heavily driven by points/airdrop farming (mercenary capital)
- Protocol must transition to organic, sticky TVL for sustainability
- TVL decline is structural (incentive expiry) rather than exploit-driven

**Bad Debt Handling:**
- No publicly documented insurance fund or its size relative to TVL (UNVERIFIED)
- The immutable nature of V2 contracts means bad debt mechanisms are fixed at deployment
- Boros has explicit liquidation parameters with margin requirements

**Risk Rating: MEDIUM** -- The core yield tokenization mechanism is sound and well-tested. The significant TVL decline is concerning but appears driven by market dynamics rather than protocol failure. Boros introduces leverage risk that requires monitoring.

### 4. Smart Contract Security

**Audit History:**
- Ackee Blockchain: Pendle V2 audit (published ~July 2024)
- Dedaub: Pendle V2 audit (Part 1, ~July 2022)
- Dingbats: Pendle V2 audit (date unclear, est. 2023)
- Code4rena: Warden review (date unclear, est. 2023)
- All audits publicly available at github.com/pendle-finance/pendle-core-v2-public/tree/main/audits
- DeFiSafety Certified Integrity Score: 91/100

**Bug Bounty:**
- Active on Immunefi since June 2021, last updated November 2024
- Max payout: $250,000 (Critical: $50K-$250K, High: $10K flat, Medium: $5K flat)
- Also listed on Cantina for additional coverage
- The $250K maximum is relatively low for a ~$1.9B TVL protocol (Aave offers $250K+ per vulnerability class)

**Battle Testing:**
- Protocol live since June 2021 (V1), December 2022 (V2) -- nearly 5 years of operation
- Peak TVL exceeded $6B without direct exploit of Pendle contracts
- Penpie exploit (September 2024, $27M loss) was in a third-party protocol built on Pendle, not in Pendle itself
- Pendle team responded within 20 minutes, pausing contracts and saving $105M from further loss
- No direct exploits of Pendle V2 core contracts known
- All contracts are open source

**Risk Rating: LOW** -- Strong audit trail, immutable contracts, proven battle testing over multiple years, and effective incident response. The bug bounty could be higher relative to TVL.

### 5. Cross-Chain & Bridge

**Multi-Chain Deployment:**
- Pendle V2 is deployed on 11 chains: Ethereum, Arbitrum, Base, Sonic, Mantle, Berachain, Hyperliquid L1, Binance, Avalanche, Optimism, Plasma
- Each chain deployment has its own set of immutable contracts
- Whether each chain has an independent admin multisig or a shared one is not publicly documented (UNVERIFIED)
- Risk parameters may vary per chain (different SY adapters and markets per chain)

**Bridge Dependencies:**
- PENDLE token uses LayerZero OFT (Omnichain Fungible Token) standard for cross-chain transfers
- OFT uses burn-and-mint model (no wrapped assets, no liquidity pools, no slippage)
- LayerZero has been Pendle's interoperability partner since March 2023, with 39,000+ messages sent across 9 chains
- LayerZero DVNs (Decentralized Verifier Networks) secure cross-chain messages
- Pendle configures which DVNs secure its messages, providing protocol-level control

**Cross-Chain Message Security:**
- vePENDLE voting logic is coordinated from Ethereum to other chains via LayerZero messaging
- Emissions schedules and protocol behavior are synchronized cross-chain
- A compromised LayerZero DVN set could theoretically forge governance messages on remote chains
- LayerZero has been independently audited and is widely used across DeFi

**Risk Rating: MEDIUM** -- LayerZero is a well-established cross-chain messaging protocol, and the OFT standard is cleaner than wrapped token bridges. However, dependency on a single bridge provider across 11 chains creates a systemic risk vector. If LayerZero were compromised, all cross-chain PENDLE operations would be affected.

### 6. Operational Security

**Team & Track Record:**
- Co-founders TN Lee and Vu Nguyen are publicly doxxed with professional profiles on Crunchbase, LinkedIn, and active social media presence
- TN Lee is publicly active on Twitter (@tn_pendle) and has given interviews (The Defiant podcast)
- The team has a strong track record of ~5 years building Pendle without a direct protocol exploit
- Pendle has received funding from investors (PitchBook, Crunchbase profiles available)

**Incident Response:**
- Demonstrated excellence during the Penpie hack (September 2024):
  - Detected exploit within minutes
  - Paused all Pendle contracts within 20 minutes
  - Prevented $105M in additional losses
  - Coordinated with security firms for analysis
- Emergency pause capability exists and has been battle-tested
- Team communicates via Twitter and official channels

**Dependencies:**
- LayerZero for cross-chain messaging and token bridging
- Chainlink and RedStone for price feeds
- Underlying yield-bearing protocols (Lido, Rocket Pool, Ethena, etc.) for SY adapters
- Composability risk: if an underlying yield-bearing protocol fails, the corresponding Pendle markets would be affected
- Ethena USDe reportedly accounts for ~70% of Pendle TVL, creating significant concentration risk

**Risk Rating: LOW** -- Doxxed team with proven incident response capability and a long track record. The Penpie incident demonstrated both the risk of composability and the team's ability to respond effectively.

## Critical Risks (if any)

No CRITICAL risks were identified. The following HIGH-concern items merit attention:

1. **No documented timelock on governance actions** (UNVERIFIED) -- If the 2/4 multisig can execute changes without delay, this creates a vector for rapid malicious action with only 2 compromised signers.
2. **TVL concentration in Ethena USDe** -- Reportedly ~70% of TVL comes from a single protocol (Ethena). A failure or depeg of USDe would have outsized impact on Pendle.
3. **Sustained TVL decline** -- 49% drop over 90 days signals fragile, incentive-driven capital. While not a security issue per se, declining TVL reduces economic security margins.

## Peer Comparison

| Feature | Pendle | Spectra (fmr. APWine) | Aave (lending benchmark) |
|---------|--------|-----------------------|--------------------------|
| Timelock | Not documented (UNVERIFIED) | Not documented | 24-48h |
| Multisig | 2/4 (UNVERIFIED) | DAO governance | 6/10 |
| Audits | 4+ (Ackee, Dedaub, Dingbats, C4) | Multiple | 20+ |
| Oracle | Chainlink + RedStone + custom AMM | Custom | Chainlink |
| Insurance/TVL | Not disclosed | N/A | ~5%+ |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | $250K (Immunefi) | N/A | $250K+ (Immunefi) |
| TVL | ~$1.9B | ~$190M | ~$15B+ |
| Immutable Contracts | Yes (V2 core) | Partially (UNVERIFIED) | No (upgradeable) |
| Cross-Chain | 11 chains (LayerZero) | Base + L2s | 8+ chains |

## Recommendations

1. **For users depositing into Pendle V2 markets**: The core contracts are immutable and well-audited. Risk primarily comes from the underlying yield-bearing assets. Verify the quality and security of the specific SY adapter and underlying protocol before depositing.

2. **Monitor Ethena USDe concentration**: With ~70% of TVL reportedly in USDe-related markets, users should assess their indirect exposure to Ethena risk through Pendle positions.

3. **For Boros (V3) users**: Margin trading introduces liquidation risk. Understand maintenance margin requirements (66% of initial margin at max leverage) and monitor positions actively.

4. **Cross-chain users**: PENDLE token bridging via LayerZero OFT is generally safe but introduces bridge dependency. For large positions, consider holding PENDLE on Ethereum (home chain) where possible.

5. **For the Pendle team**: Consider upgrading the multisig threshold from 2/4 to at least 3/5, publicly documenting timelock durations (if they exist), and increasing the bug bounty maximum relative to TVL.

6. **Governance participants**: vePENDLE holders should monitor governance proposals for changes to incentive allocation, as these can significantly impact market liquidity and yields.

## Historical DeFi Hack Pattern Check

Cross-reference against known DeFi attack vectors:

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- New SY adapters can be deployed (permissioned), timelock status UNVERIFIED
- [ ] Admin can change oracle sources arbitrarily? -- Core contracts are immutable; oracle sources fixed at deployment
- [ ] Admin can modify withdrawal limits? -- Core contracts are immutable; no withdrawal limit modification documented
- [ ] Multisig has low threshold (2/N with small N)? -- YES: 2/4 reported (UNVERIFIED)
- [ ] Zero or short timelock on governance actions? -- UNVERIFIED; no timelock documented
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (EVM protocol)
- [ ] Social engineering surface area (anon multisig signers)? -- Team is doxxed; multisig signer identities UNVERIFIED

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- Some PT/YT markets may have low liquidity near maturity
- [ ] Single oracle source without TWAP? -- No; AMM has built-in time-decay pricing + Chainlink/RedStone
- [ ] No circuit breaker on price movements? -- UNVERIFIED for Boros margin trading
- [ ] Insufficient insurance fund relative to TVL? -- Insurance fund size not publicly disclosed

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- LayerZero DVN-secured (semi-decentralized); Pendle selects DVN configuration
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

## Information Gaps

The following questions could NOT be answered from publicly available information. These represent unknown risks.

1. **Exact multisig configuration**: The 2/4 threshold is referenced in third-party sources but not confirmed in official Pendle documentation. The identities of multisig signers are not publicly listed.
2. **Timelock existence and duration**: No official documentation was found confirming or denying a timelock on admin/governance actions.
3. **Insurance fund size**: No public data on whether Pendle maintains an insurance fund or its size relative to TVL.
4. **Per-chain admin configuration**: Whether each of the 11 chain deployments has an independent multisig or shares governance with Ethereum is undocumented.
5. **Boros risk parameters**: Detailed circuit breaker mechanisms, maximum leverage limits, and liquidation bot infrastructure for Boros are partially documented but not fully transparent.
6. **Emergency pause scope**: While emergency pause was demonstrated during Penpie, the exact scope of what can be paused and by whom is not publicly detailed.
7. **Minting authority for PENDLE token**: GoPlus reports the token as mintable. The governance process and constraints around minting additional PENDLE tokens are not fully documented.
8. **LayerZero DVN configuration**: Which specific DVNs Pendle uses and their security properties are not publicly specified.
9. **Post-Penpie security improvements**: Whether Pendle made changes to prevent similar third-party exploits after the Penpie incident is not publicly documented.
10. **Audit coverage for Boros**: Whether the Boros (V3) contracts have been independently audited is not confirmed from available sources.

## Disclaimer

This analysis is based on publicly available information and web research as of 2026-04-05.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
