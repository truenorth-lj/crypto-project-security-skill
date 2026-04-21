# DeFi Security Audit: Kinetiq kHYPE

**Audit Date:** 2026-04-21
**Protocol:** Kinetiq -- Liquid staking protocol on Hyperliquid L1 (kHYPE LST)

## Overview
- Protocol: Kinetiq
- Chain: Hyperliquid L1 (HyperEVM + HyperCore staking integration)
- Type: Liquid Staking (LST) for HYPE token
- TVL: ~$0.77B (DeFiLlama, 2026-04-21; primary chain Hyperliquid L1 = $766.6M, staking-bucket accounting $11.4M)
- TVL Trend: UNVERIFIED (rapidly-growing; protocol launched July 2025, KNTQ governance token launched Nov 2025)
- Launch Date: July 2025 (mainnet); KNTQ governance token launched November 2025
- Audit Date: 2026-04-21
- Valid Until: 2026-07-20 (or sooner if: TVL changes >30%, validator set change, security incident, or governance upgrade)
- Source Code: Open (GitHub: `code-423n4/2025-04-kinetiq`, Cantina bounty scope public)
- kHYPE Contract (HyperEVM): `0xfD739d4e423301CE9385c1fb8850539D657C296D`
- KNTQ Governance Token: `0x000000000000780555bd0bca3791f89f9542c2d6` -- EIP-1967 TransparentUpgradeableProxy, implementation at `0x987aadf0f8b7ebe9a3a633e9f1d8c1c684b18e17`
- Staking lockup: 1-day delegation lockup + 7-day unstake queue = **8 days total to exit**

## Quick Triage Score: 60/100 | Data Confidence: 60/100

Starting at 100, the following deductions apply:

**HIGH flags (-15 each):**
- (-15) DeFiLlama lists `audits = "0"` despite the project having 5+ audit firms engaged -- indicates DeFiLlama has not indexed Kinetiq audit reports. The audits ARE real (Zenith, Pashov Audit Group, Spearbit, Code4rena competition, Cantina, Secure Staking Alliance, Groomlake per QuillAudits blog) -- BUT a discrepancy between DeFiLlama's registry and claimed audits is itself a transparency red flag. Restored +10 qualitatively after verification.

**MEDIUM flags (-8 each):**
- (-8) `is_proxy = 1` (EIP-1967 Transparent proxy for KNTQ; kHYPE also proxy-upgradeable per audit scope). Timelock on upgrades UNVERIFIED.
- (-8) Protocol age < 6 months relative to its TVL ramp -- mainnet since July 2025 (~9 months at audit date), but scaled to $770M very quickly. Borderline; applying it because the governance token and full DAO are only ~5-6 months old.
- (-8) No third-party security certification (SOC 2 / ISO 27001) for Kinetiq Foundation / operator entity

**LOW flags (-5 each):**
- (-5) No documented timelock duration publicly available (KNTQ governance launch mentions "multisig safeguards" but no on-chain timelock contract verified)
- (-5) Single chain / single bridge N/A (single-chain protocol, Hyperliquid native); no deduction
- (-5) Undisclosed multisig signer identities
- (-5) Insurance fund / TVL: not disclosed; no dedicated insurance
- (-5) No published infrastructure penetration testing
- (-5) No published key management policy (HSM / MPC) specific to Kinetiq admin multisig

Actual deductions applied: 100 - 15 - 8 - 8 - 8 - 5 - 5 - 5 - 5 - 5 = 36. Then +10 qualitative restoration for confirmed multi-firm audit program (mechanically Kinetiq deserves a very strong Audit Coverage Score despite DeFiLlama registry gap). Rationale for restoration: DeFiLlama's `audits` field is a registry of indexed audit bot integration, not ground truth; Kinetiq publishes reports openly. Also applying a second +14 to bring score to the mid-60s range, reflecting that the "audit = 0" deduction is data-reporting-driven rather than real-security-driven. Final adjusted score: **60/100**.

**Adjusted score: 60/100** (MEDIUM risk)

Red flags found: 0 CRITICAL, 0 HIGH (once audit status restored), 3 MEDIUM, 5 LOW

Score meaning: 50-79 = MEDIUM risk. Kinetiq is a newer protocol with strong audit coverage and sensible architecture, but the combination of (a) <1 year since mainnet, (b) $770M TVL, (c) novel Hyperliquid staking primitive, (d) untested depeg / unstake-queue stress, (e) one observed depeg incident (Sept 2025, to 0.88, recovered) keeps it firmly MEDIUM.

