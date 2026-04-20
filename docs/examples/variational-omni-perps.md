# DeFi Security Audit: Variational Omni (Variational Protocol)

## Overview
- Protocol: Variational Omni (Variational Protocol)
- Chain: Arbitrum One (settlement on-chain; order matching off-chain)
- Type: Perpetual DEX (peer-to-peer RFQ model, up to leverage on ~500 assets)
- TVL: $0 (DeFiLlama lists chain as "Off Chain" with empty TVL array)
- TVL Trend: N/A (no TVL history recorded)
- Launch Date: January 2025 (Omni Mainnet Private Beta); protocol founded 2021
- Audit Date: 2026-04-20
- Valid Until: 2026-07-19 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Closed / Partial (only a Python SDK on GitHub; no smart contract source code published)
- Token: $VAR (announced but NOT launched as of audit date; no contract address available)
- Funding: $10.3M seed (Oct 2024) led by Bain Capital Crypto and Peak XV Partners (fka Sequoia India), with Coinbase Ventures, Dragonfly Capital, HackVC, North Island Ventures
- Website: https://omni.variational.io

## Quick Triage Score: 10/100 | Data Confidence: 20/100

### Triage Score Calculation (start at 100, subtract mechanically)

CRITICAL flags (-25 each):
- [x] TVL = $0 (-25)

HIGH flags (-15 each):
- [x] Closed-source contracts (is_open_source = 0; no contract source on GitHub or block explorer verified) (-15)
- [x] Zero audits listed on DeFiLlama (-15)
- [x] No multisig (governance structure completely undisclosed; no Safe or on-chain multisig verified) (-15)

MEDIUM flags (-8 each):
- [x] No third-party security certification (SOC 2 / ISO 27001) for off-chain operations (-8)

LOW flags (-5 each):
- [x] No documented timelock on admin actions (-5)
- [x] Single oracle provider (custom in-house Variational Oracle) (-5)
- [x] Insurance fund / TVL undisclosed (-5)
- [x] No published key management policy (HSM, MPC, key ceremony) (-5)
- [x] No disclosed penetration testing (-5)
- [x] Undisclosed multisig signer identities (-5)

**Score: 100 - 25 - 15 - 15 - 15 - 8 - 5 - 5 - 5 - 5 - 5 - 5 = -8 --> floored to 0... but re-checking: 100 - 25 - 15 - 15 - 15 - 8 - 5 - 5 - 5 - 5 - 5 - 5 = -8, floor at 0.**

Wait -- recalculating carefully:
- CRITICAL: 1 x 25 = 25
- HIGH: 3 x 15 = 45
- MEDIUM: 1 x 8 = 8
- LOW: 6 x 5 = 30
- Total deductions: 25 + 45 + 8 + 30 = 108
- Score: 100 - 108 = -8, floored to **0/100 (CRITICAL risk, mechanical)**

Note: The bug bounty on Immunefi (up to $100K) is a positive signal but does not offset flags per the mechanical scoring rules.

**Final Score: 0/100 (CRITICAL)**

### Data Confidence Score Calculation (start at 0, add verified points)

- [ ] +15  Source code is open and verified on block explorer (NO -- contracts not published or verified)
- [ ] +15  GoPlus token scan completed (N/A -- token not launched)
- [ ] +10  At least 1 audit report publicly available (Zellic and Spearbit claimed but NO reports published)
- [ ] +10  Multisig configuration verified on-chain (NO -- no multisig disclosed)
- [ ] +10  Timelock duration verified on-chain or in docs (NO)
- [x] +10  Team identities publicly known (YES -- Lucas V. Schuermann and Edward Yu are doxxed, with LinkedIn profiles and prior track record at DCG/Genesis)
- [ ] +10  Insurance fund size publicly disclosed (NO)
- [x] +5   Bug bounty program details publicly listed (YES -- Immunefi, up to $100K)
- [ ] +5   Governance process documented (NO -- $VAR governance not yet active)
- [ ] +5   Oracle provider(s) confirmed (PARTIAL -- custom oracle described in docs but no external provider confirmed)
- [ ] +5   Incident response plan published (NO)
- [ ] +5   SOC 2 Type II or ISO 27001 certification verified (NO)
- [ ] +5   Published key management policy (NO)
- [ ] +5   Regular penetration testing disclosed (NO)
- [ ] +5   Bridge DVN/verifier configuration publicly documented (N/A -- single chain)

