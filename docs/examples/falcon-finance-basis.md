# DeFi Security Audit: Falcon Finance

## Overview
- Protocol: Falcon Finance (USDf / sUSDf / FF)
- Chain: Ethereum
- Type: Basis Trading / Synthetic Dollar (overcollateralized + basis trade yield)
- TVL: ~$1.63B
- TVL Trend: -0.3% / +0.3% / -6.5% (7d / 30d / 90d)
- Launch Date: February 19, 2025
- Audit Date: April 6, 2026
- Source Code: Partial (audited contracts, but not all code publicly verifiable on-chain)

## Quick Triage Score: 37/100

Starting at 100, the following deductions apply:

CRITICAL flags:
- None detected from GoPlus

HIGH flags (-15 each):
- (-15) Anonymous multisig signers -- internal Falcon Finance members only, identities undisclosed
- (-15) No bug bounty program on Immunefi or comparable platform

MEDIUM flags (-8 each):
- (-8) `is_proxy = 1` on USDf AND no documented timelock on upgrades
- (-8) Protocol age < 6 months at time of reaching $50M+ TVL (launched Feb 2025, hit $1B+ TVL within months)
- (-8) Multisig threshold undisclosed -- specific M/N configuration not public

LOW flags (-5 each):
- (-5) No documented timelock on admin actions
- (-5) No bug bounty program
- (-5) Insurance fund / TVL at ~0.61% ($10M / $1.63B) -- well below 1% threshold
- (-5) Undisclosed multisig signer identities
- (-5) DAO governance effectively non-existent (FF token governance not yet operational in practice)

Score: 100 - 15 - 15 - 8 - 8 - 8 - 5 - (already counted) - 5 - 5 - 5 = 37

Note: Several GoPlus fields for USDf returned incomplete data (is_honeypot, hidden_owner, owner_change_balance, selfdestruct, is_mintable, transfer_pausable, is_blacklisted, slippage_modifiable not returned). The USDf token is a proxy contract with open source code. The FF governance token returned clean results.

Score meaning: 20-49 = **HIGH** risk.

## Quantitative Metrics

| Metric | Value | Benchmark (Ethena) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | ~0.61% ($10M / $1.63B) | ~1.18% ($77M / $6.6B) | HIGH |
| Audit Coverage Score | 1.75 | 3.25 | MEDIUM |
| Governance Decentralization | Centralized team control | Multisig + Governance Forum | HIGH |
| Timelock Duration | UNDISCLOSED | Present (UNVERIFIED hrs) | HIGH |
| Multisig Threshold | UNDISCLOSED (MPC + multisig) | 7/10 | HIGH |
| GoPlus Risk Flags (FF token) | 0 HIGH / 0 MED | -- | LOW |
| GoPlus Risk Flags (USDf) | INCOMPLETE DATA (proxy) | -- | MEDIUM |

**Audit Coverage Score Calculation:**
- Pashov (Feb 2025): ~1.1yr old = 0.5
- Zellic (Mar 2025): ~1yr old = 1.0
- Zellic FF token (Sep 2025): <1yr old = 1.0
- Harris & Trotter reserve audit (Oct 2025): reserve attestation, not code = 0 (excluded)
- Weekly HT.Digital attestations: attestation, not code = 0 (excluded)
- Total code audit score: 1.75 (MEDIUM risk threshold: 1.5-2.99, but barely above HIGH)
- Note: Only 2 firms (Zellic, Pashov) have audited the smart contracts

## GoPlus Token Security

### FF Governance Token (0xfa1c09fc8b491b6a4d3ff53a10cad29381b3f949)

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
| Holders | 10,979 | -- |
| Trust List | N/A | -- |
| Creator Honeypot History | No | -- |

FF token top holder concentration: Top 3 holders (all contracts) control ~73.98% of total supply. The largest holder at 29.98% and second at 24.00% are likely team/vesting/treasury contracts. High concentration but expected for a recently launched governance token.

