# DeFi Security Audit: BENQI

**Audit Date:** April 6, 2026
**Protocol:** BENQI -- Avalanche Lending + Liquid Staking

## Overview
- Protocol: BENQI (Lending Markets + sAVAX Liquid Staking)
- Chain: Avalanche C-Chain
- Type: Lending / Borrowing + Liquid Staking
- TVL: ~$470M combined (~$249M Lending, ~$221M sAVAX Liquid Staking)
- TVL Trend: +3.3% / -1.9% / -38.9% (7d / 30d / 90d, Lending); +2.5% / -0.8% / -37.7% (sAVAX)
- Launch Date: August 2021 (Lending); January 2022 (sAVAX)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: Benqi-fi)

## Quick Triage Score: 57/100

Starting at 100, the following deductions apply:

- MEDIUM: No documented timelock on admin actions (-8)
- MEDIUM: Multisig threshold < 4 signers for Markets component (-8)
- LOW: Single oracle provider (Chainlink only) (-5)
- LOW: Insurance fund / TVL undisclosed (-5)
- LOW: Undisclosed multisig signer identities (-5)
- LOW: No documented timelock on admin actions (-5)
- MEDIUM: TVL dropped >30% in 90 days (-8)

Deductions do not double-count: No timelock appears once as MEDIUM (-8) and is not re-counted as LOW.

Adjusted deductions: -8 (no timelock) -8 (low multisig for Markets) -5 (single oracle) -5 (insurance/TVL undisclosed) -5 (undisclosed signers) -8 (TVL drop >30% 90d) -5 (no documented timelock on admin, LOW) = Deducting -8 -8 -5 -5 -5 -8 = -39. But no timelock covers both the MEDIUM and LOW flags, so remove duplicate: -8 -8 -5 -5 -5 -8 = -39. Removing duplicate timelock LOW: -8 -8 -5 -5 -8 -5 = -39. Score floor re-check: unique flags only.

Flags applied:
- [ ] MEDIUM (-8): No documented timelock on upgrades or admin actions
- [ ] MEDIUM (-8): Multisig < 4 signers (Markets component, per Exponential DeFi)
- [ ] MEDIUM (-8): TVL dropped >30% in 90 days (both Lending and sAVAX)
- [ ] LOW (-5): Single oracle provider (Chainlink)
- [ ] LOW (-5): Insurance fund / TVL ratio undisclosed
- [ ] LOW (-5): Undisclosed multisig signer identities
- [ ] LOW (-5): DAO governance incomplete (progressive decentralization, not fully on-chain)

Total deductions: -44. **Quick Triage Score: 56/100** (MEDIUM risk band)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (reserve factor 20%) | 1-5% (Aave ~2%) | MEDIUM |
| Audit Coverage Score | 2.0 (Halborn 2021 = 0.25, Certora 2022 = 0.25, Dedaub 2023 = 0.5, Isolated Markets 2024 = 1.0) | Aave 9+ | MEDIUM |
| Governance Decentralization | Multisig-controlled, progressive DAO | Aave: full DAO + Guardian | MEDIUM |
| Timelock Duration | Not documented / 0h | Aave: 24h/168h | HIGH |
| Multisig Threshold | <4 signers (Markets) / 4+ (Liquid Staking) | Aave: 6/10 | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 0 MED | -- | LOW |

## GoPlus Token Security (QI on Avalanche, 0x8729438EB15e2C8B576fCc6AeCdA6A148776C0F5)

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
| Holders | 39,053 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No (0) | -- |
| Anti-Whale | Yes (1) | -- |
| CEX Listed | Binance | -- |

GoPlus assessment: **LOW RISK**. The QI token is clean -- no proxy, no mint function, no hidden owner, no tax, no trading restrictions. Anti-whale mechanism is present. Token is listed on Binance and has ~39K holders. LP is primarily on Trader Joe with ~$104K liquidity, which is relatively thin for a protocol of this TVL.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | No timelock; multisig <4 signers (Markets); signer identities undisclosed | Partial |
| Oracle & Price Feeds | **LOW** | Chainlink feeds; single provider but industry-standard | Y |
| Economic Mechanism | **MEDIUM** | Compound-style liquidation; insurance fund size undisclosed; 90d TVL decline ~39% | Partial |
| Smart Contract | **MEDIUM** | 4 audits but oldest are stale; Compound fork provides battle-tested base | Partial |
| Token Contract (GoPlus) | **LOW** | Clean token; no proxy, no mint, no hidden owner, no tax | Y |
| Cross-Chain & Bridge | **N/A** | Single-chain (Avalanche) with P-Chain staking bridge for sAVAX | -- |
| Operational Security | **MEDIUM** | Doxxed co-founders; Chaos Labs risk monitoring; Avalanche Foundation backing | Partial |
| **Overall Risk** | **MEDIUM** | **Established Avalanche-native protocol with governance gaps: no timelock, weak multisig for Markets, undisclosed insurance reserves** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**Admin Key Surface Area:**
- BENQI is a Compound V2 fork, inheriting the Comptroller-based admin architecture. The admin (typically the protocol team multisig) can:
  - List new markets / collateral types
  - Modify collateral factors, close factors, and liquidation incentives
  - Change oracle price feed sources
  - Pause borrowing/lending on individual markets
  - Upgrade protocol parameters