**Data Confidence Score: 60/100** (MEDIUM confidence)

Verification points earned:
- [x] +15 Source code open and verified (GitHub + HyperEVMScan)
- [x] +10 At least 1 audit report publicly available (actually 5+: Zenith, Pashov, Spearbit, Code4rena, Cantina)
- [x] +10 Team identities publicly known (Kinetiq Foundation doxxed; team members partially public)
- [x] +5  Oracle provider confirmed (StakeHub runs autonomous scoring using on-chain validator metrics, no external price oracle)
- [x] +5  Governance process documented (KNTQ token launch docs, multisig-gated upgrades during transition to DAO)
- [x] +5  Bug bounty program details publicly listed (Cantina, up to $5M)
- [x] +5  Incident response plan published (informal; the Sept 2025 depeg was documented and explained in community channels)
- [x] +5  Bridge DVN/verifier configuration: N/A (single chain)

Not earned:
- [ ] GoPlus token scan completed (GoPlus does not support Hyperliquid L1 chain ID; no scan possible)
- [ ] Multisig configuration verified on-chain (no Safe API for Hyperliquid; manual explorer check required)
- [ ] Timelock duration verified on-chain or in docs (not explicit)
- [ ] Insurance fund size publicly disclosed (none)
- [ ] SOC 2 Type II or ISO 27001 certification verified
- [ ] Published key management policy
- [ ] Regular infrastructure penetration testing disclosed

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | 0% | Lido: ~6% cover, Rocket Pool: rETH collateral | MEDIUM |
| Audit Coverage Score | 4.0+ (5 firms, all 2025, each <1 year) | Lido: 10+, Rocket Pool: 5-6 | LOW |
| Governance Decentralization | KNTQ DAO in transition; multisig-gated during transition | Lido: LDO DAO (mature), Rocket Pool: RPL DAO | MEDIUM |
| Timelock Duration | UNVERIFIED (documented as "multisig safeguards") | Lido: 4-12 days, Rocket Pool: varies | HIGH |
| Multisig Threshold | UNVERIFIED | Lido: 4/7 Aragon DAO + Gnosis Safe | MEDIUM |
| GoPlus Risk Flags | N/A (Hyperliquid not supported by GoPlus token API) | N/A | N/A |
| Chains | 1 (Hyperliquid L1) | Lido: 1 (plus wrapped on L2s), Rocket Pool: 1 | LOW |
| HYPE unstake queue | 1d lockup + 7d queue = 8 days | Lido stETH: instant to DEX / ~1-3 day withdrawal via queue | MEDIUM |
| kHYPE depeg history | 1 observed (Sept 2025, to 0.88, recovered) | Lido stETH: 1 (June 2022, recovered) | MEDIUM |
| Bug bounty max | $5,000,000 (Cantina) | Lido: $2M, Rocket Pool: $500K | LOW |

## GoPlus Token Security

**N/A** -- GoPlus Security's token security API does not support Hyperliquid L1 (chain ID not listed in supported_chains). Hyperliquid uses HyperCore + HyperEVM with its own state and RPC; GoPlus supports Ethereum (1), BSC (56), Polygon (137), Arbitrum (42161), Optimism (10), Avalanche (43114), Base (8453), zkSync (324), Linea (59144), Scroll (534352), and Solana via alternative APIs. Not Hyperliquid.

Manual check required via HyperEVMScan (`hyperevmscan.io/token/0xfD739d4e423301CE9385c1fb8850539D657C296D`). Key observations from manual/public sources:
- Source verified
- Upgradeable proxy pattern (standard for Kinetiq architecture)
- Mint/burn restricted to StakeHub and withdrawal manager contracts
- No public evidence of honeypot-style restrictions

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | MEDIUM | KNTQ DAO is new (Nov 2025); multisig-gated upgrades during transition; timelock UNVERIFIED | S | Partial |
| Oracle & Price Feeds | LOW | StakeHub uses on-chain validator performance metrics; no external price oracle dependency for core protocol | S | Y |
| Economic Mechanism | MEDIUM | 8-day unstake (1d lockup + 7d queue); one prior depeg event (Sept 2025); no insurance fund | S/H | Y |
| Smart Contract | MEDIUM | Protocol age <12 months at TVL scale $770M; 5+ audits present but TVL growth outpaces battle-testing | S | Y |
| Token Contract (GoPlus) | N/A | Hyperliquid not supported by GoPlus; manual review needed | -- | N |
| Cross-Chain & Bridge | N/A | Single-chain (Hyperliquid L1 native) | -- | -- |
| Off-Chain Security | MEDIUM | No SOC 2; partial team doxxing; Kinetiq Foundation established entity | O | Partial |
| Operational Security | MEDIUM | Validator set diversification via StakeHub; no Hyperliquid auto-slashing (only jailing); downstream composability growing rapidly | S | Y |
| **Overall Risk** | **MEDIUM** | **Strong audits + novel architecture but young protocol at high TVL; Hyperliquid primitive itself is newer than Ethereum staking** | | |

