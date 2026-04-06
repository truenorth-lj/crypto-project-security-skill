# DeFi Security Audit: Balancer

**Audit Date:** April 6, 2026
**Protocol:** Balancer -- Multi-chain DEX / AMM

## Overview
- Protocol: Balancer (V2 + V3)
- Chain: Ethereum, Arbitrum, Base, Polygon, Gnosis, Avalanche, Optimism, Polygon zkEVM, Fraxtal, Mode, Monad, Hyperliquid L1, Plasma
- Type: DEX / Automated Market Maker (AMM)
- TVL: ~$143M (down from ~$271M 90 days ago)
- TVL Trend: +0.5% / -5.1% / -47.2% (7d / 30d / 90d)
- Launch Date: March 2020 (V1), May 2021 (V2), December 2024 (V3)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: balancer/balancer-v3-monorepo)

## Quick Triage Score: 56/100

Starting at 100. Deductions:

- [-8] TVL dropped >30% in 90 days (down 47.2%)
- [-8] is_mintable = 1 (BAL token is mintable)
- [-8] Multisig threshold < 3 signers for operational multisigs (Balancer Maxis: 2/7 or 3/7)
- [-5] Insurance fund / TVL < 1% or undisclosed (no formal insurance fund; $8M recovery from $128M exploit)
- [-5] Undisclosed multisig signer identities (partial -- some pseudonymous)
- [-5] No documented timelock on all admin actions (V3 guardian can unpause directly)
- [-5] Single oracle provider concern (rate providers are pool-specific, not standardized)

Score: 100 - 8 - 8 - 8 - 5 - 5 - 5 - 5 = **56/100 (MEDIUM risk)**

Red flags found: 7 (TVL decline, mintable token, low operational multisig thresholds, no insurance fund, partial signer doxxing, inconsistent timelocks, rate provider fragmentation)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | ~0% (no formal fund) | 1-5% (Aave ~2%) | HIGH |
| Audit Coverage Score | 3.75 (11 V2 audits pre-2023 + 3 V3 audits 2024-2025) | 3.0 avg | LOW risk |
| Governance Decentralization | veBAL DAO + 6/11 multisig | DAO + multisig avg | MEDIUM |
| Timelock Duration | Variable (action-dependent) | 24-48h avg | MEDIUM |
| Multisig Threshold | 6/11 (DAO) / 4/7 (Emergency) / 2-3/7 (Maxis) | 3/5 avg | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW risk |

**Audit Coverage Score calculation:**
- V3 Certora audit (2024): 1.0
- V3 Trail of Bits audit (2024): 1.0
- V3 Spearbit audit (2024): 1.0
- V3 Certora reassessment (2026): 1.0 (currently live, not yet final -- counting as 0.75)
- V2 Trail of Bits (Sep 2022): 0.25
- V2 OpenZeppelin (2021): 0.25
- V2 Certora (2021-2022): 0.25
- V2 ABDK (2021): 0.25
- Total: ~3.75 = LOW risk

## GoPlus Token Security (BAL on Ethereum)

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
| Holders | 48,688 | -- |
| Trust List | Yes | -- |
| Creator Honeypot History | No | -- |
| CEX Listed | Binance, Coinbase | -- |

GoPlus assessment: **LOW RISK**. The only flag is that the BAL token is mintable. BAL minting is governance-controlled and subject to a hard cap of 100M tokens total supply (current supply ~72.2M). No honeypot, no hidden owner, no proxy, no tax, no trading restrictions. Listed on major CEXs and included in GoPlus trust list.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | Layered multisig structure; operational sigs have low thresholds (2-3/7) | Partial |
| Oracle & Price Feeds | **MEDIUM** | Rate providers are pool-specific; no standardized oracle fallback | Partial |
| Economic Mechanism | **HIGH** | $128M exploit in Nov 2025; only $8M recovered; no insurance fund | Y |
| Smart Contract | **MEDIUM** | V3 well-audited; V2 exploit despite 11 audits demonstrates residual risk | Y |
| Token Contract (GoPlus) | **LOW** | Mintable but capped; no other red flags | Y |
| Cross-Chain & Bridge | **MEDIUM** | LayerZero for veBAL sync; 13 chain deployments increase surface area | Partial |
| Operational Security | **MEDIUM** | Strong post-exploit response but $128M loss exposed gaps | Y |
| **Overall Risk** | **MEDIUM** | **Mature protocol recovering from major exploit; V3 architecture is safer but V2 legacy and TVL decline are concerns** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**Multisig Structure (layered):**
- **DAO Multisig** (protocol operations, treasury): 6/11 signers. This is the primary governance execution layer. Signers are partially doxxed community members.
- **Emergency subDAO**: 4/7 multisig (signers: Solarcurve, Mike B, Zekraken, Zen Dragon, Markus, Fernando + 1). Can pause V2 pools and manage deny lists on the ProtocolFeesWithdrawer. Cannot drain funds.
- **Balancer Maxis** (operational): 2/7 or 3/7 depending on security level. Used for routine operations like adding gauges. This low threshold is a concern for an operational multisig.

