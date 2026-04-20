# DeFi Security Audit: edgeX (edgeX Exchange)

## Overview
- Protocol: edgeX Exchange
- Chain: Ethereum (L1 settlement), edgeX L1 (StarkEx Validium), Arbitrum, BSC
- Type: Perpetual DEX (CLOB orderbook, up to 100x leverage, 177 assets)
- TVL: $190.8M (bridge TVL, DeFiLlama "edgex-bridge")
- TVL Trend: -5.4% / +16.6% / -16.8% (7d / 30d / 90d)
- Launch Date: August 2024 (mainnet); token TGE March 31, 2026
- Audit Date: 2026-04-20
- Valid Until: 2026-07-19 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Partial (token contract verified on-chain; core matching engine and L2 contracts are closed-source; deposit pool contracts verified on Arbiscan)

## Quick Triage Score: 42/100 | Data Confidence: 40/100

### Triage Score Calculation (start at 100)

CRITICAL flags (-25 each):
- None detected

HIGH flags (-15 each):
- [x] Zero audits listed on DeFiLlama (-15)
- [x] No multisig disclosed (single EOA admin key assumed -- no public multisig configuration) (-15)

MEDIUM flags (-8 each):
- [x] No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations (-8)
- [x] GoPlus: several fields returned null on Ethereum token (incomplete scan -- treated as partial data gap) (-0, accounted in confidence)

LOW flags (-5 each):
- [x] No documented timelock on admin actions (-5)
- [x] No bug bounty program covering smart contracts (Immunefi scope is web/app only, max $10K) (-5)
- [x] Single oracle provider (Stork only) (-5)
- [x] Insurance fund / TVL undisclosed (-5)

**Score: 100 - 15 - 15 - 8 - 5 - 5 - 5 - 5 = 42/100 (HIGH risk)**

### Data Confidence Score Calculation (start at 0)

- [x] +15 Source code is open and verified on block explorer (token contract verified; partial)
- [x] +15 GoPlus token scan completed
- [x] +10 At least 1 audit report publicly available (RigSec, SlowMist, PeckShield claimed)
- [ ] +10 Multisig configuration verified on-chain -- NOT VERIFIED
- [ ] +10 Timelock duration verified on-chain or in docs -- NOT VERIFIED
- [ ] +10 Team identities publicly known (doxxed) -- partial (KF and TraderX known by handles only)
- [ ] +10 Insurance fund size publicly disclosed -- NOT DISCLOSED
- [ ] +5 Bug bounty program details publicly listed -- YES but web-only scope
- [ ] +5 Governance process documented -- minimal
- [ ] +5 Oracle provider(s) confirmed -- YES (Stork)
- [ ] +5 Incident response plan published -- NOT PUBLISHED
- [ ] +5 SOC 2 Type II or ISO 27001 certification verified -- NOT FOUND
- [ ] +5 Published key management policy -- NOT FOUND
- [ ] +5 Regular penetration testing disclosed -- NOT FOUND
- [ ] +5 Bridge DVN/verifier configuration publicly documented -- NOT DOCUMENTED

**Confidence: 15 (partial source) + 15 (GoPlus) + 10 (audits) = 40/100 (LOW confidence)**

- Red flags found: 8 (zero audits on DeFiLlama, no disclosed multisig, no timelock, no off-chain certs, weak bug bounty, single oracle, undisclosed insurance fund, undisclosed multisig signer identities)
- Data points verified: 3 / 15

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | Hyperliquid: disclosed; dYdX: disclosed | HIGH |
| Audit Coverage Score | 1.0 (3 audits, oldest ~1.5yr, details sparse) | Hyperliquid: ~1.0; dYdX: >3.0 | MEDIUM |
| Governance Decentralization | Minimal (token governance planned, not live) | dYdX: on-chain DAO; Hyperliquid: centralized | MEDIUM |
| Timelock Duration | Undisclosed | dYdX: 48h; Hyperliquid: N/A | HIGH |
| Multisig Threshold | Undisclosed | dYdX: multisig; Hyperliquid: undisclosed | HIGH |
| GoPlus Risk Flags | 0 HIGH / 0 MED (many fields null on ETH) | -- | LOW |

