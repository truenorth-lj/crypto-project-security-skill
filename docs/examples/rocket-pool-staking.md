# DeFi Security Audit: Rocket Pool

**Audit Date:** April 6, 2026
**Protocol:** Rocket Pool -- Decentralized Ethereum Liquid Staking Protocol

## Overview
- Protocol: Rocket Pool
- Chain: Ethereum
- Type: Liquid Staking
- TVL: ~$1.17B (plus ~$17M staking TVL)
- TVL Trend: +0.7% / +3.3% / -37.2% (7d / 30d / 90d)
- Launch Date: November 2021 (mainnet)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: rocket-pool/rocketpool)

## Quick Triage Score: 79/100

Starting at 100, deductions applied mechanically:

- [x] GoPlus: is_mintable = 1 (-8) -- RPL token is mintable (inflation mechanism for rewards)
- [x] No documented timelock on admin/upgrade actions (-5)
- [x] Undisclosed multisig signer identities (-5) -- oDAO membership is known but Security Council signer identities not fully public
- [x] Insurance fund / TVL < 1% or undisclosed (-5) -- RPL collateral insurance is protocol-native but ratio is hard to quantify precisely

Score: 100 - 8 - 5 - 5 - 5 = **79** (MEDIUM risk)

Red flags found: 4 (mintable token, no formal timelock on contract upgrades, partially undisclosed Security Council signers, unclear insurance ratio)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | RPL collateral-based (est. ~2-5%) | Lido: 0% direct insurance | MEDIUM |
| Audit Coverage Score | 3.75 (3 firms x 0.25 old + 3 firms x 0.5 recent + 1 x 1.0 recent) | Lido: ~4.0 | LOW risk |
| Governance Decentralization | On-chain pDAO + oDAO + Security Council | Lido: DAO + 4/8 multisig | LOW risk |
| Timelock Duration | None on contract upgrades (oDAO consensus required) | Lido: 48h, Aave: 24-168h | HIGH risk |
| Multisig Threshold | oDAO ~17 members, majority vote; Security Council quorum-based | Lido: 4/8 | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW risk |

## GoPlus Token Security (RPL on Ethereum)

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
| Holders | 12,097 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No (0) | -- |
| CEX Listed | Binance, Coinbase | -- |

GoPlus assessment: **LOW RISK**. The only flag is `is_mintable = 1`, which reflects RPL's intentional 5% annual inflation mechanism used to reward node operators, oDAO members, and the protocol treasury. No honeypot, no hidden owner, no tax, no trading restrictions. Top holder (~45.5%) is a contract address (likely protocol staking/rewards contract). Creator balance is 0%.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | oDAO controls upgrades without formal timelock; guardian powers being deprecated | Partial |
| Oracle & Price Feeds | **LOW** | oDAO consensus-based oracle; Chainlink feed available for rETH/ETH | Partial |
| Economic Mechanism | **LOW** | RPL collateral insurance; permissionless node operators with skin in the game | Y |
| Smart Contract | **LOW** | 6+ audits across 4 major firms; active Immunefi bounty; open source | Y |
| Token Contract (GoPlus) | **LOW** | Mintable (by design for inflation); no malicious flags | Y |
| Cross-Chain & Bridge | **N/A** | Ethereum-only protocol | N/A |
| Operational Security | **LOW** | Doxxed founders; published post-mortems; 4+ years live | Y |
| **Overall Risk** | **MEDIUM** | **Strong decentralization design but oDAO trust model and lack of timelock on upgrades are residual risks** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

Rocket Pool has one of the most complex and layered governance structures in DeFi, consisting of three bodies:

**Protocol DAO (pDAO):**
- On-chain governance introduced with the Houston upgrade (June 2024)
- Any node operator with non-zero voting power can submit proposals
- Proposals require an RPL bond from the proposer
- Voting occurs in two phases: Phase 1 for direct votes and delegates, Phase 2 for delegators to override their delegate
- Supports Abstain, For, Against, and Veto options; if veto quorum is met, the proposer loses their bond
- Controls protocol settings, treasury allocations, and Security Council appointments

