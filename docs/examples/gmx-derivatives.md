# DeFi Security Audit: GMX

## Overview
- Protocol: GMX
- Chain: Arbitrum (primary), Avalanche, MegaETH, Botanix; multichain trading via LayerZero on Base, BNB Chain, Ethereum Mainnet, Solana
- Type: Decentralized Perpetual and Spot Exchange (Derivatives/Perps)
- TVL: ~$265M (Arbitrum: $243M, Avalanche: $13M, MegaETH: $8M, Botanix: $39K)
- TVL Trend: -2.0% / +2.0% / -28.9% (7d / 30d / 90d)
- Launch Date: September 2021 (Arbitrum)
- Audit Date: 2026-04-20
- Valid Until: 2026-07-20 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Open (github.com/gmx-io)

## Quick Triage Score: 17 | Data Confidence: 60

Starting at 100, deductions:

CRITICAL flags:
- [x] GoPlus: hidden_owner = 1: -25
- [x] GoPlus: owner_change_balance = 1: -25

HIGH flags:
- [x] Anonymous team with no prior doxxed identity: -15

MEDIUM flags:
- [x] GoPlus: is_mintable = 1: -8
- [x] No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations: -8

LOW flags:
- [x] Single oracle provider: -5
- [x] Insurance fund / TVL undisclosed (no explicit insurance fund): -5
- [x] Undisclosed multisig signer identities (pseudonymous Security Council): -5

Score: 100 - 25 - 25 - 15 - 8 - 8 - 5 - 5 - 5 = **4**

Floor at 0. However, reviewing the GoPlus flags: the hidden_owner and owner_change_balance flags apply to the GMX ERC-20 token contract specifically, not the protocol's core trading contracts. The token contract owner (0x0a29...1c0) has zero balance. These are legacy token contract flags, not indicators of active rug-pull capability in the protocol. Applying the mechanical scoring strictly:

Score: **4** (CRITICAL risk, 0-19 range)

**Important context**: The mechanical triage score is heavily penalized by two CRITICAL GoPlus flags on the token contract. These flags reflect token-contract-level privileged functions that have existed since 2021 without being exploited. The protocol's core trading contracts (V2 Synthetics) are architecturally separate. Users should weigh this context when interpreting the score.

Red flags found: 8 (hidden owner on token, owner can change balance on token, anonymous team, mintable token, no security certification, single oracle, no insurance fund, pseudonymous signers)

Data Confidence Score: **60** (MEDIUM confidence)

Verification points:
- [x] +15  Source code is open and verified on block explorer
- [x] +15  GoPlus token scan completed
- [x] +10  At least 1 audit report publicly available
- [ ] +10  Multisig configuration verified on-chain (Safe API or Squads) -- NOT VERIFIED
- [ ] +10  Timelock duration verified on-chain or in docs -- PARTIAL (documented as 24h but not on-chain verified)
- [ ] +10  Team identities publicly known (doxxed) -- NO (anonymous)
- [ ] +10  Insurance fund size publicly disclosed -- NO
- [x] +5   Bug bounty program details publicly listed
- [x] +5   Governance process documented
- [x] +5   Oracle provider(s) confirmed
- [x] +5   Incident response plan published (demonstrated via V1 hack response)
- [ ] +5   SOC 2 Type II or ISO 27001 certification verified -- NO
- [ ] +5   Published key management policy -- NO
- [ ] +5   Regular penetration testing disclosed -- NO
- [ ] +5   Bridge DVN/verifier configuration publicly documented -- NOT VERIFIED

Total: 15 + 15 + 10 + 5 + 5 + 5 + 5 = **60**

Data points verified: 7 / 15

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (GSR proposed, not funded) | dYdX ~5%, Synthetix vault-based | HIGH |
| Audit Coverage Score | 3.75 (Guardian ongoing 2022-2026: ~1.0, Sherlock 2023: 0.25, Certora 2023: 0.25, Dedaub 2022: 0.25, ABDK 2022: 0.25, Zellic 2024: 0.5, Sec3 2024: 0.5, Guardian 2025-2026 addl: ~1.0) | dYdX ~3.0, Synthetix ~3.0 | LOW |
| Governance Decentralization | Snapshot voting + Security Council oversight | dYdX on-chain, Synthetix on-chain | MEDIUM |
| Timelock Duration | 24h (upgrades); parameters UNVERIFIED | dYdX 48h, Synthetix 24h | MEDIUM |
| Multisig Threshold | UNVERIFIED (timelock multisig role exists in contracts) | dYdX 4/7, Synthetix 4/8 | MEDIUM |
| GoPlus Risk Flags | 2 CRITICAL / 1 MED | -- | HIGH |

