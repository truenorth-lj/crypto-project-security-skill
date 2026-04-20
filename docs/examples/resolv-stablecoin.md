# DeFi Security Audit: Resolv

**Audit Date:** April 20, 2026
**Protocol:** Resolv -- Delta-neutral stablecoin protocol (USR)

## Overview
- Protocol: Resolv
- Chain: Ethereum
- Type: Basis Trading / Delta-Neutral Stablecoin
- TVL: ~$57.6M
- TVL Trend: -16.5% / -59.3% / -89.6% (7d / 30d / 90d)
- Launch Date: January 2025 (DeFiLlama listing: Jan 23, 2025)
- Audit Date: April 20, 2026
- Valid Until: July 19, 2026 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Open (GitHub: resolv-im)

## Quick Triage Score: 16/100 | Data Confidence: 55/100

### Quick Triage Score Calculation

```
Start at 100.

CRITICAL flags (-25 each):
  [ ] GoPlus: is_honeypot = 1                          -- N/A (USR not scannable)
  [ ] GoPlus: honeypot_with_same_creator = 1           -- N/A
  [ ] GoPlus: hidden_owner = 1                         -- N/A
  [ ] GoPlus: owner_change_balance = 1                 -- N/A
  [ ] TVL = $0                                         -- No (TVL = $57.6M)
  [ ] Admin/deployer address flagged as malicious       -- Not checked

HIGH flags (-15 each):
  [x] Closed-source contracts (is_open_source = 0)     -- No, open source. SKIP.
  [x] Zero audits listed on DeFiLlama                  -- YES. -15
  [ ] Anonymous team with no prior track record         -- No (doxxed team)
  [ ] GoPlus: selfdestruct = 1                         -- N/A
  [ ] GoPlus: can_take_back_ownership = 1              -- N/A
  [x] No multisig (single EOA admin key)               -- YES (SERVICE_ROLE was single EOA). -15
  [ ] Single bridge provider for cross-chain (5+ chains) -- N/A (single chain)

MEDIUM flags (-8 each):
  [x] GoPlus: is_proxy = 1 AND no timelock on upgrades -- RESOLV token is proxy; timelock unclear. -8
  [ ] GoPlus: is_mintable = 1                          -- N/A for USR scan
  [ ] Protocol age < 6 months with TVL > $50M          -- No (>15 months old)
  [x] TVL dropped > 30% in 90 days                    -- YES (-89.6%). -8
  [ ] Multisig threshold < 3 signers                   -- UNVERIFIED
  [ ] GoPlus: slippage_modifiable = 1                  -- N/A
  [ ] GoPlus: transfer_pausable = 1                    -- N/A
  [x] No third-party security certification             -- YES. -8
  [ ] Bridge token accepted as lending collateral on 3+ protocols -- N/A

LOW flags (-5 each):
  [x] No documented timelock on admin actions          -- YES (72h timelock exists per postmortem, but not pre-disclosed). -5
  [ ] No bug bounty program                            -- No (Immunefi exists)
  [x] Single oracle provider                           -- YES (off-chain service, no on-chain oracle). -5
  [ ] GoPlus: is_blacklisted = 1                       -- N/A
  [x] Insurance fund / TVL < 1% or undisclosed         -- Undisclosed. -5
  [x] Undisclosed multisig signer identities           -- YES. -5
  [ ] DAO governance paused or dissolved                -- Protocol paused post-hack
  [x] No published key management policy               -- YES (AWS KMS was single key). -5
  [x] No disclosed penetration testing                 -- YES. -5
  [ ] Custodial dependency without disclosed certification -- Fireblocks used (certified)

Total deductions: 15 + 15 + 8 + 8 + 8 + 5 + 5 + 5 + 5 + 5 + 5 = 84
Score: 100 - 84 = 16. Floor at 0.
```

**Quick Triage Score: 16/100 -- CRITICAL risk**

### Data Confidence Score Calculation