**Timelock:**
- Balancer uses a permission-based Authorizer system where more sensitive actions require longer timelocks. The exact durations are action-dependent and not uniformly documented.
- In V3, the guardian can unpause pools directly without governance approval, which streamlines emergency response but reduces the governance check on reactivation.

**veBAL Governance:**
- veBAL (vote-escrowed BAL) is the governance token, obtained by locking 80/20 BAL/ETH BPT on Ethereum mainnet.
- Governance is primarily off-chain via Snapshot (snapshot:balancer.eth), with on-chain execution by the DAO Multisig.
- The multisig explicitly does NOT have decision-making power -- it enacts veBAL voter decisions.
- However, the reliance on a multisig to faithfully execute off-chain votes introduces a trust assumption.

**veBAL Concentration Risk (Aura Finance):**
- Aura Finance aggregates large amounts of BAL into veBAL, creating significant voting power concentration.
- Top BAL holder is the Balancer Vault itself (43.5% of supply, 31.4M BAL), followed by contracts including Aura-related addresses.
- The top 5 holders control ~59% of BAL supply, though much is in protocol contracts (vault, staking).
- Governance capture via Aura's concentrated veBAL is a known systemic risk.

### 2. Oracle & Price Feeds -- MEDIUM

**Rate Provider Architecture:**
- Balancer does not use a traditional oracle system like Chainlink for pool pricing. Instead, pools rely on "rate providers" -- contracts that supply exchange rates for tokens in the pool (e.g., wstETH/ETH rate from Lido).
- Rate providers are set per pool at creation time and are specific to each token pair.
- This design means oracle risk is fragmented across many individual rate provider contracts rather than centralized.

**Manipulation Resistance:**
- The Nov 2025 exploit was NOT an oracle manipulation attack -- it was a rounding error in internal math. However, the pool architecture means that if a rate provider is compromised, only pools using that specific provider are affected.
- V3's vault-centric design improves this by standardizing more logic in the vault, reducing the attack surface of individual pool contracts.

**LP Oracle Risk:**
- Certora audited Balancer V3 LP Oracles (Aug 2025), indicating the protocol is actively working on providing oracle services to external protocols.
- Using Balancer pool prices as oracles for external protocols introduces composability risk -- a manipulated Balancer pool could cascade to dependent protocols.

### 3. Economic Mechanism -- HIGH

**The November 2025 Exploit ($128M):**
- On November 3, 2025, attackers exploited a rounding error in V2 ComposableStablePool contracts across 6+ chains in under 30 minutes.
- Root cause: precision loss in the `_upscaleArray` function, compounded through 65+ micro-swaps in `batchSwap` operations within a single constructor call.
- Impact: $128M drained from Composable Stable Pools on Ethereum, Base, Avalanche, Gnosis, Berachain, Polygon, Sonic, Arbitrum, and Optimism.
- V3 was NOT affected -- the exploit was isolated to V2 Composable Stable Pools.

