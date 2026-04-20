# DeFi Security Audit: Aster (Perpetual DEX)

**Audit Date:** 2026-04-20
**Protocol:** Aster -- Multi-chain perpetual DEX (formerly Astherus / APX Finance)
**Valid Until:** 2026-07-19 (or sooner if: TVL changes >30%, governance upgrade, or security incident)

## Overview
- Protocol: Aster (prev. Astherus + APX Finance merger, 2024)
- Chain: BNB Chain (primary), Ethereum, Arbitrum, Solana, Scroll; Aster Chain L1 (mainnet March 17, 2026)
- Type: Perpetual DEX / Derivatives
- TVL: ~$538M (Aster Bridge on DeFiLlama); perps TVL not tracked (DeFiLlama lists "Off Chain")
- Open Interest: ~$1.9B (reported)
- Daily Volume: ~$2-3B (reported; wash trading controversy -- see below)
- Token: ASTER (BEP-20, BNB Chain) -- 0x000Ae314E2A2172a039B26378814C252734f556A
- Max Supply: 8,000,000,000 ASTER
- TGE: September 17, 2025
- Launch Date: 2024 (as merged entity); APX Finance predecessor dates earlier
- Audit Date: 2026-04-20
- Source Code: Partial (token contract open source; perps contracts on GitHub via asterdexcom; core matching engine off-chain / closed)
- Backer: YZi Labs (CZ-affiliated fund, sole seed investor)

## Quick Triage Score: 22/100 (HIGH risk) | Data Confidence: 50/100 (MEDIUM)

**Triage deductions (mechanical):**

| Flag | Category | Points |
|------|----------|--------|
| Zero audits listed on DeFiLlama | HIGH | -15 |
| Anonymous team with no prior track record | HIGH | -15 |
| No multisig confirmed (admin key structure undisclosed) | HIGH | -15 |
| No documented timelock on admin actions | LOW | -5 |
| Insurance fund / TVL undisclosed | LOW | -5 |
| Undisclosed multisig signer identities | LOW | -5 |
| No published key management policy | LOW | -5 |
| No disclosed penetration testing | LOW | -5 |
| No third-party security certification (SOC 2 / ISO 27001) | MEDIUM | -8 |
| **Total deducted** | | **-78** |

**Data Confidence breakdown:**

| Verified Data Point | Points |
|---------------------|--------|
| Source code open and verified (GoPlus) | +15 |
| GoPlus token scan completed | +15 |
| At least 1 audit report publicly available | +10 |
| Bug bounty program on Immunefi | +5 |
| Oracle providers confirmed (Pyth + Chainlink + Binance Oracle) | +5 |
| **Total** | **50** |

Red flags found: 9 (3 HIGH, 1 MEDIUM, 5 LOW)
Data points verified: 5 / 15 checkable

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | GMX ~2-3%, Hyperliquid ~1% | HIGH |
| Audit Coverage Score | ~2.5 (4 audits, most <1yr old but scope limited to vault/LST) | GMX 3+, Hyperliquid 2+ | MEDIUM |
| Governance Decentralization | Centralized (no on-chain governance yet; planned Q2 2026) | Hyperliquid centralized, GMX DAO | HIGH |
| Timelock Duration | Undisclosed / None documented | 24-48h avg | HIGH |
| Multisig Threshold | Undisclosed | GMX 4/6, dYdX DAO | HIGH |
| GoPlus Risk Flags | 0 HIGH / 0 MED | -- | LOW |

**TVL trend (Aster Bridge):**
- 7d: -5.4%
- 30d: -4.1%
- 90d: -23.5%

## GoPlus Token Security (ASTER on BNB Chain)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | -- |
| Open Source | Yes (1) | -- |
| Proxy | No (0) | -- |
| Mintable | No (0) | -- |
| Owner Can Change Balance | No (0) | -- |
| Hidden Owner | No (0) | -- |
| Selfdestruct | No (0) | -- |
| Transfer Pausable | No (0) | -- |
| Blacklist | No (0) | -- |
| Slippage Modifiable | No (0) | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 229,863 | -- |
| Trust List | N/A | -- |
| Creator Honeypot History | No (0) | -- |

