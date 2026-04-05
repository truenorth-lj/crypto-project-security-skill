# DeFi Security Audit: Ether.fi

**Audit Date:** April 5, 2026
**Protocol:** Ether.fi -- Liquid Restaking Protocol (Ethereum, Arbitrum, Base)

## Overview
- Protocol: Ether.fi (ether.fi Stake)
- Chain: Ethereum (primary), Arbitrum, Base
- Type: Liquid Restaking
- TVL: ~$4.8B (Ethereum: ~$4.8B, Arbitrum: ~$1.4M, Base-staking: negligible)
- TVL Trend: -2.6% / 7d, -10.0% / 30d, -45.0% / 90d
- Launch Date: March 2023 (mainnet)
- Audit Date: April 5, 2026
- Source Code: Open (GitHub: etherfi-protocol/smart-contracts)
- Token: ETHFI (ERC-20, 0xFe0c30065B384F05761f15d0CC899D4F9F9Cc0eB)
- Fundraising: $5.3M (Seed, Feb 2023) + $27M (Series A, Feb 2024)
- Team: Doxxed founders (Mike Silagadze, Rok Kopp)

## Quick Triage Score: 72/100
- Red flags found: 2
  - TVL declined ~45% over 90 days (market conditions or outflows -- requires monitoring)
  - No dedicated insurance fund publicly documented
- GoPlus token security: 0 HIGH / 0 MEDIUM flags

## Quantitative Metrics

| Metric | Value | Benchmark (Lido / Rocket Pool) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Not publicly documented | Lido: ~2% (Safety Module) / Rocket Pool: RPL collateral | HIGH |
| Audit Coverage Score | 7+ audits (high recency, multiple firms) | Lido: 10+ / Rocket Pool: 5+ | LOW risk |
| Governance Decentralization | Timelock + RoleRegistry + multisig | Lido: DAO + Dual Governance / Rocket Pool: DAO | MEDIUM |
| Timelock Duration | 3 days (72h) for Vault operations (UNVERIFIED for core contracts) | Lido: 3-7 days dynamic / Rocket Pool: DAO vote | MEDIUM |
| Multisig Threshold | Gnosis Safe (exact threshold UNVERIFIED) | Lido: 6/10 Guardian / Rocket Pool: varies | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 0 MED | -- | LOW risk |

## GoPlus Token Security (ETHFI on Ethereum)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | No | -- |
| Mintable | No | -- |
| Owner Can Change Balance | No | -- |
| Hidden Owner | No | -- |
| Selfdestruct | No | -- |
| Transfer Pausable | No | -- |
| Blacklist | No | -- |
| Slippage Modifiable | No | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 107,661 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No | -- |
| Anti-Whale | No | -- |
| External Call | No | -- |
| Trading Cooldown | No | -- |
| Top Holder Concentration | ~17.3% (largest), ~10.2% (second) | MEDIUM |

GoPlus assessment: **LOW RISK**. The ETHFI governance token is a clean ERC-20 with no proxy, no mint function, no honeypot, no tax, no hidden owner, and no trading restrictions. The token contract itself is not upgradeable. Top holder concentration is moderate -- the largest holder (a contract at 0x7a6a...1c53) holds ~17.3% and the second (0x95bf...995e, an EOA) holds ~10.2%. This is typical for governance tokens with vesting/treasury allocations but warrants monitoring.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | Timelock + multisig present but exact signer details and core contract timelock durations not fully public | Partial |
| Oracle & Price Feeds | **MEDIUM** | Custom EtherFiOracle with committee quorum; eOracle integration adds decentralization | Partial |
| Economic Mechanism | **MEDIUM** | No documented insurance fund; TVL declining; withdrawal dependent on liquidity pool depth | Partial |
| Smart Contract | **LOW** | 7+ audits from reputable firms; open source; Immunefi bounty; formal verification (Certora) | Y |
| Token Contract (GoPlus) | **LOW** | Clean ERC-20; no proxy, no mint, no tax, no restrictions | Y |
| Operational Security | **LOW** | Doxxed founders with track record; domain attack thwarted; institutional backers | Y |
| **Overall Risk** | **MEDIUM** | **Strong audit coverage and clean token, but governance transparency gaps, no public insurance fund, and significant TVL decline need attention** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**Positive:**
- Ether.fi employs a TimelockController contract for governance actions, requiring a minimum delay before execution
- The protocol uses a RoleRegistry for role-based access control (RBAC) across the system, separating proposer, executor, and admin roles
- Vault operations use a 3-day timelock with multi-owner cancellation capability
- Gnosis Safe multisig (Cash Controller Safe at 0xA6cf33124cb342D1c604cAC87986B965F428AAC4) governs critical protocol components for Cash V3
- Protocol upgrades require both timelock and appropriate roles via RoleRegistry

