# DeFi Security Audit: Spark Liquidity Layer

## Overview
- Protocol: Spark Liquidity Layer (part of Spark, a Star/SubDAO of Sky Protocol, formerly MakerDAO)
- Chain: Ethereum (primary), Arbitrum, Base, Optimism, Avalanche, Unichain
- Type: Onchain Capital Allocator (stablecoin liquidity routing)
- TVL: ~$2.00B
- TVL Trend: +1.1% / +26.6% / +20.5% (7d / 30d / 90d)
- Launch Date: November 2024 (governance vote November 4, 2024; live ~November 18, 2024)
- Audit Date: April 20, 2026
- Valid Until: July 19, 2026 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Open (GitHub -- github.com/sparkdotfi/spark-alm-controller)
- Token: SPK (0xc20059e0317DE91738d13af027DfC4a50781b066) -- launched June 2025

## Quick Triage Score: 69/100 | Data Confidence: 70/100

Red flags found: 5

**CRITICAL flags (-25 each):** None.

**HIGH flags (-15 each):** None.

**MEDIUM flags (-8 each):**
- [x] GoPlus: is_mintable = 1 (-8)
- [x] No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations (-8)

**LOW flags (-5 each):**
- [x] No disclosed penetration testing (infrastructure, not just smart contract audit) (-5)
- [x] Undisclosed multisig signer identities (-5) -- Sky DAO governance is token-weighted but the off-chain relayer operator identities and Freezer role holders are not publicly disclosed
- [x] Insurance fund / TVL < 1% or undisclosed (-5)

Score: 100 - 8 - 8 - 5 - 5 - 5 = **69** (MEDIUM risk range: 50-79)

**Data Confidence Score: 70/100**

| Check | Points | Status |
|-------|--------|--------|
| Source code is open and verified on block explorer | +15 | Yes |
| GoPlus token scan completed | +15 | Yes |
| At least 1 audit report publicly available | +10 | Yes |
| Multisig configuration verified on-chain | +0 | No -- governance is DAO-based, not multisig |
| Timelock duration verified on-chain or in docs | +10 | Yes (GSM) |
| Team identities publicly known (doxxed) | +10 | Yes (Phoenix Labs / Sam MacPherson) |
| Insurance fund size publicly disclosed | +0 | No |
| Bug bounty program details publicly listed | +5 | Yes ($5M Immunefi) |
| Governance process documented | +5 | Yes |
| Oracle provider(s) confirmed | +0 | N/A -- SLL does not use price oracles directly |
| Incident response plan published | +0 | No formal plan published |
| SOC 2 / ISO 27001 certification verified | +0 | No |
| Published key management policy | +0 | No |
| Regular penetration testing disclosed | +0 | No |
| Bridge DVN/verifier configuration publicly documented | +0 | No -- SkyLink bridge internals not well-documented |

Total: 15 + 15 + 10 + 10 + 10 + 5 + 5 = **70/100** (MEDIUM confidence)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (Sky Surplus Buffer backstops) | 1-5% (Aave ~2%) | MEDIUM |
| Audit Coverage Score | 2.75 (see calculation below) | 3.0 avg | MEDIUM |
| Governance Decentralization | Sky DAO + GSM + Freezer role | DAO + Guardian avg | LOW risk |
| Timelock Duration | 18-48h (GSM Pause Delay, varies by period) | 24-48h avg | LOW risk |
| Multisig Threshold | Sky governance (MKR/SKY token voting) | 3/5-6/10 avg | LOW risk |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW risk |

**Audit Coverage Score calculation:**
- ChainSecurity ALM Controller (Oct 2024, ~1.5 years old): 0.5
- Cantina ALM Controller #1 (Sep 2024, ~1.5 years old): 0.5
- Cantina ALM Controller #2 (Oct 2024, ~1.5 years old): 0.5
- Cantina ALM Curve Controller (2024-2025): 0.5
- ChainSecurity XChain Helpers (2024): 0.5
- ChainSecurity XChain SSR Oracle (2024): 0.25
- Estimated total: **2.75** (MEDIUM risk threshold: 1.5-2.99)

