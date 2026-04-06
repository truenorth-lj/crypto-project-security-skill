# DeFi Security Audit: SparkLend

**Audit Date:** April 6, 2026
**Protocol:** SparkLend -- Stablecoin lending market (Spark / Sky ecosystem)

## Overview
- Protocol: SparkLend (part of Spark, a Star/SubDAO of Sky Protocol, formerly MakerDAO)
- Chain: Ethereum (primary), Gnosis Chain; broader Spark ecosystem on Arbitrum, Base, OP Mainnet, Avalanche, Unichain
- Type: Lending / Borrowing (stablecoin-focused)
- TVL: ~$1.92B (SparkLend); ~$3.8B (Spark parent including Liquidity Layer)
- TVL Trend: +3.4% / -2.1% / -46.9% (7d / 30d / 90d)
- Launch Date: May 4, 2023
- Audit Date: April 6, 2026
- Source Code: Open (GitHub -- github.com/sparkdotfi)
- Token: SPK (0xc20059e0317de91738d13af027dfc4a50781b066) -- launched June 17, 2025

## Quick Triage Score: 84/100

Red flags found: 2

| Flag | Severity | Points |
|------|----------|--------|
| GoPlus: is_mintable = 1 | MEDIUM | -8 |
| TVL dropped >30% in 90 days | MEDIUM | -8 |

Score: 100 - 8 - 8 = **84** (LOW risk range: 80-100)

Note: The 90-day TVL decline from ~$3.6B to ~$1.9B appears driven by capital reallocation within the broader Spark ecosystem (Liquidity Layer expansion to L2s) rather than a protocol-specific crisis.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (Sky Surplus Buffer backstops) | 1-5% (Aave ~2%) | MEDIUM |
| Audit Coverage Score | ~3.5 (multiple recent audits across components) | 3.0 avg | LOW risk |
| Governance Decentralization | Sky DAO + GSM + Freezer Mom | DAO + Guardian avg | LOW risk |
| Timelock Duration | 48h (GSM Pause Delay as of May 2025) | 24-48h avg | LOW risk |
| Multisig Threshold | Sky governance (MKR/SKY token voting) | 3/5-6/10 avg | LOW risk |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW risk |

## GoPlus Token Security (SPK on Ethereum)

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
| Holders | 16,268 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No | -- |
| CEX Listed | Coinbase | -- |

GoPlus assessment: **LOW RISK**. The only flag is mintability, which is expected for a governance token with a defined supply schedule (10B total supply minted at genesis by Sky Governance on June 4, 2025). No proxy, no honeypot, no hidden owner, no tax, no trading restrictions.

**Top SPK Holders (GoPlus data):**
| Rank | Address | Type | % Supply |
|------|---------|------|----------|
| 1 | 0xbe8e...8fb | Contract | 53.7% |
| 2 | 0x3300...8c4 | Contract | 12.0% |
| 3 | 0x46dc...847 | Contract | 6.0% |
| 4 | 0xc613...8fd | Contract | 4.7% |
| 5 | 0xf977...cec | EOA | 2.4% |

Top 5 holders control ~78.8% of supply. Most are contracts (likely treasury, vesting, staking, or reward distribution contracts). High concentration is expected at this stage given the recent token launch (June 2025) and ongoing airdrop distribution.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **LOW** | Sky DAO governance with 48h GSM timelock; Freezer Mom for emergency pause | Partial |
| Oracle & Price Feeds | **LOW** | Triple-oracle redundancy (Chainlink + Chronicle + RedStone) with Uniswap TWAP fallback | Y |
| Economic Mechanism | **MEDIUM** | Governance-defined fixed rates; D3M mints unbacked DAI/USDS into lending markets | Partial |
| Smart Contract | **LOW** | Aave V3 fork with extensive audits; $5M bug bounty; 3+ years battle-tested | Y |
| Token Contract (GoPlus) | **LOW** | Mintable but non-proxy, no honeypot, no hidden owner, no tax | Y |
| Cross-Chain & Bridge | **MEDIUM** | SkyLink + Circle CCTP for L2 expansion; governance centralized on Ethereum | Partial |
| Operational Security | **LOW** | Doxxed team (Phoenix Labs/Sam MacPherson); strong incident response via Sky governance | Partial |
| **Overall Risk** | **LOW** | **Mature Aave V3 fork backed by Sky/MakerDAO governance; strong oracle and audit coverage** | |