**Concerns:**
- The exact multisig threshold (e.g., 3/5, 4/7) for the core staking contracts is not prominently documented -- UNVERIFIED
- Individual multisig signers are not publicly listed or doxxed beyond the founding team
- The timelock duration for core LiquidityPool and staking contract upgrades (as distinct from Vault operations) is not clearly stated in public documentation -- UNVERIFIED
- Whether the protocol has an emergency bypass mechanism (Security Council equivalent) is unclear -- UNVERIFIED
- Contracts are upgradeable via proxy pattern, with ProxyAdmin controlled by the timelock

**Comparison:** Lido's Dual Governance model with dynamic timelocks (3-45 days based on opposition) and publicly known 6/10 Guardian multisig represents a higher standard of governance transparency. Rocket Pool's permissionless validator model also reduces centralization risk.

### 2. Oracle & Price Feeds -- MEDIUM

**Architecture:**
- The EtherFiOracle is a custom oracle committee that monitors the beacon chain and EigenLayer
- Oracle members submit reports containing total staked ETH, accrued rewards, and slashing events
- Reports require a quorum of committee members to agree on the same hash before on-chain publication
- Once quorum is reached, the admin executes the report if it matches the consensus hash
- eOracle (eo.app) integration provides additional decentralized oracle infrastructure for peg securing

**How Rewards Work:**
- When the oracle report is published, the LiquidityPool increases total pooled ETH without increasing eETH shares
- This rebase mechanism raises the value of each eETH share, distributing rewards to all holders
- Node operators receive a separate allocation for infrastructure maintenance

**Concerns:**
- The oracle committee composition and member count are not publicly detailed -- UNVERIFIED
- Admin involvement in report execution (even with quorum) introduces a potential bottleneck
- Unlike Chainlink (used by Aave/Lido for price feeds), the EtherFiOracle is a protocol-operated oracle for reward reporting, creating a trust assumption on the committee
- No public documentation on circuit breakers or sanity checks for abnormal reports

**Comparison:** Lido uses a similar oracle committee model (AccountingOracle) with publicly documented members and quorum requirements. Chainlink serves as a price oracle for many protocols but is not directly comparable since EtherFiOracle reports staking rewards rather than market prices.

### 3. Economic Mechanism -- MEDIUM

**eETH / weETH Mechanism:**
- Users deposit ETH into the LiquidityPool and receive eETH (rebasing) or weETH (non-rebasing wrapper)
- eETH represents a share of the total pooled ETH; its value increases as rewards accrue
- weETH is designed for DeFi composability (lending, collateral, LP positions)
- ETH is natively restaked through EigenLayer, earning consensus rewards, execution rewards, and EigenLayer restaking rewards

**Withdrawal Mechanism:**
- Users can redeem eETH/weETH for ETH instantly if the liquidity pool has sufficient unbonded ETH
- If liquidity is insufficient, the protocol queues validator withdrawals (beacon chain exit process)
- This avoids the standard 14-day EigenLayer unstaking delay under normal conditions
- During periods of high redemption demand, withdrawals may be delayed

**Insurance / Bad Debt:**
- No dedicated insurance fund or safety module is publicly documented for the staking protocol
- The protocol relies on EigenLayer's slashing insurance mechanisms for restaking-related losses
- There is no publicly described socialized loss mechanism for validator slashing events
- Protocol revenue (fee on accrued rewards) presumably funds operations, but treasury allocation is opaque