### USDf Token (0xFa2B947eEc368f42195f24F36d2aF29f7c24CeC2)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | NOT RETURNED | UNKNOWN |
| Open Source | Yes | -- |
| Proxy | Yes (EIP-1967) | MEDIUM |
| Mintable | NOT RETURNED | UNKNOWN |
| Owner Can Change Balance | NOT RETURNED | UNKNOWN |
| Hidden Owner | NOT RETURNED | UNKNOWN |
| Selfdestruct | NOT RETURNED | UNKNOWN |
| Transfer Pausable | NOT RETURNED | UNKNOWN |
| Blacklist | NOT RETURNED | UNKNOWN |
| Slippage Modifiable | NOT RETURNED | UNKNOWN |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 7,064 | -- |
| Trust List | N/A | -- |
| Creator Honeypot History | No | -- |

USDf top holder concentration: Top 5 holders (mostly EOAs, not contracts) control ~59.7% of supply. Notably, 4 of the top 5 holders are EOAs (not smart contracts), which is unusual for a $1.6B stablecoin -- this suggests concentrated whale/institutional holdings or team-controlled wallets. The sUSDf staking contract holds only ~5.79% of USDf supply.

GoPlus assessment: The FF governance token is **LOW RISK** with clean results across all checks. The USDf token returned **INCOMPLETE DATA** -- many critical fields were not returned by GoPlus, likely because the proxy contract structure complicates automated analysis. The proxy architecture itself is a MEDIUM risk factor given the lack of publicly documented timelock on upgrades.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **HIGH** | Centralized team control, undisclosed multisig config, no public timelock | N |
| Oracle & Price Feeds | **MEDIUM** | Internal pricing for basis trades; no documented oracle architecture | N |
| Economic Mechanism | **HIGH** | Basis trade/funding rate risk, 7-day redemption delay, prior depeg to $0.94, thin insurance fund | Partial |
| Smart Contract | **MEDIUM** | Upgradeable proxy, 2 audit firms, no bug bounty, limited battle testing | Partial |
| Token Contract (GoPlus) | **MEDIUM** | FF token clean; USDf proxy with incomplete GoPlus data | Partial |
| Cross-Chain & Bridge | **LOW** | Single-chain (Ethereum) primary; Base deployment announced but not yet material | N |
| Operational Security | **HIGH** | DWF Labs affiliation raises counterparty/reputational risk; prior depeg event; KYC-gated redemptions | Partial |
| **Overall Risk** | **HIGH** | **Centralized control, DWF Labs counterparty risk, prior depeg, thin insurance fund, and significant information gaps** | |

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Multisig Configuration:**
- Falcon Finance states it uses "multisig access control" and MPC wallet infrastructure
- The specific M/N threshold (e.g., 3/5, 4/7) is NOT publicly documented -- UNVERIFIED
- Multisig signers are described as "internal Falcon Finance members" -- no external signers disclosed
- No signer identities are public -- UNVERIFIED
- MPC technology ensures no single key exposure during transactions, but the trust model remains centralized to the Falcon team

**Admin Powers:**
- Admin can mint USDf against deposited collateral (minting is KYC-gated)
- Admin controls which assets are accepted as collateral -- the acceptance of low-cap altcoins (e.g., DOLO) was a factor in the July 2025 depeg
- Admin controls reserve deployment into yield strategies (basis trades, funding rate arb, cross-exchange spreads)
- Admin controls the $10M insurance fund via a multi-signature address comprising internal members only
- USDf is an upgradeable proxy (EIP-1967) -- the upgrade authority and timelock configuration are NOT publicly documented

**Timelock:**
- No public documentation of any timelock on admin actions, contract upgrades, or parameter changes
- This is a significant gap: with $1.6B TVL, the absence of a documented timelock means the team could theoretically upgrade contracts or change parameters without advance notice

**Governance Process:**
- FF token holders are granted "on-chain governance rights" per the whitepaper (September 2025)
- In practice, no evidence of active on-chain governance proposals or votes as of April 2026
- Governance appears to be entirely team-directed at present -- UNVERIFIED
- FF token launched September 29, 2025 -- governance infrastructure may still be in development

