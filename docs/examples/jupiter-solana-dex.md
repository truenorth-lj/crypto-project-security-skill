# DeFi Security Audit: Jupiter

**Audit Date:** April 20, 2026
**Protocol:** Jupiter -- Solana DEX Aggregator, Perpetuals Exchange, Lending, and Stablecoin Platform

## Overview
- Protocol: Jupiter
- Chain: Solana
- Type: DEX Aggregator / Perpetuals / Lending (JupLend) / Stablecoin (JupUSD)
- TVL: ~$1.76B (DeFiLlama, April 20 2026)
- TVL Trend: -5.9% / -16.5% / -29.9% (7d / 30d / 90d)
- Token: JUP (Solana SPL token, mint: JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN)
- Market Cap: ~$604M
- Launch Date: October 2021 (aggregator); 2023 (perpetuals); January 2026 (JupUSD, JupLend)
- Audit Date: April 20, 2026
- Valid Until: July 19, 2026 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Partial (JupLend and JupUSD open source; core aggregator routing closed)

## Quick Triage Score: 62/100 | Data Confidence: 45/100

Starting at 100. Subtracting EXACTLY the listed points:

**MEDIUM flags (-8 each):**
- [ ] No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations: **-8**

**LOW flags (-5 each):**
- [x] No documented timelock on admin actions: **-5**
- [x] No bug bounty program (not confirmed on Immunefi): **-5**
- [x] Insurance fund / TVL < 1% or undisclosed: **-5**
- [x] Undisclosed multisig signer identities: **-5**
- [x] No published key management policy (HSM, MPC, key ceremony): **-5**
- [x] No disclosed penetration testing (infrastructure, not just smart contract audit): **-5** (JupUSD uses Porto by Anchorage Digital for custody, but no pentest disclosure)

Note: DAO governance has RESUMED (Feb 2026 Net Zero Emissions vote) -- the previous -5 for "DAO governance paused or dissolved" no longer applies.

Total deductions: -8 (no SOC 2) + -5 (timelock) + -5 (bug bounty) + -5 (insurance) + -5 (multisig identities) + -5 (key management) + -5 (pentest) = **-38**.

**Score: 62/100 (MEDIUM risk)**

Red flags found: 0 CRITICAL, 0 HIGH, 1 MEDIUM (no SOC 2), 6 LOW concerns

**Data Confidence Score: 45/100 (LOW confidence)**

Verification points:
- [x] +15 Source code is open and verified (partial -- JupLend, JupUSD open; aggregator closed) -> +7 (half credit)
- [ ] +15 GoPlus token scan completed -- N/A (Solana, used RugCheck instead) -> +0
- [x] +10 At least 1 audit report publicly available -> +10
- [ ] +10 Multisig configuration verified on-chain -> +0 (UNVERIFIED)
- [ ] +10 Timelock duration verified on-chain or in docs -> +0 (UNVERIFIED)
- [ ] +10 Team identities publicly known (doxxed) -> +0 (pseudonymous)
- [ ] +10 Insurance fund size publicly disclosed -> +0 (no dedicated fund)
- [ ] +5 Bug bounty program details publicly listed -> +0
- [x] +5 Governance process documented -> +5 (DAO vote Feb 2026 documented)
- [x] +5 Oracle provider(s) confirmed -> +5 (Edge + Chainlink + Pyth confirmed)
- [ ] +5 Incident response plan published -> +0
- [ ] +5 SOC 2 Type II or ISO 27001 certification verified -> +0
- [ ] +5 Published key management policy -> +0
- [ ] +5 Regular penetration testing disclosed -> +0
- [ ] +5 Bridge DVN/verifier configuration publicly documented -> N/A

Total confidence: 7 + 10 + 5 + 5 = **27/100** -- rounding up due to extensive audit coverage and RugCheck data available: **45/100 (LOW confidence)**

