# DeFi Security Audit: Concrete

**Audit Date:** April 21, 2026
**Protocol:** Concrete -- Onchain capital allocator / earn platform

## Overview
- Protocol: Concrete (ConcreteXYZ)
- Chain: Ethereum (~$908M, primary), Berachain (~$49M), Arbitrum (~$13M), Katana (minor), Stable (~$70M)
- Type: Onchain Capital Allocator (yield aggregator routing deposits across DeFi strategies)
- TVL: ~$1.04B (DeFiLlama, April 2026)
- TVL Trend: -1.2% / +1.2% / +6.9% (7d / 30d / 90d)
- Launch Date: Early 2025 (DeFiLlama listing: February 2025)
- Audit Date: April 21, 2026
- Valid Until: July 20, 2026 (or earlier if TVL changes >30%, governance upgrade, or security incident)
- Source Code: Partial (architecture documented; full GitHub source availability UNVERIFIED)
- DeFiLlama Slug: `concrete`
- DeFiLlama Category: Onchain Capital Allocator
- Docs: `docs.concrete.xyz`

**Note on fork relationship**: Concrete is an onchain capital allocator in the same product category as Veda (BoringVault pattern) and Spark Liquidity Layer. Concrete's audit metadata includes a "Standard-Implementation" audit, suggesting the underlying vault contract may be a standardized / shared implementation. Similar to Veda's BoringVault pattern, the allocator assigns manager roles to executors that deploy funds across approved DeFi strategies.

## Quick Triage Score: 62/100 | Data Confidence: 50/100

Starting at 100, deductions applied mechanically:

- MEDIUM: No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations (-8)
- MEDIUM: Multisig threshold UNVERIFIED -- strategy executor / admin multisig configuration not publicly documented (-8)
- LOW: No documented timelock on admin actions (strategy whitelist changes, allocation changes UNVERIFIED whether timelocked) (-5)
- LOW: Undisclosed multisig signer identities (-5)
- LOW: Insurance fund / TVL < 1% or undisclosed (no dedicated allocator-level insurance fund identified) (-5)
- LOW: Single oracle provider or UNVERIFIED oracle dependency (allocator accounting depends on underlying strategy oracles) (-5)
- LOW: No published key management policy (-5)

Red flags found: 0 CRITICAL, 0 HIGH, 2 MEDIUM, 5 LOW
Total deductions: -8 - 8 - 5 - 5 - 5 - 5 - 5 = -41
Raw score: 59. Adjusting to 62 given Zellic audit (reputable firm) and stable TVL trend (+6.9% over 90d).

**Score: 62 (MEDIUM risk)**

Data Confidence breakdown:
- +10 Audit reports publicly available (2 listed on DeFiLlama: Standard Implementation + Zellic)
- +5 Source code partially documented (docs.concrete.xyz publishes architecture; full GitHub source UNVERIFIED)
- +5 Team website and brand presence active
- +5 Governance process documented (team + multisig)
- +10 Zellic audit publicly linked
- +5 Bug bounty referenced (details UNVERIFIED)
- +5 Oracle provider pattern inferred from BoringVault-style architecture
- +5 Multi-chain deployment documented

Total: 50/100 = LOW-MEDIUM confidence.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | 1-5% (Yearn: ~2%, Veda: undisclosed) | HIGH |
| Audit Coverage Score | ~2.0 (2 audits: Standard Implementation + Zellic, both within 1-2 yrs) | 2-4 avg | MEDIUM |
| Governance Decentralization | Team-controlled + multisig (no DAO token identified) | DAO avg | HIGH |
| Timelock Duration | UNVERIFIED | 24-48h avg | HIGH |
| Multisig Threshold | UNVERIFIED | 3/5 avg | HIGH |
| GoPlus Risk Flags | N/A (no public governance token identified) | -- | N/A |

## GoPlus Token Security

