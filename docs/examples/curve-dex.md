# DeFi Security Audit: Curve Finance

**Audit Date:** April 6, 2026
**Protocol:** Curve Finance -- Multi-chain DEX

## Overview
- Protocol: Curve Finance (Curve DEX)
- Chain: Ethereum (primary), Arbitrum, Base, Polygon, Optimism, Avalanche, Fraxtal, Monad, Etherlink, 20+ others
- Type: DEX (StableSwap / CryptoSwap AMM) + Stablecoin (crvUSD) + Lending (LlamaLend)
- TVL: ~$1.77B (DEX pools only; ~$1.95B including staking)
- TVL Trend: +0.2% / -2.7% / -17.6% (7d / 30d / 90d)
- Launch Date: January 2020
- Audit Date: April 6, 2026
- Source Code: Open (Vyper, GitHub: curvefi)

## Quick Triage Score: 67/100

Starting at 100, deductions applied mechanically:

- [-8] GoPlus: is_mintable = 1 (CRV token is mintable)
- [-5] No documented timelock on admin actions (DAO voting period substitutes but no explicit contract-level timelock)
- [-5] Insurance fund / TVL < 1% or undisclosed (newly created Treasury, exact size undisclosed)
- [-5] Undisclosed multisig signer identities (Emergency DAO signers described as "community members" without public identities)
- [-5] Single oracle provider concern (internal EMA oracles for lending; Chainlink for some pools)
- [-5] DAO governance concentration risk (Convex controls ~50% of veCRV)

Score: 100 - 8 - 5 - 5 - 5 - 5 - 5 = **67 (MEDIUM risk)**

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (<1% est.) | 1-5% (Aave ~2%) | HIGH |
| Audit Coverage Score | 3.75 (see below) | 3.0 avg | LOW |
| Governance Decentralization | veCRV DAO + Emergency 5/9 | DAO + Guardian avg | MEDIUM |
| Timelock Duration | 0h explicit (7-day vote period) | 24-48h avg | MEDIUM |
| Multisig Threshold | 5/9 (Emergency DAO) | 3/5 - 6/10 avg | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW |

**Audit Coverage Score calculation:**
- ChainSecurity crvUSD audit (Feb 2025): 1.0
- ChainSecurity crvUSD audit (Jan 2024): 0.5
- ChainSecurity tricrypto-ng (Jun 2023): 0.25
- MixBytes crvUSD (Jun 2023): 0.25
- ChainSecurity ETH/sETH (Sep 2021): 0.25
- MixBytes Curve pools (Jul 2020): 0.25
- Quantstamp CurveDAO (Aug 2020): 0.25
- Quantstamp Curve Metapool (Oct 2020): 0.25
- Trail of Bits (historical): 0.25
- **Total: ~3.25-3.75** (LOW risk threshold >= 3.0)

## GoPlus Token Security (CRV on Ethereum)

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
| Holders | 98,929 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No | -- |
| CEX Listed | Binance, Coinbase | -- |

GoPlus assessment: **LOW RISK**. The only flag is mintability, which is expected -- CRV has a defined emission schedule controlled by the DAO (no arbitrary minting). No honeypot, no hidden owner, no proxy, no tax, no trading restrictions. Token is not upgradeable.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | veCRV concentration (~50% Convex); no explicit timelock; Emergency DAO bypass | Partial |
| Oracle & Price Feeds | **MEDIUM** | Internal EMA oracles for lending; no external fallback on LLAMMA markets | Partial |
| Economic Mechanism | **MEDIUM** | Founder liquidation caused $10M bad debt (Jun 2024); LLAMMA soft-liquidation untested at scale | Partial |
| Smart Contract | **MEDIUM** | Vyper compiler exploit (Jul 2023, $52M loss); code audited but Vyper-specific risks remain | Y |
| Token Contract (GoPlus) | **LOW** | Mintable but emission-schedule-controlled; no other flags | Y |
| Cross-Chain & Bridge | **MEDIUM** | 30+ chain deployments; independent pools but cross-chain governance untested | Partial |
| Operational Security | **MEDIUM** | Doxxed founder but single-point dependency; strong incident response track record | Partial |
| **Overall Risk** | **MEDIUM** | **Battle-tested DEX with strong audits, but governance concentration, Vyper-specific risks, and founder dependency warrant caution** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**DAO Structure:**
- Curve uses Aragon-based on-chain governance with veCRV (vote-escrowed CRV) as the voting token.
- Users lock CRV for 1 week to 4 years to receive veCRV, with voting power proportional to lock duration.
- Ownership votes: 7-day voting period, 30% quorum, 51% pass rate.
- Parameter votes: 7-day voting period, 15% quorum, 30% pass rate.

