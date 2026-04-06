# DeFi Security Audit: Convex Finance

**Audit Date:** April 6, 2026
**Protocol:** Convex Finance -- Curve yield booster and governance aggregator

## Overview
- Protocol: Convex Finance
- Chain: Ethereum (primary), Arbitrum, Polygon, Fraxtal
- Type: Yield / Curve Booster
- TVL: ~$619M (DeFiLlama, April 2026)
- TVL Trend: -2.6% / -8.0% / -37.2% (7d / 30d / 90d)
- Launch Date: May 17, 2021
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: convex-eth)

## Quick Triage Score: 67/100

Starting at 100, the following flags apply:

- [-8] is_mintable = 1 (CVX token is mintable per GoPlus)
- [-5] No documented timelock on most admin actions (except 30-day shutdown path)
- [-5] Single oracle provider (no independent oracle; depends on Curve price feeds)
- [-5] Insurance fund / TVL undisclosed (no formal insurance fund)
- [-5] Undisclosed multisig signer identities (signers are named but not KYC-verified public figures)
- [-5] TVL dropped >30% in 90 days (37.2% decline)

Score: 100 - 8 - 5 - 5 - 5 - 5 - 5 = **67** (MEDIUM risk)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed / None | 1-5% (Aave, Yearn) | HIGH |
| Audit Coverage Score | 2.75 | 3.0+ (Aave, Yearn) | MEDIUM |
| Governance Decentralization | vlCVX vote + 3/5 multisig | DAO + Guardian (Aave) | MEDIUM |
| Timelock Duration | 30 days (shutdown only); 0h for most ops | 24-48h (peers) | MEDIUM |
| Multisig Threshold | 3/5 | 3/5 avg, 6/10 (Aave) | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW |

**Audit Coverage Score calculation:**
- MixBytes April 2021 (>2yr old): 0.25
- Peckshield April 2022 (>2yr): 0.25
- Peckshield Sept 2022 (>2yr): 0.25
- Peckshield Nov 2022 (>2yr): 0.25
- Nomoi Jan 2023 (>2yr): 0.25
- Nomoi Jan 2023 (>2yr): 0.25
- Chainsecurity April 2023 (>2yr): 0.25
- Veritas Protocol (undated): 0.25 (conservative)
- OpenZeppelin review 2021 (>2yr): 0.25
- Total: **2.25** (HIGH risk threshold is <1.5; MEDIUM threshold is 1.5-2.99)

## GoPlus Token Security (CVX on Ethereum: 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | -- |
| Open Source | Yes (1) | -- |
| Proxy | No (0) | -- |
| Mintable | Yes (1) | MEDIUM |
| Owner Can Change Balance | No (0) | -- |
| Hidden Owner | No (0) | -- |
| Selfdestruct | No (0) | -- |
| Transfer Pausable | No (0) | -- |
| Blacklist | No (0) | -- |
| Slippage Modifiable | No (0) | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 30,423 | -- |
| Trust List | No (0) | -- |
| Creator Honeypot History | No (0) | -- |
| CEX Listed | Binance, Coinbase | -- |

**GoPlus assessment: LOW RISK.** The only flag is that CVX is mintable, which is expected -- CVX minting is tied to CRV rewards earned by the protocol and follows a predetermined emission schedule with a hard cap of ~100M tokens. No honeypot, no hidden owner, no tax, no trading restrictions. Owner address is 0xF403C135812408BFbE8713b5A23a04b3D48AAE31 (Booster contract), not an EOA.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | Anonymous team, 3/5 multisig, no timelock on most operations | Partial |
| Oracle & Price Feeds | **LOW** | No independent oracle needed; inherits Curve pool pricing | Partial |
| Economic Mechanism | **MEDIUM** | Deep Curve dependency; no insurance fund; 37% TVL decline in 90d | Y |
| Smart Contract | **LOW** | Immutable contracts, 7+ audits, open source | Y |
| Token Contract (GoPlus) | **LOW** | Mintable but capped; no dangerous flags | Y |
| Cross-Chain & Bridge | **LOW** | Multi-chain but independent deployments; no bridge dependency | Partial |
| Operational Security | **MEDIUM** | Pseudonymous team; Curve dependency; DNS hijack history | Partial |
| **Overall Risk** | **MEDIUM** | **Mature protocol with strong smart contract security, but deep Curve dependency, anonymous team, and declining TVL introduce structural risks** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**Multisig Configuration:**
Convex uses a 3-of-5 multisig on both Ethereum and Arbitrum. After the 2021 OpenZeppelin disclosure (which revealed that 2-of-3 original anonymous signers could have rug-pulled $15B), the multisig was expanded to include publicly known ecosystem participants:

1. C2tP (Convex Finance, pseudonymous founder)
2. Winthorpe (Convex Finance)
3. Benny (Llama Airforce)
4. Tommy (Votium)
5. Sam (Frax Finance)

While these individuals are known within the DeFi community, they are not traditionally "doxxed" with real-world identities -- they are pseudonymous figures identified by their roles in affiliated projects. This is an improvement over the original anonymous 2-of-3 setup but does not meet the standard of fully doxxed signers as seen in protocols like Aave.

**Admin Powers:**
The multisig can:
- Update stash factory and pool manager contracts
- Adjust platform fees within fixed ranges (cvxCRV 10-15%, CVX 3-6%, treasury 0-2%)
- Pause deposits to staking contracts (users retain withdrawals)
- Shutdown entire system (users can withdraw)
- Vote on Curve DAO proposals and gauge weights
- Set distribution weights on Convex Master Chef
- Manage vlCVX rewards and boost parameters

**What the multisig cannot do:**
- Access user deposits directly
- Withdraw user LP tokens from pools

**Timelock:**
Most admin operations have NO timelock. The 30-day timelock applies only to the specific shutdown-and-redeploy attack path (documented as a known issue). The protocol argues that since admin controls do not touch user funds, timelocks are unnecessary. This is reasonable for the current design but means that fee adjustments, reward distribution changes, and gauge weight votes happen instantly.

**Protective Contracts:**
poolManagerProxy, poolManagerSecondaryProxy, and boosterOwner contracts add restrictions on what the admin can do, blocking the most dangerous vectors.

**vlCVX Governance:**
CVX holders can lock tokens as vlCVX to vote on how Convex directs its massive veCRV holdings (~50% of total CRV supply). This creates a meta-governance layer where controlling CVX effectively controls Curve. The "bribe economy" via Votium channels over $100M annually in incentives to vlCVX voters. Governance concentration risk: the top holder (0x72a1...) controls ~48.4% of CVX supply per GoPlus data -- this is likely the vlCVX staking contract but represents extreme concentration of voting power in a single venue.

### 2. Oracle & Price Feeds -- LOW

Convex Finance does not operate an independent oracle system. As a yield optimizer that sits on top of Curve, it inherits Curve's pricing mechanisms:

- LP token pricing is determined by Curve pool invariants
- CRV/CVX market prices come from DEX liquidity (Sushi, Uniswap)
- No lending/borrowing functions that require oracle price feeds for liquidations
- No collateral-based positions that could be oracle-manipulated

The primary price risk is in Curve pool depegs (historical examples: MIM depeg Jan 2022, UST depeg May 2022, stETH depeg June 2022). Convex users are exposed to these risks through their LP positions but this is inherent to the underlying Curve pools, not a Convex-specific oracle vulnerability.

### 3. Economic Mechanism -- MEDIUM

**Revenue Model:**
Convex earns platform fees on CRV rewards (10-15% on cvxCRV, 3-6% on CVX stakers). The model is sustainable as long as Curve emissions and trading fees generate meaningful yield.

**Insurance Fund:**
No formal insurance fund exists. The treasury holds 9.7% of CVX supply (vested), managed at the team's discretion. At current CVX prices, this is roughly $20-30M worth of CVX tokens, representing approximately 3-5% of TVL -- but in a crisis, CVX price would likely drop alongside any loss event, making this an unreliable backstop.

**Curve Dependency (Critical):**
Convex's entire value proposition depends on Curve Finance. The July 2023 Curve reentrancy hack ($69M exploit from Vyper compiler vulnerability) caused Convex TVL to plummet 52.5% from $2.91B. This demonstrated that Convex inherits the full risk surface of Curve, which includes:
- Vyper smart contract risks (language-level vulnerabilities)
- Curve governance risks (Curve DAO can alter gauge weights, pool parameters)
- CRV token risk (concentrated holdings by Michael Egorov historically posed systemic risk)