**Oracle DAO (oDAO):**
- Invite-only membership of trusted Ethereum ecosystem participants (~17 members historically)
- Members include entities like Etherscan, Beaconchain, Lighthouse, Nimbus, Bankless, ConsenSys (Codefi), and Gitcoin
- Responsible for: reporting Beacon Chain data to Execution Layer, constructing Merkle reward trees, monitoring validator compliance
- Critically, the oDAO also has the power to approve smart contract upgrades
- oDAO is governed by RPIP-24 charter, which constrains them to a caretaker role rather than active governance

**Security Council:**
- Introduced with Houston to provide emergency response capabilities
- Elected by the pDAO via on-chain governance
- Can pause the protocol quickly in the event of potential issues
- Quorum among members required for any security action
- Limited to pause functionality -- cannot upgrade or drain funds

**Guardian Role:**
- The original team-controlled "guardian" role allowed disabling protocol features to protect against exploits
- As of late 2025, the team has been working to disable the guardian role entirely, transferring all authority to the pDAO and Security Council
- Status of guardian deprecation: UNVERIFIED as of audit date

**Upgrade Mechanism -- HIGH concern:**
- Rocket Pool uses a custom upgrade pattern via RocketStorage, a central registry contract
- All protocol contracts register their addresses in RocketStorage
- Contract upgrades involve replacing registered contract addresses, controlled by the oDAO through trusted node consensus
- There is NO formal on-chain timelock on contract upgrades -- the oDAO's multi-party consensus serves as the check instead
- This differs from industry standard (Aave: 24-168h timelock, Lido: 48h timelock)
- The absence of a timelock means if oDAO members are compromised, upgrades could be executed immediately

### 2. Oracle & Price Feeds -- LOW

**Internal Oracle (oDAO-based):**
- The oDAO reports Beacon Chain validator balances and statuses to the Execution Layer approximately every 24 hours
- The rETH/ETH exchange rate is derived from total ETH staked + rewards across all minipools, divided by total rETH supply
- This is a consensus-based oracle: multiple oDAO members must agree on the reported values
- Manipulation would require compromising a majority of oDAO members

**External Price Feeds:**
- Chainlink provides an rETH/ETH price feed for external DeFi integrations
- This serves as a secondary reference but is not used for internal protocol operations

**Strengths:**
- Multi-party consensus model is more resilient than single oracle
- Oracle data (Beacon Chain balances) is publicly verifiable
- No single entity can manipulate the reported exchange rate

**Weaknesses:**
- oDAO membership is invite-only, creating a centralization vector
- If the oDAO majority were compromised, they could report false balances (though this would be detectable on-chain)

### 3. Economic Mechanism -- LOW

**Minipool Architecture:**
- Node operators deposit 8 ETH (reduced from 16 in Atlas upgrade, early 2023)
- Protocol matches with 24 ETH from the liquid staking deposit pool
- Each minipool is a separate smart contract managing one validator
- Saturn 1 (upcoming) will introduce "megapools" -- single contract per node operator managing multiple validators, reducing gas costs and enabling 4 ETH bonds

**RPL Collateral Insurance:**
- Pre-Saturn 0: Node operators required to stake RPL worth 10-150% of their ETH value
- Post-Saturn 0 (October 2024): RPL bond is optional; new minipools can be created with only 8 ETH
- Staking RPL still provides a commission boost (5% base to up to 14% with RPL stake)
- If a node operator is penalized/slashed and finishes with less than their borrowed ETH, their RPL collateral is auctioned to compensate the protocol

**Commission Structure (Saturn 0):**
- Base commission: 5% of staking rewards on borrowed ETH
- Commission boost: +5% to +9% depending on RPL stake level
- Total range: 10% to 14%

**RPL Tokenomics:**
- 5% annual inflation, split: 70% to node operators, 15% to oDAO, 15% to pDAO treasury
- Saturn 0 shifted value capture from inflation-dependent to protocol revenue-dependent

**Withdrawal Mechanism:**
- rETH holders can redeem directly when ETH is available in the deposit pool
- If no surplus exists and rETH trades at a discount, node operators are incentivized to buy discounted rETH, exit their minipool, and arbitrage
- No forced withdrawal delays beyond Ethereum's validator exit queue

**Risk Assessment:**
- Permissionless node operators with minimum 8 ETH skin-in-the-game is strong alignment
- RPL bond removal in Saturn 0 reduces the insurance buffer for new minipools
- rETH peg mechanism is market-driven with natural arbitrage incentives
- No catastrophic bad debt events in 4+ years of operation

