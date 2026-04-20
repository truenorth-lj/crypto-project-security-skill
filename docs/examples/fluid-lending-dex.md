# DeFi Security Audit: Fluid (Lending + DEX)

## Overview
- Protocol: Fluid (formerly Instadapp, rebranded December 2024)
- Chain: Ethereum (primary), Arbitrum, Base, Polygon, Plasma; expanding to Solana via Jupiter Lend
- Type: Unified Liquidity Layer — Lending / DEX / Vaults
- TVL: ~$861M combined (~$701M Fluid Lending + ~$160M Fluid Lite; Fluid DEX TVL tracked separately)
- TVL Trend: -12.5% / -28.4% / -44.2% (7d / 30d / 90d) — Ethereum Lending only
- Launch Date: February 2024 (Fluid Lending); October 2024 (Fluid DEX); December 2024 (rebrand from Instadapp)
- Audit Date: April 20, 2026
- Valid Until: July 19, 2026 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Open (GitHub: Instadapp/fluid-contracts-public)

## Quick Triage Score: 64/100 | Data Confidence: 65/100

### Quick Triage Score Calculation

Starting at 100. Mechanical deductions:

| Flag | Category | Deduction |
|------|----------|-----------|
| TVL dropped >30% in 90 days (44.2% decline) | MEDIUM | -8 |
| No third-party security certification (SOC 2 / ISO 27001) | MEDIUM | -8 |
| No documented timelock on Guardian emergency pause | LOW | -5 |
| Undisclosed multisig signer identities | LOW | -5 |
| Insurance fund / TVL undisclosed | LOW | -5 |
| No disclosed penetration testing (infrastructure-level) | LOW | -5 |

Flags that do NOT apply: GoPlus is_proxy = 1 has a 48h governance timelock on upgrades (Guardian can only pause, not upgrade). Single oracle provider does not apply (dual-source: Chainlink + Uniswap TWAP). Contracts are open source. Team is doxxed. Multiple audits exist. No GoPlus critical flags.

**Score: 100 - 16 - 20 = 64/100 = MEDIUM risk**

Red flags found: 6 (0 CRITICAL, 0 HIGH, 2 MEDIUM, 4 LOW)

### Data Confidence Score Calculation

Starting at 0. Add points:

- [x] +15  Source code is open and verified on block explorer
- [x] +15  GoPlus token scan completed
- [x] +10  At least 1 audit report publicly available (6+ audits)
- [ ] +10  Multisig configuration verified on-chain — NOT verified (address/threshold unknown)
- [ ] +10  Timelock duration verified on-chain — governance timelock documented (48h) but not independently verified on-chain
- [x] +10  Team identities publicly known (doxxed) — Sowmay Jain, Samyak Jain
- [ ] +10  Insurance fund size publicly disclosed — insurance pool exists but size not published
- [x] +5   Bug bounty program details publicly listed (Immunefi, up to $500K)
- [x] +5   Governance process documented (Compound Bravo-style, gov.fluid.io)
- [x] +5   Oracle provider(s) confirmed (Chainlink + Uniswap TWAP + Redstone OEV)
- [ ] +5   Incident response plan published — not formally published
- [ ] +5   SOC 2 Type II or ISO 27001 certification verified — none found
- [ ] +5   Published key management policy — none found
- [ ] +5   Regular penetration testing disclosed — none found
- [ ] +5   Bridge DVN/verifier configuration publicly documented — not documented

**Data Confidence Score: 15 + 15 + 10 + 10 + 5 + 5 + 5 = 65/100 = MEDIUM confidence**

## Quantitative Metrics

| Metric | Value | Benchmark (Aave / Compound) | Rating |
|--------|-------|-----------------------------|--------|
| Insurance Fund / TVL | Undisclosed (pool exists for risky collateral) | ~2% (Aave Safety Module) / ~1% (Compound) | HIGH |
| Audit Coverage Score | 3.5 | 9+ (Aave) / 3+ (Compound) | LOW risk |
| Governance Decentralization | DAO (Bravo) + Guardian + Team multisig | DAO + Guardian (Aave) | MEDIUM |
| Timelock Duration | 48h (governance) | 24h short / 168h long (Aave) / 48h (Compound) | LOW risk |
| Multisig Threshold | UNVERIFIED | 6/10 (Aave Guardian) / 4/6 (Compound) | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 1 MED (proxy) | 0 HIGH / 1 MED (Aave) | LOW risk |

