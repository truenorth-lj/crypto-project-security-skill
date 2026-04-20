# DeFi Security Audit: Lighter (Perps DEX)

## Overview
- Protocol: Lighter
- Chain: Ethereum L1 (settlement) + zkLighter L2 (execution), with bridge on Arbitrum
- Type: Perpetual DEX (CLOB model, zk-rollup)
- TVL: ~$507M (bridge TVL per DeFiLlama); ~$695M total value secured (per L2Beat, including USDC + LIT)
- TVL Trend: -0.8% / -12.9% / -52.5% (7d / 30d / 90d)
- Launch Date: January 2025 (private beta); October 1, 2025 (public mainnet)
- Audit Date: 2026-04-20
- Valid Until: 2026-07-19 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Partial (ZK circuits and L1 contracts open-sourced; sequencer and matching engine closed-source; pre-migration circuits never open-sourced)

## Quick Triage Score: 34/100 | Data Confidence: 55/100

**Triage Score Calculation (start at 100, subtract mechanically):**

CRITICAL flags (-25 each):
- None triggered

HIGH flags (-15 each):
- [x] No multisig adequate for security council (L2Beat: security council fails Stage 1 requirements; Lighter Multisig can bypass 21-day timelock to 0 seconds) = -15

MEDIUM flags (-8 each):
- [x] TVL dropped >30% in 90 days (-52.5%) = -8
- [x] No third-party security certification (SOC 2 / ISO 27001 / equivalent) = -8

LOW flags (-5 each):
- [x] No documented timelock on admin actions: Timelock exists (21 days) but can be bypassed to 0 = -5
- [x] No bug bounty program (none found on Immunefi or publicly) = -5
- [x] Single oracle provider (Stork primary; Chainlink/Pyth mentioned but sequencer must be trusted) = -5
- [x] Insurance fund / TVL < 1% or undisclosed (LLP size not precisely disclosed as ratio) = -5
- [x] Undisclosed multisig signer identities = -5
- [x] No published key management policy = -5
- [x] No disclosed penetration testing = -5

100 - 15 - 8 - 8 - 5 - 5 - 5 - 5 - 5 - 5 - 5 = **34/100**

**Triage: 34/100 = HIGH risk**

**Data Confidence Score Calculation (start at 0, add points):**
- [x] +15 Source code is open and verified on block explorer (partial -- L1 contracts verified, circuits open-sourced)
- [x] +15 GoPlus token scan completed
- [x] +10 At least 1 audit report publicly available (7 audits listed)
- [ ] +10 Multisig configuration verified on-chain (3/5 and 3/6 per L2Beat, but not independently verified via Safe API in this audit)
- [ ] +10 Timelock duration verified on-chain (21 days per L2Beat, not independently verified)
- [x] +10 Team identities publicly known (Vladimir Novakovski doxxed, core team from Citadel/Facebook/Quora)
- [ ] +10 Insurance fund size publicly disclosed (LLP exists but ratio to TVL not precisely disclosed)
- [ ] +5 Bug bounty program details publicly listed
- [ ] +5 Governance process documented (minimal governance documentation)
- [x] +5 Oracle provider(s) confirmed (Stork primary, Chainlink/Pyth secondary)
- [ ] +5 Incident response plan published
- [ ] +5 SOC 2 Type II or ISO 27001 certification verified
- [ ] +5 Published key management policy
- [ ] +5 Regular penetration testing disclosed
- [ ] +5 Bridge DVN/verifier configuration publicly documented

**Data Confidence: 55/100 = MEDIUM confidence**

**Red flags found: 10** (timelock bypass, TVL decline, no bug bounty, single oracle trust, no SOC2, no pentest, no key mgmt policy, undisclosed signers, undisclosed insurance ratio, historical sequencer outage)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (LLP ~$498M but unclear net exposure) | Hyperliquid HLP ~$380M; dYdX disclosed | MEDIUM |
| Audit Coverage Score | 5.5 (7 audits, all < 1 year old = 7 x 0.75 avg = 5.25; rounded) | Hyperliquid ~2.0; dYdX ~4.0 | LOW |
| Governance Decentralization | Low (sequencer centralized; multisig can bypass timelock) | Hyperliquid: centralized; dYdX: on-chain gov | HIGH |
| Timelock Duration | 21 days (but bypassable to 0 by 3/6 multisig) | Hyperliquid: none; dYdX: multi-tier | MEDIUM |
| Multisig Threshold | 3/5 (upgrades) + 3/6 (bypass) | Hyperliquid: centralized; dYdX: governance | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 0 MED | -- | LOW |

