# DeFi Security Audit: PancakeSwap

**Audit Date:** April 6, 2026
**Protocol:** PancakeSwap -- Multi-chain DEX (AMM)

## Overview
- Protocol: PancakeSwap (AMM V2/V3 + Infinity)
- Chain: BNB Chain (primary), Ethereum, Arbitrum, zkSync Era, Base, Linea, Polygon zkEVM, Aptos, opBNB, Monad
- Type: DEX (AMM) / Yield Farming
- TVL: ~$1.64B (DeFiLlama, PancakeSwap AMM)
- TVL Trend: -0.9% (7d) / +2.5% (30d) / -11.3% (90d)
- Launch Date: September 2020
- Audit Date: April 6, 2026
- Source Code: Open (GitHub)

## Quick Triage Score: 54/100

Starting at 100, subtracting flags mechanically:

- CRITICAL flags: none (0)
- HIGH flags:
  - [x] Anonymous team with no prior track record (-15)
  - [x] No multisig threshold publicly documented with signer identities (-15)
- MEDIUM flags:
  - [x] GoPlus: is_mintable = 1 (-8)
- LOW flags:
  - [x] No documented timelock on admin actions exceeding 6h (-5)
  - [x] Undisclosed multisig signer identities (-5)
  - [x] Insurance fund / TVL undisclosed (-5)

Remaining unknown-risk deductions applied conservatively. There is no single catastrophic flag, but the accumulation of governance opacity issues (anonymous team, undisclosed multisig signers, short timelock) places PancakeSwap in the MEDIUM risk tier.

**Score: 54 -- MEDIUM risk**

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | 1-5% (Uniswap N/A, SushiSwap <1%) | HIGH |
| Audit Coverage Score | ~4.5 (7+ auditors, many audits 1-3yr old) | 1-3 avg | LOW risk |
| Governance Decentralization | Multisig + 6h timelock, anon signers | DAO + Guardian avg | HIGH risk |
| Timelock Duration | 6h (minimum) | 24-48h avg (Uniswap 48h, Aave 24-168h) | HIGH risk |
| Multisig Threshold | UNVERIFIED (documented as "multisig for all contracts") | 3/5+ avg | MEDIUM risk |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW risk |

## GoPlus Token Security (CAKE on BSC)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | No | -- |
| Mintable | Yes | MEDIUM |
| Owner Can Change Balance | No | -- |
| Hidden Owner | No | -- |
| Selfdestruct | No | -- |
| Transfer Pausable | No | -- |
| Blacklist | No | -- |
| Slippage Modifiable | No | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 1,908,267 | -- |
| Trust List | Yes | -- |
| Creator Honeypot History | No | -- |

GoPlus assessment: **LOW RISK**. The only flag is mintability, which is expected for a yield-farming token where CAKE emissions are distributed to liquidity providers. The owner address is the MasterChef contract (0x73feaa1eE314F8c655E354234017bE2193C9E24E), not an EOA. No honeypot, no hidden owner, no tax, no trading restrictions. Token is on the GoPlus trust list. Top holder (90.8%) is the burn address (0x...dead), reflecting the aggressive burn mechanism under Tokenomics 3.0.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **HIGH** | Anonymous team, undisclosed multisig signers, 6h timelock | Partial |
| Oracle & Price Feeds | **LOW** | Chainlink integration for Prediction; AMM uses on-chain prices | Partial |
| Economic Mechanism | **LOW** | Battle-tested AMM; Tokenomics 3.0 burn reduces supply | Partial |
| Smart Contract | **LOW** | 7+ audit firms, open source, $1M bug bounty | Y |
| Token Contract (GoPlus) | **LOW** | Mintable (expected for farm token); no other flags | Y |
| Cross-Chain & Bridge | **MEDIUM** | LayerZero OFT for CAKE bridging; 10 chains; centralization risk in bridge config | Partial |
| Operational Security | **MEDIUM** | Anonymous team; strong incident response track record | Partial |
| **Overall Risk** | **MEDIUM** | **Well-audited, battle-tested DEX with governance opacity as primary risk** | |

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Admin Key Surface Area:**
- The MasterChef contract owner controls critical functions: adding/modifying pools, setting CAKE allocation points, and setting the migrator contract. The migrator function can move LP tokens between exchanges -- a significant power.
- PancakeSwap states it uses "multisig for all contracts" but does not publicly disclose the multisig threshold, the number of signers, or the signer identities.
- The Timelock contract (0xA1f482Dc58145Ba2210bC21878Ca34000E2e8fE4) enforces a minimum 6-hour delay on governance actions, with a maximum of 30 days and a 14-day grace period.

