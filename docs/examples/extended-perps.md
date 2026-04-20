# DeFi Security Audit: Extended

## Overview
- Protocol: Extended (formerly X10)
- Chain: Starknet (primary), Ethereum (minor bridge component)
- Type: Perpetual DEX (hybrid CLOB)
- TVL: $174.7M (DeFiLlama, 2026-04-20)
- TVL Trend: -2.7% / -9.1% / -16.4% (7d / 30d / 90d)
- Launch Date: August 2025 (Starknet mainnet; previously on StarkEx since late 2024)
- Audit Date: 2026-04-20
- Valid Until: 2026-07-19 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Open (contracts publicly accessible on Voyager explorer)

## Quick Triage Score: 32/100 | Data Confidence: 40/100

**Triage Score Computation** (start at 100, subtract mechanically):

CRITICAL flags (-25 each): None triggered.

HIGH flags (-15 each):
- [x] Zero audits listed on DeFiLlama (-15) -- DeFiLlama shows "0" audits; 2 audits exist per third-party review sources but are not registered with DeFiLlama
- [x] No multisig (single EOA admin key) (-15) -- multisig claimed in review articles but no on-chain address, threshold, or signer count published; UNVERIFIED

MEDIUM flags (-8 each):
- [x] No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations (-8)

LOW flags (-5 each):
- [x] No bug bounty program (-5) -- no Immunefi listing found
- [x] Single oracle provider (-5) -- uses "independent external oracle mark prices" but specific provider not documented
- [x] Insurance fund / TVL < 1% or undisclosed (-5) -- fund structure documented but absolute size not disclosed
- [x] Undisclosed multisig signer identities (-5)
- [x] No published key management policy (HSM, MPC, key ceremony) (-5)
- [x] No disclosed penetration testing (-5)

**Deductions**: 0 (CRITICAL) + 30 (HIGH) + 8 (MEDIUM) + 30 (LOW) = **68 points deducted**
**Score: 100 - 68 = 32/100 (HIGH risk)**

Flags NOT triggered: protocol age < 6 months (8 months, does not apply); TVL drop >30% in 90d (16.4%, does not apply); GoPlus flags (N/A, no token / Starknet unsupported).

- Red flags found: 9 (zero DeFiLlama audits, unverified multisig, no SOC2/ISO, no bug bounty, undisclosed oracle, undisclosed insurance size, undisclosed signers, no key mgmt policy, no pentest)

**Data Confidence Score Computation** (start at 0, add verified points):

- [x] +15 Source code is open and verified on block explorer
- [ ] +15 GoPlus token scan completed -- N/A (no token; Starknet unsupported by GoPlus)
- [x] +10 At least 1 audit report publicly available (StarkWare March 2024 + Nethermind August 2025 per review sources; reports not directly downloadable)
- [ ] +10 Multisig configuration verified on-chain -- NOT VERIFIED
- [ ] +10 Timelock duration verified on-chain or in docs -- 48h claimed, UNVERIFIED on-chain
- [x] +10 Team identities publicly known (doxxed) -- Ruslan Fakhrutdinov, ex-Revolut
- [ ] +10 Insurance fund size publicly disclosed -- structure disclosed, absolute size not
- [ ] +5 Bug bounty program details publicly listed
- [ ] +5 Governance process documented -- token not launched
- [x] +5 Oracle provider(s) confirmed -- "independent external oracle mark prices" referenced in docs
- [ ] +5 Incident response plan published
- [ ] +5 SOC 2 Type II or ISO 27001 certification verified
- [ ] +5 Published key management policy
- [ ] +5 Regular penetration testing disclosed
- [ ] +5 Bridge DVN/verifier configuration publicly documented -- N/A

**Score: 15 + 10 + 10 + 5 = 40/100 (LOW confidence)**

- Data points verified: 4 / 14 checkable (1 item N/A excluded)