## GoPlus Token Security (SPK on Ethereum)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | -- |
| Open Source | Yes (1) | -- |
| Proxy | No (0) | -- |
| Mintable | Yes (1) | MEDIUM |
| Owner Can Change Balance | No (0) | -- |
| Hidden Owner | No (0) | -- |
| Selfdestruct | No (0) | -- |
| Transfer Pausable | No (0) | -- |
| Blacklist | No (0) | -- |
| Slippage Modifiable | No (0) | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 16,863 | -- |
| Trust List | No (0) | -- |
| Creator Honeypot History | No (0) | -- |

GoPlus assessment: **LOW RISK**. The only flag is mintability, which is expected for a governance token with a defined 10B supply. No proxy, no honeypot, no hidden owner, no tax, no trading restrictions. Listed on Coinbase.

**Top SPK Holders (GoPlus data):**

| Rank | Address | Type | % Supply |
|------|---------|------|----------|
| 1 | 0xbe8e...8fb | Contract | 53.7% |
| 2 | 0x3300...8c4 | Contract | 12.3% |
| 3 | 0x46dc...847 | Contract | 6.0% |
| 4 | 0xc613...8fd | Contract | 4.7% |
| 5 | 0x18709...12e | EOA | 2.4% |

Top 5 holders control ~79.1% of supply. Most are contracts (likely treasury, vesting, staking, or farming distribution). High concentration is expected given the recent token launch (June 2025) and 10-year farming schedule.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **LOW** | Sky DAO governance with GSM timelock; Freezer role for emergency pause | S | Partial |
| Oracle & Price Feeds | **LOW** | SLL does not use price oracles for allocation; relies on governance-set parameters | S | Y |
| Economic Mechanism | **MEDIUM** | $1.1B Ethena USDe/sUSDe exposure; off-chain relayer controls fund deployment | S/O | Partial |
| Smart Contract | **LOW** | Multiple audits by ChainSecurity and Cantina; $5M bug bounty; open source | S | Y |
| Token Contract (GoPlus) | **LOW** | Mintable but non-proxy, no honeypot, no hidden owner, no tax | S | Y |
| Cross-Chain & Bridge | **MEDIUM** | SkyLink + CCTP for multi-chain; SkyLink is new (~1.5 years) with limited public documentation | S | Partial |
| Off-Chain Security | **MEDIUM** | Off-chain relayer is a critical component; no SOC 2/ISO 27001; no published key management | O | N |
| Operational Security | **LOW** | Doxxed team (Phoenix Labs); Sky DAO institutional governance; Freezer emergency mechanism | S/O | Partial |
| **Overall Risk** | **MEDIUM** | **Well-governed capital allocator with strong audit coverage, but off-chain relayer dependency and large Ethena exposure introduce structural risk** | | |

**Overall Risk aggregation**: 0 CRITICAL, 0 HIGH, 3 MEDIUM (Economic Mechanism, Cross-Chain, Off-Chain Security). 3+ MEDIUM = MEDIUM overall.

## Detailed Findings

### 1. Governance & Admin Key -- LOW

The Spark Liquidity Layer is governed by Sky Protocol (formerly MakerDAO), one of the most established governance systems in DeFi.

**Governance flow:**
- All material changes to the SLL (supported protocols, rate limits, maximum allocations, network additions) are executed via "Spark Proxy Spells" included in Sky/Maker executive votes.
- Sky governance uses MKR/SKY token-weighted on-chain voting with a Governance Security Module (GSM) pause delay.
- The GSM Pause Delay has varied: 30 hours in January 2025, 18 hours by April 2025, with a vote to increase it on April 30, 2025. The current value (April 2026) is UNVERIFIED but historically ranges from 18-48 hours.

