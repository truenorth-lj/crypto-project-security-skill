# DeFi Security Audit: Antarctic Exchange

## Overview
- Protocol: Antarctic Exchange (AX)
- Chain: Arbitrum (primary; also claims Ethereum and BNB Chain support)
- Type: Perpetual DEX (ZK-powered orderbook, up to high leverage)
- TVL: $10.3M (DeFiLlama, "antarctic" slug)
- TVL Trend: +4.9% (7d) / +2.9% (30d) / +187.7% (90d)
- Launch Date: ~December 2024 (mainnet; testnet Chapter 2 launched November 25, 2024)
- DeFiLlama Listed: November 20, 2025
- Audit Date: 2026-04-20
- Valid Until: 2026-07-19 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Closed (no GitHub repo listed on DeFiLlama, no public code repository found)
- Token: ATTX (pre-TGE; no contract address published yet)
- Open Interest: ~$3,676 BTC OI per CoinGecko (relatively small; CoinGecko top 10 perp DEX by OI)

## Quick Triage Score: 0/100 | Data Confidence: 0/100

### Triage Score Calculation (start at 100, subtract mechanically)

CRITICAL flags: none applied (0)

HIGH flags (-15 each):
- [x] Closed-source contracts (no public GitHub, no verified source on block explorer) (-15)
- [x] Zero audits listed on DeFiLlama (-15)
- [x] Anonymous team with no prior track record (-15)
- [x] No multisig (no multisig configuration disclosed or verifiable) (-15)

MEDIUM flags (-8 each):
- [x] No third-party security certification (SOC 2 / ISO 27001) for off-chain operations (-8)
- [x] Protocol age < 6 months with TVL > $50M -- NOT triggered (TVL $10.3M, age ~16 months) (0)

LOW flags (-5 each):
- [x] No documented timelock on admin actions (-5)
- [x] No bug bounty program (-5)
- [x] Single oracle provider (oracle provider undisclosed, likely single source) (-5)
- [x] Insurance fund / TVL undisclosed (-5)
- [x] Undisclosed multisig signer identities (-5)
- [x] No published key management policy (-5)
- [x] No disclosed penetration testing (-5)

- 4 HIGH flags: 4 x 15 = 60
- 1 MEDIUM flag: 1 x 8 = 8
- 7 LOW flags: 7 x 5 = 35
- Total deductions: 60 + 8 + 35 = 103

**Score: 100 - 103 = -3, floor at 0. Final: 0/100 (CRITICAL risk, mechanical)**

### Data Confidence Score Calculation (start at 0, add verified points)

- [ ] +15  Source code is open and verified on block explorer (CLOSED SOURCE -- no GitHub, no verified contracts)
- [ ] +15  GoPlus token scan completed (token not yet launched / no contract address available)
- [ ] +10  At least 1 audit report publicly available (none found)
- [ ] +10  Multisig configuration verified on-chain (not disclosed)
- [ ] +10  Timelock duration verified on-chain or in docs (not disclosed)
- [ ] +10  Team identities publicly known (anonymous team)
- [ ] +10  Insurance fund size publicly disclosed (only mentioned in liquidation context; no size disclosed)
- [ ] +5   Bug bounty program details publicly listed (none found)
- [ ] +5   Governance process documented (token governance mentioned in litepaper but no details)
- [ ] +5   Oracle provider(s) confirmed (not disclosed)
- [ ] +5   Incident response plan published (none found)
- [ ] +5   SOC 2 Type II or ISO 27001 certification verified (none found)
- [ ] +5   Published key management policy (none found)
- [ ] +5   Regular penetration testing disclosed (none found)
- [ ] +5   Bridge DVN/verifier configuration publicly documented (N/A -- single chain primarily)

**Confidence: 0/100 (LOW confidence -- virtually no claims could be independently verified)**

