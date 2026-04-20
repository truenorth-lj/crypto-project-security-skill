# DeFi Security Audit: GRVT (Gravity)

## Overview
- Protocol: GRVT (Gravity)
- Chain: Ethereum (L1 settlement) / zkSync Era L3 Validium (execution)
- Type: Perpetual Futures DEX (Hybrid off-chain matching + on-chain settlement)
- TVL: ~$63.5M (bridge TVL on DeFiLlama; perps TVL listed as null)
- TVL Trend: -7.0% / -44.1% / -32.0% (7d / 30d / 90d)
- Launch Date: January 2025 (mainnet)
- Audit Date: 2026-04-20
- Valid Until: 2026-07-19 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Partial (L2 smart contracts audited by Spearbit; matching engine and off-chain components are closed-source)

## Quick Triage Score: 27/100 | Data Confidence: 40/100

**Triage Score Breakdown** (start at 100, subtract mechanically):

CRITICAL flags:
- None detected

HIGH flags (-15 each):
- [x] Zero audits listed on DeFiLlama (-15)
- [x] No multisig — 2/3 GrvtChainAdminMultisig with 0s timelock for chain admin actions (-15) *(counted as "No multisig" because 2/3 with zero-delay is functionally equivalent to weak admin control)*
- [x] Single bridge provider for cross-chain (zkSync native bridge only) — N/A, not 5+ chains, but centralized sequencer is equivalent risk (-0, does not meet exact criteria)

MEDIUM flags (-8 each):
- [x] Protocol age < 6 months with TVL > $50M — launched Jan 2025, ~15 months old — does NOT apply (-0)
- [x] TVL dropped > 30% in 90 days (-8)
- [x] Multisig threshold < 3 signers (2/3) (-8)
- [x] No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations (-8)

LOW flags (-5 each):
- [x] No documented timelock on admin actions (0s timelock per L2BEAT) (-5)
- [x] No bug bounty program with published reward tiers (-5)
- [x] Single oracle provider (internal/undisclosed) (-5)
- [x] Insurance fund / TVL < 1% or undisclosed (-5)
- [x] Undisclosed multisig signer identities (-5)
- [x] No published key management policy (HSM, MPC, key ceremony) — Dfns MPC exists but protocol-level key management policy not published (-5)
- [x] No disclosed penetration testing (NCC Group mentioned in search but no published report) (-5)
- [x] Custodial dependency without disclosed custodian certification (Dfns MPC) (-5)

Total deductions: 15 + 15 + 8 + 8 + 8 + 5 + 5 + 5 + 5 + 5 + 5 + 5 + 5 = 94
**Raw score: 100 - 94 = 6** -- floored at **6/100** but applying strict formula = **6/100**

*Correction*: Re-checking -- the "No multisig (single EOA admin key)" flag requires single EOA. GRVT has a 2/3 multisig, so this HIGH flag does NOT apply. Recalculating:

HIGH flags (-15 each):
- [x] Zero audits listed on DeFiLlama (-15)

MEDIUM flags (-8 each):
- [x] TVL dropped > 30% in 90 days (-8)
- [x] Multisig threshold < 3 signers (2/3) (-8)
- [x] No third-party security certification (-8)

LOW flags (-5 each):
- [x] No documented timelock on admin actions (-5)
- [x] No bug bounty program with published reward tiers (-5)
- [x] Single oracle provider (-5)
- [x] Insurance fund / TVL undisclosed (-5)
- [x] Undisclosed multisig signer identities (-5)
- [x] No published key management policy (-5)
- [x] No disclosed penetration testing (-5)
- [x] Custodial dependency without disclosed custodian certification (-5)

Total deductions: 15 + 8 + 8 + 8 + 5 + 5 + 5 + 5 + 5 + 5 + 5 + 5 = 79
**Score: 100 - 79 = 21/100 → HIGH risk**

