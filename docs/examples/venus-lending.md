# DeFi Security Audit: Venus Protocol

**Audit Date:** April 6, 2026
**Protocol:** Venus -- BNB Chain lending protocol (multi-chain via LayerZero)

## Overview
- Protocol: Venus (V4)
- Chain: BNB Chain (primary), Ethereum, Arbitrum, zkSync Era, Optimism, Base, opBNB, Unichain
- Type: Lending / Borrowing / Stablecoin (VAI)
- TVL: ~$1.26B (all chains; ~$1.25B on BSC)
- TVL Trend: +2.2% / -16.6% / -25.4% (7d / 30d / 90d)
- Launch Date: November 2020
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: VenusProtocol)

## Quick Triage Score: 57/100

Starting at 100, deductions:

- [x] GoPlus: honeypot_with_same_creator = 1 (-25) -- creator address has deployed honeypot contracts (see GoPlus section)
- [x] GoPlus: is_mintable = 0 -- no deduction
- [x] Single oracle provider -- not applicable (multi-oracle resilient system, no deduction)
- [x] Undisclosed multisig signer identities (-5) -- guardian multisig signers not publicly doxxed
- [x] Insurance fund / TVL < 1% or undisclosed (-5) -- risk fund size undisclosed relative to TVL
- [x] GoPlus: is_anti_whale = 1 -- informational, no deduction
- [x] No documented timelock on admin actions -- not applicable (timelocks exist)
- [x] Multisig threshold < 3 signers (-8) -- guardian multisig threshold UNVERIFIED

Score: 100 - 25 - 5 - 5 - 8 = 57 (MEDIUM)

Note: The GoPlus honeypot_with_same_creator flag is the most significant single deduction. The XVS creator address (0x1ca3...6d7e) is flagged as having deployed honeypot contracts. While this may relate to early BSC-era test deployments by the Swipe team (which Binance acquired), it is a legitimate red flag that cannot be dismissed without further investigation.

## Quantitative Metrics

| Metric | Value | Benchmark (Aave/Compound) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | 1-5% (Aave Safety Module ~2%) | HIGH |
| Audit Coverage Score | ~5.5 (10+ audits, many recent) | 3-9 (Aave ~9+) | LOW risk |
| Governance Decentralization | DAO + Guardian + ACM | DAO + Guardian | MEDIUM |
| Timelock Duration | 48h normal / 6h fast / 1h critical | 24h-168h (Aave) | MEDIUM |
| Multisig Threshold | UNVERIFIED (guardian) | 6/10 (Aave) | MEDIUM |
| GoPlus Risk Flags | 1 CRITICAL / 0 HIGH / 0 MED | -- | HIGH |

## GoPlus Token Security (XVS on BSC: 0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63)

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
| Holders | 78,061 | -- |
| Trust List | Yes (1) | -- |
| Creator Honeypot History | Yes (1) | CRITICAL |
| Anti-Whale | Yes (1) | -- |
| CEX Listed | Binance | -- |

GoPlus assessment: **MEDIUM RISK**. The XVS token itself is clean -- no honeypot, no hidden owner, no tax, no pause, no mint, not a proxy. However, the creator address (0x1ca3...6d7e) is flagged as having deployed honeypot contracts (honeypot_with_same_creator = 1). This is a significant flag. The token is on the GoPlus trust list and listed on Binance, which provides some counterbalance. Top holders are dominated by contracts (vault at 43.3%, staking at 28.6%), with the largest EOA holding ~6%.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | Multi-tier VIP system with 1h critical timelock bypass; guardian signer identities undisclosed | Partial |
| Oracle & Price Feeds | **LOW** | Resilient Oracle with Chainlink + RedStone + Binance fallback | Y |
| Economic Mechanism | **HIGH** | Recurring bad debt events (~$95M in 2021, $2.15M in March 2026); donation attack vector known but unpatched | Y |
| Smart Contract | **MEDIUM** | Extensive audits but dismissed Code4rena finding led to $2.15M exploit | Y |
| Token Contract (GoPlus) | **MEDIUM** | Creator honeypot history flag; token itself is clean | Y |
| Cross-Chain & Bridge | **MEDIUM** | LayerZero dependency for omnichain governance; 8 chains deployed | Partial |
| Operational Security | **MEDIUM** | Doxxed founder (Joselito Lizarondo/Swipe); Binance involvement; multiple incident recoveries | Partial |
| **Overall Risk** | **MEDIUM** | **Established protocol with strong audit coverage but recurring bad debt events and a pattern of dismissed vulnerability reports** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

