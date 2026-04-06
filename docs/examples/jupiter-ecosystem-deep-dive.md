# DeFi Security Audit: Jupiter Ecosystem Deep Dive

**Audit Date:** April 6, 2026
**Protocol:** Jupiter -- Full Ecosystem Analysis (Companion to [Jupiter Main Audit](jupiter-solana-dex.md))

## Overview

- Protocol: Jupiter (Ecosystem)
- Chain: Solana
- Type: DeFi Superapp -- DEX Aggregator, Perpetuals, Lending, Stablecoin, Liquid Staking, Token Launchpad, Prediction Markets, Payments
- Combined TVL: ~$2.42B (Jupiter main ~$1.71B + JupSOL ~$711M)
- Token: JUP (Solana SPL token)
- Launch Date: October 2021 (aggregator); sub-products launched 2023-2026
- Audit Date: April 6, 2026
- Source Code: Partial (Jupiter Lock and some Lend contracts open source; core aggregator routing closed)

This report is a companion to the [main Jupiter security audit](jupiter-solana-dex.md) dated April 5, 2026, which covers the protocol-level risk assessment, triage scoring, and hack pattern analysis. This document provides a deep-dive into each sub-project and product within the Jupiter ecosystem, assessing the unique security risks, admin controls, and audit status of each component.

## Jupiter Ecosystem Map

Jupiter has evolved from a swap aggregator into what its founders call a "DeFi superapp." As of April 2026, the ecosystem includes the following products:

| # | Product | Category | TVL / Scale | Status |
|---|---------|----------|-------------|--------|
| 1 | Jupiter Exchange (Aggregator) | DEX Aggregator | Routes ~95% of Solana aggregator volume | Production |
| 2 | Jupiter Perpetuals | Perps DEX | ~$679M (JLP pool) | Production |
| 3 | JLP (Jupiter Liquidity Provider) | Liquidity Token | ~$679M | Production |
| 4 | Jupiter DCA | Dollar-Cost Averaging | Active orders (TVL not separately tracked) | Production |
| 5 | Jupiter Limit Orders | Limit Order Book | Active orders (TVL not separately tracked) | Production |
| 6 | Jupiter Lend | Lending/Borrowing | Recently launched; TVL growing | Production (early) |
| 7 | JupUSD | Stablecoin | Launched Jan 2026 | Production (early) |
| 8 | JupSOL | Liquid Staking Token | ~$711M | Production |
| 9 | Jupiter Lock | Token Vesting/Locking | Infrastructure tool (no direct TVL) | Production |
| 10 | LFG Launchpad | Token Launchpad | 78 projects launched | Production |
| 11 | Jupiter Studio | No-Code Token Minting | Launched Jul 2025 | Production |
| 12 | Ape Pro | Memecoin Trading | Active trading volume | Production |
| 13 | Jupiter Card | On-Chain Payments | Launched Mar 2026 | Production (early) |
| 14 | Jupiter Portfolio / explore.ag | Portfolio Tracker / Explorer | Launched Jan 2026 | Production |
| 15 | Polymarket Integration | Prediction Markets | Launched Feb 2026 | Production |
| 16 | Jupiter DAO / JUP Governance | Governance | DAO paused Jun 2025; partial resumption Feb 2026 | Paused/Partial |
| 17 | Sanctum (Affiliated) | LST Infrastructure | Powers JupSOL and most Solana LSTs | Production (independent) |

## Ecosystem-Wide Risk Summary

| Category | Risk Level | Key Concern |
|----------|-----------|-------------|
| Ecosystem Complexity | **HIGH** | 15+ products under one brand; attack surface is vast and growing |
| Shared Admin Infrastructure | **MEDIUM** | Squads multisig controls multiple programs; threshold UNVERIFIED |
| Contagion Risk | **HIGH** | Products are deeply interconnected; failure in one can cascade |
| Audit Coverage Across Products | **MEDIUM** | Core products well-audited; newer products (Card, Studio, Ape) audit status unclear |
| Governance Centralization | **MEDIUM** | DAO paused; team makes all decisions for 15+ products |
| Rapid Product Expansion | **MEDIUM** | 6+ products launched in 12 months (Jan 2025 - Jan 2026) |

---

## Detailed Sub-Project Analysis

### 1. Jupiter Exchange (DEX Aggregator)

**What it does:** Routes trades across all Solana DEXes to find the best price. Handles approximately 95% of all aggregator volume on Solana.

**Key Program:** `JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4` (Swap v6)

**Admin Controls:**
- Program is upgradeable via Squads multisig (threshold UNVERIFIED)
- Routing engine is closed source -- the algorithm that selects routes is proprietary
- Admin can presumably add/remove supported DEXes from routing

