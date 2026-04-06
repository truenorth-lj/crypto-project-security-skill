# DeFi Security Audit: Lybra Finance

## Overview
- Protocol: Lybra Finance (eUSD / peUSD / LBR)
- Chain: Ethereum
- Type: CDP / LSD-backed Stablecoin
- TVL: ~$337K (combined V1 + V2; V2 alone ~$44K)
- TVL Trend: +0.9% / +1.1% / -39.0% (7d / 30d / 90d)
- Peak TVL: $391M (July 2023) -- 99.9% decline from peak
- Launch Date: April 2023 (V1); August 2023 (V2)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: LybraFinance/LybraV2)
- Website Status: Dead (docs.lybra.finance DNS not resolving)

## Quick Triage Score: 12/100

Starting at 100, the following deductions apply:

CRITICAL flags:
- (-25) GoPlus: hidden_owner = 1 (V1 LBR token at 0xF118...)
- (-25) GoPlus: owner_change_balance = 1 (V1 LBR token at 0xF118...)

HIGH flags:
- (-15) Zero audits listed on DeFiLlama (neither V1 nor V2 entries list audits)
- (-15) Anonymous team with no prior track record

MEDIUM flags:
- (-8) GoPlus: is_mintable = 1 (both V1 and V2 LBR tokens)
- (-8) TVL dropped >30% in 90 days (-39.0%)

LOW flags:
- (-5) No documented timelock verification possible (docs site dead)
- (-5) No active bug bounty program verifiable (Immunefi listing appears inactive)
- (-5) Insurance fund / TVL ratio undisclosed
- (-5) Undisclosed multisig signer identities
- (-5) DAO governance effectively defunct (near-zero TVL, dead website)

Raw score: 100 - 25 - 25 - 15 - 15 - 8 - 8 - 5 - 5 - 5 - 5 - 5 = -21, floored to 0.

**Adjusted note**: The V2 LBR token (0xed11...) does NOT have hidden_owner but DOES have owner_change_balance = 1. Re-scoring with V2 token as the canonical governance token:

- (-25) GoPlus: owner_change_balance = 1 (V2 LBR token)
- (-15) Zero audits listed on DeFiLlama
- (-15) Anonymous team with no prior track record
- (-8) GoPlus: is_mintable = 1
- (-8) TVL dropped >30% in 90 days
- (-5) No documented timelock verification (docs dead)
- (-5) No active bug bounty verifiable
- (-5) Insurance fund / TVL undisclosed
- (-5) Undisclosed multisig signer identities
- (-5) DAO governance effectively defunct

Score: 100 - 25 - 15 - 15 - 8 - 8 - 5 - 5 - 5 - 5 - 5 = 4, floored to 4.

**Final Quick Triage Score: 4/100 (CRITICAL)**

Red flags found: 1 CRITICAL, 2 HIGH, 2 MEDIUM, 5 LOW

Score meaning: 0-19 = CRITICAL risk. The protocol is effectively abandoned with near-zero TVL, a dead website, anonymous team, owner-controllable token balances, and no verifiable security infrastructure.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | Liquity: N/A (immutable), Maker: ~5% | HIGH |
| Audit Coverage Score | 1.0 | Liquity: 3.0+, Maker: 4.0+ | HIGH |
| Governance Decentralization | Multisig + DAO (UNVERIFIED) | Liquity: immutable, Maker: full DAO | HIGH |
| Timelock Duration | Documented but UNVERIFIED (docs dead) | Liquity: N/A, Maker: 48h | HIGH |
| Multisig Threshold | Unknown (0x8190...6406 listed) | Liquity: N/A, Maker: varies | HIGH |
| GoPlus Risk Flags | 1 HIGH (V2) / 1 MED (V2) | -- | HIGH |

**Audit Coverage Score Calculation:**
- ConsenSys Diligence (Aug 2023): >2yr old = 0.25
- Code4rena contest (Jun 2023): >2yr old = 0.25
- QuillAudits (date unclear, ~2023): >2yr old = 0.25
- SourceHat (date unclear, ~2023): >2yr old = 0.25
- Total: 1.0 (HIGH risk threshold: < 1.5)

## GoPlus Token Security

### LBR V1 (0xF1182229B71E79E504b1d2bF076C15a277311e05) -- Legacy Token

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | No | -- |
| Mintable | Yes | MEDIUM |
| Owner Can Change Balance | Yes | CRITICAL |
| Hidden Owner | Yes | HIGH |
| Selfdestruct | No | -- |
| Transfer Pausable | No | -- |
| Blacklist | No | -- |
| Slippage Modifiable | No | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 3,279 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No | -- |

