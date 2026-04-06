# DeFi Security Audit: Yearn Finance

**Audit Date:** April 6, 2026
**Protocol:** Yearn Finance -- Multi-chain yield aggregator

## Overview
- Protocol: Yearn Finance (V2 + V3)
- Chain: Ethereum, Arbitrum, Optimism, Base, Polygon, Fantom, Katana
- Type: Yield Aggregator
- TVL: ~$218M (DeFiLlama, April 2026)
- TVL Trend: -2.4% / -9.1% / -46.6% (7d / 30d / 90d)
- Launch Date: July 2020
- Audit Date: April 6, 2026
- Source Code: Open (GitHub, Vyper)

## Quick Triage Score: 52/100

Starting at 100, deductions applied mechanically:

- [-8] TVL dropped >30% in 90 days (-46.6%)
- [-8] GoPlus: is_mintable = 1 (YFI token is mintable)
- [-5] Undisclosed multisig signer identities (pseudonymous, PGP-attested but not publicly doxxed)
- [-5] Insurance fund / TVL < 1% or undisclosed (no dedicated insurance fund disclosed)
- [-5] No documented timelock on admin actions (V3 vaults lack mandatory timelock; only setGovernance has 3-day lock)
- [-5] Single oracle provider (Chainlink primary, no documented fallback)
- [-5] DAO governance paused or dissolved (multi-DAO structure with Guardian veto, but no active on-chain voting since Governance 2.0)
- [-7] Legacy contract technical debt (two exploits in Nov-Dec 2025 totaling ~$9.3M)

Score: **52/100 = MEDIUM risk**

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | 1-5% (Aave ~2%) | HIGH |
| Audit Coverage Score | 3.0 (V3: ChainSecurity 2023 = 0.5, MixBytes 2023 = 0.5, StateMind = 0.5, yAudit = 0.5; V2: Trail of Bits 0.25, ChainSecurity 0.25, MixBytes 0.25, others 0.25) | 3.0 avg | LOW |
| Governance Decentralization | Multi-DAO + Guardian (6/9 multisig) | DAO + multisig avg | MEDIUM |
| Timelock Duration | 3 days (setGovernance only) | 24-168h avg | MEDIUM |
| Multisig Threshold | 6/9 | 3/5 avg | LOW |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW |

## GoPlus Token Security (YFI on Ethereum)

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
| Holders | 52,026 | -- |
| Trust List | Yes | -- |
| Creator Honeypot History | No | -- |
| CEX Listed | Binance, Coinbase | -- |

GoPlus assessment: **LOW RISK**. The only flag is that YFI is mintable. Minting ownership was transferred to governance and there has been a governance proposal to burn minting ability permanently, though the current status of minting control should be verified on-chain. No honeypot, no hidden owner, no tax, no proxy, no trading restrictions. Listed on major CEXs and on the GoPlus trust list.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | 6/9 multisig is strong but signer identities are pseudonymous; limited timelock scope | Partial |
| Oracle & Price Feeds | **LOW** | Yield aggregator has limited oracle dependency; Chainlink used where needed | N |
| Economic Mechanism | **MEDIUM** | Strategist trust model; composability risk stacks across underlying protocols | Partial |
| Smart Contract | **MEDIUM** | V3 well-audited but legacy contracts remain exploitable; two exploits in late 2025 | Y |
| Token Contract (GoPlus) | **LOW** | Mintable flag only; governance-controlled minting, no other concerns | Y |
| Cross-Chain & Bridge | **LOW** | Native deployments per chain; no cross-chain liquidity bridging | Partial |
| Operational Security | **MEDIUM** | Founder departed in 2022; team pseudonymous; incident response demonstrated but reactive | Partial |
| **Overall Risk** | **MEDIUM** | **Mature protocol with strong V3 architecture but legacy contract debt and recurring exploits undermine confidence** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**Multisig Configuration:**
- 6-of-9 Gnosis Safe multisig (known as "yChad")
- Per YIP-81, the multisig serves as a Guardian role: it can nullify governance proposals but cannot initiate new proposals
- Members were voted in by YFI holders and are subject to rotation via governance proposals (YIP-84, YIP-89 document recent rotations)
- Signer identities are pseudonymous with PGP key attestations stored in the yearn-security GitHub repo, but real-world identities are not publicly doxxed