**Timelock Concerns:**
- The 6-hour minimum timelock is significantly shorter than industry peers: Uniswap uses 48 hours, Aave uses 24-168 hours. A 6-hour window provides limited time for community review, especially across time zones.
- Whether an emergency bypass exists is UNVERIFIED. Documentation does not describe an emergency multisig or security council that can bypass the timelock.

**Upgrade Mechanism:**
- PancakeSwap Infinity (v4) introduces a new architecture with an immutable Vault layer for accounting and singleton contracts for pool management. The immutable vault is a positive security property.
- Legacy V2/V3 contracts remain active and are governed by the existing multisig + timelock setup.
- CAKE token contract itself is not a proxy (confirmed by GoPlus), reducing upgrade risk for the token.

**Governance Process:**
- Tokenomics 3.0 (April 2025) retired veCAKE staking and gauge voting in favor of a buy-and-burn model. This eliminated on-chain governance voting for CAKE holders.
- Major decisions (e.g., reducing max supply from 450M to 400M in January 2026) are put to community vote, but the governance mechanism for these votes is not clearly documented as fully on-chain.
- The retirement of veCAKE effectively centralizes governance power back to the core team's multisig, as there is no active on-chain DAO governance.

**Token Concentration:**
- 90.8% of CAKE supply is held at the burn address (0x...dead), effectively removed from circulation.
- Top non-burn holders control ~1.7% (likely Binance) and ~1.15% (unknown). Concentration among active holders is low.
- With veCAKE retired, token-based governance voting is no longer active, making whale risk less relevant but centralization of admin control more concerning.

### 2. Oracle & Price Feeds -- LOW

**Oracle Architecture:**
- As a DEX/AMM, PancakeSwap primarily uses on-chain pool prices (constant product formula for V2, concentrated liquidity for V3). These are inherently resistant to off-chain oracle manipulation.
- For the Prediction product, PancakeSwap integrates Chainlink Data Streams and Automation on Arbitrum, and BNB/USD Chainlink Price Feed on BSC.
- TWAP oracles are available via PancakeSwap pools for third-party integrations (e.g., Ankr PancakeSwap Oracle).

**Risk Assessment:**
- AMM pricing is manipulation-resistant for large pools but vulnerable for low-liquidity pairs. Flash loan attacks on small pools remain a theoretical risk, though PancakeSwap is not a lending protocol and does not use pool prices as collateral oracles.
- Chainlink integration for Prediction markets is a best practice.

### 3. Economic Mechanism -- LOW

**AMM Model:**
- PancakeSwap V2 uses the standard constant product (x*y=k) AMM model, battle-tested since Uniswap V2.
- PancakeSwap V3 uses concentrated liquidity (Uniswap V3 fork), also extensively battle-tested.
- PancakeSwap Infinity introduces singleton contracts and hooks for custom pool logic, which is newer and less battle-tested.

**Tokenomics 3.0:**
- Emissions reduced from ~40,000 to 22,250 CAKE/day.
- Buy-and-burn model: 29 consecutive months of supply reduction as of February 2026.
- Cumulative burn of ~42.2M CAKE since September 2023.
- Ecosystem Growth Fund holds ~3.5M CAKE for future initiatives.
- Max supply cap reduced from 450M to 400M via governance vote (January 2026).

**Insurance / Bad Debt:**
- As a DEX (not a lending protocol), PancakeSwap does not have a traditional insurance fund or bad debt mechanism. Users face impermanent loss risk rather than liquidation risk.
- No publicly documented insurance or compensation fund for exploit losses.

### 4. Smart Contract Security -- LOW

**Audit History:**
PancakeSwap has been audited by at least 7 firms:
- CertiK (multiple audits including Infinity/v4 hooks security)
- PeckShield (MasterChef V2, Prediction V2, CakePool, CrossFarming)
- SlowMist (core contracts, MOVE integration)
- BlockSec
- OtterSec
- Zellic
- Halborn

