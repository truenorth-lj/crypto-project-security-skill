# DeFi Security Audit: Pendle

**Audit Date:** April 5, 2026
**Protocol:** Pendle -- Multi-chain yield tokenization protocol

## Overview
- Protocol: Pendle (V2 + Boros)
- Chain: Ethereum, Arbitrum, Base, Sonic, Mantle, Berachain, Hyperliquid L1, Avalanche, Optimism, Binance, Plasma
- Type: Yield Tokenization / Fixed Income
- TVL: ~$1.93B (down from ~$3.77B 90 days ago)
- TVL Trend: -7.3% / -11.6% / -48.8% (7d / 30d / 90d)
- Launch Date: June 2021 (V1), late 2022 (V2), August 2025 (Boros)
- Audit Date: April 5, 2026
- Source Code: Open (GitHub: pendle-finance)

## Quick Triage Score: 68/100
- Red flags found: 2
  - TVL dropped ~49% over 90 days (significant outflow)
  - Multisig configuration and timelock parameters not publicly documented with specificity

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | UNVERIFIED (no public data) | 1-5% (Aave ~2%) | HIGH |
| Audit Coverage Score | 5.0 (4+ firms, audits >1yr old get 0.5 weight) | Spectra ~2.0, Notional ~3.0 | LOW risk |
| Governance Decentralization | vePENDLE + team multisig | Spectra: team multisig; Notional: team multisig | MEDIUM |
| Timelock Duration | UNVERIFIED (present in codebase) | 24-48h avg | MEDIUM |
| Multisig Threshold | UNVERIFIED | 3/5 avg | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW risk |

## GoPlus Token Security (PENDLE on Ethereum)

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
| Holders | 72,653 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No | -- |
| CEX Listed | Binance, Coinbase | -- |

GoPlus assessment: **LOW RISK**. The only flag is `is_mintable = 1`, indicating the token contract allows minting. This is expected for PENDLE, as the protocol uses a controlled emission schedule (decreasing 1.1% per week since September 2024, transitioning to 2% annual terminal inflation after April 2026). No honeypot, no proxy, no hidden owner, no tax, no trading restrictions. The token is not upgradeable (no proxy pattern), which is a positive signal.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | Multisig details and timelock parameters not publicly documented | Partial |
| Oracle & Price Feeds | **LOW** | Built-in TWAP oracles (Uniswap V3-style); minimal external oracle dependency | Partial |
| Economic Mechanism | **MEDIUM** | Complex PT/YT mechanism; YT holders absorb losses; no public insurance fund data | Partial |
| Smart Contract | **LOW** | 4+ audit firms, no critical findings, open source, $250K bug bounty | Y |
| Token Contract (GoPlus) | **LOW** | Mintable (expected for emissions schedule); no other flags | Y |
| Operational Security | **LOW** | Doxxed founders, proven incident response (Penpie), active development | Y |
| **Overall Risk** | **MEDIUM** | **Strong technical foundation with governance transparency gaps** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**vePENDLE Governance:**
- Pendle uses Vote-escrowed PENDLE (vePENDLE) for governance, where voting power is proportional to staked amount and lock duration (up to 2 years).
- vePENDLE holders can vote to direct PENDLE incentives to specific liquidity pools.
- Governance appears primarily on-chain via vePENDLE voting for incentive allocation.

**Multisig and Admin Controls:**
- Pendle has confirmed use of a multisig wallet system requiring multiple parties to sign transactions.
- The specific multisig threshold (e.g., 3/5, 5/7) is NOT publicly documented in easily accessible sources. UNVERIFIED.
- The Pendle V2 codebase includes a Timelock contract (contracts/periphery/Timelock.sol), confirming timelocks exist. However, the specific delay duration is UNVERIFIED from public documentation.

**Upgrade Mechanism:**
- Pendle V2 uses a diamond proxy pattern (EIP-2535) for its router system, organizing functionality into modular, upgradeable facets.
- The router serves as the primary user-facing interface, routing calls to specialized action contracts based on function selectors.
- Who controls upgrades and what timelock applies to router facet changes is UNVERIFIED.

