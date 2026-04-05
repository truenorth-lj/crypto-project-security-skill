# DeFi Security Audit: Ethena (USDe)

**Audit Date:** April 5, 2026
**Protocol:** Ethena -- Synthetic dollar protocol (basis trading / delta-neutral)

## Overview
- Protocol: Ethena (USDe, sUSDe, USDtb, iUSDe)
- Chain: Ethereum (primary), TON (minor)
- Type: Synthetic Dollar / Basis Trading
- TVL: ~$6.64B (Ethereum: $6.635B, TON: $4.3M)
- TVL Trend: +0.3% (7d) / -0.8% (30d) / +2.3% (90d)
- Launch Date: December 2023
- Audit Date: April 5, 2026
- Source Code: Open (GitHub: ethena-labs)
- Token: ENA (governance), USDe (synthetic dollar), sUSDe (staked USDe)

## Quick Triage Score: 62/100
- Red flags found: 3
  - USDe is mintable (by design -- minting/redeeming is core mechanism)
  - Reserve fund / TVL ratio of ~1.18% is below the 5% healthy threshold
  - October 2025 depeg incident on Binance ($0.65) exposed secondary market fragility
  - Heavy reliance on centralized exchange counterparties for delta-neutral hedging

## Quantitative Metrics

| Metric | Value | Benchmark (DAI / FRAX) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | ~1.18% (~$78M) | DAI: ~3% / FRAX: ~2% | HIGH |
| Audit Coverage Score | 7 (high recency, 0.5yr) | DAI: 8+ / FRAX: 5 | LOW risk |
| Governance Decentralization | Risk Committee + multisig | DAI: full DAO / FRAX: multisig | MEDIUM |
| Timelock Duration | UNVERIFIED | DAI: 48h / FRAX: 24h | MEDIUM |
| Multisig Threshold | 7/10 (owner multisig) | DAI: DAO vote / FRAX: 3/5 | LOW risk |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW risk |

## GoPlus Token Security (USDe on Ethereum)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | No | -- |
| Mintable | Yes | MEDIUM |
| Owner Can Change Balance | No | -- |
| Hidden Owner | No | -- |
| Selfdestruct | No | -- |
| Transfer Pausable | No | -- |
| Blacklist | No | -- |
| Slippage Modifiable | No | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 45,562 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No | -- |

GoPlus assessment: **LOW RISK** at the token contract level. USDe is open source, not a proxy, has no hidden owner, no tax, no blacklist, no trading restrictions. The mintable flag is expected and by design -- USDe is minted and redeemed through Ethena's authorized minting contract. Owner address is a 7/10 Gnosis Safe multisig (0x3b0aaf6e6fcd4a7ceef8c92c32dfea9e64dc1862). Top holder (~59.8%) is a contract address (likely the sUSDe staking vault). No honeypot indicators.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | Delegated committee model; multisig details partially public; timelock specifics UNVERIFIED | Partial |
| Oracle & Price Feeds | **MEDIUM** | Relies on CEX price feeds for derivatives; no on-chain oracle manipulation risk but exchange oracle issues exposed in Oct 2025 | Partial |
| Economic Mechanism | **HIGH** | Reserve fund at 1.18% of TVL insufficient for prolonged negative funding; CEX counterparty concentration; Oct 2025 depeg stress test | Partial |
| Smart Contract | **LOW** | 7+ audits from reputable firms; $3M bug bounty; no critical findings; open source | Y |
| Token Contract (GoPlus) | **LOW** | Clean token contract; mintable by design; no honeypot or hidden owner | Y |
| Operational Security | **MEDIUM** | Doxxed founder; strong incident response (Bybit hack, Oct 2025); but CeFi dependency creates opaque risk surface | Partial |
| **Overall Risk** | **MEDIUM** | **Well-audited smart contracts offset by structural economic risks from basis trade model and CeFi dependency** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**Multisig Configuration:**
- Ethena uses a Gnosis Safe multisig (0x3b0aaf6e6fcd4a7ceef8c92c32dfea9e64dc1862) as the owner of deployed mainnet smart contracts.
- Configured as 7/10 multisig -- all keys are cold wallets per documentation.
- The multisig is dedicated to contract ownership and does not hold protocol funds.
- This threshold (70%) is strong and exceeds industry norms (typically 3/5 or 4/7).

**Governance Structure:**
- ENA token holders vote bi-annually to elect a Risk Committee.
- Risk Committee (currently in third term) includes: Blockworks Advisory, Credio (Untangled), Ethena Labs Research, Kairos Research, Llama Risk, and Steakhouse Financial.
- Decision-making is largely delegated to committees rather than direct token holder votes.
- A proposal to reduce Risk Committee from 5 voting members to 3 was submitted -- this would increase centralization risk. UNVERIFIED whether this passed.

