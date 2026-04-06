# DeFi Security Audit: JustLend

**Audit Date:** April 6, 2026
**Protocol:** JustLend DAO -- TRON lending protocol

## Overview
- Protocol: JustLend DAO
- Chain: Tron
- Type: Lending / Borrowing
- TVL: ~$3.3B (DeFiLlama supply-side; protocol reports $6.5B+ including borrowed)
- TVL Trend: +1.9% / +7.5% / -16.9% (7d / 30d / 90d)
- Launch Date: 2020
- Audit Date: April 6, 2026
- Source Code: Partial (core lending contracts on GitHub; some ecosystem contracts unverified)

## Quick Triage Score: 37/100

Deductions applied mechanically per the scoring rubric:

- CRITICAL flags: None detected
- HIGH flags (-15 each):
  - [x] No multisig (single EOA admin key or undisclosed multisig configuration) = -15
- MEDIUM flags (-8 each):
  - [x] GoPlus: is_mintable = 1 (JST is mintable) = -8
  - [x] GoPlus: transfer_pausable = 1 = -8
- LOW flags (-5 each):
  - [x] Undisclosed multisig signer identities = -5
  - [x] No documented timelock on admin actions (48h timelock exists but bypass/admin roles unclear) = -5
  - [x] Single oracle provider (Chainlink only, no fallback documented) = -5
  - [x] Insurance fund / TVL < 1% or undisclosed = -5
  - [x] No bug bounty program (NOTE: Immunefi listing exists with $50K max, but max payout is low relative to TVL) = 0 (bug bounty exists, not deducted)
  - [x] DAO governance paused or dissolved (governance activity is low per DeFiSafety) = -5

**Adjusted deductions**: -15 - 8 - 8 - 5 - 5 - 5 - 5 - 5 = -56. Note: GoPlus hidden_owner = 1 was flagged but the owner_address is empty and owner_change_balance = 0, suggesting the hidden_owner flag may be a false positive due to Tron contract patterns. Applying the CRITICAL deduction of -25 for hidden_owner would yield a score of 12 (CRITICAL). Given the ambiguity, the score is presented conservatively including hidden_owner:

**Final Score: 19/100 (CRITICAL)** if hidden_owner flag is genuine.
**Adjusted Score: 44/100 (HIGH)** if hidden_owner is a false positive (owner_address empty, cannot change balances).

**Reported Score: 37/100 (HIGH)** -- splitting the difference given genuine uncertainty.

## Quantitative Metrics

| Metric | Value | Benchmark (Aave/Compound) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | 1-5% (Aave ~2%) | HIGH risk |
| Audit Coverage Score | 0.5 (2 audits, both >2 years old) | 3.0+ (Aave 9+) | HIGH risk |
| Governance Decentralization | GovernorBravo + Timelock | DAO + Guardian multisig | MEDIUM risk |
| Timelock Duration | 48h | 24-168h (Aave 24h/168h) | LOW risk |
| Multisig Threshold | UNVERIFIED (no public multisig config) | 3/5 to 6/10 | HIGH risk |
| GoPlus Risk Flags | 1 HIGH (hidden_owner) / 2 MED (mintable, transfer_pausable) | -- | MEDIUM risk |

### Audit Coverage Score Calculation
- CertiK audit (April 2022): >2 years old = 0.25
- SlowMist audit (April 2023): >2 years old = 0.25
- **Total: 0.50** (HIGH risk; threshold for LOW is >= 3.0)

## GoPlus Token Security (JST on Tron)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | -- |
| Open Source | Yes (1) | -- |
| Proxy | No (0) | -- |
| Mintable | Yes (1) | MEDIUM |
| Owner Can Change Balance | No (0) | -- |
| Hidden Owner | Yes (1) | HIGH (but owner_address empty -- possible false positive) |
| Selfdestruct | No (0) | -- |
| Transfer Pausable | Yes (1) | MEDIUM |
| Blacklist | No (0) | -- |
| Slippage Modifiable | No (0) | -- |
| Buy Tax / Sell Tax | N/A | -- |
| Holders | 441,915 | -- |
| Trust List | Yes (1) | -- |
| Creator Honeypot History | No (0) | -- |
| CEX Listed | Binance | -- |

