# DeFi Security Audit: mETH Protocol (Mantle Staked ETH)

## Overview
- Protocol: mETH Protocol (formerly Mantle LSP)
- Chain: Ethereum L1 (with L2 token on Mantle Network)
- Type: Liquid Staking
- TVL: $661.7M
- TVL Trend: -3.9% / +7.7% / -16.5% (7d / 30d / 90d)
- Launch Date: December 2023 (DeFiLlama listing: 2023-12-04)
- Audit Date: 2026-04-20
- Valid Until: 2026-07-19 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Open (MIT license, GitHub: mantle-lsp/contracts)

## Quick Triage Score: 54/100 (MEDIUM) | Data Confidence: 75/100 (HIGH)

### Quick Triage Score Calculation

Starting at 100. Deductions applied mechanically per SKILL.md formula:

CRITICAL flags (-25 each): None triggered.

HIGH flags (-15 each): None confirmed. Multisig status is UNVERIFIED (cannot confirm single EOA -- flagged in Information Gaps instead).

MEDIUM flags (-8 each):
- [x] GoPlus: is_proxy = 1 AND no effective timelock on upgrades (timelock delay = 0) -- -8
- [x] No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations -- -8

LOW flags (-5 each):
- [x] No documented timelock on admin actions (delay = 0, effectively instant) -- -5
- [x] Undisclosed multisig signer identities -- -5
- [x] No published key management policy (HSM, MPC, key ceremony) -- -5
- [x] No disclosed penetration testing (infrastructure-level) -- -5
- [x] Insurance fund / TVL undisclosed -- -5
- [x] Single oracle provider (custom proprietary oracle network) -- -5
- [x] No disclosed penetration testing -- already counted above, skip

Total deductions: 8 + 8 + 5 + 5 + 5 + 5 + 5 + 5 = 46

**Score: 100 - 46 = 54/100 (MEDIUM risk)**

Red flags found: 8 (proxy with zero timelock delay, no SOC 2/ISO, no effective timelock, undisclosed multisig signers, no key management policy, no pentest disclosure, undisclosed insurance fund, single custom oracle provider)

### Data Confidence Score Calculation

Starting at 0. Points added for verified data:

- [x] +15 Source code is open and verified on block explorer
- [x] +15 GoPlus token scan completed successfully
- [x] +10 At least 1 audit report publicly available (16 audits from 8 firms)
- [ ] +10 Multisig configuration verified on-chain -- UNVERIFIED
- [x] +10 Timelock duration verified in docs (delay = 0)
- [x] +10 Team identities publicly known (Ben Zhou, Daniel Yan / Bybit; Jordi Alexander)
- [ ] +10 Insurance fund size publicly disclosed -- not disclosed
- [x] +5 Bug bounty program details publicly listed (Immunefi, up to $500K)
- [x] +5 Governance process documented (Snapshot, MIPs, 200M MNT quorum)
- [x] +5 Oracle provider(s) confirmed (custom 3/6 quorum oracle)
- [ ] +5 Incident response plan published -- not formally published
- [ ] +5 SOC 2 Type II or ISO 27001 certification -- none
- [ ] +5 Published key management policy -- none
- [ ] +5 Regular penetration testing disclosed -- none
- [ ] +5 Bridge DVN/verifier configuration documented -- N/A

**Score: 15 + 15 + 10 + 10 + 10 + 5 + 5 + 5 = 75/100 (HIGH confidence)**

Data points verified: 8 / 13 checkable (excluding N/A)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (backed by ~$2B+ Mantle Treasury) | Lido: undisclosed; Rocket Pool: ~10% (RPL collateral) | MEDIUM |
| Audit Coverage Score | 8.5 (4x1.0 + 6x0.5 + 6x0.25) | Lido: ~4.0; Rocket Pool: ~3.0 | LOW |
| Governance Decentralization | Off-chain Snapshot, quorum 200M MNT | Lido: on-chain Aragon DAO; Rocket Pool: oDAO + pDAO | MEDIUM |
| Timelock Duration | 0h (delay = 0, effectively instant) | Lido: 72h; Rocket Pool: 168h | HIGH |
| Multisig Threshold | UNVERIFIED | Lido: 4/8 (EOA committee); Rocket Pool: varies | UNVERIFIED |
| GoPlus Risk Flags | 0 HIGH / 1 MED (is_proxy=1) | -- | LOW |