**Access control roles (ALM Controller):**
- **DEFAULT_ADMIN_ROLE**: Controlled by Sky governance. Manages role assignments and admin functions.
- **RELAYER**: The off-chain ALM Planner system. Can call controller functions to deploy/rebalance funds. The system explicitly assumes the relayer "can be fully compromised by a malicious actor" -- rate limits constrain damage.
- **FREEZER**: Can invoke `freeze()` to halt all controller operations. Designed as emergency response to compromised relayer.
- **CONTROLLER**: Restricted to calling ALMProxy functions and updating rate limits.

**Rate limiting as security boundary:**
- The RateLimits contract enforces per-vault and per-protocol caps on fund deployment. Even if the relayer is fully compromised, an attacker can only move funds up to the rate limit ceiling within any given time window.
- Rate limits must be explicitly configured per ERC-4626 vault and AAVE aToken; transactions revert without limits set.
- This is a well-designed defense-in-depth approach.

**Emergency mechanisms:**
- The FREEZER role can halt all operations immediately, bypassing normal governance timelines.
- A Backup Relayer can take over if the primary relayer malfunctions or is compromised.
- The Freezer Mom contract (from SparkLend) provides additional emergency pause capability via Sky governance.

**Assessment:** Strong governance architecture with appropriate defense-in-depth. The explicit assumption that the relayer can be compromised, combined with on-chain rate limits and a freezer mechanism, represents mature security design.

### 2. Oracle & Price Feeds -- LOW

Unlike SparkLend (which uses Chainlink/Chronicle/RedStone triple-oracle), the Spark Liquidity Layer does not use price oracles for allocation decisions.

**How allocation works:**
- Fund deployment targets (which protocols, how much, on which chains) are set by Sky governance.
- The off-chain relayer monitors liquidity levels and USDC reserves, then executes rebalancing transactions within governance-approved parameters.
- No price feed manipulation can cause the SLL to misallocate funds, since allocations are governance-determined, not price-dependent.

**XChain SSR Oracle:**
- The cross-chain Sky Savings Rate oracle reports the SSR value to L2 deployments. This has been audited but is a trust dependency for cross-chain sUSDS yield calculations.

**Assessment:** The SLL's governance-driven allocation model eliminates most oracle manipulation vectors. The XChain SSR Oracle is a narrow dependency with limited attack surface.

### 3. Economic Mechanism -- MEDIUM

**Capital allocation model:**
- The SLL mints USDS via Sky Allocator Vaults, deposits into the Sky Savings Rate for sUSDS, swaps for USDC via the PSM, then deploys across protocols.
- Deployed protocols include: SparkLend, Aave (Core, Prime, Base markets), Morpho (curated vaults), Curve, and Ethena (USDe/sUSDe).
- Sky maintains 25% of USDS backing in cash reserves (primarily USDC) for liquidity and stability.

**Ethena exposure (key risk):**
- Spark has allocated up to $1.1 billion of SLL balance sheet to Ethena's USDe and sUSDe tokens.
- The estimated 27% APY "during favorable market conditions" reflects the basis trade risk inherent in Ethena's model.
- If Ethena's USDe depegs or funding rates turn persistently negative, the SLL could experience significant losses.
- Risk mitigation: governance discussions around a 20% total exposure threshold; Morpho vaults provide overcollateralization.

**Aave revenue sharing:**
- Spark pays a quarterly revenue share to Aave for deploying into Aave markets. This is documented in governance votes (e.g., Q4 2024 payment in January 2025).

**Bad debt handling:**
- The SLL does not have a standalone insurance fund.
- Bad debt is backstopped by Sky Protocol's Surplus Buffer, which accumulates protocol revenue.
- The exact current Surplus Buffer size is UNVERIFIED, but historically has held hundreds of millions of DAI.

**Rate limit mechanism:**
- Per-protocol and per-vault rate limits prevent excessive deployment in any single time window.
- Formula: `currentRateLimit = min(slope * (block.timestamp - lastUpdated) + lastAmount, maxAmount)`
- This limits maximum instantaneous exposure and provides time for governance response.