**Emergency Powers:**
- Pendle demonstrated the ability to pause all contracts within 20 minutes during the September 2024 Penpie exploit. This confirms an emergency pause capability exists and is controlled by the team.
- The team's ability to pause contracts quickly is a double-edged sword: it prevented $105M in further losses during the Penpie hack, but it also means a compromised admin key could freeze user funds.

**Key Concern:** The lack of public documentation on multisig threshold, signer identities, timelock durations, and upgrade governance is the primary governance risk. For a ~$1.9B TVL protocol, this transparency gap is notable.

### 2. Oracle & Price Feeds -- LOW

**Built-in Market Oracles:**
- Each Pendle market has its own built-in oracle, similar to Uniswap V3's TWAP mechanism.
- This design eliminates reliance on external price feeds for PT/YT pricing, significantly reducing oracle manipulation risk.
- PT prices progressively align with their redemption value at expiry through a time-decay model in the AMM, without requiring external oracles.

**PY Index Ratchet Mechanism:**
- The PY (Principal-Yield) index is designed to never decrease. When the underlying SY index decreases, the PT index "freezes" and stays constant until the SY index recovers.
- Losses are absorbed by YT holders (not PT holders), providing principal protection for fixed-yield seekers.
- This ratchet mechanism is a key safety feature but also means YT holders bear disproportionate risk during yield-bearing asset depegs.

**External Oracle Usage:**
- DeFiLlama lists RedStone as a primary oracle for Pendle on the Redstone chain specifically.
- For the core PT/YT trading mechanism, Pendle relies on its own internal AMM pricing rather than external oracles.
- Chaos Labs has introduced a Pendle PT Risk Oracle for protocols that use Pendle PTs as collateral, suggesting external integrations require additional oracle infrastructure.

**Price Manipulation Resistance:**
- The AMM's time-decay function (_getRateScalar) increases price sensitivity as maturity approaches, which naturally aligns PT prices with fair value.
- During early phases, larger trades have lower price impact; near maturity, the market becomes more sensitive, encouraging market makers to maintain accurate pricing.

### 3. Economic Mechanism -- MEDIUM

**Yield Tokenization (PT/YT):**
- Users deposit SY (Standardized Yield tokens, e.g., stETH wrapper) and receive PT (Principal Token) + YT (Yield Token).
- PT represents the right to redeem the principal at maturity -- effectively a zero-coupon bond.
- YT represents the right to all yield, rewards, and points generated until maturity.
- The invariant SY_value = PT_value + YT_value is maintained by design.

**Risk Distribution:**
- PT holders get fixed-rate exposure with principal protection (PY index ratchet).
- YT holders bear all variable yield risk, including potential losses from underlying asset depegs or yield drops.
- This creates asymmetric risk: YT holders can lose significantly if yields decline or underlying assets lose value.

**AMM Design:**
- Pendle uses a custom AMM optimized for yield trading, not a standard constant-product model.
- Liquidity is concentrated around the expected yield range, improving capital efficiency.
- At maturity, PT converges to underlying asset value, and the AMM is designed to handle this convergence gracefully.

**Insurance Fund / Bad Debt:**
- No publicly documented insurance fund or bad debt socialization mechanism was found. UNVERIFIED.
- Since Pendle is not a lending protocol, traditional liquidation mechanics do not apply.
- The primary risk is impermanent loss for LPs in Pendle pools, and potential YT value loss from yield compression.

**Boros (Funding Rate Trading):**
- Launched August 2025 on Arbitrum, allowing margin trading on BTC and ETH funding rates.
- Introduces leverage (initially 1.2x) and open interest caps ($10M initially).
- This is a newer, less battle-tested product that adds complexity to the protocol's risk profile.
- Boros represents a significant expansion from passive yield tokenization to active derivatives trading.

**TVL Trend Concern:**
- TVL peaked near $8.3B in mid-2025 following the Boros launch and strong market conditions.
- Current TVL of ~$1.93B represents a significant decline, though this appears correlated with broader market conditions and natural maturity-driven TVL cycles (TVL drops as markets expire and users withdraw).
- The 90-day decline of ~49% is notable but not necessarily alarming for a yield protocol where TVL is inherently cyclical around market expiry dates.

### 4. Smart Contract Security -- LOW