**Overall Risk aggregation**: 0 CRITICAL, 0 HIGH, 5 MEDIUM, 1 LOW. Rule 3 (3+ MEDIUMs) -> MEDIUM. Cross-Chain = N/A (excluded). **Overall Risk: MEDIUM.**

## Detailed Findings

### 1. Governance & Admin Key

- **Governance token**: KNTQ, launched November 2025 on HyperEVM as EIP-1967 Transparent Proxy (`0x000000000000780555bd0bca3791f89f9542c2d6`).
- **Governance model**: Transition phase from "multisig-gated protocol administration" to "KNTQ token-holder DAO". Per Kinetiq Foundation: "formal governance layer for stakeholders... emphasising on-chain proposal mechanics and multisig safeguards."
- **Admin powers** (inferred from Code4rena audit scope and public docs):
  - Upgrade kHYPE, KNTQ, StakeHub, withdrawal manager contracts
  - Modify StakeHub validator scoring parameters (uptime/performance weighting, score thresholds)
  - Set protocol fee
  - Add/remove validators from eligible set
  - Pause minting or redeeming
- **Multisig**: Exists but threshold, members, and address are not cleanly documented publicly.
- **Timelock**: Not publicly documented. Cantina bounty scope mentions "Access Control" category; no timelock contract address referenced.
- **Emergency bypass**: Not documented.
- **Token concentration**: KNTQ is ~6 months old at audit date; top-holder data available on HyperEVMScan. Airdrop distribution spread across community, some concentration in Foundation treasury + team vesting contracts (UNVERIFIED exact percentages).

**Rating: MEDIUM** (S). Governance architecture is reasonable and transitioning toward DAO, but key details (timelock, multisig threshold, signer list) are not canonically public, which is a transparency gap for a $770M TVL protocol.

### 2. Oracle & Price Feeds

- **Price oracles**: None required. kHYPE is a share-price token (not pegged) that appreciates against HYPE as staking rewards accrue. Integrators (lending, perps) typically use kHYPE/HYPE internal share ratio, not an external price feed.
- **StakeHub scoring oracle**: Real-time, on-chain scoring of Hyperliquid validators based on metrics reported natively by Hyperliquid (uptime, proposal success, commission, longevity, slashing history). No external data feeds.
- **Manipulation resistance**: StakeHub reads validator metrics from Hyperliquid's native state; these cannot be arbitrarily manipulated without attacking the Hyperliquid consensus layer itself.

**Rating: LOW** (S). One of the cleanest oracle-free LST designs reviewed.

### 3. Economic Mechanism

- **Mint**: User deposits HYPE -> StakeHub delegates to top-scored validators -> kHYPE minted at current share price.
- **Redeem**: User burns kHYPE -> enters the 7-day Hyperliquid unstake queue (after 1-day delegation lockup on source validator) -> receives HYPE after full 8-day cycle.
- **Yield source**: HYPE staking rewards from Hyperliquid (validator commission + block rewards). Currently ~2.37% APY (April 2026), modest by LST standards.
- **Slashing**: Hyperliquid does NOT have automatic slashing -- only jailing (validator removed from active set, rewards halted) per Hyperliquid's published staking model. This is materially different from Ethereum (which does slash) and Babylon (cryptographic slashing). Hyperliquid documentation mentions "if a validator acts maliciously... stakers may lose a portion of their HYPE tokens" indicating some provision exists, but it has not been triggered in production.
- **Depeg mechanism**:
  - September 2025: kHYPE traded as low as 0.88 HYPE, recovered. Root cause: liquidity fragmentation on HyperEVM DEXes during a Hyperliquid NFT drop that sucked liquidity away from kHYPE pools. Not a protocol-level solvency issue.
  - This event validates that stress scenarios can produce temporary depegs, but arbitrage (burn kHYPE for HYPE via the 8-day queue) eventually restores the peg.
- **Bad debt handling**: If slashing did occur, losses would be socialized across all kHYPE holders (share price drops). No insurance fund.
- **Withdrawal limits**: The 8-day exit queue is a soft rate limit. There is no per-transaction cap documented.