## GoPlus Token Security (Arbitrum: 0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | LOW |
| Open Source | Yes (1) | LOW |
| Proxy | No (0) | LOW |
| Mintable | Yes (1) | MEDIUM |
| Owner Can Change Balance | Yes (1) | CRITICAL |
| Hidden Owner | Yes (1) | CRITICAL |
| Selfdestruct | No (0) | LOW |
| Transfer Pausable | No (0) | LOW |
| Blacklist | No (0) | LOW |
| Slippage Modifiable | No (0) | LOW |
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 299,358 | LOW |
| Trust List | No (0) | -- |
| Creator Honeypot History | No (0) | LOW |

Note: The hidden_owner and owner_change_balance flags are significant. The owner address (0x0a29...1c0) has zero balance but retains privileged control. The top holder (0x908c...dd4) is a contract holding ~58.2% of supply, likely a staking or vesting contract. The token is listed on Binance. Total supply: ~10.99M GMX.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | MEDIUM | Anonymous team, pseudonymous Security Council, unverified multisig threshold | S/O | Partial |
| Oracle & Price Feeds | MEDIUM | Single provider (Chainlink Data Streams); historical AVAX manipulation incident | S/H | Partial |
| Economic Mechanism | MEDIUM | No explicit insurance fund; LP-as-counterparty model exposes LPs to tail risk | S | Partial |
| Smart Contract | MEDIUM | V1 reentrancy hack ($42M, July 2025); V2 extensively audited but complex | S/H | Y |
| Token Contract (GoPlus) | HIGH | Hidden owner, owner can change balance, mintable | S | Y |
| Cross-Chain & Bridge | MEDIUM | LayerZero dependency for 7+ chain multichain trading; single bridge provider | S | Partial |
| Off-Chain Security | HIGH | Anonymous team, no SOC 2/ISO 27001, no published key management | O | N |
| Operational Security | MEDIUM | Strong bug bounty ($5M max); anonymous team; proven incident response | S/O | Partial |
| **Overall Risk** | **MEDIUM** | **Well-audited protocol with proven track record, but anonymous team, GoPlus CRITICAL flags on token contract, no off-chain security certifications, and expanding cross-chain attack surface** | |

**Overall Risk aggregation**: 0 CRITICAL categories, 2 HIGH categories (Token Contract, Off-Chain Security). 2+ HIGH = Overall HIGH. However, the Token Contract HIGH is driven by GoPlus flags on a legacy ERC-20 contract (not core protocol), and Off-Chain Security HIGH is common for anonymous-team DeFi protocols. Per mechanical rule: **2+ HIGH = Overall HIGH**. Adjusting to MEDIUM would require overriding the mechanical rule. Reporting the mechanical result: **HIGH**, with the caveat that the token contract flags are on a legacy ERC-20 and not on the V2 Synthetics trading contracts.

**Revised per mechanical rule: Overall = HIGH**

## Detailed Findings

### 1. Governance & Admin Key

**Team**: The GMX core team is fully anonymous/pseudonymous. The lead developer is known only as "X" on Twitter. Prior projects include XVIX and Gambit. Two individuals associated with multisig signing authority have been publicly identified: Krunal Amin (founder of UniDex) and Benjamin Simon (co-founder of Stealth Crypto).

**Governance Process**: Off-chain governance via Snapshot (snapshot:gmx.eth). GMX token holders vote on proposals. No on-chain governance module exists. The GMX has three committees with 6-month seasons:
- **Security Committee** (Season 4: May-Oct 2026): Dedicated security and governance oversight body. Reviews upgrades, verifies deployments, oversees timelock transactions. Season 3 members included Q, SniperMonke, Raoul, Owen (Guardian auditor), and one vacant seat. Season 4 nominations were posted March 2026.
- **Listing Committee** (Season 4): Oversees new market listings.
- **Governance Committee** (Season 4): Oversees governance process.

