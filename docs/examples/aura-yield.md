# DeFi Security Audit: Aura Finance

## Overview
- Protocol: Aura Finance
- Chain: Ethereum, Arbitrum, Optimism, Base, Polygon, Polygon zkEVM, Gnosis (xDai), Avalanche, Fraxtal (9 chains)
- Type: Yield / Balancer Booster (Convex-fork for Balancer)
- TVL: $96,928,265 (as of 2026-04-06)
- TVL Trend: +0.6% (7d) / -7.4% (30d) / -29.4% (90d)
- Launch Date: June 2022
- Audit Date: 2026-04-06
- Source Code: Open (GitHub: aurafinance/aura-contracts)
- Token: AURA (ERC-20, 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF on Ethereum)

## Quick Triage Score: 62

Red flags found: 5

- HIGH: Anonymous team with no prior track record -- (-15)
- MEDIUM: GoPlus: is_mintable = 1 -- (-8)
- LOW: No documented timelock on admin actions -- (-5)
- LOW: Undisclosed multisig signer identities -- (-5)
- LOW: Insurance fund / TVL undisclosed -- (-5)

Calculation: 100 - 15 - 8 - 5 - 5 - 5 = 62 (MEDIUM risk)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Not disclosed | Convex: Not disclosed | HIGH |
| Audit Coverage Score | 1.75 (see below) | Convex: ~1.5 | MEDIUM |
| Governance Decentralization | vlAURA + 4/7 multisig; Snapshot-based | Convex: vlCVX + 3/5 multisig | MEDIUM |
| Timelock Duration | None documented | Convex: None documented | HIGH |
| Multisig Threshold | 4/7 | Convex: 3/5 | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW |

**Audit Coverage Score Calculation:**
- Halborn (core platform, June 2022): 0.25 (> 2 years old)
- Code4rena ($150K contest, May 2022): 0.25 (> 2 years old)
- Halborn (AuraBal Compounder, ~2022-2023): 0.25 (> 2 years old)
- Halborn (Sidechain contracts, ~2023): 0.5 (1-2 years old)
- Zellic (Sidechain contracts, ~2023): 0.5 (1-2 years old)
- Total: 0.25 + 0.25 + 0.25 + 0.5 + 0.5 = 1.75 (MEDIUM)

## GoPlus Token Security (Ethereum, Chain ID 1)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | LOW |
| Open Source | Yes (1) | LOW |
| Proxy | No (0) | LOW |
| Mintable | Yes (1) | MEDIUM |
| Owner Can Change Balance | No (0) | LOW |
| Hidden Owner | No (0) | LOW |
| Selfdestruct | No (0) | LOW |
| Transfer Pausable | No (0) | LOW |
| Blacklist | No (0) | LOW |
| Slippage Modifiable | No (0) | LOW |
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 4,872 | MEDIUM |
| Trust List | Not whitelisted (0) | -- |
| Creator Honeypot History | No (0) | LOW |

**Top Holder Analysis** (from GoPlus):
- #1 (51.1%): 0x3fa73f...bcac (contract) -- likely vlAURA locker or staking contract
- #2 (10.2%): 0xba1222...2c8 (contract) -- Balancer Vault
- #3 (8.0%): 0xfc78f8...ca9 (contract) -- likely protocol-related (rewards/treasury)
- #4 (7.7%): 0xb401f0...fff (contract) -- likely protocol-related
- #5 (4.1%): 0x43b170...fa (contract) -- likely protocol-related
- Top 5 holders control ~81.2% of supply; all are contracts (not EOAs), consistent with a protocol where most tokens are locked in staking/governance contracts
- Owner address: 0xa57b8d...0234 (contract, 0% balance) -- owner holds no tokens