### 4. Smart Contract Security -- LOW

**Audit History:**
- Sigma Prime: Original protocol (May 2021), Atlas upgrade (2023)
- Consensys Diligence: Original protocol (April 2021), Atlas v1.2 (January 2023), Houston (December 2023)
- Trail of Bits: Original protocol (September 2021)
- Chainsafe: Houston release (April 2024) -- 0 critical, 0 high, 0 medium issues found

Audit Coverage Score calculation:
- Chainsafe Houston (Apr 2024, ~2 years old): 0.5
- Consensys Houston (Dec 2023, ~2.3 years old): 0.25
- Sigma Prime Atlas (2023, ~3 years old): 0.25
- Consensys Atlas (Jan 2023, ~3 years old): 0.25
- Earlier audits (2021, 4+ years old): 3 x 0.25 = 0.75
- **Total: ~2.0** (MEDIUM threshold, but breadth of coverage across 4 firms is strong)

**Notable Audit Findings (historical):**
- Atlas v1.2 audit flagged checks-effects-interactions pattern violations and potential reentrancy vectors; these were addressed
- Houston audit was clean with only very low severity findings

**Bug Bounty:**
- Active Immunefi program
- Critical: $150,000 payout (reduced from earlier $500,000 cap in February 2026 restructuring)
- High: $15,000
- Scope includes Houston code
- Historical success: Withdrawal credentials exploit was caught via bug bounty pre-launch (October 2021)

**Battle Testing:**
- Live since November 2021 (~4.5 years)
- Peak TVL: ~$3.17B (August 2025)
- Current TVL: ~$1.17B
- Over 2,700 permissionless node operators
- Open source: full codebase on GitHub (rocket-pool/rocketpool)

### 5. Cross-Chain & Bridge -- N/A

Rocket Pool operates exclusively on Ethereum. rETH is bridged to L2s by third parties (Arbitrum, Optimism, etc.) but this is outside the protocol's control and not a dependency for the core system.

### 6. Operational Security -- LOW

**Team:**
- David Rugendyke: Founder and CTO, publicly identified (LinkedIn, Crunchbase, The Org)
- Darren Langley: General Manager and Senior Developer, publicly identified
- Core team is Australian-based, doxxed with professional profiles
- Long track record in Ethereum ecosystem (protocol concept dates to 2016)

**Incident History:**
- October 2021: Withdrawal credentials exploit discovered via bug bounty pre-launch; launch postponed, fix implemented, no funds lost
- May 2022: Two team-operated oDAO nodes compromised via developer machine access; ~$28K in ETH and RPL stolen from node accounts (not protocol funds); post-mortem published
- January 2024: X (Twitter) account compromised; phishing links posted; social engineering attack, not protocol vulnerability

**Incident Response:**
- Published post-mortems for all incidents
- Bug bounty program successfully caught critical pre-launch vulnerability
- Security Council (post-Houston) provides structured emergency response
- Emergency pause capability exists

**Dependencies:**
- Ethereum Beacon Chain (consensus layer) -- fundamental dependency
- IPFS for Merkle reward tree storage
- No bridge dependencies
- No external oracle dependencies for core operations

## Critical Risks (if any)

No CRITICAL findings. Two HIGH-concern items:

1. **No formal timelock on contract upgrades**: The oDAO's consensus mechanism serves as the sole check on upgrades. While the oDAO consists of reputable ecosystem participants, the absence of a time-delayed execution window means users cannot exit before a malicious upgrade takes effect. This is below industry standard (Aave: 24-168h, Lido: 48h).

2. **oDAO trust model**: The oDAO is invite-only with ~17 members. While members are generally known ecosystem entities, the trust model means protocol security depends on the integrity of this small group for oracle reporting AND contract upgrades. Compromise of a majority could be catastrophic.

## Peer Comparison