**TVL Decline:**
The 37.2% 90-day TVL decline (from $986M to $619M) is notable but primarily reflects broader market dynamics and reduced Curve emissions rather than a Convex-specific crisis. Peak TVL was $21B in January 2022.

**Frax and Prisma Integration:**
Convex expanded to boost rewards for Frax (cvxFXS) and Prisma (cvxPRISMA). These integrations add dependencies on:
- Frax Finance stability (FRAX peg, veFXS governance)
- Prisma Finance operations (PRISMA token, mkUSD stablecoin)
Each integration adds a new attack surface and dependency chain.

### 4. Smart Contract Security -- LOW

**Immutable Contracts:**
Convex contracts are non-upgradeable. This is a significant security advantage -- there is no proxy pattern, no upgrade key, and no way to silently modify contract logic. When a bug was found in the vote-locking contract (March 2022), the team had to deploy an entirely new contract and migrate users, demonstrating the immutability is real.

**Audit History (7 audits):**
| Auditor | Date | Scope |
|---------|------|-------|
| MixBytes | April 2021 | General Platform Contracts |
| OpenZeppelin | Late 2021 | Security Review (discovered $15B rugpull vuln) |
| Peckshield | April 2022 | Convex Frax Staking |
| Peckshield | September 2022 | Convex Wrapper |
| Peckshield | November 2022 | Convex Sidechain |
| Nomoi | January 2023 (x2) | cvxCRV Wrapper + Sidechain |
| Chainsecurity | April 2023 | Convex Wrapper (Silo Integration) |

All audits are now more than 2 years old. No recent audit covers the Fraxtal deployment or any 2024-2025 changes.

**Bug Bounty:**
Active program with payouts from $1,000 to $250,000 based on severity. Contact via contact@convexfinance.com. Not hosted on Immunefi (Immunefi was used as intermediary for the 2021 OpenZeppelin disclosure but Convex does not have a standing Immunefi listing).

**Past Security Incidents:**
1. **$15B Rugpull Vulnerability (Dec 2021):** OpenZeppelin discovered that 2-of-3 anonymous multisig signers could drain all user funds. Patched by adding known signers and expanding multisig. No funds lost.
2. **Vote-Lock Bug (March 2022):** Expired locks could relock to new addresses, enabling excess cvxCRV reward claims. Non-critical; no funds lost. Required full contract redeployment.
3. **DNS Hijacking (June 2022):** Domain was hijacked, frontend served malicious approval requests. 5 wallets affected. Smart contracts were not compromised.

**Battle Testing:**
Live since May 2021 (nearly 5 years). Handled peak TVL of $21B. Open source on GitHub. No smart contract exploit has ever resulted in user fund loss.

### 5. Cross-Chain & Bridge -- LOW

Convex operates on Ethereum (primary), Arbitrum, Polygon, and Fraxtal. The vast majority of TVL (~$607M of $619M) is on Ethereum.

- Each chain deployment appears to have independent contracts
- No cross-chain messaging or bridge dependency for core operations
- Sidechain deployments were independently audited (Peckshield Nov 2022, Nomoi Jan 2023)
- Fraxtal deployment relies on Frax's own chain infrastructure

The cross-chain risk is minimal because there is no bridge-based asset transfer or governance relay mechanism.

### 6. Operational Security -- MEDIUM

**Team:**
Pseudonymous founder C2tP and core team. No real-world identities publicly known. This was a central concern in the 2021 OpenZeppelin disclosure -- the original 2-of-3 anonymous multisig meant anonymous developers could have rug-pulled. Mitigated by expanding to 3-of-5 with ecosystem-known signers, but still weaker than fully doxxed teams.

**Incident Response:**
- Demonstrated effective response to the 2021 rugpull vulnerability (patched within weeks of disclosure)
- Handled the March 2022 bug with contract redeployment
- Responded to June 2022 DNS hijack by setting up alternative URLs
- No formal published incident response plan found