### Audit Coverage Score Breakdown

**Version 3.01 (2025)** -- 4 audits, all < 1 year old: 4 x 1.0 = 4.0
- Mixbytes (Nov 2025), Hexens (Oct 2025), Blocksec (Oct 2025), Exvul (Oct 2025)

**Version 2.01 (2024)** -- 6 audits, 1-2 years old: 6 x 0.5 = 3.0
- Mixbytes (Oct 2024), Fuzzland/Verilog (Oct 2024), Quantstamp (Oct 2024), Blocksec (Oct 2024), Secure3 (Sep 2024), Hexens (Aug 2024)

**Version 1.01 (2023)** -- 6 audits, > 2 years old: 6 x 0.25 = 1.5
- Hexens (Aug 2023), Hexens (Oct 2023), MixBytes (Oct 2023), Secure3 (Oct 2023 x2), Verilog (Nov 2023)

**Total: 4.0 + 3.0 + 1.5 = 8.5** (>= 3.0 threshold = LOW risk)

## GoPlus Token Security (Ethereum, mETH: 0xd5F7838F5C461fefF7FE49ea5ebaF7728bB0ADfa)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (not flagged) | LOW |
| Open Source | Yes (is_open_source = 1) | LOW |
| Proxy | Yes (is_proxy = 1) | MEDIUM |
| Mintable | Not flagged | LOW |
| Owner Can Change Balance | Not flagged | LOW |
| Hidden Owner | Not flagged | LOW |
| Selfdestruct | Not flagged | LOW |
| Transfer Pausable | Not flagged | LOW |
| Blacklist | Not flagged | LOW |
| Slippage Modifiable | Not flagged | LOW |
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 10,704 | -- |
| Trust List | Not flagged | -- |
| Creator Honeypot History | No (honeypot_with_same_creator = 0) | LOW |

**Top Holder Concentration**: Top holder (EOA) holds 31.5%, second (contract) holds 23.3%. Combined top 5 holders: ~76.6%. HIGH concentration but expected for a liquid staking receipt token where large stakers and DeFi protocols hold significant amounts.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | MEDIUM | Timelock delay = 0; multisig config unverified; off-chain Snapshot governance | S/O | Partial |
| Oracle & Price Feeds | MEDIUM | Custom proprietary oracle (3/6 quorum); no third-party oracle fallback | S | Partial |
| Economic Mechanism | LOW | Standard LST mechanism; liquidity buffer via Aave; 12h min unstaking delay | S | Y |
| Smart Contract | LOW | 16 audits across 3 versions; open source; Immunefi bug bounty | S | Y |
| Token Contract (GoPlus) | LOW | No red flags; proxy contract (expected for upgradeable LST) | S | Y |
| Cross-Chain & Bridge | LOW | Primarily Ethereum L1; L2 token on Mantle but not critical path | S | Partial |
| Off-Chain Security | HIGH | No SOC 2/ISO; no published key management; Bybit hack exposed custody risks | O | N |
| Operational Security | MEDIUM | Team doxxed (Bybit founders); demonstrated incident response (Bybit hack recovery); dependencies on Aave, EigenLayer | S/H/O | Partial |
| **Overall Risk** | **MEDIUM** | **Functional protocol with strong audit coverage but zero timelock delay and unverified admin controls present meaningful governance risk** | | |

**Overall Risk aggregation**: No CRITICAL categories. 1 HIGH (Off-Chain Security). Governance & Admin is MEDIUM (counts 2x weight = 2 MEDIUM). Total: 1 HIGH + 4 MEDIUM (including 2x governance). Rule: 1 HIGH or 3+ MEDIUM = MEDIUM. Result: **MEDIUM**.

## Detailed Findings

### 1. Governance & Admin Key

**Timelock (MEDIUM-HIGH concern)**:
The protocol uses an OpenZeppelin TimelockController (v4.8.2) deployed at `0xc26016f1166bE7b6c5611AAB104122E0f6c2aCE2` as the sole proxy admin for all contracts. However, the **timelock delay is currently set to 0**, meaning upgrades can be scheduled and executed immediately. The docs acknowledge this and state the delay will increase as the protocol matures, but as of the audit date, this effectively provides no protection against malicious or compromised upgrades.