**Token Concentration (FF):**
- Top 3 holders (all contracts, likely treasury/vesting) control ~74% of supply
- Given 10B total supply with most locked in contracts, effective governance voting power is highly concentrated
- A single entity (DWF Labs/Falcon team) likely controls majority voting power -- UNVERIFIED

### 2. Oracle & Price Feeds -- MEDIUM

**Oracle Architecture:**
- No public documentation of which oracle providers Falcon Finance uses for pricing collateral or managing basis trade positions
- The protocol relies on internal pricing for derivatives positions across centralized exchanges
- No documented fallback mechanism if an oracle or exchange API fails
- Admin ability to change oracle sources is UNVERIFIED

**Collateral Screening:**
- Falcon claims "only assets that pass rigorous liquidity, volatility, and market-depth tests are accepted"
- However, during the July 2025 depeg, criticism focused on acceptance of low-cap tokens like DOLO as collateral, contradicting the stated standards
- The criteria for collateral acceptance and who makes the decision are not transparent

**Price Manipulation Resistance:**
- No documented circuit breaker for abnormal price movements
- No documented TWAP or multi-source oracle aggregation
- Basis trade positions depend on exchange-provided prices -- vulnerable to exchange-specific manipulation or outages

### 3. Economic Mechanism -- HIGH

**Basis Trade Strategy:**
- Similar to Ethena's delta-neutral approach but with broader collateral acceptance
- Strategies include: funding rate arbitrage, cross-exchange spread arbitrage, native staking rewards
- Yield is distributed to sUSDf holders through the staking rewards distributor contract
- Claimed APY historically exceeded 20% -- high yields from basis trades raise sustainability questions

**Funding Rate Risk:**
- Like Ethena, Falcon is exposed to prolonged negative funding rates during bear markets
- When funding rates turn negative, the protocol pays rather than earns
- The $10M insurance fund provides extremely thin coverage (~0.61% of TVL)
- By comparison, Ethena's reserve fund is 1.18% of TVL and that is already considered below the 5% healthy threshold

**July 2025 Depeg Incident:**
- On July 8, 2025, USDf depegged to approximately $0.94 (some sources report as low as $0.887)
- Triggered by allegations of bad debt, illiquid collateral, and unsustainable yield strategies
- Key issues identified:
  - Acceptance of low-liquidity altcoin collateral (DOLO)
  - Lack of transparency in reserve composition and strategy execution
  - Centralized reserve management with no independent oversight at the time
  - Reports that USDf was minted against collateral that did not match required market value
- Recovery involved: team pledging asset breakdowns, withdrawing funds from CEXs, securing $10M WLFI investment, launching transparency dashboard
- The depeg demonstrated that the protocol's redemption mechanism (7-day cooldown, whitelisted users only) is insufficient to defend the peg during a confidence crisis

**Redemption Mechanism:**
- 7-day mandatory cooldown period on all redemptions
- Redemption only available to KYC-verified users
- Non-KYC users must rely on secondary market liquidity (DEX pools with ~$575K total liquidity on Uniswap)
- The 7-day delay is significantly longer than Ethena's process and creates extended depeg exposure
- During stress, this delay prevents rapid arbitrage that would normally restore the peg

**Insurance Fund:**
- $10M insurance fund established August 28, 2025 (post-depeg)
- Held in a multi-signature address controlled by internal Falcon Finance members only
- At 0.61% of TVL, this is well below the 1% concerning threshold
- Funded by a portion of monthly protocol revenue -- growth rate is UNVERIFIED

**Overcollateralization:**
- Protocol claims 105% backing ratio as of latest transparency dashboard
- Harris & Trotter LLP quarterly attestation (October 2025) confirmed 103.87% reserves-to-liabilities
- Overcollateralization is thin: only 3-5% excess above liabilities
- For volatile altcoin collateral, this margin may be insufficient during rapid drawdowns

### 4. Smart Contract Security -- MEDIUM