**Audit History:**
- **Ackee Blockchain** (V2, April-May 2022): 4 engineering weeks. No critical or high severity issues. 11 findings (Informational to Medium).
- **Dedaub** (V2): No Critical, High, or Medium issues identified.
- **ChainSecurity** (V2 Core): Found the codebase provides a good level of security.
- **Dingbats** (V2): Audit completed (details in GitHub repo).
- **Code4rena** (V2): Top wardens including cmichel (#1 in 2021, #2 in 2022), WatchPug (#5 in 2021, #1 in 2022), and leastwood (#7 in 2021, #8 in 2022) participated.
- **Least Authority** (V1, June 2021): Final audit report completed.

All audits are publicly available at: https://github.com/pendle-finance/pendle-core-v2-public/tree/main/audits

**Audit Coverage Score:** 5.0. Multiple reputable firms have audited the protocol. However, the most recent known audits (V2) are from 2022, and significant new features (Boros, multi-chain expansion) have been added since. Audit status of Boros is UNVERIFIED.

**Bug Bounty:**
- Active bug bounty on Immunefi with rewards up to $250,000.
- Scope covers smart contracts, focused on loss of user funds.
- All severities require PoC (Hardhat or Foundry).
- Rewards paid in PENDLE, USDC, or USDT on Ethereum/Base.
- No KYC required for payouts.

**Battle Testing:**
- Protocol live since June 2021 (V1), V2 since late 2022 -- approximately 3.5 years.
- Peak TVL of ~$8.3B handled successfully.
- All smart contracts are open source.
- No direct exploit of Pendle's own contracts has occurred.

### 5. Operational Security -- LOW

**Team & Track Record:**
- Co-founder TN Lee is publicly doxxed with professional profiles on Crunchbase, IQ.wiki, and WellFound.
- Team has appeared on public podcasts (The Defiant) and maintains active social media presence (@pendle_fi on Twitter).
- No known prior security incidents under the core team's management.
- The protocol has raised institutional funding, with investors tracked on PitchBook and Tracxn.

**Incident Response (Proven):**
- September 3, 2024: Penpie (a third-party yield farming protocol built on Pendle) suffered a $27M reentrancy exploit.
- Pendle's team paused all contracts within 20 minutes of the exploit, preventing an estimated $105M in additional losses.
- The vulnerability was in Penpie's code (specifically a reentrancy in _harvestBatchMarketRewards due to permissionless market listing), NOT in Pendle's core contracts.
- This incident demonstrated strong incident response capabilities and rapid coordination.

**Dependencies:**
- Underlying yield-bearing assets (stETH, sUSDe, etc.) represent composability risk -- if an underlying asset depegs, YT holders bear the loss.
- Multi-chain deployment introduces bridge dependencies, though Pendle itself is not a bridge protocol.
- Boros introduces dependency on external funding rate data sources (initially Binance).

## Critical Risks (if any)

No CRITICAL risks were identified. The following HIGH-priority items warrant attention:

1. **Governance opacity (HIGH information gap):** For a ~$1.9B TVL protocol, the specific multisig configuration, signer identities, and timelock durations should be publicly documented. The absence of this information is a risk signal.
2. **Insurance fund status (HIGH information gap):** No verifiable data on insurance reserves or bad debt handling mechanisms. While Pendle is not a lending protocol, the Boros product introduces leveraged positions that could generate losses.
3. **Boros audit status (MEDIUM):** The Boros product (launched August 2025) introduces margin trading and leverage. Whether this codebase has undergone independent security audits is UNVERIFIED.

## Peer Comparison

| Feature | Pendle | Spectra (formerly APWine) | Notional |
|---------|--------|---------------------------|----------|
| TVL | ~$1.93B | ~$190M (early 2025) | ~$843M (V3) |
| Chains | 11 chains | Ethereum, others | Ethereum, Arbitrum |
| Timelock | Present (duration UNVERIFIED) | UNVERIFIED | UNVERIFIED |
| Multisig | Present (threshold UNVERIFIED) | Team multisig | Team multisig |
| Audits | 4+ firms (Ackee, Dedaub, ChainSecurity, Dingbats, Code4rena) | Community reviewed | Sherlock, Mixbytes |
| Oracle | Built-in TWAP (no external dependency) | External oracles | External oracles |
| Insurance/TVL | UNVERIFIED | UNVERIFIED | UNVERIFIED |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | $250K (Immunefi) | UNVERIFIED | $250K (Immunefi) |
| Incident History | None on core (Penpie was third-party) | None known | V2 vulnerability patched (March 2023, no loss) |
| Revenue | ~$40M annualized (2025) | Significantly lower | Significantly lower |

**Assessment:** Pendle is the clear market leader in yield tokenization by TVL, audit coverage, and revenue. Its built-in oracle design is superior to peers that rely on external price feeds. The main area where Pendle trails best-in-class protocols (like Aave) is governance transparency.

## Recommendations

1. **For users/depositors:**
   - Pendle V2 PT positions are relatively low-risk for fixed-yield exposure. PT holders benefit from the PY index ratchet mechanism.
   - YT positions carry significantly higher risk -- yield compression or underlying asset depegs can cause substantial losses.
   - LP positions in Pendle pools carry impermanent loss risk, particularly near market expiry dates.
   - Boros positions involve leverage and should be treated as higher-risk derivatives.

2. **For the Pendle team:**
   - Publish detailed multisig configuration (threshold, signer count, signer identities/pseudonyms) in official documentation.
   - Document timelock durations for admin actions, contract upgrades, and parameter changes.
   - Commission and publish independent audits for Boros.
   - Consider increasing bug bounty maximum (currently $250K) given the protocol's TVL scale. Comparable protocols at this TVL offer $1M+.
   - Publish an insurance fund / reserve status if one exists, or clarify the protocol's approach to bad debt in Boros.

3. **For integrators (protocols using Pendle PTs as collateral):**
   - Use the Chaos Labs Pendle PT Risk Oracle or equivalent for pricing.
   - Monitor underlying asset health, as PT value depends on the underlying yield-bearing asset.
   - Be aware of maturity-related dynamics -- PT behavior changes significantly near expiry.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- Markets can be created, but timelock status UNVERIFIED
- [ ] Admin can change oracle sources arbitrarily? -- Low risk; Pendle uses built-in oracles, not external feeds
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED
- [x] Multisig has low threshold (2/N with small N)? -- UNVERIFIED (this is itself a concern)
- [ ] Zero or short timelock on governance actions? -- Timelock contract exists; duration UNVERIFIED
- [ ] Pre-signed transaction risk? -- Not applicable (EVM, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- Signer identities UNVERIFIED

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- Not a lending protocol; less applicable
- [ ] Single oracle source without TWAP? -- No; built-in TWAP-style oracles
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [ ] Insufficient insurance fund relative to TVL? -- UNVERIFIED (no public insurance data)

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Multi-chain but not a bridge protocol
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

**Pattern Assessment:** Low pattern match for known exploit vectors. Pendle's built-in oracle design eliminates the most common DeFi attack surface (oracle manipulation). The primary residual risk is governance/admin key related, where information gaps prevent full assessment.

## Information Gaps

The following questions could NOT be answered from publicly available information. These represent unknown risks:

1. **Multisig threshold and signer count** -- What is the exact m-of-n configuration? Who are the signers?
2. **Timelock duration** -- How long is the delay on admin actions and contract upgrades?
3. **Upgrade governance** -- Who controls diamond proxy facet upgrades? Is it the same multisig?
4. **Insurance fund / reserves** -- Does Pendle maintain any reserve fund? What happens if Boros generates bad debt?
5. **Boros audit status** -- Has the Boros codebase been independently audited? By whom?
6. **Emergency pause scope** -- What exactly does the pause affect? Can paused users still withdraw?
7. **Key management practices** -- Are admin keys stored in hardware wallets, cold storage, or hot wallets?
8. **Parameter change authority** -- Who can modify AMM parameters, fee structures, or market listing criteria?
9. **vePENDLE governance scope** -- What decisions are actually subject to vePENDLE voting vs. team discretion?
10. **Multi-chain admin key management** -- Are the same keys used across all 11 chains, or are there separate admin setups per chain?

## Disclaimer

This analysis is based on publicly available information and web research conducted on April 5, 2026.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