**Timelock:**
- The `setGovernance` function (changing the governance owner) is subject to a 3-day timelock
- Other admin actions (strategy management, parameter changes) do NOT appear to have mandatory timelocks
- V3 vaults use a granular role-based permission system (role_manager, ADD_STRATEGY_MANAGER, DEBT_MANAGER, EMERGENCY_MANAGER, etc.) but timelock enforcement on these roles is not documented as mandatory

**V3 Role Architecture:**
- The `role_manager` is a single address that controls all other role assignments -- this is a single point of trust
- Roles can be assigned to EOAs, multisigs, or smart contracts -- flexibility is good but creates variable security depending on configuration
- The `EMERGENCY_MANAGER` role can shut down a vault unilaterally
- The `DEBT_MANAGER` role controls fund allocation across strategies

**Governance 2.0 (YIP-61):**
- Transitioned from direct on-chain voting to a multi-DAO structure with "constrained delegation"
- Day-to-day operations delegated to specialized working groups (yTeams)
- YFI token holders retain ultimate authority but active on-chain voting is infrequent
- This trades decentralization for operational efficiency -- a reasonable tradeoff for a yield aggregator but reduces transparency

### 2. Oracle & Price Feeds -- LOW

- Yearn Finance is a yield aggregator, not a lending protocol -- it has limited direct oracle dependency compared to protocols like Aave
- Chainlink price feeds are used where pricing is needed (e.g., for vault share price calculations and strategy rebalancing)
- The primary risk is not oracle manipulation of Yearn itself, but oracle failures in underlying protocols that Yearn strategies deposit into
- No documented fallback oracle mechanism, but the attack surface is smaller than for lending/perps protocols
- The yETH exploit (Nov 2025) was not an oracle attack -- it was an arithmetic underflow in a custom stableswap pool

### 3. Economic Mechanism -- MEDIUM

**Strategist Trust Model:**
- Strategies are built by individual strategists who go through a vetting process: concept review, code review, security review, mainnet testing
- The "Safe Farming Committee" must approve strategies before production deployment
- Strategists earn a 10% performance fee, aligning incentives with vault performance
- For strategies with >$10M TVL, a 3-person monitoring committee is expected to watch 24/7
- Risk: the strategist model relies on human judgment and monitoring; a rogue or compromised strategist could theoretically deploy a malicious strategy if vetting is circumvented

**Composability Risk (the primary economic risk):**
- Yearn vaults deposit into multiple underlying protocols (Curve, Convex, Aave, Compound, Maker, etc.)
- Risk compounds multiplicatively: a failure in any underlying protocol can drain a Yearn vault
- yPRISMA adds further dependency layers through Prisma Finance governance participation
- The yETH pool aggregated 8 different liquid staking tokens (apxETH, sfrxETH, wstETH, cbETH, rETH, ETHx, mETH, wOETH) -- each one a dependency risk

**Insurance / Bad Debt Handling:**
- No dedicated insurance fund with disclosed size
- No socialized loss mechanism documented for V3 vaults
- Historical losses from exploits (~$9.3M in Nov-Dec 2025) were partially recovered ($2.4M) through cooperation with counterparties, not from an insurance fund
- This represents a significant gap compared to peers like Aave (Safety Module ~2% of TVL)

### 4. Smart Contract Security -- MEDIUM

**Audit History:**
- V3 Vaults: Audited by ChainSecurity (no critical/high findings), MixBytes (no critical findings, 2 major), StateMind, and yAudit
- V2 Vaults: Audited by Trail of Bits, ChainSecurity, MixBytes
- Legacy contracts (iearn, yETH): Insufficient audit coverage for deprecated but still-deployed contracts
- Audit Coverage Score: ~3.0 (weighted by recency)

