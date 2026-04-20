# DeFi Security Audit: Paradex

**Audit Date:** April 20, 2026
**Protocol:** Paradex -- Decentralized Perpetual Futures Exchange on Starknet Appchain

## Overview
- Protocol: Paradex
- Chain: Paradex Chain (Starknet Appchain, ZK-Rollup settling to Ethereum)
- Type: Derivatives / Perpetuals DEX (also options and spot)
- TVL: ~$46.9M (DeFiLlama bridge TVL, April 2026)
- TVL Trend: -6.5% / -40.7% / -79.1% (7d / 30d / 90d)
- Token: DIME (Ethereum ERC-20: 0xb32e10022ffbedfe10bc818a1c7e67d9d87e0fa7; also native gas token on Paradex Chain)
- Launch Date: February 2024 (public mainnet); DIME TGE March 5, 2026
- Audit Date: April 20, 2026
- Valid Until: July 19, 2026 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Partial (Cairo contracts audited but not fully open-sourced on GitHub; L1 bridge contracts verified on Etherscan)

## Quick Triage Score: 22/100 | Data Confidence: 50/100

Starting at 100, subtracting:

CRITICAL flags:
- (none triggered)

HIGH flags (-15 each):
- [-15] Zero audits listed on DeFiLlama (DeFiLlama shows audits: "0")
- [-15] No multisig adequate: 2/5 multisig controls instant upgrades with zero timelock (effectively weak admin)

MEDIUM flags (-8 each):
- [-8] GoPlus: is_proxy = 1 AND no timelock on upgrades (DIME token is a proxy contract; core contracts upgradeable with zero delay)
- [-8] TVL dropped >30% in 90 days (-79.1% decline over 90 days)
- [-8] Multisig threshold < 3 signers: 2/5 Paradex Multisig controls core contract upgrades
- [-8] No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations

LOW flags (-5 each):
- [-5] No documented timelock on admin actions (L2BEAT confirms zero delay on upgrades)
- [-5] Single oracle provider (Stork is sole oracle for all markets)
- [-5] Insurance fund / TVL undisclosed (fund exists but balance not publicly reported)
- [-5] Undisclosed multisig signer identities (2/5 and 3/6 signer identities not public)

Total deductions: -82. Raw score: 18. Floor at 0 does not apply. **Score: 18/100 (CRITICAL risk)**

**Note on scoring**: Deductions of -15 for "zero audits on DeFiLlama" reflects the DeFiLlama metadata. Paradex has completed audits (CairoAudit, Nethermind, Zellic, Trail of Bits) but these are not registered on DeFiLlama. The mechanical scoring rule is applied as-is per the methodology.

Red flags found: 0 CRITICAL, 2 HIGH, 4 MEDIUM, 4 LOW

**Data Confidence Score: 50/100**

Verification points:
- [+15] Source code is open and verified on block explorer (L1 bridge contracts verified; Cairo contracts partially open)
- [+15] GoPlus token scan completed
- [+10] At least 1 audit report publicly available (CairoAudit May 2025, Nethermind Feb 2025, Zellic Aug 2025)
- [+5] Bug bounty program details publicly listed (Immunefi, up to $500K)
- [+5] Oracle provider(s) confirmed (Stork)

Not verified:
- [-] Multisig configuration NOT verified on-chain via Safe API (API returned redirect; L2BEAT reports 2/5 and 3/6 but addresses not independently confirmed)
- [-] Timelock duration NOT verified on-chain (L2BEAT says zero delay)
- [-] Team identities partially known (Anand Gomes is public; other team members less visible)
- [-] Insurance fund size NOT publicly disclosed
- [-] Governance process NOT fully documented (DIME governance not yet active)
- [-] Incident response plan NOT published
- [-] No SOC 2 / ISO 27001 certification
- [-] No published key management policy
- [-] No regular penetration testing disclosed (one HackerOne pentest in March 2025 found)

**Triage: 22/100 (CRITICAL) | Confidence: 50/100 (MEDIUM)**