Top holder concentration (V1): One contract (0xb361...) holds ~87% of supply. LP liquidity is minimal ($208 on UniswapV2). LP is NOT locked.

### LBR V2 (0xed1167b6Dc64E8a366DB86F2E952A482D0981ebd) -- Current Governance Token

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | No | -- |
| Mintable | Yes | MEDIUM |
| Owner Can Change Balance | Yes | CRITICAL |
| Hidden Owner | No | -- |
| Selfdestruct | No | -- |
| Transfer Pausable | No | -- |
| Blacklist | No | -- |
| Slippage Modifiable | No | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 3,862 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No | -- |

Owner address (V2): 0x078dc81e05ceb1e1743b9b5215b3bc83afd9f8c0. The owner retains the ability to modify token balances and mint new tokens. This is a significant centralization risk, especially given the anonymous team.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | CRITICAL | Deployer DAO role may not be revoked; anonymous team; dead docs prevent verification | N |
| Oracle & Price Feeds | MEDIUM | Chainlink primary oracle; single-source dependency | Partial |
| Economic Mechanism | HIGH | 99.9% TVL collapse; eUSD depeg history; rebase mechanism complexity | Y |
| Smart Contract | HIGH | 8 HIGH findings in Code4rena; broken access control in Configurator; all audits >2yr old | Y |
| Token Contract (GoPlus) | CRITICAL | Owner can change balances; mintable; hidden owner on V1 | Y |
| Cross-Chain & Bridge | MEDIUM | peUSD uses LayerZero OFT for omnichain; bridge dependency | Partial |
| Operational Security | CRITICAL | Anonymous team; dead website; dead docs; protocol appears abandoned | Y |
| **Overall Risk** | **CRITICAL** | **Protocol is effectively abandoned with 99.9% TVL decline, dead infrastructure, anonymous team, and unrevoked admin privileges** | |

## Detailed Findings

### 1. Governance & Admin Key

**Risk: CRITICAL**

Lybra Finance uses a GovernanceTimelock contract with AccessControl-based roles:

- **DAO Role**: Grants near-unlimited power over the system, including setting new LBR miners, minting tokens, and controlling all governance parameters. The ConsenSys Diligence audit explicitly flagged that the deployer address was given the DAO role at deployment, and recommended it be revoked as the system matured. Whether this was done is UNVERIFIED -- the docs site is dead and on-chain verification was not performed.

- **GOV Role**: Admin role that manages all other roles.

- **Multisig**: Listed address 0x81905eae41AF5235EC4d7e9b12e8D51247b26406. Threshold and signer composition are UNVERIFIED. Signers are anonymous.

- **Admin Timelock**: 0x126dc5e04B0e8c8ef6F4602fdA90e39c0A142bde. Duration was documented but cannot be verified (docs DNS dead).

- **LybraConfigurator**: This contract is the admin of all Lybra proxy contracts. The Code4rena audit found that access control modifiers (onlyRole, checkRole) were incorrectly implemented, allowing ANY address to call restricted functions (H-03). This was confirmed by the team but fix verification is not possible without current code review.

- **Governance Voting**: The Code4rena audit found that _voteSucceeded() had inverted logic (H-07) and quorum calculation was incorrect (H-08), effectively breaking the entire governance voting mechanism.

- **Token Migration Controversy**: During the V1-to-V2 migration, ~2M LBR tokens (~13% of circulating supply) were not migrated. The team initially planned to burn these but reversed course after community backlash, proposing a 90-day vesting instead. Only migrated token holders had governance power, disenfranchising non-migrated holders.

### 2. Oracle & Price Feeds

**Risk: MEDIUM**

- **Primary Oracle**: Chainlink price feeds for ETH/USD and stETH/ETH.
- **Single Source**: No documented fallback oracle mechanism. Single-oracle dependency is a known risk, though Chainlink is the industry standard.
- **Heartbeat**: Chainlink pushes updates on a 1-hour heartbeat or >1% price deviation.
- **Admin Override**: The ConsenSys audit noted that oracle configuration changes were not emitting events, making it difficult to monitor for unauthorized changes.
- **No Circuit Breaker**: No documented circuit breaker mechanism for extreme price movements.

### 3. Economic Mechanism

**Risk: HIGH**

