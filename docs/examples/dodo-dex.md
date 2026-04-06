# DeFi Security Audit: DODO

**Audit Date:** April 6, 2026
**Protocol:** DODO -- Decentralized Exchange with Proactive Market Maker (PMM) Algorithm

## Overview
- Protocol: DODO
- Chain: Multi-chain (Ethereum, BSC, Arbitrum, Polygon, Avalanche, Base, Scroll, Linea, OP Mainnet, Manta, Aurora, Mantle, Zircuit, Hemi, HashKey Chain -- 15 chains)
- Type: DEX (AMM with PMM algorithm) / Crowdpooling / Aggregation
- TVL: ~$12.7M (DeFiLlama, April 2026)
- TVL Trend: -0.8% / -3.4% / -32.7% (7d / 30d / 90d)
- Token: DODO (ERC-20: 0x43Dfc4159D86F3A37A5A4B3D4580b888ad7d4DDd)
- Launch Date: August 2020 (V1); February 2021 (V2); July 2023 (V3)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: DODOEX)

## Quick Triage Score: 47/100

Starting at 100, subtracting:

- -8: TVL dropped >30% in 90 days (-32.7%)
- -5: No documented timelock on admin actions beyond the stated 3-day proxy upgrade cooldown (UNVERIFIED on-chain)
- -5: Insurance fund / TVL undisclosed or non-existent
- -5: Undisclosed multisig signer identities (DAO structure described but signer details not public)
- -5: Single oracle provider (Chainlink primary; no documented multi-oracle fallback)
- -5: No documented formal incident response plan
- -8: Multisig threshold details not publicly disclosed (assumed < 3 signers without evidence)
- -5: DAO governance activity appears low; vDODO participation unclear
- -5: Past exploit ($3.8M in March 2021) demonstrates historical code quality concerns
- -2: (partial) Bug bounty max payout of $100K is low relative to protocol history

Total deductions: -53. Score: **47/100 (HIGH risk)**

Red flags found: 0 CRITICAL, 0 HIGH (GoPlus clean), 2 MEDIUM (TVL decline, multisig uncertainty), multiple LOW/INFO

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | Curve: partial; SushiSwap: none | HIGH |
| Audit Coverage Score | 2.25 (see below) | 3.0+ = LOW | MEDIUM |
| Governance Decentralization | Multi-DAO (Admin/Risk/Earn) but details opaque | On-chain + multisig avg | MEDIUM |
| Timelock Duration | 3 days (proxy upgrades, per docs) | 24-48h avg | LOW |
| Multisig Threshold | UNVERIFIED | 3/5 avg | UNVERIFIED |
| GoPlus Risk Flags | 0 HIGH / 0 MED | -- | LOW |

### Audit Coverage Score Calculation

Known audits:

**1-2 years old (0.5 each):**
1. Sherlock -- DODO V3 (July 2023): 0.25 (older than 2 years)

**Older than 2 years (0.25 each):**
2. PeckShield -- DODO V1 (July 2020): 0.25
3. Trail of Bits -- DODO V1 (September 2020): 0.25
4. PeckShield -- DODO V2 (December 2020): 0.25
5. CertiK -- DODO V2 CrowdPooling (February 2021): 0.25
6. Beosin -- DODO V2 Vending Machine (March 2021): 0.25
7. SlowMist -- DODO V2 (April 2021): 0.25
8. PeckShield -- LimitOrder & RFQ: 0.25
9. Sherlock -- DODOFeeRouteProxy: 0.25

**Total Audit Coverage Score: ~2.25 (MEDIUM risk -- below 3.0 LOW threshold)**

Note: All audits are over 2 years old except the V3 Sherlock audit (approaching 3 years). No recent audits covering the current multi-chain deployment state.

## GoPlus Token Security

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | LOW |
| Open Source | Yes (1) | LOW |
| Proxy | No (0) | LOW |
| Mintable | No (0) | LOW |
| Owner Can Change Balance | No (0) | LOW |
| Hidden Owner | No (0) | LOW |
| Selfdestruct | No (0) | LOW |
| Transfer Pausable | No (0) | LOW |
| Blacklist | No (0) | LOW |
| Slippage Modifiable | No (0) | LOW |
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 15,841 | -- |
| Trust List | Yes (1) | LOW |
| Creator Honeypot History | No (0) | LOW |