**Interpretation: Triage 0/100 (CRITICAL risk) with Confidence 0/100 (LOW). Almost nothing about this protocol's security posture could be verified from public sources. The extremely low confidence score means the actual risk could theoretically be lower, but the complete absence of verifiable security information is itself a major red flag.**

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | GMX ~5-8%, Gains Network ~3-5% | HIGH |
| Audit Coverage Score | 0.0 (zero audits) | GMX ~2.5, Gains Network ~2.0 | CRITICAL |
| Governance Decentralization | None verifiable | GMX: multisig + timelock, Gains: 4-signer multisig + 48h timelock | CRITICAL |
| Timelock Duration | Undisclosed | GMX 24h, Gains Network 48h | HIGH |
| Multisig Threshold | Undisclosed | GMX 4/6, Gains Network 4/N | HIGH |
| GoPlus Risk Flags | N/A (token not launched) | -- | N/A |

## GoPlus Token Security

**N/A** -- The ATTX token has not yet launched (pre-TGE). No contract address is publicly available. GoPlus scan cannot be performed. This will need to be reassessed once the token launches.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | CRITICAL | No disclosed multisig, no timelock, no governance contracts, anonymous team | S/O | N |
| Oracle & Price Feeds | HIGH | Oracle provider completely undisclosed; no fallback mechanism documented | S | N |
| Economic Mechanism | MEDIUM | Insurance fund exists conceptually (ADL mechanism) but size undisclosed; hybrid LP model is novel | S | N |
| Smart Contract | CRITICAL | Closed-source contracts, zero public audits, no verified source code | S | N |
| Token Contract (GoPlus) | N/A | Token not yet launched (pre-TGE) | -- | N/A |
| Cross-Chain & Bridge | N/A | Primarily Arbitrum; multi-chain claims but DeFiLlama only tracks Arbitrum | -- | N/A |
| Off-Chain Security | CRITICAL | Anonymous team, no certifications, no published security practices | O | N |
| Operational Security | HIGH | Anonymous team, no incident response plan, no disclosed emergency procedures | S/O | N |
| **Overall Risk** | **CRITICAL** | **Closed-source, zero audits, anonymous team, no verifiable governance -- near-total opacity** | | |

**Overall Risk aggregation**: Governance & Admin = CRITICAL (counts as 2x weight). Smart Contract = CRITICAL. Off-Chain Security = CRITICAL. With ANY category at CRITICAL, Overall = CRITICAL. Multiple CRITICAL categories reinforce this assessment.

## Detailed Findings

### 1. Governance & Admin Key

**Risk: CRITICAL**

Antarctic Exchange has disclosed virtually nothing about its governance or admin key architecture. Key gaps:

- **Multisig**: No multisig address, threshold, or signer information has been published. It is unknown whether protocol admin functions are controlled by a single EOA, a multisig, or some other mechanism.
- **Timelock**: No timelock on admin actions has been documented. There is no evidence of any delay between admin action initiation and execution.
- **Admin powers**: The docs describe "rules-based operational controls at the protocol level" but provide zero specifics about what admin keys can do. It is unknown whether admin can:
  - Pause the protocol
  - Upgrade contracts
  - Change trading parameters
  - Modify oracle sources
  - Drain funds
  - List new markets
- **Governance token**: The ATTX token is described as having governance utility ("governance participation"), but no governance contracts, proposal process, quorum requirements, or voting mechanisms are documented. The token has not launched yet.
- **Team allocation**: The team holds 2% of ATTX supply for "liquidity pool buffers." The litepaper states "the majority of tokens will be held by end users instead of team or investors" but provides no full token breakdown (explicitly noted as pending pre-TGE release).

**Timelock bypass detection**: Cannot be assessed -- no timelock or emergency multisig roles are documented.

**Token concentration**: Cannot be assessed -- token not yet launched.

### 2. Oracle & Price Feeds

**Risk: HIGH**

The Antarctic Exchange documentation does not mention ANY oracle provider. There is no reference to Chainlink, Pyth, or any other price feed service in any publicly available documentation or press releases.

- **Oracle architecture**: UNKNOWN. For a perpetual futures DEX, the oracle is a critical component for mark price, funding rate, and liquidation calculations. The complete absence of oracle documentation is a significant red flag.
- **Fallback mechanism**: UNKNOWN.
- **Admin override of oracle**: UNKNOWN.
- **Market listing process**: The FAQ mentions a "strict token selection process prioritizing high-quality tokens with sufficient liquidity," but no details on how price feeds are sourced for listed tokens.
- **Price manipulation resistance**: UNKNOWN. No TWAP configuration, circuit breaker, or price deviation thresholds are documented.