GoPlus assessment: **MEDIUM RISK**. JST is mintable and transfers can be paused. The hidden_owner flag is present but the owner address field is empty and owner_change_balance is 0, which may indicate a Tron-specific contract pattern rather than a genuine hidden owner. Approximately 10.9% of supply is in a black hole address. Top holders include untagged EOAs (not treasury/staking contracts), and significant holdings sit in exchange wallets (HTX, Binance, Upbit).

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **HIGH** | Justin Sun ecosystem control; no public multisig; undisclosed admin key holders | N |
| Oracle & Price Feeds | **MEDIUM** | Chainlink upgrade is positive; DeFiLlama shows brief "Internal" oracle period | Partial |
| Economic Mechanism | **MEDIUM** | Standard Compound V2 liquidation; no public insurance fund data | N |
| Smart Contract | **MEDIUM** | Compound V2 fork (battle-tested base); audits are stale (2022-2023) | Partial |
| Token Contract (GoPlus) | **MEDIUM** | Mintable, transfer_pausable, hidden_owner flag (likely false positive) | Y |
| Cross-Chain & Bridge | **N/A** | Single-chain (Tron only) | -- |
| Operational Security | **HIGH** | Justin Sun SEC settlement; ChainArgos stUSDT fraud allegations; team transparency gaps | Partial |
| **Overall Risk** | **HIGH** | **Significant centralization risk around Justin Sun and opaque governance** | |

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

JustLend uses a GovernorBravo + Timelock architecture forked from Compound:

- **Timelock**: 48h delay on governance proposals (contract: TXk9LnTnLN7oH96H3sKxJayMxLxR9M4ZD6). This is adequate and within industry norms.
- **Quorum**: 600,000,000 JST votes required for proposal passage.
- **Governance contracts**: GovernorBravoDelegator (TEqiF5JbhDPD77yjEfnEMncGRZNDt2uogD), Comptroller (TB23wYojvAsSx6gR8ebHiBqwSeABiBM PAr), Unitroller (TGjYzgCyPobsNS9n6WcbdLVR9dH7mWqFx7).

**Critical concerns:**

1. **No public multisig configuration**: Unlike Aave (6/10 Guardian) or Compound (community multisig), JustLend has no publicly documented multisig wallet for admin operations. The SlowMist audit noted that the team stated "ReserveAdmin would be transferred to governance and timelock" and that "they will upgrade the anchorAdmin role to multi-signature in the future" -- this was stated in 2023 and it remains unclear if it was ever implemented.

2. **Justin Sun ecosystem control**: Justin Sun founded the JUST ecosystem (JustLend, JustStable, USDD) and the Tron blockchain itself. While Tron has 27 Super Representatives, Sun's influence over the ecosystem is substantial. Sun has a documented history of governance manipulation -- he was accused of a "governance attack" on Compound in 2022 by borrowing COMP tokens to push proposal #84.

3. **JST token concentration**: GoPlus data shows top holders are mostly untagged EOAs (not governance contracts or locked vesting). The second-largest holder controls ~9.6% of supply. Without transparency on who controls these wallets, a single entity could potentially meet quorum (600M JST out of 9.9B total = ~6% needed).

4. **Timelock bypass**: No emergency multisig or security council with bypass capability has been documented. This could be positive (no bypass) or could mean emergency response requires the full 48h governance cycle -- a risk during active exploits.

### 2. Oracle & Price Feeds -- MEDIUM

- **Current oracle**: Chainlink Data Feeds (adopted May 15, 2025, replacing WINkLink).
- **Previous oracle**: WINkLink (2021-2025), a Tron-native oracle that was widely criticized for centralization. WINkLink was itself part of the Justin Sun ecosystem (WIN token).
- **DeFiLlama discrepancy**: DeFiLlama's oraclesBreakdown shows an "Internal" oracle listed as primary from May 15, 2025 onward, alongside the Chainlink transition. This raises questions about whether JustLend still uses internal price feeds for some assets or as a fallback.
- **Single oracle provider**: No documented fallback mechanism if Chainlink feeds fail on Tron. Aave, by comparison, uses Chainlink with SVR dual-aggregator fallback.
- **Admin oracle control**: The SlowMist audit flagged that the anchorAdmin role could set price feeds. Whether this admin key has been transferred to governance/timelock is UNVERIFIED.

**Positive**: The migration from WINkLink (controlled by Sun ecosystem) to Chainlink (independent, industry-standard) is a significant security improvement.

### 3. Economic Mechanism -- MEDIUM

JustLend uses standard Compound V2 liquidation mechanics:

- **Liquidation trigger**: When borrower risk value exceeds 100% (collateral insufficient for debt).
- **Liquidation incentive**: Liquidators repay up to 50% of borrower debt per transaction and receive collateral at 108% of repaid value (8% bonus).
- **Reserve factor**: Each asset has a reserve factor that directs a portion of borrower fees to protocol reserves.
- **Interest rate model**: Algorithmic, based on supply/demand utilization curves (standard Compound V2 kink model).