**eUSD Stablecoin Mechanism:**
- Users deposit ETH or rebase LSTs (stETH, rETH, WBETH) as collateral.
- Minimum collateral ratio: 150% for rebase vaults, 130% (adjustable) for non-rebase vaults.
- eUSD is "interest-bearing" -- the rebase mechanism distributes staking yield to eUSD holders by selling excess stETH for eUSD and burning shares proportionally.
- The Code4rena audit found a critical vulnerability (H-05) where attackers could create imbalances between _totalSupply and _totalShares via fake income injection, enabling fund theft through rigidRedemption.

**peUSD (Omnichain):**
- 1:1 convertible with eUSD.
- Uses LayerZero OFT standard for cross-chain transfers.
- Locked eUSD serves as flash loan pool for liquidations.
- The Code4rena audit found (H-01) that the executeFlashloan function could be exploited to burn other users' eUSD balances.

**Liquidation:**
- Flash loan-assisted liquidation introduced in V2.
- Liquidation incentives exist but specifics are UNVERIFIED (docs dead).

**Historical TVL Collapse:**
- Peak TVL: $391M (July 2023).
- Crashed 70% in a single day (February 2024), from ~$246M to ~$82M.
- Key Opinion Leaders (KOLs) and anonymous addresses controlling large portions of TVL triggered a sell-off.
- eUSD briefly depegged to $0.97 during the crisis.
- Current TVL: ~$337K -- effectively a dead protocol.

**Insurance/Bad Debt:**
- Lybra Stability Fund exists but size and current status are undisclosed.
- No documented socialized loss mechanism found.
- Insurance Fund / TVL ratio: UNDISCLOSED.

### 4. Smart Contract Security

**Risk: HIGH**

**Audits:**
- Code4rena (June 2023): 8 HIGH, 23 MEDIUM findings. Key issues: broken access control, flash loan exploitation, governance voting logic errors, fund theft via share manipulation.
- ConsenSys Diligence (August 2023): Identified deployer role risk, proxy upgrade concerns, missing event emissions, and recommended revoking DAO role from deployer.
- QuillAudits (~2023): Report available on GitHub.
- SourceHat (~2023): Audit report available.

**All audits are over 2.5 years old.** No evidence of any audit since August 2023.

**Key Unfixed/Unclear Issues:**
- Deployer DAO role revocation: UNVERIFIED.
- Configurator access control fix: Confirmed by team during audit but current state UNVERIFIED.
- Governance voting logic fix: Confirmed but UNVERIFIED in production.
- Flash loan exploitation fix: Confirmed but UNVERIFIED.

**Bug Bounty:**
- Lybra had an Immunefi bug bounty with up to $100K in LBR tokens.
- Payouts were in LBR on a 3-month vesting schedule, reducing their real value.
- Current status: Likely inactive given protocol's near-zero TVL and dead website. UNVERIFIED.

**Battle Testing:**
- Protocol has been live since April 2023 (~3 years).
- No known exploit in the wild, though the TVL collapse was triggered by user behavior / whale sell-off rather than a smart contract exploit.
- Code is open source on GitHub.

### 5. Cross-Chain & Bridge

**Risk: MEDIUM**

- peUSD uses LayerZero's OFT (Omnichain Fungible Token) standard for cross-chain interoperability.
- eUSD locked on Ethereum mainnet serves as backing for peUSD on other chains.
- LayerZero relayer dependency introduces bridge risk -- if LayerZero is compromised, peUSD on remote chains could be affected.
- Cross-chain governance validation: UNVERIFIED (docs dead).
- Given near-zero TVL, the practical cross-chain risk is minimal, but the architectural dependency remains.

### 6. Operational Security

**Risk: CRITICAL**

- **Team**: Fully anonymous. No known prior track record. No doxxed founders or team members.
- **Website**: Dead (lybra.finance returns content but docs.lybra.finance DNS does not resolve).
- **Documentation**: Completely inaccessible. All GitBook docs are offline.
- **Twitter**: @LybraFinanceLSD -- last activity status UNVERIFIED.
- **Incident Response**: No verifiable incident response plan.
- **Emergency Pause**: CR Guardian contract exists (0xB31E...) but capability and current status UNVERIFIED.
- **Protocol Status**: Effectively abandoned. TVL has declined 99.9% from peak. The DeFiLlama listing is marked with deadUrl = true.

## Critical Risks

