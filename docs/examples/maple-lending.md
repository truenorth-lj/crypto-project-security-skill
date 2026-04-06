# DeFi Security Audit: Maple Finance

**Audit Date:** April 6, 2026
**Protocol:** Maple Finance -- Institutional on-chain lending and credit marketplace

## Overview
- Protocol: Maple Finance (V2+)
- Chain: Ethereum (primary), Solana (via Chainlink CCIP)
- Type: Institutional Lending / Credit Marketplace
- TVL: ~$2.09B (Ethereum); ~$1.95B borrowed
- TVL Trend: -16.2% / +0.2% / -21.8% (7d / 30d / 90d)
- Launch Date: May 2021 (V1), December 2022 (V2)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub -- github.com/maple-labs)

## Quick Triage Score: 67/100

Starting at 100, subtract:
- [-8] TVL dropped >30% in 90 days (down ~21.8% -- does not trigger, but 7d drop of 16.2% notable)
- [-5] No documented timelock on admin actions -- PARTIALLY MITIGATED: 3-day timelock exists per docs but specific scope unclear
- [-5] Undisclosed multisig signer identities (multisig exists but signer identities not publicly enumerated)
- [-5] Insurance fund / TVL < 1% or undisclosed (pool cover mechanism exists but ratio vs current TVL is undisclosed)
- [-5] Single oracle provider (Chainlink only, though with oracle wrappers)
- [-8] Multisig threshold < 3 signers -- UNVERIFIED (exact threshold not publicly documented)

Score: 100 - 5 - 5 - 5 - 5 - 8 = **72** (adjusted to **67** due to the undercollateralized lending model introducing credit risk not captured by standard triage flags)

Risk bracket: **MEDIUM** (50-79)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (pool cover model) | 1-5% (Aave ~2%) | HIGH |
| Audit Coverage Score | 4.25 (see breakdown) | 3.0 avg | LOW |
| Governance Decentralization | Snapshot + Governor Timelock | DAO + Guardian avg | MEDIUM |
| Timelock Duration | 72h (3 days) | 24-48h avg | LOW |
| Multisig Threshold | UNVERIFIED | 3/5 avg | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 0 MED | -- | LOW |

**Audit Coverage Score Breakdown:**
- Spearbit + Sherlock (Nov 2025): 2 x 1.0 = 2.0 (less than 1 year old)
- 0xMacro + Three Sigma (Aug 2024): 2 x 0.5 = 1.0 (1-2 years old)
- Three Sigma (Nov 2023): 1 x 0.5 = 0.5
- Spearbit/Cantina + Three Sigma (Jun 2023): 2 x 0.25 = 0.5
- Trail of Bits + Spearbit + Three Sigma (Dec 2022): 3 x 0.25 = 0.75
- **Total: 4.75** -- LOW risk threshold (>= 3.0)

## GoPlus Token Security (MPL on Ethereum: 0x33349B282065b0284d756F0577FB39c158F935e6)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | No | -- |
| Mintable | No | -- |
| Owner Can Change Balance | No | -- |
| Hidden Owner | No | -- |
| Selfdestruct | No | -- |
| Transfer Pausable | No | -- |
| Blacklist | No | -- |
| Slippage Modifiable | No | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 8,503 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No | -- |
| CEX Listed | Coinbase | -- |

GoPlus assessment: **LOW RISK**. Zero flags across all categories. The MPL token is non-proxy, non-mintable, open source, with no hidden owner or trading restrictions. Note: the protocol has migrated governance to the SYRUP token (1 MPL = 100 SYRUP); the MPL contract itself remains clean. Holder count is relatively low (8,503) compared to major DeFi tokens, reflecting the institutional focus.

**Top Holder Concentration (MPL):** The top holder (contract at 0x9c94...) holds ~92.4% of the supply, likely a protocol migration/staking contract related to the MPL-to-SYRUP conversion. This extreme concentration is expected given the token migration but should be verified.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | Governor + 3-day timelock, but multisig details undisclosed | Partial |
| Oracle & Price Feeds | **LOW** | Chainlink with oracle wrappers; triple price feed monitoring | Partial |
| Economic Mechanism | **MEDIUM** | Undercollateralized lending history; now overcollateralized but credit risk persists | Partial |
| Smart Contract | **LOW** | 10+ audits across 5 firms; DeFi Safety 92% score; active Immunefi bounty | Y |
| Token Contract (GoPlus) | **LOW** | Zero GoPlus flags; clean MPL token contract | Y |
| Cross-Chain & Bridge | **MEDIUM** | Solana expansion via Chainlink CCIP; relatively new integration | Partial |
| Operational Security | **LOW** | Doxxed team; demonstrated crisis management; 24/7 monitoring | Y |
| **Overall Risk** | **MEDIUM** | **Strong smart contract security and team, but credit risk model and governance transparency gaps persist** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**Architecture:** Maple uses a Governor contract (MapleGlobals) that serves as the central administrative actor on behalf of the Maple DAO. The Governor can configure protocol-wide parameters, manage factory allowlists, and control time-locked actions including smart contract upgrades.