GoPlus assessment: **CLEAN** -- No risk flags detected on the DODO ERC-20 token contract. Token is on the GoPlus trust list, listed on Binance, open-source, non-mintable, and has no owner privileges.

**Top Holders (from GoPlus):**
1. 0xf977...1acec (EOA): 32.0% -- likely Binance hot wallet
2. 0x4447...bad634 (contract): 27.4% -- likely treasury/staking contract
3. 0x02fc...32bc7 (contract): 5.7%
4. 0x5288...1531 (EOA): 5.0%
5. 0xfff8...3223 (contract): 3.3%

Top 5 holders control ~73.4% of supply. The top holder appears to be a Binance wallet (exchange custody), and the second is a contract (likely protocol treasury). This concentration is notable but typical for mid-cap DeFi tokens where exchanges hold large amounts.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | MEDIUM | Multi-DAO structure with opaque multisig details; 3-day timelock on proxy upgrades claimed but not verified on-chain | Partial |
| Oracle & Price Feeds | MEDIUM | Chainlink primary oracle; no documented multi-oracle fallback or circuit breaker | Partial |
| Economic Mechanism | LOW | PMM algorithm well-tested since 2020; no known economic exploits of the PMM itself | Y |
| Smart Contract | MEDIUM | Past $3.8M exploit (March 2021); audits aging; V3 audit nearly 3 years old | Y |
| Token Contract (GoPlus) | LOW | Clean GoPlus scan; no risky owner functions; trust-listed | Y |
| Cross-Chain & Bridge | MEDIUM | 15-chain deployment; unclear if each chain has independent admin; cross-chain bridge "Coming Soon" | N |
| Operational Security | MEDIUM | Team partially doxxed; past exploit handled well with fund recovery; low bug bounty ceiling | Partial |
| **Overall Risk** | **MEDIUM** | **Aging audit coverage on multi-chain deployment; governance opacity; past exploit history offset by clean token contract and long operational track record** | |

## Detailed Findings

### 1. Governance & Admin Key

**DAO Structure:** DODO operates a three-DAO governance model:
- **Admin DAO**: Highest authority; controls protocol parameter changes. All actions must go through a governance process.
- **Risk Control DAO**: A-level authority; can freeze transactions in emergencies.
- **Earn DAO**: Manages incentive distribution and fee allocation.

Both Admin and Risk DAOs have "A-level authority" (ability to freeze transactions), but the specific multisig configurations, signer identities, and threshold requirements for each DAO are not publicly documented in detail.

**Governance Token (vDODO):** Users convert DODO to vDODO at 100:1 ratio to participate in governance. 1 vDODO = 100 votes. Proposals require 5M DODO in support to pass. Any user holding 100K+ DODO or 1K+ vDODO can submit proposals. Governance occurs via Snapshot (off-chain voting at snapshot:dodobird.eth).

**Timelock:** DODO documentation states a 3-day timelock on proxy contract upgrades. This is a reasonable delay for a DEX but has NOT been independently verified on-chain.

**Upgrade Mechanism:** DODO uses a proxy contract architecture (DODOProxies collection including DODOV2Proxy, DODOCpProxy, DODODspProxy, DODOMineV3Proxy, DODORouteProxy). Periphery contracts are designed to be replaceable independently of core contracts, providing architectural flexibility but also a wider upgrade surface area.

**Key Concern:** The governance structure documentation is high-level. Specific details -- who controls the multisig wallets, what thresholds are used, whether the Risk DAO can bypass the 3-day timelock in emergencies -- are not readily available in public documentation.

**Rating: MEDIUM** -- Reasonable structure described but insufficient transparency on implementation details.

### 2. Oracle & Price Feeds

**Oracle Provider:** DODO integrates Chainlink as its primary price oracle. On mainnet, Chainlink provides price updates from 21 independent price feeders. DODO has publicly stated: "Chainlink is the undisputed leader in the oracle space."