Interpretation: The low triage score is partially driven by DeFiLlama metadata gaps (audits exist but are not listed). Even with manual audit credit, the zero-timelock instant upgrade capability and 2/5 multisig threshold remain HIGH-risk structural concerns.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | dYdX: ~13.6%, GMX: ~5% | HIGH |
| Audit Coverage Score | 2.75 (see below) | dYdX: 2.25, GMX: 3.5+ | MEDIUM |
| Governance Decentralization | Centralized (team multisig, no DAO) | dYdX: on-chain Cosmos gov | HIGH |
| Timelock Duration | 0h (zero delay) | dYdX: 4d voting, GMX: 24h | CRITICAL |
| Multisig Threshold | 2/5 + 3/6 | dYdX: 2/3 validators, GMX: 3/6 | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 1 MED (proxy) | -- | LOW |

### Audit Coverage Score Calculation

Known audits:

**Less than 1 year old (1.0 each):**
1. CairoAudit / Cairo Security Clan -- Paraclear, Vault, Factory, Registry, Oracle contracts (May 2025) -- 1.0
2. Zellic -- ZK proofs and settlement layer (Aug 2025) -- 1.0

**1-2 years old (0.5 each):**
3. Nethermind -- Smart contracts (Feb 2025) -- 0.5

**Pre-launch / L1 audits (0.25 each, older scope):**
4. Zellic -- L1 Bridge (pre-launch) -- 0.25
5. Trail of Bits -- L1 Bridge (pre-launch) -- 0 (counted with Zellic bridge above)

**Total Audit Coverage Score: 2.75 (MEDIUM risk -- below 3.0 threshold)**

Note: Approximately 80-85% of the Paradex Chain codebase was covered by these audits. However, no audit is older than the February 2024 launch, and the code has evolved significantly since. HackerOne penetration testing (March 2025) covered API and web infrastructure but is not a smart contract audit.

## GoPlus Token Security (Ethereum DIME: 0xb32e10022ffbedfe10bc818a1c7e67d9d87e0fa7)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | N/A (not detected) | -- |
| Open Source | Yes (1) | LOW |
| Proxy | Yes (1) | MEDIUM |
| Mintable | N/A (not detected) | -- |
| Owner Can Change Balance | N/A (not detected) | -- |
| Hidden Owner | N/A (not detected) | -- |
| Selfdestruct | N/A (not detected) | -- |
| Transfer Pausable | N/A (not detected) | -- |
| Blacklist | N/A (not detected) | -- |
| Slippage Modifiable | N/A (not detected) | -- |
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 40 | LOW (very low holder count) |
| Trust List | N/A | -- |
| Creator Honeypot History | No (0) | LOW |

**GoPlus Note**: Many fields returned null, likely because DIME is a recently launched proxy token (March 2026) with very few on-chain holders (40) and no DEX liquidity (is_in_dex = 0). The proxy flag is notable given the zero-timelock upgrade context. Top holders are all contracts (likely vesting/treasury), with top 3 holding ~89.4% of supply.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | CRITICAL | 2/5 multisig can instantly upgrade all contracts with zero timelock; no DAO governance | S | Partial |
| Oracle & Price Feeds | MEDIUM | Single oracle provider (Stork); no documented fallback mechanism | S | Partial |
| Economic Mechanism | MEDIUM | Insurance fund size undisclosed; socialized loss mechanism as last resort; past $650K liquidation incident | S/H | Partial |
| Smart Contract | MEDIUM | 80-85% codebase audited; Cairo contracts partially open-source; January 2026 rollback incident | S/H | Partial |
| Token Contract (GoPlus) | MEDIUM | Proxy contract with 40 holders; top 3 hold 89%; not on any DEX yet | S | Y |
| Cross-Chain & Bridge | MEDIUM | L1 bridge controlled by same multisig; no escape hatch; sequencer censorship risk | S | Partial |
| Off-Chain Security | HIGH | No SOC 2/ISO 27001; Mithril bot compromise exposed third-party integration risk; one HackerOne pentest | O/H | N |
| Operational Security | MEDIUM | Team partially doxxed (CEO public); blockchain rollback raises decentralization questions; centralized sequencer | S/H/O | Partial |
| **Overall Risk** | **HIGH** | **Zero-timelock instant upgrade via 2/5 multisig is the primary structural risk; compounded by centralized sequencer, single oracle, and two operational incidents in January 2026** | | |

**Overall Risk aggregation**: Governance & Admin is CRITICAL (counts as 2x = 2 CRITICAL-equivalent). Any category CRITICAL triggers Overall = CRITICAL by the mechanical rule. However, the CRITICAL governance rating is partially driven by the zero-timelock + 2/5 multisig combination rather than active exploitation. Applying the mechanical rule strictly: **Overall = CRITICAL** (any category CRITICAL = Overall CRITICAL).