**Timelock:** A 3-day (72-hour) timelock governs protocol upgrades. Upgrade instances are first registered, then executed on-chain after the delay period. This is above the peer average of 24-48 hours, which is positive.

**Governor Timelock Contract Upgrade (September 2025):** The protocol upgraded its Governor Timelock Contract, suggesting ongoing governance improvements. However, the specific changes and new parameters are not fully documented publicly.

**Multisig:** A multisig exists and can trigger emergency protocol pauses. However:
- The exact number of signers and threshold (e.g., 3/5, 4/7) is not publicly enumerated -- UNVERIFIED
- Signer identities are not publicly disclosed -- UNVERIFIED
- The scope of the emergency multisig powers beyond pause functionality is unclear

**Governance Process:** Voting is conducted via Snapshot (off-chain) using SYRUP or stSYRUP token balances. This means governance votes are not enforced on-chain and rely on the team to execute the outcome faithfully. The MIP-019 vote (October 2025) that restructured tokenomics passed through this process.

**Key Concern:** The combination of off-chain governance (Snapshot) with an undisclosed multisig configuration creates a trust gap. While the 3-day timelock is solid, the lack of transparency around who controls the multisig and what powers it has beyond pause is a meaningful risk for a protocol managing over $2B.

### 2. Oracle & Price Feeds -- LOW

**Primary Oracle:** Chainlink price feeds across all deployments, consistent with DeFiLlama data.

**Oracle Wrappers:** Maple uses proprietary oracle wrappers around Chainlink feeds that provide additional security against oracle outages and manipulation, specifically during liquidation events. This is a meaningful enhancement over raw Chainlink integration.

**Triple Price Feed Monitoring:** The Maple Operations team maintains a proprietary alert system with three separate sources for price feeds and 24/7/365 live monitoring to enable swift margin calls.

**Cross-Chain Feeds:** With the Solana expansion via Chainlink CCIP, price feeds are delivered through Chainlink Data Streams for the Solana ecosystem.

**Limitations:**
- Single oracle provider dependency (Chainlink) -- though mitigated by wrappers and triple-source monitoring
- Admin can potentially change oracle configurations through the Governor contract, subject to timelock

### 3. Economic Mechanism -- MEDIUM

**Historical Context -- FTX/Alameda Crisis (2022):**
Maple suffered approximately $54 million in bad debt when the FTX collapse triggered defaults across its lending pools. Orthogonal Trading defaulted on $36M, Auros Global missed a $3M payment, and the total soured debt represented 66% of outstanding loans across four active pools. The loan book shrank by two-thirds from $260M. This was not a smart contract exploit but a fundamental failure of the undercollateralized lending model and pool delegate due diligence.

**V2 Overhaul and Model Shift:**
Following the crisis, Maple V2 (December 2022) introduced significant improvements:
- Shift from undercollateralized to overcollateralized lending (120-170% collateralization, averaging 160%+)
- Overhauled withdrawal process
- Enhanced pool cover mechanism
- Improved public pool dashboards and transparency

**Current Lending Model:**
- Fixed-rate, fixed-duration loans backed by BTC, ETH, and stablecoins as collateral
- Borrowers must maintain overcollateralization at all times
- Automatic margin calls when collateral approaches liquidation thresholds
- 24-hour cure period for borrowers to restore collateral levels
- Flagship products: syrupUSDC and syrupUSDT (yield-bearing stablecoins)

**Performance Since V2:**
- Zero losses reported since the V2 overhaul through April 2026
- Successfully navigated the October 2025 volatility event with zero liquidations and zero losses
- Net APY: 16.8% (High Yield Secured), 10.2% (Blue Chip Secured), 21.3% (Syrup) in 2024

**Pool Cover / Insurance:**
- Pool delegates must provide first-loss capital in the form of MPL tokens
- Third-party cover providers receive 10% of interest revenue as premiums
- First-loss capital is the first to be liquidated in a default event
- However, the exact ratio of pool cover to TVL is not publicly disclosed -- this is a significant information gap for a $2B+ protocol