**Audit History:**
- Pashov Audit Group (February 2025): no critical/high findings
- Zellic (March 2025, assessment period Feb 11-17, 2025): no critical/high findings
- Zellic (September 2025, FF token assessment): no critical/high findings
- Only 2 audit firms have reviewed the code -- limited diversity of auditor perspectives
- All audits are 6-12+ months old; code may have changed since

**Bug Bounty:**
- No active bug bounty program found on Immunefi or any other platform
- This is a significant gap for a protocol with $1.6B TVL
- By comparison, Ethena has a $3M maximum bounty on Immunefi

**Battle Testing:**
- Protocol live since February 2025 (~14 months)
- Experienced a significant depeg event in July 2025 (5 months after launch)
- No smart contract exploits reported, but the depeg was an economic/operational failure
- Peak TVL exceeded $2.1B before declining
- USDf is an upgradeable proxy, increasing attack surface compared to immutable contracts

**Code Accessibility:**
- USDf and sUSDf contracts are verified on Etherscan (is_open_source = 1 per GoPlus)
- Implementation behind EIP-1967 proxy pattern
- Not clear if all protocol contracts (minting, strategy execution, reward distribution) are fully open source

### 5. Cross-Chain & Bridge -- LOW

- Primary deployment is Ethereum
- Falcon Finance announced deployment of USDf on Base (Coinbase L2) in 2026
- No evidence of cross-chain governance or bridge dependencies that introduce systemic risk at present
- As multi-chain expansion proceeds, bridge risk will need reassessment

### 6. Operational Security -- HIGH

**Team & Track Record:**
- Founded by Andrei Grachev, co-founder of DWF Labs and former CEO of Huobi Russia
- CEO: Shahin Tabarsi (fintech/blockchain background)
- Additional team: Artem Tolkachev (tech/blockchain), Raghav Sood (protocol design)
- Team is partially doxxed -- key figures are public, but operational team and multisig signers are not

**DWF Labs Affiliation -- Major Counterparty Risk:**
- Falcon Finance is incubated and supported by DWF Labs
- DWF Labs has faced serious allegations of market manipulation:
  - Binance internal investigation found $300M in wash trades in 2023
  - Manipulation of YGG token price and at least 6 other tokens alleged
  - Binance investigator who filed the report was fired one week later
  - DWF Labs denies all allegations, calling them "competitor-driven FUD"
- This affiliation creates reputational and counterparty risk:
  - DWF Labs provides "strategic support, funding, ecosystem growth, business and operational support"
  - If DWF Labs faces regulatory action, it could directly impact Falcon Finance operations
  - DWF Labs purchased $25M of WLFI tokens; WLFI invested $10M in Falcon -- circular funding relationships

**World Liberty Financial (WLFI) Connection:**
- Trump-affiliated WLFI invested $10M in Falcon Finance (July 2025)
- USD1 (WLFI stablecoin) to be used as collateral on Falcon Finance
- Political exposure adds regulatory uncertainty

**Custodians:**
- Assets held with: Fireblocks, Ceffu, BitGo, ChainUp
- These are established institutional custodians, which is positive
- Off-exchange settlement reduces CEX counterparty risk versus direct exchange deposits
- However, full details of custody arrangements and insurance coverage are UNVERIFIED

**Incident Response:**
- During the July 2025 depeg, the team responded by:
  - Pledging asset breakdowns publicly
  - Withdrawing all funds from CEXs
  - Securing strategic investment
  - Launching transparency dashboard and weekly attestations
  - Establishing $10M insurance fund
- Response was reactive rather than proactive -- transparency measures came only after the crisis
- No published incident response plan or formal security council

## Critical Risks

1. **Centralized Control Without Timelock (HIGH):** The protocol's USDf token is an upgradeable proxy with no publicly documented timelock on upgrades. The multisig configuration is undisclosed. A compromised or malicious admin could theoretically upgrade contracts without advance notice. With $1.6B TVL, this represents an existential risk.

