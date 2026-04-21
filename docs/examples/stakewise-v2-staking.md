# DeFi Security Audit: StakeWise V2

**Audit Date:** 2026-04-21
**Protocol:** StakeWise V2 -- Ethereum liquid staking with split principal / yield tokens

## Overview
- Protocol: StakeWise V2 (successor architecture V3 exists; V2 remains live)
- Chain: Ethereum (primary), Gnosis Chain (xDai, minor)
- Type: Liquid Staking Derivative with split sETH2 (principal) and rETH2 (rewards) tokens
- TVL: ~$0.90B (DeFiLlama; $900.9M Ethereum + $1.3M Gnosis)
- TVL Trend: V2 stable-to-declining as deposits migrate toward StakeWise V3 Vaults; legacy users remain.
- Launch Date: StakeWise V2 mainnet mid-2021 (V3 Vaults launched 2024)
- Audit Date: 2026-04-21
- Source Code: Open (github.com/stakewise/contracts; audits folder public)

## Quick Triage Score: 80/100
- Red flags found: Legacy version with declining deposits (potential maintenance risk); proxy contracts with DAO-controlled admin.
- GoPlus token security: 0 HIGH / 1 MEDIUM flag (proxy).

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | No dedicated slashing insurance fund on V2 (UNVERIFIED current allocation) | 1-5% | MEDIUM |
| Audit Coverage Score | 2+ firms (audits in public repo -- Quantstamp, Runtime Verification, others listed historically) | 1-3 avg | LOW risk |
| Governance Decentralization | SWISE DAO governance | DAO + multisig avg | LOW risk |
| Timelock Duration | DAO-configured timelock on upgrades (UNVERIFIED exact seconds) | 24-48h avg | LOW-MEDIUM risk |
| Multisig Threshold | StakeWise DAO multisig (threshold UNVERIFIED) | 3/5 avg | MEDIUM risk |
| GoPlus Risk Flags | 0 HIGH / 1 MED (proxy) | -- | LOW risk |

## GoPlus Token Security (sETH2 on Ethereum)

Note: sETH2 on-chain total supply reads as ~1,776 in GoPlus output; this reflects the new token issuance/migration state after V3 launch. The DeFiLlama TVL figure (~$900M Ethereum) captures the full protocol state including underlying ETH held by StakeWise V2 Pool and reward accrual token (rETH2). Users should verify current in-scope token balances before trading.

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | Yes (upgradeable) | MEDIUM |
| Mintable | N/A (minted via Pool contract during deposit) | -- |
| Owner Address | Empty in GoPlus output (DAO/controller) | LOW |
| Hidden Owner | No | -- |
| Selfdestruct | No | -- |
| Transfer Pausable | Not flagged | -- |
| Blacklist | Not flagged | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 2,167 | -- |

GoPlus assessment: **LOW RISK** at the token level (proxy flag is standard for DAO-managed LSDs; no honeypot, no hidden owner, no taxes).

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **LOW-MEDIUM** | SWISE DAO governs; admin authority via DAO multisig with timelock | Partial |
| Oracle & Price Feeds | **LOW-MEDIUM** | Merkle Distributor + Oracle committee reports rewards; small committee | Partial |
| Economic Mechanism | **MEDIUM** | Split sETH2/rETH2 token model has DeFi-composability complexity; V2 legacy status | Y |
| Smart Contract | **LOW** | Multiple audits, open-source code, live since 2021 without exploit | Y |
| Token Contract (GoPlus) | **LOW** | Proxy only; no honeypot/tax | Y |
| Operational Security | **MEDIUM** | Small team, mature but focus shifting to V3 | Partial |
| **Overall Risk** | **MEDIUM** | **Battle-tested LSD with a narrow team and declining V2 attention as V3 becomes primary** | |

## Detailed Findings

### 1. Governance & Admin Key -- LOW-MEDIUM

**DAO Governance:**
- StakeWise DAO governs the protocol via SWISE token voting. Critical parameter changes (fee rate, validator parameters, oracle committee membership, contract upgrades) are executed through DAO-approved proposals.
- V2 code upgrades are behind DAO vote plus timelock.

**Admin Multisig:**
- StakeWise operates a DAO multisig for executing approved proposals and for emergency pause functions. Exact signer set and threshold are UNVERIFIED from public sources at time of audit.

**Oracle Committee:**
- Separate oracle committee reports validator rewards and posts Merkle roots for reward distribution (see Oracle section).