### Audit Coverage Score Calculation

| Audit | Firm | Date | Age Score |
|-------|------|------|-----------|
| Statemind: Fluid Liquidity Layer | Statemind | Dec 2023 | 0.25 (>2yr) |
| MixBytes: Fluid Vault Protocol | MixBytes | Jun 2024 | 0.5 (1-2yr) |
| Cantina: Fluid DEX (competition) | Cantina | Sep-Oct 2024 | 0.5 (1-2yr) |
| MixBytes: Fluid DEX | MixBytes | Dec 2024 | 1.0 (<1yr) |
| Cantina: DEX report published | Cantina | Jan 2025 | 1.0 (<1yr) |
| Certora: DEX V2 (formal verification) | Certora | Feb 2026 | 1.0 (<1yr) |
| OpenZeppelin: Legacy DSA (Instadapp era) | OpenZeppelin | 2019 | 0.25 (>2yr) |

**Audit Coverage Score: ~4.5 = LOW risk** (>= 3.0 threshold)

## GoPlus Token Security (FLUID on Ethereum: 0x6f40d4A6237C257fff2dB00FA0510DeEECd303eb)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | -- |
| Open Source | Yes (1) | -- |
| Proxy | Yes (1) | MEDIUM |
| Mintable | Not flagged | -- |
| Owner Can Change Balance | Not flagged | -- |
| Hidden Owner | Not flagged | -- |
| Selfdestruct | Not flagged | -- |
| Transfer Pausable | Not flagged | -- |
| Blacklist | Not flagged | -- |
| Slippage Modifiable | Not flagged | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 11,164 | -- |
| Trust List | Not flagged | -- |
| Creator Honeypot History | No (0) | -- |

GoPlus assessment: **LOW RISK**. Only flag is the proxy (upgradeable) pattern, standard for governance-upgradeable tokens. No honeypot indicators, no hidden owner, no tax, no trading restrictions. All top 10 holders are smart contracts (treasuries, staking, vesting), not EOAs.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **MEDIUM** | Guardian can pause without timelock; multisig signer identities undisclosed | S/O | Partial |
| Oracle & Price Feeds | **LOW** | Dual-source (Chainlink + Uniswap TWAP); Redstone OEV integration; oracle DOS vector identified | S | Partial |
| Economic Mechanism | **MEDIUM** | Insurance pool exists but size undisclosed; novel 0.1% liquidation penalty untested in extreme conditions | S | Partial |
| Smart Contract | **LOW** | 7+ audits including Certora formal verification; zero exploits in 7+ year history | S/H | Y |
| Token Contract (GoPlus) | **LOW** | Proxy only (governance-controlled); no honeypot, no hidden owner, no tax | S | Y |
| Cross-Chain & Bridge | **MEDIUM** | Multi-chain on 5 chains; per-chain admin configuration unclear; bridge solution under evaluation | S/O | Partial |
| Off-Chain Security | **HIGH** | No SOC 2/ISO 27001; no published key management policy; no disclosed penetration testing | O | N |
| Operational Security | **LOW** | Doxxed founders with 7-year track record; active Immunefi bounty; rate-limiting mechanisms | S/H/O | Y |
| **Overall Risk** | **MEDIUM** | **Strong audit and track record offset by governance opacity, declining TVL, and missing off-chain security certifications** | | |

**Overall Risk aggregation**: 1 HIGH (Off-Chain Security) + 0 CRITICAL. Governance is MEDIUM (counts 2x = 2 MEDIUM). Total: 1 HIGH + multiple MEDIUM. Per rule: "1 category is HIGH, or 3+ are MEDIUM = Overall MEDIUM." Result: **MEDIUM**.

## Detailed Findings

### 1. Governance & Admin Key