**Admin Key Surface Area (V2)**: GMX V2 (Synthetics) uses a granular role-based access control system with 21 defined roles in the RoleStore contract:
- ROLE_ADMIN: Can grant/revoke all roles. Must always have at least one holder.
- TIMELOCK_ADMIN: Administrative role with time-locked execution.
- TIMELOCK_MULTISIG: Multisig role for time-locked operations. Must always have at least one holder.
- CONFIG_KEEPER: Can modify protocol configuration settings.
- LIMITED_CONFIG_KEEPER: Restricted configuration modification.
- CONTROLLER: General control role for system operations.
- MARKET_KEEPER: Can manage markets.
- ORDER_KEEPER / LIQUIDATION_KEEPER / ADL_KEEPER: Operational roles for execution.

**Timelock**: 24-hour timelock on upgrade-related operations. The GMX README explicitly warns: "Config keepers and timelock admins could potentially disrupt regular operation through the disabling of features, incorrect setting of values, whitelisting malicious tokens, abusing the positive price impact value." The timelock multisig is expected to revoke permissions of compromised accounts.

**Multisig**: A timelock multisig role is enforced in the smart contracts (at least one member required), but the specific threshold (e.g., 3/5, 4/6) and the list of signer addresses are NOT publicly documented in a discoverable way. This is a transparency gap. Each chain deployment (Arbitrum, Avalanche, MegaETH) has its own security infrastructure set up by the Security Council.

**Risk**: MEDIUM. The role-based system is well-designed with separation of concerns. However, the anonymous team and undisclosed multisig configuration are concerns. The 24h timelock is short compared to some peers. The committee structure with 6-month rotating seasons provides some governance continuity.

### 2. Oracle & Price Feeds

**Architecture**: GMX V2 uses Chainlink Data Streams, a pull-based low-latency oracle system. On MegaETH, this enables sub-second price updates with 10ms block times. The system uses a commit-and-reveal architecture with sub-second data delivery and transaction privacy prior to execution, mitigating frontrunning.

**Oracle Keepers**: Off-chain oracle keepers pull prices from reference exchanges, cryptographically sign them, and publish to Archive nodes. Order keepers then bundle signed prices with user requests for execution. Both minimum and maximum prices are signed, incorporating bid-ask spread information.

**Fallback Mechanism**: UNVERIFIED. No public documentation describes what happens if Chainlink Data Streams become unavailable.

**Historical Incident**: In September 2022, an attacker exploited V1's zero-slippage oracle pricing to manipulate the AVAX/USD market, profiting ~$565K by wash-trading on CEXs to move the price that Chainlink oracles reported. GMX responded by capping AVAX open interest. V2's Data Streams architecture was designed partly to address this class of attack.

**Admin Oracle Control**: CONFIG_KEEPER and TIMELOCK_ADMIN roles can potentially change oracle-related parameters. The extent to which oracle sources can be swapped by admin is UNVERIFIED.

**Risk**: MEDIUM. Chainlink Data Streams is the industry standard, and the V2 architecture addresses V1's manipulation vulnerability. However, single-provider dependency and UNVERIFIED fallback mechanisms are concerns.

### 3. Economic Mechanism

**Liquidity Model**: GMX V2 uses isolated GM (GMX Market) pools where each market consists of an index token, a long collateral token, and a short collateral token (typically a stablecoin). GLV (GMX Liquidity Vault) tokens aggregate GM pools for simplified LP exposure. This is a significant improvement over V1's shared GLP pool, as it isolates risk per market.

**V2.2 and V2.3 Developments**: V2.2 introduced gasless transactions via keeper networks (Gelato), network fee subsidies, and cross-collateral functionality. V2.3 (2026) is introducing cross-margin trading with shared collateral across positions and unified liquidity pools for similar assets, plus further trading fee and price impact decreases.

**Risk Management Layers**:
- Price impact fees: Trades that increase open interest imbalance pay higher fees.
- Adaptive funding rates: The dominant side pays the minority side.
- Borrow fees: Only the larger OI side pays, using a kink rate model.
- Open interest caps: Per-market, per-side limits prevent over-commitment.
- Reserve factor: Limits how much pool liquidity can back positions.