The `updateDelay` function is itself subject to the current delay, so increasing it from 0 requires only a single transaction with no waiting period. Once set above 0, reducing it would require waiting the current delay period -- this is a good design but only protective AFTER the delay is increased from 0.

**Multisig (UNVERIFIED)**:
The Mantle Treasury at `0x78605Df79524164911C144801f41e9811B7DB73D` is known to be a Gnosis Safe, but the Safe Transaction Service API did not return data (308 redirect). The relationship between the treasury multisig and the mETH timelock controller's proposer/executor roles is not publicly documented. It is assumed but UNVERIFIED that the timelock roles are controlled by a multisig.

**Governance Process**:
Mantle uses off-chain governance via Gnosis Snapshot (space: bitdao.eth). Proposals require 200,000 MNT to create and 200,000,000 MNT quorum to pass. The Mantle Treasury holds ~46% of MNT supply, creating significant concentration of voting power. Implementation of passed proposals is handled by core contributor teams.

**Risk Rating: MEDIUM** -- The zero-delay timelock is a significant concern that prevents this from being LOW, but the off-chain governance process and large quorum requirements provide some procedural safeguards.

### 2. Oracle & Price Feeds

**Architecture**:
mETH uses a custom oracle system to bridge data between Ethereum's Consensus Layer (where staking happens) and Execution Layer (where contracts live). The oracle reports how much ETH is held on the Consensus Layer to the smart contracts.

**Quorum**: 3 of 6 oracle nodes must agree on the exchange rate. Updates occur approximately every 8 hours.

**Exchange Rate Bounds**: The protocol enforces upper and lower bounds on periodic exchange rate movements. The upper bound tracks global ETH staking APY expectations. The lower bound accounts for potential slashing events.

**Guardian Role**: Guardians can monitor the exchange rate and pause protocol components if anomalies are detected. An auto-pause mechanism triggers on unexpected deviations.

**Concerns**:
- The oracle is proprietary/custom -- no third-party oracle (Chainlink, Pyth) is used for the core exchange rate. This is common for LSTs (Lido also uses a custom oracle committee) but creates a single-vendor dependency.
- Oracle node operator identities and selection process are not publicly documented.
- No on-chain verification of Consensus Layer data via Merkle proofs or ZK proofs (noted as "future exploration" in docs).

**Risk Rating: MEDIUM** -- The 3/6 quorum and rate bounds provide meaningful protection, but the proprietary nature and lack of independent verification create trust assumptions.

### 3. Economic Mechanism

**Staking Mechanism**: Users deposit ETH and receive mETH, a value-accumulating receipt token. The exchange rate increases over time as staking rewards accrue. Deposits are permissionless with a 4 basis point (0.04%) fee. Protocol takes ~10% of staking rewards and ~20% of restaking rewards.

**Node Operators**: A41, P2P, Blockdaemon, stakefish, and Kraken -- all established, institutional-grade operators. This is a curated (permissioned) operator set, similar to Lido's approach.

**Unstaking/Withdrawal**: FIFO queue with a minimum 12-hour delay. Maximum delay depends on Liquidity Buffer availability and Ethereum validator exit queue (potentially 40+ days in extreme cases).

**Liquidity Buffer**: Since October 2025, the protocol maintains non-staked ETH deposited in Aave v3 main markets to meet redemption requests while earning yield. This significantly improves the withdrawal experience compared to pure validator-exit-based unstaking.

**cmETH Restaking**: cmETH is a 1:1 receipt token for mETH restaking across EigenLayer, Symbiotic, and Karak. This adds yield but also composability risk.

**Insurance/Bad Debt**: No dedicated insurance fund is disclosed for mETH Protocol specifically. Mantle's broader treasury (~$2B+) provides implicit backing. The Bybit hack recovery ($43M in cmETH) demonstrated the team's willingness and ability to pursue fund recovery.

**Risk Rating: LOW** -- Standard, well-understood LST mechanism with reputable node operators and a helpful liquidity buffer. The lack of explicit insurance is partially offset by the large Mantle Treasury.

### 4. Smart Contract Security