**Multisig Configuration:**
- **Markets (Lending/Borrowing):** Multisig with fewer than 4 signers (per Exponential DeFi analysis). This is below industry standard and increases centralization risk.
- **Liquid Staking (sAVAX):** Multisig with at least 4 signers, which is better but still below best-in-class protocols.
- Signer identities: NOT publicly disclosed. This is a risk signal -- anonymous multisig signers create social engineering surface area.

**Timelock:**
- No timelock has been publicly documented or verified for either the Markets or Liquid Staking components. This means admin actions (including parameter changes, market listings, and oracle changes) can be executed immediately without a delay for community review.
- This is one of the most significant governance gaps identified in this audit.

**Governance Process:**
- QI token enables governance voting on proposals (economic parameters, security upgrades, treasury allocations).
- BENQI has described "progressive decentralization" toward a full DAO, but as of audit date, governance remains heavily team-controlled.
- No public evidence of on-chain governance contracts with enforceable quorum or voting periods. UNVERIFIED whether governance proposals are binding on-chain or advisory-only.

**Token Concentration:**
- Top holder: 17.4% (contract address 0x142e...)
- Second holder: 16.3% (EOA 0x4aef...)
- Third holder: 15.0% (contract 0x9d6e...)
- Top 3 holders control ~48.7% of supply. Top 5 control ~61.3%.
- This concentration means a small number of entities could dominate governance votes if on-chain voting is implemented. The mix of contracts (likely treasury/staking) and EOAs warrants further investigation.

### 2. Oracle & Price Feeds -- LOW

**Oracle Architecture:**
- BENQI uses Chainlink price feeds natively on Avalanche as the primary oracle source, announced in May 2021.
- Initial feeds: AVAX/USD, LINK/USD, ETH/USD, wBTC/USD, USDT/USD, DAI/USD, with more added over time.
- Chainlink is the industry-standard oracle provider with multiple data sources and node operators.

**Strengths:**
- Chainlink's decentralized oracle network aggregates from hundreds of sources
- Price feeds are resistant to single-source manipulation
- Well-established on Avalanche with native integration

**Weaknesses:**
- Single oracle provider (no fallback to a secondary oracle like Pyth or Band)
- Admin can change oracle sources (no documented restriction or timelock on this action)
- No documented circuit breaker for abnormal price movements

**Assessment:** LOW risk overall due to Chainlink's reliability, but the lack of a fallback oracle and the admin's ability to change sources without timelock are minor concerns.

### 3. Economic Mechanism -- MEDIUM

**Liquidation Mechanism (Compound V2 style):**
- Health factor below 1 triggers liquidation
- Close factor: 50% (up to half of debt can be liquidated per transaction)
- Liquidation incentive: ~10% bonus for liquidators
- Collateral factors vary by asset (e.g., AVAX at 40%)
- Well-understood mechanism, battle-tested across dozens of Compound forks

**Reserve Factor & Insurance:**
- Reserve factor: 20% (20% of borrower interest accrues to protocol reserves)
- 3% of liquidated collateral is added to reserves
- Actual reserve/insurance fund size relative to TVL: NOT PUBLICLY DISCLOSED
- This is a significant information gap. Without knowing the reserve size, it is impossible to assess whether the protocol can absorb bad debt from a major liquidation cascade.

**Chaos Labs Integration:**
- BENQI has partnered with Chaos Labs for ongoing risk parameter recommendations
- Chaos Labs provides simulation-based analysis (Extreme VaR at 99th percentile) for bad debt scenarios
- Parameter recommendation dashboard is publicly accessible at community.chaoslabs.xyz/benqi
- This is a strong positive -- automated risk management is above average for Avalanche protocols

**TVL Decline:**
- 90-day TVL decline of ~39% (Lending) and ~38% (sAVAX) is notable
- Likely correlated with broader AVAX price movements and DeFi market rotation
- Peak TVL was $1.73B (Lending, Dec 2021) and $626M (sAVAX, Sep 2025); current combined ~$470M
- Not an immediate red flag but worth monitoring

**Interest Rate Model:**
- Standard Compound-style jump rate model
- Rates adjust algorithmically based on utilization
- Well-tested across the Compound fork ecosystem

### 4. Smart Contract Security -- MEDIUM