### Audit Coverage Score Detail
- RigSec (Sept 2024): 0.5 (1-2 years old)
- SlowMist (date unknown, claimed): 0.5 (assumed ~1.5yr)
- PeckShield (date unknown, claimed): 0.5 (assumed ~1.5yr)
- Total: ~1.5 (MEDIUM threshold, borderline)

Note: Only the RigSec audit is publicly downloadable. SlowMist and PeckShield audits are referenced in third-party articles but no public report links are available.

## GoPlus Token Security

**Chain: Ethereum (0xB0076DE78Dc50581770BBa1D211dDc0aD4F2a241)**

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | 0 (No) | LOW |
| Open Source | 1 (Yes) | LOW |
| Proxy | 0 (No) | LOW |
| Mintable | null (Unknown) | UNVERIFIED |
| Owner Can Change Balance | null (Unknown) | UNVERIFIED |
| Hidden Owner | null (Unknown) | UNVERIFIED |
| Selfdestruct | null (Unknown) | UNVERIFIED |
| Transfer Pausable | null (Unknown) | UNVERIFIED |
| Blacklist | null (Unknown) | UNVERIFIED |
| Slippage Modifiable | null (Unknown) | UNVERIFIED |
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 18,189 | LOW |
| Trust List | N/A | -- |
| Creator Honeypot History | 0 (No) | LOW |

**Chain: Arbitrum (0x70f2eadf1ca1969ff42b0c78e9da519e8937cbaf)**

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | 0 (No) | LOW |
| Open Source | 1 (Yes) | LOW |
| Proxy | 0 (No) | LOW |
| Mintable | 0 (No) | LOW |
| Owner Can Change Balance | 0 (No) | LOW |
| Hidden Owner | 0 (No) | LOW |
| Selfdestruct | 0 (No) | LOW |
| Transfer Pausable | 0 (No) | LOW |
| Blacklist | 0 (No) | LOW |
| Slippage Modifiable | 0 (No) | LOW |
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 42 (Arbitrum only) | -- |
| Trust List | N/A | -- |
| Creator Honeypot History | 0 (No) | LOW |

Note: Ethereum token contract returned null for several critical fields (mintable, hidden_owner, selfdestruct, etc.). The Arbitrum deployment returned complete data with all flags clean. Top holder on Ethereum holds 30% (contract), second holds 25% (contract) -- high concentration.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | HIGH | No disclosed multisig, no timelock, no on-chain governance live | S/O | N |
| Oracle & Price Feeds | MEDIUM | Single oracle provider (Stork) with no disclosed fallback | S | Partial |
| Economic Mechanism | MEDIUM | Insurance fund size undisclosed; vault-based LP model under extreme conditions | S | N |
| Smart Contract | MEDIUM | Audited by 3 firms but only 1 report public; core engine closed-source | S | Partial |
| Token Contract (GoPlus) | LOW | Arbitrum contract clean; Ethereum contract has null fields but no flags raised | S | Y |
| Cross-Chain & Bridge | MEDIUM | Multi-chain deposits via custom bridge with undocumented security model | S/O | N |
| Off-Chain Security | HIGH | No SOC 2/ISO 27001, no published key management, no pentest disclosure | O | N |
| Operational Security | MEDIUM | Team pseudonymous; Amber Group incubation provides some credibility | O | Partial |
| **Overall Risk** | **HIGH** | **Undisclosed admin controls, no governance, opaque off-chain security** | | |

**Overall Risk aggregation**: Governance & Admin = HIGH (counts 2x = 2 HIGHs), Off-Chain Security = HIGH. 2+ categories HIGH triggers Overall = HIGH.

## Detailed Findings

### 1. Governance & Admin Key

**Risk: HIGH**

edgeX has not publicly disclosed its admin key architecture. Key concerns:

- **Multisig**: No public information about whether admin operations use a multisig wallet. The "MultiSigPool V5 with Permit" contract on Arbitrum (0xceeed846...cda332e41) suggests MPC-based signature verification for deposits, but this is a deposit pool mechanism, not governance multisig.
- **Timelock**: No timelock mechanism has been documented or verified on-chain for admin actions such as parameter changes, contract upgrades, or market listings.
- **Governance**: Token-based governance is described as "planned for the next phase" but is not live as of the audit date. There is no on-chain DAO, no governance forum, and no documented proposal process.
- **Admin powers**: The extent of admin privileges is unknown. Given the hybrid off-chain orderbook architecture, the operator has significant control over trade matching, market listings, and risk parameters.
- **Team composition**: Co-founder "KF" (@edgeX_KF), "TraderX" (@edgeX_TraderX), and "Sodam" (Head of Korea) are known by handles. The team is described as coming from Goldman Sachs, Barclays, Morgan Stanley, and Bybit, but individual identities are not fully public.