**Audit History**: 16 audits across 3 major versions from 7 different auditing firms:
- Version 3.01 (2025): Mixbytes, Hexens, Blocksec, Exvul -- Liquidity Buffer
- Version 2.01 (2024): Mixbytes, Fuzzland/Verilog, Quantstamp, Blocksec, Secure3, Hexens -- cmETH, COOK token
- Version 1.01 (2023): Hexens (x2), MixBytes, Secure3 (x2), Verilog -- Core staking contracts

**Audit Coverage Score: 8.5** (well above the 3.0 LOW risk threshold). This is among the highest audit coverage scores across all protocols reviewed.

**Bug Bounty**: Active Immunefi program with up to $500,000 payout for critical smart contract bugs (10% of affected funds, capped at $500K). The program has the Immunefi Standard Badge.

**Contract Architecture**: 9 core contracts on Ethereum L1 + 1 on Mantle L2. Uses OpenZeppelin TransparentUpgradeableProxy pattern. All contracts are open source (MIT license) and verified on Etherscan.

**Key Contracts**:
- mETH Token: `0xd5F7838F5C461fefF7FE49ea5ebaF7728bB0ADfa`
- cmETH Token: `0xE6829d9a7eE3040e1276Fa75293Bde931859e8fA`
- Timelock: `0xc26016f1166bE7b6c5611AAB104122E0f6c2aCE2`
- Pauser contract: dedicated emergency pause mechanism

**Risk Rating: LOW** -- Excellent audit coverage with multiple reputable firms, active bug bounty, open source code, and live since December 2023 without a direct smart contract exploit.

### 5. Cross-Chain & Bridge

The protocol is primarily deployed on Ethereum L1 for core staking operations. An L2 mETH token (METHL2) exists on Mantle Network for DeFi usage, but the critical staking and unstaking operations happen on L1.

mETH and cmETH are accepted as collateral on Aave v3 (Mantle instance), creating downstream lending exposure. A direct exploit of mETH could cascade into bad debt on lending protocols that accept it as collateral.

**Risk Rating: LOW** -- Minimal cross-chain attack surface since core operations are single-chain (Ethereum L1).

### 6. Operational Security

**Team & Track Record**:
Mantle Network emerged from BitDAO, founded by Ben Zhou and Daniel Yan (co-founders of Bybit). The team is doxxed with significant public presence. Jordi Alexander and Arjun Krishan Kalsy are also publicly known contributors.

**Bybit Hack Involvement (February 2025)**:
On February 21, 2025, Bybit suffered a $1.5B hack attributed to North Korea's Lazarus Group. The stolen assets included mETH and cmETH tokens. mETH Protocol recovered $43M in cmETH -- the largest single recovery from the incident. The protocol published a post-mortem within 2 days and demonstrated rapid incident response.

**Important context**: The Bybit hack was NOT a vulnerability in mETH Protocol's smart contracts. It was a social engineering attack on Bybit's cold wallet infrastructure. However, it demonstrated that mETH tokens held in centralized custody are subject to custodial counterparty risk.

**Emergency Pause**: A dedicated Pauser contract enables emergency pausing of protocol components. Guardians can pause based on oracle anomalies.

**Dependencies**:
- Aave v3 (Liquidity Buffer deposits)
- EigenLayer, Symbiotic, Karak (cmETH restaking)
- Institutional node operators (A41, P2P, Blockdaemon, stakefish, Kraken)

**Off-Chain Security**: No SOC 2/ISO 27001 certifications disclosed. No published key management policy. No disclosed penetration testing of off-chain infrastructure. Given the Bybit hack context, the off-chain security posture is a meaningful concern.

**Risk Rating: MEDIUM** -- Doxxed team with demonstrated incident response capability, but the Bybit connection and lack of off-chain security certifications are notable concerns.

## Critical Risks (if any)

1. **ZERO TIMELOCK DELAY (HIGH)**: The timelock controller has a delay of 0, meaning contract upgrades can be executed immediately. This negates the primary purpose of a timelock -- giving users time to exit before potentially malicious changes take effect. A compromised admin key could upgrade contracts and drain funds in a single transaction.