The ZK-SNARK orderbook architecture may use internal price discovery, but mark price for liquidations and funding rates still requires external price feeds. This is a fundamental gap in the public documentation.

### 3. Economic Mechanism

**Risk: MEDIUM**

Antarctic has disclosed more about its economic mechanism than its governance or security. Key findings:

- **Hybrid LP System**: The protocol uses two LP pools:
  - **AMLP (Antarctic Market Making LP)**: Core market-making pool where LPs act as counterparty to traders. AMLP tokens have intrinsic USD-denominated value.
  - **AHLP (Antarctic Hedge Liquidity Pool)**: Dynamic hedging pool designed to protect LPs from drawdowns.
  - **Treasury backstop**: Funded by 40% of net trading fees.

- **Liquidation mechanism**: Auto-Deleveraging (ADL) is triggered when the insurance fund is depleted and positions cannot close above bankruptcy price. This is a standard mechanism used by major perp DEXes.

- **Position limits**: Enforced on high-leverage trading pairs to prevent over-leveraging. Specific limits are not documented.

- **Fee structure**: Maker 0.02%, Taker 0.05%. Competitive with industry standards.

- **Insurance fund**: Referenced in the liquidation documentation but no size, capitalization, or Insurance/TVL ratio is disclosed. The treasury backstop (40% of fees) provides ongoing funding, but the current balance is unknown.

- **LP withdrawal**: 7-day waiting period after removal request, followed by a 24-hour confirmation window. This is a reasonable cooldown to prevent bank-run dynamics.

- **Bad debt handling**: ADL mechanism socializes losses among profitable traders when insurance fund is exhausted. This is standard for perp DEXes.

### 4. Smart Contract Security

**Risk: CRITICAL**

- **Source code**: CLOSED. No GitHub repository is linked on DeFiLlama, the protocol website, or any documentation. No public code repository was found in web searches.
- **Audit history**: ZERO. No audit reports are listed on DeFiLlama. No references to any security audit firm (CertiK, Trail of Bits, Quantstamp, etc.) were found in any search.
- **Verified contracts**: UNKNOWN. No contract addresses are published in the documentation. The DeFiLlama adapter tracks AMLP and AHLP staking contracts, suggesting on-chain contracts exist, but their addresses and verification status are not publicly documented.
- **Audit Coverage Score**: 0.0 (no audits of any age).
- **Bug bounty**: No bug bounty program found on Immunefi or any other platform.
- **Battle testing**: The protocol has been live since approximately December 2024 (~16 months). TVL has grown from ~$277K to ~$10.3M. Peak TVL was ~$12.2M (approximately March 2026). No exploits or security incidents are documented.
- **ZK technology claims**: The protocol claims to use "ZK-SNARKs and Merkle Trees" for data compression and trade privacy. These are advanced cryptographic constructs that are difficult to implement correctly. Without code review or audit verification, these claims cannot be assessed.
- **Hybrid execution model**: The AMLP documentation mentions "on-chain verification with off-chain execution." This hybrid model means that the off-chain matching engine is a critical trust component. Its security properties are undocumented.

### 5. Cross-Chain & Bridge

**N/A** -- Antarctic is primarily deployed on Arbitrum. While documentation claims support for Ethereum and BNB Chain, DeFiLlama only tracks Arbitrum TVL. No cross-chain bridge dependencies or message-passing mechanisms are documented. If multi-chain deployment expands, this section should be reassessed.

### 6. Operational Security

**Risk: HIGH**