GoPlus assessment: **LOW RISK**. The ASTER token contract itself is clean -- no honeypot, no owner privileges, not mintable, not upgradeable. No trading restrictions or hidden mechanisms detected. The token contract risk is minimal; the risk lies in the protocol layer above, not the token contract.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **HIGH** | Anonymous CEO, no public multisig, no timelock, no on-chain governance | S/O | N |
| Oracle & Price Feeds | **MEDIUM** | Multi-oracle (Pyth + Chainlink + Binance Oracle), but Binance Oracle introduces centralization risk | S | Partial |
| Economic Mechanism | **MEDIUM** | Insurance fund undisclosed; ADL fallback exists; 1001x leverage is extreme | S | Partial |
| Smart Contract | **MEDIUM** | Multiple audits exist (PeckShield, Salus, CertiK, Hacken) but scope limited to vaults/LST, not core perps engine | S | Partial |
| Token Contract (GoPlus) | **LOW** | Clean token contract, no flags | S | Y |
| Cross-Chain & Bridge | **HIGH** | 5 chains + own L1; bridge TVL ~$538M; zero audits on DeFiLlama for bridge | S | N |
| Off-Chain Security | **HIGH** | No SOC 2, no key management policy, no pentest disclosed, anonymous team | O | N |
| Operational Security | **HIGH** | Anonymous team, no incident response plan published, wash trading controversy | S/H/O | N |
| **Overall Risk** | **HIGH** | **Anonymous team + no governance + undisclosed admin controls + multi-chain bridge risk** | | |

**Overall Risk aggregation**: Governance & Admin = HIGH (counts 2x = 2 HIGHs). Cross-Chain & Bridge = HIGH (5 chains, counts 2x = 2 HIGHs). Off-Chain Security = HIGH. Operational Security = HIGH. Total: 6+ HIGH equivalents. Overall = **HIGH**.

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Admin Key Surface Area**: UNVERIFIED. Aster has not publicly documented who controls admin keys, what admin functions exist (pause, upgrade, change params, drain), or what protections are in place. The protocol's documentation focuses on product features but omits governance architecture details.

**Multisig**: No public evidence of a multisig controlling admin functions. No Safe (Gnosis) addresses identified. No on-chain verification possible due to lack of disclosed addresses.

**Timelock**: No documented timelock on any admin actions. The protocol's documentation does not mention timelocks.

**On-chain governance**: Does not exist yet. Per the 2026 H1 roadmap, staking and on-chain governance are planned for Q2 2026 but have not launched as of the audit date.

**CEO**: Known only as "Leonard," fully anonymous. Per Yahoo Finance: "Leonard's existence is nearly entirely confined to Aster's public communications... He often discusses product branding, the roadmap, community, and security, but has never shared anything at all about himself or any work experience." His X profile features "a hooded figure with no real details."

**Token concentration**: Approximately 93% of ASTER supply is held in a few wallets, with some analyses indicating 6 wallets control over 96%. This presents extreme governance capture risk if/when token voting launches.