**Note:** The token being mintable (is_mintable = 1) is expected for Aura's emission schedule. The AURA minting function is tied to BAL reward distributions through a diminishing supply curve. The relatively low holder count (4,872) reflects concentrated participation typical of governance-focused yield protocols.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | MEDIUM | Immutable contracts but anonymous 4/7 multisig controls fees and pool operations | Partial |
| Oracle & Price Feeds | LOW | Relies on Balancer pool pricing; no independent oracle needed for core function | Partial |
| Economic Mechanism | HIGH | Core value proposition (veBAL boosting) undermined by Balancer restructuring | N |
| Smart Contract | MEDIUM | Convex fork with 5 audits but all >2 years old; immutable contracts limit upgrade risk | Partial |
| Token Contract (GoPlus) | LOW | Clean token contract; mintable but expected for emissions | Y |
| Cross-Chain & Bridge | MEDIUM | LayerZero OFT for AURA cross-chain; 9 chain deployments | Partial |
| Operational Security | HIGH | Anonymous team; Balancer dependency risk is existential post-exploit | N |
| **Overall Risk** | **HIGH** | **Balancer $128M exploit (Nov 2025) and subsequent veBAL wind-down fundamentally threaten Aura's core mechanism** | |

## Detailed Findings

### 1. Governance & Admin Key

**Immutable Contracts (Positive):** All core Aura smart contracts are immutable -- there are no admin rights to update smart contracts. Contracts are not pausable. Users always retain control of their funds. This eliminates the most dangerous admin key attack vectors (upgrades, drains).

**Multisig Structure:** Aura uses multiple Gnosis Safe multisig wallets with a 4/7 threshold. This is above the minimum best practice of 3/5. Treasury keys are reportedly delegated to "respected community members across the DeFi space with no prior or current affiliation with Aura."

**Limited Multisig Powers:**
- Change platform fees within hard-coded ranges (absolute ceiling of 25%)
- Shut down or pause new deposits to pool staking contracts
- Execute governance decisions (gauge votes, internal proposals)
- Cannot upgrade contracts, drain funds, or modify core logic

**Governance Process:** Aura uses Snapshot-based off-chain governance via vlAURA (vote-locked AURA, 16-week lock). Two Snapshot spaces exist: one for internal governance (gauges.aurafinance.eth) and one for Balancer gauge voting. The protocol has stated intentions to transition to on-chain Governor Bravo governance but this has not been implemented as of this audit date.

**Key Concerns:**
- Multisig signers are not publicly identified (anonymous community members) -- UNVERIFIED
- No documented timelock on multisig actions -- UNVERIFIED
- Snapshot governance is off-chain and non-binding, relying on multisig to faithfully execute
- No on-chain Governor Bravo despite years of stated intent
- AIP-8 established multi-sig best practices framework, showing governance maturity

**Rating: MEDIUM** -- Immutable contracts significantly reduce admin key risk, but anonymous multisig with no timelock and off-chain governance introduces trust assumptions.

### 2. Oracle & Price Feeds

Aura Finance does not operate as a lending protocol and does not require independent price oracles for its core functionality. The protocol:

- Deposits BAL into Balancer's VotingEscrow to obtain veBAL
- Wraps veBAL as auraBAL (1:1 tokenized representation)
- Manages BPT (Balancer Pool Token) staking via the Booster contract
- Routes rewards from Balancer to depositors

Price risks exist at the auraBAL/BAL peg level -- if auraBAL depegs from the underlying veBAL value, users face losses. The CrvDepositorWrapper handles BAL-to-BPT conversion via single-sided liquidity provision to the 80/20 BAL/ETH pool, which exposes users to pool composition risk and impermanent loss.

**Rating: LOW** -- No independent oracle dependency for core operations. Price risk is inherent to the Balancer pool model rather than oracle manipulation.

### 3. Economic Mechanism

**Core Mechanism (veBAL Boosting):**
Aura aggregates BAL deposits from users, locks them as veBAL for maximum boost, and distributes enhanced rewards. Users deposit BPT into the Booster contract, receive auraBPT tokens, and stake them in BaseRewardPools to earn boosted BAL rewards plus AURA emissions.