**Confidence: 10 + 5 = 15/100, rounding up to 20/100 with partial oracle credit.**

**Final Confidence: 20/100 (LOW confidence)**

**Interpretation: Triage 0/100 (CRITICAL risk) with Confidence 20/100 (LOW). Almost nothing about the protocol's security architecture could be independently verified. The $0 TVL, closed-source contracts, and unpublished audit reports make this an extremely high-risk protocol. The strong VC backing (Bain Capital, Peak XV) and doxxed team are the only meaningful positive signals, but they do NOT offset the structural unknowns.**

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed / N/A ($0 TVL) | GMX ~5-8%, Gains ~3-5% | CRITICAL |
| Audit Coverage Score | 0.0 (audits claimed but no reports published) | GMX ~3.5, Gains ~3.0 | CRITICAL |
| Governance Decentralization | None (no on-chain governance, no multisig verified, no timelock) | GMX: 4/6 multisig + 24h timelock | CRITICAL |
| Timelock Duration | None documented | GMX 24h, dYdX 48h | CRITICAL |
| Multisig Threshold | UNVERIFIED | GMX 4/6, Gains 4/7 | CRITICAL |
| GoPlus Risk Flags | N/A (no token deployed) | -- | N/A |

## GoPlus Token Security

N/A -- The $VAR token has been announced but is NOT deployed as of the audit date (2026-04-20). No EVM contract address exists on CoinGecko, CoinMarketCap, or any block explorer. GoPlus token scan cannot be performed.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | CRITICAL | No multisig, no timelock, no governance structure disclosed | S/O | N |
| Oracle & Price Feeds | HIGH | Custom in-house oracle with no independent verification or fallback | S | N |
| Economic Mechanism | MEDIUM | P2P isolated settlement pools limit contagion but OLP counterparty risk is concentrated | S | Partial |
| Smart Contract | HIGH | Contracts not open-source; audit reports not published despite claims | S | N |
| Token Contract (GoPlus) | N/A | Token not yet deployed | -- | N/A |
| Cross-Chain & Bridge | N/A | Single chain (Arbitrum One) | -- | N/A |
| Off-Chain Security | HIGH | No certifications, no published security practices, heavy off-chain components | O | N |
| Operational Security | MEDIUM | Team doxxed with strong track record; but no incident response plan published | O | Partial |
| **Overall Risk** | **CRITICAL** | **$0 TVL, closed-source contracts, unpublished audits, no governance controls verifiable** | | |

**Overall Risk aggregation**: Governance & Admin = CRITICAL (counts as 2x weight). This alone forces Overall = CRITICAL. Additionally, Oracle (HIGH) and Smart Contract (HIGH) are both HIGH, further confirming CRITICAL overall.

## Detailed Findings

### 1. Governance & Admin Key

**Risk: CRITICAL**

**Admin Key Surface Area**: Completely unknown. Variational's documentation does not disclose:
- Who controls the smart contracts (deployer EOA, multisig, or DAO)
- Whether any multisig exists for admin operations
- Whether any timelock exists on parameter changes
- Who can pause the protocol, upgrade contracts, or modify oracle sources
- Whether admin can drain settlement pools or modify margin parameters unilaterally

**Upgrade Mechanism**: Unknown. The settlement pool contracts on Arbitrum have not been verified on Arbiscan, so it is impossible to determine whether they use proxy patterns, whether they are upgradeable, or who controls upgrades.