## Quantitative Metrics
| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (structure documented, size not) | GMX: ~2-5%, Hyperliquid: ~1% | HIGH |
| Audit Coverage Score | 1.0 (1 audit <1yr) + 0.5 (1 audit 1-2yr) = 1.5 | GMX: ~3.5, dYdX: ~4.0 | HIGH |
| Governance Decentralization | Pre-token, centralized team control | GMX: DAO + multisig, dYdX: DAO + council | HIGH |
| Timelock Duration | 48h (claimed, UNVERIFIED) | GMX: 12-672h, dYdX: 24-48h | MEDIUM |
| Multisig Threshold | Claimed but unverified (no address published) | GMX: 4/N, dYdX: council multisig | HIGH |
| GoPlus Risk Flags | N/A (no token, Starknet unsupported) | -- | N/A |

## GoPlus Token Security

N/A -- Extended does not have a live token. The EXT governance token TGE is planned for H1 2026. Starknet is not supported by GoPlus token security API. When the token launches, this section should be re-evaluated.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | HIGH | No verified multisig; pre-token centralized control; 48h timelock claimed but unverified | S/O | N |
| Oracle & Price Feeds | MEDIUM | Oracle provider not named; single source assumed; no documented fallback | S | N |
| Economic Mechanism | MEDIUM | Insurance fund size undisclosed; 5% daily depletion cap is protective but untested at scale | S | Partial |
| Smart Contract | MEDIUM | 2 audits exist but reports not publicly linked; Starknet deployment < 1 year old | S/H | Partial |
| Token Contract (GoPlus) | N/A | No token exists yet | -- | N/A |
| Cross-Chain & Bridge | LOW | Minimal bridge component (Ethereum $245K); Starknet is primary chain | S | Partial |
| Off-Chain Security | HIGH | No SOC2/ISO, no published key mgmt, no pentest disclosure, no incident response plan | O | N |
| Operational Security | MEDIUM | Doxxed team (ex-Revolut), $6.5M raised, StarkWare backing; but no bug bounty | S/O | Partial |
| **Overall Risk** | **HIGH** | **Governance HIGH (2x weight) drives overall to HIGH; significant verification gaps** | | |

**Overall Risk aggregation**: Governance & Admin = HIGH (counts as 2x = 2 HIGHs). Off-Chain Security = HIGH. That is 3 HIGHs total. Per rule: "If 2+ categories are HIGH -> Overall = HIGH." Result: **HIGH**.

## Detailed Findings

### 1. Governance & Admin Key

**Admin Key Surface Area**: Extended operates as a hybrid CLOB where order processing, matching, position risk checks, and sequencing happen off-chain, while validation and settlement occur on-chain via Starknet smart contracts. The team has full control over the off-chain matching engine and sequencer.

**Multisig**: One review source (insidecryptoreview.com) claims "multisig wallet administration for critical functions," but no multisig address, threshold, or signer count has been publicly documented. No Safe/Squads address is verifiable. This is rated HIGH because the claim is UNVERIFIED.

**Timelock**: The same source claims a "48-hour timelock on governance actions." This is a reasonable duration if verified, but no on-chain timelock contract address or evidence has been published. UNVERIFIED.

**Governance Token**: The EXT token TGE is planned for H1 2026. Until the token launches, governance is entirely centralized with the team. There is no DAO, no on-chain voting, and no community governance mechanism in place.

**Upgrade Mechanism**: Smart contracts are deployed on Starknet. Contract upgradeability status is not documented. The contract class hash (0x055ca2...) is publicly known, but whether the contract is behind a proxy or who controls upgrades is UNVERIFIED.

**Timelock Bypass**: No information available about emergency roles, security councils, or bypass mechanisms.

**Risk Rating: HIGH** -- Centralized control with unverified claims of multisig and timelock. Pre-token governance means the team has unilateral control over all protocol parameters.

### 2. Oracle & Price Feeds

**Oracle Architecture**: Extended's documentation references "independent external oracle mark prices" for liquidation triggers and mark price calculations. The specific oracle provider (Pragma, Pyth, Chainlink, or custom) is not publicly documented.

Starknet ecosystem supports Pragma, Pyth, and Chainlink oracle integrations. Extended likely uses one of these, but the exact provider and configuration are undisclosed.

**Fallback Mechanism**: No documented oracle fallback or multi-oracle redundancy.

**Circuit Breaker**: The on-chain validation ensures "trades must respect user-defined price constraints and cannot be executed at a price worse than the specified limit." Funding rates have "on-chain limits on maximum funding rates per period." These are protective but not equivalent to a dedicated price circuit breaker.

