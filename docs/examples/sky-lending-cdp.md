# DeFi Security Audit: Sky (formerly MakerDAO)

**Audit Date:** April 5, 2026
**Protocol:** Sky (formerly MakerDAO) -- CDP / Stablecoin Protocol

## Overview
- Protocol: Sky (formerly MakerDAO)
- Chain: Ethereum
- Type: CDP / Stablecoin (USDS, DAI)
- TVL: ~$6.58B (DeFiLlama, April 2026)
- TVL Trend: Stable (see below)
- Launch Date: December 2017 (Single-Collateral DAI); November 2019 (Multi-Collateral DAI); August 2024 (rebrand to Sky / USDS launch)
- Audit Date: 2026-04-05
- Source Code: Open (GitHub -- sky-ecosystem)

## Quick Triage Score: 88/100
- Red flags found: 2
  - `hidden_owner = 1` on MKR token contract (legacy design, see GoPlus section)
  - `is_mintable = 1` on MKR token contract (governance-controlled, used for debt auctions)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | ~1.0% (Surplus Buffer) UNVERIFIED | Aave ~2%, Liquity 0% (no buffer needed -- immutable) | MEDIUM |
| Audit Coverage Score | 8.0 (high count, ongoing) | Aave 9+, Liquity 5 | LOW risk |
| Governance Decentralization | On-chain DAO + GSM + Protego | Aave DAO + Guardian, Liquity immutable | LOW risk |
| Timelock Duration | 48h (GSM Pause Delay, as of May 2025) | Aave 24-168h, Liquity N/A (immutable) | LOW risk |
| Multisig Threshold | Core Council Buffer Multisig (threshold UNVERIFIED) | Aave 6/10, Liquity N/A | MEDIUM |
| GoPlus Risk Flags | 1 HIGH / 1 MED | -- | MEDIUM |

## GoPlus Token Security (MKR on Ethereum)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | No | -- |
| Mintable | Yes | MEDIUM |
| Owner Can Change Balance | No | -- |
| Hidden Owner | Yes | HIGH |
| Selfdestruct | No | -- |
| Transfer Pausable | No | -- |
| Blacklist | No | -- |
| Slippage Modifiable | No | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 75,806 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No | -- |
| CEX Listed | Binance, Coinbase | -- |

GoPlus assessment: **MEDIUM RISK**. Two flags require context:

1. **hidden_owner = 1**: The MKR token contract was deployed in 2017 using DSAuth, a DappHub authorization library with an indirect ownership pattern. This is a legacy design artifact, not an active hidden backdoor. Ownership authority rests with Sky governance (the DSChief voting contract). This flag is a false positive in context but worth noting.

2. **is_mintable = 1**: MKR can be minted through governance-authorized debt auctions (flop auctions) to recapitalize the system after bad debt events. This is a deliberate protocol design feature, not an arbitrary minting privilege. Minting occurred after Black Thursday (March 2020) to cover ~$5.67M in bad debt.

No honeypot, no tax, no trading restrictions, no self-destruct. The token is listed on major centralized exchanges (Binance, Coinbase).

Note: The SKY governance token (1 MKR = 24,000 SKY) is the new primary governance token as of May 2025. GoPlus data above is for the legacy MKR contract. The SKY token contract was not separately checked in this audit.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **LOW** | On-chain DAO + 48h GSM timelock + Protego emergency cancel | Partial |
| Oracle & Price Feeds | **LOW** | Chronicle Scribe oracles (purpose-built for Sky); OSM 1h delay | Partial |
| Economic Mechanism | **MEDIUM** | Black Thursday precedent; RWA collateral introduces off-chain risk | Y |
| Smart Contract | **LOW** | 8+ audit firms, $10M bug bounty, 8+ years battle-tested | Y |
| Token Contract (GoPlus) | **MEDIUM** | Hidden owner (legacy DSAuth) and mintable flags; contextually benign | Y |
| Operational Security | **LOW** | Doxxed founder (Rune Christensen), strong governance history | Y |
| **Overall Risk** | **LOW** | **Pioneer CDP protocol with strongest governance track record in DeFi; RWA exposure is main emerging risk** | |

## Detailed Findings

### 1. Governance & Admin Key -- LOW

Sky operates one of the most mature decentralized governance systems in DeFi:

- **On-chain governance**: SKY token holders vote on executive spells (smart contract bundles) through the governance portal (vote.makerdao.com). All parameter changes, collateral onboarding, and protocol upgrades require on-chain approval.
- **Governance Security Module (GSM)**: A mandatory timelock of 48 hours (increased from 18h in April-May 2025) between spell passage and execution. This gives users time to exit if a malicious proposal passes.
- **Protego**: A new emergency cancel mechanism deployed in May 2025 that allows governance to cancel pending spells during the GSM delay period, adding a defensive layer against governance attacks.
- **Core Council Buffer Multisig**: Used for operational funding. Signer details and threshold were updated in 2025 governance proposals, but exact current configuration is UNVERIFIED from public sources.
- **Endgame transition**: The MKR-to-SKY migration (1:24,000 ratio) completed Phase One in May 2025. A "Delayed Upgrade Penalty" (1% decay every 3 months starting September 2025) incentivizes migration.
- **SubDAOs / Stars**: The protocol is decomposing into independent Stars (e.g., Spark for lending), each with their own governance token (SPK launched June 2025). This distributes risk but introduces coordination complexity.

**Key strength**: The 48-hour GSM delay is among the longest timelocks in DeFi, giving users meaningful time to react to adverse governance actions. The addition of Protego further strengthens defense against governance attacks.

**Key concern**: The Endgame restructuring introduces transitional complexity. Governance authority is shifting across multiple entities (Stars), and the security implications of this decomposition are still playing out.

### 2. Oracle & Price Feeds -- LOW

- **Primary oracle**: Chronicle Protocol (formerly MakerDAO's internal oracle team, spun out as an independent entity). Chronicle is the second-largest oracle provider by TVS (~$10.2B, 17% market share as of 2025).
- **Architecture**: Scribe-based oracle design using Schnorr signature aggregation, reducing gas costs by 60%+ on L1. Migrated from the older Median-based design in March 2025.
- **Oracle Security Module (OSM)**: Imposes a 1-hour delay on price feed updates, giving the system time to react to oracle manipulation before liquidations trigger. This is a unique defensive feature among CDP protocols.
- **Feed diversity**: Multiple independent feed providers submit prices; the median value is used. Chronicle operates 1,296 oracles across supported assets.
- **RWA oracles**: Chronicle has expanded to Real World Asset price feeds via M^0 integration, supporting Sky's growing RWA collateral exposure.

**Key strength**: The OSM 1-hour delay is a powerful defense against flash-loan-style oracle manipulation. Chronicle's deep integration with Sky (having originated as MakerDAO's oracle team) means the oracle system was purpose-built for this protocol.

**Key concern**: Chronicle's primary relationship with Sky creates concentration risk -- if Chronicle experiences systemic failure, Sky has no independent fallback oracle. This is partially mitigated by the OSM delay.

### 3. Economic Mechanism -- MEDIUM

#### 3.1 Collateral & CDP Design

- **Over-collateralization**: Users deposit collateral (ETH, wstETH, USDC, RWAs, etc.) to mint USDS/DAI. Minimum collateralization ratios range from ~150% (ETH) to 100% (PSM stablecoins).
- **Peg Stability Module (PSM)**: Allows 1:1 minting/redemption of USDS against USDC, maintaining peg stability. This introduces centralization dependency on Circle/USDC.
- **RWA exposure**: Sky has onboarded significant Real World Asset collateral (tokenized treasuries, real estate). This introduces off-chain counterparty risk, legal risk, and opacity compared to purely on-chain collateral.

#### 3.2 Liquidation Mechanism

- **Liquidations 2.0**: Dutch auction format deployed post-Black Thursday, replacing the English auction system that failed in March 2020.
- **Keepers**: Decentralized liquidation bots compete in Dutch auctions. The new system is more gas-efficient and resistant to the zero-bid exploit that occurred on Black Thursday.
- **Circuit breakers**: The OSM delay and dust parameters prevent cascading liquidations from flash price movements.

#### 3.3 Bad Debt & Insurance

- **Surplus Buffer**: Accumulates from stability fees. Functions as first-loss capital. Exact current size UNVERIFIED, but historically maintained in the tens of millions of USD range.
- **Debt auctions (flop)**: If the Surplus Buffer is depleted, MKR/SKY is minted and auctioned to recapitalize the system. This is a dilutive backstop similar to Aave's recovery issuance.
- **Black Thursday precedent**: In March 2020, $8.32M in ETH was liquidated for 0 DAI due to network congestion and keeper failures. The protocol minted MKR to cover ~$5.67M in bad debt. This event led to Liquidations 2.0, USDC PSM adoption, and the GSM delay increase.
- **Smart Burn Engine**: Buys back and burns SKY/MKR when surplus exceeds target, returning value to token holders.

**Key strength**: The protocol survived Black Thursday, learned from it, and implemented comprehensive remediation. 8+ years of operation through multiple market cycles is unmatched battle-testing.

**Key concern**: RWA collateral (a growing share of TVL) introduces risks that on-chain mechanisms cannot fully mitigate -- legal disputes, counterparty defaults, and redemption delays are inherently off-chain problems. The Insurance Fund / TVL ratio (~1% UNVERIFIED) is below Aave's ~2%.