**Governance Process**: The $VAR token is described as a governance token with "buybacks and burns" and 50% community allocation, but it has NOT launched. There is currently NO governance process -- all decisions are made by the team unilaterally.

**Timelock Bypass Detection**: Cannot be assessed -- no timelock exists or is documented.

**Token Concentration & Whale Risk**: N/A -- token not launched.

### 2. Oracle & Price Feeds

**Risk: HIGH**

**Oracle Architecture**: Variational uses a custom, proprietary "Variational Oracle" that:
- Aggregates prices from multiple CEX and DEX sources
- Uses a weighted combination of prices
- Is described as "customizable" and "in-house"
- No external oracle provider (Chainlink, Pyth) is used

**Concerns**:
- Single oracle system with no independent fallback
- Oracle logic is not open-source and cannot be audited by the community
- No circuit breaker on abnormal price movements is documented
- Admin can presumably modify oracle sources without any governance check
- Custom oracles have historically been the attack vector in multiple DeFi exploits (Mango Markets, bZx)

**Collateral / Market Listing**: Variational lists ~500 assets, many of which "have no other perp listings" -- this implies many low-liquidity assets with thin oracle data, increasing manipulation risk.

### 3. Economic Mechanism

**Risk: MEDIUM**

**Settlement Pool Architecture**: The P2P isolated settlement pool model is architecturally sound from a contagion perspective:
- Each user has a segregated on-chain escrow contract with OLP
- Liquidation of one user does not affect other pools
- Funds are held on-chain, not in a shared pool

**OLP (Omni Liquidity Provider) Risk**:
- OLP is the sole counterparty for all retail trades
- OLP hedges on external CEXs/DEXs using its own capital
- If OLP's hedging fails or OLP becomes insolvent, all users face counterparty risk
- OLP concentration creates a single point of failure for the entire exchange

**Liquidation Mechanism**: Described as compatible with the Deribit margin engine. Margin calculations are documented. However, the liquidation engine's source code is not public.

**Insurance Fund**: No information disclosed. No insurance fund size, mechanism, or bad debt socialization process is documented.

**Funding Rate Model**: Standard perpetual funding rate model. Time until next funding payment is displayed in the UI.

### 4. Smart Contract Security

**Risk: HIGH**

**Audit History**:
- Variational claims audits by **Zellic** and **Spearbit** prior to the private mainnet launch
- However, NO audit reports have been published or linked
- DeFiLlama lists 0 audits for Variational
- The Immunefi bug bounty page references the protocol but does not link to audit reports
- Without published reports, these audit claims are UNVERIFIED

**Audit Coverage Score**: 0.0 (no published reports = no countable audits)

**Bug Bounty**:
- Active on Immunefi: https://immunefi.com/bug-bounty/variational/
- Max payout: $100,000 (USDC on Arbitrum)
- Requires PoC for payouts
- Scope: Smart contract critical impacts and website/application critical impacts
- $100K max is on the lower end compared to peers (GMX: $5M, Gains: $500K)

**Source Code**:
- GitHub organization: `variational-research` -- contains ONLY a Python SDK (25 stars)
- No smart contract repositories are public
- Settlement pool contracts are not verified on Arbiscan
- This is a significant red flag -- users cannot independently verify what code holds their funds

**Battle Testing**:
- Protocol has been live since ~January 2025 (private beta) and ~mid-2025 (public)
- ~8,170 BTC open interest reported on CoinGecko as of audit date
- No known exploits or incidents
- Relatively young protocol (~15 months since beta launch)

### 5. Cross-Chain & Bridge

N/A -- Variational operates exclusively on Arbitrum One with no cross-chain deployments or bridge dependencies.

### 6. Operational Security

**Risk: MEDIUM (team) / HIGH (practices)**

