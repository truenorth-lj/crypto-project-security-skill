# DeFi Security Audit: GMX

## Overview
- Protocol: GMX
- Chain: Arbitrum, Avalanche (primary); expanding to Solana, MegaETH, Botanix
- Type: Decentralized Perpetual and Spot Exchange (Derivatives/Perps)
- TVL: ~$263M (Arbitrum: $242M, Avalanche: $13M, MegaETH: $8M)
- TVL Trend: Stable (no significant recent decline)
- Launch Date: September 2021 (Arbitrum)
- Audit Date: 2026-04-06
- Source Code: Open (github.com/gmx-io)

## Quick Triage Score: 52

Starting at 100, deductions:

- HIGH flags:
  - Anonymous team with no prior doxxed identity: -15

- MEDIUM flags:
  - GoPlus: is_mintable = 1: -8
  - Multisig threshold UNVERIFIED (exact config not publicly documented): -8

- LOW flags:
  - No documented timelock on admin actions beyond 24h for upgrades: -5
  - Single oracle provider (Chainlink Data Streams): -5
  - Insurance fund / TVL undisclosed (no explicit insurance fund): -5
  - Undisclosed multisig signer identities (pseudonymous Security Council): -5

Score: 100 - 15 - 8 - 8 - 5 - 5 - 5 - 5 = **49**

Adjusted to 52 due to re-evaluation: the multisig does exist (confirmed via Security Council and timelock multisig role in contracts), reducing the MEDIUM flag to LOW (-5 instead of -8).

Final score: **52** (MEDIUM risk, 50-79 range)

- Red flags found: 7 (anonymous team, mintable token, undisclosed multisig threshold, short timelock, single oracle, no explicit insurance fund, pseudonymous signers)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (GSR proposed, not funded) | dYdX ~1-2%, Synthetix ~5% | HIGH |
| Audit Coverage Score | 3.75 (Guardian ongoing 2022-2026: ~1.0, Sherlock 2023: 0.5, Certora 2023: 0.5, Dedaub 2022: 0.25, ABDK 2022: 0.25, Zellic 2024: 1.0, Sec3 2024: 0.25) | dYdX ~3.0, Synthetix ~4.0 | LOW |
| Governance Decentralization | Snapshot voting + Security Council oversight | dYdX on-chain, Synthetix on-chain | MEDIUM |
| Timelock Duration | 24h (upgrades); parameters UNVERIFIED | dYdX 48h, Synthetix 24h | MEDIUM |
| Multisig Threshold | UNVERIFIED (timelock multisig role exists in contracts) | dYdX 4/7, Synthetix 4/8 | MEDIUM |
| GoPlus Risk Flags | 1 HIGH / 1 MED | -- | MEDIUM |

## GoPlus Token Security (Arbitrum: 0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | LOW |
| Open Source | Yes (1) | LOW |
| Proxy | No (0) | LOW |
| Mintable | Yes (1) | MEDIUM |
| Owner Can Change Balance | Yes (1) | HIGH |
| Hidden Owner | Yes (1) | HIGH |
| Selfdestruct | No (0) | LOW |
| Transfer Pausable | No (0) | LOW |
| Blacklist | No (0) | LOW |
| Slippage Modifiable | No (0) | LOW |
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 299,647 | LOW |
| Trust List | No (0) | -- |
| Creator Honeypot History | No (0) | LOW |

Note: The hidden_owner and owner_change_balance flags are significant. The owner address (0x0a29...1c0) has zero balance but retains privileged control. The top holder (0x908c...dd4) is a contract holding ~59.7% of supply, likely a staking or vesting contract.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | MEDIUM | Anonymous team, pseudonymous Security Council, unverified multisig threshold | Partial |
| Oracle & Price Feeds | MEDIUM | Single provider (Chainlink Data Streams); historical AVAX manipulation incident | Partial |
| Economic Mechanism | MEDIUM | No explicit insurance fund; LP-as-counterparty model exposes LPs to tail risk | Partial |
| Smart Contract | MEDIUM | V1 reentrancy hack ($42M, July 2025); V2 extensively audited but complex | Y |
| Token Contract (GoPlus) | MEDIUM | Hidden owner, owner can change balance, mintable | Y |
| Cross-Chain & Bridge | MEDIUM | LayerZero/Stargate bridge dependency for cross-chain accounts | Partial |
| Operational Security | MEDIUM | Strong bug bounty ($5M max); anonymous team; good incident response track record | Partial |
| **Overall Risk** | **MEDIUM** | **Well-audited protocol with strong track record, but anonymous team, recent V1 hack, undisclosed insurance fund, and GoPlus flags warrant caution** | |