### 4. Smart Contract Security -- LOW

#### 4.1 Audit History

Sky/MakerDAO has one of the most extensively audited codebases in DeFi:

- **Audit firms**: Trail of Bits, PeckShield, Runtime Verification, ChainSecurity, Quantstamp, Sherlock, CertiK
- **Formal verification**: Runtime Verification performed high-level formal modeling of system logic. Trail of Bits noted that formal verification eliminated most "low-hanging fruit."
- **Ongoing audits**: ChainSecurity audited Sky smart contracts (rebranding), Protego, and PSM Lite as of 2025. Sherlock has been engaged for newer components.
- **Audit links**: Centralized at security.makerdao.com with full reports published.
- **Audit coverage score**: 8.0 -- high number of auditors with recent (< 1 year) audits on new components.

#### 4.2 Bug Bounty

- **Platform**: Immunefi
- **Maximum payout**: $10,000,000 (10% of affected funds, up to cap)
- **Payout structure**: First $1M paid immediately; remainder paid in $1M monthly installments
- **Payment method**: DAI or USDS directly from protocol buffer
- **Processing delay**: Up to 1 calendar month after validation (due to governance process)

This is one of the largest bug bounty programs in DeFi, comparable to only a few other protocols.

#### 4.3 Battle Testing

- **Live since**: December 2017 (8+ years)
- **Peak TVL**: ~$19B (2021)
- **Past incidents**: Black Thursday (March 2020) -- economic/operational failure, not a smart contract exploit. Critical DSChief vulnerability discovered and patched via bug bounty (OpenZeppelin disclosure) before exploitation.
- **Code**: Fully open source on GitHub (sky-ecosystem organization)

### 5. Operational Security -- LOW

#### 5.1 Team & Track Record

- **Founder**: Rune Christensen (fully doxxed, Danish entrepreneur)
- **Core contributors**: Multiple known entities including the Maker Foundation (dissolved 2021), development teams, and aligned delegates
- **Track record**: Created the first decentralized stablecoin (DAI, 2017). No smart contract exploits resulting in user fund loss in 8+ years.

#### 5.2 Incident Response

- **Emergency pause**: Emergency Shutdown Module (ESM) can freeze the entire system if 50,000 MKR (now equivalent in SKY) is deposited. This is a nuclear option designed for catastrophic scenarios.
- **Protego**: Targeted cancel of pending spells, a more surgical emergency tool added in 2025.
- **Communication**: Sky Forum, governance portal, X (@SkyEcosystem), and aligned delegate channels.

#### 5.3 Dependencies

- **Chronicle oracles**: Critical dependency; failure would halt price feeds and liquidations (mitigated by OSM delay)
- **USDC (Circle)**: PSM dependency for peg stability; Circle blacklisting of the PSM contract would be a significant event
- **Ethereum**: Single-chain deployment; Ethereum liveness is required for all operations
- **RWA counterparties**: Off-chain legal entities managing real-world collateral introduce trust dependencies

## Critical Risks (if any)

No CRITICAL risks identified. The following HIGH-attention items merit ongoing monitoring:

1. **RWA counterparty risk**: Growing share of collateral is off-chain, introducing legal and redemption risks that on-chain mechanisms cannot fully address.
2. **Chronicle oracle concentration**: Single oracle provider with no independent fallback. If Chronicle fails systemically, the OSM delay provides only a 1-hour buffer.
3. **Endgame transition complexity**: Ongoing restructuring (Stars, token migrations, governance decomposition) introduces temporary uncertainty in authority structures and security boundaries.

## Peer Comparison

| Feature | Sky (MakerDAO) | Liquity (V1/V2) | Aave V3 |
|---------|---------------|-----------------|---------|
| Type | CDP / Stablecoin | CDP / Stablecoin | Lending / Borrowing |
| TVL | ~$6.58B | ~$0.5-1B | ~$24.8B |
| Timelock | 48h (GSM) | N/A (immutable) | 24h / 168h |
| Multisig | Core Council (UNVERIFIED) | None (immutable) | 6/10 Guardian |
| Audits | 8+ firms, ongoing | 3-5 firms | 9+ firms, formal verification |
| Oracle | Chronicle (purpose-built) | Chainlink | Chainlink + SVR |
| Insurance/TVL | ~1% UNVERIFIED | 0% (no buffer; redemptions) | ~2% (Safety Module) |
| Open Source | Yes | Yes | Yes |
| Governance | On-chain DAO + GSM | Immutable (no governance) | On-chain DAO + Guardian |
| Age | 8+ years | 3+ years (V1) | 6+ years |
| Past Incidents | Black Thursday (2020) | None known | Minor bad debt (~$1.6M CRV) |
| Bug Bounty Max | $10M | $1M | $1M |