```
Start at 0.

  [x] +15  Source code is open and verified on block explorer
  [ ] +15  GoPlus token scan completed (USR scan returned null)
  [x] +10  At least 1 audit report publicly available (18 audits from MixBytes, Pashov, Sherlock, Pessimistic)
  [ ] +10  Multisig configuration verified on-chain
  [ ] +10  Timelock duration verified on-chain or in docs (72h mentioned only in postmortem)
  [x] +10  Team identities publicly known (doxxed)
  [ ] +10  Insurance fund size publicly disclosed
  [x] +5   Bug bounty program details publicly listed (Immunefi, up to $500K)
  [ ] +5   Governance process documented
  [x] +5   Oracle provider(s) confirmed (off-chain service -- confirmed as weakness)
  [ ] +5   Incident response plan published
  [ ] +5   SOC 2 Type II or ISO 27001 certification verified
  [ ] +5   Published key management policy
  [ ] +5   Regular penetration testing disclosed
  [ ] +5   Bridge DVN/verifier configuration publicly documented -- N/A
```

**Data Confidence: 55/100 -- MEDIUM confidence**

**Triage: 16/100 | Confidence: 55/100**

- Red flags found: 11 (0 CRITICAL, 2 HIGH, 3 MEDIUM, 6 LOW)
- Data points verified: 6 / 16 checkable

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (RLP pool ~$12M pre-hack) | Ethena 1.18%, Usual ~2% | HIGH |
| Audit Coverage Score | 6.5 (18 audits, mostly <1yr old) | Ethena ~3.0 | LOW risk |
| Governance Decentralization | Weak -- off-chain service role was single EOA | Ethena: multisig + ops committee | CRITICAL |
| Timelock Duration | 72h (disclosed only in postmortem) | Ethena 48h, Aave 24-168h | MEDIUM |
| Multisig Threshold | SERVICE_ROLE was single EOA (post-hack status UNVERIFIED) | Ethena 3/5+, Aave 6/10 | CRITICAL |
| GoPlus Risk Flags | USR: UNAVAILABLE; RESOLV: 0 HIGH / 1 MED (proxy) | -- | N/A |

### Audit Coverage Score Detail
```
18 audits total (MixBytes, Pashov, Sherlock, Pessimistic):
  - ~6 audits < 1 year old (Jan 2026, Jul-Aug 2025, etc.) = 6.0
  - ~6 audits 1-2 years old (2024) = 3.0
  Total: ~9.0 -- but off-chain infrastructure was NEVER audited.
  Effective score: 6.5 (penalized for scope gap that led to hack)
```

## GoPlus Token Security

### RESOLV Governance Token (0x259338656198ec7a76c729514d3cb45dfbf768a1)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | -- |
| Open Source | Yes (1) | -- |
| Proxy | Yes (1) | MEDIUM |
| Mintable | N/A | -- |
| Owner Can Change Balance | N/A | -- |
| Hidden Owner | N/A | -- |
| Selfdestruct | N/A | -- |
| Transfer Pausable | N/A | -- |
| Blacklist | N/A | -- |
| Slippage Modifiable | N/A | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 12,175 | -- |
| Trust List | N/A | -- |
| Creator Honeypot History | No (0) | -- |

### USR Stablecoin (0x66a1e37c9b0eaddca17d3662d6c05f4decf3e110)

GoPlus returned null for all fields on USR. Recorded as **GoPlus: UNAVAILABLE** for USR token.

GoPlus assessment: **Partial data only.** RESOLV governance token shows proxy pattern (expected for upgradeable tokens). USR token scan returned no data -- this is a gap. The RESOLV token has low DEX liquidity (~$12K total across Uniswap V4 pools) which is a concern for governance token holders.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **CRITICAL** | SERVICE_ROLE was single EOA; no on-chain mint cap; $25M stolen via compromised key | S/H | Y |
| Oracle & Price Feeds | **HIGH** | No on-chain oracle for minting; off-chain service determined mint amounts without validation | S/H | Y |
| Economic Mechanism | **HIGH** | No circuit breaker on minting; USR depegged 80%; downstream bad debt on Morpho/Fluid | S/H | Y |
| Smart Contract | **MEDIUM** | 18 audits but none covered off-chain infrastructure; exploit was in the off-chain gap | S/H | Y |
| Token Contract (GoPlus) | **MEDIUM** | USR scan unavailable; RESOLV is proxy with low liquidity | S | Partial |
| Cross-Chain & Bridge | **N/A** | Single-chain (Ethereum only) | -- | -- |
| Off-Chain Security | **CRITICAL** | AWS KMS single key compromised; no SOC 2; no published key mgmt policy; contractor supply chain attack | H/O | Y |
| Operational Security | **HIGH** | Hack response took ~3 hours; protocol still paused ~4 weeks post-hack; USR not re-pegged | H/O | Y |
| **Overall Risk** | **CRITICAL** | **Exploited March 2026; $25M stolen; protocol paused; USR depegged; single-key failure** | | |

