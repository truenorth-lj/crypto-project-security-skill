# DeFi Security Audit: Uniswap

**Audit Date:** April 6, 2026
**Protocol:** Uniswap -- Multi-chain decentralized exchange (AMM)

## Overview
- Protocol: Uniswap (V2, V3, V4)
- Chain: Ethereum, Arbitrum, Base, BSC, Polygon, Optimism, Avalanche, Unichain, 30+ chains total
- Type: DEX (Automated Market Maker / CLMM)
- TVL: ~$3.09B (all versions); ~$1.58B (V3 only)
- TVL Trend: +0.2% / -0.1% / -31.1% (7d / 30d / 90d, V3)
- Launch Date: November 2018 (V1), May 2020 (V2), May 2021 (V3), January 2025 (V4)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: github.com/Uniswap)

## Quick Triage Score: 82/100

Starting at 100, deductions:

- [-8] GoPlus: is_anti_whale = 1 (anti-whale mechanism present, minor flag)
- [-5] Insurance fund / TVL: N/A for a DEX (no insurance fund -- LPs bear all impermanent loss risk)
- [-5] Undisclosed multisig signer identities (cross-chain bridge relay governance signers not fully public)

No CRITICAL or HIGH flags triggered. GoPlus shows clean token profile. Protocol is well-audited, open source, with on-chain governance and timelock.

Score: **82/100 = LOW risk**

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | N/A (DEX, no insurance fund) | N/A for AMM DEX | N/A |
| Audit Coverage Score | 6.5+ (9 V4 audits in 2024, V3 audits from 2021) | 1-3 avg | LOW risk |
| Governance Decentralization | On-chain DAO + Timelock | Multisig avg | LOW risk |
| Timelock Duration | 48h (minimum 2 days) | 24-48h avg | LOW risk |
| Multisig Threshold | N/A (direct DAO governance, no admin multisig) | 3/5 avg | LOW risk |
| GoPlus Risk Flags | 0 HIGH / 0 MED | -- | LOW risk |

**Audit Coverage Score calculation:**
- V4 core: 9 audits (OpenZeppelin, Trail of Bits, Spearbit, Certora, ABDK, Pashov x3+) -- all < 2 years old = 9.0
- V3 core: 2 audits (ABDK, Trail of Bits, 2021) -- 4-5 years old = 0.5
- V2 core: 2 audits (ConsenSys Diligence 2018, dapp.org 2020) -- >5 years old = 0.5
- Permit2, Universal Router, UNIfication fees: additional OpenZeppelin audits (2024-2025) = 3.0
- Total: ~13.0 (exceptionally high)
- Rating: LOW risk (>= 3.0 threshold)

## GoPlus Token Security (UNI on Ethereum)

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
| Holders | 382,483 | -- |
| Trust List | Yes | -- |
| Creator Honeypot History | No | -- |
| CEX Listed | Binance, Coinbase | -- |
| Anti-Whale | Yes | -- |

GoPlus assessment: **LOW RISK**. The UNI token is non-upgradeable (no proxy), non-mintable, has no hidden owner, no tax, no trading restrictions, and is on the GoPlus trust list. No flags of any severity. The token is listed on major CEXs and has 382K+ holders. The anti-whale mechanism is a design feature, not a risk.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **LOW** | On-chain DAO with 48h timelock; no admin multisig needed | Partial |
| Oracle & Price Feeds | **LOW** | AMM DEX -- is the oracle source, not consumer; TWAP available | Y |
| Economic Mechanism | **LOW** | Mature AMM model; LP risk is impermanent loss, not protocol insolvency | Y |
| Smart Contract | **LOW** | 9+ V4 audits, $15.5M bug bounty, 500+ researcher competition | Y |
| Token Contract (GoPlus) | **LOW** | Clean profile; non-proxy, non-mintable, trust-listed, 0% tax | Y |
| Cross-Chain & Bridge | **MEDIUM** | 30+ chain deployments; cross-chain governance relies on bridge trust | Partial |
| Operational Security | **LOW** | Doxxed team (Hayden Adams), Uniswap Foundation, SEC investigation closed | Y |
| **Overall Risk** | **LOW** | **Gold standard DEX; primary risk is cross-chain governance relay and V4 hooks ecosystem** | |