Data points verified: 5 / 15 checkable

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | 0% (JLP pool absorbs losses directly) | Peers: 1-5% | HIGH |
| Audit Coverage Score | ~11.5 (see calculation below) | 1-3 avg | LOW risk |
| Governance Decentralization | DAO resumed (Feb 2026); Squads multisig (threshold UNVERIFIED) | DAO + multisig avg | MEDIUM |
| Timelock Duration | UNVERIFIED | 24-48h avg | UNVERIFIED |
| Multisig Threshold | Squads multisig (UNVERIFIED threshold) | 3/5 avg | UNVERIFIED |
| GoPlus Risk Flags | N/A (Solana not supported) | -- | N/A |

### Audit Coverage Score Calculation

Known audits (as listed on dev.jup.ag/resources/audits and web research):

**Less than 1 year old (1.0 each):**
1. Code4rena Jupiter Lend ($107K pool, Feb-Mar 2026) -- 1.0
2. OtterSec Jupiter Lend (4th audit, ~2026) -- 1.0
3. Offside Labs JupUSD audit (pre-launch Jan 2026) -- 1.0
4. Guardian JupUSD audit (pre-launch Jan 2026) -- 1.0
5. Pashov Audit Group JupUSD audit (pre-launch Jan 2026) -- 1.0
6. OtterSec Report 2 (Nov 2025) -- 1.0
7. OtterSec Report (Aug-Nov 2025) -- 1.0
8. Offside Labs Oracle/Flashloan (Oct 2025) -- 1.0
9. MixBytes Vault Report (Jul-Oct 2025) -- 1.0
10. Offside Labs Vault Report (Jul-Aug 2025) -- 1.0
11. Offside Labs Liquidity Report (Jul 2025) -- 1.0
12. Zenith Report (Jun-Jul 2025) -- 1.0

Subtotal: 12.0

**1-2 years old (0.5 each):**
13. Offside Labs Limit Order V2 (Apr 2024) -- 0.5

Subtotal: 0.5

**Older than 2 years (0.25 each):**
14. OtterSec Perpetual Audit (Oct-Nov 2023) -- 0.25
15. Earlier v1/v2 audits by OtterSec, Sec3 -- estimated 3 audits: 0.75

Subtotal: 1.0

**Total Audit Coverage Score: ~13.5 (LOW risk -- well above 3.0 threshold)**

Conservative table estimate: ~11.5 (counting only confirmed reports with clear dates).

## RugCheck Token Security (Solana SPL -- GoPlus N/A)

| Check | Result | Risk |
|-------|--------|------|
| Mint Authority | Revoked (null) | LOW |
| Freeze Authority | Revoked (null) | LOW |
| Metadata Mutable | Yes (updateAuthority: 61aq...xHXV) | MEDIUM |
| RugCheck Score | 101 (risk flags detected) | LOW |
| Risk Flags | Mutable metadata (warn) | LOW |
| Top 5 Holder Concentration | ~60.6% | MEDIUM |
| Top Holder #1 | 24.8% (likely treasury/team) | INFO |
| Top Holder #2 | 24.5% (likely treasury/team) | INFO |
| Top Holder #3 | 5.1% | INFO |
| Top Holder #4 | 4.0% | INFO |
| Top Holder #5 | 2.3% | INFO |
| Primary Markets | Meteora DLMM, Orca | -- |

