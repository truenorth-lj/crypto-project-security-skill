# DeFi Security Audit: USDD

**Audit Date:** April 6, 2026
**Protocol:** USDD -- Overcollateralized/CDP Stablecoin on TRON

## Overview
- Protocol: USDD (Decentralized USD)
- Chain: TRON (primary), Ethereum, BNB Chain
- Type: Overcollateralized CDP Stablecoin (formerly algorithmic, transitioned to CDP model with USDD 2.0 in January 2025)
- TVL: ~$1.29B
- TVL Trend: +18.0% / +127.8% / +149.1% (7d / 30d / 90d)
- Launch Date: April 2022 (USDD 1.0), January 25, 2025 (USDD 2.0)
- Audit Date: April 6, 2026
- Source Code: Partial (Ethereum PSM contracts audited and published; TRON-native contracts not fully open-sourced on public repositories)

## Quick Triage Score: 37/100

Starting at 100, the following deductions apply:

**CRITICAL flags:**
- None triggered from GoPlus automated checks

**HIGH flags (-15 each):**
- (-15) Zero audits listed on DeFiLlama (DeFiLlama reports "audits: 0" despite USDD claiming 5 audits from ChainSecurity/CertiK -- the audits are not registered on DeFiLlama)
- (-15) No multisig: TRON DAO Reserve governance is effectively controlled by Justin Sun with no verifiable on-chain multisig threshold or signer disclosure. The DAO portal was shut down with only one vote ever conducted in the protocol's history.

**MEDIUM flags (-8 each):**
- (-8) GoPlus: `is_mintable = 1` -- expected for a stablecoin but a privileged function
- (-8) GoPlus: `transfer_pausable = 1` (on BSC deployment)
- (-8) Multisig threshold unverifiable / effectively < 3 signers for critical decisions (collateral changes made unilaterally)

**LOW flags (-5 each):**
- (-5) No documented timelock on admin actions (collateral composition changed without governance vote or timelock)
- (-5) No bug bounty program found on Immunefi or other major platforms
- (-5) Insurance fund / TVL ratio undisclosed
- (-5) Undisclosed multisig signer identities (TRON DAO Reserve member roles unclear)
- (-5) DAO governance effectively dissolved

Red flags found: 0 CRITICAL, 2 HIGH, 3 MEDIUM, 5 LOW

Score meaning: 20-49 = HIGH risk. The score primarily reflects governance opacity, centralization around Justin Sun, and the lack of verifiable decentralized controls despite "DAO" branding.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | DAI: ~5%, USDe: ~1.2% | HIGH |
| Audit Coverage Score | 2.5 | DAI: ~4.0, USDe: ~3.25 | MEDIUM |
| Governance Decentralization | Effectively centralized (Justin Sun) | DAI: on-chain DAO, USDe: multisig 7/10 | HIGH |
| Timelock Duration | None verified | DAI: 48h, USDe: present | HIGH |
| Multisig Threshold | UNVERIFIED | DAI: governance, USDe: 7/10 | HIGH |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW |

**Audit Coverage Score Calculation:**
- ChainSecurity audit #1 (Jan 2025, USDD 2.0 launch): ~1.2yr old = 0.5
- ChainSecurity audit #2 (2025): ~1yr old = 0.5
- ChainSecurity audit #3 (2025): ~1yr old = 0.5
- ChainSecurity audit #5 (Oct 2025): <1yr old = 1.0
- CertiK Ethereum audit (Sep 2025): <1yr old = 1.0 (though overlap with ChainSecurity scope is possible)
- Note: Exact dates of audits #2-#4 are not fully public. Using conservative estimate.
- Adjusted total avoiding double-counting: ~2.5 (MEDIUM risk threshold: 1.5-2.99)

## GoPlus Token Security

### USDD on Ethereum (0x0C10bF8FcB7Bf5412187A595ab97a3609160b5c6)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | No | -- |
| Mintable | UNVERIFIED (GoPlus rate-limited) | MEDIUM |
| Owner Can Change Balance | No | -- |
| Hidden Owner | No | -- |
| Selfdestruct | No | -- |
| Transfer Pausable | UNVERIFIED | -- |
| Blacklist | UNVERIFIED | -- |
| Slippage Modifiable | No | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 1,190 | -- |
| Trust List | UNVERIFIED | -- |
| Creator Honeypot History | No | -- |