Venus V4 governance uses a tiered VIP (Venus Improvement Proposal) system with three categories:

- **Normal VIP**: 24h voting + 48h timelock (+48h for cross-chain execution)
- **Fast-track VIP**: 24h voting + 6h timelock (+6h cross-chain)
- **Critical VIP**: 6h voting + 1h timelock (+1h cross-chain)

The Access Control Manager (ACM) contract controls permissions. Only the Normal Timelock address (0x939b...8396) holds the DEFAULT_ADMIN_ROLE. The Guardian multisig (reported as 0x1C2C...aA6B on BNB Chain) can execute certain actions directly, bypassing governance voting.

**Concerns:**
- The Critical VIP path allows governance actions with only a 1-hour delay, which is very short for a protocol with $1.26B TVL. An attacker who compromises the governance token supply or the guardian multisig could push through changes rapidly.
- The Guardian multisig threshold and signer identities are not publicly documented. This is a meaningful information gap for a protocol of this size.
- The "lightning vote" mechanism used during the September 2025 phishing recovery demonstrates that emergency governance bypasses exist and have been used in practice.
- The Binance Security team reportedly has an additional review role before proposals execute, but the scope and enforceability of this are UNVERIFIED.

**Positive factors:**
- On-chain governance with XVS token voting
- Role-based access control via ACM (more granular than single admin key)
- 48h timelock on normal proposals is within industry standard

### 2. Oracle & Price Feeds -- LOW

Venus V4 introduced the Resilient Oracle system, a significant upgrade:

- **Primary**: Chainlink price feeds
- **Pivot**: RedStone or Pyth (depending on market support)
- **Fallback**: Binance oracle

The system validates prices across multiple sources before accepting them. Each oracle source is configured per asset, and the Resilient Oracle rejects prices that diverge significantly between providers.

**Concerns:**
- The March 2026 THE token exploit succeeded despite the oracle system because the attack manipulated the actual on-chain liquidity (donation attack), not the oracle price itself. The oracle correctly reported the manipulated price.
- Admin (via governance) can change oracle sources, but this is subject to VIP timelock.

**Positive factors:**
- Multi-oracle architecture with fallback is best practice
- Chainlink as primary oracle is industry standard
- RedStone integration adds redundancy
- Oracle configuration changes require governance approval

### 3. Economic Mechanism -- HIGH

Venus has a troubled history with bad debt accumulation:

**Historical Bad Debt Events:**
1. **May 2021 -- XVS price manipulation**: ~$95M bad debt. Attacker pumped XVS price on low-liquidity CEX markets, used inflated XVS as collateral to borrow BTC/ETH, then abandoned the position when XVS price collapsed. The Venus founder initially denied any attack occurred.
2. **2022 -- Terra/LUNA collapse**: ~$14M in uncollateralized exposure.
3. **2022 -- BNB Chain bridge hack**: Stolen BNB used to borrow ~$150M in stablecoins through Venus.
4. **February 2025 -- ZKSync donation attack**: ~$700K bad debt from supply cap bypass.
5. **March 2026 -- THE token donation attack**: ~$2.15M bad debt. Attacker spent 9 months accumulating 84% of THE token supply, then bypassed supply caps by donating tokens directly to the vTHE contract, inflating the exchange rate 3.8x. Borrowed 20 BTC, 1.5M CAKE, 200 BNB.
6. **September 2025 -- Phishing incident**: $27M drained from a single whale user (not a protocol exploit; funds partially recovered via emergency governance).

**Risk Fund Mechanism:**
Venus V4 introduced a Risk Fund that accumulates from interest reserves and liquidation incentives (50% of released funds). The Shortfall contract can auction Risk Fund assets to cover bad debt. However, the current size of the Risk Fund relative to TVL is not publicly disclosed, which is a significant information gap given the protocol's bad debt history.

**Interest Rate Model:**
Venus uses a standard jump-rate interest model with kink-based rate curves. Rates are configurable per market via governance.

**Liquidation:**
Standard liquidation with configurable close factors and liquidation incentives per market. V4 isolated pools limit contagion between markets.

### 4. Smart Contract Security -- MEDIUM