**Admin Key Surface Area:**
- Fluid's core Liquidity Layer is controlled through an AdminModule that manages user classification, rate configurations, protocol whitelisting, and risk parameter changes.
- The AdminModule can add/remove protocols from the Liquidity Layer, change rate curves, set LTV ratios, and configure operational limits.
- A "Guardian" role exists as a security backstop that can pause subprotocol access to the Liquidity Layer in emergencies. At launch, all subprotocols are Class 0 (guardian-pausable). Over time, governance can upgrade them to Class 1 (guardian cannot pause).
- The Guardian pause does NOT require a timelock -- standard for emergency functions but expands the trust surface.

**Timelock Bypass Detection:**
- The Guardian role can bypass the governance timelock for pause actions only.
- This is LOW risk -- pause-only bypass is acceptable emergency design.
- Whether the Guardian can do anything beyond pausing (e.g., upgrade contracts, change parameters) is UNVERIFIED. If Guardian powers extend beyond pause, this would escalate to HIGH risk.

**Governance Process:**
- Uses Compound Bravo-style governance (deployed at 0x0204Cd037B2ec03605CFdFe482D8e257C765fA1B).
- Proposal threshold: 1% of FLUID supply (1M tokens).
- Quorum: 4% of FLUID supply.
- Voting period: ~3 days.
- Timelock delay: 2 days (48 hours) after vote passes before execution.
- FLUID token is fully unlocked as of 2025.

**Multisig:**
- A "community multisig" exists that can pause protocols in emergencies.
- Specific multisig address, threshold (m/n), and signer identities are NOT publicly documented. This is a significant transparency gap.
- On Solana (Jupiter Lend partnership), a 12-hour timelock multisig is jointly controlled by Jupiter and Fluid team signers.

**Token Concentration (from GoPlus):**
- Top holder: 22.05M FLUID (22.05%) -- smart contract (likely treasury/staking).
- Top 5 holders: ~42.7% -- all smart contracts.
- Top 10 holders: ~60% -- all smart contracts (treasuries, staking, vesting), not EOAs.
- This reduces whale governance attack risk but means governance power depends on who controls those contracts.

**Foundation Transition (2026):**
- A governance proposal seeks to transfer all IP to a non-profit Cayman Islands foundation.
- FLUID token holders would retain ultimate governance control.
- Legal work expected to complete by mid-2026 -- UNVERIFIED whether finalized.

**Rating: MEDIUM** -- Governance follows established patterns (Bravo, timelock). The 48h timelock is adequate. However, undisclosed multisig composition and Guardian signer identities create meaningful trust assumptions.

### 2. Oracle & Price Feeds

**Oracle Architecture:**
- Dual-source: Chainlink price feeds + Uniswap V3 TWAP checkpoints.
- Vault implements three separate TWAP checkpoints alongside Chainlink data.
- Cross-verification between sources: center price calculated from both, preventing manipulation through one feed alone.

**Redstone OEV Integration:**
- Gas-optimized oracle flow capturing Oracle Extractable Value (OEV) -- redirecting MEV from liquidations back to the protocol.

**Manipulation Resistance:**
- TWAP comparison with historical checkpoints prevents sudden price manipulation.
- Cantina audit confirmed: "an attacker cannot manipulate the price due to comparisons with old TWAPs."
- A Cantina finding noted that an attacker could DOS the oracle by changing tick values in every block by a minimal delta -- liveness risk, not fund-theft risk.

**Admin Oracle Control:**
- Whether admin can arbitrarily change oracle sources is UNVERIFIED. The AdminModule handles configurations, which likely includes oracle parameters.

**Rating: LOW** -- Dual-source oracle with TWAP cross-verification is robust. Oracle DOS vector was identified in audit. Redstone OEV integration is innovative.

### 3. Economic Mechanism

**Liquidation Mechanism:**
- Innovative tick-based liquidation: positions grouped by risk into "ticks" and liquidated in aggregate.
- Liquidation penalty as low as 0.1% (vs. 5-10% industry standard).
- Max LTV: up to 92% for uncorrelated pairs, 98.5% for correlated pairs.
- Liquidation is as gas-efficient as a simple swap -- can be integrated into DEX aggregators.