**Overall Risk aggregation**:
1. Governance & Admin = CRITICAL (counts 2x) -> auto-triggers Overall = CRITICAL
2. Off-Chain Security = CRITICAL -> confirms CRITICAL
3. Additionally: 2 HIGH categories (Oracle, Economic Mechanism, Operational)
4. Result: **CRITICAL**

## Detailed Findings

### 1. Governance & Admin Key -- CRITICAL

**The core failure.** The SERVICE_ROLE, which authorized USR minting via the `completeSwap` function, was controlled by a single externally owned account (EOA) -- not a multisig. This key was stored in AWS KMS without MPC distribution or hardware security modules.

**Two-step swap mechanism (the vulnerability)**:
1. User calls `requestSwap` to deposit USDC and submit a minting request
2. Off-chain service holding SERVICE_ROLE calls `completeSwap` to finalize how much USR to issue
3. The contract performed ZERO validation on the mint amount -- the off-chain service had unchecked authority

**What the admin could do (pre-hack)**:
- Mint unlimited USR with no on-chain cap
- No oracle check on mint ratio
- No maximum mint per transaction
- No rate limiting on minting volume

**Timelock**: A 72-hour governance timelock existed for contract upgrades. After the hack, the team used this timelock to upgrade contracts and blacklist attacker addresses. However, the SERVICE_ROLE itself had NO timelock -- it could mint instantly.

**Multisig**: The SERVICE_ROLE was a single EOA. Post-hack status of multisig implementation is UNVERIFIED. The protocol has not publicly disclosed upgrading to multisig for privileged roles.

**Minting and redemption access**: Restricted to "allowlisted wallets" requiring form submission -- but the SERVICE_ROLE bypass made this irrelevant.

### 2. Oracle & Price Feeds -- HIGH

**No on-chain oracle.** The delta-neutral hedging calculation happened entirely off-chain because the protocol needed to calculate futures positions and hedging requirements before finalizing USR issuance. This means:

- No Chainlink, Pyth, or TWAP oracle for minting price validation
- The off-chain service WAS the oracle -- and it was a single key
- No circuit breaker on abnormal price movements
- No sanity check on mint ratio (attacker received 50M USR for 100K USDC -- a 500:1 ratio vs expected 1:1)

The protocol used Fireblocks for custody/infrastructure, but the minting oracle was not within Fireblocks' scope.

### 3. Economic Mechanism -- HIGH

**Delta-neutral design**: Resolv holds ETH spot + short ETH perpetual futures to neutralize directional risk. Yield comes from funding rate premiums (~6.7% annualized).

**Dual-token structure**:
- USR: Stablecoin pegged to $1, senior tranche
- RLP (Resolv Liquidity Provider): Junior tranche absorbing market risk, providing overcollateralization

**The depeg cascade**:
1. Attacker minted 80M unbacked USR
2. USR flooded DEX markets, crashing price to $0.02-0.20
3. Downstream protocols (Morpho, Fluid/Instadapp) suffered bad debt ($10M+ on Fluid alone)
4. 15+ vaults with >$10K liquidity were impacted
5. USR has NOT restored its peg (trading ~$0.27-0.56 range post-hack)

**Insurance fund**: RLP was meant to provide overcollateralization, but its size relative to the exploit was inadequate. No standalone insurance fund was disclosed.