**PMM Dependency on Oracles:** The Proactive Market Maker algorithm relies heavily on external price feeds to set the "fair market price" (parameter i) around which liquidity is concentrated. The slippage factor (k) determines how tightly liquidity clusters around this price. A corrupted oracle feed would directly affect PMM pricing, potentially enabling arbitrage extraction or LP losses.

**Fallback Mechanism:** No documented multi-oracle fallback or secondary oracle source. If Chainlink feeds become stale or inaccurate, the PMM algorithm would operate on incorrect pricing.

**Circuit Breaker:** No documented circuit breaker for abnormal price movements.

**Admin Oracle Control:** UNVERIFIED whether admin can change oracle sources without governance process or timelock.

**Rating: MEDIUM** -- Chainlink is a reliable oracle provider, but single-source dependency without documented fallback creates risk, especially given PMM's direct reliance on accurate pricing.

### 3. Economic Mechanism

**PMM Algorithm:** DODO's proprietary Proactive Market Maker is an inventory management strategy that dynamically adjusts prices based on the ratio of base/quote tokens in the pool. When inventory of one asset decreases, PMM raises its price to incentivize rebalancing. The slippage factor (k) allows concentration of liquidity near the oracle price, providing better capital efficiency than constant-product AMMs.

**Key PMM Parameters:**
- **i (price)**: Oracle-derived mid-market price
- **k (slippage factor)**: Controls liquidity concentration (lower k = more concentrated = better prices but more oracle dependency)
- **R (inventory ratio)**: Tracks deviation from equilibrium

**Crowdpooling:** DODO's token launch mechanism includes a liquidity protection period during which project creators cannot withdraw liquidity. Settlement fees are pre-deposited. The March 2021 exploit targeted crowdpooling contracts specifically, not the core PMM.

**V3 Improvements:** Multi-asset pools, separated buy/sell liquidity, concentrated liquidity design, flexible fee tiers (as low as 0.01%), and 90%+ gas reduction vs. Uniswap V3.

**Insurance Fund:** No publicly documented insurance fund or socialized loss mechanism. For a DEX (vs. lending protocol), the risk profile is different -- LPs bear impermanent loss risk rather than bad debt risk. However, absence of any safety net for LP losses during extreme conditions is notable.

**Rating: LOW** -- PMM is well-tested over 5+ years with no known economic exploits of the core algorithm. V3 architecture represents meaningful improvements. The crowdpooling vulnerability was an access control bug, not an economic design flaw.

### 4. Smart Contract Security

**Audit History:**
- PeckShield (V1, July 2020): 0 Critical, 0 High, 2 Medium, 6 Low findings
- Trail of Bits (V1, September 2020): Comprehensive audit
- PeckShield (V2, December 2020): Pre-launch audit
- CertiK (V2 CrowdPooling, February 2021): Pre-launch audit
- Beosin (V2 Vending Machine, March 2021): Post-exploit area audit
- SlowMist (V2, April 2021): Post-exploit comprehensive audit
- PeckShield (LimitOrder & RFQ): Peripheral feature audit
- Sherlock (V3, July 2023): Most recent audit
- Sherlock (DODOFeeRouteProxy): Peripheral audit
- Sherlock (DODO cross-chain DEX, May 2025): Competitive audit on GitHub

Multiple reputable firms have audited DODO. However, the most recent core audit (V3 by Sherlock) is approaching 3 years old. The May 2025 Sherlock competitive audit on the cross-chain DEX module is more recent but narrow in scope.

**Past Exploit (March 8, 2021):**
- **Impact:** ~$3.8M drained from four V2 Crowdpooling contracts (WSZO, WCRES, ETHA, FUSI pools)
- **Root Cause:** The `init()` function in the crowdpool contract could be called multiple times. Attackers used flash loans to drain real tokens, then re-initialized the contract with counterfeit tokens to bypass the flash loan repayment check.
- **Recovery:** ~$3.1M (~82%) of stolen funds was recovered. The exploit was partially frontrun by MEV bots.
- **Remediation:** Access control was added to prevent re-initialization. Post-mortem was published transparently.