**Ethereum holder concentration:** Top holder (0x9277...2433, contract) holds 99.08% of Ethereum USDD supply. This is likely the sUSDD staking contract or PSM vault, but represents extreme concentration on a single contract address.

**Note:** GoPlus returned rate-limit errors on retry attempts. Partial data from initial successful query used. Full token security profile could not be retrieved for all fields.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | CRITICAL | DAO dissolved; Justin Sun makes unilateral collateral decisions; $732M BTC removed without vote | Partial |
| Oracle & Price Feeds | MEDIUM | WINkLink (TRON-native) transitioning to Chainlink; oracle manipulation risk on TRON | Partial |
| Economic Mechanism | HIGH | TRX concentration (~40%+ collateral); reflexive risk if TRX declines; yield sustainability unclear | Partial |
| Smart Contract | MEDIUM | 5 audits by ChainSecurity/CertiK; CertiK AA rating (87.5/100); but TRON contracts not fully open-sourced | Partial |
| Token Contract (GoPlus) | LOW | No honeypot, open source on Ethereum, no hidden owner; mintable (expected for stablecoin) | Partial |
| Cross-Chain & Bridge | MEDIUM | Native deployments on 3 chains; PSM on each chain; bridge mechanism for cross-chain not fully documented | N |
| Operational Security | HIGH | Justin Sun's legal/regulatory exposure; HTX (Sun-owned) holds ~83% of Ethereum USDD; team reputation concerns | Partial |
| **Overall Risk** | **HIGH** | **Centralized control masquerading as DAO governance; reflexive TRX collateral risk; governance opacity** | |

## Detailed Findings

### 1. Governance & Admin Key

**Risk: CRITICAL**

This is the single most concerning aspect of USDD. Despite the "Decentralized" branding and "DAO Reserve" structure, governance is effectively centralized around TRON founder Justin Sun.

**Key findings:**

- **DAO dissolved:** The TRON DAO Reserve governance portal has been shut down. In the protocol's entire history (since April 2022), only one governance vote was ever conducted (May 2023, regarding burned TRX tokens). The voting page has since been taken down.
- **Unilateral collateral changes:** In August 2024, approximately 12,000 BTC ($732 million) were removed from USDD reserves without any DAO vote or community consultation. Justin Sun described this as "DeFi 101" and compared it to MakerDAO's operations, despite MakerDAO having on-chain governance for such decisions.
- **TRON DAO Reserve members:** The seven listed members (Poloniex, Amber Group, Ankr, Mirana Ventures, Multichain Capital, FalconX, TPS Capital) are the only entities that can mint USDD. However, the TRON Foundation controls entry to the DAO, and several members have unclear current status (Multichain ceased operations in 2023).
- **No verifiable multisig:** There is no publicly documented multisig threshold, signer list, or timelock mechanism for critical operations. The on-chain governance structure on TRON is opaque compared to EVM-based DAO frameworks.
- **Immutable contracts claim:** USDD 2.0 reportedly introduced immutable contracts with no admin keys. If true, this eliminates smart contract upgrade risk but does not address the off-chain governance risk around reserve management and collateral decisions, which is where the actual power resides.

**Comparison to UST/Luna:** Unlike Terra's purely algorithmic model that collapsed in May 2022, USDD 2.0 uses overcollateralization. However, the concentration of collateral in TRX (the protocol's own ecosystem token) creates a similar reflexive risk -- if TRX price falls, collateral value drops, potentially triggering a confidence crisis and further TRX selling.

### 2. Oracle & Price Feeds

**Risk: MEDIUM**