**Mitigating factors**: Amber Group incubation provides institutional backing. Circle Ventures strategic investment adds credibility. The protocol has operated since August 2024 without fund loss incidents.

### 2. Oracle & Price Feeds

**Risk: MEDIUM**

- **Oracle provider**: Stork decentralized oracle network. Stork uses a decentralized publisher network where independent data providers sign and deliver market data, with on-chain verification.
- **Single provider risk**: edgeX relies solely on Stork. There is no documented fallback oracle (e.g., Chainlink, Pyth) if Stork experiences downtime or data quality issues.
- **Manipulation resistance**: Stork claims to support 2,000+ assets and $300B+ in trading volume worth of price data. The decentralized publisher model provides some manipulation resistance.
- **Admin oracle control**: Unknown whether admin can change oracle sources without timelock or governance vote.

### 3. Economic Mechanism

**Risk: MEDIUM**

- **Architecture**: Hybrid CLOB with off-chain matching and on-chain settlement via StarkEx ZK proofs. Up to 100x leverage across 177 assets.
- **Liquidation**: Cross-margin engine using Stork oracle prices for margin requirements and liquidation thresholds. Specific liquidation parameters (maintenance margin, penalty fees) are not publicly documented in detail.
- **Insurance fund**: 10% of eStrategy vault returns are allocated to a "risk reserve" for extreme events. However, the absolute size of the insurance fund is not publicly disclosed. Given $190M bridge TVL and ~$900M open interest, this is a significant gap.
- **Bad debt handling**: Auto-deleveraging (ADL) mechanism is implied but not explicitly documented. The vault (eStrategy) serves as the counterparty liquidity pool -- in strong trending markets, vault LPs bear the risk.
- **Stress test record**: edgeX claims zero downtime during the October 2025 $19.5B liquidation event, which is a positive signal.
- **Funding rates**: Standard perpetual funding rate mechanism; no unusual design patterns detected.

### 4. Smart Contract Security

**Risk: MEDIUM**

- **Audit history**: Three audits claimed -- RigSec (September 2024), SlowMist, and PeckShield. Only the RigSec report is publicly accessible (PDF at static.edgex.exchange). The RigSec audit found issues including 1inch router integration concerns in the MultiSigPoolV5WithPermit deposit function and EIP-712 specification non-compliance.
- **SlowMist and PeckShield**: Referenced in third-party articles (Datawallet, Coin Bureau) but no public report links found. UNVERIFIED.
- **Open source status**: Token contracts are verified on-chain. Core trading engine and L2 settlement contracts operate on StarkEx infrastructure (closed-source proprietary layer). The deposit pool contracts appear verified on Arbiscan.
- **StarkEx dependency**: edgeX builds on StarkWare's StarkEx engine, which has processed over $1T in cumulative volume without a major exploit. This provides inherited security from a battle-tested framework.
- **Bug bounty**: Immunefi program launched April 7, 2026 with maximum $10,000 payout. Critically, the scope covers only websites and applications (web endpoints), NOT smart contracts. This is far below industry standard for a protocol handling $190M+ in TVL.

### 5. Cross-Chain & Bridge

**Risk: MEDIUM**

- **Multi-chain deposits**: Users can deposit from Ethereum, Arbitrum, BSC, and other EVM chains. Cross-chain withdrawals use L2 asset pools with fees (1 USDT + 0.05%).
- **Bridge architecture**: The bridge mechanism is not publicly documented in detail. DeFiLlama lists "edgeX Bridge" as a separate entity with $190.8M TVL across Ethereum ($115.5M), edgeX L1 ($63.4M), Arbitrum ($11.8M), and BSC ($0.15M).
- **Bridge security**: No public documentation on bridge validator set, DVN configuration, or message verification mechanism.
- **Forced withdrawal**: edgeX claims a forced withdrawal mechanism allowing users to reclaim assets directly on Ethereum L1 if the operator fails -- a standard StarkEx feature that provides an important safety net.

### 6. Operational Security