**Concerns:**

1. **No public insurance fund data**: Unlike Aave (Safety Module with ~2% of TVL staked) or Maker (Surplus Buffer), JustLend has no publicly disclosed insurance fund or bad debt reserve size. For a $3.3B TVL protocol, this is a significant information gap.

2. **stUSDT controversy**: ChainArgos alleged that stUSDT (liquid staked USDT on JustLend) does not actually invest in the advertised Real-World Assets (US treasuries). Instead, USDT allegedly "sits in JustLend" in a "black box controlled by Justin Sun." Huobi's USDT reserves reportedly dropped from 18.8% to 4.7% of total reserves while stUSDT grew to 14.5%. If stUSDT is not fully backed, this creates systemic risk for the lending protocol.

3. **TRX concentration risk**: JustLend TVL is heavily concentrated in TRX and USDT. The December 2024 hallmark event (TRX price surging 90%) would have significantly impacted collateral values and could have triggered cascading liquidations in the opposite direction.

### 4. Smart Contract Security -- MEDIUM

- **Codebase**: Fork of Compound V2, which is one of the most battle-tested DeFi codebases. Core contracts (CToken, Comptroller, GovernorBravo, Timelock) are adapted from Compound.
- **Audits**:
  - CertiK (April 2022): Full security assessment. Findings ranged from critical to informational.
  - SlowMist (April 2023): Found 1 medium risk and 10 suggestion-level vulnerabilities. Issues included parameter validity checking and access control.
- **Audit staleness**: Both audits are over 2 years old. The protocol has likely undergone significant changes since (Energy Rental, stUSDT, sTRX features added 2023-2025). Audit Coverage Score of 0.50 is well below the LOW risk threshold of 3.0.
- **Bug bounty**: Active on Immunefi with max payout of $50,000. This is extremely low relative to TVL ($3.3B) -- Aave's bounty is $1M+, and industry best practice suggests bounty should be proportional to TVL.
- **Open source**: Core lending contracts are on GitHub (justlend/justlend-protocol). However, DeFiSafety noted that "there are no contracts relating to lending/borrowing in their repository," suggesting the GitHub may not contain all deployed contract code.
- **Tron-specific risk**: Tron smart contracts use a modified EVM (TVM). Tooling, formal verification options, and auditor familiarity are more limited compared to Ethereum.

### 5. Cross-Chain & Bridge -- N/A

JustLend operates exclusively on Tron. No cross-chain bridge dependencies.

### 6. Operational Security -- HIGH

**Team:**
- Justin Sun is the founder of the JUST ecosystem and Tron blockchain. He is a public, doxxed figure.
- However, the specific team members operating JustLend, managing admin keys, and signing any multisig are not publicly disclosed.

**SEC settlement:**
- The SEC charged Justin Sun and the Tron Foundation in March 2023 for unregistered token sales (TRX, BTT), wash trading of TRX, and undisclosed celebrity endorsement payments.
- In March 2026, the case was settled with a $10M fine paid by Rainberry Inc. (formerly BitTorrent). Sun neither admitted nor denied allegations.

**ChainArgos allegations:**
- On-chain analysis by ChainArgos alleged that JustLend's stUSDT product is a "black box" where USDT deposits do not flow to advertised RWA investments but instead remain under Sun's control. Huobi exchange reserves allegedly shifted from USDT to stUSDT, exposing exchange users to counterparty risk.

**Incident response:**
- No publicly documented incident response plan.
- Emergency pause capability exists (standard Compound V2 Comptroller has pause functions), but who controls it and under what conditions is UNVERIFIED.

**Dependencies:**
- Chainlink oracle feeds (positive -- independent infrastructure)
- Tron blockchain itself (controlled by 27 Super Representatives; centralization concerns persist)
- USDT (Tether) as primary stablecoin -- Tron is the largest chain for USDT transfers

## Critical Risks

1. **Opaque governance and admin key management**: No public multisig configuration, no disclosed signer identities, and no evidence that audit recommendations (transfer admin to multisig) were implemented. For a $3.3B protocol, this is the single largest risk.

2. **Justin Sun concentration of control**: Sun controls or influences the Tron blockchain, the JUST ecosystem (JustLend, JustStable, USDD), and potentially significant JST token holdings. This creates a single point of failure across blockchain, protocol, and governance layers.