**Smart Collateral / Smart Debt:**
- Smart Collateral: vault collateral simultaneously serves as DEX liquidity, earning trading fees.
- Smart Debt: borrowed funds automatically deploy as DEX liquidity, with trading fees reducing borrow costs.
- This dual-use of capital is the core innovation but introduces correlation risk -- if DEX volume drops, the fee subsidy disappears while the risk remains.

**Insurance Pool:**
- An Insurance Pool exists for riskier collateral tiers -- absorbs bad debt before it reaches lenders.
- Blue-chip collateral (ETH, BTC, established stablecoins) does NOT go through insurance.
- Riskier collateral borrowers pay higher interest rates that fund the insurance pool.
- If insurance pool is exhausted, Fluid's own reserves serve as final backstop.
- **Size of the insurance pool is NOT publicly disclosed** -- this is a significant gap.

**Rate Limits & Circuit Breakers:**
- Automated limits dynamically adjust debt/collateral ceilings every block.
- Base withdrawal is unrestricted; beyond the base, capacity increases gradually (e.g., 20% over 24 hours).
- This limits bank-run scenarios and hack-related drains.

**Revenue:**
- Protocol revenue ~$1.5M/month (August 2025), ~$12M annualized on Ethereum.
- 100% of Ethereum mainnet revenue directed toward FLUID buybacks (as of October 2025).
- Team targets $10B market size and $30M annualized revenue.

**Rating: MEDIUM** -- Innovative liquidation mechanism with lower penalties is capital-efficient. However, 0.1% liquidation penalty may be insufficient to cover bad debt in extreme market conditions. Insurance pool existence is positive but undisclosed size is concerning. Novel Smart Collateral/Smart Debt introduces untested correlation risks.

### 4. Smart Contract Security

**Audit History:**
- 7+ professional audits across different components:
  - Statemind: Fluid Liquidity Layer (December 2023)
  - MixBytes: Fluid Vault Protocol (June 2024) -- "no dangerous vulnerabilities"
  - Cantina: Fluid DEX competitive audit (Sep-Oct 2024) -- 13 issues identified
  - MixBytes: Fluid DEX (December 2024)
  - Cantina: DEX report published (January 2025)
  - Certora: DEX V2 formal verification (February 2026)
  - OpenZeppelin: Legacy DSA contracts (2019)
- $500K security budget approved via governance for Certora formal verification (EVM + Solana codebase).
- All audits publicly available at docs.fluid.instadapp.io/audits-and-security.html.

**Notable Audit Findings (Cantina):**
- Division-by-zero bug in `_getPricesAndExchangePrices` (HIGH -- admin can resolve by updating center price address, downgraded to MEDIUM)
- Oracle DOS vector via minimal tick value changes per block (liveness risk)
- 13 total issues identified during competitive audit

**Bug Bounty:**
- Active Immunefi program covering Fluid Liquidity Layer, Lending, and Vault protocols.
- Maximum payout: $500,000 (10% of affected funds, capped).
- Scope: Fluid contracts excluding periphery folder.
- Payouts in stablecoins (USDC, USDT, DAI).

**Battle Testing:**
- 7+ years operational history (since 2019 as Instadapp, since Feb 2024 as Fluid).
- Zero dollars lost to smart contract vulnerabilities in entire history.
- No rekt.news entry for Fluid or Instadapp.
- Open source: all core contracts publicly available on GitHub.
- Code is highly gas-optimized, which auditors noted sacrifices some code clarity.

**Kelp rsETH Downstream Impact (April 18, 2026):**
- Fluid was NOT directly exploited but was affected as a downstream protocol.
- Fluid promptly froze rsETH markets after the Kelp bridge exploit.
- Bad debt exposure from rsETH on Fluid: UNVERIFIED (Aave took ~$196M; Fluid likely significantly less given smaller rsETH market).
- Response demonstrates operational readiness but highlights composability risk from accepting bridge-dependent collateral.

**Rating: LOW** -- Extensive audit coverage from reputable firms including formal verification, active bug bounty, open source code, and zero-exploit track record. The Kelp incident response was prompt and appropriate.