**Risk: HIGH (Off-Chain) / MEDIUM (Operational)**

- **Team**: Pseudonymous leadership with institutional backing (Amber Group, Circle Ventures). The Amber Group connection provides some accountability -- Amber is a well-known, Hong Kong-based digital asset firm managing $3B+ in assets.
- **Incident history**: No known security incidents, exploits, or fund losses since August 2024 launch.
- **SOC 2 / ISO 27001**: No evidence of any third-party security certification for off-chain operations.
- **Key management**: No published key management policy (HSM, MPC, key ceremony).
- **Penetration testing**: No disclosed penetration testing beyond smart contract audits.
- **Incident response**: No published incident response plan. The platform maintained uptime during the October 2025 market stress event, but formal IR procedures are not documented.
- **Dependencies**: StarkEx (StarkWare), Stork oracle, Ethereum L1 for settlement and ZK proof verification.

## Critical Risks (if any)

1. **No disclosed multisig or timelock** (HIGH): Without public verification of admin key controls, the protocol's $190M TVL is potentially controlled by unknown key management infrastructure. This is the single largest risk factor.
2. **Opaque off-chain security** (HIGH): No SOC 2, no published key management, pseudonymous team -- the off-chain operational security posture cannot be verified.
3. **Bug bounty covers web only, not contracts** (MEDIUM-HIGH): The $10K max bounty covering only web endpoints is inadequate for a $190M+ TVL protocol. Smart contract vulnerabilities are not incentivized.
4. **Single oracle dependency** (MEDIUM): Sole reliance on Stork without a documented fallback creates a single point of failure for pricing.

## Peer Comparison

| Feature | edgeX | Hyperliquid | dYdX |
|---------|-------|-------------|------|
| TVL | $190M (bridge) | ~$6.2B | ~$350M |
| Timelock | Undisclosed | Undisclosed | 48h |
| Multisig | Undisclosed | Undisclosed | Yes (documented) |
| Audits | 3 claimed (1 public) | Multiple (Zellic, others) | 10+ (Trail of Bits, others) |
| Oracle | Stork (single) | Pyth + internal | Multiple (Chainlink, etc.) |
| Insurance/TVL | Undisclosed | Disclosed (HLP vault) | Disclosed (insurance fund) |
| Open Source | Partial (token only) | Partial | Fully open source |
| Bug Bounty Max | $10K (web only) | $2M+ (Immunefi) | $1M+ (Immunefi) |
| Governance | Planned (not live) | Centralized | On-chain DAO |
| Leverage | 100x | 50x | 100x |
| Architecture | StarkEx Validium + CLOB | Custom L1 + CLOB | Cosmos appchain + CLOB |

edgeX's security posture is notably weaker than dYdX on governance transparency, audit depth, and bug bounty coverage. It is roughly comparable to Hyperliquid on governance opacity, but Hyperliquid has significantly higher TVL battle-testing and a larger bug bounty program.

## Recommendations

1. **Users**: Exercise caution with large deposits until admin key architecture is publicly disclosed and verified. Use the forced withdrawal mechanism awareness as a safety net -- confirm you understand how to invoke it on Ethereum L1 if needed.
2. **Protocol**: Publish multisig configuration and timelock parameters. This is the single highest-impact action for building trust.
3. **Protocol**: Expand bug bounty to cover smart contracts with payouts proportional to TVL ($100K+ minimum for critical).
4. **Protocol**: Publish at least one additional audit report (SlowMist or PeckShield) to verify the claimed audit coverage.
5. **Protocol**: Add a secondary oracle provider (Pyth or Chainlink) as fallback for Stork.
6. **Protocol**: Pursue SOC 2 Type II or equivalent certification for off-chain operations, particularly given the centralized matching engine.
7. **Protocol**: Disclose insurance fund size relative to TVL and open interest.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- UNKNOWN (not documented)
- [x] Admin can change oracle sources arbitrarily? -- UNKNOWN (not documented)
- [x] Admin can modify withdrawal limits? -- UNKNOWN (not documented)
- [x] Multisig has low threshold (2/N with small N)? -- UNKNOWN (not documented)
- [x] Zero or short timelock on governance actions? -- UNKNOWN (likely zero)
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (EVM-based)
- [x] Social engineering surface area (anon multisig signers)? -- YES (pseudonymous team)