| Feature | Rocket Pool | Lido | StakeWise V3 |
|---------|------------|------|-------------|
| Timelock | None (oDAO consensus) | 48h | 24h |
| Multisig / Governance | pDAO (on-chain) + oDAO (~17) + Security Council | DAO + 4/8 multisig | DAO + multisig |
| Audits | 6+ (4 firms) | 10+ (5+ firms) | 3+ |
| Oracle | oDAO consensus (~17 members) | Lido Oracle Committee (9 members) | Internal |
| Insurance/TVL | RPL collateral (~2-5% est.) | Lido cover fund (~0.5%) | Operator bonds |
| Open Source | Yes | Yes | Yes |
| Node Operators | 2,700+ permissionless | ~30 permissioned | Permissionless |
| Min Operator Bond | 8 ETH (4 ETH in Saturn 1) | 0 (permissioned) | 1 ETH |
| Bug Bounty Max | $150K | $250K | $100K |

## Recommendations

1. **For rETH holders / stakers**: Rocket Pool is one of the most decentralized liquid staking options on Ethereum. The permissionless node operator model and RPL collateral system provide strong alignment. The main concern is the absence of a formal timelock on upgrades -- monitor governance proposals and oDAO activity.

2. **For node operators**: Post-Saturn 0, RPL staking is optional but provides meaningful commission boosts (5-9% additional). The 8 ETH bond requirement is a reasonable entry point. Ensure you understand slashing risks and RPL collateral mechanics.

3. **For DeFi integrators using rETH**: The rETH/ETH exchange rate is reported by the oDAO consensus mechanism and verifiable on-chain. Use the Chainlink rETH/ETH feed as an additional reference. Be aware of potential withdrawal delays when the deposit pool is depleted.

4. **For the protocol team**: Consider implementing a formal on-chain timelock for contract upgrades, even if short (24-48h). This would bring Rocket Pool in line with industry standards and provide users an exit window. The ongoing guardian deprecation is a positive step.

5. **Monitor the Saturn 1 transition**: The shift to megapools and 4 ETH bonds will significantly change the risk profile. New audits for Saturn 1 contracts should be confirmed before participation.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- N/A (not a lending protocol)
- [x] Admin can change oracle sources arbitrarily? -- oDAO controls oracle reporting; no timelock on changes
- [ ] Admin can modify withdrawal limits? -- No admin-controlled withdrawal limits
- [ ] Multisig has low threshold (2/N with small N)? -- oDAO has ~17 members with majority threshold
- [x] Zero or short timelock on governance actions? -- No formal timelock on contract upgrades
- [ ] Pre-signed transaction risk? -- Not applicable (Ethereum, not Solana)
- [ ] Social engineering surface area (anon multisig signers)? -- oDAO members are known ecosystem entities

**Drift pattern match: LOW** -- oDAO's multi-party nature and known membership mitigate governance attack risk, but the absence of a timelock is a notable gap.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A (staking protocol, not lending)
- [ ] Single oracle source without TWAP? -- oDAO consensus-based, not single source
- [ ] No circuit breaker on price movements? -- rETH exchange rate is mechanically derived, not market-based
- [ ] Insufficient insurance fund relative to TVL? -- RPL collateral provides partial coverage; exact ratio unclear

**Euler/Mango pattern match: LOW** -- The liquid staking model has fundamentally different risk vectors than lending protocols.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No bridge dependency
- [x] Admin keys stored in hot wallets? -- May 2022 incident involved developer machine compromise of oDAO nodes
- [ ] No key rotation policy? -- UNVERIFIED

**Ronin/Harmony pattern match: LOW** -- No bridge dependency. The 2022 oDAO node compromise was limited in scope ($28K) and did not affect protocol funds.

## Information Gaps

- **Exact Security Council composition and threshold**: The number of Security Council members and their identities are not fully documented in public sources as of audit date
- **Guardian deprecation status**: The team indicated the guardian role would be disabled by late 2025, but current status is UNVERIFIED
- **Precise insurance fund ratio**: The exact ratio of RPL collateral backing to total TVL is difficult to calculate from public data, particularly post-Saturn 0 when RPL bonds became optional
- **oDAO member count (current)**: Historical references suggest ~17 members, but the exact current count and full member list are not readily available without querying on-chain data
- **Key rotation and operational security policies**: No public documentation found on key management practices for oDAO members or Security Council
- **Saturn 1 audit status**: Saturn 1 development is ongoing; audit completion status for megapool contracts is UNVERIFIED
- **Timelock implementation plans**: Whether the team plans to add a formal timelock for contract upgrades is unclear from public documentation

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