**Audit History:**
| Audit | Firm | Date | Scope | Age Score |
|-------|------|------|-------|-----------|
| Smart Contract Audit | Halborn | 2021 (pre-launch) | Core lending contracts | 0.25 |
| Liquid Staking Formal Verification | Certora | April 2022 | sAVAX contracts | 0.25 |
| Ignite Security Analysis | Dedaub | March 2023 | Ignite (validator staking) | 0.5 |
| Isolated Markets Audit | UNVERIFIED firm | 2024 | Isolated markets | 1.0 |
| Web App Pentest | Halborn | March 2022 | Web application & API | 0.25 |
**Audit Coverage Score: 2.25** (MEDIUM risk tier; threshold for LOW is >= 3.0)

**Key Observations:**
- The core lending contracts audit (Halborn, 2021) is now nearly 5 years old. While the Compound V2 codebase is well-audited across the ecosystem, any BENQI-specific modifications may have drifted from the audited code.
- Formal verification by Certora for sAVAX is a strong positive but is also 4+ years old.
- The 2024 isolated markets audit suggests ongoing security investment, but the auditing firm could not be verified from public sources.
- CORS vulnerability was identified in the Halborn web app pentest (API allows any website to trigger authenticated requests). Status of fix: UNVERIFIED.

**Bug Bounty (Immunefi):**
- Active program on Immunefi
- Scope: smart contracts, user fund loss, governance fund theft, DoS, DNS hijack, social media takeover
- Payouts in USDC/USDT; for amounts >= $50K, up to 80% may be in QI tokens
- Maximum payout amount: NOT PUBLICLY DOCUMENTED in search results
- Proof of concept required for all severities
- Immunefi Vulnerability Severity Classification System V2.2

**Battle Testing:**
- Live since August 2021 (~4.5 years)
- Peak TVL: $1.73B (Dec 2021)
- No known exploits or security incidents found on rekt.news or in general search
- Compound V2 fork provides a well-understood and widely-deployed codebase
- Open source (GitHub: Benqi-fi)

### 5. Cross-Chain & Bridge -- N/A (with caveat)

BENQI operates exclusively on Avalanche C-Chain for its lending and borrowing markets. However, the sAVAX liquid staking mechanism involves a cross-chain component:

- Users stake AVAX on C-Chain
- Protocol bridges staked AVAX to Avalanche P-Chain for validator delegation
- Bridge uses MPC (Multi-Party Computation) encryption
- sAVAX token remains on C-Chain

This P-Chain bridge is internal to the BENQI protocol and the Avalanche network. It is not a third-party bridge but does introduce a trust assumption on the MPC key management. The security of this bridge component is covered by the Certora formal verification (2022). Full bridge architecture details and MPC participant set are NOT PUBLICLY DOCUMENTED.

### 6. Operational Security -- MEDIUM

**Team & Track Record:**
- Co-founders: JD Gagnon, Hannu Kuusi, Alexander Szul -- doxxed with public profiles
- Team has maintained the protocol since August 2021 without major incidents
- Backed by Avalanche Foundation ($6M raise), Mechanism Capital, Dragonfly Capital, Arrington XRP Capital, Spartan Group
- Close relationship with Avalanche Foundation (joint $3M liquidity mining initiative)
- The Avalanche Foundation backing provides implicit institutional support but also raises questions about independence

**Incident Response:**
- Emergency pause capability exists (standard in Compound forks via Comptroller)
- No published incident response plan found
- Communication channels: Twitter (@BenqiFinance), Medium, Telegram announcements

**Risk Management:**
- Chaos Labs provides ongoing automated parameter monitoring and recommendations
- Chaos Labs risk dashboard with real-time alerts for risk conditions
- veQI economic analysis conducted by Chaos Labs
- This is a meaningful differentiator vs. most Avalanche-native protocols

**Dependencies:**
- Chainlink oracle feeds (critical)
- Avalanche network (C-Chain for lending, P-Chain for staking)
- Trader Joe and other DEXs for QI token liquidity
- sAVAX integration with Aave, Trader Joe, Pangolin, and other Avalanche DeFi protocols (composability risk)

## Critical Risks (if any)

No CRITICAL risks were identified. The following HIGH-concern findings warrant attention:

1. **No documented timelock on admin actions**: Admin can execute parameter changes, market listings, and oracle source changes immediately. In the event of key compromise, there is no delay for community detection and response.
2. **Markets multisig has fewer than 4 signers**: Combined with no timelock, this creates a narrow attack surface for key compromise or social engineering.
3. **Insurance/reserve fund size undisclosed**: Cannot assess protocol solvency buffer against cascading liquidation events.
4. **90-day TVL decline of ~39%**: While likely market-driven, sustained capital outflow reduces protocol health.

## Peer Comparison