## GoPlus Token Security (LIT on Ethereum: 0x232ce3bd40fcd6f80f3d55a522d03f25df784ee2)

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
| Holders | 3,250 | -- |
| Trust List | Listed on Coinbase | LOW |
| Creator Honeypot History | 0 (No) | LOW |

**Top Holder Concentration:**
- Top holder (EOA): 25.0% -- significant concentration
- 2nd holder (contract, likely bridge/L2): 20.7%
- Top 5 holders: ~61.1% of supply -- HIGH concentration risk

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | HIGH | 3/6 multisig can bypass 21-day timelock to 0; signers undisclosed; security council fails L2Beat Stage 1 | S/O | Partial |
| Oracle & Price Feeds | MEDIUM | Stork primary oracle; sequencer must be trusted to truthfully report data; external signatures not verified on-chain | S | Partial |
| Economic Mechanism | MEDIUM | LLP insurance fund exists but size/ratio undisclosed; ADL backstop present; Oct 2025 outage caused 5.35% LLP loss | S/H | Partial |
| Smart Contract | LOW | 7 audits by Nethermind + zkSecurity; ZK circuits open-sourced; L1 contracts verified | S | Y |
| Token Contract (GoPlus) | LOW | Clean GoPlus scan; no proxy, no mint, no tax; Coinbase-listed | S | Y |
| Cross-Chain & Bridge | MEDIUM | Bridge on Ethereum + Arbitrum; pre-migration blobs undecodable; desert mode circuits not public; forced exit depends on state reconstruction that is currently blocked | S | Partial |
| Off-Chain Security | HIGH | No SOC 2/ISO 27001; no published key management; no pentest disclosure; sequencer is closed-source single point of failure | O | N |
| Operational Security | HIGH | Oct 2025 multi-hour outage during $19B liquidation event; CEO acknowledged delayed infrastructure upgrade; single centralized sequencer | S/H/O | Y |
| **Overall Risk** | **HIGH** | **Centralized sequencer + bypassable timelock + historical outage during extreme conditions; governance counts 2x = 2 HIGHs alone** | | |

**Overall Risk aggregation**: Governance & Admin = HIGH (counts as 2x = 2 HIGHs). Off-Chain Security = HIGH. Operational Security = HIGH. That is 4 effective HIGHs. **Overall = HIGH.**

## Detailed Findings

### 1. Governance & Admin Key

**Admin Key Surface Area:**
- Lighter operates as an application-specific zk-rollup (zkLighter) with governance controlled by two multisig wallets:
  - **Lighter Multisig 2** (3/5 threshold): Controls upgrades via UpgradeGatekeeper with a 21-day delay
  - **Lighter Multisig** (3/6 threshold): Can reduce the upgrade delay to zero seconds, effectively bypassing the timelock entirely
- The security council does not meet L2Beat Stage 1 requirements, meaning it lacks adequate checks on its emergency powers
- Multisig signer identities are not publicly disclosed

**Timelock Bypass (CRITICAL concern):**
- The 21-day upgrade delay is rendered largely meaningless because the 3/6 "security council" multisig can reduce it to zero at will
- This is not a pause-only bypass -- it enables full contract upgrades without delay
- With only 3 of 6 signers needed and signers undisclosed, this represents a significant governance attack surface
- Comparable to the pattern seen in the Drift Protocol exploit where weak admin controls were the entry vector

**Upgrade Mechanism:**
- Contracts are upgradeable via proxy pattern
- L2Beat assessment: "There is no window for users to exit in case of an unwanted regular upgrade since contracts are instantly upgradable" (when the bypass is used)
- Stage 0 classification on L2Beat -- the lowest maturity level

**Governance Process:**
- No formal on-chain governance process documented
- No DAO structure visible
- LIT token launched December 2025 but governance utility is minimal beyond future plans

**Token Concentration:**
- Top holder controls 25% of supply (EOA)
- Top 5 holders control ~61% of supply
- If governance is introduced, this concentration creates unilateral proposal risk

**Risk Rating: HIGH**

### 2. Oracle & Price Feeds

**Oracle Architecture:**
- Primary oracle: Stork Network (low-latency, pull-based)
- Secondary sources: Chainlink, Pyth referenced in documentation
- Mark price is a composite of: (1) Oracle index price with funding adjustment, (2) Median of CEX mark prices (Binance, OKX), (3) Impact price from Lighter's own order book
- EMA-capped premium of 0.5% prevents large deviations