**Admin Override**: Whether the admin can change oracle sources is UNVERIFIED.

**Risk Rating: MEDIUM** -- Oracle usage is confirmed but provider and redundancy are undisclosed, creating opacity risk. On-chain validation of price constraints provides some protection.

### 3. Economic Mechanism

**Liquidation Mechanism**: Well-documented graduated liquidation process:
1. Two-stage margin call warnings (66% and 80% margin ratio)
2. Partial liquidation (5 x 20% Fill-or-Kill orders at bankruptcy price)
3. Full liquidation at 5% worse than bankruptcy price if partials fail
4. ADL (Auto-Deleveraging) as final backstop

The liquidation process is on-chain verified, meaning "each liquidation must improve the user's Total Value to Total Risk ratio." This is a strong structural protection.

**Insurance Fund (Vault)**: The Extended Vault is a tiered insurance mechanism:
- Group 1 markets: 2.5% daily access, $100K max loss per trade
- Groups 2-7: progressively lower limits ($5K-$50K max loss per trade)
- Global constraint: fund cannot be depleted more than 5% in 24 hours

The fund structure is well-designed with daily depletion caps. However, the absolute fund size is not publicly disclosed, making it impossible to assess adequacy relative to TVL ($174.7M) or open interest (~$327M).

**Funding Rate Model**: Subject to on-chain limits on maximum funding rates per period. Specific rate caps not documented.

**Leverage**: Up to 100x on some assets (originally marketed as 50x, now up to 100x). High leverage increases liquidation cascade risk during extreme volatility.

**Risk Rating: MEDIUM** -- Liquidation mechanism is well-designed and on-chain verified. Insurance fund structure is reasonable with daily caps. However, undisclosed fund size and 100x leverage are risk factors.

### 4. Smart Contract Security

**Audit History**:
1. StarkWare audit (March 2024) -- covering StarkEx integration (the pre-Starknet deployment)
2. Nethermind audit (August 2025) -- covering Starknet migration

Audit Coverage Score: 1.0 (Nethermind, <1 year old) + 0.5 (StarkWare, 1-2 years old) = 1.5. This is at the LOW end of MEDIUM (threshold: 1.5-2.99).

Neither audit report appears to be publicly linked or downloadable. DeFiLlama lists 0 audits for the protocol, indicating the reports have not been submitted to DeFiLlama's audit database.

**Bug Bounty**: No active bug bounty program found on Immunefi or any other platform.

**Open Source**: Smart contracts are open source and publicly accessible on Voyager explorer. Contract class: 0x055ca2019a8677a996e7b583c5c9d0147d2854d0c477716af685e926ee4a5463.

**Battle Testing**: Starknet mainnet deployment live since August 2025 (~8 months). No known exploits or security incidents. Total trading volume ~$180B in first 6 months. Previously operated on StarkEx, which itself has been audited by multiple parties (including ChainSecurity).

**Starknet Security**: Starknet is a Stage 1 zk-rollup. All state transitions are verified through zero-knowledge proofs, providing a strong security baseline. Every transaction triggers a full on-chain health check.

**Risk Rating: MEDIUM** -- Two audits exist but reports are not public. No bug bounty is a notable gap. Open source code and Starknet's ZK verification provide structural safety. No past incidents.

### 5. Cross-Chain & Bridge

Extended is primarily a Starknet-native protocol with a minor Ethereum component ($245K TVL on Ethereum vs $174.4M on Starknet). The Ethereum component likely relates to the StarkGate bridge for L1-L2 asset transfers, which is part of Starknet's canonical infrastructure (audited by multiple firms independently of Extended).

The team is "actively building a direct on-ramp from other chains" but multi-chain deployment is not yet live.

**Risk Rating: LOW** -- Single-chain deployment on Starknet with canonical bridge dependency. StarkGate is independently audited. No third-party bridge risk.

### 6. Operational Security

**Team & Track Record**: Led by Ruslan Fakhrutdinov, former Head of Crypto Operations at Revolut. Team composed of ex-Revolut executives with fintech background. Raised $6.5M from Tioga Capital, Semantic Ventures, Prelude, StarkWare, Cyber Fund, Revolut executives, and Lido co-founder Konstantin Lomashuk. Doxxed team with credible institutional background.

