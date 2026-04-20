# DeFi Security Audit: Ostium

**Audit Date:** April 20, 2026
**Protocol:** Ostium -- RWA Perpetual DEX on Arbitrum

## Overview
- Protocol: Ostium (V2)
- Chain: Arbitrum
- Type: Perpetual DEX (Derivatives)
- TVL: ~$59.6M
- TVL Trend: +4.7% / -36.2% / -5.7% (7d / 30d / 90d)
- Launch Date: July 2024 (mainnet on Arbitrum)
- Audit Date: April 20, 2026
- Valid Until: July 19, 2026 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Open (GitHub: 0xOstium/smart-contracts-public, MIT license)

## Quick Triage Score: 36/100 (HIGH) | Data Confidence: 45/100 (LOW)

**Triage Score Calculation (mechanical, start at 100):**

| Flag | Severity | Deduction |
|------|----------|-----------|
| No multisig verified (governance config undisclosed) | HIGH | -15 |
| Proxy contracts with timelock unverified on-chain | MEDIUM | -8 |
| TVL dropped >30% in 30 days (~36.2% drop) | MEDIUM | -8 |
| No third-party security certification (SOC 2 / ISO 27001) | MEDIUM | -8 |
| Single oracle provider for RWA feeds (Stork) | LOW | -5 |
| Insurance fund / TVL undisclosed | LOW | -5 |
| Undisclosed multisig signer identities | LOW | -5 |
| No published key management policy | LOW | -5 |
| No disclosed penetration testing | LOW | -5 |
| **Total** | **1H + 3M + 5L** | **-64** |

**Final Score: 36/100 (HIGH risk)**

Note: The low score is driven primarily by lack of public disclosure of governance configuration, not by confirmed vulnerabilities. If Ostium publicly discloses a multisig configuration with adequate threshold and timelock durations, the score would improve to ~51 (MEDIUM).

- Red flags found: 9 (1 HIGH, 3 MEDIUM, 5 LOW)
- Data points verified: 5 / 15 checkable

**Data Confidence Score (start at 0):**

| Data Point | Status | Points |
|------------|--------|--------|
| Source code open and verified | YES (GitHub, MIT) | +15 |
| GoPlus token scan | N/A (no token) | -- |
| Audit report publicly available | YES (Zellic, ThreeSigma, Pashov, Octane) | +10 |
| Multisig verified on-chain | NOT VERIFIED | +0 |
| Timelock duration verified | NOT VERIFIED (exists in code, duration unknown) | +0 |
| Team identities doxxed | YES (Kiernan-Linn, Ribeiro) | +10 |
| Insurance fund size disclosed | NO (buffer exists, size unknown) | +0 |
| Bug bounty listed | YES (Immunefi, $200K) | +5 |
| Governance process documented | NO ("coming soon") | +0 |
| Oracle providers confirmed | YES (Stork + Chainlink) | +5 |
| Incident response plan | NO | +0 |
| SOC 2 / ISO 27001 | NO | +0 |
| Key management policy | NO | +0 |
| Penetration testing | NO | +0 |
| **Total** | | **45/100** |

**Confidence: 45/100 (LOW)** -- Most governance and operational claims are unverified. A triage score of 36 with confidence of 45 means significant unknowns remain. Treat with skepticism.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (buffer mechanism) | 1-5% (GMX: ~3%) | HIGH risk |
| Audit Coverage Score | 4.5 (6 audits, most <1yr old) | 2-3 avg | LOW risk |
| Governance Decentralization | Undisclosed (timelock in code, gov address unknown) | Multisig + timelock avg | HIGH risk |
| Timelock Duration | UNVERIFIED (exists in code) | 24-48h (GMX: 24h) | UNVERIFIED |
| Multisig Threshold | UNVERIFIED | 3/5 - 4/6 avg | UNVERIFIED |
| GoPlus Risk Flags | N/A (no token) | -- | N/A |

**Audit Coverage Score calculation:**
- Zellic audit #1 (pre-2025, est. 2024): 0.5
- Zellic audit #2 (November 2025): 1.0
- ThreeSigma (pre-mainnet, est. 2024): 0.5
- Pashov audit #1 (January 2025): 1.0
- Pashov audit #2 (January 2025): 1.0
- Pashov audit #3 (April 2025): 1.0
- Octane ARE (2025-2026): 0.5 (adversarial research, not traditional audit)
- Chaos Labs economic audit (pre-launch): 0.25
Total: 5.75 --> Rating: LOW risk (>= 3.0)