**Critical Trust Assumption:**
- External oracle signatures are currently NOT verified on-chain
- The sequencer must be trusted to truthfully report oracle data
- This means a compromised or malicious sequencer could feed false price data
- ZK proofs verify that the matching engine executed correctly given the inputs, but they do NOT verify that the inputs (oracle prices) were authentic

**Manipulation Resistance:**
- Multi-source design is theoretically sound (requires compromising 2+ sources)
- 0.5% EMA cap limits rapid manipulation
- However, the sequencer trust assumption undermines these protections -- if the sequencer is compromised, all oracle data is suspect

**Fallback Mechanism:**
- No publicly documented fallback if Stork goes down
- Chainlink/Pyth mentioned but mechanism for failover unclear

**Risk Rating: MEDIUM**

### 3. Economic Mechanism

**Liquidation Mechanism:**
- Multi-tier system: Initial Margin > Maintenance Margin > Close-out Margin
- Partial liquidation via "zero price" IoC orders (innovative -- allows market to absorb liquidations)
- Full liquidation: LLP takes over all positions
- Auto-Deleveraging (ADL) as final backstop when LLP cannot absorb

**Insurance Fund (LLP):**
- LLP serves as both market maker and insurance fund
- Reported APR ~47.6% with ~$498M TVL (per various sources)
- LLP absorbs losses from underwater liquidations
- 1% liquidation fee collected during partial liquidations
- Dual role (market making + insurance) creates potential conflicts during extreme volatility

**Historical Stress Test (October 2025):**
- During $19B market liquidation event, Lighter experienced multi-hour outage
- LLP suffered 5.35% loss
- Users could not manage positions during the outage
- Transaction volume surged 80x normal (639,370 txs in 2 minutes)
- Database index corruption and order processing breakdown
- ZK proof generation could not handle simultaneous matching + liquidation
- CEO acknowledged the failure was due to a delayed infrastructure upgrade

**Bad Debt Handling:**
- ADL mechanism prevents protocol insolvency
- ADL selects counterparties by leverage and unrealized PnL
- System has been stress-tested (Oct 2025) but failed partially

**Risk Rating: MEDIUM**

### 4. Smart Contract Security

**Audit History:**
- 7 audits completed, all within the last ~1.5 years:

| Audit | Date | Firm | Scope |
|-------|------|------|-------|
| LighterCore | Sep 2025 | Nethermind | Smart contracts |
| LighterEVM Deposit Bridge | Sep 2025 | Nethermind | Smart contracts |
| Block Audit | Apr 2025 | zkSecurity | Circuits/contracts |
| Block and Delta Audit | Aug 2025 | zkSecurity | Circuits/contracts |
| Wrapper Audit | Oct 2025 | zkSecurity | Circuits/contracts |
| Desert Exit Audit | May 2025 | zkSecurity | Circuits/contracts |
| Spot Audit | Nov 2025 | zkSecurity | Circuits/contracts |

- Audit Coverage Score: 7 audits x 1.0 (all < 1 year old) = **7.0** (LOW risk -- excellent coverage)
- Note: Nethermind and zkSecurity are reputable but not Tier 1 (no Trail of Bits, Spearbit, or OpenZeppelin)

**Bug Bounty:**
- No bug bounty program found on Immunefi or any public platform
- This is a significant gap for a protocol with $500M+ TVL

**Source Code:**
- ZK circuits: Open-sourced (elliottech/lighter-prover on GitHub)
- L1 contracts: Verified on Etherscan
- Sequencer/matching engine: Closed-source
- Pre-migration ZK circuits (before block 23,711,820): Never open-sourced, preventing full state reconstruction

**Battle Testing:**
- ~18 months live (private beta Jan 2025, public Oct 2025)
- Peak OI ~$1.5B+
- One major outage (Oct 2025) but no exploit or fund loss
- ~$720M OI and ~$1.3B daily volume currently

**Risk Rating: LOW**

### 5. Cross-Chain & Bridge

**Multi-Chain Deployment:**
- Execution on zkLighter L2 (application-specific rollup)
- Settlement on Ethereum L1
- Bridge component on Ethereum + Arbitrum
- Bridge TVL: ~$507M

**Bridge Architecture:**
- Native zk-rollup bridge (not third-party like LayerZero/Wormhole)
- Deposits flow from Ethereum/Arbitrum to zkLighter via L1 contracts
- Withdrawals require proof verification on L1

**Critical Issue -- State Reconstruction Blocked:**
- L2Beat found that a prover migration (gnark/MIMC to plonky2/Poseidon2) occurred at block 23,711,820
- No state snapshot was published during the migration
- ~60,000 pre-migration blobs cannot be decoded because the old circuit was never open-sourced
- This means users CANNOT independently reconstruct their account state from L1 data alone
- The desert mode (escape hatch) depends on state reconstruction, making it effectively non-functional for pre-migration accounts