**Dependencies:**
- **Curve Finance (CRITICAL):** Convex is entirely dependent on Curve. A Curve exploit, governance attack, or protocol shutdown would directly impact all Convex users
- **Frax Finance:** cvxFXS integration creates dependency on Frax stability
- **Prisma Finance:** cvxPRISMA creates dependency on Prisma operations
- **Votium:** Bribe marketplace integral to vlCVX value proposition

## Critical Risks (if any)

1. **[HIGH] Deep Curve Dependency:** A catastrophic Curve Finance exploit or governance failure would directly impact Convex users' funds. The July 2023 Curve hack demonstrated this with 52.5% TVL loss.
2. **[HIGH] No Insurance Fund:** No formal insurance or bad debt fund exists. Treasury is CVX-denominated and would lose value precisely when it is most needed.
3. **[MEDIUM] Pseudonymous Team:** Despite the 2021 multisig expansion, core developers remain pseudonymous. Social engineering or key compromise of 3 of 5 pseudonymous signers remains a theoretical risk.
4. **[MEDIUM] Stale Audits:** All audits are >2 years old. Any new code deployed since April 2023 (including Fraxtal deployment) is unaudited.

## Peer Comparison

| Feature | Convex Finance | Yearn Finance | Aura Finance |
|---------|---------------|---------------|--------------|
| Timelock | 30d (shutdown only); none for most ops | 24h governance timelock | 14d timelock |
| Multisig | 3/5 (pseudo-doxxed) | 6/9 (doxxed) | 3/6 multisig |
| Audits | 7+ (latest Apr 2023) | 10+ (continuous) | 5+ |
| Oracle | Inherits Curve | Chainlink + custom | Inherits Balancer |
| Insurance/TVL | None formal | ~1% (treasury) | None formal |
| Open Source | Yes | Yes | Yes |
| Contracts | Immutable | Upgradeable | Mixed |

## Recommendations

1. **For users:** Understand that depositing in Convex means accepting both Convex AND Curve risk. Monitor Curve governance proposals that could affect gauge weights or pool parameters.
2. **For large depositors:** Diversify across yield optimizers; do not concentrate all Curve LP positions through Convex alone.
3. **For the protocol:** Commission a fresh comprehensive audit covering all current contracts including Fraxtal deployment. Establish a formal insurance fund with non-CVX assets. Consider adding timelocks to fee adjustment and reward distribution operations.
4. **For governance participants:** Monitor vlCVX voting concentration -- if a single entity accumulates >33% of vlCVX, they could unilaterally direct Curve emissions.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- N/A (not a lending protocol)
- [ ] Admin can change oracle sources arbitrarily? -- N/A (no oracle dependency)
- [ ] Admin can modify withdrawal limits? -- No, users can always withdraw
- [ ] Multisig has low threshold (2/N with small N)? -- 3/5, acceptable
- [x] Zero or short timelock on governance actions? -- Yes, most admin actions have no timelock
- [ ] Pre-signed transaction risk? -- N/A (EVM)
- [x] Social engineering surface area (anon multisig signers)? -- Yes, signers are pseudonymous

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A
- [ ] Single oracle source without TWAP? -- N/A
- [ ] No circuit breaker on price movements? -- N/A
- [x] Insufficient insurance fund relative to TVL? -- Yes, no formal insurance fund

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No
- [x] Admin keys stored in hot wallets? -- Unknown, UNVERIFIED
- [ ] No key rotation policy? -- Unknown, UNVERIFIED

## Information Gaps

- **Multisig key storage:** How and where the 5 multisig signers store their keys is not publicly documented. Hardware wallet usage is UNVERIFIED.
- **Key rotation policy:** No public information on whether multisig signers rotate keys or have succession plans.
- **Fraxtal deployment audit:** The Fraxtal chain deployment does not appear to have been independently audited.
- **Treasury composition:** The exact current composition of the treasury beyond CVX tokens is not publicly documented. The treasury dashboard at convexfinance.com/treasury was not verifiable during this audit.
- **Formal incident response plan:** No published runbook or SLA for security incident response.
- **Real identities of multisig signers:** While signers are named by pseudonym and project affiliation, their real-world legal identities are not public.
- **Recent code changes:** Any smart contract changes or deployments since April 2023 are not covered by existing audits.
- **vlCVX voting concentration:** Exact breakdown of top vlCVX holders and whether any single entity can unilaterally direct gauge votes is not fully documented.

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