**Recovery:**
- ~$28M recovered through whitehat actions and internal rescue efforts.
- Balancer DAO proposed an $8M reimbursement plan (non-socialized: each affected pool's recovered funds go only to its LPs).
- Whitehat bounties: 10% of recovered funds, capped at $1M per operation.
- 180-day claim period for affected LPs.
- Net loss to LPs: ~$100M+ unrecovered. This is devastating for affected users.

**Insurance Fund:**
- Balancer has NO formal insurance fund. The protocol relies on treasury assets and recovered funds for compensation.
- Insurance/TVL ratio is effectively 0%, far below the 1-5% benchmark.
- This is the single largest risk factor: another exploit of similar magnitude would have no backstop.

**Liquidation / Bad Debt:**
- As a DEX/AMM, Balancer does not have traditional liquidation mechanisms. Risk is borne by LPs through impermanent loss and potential smart contract exploits.
- No socialized loss mechanism exists beyond ad-hoc governance proposals.

### 4. Smart Contract Security -- MEDIUM

**Audit History:**
- V2: 11 audits by OpenZeppelin, Trail of Bits, Certora, and ABDK (2021-2022). Despite this, the $128M exploit in Nov 2025 went undetected.
- V3: Audited by Certora (formal verification + manual review, Aug-Sep 2024), Trail of Bits, and Spearbit. Certora found no vulnerabilities in V3 contracts.
- V3 post-exploit reassessment (Feb 2026): Certora conducted an extensive reassessment confirming V3 contracts remain secure.
- The V2 exploit demonstrated that even 11 audits from top firms can miss subtle rounding bugs. Audit coverage is necessary but not sufficient.

**Bug Bounty:**
- Active on Immunefi with up to $1,000,000 maximum payout for critical vulnerabilities.
- Balancer paid the maximum $1M bounty for a prior rounding error report.
- Scope covers smart contract vulnerabilities; requires PoC for critical/high submissions.
- No KYC required for payouts.

**Battle Testing:**
- Live since March 2020 (6+ years). Peak TVL exceeded $3B in 2021.
- Current TVL ~$143M represents a ~95% decline from peak, largely due to the Nov 2025 exploit cutting TVL by approximately two-thirds.
- V3 has been live since Dec 2024 with no exploits to date.
- Open source across all versions.

### 5. Cross-Chain & Bridge -- MEDIUM

**Multi-Chain Deployment:**
- Balancer is deployed across 13 chains. Each chain deployment has its own pool contracts, but governance (veBAL) is Ethereum-centric.
- Ethereum is the canonical home chain for governance; veBAL positions can be synced to L2s via LayerZero bridge forwarders.

**LayerZero Dependency:**
- Balancer uses LayerZero for cross-chain veBAL sync and gauge voting on L2s.
- L2 LayerZero Bridge Forwarder contracts are deployed on Base, Gnosis, and other chains.
- LayerZero is a third-party bridge with its own security model (ultra-light nodes, DVN network). A LayerZero compromise could allow forged governance messages on L2 chains.

**Cross-Chain Governance Risk:**
- The Nov 2025 exploit hit 6+ chains in 30 minutes, demonstrating that cross-chain deployment multiplies exploit impact.
- Each chain deployment appears to share similar contract logic, meaning a single vulnerability can be exploited across all deployments simultaneously.
- Risk parameters are not clearly independently configured per chain (UNVERIFIED).

### 6. Operational Security -- MEDIUM

**Team & Track Record:**
- Balancer Labs is a known entity; Fernando Martinelli (co-founder) is publicly identified and active in governance.
- Emergency subDAO signers are partially doxxed (community-known pseudonyms).
- The team has been operating since 2020 with a generally strong track record, though the Nov 2025 exploit response exposed coordination challenges.

**Incident Response:**
- Post-exploit (Nov 2025): Emergency subDAO paused affected V2 pools. Hypernative monitoring integration enabled rapid detection.
- Recovery coordination involved whitehat negotiation, governance proposals for reimbursement, and V3 reassessment.
- Communication was handled through official channels (X/Twitter, governance forum, docs).
- The 30-minute exploit window across 6 chains suggests the emergency pause mechanism was not fast enough to prevent cross-chain losses.

**Key Dependencies:**
- **Aura Finance**: Major veBAL holder; Aura's failure or governance capture could destabilize Balancer governance.
- **LayerZero**: Cross-chain veBAL sync. Bridge failure would isolate L2 governance.
- **Rate Providers**: External contracts (e.g., Lido for wstETH rates). Compromised rate providers affect specific pools.
- **Composability**: Protocols building on Balancer (Aura, Beets/Beethoven X) inherit Balancer's risk profile.

## Critical Risks

1. **No insurance fund**: Zero formal backstop for LP losses. The $128M exploit resulted in ~$100M+ of unrecovered user funds with only $8M proposed reimbursement. Another similar exploit would have no safety net.
2. **TVL decline of 47% in 90 days**: Significant TVL erosion post-exploit signals ongoing confidence crisis and potential liquidity spiral.
3. **Low operational multisig thresholds**: Balancer Maxis operational multisigs require only 2/7 or 3/7 signers for routine actions including gauge management.
4. **Cross-chain exploit amplification**: The Nov 2025 exploit demonstrated that identical contracts across 13 chains means a single bug can be exploited everywhere simultaneously.

## Peer Comparison

| Feature | Balancer | Uniswap | Curve |
|---------|----------|---------|-------|
| Timelock | Variable (action-dependent) | 2 days minimum (hard-coded) | DAO-governed |
| Multisig | 6/11 (DAO) / 4/7 (Emergency) / 2-3/7 (Ops) | N/A (on-chain governance) | Community multisig |
| Audits | 11 (V2) + 3+ (V3) | 9+ (V4) | Multiple |
| Oracle | Rate providers (per-pool) | No oracle dependency (AMM) | Internal TWAP + oracles |
| Insurance/TVL | ~0% | N/A (no insurance fund) | N/A |
| Open Source | Yes | Yes | Yes |
| TVL | ~$143M | ~$5B+ | ~$1.5B+ |
| Past Exploits | $128M (Nov 2025) | None of comparable scale | Vyper reentrancy ($70M, Jul 2023) |

## Recommendations

1. **For current LPs**: Monitor V2 pool exposure carefully. Prefer V3 pools which have a cleaner architecture and were unaffected by the Nov 2025 exploit. Be aware there is no insurance backstop.
2. **For new users**: V3 pools are the recommended entry point. The vault-centric architecture reduces per-pool attack surface. Avoid remaining V2 Composable Stable Pools.
3. **For governance participants**: Advocate for an insurance or safety module similar to Aave's Safety Module. The current 0% insurance/TVL ratio is the protocol's most glaring deficiency.
4. **For Aura Finance users**: Understand that Aura inherits all of Balancer's risk profile plus additional smart contract and governance concentration risk.
5. **Monitor TVL trends**: The 47% 90-day TVL decline indicates ongoing outflows. Declining TVL reduces trading fees, liquidity depth, and protocol sustainability.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- N/A (DEX, not lending)
- [ ] Admin can change oracle sources arbitrarily? -- Rate providers set at pool creation; UNVERIFIED if admin can change post-deployment
- [ ] Admin can modify withdrawal limits? -- No withdrawal limits (LP can withdraw anytime)
- [x] Multisig has low threshold (2/N with small N)? -- Yes, operational Maxis multisigs are 2/7 or 3/7
- [ ] Zero or short timelock on governance actions? -- Partial; timelock exists but duration varies by action
- [ ] Pre-signed transaction risk? -- N/A (EVM)
- [x] Social engineering surface area (anon multisig signers)? -- Partial; some signers use pseudonyms only

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A (DEX)
- [ ] Single oracle source without TWAP? -- Rate providers are single-source per pool
- [ ] No circuit breaker on price movements? -- No protocol-wide circuit breaker (UNVERIFIED for V3)
- [x] Insufficient insurance fund relative to TVL? -- Yes, effectively 0%

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- LayerZero for cross-chain veBAL (semi-decentralized DVN network)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

## Information Gaps

- Exact timelock durations for each permission level in the Authorizer system are not clearly documented in public sources
- Whether V3 rate providers can be changed by admin post-deployment is UNVERIFIED
- Independent risk parameter configuration per chain is UNVERIFIED
- Key storage practices (hot vs. cold wallet) for multisig signers are not publicly disclosed
- Key rotation policy for multisig signers is not documented
- Full identities of all 11 DAO multisig signers are not publicly available (some are pseudonymous)
- Whether the ~$100M+ in unrecovered exploit funds will ever be compensated beyond the $8M proposal is unclear
- V2 pool deprecation timeline -- how long will vulnerable V2 contracts remain active
- Hypernative monitoring integration details and response time SLAs are not public
- LayerZero DVN configuration specifics for Balancer's cross-chain messages

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