**Audit History:**
Venus has been audited extensively by multiple firms:
- OpenZeppelin (2023)
- Certik (multiple -- 2023, 2024, 2025)
- Quantstamp (2023, 2024)
- PeckShield (2023)
- Hacken (2023)
- FairyProof (2023, 2025)
- Pessimistic (2025)
- Code4rena (competitive audit, 2023)
- Cyberscope (2025 -- 91% score, multi-chain evaluation)
- Cantina (governance contracts)

**Audit Coverage Score**: ~5.5
- Certik 2025 + Pessimistic 2025 + FairyProof 2025 + Cyberscope 2025 = 4.0 (4 audits < 1 year)
- Certik 2024 + Quantstamp 2024 = 1.0 (2 audits 1-2 years old at 0.5 each)
- OZ 2023 + PeckShield 2023 + Hacken 2023 + Code4rena 2023 + Quantstamp 2023 = 1.25 (5 audits > 2 years at 0.25 each, capped conservatively)
- Total: ~5.5 (LOW risk threshold: >= 3.0)

**Critical Issue -- Dismissed Audit Finding:**
The March 2026 donation attack exploited a vulnerability (supply cap bypass via direct token transfer) that was identified in a Code4rena competitive audit but disputed by the Venus team, who argued that "donations are supported behavior with no negative side effects." This exact vector was exploited first on ZKSync in February 2025 ($700K) and then on BNB Chain in March 2026 ($2.15M). This pattern of dismissing valid audit findings is a significant concern.

**Bug Bounty:**
Venus Protocol is not listed on Immunefi as of the audit date. The absence of a major bug bounty program for a protocol with $1.26B TVL is a notable gap.

### 5. Cross-Chain & Bridge -- MEDIUM

Venus expanded to 8 chains via LayerZero integration (omnichain governance):
- BNB Chain (primary, ~$1.25B TVL)
- Ethereum (~$3.9M)
- Arbitrum (~$2.2M)
- zkSync Era (~$874K)
- Optimism (~$25K)
- Base (~$37K)
- opBNB (~$9K)
- Unichain (~$100K)

**Omnichain Governance:**
Cross-chain VIP execution uses LayerZero messaging with additional timelock delays (+48h normal, +6h fast-track, +1h critical) on remote chains.

**Concerns:**
- LayerZero is a third-party bridge dependency. If LayerZero is compromised, cross-chain governance messages could be forged.
- TVL is heavily concentrated on BNB Chain (99%+), so the cross-chain risk is limited in practice to a small fraction of total funds.
- The ZKSync deployment was the first target of the donation attack ($700K bad debt in February 2025), suggesting that newer chain deployments may receive less security scrutiny.

**Positive factors:**
- Additional timelock on cross-chain messages
- Each chain deployment has its own risk parameters
- Low TVL on secondary chains limits blast radius

### 6. Operational Security -- MEDIUM

**Team:**
- Founded by Joselito Lizarondo, former CEO of Swipe (acquired by Binance in 2020)
- Team is partially doxxed (founder and some core members)
- Venus Labs is the development entity
- Strong Binance connection (Binance Security team reviews proposals)

**Incident Response:**
- The September 2025 phishing response demonstrated effective emergency capabilities: protocol was paused, "lightning vote" governance executed, and $13.5M of $27M recovered
- The March 2026 THE exploit response included immediate market pause, collateral factor set to zero, and post-mortem initiated with risk manager Allez Labs
- However, the pattern of recurring exploits (2021, 2022, 2025, 2026) suggests systemic gaps in proactive risk management

**Dependencies:**
- Chainlink (oracle) -- well-established, low risk
- RedStone (oracle fallback) -- newer but audited
- LayerZero (cross-chain messaging) -- centralized relayer risk
- Allez Labs (risk management) -- third-party risk manager

## Critical Risks

1. **Recurring bad debt accumulation**: Venus has suffered at least 5 significant bad debt events since 2021, totaling well over $100M cumulatively. The pattern suggests structural weaknesses in risk parameter management.
2. **Dismissed audit findings**: The Code4rena donation attack finding was disputed by the team, and the exact vulnerability was exploited twice (February 2025, March 2026). This raises concerns about the team's security culture.
3. **Creator honeypot history (GoPlus)**: The XVS token creator address is flagged for having deployed honeypot contracts. While this may have benign explanations (early BSC test contracts), it is unresolved.
4. **Undisclosed Risk Fund size**: For a protocol with $1.26B TVL and a history of bad debt events exceeding $100M, the lack of public disclosure of the Risk Fund balance is a material information gap.
5. **No Immunefi bug bounty**: The absence of a major bug bounty program for a top-10 BSC protocol is an unusual gap.