**Revised Overall: CRITICAL**

## Detailed Findings

### 1. Governance & Admin Key

**Risk: CRITICAL**

Paradex is controlled by two Ethereum multisigs reported by L2BEAT:

1. **Paradex Multisig (2/5 threshold)**: Can upgrade core contracts (Paradex Core proxy at 0xF338cad020D506e8e3d9B4854986E0EcE6C23640) and the USDC Bridge proxy with **zero delay**. Only 2 of 5 signers are needed to push a malicious upgrade.

2. **Paradex Multisig 2 (3/6 threshold)**: Secondary multisig with additional governance powers.

3. **Sequencer operator**: A single EOA (0xC70ae19B5FeAA5c19f576e621d2bad9771864fe2) runs the centralized sequencer. If the sequencer goes down, users cannot transact. There is no fallback mechanism for transaction inclusion.

4. **No timelock**: L2BEAT explicitly flags: "Funds can be stolen if a contract receives a malicious code upgrade. There is no delay on code upgrades." This is the most critical finding.

5. **No DAO governance**: DIME token utility includes future governance/voting, but as of April 2026, no on-chain governance exists. All decisions are made by the team.

6. **Multisig signer identities**: Not publicly disclosed. This increases social engineering risk.

7. **SHARP Verifier**: The SHARP verification system uses a 2/4 multisig with an 8-day delay, which is the strongest governance control in the stack but only covers the proof verification layer.

**Timelock bypass detection**: Not applicable -- there is no timelock to bypass. The absence of any timelock is itself the critical issue.

### 2. Oracle & Price Feeds

**Risk: MEDIUM**

- **Oracle provider**: Stork is the sole oracle provider for all perpetual, options, and spot markets. Stork aggregates price data from multiple sources and delivers signed price updates with millisecond latency.

- **Single provider risk**: No documented fallback to Chainlink, Pyth, or any secondary oracle. If Stork experiences downtime or manipulation, all Paradex markets are affected.

- **January 2026 BTC $0 incident**: During a database migration, corrupted market data was written on-chain, causing BTC and other assets to display at $0. This was not an oracle failure per se, but it demonstrates that the price pipeline has a single point of failure. The platform's liquidation engine acted on the corrupted prices before engineers could intervene.

- **Circuit breaker**: Paradex has documented protections against "scam wicks" and unfair liquidations (published March 2024), but the January 2026 incident showed these protections were insufficient to prevent mass liquidations from internal data corruption.

- **Admin oracle control**: The Oracle contract is within the audited scope (CairoAudit), but whether the admin can swap oracle sources without delay is UNVERIFIED.

### 3. Economic Mechanism

**Risk: MEDIUM**

- **Leverage**: Up to 50x leverage across 460+ assets (perpetuals, options, spot).

- **Liquidation mechanism**: Positions are reduced by a "Liquidation Share" (multiples of 20%). A liquidation penalty of 70% of MMR is charged and transferred to the insurance fund.

- **Insurance fund**: Exists on the Paraclear contract (address: 0x24d52bb68763343c4f73b63e3723007e00b9f81d2f36d0036c3590ad32062c9 on L2). However, the current balance is **not publicly disclosed** on the stats page or documentation. This is a significant transparency gap for a protocol with $46.9M TVL.

- **Socialized losses**: If the insurance fund is depleted, losses are socialized across users who withdraw during "shortfall" periods. This is a standard last-resort mechanism but concentrates risk on active withdrawers.

- **Funding rate**: Standard perpetual funding mechanism documented at docs.paradex.trade. No unusual design concerns identified.

- **Past incident**: $650K refunded to ~200 users after the January 2026 database migration bug triggered incorrect liquidations. The team absorbed this cost, which is positive, but the incident exposed the fragility of the price-to-liquidation pipeline.

- **Zero fees**: Paradex charges 0% maker and taker fees for retail. Revenue comes from other sources (institutional fees, liquidation penalties). The sustainability of this model long-term is an open question.

### 4. Smart Contract Security

**Risk: MEDIUM**

- **Audit history**:
  - CairoAudit / Cairo Security Clan (May 2025): Paraclear, Vault, Factory, Registry, Oracle contracts (~80-85% coverage)
  - Nethermind (Feb 2025): Smart contracts
  - Zellic (Aug 2025): ZK proofs and settlement layer
  - Zellic + Trail of Bits: L1 Bridge (pre-launch)
  - HackerOne penetration test (March 2025): API and web infrastructure