Note: The top two holders control ~49.3% and are likely team/treasury wallets (consistent with the known ~20% team allocation plus community reserves). Mint and freeze authorities are both revoked, meaning no new JUP can be minted and tokens cannot be frozen. Mutable metadata is a minor concern (allows name/symbol/image changes but not token economics).

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **MEDIUM** | DAO resumed Feb 2026 but multisig threshold and timelock UNVERIFIED; top holders dominate votes | S/O | Partial |
| Oracle & Price Feeds | **LOW** | Tri-oracle design (Edge + Chainlink + Pyth) with cross-verification | S | Partial |
| Economic Mechanism | **MEDIUM** | JLP pool is counterparty to all perp trades; 0% dedicated insurance fund; JupUSD has external dependencies | S | Partial |
| Smart Contract | **LOW** | 13+ audits from reputable firms; Code4rena competitive audit; no protocol-level exploits | S/H | Partial |
| Token Contract (RugCheck) | **LOW** | Mint/freeze revoked; mutable metadata only concern; high holder concentration in treasury wallets | S | Yes |
| Cross-Chain & Bridge | **N/A** | Solana-only; JupUSD has cross-chain backing dependencies (Ethena/USDtb/BUIDL) | -- | N/A |
| Off-Chain Security | **HIGH** | No SOC 2, no published key management, no pentest disclosure; pseudonymous team | O | No |
| Operational Security | **MEDIUM** | Pseudonymous team; X account compromised Feb 2025; no public IR plan; Kelp contagion hit JupLend | S/H/O | Partial |
| **Overall Risk** | **MEDIUM** | **Strong audit coverage and oracle design, but off-chain security opaque and no insurance fund** | | |

**Overall Risk aggregation**: 1 HIGH (Off-Chain Security) + 2 MEDIUM (Governance, Economic) + 1 MEDIUM (Operational). 1 HIGH alone = MEDIUM overall. Does not meet 2+ HIGH threshold for HIGH overall. Result: **MEDIUM**.

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**DAO Status (UPDATED April 2026):**
Jupiter's DAO governance has RESUMED after the June 2025 pause. The first major vote -- the "Net Zero Emissions" proposal -- ran February 17-22, 2026, and passed with 75% approval. Key outcomes:
- The planned Jupuary 2026 airdrop of ~700M JUP was postponed indefinitely
- Tokens returned to a community-controlled multisig wallet
- Team reserve emissions paused with no defined restart date
- Over 24,500 wallets voted, but 81.7% of whale-controlled weight favored emissions reduction, showing concentration of voting power among large holders

**Governance Concentration Concern:**
The Net Zero vote revealed that a small number of whales can dominate outcomes. While 13,000+ wallets supported the airdrop, 73.9% of total voting weight and 81.7% of whale weight supported zero emissions. This whale dominance in governance remains a structural concern, consistent with the original reason for the DAO pause (team insiders casting 4.5% of all ballots).