**Bug Bounty:**
- Active Immunefi program with rewards up to $200,000
- Covers all current production vaults and strategies
- No end date; scope dynamically updated as vaults are added/removed
- The $200K max payout is relatively low compared to peers (Aave: $1M+)

**Exploit History (significant concern):**
1. **Feb 2021**: DAI vault exploit, ~$11M loss (flash loan + misconfigured yUSDT)
2. **Apr 2023**: iearn USDT exploit, ~$11.5M loss (copy-paste configuration error in legacy contract, flash loan attack)
3. **Nov 30, 2025**: yETH exploit, ~$9M loss (arithmetic underflow in weighted stableswap pool, $2.4M recovered)
4. **Dec 17, 2025**: Legacy TUSD vault exploit, ~$300K loss (donation attack on V1 vault)

Pattern: All four exploits targeted legacy or peripheral contracts, NOT the core V2/V3 vault infrastructure. However, the persistence of exploitable legacy contracts that still hold user funds is a systemic concern. The team has repeatedly stated "current contracts are safe" after each exploit while legacy contracts remain deployed and vulnerable.

**Code Quality:**
- Written in Vyper (not Solidity), which has a smaller auditor ecosystem but is considered less prone to certain vulnerability classes
- V3 architecture is ERC-4626 compliant, which provides standardization benefits
- Open source on GitHub (yearn/yearn-vaults-v3)

### 5. Cross-Chain & Bridge -- LOW

- Yearn deploys natively on each chain (Ethereum, Arbitrum, Optimism, Base, Polygon, Fantom, Katana)
- Each chain deployment operates independently -- no cross-chain liquidity pooling or bridged assets
- No dependency on third-party bridges for core vault operations
- Users must independently bridge assets to deposit on different chains
- Governance appears to be Ethereum-centric with no documented cross-chain governance messaging
- Per-chain TVL is heavily concentrated on Ethereum ($140M) and Katana ($72M), with L2 deployments holding <$5M each
- Risk is LOW because there is no bridge attack surface, but governance centralization on Ethereum means L2 deployments may have different (possibly weaker) admin configurations -- UNVERIFIED

### 6. Operational Security -- MEDIUM

**Team & Track Record:**
- Andre Cronje founded Yearn in 2020 but departed from DeFi entirely in March 2022 (citing SEC pressure)
- Cronje has since returned to crypto with Sonic Labs/Flying Tulip but is not actively involved in Yearn
- Current team operates pseudonymously -- contributors are known by handles, not real-world identities
- The team has a track record dating to 2020, making it one of the more established DeFi teams

**Incident Response:**
- Nov 2025 yETH exploit: war room convened within ~20 minutes, SEAL 911 engaged shortly after
- Partial recovery of $2.4M achieved through coordination with Plume/Dinero teams
- Communication was timely via Twitter and governance forum
- However, the response was reactive -- the exploitable legacy contracts had been known risks for years

**Dependencies:**
- Heavy dependency on Curve Finance (many strategies are Curve/Convex-based)
- Dependency on liquid staking protocols (Lido, Rocket Pool, Coinbase, Frax, etc.) for yETH
- Dependency on Chainlink for price feeds
- Any failure in Curve, Convex, or major LST protocols could cascade into Yearn vaults

## Critical Risks

1. **Legacy Contract Technical Debt (HIGH)**: Four exploits since 2021, all targeting legacy/peripheral contracts that remain deployed with user funds. The pattern of "current vaults are safe" statements after each exploit while leaving legacy contracts live suggests insufficient deprecation and migration practices.

2. **No Insurance Fund (HIGH)**: Unlike peers such as Aave (Safety Module) or Nexus Mutual integration, Yearn has no disclosed insurance fund or bad debt backstop. Users bear 100% of loss risk from strategy failures or exploits.

3. **Composability Risk Stacking (MEDIUM)**: As a yield aggregator, Yearn inherits the smart contract risk of every protocol its strategies deposit into. A single Curve or Convex vulnerability could cascade into significant Yearn vault losses.