**Credit Risk Concerns:**
- While the model has shifted to overcollateralized, institutional borrower credit risk remains (counterparty risk)
- Pool delegates serve as gatekeepers for borrower quality -- the 2022 crisis demonstrated this is a single point of failure
- High yields (13.5%+ average) in a low-rate environment suggest elevated risk-taking
- The pool delegate trust model means lenders are implicitly trusting delegate underwriting judgment

### 4. Smart Contract Security -- LOW

**Audit History (Comprehensive):**

| Release | Auditors | Date | Severity |
|---------|----------|------|----------|
| V2 (Dec 2022) | Trail of Bits, Spearbit, Three Sigma | Aug-Oct 2022 | All issues addressed |
| Jun 2023 | Spearbit (Cantina), Three Sigma | Apr-Jun 2023 | All issues addressed |
| Dec 2023 | Three Sigma | Nov 2023 | All issues addressed |
| Aug 2024 | 0xMacro, Three Sigma | Aug 2024 | All issues addressed |
| Nov 2025 | Spearbit, Sherlock | Nov 2025 | All issues addressed |

No vulnerabilities of high severity or greater have been identified since the June 2023 audits.

**Bug Bounty:**
- Active on Immunefi with rewards up to $500,000
- Payouts in USDC or MPL at team discretion
- KYC required for bounty hunters
- Proof of concept required for all severities
- Known audit issues and 4626 compliance issues are out of scope

**Code Quality:**
- Open source on GitHub (github.com/maple-labs)
- DeFi Safety score: 92% (Process Quality Review)
- Code4rena audit contest conducted (March 2022)
- Factory pattern for contract management with Governor-controlled allowlists

**Battle Testing:**
- Live since May 2021 (nearly 5 years)
- Survived the 2022 bear market and FTX crisis (credit loss, not contract exploit)
- No smart contract exploits in production
- Peak TVL ~$2.8B (Q3 2025)

### 5. Cross-Chain & Bridge -- MEDIUM

**Multi-Chain Deployment:**
- Primary: Ethereum (all core lending infrastructure)
- Solana: syrupUSDC accessible via Chainlink CCIP (launched mid-2025)
- BNB Chain expansion planned for 2026

**Bridge Architecture:**
- Uses Chainlink CCIP (Cross-Chain Interoperability Protocol) and the Cross-Chain Token (CCT) standard
- Not reliant on third-party bridges (Wormhole, LayerZero, etc.)
- CCIP leverages Chainlink's oracle infrastructure with a separate Risk Management Network
- Zero-slippage transfers with configurable rate limits and Smart Execution

**Security Considerations:**
- CCIP is among the more conservative cross-chain solutions, backed by Chainlink's $21T+ transaction value infrastructure
- Rate limits provide protection against bridge-related exploits
- Relatively new integration (mid-2025) -- less battle-tested than the core Ethereum deployment
- $500K in incentives and $30M+ in initial liquidity deployed on Solana

**Risk Assessment:**
The choice of Chainlink CCIP over less established bridge providers is a positive signal. However, the Solana deployment is less than a year old and the cross-chain governance model (whether Solana deployment has independent risk parameters) is not fully documented.

### 6. Operational Security -- LOW

**Team:**
- Co-founders Sidney Powell (CEO) and Joe Flanagan are fully doxxed
- Sidney Powell is a regular speaker at major conferences (Consensus 2025, CfC St. Moritz, Greenwich Economic Forum)
- Company is venture-backed with Crunchbase profile and institutional investors
- Team has navigated the 2022 FTX crisis and rebuilt the protocol successfully

**Incident Response:**
- Emergency pause capability via multisig
- 24/7/365 live monitoring with proprietary alert systems
- Three separate price feed sources for monitoring
- Demonstrated crisis management during 2022 defaults and October 2025 volatility event
- Published security documentation at docs.maple.finance

**Dependencies:**
- Chainlink (oracle feeds and CCIP) -- well-established, LOW risk
- Ethereum (base layer) -- LOW risk
- Solana (secondary deployment) -- MEDIUM risk (newer integration)
- USDC/USDT stablecoin issuers (Circle, Tether) -- systemic risk shared by all DeFi

## Critical Risks

1. **MEDIUM -- Undisclosed insurance/cover ratio:** For a $2B+ protocol, the lack of publicly disclosed pool cover-to-TVL ratio is a significant transparency gap. If pool cover is thin relative to outstanding loans, a cascading default event could leave lenders with unrecoverable losses.

2. **MEDIUM -- Pool delegate concentration of trust:** The lending model places enormous trust in pool delegates to properly underwrite borrowers. The 2022 crisis proved this model can fail catastrophically ($54M in bad debt). While the shift to overcollateralized loans mitigates this, delegates still control loan origination and borrower selection.