- **Bug bounty**: Active on Immunefi with up to $500,000 for critical smart contract bugs. Scope covers Paraclear, Oracle, Registry, Vault Factory contracts, plus API and UI. KYC required for payouts.

- **Code openness**: L1 bridge contracts are verified on Etherscan. Cairo smart contracts are partially open (audited code shared with auditors but not fully open-sourced on GitHub as a browsable repo). The paradex-docs repo exists on GitHub, but contract source code repos are not public.

- **Proxy architecture**: Core contracts use StarkWare proxy pattern, upgradeable by 2/5 multisig with zero delay. This means any audit findings are moot if the implementation can be swapped instantly.

- **Battle testing**: Live since February 2024 (~26 months). Handled $250B+ cumulative volume. However, two significant incidents occurred in January 2026 (blockchain rollback + Mithril bot compromise).

### 5. Cross-Chain & Bridge

**Risk: MEDIUM**

- **Architecture**: Paradex is an L2 appchain settling to Ethereum via STARK validity proofs. All funds are bridged from Ethereum L1 to the Paradex L2.

- **Bridge contracts**: USDC Bridge (0xE3cbE3A636AB6A754e9e41B12b09d09Ce9E53Db3) is upgradeable via the same 2/5 multisig with zero delay. Audited by Zellic and Trail of Bits.

- **Withdrawal mechanism**: L2 withdrawal transactions are batched, proved via STARK proofs (Stwo prover), and settled on L1. Total withdrawal time is several hours. There is no emergency escape hatch -- if the sequencer goes down or the proposer is unavailable, withdrawals are frozen.

- **Data availability**: L2BEAT flags a critical concern: "Encrypted data is posted on Ethereum as blobs, and a privacy council of 3 members holds the decryption keys." Users cannot independently reconstruct L2 state without council cooperation. This is a unique privacy-focused design choice but introduces a trust assumption on the 3-member privacy council.

- **Cross-chain bridging**: Paradex supports deposits from other chains via third-party bridge partners (LayerZero, etc.) for convenience, but all funds ultimately settle as USDC on the L1 bridge.

- **Sequencer censorship**: L2BEAT notes there is no mechanism for forced transaction inclusion if the sequencer is censoring. Users are entirely dependent on the centralized operator.

### 6. Operational Security

**Risk: HIGH**

**Team & Track Record:**
- **Anand Gomes** is the publicly known co-founder and CEO of both Paradex and Paradigm (institutional liquidity network). He is doxxed and has a public track record in crypto derivatives infrastructure.
- Other team members: Clement Ho (Director of Engineering) is semi-public (active on Discord during incident response). Beyond these, team composition is not widely disclosed.
- Paradigm (the liquidity network, not the VC firm) provides institutional backing and liquidity infrastructure.

**Incident History (January 2026 -- two incidents in rapid succession):**

1. **January 19, 2026 -- Database migration rollback**: A race condition during a planned database upgrade caused BTC and other prices to display at $0, triggering mass liquidations. The team performed a blockchain rollback to block 1604710 (the last verified state before maintenance). $650K refunded to ~200 affected users. Trading restored ~12:10 UTC.

   This incident is significant because:
   - It demonstrated the team has unilateral power to roll back the blockchain state
   - The liquidation engine had no circuit breaker for obviously invalid prices ($0)
   - The "decentralized" chain acted centrally during the crisis

2. **January 21, 2026 -- Mithril trading bot compromise**: An attacker accessed Mithril's internal systems and exposed 57 user subkeys. No funds were lost (subkeys could only trade, not withdraw). Paradex revoked all affected subkeys and paused XP transfers. This was a third-party integration failure, not a core protocol exploit, but highlights the expanded attack surface from ecosystem integrations.

**Incident response**: No published incident response plan. During the January incidents, communication happened via Discord. Response time for the rollback was several hours (incident ~4:30 AM London time, trading restored ~12:10 UTC = ~7.5 hours).

**Off-chain security**:
- No SOC 2 Type II or ISO 27001 certification disclosed
- One HackerOne penetration test (March 2025) -- this is positive but a single instance
- No published key management policy (HSM, MPC, key ceremony)
- No disclosed operational segregation between development and admin operations
- Centralized sequencer operated by a single EOA -- key compromise = complete service disruption