**Assessment:** The economic model is well-designed with governance controls and rate limits. The primary concern is the large Ethena USDe/sUSDe allocation ($1.1B cap), which introduces basis trade risk and Ethena counterparty risk to the Sky ecosystem.

### 4. Smart Contract Security -- LOW

**Codebase:**
- The SLL is a custom system (not a fork) built by Spark/Phoenix Labs, consisting of ALMProxy, MainnetController, ForeignController, and RateLimits contracts.
- Uses OpenZeppelin AccessControl for role-based permissions.
- Open source at github.com/sparkdotfi/spark-alm-controller.

**Audit history:**

| Auditor | Component | Date | Status |
|---------|-----------|------|--------|
| ChainSecurity | Spark ALM Controller | October 22, 2024 | Complete |
| Cantina | Spark ALM Controller | September 25, 2024 | Complete |
| Cantina | Spark ALM Controller (follow-up) | October 23, 2024 | Complete |
| Cantina | Spark ALM Curve Controller | 2024-2025 | Complete |
| ChainSecurity | XChain Helpers | 2024 | Complete |
| ChainSecurity | XChain SSR Oracle | 2024 | Complete |
| ChainSecurity | Spark Vaults V2 | 2024-2025 | Complete |

ChainSecurity assessment: "The codebase provides a high level of security." The audit covered functional correctness, access control, and CCTP integration.

Cantina assessment: Focused on slippage enforcement, virtual price misalignments, Curve rate limit configuration, and edge cases in low-liquidity conditions.

**Bug bounty:**
- Active on Immunefi with maximum payout of **$5,000,000** (Critical: 10% of funds affected, capped at $5M).
- High severity: $10,000-$100,000.
- Immunefi Standard Badge holder.
- Rewards paid in DAI on Ethereum.

**Battle testing:**
- Live since November 2024 (~17 months).
- Current TVL: ~$2.0B.
- No known exploits or security incidents.
- No rekt.news entry for Spark.

**Assessment:** Multiple concurrent audits by two reputable firms (ChainSecurity and Cantina), a $5M bug bounty, and 17 months of incident-free operation with $2B TVL represent strong smart contract security for a protocol of this age.

### 5. Cross-Chain & Bridge -- MEDIUM

**Multi-chain deployment:**
- The SLL operates on 6 chains: Ethereum, Arbitrum, Base, Optimism, Avalanche, and Unichain.
- Governance is centralized on Ethereum via Sky DAO executive votes, with Spark Gov Relay contracts relaying actions to other chains.

**Bridge dependencies:**
- **SkyLink**: Custom bridge infrastructure for USDS/sUSDS cross-chain transfers. Uses Sky's Allocation System (Allocator Vaults mint on Ethereum, then bridge to L2s). SkyLink is relatively new (~1.5 years) with less battle-testing than established bridges.
- **Circle CCTP**: Used for USDC cross-chain transfers. CCTP is a burn-and-mint protocol operated by Circle, eliminating wrapped token risk. CCTP is centralized (operated by Circle) but Circle is a regulated entity.
- **Native rollup bridges**: For Arbitrum and Base, the protocol can leverage native rollup bridges for governance message passing.

**Cross-chain governance security:**
- Spark Gov Relay contracts have been audited (separate audit repo at github.com/sparkdotfi/spark-gov-relay/audits).
- XChain Helpers and XChain SSR Oracle have separate audits.
- Governance actions on L2s are subject to the same GSM delay as Ethereum actions (via relay).

**Risk factors:**
- SkyLink's internal architecture (validator/relayer set, security assumptions) is not well-documented publicly.
- A compromised SkyLink bridge could affect L2 USDS/sUSDS minting.
- CCTP dependency on Circle is a centralization risk, but Circle's regulatory status provides some assurance.
- The protocol is on 6 chains but not all use the same bridge, reducing single-bridge-provider risk.