**CRITICAL DEVELOPMENT -- Balancer Restructuring (March 2026):**
Following the $128M Balancer v2 exploit on November 3, 2025 (rounding flaw in swap calculations), Balancer Labs announced it will shut down as a corporate entity. The DAO restructuring includes:
- **Removal of veBAL model entirely** -- the foundational mechanism Aura is built upon
- **BAL emissions cut to zero** -- ending the "circular bribe economy"
- **100% of protocol fees redirected to DAO treasury** (previously 17.5%)
- **$500,000 compensation for veBAL holders** for termination of economic rights
- Balancer's co-founder explicitly cited "meta-governance protocols like Aura and bribe markets" as having "captured" voting power, making it "unrepresentative"

This restructuring is existential for Aura Finance. Without veBAL:
- Aura's core value proposition (boosted yields via veBAL) ceases to function
- vlAURA governance power over Balancer gauge votes becomes meaningless
- The auraBAL wrapper loses its purpose
- The entire bribe/incentive economy around vlAURA collapses

**AURA Token Economics:**
- Total supply: ~85.66M AURA
- Minting tied to BAL reward distributions via diminishing supply curve
- If BAL emissions go to zero, AURA minting effectively stops
- vlAURA requires 16-week lock, creating illiquidity risk during structural transitions

**Insurance Fund:** No publicly documented insurance fund. This is a significant gap for a protocol managing ~$97M TVL across 9 chains.

**Rating: HIGH** -- The Balancer restructuring and veBAL wind-down fundamentally undermines Aura's economic model. The protocol must pivot or face obsolescence.

### 4. Smart Contract Security

**Architecture:** Aura is a fork of Convex Finance (Curve booster) adapted for Balancer. Key contracts include:
- **VoterProxy**: Holds veBAL voting power; whitelisted in BAL ecosystem
- **Booster**: Manages pool deposits; minimal changes from Convex
- **BaseRewardPool**: Handles reward distribution to stakers
- **AuraLocker**: vlAURA locking mechanism (most modified from Convex)
- **CrvDepositorWrapper**: Handles BAL-to-auraBAL conversion
- **PoolManagerV3**: Manages addition of Balancer pools

**Convex Fork Strategy (Positive):** The team deliberately kept changes from Convex minimal to benefit from Convex's battle-tested codebase and facilitate manual review.

**Audit History:**
1. Halborn Security -- 6-week core platform audit (May-June 2022)
2. Code4rena -- $150K contest, 2-week competition (May 2022)
3. Halborn -- 2-week AuraBal Compounder audit (~2022-2023)
4. Halborn -- 4-week Sidechain contracts audit (~2023)
5. Zellic -- 8-day Sidechain contracts audit (~2023)

All audits are over 2 years old. No critical findings were publicly reported in audit summaries.

**Bug Bounty:** Active on Immunefi since June 2022, with up to $1M maximum payout for critical vulnerabilities. Critical bugs require PoC, capped at 10% of economic damage.

**Development Practices:**
- Protected master branch with mandatory peer reviews
- CI with linting and compilation checks
- >98% code coverage
- Partnership with Chainalysis for incident response

**Code Immutability:** Core contracts are immutable (non-upgradeable, non-proxy). This is a double-edged sword: it eliminates admin upgrade risk but prevents patching vulnerabilities.

**Note on Convex Precedent:** OpenZeppelin discovered a potential $15B rug-pull vulnerability in Convex (if 2 of 3 multisig signers colluded). The bug was patched before exploitation. Since Aura forked from Convex, this class of vulnerability was reviewed during the Code4rena contest.

**Rating: MEDIUM** -- Strong audit history and immutable contracts, but all audits are stale (>2 years). The Convex fork approach reduces novel bug risk but introduces dependency on Convex's security posture.

### 5. Cross-Chain & Bridge

**Multi-Chain Deployment:** Aura operates on 9 chains: Ethereum (primary, 79% of TVL), Arbitrum, Optimism, Base, Polygon, Polygon zkEVM, Gnosis, Avalanche, and Fraxtal.