**WARNING: 5+ indicators match the Drift-type pattern. The governance opacity means this attack vector cannot be ruled out. The lack of documented admin controls is the primary risk factor.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- UNKNOWN (177 assets, some may be low-liquidity)
- [x] Single oracle source without TWAP? -- YES (Stork only, no TWAP documented)
- [ ] No circuit breaker on price movements? -- UNKNOWN
- [x] Insufficient insurance fund relative to TVL? -- UNKNOWN (undisclosed)

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- UNKNOWN (bridge architecture undocumented)
- [ ] Admin keys stored in hot wallets? -- UNKNOWN
- [x] No key rotation policy? -- YES (no policy disclosed)

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time? -- N/A (governance not live)
- [ ] Flash loans can be used to acquire voting power? -- N/A
- [ ] Proposal + execution in same block or short window? -- N/A
- [ ] No minimum holding period for voting eligibility? -- N/A

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? -- UNKNOWN
- [ ] Read-only reentrancy risk? -- LOW (StarkEx architecture separates L1 settlement)
- [ ] Flash loan compatible without reentrancy guards? -- LOW
- [ ] Composability with protocols that expose callback hooks? -- LOW

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler? -- NO (Solidity on StarkEx)
- [ ] Compiler version has known CVEs? -- UNKNOWN
- [ ] Contracts compiled with different compiler versions? -- UNKNOWN
- [ ] Code depends on language-specific behavior? -- LOW

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral? -- N/A (not a stablecoin protocol)
- [ ] Redemption mechanism creates sell pressure on collateral? -- N/A
- [ ] Oracle delay could mask depegging? -- N/A
- [ ] No circuit breaker on redemption volume? -- N/A

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [x] Protocol uses a cross-chain bridge for token minting or reserve release? -- YES (custom bridge)
- [ ] Bridge message validation relies on a single messaging layer? -- UNKNOWN
- [ ] DVN/relayer/verifier configuration not publicly documented? -- YES (undocumented)
- [ ] Bridge can release or mint tokens without rate limiting? -- UNKNOWN
- [ ] Bridged/wrapped token accepted as collateral on lending protocols? -- EDGE token not yet widely used as collateral
- [ ] No circuit breaker to pause minting if bridge volume exceeds thresholds? -- UNKNOWN
- [ ] Emergency pause response time > 15 minutes? -- UNKNOWN
- [ ] Bridge admin controls under different governance than core protocol? -- UNKNOWN
- [ ] Token deployed on 5+ chains via same bridge provider? -- NO (3 chains)

## Information Gaps

The following questions could NOT be answered from public information. These represent unknown risks -- absence of evidence is not evidence of absence.

1. **Admin key architecture**: Is there a multisig? What is the threshold? Who are the signers? This is the most critical unknown.
2. **Timelock configuration**: Is there any timelock on admin actions (parameter changes, upgrades, market listings)?
3. **Insurance fund size**: What is the absolute size of the risk reserve relative to $190M TVL and ~$900M open interest?
4. **SlowMist and PeckShield audit reports**: Are these audits real? When were they conducted? What was the scope and findings?
5. **Bridge security model**: What validation mechanism secures cross-chain deposits? What is the validator/relayer configuration?
6. **Circuit breakers**: Are there automated circuit breakers for abnormal price movements or unusual withdrawal patterns?
7. **Key management**: How are operator keys stored? HSM? MPC? What is the key rotation policy?
8. **Upgrade mechanism**: Can the operator upgrade contracts? Is there a timelock or governance requirement?
9. **Team identities**: Who are the specific individuals behind the pseudonymous handles? What is their verifiable track record?
10. **Off-chain matching engine**: How is the orderbook engine secured? What prevents the operator from front-running or censoring orders?
11. **EDGE token Ethereum contract**: Why did GoPlus return null for critical fields (mintable, hidden_owner, selfdestruct, etc.)? The contract may use a non-standard implementation.
12. **Token holder concentration**: Top 2 holders on Ethereum hold 55% of supply (both contracts). What are these contracts? Are they vesting, treasury, or LP?
13. **Forced withdrawal mechanism**: While claimed, no step-by-step user documentation or on-chain verification of this mechanism was found.
14. **Downstream lending exposure**: Is EDGE token accepted as collateral on any lending protocol? If so, an exploit could cascade.

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