- **Team**: Fully anonymous. No team members are named in any documentation, press releases, or social media. The contact email is socials@antarctic.exchange. No team bios, LinkedIn profiles, or previous project history could be found.
- **Track record**: No prior projects attributable to the team. The protocol launched in late 2024 and has operated without known incidents for ~16 months.
- **Incident response**: No published incident response plan. No documentation of emergency pause capability, security alert channels, or escalation procedures.
- **Emergency pause**: The self-custody documentation mentions "rules-based operational controls" but does not confirm whether an emergency pause exists or who can trigger it.
- **Dependencies**: Unknown oracle provider(s). Arbitrum chain dependency (Arbitrum sequencer risk). Unknown off-chain execution engine dependencies.
- **Certifications**: No SOC 2, ISO 27001, or any other security certification found.
- **Key management**: No published key management policy. No mention of HSMs, MPC custody, or key ceremony procedures.
- **Penetration testing**: No disclosed infrastructure penetration testing.

## Critical Risks

1. **CRITICAL: Closed-source contracts with zero audits** -- Users are trusting unaudited, unverifiable code with their funds. For a protocol handling $10.3M TVL, this is an unacceptable security posture. Any vulnerability in the ZK circuits, settlement logic, or LP mechanics could lead to total fund loss.

2. **CRITICAL: Completely anonymous team with no verifiable governance** -- No multisig, no timelock, no governance contracts are documented. If admin keys exist (which they must for any operational protocol), their configuration and holder identities are entirely unknown. This creates maximum rug-pull risk.

3. **CRITICAL: No disclosed oracle provider** -- For a perpetual futures DEX, the oracle is critical infrastructure. The complete absence of oracle documentation means users cannot assess liquidation fairness, funding rate accuracy, or price manipulation risk.

4. **HIGH: Off-chain execution engine is a black box** -- The hybrid on-chain/off-chain model means the matching engine operates off-chain with no public documentation of its security properties. Users must trust the anonymous team to operate this fairly.

## Peer Comparison

| Feature | Antarctic | GMX (Arbitrum) | Gains Network (Arbitrum) |
|---------|-----------|----------------|--------------------------|
| TVL | $10.3M | $262.7M | ~$50M |
| Timelock | Undisclosed | 24h | 48h |
| Multisig | Undisclosed | 4/6 (partially doxxed signers) | 4/N multisig |
| Audits | 0 | Multiple (ABDK, others) | Multiple |
| Oracle | Undisclosed | Chainlink | Chainlink + custom DON |
| Insurance/TVL | Undisclosed | ~5-8% | ~3-5% |
| Open Source | No | Yes | Yes |
| Team | Anonymous | Pseudonymous (partially doxxed) | Pseudonymous (partially doxxed) |
| Bug Bounty | None | Yes (Immunefi) | Yes (Immunefi) |
| Architecture | ZK orderbook (claimed) | AMM / GLP-based | Synthetic / DAI vault |

Antarctic falls significantly below both peer benchmarks on every security metric. GMX and Gains Network, despite being imperfect, provide substantially more transparency, audit coverage, and governance safeguards.

## Recommendations

1. **For users**: Exercise extreme caution. The complete lack of audit, open-source code, governance disclosure, and team identity creates maximum information asymmetry. Only deposit what you can afford to lose entirely. Monitor TVL trends for sudden drops (potential rug indicator).

2. **For the protocol**: Before seeking additional TVL:
   - Publish smart contract source code and get verified on Arbiscan
   - Commission at least one reputable security audit (Trail of Bits, OpenZeppelin, ChainSecurity, or equivalent)
   - Disclose multisig configuration (addresses, threshold, signer identities)
   - Implement and document a timelock (minimum 24h, ideally 48h+)
   - Disclose oracle provider(s) and fallback mechanisms
   - Launch a bug bounty program on Immunefi
   - Publish an incident response plan
   - Disclose insurance fund size and capitalization

3. **For DeFi aggregators/trackers**: Consider adding risk warnings for protocols with zero audits and closed-source contracts.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? UNKNOWN -- no timelock documented
- [x] Admin can change oracle sources arbitrarily? UNKNOWN -- oracle undisclosed
- [x] Admin can modify withdrawal limits? UNKNOWN -- admin powers undisclosed
- [x] Multisig has low threshold (2/N with small N)? UNKNOWN -- multisig undisclosed
- [x] Zero or short timelock on governance actions? YES -- no timelock documented
- [ ] Pre-signed transaction risk (durable nonce on Solana)? N/A -- EVM chain
- [x] Social engineering surface area (anon multisig signers)? YES -- fully anonymous team