**Incident Response**: No published incident response plan. No documented emergency response time benchmarks. The protocol has an emergency pause capability (mentioned in the context of on-chain validation), but details are not public.

**Bug Bounty**: No active bug bounty program found. This is a significant gap for a protocol with $174.7M TVL.

**Off-Chain Controls**: No SOC 2, ISO 27001, or equivalent certification disclosed. No published key management policy. No disclosed penetration testing. The team's Revolut background suggests familiarity with institutional security practices, but nothing is publicly verifiable.

**Dependencies**: Starknet L2 (operational dependency), StarkGate bridge (asset bridging), unnamed oracle provider(s).

**US Access**: The platform is not accessible to US users.

**Risk Rating: MEDIUM** (Operational) / **HIGH** (Off-Chain Security) -- Doxxed team with strong pedigree offsets some operational risk. However, complete absence of published security certifications, key management practices, and bug bounty makes off-chain security HIGH risk.

## Critical Risks

1. **UNVERIFIED multisig and timelock** -- The protocol claims multisig administration and 48h timelock, but no on-chain evidence, addresses, or threshold configurations have been published. If these controls do not exist or are weaker than claimed, the team has unilateral control over user funds and protocol parameters.
2. **No bug bounty program** -- A $174.7M TVL protocol with no active bug bounty on Immunefi or elsewhere is a significant gap. Whitehat researchers have no incentive path to report vulnerabilities.
3. **Undisclosed oracle provider** -- Liquidation prices depend on "independent external oracle mark prices" but the provider is unnamed. A compromised or manipulated oracle could trigger unfair liquidations on 100x leveraged positions.
4. **Undisclosed insurance fund size** -- The fund structure (tiered limits, 5% daily cap) is well-designed, but without knowing the absolute size, it is impossible to assess whether the fund can handle a black swan event on $327M open interest.
5. **Pre-token centralized governance** -- Until the EXT token launches and a DAO is established, the team has unilateral control over all protocol parameters, market listings, and risk settings.

## Peer Comparison
| Feature | Extended | GMX (Arbitrum) | Hyperliquid |
|---------|----------|----------------|-------------|
| Timelock | 48h (UNVERIFIED) | 12h (on-chain verified) | N/A (L1 chain) |
| Multisig | Claimed, unverified | 4/N (verified) | Validator set |
| Audits | 2 (reports not public) | 5+ (multiple firms, public) | 2+ (public) |
| Oracle | Undisclosed | Chainlink + custom | Pyth + custom |
| Insurance/TVL | Undisclosed | ~2-5% | ~1% (Assistance Fund) |
| Open Source | Yes (Voyager) | Yes (GitHub) | Partial |
| Bug Bounty | None | $5M (Immunefi) | None published |
| Max Leverage | 100x | 100x | 50x |
| TVL | $174.7M | ~$800M | ~$6.2B |
| Token | Not launched | GMX (live) | HYPE (live) |

## Recommendations

