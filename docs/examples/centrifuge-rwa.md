# DeFi Security Audit: Centrifuge

**Audit Date:** April 6, 2026
**Protocol:** Centrifuge -- Multi-chain RWA (Real World Asset) tokenization and onchain asset management

## Overview
- Protocol: Centrifuge (V3)
- Chain: Ethereum (primary hub), Base, Arbitrum, Avalanche, Optimism, BSC, Plume, HyperEVM, Monad (9 chains)
- Type: RWA Tokenization / Structured Credit / Onchain Fund Management
- TVL: ~$1.71B (DeFiLlama, April 2026)
- TVL Trend: +8.1% / +24.1% / +31.5% (7d/30d/90d)
- Launch Date: 2019 (Tinlake on Ethereum); V3 launched April 2025
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: github.com/centrifuge)

## Quick Triage Score: 62/100

Starting at 100, subtracting:
- [-8] GoPlus: is_mintable = 1 (wCFG token is mintable)
- [-5] No documented insurance fund / TVL ratio (undisclosed)
- [-5] Undisclosed multisig signer identities (Guardian Safe signers not publicly named)
- [-5] DAO governance paused or dissolved (CP171 suspended active DAO governance, Nov 2025)
- [-5] Single oracle provider (Chronicle Labs for RWA NAV)
- [-5] No documented bug bounty on Immunefi (bounty is on Cantina instead -- $250K max)
- [-5] No documented timelock on admin actions (Guardian has 24h Zodiac Delay but Root has 48h -- partial credit, but Guardian bypass exists)

Score: 100 - 8 - 5 - 5 - 5 - 5 - 5 - 5 = **62** (MEDIUM risk)

Red flags found: 7 (mintable token, no insurance fund disclosure, anonymous Guardian signers, suspended DAO governance, single oracle for NAV, no Immunefi bounty, Guardian timelock bypass potential)

## Quantitative Metrics