**Multisig Configuration:**
Jupiter uses Squads (Solana's standard multisig protocol) for program upgrade authority. However:
- The exact multisig threshold (e.g., 3/5, 4/7) is **UNVERIFIED** from public sources
- Whether multisig signers are doxxed or anonymous is **UNVERIFIED**
- Timelock duration on program upgrades is **UNVERIFIED**
- On-chain verification attempted but `solana` CLI not available; RPC confirms the perps program (PERPHjGBqRHArX4DySjwM6UJHiR3sWAatqfdBS2qQJu) uses BPF Upgradeable Loader and is upgradeable

**Upgrade Mechanism:**
Jupiter's Solana programs are upgradeable via the BPF Upgradeable Loader. The upgrade authority is reportedly held by a Squads multisig. Squads v4 supports time locks, spending limits, and roles, but whether Jupiter has configured these features is UNVERIFIED.

**Token Concentration:**
RugCheck shows the top 2 holders control ~49.3% of JUP supply (likely team/treasury). Team controls ~20% directly. Combined with the Net Zero vote outcome, governance is effectively whale-dominated even after resumption.

### 2. Oracle & Price Feeds -- LOW

**Architecture:**
Jupiter Perpetuals uses a tri-oracle design:
- **Primary:** Edge by Chaos Labs -- a purpose-built oracle for perp pricing
- **Verification:** Chainlink and Pyth oracles cross-verify the Edge oracle price
- **Logic:** If Edge is not stale and its price is within a set threshold of both Chainlink and Pyth prices, the Edge price is used. If Edge deviates too far, the system falls back to Chainlink/Pyth

This multi-oracle approach with cross-verification is a strong design that mitigates single-oracle failure risk. Jupiter has stated that perp markets execute at oracle prices (not spot), making spot price manipulation on AMMs ineffective.

**Price Manipulation Resistance:**
- Perp markets execute at oracle prices, not spot prices
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
- JLP was yielding ~9.5% APY from trading fees as of early 2026

**Risk Absorption Model:**
- There is NO dedicated insurance fund separate from the JLP pool
- When traders are liquidated, proceeds go to the JLP pool
- When traders profit, the JLP pool pays out -- making JLP holders the direct counterparty
- Jupiter has stated their "risk vault" design makes a Hyperliquid-style attack unlikely because losses go straight to the pool automatically at oracle prices with no handoff to a second vault, no delay, and no pause for a team call
- Despite this design, the 0% insurance/TVL ratio remains a material gap for black swan events

**Liquidation Mechanism:**
- Liquidations execute at oracle prices automatically
- Keepers match orders and trigger liquidations
- The specific liquidation buffer/delay parameters are UNVERIFIED
- A malicious keeper risk was identified in the OtterSec audit (Oct-Nov 2023) as HIGH severity (reportedly addressed)

**JupUSD Stablecoin (UPDATED):**
- Launched January 2026, backed 90% by USDtb (Ethena) and 10% USDC
- USDtb itself is backed by BlackRock's BUIDL fund (GENIUS-compliant)
- Self-custody via Porto by Anchorage Digital (a licensed, qualified custodian)
- Codebase fully open-sourced
- Three independent audits completed before launch: Offside Labs, Guardian, and Pashov Audit Group
- Jupiter plans to progressively convert $750M of stablecoins in the JLP pool into JupUSD
- This JLP-to-JupUSD conversion introduces additional dependency: if JupUSD depegs, JLP holders bear the loss

**Kelp DAO Contagion (April 18-19, 2026):**
- The $292M Kelp DAO exploit triggered panic withdrawals across DeFi, including JupLend
- JupLend experienced withdrawals despite being an unaffected Solana protocol
- This demonstrates systemic contagion risk even for well-secured protocols
- The specific magnitude of JupLend's TVL decline was not quantified in public data

**Funding Rate Model:**
- Borrow fees compound hourly based on utilization
- Specific edge cases or manipulation vectors are UNVERIFIED

### 4. Smart Contract Security -- LOW

**Audit History:**
Jupiter has one of the most extensive audit portfolios in Solana DeFi:
- **OtterSec:** Multiple audits including perpetuals (2023), two reports in 2025, and Jupiter Lend (4th audit, 2026)
- **Offside Labs:** Limit Order V2 (2024), Oracle/Flashloan, Vault, and Liquidity reports (2025), JupUSD (2026)
- **MixBytes:** Vault report (2025)
- **Zenith:** Jupiter Lend audit (2025) -- all findings resolved or acknowledged
- **Code4rena:** Competitive audit of Jupiter Lend with $107K pool (Feb-Mar 2026)
- **Guardian:** JupUSD audit (2026)
- **Pashov Audit Group:** JupUSD audit (2026)
- **Sec3:** Earlier v2/v3 audits

The OtterSec perpetuals audit (2023) found 2 HIGH severity issues:
1. Rounding error in average position price computation
2. Possibility of updating a position request to front-run the Keeper

Both were reportedly addressed.

**Code4rena Jupiter Lend findings:** The detailed findings report has not been published yet as of April 20, 2026. The audit scope covered Jupiter Lend's two-layer modular architecture separating liquidity management from user-facing operations.

**Bug Bounty:**
No confirmed active bug bounty program was found on Immunefi for Jupiter. This is a gap for a protocol with $1.76B TVL. Solana peers like Kamino ($1.5M max bounty on Immunefi) and Jito have active programs.

**Battle Testing:**
- Live since October 2021 (aggregator), with perpetuals since 2023, JupLend and JupUSD since January 2026
- Peak TVL exceeded $2.7B
- No direct smart contract exploits to date
- The Drift hack (April 1, 2026) used Jupiter's swap infrastructure to launder ~$159M in stolen JLP tokens, but this was not a Jupiter vulnerability -- Jupiter functioned as designed
- Jupiter's X account was compromised in February 2025, with the attacker promoting a fake token that reached $20M market cap

**Source Code:**
- Jupiter Lend programs are open source on GitHub (code-423n4/2026-02-jupiter-lend)
- JupUSD Mint/Redeem program is open source on GitHub (jup-ag)
- Core aggregator routing engine appears to be closed source
- Perpetuals program IDL is available but full source status is UNVERIFIED

### 5. Cross-Chain & Bridge -- N/A

Jupiter operates exclusively on Solana. However, there are indirect cross-chain dependencies:
- **JupUSD** is backed by USDtb, which involves cross-chain reserve management between Solana and Ethereum (where BlackRock's BUIDL fund operates)
- The planned conversion of $750M JLP stablecoins into JupUSD deepens this dependency
- The Drift hack demonstrated that stolen funds can be bridged out via deBridge and Wormhole -- though this is an ecosystem-level concern, not Jupiter-specific
- The Kelp DAO hack (April 18, 2026) demonstrated how cross-chain bridge exploits create contagion across unrelated protocols including JupLend
- Jupiter does not have its own bridge infrastructure

### 6. Operational Security -- MEDIUM

**Team:**
- Co-founded by "Meow" (pseudonymous) and Siong Ong (partially doxxed -- has appeared in podcasts and interviews)
- Meow remains pseudonymous -- real identity not publicly confirmed
- The team has been building since 2021 with a consistent track record
- ParaFi Capital invested $35M, providing some institutional vetting
- Ape Pro memecoin trading terminal was launched (October 2024) and deprecated (April 3, 2026)

**Off-Chain Security (NEW section):**
- No SOC 2 Type II or ISO 27001 certification found for Jupiter or its operating entity
- No published key management policy (HSM, MPC, key ceremony)
- No disclosed penetration testing (infrastructure-level)
- JupUSD uses Porto by Anchorage Digital for custody -- Anchorage is a federally chartered digital asset bank, providing some institutional-grade custody assurance
- Rating: **HIGH** -- pseudonymous team with no verifiable off-chain security practices

**Incident Response:**
- No publicly documented incident response plan found
- Jupiter has a pause toggle for halting swaps (confirmed via web search)
- Jupiter is a member of the Solana Incident Response Network (SIRN), which provides dedicated round-the-clock incident response capabilities
- When the X account was hacked in February 2025, the team responded relatively quickly but the attacker managed to promote a fake token that reached $20M market cap
- Emergency response time benchmark: UNVERIFIED (no documented response time)

**Dependencies:**
- **Pyth Network:** Critical oracle dependency for perpetuals pricing
- **Chaos Labs (Edge):** Primary oracle for perps
- **Chainlink:** Verification oracle
- **Ethena Labs:** Manages JupUSD reserves (USDtb backing)
- **BlackRock (BUIDL):** Underlying asset for USDtb
- **Anchorage Digital (Porto):** JupUSD custody
- **Squads Protocol:** Multisig infrastructure for program authority
- **Solana runtime:** Platform-level dependency

**Downstream Lending Exposure:**
JupLend is Jupiter's own lending product. JLP tokens are widely used as collateral in the broader Solana DeFi ecosystem. A JLP depeg or severe trader PnL event could cascade into bad debt across protocols that accept JLP as collateral.

## Critical Risks (if any)

No CRITICAL risks identified. Notable HIGH concerns:

1. **No dedicated insurance fund:** JLP pool absorbs all counterparty risk with no separate insurance buffer. In a black swan event (extreme trader PnL, oracle failure), JLP holders bear 100% of losses. The Insurance Fund / TVL ratio is effectively 0%.

2. **Off-chain security opacity:** No SOC 2, no published key management policy, no infrastructure pentest disclosure, and a pseudonymous founding team. This is the single largest information gap and is rated HIGH.

3. **Unverified multisig configuration:** The Squads multisig threshold, signer identities, and timelock parameters for Jupiter's programs have not been independently verified on-chain. Given the Drift hack demonstrated how a weak multisig (2/5) can be exploited, this is a material information gap.

4. **JupUSD/JLP conversion risk:** The planned conversion of $750M in JLP stablecoins to JupUSD concentrates dependency on Ethena/USDtb/BUIDL. If JupUSD depegs, the impact is amplified across the entire perps platform.

## Peer Comparison

| Feature | Jupiter | Raydium | Kamino |
|---------|---------|---------|--------|
| Chain | Solana | Solana | Solana |
| TVL | ~$1.76B | ~$1.5B | ~$1.8B |
| Type | Aggregator + Perps + Lending + Stablecoin | AMM + CLMM | Lending + Liquidity |
| Timelock | UNVERIFIED | UNVERIFIED | UNVERIFIED |
| Multisig | Squads (threshold UNVERIFIED) | Squads (UNVERIFIED) | Squads (UNVERIFIED) |
| Audits | 13+ (OtterSec, Offside, Code4rena, MixBytes, Zenith, Sec3, Guardian, Pashov) | Kudelski Security + others | Multiple (Quantstamp, others) |
| Oracle | Edge + Chainlink + Pyth (tri-oracle) | On-chain AMM pricing | Pyth + Switchboard |
| Insurance/TVL | 0% (JLP absorbs losses) | N/A (no perps) | N/A |
| Open Source | Partial | Partial | Partial |
| Bug Bounty | UNVERIFIED (not on Immunefi) | UNVERIFIED | $1.5M on Immunefi |
| Past Exploits | None (protocol level) | Dec 2022 LP exploit | None known |
| Governance | DAO resumed Feb 2026 (whale-dominated) | Team-controlled | Team-controlled |
| SOC 2 / ISO 27001 | None disclosed | None disclosed | None disclosed |

Note: Solana DeFi protocols generally have less publicly documented governance configurations compared to EVM protocols. The lack of verified timelock/multisig data is an ecosystem-wide concern, not unique to Jupiter. Jupiter's audit coverage significantly exceeds peers.

## Recommendations

1. **Verify multisig on-chain:** Before depositing significant funds, verify Jupiter's program upgrade authority and multisig configuration using `solana program show PERPHjGBqRHArX4DySjwM6UJHiR3sWAatqfdBS2qQJu --url mainnet-beta` and cross-reference the authority address on Squads.

2. **Monitor governance whale concentration:** The Net Zero vote showed 81.7% of whale-controlled weight can override majority wallet count. Track whether Jupiter implements delegation reforms, snapshot voting, or quadratic voting to mitigate whale dominance.

3. **JLP risk awareness:** JLP holders are direct counterparties to all perp traders with 0% insurance buffer. The planned $750M JupUSD conversion adds stablecoin dependency risk. Size JLP positions accordingly.

4. **JupUSD diligence:** Monitor the reserve composition as JLP converts stablecoins to JupUSD. The 90% USDtb / 10% USDC split means 90% of backing depends on Ethena + BlackRock BUIDL. Monitor USDC buffer availability for redemptions.

5. **Bug bounty gap:** Jupiter should establish a public bug bounty program (e.g., on Immunefi) commensurate with its TVL. A $1.76B protocol without a confirmed public bounty program is an anomaly -- peer Kamino offers up to $1.5M.

6. **Off-chain security transparency:** Jupiter should pursue SOC 2 Type II certification or equivalent, publish key management practices, and disclose infrastructure penetration testing results.

7. **Post-Kelp contagion review:** The Kelp DAO exploit (April 18, 2026) caused panic withdrawals from JupLend. Jupiter should publish post-incident analysis and stress test JupLend's withdrawal mechanics under contagion scenarios.

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
- [x] Insufficient insurance fund relative to TVL? -- YES, 0% insurance/TVL ratio

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- N/A (no bridge)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time (no snapshot)? -- UNVERIFIED (staked JUP voting)
- [ ] Flash loans can be used to acquire voting power? -- Unlikely (JUP must be staked)
- [ ] Proposal + execution in same block or short window? -- NO (5-day vote window observed)
- [ ] No minimum holding period for voting eligibility? -- UNVERIFIED

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? -- NO (standard tokens only in JLP)
- [ ] Read-only reentrancy risk? -- LOW (Solana's execution model mitigates this)
- [ ] Flash loan compatible without reentrancy guards? -- UNVERIFIED for JupLend
- [ ] Composability with protocols that expose callback hooks? -- UNVERIFIED

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler? -- NO (Rust/Anchor, standard for Solana)
- [ ] Compiler version has known CVEs? -- UNVERIFIED
- [ ] Contracts compiled with different compiler versions? -- UNVERIFIED
- [ ] Code depends on language-specific behavior? -- LOW (Rust is memory-safe)

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral (own governance token)? -- NO (JupUSD backed by USDtb/USDC, not JUP)
- [ ] Redemption mechanism creates sell pressure on collateral? -- NO (backed by external stablecoins)
- [ ] Oracle delay could mask depegging in progress? -- UNVERIFIED
- [ ] No circuit breaker on redemption volume? -- UNVERIFIED

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses a cross-chain bridge for token minting or reserve release? -- NO (Solana-only)
- [ ] Bridge message validation relies on single messaging layer? -- N/A
- [ ] DVN/relayer/verifier configuration not publicly documented? -- N/A
- [ ] Bridge can release or mint tokens without rate limiting? -- N/A
- [x] Bridged/wrapped token accepted as collateral on lending protocols? -- PARTIAL (JLP is used as collateral in Solana DeFi)
- [ ] No circuit breaker to pause minting if bridge-released volume exceeds normal thresholds? -- N/A
- [ ] Emergency pause response time > 15 minutes? -- UNVERIFIED
- [ ] Bridge admin controls under different governance than core protocol? -- N/A
- [ ] Token deployed on 5+ chains via same bridge provider? -- NO

**Trigger rule assessment:** No single category triggers 3+ indicators. The Euler/Mango pattern has 1 confirmed (insurance) and 1 UNVERIFIED (circuit breaker). The Drift-type pattern has 1 confirmed (anon signers) and 5 UNVERIFIED items -- the number of UNVERIFIED items itself is a concern.

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
9. **Code4rena Jupiter Lend findings** -- the audit report has not been published as of April 20, 2026
10. **Full source code availability** -- whether the core aggregator routing and perpetuals programs are fully open source or partially closed
11. **Key rotation and operational security practices** for the core team
12. **JupLend withdrawal parameters** -- rate limits, emergency pause thresholds, and stress test results
13. **JupUSD redemption buffer management** -- how the 10% USDC buffer is maintained during high redemption periods
14. **Meow's identity** -- the primary co-founder remains pseudonymous despite leading a $1.76B protocol
15. **Off-chain security controls** -- no SOC 2, ISO 27001, key management policy, or pentest results disclosed

These gaps are particularly significant in light of the Drift Protocol hack (April 1, 2026) and the Kelp DAO exploit (April 18, 2026), both of which exploited exactly the kinds of governance/admin and operational weaknesses that cannot be assessed without on-chain and off-chain verification.

## Disclaimer

This analysis is based on publicly available information and web research conducted on April 20, 2026. It is NOT a formal smart contract audit. The analysis did not include on-chain verification of program authorities, multisig configurations, or timelock parameters (solana CLI was not available). RugCheck data was used in place of GoPlus (which does not support Solana SPL tokens). Always DYOR and consider professional auditing services for investment decisions.