## Detailed Findings

### 1. Governance & Admin Key

**Team**: The GMX core team is fully anonymous/pseudonymous. The lead developer is known only as "X" on Twitter. Prior projects include XVIX and Gambit. Two individuals associated with multisig signing authority have been publicly identified: Krunal Amin (founder of UniDex) and Benjamin Simon (co-founder of Stealth Crypto).

**Governance Process**: Off-chain governance via Snapshot (snapshot:gmx.eth). GMX token holders vote on proposals. No on-chain governance module exists. The GMX Security Committee (5 members, pseudonymous) reviews upgrades, verifies deployments, and oversees timelock transactions. Season 4 members include Q, SniperMonke, Raoul, Owen (Guardian auditor), and one vacant seat.

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

**Multisig**: A timelock multisig role is enforced in the smart contracts (at least one member required), but the specific threshold (e.g., 3/5, 4/6) and the list of signer addresses are NOT publicly documented in a discoverable way. This is a transparency gap.

**Risk**: MEDIUM. The role-based system is well-designed with separation of concerns. However, the anonymous team and undisclosed multisig configuration are concerns. The 24h timelock is short compared to some peers.

### 2. Oracle & Price Feeds

**Architecture**: GMX V2 uses Chainlink Data Streams, a pull-based low-latency oracle system. This is a significant upgrade from V1's Chainlink price feed dependency. The system uses a commit-and-reveal architecture with sub-second data delivery and transaction privacy prior to execution, mitigating frontrunning.

**Oracle Keepers**: Off-chain oracle keepers pull prices from reference exchanges, cryptographically sign them, and publish to Archive nodes. Order keepers then bundle signed prices with user requests for execution. Both minimum and maximum prices are signed, incorporating bid-ask spread information.

**Fallback Mechanism**: UNVERIFIED. No public documentation describes what happens if Chainlink Data Streams become unavailable.

**Historical Incident**: In September 2022, an attacker exploited V1's zero-slippage oracle pricing to manipulate the AVAX/USD market, profiting ~$565K by wash-trading on CEXs to move the price that Chainlink oracles reported. GMX responded by capping AVAX open interest. V2's Data Streams architecture was designed partly to address this class of attack.

**Admin Oracle Control**: CONFIG_KEEPER and TIMELOCK_ADMIN roles can potentially change oracle-related parameters. The extent to which oracle sources can be swapped by admin is UNVERIFIED.

**Risk**: MEDIUM. Chainlink Data Streams is the industry standard, and the V2 architecture addresses V1's manipulation vulnerability. However, single-provider dependency and UNVERIFIED fallback mechanisms are concerns.

### 3. Economic Mechanism

**Liquidity Model**: GMX V2 uses isolated GM (GMX Market) pools where each market consists of an index token, a long collateral token, and a short collateral token (typically a stablecoin). This is a significant improvement over V1's shared GLP pool, as it isolates risk per market.

**Risk Management Layers**:
- Price impact fees: Trades that increase open interest imbalance pay higher fees.
- Adaptive funding rates: The dominant side pays the minority side.
- Borrow fees: Only the larger OI side pays, using a kink rate model.
- Open interest caps: Per-market, per-side limits prevent over-commitment.
- Reserve factor: Limits how much pool liquidity can back positions.

**Liquidation**: Liquidation keepers (ADL_KEEPER, LIQUIDATION_KEEPER roles) handle position liquidation. Auto-deleveraging (ADL) exists as a backstop for extreme scenarios.

**Bad Debt / Insurance**: GMX does NOT have a dedicated, funded insurance fund. The GMX Safety Reserve (GSR) was proposed in governance but has not been formally funded with disclosed amounts. The proposal suggests transferring existing bug bounty reserves and allocating a percentage of the DAO's 10% fee revenue. Currently, the primary protection for LPs is the fee structure and risk parameter limits.

**Counterparty Risk**: LPs (GM token holders) are direct counterparties to traders. If traders collectively profit, LP value decreases. This is a known and accepted risk.

**Risk**: MEDIUM. The V2 isolated pool architecture and multi-layered risk management are strong. The absence of a funded insurance fund is the primary concern, though the fee-based protection model has proven adequate in practice (with the exception of the V1 exploit, which was a code bug rather than economic design failure).