**Bug Bounty:** Active Immunefi program since May 2021, last updated November 2024. Maximum payout: $100,000. Scope: smart contracts focused on prevention of fund loss. The $100K max payout is relatively low for a protocol with $12.7M TVL (represents ~0.8% of TVL, which is reasonable, but low compared to larger programs).

**Open Source:** All core contracts are open source on GitHub (DODOEX organization). This is a positive signal for transparency and community review.

**Rating: MEDIUM** -- Strong audit history with multiple reputable firms, but aging coverage. The 2021 exploit was handled well with significant fund recovery and transparent post-mortem. Code is open source, which is positive.

### 5. Cross-Chain & Bridge

**Multi-Chain Deployment:** DODO is deployed across 15 chains per DeFiLlama data. The TVL distribution is heavily skewed:
- BSC: $4.27M (34%)
- Ethereum: $2.72M (21%)
- Avalanche: $1.86M (15%)
- Arbitrum: $1.32M (10%)
- Polygon: $1.11M (9%)
- HashKey Chain: $0.84M (7%)
- Base: $0.52M (4%)
- Others: <$100K combined

**Cross-Chain Admin:** It is NOT publicly documented whether each chain deployment has its own independent admin multisig or whether a single key controls all deployments. This is a significant information gap.

**Bridge Dependencies:** DODO does not currently operate its own cross-chain bridge. A cross-chain bridge feature was listed as "Coming Soon" as of early 2026. The protocol has participated in a Sherlock competitive audit for a DODO cross-chain DEX module (May 2025 on GitHub), suggesting cross-chain functionality is in development.

**DODOchain:** DODO has announced "DODOchain" as a Layer 3 leveraging EigenDA and an AVS validator network for cross-chain settlement. This is an emerging component with unknown maturity.

**Rating: MEDIUM** -- Wide multi-chain deployment creates operational surface area. Lack of clarity on per-chain admin independence is a concern. No active bridge dependency reduces bridge-specific risk currently.

### 6. Operational Security

**Team:** Co-founded by Diane Dai (CMO, publicly identified, previously at DeFi-focused media) and Radar Bear (lead developer, pseudonymous). The broader development team is based in China and largely anonymous. Diane Dai is well-known in the DeFi space with a public track record including interviews, conference appearances, and media presence.

**Incident Response:** DODO demonstrated competent incident response during the March 2021 exploit, recovering 82% of funds and publishing a transparent post-mortem. However, no formal, publicly documented incident response plan exists.

**Communication:** Active Twitter (@BreederDodo), Discord, community forum (community.dodoex.io), and Medium blog.

**Dependencies:**
- Chainlink (oracle provider -- critical dependency)
- Various chain infrastructure (15 chains)
- No direct bridge dependency currently

**Rating: MEDIUM** -- Partially doxxed team with demonstrated incident response capability. Long operational history (5+ years) is positive. Pseudonymous lead developer and anonymous broader team add risk.

## Critical Risks

1. **Aging Audit Coverage (HIGH):** The most recent core protocol audit (V3 by Sherlock) is from July 2023, nearly 3 years old. Given active development including V3 features, cross-chain expansion, and DODOchain, significant unaudited code may be in production.

2. **Governance Transparency Gap (MEDIUM-HIGH):** While DODO describes a three-DAO governance model, the specific multisig configurations, signer identities, and threshold requirements are not publicly documented. Users cannot independently verify who controls protocol upgrades.

3. **Multi-Chain Admin Ambiguity (MEDIUM-HIGH):** With 15 chain deployments, it is unclear whether a single compromised admin key could affect all chains or whether each deployment is independently secured.

4. **Single Oracle Dependency (MEDIUM):** PMM algorithm's direct reliance on Chainlink price feeds without a documented fallback creates a single point of failure for pricing accuracy.

## Peer Comparison