1. **Protocol appears abandoned**: 99.9% TVL decline, dead documentation, dead website. Users with remaining funds face risk of no support or incident response.
2. **Owner can change token balances**: GoPlus confirms owner_change_balance = 1 on both V1 and V2 LBR tokens. Combined with anonymous team, this is a direct rug-pull vector.
3. **Deployer DAO role may be unrevoked**: The deployer address may still hold the DAO role, granting near-unlimited system control including minting LBR and changing all parameters.
4. **All audits are stale**: Last audit was August 2023, over 2.5 years ago. Any code changes since are completely unaudited.
5. **Governance mechanism was fundamentally broken**: Code4rena found inverted vote logic and incorrect quorum calculation. Fix status is UNVERIFIED.
6. **Token migration disenfranchised holders**: ~13% of LBR holders lost governance rights during the V1-to-V2 migration.

## Peer Comparison

| Feature | Lybra Finance | Liquity (LUSD) | MakerDAO (DAI) |
|---------|--------------|----------------|----------------|
| Timelock | UNVERIFIED (docs dead) | N/A (immutable) | 48h GSM |
| Multisig | Unknown threshold, anon signers | N/A (immutable) | Multiple, doxxed |
| Audits | 4 (all >2yr old) | 3+ (Trail of Bits, etc.) | 10+ (continuous) |
| Oracle | Chainlink (single) | Chainlink + Tellor | Chainlink + Chronicle |
| Insurance/TVL | Undisclosed | Stability Pool (~6%+) | Surplus Buffer (~5%) |
| Open Source | Yes | Yes | Yes |
| Team | Anonymous | Anonymous but established | Doxxed, foundation |
| TVL | $337K | ~$500M+ | ~$8B+ |
| Collateral Ratio | 150% | 110% | 150%+ (varies) |
| Website Status | Dead | Active | Active |

## Recommendations

1. **Do NOT deposit new funds into Lybra Finance.** The protocol shows all hallmarks of an abandoned project: dead docs, dead website, near-zero TVL, and no recent development activity.
2. **Existing users should withdraw immediately.** With anonymous team, unrevoked admin privileges, and owner-controllable token balances, remaining funds are at elevated risk.
3. **Do NOT hold LBR tokens.** The owner can modify balances and mint new tokens. Liquidity is near-zero ($208 on UniswapV2 for V1 token).
4. **If you hold eUSD or peUSD**, verify the peg and redeem for underlying collateral as soon as possible.
5. **Monitor the multisig address** (0x81905eae41AF5235EC4d7e9b12e8D51247b26406) for any unexpected transactions.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- UNVERIFIED but DAO role grants this power
- [x] Admin can change oracle sources arbitrarily? -- Audit noted missing events on oracle changes
- [x] Admin can modify withdrawal limits? -- DAO role grants near-unlimited parameter control
- [x] Multisig has low threshold (2/N with small N)? -- UNKNOWN (threshold unverifiable)
- [ ] Zero or short timelock on governance actions? -- Timelock exists but duration UNVERIFIED
- [ ] Pre-signed transaction risk? -- N/A (Ethereum, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- YES, all signers anonymous

**Match: 4/7 indicators (HIGH risk of Drift-type attack)**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- Primary collateral is stETH (high liquidity)
- [x] Single oracle source without TWAP? -- Chainlink only, no TWAP documented
- [x] No circuit breaker on price movements? -- No documented circuit breaker
- [x] Insufficient insurance fund relative to TVL? -- Undisclosed insurance fund

**Match: 3/4 indicators (HIGH risk of Euler/Mango-type attack)**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- LayerZero relayer for peUSD
- [x] Admin keys stored in hot wallets? -- UNKNOWN (anonymous team, no key management disclosure)
- [x] No key rotation policy? -- No documented key rotation

**Match: 3/3 indicators (HIGH risk of Ronin/Harmony-type attack)**

## Information Gaps

- Whether the deployer DAO role has been revoked from the initial deployer address
- Current multisig threshold and signer composition (all anonymous)
- Timelock duration and configuration (docs dead, unverifiable)
- Whether the 8 HIGH-severity Code4rena findings were properly fixed in production
- Whether the Configurator access control vulnerability (H-03) was patched
- Current status of the Immunefi bug bounty program
- Insurance/Stability Fund size and current balance
- Whether any code changes have been made since the last audit (August 2023)
- Current status of eUSD peg and circulating supply
- Whether the CR Guardian contract has emergency pause authority
- LayerZero configuration for peUSD cross-chain messaging
- Whether the team is still active or has fully abandoned the project
- Key management practices for admin and multisig keys
- Current liquidation parameters and whether they have been modified post-audit

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