**LayerZero Dependency:** AURA token uses LayerZero's Omnichain Fungible Token (OFT) standard for cross-chain transfers. This creates a dependency on LayerZero's messaging infrastructure and relayer/oracle network.

**Cross-Chain Governance:** Governance is Ethereum-centric via Snapshot. It is unclear whether sidechain deployments have independent multisig controls or rely on cross-chain message relaying from Ethereum -- UNVERIFIED.

**Bridge Risk Assessment:**
- LayerZero is a major cross-chain infrastructure provider, reducing third-party bridge risk
- However, any LayerZero vulnerability could affect AURA token availability across chains
- Sidechain contracts were separately audited by Halborn and Zellic
- Fraxtal and Polygon zkEVM show $0 TVL, suggesting potential deployment issues or abandonment

**Rating: MEDIUM** -- LayerZero is a reputable cross-chain provider, but 9-chain deployment increases attack surface. Some chains show zero TVL, raising questions about maintenance.

### 6. Operational Security

**Team:** The Aura Finance team is anonymous/pseudonymous. No founders or core contributors are publicly identified. While common in DeFi, this increases social engineering and accountability risk. The team has no publicly documented track record from prior projects.

**Incident Response:**
- Partnership with Chainalysis for incident response planning
- Emergency pause capability exists for new deposits to staking contracts
- No documented public incident response playbook

**Key Dependencies:**
1. **Balancer Protocol** (CRITICAL): Aura is entirely dependent on Balancer for its core functionality. The Balancer v2 exploit ($128M, Nov 2025) and subsequent restructuring (veBAL removal, Labs shutdown) represent an existential threat.
2. **LayerZero**: Cross-chain token bridging and messaging
3. **Gnosis Safe**: Multisig infrastructure for governance execution
4. **Snapshot**: Off-chain governance voting

**Composability Risk:** If Balancer pools fail, Aura depositors' BPT tokens could lose value. If the Balancer VotingEscrow is deprecated (as planned in the restructuring), Aura's veBAL position becomes illiquid or worthless.

**Communication:** Active Twitter (@aurafinance), governance forum (forum.aura.finance), and documentation (docs.aura.finance). No emergency communication channel documented.

**Rating: HIGH** -- Anonymous team combined with existential Balancer dependency risk. The Balancer restructuring creates unprecedented uncertainty for Aura's operational continuity.

## Critical Risks

1. **Balancer Restructuring / veBAL Wind-Down (CRITICAL):** The removal of veBAL and zeroing of BAL emissions directly dismantles Aura's core value proposition. Without veBAL, there is no yield boost to aggregate, no gauge votes to direct, and no bribe economy to sustain vlAURA demand. The protocol must pivot or become obsolete.

2. **Stale Audit Coverage (HIGH):** All five audits are more than 2 years old. The sidechain deployments and any contract changes since 2023 may have unaudited code paths. Given the protocol manages ~$97M across 9 chains, fresh audit coverage is overdue.

3. **Anonymous Team with Existential Dependency Crisis (HIGH):** The anonymous team managing a protocol facing an existential threat (Balancer restructuring) creates heightened counterparty risk. Users have no recourse or accountability framework if the team abandons the project.

4. **No Insurance Fund (HIGH):** No publicly documented insurance fund or bad debt coverage mechanism for a ~$97M TVL protocol. In a depeg or exploit scenario, losses would be fully borne by depositors.

## Peer Comparison

| Feature | Aura Finance | Convex Finance | Pendle Finance |
|---------|-------------|----------------|----------------|
| Type | Balancer Booster | Curve Booster | Yield Tokenization |
| TVL | ~$97M | ~$1.2B | ~$1.9B |
| Timelock | None documented | None documented | None documented |
| Multisig | 4/7 (Gnosis Safe) | 3/5 | 2/4 (UNVERIFIED) |
| Audits | 5 (all >2yr old) | Multiple (MixBytes+) | 4 (1 recent) |
| Bug Bounty | $1M (Immunefi) | Yes (Immunefi) | $250K (Immunefi) |
| Oracle | N/A (Balancer pools) | N/A (Curve pools) | RedStone + Chainlink |
| Insurance/TVL | Undisclosed | Undisclosed | Undisclosed |
| Open Source | Yes | Yes | Yes |
| Immutable Contracts | Yes | Mostly | No (upgradeable) |
| Team | Anonymous | Pseudonymous | Pseudonymous |
| Base Protocol Risk | CRITICAL (Balancer restructuring) | MEDIUM (Curve stable) | LOW (independent) |