**WARNING: 5+ indicators matched in the Drift-type category. Antarctic's complete governance opacity means a Drift-type attack (admin key compromise leading to fund theft) cannot be ruled out. The anonymous team and undisclosed multisig create maximum social engineering risk.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [x] Low-liquidity collateral accepted? UNKNOWN -- collateral types undisclosed
- [x] Single oracle source without TWAP? UNKNOWN -- oracle undisclosed
- [x] No circuit breaker on price movements? UNKNOWN -- not documented
- [ ] Insufficient insurance fund relative to TVL? UNKNOWN -- fund size undisclosed

**WARNING: 3+ indicators matched. The complete lack of oracle documentation means oracle manipulation risks cannot be assessed.**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? N/A (single chain)
- [x] Admin keys stored in hot wallets? UNKNOWN
- [x] No key rotation policy? YES -- no key management policy published

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time? UNKNOWN (token not launched)
- [ ] Flash loans can be used to acquire voting power? UNKNOWN
- [ ] Proposal + execution in same block or short window? UNKNOWN
- [ ] No minimum holding period for voting eligibility? UNKNOWN

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? UNKNOWN
- [ ] Read-only reentrancy risk? UNKNOWN (closed source)
- [ ] Flash loan compatible without reentrancy guards? UNKNOWN
- [ ] Composability with protocols that expose callback hooks? UNKNOWN

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler? UNKNOWN (closed source)
- [ ] Compiler version has known CVEs? UNKNOWN
- [ ] Contracts compiled with different compiler versions? UNKNOWN
- [ ] Code depends on language-specific behavior? UNKNOWN

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral? No stablecoin component
- [ ] Redemption mechanism creates sell pressure on collateral? N/A
- [ ] Oracle delay could mask depegging? N/A
- [ ] No circuit breaker on redemption volume? N/A

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses a cross-chain bridge for token minting? Not currently
- [ ] Bridge message validation relies on single messaging layer? N/A
- [ ] DVN/relayer/verifier configuration not documented? N/A
- [ ] Bridge can release or mint tokens without rate limiting? N/A
- [ ] Bridged token accepted as collateral on lending protocols? No
- [ ] No circuit breaker for bridge-released volume? N/A
- [ ] Emergency pause response time > 15 minutes? UNKNOWN
- [ ] Bridge admin controls under different governance? N/A
- [ ] Token deployed on 5+ chains via same bridge? No

## Information Gaps

The following critical questions could NOT be answered from publicly available information:

1. **Smart contract addresses** -- No contract addresses for core protocol components (vault, orderbook, LP contracts) are published
2. **Audit reports** -- Zero audits found; no audit firm engagement disclosed
3. **Multisig configuration** -- Unknown whether admin keys use a multisig; if so, threshold, signers, and addresses are all unknown
4. **Timelock** -- No timelock on any admin action is documented
5. **Oracle provider** -- Completely undisclosed; critical for a perpetual DEX
6. **Team identities** -- Fully anonymous with no prior project attribution
7. **Insurance fund size** -- Referenced in liquidation docs but actual balance/capitalization never disclosed
8. **Source code** -- Closed source; no public repository
9. **ZK circuit verification** -- Claims of ZK-SNARK usage cannot be verified without source code or audit
10. **Off-chain matching engine** -- Architecture, security, and operator identity undisclosed
11. **Upgrade mechanism** -- Unknown whether contracts are upgradeable and who controls upgrades
12. **Incident response** -- No emergency procedures documented
13. **Key management** -- No policies disclosed for admin key storage or rotation
14. **Revenue and fee distribution** -- 40% of fees go to treasury backstop, but remaining distribution and treasury management are opaque
15. **Token contract address (ATTX)** -- Pre-TGE, no contract deployed

**These information gaps represent the most comprehensive set of unknowns encountered in any protocol audit in this series. The near-total absence of verifiable security information makes meaningful risk assessment impossible beyond flagging the opacity itself as the primary risk.**

## Disclaimer
This analysis is based on publicly available information and web research as of 2026-04-20.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