| Metric | Value | Benchmark (RWA peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | 1-5% (DeFi avg) | HIGH |
| Audit Coverage Score | 12.5+ (24 audits, many recent) | 1-3 avg | LOW risk |
| Governance Decentralization | Foundation-controlled (CP171) | DAO avg | HIGH |
| Timelock Duration | 48h (Root) / 24h (Guardian Zodiac) | 24-48h avg | MEDIUM |
| Multisig Threshold | UNVERIFIED (Guardian is Gnosis Safe) | 3/5 avg | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW risk |

## GoPlus Token Security (wCFG on Ethereum: 0xc221b7E65FfC80DE234bbB6667aBDd46593D34F0)

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
| Holders | 7,159 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No | -- |
| CEX Listed | Coinbase | -- |

GoPlus assessment: **LOW RISK**. The only flag is `is_mintable = 1`, which is expected for a wrapped bridge token (wCFG wraps the native CFG from the former Centrifuge Chain). No honeypot, no hidden owner, no tax, no trading restrictions. Top holder (0xacf3...3069) holds 95.1% and is a contract (likely the bridge/wrapping contract). Low holder count (7,159) reflects that most CFG activity has migrated to the new EVM-native token (0xcccccccc...1ff4e8a94).

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **HIGH** | DAO governance suspended (CP171); Foundation controls operations and treasury unilaterally | Partial |
| Oracle & Price Feeds | **MEDIUM** | Single oracle provider (Chronicle Labs) for RWA NAV; off-chain valuation dependency | Partial |
| Economic Mechanism | **MEDIUM** | $6M+ in historical defaults (Harbor Trade Credit); no protocol-level insurance fund disclosed | Partial |
| Smart Contract | **LOW** | 24 security reviews, 0 exploits since 2019; critical router flaw caught pre-deployment | Y |
| Token Contract (GoPlus) | **LOW** | Mintable (expected for wrapped token); no other flags | Y |
| Cross-Chain & Bridge | **MEDIUM** | Wormhole dependency for cross-chain messaging; 9-chain deployment surface area | Partial |
| Operational Security | **LOW** | Doxxed team, 7-year track record, active security program | Y |
| **Overall Risk** | **MEDIUM** | **Strong technical security offset by centralized governance and inherent RWA credit/legal risks** | |

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Admin Key Surface Area:**
- The protocol is controlled by the **Root contract** (Ethereum: `0x7Ed48C31f2fdC40d37407cBaBf0870B2b688368f`), which has access to all other contracts and enforces a **48-hour delay** for upgrades and configuration changes.
- Each deployment has a **Guardian role** (address: `0xCEb7eD5d5B3bAD3088f6A1697738B60d829635c6` for Protocol Guardian, `0x055589229506Ee89645EF08ebE9B9a863486d0dE` for Ops Guardian), implemented as a **Gnosis Safe** with a **Zodiac Delay module** enforcing a **24-hour delay**.
- The Guardian can: pause the protocol in emergencies, schedule upgrades, and set up adapters to new networks.
- The protocol codebase is described as "fully immutable" with emergency functions locked behind a **48-hour timelock**.

**Multisig Configuration:**
- Guardian is a Gnosis Safe, but the **threshold (m/n) and signer identities are not publicly documented** in the official security docs. This is a significant transparency gap for a $1.7B protocol. UNVERIFIED.

**Governance Suspension (CP171):**
- On November 3, 2025, the Centrifuge DAO approved **CP171**, which paused active DAO governance and transferred operational decision-making to the **Centrifuge Network Foundation (CNF)** and its subsidiary **Centrifuge Labs**.
- Under CP171: marketing, product development, partnerships, distribution, and revenue growth decisions are made by Labs. DAO treasury assets (CFG tokens, stablecoins, fiat) transferred to CNF for management.
- The DAO retains the theoretical ability to create a proposal to transfer control back, but with governance mechanisms paused, the practical ability to do so is unclear.
- This represents a **deliberate centralization trade-off** for operational efficiency, but creates concentrated risk: a single entity controls protocol operations, treasury, and strategic direction for a $1.7B protocol.

**Timelock Bypass Assessment:**
- The Guardian (Gnosis Safe) can schedule actions with only a 24-hour Zodiac Delay, while the Root contract enforces 48 hours. The Guardian role can effectively bypass the longer Root delay for certain operations. The exact scope of what the Guardian can do without Root approval is not fully documented publicly.

**Rating: HIGH** -- The combination of suspended DAO governance, Foundation-controlled treasury, undisclosed multisig configuration, and potential Guardian timelock bypass creates significant centralization risk.

### 2. Oracle & Price Feeds -- MEDIUM

**Oracle Architecture:**
- Centrifuge uses **Chronicle Labs** as its primary oracle provider for RWA Net Asset Value (NAV) calculations.
- Chronicle's **Verified Asset Oracle** provides on-chain tracking of fund NAV, pulling data from custodians (e.g., Trident Trust) and market sources.
- The protocol's **Proof of Portfolio** dashboard offers real-time reporting verified by third-party sources.

**RWA Valuation Challenge:**
- Unlike DeFi tokens with liquid on-chain markets, RWA valuations depend on **off-chain data sources**: custodian reports, fund administrator NAV calculations, and traditional financial market prices.
- This creates an inherent trust dependency: the oracle reports what off-chain entities provide. If a custodian misreports asset holdings, the on-chain NAV will be incorrect.
- For assets like US Treasury bills (Anemoy/Janus Henderson fund), the valuation risk is low. For private credit and trade receivables, the risk is substantially higher.

**Single Oracle Provider:**
- Chronicle Labs is the sole oracle provider for RWA NAV. There is no documented fallback oracle or multi-source verification for on-chain price data.
- Chronicle itself is a reputable provider (originally MakerDAO's oracle), but single-source dependency remains a risk.

**Admin Oracle Control:**
- The hub chain handles NAV calculations and pushes price oracle updates to all networks. UNVERIFIED whether admin can override oracle sources without timelock.

**Rating: MEDIUM** -- Single oracle provider with inherent off-chain data dependency. Mitigated by Chronicle's reputation and third-party verification (Trident Trust).

### 3. Economic Mechanism -- MEDIUM

**RWA Credit Risk:**
- Centrifuge pools finance real-world assets including trade receivables, real estate, corporate credit, and US Treasuries. Credit risk is the primary economic risk.
- Each pool has an associated **Special Purpose Vehicle (SPV)** that legally holds the tokenized assets, providing bankruptcy remoteness from the asset originator.
- The **tranche structure** (senior/junior) provides waterfall protection: junior tranche (TIN) absorbs losses first, protecting senior tranche (DROP) investors.

**Historical Defaults:**
- In February 2023, Centrifuge accrued **~$5.8M in overdue loans** across two lending pools, including consumer loans, invoices, and trade receivables.
- **Harbor Trade Credit** defaults led MakerDAO to halt lending to the pool after **$2.1M in loan defaults** (July 2023). All 3 remaining assets in the HTC2 pool were in default since April 2023.
- In August 2023, additional defaults on tokenized loans put MakerDAO's investment at risk.
- These defaults demonstrated that the legal enforcement mechanism (SPV pursuing defaulting borrowers) is slow and uncertain in practice.

**Insurance Fund:**
- No protocol-level insurance fund has been publicly disclosed. Bad debt is handled through the tranche waterfall structure (junior absorbs first) and legal recovery via SPVs.
- Insurance Fund / TVL ratio: **Undisclosed / Not applicable** in the traditional DeFi sense. The junior tranche functions as a first-loss buffer, but its size varies by pool.

**Liquidation Mechanism:**
- RWA assets cannot be liquidated in the same way as crypto collateral. Recovery depends on real-world legal proceedings, which may take months or years.
- The investment flow is asynchronous (ERC-7540 standard): redemption requests are processed by pool operators, not instant.

**Integration Risk:**
- Centrifuge pools have been used as collateral sources for MakerDAO (now Sky) and Aave. The BlockTower vaults provided $120M+ in DAI through MakerDAO.
- The **$100M JAAA strategy with Resolv** (2026) represents one of the largest RWA deployments in DeFi.
- If a major Centrifuge pool defaults, it could cascade to MakerDAO/Aave positions.

**Rating: MEDIUM** -- Historical defaults demonstrate real credit risk, but improved originator vetting and tranche structures provide meaningful protection. The lack of a protocol-level insurance fund is a gap.

### 4. Smart Contract Security -- LOW

**Audit History:**
- **24 security reviews** completed since 2019, with **0 exploits** in production.
- Recent audits (2025-2026) include:
  - Sherlock: V3.1 (Feb 2026, Nov-Dec 2025)
  - yAudit: V3.1 (Jan 2026, Oct 2025, June 2025)
  - BurraSec: V3.1 (Oct 2025, Sep 2025, Aug 2025, May 2025, Apr 2025)
  - Spearbit: V3.0 (July 2025, May 2025), V2.1 (Feb 2025), V2.0 (July 2024)
  - Code4rena: V1.0 (Sep 2023)
  - Macro, xmxanuel, Alex the Entreprenerd, Recon, SRLabs -- multiple engagements

**Audit Coverage Score:**
- 9 audits less than 1 year old (9.0) + 6 audits 1-2 years old (3.0) + ~9 audits older (2.25) = **~14.25**
- This is exceptionally high, well above the LOW risk threshold of 3.0.

**Critical Vulnerability Found (Pre-deployment):**
- A **critical vulnerability** was discovered in the Centrifuge router contract during a Spearbit review. The router lacked proper ownership verification: an attacker could call `open()` to gain control of a vault, then use `requestDeposit()` or `requestRedeem()` to deposit or withdraw assets without the owner's permission.
- The flaw was **fixed before deployment** by adding ownership verification to `requestDeposit()` and `requestRedeem()`. This demonstrates the audit program's effectiveness.

**Bug Bounty:**
- Active **$250,000 bug bounty** on Cantina (not Immunefi).
- Protocol has been live since 2019 with no production exploits.

**Architecture:**
- "Immutable core, modular extensions" design -- core contracts are immutable, with customizable extensions (investment vaults, transfer hooks, balance sheet managers, hub managers, valuation contracts, cross-chain adapters).
- Hub-and-spoke model: Ethereum hub handles accounting, NAV, and investment processing; spoke chains handle tokenization and distribution.

**Rating: LOW** -- Exceptional audit coverage (24 reviews, 6+ firms), 0 production exploits in 7 years, active bug bounty, and immutable core design.

### 5. Cross-Chain & Bridge -- MEDIUM

**Multi-Chain Deployment:**
- Deployed across **9 mainnet chains**: Ethereum, Base, Arbitrum, Avalanche, Optimism, BSC, Plume, HyperEVM, and Monad.
- Ethereum serves as the **hub chain** for accounting, NAV calculations, and governance. Other chains are spokes for tokenization and distribution.
- Most core contract addresses are consistent across chains (deterministic deployment), but Root contract addresses differ between Ethereum and other chains.

**Bridge Dependencies:**
- Centrifuge V3 uses **Wormhole** as the primary cross-chain messaging provider, with additional adapters for **LayerZero**, **Chainlink CCIP**, and **Axelar**.
- The multi-adapter approach provides redundancy: if one messaging provider fails, others can be used.
- Wormhole's Guardian Network consists of **19 independent validators** with a 13/19 (2/3+) signature threshold for message verification.

**Cross-Chain Message Security:**
- Cross-chain transfers use a **burn-and-mint mechanism** for 1:1 token movement.
- The Gateway contract (`0x19a524D03aA94ECEe41a80341537BCFCb47D3172`) handles cross-chain message processing.
- Each adapter has been audited (BurraSec audited the LayerZero adapter in Aug 2025; Gateway audited in Apr-May 2025).

**Risks:**
- A compromised bridge could potentially forge messages affecting pool operations on spoke chains.
- The 9-chain deployment surface area is large, increasing the attack surface.
- Bridge dependencies (Wormhole primarily) create systemic risk: a Wormhole exploit could affect all cross-chain operations.

**Rating: MEDIUM** -- Multi-adapter redundancy mitigates single bridge risk, but the 9-chain surface area and reliance on Wormhole for primary operations create meaningful exposure. Wormhole's 2022 exploit ($320M) is a historical concern, though Wormhole has since improved its security.

### 6. Operational Security -- LOW

**Team & Track Record:**
- Founded in 2017 by **Lucas Vogelsang, Martin Quensel, Maex Ament, and Philip Stehlik** -- all publicly identified (doxxed).
- Lucas Vogelsang serves as CEO and has been active in industry events (e.g., AIMA conferences).
- The team has raised institutional funding (tracked on Tracxn, Dealroom, CB Insights).
- 7+ years of operation with no protocol-level exploits.

**Incident Response:**
- Guardian role enables emergency pause functionality.
- Security vulnerability disclosure program at centrifuge.io/security.
- Contact: security@centrifuge.io.
- Active bug bounty ($250K on Cantina).

**Dependencies:**
- **Chronicle Labs** (oracle/NAV), **Wormhole** (cross-chain), **Gnosis Safe** (multisig), **LayerZero/Chainlink CCIP/Axelar** (additional adapters).
- **Legal dependencies**: SPV structures, fund administrators (Trident Trust), custodians, real-world legal systems for debt recovery.
- **Institutional partners**: MakerDAO/Sky, Aave, Resolv, Janus Henderson, S&P DJI.

**Rating: LOW** -- Doxxed team with 7+ years of track record, active security program, multiple institutional partnerships validating operational credibility.

## Critical Risks

1. **Centralized Governance (HIGH)**: CP171 suspended DAO governance and placed operational control and treasury management under the Centrifuge Network Foundation. While theoretically reversible, the practical mechanism for the DAO to reassume control with paused governance infrastructure is unclear. A single organizational failure, compromise, or misalignment could affect the entire $1.7B protocol.

2. **RWA Credit Default Risk (MEDIUM-HIGH)**: Historical defaults ($6M+ across Harbor Trade and other pools) demonstrate that real-world borrower default is a material risk. Legal recovery through SPVs is slow and uncertain. A large-scale default in a major pool could cascade to integrated protocols (MakerDAO, Aave).

3. **Off-Chain Trust Dependencies (MEDIUM)**: RWA valuation, custody, and legal enforcement all depend on off-chain entities and legal systems. Smart contracts cannot force a real-world borrower to repay. The protocol's security guarantees are only as strong as the weakest link in the off-chain chain of trust.

4. **Undisclosed Guardian Multisig Configuration (MEDIUM)**: The Guardian Safe threshold and signer identities are not publicly documented for a $1.7B protocol. This prevents independent verification of a critical security layer.

## Peer Comparison

| Feature | Centrifuge | Ondo Finance | Maple Finance |
|---------|-----------|-------------|---------------|
| Timelock | 48h (Root) / 24h (Guardian) | UNVERIFIED | UNVERIFIED |
| Multisig | Gnosis Safe (threshold UNVERIFIED) | UNVERIFIED | UNVERIFIED |
| Audits | 24 reviews, 6+ firms | Multiple audits | Multiple audits |
| Oracle | Chronicle Labs (single) | Proprietary NAV | Proprietary |
| Insurance/TVL | Undisclosed (tranche waterfall) | N/A (treasury-backed) | Pool-level reserves |
| Open Source | Yes | Partial | Yes |
| TVL | ~$1.71B | ~$4B+ | ~$200M |
| Governance | Foundation-controlled (CP171) | Centralized | DAO + team |
| Default History | $6M+ (2023) | None (US Treasuries) | $36M+ (2022, Orthogonal) |
| Asset Types | Diverse (credit, treasuries, RE) | US Treasuries primarily | Corporate credit |

## Recommendations

1. **For investors**: Understand that Centrifuge pool risk varies dramatically by underlying asset type. US Treasury-backed pools (e.g., Anemoy/Janus Henderson) carry far less credit risk than private credit or trade receivable pools. Evaluate each pool individually, not just the protocol.

2. **For the protocol**: Publicly disclose Guardian multisig threshold, signer count, and signer identities. For a $1.7B protocol, the current opacity around this critical security layer is below industry best practice.

3. **For the protocol**: Publish a clear roadmap for restoring DAO governance. The CP171 centralization is a reputational and structural risk that institutional investors may increasingly scrutinize.

4. **For the protocol**: Consider adding a secondary oracle provider or multi-source verification for RWA NAV to reduce single-point-of-failure risk on Chronicle Labs.

5. **For DeFi integrators (MakerDAO, Aave)**: Monitor the tranche structure and junior tranche coverage ratios of integrated Centrifuge pools. Historical defaults demonstrate that credit losses are a when-not-if scenario for private credit pools.

6. **For all participants**: Understand that legal enforceability of on-chain claims on real-world assets depends on the jurisdiction, SPV structure, and local legal systems. Smart contract guarantees do not extend to off-chain asset recovery.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- Root enforces 48h delay. LOW risk.
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED. Potential risk given Foundation control.
- [ ] Admin can modify withdrawal limits? -- Pool operators control redemption processing. MEDIUM risk.
- [x] Multisig has low threshold (2/N with small N)? -- **UNVERIFIED. Guardian Safe threshold not disclosed.**
- [ ] Zero or short timelock on governance actions? -- 48h Root / 24h Guardian. Adequate.
- [ ] Pre-signed transaction risk? -- N/A (EVM, not Solana).
- [x] Social engineering surface area (anon multisig signers)? -- **Guardian signer identities not public.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- RWA collateral is illiquid by nature but valued by NAV, not market. MEDIUM.
- [x] Single oracle source without TWAP? -- **Chronicle Labs is sole NAV oracle.** (TWAP not applicable for RWA.)
- [ ] No circuit breaker on price movements? -- UNVERIFIED for NAV updates.
- [x] Insufficient insurance fund relative to TVL? -- **No protocol-level insurance fund disclosed.**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Wormhole (19 Guardians, 13/19 threshold). Acceptable.
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED. Guardian is Gnosis Safe.
- [ ] No key rotation policy? -- UNVERIFIED.

## Information Gaps

The following questions could NOT be definitively answered from publicly available information. Each represents an unknown risk:

1. **Guardian multisig threshold and signer identities**: The exact m/n configuration and who the signers are for the Protocol Guardian and Ops Guardian Safes are not documented in public security docs.
2. **Scope of Guardian bypass powers**: Exactly which Root-level operations the Guardian can perform with only the 24h Zodiac Delay (vs. the full 48h Root delay) is not publicly specified.
3. **Oracle admin override capability**: Whether admin/Guardian can change oracle sources or override NAV calculations without timelock is not documented.
4. **Insurance fund or reserve status**: No protocol-level insurance or reserve fund has been disclosed. The tranche waterfall is the only documented loss absorption mechanism.
5. **CP171 governance reassumption mechanism**: The practical process for CFG token holders to reinstate DAO governance with the governance infrastructure paused is unclear.
6. **Per-pool junior tranche coverage ratios**: Aggregate junior tranche coverage across all active pools is not readily available for independent risk assessment.
7. **Legal jurisdiction enforceability**: The effectiveness of SPV-based legal recovery across different jurisdictions (for global borrowers) has limited public track record beyond the Harbor Trade case.
8. **Foundation treasury management policies**: Investment guidelines, risk limits, and reporting cadence for the Foundation-managed treasury are not publicly documented beyond quarterly earnings call commitments.
9. **Wormhole message validation specifics**: How Centrifuge validates and rate-limits cross-chain messages from Wormhole to prevent replay or forgery attacks is not publicly detailed.
10. **GoPlus note**: The wCFG token analyzed (0xc221b7E65FfC80DE234bbB6667aBDd46593D34F0) is the legacy wrapped token. The new EVM-native CFG token (0xcccccccccc33d538dbc2ee4feab0a7a1ff4e8a94) was not available in GoPlus at the time of this audit.

## Disclaimer

This analysis is based on publicly available information and web research conducted on April 6, 2026. It is NOT a formal smart contract audit. Centrifuge's risk profile is unique among DeFi protocols because it introduces real-world credit risk, legal enforceability risk, and off-chain trust dependencies that are fundamentally different from on-chain-only protocol risks. Always DYOR and consider professional auditing services and legal counsel for investment decisions.