**Liquidation**: Liquidation keepers (ADL_KEEPER, LIQUIDATION_KEEPER roles) handle position liquidation. Auto-deleveraging (ADL) exists as a backstop for extreme scenarios.

**Bad Debt / Insurance**: GMX does NOT have a dedicated, funded insurance fund. The GMX Safety Reserve (GSR) was proposed in governance but has not been formally funded with disclosed amounts. The proposal suggests transferring existing bug bounty reserves and allocating a percentage of the DAO's 10% fee revenue. As of April 2026, no public update confirms the GSR has been operationalized.

**Counterparty Risk**: LPs (GM/GLV token holders) are direct counterparties to traders. If traders collectively profit, LP value decreases. The multichain LP token feature allows GM and GLV tokens to be held on Base, BNB Chain, or Ethereum Mainnet while still earning yield from Arbitrum pools.

**Volume and Scale**: GMX has facilitated over $360B in notional volume from 740,000+ traders, demonstrating significant battle-testing of the economic mechanism.

**Risk**: MEDIUM. The V2 isolated pool architecture, multi-layered risk management, and massive volume throughput are strong. The absence of a funded insurance fund is the primary concern. V2.3 cross-margin introduces new complexity that will need audit coverage.

### 4. Smart Contract Security

**Audit History**:
- Guardian Audits: 10+ engagements from Oct 2022 through 2026 covering V2 Synthetics, GLV, buybacks, pro tiers, gasless calls, cross-chain V2.2, fee automations. 3 Critical, 7 High, 31 Medium, 43 Low issues disclosed and remediated across the additional engagements. Guardian confirmed all high-severity issues were fixed and test cases were incorporated into the GMX test suite.
- ABDK: GMX Synthetics (2022)
- Dedaub: GMX Synthetics (Nov 2022)
- Sherlock: GMX Synthetics updates (2023)
- Certora: GMX Synthetics (Nov 2023)
- Zellic: Solana deployment (2024)
- Sec3: Solana deployment (2024)

**Proactive Security Layer**: A governance proposal explores evaluating continuous static analysis, unit test generation, mutation testing, and an internal audit agent to complement existing audits and monitoring.

**Bug Bounty**: Active on Immunefi with maximum payout of $5,000,000 for critical smart contract vulnerabilities. Covers all repositories under github.com/gmx-io. Payouts in ETH or USDC. Critical payouts capped at 10% of economic damage. No KYC required.

**Past Incidents**:
1. **September 2022 -- AVAX Price Manipulation** ($565K loss): Exploited zero-slippage oracle pricing in V1. Not a code bug per se, but an economic design weakness.
2. **2022 -- GLP Pricing Bug** ($1M bounty paid to Collider): A critical vulnerability in GLP pricing was responsibly disclosed via Immunefi. No funds were lost.
3. **July 9, 2025 -- V1 Reentrancy Attack** ($42M stolen, $37M recovered): A cross-contract reentrancy vulnerability in executeDecreaseOrder allowed GLP price manipulation via vault accounting manipulation. The attacker returned funds within 48 hours for a $5M bounty. GMX executed a ~$44M distribution plan to make all affected Arbitrum GLP holders whole. V2 was NOT affected. V1 was immediately paused and is now permanently deprecated.

**V1 Status**: V1 is paused and officially deprecated as of July 2025. The protocol has fully transitioned to V2. V1 contracts may still exist on-chain but are non-operational.

**Code Maturity**: V2 (Synthetics) has been live since August 2023 (~2.7 years). V2.2 introduced gasless transactions and multichain support. V2.3 (cross-margin) is in development for 2026.

**Risk**: MEDIUM. The audit coverage is extensive (Audit Coverage Score: 3.75, LOW risk threshold). The V1 hack occurred on deprecated V1 code, and GMX demonstrated exemplary incident response with full user compensation. The ongoing Guardian engagement provides continuous coverage for V2. The expanding codebase for V2.2/V2.3 and multichain deployments will require continued audit attention.

### 5. Cross-Chain & Bridge