**Analysis**: Sky occupies a unique position: it is the oldest and most battle-tested CDP protocol, with the most comprehensive governance infrastructure. Liquity achieves security through immutability (no governance attack surface at all), while Aave achieves it through defense in depth (multiple timelocks, guardian, formal verification). Sky's approach -- sophisticated governance with strong timelocks -- is the most complex of the three but has proven resilient over 8+ years. The main trade-off is the RWA exposure that neither Liquity nor Aave carries at Sky's scale.

## Recommendations

1. **For depositors/vault users**: Sky is among the lowest-risk CDP protocols in DeFi. The 48h GSM delay provides meaningful exit time. Monitor governance proposals via vote.makerdao.com, especially collateral parameter changes.
2. **Monitor RWA exposure**: Track the proportion of TVL backed by RWA vs. crypto-native collateral. Higher RWA share means more off-chain risk.
3. **USDC PSM dependency**: Be aware that USDS peg stability relies partly on USDC. If Circle were to blacklist the PSM contract, it could temporarily disrupt the peg.
4. **Token migration**: If holding MKR, be aware of the Delayed Upgrade Penalty (1% decay per quarter starting September 2025). Convert to SKY to preserve full governance weight.
5. **Verify multisig configuration**: The Core Council Buffer Multisig threshold and signer identities should be independently verified before large capital deployment.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? **No** -- requires governance vote + 48h GSM delay
- [ ] Admin can change oracle sources arbitrarily? **No** -- requires governance spell + GSM delay
- [ ] Admin can modify withdrawal limits? **No** -- parameter changes require governance
- [ ] Multisig has low threshold (2/N with small N)? **UNVERIFIED** -- Core Council multisig threshold not confirmed
- [ ] Zero or short timelock on governance actions? **No** -- 48h GSM Pause Delay (among longest in DeFi)
- [ ] Pre-signed transaction risk (durable nonce on Solana)? **N/A** -- Ethereum only
- [ ] Social engineering surface area (anon multisig signers)? **LOW** -- founder is doxxed; delegate system is public

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? **Partially** -- RWA collateral has limited on-chain liquidity by nature
- [ ] Single oracle source without TWAP? **No** -- Chronicle with OSM 1h delay acts as TWAP equivalent
- [ ] No circuit breaker on price movements? **No** -- OSM delay + liquidation ratio buffers
- [ ] Insufficient insurance fund relative to TVL? **Possibly** -- ~1% ratio is below Aave's ~2% UNVERIFIED

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? **No** -- single-chain (Ethereum)
- [ ] Admin keys stored in hot wallets? **No evidence** -- governance is on-chain voting
- [ ] No key rotation policy? **N/A** -- governance authority is the DSChief contract, not individual keys

**Hack pattern assessment**: Sky shows minimal overlap with known DeFi attack patterns. The protocol's governance-first design, 48h timelock, and 8+ years of battle testing place it in the lowest-risk category for governance attacks. The primary residual risk vectors are economic (RWA counterparty failure, oracle concentration) rather than governance or smart contract exploits.

## Information Gaps

The following questions could NOT be fully answered from publicly available information:

1. **Core Council Buffer Multisig exact configuration**: Current signer count, threshold, and signer identities were updated in 2025 but specific details were not confirmed in this audit.
2. **Surplus Buffer current balance**: The exact size of the Surplus Buffer (protocol insurance) was not verified. Historical estimates suggest tens of millions of USD, but the current figure relative to $6.58B TVL is unknown.
3. **RWA collateral breakdown**: The exact composition and percentage of TVL backed by Real World Assets vs. crypto-native collateral was not determined.
4. **SKY token contract GoPlus analysis**: Only the legacy MKR token was checked via GoPlus. The new SKY token contract security profile was not independently verified.
5. **Star (SubDAO) governance boundaries**: The security perimeter between Sky core governance and individual Stars (e.g., Spark) is evolving. The exact authority delegation and risk isolation between Stars is not fully documented.
6. **Chronicle oracle validator set**: The number and identity of Chronicle feed providers for Sky's price feeds was not independently verified.
7. **Emergency Shutdown Module threshold**: The ESM trigger threshold (historically 50,000 MKR) may have been updated during the SKY migration; current value is UNVERIFIED.

## Disclaimer

This analysis is based on publicly available information and web research as of April 5, 2026. It is NOT a formal smart contract audit. The protocol has undergone significant structural changes (Endgame, rebranding, token migration) in 2024-2025, and some findings may not reflect the most current state. Always DYOR and consider professional auditing services for investment decisions.