**Security Risks:**
- **Closed-source routing engine (HIGH):** The core value proposition of Jupiter -- finding optimal routes -- runs on proprietary code. Users must trust that the routing does not front-run, sandwich, or otherwise extract value beyond disclosed fees. This cannot be independently verified.
- **MEV exposure:** While Jupiter has implemented anti-MEV protections, the aggregator sits at the highest-value position in the Solana MEV supply chain. Any routing manipulation would be extremely lucrative.
- **Keeper/relayer trust:** Transactions are submitted through Jupiter's infrastructure, adding a trust assumption beyond the smart contract itself.

**Audit Status:**
- Offside Labs (Oct 2025) -- v6 audit
- Offside Labs (Apr 2024) -- v6 audit
- Sec3 -- v3 audit (older)

**Risk Rating: MEDIUM** -- Extensive battle testing (live since 2021, $50B+ cumulative volume) mitigates the closed-source concern somewhat, but the opacity of the routing engine remains a persistent trust gap.

---

### 2. Jupiter Perpetuals

**What it does:** LP-to-trader perpetual futures exchange offering up to 250x leverage on SOL, ETH, and wBTC. The JLP pool acts as counterparty to all trades.

**Key Program:** `PERPHjGBqRHArX4DySjwM6UJHiR3sWAatqfdBS2qQJu`

**Admin Controls:**
- Program upgrade authority held by Squads multisig (threshold UNVERIFIED)
- Admin can adjust leverage limits, fee parameters, and AUM caps
- Admin can add/remove supported trading pairs
- Admin can change oracle sources (UNVERIFIED whether timelock exists)

**Oracle Design:**
- Tri-oracle system: Edge (by Chaos Labs, primary), Chainlink (verification), Pyth (verification)
- Cross-verification logic: Edge price used only if not stale and within threshold of both Chainlink and Pyth
- Fallback to Chainlink/Pyth if Edge deviates
- The "Dove Oracle" was co-designed by Jupiter and Chaos Labs and separately audited by Offside Labs

**Security Risks:**
- **250x leverage (HIGH):** The increase from 100x to 250x magnifies liquidation cascade risk. A sudden oracle failure or price spike could trigger mass liquidations faster than the system can process them.
- **Keeper trust:** Keepers match orders and trigger liquidations. The OtterSec 2023 audit flagged a HIGH severity issue where a malicious keeper could front-run position updates. Whether this was fully remediated is UNVERIFIED.
- **JLP counterparty risk:** See JLP section below.
- **No dedicated insurance fund:** The JLP pool absorbs all losses. Insurance/TVL ratio is effectively 0%.

**Audit Status:**
- OtterSec -- perpetuals audit (Oct-Nov 2023, found 2 HIGH severity issues)
- Offside Labs -- perpetuals audit
- Sec3 -- perpetuals audit (older)
- Offside Labs -- Oracle and Flashloan report (Oct 2025)

**Risk Rating: MEDIUM** -- Tri-oracle design is strong. Leverage increase to 250x is concerning. No insurance fund is a structural gap. Well-audited but keeper trust remains a question.

---

### 3. JLP (Jupiter Liquidity Provider Token)

**What it does:** JLP is the liquidity token for Jupiter Perpetuals. JLP holders provide liquidity (SOL, ETH, wBTC, USDC, USDT) and act as counterparty to all perp traders. JLP holders earn 75% of all fees; Jupiter takes 25%.

**TVL:** ~$679M (as of April 2026)

**Pool Composition:** SOL, ETH, wBTC, USDC, USDT with configurable target weights

**Security Risks:**
- **Direct counterparty risk (HIGH):** JLP holders are on the opposite side of every perp trade. If traders as a group are net profitable, JLP holders lose money. There is no insurance backstop.
- **Drift hack contagion (HIGH):** The Drift Protocol exploit (April 1, 2026) resulted in ~42.7 million JLP (~$159M) being drained from a Drift vault. While this was not a Jupiter vulnerability, it demonstrated that JLP's value can be affected by external protocol failures. The stolen JLP was swapped through Jupiter itself, temporarily impacting JLP supply and liquidity.
- **AUM limit governance:** The JLP pool has a configurable AUM cap that limits how much liquidity can be deposited. Who can change this cap, and under what conditions, is UNVERIFIED. Removing or raising the cap without proper risk assessment could over-expose the pool.
- **Composition drift:** The pool's target weight allocation between volatile assets (SOL, ETH, wBTC) and stables (USDC, USDT) determines risk exposure. Admin-controlled rebalancing parameters could shift risk profiles.

**Audit Status:** Audited as part of Jupiter Perpetuals audits (OtterSec, Offside Labs, Sec3).

**Risk Rating: HIGH** -- The zero-insurance model, direct counterparty exposure, and demonstrated contagion vulnerability via the Drift hack make JLP one of the higher-risk components of the ecosystem.

---

### 4. Jupiter DCA (Dollar-Cost Averaging)

**What it does:** Allows users to split a large buy/sell order into smaller increments over time. Funds are locked in a program account and a keeper bot executes swaps at each interval via the Jupiter aggregator.