2. **DWF Labs Counterparty and Reputational Risk (HIGH):** The protocol is incubated by a firm facing serious market manipulation allegations. DWF Labs provides operational support and has circular financial relationships with Falcon Finance. Regulatory action against DWF Labs could cascade to Falcon Finance.

3. **Inadequate Insurance Fund (HIGH):** The $10M insurance fund covers only ~0.61% of TVL. During the July 2025 depeg, USDf dropped to $0.94. A more severe event (sustained negative funding, custodian failure, or loss of confidence) could overwhelm the fund.

4. **7-Day Redemption Delay (HIGH):** The mandatory 7-day cooldown on all redemptions, combined with KYC gating, severely limits the protocol's ability to maintain the peg during stress events. Secondary market liquidity on Uniswap is only ~$575K -- negligible relative to $1.6B supply.

5. **Prior Depeg Event Demonstrates Structural Weakness (MEDIUM):** The July 2025 depeg was not caused by a smart contract exploit but by economic/operational failures: illiquid collateral acceptance, opaque reserve management, and inability to process rapid redemptions. While transparency has improved since, the structural redemption delay remains.

## Peer Comparison

| Feature | Falcon Finance (USDf) | Ethena (USDe) | MakerDAO (DAI/USDS) |
|---------|----------------------|---------------|---------------------|
| Timelock | UNDISCLOSED | Present (duration UNVERIFIED) | 48h (GSM) |
| Multisig | UNDISCLOSED (MPC + multisig) | 7/10 Gnosis Safe | DAO governance vote |
| Audits | 3 (Zellic x2, Pashov) | 7+ (Code4rena, Pashov, Quantstamp, Cyfrin) | 20+ |
| Oracle | UNDISCLOSED | Internal + Chainlink/Pyth | Chainlink + Maker oracles |
| Insurance/TVL | ~0.61% ($10M) | ~1.18% ($77M) | ~5%+ (Surplus Buffer) |
| Open Source | Partial (proxy verified) | Yes (GitHub) | Yes (GitHub) |
| Bug Bounty | None | $3M Immunefi | $10M+ Immunefi |
| Mechanism | Overcollateralized + basis trade | Delta-neutral hedging | Overcollateralized vaults |
| Custodian Risk | High (Fireblocks, Ceffu, BitGo, ChainUp) | High (Copper, Fireblocks, Ceffu) | Low (fully on-chain) |
| Depeg History | Yes (July 2025, ~6% depeg) | Minor (<1% deviations) | Minor (<1% deviations) |
| Redemption Delay | 7 days (KYC-gated) | Permissioned (20 whitelisted) | Permissionless instant |
| Time in Production | ~14 months | ~2.3 years | ~8+ years |

Falcon Finance compares unfavorably to both Ethena and MakerDAO across nearly all security dimensions. The most concerning gaps are: no documented timelock (Ethena and Maker both have them), no bug bounty (both peers have large bounties), and a materially thinner insurance fund with a history of actual depeg events.

## Recommendations

1. **For users holding USDf:** Understand that USDf carries higher risk than comparable synthetic dollars. The 7-day redemption delay, thin insurance fund, and DWF Labs affiliation create compounding risks. Monitor the transparency dashboard for reserve ratio changes and be aware that secondary market exit liquidity is extremely thin (~$575K on Uniswap).

2. **For sUSDf stakers:** Yields above 15-20% from basis trade strategies are not sustainable long-term. During bear markets, funding rates turn negative and the thin insurance fund provides minimal protection. The July 2025 depeg demonstrated that high yields attracted deposits that the protocol could not manage safely.

3. **For DeFi integrators:** Apply highly conservative collateral factors if accepting USDf. The 7-day redemption delay means depeg events can persist for extended periods. The prior depeg to $0.94 should inform risk parameter calibration.

4. **For the Falcon Finance team:** (a) Publish exact multisig configuration and signer identities. (b) Implement and document a timelock on contract upgrades and admin parameter changes. (c) Establish a bug bounty program proportional to TVL. (d) Increase insurance fund to at least 3-5% of TVL. (e) Consider adding external signers to the multisig and insurance fund.