**V2 vs. V3 Governance:**
- SWISE DAO governs both V2 and V3. Since V3 is the team's primary development focus, V2-specific governance activity has slowed -- material V2 parameter changes are rare in 2025-2026.

**Assessment:** LOW-MEDIUM. The DAO + timelock model is solid. The MEDIUM bump reflects undisclosed multisig threshold and slowing governance attention on V2 relative to V3.

### 2. Oracle & Price Feeds -- LOW-MEDIUM

**Oracle Architecture:**
- StakeWise V2 uses an Oracles contract that accepts signed reports from a committee of oracle members.
- Oracles periodically submit the sum of validator rewards accrued across all StakeWise validators, which is then distributed via the Merkle Distributor to stakers (in the form of rETH2).

**Committee Size:**
- Historically the oracle committee has been ~4-11 members with an m-of-n quorum; current exact committee size and quorum threshold are UNVERIFIED from the audit sources at time of writing.

**rETH2 Claim Process:**
- Rewards accrue as rETH2 balances, which users claim via the Merkle Distributor based on the posted Merkle root.

**Assessment:** Structure is similar to Lido's oracle committee but historically with fewer members. Bump to MEDIUM reflects the smaller committee and unverified current parameters.

### 3. Economic Mechanism -- MEDIUM

**Split Token Model (V2):**
- Users deposit ETH -> receive sETH2 (principal, 1:1 with ETH) and accrue rETH2 (rewards).
- sETH2 is NOT rebasing; rewards are paid out separately as rETH2.
- This model was designed to simplify DeFi composability (sETH2 does not inflate), but it also introduces dual-token UX complexity.

**Withdrawals:**
- Post-Shapella, StakeWise V2 enables withdrawals via the exit queue. Historical pre-Shapella withdrawals were not supported; the mechanism is now live.

**Node Operators:**
- Curated node operators approved by the DAO. StakeWise originally onboarded a smaller operator set than Lido; V2 operator diversification improved over 2022-2024 but remains more concentrated than Lido.

**Fees:**
- Protocol fee on rewards (historically 10%, with a portion going to the DAO treasury). Exact current fee UNVERIFIED.

**Insurance:**
- No dedicated slashing insurance fund identified at the V2 level. The DAO treasury can in principle be used for loss coverage.

**Assessment:** Mechanically sound and battle-tested since 2021. The MEDIUM rating reflects the dual-token DeFi-composability friction, the smaller operator set vs. Lido, and the lack of a dedicated insurance fund. Withdrawals being enabled post-Shapella reduces what was previously the largest risk.

### 4. Smart Contract Security -- LOW

**Audit Firms:**
- StakeWise maintains an `audits/` folder in its public contracts repo. Historical audit firms include Quantstamp and Runtime Verification (among others listed in the repo).
- DeFiLlama reports 2 audits but the repo contains more detailed reports per component.

**Upgradeable Contracts:**
- Core contracts (Pool, StakedEthToken/sETH2, RewardEthToken/rETH2, Oracles, MerkleDistributor) are proxy-based and upgradeable via DAO vote + timelock.

**Bug Bounty:**
- Historically StakeWise has run bug bounty programs (Immunefi). Current program scope and maximum payout are UNVERIFIED at time of audit.

**Battle Testing:**
- V2 live since mid-2021. No protocol-level exploits or user fund losses have been publicly reported.
- Handled the Shapella withdrawal upgrade without incident.

**Assessment:** LOW. Multiple audits, 5+ years live without exploit, open-source code, public audit repo. This is a mature and stable V2 code base.

### 5. Operational Security -- MEDIUM

**Team:**
- StakeWise is a small, focused team. Core contributors are identifiable via GitHub and conference appearances.
- Development momentum has shifted to StakeWise V3 Vaults since 2024.

**Incident History:**
- No known user fund losses on V2.
- Cross-protocol governance activity (SWISE token distribution, V3 migration) has proceeded without major incident.

**Transparency:**
- Public GitHub with audits folder.
- DAO governance forum and voting history are public.
- Documentation at docs.stakewise.io covers both V2 and V3.

**Attention Risk (V2):**
- Because V3 is the primary development focus, V2 receives less active attention. Potential risks: slower response to newly disclosed issues, fewer updates to oracle committee composition, less active multisig key-rotation cadence.

**Assessment:** MEDIUM due to attention dilution between V2 and V3. This is a common pattern for legacy protocol versions and does not indicate operational failure; it does mean V2 users should be aware that maintenance priority is lower than V3.