**TVL Trend:**
- Current TVL: ~$4.8B (down from ~$8.7B 90 days ago)
- The ~45% decline over 90 days is significant and may reflect market-wide ETH price decline, competitive outflows, or reduced restaking demand
- 7-day decline of ~2.6% suggests stabilization

**Concerns:**
- Absence of a documented insurance fund is the most significant gap relative to peers
- Withdrawal liquidity depends on pool depth; a bank-run scenario could delay redemptions
- Fee structure and protocol revenue allocation are not transparently reported

**Comparison:** Lido has the Safety Module (~2% of TVL staked in AAVE Safety Module + stETH/ETH). Rocket Pool requires node operators to post RPL collateral (minimum 10% of staked ETH). Ether.fi's lack of a comparable mechanism is a notable gap.

### 4. Smart Contract Security -- LOW

**Audit History:**
- Hats Finance (December 2023) -- competitive audit, medium severity finding reported
- Zellic (January 2024, March 2024) -- two separate audits
- Decurity (April 2024)
- Halborn (June 2024, August 2024) -- two separate audits
- Paladin (September 2024)
- Certora (October 2024, January 2025) -- formal verification

This represents 7+ audits across 6 firms with high recency (most within the last 18 months). The inclusion of formal verification (Certora) is a strong positive signal.

**Bug Bounty:**
- Active Immunefi program
- Critical smart contract: up to $200,000 (10% of affected funds, min $10,000)
- All other Critical-classified impacts: $5,000 flat
- Scope covers core protocol contracts
- Payouts in USDC on Ethereum

**Battle Testing:**
- Protocol live since March 2023 (~3 years)
- Peak TVL exceeded $8.7B
- No smart contract exploits in production
- Open source codebase on GitHub

**Concerns:**
- Bug bounty max of $200K is lower than industry leaders (Lido: $2M, Aave: $1M)
- Given TVL of ~$4.8B, the bounty-to-TVL ratio is very low (~0.004%)

### 5. Operational Security -- LOW

**Team:**
- Mike Silagadze (CEO, Founder) -- doxxed, previously founded Top Hat (edtech, 500+ employees, $60M revenue), crypto since 2011, University of Waterloo
- Rok Kopp (Co-founder) -- doxxed
- Backed by institutional investors: CoinFund, Bullish, North Island VC, Chapter One, ConsenSys, OKX Ventures, and notable angels including Stani Kulechov (Aave) and Sandeep Nailwal (Polygon)

**Incident Response:**
- Successfully thwarted a domain takeover attempt in September 2024 via Gandi.net registrar
- The team detected the attack through email authentication verification (SPF, DKIM, DMARC)
- Domain locked down within hours; no user funds affected
- Response demonstrated functioning security monitoring and incident procedures

**Dependencies:**
- EigenLayer: Core dependency for restaking rewards and AVS participation. EigenLayer risks (slashing bugs, governance issues) directly affect Ether.fi
- Ethereum beacon chain: Validator performance and consensus rewards
- eOracle: Supplementary oracle infrastructure
- DeFi integrations: weETH is widely used as collateral across DeFi (Aave, Pendle, etc.), creating composability risk if eETH depegs

## Critical Risks

1. **No documented insurance fund (HIGH):** Unlike Lido (Safety Module) and Rocket Pool (RPL collateral), Ether.fi has no publicly documented mechanism to absorb slashing losses or bad debt. Users bear full exposure to validator slashing and EigenLayer AVS risks.

2. **Governance transparency gaps (MEDIUM):** Multisig signer identities, exact threshold, and core contract timelock durations are not prominently published. This makes independent verification of governance security difficult.

3. **EigenLayer dependency risk (MEDIUM):** As a liquid restaking protocol, Ether.fi inherits all risks from EigenLayer -- including potential AVS slashing events, smart contract vulnerabilities in EigenLayer itself, and governance changes to restaking parameters.

4. **TVL decline trajectory (MEDIUM):** A 45% TVL decline over 90 days warrants monitoring. While partially attributable to ETH price movements, sustained outflows could stress withdrawal liquidity.

## Peer Comparison