- Red flags found: 12 (zero DeFiLlama audits, TVL -44% in 30d, 2/3 multisig with 0s timelock, no SOC 2, no published timelock, no bug bounty tiers, undisclosed oracle, undisclosed insurance fund, anon multisig signers, no key management policy, no pentest disclosure, no custodian certification)
- Data points verified: 8 / 20

**Data Confidence Score Breakdown** (start at 0, add points):

- [ ] +15 Source code open and verified — PARTIAL, L2 contracts verified but matching engine closed (+0)
- [ ] +15 GoPlus token scan completed — scanned but token is NOT the official GRVT token (TGE not yet occurred) (+0)
- [x] +10 At least 1 audit report publicly available — Spearbit confirmed but report not public (+0)
- [ ] +10 Multisig configuration verified on-chain — L2BEAT reports 2/3 GrvtChainAdminMultisig (+10)
- [ ] +10 Timelock duration verified on-chain — L2BEAT confirms 0s minimum delay for chain admin (+10)
- [x] +10 Team identities publicly known (doxxed) — CEO Hong Yea (Goldman Sachs), CTO Aaron Ong (Meta), COO Matthew Quek (DBS) (+10)
- [ ] +10 Insurance fund size publicly disclosed (+0)
- [x] +5  Bug bounty program details publicly listed — exists but no reward tiers (+5)
- [ ] +5  Governance process documented — no on-chain governance yet (+0)
- [ ] +5  Oracle provider(s) confirmed (+0)
- [ ] +5  Incident response plan published (+0)
- [ ] +5  SOC 2 Type II or ISO 27001 verified (+0)
- [ ] +5  Published key management policy (+0)
- [ ] +5  Regular penetration testing disclosed (+0)
- [x] +5  Bridge DVN/verifier configuration documented — zkSync native bridge, L2BEAT documents verification (+5)

**Data Confidence: 40/100 (LOW)**

## Quantitative Metrics
| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | dYdX ~5%, Hyperliquid ~3% | HIGH |
| Audit Coverage Score | 0.0 (0 public audits on DeFiLlama; Spearbit confirmed but unpublished) | dYdX ~4.0, Hyperliquid ~1.5 | HIGH |
| Governance Decentralization | Very low (no DAO, no on-chain governance, 2/3 multisig) | dYdX: on-chain DAO + timelock | HIGH |
| Timelock Duration | 0h (chain admin); 96-192h (DAO upgrade path per L2BEAT) | dYdX: 48h, Hyperliquid: N/A (validator) | HIGH |
| Multisig Threshold | 2/3 (GrvtChainAdminMultisig) | dYdX: governance + Security Council, Hyperliquid: validator set | MEDIUM |
| GoPlus Risk Flags | N/A (token not yet launched; scanned token is impersonator) | -- | N/A |

## GoPlus Token Security

**Note**: The $GRVT TGE has NOT occurred as of 2026-04-20 (targeted post-June 2026). The token found at `0xe6c19b4d897f400d49c138331ac8f96e8d330b9a` on Ethereum has only 22 holders, zero transfers, 81.4% creator concentration, and unknown reputation on Etherscan. This is almost certainly NOT the official GRVT token and appears to be an impersonator or placeholder.

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | 0 (No) | -- |
| Open Source | 1 (Yes) | -- |
| Proxy | 0 (No) | -- |
| Mintable | 0 (No) | -- |
| Owner Can Change Balance | 0 (No) | -- |
| Hidden Owner | 0 (No) | -- |
| Selfdestruct | 0 (No) | -- |
| Transfer Pausable | 0 (No) | -- |
| Blacklist | 0 (No) | -- |
| Slippage Modifiable | 0 (No) | -- |
| Buy Tax / Sell Tax | N/A / N/A | -- |
| Holders | 22 | CRITICAL (impersonator) |
| Trust List | Not listed | -- |
| Creator Honeypot History | 0 (No) | -- |