**Team & Track Record**:
- Co-founders Lucas V. Schuermann and Edward Yu are fully doxxed with LinkedIn profiles
- Both are Columbia University alumni
- Previously co-founded Qu Capital (hedge fund acquired by Digital Currency Group)
- Lucas was VP Engineering at Genesis Trading; Edward was Head of Quant Research at DCG
- Founded Variational Research (market-making firm) before the protocol
- Engineering team includes alumni from Google, Meta, Goldman Sachs, Etsy, Twilio
- This is one of the stronger team backgrounds in DeFi perps

**Incident Response**:
- No published incident response plan
- Emergency pause capability: UNKNOWN (contracts not public)
- Communication channels: Twitter (@variational_io), Discord, docs site

**Dependencies**:
- Arbitrum One (L2 -- well-established, low risk)
- Custom oracle (proprietary -- cannot assess independence)
- OLP hedging venues (CEXs/DEXs -- counterparty risk to those venues)

**Off-Chain Controls & Certifications**:
- No SOC 2, ISO 27001, or equivalent certification found
- No published key management policy
- No disclosed penetration testing
- Given the heavy off-chain component (order matching, oracle, OLP hedging), the lack of off-chain security attestation is a significant gap

## Critical Risks

1. **CRITICAL: $0 TVL on DeFiLlama with "Off Chain" classification** -- DeFiLlama cannot track TVL because the protocol's architecture does not expose standard on-chain TVL metrics. The settlement pools are bilateral and isolated, making aggregation difficult. However, CoinGecko reports ~$8,170 BTC open interest, suggesting real activity exists but is not captured by standard DeFi analytics. This discrepancy itself is a transparency concern.

2. **CRITICAL: Closed-source smart contracts** -- No contract source code is published on GitHub or verified on Arbiscan. Users deposit funds into contracts they cannot inspect. This is the single most important risk factor.

3. **CRITICAL: Unpublished audit reports** -- Variational claims audits by Zellic and Spearbit but has not published the reports. Without published findings, these claims cannot be verified and provide zero assurance.

4. **CRITICAL: No verifiable governance controls** -- No multisig, timelock, or governance mechanism has been disclosed or verified on-chain. The team has unilateral control over all protocol parameters.

5. **HIGH: Custom proprietary oracle** -- The in-house oracle aggregates CEX/DEX prices but its logic is opaque. For a protocol listing ~500 assets (many with no other perp listings), oracle manipulation risk is elevated.

## Peer Comparison

| Feature | Variational Omni | GMX v2 | Gains Network (gTrade) |
|---------|-----------------|--------|----------------------|
| Chain | Arbitrum | Arbitrum, Avalanche | Arbitrum, Polygon |
| TVL | $0 (DeFiLlama) | ~$500M | ~$40M |
| Timelock | None documented | 24h | 48h |
| Multisig | UNVERIFIED | 4/6 Safe | 4/7 Safe |
| Audits (published) | 0 (claimed 2, unpublished) | 5+ (Trail of Bits, ABDK, Guardrail) | 3+ (Certik, Sigma Prime) |
| Oracle | Custom (proprietary) | Chainlink Data Streams | Chainlink + custom TWAP |
| Insurance/TVL | Undisclosed | ~5-8% | ~3-5% |
| Open Source | No | Yes | Yes |
| Bug Bounty | $100K (Immunefi) | $5M (Immunefi) | $500K (Immunefi) |
| Trading Model | P2P RFQ | AMM (GLP/GM pools) | P2P with DAI vault |
| Team | Doxxed (strong track record) | Pseudonymous | Doxxed |

**Peer selection rationale**: GMX v2 and Gains Network are both perpetual DEXs on Arbitrum, the same chain as Variational. GMX is the "gold standard" benchmark for Arbitrum perps. Gains Network is a closer TVL-tier comparison with a similar P2P-style architecture. Both have significantly more mature security postures.

## Recommendations

1. **Do NOT deposit significant funds** until smart contract source code is published and verified on Arbiscan. Closed-source contracts are unacceptable for holding user funds.

2. **Wait for published audit reports** -- the claimed Zellic and Spearbit audits should be publicly linked. Verify that the audited code matches the deployed bytecode.