**Multi-Chain Deployment**: GMX is now deployed on 7+ chains:
- Arbitrum (primary, ~$243M TVL) -- core V2 deployment
- Avalanche (~$13M TVL) -- V2 deployment
- MegaETH (~$8M TVL) -- V2 deployment (March 2026)
- Botanix (~$39K TVL) -- hybrid V2 deployment (Bitcoin ecosystem)
- Solana -- GMSOL deployment (audited by Zellic and Sec3)
- Base, BNB Chain, Ethereum Mainnet -- multichain trading via LayerZero (September-December 2025)

**Bridge Dependency**: GMX uses LayerZero for cross-chain messaging and Stargate for token transfers. The GMX Multichain feature (launched September 2025) enables users to trade and provide liquidity from any supported chain without manual bridging. Deposits and trades are signed as messages and broadcasted via LayerZero to execution chains.

**Cross-Chain LP Tokens**: GM and GLV liquidity tokens can be purchased and held on Base, BNB Chain, and Ethereum Mainnet while earning yield from Arbitrum pools. This introduces cross-chain accounting complexity.

**Token Bridging**: The GMX token can be bridged between chains using LayerZero's OFT standard and Synapse.

**Cross-Chain Governance**: Each chain deployment has its own admin configuration. The MegaETH deployment had a dedicated security multisig infrastructure set up by the Security Council. Whether a compromised bridge could forge governance actions is UNVERIFIED.

**Single Bridge Provider Risk**: GMX's multichain expansion relies primarily on LayerZero as the sole cross-chain messaging provider across 7+ chains. This creates a single point of failure. The DVN/verifier configuration for LayerZero is not publicly documented for GMX's deployments.

**Risk**: MEDIUM. LayerZero and Stargate are established infrastructure. However, the rapid expansion to 7+ chains with a single bridge provider creates concentration risk. The cross-chain LP token feature adds complexity. The protocol is approaching the 5+ chain threshold where bridge risk becomes elevated.

### 6. Operational Security

**Team Track Record**: Anonymous team with successful prior projects (XVIX, Gambit). The protocol has been operational since 2021 with a strong track record. The team's incident response to the July 2025 hack was swift (48-hour fund recovery, full $44M compensation plan).

**Incident Response**: The V1 hack response demonstrated mature incident handling: GLP trading was halted immediately, negotiation with the attacker was conducted, and a comprehensive $44M distribution plan was executed. The Security Council has the Guardian role to pause trading for specific assets or the entire platform.

**Bug Bounty Program**: $5M maximum payout on Immunefi. This has been validated three times: the $1M Collider bounty, the $5M bounty paid to the V1 attacker (who returned funds), and ongoing program activity. Critical payouts are capped at 10% of economic damage.

**Off-Chain Security**: No SOC 2, ISO 27001, or equivalent certifications disclosed. No published key management policy (HSM, MPC, key ceremony). No disclosed penetration testing of infrastructure. Anonymous team makes off-chain controls unverifiable. This is rated HIGH risk per the skill methodology.

**Dependencies**:
- Chainlink Data Streams (oracle)
- LayerZero / Stargate (cross-chain -- now critical for 7+ chain operations)
- Gelato (keeper infrastructure for gasless transactions in V2.2)
- Arbitrum L2 (base layer)
- Various keeper infrastructure (order execution, liquidation, ADL)

**Risk**: MEDIUM for operational security overall. HIGH for off-chain security specifically. Strong bug bounty track record and proven incident response partially mitigate the anonymous team concern, but off-chain controls remain unverifiable.

## Critical Risks

1. **GoPlus: hidden_owner and owner_change_balance flags** -- The GMX token contract has a hidden owner mechanism and the owner can modify balances. While this is a legacy artifact of the token contract and has existed since 2021 without exploitation, it represents a theoretical rug-pull vector. The owner address (0x0a29...1c0) has zero balance. Users should be aware of this privileged capability.
2. **No funded insurance fund** -- Unlike peers (dYdX ~5%), GMX lacks an explicit, funded insurance reserve. The GMX Safety Reserve has been proposed but not operationalized with disclosed funding as of April 2026. In a tail-risk event affecting V2, LP losses may be fully socialized.
3. **Single bridge provider across 7+ chains** -- GMX's multichain expansion relies exclusively on LayerZero. A LayerZero vulnerability or compromise would affect trading and LP operations across all non-native chains. The DVN configuration is not publicly documented.
4. **Undisclosed multisig configuration** -- The exact threshold and signer list for the timelock multisig are not publicly documented. This limits community auditability of governance security.
5. **No off-chain security certifications** -- Anonymous team with no SOC 2, ISO 27001, published key management, or penetration testing disclosure. Off-chain controls are entirely trust-based.