**Withdrawal status**: Protocol is paused. Resolv stated collateral pool "remains fully intact" with ~$141M in assets, and is preparing allowlisted redemptions for pre-incident USR holders. But the protocol remains non-operational as of April 20, 2026.

### 4. Smart Contract Security -- MEDIUM

**Audit history is extensive but had a fatal scope gap**:

| Auditor | Date | Scope |
|---------|------|-------|
| MixBytes | Jan 2026 | ExternalRequestsCoordinator |
| Pashov | Jul-Aug 2025 | ResolvStakingV2 |
| MixBytes | Jul 2025 | EtherFiTreasuryExtension, RlpUpOnlyPriceStorage, Multicall |
| MixBytes + Pashov | Apr-May 2025 | ResolvStaking, RewardDistributor |
| MixBytes | Mar 2025 | TreasuryIntermediateEscrow |
| MixBytes + Pashov | Dec 2024 | TheCounter, UsrPriceStorage, ExternalRequestsManager, etc. |
| Sherlock | Nov 2024 | Treasury, Request Managers, stUSR, wstUSR, USR, RLP |
| MixBytes + Pashov | Aug-Sep 2024 | Treasury & Request Manager Contracts |
| Pessimistic + Pashov | Jul-Aug 2024 | Wrapped Staking/wstUSR |
| MixBytes + Pessimistic | May-Jun 2024 | Token Contracts, Request Manager, Staking |

18 audit reports across 4 firms (MixBytes, Pashov, Sherlock, Pessimistic). The smart contracts themselves were well-audited. However, the critical vulnerability was in the off-chain infrastructure (AWS KMS key management, SERVICE_ROLE authorization logic), which was explicitly outside the scope of all 18 audits.

**Bug bounty**: Active on Immunefi, up to $500,000 max payout. Rewards distributed in USR. Primacy of Impact policy.

**Source code**: Open source on GitHub (resolv-im org). Contracts verified on Etherscan.

### 5. Cross-Chain & Bridge -- N/A

Resolv operates exclusively on Ethereum. No cross-chain bridge dependencies.

### 6. Operational Security -- HIGH

**Team**: Doxxed. Founded by Ivan Kozlov (CEO), Fedor Chmile, and Tim Shekikhachev. Kozlov has a background in derivatives structuring at VTB Capital (2011-2022), CFA Level II, MIPT physics/math degree. Based in Dubai, UAE.

**Funding**: $10M seed round (April 2025).

**The hack supply chain attack**:
1. Attackers first compromised a third-party project linked to a contractor account
2. Exposed GitHub credentials -> access to internal repositories
3. Deployed malicious workflow to extract sensitive credentials silently
4. Moved into cloud systems (AWS), mapped infrastructure, targeted API keys
5. Compromised AWS KMS environment holding the SERVICE_ROLE private key
6. Total time from first mint to credential revocation: ~3 hours (02:21 UTC to ~05:30 UTC)

**Response timeline**:
- 02:21 UTC: First malicious mint (50M USR)
- 03:41 UTC: Second malicious mint (30M USR)
- ~05:30 UTC: Resolv revoked compromised credentials
- Post-hack: Protocol paused, 46M USR burned/blacklisted, 72h timelock used for contract upgrade

**Incident response assessment**: 3+ hours to revoke credentials after first anomalous mint is SLOW. Industry best practice is <15 minutes for critical minting operations. Monitoring tools flagged unusual activity "early" but response was not fast enough to prevent the second mint.

**Fireblocks relationship**: Resolv uses Fireblocks for custody/infrastructure (confirmed on Fireblocks customer page), but the compromised SERVICE_ROLE key was in AWS KMS, not Fireblocks MPC. This indicates incomplete adoption of MPC key management for critical signing roles.

**Dependencies**: CEX perpetual futures positions (for delta-neutral hedging), Fireblocks custody, AWS cloud infrastructure.

## Critical Risks

1. **CRITICAL: Protocol is paused and USR is depegged.** As of April 20, 2026, Resolv is non-operational. USR is not trading at peg. Users cannot freely mint or redeem. Any current exposure carries total loss risk.