3. **MEDIUM -- Governance transparency gap:** The combination of off-chain Snapshot voting, an undisclosed multisig configuration, and the Governor contract's broad powers creates a trust assumption that may not be appropriate for a top-10 lending protocol by TVL.

## Peer Comparison

| Feature | Maple Finance | Aave | Compound |
|---------|--------------|------|----------|
| Timelock | 72h (3 days) | 24h / 168h (dual) | 48h |
| Multisig | UNVERIFIED | 6/10 Guardian | Community multisig |
| Audits | 10+ (5 firms) | 6+ firms, formal verification | Multiple firms |
| Oracle | Chainlink + wrappers | Chainlink + SVR | Chainlink |
| Insurance/TVL | Undisclosed | ~2% (Safety Module) | Reserve factor |
| Open Source | Yes | Yes | Yes |
| Governance | Snapshot (off-chain) | On-chain DAO | On-chain DAO |
| Bug Bounty | $500K (Immunefi) | $1M+ (Immunefi) | $500K+ |
| TVL | ~$2.1B | ~$23.6B | ~$2.0B |
| Lending Model | Overcollateralized (institutional) | Overcollateralized (permissionless) | Overcollateralized (permissionless) |

**Key Differentiator:** Maple's institutional lending model with pool delegates is fundamentally different from Aave/Compound's permissionless model. This creates unique credit risk that does not exist in purely algorithmic lending protocols, but also enables higher yields and institutional-grade products.

## Recommendations

1. **For lenders/depositors:** Understand that syrupUSDC/syrupUSDT yields come from institutional lending with credit risk. Even with overcollateralization, extreme market events could lead to losses. Diversify across pools and monitor pool delegate performance.

2. **For the protocol:** Publicly disclose pool cover-to-TVL ratios and multisig signer identities/thresholds. As a $2B+ protocol, governance transparency should match institutional peers like Aave.

3. **For large depositors:** Verify the multisig configuration on-chain before committing significant capital. The 3-day timelock is solid, but the undisclosed multisig threshold creates uncertainty about who can initiate timelocked actions.

4. **Monitor:** TVL trend shows a 7-day decline of 16.2% -- while this may be normal market fluctuation, sharp TVL drops can indicate institutional withdrawals. Track whether this stabilizes.

5. **Cross-chain users:** The Solana deployment via CCIP is relatively new. Consider keeping larger positions on the battle-tested Ethereum deployment until the cross-chain infrastructure matures.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- No, Governor uses 3-day timelock
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED; Governor controls oracle config but timelock applies
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED; Governor has broad parameter control
- [ ] Multisig has low threshold (2/N with small N)? -- UNVERIFIED (multisig threshold not public)
- [ ] Zero or short timelock on governance actions? -- No, 3-day timelock confirmed
- [ ] Pre-signed transaction risk? -- N/A (EVM-based)
- [x] Social engineering surface area (anon multisig signers)? -- Yes, multisig signers not publicly identified

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- No, collateral is BTC/ETH/stablecoins (high liquidity)
- [ ] Single oracle source without TWAP? -- Partially; single provider (Chainlink) but with wrappers
- [ ] No circuit breaker on price movements? -- Oracle wrappers provide protection
- [ ] Insufficient insurance fund relative to TVL? -- UNVERIFIED (ratio not disclosed)

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No, uses Chainlink CCIP (decentralized)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

**Pattern Match Assessment:** Low match across all three exploit patterns. The primary risk vector for Maple is not a traditional DeFi hack but rather credit/counterparty risk (as demonstrated in the 2022 FTX crisis). The protocol's shift to overcollateralized lending significantly reduces but does not eliminate this risk.

## Information Gaps

- Exact multisig signer count, threshold, and identities -- critical governance information not publicly available
- Pool cover-to-TVL ratio -- the insurance mechanism exists but its adequacy relative to the $2.09B TVL is undisclosed
- Scope of emergency multisig powers beyond protocol pause -- can it upgrade contracts or drain funds?
- Whether the Governor timelock has bypass mechanisms (emergency council, security guardian)
- Detailed Solana deployment governance -- whether risk parameters are independently managed or controlled from Ethereum
- Specific borrower concentration data -- what percentage of loans are to top 3-5 borrowers
- Key storage practices for admin keys (hardware wallets, operational security procedures)
- On-chain verification of the Governor contract's timelock parameters and multisig configuration
- Breakdown of the SYRUP token's top holder (92.4% in a single contract) -- likely migration-related but unverified

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