**Timelock:**
- Ethena documentation references a "Matrix of Multisig and Timelocks" but specific timelock durations for admin actions could not be independently verified from public sources. UNVERIFIED.
- Absence of clearly published timelock durations is itself a risk signal.

**Admin Capabilities:**
- Owner multisig can modify contract parameters, set operators, update minting contracts, and manage asset approvals.
- Mint/Redeem roles are distributed across 20 addresses for high throughput.
- Delegated signer capability exists (setDelegatedSigner) allowing EOA delegation for minting.

**Key Concern:** While the 7/10 multisig threshold is strong, the delegated committee governance model and unclear timelock specifics introduce uncertainty. The signers of the multisig are not publicly identified, reducing accountability.

### 2. Oracle & Price Feeds -- MEDIUM

**Architecture:**
- Ethena does not use traditional on-chain oracles (Chainlink, Pyth) for its core mechanism. Instead, it relies on centralized exchange price feeds for perpetual futures pricing.
- The delta-neutral hedge is executed against CEX orderbooks (Binance, Bybit, Bitget, Deribit, OKX), meaning price discovery happens off-chain.
- On the Converge chain, Pyth Network and RedStone are integrated as oracle providers.

**October 2025 Oracle Incident:**
- During the October 11, 2025 crash, Binance's internal oracle referenced its own thinly-liquid USDe orderbook rather than broader market data.
- This caused USDe to display at $0.65 on Binance while maintaining peg on DEXs (Curve) and other venues.
- The issue was exchange infrastructure, not Ethena protocol failure -- but it demonstrates how off-chain price feeds create opaque risk.

**Manipulation Resistance:**
- No on-chain TWAP manipulation vector since hedging happens on CEXs.
- However, concentrated exchange volumes mean a single exchange outage or oracle misconfiguration can cause localized depegs.
- No public documentation of circuit breakers for abnormal price movements on the protocol side.

**Key Concern:** The reliance on CEX infrastructure for price discovery and hedging means traditional DeFi oracle analysis does not fully apply. Risk is shifted from on-chain oracle manipulation to off-chain exchange infrastructure reliability.

### 3. Economic Mechanism -- HIGH

**Delta-Neutral Basis Trade:**
- USDe is backed by a "cash and carry" trade: long spot crypto (stETH, ETH, BTC) held in custody + equal short perpetual futures on CEXs.
- Yield for sUSDe holders comes from: (a) ETH staking yield and (b) funding rate payments received on short positions.
- In bull markets, shorts receive funding from longs, generating positive yield.
- In bear markets, funding rates can turn negative, requiring Ethena to pay rather than receive.

**Reserve Fund Adequacy -- HIGH RISK:**
- Reserve fund is approximately $78M, representing ~1.18% of TVL.
- Industry benchmark for healthy reserve: >5% of TVL. Ethena falls significantly below this.
- CryptoQuant warned in April 2024 that the reserve fund is only sustainable if USDe market cap stays below $4B. Current supply exceeds this threshold.
- During the summer 2024 bear market, negative funding caused USDe supply to shrink from ~$3.6B to $3.09B.
- During Q4 2025, USDe supply crashed from ~$14.7B peak to ~$6.4B following the October crash.

**Funding Rate Risk:**
- Prolonged negative funding is the primary tail risk. Historical episodes include:
  - Luna/3AC collapse (2022): funding negative for weeks
  - FTX collapse (November 2022): sharp negative funding
  - October 2025 flash crash: funding flipped negative
- Ethena mitigates by: adjusting sUSDe yield downward, tapping reserve fund, and allowing natural supply contraction through redemptions.

**Custody and Counterparty Risk:**
- Collateral is held at institutional custodians: Ceffu, Copper, Fireblocks, Cobo.
- "Off-Exchange Settlement" (OES) model means collateral is delegated (not transferred) to exchanges -- Ethena retains ownership.
- This was validated during the February 2025 Bybit hack ($1.4B stolen from Bybit hot wallets) -- Ethena's collateral was unaffected because it was held in OES custody, not on Bybit directly.
- However, unrealized P&L and funding settlements still create exchange exposure.

**October 2025 Stress Test:**
- USDe dropped to $0.65 on Binance during a $19B market crash.
- The depeg was confined to Binance due to exchange-specific issues (API failures, halted withdrawals, no primary dealer relationship with Ethena).
- On Curve and other DEXs, peg held near $1.00.
- Protocol processed >$2B in redemptions within 24 hours without interruption.
- Post-crash, USDe supply declined from ~$14.7B to ~$6.4B over two months, demonstrating the reflexive risk of the model.

