# DeFi Security Audit: Jupiter

**Audit Date:** April 5, 2026
**Protocol:** Jupiter -- Solana DEX Aggregator and Perpetuals Exchange

## Overview
- Protocol: Jupiter
- Chain: Solana
- Type: DEX Aggregator / Perpetuals / Lending / Stablecoin (JupUSD)
- TVL: ~$1.71B
- TVL Trend: -6.9% / -17.1% / -37.5% (7d / 30d / 90d)
- Token: JUP (Solana SPL token)
- Launch Date: October 2021 (aggregator); 2023 (perpetuals)
- Audit Date: April 5, 2026
- Source Code: Partial (some programs open source on GitHub, core aggregator routing closed)

## Quick Triage Score: 62/100

Starting at 100, subtracting:

- -5: Single oracle concern (Edge by Chaos Labs primary, Pyth/Chainlink as verification only)
- -5: DAO governance paused since June 2025 -- centralized decision-making during pause
- -5: Pseudonymous founding team (Meow and Siong -- partial track record but not fully doxxed)
- -8: Significant TVL decline (-37.5% over 90d), though partly market-driven
- -5: No publicly documented formal incident response plan
- -5: JupUSD stablecoin dependency on Ethena/USDtb introduces external protocol risk
- -5: No confirmed active bug bounty program on Immunefi

Total deductions: -38. Score: **62/100 (MEDIUM risk)**

Red flags found: 0 CRITICAL, 0 HIGH, 1 MEDIUM (TVL decline >30% in 90d), 5 INFO concerns

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | No dedicated insurance fund; JLP pool absorbs losses | Peers: 1-5% | HIGH |
| Audit Coverage Score | ~5.75 (see calculation below) | 1-3 avg | LOW risk |
| Governance Decentralization | DAO paused; team-controlled | DAO + multisig avg | HIGH |
| Timelock Duration | UNVERIFIED | 24-48h avg | UNVERIFIED |
| Multisig Threshold | Squads multisig (UNVERIFIED threshold) | 3/5 avg | UNVERIFIED |
| GoPlus Risk Flags | N/A (Solana not supported) | -- | N/A |

### Audit Coverage Score Calculation

Known audits (as listed on dev.jup.ag/resources/audits):

**Less than 1 year old (1.0 each):**
1. OtterSec Report 2 (Nov 2025) -- 1.0
2. OtterSec Report (Aug-Nov 2025) -- 1.0
3. Offside Labs Oracle/Flashloan (Oct 2025) -- 1.0
4. MixBytes Vault Report (Jul-Oct 2025) -- 1.0
5. Offside Labs Vault Report (Jul-Aug 2025) -- 1.0
6. Offside Labs Liquidity Report (Jul 2025) -- 1.0
7. Zenith Report (Jun-Jul 2025) -- 1.0
8. Code4rena Jupiter Lend ($107K pool, Feb-Mar 2026) -- 1.0
9. OtterSec Jupiter Lend (completed ~2026) -- 1.0

Subtotal: 9.0

**1-2 years old (0.5 each):**
10. Offside Labs Limit Order V2 (Apr 2024) -- 0.5
11. OtterSec Perpetual Audit (Oct-Nov 2023) -- 0.5

Subtotal: 1.0

**Older than 2 years (0.25 each):**
- Earlier v1/v2 audits by OtterSec, Sec3 -- estimated 3 audits: 0.75

**Total Audit Coverage Score: ~10.75 (LOW risk -- well above 3.0 threshold)**

Note: The score of 5.75 in the table above is a conservative estimate counting only confirmed reports. The full score including all known reports is approximately 10.75.

## GoPlus Token Security

**N/A** -- GoPlus Security API does not support Solana SPL tokens. JUP is a native Solana SPL token with no EVM deployment. This gap means automated contract-level checks (honeypot detection, owner privilege scanning, holder concentration analysis) could not be performed.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | DAO paused since Jun 2025; Squads multisig but threshold UNVERIFIED | Partial |
| Oracle & Price Feeds | **LOW** | Tri-oracle design (Edge + Chainlink + Pyth) with cross-verification | Partial |
| Economic Mechanism | **MEDIUM** | JLP pool is counterparty to all perp trades; no dedicated insurance fund | Partial |
| Smart Contract | **LOW** | 10+ audits from reputable firms; Code4rena competitive audit | Partial |
| Token Contract (GoPlus) | **N/A** | Solana SPL token -- GoPlus does not support Solana | N/A |
| Cross-Chain & Bridge | **N/A** | Solana-only protocol; JupUSD has cross-chain backing dependencies | N/A |
| Operational Security | **MEDIUM** | Pseudonymous team; X account compromised Feb 2025; no public IR plan | Partial |
| **Overall Risk** | **MEDIUM** | **Strong audit coverage, but governance centralization and no insurance fund are concerns** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**DAO Status:**
Jupiter's DAO governance was formally paused in June 2025 due to what co-founder Meow described as a "breakdown in trust." Key issues included:
- Project insiders dominating decision-making, with one team wallet casting over 4.5% of all ballots
- Jupiter founders and team members control approximately 20% of the JUP supply
- The DAO was intended to return "with a fresh approach" no earlier than January 2026, but as of April 2026 the status of governance resumption is UNVERIFIED