## Detailed Findings

### 1. Governance & Admin Key -- LOW

SparkLend's governance is deeply integrated with Sky Protocol (formerly MakerDAO), one of the most established governance systems in DeFi.

**Governance flow:**
- All material changes to SparkLend (parameter updates, new asset listings, oracle changes, rate adjustments) are executed via "Spark Proxy Spells" -- smart contract bundles that are included in Sky/Maker executive votes.
- Sky governance uses MKR/SKY token-weighted on-chain voting with a Governance Security Module (GSM) pause delay.
- As of May 2025, the GSM Pause Delay is **48 hours**, meaning any passed executive vote takes 48 hours before it can be executed on-chain.
- The Protego contract allows governance to cancel queued spells during the pause delay window.

**Emergency mechanisms:**
- The **Spark Freezer Mom** contract can bypass the 48h GSM delay to freeze or pause SparkLend markets in emergencies. This is controlled by the Sky Chief contract (governance). This is a pause-only bypass -- it cannot upgrade contracts or drain funds.
- The **Emergency Shutdown Module (ESM)** allows MKR/SKY holders to trigger a global shutdown if enough tokens are deposited, bypassing the GSM entirely.

**SPK token governance (emerging):**
- SPK is currently used for signaling via Snapshot voting. The "Spark Federation" governance model is planned for 2026, where veSPK holders will control key parameter adjustments.
- Until then, Sky DAO retains ultimate authority over SparkLend.

**Assessment:** The dual-layer governance (Sky DAO + planned SPK governance) with a 48h timelock and pause-only emergency bypass represents strong governance security. The Freezer Mom is appropriately scoped to pause-only actions.

### 2. Oracle & Price Feeds -- LOW

SparkLend uses a **redundant multi-oracle system** that is among the most robust in DeFi lending:

**Oracle providers:**
- **Chainlink** -- primary price feed source
- **Chronicle** -- secondary/redundant feed (originally built for MakerDAO)
- **RedStone** -- tertiary feed, approved by Sky Governance on recommendation from BlockAnalitica (risk management provider)

**Architecture:**
- The AaveOracle contract (inherited from Aave V3) uses Chainlink aggregators as the first source. If Chainlink returns a price <= 0, the call falls back to the next available oracle.
- In a black swan scenario where all three oracle providers fail simultaneously, a **Uniswap time-weighted average price (TWAP)** serves as the final fallback.
- Specialized oracles exist for derivative assets: wstETH, rETH, weETH, rsETH, ezETH, spETH, with capped price oracles to limit manipulation.

**KillSwitch mechanism:**
- Three peg ratio oracles (cbBTC, rETH, weETH) monitor for depeg events. If a depeg is detected, the KillSwitch can disable all borrowing across affected markets.

**Oracle governance:**
- Oracle source changes must go through Sky executive votes with the 48h GSM delay.
- Admin cannot unilaterally change oracle sources without governance approval.

**Assessment:** Triple-oracle redundancy with TWAP fallback, plus automated depeg detection via KillSwitch, represents best-in-class oracle security for a lending protocol.

### 3. Economic Mechanism -- MEDIUM

**Interest rate model:**
- Unlike Aave's utilization-based rates, SparkLend uses **governance-defined fixed rates** that do not vary based on utilization or loan size.
- This is made possible by the D3M (Direct Deposit Module), which supplies consistent stablecoin liquidity from Sky's reserves.

**D3M (Direct Deposit Module):**
- The D3M allows Sky governance to mint new DAI/USDS directly into SparkLend's lending markets to maintain target interest rates.
- This is a powerful mechanism: it means SparkLend has effectively unlimited stablecoin liquidity backed by the full credit of the Sky Protocol.
- **Risk:** The D3M creates systemic coupling between SparkLend and Sky. If Sky governance makes poor rate decisions or mints excessive USDS, this could create bad debt. However, this is mitigated by the maturity of Sky's risk management (BlockAnalitica oversight, years of operation).

**Liquidation mechanism:**
- Inherited from Aave V3 with variable liquidation close factor.
- Health Factor (HF) > 0.95 but < 1.0: up to 50% of collateral can be liquidated.
- HF < 0.95: up to 100% of collateral can be liquidated.
- Liquidation penalties vary by asset, incentivizing external liquidators.