## Detailed Findings

### 1. Governance & Admin Key -- LOW

**Governance Architecture:**
Uniswap uses a fully on-chain governance system with three components:
1. **UNI Token** -- ERC-20 governance token (1B supply, non-mintable)
2. **Governor (GovernorBravo)** -- on-chain proposal and voting contract
3. **Timelock** -- minimum 2-day (48h) delay on all governance actions, with up to 30-day delay for major changes

**Key Governance Parameters:**
- Proposal threshold: 2.5M UNI (~0.25% of supply) required to submit a proposal
- Quorum: 40M UNI (~4% of supply) must vote for a proposal to pass
- Voting period: 7 days
- Timelock: 2-day minimum delay after proposal passes before execution
- No admin key, no multisig owner -- governance is the sole admin

**Timelock Bypass:**
There is no emergency multisig or security council that can bypass the timelock. This is both a strength (no backdoor) and a potential weakness (no emergency pause capability at the protocol level). Individual pool contracts in V3 are immutable once deployed. V4 introduces the PoolManager singleton, which is also governed by the DAO.

**UNIfication Proposal (December 2025):**
The landmark "UNIfication" proposal passed with 99.9% approval (125M UNI for, 742 against). This activated the fee switch, burned 100M UNI, and established a 20M UNI annual growth budget. The proposal demonstrated strong governance participation and alignment between Uniswap Labs and the DAO.

**Token Concentration:**
- Top holder: Timelock contract (0x1a9c...35bc) with ~264M UNI (26.5%) -- this is protocol treasury, not a whale
- Dead address: ~102M UNI (10.3%) burned
- Binance hot wallet: ~50M UNI (5%)
- Voting power concentration: Gini coefficient has improved from 0.990 (2022) to 0.913 (2025), showing gradual democratization
- a16z delegate holds ~15M votes (6.8% weight) -- largest single delegate
- ConsenSys holds ~7M votes (3.2%)
- No single entity can unilaterally pass proposals (quorum is 40M)

**Uniswap Labs vs Protocol Distinction:**
Uniswap Labs is a US-based company (NYC) that develops the frontend and contributes to protocol development. The protocol itself is autonomous smart contracts governed by UNI holders. The SEC closed its investigation into Uniswap Labs in February 2025 without enforcement action, validating the non-custodial protocol model.

### 2. Oracle & Price Feeds -- LOW

Uniswap is a DEX -- it is a price source, not a price consumer. This fundamentally changes the oracle risk profile compared to lending protocols.

**TWAP Oracles:**
- V3 provides built-in TWAP (Time-Weighted Average Price) oracles that other protocols consume
- V4 maintains oracle functionality through hooks
- TWAP window length is configurable by consumers, not controlled by Uniswap governance

**Price Manipulation Resistance:**
- Concentrated liquidity in V3/V4 makes price manipulation more expensive for deep pools
- Low-liquidity pools remain vulnerable to manipulation (this is inherent to AMMs, not a Uniswap-specific flaw)
- No circuit breakers exist within the protocol itself -- prices are purely market-driven

**Risk Assessment:**
The main oracle risk is not to Uniswap users but to protocols that consume Uniswap TWAP data. For Uniswap itself, the risk is MEV extraction (sandwich attacks, frontrunning), which Unichain's TEE-based block building aims to mitigate.

### 3. Economic Mechanism -- LOW

**AMM Model:**
- V2: Constant product (x*y=k) AMM -- simple, battle-tested since May 2020
- V3: Concentrated liquidity AMM (CLMM) -- LPs provide liquidity in specific price ranges
- V4: Singleton PoolManager with hooks -- same CLMM model with extensibility