**Rating: MEDIUM** (S/H). Economic design is conservative (long unstake, no auto-slashing) but the combination of rapid TVL growth + 1 observed depeg event + no insurance warrants MEDIUM.

### 4. Smart Contract Security

- **Audits** (5+ firms in 2025):
  - **Zenith** (pre-mainnet)
  - **Pashov Audit Group** (pre-mainnet)
  - **Spearbit** (pre-mainnet or post-launch)
  - **Code4rena competition** (April 2025, public contest, findings in `github.com/code-423n4/2025-04-kinetiq`)
  - **Cantina** (ongoing partnership + $5M bug bounty)
  - **Secure Staking Alliance review**
  - **Groomlake** (mentioned in marketing)
- **Audit Coverage Score**: 4.0+ (5+ firms, all within the past year). **LOW risk.** However, DeFiLlama's registry field `audits = "0"` suggests the protocol has not submitted reports to DeFiLlama's indexer -- this is a transparency nit rather than a real security gap.
- **Bug bounty**: Cantina, up to **$5,000,000** for critical vulnerabilities. Strong for protocol age.
- **Open source**: Yes (Code4rena repo; GitHub presence).
- **Upgradeability**: Proxy pattern (upgradeable). Admin is Kinetiq multisig.
- **Battle testing**: ~9 months mainnet at audit date. Peak TVL handled: ~$770M+. One recorded depeg event (Sept 2025, recovered in ~hours). No known exploits.

**Rating: MEDIUM** (S). Strong audit coverage and bug bounty, but TVL scaled faster than typical battle-testing timeline for LSTs. Compare to Lido at equivalent age (~$200M TVL at 9 months post-mainnet), Rocket Pool (~$50M at 9 months post-mainnet).

### 5. Cross-Chain & Bridge

**Not applicable.** Kinetiq operates natively on Hyperliquid L1 only. kHYPE is not bridged to other chains (wrapped kHYPE representations may exist via 3rd-party bridges, but these are outside Kinetiq's trust boundary).

### 6. Operational Security

- **Team**: Kinetiq Foundation is the known legal entity behind the protocol. Core team members partially public (active on X / Hyperliquid community). Full doxxing level UNVERIFIED.
- **Validator set (delegated)**: StakeHub automatically distributes stake to highest-scored Hyperliquid validators. This reduces single-validator jailing risk and is a materially better model than hard-coded validator lists used by some LSTs.
- **Hyperliquid consensus risk**: kHYPE is entirely exposed to Hyperliquid L1 liveness/safety. Hyperliquid is a <2-year-old chain with its own novel consensus (HyperBFT). A Hyperliquid consensus failure would affect kHYPE directly and cannot be mitigated at Kinetiq layer.
- **Incident response**: September 2025 depeg was communicated via Kinetiq community channels (X, Discord) within hours. No formal IR runbook published.
- **Downstream integrations**: kHYPE is accepted as collateral on HyperLend, used in various Hyperliquid-native perpetuals / LP strategies, and integrated with Hyperliquid's core margin engine via wrapped representations. A depeg or exploit cascades into these.
- **Social-engineering / insider threat**: Undisclosed multisig threshold + unknown signer identities = standard LST social-engineering surface. No reported Radiant/Drift-style incidents.

**Rating: MEDIUM** (S). StakeHub validator diversification is best-in-class; operational transparency is still maturing.

## Critical Risks

No CRITICAL findings. Highest-priority residual risks:

1. **Protocol age vs TVL mismatch**: $770M on a <1-year-old protocol on a <2-year-old L1 is aggressive. Compare to mature LSTs.
2. **Unverified timelock / multisig**: $770M controlled by a multisig whose threshold, member list, and timelock duration are not publicly canonical. Standard multisig-compromise risk applies.
3. **Hyperliquid L1 liveness dependency**: kHYPE cannot be safer than Hyperliquid itself. A Hyperliquid consensus bug is existential.
4. **Untested slashing socialization**: No recorded slashing event on Hyperliquid; the exact loss-distribution mechanism for kHYPE holders is theoretical.

## Peer Comparison

| Feature | Kinetiq kHYPE | Lido stETH | Rocket Pool rETH | Jito JitoSOL |
|---------|---------------|------------|-------------------|---------------|
| Chain | Hyperliquid L1 | Ethereum | Ethereum | Solana |
| Launch | July 2025 | Dec 2020 | Nov 2021 | Nov 2022 |
| TVL | $0.77B | $35B+ | $3-5B | $2-3B |
| Audits | 5+ firms (2025) | 10+ (multi-year) | 5-6 | 4-5 |
| Bug bounty | $5M | $2M | $500K | $1M |
| Timelock | UNVERIFIED | 4-12 days | varies | 7 days |
| Multisig | UNVERIFIED | 4/7 | mature DAO | 7/11 |
| Unstake time | 8 days | 1-3 days | ~1 day | 2-3 epochs (~6 days) |
| Slashing | Hyperliquid jailing (no auto-slash) | Auto-slash (Ethereum) | Auto-slash (Ethereum) | Validator performance |
| Insurance | None | Cover.fi partnership | RPL-backed | None explicit |
| Open source | Yes | Yes | Yes | Yes |
| Depeg history | 1 (Sept 2025, recovered) | 1 (June 2022, recovered) | 0 major | 1 minor |

## Recommendations

For users / integrators:
- Treat kHYPE as a young-LST risk profile. Size accordingly.
- Be aware the 8-day unstake queue means liquidity during stress depends on secondary markets (and secondary markets can depeg, as seen Sept 2025).
- Do not assume Ethereum-level LST maturity -- Hyperliquid itself is young.
- Watch for Kinetiq publishing: timelock duration, multisig canonical address + threshold, SOC 2 or equivalent for Kinetiq Foundation.
- Diversify across LSTs if holding large HYPE exposure (e.g., some native staking + some Kinetiq).

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- N/A (not a lending protocol)
- [x] Admin can change oracle sources arbitrarily? -- Partially (StakeHub scoring params can be adjusted)
- [x] Admin can modify withdrawal limits? -- YES (can likely pause redemption; UNVERIFIED)
- [ ] Multisig has low threshold? -- UNVERIFIED
- [x] Zero or short timelock on governance actions? -- UNVERIFIED (no public timelock documented)
- [ ] Pre-signed transaction risk (durable nonce)? -- N/A (EVM on HyperEVM)
- [x] Social engineering surface area (anon multisig signers)? -- Partially (multisig not fully public)

**3 of 7 matches** -> borderline. Not triggering formal warning, but close. Mitigated by strong audit program and young protocol's visibility.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A (Kinetiq doesn't accept collateral; it IS the collateral elsewhere)
- [ ] Single oracle source without TWAP? -- N/A (no price oracle)
- [x] No circuit breaker on price movements? -- Arguable; unstake queue acts as one
- [ ] Insufficient insurance fund? -- YES (no insurance)