## GoPlus Token Security

N/A -- Ostium does not currently have a governance or utility token on any EVM chain. The DeFiLlama listing shows `symbol: "-"` and `gecko_id: null`. No GoPlus scan applicable.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **HIGH** | Governance address, multisig config, and timelock durations are entirely undisclosed | S/O | N |
| Oracle & Price Feeds | **MEDIUM** | Custom in-house RWA oracle via Stork; no documented fallback or circuit breaker | S | Partial |
| Economic Mechanism | **MEDIUM** | Buffer mechanism replaces insurance fund; sizing and stress-test results undisclosed | S | Partial |
| Smart Contract | **LOW** | 6+ audits (Zellic, ThreeSigma, Pashov, Octane), open source, critical findings fixed | S/H | Y |
| Token Contract (GoPlus) | **N/A** | No token exists | -- | -- |
| Cross-Chain & Bridge | **N/A** | Single-chain (Arbitrum only) | -- | -- |
| Off-Chain Security | **HIGH** | No SOC 2, no published key management, no disclosed pentest | O | N |
| Operational Security | **MEDIUM** | Doxxed team with strong backgrounds; but no published incident response plan | O | Partial |
| **Overall Risk** | **HIGH** | **Strong audit coverage but critical governance opacity; admin configuration entirely undisclosed** | | |

**Overall Risk aggregation:**
1. Governance & Admin = HIGH (counts as 2x weight = 2 HIGHs)
2. 2+ categories HIGH (Governance 2x + Off-Chain) --> Overall = HIGH
3. Cross-Chain and Token are N/A, excluded from count.

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Admin Key Surface Area:**
- The protocol implements a three-tier role hierarchy: Governance (`registry.gov()`), Manager (`registry.manager()`), and Developer (`registry.dev()`)
- **Governance** can: update any contract address in the registry (effectively upgrade all contracts), change protocol parameters, register oracle forwarders, permanently disable contracts via `isDone`
- **Manager** can: pause/unpause trading, tune pair parameters (fees, OI caps, leverage limits)
- **Developer** can: collect fees, debugging functions
- All roles resolve dynamically through `OstiumRegistry` -- changing the registry governance address transfers full control

**Multisig:**
- UNVERIFIED. No public disclosure of whether the governance address is an EOA, multisig, or other structure
- No Safe address documented for any admin role
- The testnet deployment shows a `TimeLockOwner` contract at `0xbc7B65D3Aa1C38B39AC63f131D5245C51b83acbc` but no mainnet equivalent is listed

**Timelock:**
- Two timelock wrappers exist in the codebase: `OstiumTimelockOwner` (for registry-level changes) and `OstiumTimelockManager` (for operational changes)
- Both use OpenZeppelin's `TimelockController`
- **Duration is not publicly documented and could not be verified on-chain** (Arbiscan API key unavailable)
- The mainnet contract list does NOT include timelock addresses, raising questions about whether they are deployed

**Upgrade Mechanism:**
- The `OstiumRegistry` pattern enables instant contract upgrades: governance calls `updateContractAddress()` and all dependent contracts immediately resolve to the new implementation
- A `ProxyAdmin` contract exists at `0x083F97BabF33D4abC03151B5DEc98170761f4025` on mainnet
- This is effectively an upgradeable proxy system, but the upgrade authority chain (ProxyAdmin -> owner -> timelock? -> multisig?) is undisclosed

**Governance Process:**
- No on-chain governance (no token, no DAO)
- Documentation states governance is "working towards a gradual transition to increasingly community-driven governance"
- Currently fully centralized admin control

**Timelock Bypass Detection:**
- Cannot assess -- bypass roles and emergency powers are undisclosed
- The `isDone` flag allows governance to permanently disable the Trading contract (emergency shutdown), but no documentation on who can trigger this or under what conditions

### 2. Oracle & Price Feeds -- MEDIUM

**Oracle Architecture:**
- Dual-provider system: Stork Network (custom RWA feeds) + Chainlink Data Streams (crypto feeds)
- Pull-based architecture: prices only written on-chain when needed for trade execution
- Sub-second update latency from both providers
- Custom aggregation logic for RWA assets handles market hours, holidays, bid/ask spreads

