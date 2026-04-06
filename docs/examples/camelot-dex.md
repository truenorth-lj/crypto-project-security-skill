# DeFi Security Audit: Camelot

**Audit Date:** April 6, 2026
**Protocol:** Camelot -- Arbitrum-native Decentralized Exchange (DEX)

## Overview
- Protocol: Camelot
- Chain: Arbitrum (primary), plus Gravity, ApeChain, Xai, Rari, Superposition, ReyaChain, EDU Chain, DuckChain, WINR
- Type: DEX (dual AMM: V2 constant-product + V3/V4 concentrated liquidity via Algebra)
- TVL: ~$24.8M (DeFiLlama, April 2026)
- TVL Trend: -0.3% / -5.2% / -40.9% (7d / 30d / 90d)
- Token: GRAIL (ERC-20, Arbitrum: 0x3d9907F9a368ad0a51Be60f7Da3b97cf940982D8)
- Launch Date: November 2022 (public sale November 29, 2022)
- Audit Date: April 6, 2026
- Source Code: Open (verified on Arbiscan; AMM based on Algebra open-source codebase)

## Quick Triage Score: 41/100

Starting at 100, subtracting:

- -8: GoPlus: is_mintable = 1 (GRAIL token is mintable by owner, used for emissions)
- -8: TVL dropped >30% in 90 days (-40.9%)
- -8: Multisig threshold < 3 signers: Team multisig is 2/3 (verified on-chain)
- -5: Overlapping multisig signers: all 3 team keys also meet 3/6 ecosystem threshold (no signer independence)
- -15: Anonymous team with no prior track record (pseudonymous founders -- no public identities or verifiable prior projects)
- -5: No documented timelock on admin actions
- -5: No confirmed bug bounty program on Immunefi
- -5: Undisclosed multisig signer identities (all pseudonymous)

Total deductions: -59. Raw score: 41. Floor at 0. **Score: 41/100 (HIGH risk)**

Red flags found: 0 CRITICAL, 1 HIGH (anonymous team), 4 MEDIUM (mintable token, TVL decline, low multisig threshold, overlapping multisig signers), 3 LOW (no timelock, no bug bounty, undisclosed signer identities)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed / N/A (DEX, no lending) | N/A for spot DEX | LOW |
| Audit Coverage Score | 1.0 (see calculation) | Uniswap ~4.0, Trader Joe ~2.5 | HIGH |
| Governance Decentralization | xGRAIL gasless voting, but team executes | Uniswap on-chain gov | MEDIUM |
| Timelock Duration | None documented | 24-48h industry avg | HIGH |
| Multisig Threshold | 2/3 (team) / 3/6 (ecosystem); 3 overlapping signers | 3/5 avg | HIGH |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW |

### Audit Coverage Score Calculation

Known audits:

**Older than 2 years (0.25 each):**
1. Paladin -- Camelot Main (Oct 30, 2022) -- 0.25
2. Paladin -- Camelot Nitro & Presale (Nov 14, 2022) -- 0.25

**1-2 years old (0.5 each):**
3. BailSec -- Camelot Router (date unclear, estimated ~2023-2024) -- 0.5

**Algebra AMM audits (underlying V3/V4 codebase, not Camelot-specific):**
- Hacken -- Algebra (0.25, >2yr)
- ABDK -- Algebra v1.0 (0.25, >2yr)
- Hexens -- Algebra (0.25, >2yr)
- Paladin -- Algebra Protocol Update (Apr 2023, 0.25)
- Paladin -- Algebra Tick Spacing Upgrade (Jun 2023, 0.25)
- MixBytes -- Algebra Integral V4 Core (0.25)
- BailSec -- Algebra Integral v1.2 Core Update (0.5)

Camelot-specific subtotal: ~1.0
Including Algebra audits: ~2.75