| Feature | BENQI | Aave (Avalanche) | Compound V3 |
|---------|-------|-------------------|-------------|
| Timelock | None documented | 24h / 168h | 48h |
| Multisig | <4 (Markets) / 4+ (LST) | 6/10 Guardian | 4/9 community multisig |
| Audits (count) | 4-5 | 15+ | 10+ |
| Audit Coverage Score | 2.25 | 9+ | 6+ |
| Oracle | Chainlink (single) | Chainlink + SVR fallback | Chainlink |
| Insurance/TVL | Undisclosed | ~2% (Safety Module) | ~2% |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | Immunefi (max undisclosed) | Immunefi ($1M max) | Immunefi ($1M max) |
| Risk Manager | Chaos Labs | Chaos Labs + Gauntlet | Gauntlet |
| TVL (Avalanche) | ~$249M (lending) | ~$1.2B | N/A (not on AVAX) |

BENQI lags behind Aave significantly in governance infrastructure (no timelock, weaker multisig, no on-chain DAO) and audit depth. However, it leads as the dominant Avalanche-native lending protocol and has strong risk management via Chaos Labs.

## Recommendations

1. **For users depositing significant funds**: Monitor governance announcements closely. The absence of a timelock means changes can happen without advance notice. Consider diversifying across BENQI and Aave on Avalanche.
2. **For sAVAX stakers**: Understand that the P-Chain bridge introduces MPC trust assumptions. sAVAX liquidity on DEXs should be monitored for depegging risk during market stress.
3. **For QI governance participants**: Push for timelock implementation, multisig signer disclosure, and formal on-chain governance with enforceable quorum.
4. **For the BENQI team**: Implement a timelock (48h minimum, 7d for critical changes); increase Markets multisig to 4+ signers minimum; publish reserve fund balances; disclose multisig signer identities; commission a fresh audit of core lending contracts (last was 2021); publish the Immunefi bug bounty maximum payout.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? **YES** -- no documented timelock
- [x] Admin can change oracle sources arbitrarily? **LIKELY** -- no documented restriction
- [ ] Admin can modify withdrawal limits? UNVERIFIED
- [x] Multisig has low threshold (2/N with small N)? **YES** -- Markets multisig <4 signers
- [x] Zero or short timelock on governance actions? **YES** -- no documented timelock
- [ ] Pre-signed transaction risk (durable nonce on Solana)? N/A (EVM)
- [x] Social engineering surface area (anon multisig signers)? **YES** -- signer identities undisclosed

**5/6 applicable Drift-type indicators flagged.** This is a meaningful governance risk concentration. While BENQI benefits from a simpler architecture than Drift (no perps, no complex margin), the admin control surface is broad and unprotected by timelock or transparency.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? UNVERIFIED (Chaos Labs monitors parameters)
- [ ] Single oracle source without TWAP? Chainlink uses aggregation (not single-source)
- [x] No circuit breaker on price movements? **YES** -- no documented circuit breaker
- [x] Insufficient insurance fund relative to TVL? **UNKNOWN** -- fund size undisclosed

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? sAVAX uses MPC bridge (internal)
- [ ] Admin keys stored in hot wallets? UNKNOWN
- [ ] No key rotation policy? UNKNOWN

## Information Gaps

The following questions could NOT be answered from publicly available information. Each represents an unknown risk:

1. **Timelock contract**: Does a timelock exist on any admin action, or is it truly absent? No on-chain verification was performed.
2. **Multisig exact configuration**: What is the exact threshold (e.g., 2/3, 3/5) for the Markets multisig? Exponential DeFi reports <4 signers, but the exact number is not public.
3. **Multisig signer identities**: Who are the signers? Are they team members, advisors, or external parties?
4. **Reserve/insurance fund balance**: What is the actual USD value of accumulated reserves? Is it sufficient for a major liquidation cascade?
5. **sAVAX MPC bridge participants**: Who participates in the MPC ceremony for the P-Chain bridge? What is the threshold?
6. **Oracle change governance**: Can the admin change Chainlink feed addresses unilaterally, or is there any restriction?
7. **Emergency pause scope**: Can the admin pause withdrawals (not just new borrowing)?
8. **Bug bounty maximum payout**: What is the maximum reward for critical vulnerabilities?
9. **Code drift from audited version**: How much has the lending codebase changed since the 2021 Halborn audit?
10. **On-chain governance status**: Are governance votes binding on-chain, or purely advisory with team execution?
11. **Validator selection for sAVAX**: What criteria govern validator selection? Can the team delegate to related validators?

## Disclaimer

This analysis is based on publicly available information and web research as of April 6, 2026. It is NOT a formal smart contract audit. Always DYOR and consider professional auditing services for investment decisions. DeFiLlama and GoPlus API data were retrieved on the audit date. On-chain verification of multisig, timelock, and contract state was NOT performed for this assessment.