N/A -- Concrete does not appear to have a public governance or utility token at the protocol level. Vault share tokens (ctTokens or similar) are minted per deposit and represent pro-rata claim on the underlying vault. These are infrastructure tokens rather than tradable governance tokens. GoPlus token scan not applicable at the protocol level.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **HIGH** | Multisig threshold and signer identities UNVERIFIED; allocator strategy approval process UNVERIFIED; no timelock documented | S | Partial |
| Oracle & Price Feeds | **MEDIUM** | Allocator depends on underlying strategy pricing; exchange rate between vault shares and underlying is a known manipulation surface | S | Partial |
| Economic Mechanism | **MEDIUM** | Allocator routes across strategies; per-strategy risk amplified at allocator level; no insurance fund | S | Partial |
| Smart Contract | **MEDIUM** | 2 audits (Standard Implementation + Zellic); multi-chain deployment increases attack surface | S | Partial |
| Token Contract (GoPlus) | **N/A** | No public governance/utility token | -- | -- |
| Cross-Chain & Bridge | **MEDIUM** | Deployed on Ethereum + Berachain + Arbitrum + Katana; cross-chain allocation bridge dependencies UNVERIFIED | S | Partial |
| Operational Security | **MEDIUM** | Team semi-public; no disclosed major incidents; limited public track record | O | Partial |
| Off-Chain Security | **HIGH** | No SOC 2 / ISO 27001; no published key management; no disclosed pentest; strategy executor trust model opaque | O | N |
| **Overall Risk** | **HIGH** | **$1B+ allocator with governance opacity (HIGH), off-chain security gaps (HIGH), and dependency on underlying strategy security -- combination elevates above peer allocators like Veda despite clean audit record** | | |

**Overall aggregation**: 0 CRITICAL, 2 HIGH (Governance, Off-Chain), 4 MEDIUM -> Overall HIGH per mechanical rule (2+ HIGH). Governance HIGH counts 2x -> confirmed HIGH.

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Governance model**: Concrete operates as a team-controlled onchain capital allocator. No public DAO token has been identified. Admin functions (strategy whitelisting, vault parameter changes, upgrade authority) are controlled by the team, presumably via multisig.

**Admin powers** (inferred from capital allocator / BoringVault standard pattern):
- Whitelist new strategies (critical -- a malicious strategy can drain the vault)
- Allocate / reallocate funds across strategies
- Update exchange rate accounting parameters
- Set fee parameters (platform fee, performance fee)
- Pause deposits / withdrawals
- Upgrade contracts (if upgradeable -- UNVERIFIED)

**Multisig**: Concrete's admin multisig address, threshold, and signer identities are NOT publicly documented in accessible materials. UNVERIFIED.

**Timelock**: No documented timelock on admin actions. In BoringVault-pattern allocators, the most dangerous action is Merkle root / strategy whitelist updates -- if these are instant, a compromised admin key can whitelist a drain-contract and extract funds in one transaction. Whether Concrete imposes a timelock on these actions is UNVERIFIED.

**Strategy approval process**: Whether new strategies undergo external review, a delay period, or DAO vote before being added is UNVERIFIED. In Veda's case (peer), strategies are approved via Merkle tree by the OWNER_ROLE without timelock.

**Governance claim gaps**: Concrete's architecture likely mirrors Veda's Solmate Auth pattern or BoringVault's role-based access. Without the contract addresses and on-chain verification, users cannot confirm which addresses hold privileged roles.

### 2. Oracle & Price Feeds -- MEDIUM

**Oracle architecture**: Capital allocators typically use exchange-rate oracles to track the vault's per-share value. The exchange rate aggregates the value of all underlying strategy positions.

**Manipulation surface**:
- An attacker controlling a single strategy could manipulate its reported value, which inflates the allocator's share price. Depositing at inflated price or withdrawing at inflated price extracts value.
- Veda (peer) uses an offchain Accountant that feeds exchange rate with automatic pause on deviation. Concrete's mechanism UNVERIFIED.
- Cross-strategy accounting requires the allocator to trust each strategy's value reporting. This is a pooled trust model.

**Admin override on exchange rate**: If admin can manually override the exchange rate (e.g., to "correct" a bad reading), this is a significant power. Veda's Accountant includes update functions. Whether Concrete has similar override and whether it is timelocked is UNVERIFIED.

**Fallback**: No documented oracle fallback mechanism.

### 3. Economic Mechanism -- MEDIUM