4. **Pseudonymous Team (MEDIUM)**: While pseudonymity is common in DeFi, it increases social engineering risk and reduces accountability. The founder is no longer involved.

## Peer Comparison

| Feature | Yearn Finance | Convex Finance | Beefy Finance |
|---------|--------------|----------------|---------------|
| Timelock | 3 days (setGovernance only) | 2 days (all admin) | 6h-24h varies |
| Multisig | 6/9 Gnosis Safe | 3/5 multisig | 3/6 multisig |
| Audits | 6+ (V2+V3 combined) | 3+ | 2+ |
| Oracle | Chainlink (limited use) | Chainlink (limited use) | Chainlink |
| Insurance/TVL | Undisclosed / none | None | None |
| Open Source | Yes (Vyper) | Yes (Solidity) | Yes (Solidity) |
| Bug Bounty | $200K (Immunefi) | $250K (Immunefi) | $200K (Immunefi) |
| Exploit History | 4 exploits (~$31M total) | None known | 1 exploit (Balancer-related, 2025) |
| TVL | ~$218M | ~$1.75B | ~$200M |

## Recommendations

- **For depositors**: Avoid legacy V1/iearn vaults entirely. Only use V2 or V3 vaults that are actively maintained and listed on the current yearn.fi interface. Check that your specific vault has been recently harvested and is actively managed.
- **For large depositors**: Consider that Yearn has no insurance fund. Self-insure through position sizing or use DeFi insurance protocols (Nexus Mutual, InsurAce) to cover Yearn vault positions.
- **For the Yearn team**: Prioritize forced deprecation and migration of all legacy contracts that still hold user funds. Consider implementing mandatory timelocks for V3 vault role changes, not just setGovernance. Increase bug bounty maximum to at least $500K-$1M given TVL scale.
- **For governance participants**: Push for transparent insurance/treasury fund disclosure and consider establishing a formal bad debt backstop mechanism.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- V3 role_manager can add strategies without mandatory timelock (UNVERIFIED if timelock is configured per deployment)
- [x] Admin can change oracle sources arbitrarily? -- Not directly applicable (yield aggregator)
- [ ] Admin can modify withdrawal limits? -- V3 WITHDRAW_LIMIT_MANAGER role exists; timelock status UNVERIFIED
- [x] Multisig has low threshold (2/N with small N)? -- No, 6/9 is strong
- [ ] Zero or short timelock on governance actions? -- 3-day on setGovernance only; other actions lack documented timelock
- [x] Pre-signed transaction risk? -- Not applicable (EVM, not Solana)
- [ ] Social engineering surface area (anon multisig signers)? -- Yes, signers are pseudonymous with PGP attestation only

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- yETH pool included multiple LSTs, some with lower liquidity
- [x] Single oracle source without TWAP? -- Limited oracle dependency for yield aggregator
- [x] No circuit breaker on price movements? -- Not directly applicable
- [ ] Insufficient insurance fund relative to TVL? -- Yes, no disclosed insurance fund

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- No bridge dependency
- [ ] Admin keys stored in hot wallets? -- Unknown, UNVERIFIED
- [ ] No key rotation policy? -- Signer rotation has occurred (YIP-84, YIP-89) but no documented schedule

## Information Gaps

- Exact composition and configuration of V3 vault role_manager assignments per chain (which addresses hold which roles, are they multisigs or EOAs?)
- Whether timelocks are configured on V3 role changes beyond setGovernance
- Current YFI minting ownership status (was the proposal to burn minting ability executed?)
- Treasury/insurance fund size and composition
- Specific admin configurations for L2 deployments (Arbitrum, Optimism, Base) -- are they using the same 6/9 multisig or different setups?
- Full list of currently active strategies and their underlying protocol dependencies
- Key storage practices for multisig signers
- Whether any remaining legacy contracts still hold significant user funds post-2025 exploits
- Status of yETH remediation plan and timeline for affected depositor compensation beyond the $2.4M recovered
- Andre Cronje's residual influence or token holdings, if any

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