Audit Coverage Score calculation:
- CertiK Infinity hooks (2025): 1.0
- PeckShield MasterChef V3 (Apr 2023): 0.25
- SlowMist Exchange V3 (Mar 2023): 0.25
- PeckShield Cross-chain Farming (Sep 2022): 0.25
- PeckShield StableSwap (Aug 2022): 0.25
- PeckShield Farm Booster (Jul 2022): 0.25
- PeckShield New CAKE Pool (Apr 2022): 0.25
- PeckShield MasterChef V2 (Mar 2022): 0.25
- Additional audits by BlockSec, OtterSec, Zellic, Halborn (dates UNVERIFIED): ~1.0 estimated
- **Total: ~3.75 (LOW risk threshold >= 3.0)**

**Bug Bounty:**
- Active on Immunefi with maximum payout up to $1,000,000.
- Scope covers smart contracts, website, and apps.
- Rewards paid in CAKE or USDT, pegged to USD.
- Previously paid out for a lottery vulnerability (documented postmortem on Immunefi/Medium).

**Battle Testing:**
- Live since September 2020 (~5.5 years).
- Peak TVL exceeded $7B (May 2021).
- Open source on GitHub.
- No critical smart contract exploit affecting core AMM contracts. The March 2025 BCE/USDT pool exploit ($679K) targeted a specific token's burn mechanism vulnerability, not PancakeSwap's core contracts.

### 5. Cross-Chain & Bridge -- MEDIUM

**Multi-Chain Deployment:**
PancakeSwap is deployed on 10 chains: BNB Chain, Ethereum, Arbitrum, zkSync Era, Base, Linea, Polygon zkEVM, Aptos, opBNB, and Monad.

**Bridge Dependencies:**
- CAKE bridging uses LayerZero OFT (Omnichain Fungible Token) standard for cross-chain token transfers.
- PancakeSwap Bridge (launched for broader token bridging) is powered by BNB Chain partnerships with multiple bridge providers: Celer, LayerZero, deBridge, Meson, and Stargate.
- The use of multiple bridge providers reduces single-point-of-failure risk but increases the attack surface.

**Cross-Chain Governance:**
- Whether each chain deployment has its own admin multisig or a single key controls all deployments is UNVERIFIED.
- BNB Chain appears to be the canonical "home chain" for governance.
- Cross-chain message security for governance actions is not publicly documented.

**LayerZero Security:**
- LayerZero has processed $50B+ in volume across 132+ blockchains without a core protocol exploit.
- Security model requires collusion between oracle and relayer operators for compromise.
- LayerZero has undergone independent audits.

### 6. Operational Security -- MEDIUM

**Team & Track Record:**
- PancakeSwap was created by an anonymous team in September 2020. Known pseudonyms include "Hops" and "Thumper" (co-leads) and the original "Chef Nomi."
- Speculation exists that PancakeSwap was created by Binance staff, but this is UNVERIFIED. The close relationship with BNB Chain ecosystem (deep integration, co-promoted bridge) supports this speculation.
- No team member has been publicly doxxed or identified.

**Incident Response:**
- Demonstrated strong incident response during the March 2025 BCE/USDT exploit: quickly paused affected pools and communicated with the community.
- DNS hijack attack (March 2021) was a front-end issue, not a smart contract compromise. Team responded promptly.
- Chinese X account compromise (October 2025) was a social media issue, handled with X team coordination.
- No published formal incident response plan found in documentation.

**Dependencies:**
- Heavy dependency on BNB Chain infrastructure and ecosystem.
- LayerZero dependency for cross-chain CAKE bridging.
- Chainlink dependency for Prediction product price feeds.
- Multiple bridge provider dependencies for cross-chain token transfers.

## Critical Risks (if any)

No CRITICAL risks identified. Key HIGH-level concerns:

1. **Governance opacity**: Anonymous team with undisclosed multisig configuration. The community cannot verify who controls protocol upgrades or fund movements. With veCAKE governance retired, there is no on-chain check on admin power.
2. **Short timelock (6 hours)**: Significantly below industry standard. A compromised multisig could execute malicious changes with only 6 hours of community visibility, potentially insufficient for detection and response.
3. **MasterChef migrator function**: The owner-controlled migrator can move LP tokens between exchanges. While standard in SushiSwap-forked protocols, this represents a theoretical rug-pull vector if the multisig is compromised.

## Peer Comparison