**Conclusion**: GoPlus scan is NOT applicable. The scanned token is an impersonator. Official token does not exist yet.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | HIGH | 2/3 multisig with 0s timelock for chain admin; no on-chain governance | S | Partial |
| Oracle & Price Feeds | HIGH | Oracle provider(s) undisclosed; off-chain matching engine | S/O | N |
| Economic Mechanism | MEDIUM | Full-equity forfeiture liquidation; undisclosed insurance fund; -44% TVL in 30d | S | Partial |
| Smart Contract | MEDIUM | Spearbit audit confirmed but not publicly published; partial open source | S | Partial |
| Token Contract (GoPlus) | N/A | Token not yet launched (TGE post-June 2026) | -- | N/A |
| Cross-Chain & Bridge | MEDIUM | zkSync native bridge with centralized sequencer; no forced inclusion mechanism | S | Partial |
| Off-Chain Security | HIGH | No SOC 2/ISO 27001; no published pentest; Dfns MPC but no published key policy | O | N |
| Operational Security | MEDIUM | Doxxed team with strong TradFi background; no published incident response plan | O | Partial |
| **Overall Risk** | **HIGH** | **Centralized operator model with weak admin controls, undisclosed oracle, and no published security certifications** | | |

**Overall Risk aggregation**: Governance & Admin = HIGH (counts as 2x = 2 HIGHs). Off-Chain Security = HIGH. That is 3 HIGHs total. 2+ HIGHs = **HIGH**.

## Detailed Findings

### 1. Governance & Admin Key

**Architecture**: GRVT operates as a zkSync Era L3 Validium -- the first "hyperchain" in the zkSync ecosystem. The governance structure is highly centralized:

- **GrvtChainAdminMultisig**: 2/3 threshold controlling chain-specific operations including transaction filtering, DA mode, and settlement layer migration. Three EOA signers with **immediate (0s delay) upgrade authority**.
- **EmergencyUpgradeBoard**: 3/3 multisig (SecurityCouncil + ZK Foundation + Guardians) enabling **zero-delay emergency upgrades** across shared zkSync infrastructure.
- **Governance Proxy**: Allows GrvtChainAdminMultisig to act through it.
- **No on-chain DAO governance**: No token-based voting, no governance proposals, no quorum requirements.
- **Timelock**: L2BEAT reports a minimum delay of **0 seconds** for chain admin actions. The standard DAO upgrade path has a 4d 3h to 8d 3h cumulative delay, but this is the ZK Foundation path, not GRVT-specific governance.

**Key concern**: The 2/3 multisig with 0s timelock means two of three anonymous signers can unilaterally upgrade contracts, change parameters, enable transaction filtering, or migrate the settlement layer with zero delay and zero community notice.

**Risk: HIGH**

### 2. Oracle & Price Feeds

**Architecture**: GRVT's oracle and price feed mechanism is **not publicly documented**. Key findings:

- No mention of Chainlink, Pyth, or any third-party oracle provider in public documentation
- The matching engine operates off-chain with a centralized order book (CLOB)
- Funding rates use an "index-based methodology" with +/-5% caps
- Mark price and index price derivation methodology is not publicly disclosed
- Liquidation prices are validated on-chain via smart contract logic

**Key concern**: For a perpetual futures exchange handling ~$474M in open interest, the complete absence of public oracle documentation is a significant risk. Users cannot independently verify how prices are determined, whether manipulation safeguards exist, or what happens during oracle failures.

**Risk: HIGH**

### 3. Economic Mechanism

**Liquidation**: GRVT uses a **full-equity forfeiture** model -- the harshest approach among perpetual DEXs. When liquidated, a trader's entire account equity is forfeited (not just the position margin). The liquidation penalty = liquidation_share x liquidation_fee (70%) x maintenance_margin.

**Insurance Fund**: Not publicly disclosed. No documented insurance fund size, no public reserve address, no transparency on bad debt handling beyond the full-equity forfeiture model.