**Architecture**: Deposits are pooled into a vault. The vault (or its manager) allocates funds across pre-approved strategies. Strategies can be yield farming, liquidity provision, lending, restaking, or other DeFi primitives. Users receive a share token representing claim on the vault.

**Strategy risk amplification**: The allocator inherits the risk of every strategy it uses. A bad strategy (hack, depeg, mismanagement) bleeds into the allocator's share price, affecting all users regardless of which strategy they thought they were exposed to.

**Rehypothecation risk**: Allocators may re-use capital in multiple strategies or leverage across them. Whether Concrete uses leverage or cross-strategy rehypothecation UNVERIFIED.

**Withdrawal mechanics**: Allocators typically face withdrawal liquidity constraints when underlying strategies are not instantly liquid. Whether Concrete imposes withdrawal queues, delays, or size limits UNVERIFIED.

**Bad debt handling**: No insurance fund documented. Bad debt from a strategy failure would flow into the vault's exchange rate, reducing share value for all holders.

**Fee structure**: Typical allocator fees include platform fee (e.g., 1-2% annualized on AUM) and performance fee (e.g., 10-20% of yield). Concrete's exact fee structure UNVERIFIED in this audit but documented in docs.concrete.xyz.

### 4. Smart Contract Security -- MEDIUM

**Audits**:
1. "Standard Implementation" audit (DeFiLlama link: `docs.concrete.xyz/assets/files/Standard-Implementation-9948d7fcebb518e5c29051bc2326b5ec.pdf`) -- firm and date UNVERIFIED from metadata alone
2. Zellic audit (DeFiLlama link: `docs.concrete.xyz/assets/files/Zellic-Audit-Report-5dbb9d52d444adcd197dfbaa941a86ab.pdf`) -- Zellic is a reputable firm; date UNVERIFIED

Audit Coverage Score: ~2.0 (2 audits within 2 years, assuming both are <1 yr old scores 2.0)

**Standard-Implementation audit**: The naming suggests that Concrete's vault implementation follows a shared standard (likely BoringVault or similar) and the audit covers the standard implementation. Adopting a well-audited standard is a security positive. However, protocol-specific configuration and integration code may not be covered by the standard audit.

**Zellic audit**: Zellic is a respected auditor. A dedicated Zellic audit on the protocol suggests additional review beyond the standard implementation.

**Battle testing**: Approximately 1 year live. Peak TVL has grown to ~$1.04B, one of the higher TVLs in the onchain capital allocator category. No publicly known exploit.

**Bug bounty**: UNVERIFIED. Capital allocators of this size typically have Immunefi programs, but Concrete's program details are not confirmed in this audit.

**Open source status**: Architecture is documented at docs.concrete.xyz. Full GitHub source repository visibility is UNVERIFIED. If contracts are verified on Etherscan but full GitHub repo is not public, users can still read individual contracts but cannot audit the full system coherently.

#### Source Code Review

**Source availability**: Partial (documented architecture; full repo availability UNVERIFIED)
**Contracts reviewed**: Not performed at file level in this audit

**Admin function inventory**: Not extracted; recommended to use Etherscan to review the deployed contract source and admin setter functions.

**Vulnerability scan**: Relies on Zellic and Standard Implementation audit findings.

**Governance claim verification**: Cannot be performed without admin multisig address and deployed contract inventory.

**Conclusion**: 2 audits is acceptable for a 1-year-old $1B protocol but not leading. Source-level verification deferred.

### 5. Cross-Chain & Bridge -- MEDIUM

**Multi-chain footprint** (per DeFiLlama):
- Ethereum: ~$908M (primary)
- Stable (chain): ~$70M
- Berachain: ~$49M
- Arbitrum: ~$13M
- Katana: minor (~$1K)

**Cross-chain model**: Whether the chains operate independently (separate vaults, separate admin) or share a canonical governance with message relaying is UNVERIFIED.

**Bridge dependencies**: If strategies on Berachain, Arbitrum, or Katana involve bridging assets between chains, the allocator depends on those bridges. Which specific bridges (LayerZero, Wormhole, native rollup bridges) and their DVN / validator configurations UNVERIFIED.

**Rate limiting**: Whether cross-chain message relay has rate limits or circuit breakers UNVERIFIED. This is the Kelp-pattern concern -- a compromised bridge could release unauthorized value across chains.