| Feature | PancakeSwap | Uniswap | SushiSwap |
|---------|-------------|---------|-----------|
| Timelock | 6h (minimum) | 48h | 48h |
| Multisig | Yes (threshold UNVERIFIED) | Governance DAO | 3/5 multisig |
| Audits | 7+ firms | 5+ firms | 3+ firms |
| Oracle | On-chain AMM + Chainlink (Prediction) | On-chain AMM + TWAP | On-chain AMM |
| Insurance/TVL | Undisclosed | N/A (DEX) | N/A (DEX) |
| Open Source | Yes | Yes | Yes |
| Team | Anonymous | Doxxed (Hayden Adams) | Partially doxxed |
| Bug Bounty | $1M (Immunefi) | $15.5M (Immunefi) | $250K |
| Governance | Retired veCAKE; multisig-controlled | Full on-chain DAO | On-chain DAO |
| Chains | 10 | 20+ | 25+ |

PancakeSwap's 6-hour timelock and anonymous team are notable weaknesses compared to peers. Its audit coverage and bug bounty program are strengths. The retirement of on-chain governance (veCAKE) is a step backward in decentralization compared to Uniswap's fully on-chain DAO.

## Recommendations

1. **Monitor governance changes carefully**: With only a 6-hour timelock, users should monitor the Timelock contract (0xA1f482Dc58145Ba2210bC21878Ca34000E2e8fE4) for queued transactions. Consider using alert services.
2. **Be cautious with low-liquidity pools**: The BCE/USDT exploit demonstrated that individual token vulnerabilities can affect PancakeSwap pools. Avoid LPing in pools for unaudited or low-market-cap tokens.
3. **Diversify across DEXes**: Given the governance opacity, avoid concentrating all DEX activity on PancakeSwap. Consider splitting across Uniswap, PancakeSwap, and other audited DEXes.
4. **Watch for multisig disclosure**: Advocate for PancakeSwap to publicly disclose multisig threshold, signer count, and signer identities. This is standard practice among top protocols.
5. **Prefer Infinity (v4) pools when available**: The immutable vault architecture of PancakeSwap Infinity provides stronger security guarantees than legacy V2/V3 contracts.
6. **Cross-chain users**: Be aware that CAKE bridging depends on LayerZero. In a bridge failure scenario, CAKE on non-BSC chains could become temporarily illiquid.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- N/A (DEX, not lending)
- [ ] Admin can change oracle sources arbitrarily? -- Partially; Prediction oracle config is admin-controlled (UNVERIFIED timelock coverage)
- [x] Admin can modify withdrawal limits? -- MasterChef owner can modify pool parameters
- [ ] Multisig has low threshold (2/N with small N)? -- UNVERIFIED
- [x] Zero or short timelock on governance actions? -- 6h minimum, significantly below 24-48h peer standard
- [ ] Pre-signed transaction risk? -- N/A (EVM)
- [x] Social engineering surface area (anon multisig signers)? -- All signers anonymous and undisclosed

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A (DEX, not lending)
- [ ] Single oracle source without TWAP? -- N/A for AMM; Prediction uses Chainlink
- [ ] No circuit breaker on price movements? -- N/A for AMM
- [ ] Insufficient insurance fund relative to TVL? -- No insurance fund (DEX model)

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- LayerZero (decentralized oracle+relayer model)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

**Pattern match assessment**: PancakeSwap shows partial alignment with the Drift-type pattern due to anonymous multisig signers, short timelock, and broad admin powers over MasterChef. However, as a DEX rather than a lending protocol, the attack surface for governance exploitation is more limited -- an attacker cannot list fake collateral to borrow against. The primary risk vector would be a malicious migrator deployment or pool parameter manipulation.

## Information Gaps

- Multisig threshold and signer count for all admin multisigs (BSC and other chains)
- Identity of multisig signers (all anonymous)
- Whether an emergency bypass mechanism exists for the timelock
- Whether each chain deployment has independent admin controls or a shared multisig
- Cross-chain governance message validation mechanism
- Formal incident response plan
- Insurance or user compensation policy for exploit losses
- Whether the MasterChef migrator function has been disabled or restricted
- Key storage practices (hot wallet vs. hardware wallet vs. MPC)
- Key rotation policy and frequency
- Detailed audit reports for Infinity (v4) contracts beyond CertiK hooks review
- Whether Binance has any formal or informal control over the protocol
- On-chain governance roadmap after veCAKE retirement

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