| Feature | Ether.fi | Lido | Rocket Pool |
|---------|----------|------|-------------|
| Type | Liquid Restaking | Liquid Staking | Liquid Staking |
| TVL | ~$4.8B | ~$23B | ~$3B |
| Timelock | 72h (Vault); core UNVERIFIED | 3-45 days (dynamic) | DAO vote |
| Multisig | Gnosis Safe (threshold UNVERIFIED) | 6/10 Guardian (public) | pDAO Guardian |
| Audits | 7+ (6 firms, formal verification) | 10+ (multiple firms) | 5+ (multiple firms) |
| Oracle | Custom EtherFiOracle + eOracle | AccountingOracle + Chainlink | Minipool-based |
| Insurance/TVL | Not documented | ~2% (Safety Module) | RPL collateral (10%+) |
| Open Source | Yes | Yes | Yes |
| Bug Bounty Max | $200K | $2M | $250K |
| Node Operators | Permissioned (professional set) | Permissioned (curated + DVT) | Permissionless |
| Validator Model | Native restaking via EigenLayer | Direct ETH staking | Minipool (16 ETH + 8 ETH) |
| Team | Doxxed | Doxxed (DAO) | Pseudonymous (DAO) |

## Recommendations

- **For users:** Ether.fi is a well-audited protocol with a doxxed team and institutional backing. The primary additional risk versus Lido/Rocket Pool is the lack of a documented insurance mechanism and the added EigenLayer restaking layer. Users should monitor withdrawal liquidity and TVL trends. Diversification across liquid staking providers is advisable.

- **For the protocol:**
  - Publish detailed governance documentation: multisig threshold, signer identities, timelock durations for all contract types
  - Establish and publicly document an insurance fund or safety module mechanism
  - Increase bug bounty maximum to be more proportional to TVL (recommend $1M+ for critical findings)
  - Publish oracle committee membership and quorum requirements
  - Provide transparent reporting on protocol revenue, treasury allocation, and fee breakdown

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- Not applicable (single-asset ETH staking)
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED; oracle committee changes not documented
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED; LiquidityPool admin capabilities not fully documented
- [ ] Multisig has low threshold (2/N with small N)? -- UNVERIFIED; threshold not publicly confirmed
- [ ] Zero or short timelock on governance actions? -- 72h for Vault; core contract timelock UNVERIFIED
- [ ] Pre-signed transaction risk? -- Not applicable (EVM, no durable nonce equivalent)
- [x] Social engineering surface area? -- Demonstrated by Sept 2024 domain attack attempt (successfully defended)

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- No; ETH only
- [ ] Single oracle source without TWAP? -- EtherFiOracle is committee-based with quorum, not a price oracle
- [ ] No circuit breaker on price movements? -- Not applicable (reward reporting, not price feeds)
- [x] Insufficient insurance fund relative to TVL? -- Yes; no documented insurance mechanism

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Multi-chain deployment exists (Arbitrum, Base) but core TVL is on Ethereum
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED; key storage practices not documented
- [ ] No key rotation policy? -- UNVERIFIED

## Information Gaps

- Exact multisig threshold and signer count for core staking contracts (LiquidityPool, eETH, validators)
- Identity of multisig signers beyond founding team
- Timelock duration for core staking contract upgrades (distinct from Vault 72h timelock)
- Whether an emergency bypass / Security Council mechanism exists
- Oracle committee member count, identities, and quorum threshold
- Insurance fund or safety module status and size
- Protocol treasury size and allocation breakdown
- Fee structure details (exact percentage split between protocol, node operators, depositors)
- Admin key storage practices (hardware wallet, MPC, etc.)
- Emergency pause capability scope and who can trigger it
- Key rotation policy and frequency
- Detailed node operator selection criteria and permissioning process
- EigenLayer AVS selection process and risk assessment methodology

## Disclaimer
This analysis is based on publicly available information and web research as of April 5, 2026. It is NOT a formal smart contract audit. The significant number of information gaps identified above represents unknown risk -- absence of evidence is not evidence of absence. Always conduct your own research (DYOR) and consider professional auditing services for investment decisions.