**Proposer Centralization:**
- Only whitelisted proposers can publish state roots on L1
- If proposers fail, withdrawals are frozen
- Desert mode (14-day censorship timeout) exists in theory but circuits are not publicly available

**Risk Rating: MEDIUM**

### 6. Operational Security

**Team & Track Record:**
- Founder: Vladimir Novakovski (doxxed) -- Harvard graduate at 18, former Citadel quantitative trader
- Core team members from Facebook, Quora, Microsoft
- Company: Elliot Technologies, Inc.
- Funding: ~$89M total raised ($21M in 2024 from Haun Ventures/Craft Ventures; $68M in Nov 2025 from Founders Fund/Ribbit Capital at $1.5B valuation)
- Robinhood also participated as investor
- No prior security incidents under team's management before the Oct 2025 outage

**Incident Response:**
- No published incident response plan
- Oct 2025 outage response: CEO acknowledged "incorrect upgrade window"
- Emergency pause capability exists but response time during Oct 2025 event was poor (multi-hour outage)
- 14-day desert mode for sequencer censorship (theoretical -- not practically functional per L2Beat)

**Dependencies:**
- Stork Network (oracle)
- Ethereum L1 (settlement, DA)
- Centralized sequencer (single point of failure)
- ZK proof generation infrastructure

**Downstream Exposure:**
- LIT token is relatively new (Dec 2025 launch)
- Listed on Coinbase and Uniswap
- Not widely used as lending collateral on major platforms yet -- limits cascade risk

**Off-Chain Controls:**
- No SOC 2 or ISO 27001 certification found
- No published key management policy
- No disclosed penetration testing (infrastructure-level)
- Sequencer is closed-source -- operational security of matching engine cannot be independently verified
- No published operational segregation or insider threat controls

**Risk Rating: HIGH**

## Critical Risks

1. **Timelock Bypass**: The 3/6 multisig can reduce the 21-day upgrade delay to zero seconds, enabling instant contract upgrades without user exit window. With undisclosed signers, this is the single largest governance risk.

2. **Centralized Sequencer**: Single sequencer is a critical single point of failure. The Oct 2025 outage proved this under stress (80x traffic surge caused multi-hour downtime). Users cannot exit if the sequencer is down for <14 days.

3. **State Reconstruction Blocked**: Pre-migration blobs (~60,000 blocks) cannot be decoded because the old circuit was never open-sourced. Desert mode escape hatch is effectively non-functional for affected accounts.

4. **Oracle Trust Assumption**: External oracle signatures are not verified on-chain. The sequencer must be trusted to report accurate price data. A compromised sequencer could manipulate oracle feeds without detection by ZK proofs.

5. **No Bug Bounty**: A protocol with $500M+ TVL and no public bug bounty program creates a perverse incentive for black-hat exploitation over responsible disclosure.

## Peer Comparison

| Feature | Lighter | Hyperliquid | dYdX v4 |
|---------|---------|-------------|---------|
| Timelock | 21 days (bypassable to 0) | None | Multi-tier (short + long) |
| Multisig | 3/5 + 3/6 bypass | Centralized (improving) | On-chain governance |
| Audits | 7 (Nethermind, zkSecurity) | ~3 (various) | 6+ (Trail of Bits, Peckshield) |
| Oracle | Stork + CEX median (not verified on-chain) | Internal oracle | Chainlink + Skip |
| Insurance/TVL | LLP ~$498M / undisclosed ratio | HLP ~$380M | Protocol insurance fund (disclosed) |
| Open Source | Partial (circuits yes, sequencer no) | Partial | Full (Cosmos SDK) |
| Bug Bounty | None found | Yes (Immunefi) | Yes (Immunefi, $1M+) |
| Sequencer | Centralized (single) | Centralized | Decentralized validators |
| Stage (L2Beat) | Stage 0 | N/A (own L1) | N/A (own L1) |

## Recommendations

1. **For users**: Be aware that the protocol's governance can instantly upgrade contracts. Do not deposit more than you can afford to lose in a scenario where the timelock is bypassed. Monitor L2Beat for Stage progression.

2. **For the protocol team**:
   - Remove or constrain the timelock bypass: limit the 3/6 multisig to pause-only actions, not full upgrades
   - Launch a bug bounty program on Immunefi proportional to TVL (recommended: $500K-$1M max payout)
   - Open-source the pre-migration circuits to enable full state reconstruction
   - Publish desert mode circuit code to make the escape hatch practically functional
   - Verify oracle signatures on-chain rather than trusting the sequencer
   - Disclose multisig signer identities
   - Pursue SOC 2 Type II certification for operational security
   - Implement redundant sequencer architecture