1. **Verify multisig on-chain before depositing significant funds** -- Request the team publish the multisig address, threshold, and signer identities. Until verified, treat governance controls as single-key.
2. **Wait for bug bounty launch** -- A protocol at this TVL should have a funded bug bounty. Consider reducing exposure until one is established.
3. **Monitor EXT token launch governance design** -- The transition from centralized team control to token-based governance is a critical inflection point. Evaluate the governance framework when published.
4. **Use conservative leverage** -- 100x leverage on a protocol with undisclosed insurance fund size and unverified oracle setup creates compounding risk. Consider staying well below maximum leverage.
5. **Track audit report publication** -- Request the team publish the StarkWare and Nethermind audit reports publicly. Unverifiable audit claims are nearly as concerning as no audits.
6. **Set withdrawal alerts** -- Given unverified admin controls, monitor for any governance proposals or parameter changes. The claimed 48h timelock, if real, provides a response window.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- UNVERIFIED (assumed possible given centralized control)
- [x] Admin can change oracle sources arbitrarily? -- UNVERIFIED
- [x] Admin can modify withdrawal limits? -- UNVERIFIED
- [x] Multisig has low threshold (2/N with small N)? -- UNVERIFIED (no threshold published)
- [ ] Zero or short timelock on governance actions? -- 48h claimed (would be adequate if verified)
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (Starknet, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- Signers undisclosed

**WARNING: 5/7 Drift-type indicators triggered.** The combination of unverified multisig, undisclosed oracle configuration, and centralized team control creates a governance attack surface similar to the Drift pattern. The key mitigant is the doxxed team with institutional background (ex-Revolut), which significantly raises the cost of an insider attack.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- USDC primary collateral, low risk
- [x] Single oracle source without TWAP? -- Oracle provider undisclosed, TWAP not documented
- [ ] No circuit breaker on price movements? -- On-chain price constraint validation exists
- [x] Insufficient insurance fund relative to TVL? -- Fund size undisclosed

2/4 indicators triggered. Below warning threshold.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Canonical StarkGate bridge
- [x] Admin keys stored in hot wallets? -- Key storage unknown
- [x] No key rotation policy? -- No published policy

2/3 indicators triggered. Below warning threshold.

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time (no snapshot)? -- N/A (no token)
- [ ] Flash loans can be used to acquire voting power? -- N/A
- [ ] Proposal + execution in same block or short window? -- N/A
- [ ] No minimum holding period for voting eligibility? -- N/A

0/4 indicators triggered. N/A -- no governance token.

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? -- No (USDC primary)
- [ ] Read-only reentrancy risk (cross-contract callbacks before state update)? -- Cairo/Starknet reduces this risk
- [ ] Flash loan compatible without reentrancy guards? -- ZK proof validation mitigates
- [ ] Composability with protocols that expose callback hooks? -- Limited Starknet DeFi composability

0/4 indicators triggered.

### Curve-type (Compiler / Language Bug):
- [x] Uses non-standard or niche compiler (Vyper, Huff)? -- Cairo (niche, Starknet-specific)
- [ ] Compiler version has known CVEs? -- No known Cairo compiler CVEs
- [ ] Contracts compiled with different compiler versions? -- Unknown
- [x] Code depends on language-specific behavior (storage layout, overflow)? -- Cairo's felt type has specific overflow behavior

2/4 indicators triggered. Below warning threshold. Note: Cairo is newer and less battle-tested than Solidity/Vyper, which is a systemic Starknet ecosystem risk rather than Extended-specific.

### UST/LUNA-type (Algorithmic Depeg Cascade):
N/A -- Extended is a perps DEX, not a stablecoin protocol.

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
N/A -- Extended is primarily single-chain on Starknet with minimal bridge exposure.

## Information Gaps

The following questions could NOT be answered from publicly available information:

1. **Multisig address and configuration** -- No on-chain address, threshold, or signer list published
2. **Timelock contract address** -- 48h timelock claimed but no contract address or on-chain verification
3. **Oracle provider identity** -- "Independent external oracle" referenced but specific provider (Pragma, Pyth, Chainlink) not named
4. **Insurance fund absolute size** -- Fund structure documented but total assets undisclosed
5. **Audit report contents** -- Two audits claimed (StarkWare, Nethermind) but reports not publicly available
6. **Contract upgradeability** -- Whether contracts use proxy patterns and who controls upgrades
7. **Emergency pause mechanism** -- Whether team can pause trading and under what conditions
8. **Key management practices** -- HSM, MPC, key ceremony procedures not disclosed
9. **Off-chain matching engine security** -- The off-chain sequencer/matcher is a critical component but its security architecture is opaque
10. **Revenue and fee distribution** -- How protocol revenue is allocated (team, insurance fund, future token holders)
11. **GoPlus token analysis** -- Cannot be performed until EXT token launches and if deployed on an EVM-supported chain
12. **On-chain verification of admin controls** -- Starknet is not supported by the onchain-check.sh script (Safe API, Etherscan); manual verification would require Voyager/Starkscan analysis

These gaps are significant. The protocol presents well-designed economic mechanisms (tiered insurance, graduated liquidation) but the governance and admin layer is almost entirely opaque. The claimed 48h timelock and multisig, if verified, would substantially improve the risk profile.

## Disclaimer
This analysis is based on publicly available information and web research as of 2026-04-20.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions. Extended operates
on Starknet, which limits the applicability of standard EVM verification tools.
Several key claims (multisig, timelock) could not be independently verified.