**RWA-Specific Risks:**
- The custom oracle is architecturally novel and less battle-tested than standard Chainlink feeds
- Stork Network operates the node infrastructure for RWA feeds -- single infrastructure provider for majority of assets
- Price gaps at market open/close present manipulation windows unique to RWA perps
- Holiday session handling adds complexity not present in crypto-only DEXes

**Fallback Mechanism:**
- Not documented. No public information on what happens if Stork Network goes down
- For crypto feeds, Chainlink Data Streams are well-established, but no documented fallback

**Circuit Breaker:**
- Not documented. No public information on price movement limits or circuit breakers
- Market open/close metadata is consumed by contracts, but behavior during extreme gaps unclear

**Admin Override:**
- Governance can register new oracle forwarders, effectively changing price sources
- Whether this is behind a timelock is UNVERIFIED

### 3. Economic Mechanism -- MEDIUM

**Liquidation Mechanism:**
- Liquidations executed by Chainlink Automation and Gelato Functions (decentralized keepers)
- Dual-keeper system provides redundancy for liquidation execution
- Take-profit, stop-loss, and limit orders also executed via `OstiumTradesUpKeep`
- Keeper-based execution is standard for modern perps protocols

**Buffer / Insurance Design:**
- No traditional insurance fund. Instead, a two-tiered liquidity layer:
  - **Buffer**: absorbs trader P&L when vault is overcollateralized (c-ratio >= 100%)
  - **OLP Vault**: LPs directly absorb trader P&L when undercollateralized (c-ratio < 100%)
- In undercollateralized state, LPs are fully exposed to trader gains -- this is the counterparty risk
- Buffer size is not publicly disclosed

**Bad Debt Handling:**
- Socialized loss model: when buffer is depleted, LP depositors absorb losses
- No external insurance fund backstop
- No disclosed maximum loss scenario analysis

**Funding Rate Model:**
- Non-linear funding fees that scale with open interest imbalance
- Designed to encourage arbitrage and balance long/short exposure
- Rollover fees reflect underlying market carrying costs (interest differentials, convenience yield)
- Chaos Labs conducted economic audit and developed the "Imbalance Score" metric

**Withdrawal Limits:**
- Two-stage withdrawal: request submission, then 24-48 hour processing before withdrawal
- This provides a natural delay that could serve as a defense against bank runs
- No disclosed hard caps on withdrawal amounts

### 4. Smart Contract Security -- LOW

**Audit History:**
- **Zellic**: 2 audits (one pre-mainnet ~2024, one November 2025)
- **ThreeSigma**: 1 audit (10-person-week deep dive, pre-mainnet). Found: 1 critical (trade overwrite via index 0 default), 2 high-severity economic flaws, multiple medium issues. All critical/high fixed.
- **Pashov**: 3 audits (January 2025 x2, April 2025)
- **Octane**: Adversarial Research Engagement (ARE) with runnable PoCs
- **Chaos Labs**: Economic audit (pre-launch)
- Total: 6+ security reviews by 4+ firms, plus an economic audit
- Most recent audit: likely late 2025 / early 2026

**Critical Finding History:**
- ThreeSigma found a critical vulnerability where `firstEmptyTradeIndex()` returned index 0 when no slot was available, allowing silent overwrite of live positions. Fixed by reverting instead of defaulting to zero.
- Two high-severity economic flaws also found and fixed (details not public)

**Bug Bounty:**
- Active on Immunefi: up to $200,000 for critical smart contract vulnerabilities
- Tiered rewards: Critical $20K-$200K, High $10K-$50K, Medium $5K, Low $1K
- Covers 15 smart contract assets + web app + Telegram bot
- KYC required for payouts
- Primacy of Impact approach

**Battle Testing:**
- Live since July 2024 (~21 months)
- $25B+ cumulative trading volume processed
- Peak TVL ~$93M (March 2026)
- No known exploits or security incidents in production
- Open source (MIT license, Solidity 99.8%, Hardhat framework)

### 5. Cross-Chain & Bridge

N/A -- Ostium operates exclusively on Arbitrum with no cross-chain dependencies.

### 6. Operational Security -- MEDIUM