**Rating: HIGH** (Camelot-specific audit coverage is thin at 1.0; Algebra audits cover the AMM layer but not Camelot's custom contracts like xGRAIL plugins, Nitro pools V2, or launchpad updates since 2022)

## GoPlus Token Security

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
| Holders | 47,236 | LOW |
| Trust List | No | -- |
| Creator Honeypot History | No (0) | LOW |

**Owner address:** 0x8b797d42d4b2c330575e18f7c793fe4383086807 (Ecosystem Multisig, 3/6 threshold -- verified on-chain via Safe API, April 2026)
**Creator address:** 0x01bb7b44cc398aaa2b76ac6253f0f5634279db9d
**Top holder:** 0x3caae25ee616f2c8e13c74da0813402eae3f496b (xGRAIL contract, 24.9%)

**Note:** is_mintable = 1 means the owner (Ecosystem Multisig) can mint new GRAIL tokens. This is by design for the emission schedule (max supply 100,000 GRAIL), but represents a trust assumption on the 3/6 multisig -- which shares all 3 signers with the 2/3 team multisig, meaning the same 3 keys that control core contracts can also mint tokens.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | HIGH | 2/3 team multisig controls core contracts; no timelock; 3/6 ecosystem multisig shares all 3 team signers | Verified on-chain (Safe API, April 2026) |
| Oracle & Price Feeds | LOW | Uses Algebra TWAP from pool; DEX spot pricing (no external oracle dependency) | Partial |
| Economic Mechanism | MEDIUM | xGRAIL lock-up creates illiquidity risk; Nitro pool emissions depend on team | N |
| Smart Contract | MEDIUM | Camelot-specific audits are 3+ years old; Algebra layer better audited | Y |
| Token Contract (GoPlus) | MEDIUM | Mintable by 3/6 multisig (controlled by same 3 keys as team multisig); max supply 100K but enforced by trust not code | Y |
| Cross-Chain & Bridge | MEDIUM | Deployed on 10 chains; governance centralized on Arbitrum; bridge risk for orbit chains | Partial |
| Operational Security | HIGH | Fully pseudonymous team; no public incident response plan; no Immunefi bounty | N |
| **Overall Risk** | **HIGH** | **Pseudonymous team with low multisig threshold (2/3), no timelock, and stale audits** | |

## Detailed Findings

### 1. Governance & Admin Key

**Team Multisig (2/3):** Address 0x460d0F7B75412592D14440857f715ec28861c2D7 (Safe v1.3.0+L2, no modules) controls the most critical protocol functions: Factory/Pairs, Master/NFTPools, NitroPoolFactory, xGRAIL, Real Yield Staking, and YieldBooster contracts. Verified on-chain (Safe API, April 2026) -- threshold: 2/3, owners:
- 0x2Fcbc80f9290edCE8BE09b14f3AfaFc8c89Bd2Da
- 0x56140b52879D5b6D03449B912193c7b18210A7af
- 0x01E5d631ba707a029C8A1555bDAc4805d7853E21

A 2/3 threshold is the minimum viable multisig and a classic Drift-type attack surface. If any single signer's key is compromised AND one other signer is colluding or social-engineered, the attacker gains full control of core contracts. This is well below industry standard (3/5 or higher). With no timelock and pseudonymous signers, there is zero recovery window.

**Ecosystem Multisig (3/6):** Address 0x8b797d42d4b2c330575e18f7c793fe4383086807 (Safe v1.3.0+L2, no modules) controls GRAIL token minting, partnership/team/advisor vesting, and ecosystem funds. Verified on-chain (Safe API, April 2026) -- threshold: **3/6** (NOT 4/6 as previously reported in some sources), owners:
- 0x2Fcbc80f9290edCE8BE09b14f3AfaFc8c89Bd2Da (also in team multisig)
- 0x56140b52879D5b6D03449B912193c7b18210A7af (also in team multisig)
- 0x1a4afB607900fb1594c9EE8D119D748C6ccEC210
- 0x29E3DdF94d76C97FcD43D07Fc8B15A03AD233A40
- 0xb4390019Bff98aA112eAf93A91Ef5d9653e24C7a
- 0x01E5d631ba707a029C8A1555bDAc4805d7853E21 (also in team multisig)

**CRITICAL FINDING -- Overlapping Signers:** All 3 owners of the team multisig (0x2Fcbc...Da, 0x56140...af, 0x01E5d...21) also appear in the 3/6 ecosystem multisig. This means the same 3 keys that have full control of core contracts via the 2/3 team multisig also meet the 3/6 threshold on the ecosystem multisig. In practice, a single keyholder group controls BOTH multisigs. The 3/6 ecosystem threshold provides no additional security independence from the 2/3 team multisig.

**No Timelock:** There is no documented or on-chain timelock on any admin actions. The team multisig can execute changes to core contracts immediately. This means there is no window for the community to react to malicious or erroneous governance actions.

**Governance Process:** xGRAIL holders vote on proposals via gasless off-chain voting. However, "when a proposal is approved, a DAO of team members and advisors executes the necessary contracts and makes the final decision." This means governance is ultimately advisory -- the team retains execution authority and can override community votes.

**Rating: HIGH**

### 2. Oracle & Price Feeds

Camelot is a spot DEX, not a lending protocol, so oracle risk is structurally different from lending/perps platforms. Key considerations:

- **TWAP from Algebra V4:** The AMM V4 provides on-chain TWAP data directly from pool price observations. This is used by external protocols that integrate with Camelot for price references.
- **No External Oracle Dependency:** Camelot itself does not rely on Chainlink or Pyth for its core swap functionality. Prices are determined by AMM mechanics.
- **TWAP Manipulation Risk:** For low-liquidity pools, TWAP can be manipulated via large trades. This is primarily a risk for protocols integrating Camelot as a price source, not for Camelot's own operations.
- **Launchpad Risk:** New tokens launched via Camelot's launchpad may have extremely thin liquidity, making price manipulation trivial in the early hours/days.

**Rating: LOW** (for Camelot's own operations; MEDIUM for protocols relying on Camelot TWAP)

### 3. Economic Mechanism

**Dual AMM Model:** Camelot operates V2 (constant-product x*y=k and stable curve x3y+y3x=k) alongside V3/V4 (Algebra-based concentrated liquidity with dynamic fees). This provides flexibility but increases the attack surface -- LPs must understand which model they are providing liquidity to.

**xGRAIL Lock-up:** GRAIL can be converted to xGRAIL (non-transferable, escrowed). xGRAIL is allocated to "plugins" for staking rewards, yield boosting, launchpad access, and governance. Converting xGRAIL back to GRAIL requires a vesting period (details vary). This creates:
- Illiquidity risk for xGRAIL holders who cannot exit quickly
- Governance concentration in long-term holders (by design, but reduces accountability)
- Dependency on the plugin system continuing to function

**Nitro Pools:** Permissionless incentive pools where protocols can direct rewards to specific liquidity types. This is a positive feature for ecosystem flexibility but creates risk of incentive manipulation -- a malicious actor could create a Nitro pool with misleading rewards to attract liquidity to a low-quality token.

**Emissions:** ~85% of mining rewards are emitted as xGRAIL (non-transferable), with ~15% as liquid GRAIL. Max supply is 100,000 GRAIL with emissions over ~4 years (launched Nov 2022, so nearing completion of initial schedule). The mintable flag on the token contract means the Ecosystem Multisig could theoretically mint beyond the stated 100K cap -- this is a trust assumption.

**TVL Decline:** The -40.9% TVL decline over 90 days is significant. Current TVL of ~$24.8M is well below the protocol's peak. This may reflect broader market conditions or migration to competitors, but it reduces the protocol's resilience and increases concentration risk for remaining LPs.

**Rating: MEDIUM**

### 4. Smart Contract Security

**Camelot-Specific Audits:**
- Paladin: Main audit (Oct 2022) and Nitro & Presale (Nov 2022) -- both over 3 years old
- BailSec: Router audit (date unclear)

**Algebra AMM Audits (underlying V3/V4):**
- Hacken, ABDK, Hexens, Paladin (x2), MixBytes, BailSec -- comprehensive coverage of the core AMM

**Key Concern:** Camelot's custom contracts -- xGRAIL token, plugin system, YieldBooster, Nitro pools, launchpad -- have not been publicly audited since the protocol's initial launch in late 2022. Significant feature additions (V3/V4 migration, plugin architecture, multi-chain deployment) have occurred since then without documented Camelot-specific audits covering these changes.

**Bug Bounty:** Camelot claims to have a bug bounty program but it is not listed on Immunefi (the industry standard platform). No public details on scope or maximum payout were found.

**Battle Testing:** The protocol has been live since November 2022 (~3.5 years). No direct exploits of Camelot's core contracts have occurred. The Gamma Strategies incident (January 2024, ~$6.18M loss) affected Gamma's vault configurations on Camelot but did not compromise Camelot's own contracts. The Aurory SyncSpace bridge exploit (December 2023) drained an AURY-USDC pool on Camelot but was an Aurory vulnerability, not a Camelot one.

**Open Source:** Core contracts are verified on Arbiscan. The Algebra codebase is open source.

**Rating: MEDIUM**

### 5. Cross-Chain & Bridge

Camelot is deployed across 10 chains according to DeFiLlama, with Arbitrum as the primary chain (~$21M of ~$24.8M TVL). Secondary deployments include Gravity (~$2.3M), ApeChain (~$1.4M), and several smaller chains.

**Governance Centralization:** All multisig addresses identified are on Arbitrum. It is UNVERIFIED whether each chain deployment has its own independent admin controls or if Arbitrum governance controls all deployments via cross-chain messaging.

**Bridge Risk:** Secondary chains (Xai, Rari, DuckChain, etc.) are Arbitrum Orbit chains or L3s that rely on Arbitrum's native bridge infrastructure. A compromise of the bridge to any orbit chain could affect Camelot's deployment on that chain, but the financial impact would be limited given the small TVL on those chains.

**Rating: MEDIUM**

### 6. Operational Security

**Team:** Fully pseudonymous. The core team members (Myrddin, Percival, SirIronBoots) use pseudonyms with no verified prior project history. The Ecosystem Multisig adds three more pseudonymous participants. While pseudonymity is common in DeFi, it eliminates legal accountability and increases social engineering risk.

**Incident Response:** No published incident response plan was found. During the Gamma incident (Jan 2024), Camelot communicated via X/Twitter that their core protocol was unaffected and unlocked Gamma vault spNFTs for user withdrawals -- a reasonable response, but reactive rather than following a documented playbook.

**Launchpad Risk:** Camelot operates a launchpad for new Arbitrum-native projects. The documentation explicitly states: "just because a protocol uses Camelot does not mean Camelot has verified or endorsed its security or safety." This is appropriate disclosure, but users may still conflate Camelot's brand with launched projects.

**Dependencies:**
- Algebra Finance: Core AMM dependency. A vulnerability in Algebra would directly affect Camelot.
- Arbitrum L2: Relies on Arbitrum's security model and bridge to Ethereum L1.
- Gnosis Safe: Multisig infrastructure (both multisigs verified as Safe v1.3.0+L2, no modules).

**Rating: HIGH**

## Critical Risks

1. **LOW MULTISIG THRESHOLD (2/3) WITH NO TIMELOCK -- DRIFT-TYPE ATTACK SURFACE:** The team multisig controlling core contracts requires only 2 of 3 pseudonymous signers. Combined with zero timelock, this means two compromised or colluding signers could immediately modify Factory settings, pool parameters, NFT pool rewards, xGRAIL plugin allocations, and YieldBooster configurations. There is no community reaction window. This configuration closely mirrors the governance weaknesses exploited in the Drift Protocol hack.

2. **OVERLAPPING MULTISIG SIGNERS -- NO INDEPENDENCE BETWEEN MULTISIGS:** On-chain verification (Safe API, April 2026) confirms all 3 team multisig owners also sit on the 3/6 ecosystem multisig. The team's 3 keys alone meet the ecosystem multisig threshold. This means a single compromised keyholder group controls both core protocol operations AND token minting/ecosystem funds. The ecosystem multisig provides zero additional security separation.

3. **FULLY PSEUDONYMOUS TEAM WITH PROTOCOL CONTROL:** All signers on both multisigs are pseudonymous with no verifiable identity or prior track record. The team retains execution authority over governance proposals ("makes the final decision"). Users are trusting unknown individuals with admin access to ~$24.8M in TVL.

4. **STALE CAMELOT-SPECIFIC AUDITS:** The last Camelot-specific audit was in late 2022. The protocol has since migrated AMM versions, added plugins, expanded to 10 chains, and evolved its tokenomics. Critical custom contracts (xGRAIL, plugins, launchpad) have not been re-audited in over 3 years.

## Peer Comparison

| Feature | Camelot | Uniswap (Arbitrum) | Trader Joe (Avalanche) |
|---------|---------|-------------------|----------------------|
| Timelock | None documented | 2-day minimum | 48h on key actions |
| Multisig | 2/3 (team), 3/6 (ecosystem); 3 overlapping signers | Uniswap Governance (on-chain) | 3/5 multisig |
| Audits | 3 Camelot-specific (2022); 7+ Algebra | 10+ (Trail of Bits, OpenZeppelin, etc.) | 5+ (Paladin, Omniscia, Halborn) |
| Oracle | TWAP from pool (Algebra) | TWAP from pool (native) | TWAP from pool (native) |
| Insurance/TVL | N/A (spot DEX) | N/A (spot DEX) | N/A (spot DEX) |
| Open Source | Yes | Yes | Yes |
| Team | Pseudonymous | Known (Hayden Adams et al.) | Known (core team doxxed) |
| TVL (Arbitrum) | ~$21M | ~$288M | ~$10M (Avalanche) |
| Bug Bounty | Claimed, not on Immunefi | $15.5M max on Immunefi | On Immunefi |

## Recommendations

1. **For users/LPs:** Be aware that Camelot's admin controls are concentrated in a 2/3 pseudonymous multisig with no timelock. Monitor the team multisig (0x460d...c2D7) for unusual transactions. Avoid allocating large positions relative to pool TVL.

2. **For the Camelot team:** Implement a 24-48h timelock on all non-emergency admin actions. Increase the team multisig threshold to at least 3/5. Add independent (non-overlapping) signers to both multisigs to eliminate the single keyholder group controlling both. List the bug bounty program on Immunefi with clear scope and competitive payouts. Commission a fresh audit of xGRAIL plugins, Nitro pools, and multi-chain deployment contracts.

3. **For protocols integrating Camelot:** Do not rely on Camelot TWAP as a sole price oracle for lending or perps. Use Chainlink or multi-source oracles with Camelot TWAP as a secondary check.

4. **For xGRAIL holders:** Understand that xGRAIL is non-transferable and conversion back to GRAIL requires vesting. The governance system is advisory -- the team makes final execution decisions. Factor in the illiquidity risk.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- N/A (DEX, not lending), but admin can modify pool parameters without timelock
- [ ] Admin can change oracle sources arbitrarily? -- No external oracle dependency
- [x] Admin can modify withdrawal limits? -- Team multisig (2/3, verified on-chain) controls core contracts
- [x] Multisig has low threshold (2/N with small N)? -- YES, 2/3 team multisig
- [x] Zero or short timelock on governance actions? -- YES, no timelock documented
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (EVM)
- [x] Social engineering surface area (anon multisig signers)? -- YES, all signers pseudonymous

**Drift-pattern match: 4/6 applicable flags triggered. ELEVATED RISK.** On-chain verification confirms the 2/3 team multisig threshold and overlapping signers with the ecosystem multisig, strengthening this assessment.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [x] Low-liquidity collateral accepted? -- N/A for DEX core, but launchpad tokens have very thin liquidity
- [ ] Single oracle source without TWAP? -- Uses TWAP
- [ ] No circuit breaker on price movements? -- N/A for spot DEX
- [ ] Insufficient insurance fund relative to TVL? -- N/A for spot DEX

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Uses Arbitrum native bridge (decentralized sequencer set)
- [x] Admin keys stored in hot wallets? -- UNVERIFIED; no information on key storage practices
- [x] No key rotation policy? -- UNVERIFIED; no documented rotation policy

## Information Gaps

- **Timelock existence:** No on-chain or documented timelock was found. It is possible a timelock exists but is not publicly documented. This could not be verified without direct contract inspection.
- **Emergency pause mechanism:** No information found on whether the team can pause swaps, Nitro pools, or xGRAIL operations in an emergency.
- **Key storage practices:** No information on how multisig signer keys are stored (hardware wallets, HSMs, etc.).
- **Key rotation policy:** No information on whether signers rotate keys or whether signer membership has changed since launch.
- **Multi-chain admin controls:** It is unknown whether each chain deployment has its own admin or if Arbitrum governance controls all chains.
- **GRAIL max supply enforcement:** The token is mintable. It is UNVERIFIED whether the 100,000 max supply cap is enforced in the smart contract or is merely a stated policy. Given that the 3 team keys can meet the 3/6 ecosystem multisig threshold, this is a heightened concern.
- **Multisig signer independence:** Verified on-chain that all 3 team multisig owners overlap with the 3/6 ecosystem multisig. No information on whether the 3 additional ecosystem signers have any independent authority or veto power.
- **Bug bounty details:** Camelot claims a bug bounty exists but no details on scope, maximum payout, or platform were found.
- **Team identity:** No real-world identities, company registrations, or legal entities are publicly associated with Camelot.
- **Revenue model sustainability:** Fee structure and protocol revenue relative to emissions are not clearly documented.
- **Insurance or bad debt mechanisms:** No information on what happens if a critical vulnerability is exploited -- whether there is a treasury allocation for user reimbursement.

## Disclaimer

This analysis is based on publicly available information and web research as of April 6, 2026. It is NOT a formal smart contract audit. The findings reflect what could be determined from documentation, on-chain data, and public sources. Always DYOR and consider professional auditing services for investment decisions.