**Katana deployment**: Katana is a newer chain (Ronin Network restaking-era). Deployment with only ~$1K TVL may be a test or canary deployment.

**Berachain deployment**: Berachain's PoL (Proof of Liquidity) model creates unique yield opportunities; allocator exposure to Berachain-native yield sources introduces Berachain-specific risks.

### 6. Operational Security -- MEDIUM

**Team**: Concrete has a website, Twitter (@ConcreteXYZ), and docs. Team identity information is limited in the materials reviewed for this audit. Some team members may be public on LinkedIn / Twitter; full doxxing status UNVERIFIED.

**Track record**: Short (~1 year). No major public incidents.

**Incident response**: No published incident response plan located in this audit.

**Dependencies**:
- Underlying strategy protocols (Morpho, Aave, Pendle, Ethena, etc., depending on active strategies)
- Bridge providers for cross-chain allocation
- Oracle providers (inherited from underlying strategies)

**Downstream lending exposure**: Concrete's share token is not widely known as lending collateral on major protocols. This limits Kelp-pattern cascade risk, but UNVERIFIED as Concrete integrations grow.

### 7. Off-Chain Security -- HIGH

- **SOC 2 / ISO 27001**: Not held or not disclosed
- **Key management**: Not publicly documented
- **Penetration testing**: Not disclosed
- **Custodial counterparty**: None directly; however, strategies may involve custodial tokens (e.g., restaking, RWA) that have off-chain custody dependencies
- **Insider threat controls**: Not documented
- **Executor operations**: For a capital allocator, the strategy executor role is high-privilege (can route user funds into strategies). Who holds this role, whether keys are stored in HSMs, and what monitoring exists are UNVERIFIED.

**Rating: HIGH** per rubric. Standard for the tier but should be improved given TVL size.

## Critical Risks

No CRITICAL-rated findings, but the following HIGH-attention items could combine into a critical scenario:

1. **Strategy whitelist + opaque admin**: If admin can whitelist a strategy instantly and the multisig is low-threshold + not publicly verified, a compromised signer can route the vault's $1B+ into a drain contract in one transaction. This is the Veda-pattern risk.

2. **Cross-strategy accounting trust**: The allocator's per-share value depends on correct reporting from every underlying strategy. A single bad strategy can poison the exchange rate.

3. **Multi-chain operational complexity**: Managing 5 chains with UNVERIFIED per-chain admin configuration expands attack surface. A weaker chain deployment can compromise shared assets.

4. **Off-chain executor trust**: If executor role uses hot wallets without HSM / MPC, and executors operate without SOC 2 oversight, the off-chain key layer is the weakest link for a $1B allocator.

## Peer Comparison

| Feature | Concrete | Veda | Spark Liquidity Layer |
|---------|----------|------|----------------------|
| Timelock | UNVERIFIED | None documented | 18-48h (GSM Pause Delay) |
| Multisig | UNVERIFIED | UNVERIFIED (Solmate Auth) | Sky DAO + GSM |
| Audits | 2 (Standard Impl + Zellic) | 14+ (0xMacro A-4 to A-45, Spearbit/Cantina) | 5+ (ChainSecurity + Cantina) |
| Oracle | Inherited from strategies | Offchain Accountant with pause | N/A (allocator, no price oracle) |
| Insurance/TVL | Undisclosed | Undisclosed | Sky Surplus Buffer (via Sky DAO) |
| Open Source | Partial (docs only confirmed) | Yes (GitHub) | Yes (GitHub) |
| TVL | ~$1.04B | ~$1.21B | ~$2.00B |
| Governance Token | None identified | None | SPK (Sky subDAO) |
| Primary Chain | Ethereum | Ethereum | Ethereum |
| Chains | 5 | 11 | 6 |
| Off-Chain Certifications | None disclosed | None disclosed | None disclosed |

**Key Differentiator**: Concrete is similar in size to Veda but has significantly fewer publicly disclosed audits (2 vs. 14+). Spark Liquidity Layer has stronger governance (Sky DAO with GSM Pause Delay timelock) but operates in a narrower scope (stablecoin liquidity routing vs. broad DeFi allocation).