### 5. Cross-Chain & Bridge

**Multi-Chain Deployment:**
- Deployed on 5 chains: Ethereum (primary), Arbitrum, Base, Polygon, Plasma.
- Fluid DEX primarily on Ethereum, Arbitrum, and Polygon.
- Expanding to Solana via Jupiter Lend partnership.

**Bridge Solution:**
- A governance proposal evaluated bridge solutions for multi-chain FLUID token deployment.
- Chainlink CCIP was considered/selected as the cross-chain messaging solution.
- 0.25% of FLUID supply allocated to establish liquidity on L2s starting with Arbitrum.

**Per-Chain Admin Configuration:**
- Whether each chain has an independent admin multisig and independently configured risk parameters is UNVERIFIED.
- On Solana, governance uses a 12-hour timelock multisig jointly controlled by Jupiter and Fluid team signers.
- Ethereum is the governance home chain.

**Rating: MEDIUM** -- Use of Chainlink CCIP is a strong choice for cross-chain messaging. However, 5-chain deployment increases attack surface, and per-chain governance configuration is not transparently documented. The Kelp incident demonstrates real composability risk from bridge-dependent collateral accepted on lending markets.

### 6. Operational Security

**Team & Track Record:**
- Founded by Sowmay Jain (CEO) and Samyak Jain (CTO) -- fully doxxed brothers from Kota, Rajasthan, India.
- Samyak Jain: Forbes 30 under 30 India.
- Started at ETHIndia hackathon (August 2018), won the competition.
- Raised $12.4M from Pantera Capital and Naval Ravikant.
- 7+ year operational history with zero direct security incidents.

**Incident Response:**
- Guardian role can pause subprotocols immediately without timelock.
- Liquidity Layer automatically restricts abnormally large borrowings and withdrawals.
- Rate-limiting buys time for community multisig to intervene.
- Demonstrated response during Kelp incident (April 2026): rsETH market frozen promptly.
- No published formal incident response plan (common in DeFi, but a gap).

**Off-Chain Security:**
- No SOC 2 Type II or ISO 27001 certification found.
- No published key management policy (HSM, MPC, key ceremony).
- No disclosed penetration testing (infrastructure-level).
- No disclosed operational segregation or insider threat controls.
- Rating for off-chain controls: **HIGH risk** -- no certifications, no published security practices.

**Dependencies:**
- Chainlink (oracles + CCIP bridge)
- Uniswap (TWAP oracle data)
- Redstone (OEV oracle optimization)
- Jupiter (Solana deployment partner)
- Various integrated protocols via legacy DSA connectors

**Downstream Lending Exposure:**
- FLUID token itself is not widely accepted as collateral on other lending protocols (reducing cascade risk).
- However, Fluid accepts tokens from other protocols (including rsETH before the Kelp freeze), exposing it to upstream risks.

**Rating: LOW** (Operational Security overall) / **HIGH** (Off-Chain Security sub-category) -- Doxxed founders with strong track record and proven incident response. Off-chain security practices are opaque, which is common in DeFi but represents a real gap.

## Critical Risks

1. **Undisclosed insurance pool size** -- An insurance pool exists for riskier collateral but its size relative to TVL is not publicly reported. If a black swan event generates bad debt exceeding the pool, there is no documented secondary backstop beyond protocol reserves. (HIGH concern)
2. **Undisclosed multisig composition** -- Community multisig signer identities, address, and threshold are not publicly documented. This creates trust assumptions around emergency response. (MEDIUM concern)
3. **TVL declining sharply** -- 44.2% TVL decline over 90 days on Ethereum Lending. May reflect broader market conditions but warrants monitoring. (MEDIUM concern)
4. **No off-chain security certifications** -- No SOC 2, ISO 27001, published key management, or penetration testing. Standard for DeFi but a gap for a protocol managing ~$861M. (MEDIUM concern)
5. **Kelp composability exposure** -- Fluid was downstream-affected by the Kelp rsETH exploit (April 2026). While the team responded promptly by freezing the market, the incident highlights the risk of accepting bridge-dependent tokens as collateral. (MEDIUM concern)
6. **Novel liquidation mechanism untested in extreme conditions** -- The 0.1% liquidation penalty and 98.5% max LTV for correlated pairs have not been tested during a sustained market crash. (MEDIUM concern)