2. **CRITICAL: Single-key failure led to $25M exploit.** The SERVICE_ROLE controlling unlimited minting was a single EOA in AWS KMS. No multisig, no on-chain mint cap, no oracle validation. This is the most basic operational security failure possible for a protocol handling >$100M TVL.

3. **CRITICAL: Off-chain infrastructure was never audited.** 18 smart contract audits from 4 firms, yet the vulnerability that caused the exploit was entirely in the off-chain signing infrastructure. The audit scope systematically excluded the highest-risk component.

4. **HIGH: No on-chain oracle for minting validation.** The protocol relied entirely on an off-chain service to determine mint amounts, with zero on-chain sanity checks. An attacker received 500x the expected USR for their USDC deposit.

5. **HIGH: Downstream composability damage.** USR was accepted as collateral on Morpho and Fluid (Instadapp), creating $10M+ in bad debt when the depeg occurred. This is the same pattern as the Kelp hack (April 2026).

6. **HIGH: Supply chain attack vector.** The initial breach came through a compromised contractor account and malicious GitHub workflow -- a social engineering / supply chain vector similar to the Radiant Capital hack.

## Peer Comparison

| Feature | Resolv (USR) | Ethena (USDe) | Usual (USD0) |
|---------|-------------|---------------|--------------|
| Type | Delta-neutral (ETH) | Delta-neutral (ETH/BTC) | RWA-backed |
| TVL | $57.6M (post-hack) | ~$5.9B | ~$800M |
| Timelock | 72h (contract upgrades only) | 48h | 24h |
| Multisig | SERVICE_ROLE was single EOA | Ops committee multisig | Multisig |
| Audits | 18 (4 firms) | 5+ (Zellic, Trail of Bits) | 3+ |
| Oracle | None (off-chain service) | Chainlink + internal | Chainlink |
| Insurance/TVL | Undisclosed | 1.18% ($70M reserve fund) | ~2% |
| Open Source | Yes | Yes | Yes |
| Custody | Fireblocks (partial) | Copper/Ceffu/Kraken | N/A (RWA) |
| Major Exploit | $25M (March 2026) | None | None |
| Status | PAUSED | Operational | Operational |

## Recommendations

1. **Do NOT deposit into Resolv or acquire USR until the protocol resumes operations and demonstrates upgraded security.** The protocol is paused. USR is depegged. There is no timeline for recovery.

2. **If holding USR**: Monitor Resolv's official channels for allowlisted redemption process. The team claims $141M in collateral remains intact.

3. **If considering post-recovery**: Before re-entering, verify:
   - SERVICE_ROLE upgraded to multisig (minimum 3/5)
   - On-chain mint cap and rate limiting implemented
   - On-chain oracle validation for mint ratios
   - Independent infrastructure audit (not just smart contract audit)
   - SOC 2 or equivalent certification for off-chain operations

4. **For lending protocols**: Do NOT accept USR as collateral until the protocol has operated incident-free for at least 6 months post-recovery with verified security upgrades.

5. **General lesson**: Delta-neutral stablecoin protocols that rely on off-chain computation for minting carry inherent key management risk. Smart contract audits alone are insufficient -- demand infrastructure audits.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- SERVICE_ROLE had no timelock
- [x] Admin can change oracle sources arbitrarily? -- No on-chain oracle existed
- [x] Admin can modify withdrawal limits? -- Admin had broad contract upgrade powers
- [x] Multisig has low threshold (2/N with small N)? -- Single EOA, worse than any multisig
- [x] Zero or short timelock on governance actions? -- SERVICE_ROLE had zero timelock
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (Ethereum)
- [x] Social engineering surface area (anon multisig signers)? -- Contractor supply chain attack vector

**WARNING: 6/7 Drift-type indicators match. This exploit IS a Drift-type governance failure.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- Not a lending protocol
- [x] Single oracle source without TWAP? -- No oracle at all
- [x] No circuit breaker on price movements? -- No mint circuit breaker
- [x] Insufficient insurance fund relative to TVL? -- RLP fund undisclosed/inadequate