3. **For integrators**: Do not accept LIT as lending collateral without understanding the token concentration risk (top holder has 25% of supply). Rate-limit any bridge-related integrations.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? UNVERIFIED -- sequencer controls market listings
- [x] Admin can change oracle sources arbitrarily? YES -- sequencer reports oracle data; not verified on-chain
- [ ] Admin can modify withdrawal limits? UNVERIFIED
- [x] Multisig has low threshold (2/N with small N)? YES -- 3/6 bypass multisig
- [x] Zero or short timelock on governance actions? YES -- timelock can be bypassed to 0
- [ ] Pre-signed transaction risk? N/A (EVM)
- [x] Social engineering surface area (anon multisig signers)? YES -- signers undisclosed

**WARNING: 5/7 Drift-type indicators match. This protocol has a governance architecture vulnerable to the same class of attack that drained $285M from Drift Protocol.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? No (USDC primary collateral)
- [x] Single oracle source without TWAP? Partially -- Stork primary, but EMA-capped
- [ ] No circuit breaker on price movements? 0.5% EMA cap exists
- [x] Insufficient insurance fund relative to TVL? Undisclosed ratio

2/4 indicators -- below trigger threshold.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? Native rollup bridge, not external validators
- [x] Admin keys stored in hot wallets? UNVERIFIED (no key management disclosure)
- [x] No key rotation policy? Yes -- none disclosed

2/3 indicators -- below trigger threshold.

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time? No on-chain governance yet
- [ ] Flash loans can be used to acquire voting power? N/A
- [ ] Proposal + execution in same block? N/A
- [ ] No minimum holding period? N/A

0/4 indicators -- not applicable.

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens? No
- [ ] Read-only reentrancy risk? UNVERIFIED
- [ ] Flash loan compatible without reentrancy guards? N/A (order book model)
- [ ] Composability with callback hooks? No

0/4 indicators -- not applicable.

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler? Custom ZK circuits (Plonky2) -- non-standard but audited
- [ ] Compiler version has known CVEs? UNVERIFIED
- [ ] Contracts compiled with different compiler versions? Migration from gnark to plonky2 occurred
- [ ] Code depends on language-specific behavior? ZK-specific constraints apply

1/4 indicators -- below trigger threshold.

### UST/LUNA-type (Algorithmic Depeg Cascade):
- Not applicable (no stablecoin mechanism).

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses cross-chain bridge for token minting? Native rollup bridge, not third-party messaging
- [ ] Bridge message validation relies on single messaging layer? N/A -- uses validity proofs
- [ ] DVN/relayer configuration not public? N/A
- [ ] Bridge can mint without rate limiting? UNVERIFIED
- [ ] Bridged token accepted as collateral on lending protocols? LIT not widely used as collateral yet
- [ ] No circuit breaker on minting? UNVERIFIED
- [ ] Emergency pause response time >15 minutes? YES -- Oct 2025 outage was multi-hour
- [ ] Bridge admin different from core protocol? Same team
- [ ] Token deployed on 5+ chains via same bridge? No (only Ethereum)

1/9 indicators -- below trigger threshold.

## Information Gaps

- **Multisig signer identities**: Unknown who the 3/5 and 3/6 multisig signers are
- **Insurance fund / TVL ratio**: LLP TVL reported (~$498M) but net exposure and actual insurance capacity are not precisely disclosed
- **Sequencer source code**: Matching engine, order processing, and sequencer logic are closed-source
- **Pre-migration state data**: ~60,000 blocks of state data are undecodable due to unreleased old circuit code
- **Desert mode functionality**: Circuit code not publicly available; L2Beat confirms escape hatch is not practically functional
- **Key management practices**: No information on HSM, MPC, key ceremony, or key rotation
- **Incident response plan**: No published procedure for security incidents
- **Bug bounty program**: None found publicly
- **SOC 2 / ISO 27001 / penetration testing**: No certifications or testing disclosures found
- **Oracle failover procedure**: What happens if Stork goes offline is not documented
- **Governance roadmap**: Whether and when LIT token will gain governance utility is unclear
- **Admin powers enumeration**: Full list of what the multisig can do beyond upgrades is not publicly documented
- **Rate limits on deposits/withdrawals**: Not documented
- **Sequencer key management**: How the centralized sequencer key is secured is unknown

## Disclaimer

This analysis is based on publicly available information and web research as of 2026-04-20.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