## Recommendations

1. **Monitor Balancer Restructuring Closely:** Users should track Balancer governance proposals regarding veBAL wind-down timeline. Consider reducing Aura exposure until the protocol's post-veBAL strategy is clarified.

2. **Assess Exit Liquidity:** vlAURA has a 16-week lock period. Users currently locked should evaluate whether they can exit before veBAL termination. auraBAL holders should monitor the auraBAL/BAL peg for signs of depegging.

3. **Demand Fresh Audits:** The community should push for updated security audits, especially for sidechain deployments and any contract changes since 2023.

4. **Request Team Transparency:** Given the existential threat from Balancer restructuring, the community should request the team publish a concrete post-veBAL roadmap and consider doxxing key contributors to increase accountability.

5. **Diversify Yield Sources:** Do not concentrate yield strategies in Aura given the structural uncertainty. Consider direct Balancer deposits or alternative yield protocols.

6. **Verify Multisig On-Chain:** Users and researchers should independently verify the 4/7 multisig configuration, signer addresses, and any recent transactions on Etherscan/Gnosis Safe interface.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- N/A (not a lending protocol); pools added via PoolManagerV3
- [ ] Admin can change oracle sources arbitrarily? -- N/A (no oracle dependency)
- [ ] Admin can modify withdrawal limits? -- No; immutable contracts
- [x] Multisig has low threshold (2/N with small N)? -- No; 4/7 is adequate
- [x] Zero or short timelock on governance actions? -- Yes; no documented timelock
- [ ] Pre-signed transaction risk? -- N/A (EVM, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- Yes; signers are anonymous

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A (no collateral/lending)
- [ ] Single oracle source without TWAP? -- N/A
- [ ] No circuit breaker on price movements? -- N/A
- [x] Insufficient insurance fund relative to TVL? -- Yes; no documented insurance fund

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- Partial; LayerZero relayer model
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

**Pattern Match Assessment:** Low Drift-type risk due to immutable contracts. Low Euler/Mango-type risk due to no lending/oracle dependency. Moderate Ronin-type risk from multi-chain LayerZero dependency. The primary risk is structural (Balancer dependency) rather than attack-vector based.

## Information Gaps

- **Post-veBAL Strategy:** No public communication from Aura team regarding plans after Balancer removes veBAL. This is the single most important unknown.
- **Multisig Signer Identities:** Signers described as "respected community members" but not publicly identified or verifiable.
- **Timelock Configuration:** No documentation confirms whether any timelock exists on multisig actions.
- **Insurance Fund:** No information on any insurance or bad debt coverage mechanism.
- **Sidechain Multisig Independence:** Unclear whether each chain deployment has an independent multisig or shares control.
- **Team Identity:** No publicly identified team members, founders, or contributors.
- **Recent Code Changes:** Unknown whether any contract changes have been made since the last audit (~2023).
- **auraBAL Redemption Mechanism:** Unclear how auraBAL holders will be made whole if veBAL is wound down by Balancer.
- **Fraxtal and Polygon zkEVM Deployments:** Both show $0 TVL -- unclear if abandoned or experiencing issues.
- **LayerZero Configuration:** Specific relayer/oracle configuration for AURA OFT cross-chain messaging is not documented.

## Disclaimer

This analysis is based on publicly available information and web research as of 2026-04-06.
It is NOT a formal smart contract audit. The Balancer restructuring situation is rapidly evolving
and may change materially after this report date. Always DYOR and consider
professional auditing services for investment decisions.