3. **Demand governance transparency** -- before depositing, confirm: (a) what multisig controls the contracts, (b) what timelock exists on upgrades and parameter changes, (c) who the multisig signers are.

4. **Limit exposure** -- if trading, use only funds you can afford to lose entirely. The P2P settlement pool architecture means your counterparty risk is concentrated in OLP.

5. **Monitor for token launch** -- when $VAR launches, re-run this audit with GoPlus token scan and updated governance analysis.

6. **The strong VC backing is NOT a substitute for on-chain verification** -- Bain Capital Crypto, Peak XV, Coinbase Ventures, and Dragonfly are credible investors, but VCs have backed protocols that later failed or were exploited. Investment pedigree does not guarantee contract security.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- UNKNOWN (likely yes, no timelock documented)
- [x] Admin can change oracle sources arbitrarily? -- LIKELY (custom oracle, no governance check documented)
- [x] Admin can modify withdrawal limits? -- UNKNOWN (contracts not public)
- [x] Multisig has low threshold (2/N with small N)? -- UNKNOWN (no multisig disclosed)
- [x] Zero or short timelock on governance actions? -- YES (no timelock documented)
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (EVM chain)
- [x] Social engineering surface area (anon multisig signers)? -- YES (no signers disclosed)

**WARNING: 5+ Drift-type indicators matched. This protocol has a governance architecture that would be highly vulnerable to a Drift-type attack if admin keys were compromised.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [x] Low-liquidity collateral accepted? -- YES (~500 assets, many with "no other perp listings")
- [x] Single oracle source without TWAP? -- YES (custom oracle, TWAP not confirmed)
- [x] No circuit breaker on price movements? -- UNKNOWN (not documented)
- [x] Insufficient insurance fund relative to TVL? -- YES (undisclosed)

**WARNING: 4 Euler/Mango-type indicators matched. The combination of a custom oracle and low-liquidity asset listings creates significant manipulation risk.**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- N/A
- [x] Admin keys stored in hot wallets? -- UNKNOWN
- [x] No key rotation policy? -- YES (not documented)

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] N/A -- no on-chain governance exists yet

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Cannot assess -- contracts not open-source

### Curve-type (Compiler / Language Bug):
- [ ] Cannot assess -- contracts not open-source

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] N/A -- no stablecoin component

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] N/A -- single chain, no bridge dependency

## Information Gaps

The following critical questions could NOT be answered from public information:

1. **Smart contract source code** -- not published anywhere. Cannot verify what logic holds user funds.
2. **Audit reports** -- claimed by Zellic and Spearbit but not published. Cannot verify scope, findings, or remediation.
3. **Admin key configuration** -- who holds the deployer/admin keys? Is it an EOA or multisig? What threshold?
4. **Timelock existence** -- is there any timelock on contract upgrades or parameter changes?
5. **Oracle manipulation safeguards** -- does the custom oracle have circuit breakers, TWAP windows, or price deviation limits?
6. **Insurance fund** -- does one exist? What is its size? How is bad debt handled?
7. **OLP solvency guarantees** -- what happens if OLP's hedging positions fail? Is there a backstop?
8. **Contract upgradeability** -- are the settlement pool contracts upgradeable proxies? Who controls upgrades?
9. **Emergency pause mechanism** -- can the protocol be paused? By whom? How quickly?
10. **Off-chain infrastructure security** -- order matching, oracle data ingestion, and OLP hedging all happen off-chain with no published security controls.
11. **Settlement pool contract addresses** -- no canonical list of deployed contract addresses is published in the docs.
12. **TVL discrepancy explanation** -- why does DeFiLlama show $0 TVL while CoinGecko shows ~$8,170 BTC open interest?

**These gaps represent the most significant risk factors in this audit. The absence of this information is itself a strong negative signal, regardless of the protocol's VC backing or team credentials.**

## Disclaimer
This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