## Critical Risks

1. **CRITICAL: Zero-timelock instant upgrade via 2/5 multisig** -- Only 2 of 5 signers are needed to push a contract upgrade that could drain all $46.9M in bridged USDC. No delay period exists for users to exit. This is the single most dangerous structural property of the protocol.

2. **HIGH: Centralized sequencer with no forced inclusion** -- The sequencer is a single EOA. If compromised, censored, or offline, all user transactions (including withdrawals) are blocked. No fallback mechanism exists.

3. **HIGH: Privacy council (3 members) controls data availability** -- Users cannot independently verify L2 state without the privacy council's decryption keys. Collusion between the proposer and the privacy council could finalize an invalid state.

4. **HIGH: No escape hatch for fund recovery** -- If the operator goes offline permanently, there is no mechanism for users to recover funds from L1.

## Peer Comparison

| Feature | Paradex | dYdX V4 | GMX V2 |
|---------|---------|---------|--------|
| Timelock | None (0h) | 4-day voting period | 24h timelock |
| Multisig | 2/5 + 3/6 | Validator consensus (2/3 of 60) | 3/6 multisig |
| Audits | 3-4 (CairoAudit, Nethermind, Zellic, Trail of Bits) | 6+ (Informal Systems, Peckshield, OpenZeppelin) | 5+ (Trail of Bits, ABDK, Guardian, Sherlock) |
| Oracle | Stork (single) | Slinky sidecar (multi-CEX aggregator) | Chainlink + custom |
| Insurance/TVL | Undisclosed | ~13.6% | ~5% |
| Open Source | Partial (L1 verified, Cairo partial) | Full (GitHub) | Full (GitHub) |
| Sequencer | Centralized (single EOA) | Decentralized (60 validators) | N/A (AMM, no sequencer) |
| Escape Hatch | None | N/A (own chain) | N/A (L1 native) |
| Past Incidents | Rollback + bot compromise (Jan 2026) | Chain halt (Oct 2025), $9M YFI bad debt (V3) | Oracle manipulation attempts (mitigated) |

## Recommendations

1. **For users currently on Paradex**: Understand that funds are secured by a 2/5 multisig with no timelock. Do not deposit more than you can afford to lose. Consider the centralized sequencer risk: if Paradex goes offline, your funds may be inaccessible for an extended period.

2. **For the Paradex team**: Implement a timelock on contract upgrades (minimum 24h, ideally 48-72h). This is the single most impactful security improvement possible. Increase the multisig threshold to at least 3/5.

3. **Disclose insurance fund balance**: Publish real-time insurance fund data on the stats page. Users need to assess whether the fund is adequately sized relative to open interest.

4. **Add oracle fallback**: Integrate a secondary oracle provider (Pyth or Chainlink) as a fallback for Stork. The January 2026 price corruption incident demonstrates the risk of a single price pipeline.

5. **Implement escape hatch**: As a ZK-rollup, it is technically feasible to implement a forced withdrawal mechanism that allows users to exit directly to L1 without sequencer cooperation. This should be a priority for reaching L2BEAT Stage 1.

6. **Publish incident response plan**: Formalize and publish response procedures, including maximum response times and escalation paths.