**Funding Rate**: Continuous funding with +/-5% caps based on index methodology. Rates are subject to admin changes.

**Margin Model**: 10-tier maintenance margin model. Initial and maintenance margin rates vary by instrument and position size. Rates are "subject to change" -- implying admin can modify without governance.

**TVL Trend**: The bridge TVL dropped from ~$113M to ~$63.5M, a **-44% decline over 30 days** and **-32% over 90 days**. This is a significant red flag, though it may partially reflect market conditions or the end of incentive programs.

**Risk: MEDIUM**

### 4. Smart Contract Security

**Audit History**:
- Spearbit DAO: Confirmed as audit partner, but the audit report is **not publicly available**. No details on scope, findings, or remediation status.
- NCC Group: Mentioned in association with GRVT (pentest), but no published report.
- DeFiLlama lists **0 audits** for GRVT Perps.
- **Audit Coverage Score: 0.0** (no publicly verifiable audits)

**Architecture**:
- L2 smart contracts on zkSync Era Validium
- Dual verification: Fflonk and Plonk proof systems via DualVerifier contract (both require trusted setup)
- Validity proofs: STARKs wrapped in SNARKs with 3-hour execution delay
- Off-chain CLOB matching engine (closed source, ~600k TPS, <2ms latency)

**Bug Bounty**: GRVT has a bug bounty program (security-report@grvt.io) covering nodes, API servers, authentication, fund theft, and Web2/Web3 vulnerabilities. However, **no published reward tiers or maximum payout**. Rewards are "at GRVT's discretion." This is significantly weaker than industry standard (e.g., Immunefi-hosted programs with defined payouts).

**Risk: MEDIUM**

### 5. Cross-Chain & Bridge

**Bridge Architecture**: GRVT uses the zkSync native bridge for L1-L2 asset transfers. Additional cross-chain access via RhinoFi bridge to Arbitrum, BSC, Solana, and Tron with daily limits.

**Critical concerns from L2BEAT**:
- **Data Availability**: "Proof construction and state derivation rely fully on data that is NOT published onchain." A malicious sequencer can collude with the proposer to finalize unavailable state, causing **loss of funds**.
- **Sequencer**: Centralized, single-operator sequencer. No mechanism for transaction inclusion if sequencer is down or censoring. A **TransactionFilterer** actively requires whitelisted accounts for L1-to-L2 messaging, enabling censorship.
- **Proposer**: Only whitelisted proposers can publish state roots. If proposer fails, withdrawals are frozen.
- **Exit Window**: No documented exit window for standard upgrades due to centralized operator control.
- **No forced inclusion**: Users cannot force transactions through L1 if the sequencer censors them, unless they are whitelisted.

**Risk: MEDIUM** (single chain with native bridge, but centralized sequencer is the primary concern)

### 6. Operational Security

**Team**: Doxxed with strong traditional finance and technology backgrounds:
- **CEO Hong Yea**: 10+ years at Goldman Sachs (Executive Director), Credit Suisse
- **CTO Aaron Ong**: Former Meta, data privacy frameworks
- **COO Matthew Quek**: DBS Bank, Singapore government tech sector

**Funding**: $34M total raised from Hack VC, Delphi Ventures, Further Ventures, ZKSync, EigenLayer, 500 Global.

**Key Management**: Dfns provides MPC wallet infrastructure with 5 partial keys in Tier 3+/4 data centers, 3-of-5 threshold signing, WebAuthn biometric authentication. This is for user wallets, not necessarily protocol admin keys.

**Incident Response**: No published incident response plan. No documented emergency response time benchmark. Emergency pause capability exists via the GrvtChainAdminMultisig (2/3 can pause).

**Off-Chain Security**: No SOC 2 Type II, ISO 27001, or equivalent certification disclosed. No published penetration testing results. No published key management policy for protocol admin keys (distinct from user wallets via Dfns).