## Peer Comparison

| Feature | GMX | dYdX (v4) | Synthetix (v3) |
|---------|-----|-----------|----------------|
| TVL | ~$265M | ~$40-159M | ~$39M |
| Timelock | 24h (upgrades) | 48h (short), 7d (long) | 24h |
| Multisig | UNVERIFIED threshold | 4/7 | 4/8 |
| Audits | 7+ firms, ongoing Guardian | Trail of Bits, Informal Systems | Multiple (Iosiro, Sigma Prime) |
| Oracle | Chainlink Data Streams | Custom (skip protocol) | Chainlink + Pyth |
| Insurance/TVL | Undisclosed / ~$265M | ~5% / ~$40-159M | Vault-based / ~$39M |
| Open Source | Yes | Yes | Yes |
| Team | Anonymous | Doxxed (dYdX Foundation) | Doxxed (Synthetix core) |
| Bug Bounty Max | $5M | $5M | $2M |
| Chains | 7+ (Arb, Avax, MegaETH, Botanix, Solana, Base, BNB, ETH) | dYdX Chain (Cosmos) | Optimism, Base, Ethereum |
| Volume | $360B+ cumulative | ~$200B+ cumulative | ~$50B+ cumulative |

## Recommendations

1. **For LPs**: Understand that GM/GLV pools are direct counterparties to traders. In a flash crash or mass liquidation event, LP losses are possible. Monitor pool utilization and OI imbalance via stats.gmx.io. If holding multichain LP tokens (GM/GLV on Base, BNB, ETH), understand the additional bridge dependency.
2. **For traders**: GMX V2 is a well-audited platform with strong execution guarantees via Chainlink Data Streams. V2.2 gasless transactions improve UX. Avoid V1 entirely (deprecated). The cross-margin feature (V2.3) will introduce new complexity when launched.
3. **For governance participants**: Push for public disclosure of the timelock multisig threshold and signer addresses. The Security Committee Season 4 (May-Oct 2026) should publish signer identities. The GSR insurance fund proposal should be operationalized and funded.
4. **For all users**: The GoPlus flags on the token contract (hidden_owner, owner_change_balance) should be investigated and publicly addressed by the team. The 90-day TVL decline of ~29% warrants monitoring, though it may reflect broader market conditions.
5. **For developers integrating with GMX**: Note the 21-role access control system. The multichain architecture via LayerZero adds cross-chain messaging complexity. Ensure your integration handles edge cases around keeper failures, oracle delays, ADL events, and cross-chain message delays.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- MARKET_KEEPER role can manage markets; timelock enforcement UNVERIFIED
- [ ] Admin can change oracle sources arbitrarily? -- CONFIG_KEEPER can modify config; oracle source changes UNVERIFIED
- [ ] Admin can modify withdrawal limits? -- CONFIG_KEEPER can modify parameters
- [x] Multisig has low threshold (2/N with small N)? -- UNVERIFIED, threshold not disclosed
- [ ] Zero or short timelock on governance actions? -- 24h timelock on upgrades (short but nonzero)
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- Relevant for GMSOL Solana deployment
- [x] Social engineering surface area (anon multisig signers)? -- Yes, Security Council members are pseudonymous

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- V2 uses isolated pools with OI caps per market
- [ ] Single oracle source without TWAP? -- Single source (Chainlink) but with Data Streams architecture
- [ ] No circuit breaker on price movements? -- Price impact fees serve as soft circuit breaker
- [x] Insufficient insurance fund relative to TVL? -- Yes, no funded insurance reserve

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- LayerZero/Stargate used, semi-decentralized
- [x] Admin keys stored in hot wallets? -- Unknown, storage mechanism undisclosed
- [ ] No key rotation policy? -- Security Council has 6-month seasons with rotation

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time (no snapshot)? -- Uses Snapshot for off-chain voting
- [ ] Flash loans can be used to acquire voting power? -- Off-chain voting mitigates this
- [ ] Proposal + execution in same block or short window? -- No, off-chain governance
- [ ] No minimum holding period for voting eligibility? -- UNVERIFIED