**Key Program:** `DCA265Vj8a9CEuX1eb1LWRnDT7uK6q1xMipnNyatn23M`

**Admin Controls:**
- Program upgrade authority via Squads multisig (UNVERIFIED)
- Users can cancel and withdraw at any time

**Security Risks:**
- **Keeper execution risk (MEDIUM):** The keeper bot determines when and how each DCA swap executes. If the keeper is malicious or compromised, it could execute swaps at suboptimal times or through routes that extract value.
- **Fund custody:** User funds sit in a program-controlled account between DCA intervals. The security of these funds depends entirely on the smart contract integrity and upgrade authority controls.
- **Execution price risk:** Each swap executes at the market price at execution time. No slippage protection or price bounds are documented (UNVERIFIED whether such protections exist).
- **Platform fee:** 0.1% fee per DCA order.

**Audit Status:** No separate DCA-specific audit found in the published audit list. The DCA program may have been covered under broader audits, but this is UNVERIFIED.

**Risk Rating: MEDIUM** -- Lower TVL at risk per user compared to JLP, but keeper trust and lack of confirmed dedicated audit are concerns.

---

### 5. Jupiter Limit Orders

**What it does:** Places limit orders that execute when a token reaches a target price. Keepers monitor on-chain liquidity and fill orders when conditions are met. V2 introduced privacy features to prevent front-running.

**Key Program:** `jupoNjAxXgZ4rjzxzPMP4oxduvQsQtZzyknqvzYNrNu`

**Admin Controls:**
- Program upgrade authority via Squads multisig (UNVERIFIED)

**Security Risks:**
- **V2 privacy mechanism:** Orders are kept private until the trigger price is reached, which mitigates front-running. However, the implementation details of this privacy mechanism are not fully public, and whether it can be bypassed is UNVERIFIED.
- **Keeper trust:** Similar to DCA, keepers are responsible for monitoring and filling orders. A malicious keeper could selectively delay fills.
- **Partial fill risk:** Whether partial fills are supported and how residual funds are handled could create edge cases.

**Audit Status:**
- Offside Labs -- Limit Order V2 audit (Apr 2024)

**Risk Rating: LOW** -- Dedicated V2 audit by Offside Labs. Privacy features reduce front-running risk. Lower funds-at-risk compared to perps/JLP.

---

### 6. Jupiter Lend

**What it does:** A lending/borrowing market designed to complement the JLP pool and JupUSD. Features a bespoke liquidation engine and "dynamic limits to isolate risk." Built in partnership with Fluid.

**Admin Controls:**
- Program upgrade authority via Squads multisig (UNVERIFIED)
- Admin can presumably adjust collateral factors, liquidation parameters, and supported assets

**Security Risks:**
- **New product (HIGH):** Jupiter Lend is one of the newest products in the ecosystem. Lending protocols are historically among the most exploited categories in DeFi (Euler, Compound forks, etc.).
- **Rehypothecation concerns:** Reports have flagged rehypothecation risks in Jupiter Lend -- where deposited collateral may be re-used in ways that amplify risk. The specifics are UNVERIFIED.
- **Code4rena known issues:** The Code4rena audit ($107K pool, Feb-Mar 2026) identified known issues including:
  - DoS vulnerability if transactions load more than 64 accounts
  - Token extensions support can break the protocol
  - No way to close a position PDA to reclaim rent
  - Dust phantom debt positions possible
- **Liquidation engine:** A custom liquidation engine introduces complexity and novel attack surface compared to battle-tested designs (Aave, Compound).
- **Interaction with JLP and JupUSD:** As a lending market that accepts JLP and JupUSD as collateral (UNVERIFIED), failures in those products could cascade into bad debt in Jupiter Lend.

**Audit Status:**
- OtterSec Report 2 (Nov 2025)
- OtterSec Report (Aug-Nov 2025)
- Offside Labs Oracle and Flashloan (Oct 2025)
- MixBytes Vault Report (Jul-Oct 2025)
- Offside Labs Vault Report (Jul-Aug 2025)
- Offside Labs Liquidity Report (Jul 2025)
- Zenith Report (Jun-Jul 2025)
- Code4rena competitive audit ($107K pool, Feb-Mar 2026)
- Certora Formal Verification Report
- OtterSec Jupiter Lend (2026)

This is an exceptionally thorough audit program for a new lending product. However, the Code4rena audit results may not be fully published yet.

**Risk Rating: MEDIUM** -- Extensive audit coverage reduces smart contract risk, but lending protocols inherently carry high exploitation risk, and this product is early in its life cycle with limited battle testing.

---

### 7. JupUSD (Stablecoin)

**What it does:** Jupiter's native stablecoin, launched January 2026. Backed 90% by USDtb (Ethena Labs, which is itself backed by BlackRock's BUIDL fund) and 10% USDC liquidity buffer.