**WARNING: 3/4 indicators match. Minting had no economic guardrails.**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- N/A
- [x] Admin keys stored in hot wallets? -- AWS KMS (cloud-hosted, compromised)
- [x] No key rotation policy? -- Not disclosed

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time? -- N/A (no on-chain governance)
- [ ] Flash loans can be used to acquire voting power? -- N/A
- [ ] Proposal + execution in same block? -- N/A
- [ ] No minimum holding period? -- N/A

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens? -- No
- [ ] Read-only reentrancy risk? -- Not applicable
- [ ] Flash loan compatible without reentrancy guards? -- Not applicable
- [ ] Composability with protocols that expose callback hooks? -- Not applicable

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler? -- Solidity (standard)
- [ ] Compiler version has known CVEs? -- Not identified
- [ ] Contracts compiled with different compiler versions? -- Unknown
- [ ] Code depends on language-specific behavior? -- Not identified

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral (own governance token)? -- No (backed by ETH + futures)
- [ ] Redemption mechanism creates sell pressure on collateral? -- No
- [x] Oracle delay could mask depegging in progress? -- No oracle existed to detect depeg
- [x] No circuit breaker on redemption volume? -- No circuit breaker on minting volume

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses a cross-chain bridge for token minting? -- No
- [ ] Bridge message validation relies on single messaging layer? -- N/A
- [ ] DVN/relayer config not publicly documented? -- N/A
- [x] Bridge can release or mint tokens without rate limiting? -- Minting had NO rate limit (analogous)
- [x] Bridged/wrapped token accepted as collateral on lending protocols? -- USR on Morpho, Fluid
- [x] No circuit breaker to pause minting if volume exceeds normal? -- Correct
- [x] Emergency pause response time > 15 minutes? -- Yes (~3 hours)
- [ ] Bridge admin controls under different governance? -- N/A
- [ ] Token deployed on 5+ chains via same bridge? -- No

**WARNING: 4/9 Kelp-type indicators match. The composability cascade (USR on Morpho/Fluid causing downstream bad debt) follows the Kelp pattern exactly.**

## Information Gaps

- **Post-hack security upgrades**: No public disclosure of whether SERVICE_ROLE has been upgraded to multisig, whether on-chain mint caps have been added, or whether infrastructure security has been independently audited.
- **Multisig configuration**: No on-chain verification of any multisig for protocol admin roles. Pre-hack, SERVICE_ROLE was confirmed as single EOA. Post-hack status unknown.
- **Insurance fund size**: RLP token was described as the insurance/overcollateralization mechanism, but its exact size and coverage ratio were never publicly disclosed.
- **USR GoPlus scan**: GoPlus returned null for all fields on USR token (0x66a1e37c9b0eaddca17d3662d6c05f4decf3e110). Cannot verify token-level security properties.
- **Custodial details**: Fireblocks relationship confirmed but scope of services unclear. The compromised key was in AWS KMS, not Fireblocks -- suggesting Fireblocks was used only for treasury custody, not operational signing.
- **Current protocol status**: Protocol remains paused. No public timeline for resumption. Redemption process for pre-incident holders is "being prepared" but not launched.
- **Key management policy**: No published key rotation, MPC distribution, or HSM policy. The hack revealed single AWS KMS key for critical operations.
- **SOC 2 / ISO 27001**: No evidence of any third-party security certification for off-chain operations.
- **Penetration testing**: No disclosed infrastructure-level penetration testing (distinct from smart contract audits).
- **Governance token utility**: RESOLV token launched but governance framework is undocumented.
- **Total hack losses**: Reported as $23-34M depending on source; exact figure including downstream bad debt unclear.

## Disclaimer

This analysis is based on publicly available information and web research as of April 20, 2026. It is NOT a formal smart contract audit. The Resolv protocol was exploited on March 22, 2026 and remains paused at the time of this analysis. Always DYOR and consider professional auditing services for investment decisions. Past audit reports do not guarantee future security -- this protocol had 18 audits and still suffered a $25M exploit.