**Fee Structure (Post-UNIfication):**
- LP fees: 0.25% (reduced from 0.30% for fee-switch pools)
- Protocol fees: 0.05% (newly activated, directed to UNI buyback/burn)
- Fee switch has been live since late 2025; over $5.5M in UNI burned as of early 2026 (~$34M annualized)

**Impermanent Loss:**
- The primary economic risk for LPs is impermanent loss, which is inherent to AMM design
- V3 concentrated liquidity amplifies both returns and impermanent loss
- No insurance fund exists -- losses are borne entirely by individual LPs
- This is standard for DEX protocols and not a unique risk

**Bad Debt:**
- Not applicable -- Uniswap is non-custodial and does not offer leverage or lending
- No socialized loss mechanism needed
- No liquidation mechanism (LPs can withdraw at any time)

**No Withdrawal Limits:**
- Users can swap and LPs can withdraw at any time without admin-imposed limits
- No rate limiting on deposits or withdrawals

### 4. Smart Contract Security -- LOW

**Audit History (Exceptional):**

*Uniswap V4 (2024-2025):*
- OpenZeppelin -- found 1 Critical (delegation bypass, fixed in PR #743), 1 Critical (CELO-specific accounting flaw, fixed)
- Trail of Bits
- Spearbit
- Certora (formal verification)
- ABDK
- Pashov Audit Group (3 rounds)
- Total: 9 independent audits
- $2.35M security competition with 500+ researchers -- no critical findings

*Uniswap V3 (2021):*
- ABDK (March 2021)
- Trail of Bits
- Audits linked on GitHub: github.com/Uniswap/uniswap-v3-core/tree/main/audits

*Uniswap V2 (2020):*
- ConsenSys Diligence (December 2018, V1 Vyper audit)
- dapp.org (2020, V2)

*Additional audits (2024-2026):*
- OpenZeppelin: Permit2, Universal Router, UNIfication Fees, UNIVesting, The Compact/Emissary
- Ongoing security partnership with OpenZeppelin throughout 2024-2025

**Bug Bounty:**
- V4: $15.5M maximum payout -- largest bug bounty in DeFi history
- Covers core and periphery contracts
- Additional program for Uniswap on zkSync ($20K max)
- Hosted on Cantina (open and ongoing)

**Battle Testing:**
- V2 has been live since May 2020 (6 years) with no core protocol exploit
- V3 has been live since May 2021 (5 years) with no core protocol exploit
- V4 deployed January 2025 (~15 months live)
- Peak combined TVL exceeded $10B
- The 2020 reentrancy incident was specific to ERC-777 token interaction, not a core protocol flaw
- The 2023 phishing attack targeted users, not the protocol

**V4 Hooks Security (NEW RISK SURFACE):**
V4 introduces "hooks" -- custom smart contract logic that can be attached to pools. This is a significant new attack surface:
- Cork Protocol lost $11M (May 2025) due to access control vulnerability in their V4 hook
- Bunni DEX lost $2.4M (September 2025) due to hook vulnerability
- Research shows ~36% of sample hooks may contain vulnerabilities
- Hooks are permissionless -- anyone can deploy a pool with any hook
- Key vulnerability categories: access control, custom accounting errors, reentrancy, delta handling
- IMPORTANT: These exploits affected third-party hook implementations, NOT Uniswap V4 core contracts

The core V4 PoolManager itself has not been exploited. The risk is in the ecosystem of hooks that build on top of V4, similar to how malicious tokens on Uniswap do not represent a flaw in the DEX itself.

### 5. Cross-Chain & Bridge -- MEDIUM

**Multi-Chain Deployment:**
Uniswap V3 is deployed on 40+ chains, making it one of the most widely deployed DeFi protocols. V4 is deployed on Ethereum and major L2s.

**Cross-Chain Governance:**
- All governance contracts live on Ethereum L1
- Cross-chain governance messages must be relayed via bridge contracts to other deployments
- The Uniswap Foundation conducted a formal bridge assessment process with expert committee
- Wormhole was fully approved for cross-chain governance relay
- Axelar was conditionally approved
- Recommended architecture: multi-bridge (2-of-3 quorum) for future deployments

**Bridge Risk Assessment:**
- Each new chain deployment requires a bridge to relay governance actions
- If a bridge is compromised, an attacker could potentially forge governance actions on that specific chain
- However, each chain's TVL is isolated -- a bridge compromise on one chain does not affect others
- Many smaller chain deployments use trusted bridges or multisigs rather than trust-minimized bridges

**Unichain:**
- Uniswap Labs launched Unichain (OP Stack L2) in February 2025
- Stage 1 rollup with permissionless fault proofs
- TEE-based block building (Flashbots collaboration) for MEV protection
- Unichain Validation Network (UVN) planned for additional decentralization
- Current TVL: ~$21M
- Risk: Unichain sequencer is currently centralized (operated by Uniswap Labs), typical for OP Stack rollups at this stage

**Key Concern:**
The sheer number of chain deployments (40+) creates a large surface area. Not all deployments have the same level of bridge security. Smaller chain deployments with trusted bridge setups represent a higher risk profile than mainnet Ethereum.

### 6. Operational Security -- LOW

**Team & Track Record:**
- Hayden Adams (founder, CEO of Uniswap Labs) -- fully doxxed, public figure since 2018
- Uniswap Labs is a registered US company in New York City
- Uniswap Foundation founded 2022 by Devin Walsh and Ken Ng -- separate nonprofit supporting the protocol
- Team has been operating since 2018 with no internal security incidents

**Incident Response:**
- No emergency pause mechanism at the protocol level (V2/V3 pools are immutable)
- V4 PoolManager governance could theoretically pause via governance proposal + timelock (slow)
- Individual protocols building on Uniswap (hooks) can implement their own pause mechanisms
- Uniswap Labs frontend can block tokens/addresses (has done so for sanctioned addresses and scam tokens)

**SEC Resolution:**
- SEC issued Wells Notice to Uniswap Labs in 2024
- Investigation closed February 2025 without enforcement action
- Validates the legal separation between Uniswap Labs (company) and Uniswap Protocol (autonomous contracts)

**Dependencies:**
- Ethereum L1 security for main governance and largest TVL share
- Bridge infrastructure for cross-chain governance relay
- Block builders / MEV infrastructure (Flashbots for Unichain)
- No oracle dependencies (Uniswap is the oracle source)

**Delegate Reward Initiative:**
The Uniswap community expanded delegate rewards to incentivize active governance participation, addressing historical low voter turnout. This is a positive signal for long-term governance health.

## Critical Risks

No CRITICAL risks identified. Notable HIGH-attention items:

1. **V4 Hooks Ecosystem Risk** -- Third-party hooks built on V4 have already been exploited ($11M Cork, $2.4M Bunni). While this does not threaten Uniswap core, users interacting with hook-enabled pools must independently assess hook security. There is no Uniswap-level vetting of hooks.

2. **Cross-Chain Governance Relay** -- With 40+ chain deployments, the trust assumptions for governance relay vary significantly. Some chains rely on trusted bridges or multisigs rather than trust-minimized solutions. A bridge compromise could affect governance on a specific chain.

3. **No Emergency Pause** -- The protocol has no emergency pause capability. While this eliminates admin key risk, it means the protocol cannot respond quickly to a discovered vulnerability. The 2-day minimum timelock means any governance response takes at least 48 hours minimum.

## Peer Comparison

| Feature | Uniswap | Curve | SushiSwap |
|---------|---------|-------|-----------|
| Timelock | 48h minimum | 72h (3 days) | 48h |
| Multisig | None (direct DAO) | Emergency DAO 4/9 | Ops multisig |
| Audits | 9+ (V4), 2+ (V3) | 4+ | 2-3 |
| Oracle | N/A (is the oracle) | Internal TWAP + Chainlink | N/A (is the oracle) |
| Insurance/TVL | N/A (DEX) | N/A (DEX) | N/A (DEX) |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | $15.5M (record) | $250K | $100K |
| Chain Deployments | 40+ | 15+ | 25+ |
| Fee Switch | Active (Dec 2025) | Active | Active |

Uniswap leads peers in audit depth, bug bounty size, and governance transparency. The lack of an emergency multisig is more aggressive than Curve's Emergency DAO but eliminates centralization risk.

## Recommendations

1. **For LPs:** Understand that impermanent loss risk is amplified in V3/V4 concentrated liquidity positions. No protocol insurance covers LP losses. Stick to deep, high-volume pools.

2. **For Swappers:** Use the official Uniswap frontend or well-known aggregators. Verify pool legitimacy before trading, especially on V4 hook-enabled pools. Prefer pools without custom hooks unless you have verified the hook contract.

3. **For V4 Hook Users:** Independently audit any hook contract before providing liquidity. The Cork Protocol and Bunni exploits demonstrate that hook vulnerabilities can drain user funds. Look for hooks that have been audited by reputable firms.

4. **For Governance Participants:** Delegate your UNI to active, reputable delegates if you cannot participate directly. The delegate reward initiative provides compensation for active participation.

5. **For Cross-Chain Users:** Be aware that governance on non-Ethereum chains depends on bridge security. Prefer deployments on chains with trust-minimized bridges (Ethereum L2s with native bridges) over chains with trusted/multisig bridges.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- N/A (DEX, no collateral)
- [ ] Admin can change oracle sources arbitrarily? -- N/A (DEX is the oracle)
- [ ] Admin can modify withdrawal limits? -- No withdrawal limits exist
- [ ] Multisig has low threshold (2/N with small N)? -- No multisig; direct DAO governance
- [ ] Zero or short timelock on governance actions? -- No; 48h minimum timelock
- [ ] Pre-signed transaction risk? -- No; on-chain governance with voting period
- [ ] Social engineering surface area (anon multisig signers)? -- No multisig to compromise

**Drift-type risk: VERY LOW.** Uniswap's governance architecture has no admin keys, no multisig, and mandatory timelocks. There is no single point of compromise.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A (no lending/collateral)
- [ ] Single oracle source without TWAP? -- N/A (Uniswap provides TWAPs to others)
- [ ] No circuit breaker on price movements? -- Yes, no circuit breakers (inherent to AMM design)
- [ ] Insufficient insurance fund relative to TVL? -- N/A (DEX)

**Euler/Mango-type risk: LOW.** AMM price manipulation is possible in low-liquidity pools but affects individual traders, not the protocol itself.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- Partial; some cross-chain deployments use trusted bridges
- [ ] Admin keys stored in hot wallets? -- No admin keys
- [ ] No key rotation policy? -- No keys to rotate

**Ronin/Harmony-type risk: LOW-MEDIUM.** Cross-chain governance relay introduces some bridge dependency, but each chain's TVL is isolated. A bridge compromise would only affect governance on one chain.

## Information Gaps

- **Cross-chain bridge configurations per chain:** The specific bridge used for governance relay on each of the 40+ chains is not fully documented publicly. Some may use single-operator bridges.
- **Unichain sequencer decentralization timeline:** The UVN (Unichain Validation Network) is planned but not yet live. Current sequencer is centralized.
- **V4 hooks registry or vetting process:** There is no public registry of audited/approved hooks. Users must independently assess hook security.
- **Emergency response playbook:** No public incident response plan. The lack of emergency pause means the protocol relies entirely on the 48h+ governance process for any response.
- **Delegate identity verification:** While top delegates are known entities (a16z, ConsenSys), many smaller delegates are pseudonymous.
- **Insurance coverage:** No protocol-level insurance or safety module. Third-party insurance (Nexus Mutual, etc.) coverage levels for Uniswap positions are unknown.
- **V4 formal verification scope:** Certora performed formal verification, but the exact scope and invariants verified are not fully public.

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