**Admin Controls:**
- Mint/redeem program is on-chain (open source on GitHub: jup-ag)
- Reserve management delegated to Ethena Labs
- Who controls minting parameters and reserve ratios is UNVERIFIED

**Security Risks:**
- **Ethena dependency (HIGH):** 90% of JupUSD reserves are in USDtb, managed by Ethena Labs. Jupiter users are exposed to:
  - Ethena operational risk (reserve management, de-peg risk)
  - USDtb smart contract risk on Ethereum
  - BlackRock BUIDL fund counterparty risk (low probability but systemic)
  - Cross-chain bridge risk for reserve redemption (Solana <-> Ethereum)
- **Redemption liquidity (MEDIUM):** Only 10% USDC buffer is available for instant redemptions. During high-demand periods (bank run scenario), the buffer could be exhausted. Remaining 90% requires USDtb redemption through Ethena, which may have delays.
- **Regulatory risk:** The stablecoin landscape is evolving rapidly. JupUSD's GENIUS Act compliance was noted, but regulatory changes could affect operations.
- **Composability amplification:** JupUSD is designed to be used as collateral for perps trading, in lending markets, and for prediction market settlement. Any de-peg event would cascade across multiple Jupiter products simultaneously.

**Audit Status:** Mint/redeem smart contracts reportedly audited (details UNVERIFIED). The underlying USDtb has its own audit history through Ethena.

**Risk Rating: HIGH** -- Multi-layer dependency chain (Jupiter -> Ethena -> BlackRock BUIDL), limited redemption buffer, and high composability amplification make this a systemic risk vector for the Jupiter ecosystem.

---

### 8. JupSOL (Liquid Staking Token)

**What it does:** Jupiter's liquid staking token, built on Sanctum infrastructure. Delegates primarily to Jupiter's validator. Holders earn staking rewards plus MEV.

**TVL:** ~$711M (as of April 2026, per DeFiLlama)

**Admin Controls:**
- Built on SPL stake pool program (Solana standard)
- Validator selection and delegation strategy controlled by Jupiter/Sanctum
- Sanctum provides the infrastructure; Jupiter provides the brand and validator

**Security Risks:**
- **Sanctum dependency (MEDIUM):** JupSOL relies entirely on Sanctum's infrastructure. A vulnerability in Sanctum's contracts would affect JupSOL and virtually all other Solana LSTs (except JitoSOL and mSOL which run independent infrastructure).
- **Validator concentration:** JupSOL primarily delegates to Jupiter's own validator. While expanding to multi-validator, current concentration means a slashing event on Jupiter's validator would directly impact all JupSOL holders.
- **De-peg risk (LOW):** LSTs can trade below their underlying value during periods of high redemption demand or market stress. JupSOL's liquidity through Sanctum's swap infrastructure mitigates this somewhat.
- **Smart contract risk (LOW):** The SPL stake pool program is one of the most battle-tested programs on Solana, audited by Neodyme, OtterSec, and Kudelski Security. It secures billions in aggregate value.

**Audit Status:**
- SPL Stake Pool: Neodyme, OtterSec, Kudelski Security
- Sanctum infrastructure: separate audit history (UNVERIFIED details)

**Risk Rating: LOW** -- Built on a well-audited, battle-tested SPL standard. The Sanctum dependency is shared across most of the Solana LST ecosystem. $711M TVL demonstrates significant trust.

---

### 9. Jupiter Lock

**What it does:** Open-source, free token vesting and locking tool. Projects use it to lock team tokens, implement cliffs, and vest non-circulating supply transparently.

**Key Repository:** github.com/jup-ag/jup-lock (open source)

**Admin Controls:**
- Once tokens are locked, the lock parameters cannot be changed -- immutable by design
- The program itself is upgradeable (UNVERIFIED whether upgrade authority exists or if the program is frozen)

**Security Risks:**
- **Low direct risk:** Jupiter Lock is a utility tool -- it holds tokens according to predefined vesting schedules. The risk surface is narrow: either the lock works as designed, or it does not.
- **Upgrade authority:** If the Lock program is upgradeable, an admin could theoretically modify the program to release locked tokens early. Whether the program has been frozen (upgrade authority set to None) is UNVERIFIED.
- **Ecosystem trust tool:** Many Solana projects use Jupiter Lock for credibility. A failure in Lock would undermine trust across the ecosystem, not just Jupiter.

**Audit Status:**
- OtterSec -- lock protocol audit
- Sec3 -- lock protocol audit

**Risk Rating: LOW** -- Open source, dual-audited, narrow attack surface. The main unknown is whether the program upgrade authority has been frozen.

---

### 10. LFG Launchpad

**What it does:** Jupiter's token launchpad for new Solana projects. Provides token launch, fundraising, distribution, and initial liquidity pool seeding. Has launched 78 projects as of 2026.