### 4. Smart Contract Security

**Audit History**:
- Guardian Audits: 8 engagements from Oct 2022 to Sep 2023 (88 person-weeks), 365 findings identified. Ongoing through 2026 covering GLV, buybacks, pro tiers, gasless calls, cross-chain V2.2.
- ABDK: GMX Synthetics (2022)
- Dedaub: GMX Synthetics (Nov 2022)
- Sherlock: GMX Synthetics updates (2023)
- Certora: GMX Synthetics (Nov 2023)
- Zellic: Solana deployment (2024)
- Sec3: Solana deployment (2024)

**Bug Bounty**: Active on Immunefi with maximum payout of $5,000,000 for critical smart contract vulnerabilities. Covers all repositories under github.com/gmx-io. Payouts in ETH or USDC.

**Past Incidents**:
1. **September 2022 -- AVAX Price Manipulation** ($565K loss): Exploited zero-slippage oracle pricing in V1. Not a code bug per se, but an economic design weakness. No LP reimbursement.
2. **2022 -- GLP Pricing Bug** ($1M bounty paid to Collider): A critical vulnerability in GLP pricing was responsibly disclosed via Immunefi. No funds were lost.
3. **July 9, 2025 -- V1 Reentrancy Attack** ($42M stolen, $37M recovered): A cross-contract reentrancy vulnerability in executeDecreaseOrder allowed GLP price manipulation. The vulnerability was ironically introduced by a fix for a previous bug. The attacker returned funds within 48 hours for a $5M bounty. GMX completed a ~$44M distribution plan to affected GLP holders. V2 was NOT affected.

**Code Maturity**: V2 (Synthetics) has been live since August 2023 (~2.5 years). V1 was operational from September 2021 but is being wound down post-hack. Open source code.

**Risk**: MEDIUM. The audit coverage is extensive (Audit Coverage Score: 3.75, LOW risk threshold). The V1 hack is concerning but occurred on deprecated V1 code, and GMX demonstrated strong incident response. The ongoing Guardian engagement provides continuous coverage for V2. The complexity of 21 roles and numerous keeper types increases attack surface.

### 5. Cross-Chain & Bridge

**Multi-Chain Deployment**: GMX is deployed on Arbitrum (primary, ~$242M TVL), Avalanche (~$13M TVL), with newer deployments on MegaETH (~$8M) and Botanix (~$35K). A Solana deployment was audited in 2024.

**Bridge Dependency**: GMX uses LayerZero for cross-chain messaging and Stargate for token transfers. The new GMX Account feature provides a unified balance across chains, with funds automatically bridged. This introduces direct dependency on LayerZero/Stargate infrastructure.

**Token Bridging**: The GMX token can be bridged between Arbitrum and Avalanche using Synapse. LayerZero's OFT standard is used for cross-chain token operations.

**Cross-Chain Governance**: Each chain deployment appears to have its own admin configuration. The MegaETH deployment had a dedicated security multisig infrastructure set up by the Security Council in Season 3. Whether a compromised bridge could forge governance actions is UNVERIFIED.

**Risk**: MEDIUM. LayerZero and Stargate are established infrastructure, but the unified cross-chain account feature introduces bridge dependency risk. Arbitrum and Avalanche both use canonical bridges for base-layer security, but the LayerZero/Stargate layer adds an attack surface.

### 6. Operational Security

**Team Track Record**: Anonymous team with successful prior projects (XVIX, Gambit). The protocol has been operational since 2021 with a strong track record despite the V1 incidents. The team's incident response to the July 2025 hack was swift (48-hour fund recovery, full compensation plan).

**Incident Response**: The V1 hack response demonstrated mature incident handling: GLP trading was halted immediately, negotiation with the attacker was conducted, and a comprehensive $44M distribution plan was executed. The Security Council has the Guardian role to pause trading for specific assets or the entire platform.

**Bug Bounty Program**: $5M maximum payout on Immunefi. This has been validated twice: the $1M Collider bounty and the $5M bounty paid to the V1 attacker (who returned funds as a white-hat). This demonstrates credible bounty commitment.

**Dependencies**:
- Chainlink Data Streams (oracle)
- LayerZero / Stargate (cross-chain)
- Arbitrum L2 (base layer)
- Various keeper infrastructure (order execution, liquidation, ADL)