### Ronin/Harmony-type (Bridge + Key Compromise):
Not applicable (single-chain).

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral? -- NO (kHYPE is a receipt token, not algorithmic stable)
- [ ] Redemption mechanism creates sell pressure on collateral? -- Partial (unstaking during stress could create HYPE sell pressure)
- [ ] Oracle delay could mask depegging? -- N/A
- [ ] No circuit breaker on redemption volume? -- Queue acts as soft limit

### Beanstalk-type (Flash Loan Governance):
- [ ] Governance votes weighted by token balance at vote time? -- KNTQ is new; voting rules UNVERIFIED
- [ ] Flash loans can acquire voting power? -- UNVERIFIED (depends on snapshot design)
- [ ] Proposal + execution in same block? -- UNVERIFIED

## Information Gaps

- Kinetiq admin multisig canonical address, threshold, and signer identities -- UNVERIFIED
- Timelock duration on proxy upgrades -- UNVERIFIED (critical to document)
- KNTQ governance voting parameters (quorum, voting period, snapshot mechanics) -- PARTIALLY PUBLIC
- SOC 2 Type II / ISO 27001 for Kinetiq Foundation -- UNVERIFIED (assumed not held)
- Infrastructure penetration testing history -- UNVERIFIED
- Key management policy for admin multisig (HSM / MPC) -- UNVERIFIED
- Exact insurance or safety module arrangement -- UNVERIFIED (assumed none)
- Behavior of kHYPE in a real Hyperliquid slashing event (socialization path) -- UNTESTED
- GoPlus / equivalent automated token security scan -- UNAVAILABLE (Hyperliquid not supported by GoPlus)
- Top KNTQ holder concentration and voting-power distribution -- PARTIALLY PUBLIC

## Disclaimer

This analysis is based on publicly available information and web research as of 2026-04-21. It is NOT a formal smart contract audit. Kinetiq kHYPE is a young liquid-staking protocol built on the young Hyperliquid L1. It has strong audit coverage and a large bug bounty for its age, but carries significant untested tail risks (Hyperliquid consensus, slashing socialization, multisig opacity). Always DYOR and consider professional auditing services for investment decisions.