**Admin Controls:**
- Jupiter team curates which projects are approved for LFG launches
- Pool seeding parameters and token distribution mechanics are controlled by the launchpad contract
- Whether there is a permissionless mode or if all launches require Jupiter approval is UNVERIFIED

**Security Risks:**
- **Project quality risk (MEDIUM):** Jupiter's reputation is tied to every project launched through LFG. If a launched project rug-pulls or fails, it reflects on Jupiter regardless of whether Jupiter had control. This is a reputational risk more than a direct security risk.
- **Smart contract risk for launch mechanics:** The token distribution and initial liquidity provisioning involve complex mechanics. Sniping, front-running during launches, and unfair distribution are common attack vectors for launchpads.
- **Regulatory risk:** Token launches are under increasing regulatory scrutiny. Jupiter's role as a launchpad operator may create legal exposure.

**Audit Status:** No separate LFG Launchpad audit identified. The Jupiter DAO audit by Offside Labs may partially cover governance-related launch mechanics.

**Risk Rating: MEDIUM** -- Reputational risk from launched projects. No confirmed dedicated audit of the launchpad smart contracts.

---

### 11. Jupiter Studio

**What it does:** No-code token minting platform launched July 2025. Allows anyone to create and launch tokens on Solana with built-in anti-MEV/sniping protection, 50% trading fee revenue sharing, and vesting tools.

**Admin Controls:**
- Jupiter controls the Studio platform and its parameters
- Revenue sharing model (50% of trading fees to token creators) is set by Jupiter
- Anti-MEV protection settings are platform-controlled

**Security Risks:**
- **Scam token enablement (HIGH):** While Studio provides legitimate token creation tools, it also lowers the barrier for creating scam tokens. The combination of easy minting + Jupiter's trusted brand creates a trust-by-association risk for users.
- **Revenue sharing smart contract risk:** The 50% fee-sharing model requires a smart contract to split fees. Bugs in this contract could result in fee loss or theft.
- **Anti-MEV bypass:** If the anti-MEV protections can be bypassed, insiders could snipe their own launches.

**Audit Status:** No dedicated audit identified for Jupiter Studio.

**Risk Rating: HIGH** -- No confirmed audit for a product that handles token creation and fee distribution. High potential for misuse by bad actors leveraging Jupiter's brand.

---

### 12. Ape Pro

**What it does:** Dedicated memecoin trading terminal, designed for speed and token discovery in the Solana memecoin market. Features MEV protection, vault-based wallet security, and Rugcheck integration for token verification.

**Admin Controls:**
- Platform-level controls on which tokens are displayed and flagged
- Rugcheck scoring integration provides automated risk assessments
- Vault technology isolates user wallets from direct exposure to untrustworthy token contracts

**Security Risks:**
- **Memecoin market risk (HIGH):** By definition, Ape Pro facilitates trading in the highest-risk segment of crypto. While the platform provides safety tools (Rugcheck, MEV protection), it cannot prevent users from trading worthless or malicious tokens.
- **False sense of security:** The "Danger" flag system powered by Rugcheck may give users a false sense that un-flagged tokens are safe. Rugcheck cannot detect all scam patterns, especially novel ones.
- **Alpha/beta status:** Ape Pro is described as still in alpha development, meaning the platform is expected to change and may have unresolved issues.
- **X account hack incident:** During the February 2025 X account compromise, the attacker promoted a fake "Meow" token that reached $20M market cap. This demonstrated how Jupiter-branded trading tools can be weaponized through social engineering, even without smart contract vulnerabilities.

**Audit Status:** No dedicated audit identified for Ape Pro.

**Risk Rating: HIGH** -- No confirmed audit for a platform handling high-risk token trading. Alpha status. Social engineering risk demonstrated in practice.

---

### 13. Jupiter Card

**What it does:** On-chain virtual payment card launched March 2026. Integrates with Visa for global merchant payments. Uses Solana smart contracts for non-custodial, on-chain settlement. Automatically converts crypto to USDC at point of sale via Jupiter's aggregation engine.

**Admin Controls:**
- Smart contract controls on-chain settlement logic
- Account abstraction techniques simplify user interactions
- Transaction batching for network efficiency

**Security Risks:**
- **Newest product (HIGH):** Launched March 2026 -- only weeks old at the time of this audit. No meaningful battle testing.
- **Payments regulatory risk:** Payments products face regulatory requirements (KYC/AML, money transmission licenses) that pure DeFi products do not. Compliance failures could result in product shutdown.
- **Auto-conversion risk:** Automatic conversion of crypto to USDC at point of sale relies on Jupiter's aggregator functioning correctly in real-time. Aggregator downtime would break card functionality.
- **Smart contract + fiat hybrid:** The intersection of on-chain smart contracts and traditional payment rails (Visa) introduces a novel attack surface. Failures could occur at either the smart contract level or the fiat integration level.
- **Account abstraction risks:** Account abstraction simplifies UX but introduces new trust assumptions around transaction batching and gas fee handling.

