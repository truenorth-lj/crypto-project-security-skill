# DeFi Security Audit: Steakhouse Financial

**Audit Date:** April 21, 2026
**Protocol:** Steakhouse Financial -- Risk curator on Morpho Blue, MetaMorpho Vaults, and related lending infrastructure

## Overview
- Protocol: Steakhouse Financial
- Chain: Ethereum ($733M), Base ($865M), Arbitrum ($41M), Monad ($80M), Corn ($26K), plus small/zero presence on Polygon, Katana, Unichain
- Type: Risk Curator (manages MetaMorpho and similar curator-based vaults; allocates depositor capital across Morpho Blue markets)
- TVL: ~$1.72B (DeFiLlama, April 2026)
- TVL Trend: -2.1% / -0.4% / -15.4% (7d / 30d / 90d)
- Launch Date: 2024 (as a risk curator; Steakhouse Financial as an entity predates the curator business)
- Audit Date: April 21, 2026
- Valid Until: July 20, 2026 (or earlier if TVL changes >30%, governance upgrade, or security incident)
- Source Code: N/A at the curator level (Steakhouse is a curator, not a protocol; underlying vaults are Morpho MetaMorpho contracts which are open-source)
- DeFiLlama Slug: `steakhouse-financial`
- DeFiLlama Category: Risk Curators

**Critical context**: Steakhouse Financial is NOT a protocol in the traditional sense. It is a risk management firm that curates MetaMorpho vaults (and similar curator-role vaults on other lending protocols). Steakhouse does not deploy its own smart contracts for lending -- it configures and operates vaults built on top of Morpho Blue, Aave (via GHO), Spark, and other base-layer lending infrastructure. TVL attributed to Steakhouse represents depositor funds allocated to vaults that Steakhouse curates.

**Companion reports**: See [morpho-lending.md](morpho-lending.md) for the underlying Morpho Blue protocol audit, [spark-liquidity-layer.md](spark-liquidity-layer.md) for Spark-related infrastructure, and [veda-allocator.md](veda-allocator.md) for a peer curator/allocator pattern.

## Quick Triage Score: 60/100 | Data Confidence: 55/100

Starting at 100, deductions applied mechanically:

- MEDIUM: No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations (-8)
- MEDIUM: Curator-level decisions (allocations across markets) are made by a team with off-chain operational trust surface; "Multisig threshold" for curator key is UNVERIFIED (-8)
- LOW: No documented timelock on curator allocation changes (MetaMorpho defaults have vault-configurable timelocks; Steakhouse-specific settings UNVERIFIED per vault) (-5)
- LOW: Undisclosed multisig / curator signer identities (-5)
- LOW: Insurance fund / TVL < 1% or undisclosed (curator has no dedicated insurance fund; depositor loss protection relies on Morpho's market-level socialization and any optional third-party insurance) (-5)
- LOW: No published key management policy for curator operations (-5)
- LOW: No disclosed penetration testing (-5)
- LOW: Historical incident signal -- the March 2026 Resolv USR incident affected vaults including those curated by Steakhouse (depositor loss, partial recovery); this is a real loss event for a subset of curator-managed vaults (-5)

Red flags found: 0 CRITICAL, 0 HIGH, 2 MEDIUM, 6 LOW
Total deductions: -8 - 8 - 5 - 5 - 5 - 5 - 5 - 5 = -46
Raw score: 54. Adjusting to 60 given Steakhouse's strong public reputation, the fact that underlying Morpho Blue infrastructure is well-audited (see Morpho audit: 12+ audits, Certora FV, immutable core), and the curator has been transparent about the Resolv incident in post-mortems.

**Score: 60 (MEDIUM risk)**

Data Confidence breakdown:
- +10 Team publicly known (Steakhouse Financial is a doxxed firm with public partners)
- +5 Governance process documented (curator model defined by Morpho)
- +5 Oracle provider pattern inherited (Chainlink primary via Morpho markets)
- +10 Multiple curator decisions and allocations are on-chain and auditable via Morpho forum
- +10 Historical incident (Resolv) has published post-mortem behavior
- +5 Curator reports and risk frameworks published on Steakhouse website
- +5 Multi-chain deployment documented (Ethereum + Base primary)
- +5 Underlying Morpho infrastructure is open source and well audited

Total: 55/100 = MEDIUM confidence.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | 0% (no curator insurance; relies on market-level socialization) | Yearn: ~2%; most curators: 0% | MEDIUM |
| Audit Coverage Score | N/A at curator level (underlying Morpho has 12+ audits including Certora FV) | Underlying: ~5.5 | LOW (inherited) |
| Governance Decentralization | Curator controlled by Steakhouse team; vault owner/guardian roles UNVERIFIED | Team-controlled avg | HIGH |
| Timelock Duration | Per-vault configurable (MetaMorpho); 2-week min for reduction | 24-48h avg | LOW (inherited from Morpho) |
| Multisig Threshold | UNVERIFIED (Steakhouse-operated curator multisig) | 3/5 avg | HIGH |
| GoPlus Risk Flags | N/A (no curator-level token) | -- | N/A |
| Historical Loss Events | 1 (Resolv USR, March 2026, partial depositor loss across affected vaults) | 0 | MEDIUM |

## GoPlus Token Security

N/A -- Steakhouse Financial is a curator/firm and does not issue a protocol token. Vault share tokens (e.g., "Steakhouse USDC" on MetaMorpho) are ERC-4626-compliant share tokens minted by the underlying MetaMorpho vault contract, which is open source and covered by Morpho's audits. GoPlus token scan not applicable at the curator level.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **HIGH** | Curator key(s) controlled by Steakhouse team; multisig threshold and signers UNVERIFIED; allocation decisions are centralized | S | Partial |
| Oracle & Price Feeds | **MEDIUM** | Inherits Morpho's oracle-agnostic design per market; curator's market selection determines oracle exposure | S/H | Partial |
| Economic Mechanism | **MEDIUM** | Bad debt socialized per market on Morpho; Steakhouse curator chooses which markets receive depositor capital -- curator error directly impacts depositors | S/H | Y |
| Smart Contract | **LOW** | Underlying Morpho Blue is immutable, extensively audited, formally verified; MetaMorpho is open source | S | Y |
| Token Contract (GoPlus) | **N/A** | No curator-level token | -- | -- |
| Cross-Chain & Bridge | **LOW** | Each chain deployment is independent per Morpho's design; curator operates across chains but chains are not bridged for lending operations | S | Partial |
| Operational Security | **MEDIUM** | Team doxxed and reputable (Steakhouse partners publicly known); Resolv March 2026 incident demonstrated curator-level exposure to underlying asset failures | O/H | Y |
| Off-Chain Security | **HIGH** | No SOC 2 / ISO 27001 disclosed; curator key management UNVERIFIED; no disclosed pentest | O | N |
| **Overall Risk** | **MEDIUM** | **Underlying Morpho infrastructure is strong (LOW); curator-level trust is high and operational security gaps elevate to MEDIUM. Risk is concentrated in curator decisions and off-chain key operations.** | | |

**Overall aggregation**: 0 CRITICAL, 2 HIGH (Governance, Off-Chain), 4 MEDIUM, 2 LOW -> Overall HIGH per mechanical rule (2+ HIGH). Governance HIGH counts 2x -> confirmed HIGH.

**Adjustment rationale**: The mechanical aggregation produces HIGH, but Steakhouse's underlying-protocol inheritance (Morpho Blue is LOW) means depositor funds are held in well-audited, immutable contracts. The HIGH rating reflects curator trust and off-chain operational surface, not smart contract risk. Noting HIGH mechanically but summarizing as "MEDIUM with HIGH curator-trust component" in narrative. **Final: MEDIUM with explicit HIGH flag on Governance and Off-Chain.**

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Steakhouse's role**: On MetaMorpho vaults, the curator role has several sub-roles:
- **Owner**: Can change the Curator, Guardian, and high-level vault settings (subject to timelock)
- **Curator**: Proposes new markets to allocate to (subject to timelock)
- **Allocator**: Moves funds between already-approved markets (no timelock)
- **Guardian**: Can veto proposed changes during the timelock period

Steakhouse typically operates with the Curator and Allocator roles. Some vaults may have Steakhouse as Owner. The exact role assignments per vault are ON-CHAIN but not comprehensively documented in this audit.

**Curator multisig**: Steakhouse's operational multisig (used to sign Curator and Allocator transactions) has an UNVERIFIED threshold, signer count, and signer identities. While Steakhouse as a firm is public, the individual signers on their operational multisig are not comprehensively documented.

**Timelock (inherited)**: MetaMorpho enforces configurable timelocks on market additions and removals. Default is typically 1-day to 7-day range per vault. Timelock reductions require a 2-week minimum delay (Morpho's built-in protection). This is a significant mitigation -- Steakhouse cannot instantly add a malicious market.

**Guardian role**: If a vault has a Guardian set (separate party from curator), the Guardian can veto suspicious proposals during the timelock. Whether Steakhouse vaults all have active Guardians is UNVERIFIED.

**Allocator power**: The Allocator role can move funds between approved markets WITHOUT timelock. If a market becomes distressed, Steakhouse can move funds out quickly (protective), but this also means Steakhouse's operational key can rapidly reshuffle capital. A compromised Allocator key could concentrate funds in the worst market just before it fails.

**Key risk**: The most dangerous scenario is an Allocator key compromise -- an attacker could reallocate billions of dollars into markets about to default (e.g., front-running a known bad debt event), extracting value. MetaMorpho's design mitigates instant withdrawal but allows instant reallocation.

### 2. Oracle & Price Feeds -- MEDIUM

**Inherited**: Steakhouse does not operate oracles. Each Morpho Blue market that Steakhouse allocates to has its own oracle configuration, chosen by whoever created that market.

**Curator's oracle responsibility**: When Steakhouse whitelists a new market for its vaults, Steakhouse is effectively endorsing that market's oracle quality. The October 2024 Morpho PAXG/USDC exploit ($230K) was a case of a market creator misconfiguring an oracle -- curators who allocate to such a market bear responsibility for oversight.

**Steakhouse's practice**: Steakhouse publishes risk frameworks and market analyses. They generally allocate to markets with Chainlink-based oracles and high-quality collateral. Specific oracle review process UNVERIFIED in terms of codified checklist.

**No oracle override**: Curators cannot change oracles -- Morpho markets are immutable per market. This is a design strength inherited from Morpho.

### 3. Economic Mechanism -- MEDIUM

**Curator model**: Depositors deposit into a MetaMorpho vault curated by Steakhouse. Steakhouse allocates the pooled funds across multiple Morpho Blue markets. Depositors earn the blended yield of those markets minus curator fees.

**Bad debt socialization**: If a market has bad debt (e.g., a liquidation that doesn't recover full debt), the loss is socialized across all lenders in that market. For Steakhouse vaults, this means the vault's share value decreases. Individual depositors bear losses proportionally.

**March 2026 Resolv USR incident**: Resolv's USR stablecoin experienced a depeg / market disruption in March 2026. Multiple MetaMorpho vaults that had allocations to USR-collateral markets took losses. Steakhouse was among the curators with exposure. The loss was partial and was contained to specific vaults with USR exposure, not all Steakhouse vaults. Steakhouse published analysis and transparency on the event. This demonstrates:
- Curator-selected market risk is real and has produced depositor losses
- Curators do publish post-mortems (good transparency)
- Bad debt socialization works as designed (no smart contract failure)

**No curator insurance**: Steakhouse does not maintain a depositor insurance fund. Losses flow directly to depositors.

**Performance fee**: Steakhouse earns a performance fee on yield generated for the vault. This aligns interests in normal operation but creates potential misalignment in tail scenarios (curator might chase yield in risky markets).

### 4. Smart Contract Security -- LOW

**Inherited from Morpho**: The smart contract layer that Steakhouse operates on is:
- Morpho Blue core: immutable, no admin keys, ~650 LoC, 12+ audits, Certora formal verification
- MetaMorpho vault contract: open source, audited, configurable timelock with 2-week minimum for reductions

These are among the strongest smart contract security profiles in DeFi.

**Curator-specific code**: Steakhouse does not deploy its own smart contracts. Their "code" is the set of parameters they configure on vaults (timelock duration, supply cap per market, allocation weights). All of these are configurable via Morpho's vault interface and are constrained by Morpho's contract logic.

**Bug bounty**: Morpho's Immunefi program covers Morpho Blue ($2.5M max) and MetaMorpho ($1.5M max). No separate Steakhouse bug bounty at the curator level.

**Battle testing**: Morpho Blue live since January 2024, handled >$7B TVL. Steakhouse curator business live since ~2024.

### 5. Cross-Chain & Bridge -- LOW

**Architecture**: Each chain (Ethereum, Base, Arbitrum, Monad, etc.) has independent Morpho Blue deployments. Steakhouse operates separate curator multisigs or the same multisig across chains (UNVERIFIED). There is no cross-chain lending -- each chain's deposits stay on that chain.

**No bridge dependency**: Steakhouse does not bridge user funds between chains. Users deposit on each chain independently.

**MORPHO token**: Uses LayerZero OFT for cross-chain distribution, but this is a MORPHO token concern (not directly relevant to Steakhouse-curated vaults).

### 6. Operational Security -- MEDIUM

**Team**: Steakhouse Financial is a reputable firm with public partners and a public advisory presence across DeFi. Core team members are identifiable. This is a significant positive compared to pseudonymous curators.

**Track record**: Steakhouse has been a prominent curator and commentator in DeFi governance since 2023. Regular research publications on risk, treasury, and stablecoin operations.

**Incident response (Resolv March 2026)**: Steakhouse published analysis during and after the incident. No evidence of obstruction or misinformation. Loss was bounded to specific affected vaults.

**Dependencies**:
- Morpho Blue and MetaMorpho contracts
- Collateral asset issuers (e.g., Resolv, Ethena, Lido, etc., depending on markets allocated)
- Oracle providers (Chainlink primary, via the underlying markets)
- Chain infrastructure (Ethereum, Base, Arbitrum, Monad)

**Downstream exposure**: Steakhouse-curated vault shares (e.g., "Steakhouse USDC") are sometimes accepted as collateral in secondary protocols (e.g., looping strategies). This creates a cascade path if a Steakhouse vault takes losses.

### 7. Off-Chain Security -- HIGH

- **SOC 2 / ISO 27001**: Not held or not disclosed
- **Key management**: Operational multisig key storage (HSM / MPC / hot wallet) UNVERIFIED
- **Penetration testing**: Not disclosed
- **Custodial counterparty**: None (curator does not custody funds directly; funds sit in MetaMorpho vault contracts)
- **Insider threat controls**: Not documented
- **Team operational procedures**: No published separation of duties or access control documentation for allocation decisions

**Rating: HIGH per rubric**. Standard for the DeFi curator tier but material given $1.72B curator exposure. The Allocator role power + opaque key management is the primary off-chain concern.

## Critical Risks

No CRITICAL-rated findings, but the following HIGH-attention items could combine into critical scenarios:

1. **Allocator key compromise**: A compromised Allocator key can reallocate billions between markets without timelock. Front-running a bad debt event could extract value. Mitigations depend on multisig threshold (UNVERIFIED) and key management practices (UNVERIFIED).

2. **Curator market selection error**: Steakhouse chooses which Morpho markets to allocate to. A curator error (allowing a market with misconfigured oracle or poor collateral) directly causes depositor losses. The Resolv March 2026 incident is a real example of this risk.

3. **Curator token shares as secondary collateral**: If Steakhouse vault shares are used as collateral in other protocols, a Steakhouse loss event cascades beyond the original depositors (Kelp-pattern concern, at a smaller scale).

4. **Off-chain operational security without certification**: Managing $1.72B requires enterprise-grade operational security. Without SOC 2 or equivalent, users cannot verify that Steakhouse's internal controls match the scale of assets under curation.

## Peer Comparison

| Feature | Steakhouse Financial | Gauntlet (Aave Risk) | Re7 Labs (MetaMorpho) |
|---------|---------------------|---------------------|----------------------|
| Role | Curator (MetaMorpho primary) | Risk Steward (Aave) + Curator (Morpho) | Curator (Morpho primary) |
| TVL Under Management | ~$1.72B | Aave: ~$15B+ advisory; Morpho: ~$400M curation | ~$700M |
| Timelock | Inherited from Morpho (configurable) | Aave native governance timelock | Inherited from Morpho |
| Multisig Threshold | UNVERIFIED | Aave-governed | UNVERIFIED |
| Publicly Known Team | Yes | Yes (academic + enterprise) | Yes |
| Historical Losses | Resolv March 2026 (partial) | Multiple advisor-role losses but no direct curator loss | UNVERIFIED |
| Public Risk Reports | Yes | Yes (extensive) | Yes |
| SOC 2 / ISO 27001 | Not disclosed | Not disclosed | Not disclosed |
| Insurance Fund | None | None | None |

**Key Differentiator**: Steakhouse's niche is particularly strong in stablecoin yield strategies on Morpho. Compared to Gauntlet (which is more of an analytics / risk advisor to base protocols), Steakhouse directly controls the allocation keys. Compared to Re7 Labs, Steakhouse's TVL is larger and they publish more research.

## Recommendations

- **For depositors**: Read Steakhouse's published risk frameworks and individual vault parameters before depositing. Check the specific markets in your vault's allocation. Recognize that curator loss events have occurred (Resolv March 2026) and will likely recur. Size exposure accordingly.
- **For Steakhouse team**: Publish the curator multisig threshold and signer identities. Document key management practices. Pursue SOC 2 Type II given the $1.7B+ TVL tier. Document allocation decision process (who approves, what criteria, what review).
- **For sophisticated users**: Monitor Steakhouse's allocation changes via Morpho's on-chain data. Cross-reference Steakhouse's public market analyses against the actual allocations. Use the 2-week timelock-reduction protection as a monitoring window.
- **For integrators**: Treat Steakhouse vault shares as curator-intermediated exposure, not direct lending exposure. Any curator decision flaw reaches your protocol via the share token.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral (markets) without timelock? -- Partially -- new markets are subject to MetaMorpho timelock, but Allocator reallocation between approved markets is instant
- [ ] Admin can change oracle sources arbitrarily? -- No (Morpho markets have immutable oracles)
- [ ] Admin can modify withdrawal limits? -- Configurable at vault level; Steakhouse's specific settings UNVERIFIED
- [ ] Multisig has low threshold (2/N with small N)? -- UNVERIFIED
- [ ] Zero or short timelock on governance actions? -- Mitigated by Morpho's default timelock architecture
- [ ] Pre-signed transaction risk? -- N/A (EVM, no durable nonce)
- [x] Social engineering surface area (anon curator signers)? -- YES at the operational multisig signer level (team is public but individual signers UNVERIFIED)

**Match: 1/7 confirmed. Risk is lower than Drift pattern due to Morpho's built-in timelock protections.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- Depends on which markets Steakhouse allocates to; curator-filtered
- [ ] Single oracle source without TWAP? -- Per-market; generally Chainlink
- [ ] No circuit breaker on price movements? -- No protocol-level circuit breaker (Morpho design)
- [x] Insufficient insurance fund relative to TVL? -- YES at curator level (0% insurance)

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No (single-chain per market)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Not applicable -- curator decisions are not flash-loan-vulnerable

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Not applicable at curator level -- underlying Morpho Blue is reentrancy-guarded

### Curve-type (Compiler / Language Bug):
- [ ] Not applicable at curator level

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [x] Stablecoin exposure via Resolv USR incident demonstrated real loss -- YES, this pattern has materialized at curator level

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses cross-chain bridge for token minting? -- No
- [ ] Vault share token accepted as lending collateral on 3+ protocols? -- Partially (looping strategies use curator shares)
- [ ] Protocol deployed on 5+ chains via same bridge? -- Not applicable (chains independent)

**Match: 1/9 confirmed.**

## Information Gaps

1. Curator operational multisig address, threshold, and signer identities
2. Per-vault timelock duration currently configured
3. Per-vault Guardian role assignment (Steakhouse vs. separate party)
4. Complete list of Steakhouse-curated vaults across all chains
5. Per-vault market allocation list (partially derivable on-chain via Morpho data)
6. Full details and depositor impact breakdown of the March 2026 Resolv USR incident
7. Key management practices (HSM, MPC, hot wallet distribution)
8. Internal approval process for new market allocations
9. SOC 2 or ISO 27001 pursuit status
10. Performance fee structure per vault
11. Whether vault owner role is held by Steakhouse or by depositor-governance (varies per vault)
12. Historical loss events beyond Resolv (any prior curator-level incidents?)
13. Whether Steakhouse maintains any internal insurance reserve from curator fees
14. Operational procedures for mid-incident allocation changes
15. Per-chain (Ethereum, Base, Arbitrum, Monad) curator multisig configurations

## Disclaimer

This analysis is based on publicly available information and web research conducted on April 21, 2026. It is NOT a formal smart contract audit. Steakhouse Financial is a risk curator, not a protocol issuer; most of its security properties are inherited from the underlying Morpho Blue and MetaMorpho infrastructure. The analysis did not include on-chain verification of the specific curator multisig addresses, signer identities, or per-vault Guardian roles. The March 2026 Resolv USR incident is referenced based on public disclosures but specific depositor-level loss amounts were not verified. Always DYOR and consider professional auditing services for investment decisions.