**Team & Track Record:**
- Co-founders Kaledora Kiernan-Linn (CEO) and Marco Antonio Ribeiro (CTO) are publicly doxxed
- Both are Harvard alumni; previously worked at Bridgewater Associates
- Team includes alumni from BlackRock, Jane Street, Citadel, Two Sigma, Coinbase, Uniswap, dYdX
- Average 8+ years industry experience
- No known past security incidents under their management

**Funding:**
- $27.8M total raised: $3.5M seed (2023), $20M Series A (Dec 2025, led by General Catalyst + Jump Crypto), $4M strategic round
- Well-capitalized with institutional backing from reputable firms

**Incident Response:**
- No published incident response plan
- Emergency shutdown capability exists (`isDone` flag) but response time benchmarks not disclosed
- No public security communication channel documented

**Off-Chain Controls:**
- No SOC 2 Type II or ISO 27001 certification disclosed
- No published key management policy (HSM, MPC, key ceremony)
- No disclosed infrastructure-level penetration testing
- Octane ARE covers smart contract attack surface but not infrastructure/operational security
- Operational segregation and insider threat controls are unknown
- Rating: HIGH risk (no certifications, no published security practices)

## Critical Risks

1. **Governance opacity (HIGH)**: The governance address, multisig configuration, timelock durations, and upgrade authority chain are entirely undisclosed. Users cannot verify who controls the protocol or what safeguards exist against admin key compromise.

2. **Undisclosed insurance/buffer sizing (HIGH)**: The buffer mechanism that protects LPs from trader P&L has no publicly disclosed size or adequacy analysis. In extreme market conditions, LP depositors could face unquantified losses.

3. **Custom oracle single point of failure (MEDIUM)**: The majority of Ostium's volume (95%+ in RWA markets) relies on a custom oracle operated by Stork Network. No fallback mechanism or circuit breaker is documented.

4. **No off-chain security certifications (HIGH)**: No SOC 2, ISO 27001, key management policy, or infrastructure pentest disclosed. For a protocol handling $144M in open interest, this is a significant operational gap.

## Peer Comparison

| Feature | Ostium | GMX V2 | Gains Network |
|---------|--------|--------|---------------|
| TVL | $59.6M | $261M | $19.4M |
| Chain | Arbitrum | Arbitrum, Avalanche | Arbitrum, Polygon, Base |
| Timelock | UNVERIFIED (exists in code) | 24h | 72h |
| Multisig | UNVERIFIED | 4/6 | 3/5 |
| Audits | 6+ (Zellic, ThreeSigma, Pashov, Octane) | 4+ (ABDK, Sherlock, Guardian) | 3+ (Certik, dWallet) |
| Oracle | Stork (RWA) + Chainlink (crypto) | Chainlink | Chainlink + custom TWAP |
| Insurance/TVL | Undisclosed (buffer) | ~3% (GLP) | ~2% (gDAI buffer) |
| Open Source | Yes (MIT) | Yes | Yes |
| Bug Bounty | $200K (Immunefi) | $2.5M (Immunefi) | $100K (Immunefi) |
| Max Leverage | 200x | 100x | 150x |
| Team | Doxxed | Pseudonymous | Pseudonymous |

**Key Comparisons:**
- Ostium has stronger audit coverage than both peers (6+ reviews vs 3-4)
- Ostium's governance transparency is significantly worse than both peers (undisclosed vs documented multisig + timelock)
- GMX's bug bounty ($2.5M) is 12.5x larger than Ostium's ($200K)
- Ostium's 200x max leverage is the highest among peers, increasing liquidation cascade risk
- Ostium is the only one with fully doxxed founders, which is a positive operational signal

## Recommendations

1. **For users/traders**: Ostium's smart contract security is well-audited and the team is credible. However, the lack of governance transparency means users must trust the team's admin key management without verification. Keep position sizes conservative and monitor governance disclosures.

2. **For LPs (OLP depositors)**: Understand that you are the counterparty to trader P&L with no external insurance backstop. The buffer mechanism provides first-loss protection only when overcollateralized. Monitor the c-ratio and understand that in undercollateralized states, you absorb 100% of trader gains.

3. **For the Ostium team**: Publicly disclose the governance address and multisig configuration. Document timelock durations. Publish an incident response plan. Consider increasing the bug bounty to match or exceed Gains Network. Pursue SOC 2 or equivalent certification given the scale of OI handled.