7. **Pursue third-party security certification**: SOC 2 Type II or equivalent would provide assurance on operational controls that cannot be verified from on-chain data alone.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- YES, zero timelock on all admin actions
- [x] Admin can change oracle sources arbitrarily? -- UNVERIFIED, but likely given zero-timelock upgrade capability
- [x] Admin can modify withdrawal limits? -- YES, via contract upgrade
- [x] Multisig has low threshold (2/N with small N)? -- YES, 2/5 threshold
- [x] Zero or short timelock on governance actions? -- YES, zero timelock
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (Starknet, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- YES, signer identities undisclosed

**WARNING: 6/7 Drift-type indicators triggered. Paradex's governance structure closely mirrors the pre-hack Drift configuration: low multisig threshold, zero timelock, undisclosed signers, and broad admin powers.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A (USDC-only collateral for perpetuals)
- [x] Single oracle source without TWAP? -- YES, Stork is sole oracle
- [ ] No circuit breaker on price movements? -- PARTIAL (protections exist but failed during Jan 2026 incident)
- [x] Insufficient insurance fund relative to TVL? -- UNVERIFIED (undisclosed)

**2/4 indicators triggered -- below 3-indicator warning threshold.**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- PARTIAL (bridge controlled by 2/5 multisig, but validation is via STARK proofs)
- [x] Admin keys stored in hot wallets? -- UNVERIFIED (no key management policy disclosed)
- [x] No key rotation policy? -- YES, no policy disclosed

**2/3 indicators triggered -- below 3-indicator warning threshold.**

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time? -- N/A (no on-chain governance yet)
- [ ] Flash loans can be used to acquire voting power? -- N/A
- [ ] Proposal + execution in same block or short window? -- N/A
- [ ] No minimum holding period for voting eligibility? -- N/A

**Not applicable -- no on-chain governance exists yet.**

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? -- No (USDC only)
- [ ] Read-only reentrancy risk? -- N/A (Cairo VM, not EVM)
- [ ] Flash loan compatible without reentrancy guards? -- N/A (Starknet architecture)
- [ ] Composability with protocols that expose callback hooks? -- LOW (isolated appchain)

**0/4 indicators triggered.**

### Curve-type (Compiler / Language Bug):
- [x] Uses non-standard or niche compiler (Vyper, Huff)? -- YES, Cairo (relatively new language)
- [ ] Compiler version has known CVEs? -- Not known
- [ ] Contracts compiled with different compiler versions? -- UNVERIFIED
- [ ] Code depends on language-specific behavior? -- POSSIBLE (Cairo has unique memory model)

**1/4 indicators triggered -- below warning threshold, but Cairo's relative immaturity compared to Solidity is a background risk.**

### UST/LUNA-type (Algorithmic Depeg Cascade):
- Not applicable (no stablecoin issuance).

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses a cross-chain bridge for token minting or reserve release? -- YES (L1 bridge releases USDC)
- [ ] Bridge message validation relies on a single messaging layer? -- NO (STARK validity proofs provide cryptographic verification)
- [ ] DVN/relayer/verifier configuration not publicly documented? -- PARTIAL (SHARP verifier is documented)
- [ ] Bridge can release tokens without rate limiting? -- UNVERIFIED
- [ ] Bridged token accepted as collateral on lending protocols? -- NO (DIME is not widely used as collateral)
- [ ] No circuit breaker for abnormal bridge volumes? -- UNVERIFIED
- [ ] Emergency pause response time > 15 minutes? -- YES (~7.5 hours in January 2026 incident)
- [ ] Bridge admin controls under different governance than core protocol? -- NO (same multisig)
- [ ] Token deployed on 5+ chains via same bridge provider? -- NO

**2/9 indicators triggered -- below warning threshold. STARK proof verification significantly mitigates bridge message spoofing risk.**

## Information Gaps

1. **Insurance fund balance**: Not publicly disclosed. Cannot assess fund adequacy relative to TVL or open interest.
2. **Multisig signer identities**: Unknown for both 2/5 and 3/6 multisigs. Cannot assess insider/social engineering risk.
3. **Privacy council members**: The 3-member privacy council controlling data availability encryption keys is not identified publicly.
4. **Full smart contract source code**: Cairo contracts are not in a public GitHub repository. Audit reports are referenced but the full code is not independently browsable.
5. **Sequencer decentralization roadmap**: Paradex mentions plans for Stage 1 and Stage 2 rollup, but no timeline or technical specification is published.
6. **Key management practices**: No information on HSM usage, MPC custody, key rotation, or operational segregation.
7. **Admin oracle override capability**: Whether the admin can swap oracle sources (from Stork to another provider or a malicious feed) without any delay is not documented.
8. **Emergency pause mechanism**: Whether there is a dedicated pause function separate from full contract upgrade is unclear.
9. **Revenue sustainability**: Zero-fee model for retail raises questions about long-term economic viability and potential future fee changes.
10. **CairoAudit full report**: The audit is referenced as public (May 2025) but a direct link to the full findings report was not located during this research.

## Disclaimer

This analysis is based on publicly available information and web research as of April 20, 2026. It is NOT a formal smart contract audit. The analysis relies heavily on L2BEAT, DeFiLlama, GoPlus, Immunefi, and web search results. Always DYOR and consider professional auditing services for investment decisions. Paradex operates on a relatively new technology stack (Starknet appchain with Cairo smart contracts) that has less battle-testing than EVM-based alternatives.