**Dependencies**:
- zkSync Era (shared infrastructure, shared security council)
- Dfns (MPC wallet infrastructure)
- RhinoFi (cross-chain bridge for non-Ethereum deposits/withdrawals)
- Data Availability Committee (unnamed "large entities" per GRVT blog)

**Risk: MEDIUM**

## Critical Risks

1. **Zero-delay admin upgrades**: The 2/3 GrvtChainAdminMultisig can upgrade contracts with 0 seconds delay. Two anonymous signers can drain funds, change parameters, or migrate settlement -- with no notice to users. This is the single highest risk.

2. **Off-chain data availability**: State data is NOT published on-chain. A malicious sequencer colluding with the proposer can finalize unavailable state, causing permanent loss of user funds with no recourse.

3. **Centralized sequencer with transaction filtering**: The TransactionFilterer whitelist means GRVT can censor any L1-to-L2 transaction. Users cannot force-include transactions. If the sequencer goes down, there is no mechanism to withdraw funds.

4. **Undisclosed oracle and price feeds**: For an exchange with ~$474M open interest, the complete absence of oracle documentation means users cannot verify price integrity or manipulation resistance.

5. **No publicly available audit report**: Despite Spearbit partnership claims, no audit report is publicly accessible. DeFiLlama lists 0 audits.

## Peer Comparison
| Feature | GRVT | dYdX | Hyperliquid |
|---------|------|------|-------------|
| Timelock | 0s (chain admin) | 48h (governance) | N/A (validator upgrades) |
| Multisig | 2/3 (anon signers) | Governance DAO + Security Council | Validator set (~20+) |
| Audits | 0 public (Spearbit claimed) | 5+ (Trail of Bits, Peckshield, others) | Limited public audits |
| Oracle | Undisclosed | Chainlink + internal | Internal orderbook |
| Insurance/TVL | Undisclosed | ~5% | ~3% (Assistance Fund) |
| Open Source | Partial (L2 contracts only) | Yes (smart contracts) | Partial |
| Data Availability | Off-chain (Validium) | On-chain (StarkEx rollup) | On-chain (L1) |
| Forced Inclusion | No (requires whitelist) | Yes (L1 force) | N/A (L1) |
| Sequencer | Centralized, single operator | Centralized (StarkEx) → decentralizing | Decentralized validators |

## Recommendations

1. **Users should limit exposure**: Given the centralized operator model, 0s admin timelock, and off-chain data availability, users should not deposit more than they can afford to lose. The platform's trust assumptions are closer to a centralized exchange than a DEX.

2. **Monitor TVL trends**: The -44% TVL decline over 30 days warrants close monitoring. Further declines may signal deeper issues.

3. **Wait for TGE clarity**: The $GRVT token has not launched. Do not interact with any token claiming to be GRVT on Ethereum -- it is likely an impersonator.

4. **Request audit transparency**: The community should pressure GRVT to publish the Spearbit audit report publicly and list it on DeFiLlama.

5. **Verify withdrawal paths**: Before depositing significant funds, test the full withdrawal flow. Note that RhinoFi bridge withdrawals have daily limits, and native Ethereum bridge withdrawals may take hours due to ZK proof generation.

6. **Use the native Ethereum bridge for large withdrawals**: The native bridge has no withdrawal limits (unlike RhinoFi), though it is slower.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? — UNVERIFIED, likely yes given 0s admin timelock
- [x] Admin can change oracle sources arbitrarily? — UNVERIFIED, oracle architecture undisclosed
- [x] Admin can modify withdrawal limits? — Yes, admin controls risk parameters
- [x] Multisig has low threshold (2/N with small N)? — Yes, 2/3
- [x] Zero or short timelock on governance actions? — Yes, 0s for chain admin
- [ ] Pre-signed transaction risk (durable nonce on Solana)? — N/A (EVM)
- [x] Social engineering surface area (anon multisig signers)? — Yes, signer identities undisclosed