4. **For integrators**: Do not integrate Ostium tokens (OLP) as collateral in lending protocols until governance configuration is publicly verified and timelock durations are confirmed.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral / markets without timelock? -- UNVERIFIED (Manager can tune pair parameters; timelock applicability unknown)
- [x] Admin can change oracle sources arbitrarily? -- YES (governance can register new oracle forwarders)
- [x] Admin can modify withdrawal limits? -- UNVERIFIED
- [ ] Multisig has low threshold (2/N with small N)? -- UNVERIFIED
- [x] Zero or short timelock on governance actions? -- UNVERIFIED (timelock exists in code but duration unknown)
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (EVM)
- [x] Social engineering surface area (anon multisig signers)? -- YES (multisig signer identities undisclosed)

**WARNING: 5/6 applicable Drift-type indicators are triggered or unverified. The governance opacity means this attack pattern CANNOT be ruled out.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A (USDC-only collateral)
- [x] Single oracle source without TWAP? -- PARTIAL (Stork for RWA, no documented TWAP)
- [x] No circuit breaker on price movements? -- YES (not documented)
- [x] Insufficient insurance fund relative to TVL? -- YES (undisclosed)

**WARNING: 3/4 Euler/Mango-type indicators triggered.**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- N/A (single chain)
- [x] Admin keys stored in hot wallets? -- UNVERIFIED
- [x] No key rotation policy? -- YES (not disclosed)

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time? -- N/A (no token governance)
- [ ] Flash loans can be used to acquire voting power? -- N/A
- [ ] Proposal + execution in same block? -- N/A
- [ ] No minimum holding period? -- N/A

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens? -- NO (USDC only)
- [ ] Read-only reentrancy risk? -- LOW (audited by multiple firms)
- [ ] Flash loan compatible without reentrancy guards? -- LOW (audited)
- [ ] Composability with callback hooks? -- LOW (limited external integrations)

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard compiler? -- NO (Solidity/Hardhat)
- [ ] Compiler version has known CVEs? -- UNVERIFIED
- [ ] Different compiler versions across contracts? -- UNVERIFIED
- [ ] Language-specific behavior dependency? -- LOW

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral? -- N/A
- [ ] Redemption creates sell pressure on collateral? -- N/A
- [ ] Oracle delay masks depegging? -- N/A
- [ ] No circuit breaker on redemption? -- N/A

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- N/A -- Single-chain protocol with no bridge dependencies.

## Information Gaps

The following questions could NOT be answered from public information:

1. **Governance address**: What is the actual address that holds governance rights on mainnet? Is it an EOA, multisig, or other structure?
2. **Multisig configuration**: If a multisig is used, what is the threshold (m/n)? Who are the signers?
3. **Timelock durations**: Are `OstiumTimelockOwner` and `OstiumTimelockManager` deployed on mainnet? What are their delay periods?
4. **Emergency bypass**: Does any role bypass the timelock? What powers does it have?
5. **Buffer/insurance sizing**: How large is the overcollateralization buffer? What percentage of TVL does it represent?
6. **Oracle fallback**: What happens if Stork Network infrastructure goes down? Is there automatic failover?
7. **Circuit breakers**: Are there price movement limits or circuit breakers for RWA price gaps?
8. **Key management**: How are admin keys stored? HSM, MPC, or hot wallet?
9. **Incident response time**: How quickly can the team pause the protocol in an emergency?
10. **Withdrawal caps**: Is there a hard cap on withdrawals that even admin cannot override?
11. **Security certifications**: Any SOC 2, ISO 27001, or equivalent?
12. **Penetration testing**: Has infrastructure-level (not just smart contract) security testing been performed?
13. **Manager role holder**: Who holds the Manager role? Same entity as governance or different?
14. **Mainnet timelock addresses**: Why are timelock contract addresses absent from the mainnet deployment list but present on testnet?
15. **Chaos Labs economic audit results**: The economic audit was noted as "in progress" -- were results ever published?

These gaps are significant. The protocol's smart contract security is well-documented, but its operational and governance security is almost entirely opaque. This asymmetry is itself a risk signal.

## Disclaimer

This analysis is based on publicly available information and web research as of April 20, 2026.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