**Assessment:** The use of CCTP for USDC and native rollup bridges reduces bridge exploit risk compared to a single third-party bridge. However, SkyLink's limited public documentation and relatively short track record introduce moderate risk.

### 6. Operational Security -- LOW

**Team:**
- Spark Protocol was developed by **Phoenix Labs**, co-founded by **Sam MacPherson** (CEO), who is publicly doxxed and has appeared at Blockworks, CoinDesk, and other industry events.
- **Nadia Alvarez** is a public co-founder.
- Phoenix Labs has a track record of contributing to MakerDAO core protocol development prior to launching Spark.

**Incident response:**
- FREEZER role can halt all SLL operations immediately.
- Backup Relayer provides redundancy against primary relayer failure.
- Sky governance's existing emergency infrastructure (ESM, Protego, Freezer Mom) applies.
- BlockAnalitica serves as risk management provider.
- No published formal incident response plan or response time SLA.

**Dependencies:**
- **Sky Protocol / MakerDAO**: Core dependency -- the SLL relies on Sky governance for all parameter changes and Sky Allocator Vaults for USDS minting. Sky has been operational since 2017.
- **Circle CCTP**: USDC bridging dependency. Centralized but regulated.
- **Ethena**: Up to $1.1B allocation to USDe/sUSDe creates significant counterparty risk.
- **Aave, Morpho, Curve**: Downstream protocol dependencies where funds are deployed. Vulnerabilities in these protocols could impact SLL-deployed capital.

**Off-chain controls:**
- No SOC 2 Type II or ISO 27001 certification found for Phoenix Labs or Spark.
- No published key management policy (HSM, MPC, key ceremony) for the relayer infrastructure.
- No disclosed penetration testing (infrastructure-level).
- The off-chain relayer is a critical component that determines when and where to deploy billions of dollars. Its operational security is opaque.

**Assessment:** Doxxed team with strong DeFi track record, backed by Sky/MakerDAO's institutional governance. The gap is in off-chain operational security transparency -- the relayer infrastructure that controls $2B in fund routing lacks published security practices.

## Critical Risks (if any)

No CRITICAL findings. Notable HIGH-attention items:

1. **Off-chain relayer opacity**: The off-chain relayer controls when and where to deploy ~$2B in stablecoin liquidity. While on-chain rate limits constrain damage from relayer compromise, the operational security of the relayer infrastructure is not publicly documented. No SOC 2, no published key management, no penetration testing disclosure.

2. **Ethena USDe/sUSDe concentration**: Up to $1.1B in Ethena exposure introduces basis trade risk and Ethena counterparty risk. A Ethena depeg or funding rate inversion could cause significant losses to the SLL and by extension to Sky's Surplus Buffer.

3. **SkyLink bridge documentation gap**: SkyLink's validator/verifier configuration, security model, and audit status are not well-documented publicly. For a bridge carrying potentially billions in stablecoin value, this opacity is concerning.

## Peer Comparison

| Feature | Spark Liquidity Layer | Morpho (allocator vaults) | Yearn V3 (yield allocator) |
|---------|----------------------|---------------------------|----------------------------|
| Timelock | 18-48h (GSM, varies) | Vault-specific (1d+) | 72h (governance) |
| Multisig / Governance | Sky DAO (token vote) + Freezer | Vault curator + DAO | yDAO multisig (6/9) |
| Audits | ChainSecurity + Cantina (4+) | Multiple (Spearbit, etc.) | Multiple (ChainSecurity, etc.) |
| Oracle | N/A (governance-set) | Market-determined | Chainlink + custom |
| Insurance/TVL | Undisclosed (Sky Buffer) | No dedicated fund | Undisclosed |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | $5M (Immunefi) | $200K (Immunefi) | $250K (Immunefi) |
| Rate Limits | Yes (on-chain per-vault) | Vault caps | Strategy caps |

Spark's $5M bug bounty is significantly larger than comparable allocator protocols. Its governance through Sky DAO (one of the oldest DeFi governance systems) provides stronger decentralization guarantees than most peers. The on-chain rate limiting mechanism is a differentiator that most yield allocators lack.