**Key Concern:** The reserve fund is structurally undersized relative to TVL and historical stress scenarios. While the OES custody model proved resilient (Bybit hack), the fundamental dependence on positive funding rates creates a fragile equilibrium. Supply can contract rapidly during stress, as evidenced by the ~57% decline post-October 2025.

### 4. Smart Contract Security -- LOW

**Audit History (7+ audits):**
1. Zellic -- V1 protocol (no critical/high findings)
2. Quantstamp -- October 18, 2023 (no critical/high findings)
3. Speabit -- October 18, 2023 (no critical/high findings)
4. Pashov -- October 22, 2023 (no critical/high findings)
5. Code4rena -- November 13, 2023 (no critical/high findings)
6. Pashov -- September 2, 2024 (no critical/high findings)
7. Quantstamp -- October 25, 2024 (no critical/high findings)
8. Cyfrin -- October 31, 2024 (no critical/high findings)
9. Pashov -- October 20, 2024 (additional review)
10. Code4rena Invitational -- November 2024

All audits reported no critical or high-level vulnerabilities.

**Audit Coverage Score:** 7+ audits with most recent within 18 months. Weighted score is strong. Multiple independent firms provide cross-validation.

**Bug Bounty:**
- Active Immunefi program since April 4, 2024.
- Maximum payout: $3,000,000 for critical smart contract bugs (10% of affected funds, capped at $3M).
- KYC required for payouts. Paid in USDC on Ethereum.
- Primacy of Impact policy -- encourages reporting on all bugs with in-scope impact.

**Code Status:**
- Open source on GitHub (ethena-labs).
- GoPlus confirms contract is verified and open source.
- USDe token is NOT a proxy contract -- reduces upgrade risk at the token level.
- Contract is not self-destructible.

**Key Assessment:** Smart contract security is a clear strength. The breadth and recency of audits, combined with a meaningful bug bounty and open-source code, place Ethena in the top tier for on-chain contract security.

### 5. Operational Security -- MEDIUM

**Team:**
- Founder: Guy Young (doxxed). Background in traditional finance -- worked at Cerberus Capital Management (2016-2022) in investment banking, hedge funds, and private equity before founding Ethena Labs in 2023.
- Team includes public-facing members from TradFi backgrounds.
- Backed by prominent investors including Dragonfly, Arthur Hayes (BitMEX co-founder), and others.

**Incident Response Track Record:**
- **February 2025 Bybit Hack:** Ethena paused operations with Bybit, re-routed hedges to other venues, continued honoring mints/redemptions. Collateral was safe in OES custody. Demonstrated effective crisis response.
- **October 2025 Crash:** Protocol processed $2B+ in redemptions within 24 hours. Peg held on primary venues (Curve). Team communicated quickly to clarify the Binance-specific nature of the depeg.
- **Summer 2024 Negative Funding:** Managed orderly supply contraction from ~$3.6B to ~$3.09B without peg break.

**Dependencies:**
- Critical dependency on 4-5 centralized exchanges for hedging (Binance, Bybit, Bitget, Deribit, OKX).
- Critical dependency on 4 institutional custodians (Ceffu, Copper, Fireblocks, Cobo).
- Converge chain introduces new infrastructure dependencies (LayerZero, Pyth, Wormhole).
- Single exchange failure is survivable (proven with Bybit). Multiple simultaneous exchange failures would be catastrophic.

**Key Concern:** Operational security is competent with a proven track record, but the fundamental architecture creates an opaque risk surface that is difficult for external observers to monitor in real time. Hedge positions, funding rates, and custodial balances are not transparently verifiable on-chain.

## Critical Risks

1. **Reserve Fund Insufficiency (HIGH):** At 1.18% of TVL (~$78M), the reserve fund is inadequate for a prolonged negative funding environment at current scale. CryptoQuant analysis indicates sustainability only below $4B market cap. Current TVL of $6.6B exceeds this threshold.

2. **Centralized Exchange Dependency (HIGH):** The entire delta-neutral mechanism relies on CeFi exchange infrastructure. A simultaneous failure or regulatory action affecting multiple exchanges (e.g., a coordinated regulatory crackdown) could prevent Ethena from maintaining hedges, breaking the peg.

3. **Reflexive Supply Contraction (HIGH):** During stress, USDe supply can contract rapidly (57% decline in Oct-Dec 2025), which may amplify market stress through forced position unwinding and liquidity withdrawal from DeFi protocols that integrate sUSDe as collateral.

## Peer Comparison