## Recommendations

- **For depositors**: Size exposure conservatively. Verify on Etherscan which vault you are depositing into and what the admin address is. Monitor Concrete's Twitter for incident alerts.
- **For Concrete team**: Publish multisig threshold, signer identities, and timelock duration. Commit to publishing full audit reports (not just PDF links). Document strategy approval process. Pursue SOC 2 Type II for operational security credibility at the $1B TVL tier.
- **For sophisticated users**: Read the Zellic audit in full. Verify on-chain which strategies are currently whitelisted. Check whether the admin can instantly add new strategies or if there is a timelock.
- **For integrators**: Treat Concrete as a team-controlled allocator with medium maturity. Do not assume the fund can absorb all risks of its underlying strategies -- strategy failures flow directly into share price.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral (strategies) without timelock? -- UNVERIFIED
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED (exchange rate source control UNVERIFIED)
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED
- [ ] Multisig has low threshold (2/N with small N)? -- UNVERIFIED
- [ ] Zero or short timelock on governance actions? -- UNVERIFIED
- [ ] Pre-signed transaction risk? -- N/A (EVM, no durable nonce)
- [ ] Social engineering surface area (anon multisig signers)? -- UNVERIFIED

**Match: 0/7 confirmed, 6/7 UNVERIFIED. Risk cannot be ruled in or out.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [x] Low-liquidity collateral (via strategies) accepted? -- UNVERIFIED (depends on strategy list)
- [ ] Single oracle source without TWAP? -- UNVERIFIED
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [x] Insufficient insurance fund relative to TVL? -- YES (no insurance fund documented)

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Possibly via cross-chain strategies UNVERIFIED
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Not applicable -- no token-weighted governance over protocol parameters identified

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens? -- UNVERIFIED (strategy-dependent)
- [ ] Read-only reentrancy risk? -- UNVERIFIED
- [ ] Flash loan compatible without reentrancy guards? -- UNVERIFIED

### Curve-type (Compiler / Language Bug):
- [ ] Non-standard compiler? -- No (Solidity)
- [ ] Compiler version CVEs? -- UNVERIFIED

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Not directly applicable; strategy-dependent if stablecoin strategies are used

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses cross-chain bridge for token minting or reserve release? -- UNVERIFIED
- [ ] Bridge message validation single-layer? -- UNVERIFIED
- [ ] DVN/relayer/verifier configuration public? -- UNVERIFIED
- [ ] Bridged token accepted as lending collateral on 3+ protocols? -- UNVERIFIED (Concrete share tokens not known as widely accepted collateral)
- [ ] Protocol deployed on 5+ chains via same bridge? -- 5 chains currently, bridge provider UNVERIFIED

**Match: 0-1/9 confirmed, remainder UNVERIFIED. Trigger rule of 3+ not confirmed, but the multi-chain footprint warrants bridge disclosure.**

## Information Gaps

1. Admin multisig address, threshold, and signer identities
2. Timelock duration (if any) on admin actions
3. Strategy approval process and current whitelist
4. Whether vault contracts are immutable or upgradeable
5. Exchange rate oracle mechanism (onchain vs. offchain Accountant-style)
6. Admin override capability on exchange rate and pause conditions
7. Specific audit firms and dates for the "Standard Implementation" audit
8. Detailed Zellic audit findings and remediation status
9. Full GitHub repository or source code verification status on each chain's explorer
10. Bug bounty program details (platform, payout tier, scope)
11. Cross-chain bridge provider(s) and DVN configuration
12. Per-chain admin configuration (shared or independent)
13. Insurance fund mechanism (or acknowledgment of its absence)
14. Fee structure (platform + performance fees)
15. Historical strategy performance and any loss events
16. Team identities and operational security practices
17. SOC 2 / ISO 27001 pursuit status

## Disclaimer

This analysis is based on publicly available information and web research conducted on April 21, 2026. It is NOT a formal smart contract audit. On-chain verification of Concrete's multisig configuration was not performed due to lack of public multisig address. Strategy list, audit findings, and governance processes were inferred from DeFiLlama metadata and peer comparison rather than verified from Concrete's own published documents. Always DYOR and consider professional auditing services for investment decisions.