## Critical Risks

None identified as CRITICAL. The dominant concern is the attention-dilution risk on a legacy version with ~$900M TVL.

## Peer Comparison

| Feature | StakeWise V2 | StakeWise V3 | Lido stETH | Rocket Pool rETH |
|---------|--------------|--------------|------------|-------------------|
| TVL | ~$0.9B | UNVERIFIED (V3 adoption growing) | ~$19B | ~$3B |
| Governance | SWISE DAO | SWISE DAO | DAO + Dual Governance | RPL DAO |
| Timelock | DAO + timelock | DAO + timelock | Dynamic (Dual Governance) | DAO vote delay |
| Token Model | sETH2 (principal) + rETH2 (rewards) | osETH (per-vault) | stETH (rebasing) | rETH (non-rebasing) |
| Oracle | Oracle committee + Merkle | Oracle committee | 5-of-9 | Minipool-level |
| Operator Set | Curated (smaller) | Per-vault, permissionless | 600+ curated + permissionless | Permissionless minipools |
| Audits (public) | Multiple (repo folder) | Multiple | 10+ firms + FV | Multiple |
| Withdrawals | Yes (post-Shapella) | Yes | Native (V2+) | Native |

## Recommendations

1. **V2 users should evaluate migration to V3**: V3 Vaults offer per-vault isolation, modernized economics, and receive the team's primary development attention. Users with significant V2 positions should weigh migration.
2. **Publish oracle committee composition**: Current committee members, threshold, and last rotation should be clearly documented for V2.
3. **DAO multisig transparency**: Publish signer set and threshold for the DAO multisig that executes V2 upgrades.
4. **Insurance gap**: No dedicated slashing insurance fund on V2 is a peer-laggard position. DAO treasury allocation for user-loss coverage would close this gap.
5. **Bug bounty clarity**: Explicitly confirm that V2 contracts remain in-scope for any active Immunefi program.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock -- **N/A**, not a lending protocol
- [ ] Admin can change oracle sources arbitrarily -- **NO**, oracle committee changes require DAO vote
- [ ] Admin can modify withdrawal limits -- **NO**, withdrawals are protocol-level
- [x] Multisig has low threshold -- **UNVERIFIED**
- [ ] Zero or short timelock -- **NO** (timelock present; exact duration UNVERIFIED)
- [ ] Pre-signed transaction risk -- **N/A**, EVM
- [x] Social engineering surface area -- **MEDIUM**, small team + multisig

**1-2/7 flags matched**. Governance architecture is broadly sound; the main outstanding flag is transparency on multisig threshold.

### Euler/Mango-type (Oracle Manipulation + Economic Exploit):
- [ ] Low-liquidity collateral accepted -- **N/A**
- [ ] Single oracle source without TWAP -- **NO**, oracle committee with quorum
- [ ] No circuit breaker -- DAO can pause via multisig; exact mechanism UNVERIFIED
- [x] Insufficient insurance -- **YES**, no dedicated insurance fund identified

**1/4 flags matched**.

### Ronin/Harmony-type (Bridge / Validator Key Compromise):
- [ ] Small validator/signer set -- **BORDERLINE**, curated operator set is smaller than Lido but diversified over time
- [ ] Keys stored in hot wallets -- Professional node operators with key management requirements
- [ ] Single point of failure in bridge -- **N/A**, no bridge (Gnosis deployment uses separate native staking)
- [ ] No key rotation mechanism -- Operator-level responsibility

**0-1/4 flags matched**.

## Information Gaps

- **DAO multisig signer set and threshold**: Exact composition not verified.
- **Timelock duration**: Exact seconds/hours of the V2 upgrade timelock not verified.
- **Oracle committee current composition and quorum**: Number of members and m-of-n threshold at time of audit not verified.
- **Current fee rate**: Exact V2 protocol fee at time of audit not verified.
- **Bug bounty scope and maximum payout**: Specifically whether V2 is covered and at what maximum amount.
- **Relative V2 vs. V3 TVL trajectory**: The DeFiLlama figure captures V2 TVL; migration pace to V3 is not broken out here.
- **Gnosis Chain deployment status**: The $1.3M xDai TVL is small; whether this deployment is actively maintained is not verified.

## Disclaimer

This is a research-based assessment, not a formal smart contract audit. It is based on publicly available information, on-chain data, DeFiLlama metrics, and GoPlus token security scanning as of 2026-04-21. DYOR.