**WARNING: 5/6 applicable Drift-type indicators match. This protocol has significant governance attack surface.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? — UNVERIFIED (perps only, not lending)
- [x] Single oracle source without TWAP? — Likely, oracle undisclosed
- [ ] No circuit breaker on price movements? — UNVERIFIED
- [x] Insufficient insurance fund relative to TVL? — Undisclosed insurance fund

**2/4 indicators match.**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? — Yes, centralized sequencer and proposer
- [ ] Admin keys stored in hot wallets? — UNVERIFIED
- [x] No key rotation policy? — No published key rotation policy

**2/3 indicators match.**

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time? — N/A, no on-chain governance
- [ ] Flash loans can be used to acquire voting power? — N/A
- [ ] Proposal + execution in same block? — N/A
- [ ] No minimum holding period? — N/A

**N/A -- no on-chain governance exists.**

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens? — UNVERIFIED
- [ ] Read-only reentrancy risk? — UNVERIFIED
- [ ] Flash loan compatible without reentrancy guards? — UNVERIFIED
- [ ] Composability with callback hooks? — Limited (Validium is isolated)

**0/4 confirmed.**

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard compiler? — No, Solidity
- [ ] Compiler version has known CVEs? — UNVERIFIED
- [ ] Different compiler versions? — UNVERIFIED
- [ ] Language-specific behavior dependency? — UNVERIFIED

**0/4 confirmed.**

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral? — N/A
- [ ] Redemption creates sell pressure on collateral? — N/A
- [ ] Oracle delay could mask depegging? — N/A
- [ ] No circuit breaker on redemption? — N/A

**N/A -- no stablecoin mechanism.**

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [x] Uses cross-chain bridge for token minting or reserve release? — Yes, zkSync native bridge
- [ ] Bridge validation relies on single messaging layer? — zkSync uses validity proofs (stronger than messaging)
- [ ] DVN/relayer config not documented? — Partially documented via L2BEAT
- [ ] Bridge can mint without rate limiting? — UNVERIFIED
- [ ] Bridged token accepted as lending collateral? — No, token not launched
- [ ] No circuit breaker on minting? — UNVERIFIED
- [ ] Emergency pause > 15 minutes? — UNVERIFIED
- [ ] Bridge admin under different governance? — Partially (EmergencyUpgradeBoard is shared zkSync infra)
- [ ] Token on 5+ chains via same bridge? — No

**1/9 confirmed. Low Kelp-type risk.**

**Trigger rule**: Drift-type pattern triggers explicit warning (5/6 indicators match).

## Information Gaps

1. **Oracle architecture**: No public documentation on price feed sources, fallback mechanisms, or manipulation resistance
2. **Insurance fund**: Size, mechanism, and bad debt handling are completely undisclosed
3. **Audit report**: Spearbit audit confirmed but not publicly available; scope, findings, and remediation unknown
4. **NCC Group pentest**: Mentioned but no published results or scope
5. **Multisig signer identities**: The three GrvtChainAdminMultisig signers are anonymous
6. **Data Availability Committee**: Members described as "large entities" but not named
7. **Admin key management**: Protocol-level admin key storage, rotation, and ceremony procedures not disclosed (distinct from user wallet Dfns MPC)
8. **Emergency response time**: No benchmark or SLA published
9. **Off-chain matching engine**: Closed source, no independent security review disclosed
10. **Transaction filtering policy**: The TransactionFilterer whitelist criteria and process are not documented
11. **SOC 2 / ISO 27001**: No certifications disclosed for the operating entity
12. **Token contract**: Official $GRVT token not yet deployed (TGE post-June 2026)
13. **Downstream lending exposure**: Cannot assess until token launches
14. **Full withdrawal path under sequencer failure**: No documented procedure for users to exit if sequencer goes down

## Disclaimer
This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