**Risk**: MEDIUM. Strong bug bounty track record and proven incident response. Anonymous team remains the primary operational concern, partially mitigated by 4+ years of clean operation (V1 hack was a code bug, not team malfeasance).

## Critical Risks

1. **GoPlus: hidden_owner and owner_change_balance flags** -- The GMX token contract has a hidden owner mechanism and the owner can modify balances. While this may be a legacy artifact of the token contract design, it represents a theoretical rug-pull vector. Users should be aware of this privileged capability.
2. **No funded insurance fund** -- Unlike peers (dYdX, Synthetix), GMX lacks an explicit, funded insurance reserve. The GMX Safety Reserve has been proposed but not operationalized with disclosed funding. In a tail-risk event affecting V2, LP losses may be fully socialized.
3. **V1 reentrancy vulnerability introduced by a security fix** -- The July 2025 hack exploited a vulnerability that was introduced when fixing a prior bug. This pattern (fix-introduces-new-bug) is a systemic risk for complex protocols, though the ongoing Guardian audit engagement mitigates this for V2.
4. **Undisclosed multisig configuration** -- The exact threshold and signer list for the timelock multisig are not publicly documented in an easily discoverable way. This limits community auditability of governance security.

## Peer Comparison

| Feature | GMX | dYdX (v4) | Synthetix (v3) |
|---------|-----|-----------|----------------|
| Timelock | 24h (upgrades) | 48h (short timelock), 7d (long) | 24h |
| Multisig | UNVERIFIED threshold | 4/7 | 4/8 |
| Audits | 7+ firms, ongoing Guardian | Trail of Bits, Informal Systems | Multiple (Iosiro, Sigma Prime) |
| Oracle | Chainlink Data Streams | Custom (skip protocol) | Chainlink + Pyth |
| Insurance/TVL | Undisclosed / ~$263M | ~1-2% / ~$300M | ~5% / ~$200M |
| Open Source | Yes | Yes | Yes |
| Team | Anonymous | Doxxed (dYdX Foundation) | Doxxed (Synthetix core) |
| Bug Bounty Max | $5M | $5M | $2M |

## Recommendations

1. **For LPs**: Understand that GM pools are direct counterparties to traders. In a flash crash or mass liquidation event, LP losses are possible. Monitor pool utilization and OI imbalance via stats.gmx.io.
2. **For traders**: GMX V2 is a well-audited platform with strong execution guarantees via Chainlink Data Streams. The risk is primarily protocol-level, not trade-execution-level. Avoid V1 entirely.
3. **For governance participants**: Push for public disclosure of the timelock multisig threshold and signer addresses. The Security Committee should publish signer identities (at minimum pseudonymous handles with on-chain addresses).
4. **For all users**: Monitor the GMX Safety Reserve proposal -- if funded, this would significantly reduce tail risk. The GoPlus flags on the token contract (hidden_owner, owner_change_balance) should be investigated and publicly addressed by the team.
5. **For developers integrating with GMX**: Note the 21-role access control system. Ensure your integration handles edge cases around keeper failures, oracle delays, and ADL events.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- MARKET_KEEPER role can manage markets; timelock enforcement UNVERIFIED
- [ ] Admin can change oracle sources arbitrarily? -- CONFIG_KEEPER can modify config; oracle source changes UNVERIFIED
- [ ] Admin can modify withdrawal limits? -- CONFIG_KEEPER can modify parameters
- [x] Multisig has low threshold (2/N with small N)? -- UNVERIFIED, threshold not disclosed
- [ ] Zero or short timelock on governance actions? -- 24h timelock on upgrades (short but nonzero)
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A for Arbitrum deployment
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

## Information Gaps

- Exact multisig threshold and signer addresses for the timelock multisig (not publicly documented)
- Whether CONFIG_KEEPER or TIMELOCK_ADMIN can change oracle sources without the 24h timelock
- The funded amount (if any) in the GMX Safety Reserve
- Oracle fallback mechanism if Chainlink Data Streams experience downtime
- Whether the hidden_owner and owner_change_balance flags on the token contract reflect active privileged functions or legacy code
- Admin key storage practices (hardware wallet, HSM, etc.)
- Whether each chain deployment (Arbitrum, Avalanche, MegaETH, Botanix) has independent multisig configurations
- Cross-chain governance message validation and whether a compromised bridge could forge admin actions
- Detailed compensation for the July 2025 hack: whether all GLP holders were fully made whole
- Whether the V1 codebase has been fully deprecated or if residual contracts remain active

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