**Emergency DAO:**
- 5-of-9 multisig composed of "Curve community members" (identities not fully public).
- Powers: can kill gauge rewards, recover ERC-20 tokens from fee distributor, pause Peg Stabilization Reserve contracts.
- Cannot directly upgrade contracts, drain pools, or override ownership votes.
- Emergency DAO votes require 59.999% support and 51% quorum.

**Timelock:**
- There is no explicit contract-level timelock on admin actions. Instead, the 7-day voting period on Aragon serves as a de facto delay.
- Once a vote passes, execution can occur immediately. This is a meaningful difference from protocols with enforced on-chain timelocks (e.g., Aave's 24h/168h dual timelock).
- The Emergency DAO can act without a voting period, but its powers are limited to pausing/killing gauges.

**veCRV Concentration (KEY CONCERN):**
- Convex Finance controls approximately 50% of all veCRV, making it the single dominant governance actor.
- Convex delegates this power to vlCVX holders, creating a meta-governance layer.
- Top holder (veCRV contract: 0x5f3b5dfeb7b28cdbd7faba78963ee202a494e2a2) holds ~36% of CRV supply.
- A coordinated attack via Convex governance could theoretically control Curve governance outcomes.
- In November 2021, Mochi Protocol attempted a governance attack via concentrated veCRV voting, which was stopped by the Emergency DAO -- demonstrating both the vulnerability and the mitigation mechanism.

### 2. Oracle & Price Feeds -- MEDIUM

**StableSwap/CryptoSwap Pools:**
- Curve pools use internal AMM pricing; no external oracle dependency for basic swaps.
- This makes pool pricing manipulation-resistant to external oracle failures but vulnerable to pool-specific liquidity attacks.

**crvUSD / LLAMMA Oracle:**
- LLAMMA (Lending-Liquidating AMM Algorithm) uses internal Exponential Moving Average (EMA) oracles built into Curve pool contracts (StableSwap-NG, Tricrypto-NG, Twocrypto-NG).
- EMA smoothing mitigates flash-crash liquidation cascades but introduces lag risk during sustained moves.
- Collateral assets must be priced against crvUSD, not other stablecoins, reducing dependency on external stablecoin oracles.
- No external fallback oracle (e.g., Chainlink) for LLAMMA markets -- if the internal EMA oracle is manipulated via pool liquidity, liquidations could malfunction.

**Peg Stabilization Reserve (PSR):**
- crvUSD peg relies on liquidity in specific pools that serve dual purpose as price feeds.
- If incentives for crvUSD pool liquidity decline, both peg stability and oracle accuracy degrade simultaneously -- a correlated failure mode.

### 3. Economic Mechanism -- MEDIUM

**LLAMMA Soft-Liquidation:**
- Unlike traditional binary liquidation, LLAMMA gradually converts collateral to borrowed asset as price declines across user-defined "bands."
- This reduces liquidation cascades and MEV extraction but introduces "soft-liquidation losses" -- users in soft-liquidation continuously lose value to arbitrageurs.
- The mechanism is novel (launched 2023) and has not been stress-tested through a severe market crash at current scale.

**Bad Debt Event (June 2024):**
- Founder Michael Egorov borrowed ~$95.7M in stablecoins against ~$141M in CRV collateral across multiple platforms (LlamaLend, Fraxlend, Inverse, UwU Lend, Aave).
- CRV price dropped 24% over June 12-13, 2024, triggering cascading liquidations.
- Result: ~$10M in bad debt on Curve Lend (CRV market specifically), with Egorov losing ~78% of his collateral.
- Egorov repaid ~93% of the bad debt and sold 30M CRV to cover the remainder.
- This demonstrated concentration risk: a single borrower's positions were large enough to cause protocol-level bad debt.

**Insurance/Reserve:**
- In June 2025, the DAO voted to allocate 10% of protocol revenue to a new Treasury reserve.
- Prior to this, there was no dedicated insurance or reserve fund -- all fees were distributed to stakeholders.
- The Treasury size is undisclosed and likely small given the recent establishment. Estimated Insurance/TVL ratio is well below 1%.

### 4. Smart Contract Security -- MEDIUM

**Vyper Compiler Exploit (July 30, 2023) -- CRITICAL HISTORICAL EVENT:**
- A zero-day vulnerability in Vyper compiler versions 0.2.15, 0.2.16, and 0.3.0 caused reentrancy guards to malfunction due to storage slot mismatches.
- Affected pools: aETH/ETH, msETH/ETH, pETH/ETH, CRV/ETH.
- Total losses: ~$70M initially; ~$52M net after white-hat recoveries.
- White-hat hacker c0ffeebabe.eth front-ran and recovered ~$5.4M; Alchemix recovered $22M; overall 73% of funds recovered.
- Root cause: The Vyper compiler bug was fixed in v0.3.1 but was incorrectly categorized as an "optimization bug" rather than a security vulnerability -- it went undetected for 2 years.
- Curve offered a 10% bounty (~$1.85M) for identification of remaining exploiter.

**Vyper Language Risk:**
- Curve is one of the few major DeFi protocols written primarily in Vyper rather than Solidity.
- The Vyper ecosystem is smaller, meaning fewer security tools, auditors with Vyper expertise, and community review.
- The July 2023 exploit was a compiler-level vulnerability, not a contract logic bug -- this attack vector is unique to compiled languages and harder to detect through standard smart contract audits.

**Audit History:**
- Multiple audits from ChainSecurity (2021-2025), MixBytes (2020, 2023), Quantstamp (2020), Trail of Bits (historical).
- Most recent: ChainSecurity crvUSD audit (February 2025).
- Audit Coverage Score: ~3.5 (LOW risk threshold).
- Audits cover individual components (pools, crvUSD, tricrypto-ng) rather than the full protocol surface area.

**Bug Bounty:**
- Curve does not appear to have an active Immunefi bug bounty program (UNVERIFIED -- could not confirm on Immunefi).
- The 10% bounty offered post-exploit suggests ad-hoc rather than systematic vulnerability disclosure.

### 5. Cross-Chain & Bridge -- MEDIUM

**Multi-Chain Deployment:**
- Curve is deployed on 30+ chains, making it one of the most widely deployed DeFi protocols.
- Each chain deployment operates independent liquidity pools -- there is no shared liquidity or cross-chain messaging dependency for core DEX functionality.
- Pool factory contracts allow permissionless pool creation on each chain.

**Governance:**
- Core DAO governance (veCRV voting, gauge weight allocation) operates on Ethereum mainnet.
- Cross-chain gauge allocation directs CRV emissions to pools on other chains.
- The mechanism for relaying governance decisions cross-chain is not fully documented publicly (UNVERIFIED).

**Bridge Exposure:**
- Core Curve pools do not depend on bridges for operation.
- However, CRV token exists as bridged assets on L2s/alt-chains, creating indirect bridge dependency.
- CrossCurve (formerly EYWA), a third-party protocol built on Curve, was exploited for ~$3M via a gateway validation bypass -- this is a third-party risk, not a Curve core vulnerability, but demonstrates ecosystem risk.
- Some chain deployments (e.g., Harmony with $0 TVL) appear abandoned, creating potential attack surface if old contracts remain active.

### 6. Operational Security -- MEDIUM

**Team:**
- Founded by Michael Egorov (doxxed), a physicist with a background in cryptography (NuCypher).
- Egorov is publicly associated with the protocol and has been a visible leader throughout its history.
- Single-founder dependency: Egorov's personal financial decisions (the CRV loan saga) directly impacted protocol stability and token price.

**Incident Response:**
- Demonstrated strong incident response during the July 2023 Vyper exploit: coordinated with white-hat hackers, offered bounties, and recovered 73% of funds.
- Emergency DAO successfully intervened during the November 2021 Mochi governance attack.
- Communication channels: active Discord, Twitter (@CurveFinance), and governance forum.

**Dependencies:**
- Vyper compiler: critical dependency; compiler bugs can affect all Curve contracts.
- Chainlink (partial): used for some pool oracle integrations.
- Convex Finance: governance dependency; Convex controlling ~50% of veCRV creates systemic coupling.

## Critical Risks (if any)

1. **MEDIUM-HIGH: veCRV governance concentration** -- Convex controls ~50% of voting power. A governance attack via Convex (compromised vlCVX governance or social engineering of Convex team) could redirect emissions or pass malicious proposals. Mitigated by Emergency DAO veto power, but the Emergency DAO itself has undisclosed signer identities.

2. **MEDIUM-HIGH: Vyper compiler dependency** -- The July 2023 exploit proved that compiler-level vulnerabilities can bypass all contract-level audits. Curve remains committed to Vyper, a smaller ecosystem than Solidity with fewer security tools and auditors.

3. **MEDIUM: Founder concentration risk** -- Egorov's CRV holdings and borrowing behavior have historically created systemic risk. The June 2024 liquidation event caused $10M in bad debt and a 30% CRV price crash.

4. **MEDIUM: Internal oracle risk for lending** -- LLAMMA uses EMA oracles from Curve's own pools, creating circular dependency. If pool liquidity degrades, oracle quality degrades simultaneously with liquidation capacity.

## Peer Comparison

| Feature | Curve Finance | Uniswap | Balancer |
|---------|--------------|---------|----------|
| Timelock | None (7-day vote period) | ~2 days | 10 days |
| Multisig | 5/9 Emergency DAO | Uniswap Foundation multisig | Emergency subDAO |
| Audits | 9+ (ChainSecurity, MixBytes, Quantstamp, Trail of Bits) | 10+ (multiple firms) | 5+ (Trail of Bits, Certora) |
| Oracle | Internal EMA (lending); AMM pricing (swaps) | AMM pricing; TWAP | AMM pricing; Chainlink |
| Insurance/TVL | <1% (new Treasury) | N/A (no lending) | N/A (no lending) |
| Open Source | Yes (Vyper) | Yes (Solidity) | Yes (Solidity) |
| Language | Vyper | Solidity | Solidity |
| Bug Bounty | Unconfirmed | $15.5M (Immunefi) | $1M (Immunefi) |

## Recommendations

- **For LPs and swappers**: Curve's core AMM pools are battle-tested over 6+ years and represent LOW to MEDIUM risk for swap/LP activity. Prefer pools on Ethereum mainnet where governance oversight is strongest.
- **For crvUSD/LlamaLend users**: Understand that LLAMMA soft-liquidation is novel and the internal oracle design introduces circular risk. Monitor loan health ratios conservatively. The June 2024 bad debt event demonstrates that large positions can exceed market capacity.
- **For governance participants**: Be aware of Convex's dominant veCRV position. Monitor Convex governance (vlCVX) for unusual proposal activity that could cascade to Curve.
- **For all users**: Diversify across chains cautiously -- some chain deployments have minimal TVL and may lack active monitoring. Avoid deployments with near-zero TVL (e.g., Harmony, Aurora).
- **General**: Curve should consider establishing a formal Immunefi bug bounty program, implementing an explicit on-chain timelock for governance execution, and publicly disclosing Emergency DAO signer identities.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- No, requires DAO vote (7-day period), but pool factories allow permissionless pool creation
- [ ] Admin can change oracle sources arbitrarily? -- No, oracle design is embedded in pool contracts
- [ ] Admin can modify withdrawal limits? -- No
- [x] Multisig has low threshold (2/N with small N)? -- No, 5/9 is reasonable, but signer identities undisclosed
- [ ] Zero or short timelock on governance actions? -- No explicit timelock, but 7-day vote period mitigates
- [ ] Pre-signed transaction risk? -- Not applicable (EVM)
- [x] Social engineering surface area (anon multisig signers)? -- Yes, Emergency DAO signers are not fully public

### Euler/Mango-type (Oracle + Economic Manipulation):
- [x] Low-liquidity collateral accepted? -- Permissionless pool creation means low-liquidity pools can exist; LLAMMA requires sufficient pool liquidity for oracle accuracy
- [ ] Single oracle source without TWAP? -- EMA oracles provide smoothing similar to TWAP
- [ ] No circuit breaker on price movements? -- LLAMMA soft-liquidation acts as a buffer
- [x] Insufficient insurance fund relative to TVL? -- Yes, Treasury is new and small

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No core bridge dependency
- [ ] Admin keys stored in hot wallets? -- Unknown (UNVERIFIED)
- [ ] No key rotation policy? -- Unknown (UNVERIFIED)

## Information Gaps

- Exact size of the newly established DAO Treasury / reserve fund
- Emergency DAO signer identities and selection/rotation process
- Cross-chain governance relay mechanism details (how Ethereum DAO decisions propagate to L2/alt-chain deployments)
- Whether Curve has an active formal bug bounty program (could not confirm on Immunefi)
- Key management practices for Emergency DAO multisig (hot vs. cold wallet, hardware security)
- Detailed post-mortem on Vyper compiler audit coverage -- whether current Vyper versions undergo independent compiler-level security review
- Internal risk parameters for LlamaLend markets (max LTV, liquidation thresholds per collateral type)
- Monitoring and incident response procedures for 30+ chain deployments
- Whether abandoned chain deployments (Harmony, Mantle with ~$0 TVL) have active kill switches or can be exploited

## Disclaimer
This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