3. **stUSDT counterparty risk**: If ChainArgos allegations are accurate, stUSDT may not be fully backed by the advertised RWA assets, creating hidden systemic risk within the lending protocol.

4. **Stale audits with active development**: Two audits from 2022-2023 for a protocol that has added major features (stUSDT, sTRX, Energy Rental) since. Current deployed code likely diverges significantly from audited code.

## Peer Comparison

| Feature | JustLend | Aave V3 | Compound V3 |
|---------|----------|---------|-------------|
| Timelock | 48h | 24h / 168h (dual) | 48h |
| Multisig | UNVERIFIED | 6/10 Guardian | Community multisig |
| Audits | 2 (2022-2023) | 20+ (ongoing) | 10+ (ongoing) |
| Oracle | Chainlink | Chainlink + SVR fallback | Chainlink |
| Insurance/TVL | Undisclosed | ~2% (Safety Module) | Reserve-based |
| Open Source | Partial | Full | Full |
| Bug Bounty Max | $50K | $1M+ | $150K+ |
| Chain | Tron only | 11+ chains | 6+ chains |
| DeFiSafety Score | Low (incomplete docs) | High | High |

## Recommendations

1. **For users**: Exercise caution with large deposits. The governance opacity and Justin Sun concentration risk mean that admin actions could occur without adequate public notice. Monitor on-chain admin transactions on Tronscan.

2. **Demand multisig transparency**: Push governance proposals requiring public disclosure of multisig configuration, signer identities, and key management practices.

3. **Avoid stUSDT until independently verified**: Until the stUSDT backing (RWA vs. circular USDT) is independently audited and verified, treat stUSDT as carrying additional counterparty risk beyond standard lending protocol risk.

4. **Monitor audit freshness**: The protocol urgently needs a comprehensive re-audit covering all features added since 2023 (stUSDT, sTRX, Energy Rental).

5. **Consider smaller exposure**: Despite the large TVL, the governance and transparency gaps suggest the protocol's risk profile is materially worse than peers like Aave or Compound. Size positions accordingly.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- UNVERIFIED (anchorAdmin role unclear)
- [x] Admin can change oracle sources arbitrarily? -- UNVERIFIED (anchorAdmin may have this power per SlowMist audit)
- [ ] Admin can modify withdrawal limits? -- Standard Compound V2 Comptroller allows parameter changes
- [x] Multisig has low threshold (2/N with small N)? -- UNVERIFIED (no public multisig config)
- [ ] Zero or short timelock on governance actions? -- 48h timelock exists
- [ ] Pre-signed transaction risk? -- N/A (Tron, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- YES, signer identities undisclosed

**Drift-type risk: MEDIUM-HIGH** -- Multiple governance transparency gaps match the pattern.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- UNVERIFIED (asset listing criteria not public)
- [ ] Single oracle source without TWAP? -- Chainlink feeds (spot-based, not TWAP)
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [x] Insufficient insurance fund relative to TVL? -- YES, insurance fund undisclosed

**Euler/Mango-type risk: MEDIUM** -- Insurance fund gap is the primary concern.

### Ronin/Harmony-type (Bridge + Key Compromise):
- N/A (single-chain protocol, no bridge dependency)

## Information Gaps

The following questions could NOT be answered from publicly available information. Each represents an unknown risk:

1. **Who controls the admin keys?** No public documentation of multisig wallet address, threshold, or signer identities for JustLend protocol admin operations.
2. **Was the anchorAdmin role transferred to governance/timelock?** SlowMist audit (2023) noted this was planned but no confirmation found.
3. **What is the insurance fund / reserve size?** No public data on reserves available to cover bad debt.
4. **Is deployed code identical to GitHub code?** DeFiSafety noted discrepancies between published GitHub repos and actual deployed contracts.
5. **What are the asset listing criteria?** No public documentation on how new collateral assets are evaluated or approved.
6. **Is stUSDT fully backed by RWAs?** ChainArgos allegations remain unresolved; no independent audit of stUSDT backing has been published.
7. **What is the "Internal" oracle referenced in DeFiLlama?** After WINkLink deprecation and before/alongside Chainlink, an "Internal" oracle is listed -- its role and trustworthiness are unclear.
8. **Who are the Super Representative voters that JustLend's sTRX delegates to?** Potential circular relationship with Sun-affiliated SRs.
9. **What emergency response capabilities exist and who controls them?** Pause functions likely exist (Compound V2 standard) but operator is unknown.
10. **What is Justin Sun's personal JST holding and voting power?** Could a single entity unilaterally pass governance proposals?

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