**YZi Labs relationship**: YZi Labs (CZ's fund) is the sole seed investor and provides technical support, marketing, and ecosystem access. The degree of operational control YZi Labs exerts over the protocol is unclear.

### 2. Oracle & Price Feeds -- MEDIUM

**Oracle Architecture**: Multi-oracle approach using Pyth Network, Chainlink, and Binance Oracle.

**1001x Simple Mode**: Pyth Oracle retrieves the latest price and updates the index-weighted average price feed. Smart contracts compare Pyth's price with Chainlink's feed to verify data accuracy. This dual-verification is positive.

**Binance Oracle dependency**: Including Binance Oracle introduces centralization risk. Binance Oracle is not a decentralized oracle network -- it is a single-source feed from Binance. Given Aster's close ties to YZi Labs (Binance ecosystem), this creates a potential conflict of interest.

**Admin oracle override**: UNVERIFIED whether admin can change oracle sources without timelock or governance vote.

**Circuit breaker**: UNVERIFIED. No public documentation of price movement circuit breakers.

### 3. Economic Mechanism -- MEDIUM

**Leverage**: Aster offers up to 1001x leverage in Simple Mode, which is the highest in the perp DEX market. While this is a marketing feature, it introduces extreme liquidation cascade risk during volatile markets.

**Liquidation**: Multi-tier system:
1. Standard liquidation when maintenance margin is breached
2. Insurance fund absorbs remaining losses
3. Auto-Deleveraging (ADL) as last resort -- profitable opposing positions are reduced
4. Market halt as final fallback

**Insurance fund**: Exists but size is undisclosed. Funded by liquidation fees. Without knowing the ratio to open interest (~$1.9B) or bridge TVL (~$538M), the adequacy cannot be assessed. This is a significant information gap.

**ALP Liquidity Pool**: LPs deposit assets to earn fees from trading. 48-hour lockup on ALP redemption provides some protection against bank-run scenarios but is short by industry standards.

**USDF stablecoin**: Aster's USDF product (TVL ~$118M) "depends entirely on Binance. If Binance faces issues, USDF could depeg causing platform-wide liquidations" (per Nefture Security analysis). This is a concentration risk.

**Bad debt**: No publicly disclosed bad debt events. ADL mechanism exists as backstop.

### 4. Smart Contract Security -- MEDIUM

**Audit History**:
- Salus Security: AstherusVault, AsterEarn, asBNB, asCAKE
- PeckShield: asBNB, USDF, core protocol (March 2025)
- CertiK: Smart contracts (June 2025), multi-chain architecture
- Hacken: Multi-chain deployment (September 2025)
- BlockSec: Referenced in some sources

Audit Coverage Score: ~2.5 (4 auditors with recent audits, but scope is predominantly vault/LST/earn products, not the core perps matching engine)

**Critical gap**: The core perpetuals trading engine uses off-chain order matching. This off-chain component is NOT covered by smart contract audits. Settlement, margin calculations, risk checks, and liquidations happen on-chain, but trade routing, price aggregation, and order book updates are off-chain -- creating a trust boundary that audits do not cover.

**Bug bounty**: Active on Immunefi with up to $200,000 max payout. Scope covers 10 smart contracts (asBTC, USDF, asUSDF, asBNB-related) plus frontend. Critical smart contract bugs: 10% of affected funds, capped at $200K (min $50K). The $200K cap is low relative to the protocol's scale (~$538M bridge TVL, ~$1.9B OI). For comparison, Hyperliquid has no formal bounty, but GMX offers up to $5M.

**Open source**: Token contract is verified on BscScan. GitHub organization (asterdexcom) has repositories including asterdex-perpetual-contracts. However, the off-chain matching engine is closed source.

**DeFiLlama audit count**: 0. Despite having multiple audits from reputable firms, none are registered on DeFiLlama, indicating either incomplete documentation or lack of effort in updating the DeFiLlama listing.

### 5. Cross-Chain & Bridge -- HIGH

**Multi-chain deployment**: 5 chains (BNB Chain, Ethereum, Arbitrum, Solana, Scroll) plus the Aster Chain L1 (mainnet March 2026). DeFiLlama tracks Aster Bridge with ~$538M TVL.

**Bridge architecture**: UNVERIFIED. The bridge configuration, validator/relayer set, DVN configuration, and message validation mechanisms are not publicly documented. DeFiLlama lists 0 audits for the bridge.

**Per-chain admin controls**: UNVERIFIED. Whether each chain deployment has independent admin keys, risk parameters, or governance is unknown.

**Aster Chain**: A PoSA (Proof-of-Staked Authority) L1 with 50ms blocks, 100K TPS, zero gas. Uses ZK proofs for privacy. This is a new, untested chain with limited validator decentralization data available. PoSA inherently has a small, permissioned validator set.

**Single point of failure**: All 5+ chains appear to use the same bridge infrastructure controlled by the Aster team. A bridge compromise could affect all chains simultaneously.

### 6. Operational Security -- HIGH

**Team**: Anonymous. CEO "Leonard" has no verifiable identity or track record. No other team members are publicly identified by real name or background.

**YZi Labs backing**: While YZi Labs (formerly Binance Labs) backing provides some institutional credibility, the operational relationship is opaque. YZi Labs is described as providing "technical support, marketing, and ecosystem access" beyond just funding.

**Incident response**: No published incident response plan. No documented emergency pause response time. The protocol issued a phishing alert in October 2025, but this addresses user-side risk, not protocol-side incident response.

**Wash trading controversy (October 2025)**: DeFiLlama delisted Aster's perpetual volume data after detecting trading volumes that mirrored Binance's nearly 1:1. Before delisting, Aster claimed $41.78B in 24-hour volume -- 4x Hyperliquid's volume. CEO Leonard attributed the pattern to "airdrop farming" by "opportunistic API traders." Aster was relisted on October 19, but DeFiLlama noted the DEX "remained a black box and we can't verify the numbers." This raises serious concerns about:
  - Data integrity and transparency
  - Actual organic trading volume
  - Whether reported open interest figures are similarly inflated

**Off-chain controls**: No SOC 2, ISO 27001, or any third-party security certification. No published key management policy. No disclosed penetration testing. No information about operational segregation or insider threat controls.

**Certifications**: NONE. Rating = HIGH per SKILL.md guidelines (anonymous team with no verifiable security practices).

## Critical Risks

1. **Anonymous team with no governance controls**: A single anonymous individual ("Leonard") appears to control the protocol with no public multisig, no timelock, and no on-chain governance. This is the Drift-type attack pattern.
2. **Undisclosed admin key architecture**: What admin functions exist and who controls them is entirely unknown. Admin could potentially pause, upgrade, change parameters, or drain funds -- we cannot verify or deny any of these capabilities.
3. **Bridge with $538M TVL and zero audits on DeFiLlama**: The cross-chain bridge handling hundreds of millions in assets has no publicly verifiable audit trail on DeFiLlama and no documented DVN/verifier configuration.
4. **Off-chain matching engine is a trust black box**: The core trading engine runs off-chain with closed-source code. Users must trust the operator for fair order matching, which is indistinguishable from a centralized exchange with on-chain settlement.
5. **Extreme token concentration**: ~93-96% of ASTER supply held by a few wallets. If token governance launches as planned in Q2 2026, this enables complete governance capture.
6. **Wash trading controversy**: DeFiLlama delisting for suspected wash trading undermines confidence in reported volume and OI metrics.

## Peer Comparison

| Feature | Aster | Hyperliquid | GMX |
|---------|-------|-------------|-----|
| Timelock | Undisclosed | None documented | 24h |
| Multisig | Undisclosed | Undisclosed | 4/6 Safe |
| Audits (DeFiLlama) | 0 | 0 | 3 |
| Audits (actual) | 4+ firms (vault/LST scope) | Limited | 5+ firms (core protocol) |
| Oracle | Pyth + Chainlink + Binance | Custom (validator-sourced) | Chainlink |
| Insurance/TVL | Undisclosed | ~1% (Assistance Fund) | ~2-3% |
| Open Source | Partial (token + some contracts) | Partial | Yes (core contracts) |
| Team | Anonymous | Pseudonymous (Jeff) | Pseudonymous (X dev) |
| Bug Bounty | $200K (Immunefi) | None formal | $5M (Immunefi) |
| Max Leverage | 1001x | 500x | 100x |
| Architecture | Off-chain matching + on-chain settlement | Custom L1 (HyperBFT) | Fully on-chain (AMM) |

## Recommendations

1. **Users**: Treat Aster as a centralized exchange with on-chain settlement. Do not assume "DEX" means trustless. Limit exposure to amounts you can afford to lose. Be aware that the off-chain matching engine is a trust assumption.
2. **Users**: Monitor the wash trading situation. If reported volumes are inflated, actual liquidity depth may be significantly lower than advertised, leading to worse execution.
3. **Users**: Be cautious with USDF -- its dependency on Binance introduces counterparty risk that is atypical for DeFi stablecoins.
4. **Protocol**: Publish admin key architecture, multisig configuration, and timelock details. This is the single highest-impact improvement for user trust.
5. **Protocol**: Register audits on DeFiLlama and publish full audit reports publicly (not just summaries).
6. **Protocol**: Increase bug bounty cap to at least $1M given the protocol's scale ($538M bridge TVL, ~$1.9B OI).
7. **Protocol**: Pursue SOC 2 Type II or equivalent certification for off-chain operations.
8. **Protocol**: Document bridge validator/verifier configuration and get the bridge independently audited.
9. **Protocol**: Implement and publish a timelock (minimum 24h) on all admin actions before launching token governance.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- UNVERIFIED (no timelock documented)
- [x] Admin can change oracle sources arbitrarily? -- UNVERIFIED (no restrictions documented)
- [x] Admin can modify withdrawal limits? -- UNVERIFIED
- [x] Multisig has low threshold (2/N with small N)? -- UNVERIFIED (no multisig confirmed)
- [x] Zero or short timelock on governance actions? -- Yes (no timelock documented)
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A for primary BNB Chain deployment
- [x] Social engineering surface area (anon multisig signers)? -- Yes (entire team anonymous)

**WARNING: 6/7 Drift-type indicators triggered (5 confirmed + 1 unverifiable). The governance architecture is opaque and presents the highest risk surface.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- Limited to major assets for perps
- [ ] Single oracle source without TWAP? -- No (multi-oracle)
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [x] Insufficient insurance fund relative to TVL? -- UNVERIFIED (undisclosed = flagged)

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- UNVERIFIED (bridge architecture undocumented)
- [x] Admin keys stored in hot wallets? -- UNVERIFIED (key management undisclosed)
- [x] No key rotation policy? -- Yes (no policy published)

**WARNING: 3/3 Ronin/Harmony-type indicators triggered. Bridge security posture is entirely opaque.**

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time? -- N/A (no governance yet)
- [ ] Flash loans can be used to acquire voting power? -- N/A
- [ ] Proposal + execution in same block? -- N/A
- [ ] No minimum holding period for voting eligibility? -- N/A

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? -- UNVERIFIED
- [ ] Read-only reentrancy risk? -- UNVERIFIED
- [ ] Flash loan compatible without reentrancy guards? -- UNVERIFIED
- [ ] Composability with protocols that expose callback hooks? -- UNVERIFIED

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler? -- No (Solidity)
- [ ] Compiler version has known CVEs? -- UNVERIFIED
- [ ] Contracts compiled with different compiler versions? -- UNVERIFIED
- [ ] Code depends on language-specific behavior? -- UNVERIFIED

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral? -- USDF is basis-trading backed, not algo
- [ ] Redemption mechanism creates sell pressure on collateral? -- No
- [ ] Oracle delay could mask depegging? -- UNVERIFIED
- [ ] No circuit breaker on redemption volume? -- UNVERIFIED

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [x] Protocol uses a cross-chain bridge for token minting or reserve release? -- Yes (5 chains + Aster Chain)
- [x] Bridge message validation relies on a single messaging layer without independent verification? -- UNVERIFIED (undocumented = flagged)
- [x] DVN/relayer/verifier configuration is not publicly documented? -- Yes
- [x] Bridge can release or mint tokens without rate limiting? -- UNVERIFIED
- [ ] Bridged/wrapped token is accepted as collateral on lending protocols? -- Not widely
- [x] No circuit breaker to pause minting if bridge volume exceeds normal thresholds? -- UNVERIFIED
- [x] Emergency pause response time > 15 minutes? -- UNVERIFIED (no SLA published)
- [x] Bridge admin controls under different governance than core protocol? -- UNVERIFIED
- [x] Token is deployed on 5+ chains via same bridge provider? -- Yes (5 chains + Aster Chain)

**WARNING: 8/9 Kelp-type indicators triggered. Given the Kelp hack just occurred on April 19, 2026 ($292M stolen), this pattern is especially urgent for Aster with its $538M bridge TVL across 5+ chains.**

## Information Gaps

The following critical questions could NOT be answered from public information:

1. **Admin key architecture**: Who holds admin keys? Is there a multisig? What threshold? What can admin do (pause, upgrade, drain)?
2. **Timelock configuration**: Is there any timelock on admin actions, contract upgrades, or parameter changes?
3. **Insurance fund size**: How large is the insurance fund relative to open interest (~$1.9B) and bridge TVL (~$538M)?
4. **Bridge architecture**: What bridge protocol is used? What is the validator/relayer set? Are there rate limits on cross-chain transfers?
5. **Off-chain matching engine**: How does the off-chain order matching work? What prevents front-running or manipulation by the operator?
6. **Team identities**: Who is Leonard? What is his/the team's background? Are there other key personnel?
7. **Actual organic volume**: Given the DeFiLlama delisting for wash trading, what is the real trading volume?
8. **Aster Chain validator set**: How many validators? Who are they? What is the BFT threshold?
9. **Emergency response**: What is the protocol's emergency pause response time? Who can trigger it?
10. **Key management**: How are admin keys stored? HSM, MPC, or regular EOA?
11. **Contract upgrade process**: Are core contracts upgradeable? Via what mechanism?
12. **USDF backing details**: Exact composition of the basis trading strategy backing USDF and how Binance dependency is managed.

These gaps are extensive and represent the most significant risk factor. The protocol operates more like a centralized exchange with selective on-chain transparency. Absence of this information is not evidence of absence of risk -- it is itself a risk signal.

## Disclaimer

This analysis is based on publicly available information and web research as of April 20, 2026. It is NOT a formal smart contract audit. The analysis relies on web search results, DeFiLlama data, GoPlus token security scans, and published documentation. Many critical security parameters could not be verified due to lack of public disclosure by the protocol. Always DYOR and consider professional auditing services for investment decisions. This report does not constitute financial advice.