| Feature | Ethena (USDe) | DAI (MakerDAO) | FRAX |
|---------|--------------|----------------|------|
| Backing | Delta-neutral basis trade | Overcollateralized crypto + RWA | Fractional algo + AMO |
| Timelock | UNVERIFIED | 48h (GSM) | 24h |
| Multisig | 7/10 Gnosis Safe | DAO governance (MKR vote) | 3/5 multisig |
| Audits | 7+ (Zellic, Quantstamp, Cyfrin, Code4rena, Pashov, Speabit) | 10+ (Trail of Bits, ABDK, others) | 5+ (Trail of Bits, Certora) |
| Oracle | CEX price feeds (off-chain) | Chainlink + Maker oracles | Chainlink + Curve TWAP |
| Insurance/TVL | ~1.18% | ~3% (surplus buffer) | ~2% (AMO reserves) |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | $3M (Immunefi) | $5M (Immunefi) | $1M (Immunefi) |
| Depeg History | $0.65 on Binance (Oct 2025, exchange-specific) | $0.89 (Mar 2020, Black Thursday) | Minor deviations |
| Key Risk | Negative funding rates + CeFi dependency | Governance attack + RWA exposure | Algorithmic component fragility |

## Recommendations

- **For USDe holders:** Monitor the reserve fund size relative to TVL on an ongoing basis. If the ratio drops significantly below 1%, consider reducing exposure. Track funding rates across major exchanges as a leading indicator of stress.
- **For sUSDe stakers:** Understand that yield comes from funding rates, which can turn negative. During bear markets, yields may drop to zero or sUSDe holders may effectively subsidize the peg.
- **For DeFi protocols integrating sUSDe as collateral:** Apply conservative collateral factors and monitor for rapid supply contraction events. The October 2025 episode demonstrates that sUSDe can lose significant market depth during stress.
- **For governance participants:** Advocate for increasing the reserve fund as a percentage of TVL. The current 1.18% is below industry benchmarks and below the protocol's own risk models.
- **General:** Ethena's smart contract layer is well-secured. The primary risks are economic and structural (funding rates, CeFi dependency), not code-level vulnerabilities. Users should evaluate Ethena more like a structured finance product than a traditional DeFi protocol.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- UNVERIFIED (timelock details not publicly confirmed)
- [ ] Admin can change oracle sources arbitrarily? -- Not directly applicable (CEX-based hedging)
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED
- [x] Multisig has low threshold (2/N with small N)? -- NO. 7/10 threshold is strong
- [ ] Zero or short timelock on governance actions? -- UNVERIFIED
- [ ] Pre-signed transaction risk? -- Not applicable (Ethereum, not Solana)
- [ ] Social engineering surface area (anon multisig signers)? -- Multisig signers are not publicly identified

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- Collateral is ETH/BTC (high liquidity)
- [ ] Single oracle source without TWAP? -- CEX price feeds, not on-chain oracle
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [x] Insufficient insurance fund relative to TVL? -- YES. 1.18% is below 5% healthy threshold

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Converge chain uses LayerZero/Wormhole (emerging risk)
- [ ] Admin keys stored in hot wallets? -- No, all multisig keys are cold wallets per documentation
- [ ] No key rotation policy? -- UNVERIFIED

## Information Gaps

- **Timelock durations:** Specific timelock delays for admin/owner actions could not be independently verified. Ethena documents a "Matrix of Multisig and Timelocks" but the exact values are not prominently published.
- **Multisig signer identities:** The 7/10 multisig signers are not publicly identified, reducing accountability.
- **Real-time hedge position transparency:** No public dashboard showing current hedge positions, funding rate exposure, or custodial balances in real time.
- **Reserve fund composition:** Exact composition and custody arrangement of the ~$78M reserve fund is not fully detailed in public sources.
- **Emergency procedures:** While Ethena has demonstrated effective incident response, no formal public incident response plan or emergency pause documentation was found.
- **Converge chain security:** The new Converge L1 chain introduces an entirely new trust surface that has not been battle-tested. Security posture of the Converge validator set is unknown.
- **Counterparty exposure limits:** Maximum exposure per exchange is not publicly documented. Concentration risk across Binance, Bybit, Bitget, Deribit, and OKX is opaque.
- **Governance proposal outcomes:** Whether the proposal to reduce Risk Committee from 5 to 3 voting members passed could not be confirmed.

## Disclaimer

This analysis is based on publicly available information and web research as of April 5, 2026. It is NOT a formal smart contract audit. The unique risk profile of Ethena (basis trading / CeFi dependency) means that traditional DeFi security analysis captures only part of the picture. Economic and counterparty risks may be more significant than smart contract risks. Always DYOR and consider professional auditing services for investment decisions.