2. **UNVERIFIED ADMIN MULTISIG (HIGH)**: The multisig configuration controlling the timelock's proposer and executor roles has not been verified on-chain. If the timelock roles are controlled by a single EOA or a low-threshold multisig, the zero-delay timelock becomes an even more critical risk.

3. **OFF-CHAIN SECURITY GAPS (HIGH)**: No disclosed SOC 2, ISO 27001, key management policy, or penetration testing. The Bybit hack (involving mETH tokens) demonstrated that off-chain security is a real attack surface for this ecosystem.

## Peer Comparison

| Feature | mETH Protocol | Lido (stETH) | Rocket Pool (rETH) |
|---------|--------------|--------------|-------------------|
| TVL | $662M | $21.5B | $1.3B |
| Timelock | 0h (instant) | 72h | 168h (7d) |
| Multisig | UNVERIFIED | 4/8 (EOA committee) | oDAO 9/15 + pDAO |
| Audits | 16 (8 firms) | 20+ (10+ firms) | 15+ (6+ firms) |
| Audit Coverage Score | 8.5 | ~4.0 | ~3.0 |
| Oracle | Custom 3/6 quorum | Custom 5/9 quorum | Decentralized (per-operator) |
| Insurance/TVL | Undisclosed (~$2B treasury) | Undisclosed (LDO treasury) | ~10% (RPL collateral) |
| Open Source | Yes (MIT) | Yes | Yes |
| Bug Bounty | $500K (Immunefi) | $2M (Immunefi) | $250K (Immunefi) |
| Node Operators | 5 (permissioned) | 40+ (curated) | 2,700+ (permissionless) |
| Governance | Off-chain Snapshot | On-chain Aragon DAO | oDAO + pDAO (on-chain) |

**Key takeaways**:
- mETH's timelock delay of 0h is significantly worse than both peers (72h and 168h). This is the most critical gap.
- mETH's audit coverage score (8.5) is actually the highest among peers, reflecting aggressive audit cadence.
- mETH's bug bounty ($500K) is modest compared to Lido ($2M) but adequate for its TVL tier.
- mETH's node operator set (5) is the smallest, creating higher concentration risk compared to Rocket Pool's permissionless model.

## Recommendations

1. **Increase timelock delay immediately**: The zero-delay timelock is the single most impactful improvement. Even 24-48 hours would significantly reduce risk. Peers use 72h-168h.

2. **Publish multisig configuration**: Publicly document the multisig (if any) controlling the timelock's proposer/executor roles, including threshold and signer identities. Verify on-chain via Safe API.

3. **Pursue SOC 2 Type II certification**: Given the Bybit hack's relevance to the Mantle ecosystem, demonstrating off-chain security controls through third-party attestation would meaningfully reduce perceived operational risk.

4. **Publish key management policy**: Document HSM/MPC custody arrangements, key rotation procedures, and access controls for admin keys.

5. **Add independent oracle verification**: Consider supplementing the custom oracle with Merkle proof verification of Consensus Layer state, or integrating a secondary oracle source as a sanity check.

6. **Increase bug bounty ceiling**: At $662M TVL, the $500K max payout is only 0.076% of TVL. Industry best practice for protocols of this size is 1-2% of TVL or higher.

7. **Monitor downstream lending exposure**: As mETH/cmETH are onboarded as collateral on Aave and other lending protocols, monitor concentration and ensure rate limits exist to prevent Kelp-type cascade scenarios.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- N/A (not a lending protocol)
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED
- [x] Admin can modify withdrawal limits? -- UNVERIFIED but likely given zero timelock
- [ ] Multisig has low threshold (2/N with small N)? -- UNVERIFIED
- [x] Zero or short timelock on governance actions? -- YES (delay = 0)
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (Ethereum)
- [x] Social engineering surface area (anon multisig signers)? -- YES (signers undisclosed)

**3 indicators matched -- WARNING: Drift-type pattern partially present.** The zero timelock combined with unverified multisig configuration and undisclosed signers creates a meaningful social engineering attack surface. The Bybit hack (social engineering on related infrastructure) reinforces this concern.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A
- [ ] Single oracle source without TWAP? -- Partial (custom oracle, but with 3/6 quorum and bounds)
- [ ] No circuit breaker on price movements? -- No (guardian pause + auto-pause exist)
- [ ] Insufficient insurance fund relative to TVL? -- Undisclosed but treasury backstop exists