## Peer Comparison

| Feature | Fluid | Aave V3 | Compound V3 |
|---------|-------|---------|-------------|
| Timelock | 48h (governance) | 24h / 168h (dual) | 48h |
| Multisig | UNVERIFIED (community) | 6/10 (Guardian) | 4/6 |
| Audits | 7+ (Statemind, MixBytes, Cantina, Certora, OZ) | 10+ (Trail of Bits, Certora, Sigma Prime, etc.) | 5+ (Trail of Bits, OpenZeppelin) |
| Oracle | Chainlink + Uniswap TWAP + Redstone OEV | Chainlink + SVR fallback | Chainlink |
| Insurance/TVL | Undisclosed (pool exists) | ~2% (Safety Module) | ~1% (Reserves) |
| Open Source | Yes | Yes | Yes |
| Bug Bounty Max | $500K | $1M | $150K |
| Zero-Exploit Record | 7+ years | 6+ years (V3) | 6+ years |
| Liquidation Penalty | 0.1% (min) | 5-10% | 5-8% |
| Max LTV | 98.5% (correlated) | 93% (stablecoins) | 90% |
| Formal Verification | Certora (2026) | Certora (ongoing) | -- |
| Off-Chain Certs | None | None | None |

## Recommendations

- **For depositors/lenders**: Fluid Lending offers competitive yields and a strong security track record. The undisclosed insurance pool size is the primary risk -- consider diversifying across Aave and Compound. Prefer blue-chip collateral markets where the insurance pool is not needed.
- **For borrowers**: Fluid's 0.1% liquidation penalty and high LTV are industry-leading, but maintain conservative positions. The novel liquidation mechanism is untested in extreme crash scenarios.
- **For liquidity providers (DEX)**: Smart Collateral/Smart Debt earn additional fees but introduce correlation risk. If DEX volume drops, fee subsidy disappears while IL risk remains.
- **For governance participants**: Push for public disclosure of community multisig signer identities and threshold. Advocate for publishing insurance pool size and establishing a formal safety module. Request off-chain security certifications.
- **For all users**: Monitor the foundation transition (expected mid-2026). Prefer Ethereum mainnet as the most battle-tested deployment. Be cautious with bridge-dependent collateral types after the Kelp incident.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- UNVERIFIED; AdminModule handles configs
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED; likely requires governance
- [ ] Admin can modify withdrawal limits? -- Yes, via AdminModule, but rate-limited by design
- [x] Multisig has low threshold (2/N with small N)? -- UNVERIFIED; threshold not publicly disclosed
- [ ] Zero or short timelock on governance actions? -- No; 48h timelock on governance proposals
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A for EVM; Solana deployment via Jupiter has 12h timelock
- [x] Social engineering surface area (anon multisig signers)? -- Yes; multisig signer identities undisclosed

**2/7 flags triggered -- below 3-flag warning threshold.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- UNVERIFIED; tiered system exists but listing process not fully documented
- [ ] Single oracle source without TWAP? -- No; dual-source (Chainlink + TWAP)
- [ ] No circuit breaker on price movements? -- No; automated limits adjust every block
- [x] Insufficient insurance fund relative to TVL? -- Insurance pool exists but size undisclosed

**1/4 flags triggered -- below 3-flag warning threshold.**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No; uses Chainlink CCIP (decentralized)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

**0/3 flags triggered.**

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time (no snapshot)? -- UNVERIFIED; Bravo typically uses block-based snapshots
- [ ] Flash loans can be used to acquire voting power? -- Unlikely with Bravo snapshot design
- [ ] Proposal + execution in same block or short window? -- No; 48h timelock
- [ ] No minimum holding period for voting eligibility? -- UNVERIFIED