**Audit Status:** No dedicated audit identified for Jupiter Card. UNVERIFIED whether an audit was conducted before launch.

**Risk Rating: HIGH** -- Brand new product at the intersection of DeFi and traditional payments. No confirmed audit. Novel attack surface.

---

### 14. Jupiter Portfolio / explore.ag

**What it does:** Portfolio tracker and Solana ecosystem explorer. Integrates data from Solscan and DeFiLlama. Launched January 2026. Acquired SonarWatch to build the product.

**Security Risks:**
- **Low direct financial risk:** This is primarily a read-only data product. It does not custody funds or execute transactions (beyond what is done through other Jupiter products).
- **Phishing/spoofing risk (LOW):** A compromised explorer could display incorrect data to mislead users into making bad trades or connecting wallets to malicious sites.
- **Data integrity:** Users rely on portfolio data for financial decisions. Incorrect TVL, balance, or price data could lead to material losses.

**Audit Status:** N/A (data product, not a smart contract)

**Risk Rating: LOW** -- Read-only product with minimal direct financial risk.

---

### 15. Polymarket Integration

**What it does:** Integrates Polymarket prediction markets directly into the Jupiter app. Users can trade event-based markets (politics, sports, economics) without leaving Jupiter. Launched February 2026 with $35M strategic investment from ParaFi Capital.

**Security Risks:**
- **Polymarket dependency:** Jupiter inherits all of Polymarket's smart contract and oracle risks. Polymarket operates on Polygon; this integration involves cross-chain bridging of settlement.
- **Cross-chain settlement (MEDIUM):** Prediction market positions must be settled across Solana and Polygon, introducing bridge dependencies.
- **Market manipulation:** Prediction markets can be manipulated through large positions or information asymmetry. Jupiter's integration amplifies Polymarket's reach.
- **Regulatory risk:** Prediction markets face uncertain regulatory status in many jurisdictions.

**Audit Status:** Relies on Polymarket's own audit history. No Jupiter-specific audit of the integration identified.

**Risk Rating: MEDIUM** -- Inherits Polymarket risks plus cross-chain settlement complexity. Regulatory uncertainty.

---

### 16. Jupiter DAO / JUP Token Governance

**What it does:** On-chain governance for the Jupiter ecosystem. DAO was paused in June 2025 due to "breakdown in trust" after insiders were found dominating votes. Partial resumption in February 2026 with the Net-Zero Emissions proposal vote.

**Key Details:**
- Team controls ~20% of JUP supply
- One team wallet cast over 4.5% of all ballots pre-pause
- DAO paused Jun 2025, target resumption "no earlier than January 2026"
- Feb 2026: Net-Zero Emissions vote passed with ~75% support, cancelling Jupuary 2026 airdrop and pausing new emissions
- Staking rewards continue during governance pause

**Admin Controls:**
- During DAO pause, all protocol decisions made by core team
- Offside Labs audited the DAO contracts
- Squads multisig for on-chain execution (threshold UNVERIFIED)

**Security Risks:**
- **Governance centralization (HIGH):** With 15+ products and growing, the Jupiter team makes all strategic and operational decisions during the DAO pause. This is a single point of failure for the entire ecosystem.
- **Token concentration:** 20% team supply creates whale risk when governance resumes. A coordinated team vote could pass proposals unilaterally depending on quorum requirements.
- **Governance capture upon resumption:** When the DAO resumes, there is risk that the same concentration issues will recur unless structural reforms are implemented.
- **Staking as governance proxy:** Continued staking rewards during the pause incentivize holding JUP but remove the governance utility. This may lead to a "staking-only" holder base that does not participate when governance resumes.

**Audit Status:**
- Offside Labs -- DAO protocol audit

**Risk Rating: HIGH** -- Governance effectively centralized during pause. 15+ products controlled by a small pseudonymous team. Token concentration threatens meaningful decentralization when governance resumes.

---

### 17. Sanctum (Jupiter-Affiliated)

**What it does:** Liquid staking token infrastructure for Solana. Powers JupSOL and most other Solana LSTs (except JitoSOL and mSOL). Provides LST creation, swapping, and routing infrastructure.

**Relationship to Jupiter:**
- Sanctum is an independent project, not a Jupiter sub-project
- Jupiter uses Sanctum infrastructure for JupSOL
- Sanctum provides all LST routing for Jupiter
- The two teams collaborate closely but have separate governance and admin controls

**Security Risks:**
- **Systemic risk (MEDIUM):** Sanctum infrastructure powers virtually all Solana LSTs. A vulnerability in Sanctum would affect JupSOL and most of the Solana staking ecosystem simultaneously.
- **Independence is a strength:** Because Sanctum operates independently, a Jupiter compromise would not directly affect Sanctum, and vice versa (beyond market contagion).
- **Audit status for Sanctum:** UNVERIFIED from this audit. Sanctum has its own security program.