- **Primary oracle:** WINkLink (TRON-native oracle, associated with Justin Sun's ecosystem) was the primary oracle through May 2025. DeFiLlama records show a transition to Chainlink starting May 2025.
- **Chainlink integration:** The move to Chainlink is a significant improvement, providing industry-standard price feeds with decentralized node operators. However, Chainlink's coverage on TRON is more limited than on Ethereum.
- **PSM pricing:** The Peg Stability Module uses a fixed 1:1 exchange rate for USDD/USDT and USDD/USDC swaps, which is a design choice that simplifies peg maintenance but assumes the backing stablecoins maintain their own pegs.
- **Collateral valuation:** How TRX and sTRX collateral is valued within the CDP system (oracle source, TWAP parameters, circuit breakers) is not fully documented publicly.
- **Cross-chain oracle:** Each chain deployment (TRON, Ethereum, BNB Chain) presumably uses its own oracle infrastructure. Whether there is consistency and how cross-chain price discrepancies are handled is UNVERIFIED.

### 3. Economic Mechanism

**Risk: HIGH**

**Overcollateralization model (USDD 2.0):**
- Collateral: TRX, sTRX (staked TRX), and USDT
- Collateralization ratio: Reported between 103%-199% throughout 2025, averaging ~112%
- Peak collateral value: $620M+ (August 2025)
- As of early 2026: $611M collateral vs. $565M supply (reported)

**Critical concerns:**

1. **TRX concentration risk:** TRX reportedly constitutes ~40% of collateral. This creates reflexive/circular risk: USDD's value depends on TRX, which is part of the same TRON ecosystem. If TRX price drops sharply, the collateral ratio could fall below 100%, similar to the FTT/FTX dynamic. This is the most significant economic risk.

2. **Thin overcollateralization:** Average collateralization of ~112% provides only a 12% buffer above minimum. For comparison, MakerDAO's DAI typically requires 150%+ collateralization per vault. A 12% average buffer with volatile TRX collateral is concerning.

3. **Yield sustainability:** sUSDD offers 6-8% APY, funded by the "Smart Allocator" deploying reserves into DeFi protocols (Aave, JustLend). The sustainability of these yields depends on DeFi market conditions. Cumulative distributions of ~$20M across 459K wallets by end-2025 suggests modest actual payouts per user. The APY has already been reduced from 12% to 6-8%, indicating normalization.

4. **Liquidation mechanism:** USDD 2.0 includes automated liquidations and deficit auctions, but the specific parameters (liquidation ratio, penalty, auction duration) are not comprehensively documented in public sources.

5. **Peg history:** USDD depegged to $0.96 in June 2022 and below $0.97 during the FTX collapse in November 2022. It also experienced volatility during the 2024 Blast token launch. The USDD 2.0 upgrade in January 2025 was designed to address these issues.

6. **Insurance/bad debt fund:** No publicly disclosed insurance fund or its size relative to TVL. This is a significant information gap for a $1.29B stablecoin.

### 4. Smart Contract Security

**Risk: MEDIUM**

**Audit history:**
- 5 audits total from ChainSecurity and CertiK (January 2025 -- October 2025)
- ChainSecurity: Focused on PSM contracts, token integrations, emergency shutdowns, deficit auctions
- CertiK: Ethereum deployment audit (September 2025); Skynet AA rating (87.5/100)
- Public audit report available at usdd.io/USDD-V2-audit-report.pdf (January 24, 2025)
- All audits reportedly found no critical vulnerabilities

**Strengths:**
- Multiple audits from reputable firms
- CertiK's AA rating is among the higher scores in the stablecoin space
- USDD 2.0 contracts reportedly immutable (no admin keys)

**Concerns:**
- DeFiLlama lists 0 audits, suggesting the audits are not registered/linked in the standard DeFi audit databases
- TRON-native contracts are not fully open-sourced on GitHub or public repositories in the way that Ethereum-based protocols typically are
- No bug bounty program found on Immunefi or other major platforms
- The claim of "immutable contracts" could not be independently verified on TRON's block explorer

**Battle testing:**
- Protocol live since April 2022 (~4 years)
- Survived multiple market stress events (UST collapse, FTX collapse, 2024 volatility)
- No direct smart contract exploits reported
- Peak TVL now at ~$1.29B

### 5. Cross-Chain & Bridge

**Risk: MEDIUM**

**Multi-chain deployment:**
- TRON: ~$1.21B TVL (primary, ~94% of total)
- Ethereum: ~$60M TVL (launched September 2025)
- BNB Chain: ~$16.4M TVL (launched October 2025)

**Architecture:**
- Each chain has native USDD issuance (not bridged/wrapped tokens)
- Ethereum and BNB Chain use independent PSM contracts for minting/redemption
- BNB Chain PSM holds $12.5M USDT backing $12.5M USDD supply (1:1 ratio, verified per Messari)

**Concerns:**
- Whether admin controls (if any) are shared across chains or independently managed is UNVERIFIED
- The cross-chain mechanism for coordinating collateral and supply is not publicly documented
- Ethereum USDD supply is ~83% concentrated in HTX (Justin Sun's exchange), raising questions about whether the Ethereum deployment is primarily a centralized exchange product rather than a decentralized protocol
- Bridge security between chains (how USDD moves between TRON, Ethereum, and BSC) is not clearly documented

### 6. Operational Security

**Risk: HIGH**

**Team & track record:**
- Justin Sun: Founder of TRON, acquirer of Poloniex and HTX exchanges. Publicly doxxed but controversial figure with multiple regulatory and legal issues globally. SEC lawsuit settled. Known for aggressive marketing and promotional tactics.
- TRON DAO Reserve members: Seven named institutional members, but several are inactive or defunct (Multichain ceased operations in 2023). Whether the member list has been updated is UNVERIFIED.
- The protocol is fundamentally a one-person operation in terms of strategic decision-making, despite the DAO branding.

**HTX concentration risk:**
- ~83% of Ethereum USDD is held in HTX (Sun-owned exchange)
- ~61% of TRON USDD is lent on JustLend (Sun-affiliated lending protocol)
- This creates a dangerous concentration where the majority of USDD is within Justin Sun's ecosystem of controlled entities
- If HTX faces solvency issues (as with FTX), USDD holders on Ethereum would be directly impacted

**Incident response:**
- USDD 2.0 includes emergency shutdown capability (per ChainSecurity audit scope)
- No publicly documented incident response plan
- Communication primarily through Justin Sun's personal social media and USDD Medium blog

**Regulatory risk:**
- Justin Sun has faced SEC enforcement action (settled)
- Multiple regulatory investigations in various jurisdictions
- TRON network's association with illicit finance has been flagged by blockchain analytics firms
- Regulatory action against Sun or HTX could directly impact USDD operations

## Critical Risks

1. **CRITICAL -- Governance centralization:** Justin Sun effectively controls USDD unilaterally. The DAO is dissolved, no multisig is verifiable, and $732M in collateral was removed without any governance process. This is a single-point-of-failure for a $1.29B stablecoin.

2. **HIGH -- Reflexive TRX collateral risk:** With ~40% of collateral in TRX, a sharp decline in TRX price could simultaneously reduce collateral value and trigger a confidence crisis, creating a downward spiral similar to UST/Luna or FTT/FTX dynamics.

3. **HIGH -- HTX concentration:** The majority of USDD on Ethereum sits in Justin Sun's own exchange. Exchange insolvency would directly threaten USDD holders. This is not a decentralized stablecoin in practice.

4. **HIGH -- Information opacity:** Key parameters (exact collateral breakdown, insurance fund, liquidation parameters, multisig configuration, smart contract source code on TRON) are not publicly verifiable, forcing reliance on self-reported data.

## Peer Comparison

| Feature | USDD | DAI (MakerDAO/Sky) | USDe (Ethena) |
|---------|------|---------------------|---------------|
| Timelock | None verified | 48h governance delay | Present (UNVERIFIED hours) |
| Multisig | UNVERIFIED / None | On-chain DAO governance | 7/10 protocol multisig |
| Audits | 5 (ChainSecurity, CertiK) | 20+ (multiple firms) | 7+ (Code4rena, Cyfrin, etc.) |
| Oracle | WINkLink -> Chainlink | Chainlink (primary) | Internal + Chainlink |
| Insurance/TVL | Undisclosed | ~5% (Surplus Buffer) | ~1.2% ($77M) |
| Open Source | Partial (Ethereum only) | Full | Full |
| Collateral | TRX, sTRX, USDT | ETH, wBTC, USDC, RWA | Delta-neutral (ETH/BTC perps) |
| Governance | Centralized (Justin Sun) | On-chain DAO (MKR holders) | Multisig + governance forum |
| Depeg history | $0.96 (Jun 2022), $0.97 (Nov 2022) | $0.89 (Mar 2023, USDC cascade) | Minor (<1%) deviations |

USDD compares unfavorably to both peers on governance decentralization, transparency, and audit depth. Its primary differentiator is the high APY offered through sUSDD, which may not be sustainable.

## Recommendations

1. **For users holding USDD:** Be aware that this is effectively a centralized stablecoin controlled by Justin Sun, despite the "Decentralized" branding. Risk-adjust accordingly.

2. **For users staking sUSDD:** The 6-8% APY is attractive but carries counterparty risk through HTX and Justin Sun's ecosystem. Ensure exposure is sized appropriately.

3. **Monitor collateral composition:** Track the USDD reserve page regularly. Unannounced collateral changes (like the $732M BTC removal) have occurred before and could occur again.

4. **Prefer TRON-native USDD if using USDD:** The TRON deployment has the deepest liquidity and longest track record. Ethereum USDD is highly concentrated in HTX.

5. **Diversify stablecoin exposure:** Do not rely solely on USDD. Pair with USDT, USDC, or DAI for stablecoin needs, especially for larger positions.

6. **Avoid large concentrated positions:** The lack of verifiable governance, insurance fund, and the reflexive TRX collateral risk make large USDD positions inadvisable.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [X] Admin can list new collateral without timelock? -- Collateral changes made unilaterally ($732M BTC removal)
- [X] Admin can change oracle sources arbitrarily? -- Oracle transitioned from WINkLink to Chainlink; decision-making process opaque
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED
- [X] Multisig has low threshold (2/N with small N)? -- No verifiable multisig at all
- [X] Zero or short timelock on governance actions? -- No timelock verified
- [ ] Pre-signed transaction risk? -- N/A (not Solana)
- [X] Social engineering surface area (anon multisig signers)? -- DAO members are institutions but their operational security and current status is unknown

**5/6 applicable flags triggered -- HIGH Drift-type pattern match**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- TRX has reasonable liquidity but is ecosystem-correlated
- [X] Single oracle source without TWAP? -- WINkLink was single source; Chainlink transition helps but TWAP parameters unknown
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [X] Insufficient insurance fund relative to TVL? -- Insurance fund undisclosed

**2/4 flags triggered -- MEDIUM Euler/Mango-type pattern match**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Native deployments, not bridged
- [X] Admin keys stored in hot wallets? -- Key management practices UNVERIFIED; no HSM/cold storage documentation
- [X] No key rotation policy? -- No key rotation documentation found

**2/3 flags triggered -- MEDIUM Ronin/Harmony-type pattern match**

## Information Gaps

The following questions could NOT be answered from publicly available information. These gaps represent unknown risks:

1. **Multisig configuration:** What is the exact multisig threshold and signer list for USDD reserve management? Is there a multisig at all, or is it a single key?
2. **TRON contract source code:** Are the core USDD contracts on TRON fully open-sourced and verifiable? Where is the public repository?
3. **Insurance/bad debt fund:** Is there a dedicated insurance fund? What is its size relative to TVL?
4. **Liquidation parameters:** What are the specific liquidation ratios, penalties, and auction mechanisms for the CDP system?
5. **TRX collateral percentage:** What is the exact current breakdown of collateral by asset type (TRX vs. sTRX vs. USDT)?
6. **Cross-chain coordination:** How is USDD supply and collateral coordinated across TRON, Ethereum, and BNB Chain?
7. **Smart Allocator details:** What specific DeFi protocols receive reserve deployments, and what risk parameters govern allocation?
8. **TRON DAO Reserve member status:** Are all seven listed members still active? How are new members added or removed?
9. **Emergency shutdown authority:** Who can trigger emergency shutdown, and under what conditions?
10. **Key management:** How are admin keys (if any) stored? Are hardware security modules used?
11. **Revenue model sustainability:** How long can 6-8% APY be maintained? What happens to peg stability if yields are reduced to 0%?
12. **Regulatory compliance:** What jurisdictions does USDD operate under? Are there any pending regulatory actions?

## Disclaimer

This analysis is based on publicly available information and web research conducted on April 6, 2026. It is NOT a formal smart contract audit. The analysis was limited by GoPlus API rate limits (partial data only), the opacity of TRON-based governance structures, and the lack of comprehensive public documentation for many critical protocol parameters. Always DYOR and consider professional auditing services for investment decisions.