**0-1 indicators matched -- LOW risk for this pattern.**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No (primarily single-chain)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

**0 confirmed indicators -- LOW risk for this pattern (but key management is unverified).**

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time (no snapshot)? -- No (uses Snapshot with delegation)
- [ ] Flash loans can be used to acquire voting power? -- No (off-chain voting)
- [ ] Proposal + execution in same block or short window? -- No (off-chain process)
- [ ] No minimum holding period for voting eligibility? -- Yes (delegation required but no holding period)

**0 indicators matched -- LOW risk for this pattern.**

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? -- N/A (not a lending protocol)
- [ ] Read-only reentrancy risk (cross-contract callbacks before state update)? -- Audited, no known issues
- [ ] Flash loan compatible without reentrancy guards? -- Standard protections in audited contracts
- [ ] Composability with protocols that expose callback hooks? -- Aave integration (well-audited)

**0 indicators matched -- LOW risk for this pattern.**

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler (Vyper, Huff)? -- No (Solidity)
- [ ] Compiler version has known CVEs? -- UNVERIFIED
- [ ] Contracts compiled with different compiler versions? -- UNVERIFIED
- [ ] Code depends on language-specific behavior (storage layout, overflow)? -- Standard Solidity practices

**0 indicators matched -- LOW risk for this pattern.**

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral (own governance token)? -- No (backed by staked ETH)
- [ ] Redemption mechanism creates sell pressure on collateral? -- No (1:1 ETH backing)
- [ ] Oracle delay could mask depegging in progress? -- Minimal (8h update cycle with bounds)
- [ ] No circuit breaker on redemption volume? -- FIFO queue with liquidity buffer provides natural rate limiting

**0 indicators matched -- LOW risk for this pattern.**

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses a cross-chain bridge for token minting or reserve release? -- No (L1-native staking)
- [ ] Bridge message validation relies on a single messaging layer? -- N/A
- [ ] DVN/relayer/verifier configuration is not publicly documented? -- N/A
- [ ] Bridge can release or mint tokens without rate limiting? -- N/A
- [x] Bridged/wrapped token is accepted as collateral on lending protocols? -- YES (Aave v3 Mantle instance)
- [ ] No circuit breaker to pause minting if volume exceeds thresholds? -- Guardian pause exists
- [ ] Emergency pause response time > 15 minutes? -- Demonstrated rapid response in Bybit incident
- [ ] Bridge admin controls under different governance than core protocol? -- N/A
- [ ] Token deployed on 5+ chains via same bridge provider? -- No

**1 indicator matched -- LOW risk for this pattern.** However, as mETH adoption grows on lending protocols, this should be monitored.

## Information Gaps

1. **Multisig configuration**: The specific multisig (threshold, signer count, signer identities) controlling the timelock's proposer and executor roles is not publicly documented or verified on-chain.

2. **Timelock delay rationale**: No public explanation for why the delay remains at 0 despite the protocol being live for 2+ years and holding $662M in TVL.

3. **Oracle node operators**: The identities and selection criteria for the 6 oracle nodes are not publicly documented.

4. **Insurance fund**: No dedicated insurance fund for mETH Protocol is disclosed. The implicit reliance on Mantle Treasury is assumed but not formally committed.

5. **Key management**: No published information about HSM usage, MPC custody, key ceremony procedures, or key rotation policies for admin keys.

6. **Penetration testing**: No disclosed infrastructure-level security testing beyond smart contract audits.

7. **SOC 2 / ISO 27001**: No third-party security certifications disclosed for the operating entity.

8. **Emergency response time**: While the Bybit incident showed rapid communication (same day), the specific time-to-pause for on-chain emergencies is not documented.

9. **Guardian role details**: The number of guardians, their identities, and the specific conditions that trigger auto-pause are not fully documented.

10. **Downstream lending exposure limits**: Whether rate limits or supply caps exist for mETH/cmETH as collateral on Aave and other protocols is unclear.

## Disclaimer

This analysis is based on publicly available information and web research conducted on 2026-04-20. It is NOT a formal smart contract audit. The assessment reflects publicly available data at the time of writing; protocol configurations may have changed since publication. Always DYOR and consider professional auditing services for investment decisions.