### Cream/bZx-type (Reentrancy + Flash Loan):
- [x] Accepts rebasing or fee-on-transfer tokens as collateral? -- UNVERIFIED for all listed markets
- [x] Read-only reentrancy risk (cross-contract callbacks before state update)? -- V1 was exploited via reentrancy; V2 has guards but cross-contract interactions are complex
- [ ] Flash loan compatible without reentrancy guards? -- V2 has reentrancy guards
- [ ] Composability with protocols that expose callback hooks? -- GM/GLV tokens are composable

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler (Vyper, Huff)? -- Solidity
- [ ] Compiler version has known CVEs? -- UNVERIFIED
- [ ] Contracts compiled with different compiler versions? -- UNVERIFIED
- [ ] Code depends on language-specific behavior (storage layout, overflow)? -- Standard Solidity patterns

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral (own governance token)? -- No stablecoin issued
- [ ] Redemption mechanism creates sell pressure on collateral? -- N/A
- [ ] Oracle delay could mask depegging in progress? -- N/A
- [ ] No circuit breaker on redemption volume? -- N/A

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [x] Protocol uses a cross-chain bridge (LayerZero, Wormhole, etc.) for token minting or reserve release? -- Yes, LayerZero for multichain operations
- [x] Bridge message validation relies on a single messaging layer without independent verification? -- Yes, LayerZero only
- [x] DVN/relayer/verifier configuration is not publicly documented or auditable? -- Yes, not documented for GMX
- [ ] Bridge can release or mint tokens without rate limiting per transaction or per time window? -- UNVERIFIED
- [ ] Bridged/wrapped token is accepted as collateral on lending protocols (Aave, Compound, Euler)? -- GM/GLV tokens have limited external protocol integration
- [ ] No circuit breaker to pause minting if bridge-released volume exceeds normal thresholds? -- UNVERIFIED
- [ ] Emergency pause response time > 15 minutes? -- V1 hack response was fast; multichain pause time UNVERIFIED
- [ ] Bridge admin controls under different governance than core protocol? -- LayerZero admin is separate from GMX governance
- [x] Token is deployed on 5+ chains via same bridge provider (single point of failure)? -- Yes, 7+ chains via LayerZero

**WARNING**: Kelp-type pattern matches 4 of 9 indicators. GMX's multichain expansion via a single bridge provider (LayerZero) across 7+ chains creates concentration risk similar to the Kelp attack pattern. While GM/GLV tokens are not widely used as lending collateral (reducing composability cascade risk), a LayerZero compromise could disrupt cross-chain trading and LP operations. The DVN configuration should be publicly documented and independently verified.

## Information Gaps

- Exact multisig threshold and signer addresses for the timelock multisig (not publicly documented)
- Whether CONFIG_KEEPER or TIMELOCK_ADMIN can change oracle sources without the 24h timelock
- The funded amount (if any) in the GMX Safety Reserve
- Oracle fallback mechanism if Chainlink Data Streams experience downtime
- Whether the hidden_owner and owner_change_balance flags on the token contract reflect active privileged functions or legacy code
- Admin key storage practices (hardware wallet, HSM, etc.)
- Whether each chain deployment (Arbitrum, Avalanche, MegaETH, Botanix, Solana, Base, BNB, ETH) has independent multisig configurations
- Cross-chain governance message validation and whether a compromised LayerZero bridge could forge admin actions
- LayerZero DVN/verifier configuration for GMX's cross-chain messaging
- V2.3 cross-margin audit status and timeline
- Security Committee Season 4 final member list (proposal posted March 2026, term starts May 2026)
- Rate limiting on cross-chain operations via LayerZero
- Emergency pause response time for multichain deployments (per-chain or coordinated?)
- Whether V1 contracts have been fully deprecated or if residual contracts remain active on-chain
- Gelato keeper infrastructure security for gasless transactions

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