## Recommendations

- **For depositors (Spark Savings / sUSDS users)**: The SLL is well-governed with strong audit coverage and defense-in-depth. Primary risk is indirect -- through Ethena exposure and off-chain relayer operations. Users should monitor Sky governance votes for changes to allocation parameters.
- **Monitor Ethena exposure**: Track the actual allocation to USDe/sUSDe relative to the $1.1B cap. Watch for governance discussions about adjusting the 20% total exposure threshold.
- **Request operational security transparency**: The community should push for published security practices around the off-chain relayer infrastructure -- key management, access controls, monitoring, and incident response procedures.
- **Watch SkyLink maturation**: As SkyLink handles increasing cross-chain volume, its security documentation should improve. Users on L2s should be aware of additional bridge risk.
- **Track GSM Pause Delay**: The timelock has varied between 18-48h. Verify the current value before making large deposits.
- **Cross-chain caution**: Ethereum deployment benefits from Sky DAO's direct governance. L2 deployments rely on governance relay and SkyLink/CCTP bridges, adding layers of trust.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? **No** -- requires Sky executive vote + GSM delay
- [ ] Admin can change oracle sources arbitrarily? **N/A** -- SLL does not use price oracles for allocation
- [ ] Admin can modify withdrawal limits? **No** -- rate limits set by governance
- [ ] Multisig has low threshold (2/N with small N)? **No** -- Sky DAO uses token-weighted voting
- [ ] Zero or short timelock on governance actions? **No** -- GSM Pause Delay (18-48h)
- [ ] Pre-signed transaction risk (durable nonce on Solana)? **N/A** -- EVM protocol
- [ ] Social engineering surface area (anon multisig signers)? **Low** -- governance is token-weighted, not dependent on a small signer set. Relayer operators are UNVERIFIED.

**Drift-type risk: LOW**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? **N/A** -- SLL allocates stablecoins, does not accept collateral
- [ ] Single oracle source without TWAP? **N/A** -- no price oracle dependency
- [ ] No circuit breaker on price movements? **N/A** -- no price-dependent logic
- [ ] Insufficient insurance fund relative to TVL? **Unclear** -- relies on Sky Surplus Buffer (size UNVERIFIED)

**Euler/Mango-type risk: LOW**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? **Partial** -- CCTP relies on Circle (centralized but regulated); SkyLink security model UNVERIFIED
- [ ] Admin keys stored in hot wallets? **Unknown** -- relayer key management not disclosed
- [ ] No key rotation policy? **Unknown** -- no published key management policy

**Ronin/Harmony-type risk: MEDIUM** (1 indicator confirmed, 2 unknown)

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time (no snapshot)? **No** -- Sky governance uses hat system
- [ ] Flash loans can be used to acquire voting power? **No** -- MKR/SKY governance requires token locking
- [ ] Proposal + execution in same block or short window? **No** -- GSM delay enforced
- [ ] No minimum holding period for voting eligibility? **N/A** -- token locking required

**Beanstalk-type risk: LOW**

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? **N/A** -- SLL deploys stablecoins, does not accept collateral
- [ ] Read-only reentrancy risk? **Low** -- ALMProxy is stateless, RateLimits is stateful but simple
- [ ] Flash loan compatible without reentrancy guards? **Low** -- rate limits would constrain flash loan exploitation
- [ ] Composability with protocols that expose callback hooks? **Yes** -- deploys into Aave, Morpho, Curve (all have callbacks)

**Cream/bZx-type risk: LOW**

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler (Vyper, Huff)? **No** -- Solidity
- [ ] Compiler version has known CVEs? **UNVERIFIED**
- [ ] Contracts compiled with different compiler versions? **UNVERIFIED**
- [ ] Code depends on language-specific behavior? **No** -- standard OpenZeppelin patterns