## Peer Comparison

| Feature | Venus | Aave | Compound |
|---------|-------|------|----------|
| Timelock | 48h normal / 1h critical | 24h / 168h | 48h |
| Multisig | Guardian (threshold UNVERIFIED) | 6/10 Guardian | 4/6 multisig |
| Audits | 10+ firms | 6+ firms + formal verification | 5+ firms |
| Oracle | Chainlink + RedStone + Binance (Resilient) | Chainlink + SVR | Chainlink |
| Insurance/TVL | Undisclosed | ~2% (Safety Module) | ~0.5% |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | None on Immunefi | $1M on Immunefi | $500K on Immunefi |
| Bad Debt History | ~$100M+ cumulative | Minimal | Minimal |
| Chains | 8 (LayerZero) | 10+ (native bridges) | 4 |

## Recommendations

- **For depositors**: Venus offers competitive yields on BNB Chain but carries higher risk than Aave or Compound due to recurring bad debt events. Prefer core pool assets (BNB, BTCB, ETH, USDT, USDC) over isolated pool tokens with lower liquidity. Monitor governance proposals for risk parameter changes.
- **For large depositors**: The $27M phishing incident demonstrates the importance of wallet-level security. Use hardware wallets and verify all approval transactions. Consider position limits given the protocol's bad debt history.
- **For the Venus team**: (1) Establish a public bug bounty program on Immunefi commensurate with TVL. (2) Publicly disclose Risk Fund balance and target ratio. (3) Address the GoPlus creator honeypot flag with a public explanation. (4) Implement stronger supply cap enforcement to prevent donation attacks. (5) Publish guardian multisig configuration (threshold and signer identities).
- **For governance participants**: The pattern of dismissing audit findings (Code4rena donation attack) should be reviewed and corrected. A more conservative approach to risk parameter settings on newer markets (like THE) would reduce future bad debt.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- No, requires VIP (but fast-track and critical paths have short delays)
- [ ] Admin can change oracle sources arbitrarily? -- No, requires governance VIP
- [ ] Admin can modify withdrawal limits? -- Via governance with timelock
- [x] Multisig has low threshold (2/N with small N)? -- UNVERIFIED; guardian threshold not disclosed
- [x] Zero or short timelock on governance actions? -- Critical VIP has only 1h timelock
- [ ] Pre-signed transaction risk? -- Not applicable (EVM)
- [x] Social engineering surface area (anon multisig signers)? -- Guardian signers not publicly identified

### Euler/Mango-type (Oracle + Economic Manipulation):
- [x] Low-liquidity collateral accepted? -- Yes, THE token was accepted with ~84% supply concentration possible
- [ ] Single oracle source without TWAP? -- No, multi-oracle resilient system
- [ ] No circuit breaker on price movements? -- Partial; Resilient Oracle validates but did not prevent THE exploit
- [x] Insufficient insurance fund relative to TVL? -- Risk Fund size undisclosed; historical bad debt ($100M+) suggests possible inadequacy

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- LayerZero has centralized elements but limited TVL at risk on secondary chains
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

## Information Gaps

- **Guardian multisig configuration**: Threshold (M-of-N), signer identities, and signer selection process are not publicly documented
- **Risk Fund balance**: Current balance and target ratio to TVL are not disclosed publicly
- **Binance Security review scope**: The exact scope and veto power of the Binance Security team review is unclear
- **Total cumulative bad debt**: Exact current outstanding bad debt figure (historically ~$53M per Risk DAO, potentially higher after 2025-2026 events) is not easily verified
- **Bug bounty program**: No public bug bounty program found on Immunefi or other major platforms
- **Guardian bypass powers**: The full scope of what the Guardian multisig can execute without governance vote is not clearly enumerated in public documentation
- **Key rotation and custody**: No public information on how admin keys are stored, rotated, or secured
- **VAI stablecoin backing**: Current collateralization ratio and Peg Stability Module reserves are not readily available
- **Allez Labs risk management**: The scope and authority of the risk manager (Allez Labs) in parameter changes vs. governance is unclear

## Disclaimer

This analysis is based on publicly available information and web research as of April 6, 2026.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