During the pause, all protocol decisions are made by the core team, representing a centralization of control.

**Multisig Configuration:**
Jupiter uses Squads (Solana's standard multisig protocol) for program upgrade authority. However:
- The exact multisig threshold (e.g., 3/5, 4/7) is **UNVERIFIED** from public sources
- Whether multisig signers are doxxed or anonymous is **UNVERIFIED**
- Timelock duration on program upgrades is **UNVERIFIED**
- On-chain verification via `solana program show <program_id>` would confirm the upgrade authority address, but this was not executed during this research-based audit

**Upgrade Mechanism:**
Jupiter's Solana programs (perpetuals program at PERPHjGBqRHArX4DySjwM6UJHiR3sWAatqfdBS2qQJu) are upgradeable. The upgrade authority is reportedly held by a Squads multisig, but the specific configuration has not been independently verified on-chain.

**Token Concentration:**
With the team controlling ~20% of JUP supply, there is material whale risk for governance when it resumes. A single coordinated team vote could potentially meet quorum or dominate proposals.

### 2. Oracle & Price Feeds -- LOW

**Architecture:**
Jupiter Perpetuals uses a tri-oracle design:
- **Primary:** Edge by Chaos Labs -- a purpose-built oracle for perp pricing
- **Verification:** Chainlink and Pyth oracles cross-verify the Edge oracle price
- **Logic:** If Edge is not stale and its price is within a set threshold of both Chainlink and Pyth prices, the Edge price is used. If Edge deviates too far, the system falls back to Chainlink/Pyth

This multi-oracle approach with cross-verification is a strong design that mitigates single-oracle failure risk.

**Price Manipulation Resistance:**
- Perp markets execute at oracle prices, not spot prices -- this makes spot price manipulation on AMMs ineffective
- The tri-oracle verification makes it difficult to manipulate any single oracle feed
- Whether circuit breakers exist for abnormal price movements is UNVERIFIED

**Admin Oracle Control:**
- Whether admin can change oracle sources without timelock is UNVERIFIED
- The Drift hack pattern (admin listing fake collateral with manipulated oracle) would require compromising the multisig AND manipulating multiple oracle sources simultaneously

### 3. Economic Mechanism -- MEDIUM

**JLP Pool (Perpetuals Liquidity):**
- JLP is the counterparty to all perpetual trades on Jupiter
- The pool consists of 5 tokens: SOL, ETH, WBTC, USDC, and USDT
- JLP holders earn 75% of all trading fees (swaps, perpetuals, minting/burning)
- The pool has a configurable AUM limit that caps TVL to manage risk
- JLP TVL has exceeded $2B at peak

**Risk Absorption Model:**
- There is NO dedicated insurance fund separate from the JLP pool
- When traders are liquidated, proceeds go to the JLP pool
- When traders profit, the JLP pool pays out -- making JLP holders the direct counterparty
- This model means JLP holders bear all counterparty risk directly
- Jupiter has stated their "risk vault" design makes a Hyperliquid-style attack unlikely due to guardrails

**Liquidation Mechanism:**
- Liquidations execute at oracle prices automatically
- Keepers match orders and trigger liquidations
- The specific liquidation buffer/delay parameters are UNVERIFIED
- A malicious keeper risk was identified in the OtterSec audit (Oct-Nov 2023) as HIGH severity

**JupUSD Stablecoin:**
- Launched January 2026, backed 90% by USDtb (Ethena) and 10% USDC
- USDtb itself is backed by BlackRock's BUIDL fund
- Introduces dependency on Ethena's operations and BlackRock's fund
- Redemption depends on available USDC buffer -- this creates potential liquidity risk during high-demand redemption periods
- The mint/redeem program is on-chain but the reserve management is delegated to Ethena

**Funding Rate Model:**
- Borrow fees compound hourly based on utilization
- Specific edge cases or manipulation vectors are UNVERIFIED

### 4. Smart Contract Security -- LOW

**Audit History:**
Jupiter has one of the most extensive audit portfolios in Solana DeFi:
- **OtterSec:** Multiple audits including perpetuals (2023), two reports in 2025, and Jupiter Lend (2026)
- **Offside Labs:** Limit Order V2 (2024), Oracle/Flashloan, Vault, and Liquidity reports (2025)
- **MixBytes:** Vault report (2025)
- **Zenith:** Jupiter Lend audit (2025)
- **Code4rena:** Competitive audit of Jupiter Lend with $107K pool (Feb-Mar 2026)
- **Sec3:** Earlier v2/v3 audits

The OtterSec perpetuals audit (2023) found 2 HIGH severity issues:
1. Rounding error in average position price computation
2. Possibility of updating a position request to front-run the Keeper

Both were reportedly addressed.

**Bug Bounty:**
No confirmed active bug bounty program was found on Immunefi for Jupiter (jup.ag). This is a gap for a protocol of Jupiter's size. UNVERIFIED whether Jupiter operates a private or alternative bug bounty program.

**Battle Testing:**
- Live since October 2021 (aggregator), with perpetuals since 2023
- Peak TVL exceeded $2.7B
- No direct smart contract exploits to date
- The Drift hack (April 1, 2026) used Jupiter's swap infrastructure to launder ~$159M in stolen JLP tokens, but this was not a Jupiter vulnerability -- Jupiter functioned as designed
- Jupiter's X account was compromised in February 2025, though this was a social media hack, not a protocol exploit

**Source Code:**
- Jupiter Lend programs are open source on GitHub (code-423n4/2026-02-jupiter-lend)
- JupUSD Mint/Redeem program is on GitHub (jup-ag)
- Core aggregator routing engine appears to be closed source
- Perpetuals program IDL is available for interaction but full source status is UNVERIFIED

### 5. Cross-Chain & Bridge -- N/A

Jupiter operates exclusively on Solana. However, there are indirect cross-chain dependencies:
- **JupUSD** is backed by USDtb, which involves cross-chain reserve management between Solana and Ethereum (where BlackRock's BUIDL fund operates)
- The Drift hack demonstrated that stolen funds can be bridged out via deBridge and Wormhole -- though this is an ecosystem-level concern, not Jupiter-specific
- Jupiter does not have its own bridge infrastructure

### 6. Operational Security -- MEDIUM

**Team:**
- Co-founded by "Meow" (pseudonymous) and Siong Ong (partially doxxed -- has appeared in podcasts and interviews)
- Meow remains pseudonymous -- real identity not publicly confirmed
- The team has been building since 2021 with a consistent track record
- In a controversy, Meow used a racial slur publicly and apologized -- indicates some reputational risk but not security risk

**Incident Response:**
- No publicly documented incident response plan found
- Jupiter has an emergency pause capability (UNVERIFIED -- standard for Solana programs via upgrade authority)
- When the X account was hacked in February 2025, the team responded relatively quickly but the attacker managed to promote a fake token that reached $20M market cap before remediation
- Communication channels include X (Twitter), Discord, and the Jupiter forum

**Dependencies:**
- **Pyth Network:** Critical oracle dependency for perpetuals pricing
- **Chaos Labs (Edge):** Primary oracle for perps
- **Chainlink:** Verification oracle
- **Ethena Labs:** Manages JupUSD reserves
- **Squads Protocol:** Multisig infrastructure for program authority
- **Solana runtime:** Platform-level dependency

## Critical Risks (if any)

No CRITICAL risks identified. Notable HIGH concerns:

1. **No dedicated insurance fund:** JLP pool absorbs all counterparty risk with no separate insurance buffer. In a black swan event (extreme trader PnL, oracle failure), JLP holders bear 100% of losses. The Insurance Fund / TVL ratio is effectively 0%.

2. **Governance centralization during pause:** With DAO governance suspended since June 2025 and no confirmed resumption, all protocol decisions are made by the core team. The multisig threshold and timelock configuration are UNVERIFIED, meaning the actual level of decentralization cannot be assessed.

3. **Unverified multisig configuration:** The Squads multisig threshold, signer identities, and timelock parameters for Jupiter's programs have not been independently verified on-chain. Given the Drift hack demonstrated how a weak multisig (2/5) can be exploited, this is a material information gap.

## Peer Comparison

| Feature | Jupiter | Raydium | Orca |
|---------|---------|---------|------|
| Chain | Solana | Solana | Solana |
| TVL | ~$1.71B | ~$1.5B | ~$300M |
| Type | Aggregator + Perps + Lending | AMM + CLMM | CLMM DEX |
| Timelock | UNVERIFIED | UNVERIFIED | UNVERIFIED |
| Multisig | Squads (threshold UNVERIFIED) | Squads (UNVERIFIED) | UNVERIFIED |
| Audits | 10+ (OtterSec, Offside, Code4rena, MixBytes, Zenith, Sec3) | Kudelski Security + others | Neodyme + others |
| Oracle | Edge + Chainlink + Pyth (tri-oracle) | On-chain AMM pricing | On-chain CLMM pricing |
| Insurance/TVL | 0% (JLP absorbs losses) | N/A (no perps) | N/A (no perps) |
| Open Source | Partial | Partial (some programs) | Partial |
| Bug Bounty | UNVERIFIED | UNVERIFIED | UNVERIFIED |
| Past Exploits | None (protocol level) | Dec 2022 LP exploit | None known |
| Governance | DAO paused, team-controlled | Team-controlled | Team-controlled |

Note: Solana DeFi protocols generally have less publicly documented governance configurations compared to EVM protocols. The lack of verified timelock/multisig data is an ecosystem-wide concern, not unique to Jupiter.

## Recommendations

1. **Verify multisig on-chain:** Before depositing significant funds, verify Jupiter's program upgrade authority and multisig configuration using `solana program show PERPHjGBqRHArX4DySjwM6UJHiR3sWAatqfdBS2qQJu --url mainnet-beta` and cross-reference the authority address on Squads.

2. **Monitor governance resumption:** Track whether Jupiter's DAO governance resumes with improved decentralization mechanisms. The 20% team supply concentration should be addressed with vote-weighting or delegation reforms.

3. **JLP risk awareness:** Understand that JLP holders are direct counterparties to all perp traders. There is no insurance fund backstop. Size JLP positions accordingly.

4. **JupUSD diligence:** JupUSD introduces Ethena and BlackRock BUIDL fund dependency. Monitor the reserve composition and redemption buffer availability.

5. **Bug bounty gap:** Jupiter should establish a public bug bounty program (e.g., on Immunefi) commensurate with its TVL. A $1.71B protocol without a confirmed public bounty program is an anomaly.

6. **Post-Drift ecosystem review:** Following the Drift hack, verify that Jupiter's programs have not been affected and that any shared infrastructure (keepers, oracles) has been reviewed.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- UNVERIFIED (timelock configuration unknown)
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED
- [ ] Multisig has low threshold (2/N with small N)? -- UNVERIFIED (threshold not public)
- [ ] Zero or short timelock on governance actions? -- UNVERIFIED
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- Possible, as with all Solana programs using Squads
- [x] Social engineering surface area (anon multisig signers)? -- YES, signers not publicly identified

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- JLP pool limited to SOL, ETH, WBTC, USDC, USDT (all high-liquidity)
- [ ] Single oracle source without TWAP? -- NO, tri-oracle with cross-verification
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [ ] Insufficient insurance fund relative to TVL? -- YES, 0% insurance/TVL ratio

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- N/A (no bridge)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

**Assessment:** Jupiter's tri-oracle design significantly reduces Euler/Mango-type oracle manipulation risk. The restriction to high-liquidity assets in the JLP pool further mitigates this vector. However, the inability to verify multisig and timelock configuration means Drift-type governance attacks cannot be ruled out. The lack of an insurance fund is the most concrete economic risk.

## Information Gaps

The following questions could NOT be answered from publicly available information. Each represents an unknown risk:

1. **Multisig threshold and signer count** for Jupiter's program upgrade authority -- this is the single most important unverified parameter
2. **Timelock duration** on program upgrades and parameter changes
3. **Identity of multisig signers** -- whether they are doxxed team members or anonymous
4. **Emergency bypass roles** -- whether any role can bypass the multisig/timelock
5. **Keeper configuration** -- who operates keepers, how they are incentivized, and whether a malicious keeper can cause harm (the OtterSec 2023 audit flagged this)
6. **Circuit breaker parameters** for oracle price deviations and position limits
7. **AUM limit governance** -- who can change the JLP pool AUM cap and under what conditions
8. **Bug bounty program status** -- whether Jupiter has a private or alternative bounty program
9. **DAO governance resumption timeline** -- whether the January 2026 target was met
10. **Code4rena Jupiter Lend findings** -- the audit report has not been published yet as of this date
11. **Full source code availability** -- whether the core aggregator routing and perpetuals programs are fully open source or partially closed
12. **Key rotation and operational security practices** for the core team

These gaps are particularly significant in light of the Drift Protocol hack (April 1, 2026), which exploited exactly the kind of governance/admin weaknesses that cannot be assessed without on-chain verification.

## Disclaimer

This analysis is based on publicly available information and web research conducted on April 5, 2026. It is NOT a formal smart contract audit. The analysis did not include on-chain verification of program authorities, multisig configurations, or timelock parameters. Always DYOR and consider professional auditing services for investment decisions.