**0/4 flags triggered.**

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? -- UNVERIFIED
- [ ] Read-only reentrancy risk (cross-contract callbacks before state update)? -- UNVERIFIED; audited by multiple firms
- [ ] Flash loan compatible without reentrancy guards? -- UNVERIFIED; Immunefi scope includes flash loan attacks
- [ ] Composability with protocols that expose callback hooks? -- Yes (Smart Collateral/Smart Debt involve DEX integration)

**0-1/4 flags triggered.**

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler (Vyper, Huff)? -- No; Solidity
- [ ] Compiler version has known CVEs? -- UNVERIFIED
- [ ] Contracts compiled with different compiler versions? -- UNVERIFIED
- [ ] Code depends on language-specific behavior (storage layout, overflow)? -- No; standard Solidity patterns

**0/4 flags triggered.**

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral (own governance token)? -- No
- [ ] Redemption mechanism creates sell pressure on collateral? -- N/A
- [ ] Oracle delay could mask depegging in progress? -- TWAP mitigates
- [ ] No circuit breaker on redemption volume? -- Rate limits exist

**0/4 flags triggered.**

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses a cross-chain bridge for token minting or reserve release? -- Yes (Chainlink CCIP for FLUID distribution)
- [ ] Bridge message validation relies on a single messaging layer without independent verification? -- CCIP has multi-layer validation
- [ ] DVN/relayer/verifier configuration is not publicly documented? -- UNVERIFIED
- [x] Bridge can release or mint tokens without rate limiting? -- UNVERIFIED
- [x] Bridged/wrapped token accepted as collateral on lending protocols? -- Fluid accepted rsETH (now frozen post-Kelp)
- [ ] No circuit breaker to pause minting if bridge-released volume exceeds normal thresholds? -- Rate limits exist on Liquidity Layer
- [ ] Emergency pause response time > 15 minutes? -- Demonstrated prompt response during Kelp (exact time UNVERIFIED)
- [ ] Bridge admin controls under different governance than core protocol? -- UNVERIFIED
- [ ] Token deployed on 5+ chains via same bridge provider? -- 5 chains, but canonical native deployments, not bridge-minted

**2/9 flags triggered -- below 3-flag warning threshold.** However, the Kelp incident directly demonstrated this risk category's relevance to Fluid as a downstream protocol.

**Overall pattern match**: No single category triggers the 3-flag warning threshold. The primary exposure is through composability (accepting bridge-dependent collateral) rather than structural vulnerabilities.

## Information Gaps

The following questions could NOT be answered from publicly available information:

1. **Community multisig details**: What is the multisig address, threshold (m/n), and who are the signers? This is the single largest transparency gap.
2. **Insurance pool size**: How large is the insurance pool relative to TVL? What is the breakdown between collateral tiers?
3. **Per-chain admin configuration**: Does each chain deployment (Arbitrum, Base, Polygon) have an independent admin multisig and independently configured risk parameters?
4. **Guardian role specifics**: Who holds the Guardian role? Is it the same as the community multisig? Can the Guardian do anything beyond pausing?
5. **Oracle admin controls**: Can the AdminModule change oracle sources without a governance vote and timelock?
6. **Asset listing process**: What is the governance process for listing new collateral types? Is there a liquidity depth requirement?
7. **Admin key storage**: Are admin keys stored in cold wallets? Is there a key rotation policy?
8. **Formal incident response plan**: Is there a published plan with defined roles and communication channels?
9. **Foundation transition status**: Is the Cayman Islands foundation setup finalized? Who has interim governance authority?
10. **Class 0 vs Class 1 subprotocol status**: Which subprotocols have been upgraded to Class 1 (guardian cannot pause)?
11. **Kelp bad debt exposure**: How much bad debt did Fluid absorb from the rsETH market freeze?
12. **Smart Collateral/Smart Debt stress testing**: Has the dual-use liquidity mechanism been stress-tested under extreme market conditions?
13. **Off-chain security practices**: Key management, operational segregation, insider threat controls, penetration testing.
14. **DEX V2 audit status**: Are additional audits planned beyond the Certora formal verification completed in February 2026?

## Disclaimer

This analysis is based on publicly available information and web research as of April 20, 2026.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