**Risk Rating: MEDIUM** -- Systemic importance to Solana LST ecosystem. Independent from Jupiter operationally, which limits direct contagion.

---

## Cross-Product Contagion Analysis

One of the most significant risks in the Jupiter ecosystem is the deep interconnection between products. A failure in one product can cascade across multiple others:

### Contagion Pathways

```
JupUSD de-peg
  --> JLP pool composition disrupted (if JupUSD is accepted)
  --> Jupiter Lend bad debt (if JupUSD used as collateral)
  --> Perps settlement affected
  --> Card payments fail (if auto-converting JupUSD)

JLP value crash
  --> Jupiter Lend liquidation cascade (if JLP used as collateral)
  --> Perps liquidity crisis
  --> Trader positions force-closed
  --> Downstream protocols using JLP (e.g., Drift pre-hack) affected

Multisig compromise
  --> All upgradeable programs at risk simultaneously
  --> Aggregator, Perps, DCA, Limit Orders, Lend, JupUSD, Lock all vulnerable
  --> Systemic ecosystem failure

Oracle failure (Edge, Chainlink, or Pyth)
  --> Perps pricing breaks
  --> Liquidation engine misfires
  --> JLP pool suffers unexpected losses
  --> Lending liquidations misfire
```

### Contagion Risk Rating: HIGH

The Drift hack demonstrated this contagion in practice: $159M of JLP was drained from Drift, impacting JLP holders who had no exposure to Drift. As Jupiter adds more products that reference each other (Lend using JLP as collateral, JupUSD backing perps, Card using the aggregator), the interconnection risk grows.

---

## Comprehensive Audit Coverage Matrix

| Product | Auditing Firms | Most Recent Audit | Dedicated Audit? | Rating |
|---------|---------------|-------------------|-------------------|--------|
| Aggregator (Swap v6) | Offside Labs, Sec3 | Oct 2025 | Yes | LOW |
| Perpetuals | OtterSec, Offside Labs, Sec3 | Oct 2025 (oracle) | Yes | LOW |
| Jupiter Lend | OtterSec, Offside Labs, MixBytes, Zenith, Code4rena, Certora | Mar 2026 (Code4rena) | Yes (extensive) | LOW |
| Limit Orders V2 | Offside Labs | Apr 2024 | Yes | LOW |
| Jupiter Lock | OtterSec, Sec3 | UNVERIFIED date | Yes | LOW |
| Jupiter DAO | Offside Labs | UNVERIFIED date | Yes | LOW |
| DCA | None identified | N/A | No | HIGH |
| JupUSD | UNVERIFIED | UNVERIFIED | UNVERIFIED | MEDIUM |
| JupSOL (via SPL Stake Pool) | Neodyme, OtterSec, Kudelski | N/A (standard program) | Indirect | LOW |
| LFG Launchpad | None identified | N/A | No | HIGH |
| Jupiter Studio | None identified | N/A | No | HIGH |
| Ape Pro | None identified | N/A | No | HIGH |
| Jupiter Card | None identified | N/A | No | HIGH |
| Polymarket Integration | None identified (Jupiter-side) | N/A | No | MEDIUM |
| Portfolio / explore.ag | N/A | N/A | N/A (data product) | N/A |

**Key Finding:** While Jupiter's core products (Aggregator, Perps, Lend, Lock) have excellent audit coverage, at least 5 products handling user funds or facilitating high-risk trading have NO confirmed dedicated audits: DCA, LFG Launchpad, Jupiter Studio, Ape Pro, and Jupiter Card.

---

## Ecosystem-Wide Recommendations

1. **Audit the unaudited products.** DCA, Studio, Ape Pro, Card, and the LFG Launchpad collectively handle significant user funds and trading activity. Each should have a dedicated security audit from a Solana-specialist firm.

2. **Publish multisig configuration.** The single most impactful transparency improvement Jupiter can make is publishing the Squads multisig threshold, signer count, and signer identities for all major programs. The Drift hack demonstrated the consequences of opaque multisig configurations.

3. **Establish an insurance fund.** With $2.4B+ in combined TVL across 15+ products, the absence of any dedicated insurance fund is a critical gap. Even a 1% insurance/TVL ratio ($24M) would provide meaningful protection.

4. **Resume and reform DAO governance.** Centralized control over 15+ products by a pseudonymous team is a systemic risk. Governance resumption with structural reforms (vote-weight caps, signer doxxing, delegation limits) should be prioritized.

5. **Conduct a contagion risk assessment.** Formally map and stress-test the interconnections between products. The Drift hack's $159M JLP impact was a warning; the next contagion event could originate from within the Jupiter ecosystem itself.

6. **Implement a public bug bounty program.** A $2.4B ecosystem without a confirmed public bug bounty on Immunefi or equivalent is an anomaly. The program should cover all products, not just core contracts.

7. **Freeze Jupiter Lock program.** If the Lock program is still upgradeable, freezing the upgrade authority (setting it to None) would provide maximum trust guarantees for projects using Lock for token vesting.