5. **For all users:** The DWF Labs affiliation is a material risk factor that cannot be mitigated through protocol design alone. If DWF Labs faces regulatory enforcement, the impact on Falcon Finance operations and confidence could be severe.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- YES: the acceptance of DOLO as collateral during the depeg suggests admin has unilateral collateral listing power
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED (no documentation on oracle architecture)
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED
- [ ] Multisig has low threshold (2/N with small N)? -- UNVERIFIED (threshold not public)
- [x] Zero or short timelock on governance actions? -- YES: no timelock documented
- [ ] Pre-signed transaction risk? -- N/A (EVM, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- YES: multisig signers are anonymous internal members

### Euler/Mango-type (Oracle + Economic Manipulation):
- [x] Low-liquidity collateral accepted? -- YES: DOLO and other low-cap tokens were accepted as collateral
- [ ] Single oracle source without TWAP? -- UNVERIFIED
- [ ] No circuit breaker on price movements? -- UNVERIFIED (likely no circuit breaker)
- [x] Insufficient insurance fund relative to TVL? -- YES: 0.61% is far below the 5% threshold

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- NO (single-chain primarily)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED (MPC implies distribution but not necessarily cold storage)
- [ ] No key rotation policy? -- UNVERIFIED

**Pattern Match Assessment:** Falcon Finance matches 5 of the checklist indicators across Drift-type and Euler/Mango-type attack patterns. The combination of unilateral collateral listing, no documented timelock, anonymous multisig signers, low-liquidity collateral acceptance, and thin insurance fund creates a risk profile that mirrors the preconditions of historical DeFi exploits. The July 2025 depeg, while not an exploit, demonstrated that these structural weaknesses can lead to material loss of value.

## Information Gaps

The following questions could NOT be answered from publicly available information and represent unknown risks:

1. **Multisig threshold and signer count** -- the specific M/N configuration is not public
2. **Multisig signer identities** -- only described as "internal Falcon Finance members"
3. **Timelock configuration** -- no documentation of any timelock on contract upgrades or parameter changes
4. **Emergency bypass roles** -- whether any role can bypass admin controls for emergency actions
5. **Oracle architecture** -- which providers are used, whether fallbacks exist, how pricing is determined
6. **Collateral listing criteria** -- specific thresholds for liquidity, volatility, and market depth
7. **Strategy execution details** -- how basis trades are executed, on which exchanges, with what risk limits
8. **Insurance fund growth rate** -- what percentage of revenue is allocated and current accumulation trajectory
9. **Smart contract upgrade history** -- whether any upgrades have been performed since deployment
10. **Full list of admin-controlled parameters** -- what the admin key can modify without governance approval
11. **Custodian insurance coverage** -- whether custodian partnerships include insurance against loss/theft
12. **DWF Labs operational involvement** -- the exact scope of DWF Labs' operational control over Falcon Finance
13. **FF token governance activation timeline** -- when on-chain governance will become functional
14. **Reserve composition breakdown** -- current allocation between stablecoins, BTC, altcoins, and RWAs
15. **USDf GoPlus incomplete data** -- several critical security fields (honeypot, hidden owner, owner_change_balance, selfdestruct, mintable, pausable, blacklist) were not returned by GoPlus for the USDf proxy contract

These gaps are extensive and represent a higher degree of opacity than peer protocols like Ethena. For a protocol managing $1.6B in TVL, the lack of public documentation on governance configuration, timelock, and admin powers is a material risk signal.

## Disclaimer

This analysis is based on publicly available information and web research as of April 6, 2026. It is NOT a formal smart contract audit. The findings reflect a point-in-time assessment; DeFi protocols change frequently. Always DYOR and consider professional auditing services for investment decisions. Falcon Finance's risk profile is heavily influenced by off-chain factors (custodial arrangements, DWF Labs affiliation, basis trade strategy execution, funding rate exposure) that cannot be verified on-chain.