| Feature | DODO | Curve | SushiSwap |
|---------|------|-------|-----------|
| TVL | $12.7M | $2.12B | $48M |
| Timelock | 3 days (UNVERIFIED) | 3 days (Curve DAO) | 2 days |
| Multisig | UNVERIFIED | Curve DAO (on-chain) | 3/5 Gnosis Safe |
| Audits | 9+ (latest 2023) | 2+ (documented) | 3+ (Quantstamp, PeckShield) |
| Oracle | Chainlink (single) | Internal TWAP + Chainlink | Chainlink |
| Insurance/TVL | Undisclosed | Partial (CRV emissions) | None |
| Open Source | Yes | Yes | Yes |
| Past Exploits | $3.8M (2021, 82% recovered) | Various pool exploits | Kashi/SushiSwap route exploit |
| Chains | 15 | 12+ | 25+ |
| Bug Bounty | $100K (Immunefi) | $250K+ | $250K+ |

## Recommendations

1. **For Users/LPs:** DODO's PMM algorithm is well-tested and the token contract is clean per GoPlus. However, concentrate positions on the more established chains (BSC, Ethereum, Arbitrum) where TVL and liquidity are deepest. Avoid large positions on chains with minimal TVL (<$100K).

2. **For the Protocol:** Urgently commission a comprehensive audit of the current V3 deployment across all chains. The nearly 3-year gap since the last core audit is a meaningful risk given ongoing development.

3. **For the Protocol:** Publish detailed multisig configurations, signer identities (or at minimum, signer categories/affiliations), and threshold requirements for each chain deployment. Governance transparency is a prerequisite for institutional trust.

4. **For the Protocol:** Implement and document a multi-oracle fallback strategy. Given PMM's direct dependence on oracle pricing, a Chainlink-only setup creates unnecessary concentration risk.

5. **For the Protocol:** Increase bug bounty maximum from $100K. For a multi-chain protocol with 15 deployments, a higher ceiling would incentivize responsible disclosure of cross-chain vulnerabilities.

6. **For Users:** Monitor the DODOchain (Layer 3) and cross-chain bridge development carefully. New infrastructure components introduce new risk vectors, especially before they are battle-tested.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- N/A (DEX, not lending)
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED
- [x] Admin can modify withdrawal limits? -- UNVERIFIED, likely yes for pool parameters
- [ ] Multisig has low threshold (2/N with small N)? -- UNVERIFIED
- [ ] Zero or short timelock on governance actions? -- 3-day timelock claimed (UNVERIFIED)
- [ ] Pre-signed transaction risk? -- N/A (EVM chains)
- [x] Social engineering surface area (anon multisig signers)? -- Yes, signer identities undisclosed

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A (DEX, not lending)
- [x] Single oracle source without TWAP? -- Yes, Chainlink only without documented TWAP fallback
- [ ] No circuit breaker on price movements? -- UNVERIFIED, likely no circuit breaker documented
- [x] Insufficient insurance fund relative to TVL? -- Yes, no documented insurance fund

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No active bridge currently
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

## Information Gaps

- **Multisig details:** Specific multisig wallet addresses, thresholds, and signer identities for each chain deployment are not publicly documented
- **Per-chain admin independence:** Whether each of the 15 chain deployments has independent admin controls or shares a single admin key is unknown
- **Timelock verification:** The 3-day timelock on proxy upgrades is stated in docs but not independently verified on-chain
- **Risk DAO emergency powers:** Whether the Risk Control DAO can bypass the timelock (and under what conditions) is not documented
- **Oracle fallback:** No documentation on what happens if Chainlink feeds become stale or inaccurate
- **Insurance fund:** No public information on any safety mechanism for LPs during extreme market events
- **V3 deployment coverage:** Unclear which chains run V2, V3, or both
- **DODOchain security model:** Layer 3 / EigenDA integration security details are sparse
- **vDODO participation rate:** Actual governance participation metrics and voter turnout are not readily available
- **Admin parameter change history:** No easily accessible log of admin-initiated parameter changes across chains
- **Cross-chain DEX module status:** The Sherlock-audited cross-chain DEX module's deployment status is unclear

## Disclaimer

This analysis is based on publicly available information and web research as of April 6, 2026. It is NOT a formal smart contract audit. The actual TVL observed (~$12.7M via DeFiLlama) differs significantly from the initially stated ~$843M, which may reflect different counting methodologies or data sources. Always DYOR and consider professional auditing services for investment decisions.