8. **Address JupUSD redemption buffer.** The 10% USDC buffer for JupUSD redemptions is thin for a stablecoin. Increasing to 20-30% or implementing dynamic buffer sizing based on market conditions would reduce run risk.

9. **Disclose keeper operations.** For DCA, Limit Orders, and Perps, publish details about keeper operators, incentive structures, and safeguards against malicious keeper behavior.

10. **Rate-limit product launches.** 6+ products in 12 months strains security review capacity. Slowing the launch cadence to allow thorough auditing and battle testing of each product would reduce risk.

---

## Information Gaps (Ecosystem-Wide)

The following questions could NOT be answered from publicly available information. Each represents an unknown risk:

1. **Squads multisig threshold and signer identities** across all Jupiter programs -- this is the single most important unverified parameter for the entire ecosystem
2. **Whether the same multisig controls all programs** or if there are separate multisigs per product
3. **Timelock duration** on program upgrades for each product
4. **DCA program audit status** -- no audit identified for a product that custodies user funds between intervals
5. **Jupiter Studio audit status** -- no audit identified for a token minting platform
6. **Ape Pro audit status** -- no audit identified for a memecoin trading terminal
7. **Jupiter Card audit status** -- no audit identified for a payments product
8. **JupUSD mint/redeem program audit details** -- reportedly audited but specifics not public
9. **Keeper operator identities and incentive structures** for DCA, Limit Orders, and Perps
10. **JLP AUM cap governance** -- who can change the cap and under what conditions
11. **Jupiter Lend collateral types** -- whether JLP, JupUSD, or JupSOL are accepted as collateral (and the resulting contagion implications)
12. **Jupiter Lock program freeze status** -- whether the upgrade authority has been set to None
13. **Polymarket integration settlement mechanism** -- how cross-chain settlement between Solana and Polygon works
14. **Emergency pause capabilities** per product -- which products can be paused and by whom
15. **Revenue distribution smart contract audits** for Jupiter Studio's 50% fee-sharing model
16. **DAO governance resumption timeline** and structural reform plans beyond the February 2026 Net-Zero vote
17. **Anti-MEV protection implementation details** for Ape Pro and Jupiter Studio

---

## Historical DeFi Hack Pattern Check (Ecosystem-Wide)

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- UNVERIFIED across all products
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED
- [ ] Multisig has low threshold (2/N with small N)? -- UNVERIFIED (threshold not public for ANY program)
- [ ] Zero or short timelock on governance actions? -- UNVERIFIED
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- Possible, as with all Solana programs using Squads
- [x] Social engineering surface area (anon multisig signers)? -- YES, signers not publicly identified
- [x] Single multisig potentially controls multiple high-value programs? -- POSSIBLE, not confirmed

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- JLP pool limited to high-liquidity assets; Lend collateral types UNVERIFIED
- [ ] Single oracle source without TWAP? -- NO, tri-oracle with cross-verification for Perps
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [x] Insufficient insurance fund relative to TVL? -- YES, 0% insurance/TVL ratio across $2.4B+ ecosystem

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Indirect via JupUSD (Ethena) and Polymarket (cross-chain)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

**Ecosystem-Specific Pattern: Complexity/Contagion Attack:**
- [x] 15+ interconnected products sharing admin infrastructure
- [x] Compromise of one multisig could affect all products simultaneously
- [x] Products reference each other (JLP in Lend, JupUSD in Perps, Aggregator in Card)
- [x] Demonstrated external contagion via Drift hack ($159M JLP impact)

---

## Overall Ecosystem Risk Assessment

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Core Products (Aggregator, Perps, Lend, Lock, Limit Orders) | **MEDIUM** | Well-audited, battle-tested, but governance centralization and no insurance fund |
| Newer Products (JupUSD, Card, Studio, Ape Pro) | **HIGH** | Limited or no audit coverage, early-stage, novel attack surfaces |
| Ecosystem Interconnection / Contagion | **HIGH** | Deep cross-product dependencies; demonstrated contagion via Drift hack |
| Governance / Admin Controls | **HIGH** | DAO paused; multisig config opaque; team controls all 15+ products |
| Audit Coverage (aggregate) | **MEDIUM** | Core products excellent; 5+ products with no confirmed audits |
| **Overall Ecosystem Risk** | **MEDIUM-HIGH** | **Strong core, but rapid expansion, governance centralization, and interconnection risks elevate the overall profile beyond what any single product assessment would suggest** |

---

## Disclaimer

This analysis is based on publicly available information and web research conducted on April 6, 2026. It is NOT a formal smart contract audit. The analysis did not include on-chain verification of program authorities, multisig configurations, or timelock parameters for any Jupiter program. This report is a companion to the main Jupiter security audit dated April 5, 2026, and should be read alongside it. Always DYOR and consider professional auditing services for investment decisions.