**Curve-type risk: LOW**

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral (own governance token)? **Partial** -- USDS is backed by diversified collateral including crypto, RWAs, and USDC; not reflexive
- [ ] Redemption mechanism creates sell pressure on collateral? **No** -- PSM provides direct USDS-USDC swaps
- [ ] Oracle delay could mask depegging in progress? **Low** -- PSM provides real-time price floor
- [ ] No circuit breaker on redemption volume? **UNVERIFIED** -- PSM has governance-set parameters

**UST/LUNA-type risk: LOW**

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses a cross-chain bridge for token minting or reserve release? **Yes** -- SkyLink bridges USDS/sUSDS to L2s
- [ ] Bridge message validation relies on a single messaging layer without independent verification? **UNVERIFIED** -- SkyLink internals not well-documented
- [ ] DVN/relayer/verifier configuration is not publicly documented or auditable? **Yes** -- SkyLink configuration is opaque
- [ ] Bridge can release or mint tokens without rate limiting per transaction or per time window? **No** -- on-chain rate limits enforced
- [ ] Bridged/wrapped token is accepted as collateral on lending protocols? **Partial** -- sUSDS is accepted on some lending platforms
- [ ] No circuit breaker to pause minting if bridge-released volume exceeds normal thresholds? **UNVERIFIED**
- [ ] Emergency pause response time > 15 minutes? **UNVERIFIED** -- no published SLA
- [ ] Bridge admin controls under different governance than core protocol? **No** -- same Sky governance
- [ ] Token is deployed on 5+ chains via same bridge provider? **Yes** -- SkyLink covers 6 chains

**Kelp-type risk: MEDIUM** (3+ indicators triggered -- explicit warning)

**WARNING**: The SLL triggers 3+ Kelp-type indicators. While on-chain rate limits mitigate the severity (attackers cannot mint unlimited tokens even with bridge compromise), the lack of documentation around SkyLink's validator/verifier configuration and the deployment across 6 chains via the same bridge provider warrant close monitoring. The key mitigating factors are: (1) on-chain rate limits per vault/protocol, (2) CCTP is used for USDC (separate from SkyLink), and (3) the Freezer role can halt operations.

## Information Gaps

- **SkyLink bridge security model**: The validator/relayer set, message verification mechanism, and independent audit status of SkyLink are not publicly documented. For a bridge carrying billions in stablecoin value across 6 chains, this is the most significant information gap.
- **Off-chain relayer operational security**: Key management, access controls, hosting infrastructure, monitoring, and incident response procedures for the relayer that controls $2B in fund routing are not disclosed.
- **Current GSM Pause Delay**: The exact current value of the GSM Pause Delay is UNVERIFIED. It has ranged from 18-48 hours across different governance periods.
- **Sky Surplus Buffer size**: The exact current value of the Surplus Buffer (which backstops SLL bad debt) is not easily accessible from public sources.
- **Actual Ethena allocation**: The $1.1B is a cap; the actual current allocation to USDe/sUSDe is not immediately visible.
- **Freezer role holders**: Which addresses hold the FREEZER role and their operational security practices are not documented.
- **Relayer key management**: Whether the relayer uses HSMs, MPC custody, or simple EOA keys is not disclosed. This is particularly important given the system's explicit acknowledgment that the relayer "can be fully compromised."
- **Individual audit findings and remediation**: While audit repos exist, the specific critical/high findings and their remediation status require reviewing each PDF individually.
- **Rate limit parameter values**: The specific maxAmount and slope values for each vault/protocol deployment are not easily summarized from public sources.
- **Backup Relayer configuration**: The backup relayer's trigger conditions, operational control, and security properties are not documented.

## Disclaimer

This analysis is based on publicly available information and web research as of April 20, 2026. It is NOT a formal smart contract audit. The risk assessment relies on publicly documented governance structures, audit reports, GoPlus token security data, and DeFiLlama metrics. Always DYOR and consider professional auditing services for investment decisions. DeFi protocols can change rapidly -- governance proposals, parameter updates, and new deployments may alter the risk profile at any time.