**Bad debt handling:**
- SparkLend does not have a standalone insurance fund. Bad debt is ultimately backstopped by Sky Protocol's Surplus Buffer, which holds accumulated protocol revenue.
- The Sky Surplus Buffer has historically maintained significant reserves (hundreds of millions of DAI), though the exact current value fluctuates.

**Supported collateral:**
- Primarily high-quality assets: ETH, wstETH, rETH, weETH, WBTC (being offboarded), DAI, sDAI, USDS, sUSDS.
- sDAI/sUSDS are ERC-4626 vault tokens representing DAI/USDS deposited in the DAI Savings Rate module.
- Low-liquidity tokens are generally not accepted as collateral due to Sky governance's conservative asset listing process.

**Assessment:** The fixed-rate model via D3M is innovative but creates systemic dependency on Sky governance. The Aave V3 liquidation mechanism is proven. The lack of a dedicated insurance fund (relying on Sky's Surplus Buffer) is a minor concern but reasonable given the institutional backing.

### 4. Smart Contract Security -- LOW

**Codebase:**
- SparkLend is a **fork of Aave V3**, one of the most audited and battle-tested DeFi codebases. The forked-from relationship is confirmed by DeFiLlama (forkedFromIds: 1599 = Aave V3).
- Custom additions include: specialized oracle implementations, Cap Automator, Spark ALM Controller, cross-chain helpers, Spark PSM, and Spark Vaults V2.

**Audit history:**
DeFiLlama lists 2 audits. The actual audit coverage is significantly broader based on Spark's documentation:

| Auditor | Component | Date | Status |
|---------|-----------|------|--------|
| ChainSecurity | SparkLend Deployment Verification | April 2023 | Complete |
| ChainSecurity | SparkLend Advanced (oracles, rate strategies) | 2024 | Complete |
| ChainSecurity | Cap Automator | 2024 | Complete |
| ChainSecurity | Spark Vaults | 2024-2025 | Complete |
| Various (repos contain /audits dirs) | Spark ALM Controller, XChain Helpers, XChain SSR Oracle, Spark Gov Relay, Spark PSM, Spark Vaults V2, Savings Vault Intents | 2023-2025 | Complete |

Additionally, the underlying Aave V3 codebase has been audited by Trail of Bits, OpenZeppelin, SigmaPrime, ABDK, Peckshield, and Certora (formal verification), among others.

**Audit Coverage Score calculation:**
- ~3-4 audits less than 1 year old (1.0 each) = 3.0-4.0
- ~2-3 audits 1-2 years old (0.5 each) = 1.0-1.5
- ~1-2 audits older than 2 years (0.25 each) = 0.25-0.5
- **Estimated total: ~4.25-6.0** (LOW risk threshold: >= 3.0)

**Bug bounty:**
- Active on Immunefi since November 1, 2023
- Maximum payout: **$5,000,000** (Critical smart contract: 10% of funds affected, capped at $5M)
- High severity: $10,000-$100,000
- 348 assets in scope across multiple chains
- Immunefi Standard Badge holder
- No KYC required for payouts

**Battle testing:**
- Live since May 2023 (~3 years)
- Peak TVL handled: ~$3.6B+
- No known exploits or security incidents on rekt.news or elsewhere
- Open source code on GitHub

**Assessment:** The combination of Aave V3's proven codebase, extensive audits of custom components by ChainSecurity, a $5M bug bounty, and 3 years of incident-free operation represents strong smart contract security.

### 5. Cross-Chain & Bridge -- MEDIUM

**Multi-chain deployment:**
- SparkLend core lending is deployed on Ethereum (primary) and Gnosis Chain.
- The broader Spark Liquidity Layer (SLL) operates on Ethereum, Arbitrum, Base, OP Mainnet, Avalanche, and Unichain.
- Governance is centralized on Ethereum via Sky DAO executive votes, with Spark Gov Relay contracts relaying governance actions to other chains.

**Bridge dependencies:**
- **SkyLink**: Custom bridge infrastructure for USDS/sUSDS cross-chain transfers using Sky's Allocation System (Allocator Vaults mint USDS/sUSDS on Ethereum, then bridge to L2s).
- **Circle CCTP (Cross-Chain Transfer Protocol)**: Used for USDC liquidity bridging. CCTP is a burn-and-mint protocol operated by Circle (the USDC issuer), not a traditional lock-and-mint bridge, which eliminates wrapped token risk.
- For Arbitrum and Base, the protocol can also leverage native rollup bridges for governance message passing.

**Cross-chain governance security:**
- Spark Gov Relay contracts have been audited (audit reports in github.com/sparkdotfi/spark-gov-relay/audits).
- XChain Helpers and XChain SSR Oracle have separate audit repos.
- Governance actions on L2s are subject to the same 48h GSM delay as Ethereum actions (via relay).

**Risk factors:**
- A compromised bridge could theoretically affect L2 deployments, but core lending (SparkLend) is primarily on Ethereum.
- CCTP dependency on Circle is a centralization risk, though Circle is a regulated entity.
- SkyLink is relatively new infrastructure (2025) with less battle-testing than native bridges.

**Assessment:** Cross-chain expansion introduces moderate risk. The use of CCTP over traditional bridges reduces bridge exploit risk. Governance relay contracts are audited. However, SkyLink is new and the cross-chain governance model adds complexity.

### 6. Operational Security -- LOW

**Team:**
- Spark Protocol was developed by **Phoenix Labs**, co-founded by **Sam MacPherson** (CEO), who is publicly doxxed and has appeared at multiple industry conferences (Blockworks, CoinDesk interviews).
- Nadia Alvarez is also a public co-founder.
- Phoenix Labs has a track record of contributing to MakerDAO core protocol development prior to launching Spark.

**Incident response:**
- SparkLend benefits from Sky Protocol's mature incident response infrastructure:
  - Freezer Mom contract for emergency market freezing (can bypass 48h GSM delay)
  - Emergency Shutdown Module (nuclear option)
  - Protego contract for canceling queued governance actions
  - BlockAnalitica serves as risk management provider, monitoring parameters and recommending adjustments
- Active community governance with weekly executive votes including Spark Proxy Spells

**Dependencies:**
- **Sky Protocol / MakerDAO**: Core dependency -- SparkLend relies on Sky governance for all parameter changes and the D3M for liquidity. Sky is one of the oldest and most established DeFi protocols (since 2017).
- **Chainlink / Chronicle / RedStone**: Oracle providers. Triple redundancy mitigates single-provider risk.
- **Aave V3 codebase**: Upstream dependency. Any undiscovered vulnerability in Aave V3 could potentially affect SparkLend, though Aave's extensive audit coverage makes this unlikely.

**Assessment:** Doxxed team with strong DeFi track record, backed by Sky/MakerDAO's institutional governance infrastructure and risk management. Multiple layers of emergency response capability.

## Critical Risks (if any)

No CRITICAL findings. Notable HIGH-attention items:

1. **Systemic coupling to Sky Protocol**: SparkLend's fixed rates, liquidity (D3M), and governance all flow from Sky. A catastrophic failure of Sky governance (hostile takeover, ESM trigger) would directly impact SparkLend. This is by design but represents concentration risk.
2. **90-day TVL decline of ~47%**: While likely explained by capital reallocation to L2 Liquidity Layer deployments within the Spark ecosystem, this magnitude of decline warrants monitoring.
3. **SPK token concentration**: Top holder controls 53.7% of supply. While likely a treasury/distribution contract, this creates theoretical governance centralization risk once SPK governance (Spark Federation) goes live in 2026.

## Peer Comparison

| Feature | SparkLend | Aave V3 | Compound V3 |
|---------|-----------|---------|-------------|
| Timelock | 48h (GSM) | 24h / 168h | 48h |
| Multisig / Governance | Sky DAO (token vote) + Freezer Mom | DAO + 6/10 Guardian | DAO + 4/6 Guardian |
| Audits | ChainSecurity + Aave V3 inherited | 6+ firms + formal verification | OpenZeppelin, Trail of Bits |
| Oracle | Chainlink + Chronicle + RedStone (triple) | Chainlink + SVR | Chainlink |
| Insurance/TVL | Undisclosed (Sky Surplus Buffer) | ~2% (Safety Module) | ~1% (Reserves) |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | $5M (Immunefi) | $1M (Immunefi) | $1M (Immunefi) |
| Rate Model | Governance-defined fixed | Utilization-based variable | Utilization-based variable |

SparkLend's oracle architecture (triple redundancy + TWAP fallback) is stronger than both peers. Its governance inherits Sky/MakerDAO's mature infrastructure with a competitive 48h timelock. The $5M bug bounty is the largest among the three. The main differentiator is the governance-defined fixed rate model via D3M, which is unique but creates dependency on Sky governance quality.

## Recommendations

- **For depositors/borrowers**: SparkLend is one of the more secure lending platforms in DeFi, benefiting from Aave V3's battle-tested code and Sky's institutional governance. The fixed-rate model provides predictability. Primary risk is systemic exposure to Sky Protocol.
- **Monitor TVL trends**: The 90-day decline is significant. Track whether TVL stabilizes or continues declining -- sustained outflows would be a negative signal.
- **Watch SPK governance transition**: The planned Spark Federation (veSPK governance) in 2026 is a critical transition. The concentration of SPK tokens means early governance could be dominated by insiders.
- **Cross-chain caution**: SparkLend core on Ethereum is well-established. L2 deployments via the Liquidity Layer (SkyLink, CCTP) are newer and less battle-tested. Users on L2s should be aware of additional bridge risk.
- **Verify Sky Surplus Buffer**: The lack of a dedicated SparkLend insurance fund means bad debt protection depends on Sky's Surplus Buffer. Users should verify the buffer size relative to SparkLend's outstanding borrows (~$950M).

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? **No** -- requires Sky executive vote + 48h GSM delay
- [ ] Admin can change oracle sources arbitrarily? **No** -- requires Sky executive vote + 48h GSM delay
- [ ] Admin can modify withdrawal limits? **No** -- governed by Sky DAO
- [ ] Multisig has low threshold (2/N with small N)? **No** -- Sky DAO uses token-weighted voting, not a small multisig
- [ ] Zero or short timelock on governance actions? **No** -- 48h GSM Pause Delay
- [ ] Pre-signed transaction risk (durable nonce on Solana)? **N/A** -- EVM protocol
- [ ] Social engineering surface area (anon multisig signers)? **Low** -- governance is token-weighted, not dependent on a small signer set

**Drift-type risk: LOW**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? **No** -- conservative asset listing via Sky governance
- [ ] Single oracle source without TWAP? **No** -- triple oracle + TWAP fallback
- [ ] No circuit breaker on price movements? **No** -- KillSwitch with depeg detection oracles
- [ ] Insufficient insurance fund relative to TVL? **Unclear** -- relies on Sky Surplus Buffer (size UNVERIFIED)

**Euler/Mango-type risk: LOW**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? **Partial** -- CCTP relies on Circle (centralized but regulated); SkyLink security model UNVERIFIED
- [ ] Admin keys stored in hot wallets? **Unknown** -- Sky governance uses on-chain voting, not hot wallet admin keys
- [ ] No key rotation policy? **N/A** -- governance-based, not key-based

**Ronin/Harmony-type risk: LOW**

## Information Gaps

- **Sky Surplus Buffer size**: The exact current value of the Sky Surplus Buffer (which backstops SparkLend bad debt) is not publicly documented in an easily accessible format. This is the primary backstop for SparkLend and should be verifiable.
- **Freezer Mom signer details**: While the Freezer Mom is controlled by the Sky Chief contract, the exact operational security of who can trigger it (and under what conditions) could be more clearly documented.
- **SkyLink bridge security model**: The SkyLink cross-chain bridge is relatively new (2025). Its validator/relayer set, security assumptions, and independent audit status are not well-documented in public sources.
- **Formal verification status**: While Aave V3's codebase has formal verification by Certora, it is unclear whether SparkLend's custom additions (oracles, Cap Automator, ALM Controller) have undergone formal verification beyond traditional audits.
- **Individual audit findings and remediation**: While audit repos exist for each component, the specific findings (critical/high issues and their remediation status) are not easily summarized from public sources without reviewing each PDF.
- **SPK token distribution contract identities**: The top SPK holders are contracts controlling ~78.8% of supply. Their exact purpose (treasury, vesting, staking rewards) is not labeled in GoPlus data.
- **L2 deployment admin keys**: Whether each L2 deployment (Arbitrum, Base, etc.) has its own admin key or relies solely on cross-chain governance relay is not fully documented.
- **Historical bad debt events**: Whether SparkLend has ever experienced bad debt (and how it was resolved) is not publicly reported -- absence of reports likely means none, but this is UNVERIFIED.

## Disclaimer

This analysis is based on publicly available information and web research as of April 6, 2026. It is NOT a formal smart contract audit. The risk assessment relies on publicly documented governance structures, audit reports, and on-chain data. Always DYOR and consider professional auditing services for investment decisions. DeFi protocols can change rapidly -- governance proposals, parameter updates, and new deployments may alter the risk profile at any time.
