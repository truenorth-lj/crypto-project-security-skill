# DeFi Security Audit: Veda (Onchain Capital Allocator)

**Audit Date:** April 6, 2026
**Protocol:** Veda -- Onchain vault infrastructure for DeFi yield products

## Overview
- Protocol: Veda (formerly Seven Seas Capital BoringVault)
- Chain: Ethereum (primary), Berachain, Arbitrum, Binance, Sonic, Ink, Base, Plasma, BOB, Hyperliquid L1, Scroll
- Type: Onchain Capital Allocator / Vault Infrastructure
- TVL: ~$1.21B (DeFiLlama, April 2026)
- TVL Trend: +0.9% / +0.0% / -34.7% (7d / 30d / 90d)
- Launch Date: March 2024 (DeFiLlama listing: February 2025)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: Se7en-Seas/boring-vault, Veda-Labs/boring-vault)

## Quick Triage Score: 57/100

Starting at 100, the following deductions apply:

- (-8) MEDIUM: TVL dropped >30% in 90 days (from ~$1.85B to ~$1.21B, -34.7%)
- (-5) LOW: No documented timelock on admin actions (Merkle root updates, Accountant parameter changes are instant for OWNER_ROLE)
- (-5) LOW: Undisclosed multisig signer identities (no public disclosure of which addresses hold OWNER_ROLE or MULTISIG_ROLE across vaults)
- (-5) LOW: Insurance fund / TVL ratio undisclosed (no protocol-wide insurance fund documented)
- (-5) LOW: Single oracle provider pattern (offchain oracle feeds exchange rate to Accountant; fallback mechanism not documented)
- (-5) LOW: No DAO governance (protocol-wide decisions rest with Veda Labs team, no token-based governance)
- (-8) MEDIUM: Multisig threshold UNVERIFIED (role-based access via Solmate Auth but specific threshold for deployed vaults not publicly documented)
- (-2) Minor: Per-vault governance fragmentation -- each vault may have different admin configurations, making holistic security assessment difficult

Red flags found: 0 CRITICAL, 0 HIGH, 2 MEDIUM, 5 LOW

Score meaning: 50-79 = MEDIUM risk. The score reflects operational centralization and governance opacity rather than smart contract design flaws. The BoringVault architecture is well-designed but admin controls are concentrated and not transparently documented.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | 1-5% (Yearn: ~2%, Morpho: N/A) | HIGH |
| Audit Coverage Score | 8.5+ | 2-4 avg | LOW |
| Governance Decentralization | Team-controlled, per-vault admin | DAO vote avg | HIGH |
| Timelock Duration | None documented | 24-48h avg | HIGH |
| Multisig Threshold | UNVERIFIED (Auth roles) | 3/5 avg | MEDIUM |
| GoPlus Risk Flags | N/A (no token) | -- | N/A |

**Audit Coverage Score Calculation:**
Veda has an exceptionally extensive audit history with 14+ audits documented on their site:
- Spearbit/Cantina (date UNVERIFIED, likely 2024): 1.0
- 0xMacro A-4 through A-45 (13+ audits, ongoing through 2025-2026): ~7.5 (mix of <1yr and 1-2yr old)
- Total: ~8.5+ (LOW risk threshold: >= 3.0)

This is one of the highest audit coverage scores in DeFi, reflecting continuous auditing of both core architecture and integration-specific decoders.

## GoPlus Token Security

N/A -- Veda does not have a governance or utility token. The protocol operates as infrastructure; individual vault share tokens (e.g., LiquidETH, LiquidBTC) are ERC20 shares minted by the BoringVault contract. GoPlus token analysis is not applicable at the protocol level.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | HIGH | No timelock on Merkle root/parameter changes; OWNER_ROLE has broad powers; signer identities undisclosed | Partial |
| Oracle & Price Feeds | MEDIUM | Offchain oracle feeds exchange rate to Accountant; automatic pause on deviation but no documented fallback | Partial |
| Economic Mechanism | LOW | Merkle tree whitelisting prevents unauthorized strategy execution; share lock periods protect against MEV | Yes |
| Smart Contract | LOW | Minimal core contract (~100 LoC), extensive audit history (14+ audits), open source, modular architecture | Yes |
| Token Contract (GoPlus) | N/A | No protocol token | N/A |
| Cross-Chain & Bridge | MEDIUM | 11 chains deployed; uses Hyperlane and LayerZero for bridging; bridge compromise could affect cross-chain vaults | Partial |
| Operational Security | MEDIUM | Team doxxed (co-founders public); $1M bug bounty on Immunefi; no published incident response plan | Partial |
| **Overall Risk** | **MEDIUM** | **Strong smart contract design offset by centralized admin controls, governance opacity, and lack of timelock** | |

## Detailed Findings

### 1. Governance & Admin Key

**Architecture:** Veda uses Solmate's Auth/Authority pattern for role-based access control. The BoringVault contract inherits from `Auth`, which provides `requiresAuth` modifiers. Key roles referenced in the codebase include:

- **OWNER_ROLE**: Can set Merkle roots (strategy whitelists), update exchange rate parameters (bounds, delays, fees), and configure rate providers. This is the most powerful role.
- **MULTISIG_ROLE**: Can pause and unpause the Manager and Accountant contracts.
- **MANAGER_ROLE**: Authorized to call `manage()` on the BoringVault, executing arbitrary calls (subject to Merkle verification).
- **MINTER_ROLE / BURNER_ROLE**: Assigned to the Teller contract for minting/burning shares.

**Key Concerns:**

1. **No timelock on critical admin actions.** The `setManageRoot()` function on the Manager allows the OWNER_ROLE to instantly update the Merkle root, which defines every permitted strategy action. A compromised owner key could instantly whitelist a malicious contract and drain the vault. This is the single most significant risk in the protocol.

2. **Accountant parameter changes are instant.** Functions like `updateDelay()`, `updateUpper()`, `updateLower()`, `updatePlatformFee()`, and `updatePerformanceFee()` are all callable by OWNER_ROLE with no timelock or delay.

3. **Per-vault admin fragmentation.** Each vault deployment can have a different owner and authority configuration. There is no protocol-wide governance structure. This means security varies vault-by-vault, and users must verify the admin setup for each specific vault they deposit into.

4. **Multisig details not publicly documented.** While the code references MULTISIG_ROLE, the specific multisig configuration (threshold, signer count, signer identities) for each deployed vault is not documented in Veda's public materials. UNVERIFIED.

5. **Authority contract can be changed.** The Solmate Auth pattern includes `setAuthority()` which allows the owner to change the entire authority contract, potentially reassigning all roles. This is a standard Solmate pattern but represents concentrated power.

**Mitigating Factors:**
- The Merkle tree verification system is a strong architectural safeguard -- even with MANAGER_ROLE, a strategist cannot execute actions not encoded in the tree.
- The Pauser contract provides a dedicated pause mechanism with per-contract granularity.
- Pause is callable by MULTISIG_ROLE, providing a circuit breaker that does not require the owner.

**Risk Level: HIGH** -- The lack of timelock on Merkle root changes and Accountant parameters, combined with undisclosed multisig configurations, creates significant trust assumptions.

### 2. Oracle & Price Feeds

**Architecture:** The Accountant contract maintains the vault's exchange rate, which determines share pricing for deposits and withdrawals. Key characteristics:

- **Offchain oracle model.** An authorized address (UPDATE_EXCHANGE_RATE_ROLE) pushes exchange rate updates to the Accountant contract. The specific oracle source is not documented -- it appears to be an offchain system operated by Veda.
- **Onchain safety bounds.** The Accountant enforces `allowedExchangeRateChangeUpper` and `allowedExchangeRateChangeLower` bounds. If an update exceeds these bounds, the contract automatically pauses.
- **Rate limiting.** A `minimumUpdateDelayInSeconds` parameter prevents overly frequent updates (max configurable: 14 days).
- **Rate providers.** For multi-asset vaults, `AccountantWithRateProviders` can reference external rate providers (e.g., Chainlink, protocol-specific feeds) to convert asset prices.

**Key Concerns:**

1. **Centralized exchange rate updates.** The offchain oracle is a single point of failure. If compromised, it could push a manipulated exchange rate within the allowed bounds, causing users to deposit at inflated or deflated rates.

2. **Bounds are configurable by OWNER_ROLE.** The safety bounds themselves can be widened by the owner, potentially allowing larger rate manipulations.

3. **No documented fallback oracle.** If the primary offchain oracle goes down, there is no automatic fallback mechanism described in the documentation.

**Mitigating Factors:**
- Automatic pause on deviation breach is a strong safety mechanism.
- Rate limiting prevents rapid successive manipulations.
- The bounds constrain the damage from any single malicious update.

**Risk Level: MEDIUM** -- Onchain safety mechanisms are well-designed, but the offchain oracle model and owner-configurable bounds introduce centralization risk.

### 3. Economic Mechanism

**Architecture:** Veda's economic model is based on:

- **Merkle-verified strategy execution.** The Manager stores a Merkle tree of all permitted actions (target contract, function selector, parameter values). The Curator/Strategist submits rebalance transactions with Merkle proofs. Unauthorized actions are mathematically impossible without the correct proof.
- **Share lock periods.** After deposit, shares are locked for a configurable period to prevent MEV and flashloan arbitrage.
- **Time-delayed withdrawals.** The BoringQueue implements a maturity period (~1 hour typical) before withdrawal requests can be fulfilled by third-party solvers.
- **Fee structure.** Platform fees and performance fees (with high watermark tracking) are collected by the Accountant.

**Key Concerns:**

1. **No protocol-wide insurance fund.** Unlike lending protocols that maintain safety modules, Veda does not document an insurance fund that would cover losses from smart contract bugs or strategy failures.
2. **Strategy risk is vault-specific.** Each vault deploys capital into different DeFi protocols (Aave, Morpho, Euler, Pendle, etc.). The risk profile depends entirely on which protocols are whitelisted in the Merkle tree.
3. **Solver-based withdrawals introduce counterparty dependency.** If no solver fulfills a withdrawal request after maturity, users may experience delays.

**Mitigating Factors:**
- Merkle verification is cryptographically enforced -- the strongest strategy restriction mechanism available in DeFi.
- Share lock periods effectively eliminate flashloan-based attacks.
- Per-asset configurable withdrawal parameters allow fine-tuning of queue behavior.

**Risk Level: LOW** -- The Merkle tree verification and share lock mechanisms are well-designed. The main concern is the absence of a protocol-wide insurance fund.

### 4. Smart Contract Security

**Audit History:**
Veda has one of the most extensive audit histories in DeFi:

| Auditor | Reports | Scope |
|---------|---------|-------|
| 0xMacro | 13+ reports (A-4 through A-45) | Core architecture, Teller, Accountant, Solver, Queue, decoders, cross-chain bridging, protocol integrations |
| Spearbit (Cantina) | 1 report | Full security review of BoringVault Arctic |
| Secure3 | Referenced in docs | UNVERIFIED scope |
| Hexens | Referenced in docs | UNVERIFIED scope |

The continuous auditing model (new audit for each integration or feature) is best-in-class.

**Bug Bounty:**
- Platform: Immunefi
- Max payout: $1,000,000 (Critical, smart contract)
- Tiers: Critical $100K-$1M (10% of funds at risk), High $10K-$25K
- Scope: 52 assets across Ethereum, Scroll, Ink
- Known issues: Fee calculation inaccuracies in yield streaming (acknowledged, no fund risk)
- PoC required, KYC required for payout

**Code Quality:**
- Core BoringVault: ~100 lines of code (minimalist by design)
- All contracts open source on GitHub
- Solmate Auth for access control
- Modular architecture isolates risk per component
- Each DecoderAndSanitizer validates calldata for specific protocol integrations

**Battle Testing:**
- Live since March 2024 (~2 years)
- Peak TVL: ~$2.6B+ (late 2024 / early 2025)
- Zero security incidents reported
- No rekt.news entries

**Risk Level: LOW** -- Exceptional audit coverage, minimal core code, open source, and 2+ years of battle testing with zero incidents.

### 5. Cross-Chain & Bridge

**Multi-Chain Deployment:**
Veda is deployed across 11 chains: Ethereum, Berachain, Arbitrum, Binance, Sonic, Ink, Base, Plasma, BOB, Hyperliquid L1, and Scroll.

**Bridge Dependencies:**
- **Hyperlane**: Used for cross-chain vault operations (audited in 0xMacro A-19)
- **LayerZero**: Used for cross-chain Teller operations (audited in 0xMacro A-19)
- **CCIP**: Referenced in audit scope for protocol decoders (A-10)

**Key Concerns:**

1. **Multiple bridge dependencies.** Using both Hyperlane and LayerZero creates exposure to two separate bridge security models. A compromise of either could affect cross-chain vault operations.
2. **Per-chain admin configuration unknown.** Whether each chain deployment has its own multisig or is controlled from Ethereum is not documented.
3. **Cross-chain message validation.** How cross-chain rebalancing messages are authenticated and whether timelocks apply to cross-chain operations is not publicly detailed.

**Mitigating Factors:**
- Cross-chain bridging operations were specifically audited by 0xMacro (A-19, A-44).
- Using multiple bridge providers reduces single-point-of-failure risk.
- TVL is concentrated on Ethereum (~$769M, 64% of total), limiting cross-chain exposure.

**Risk Level: MEDIUM** -- Cross-chain operations add attack surface, but the audit coverage and Ethereum concentration mitigate risk.

### 6. Operational Security

**Team:**
- **Sunand Raghupathi** (CEO, Co-founder): Former CEO of Seven Seas Capital, previously Head of R&D at Sommelier. Columbia University. Publicly doxxed.
- **Stephanie Vaughan** (COO, Co-founder): Co-founder and Managing Partner of Seven Seas Capital. Publicly doxxed.
- **Joseph Terrigno** (CTO, Co-founder): Co-founder and CTO of Seven Seas Capital. Publicly doxxed.

The team has a traceable track record in DeFi vault management through Seven Seas Capital. Veda is the evolution of their Seven Seas infrastructure.

**Funding:**
- $18M raised (May/June 2025), led by CoinFund
- Investors: Coinbase Ventures, Animoca Ventures, GSR, Mantle EcoFund, BitGo, Draper Dragon
- Institutional backing from credible crypto-native investors

**Incident Response:**
- No published incident response plan found.
- Emergency pause capability exists via MULTISIG_ROLE on Manager and Accountant.
- Pauser contract provides centralized pause control over multiple components.
- Bug bounty program active on Immunefi ($1M max).

**Key Partnerships:**
- ether.fi: Powers ether.fi Liquid vaults (LiquidETH, LiquidBTC, LiquidUSD)
- Lombard: Powers DeFi Vault for LBTC yield
- Mantle: cmETH integration
- Binance Wallet, Bybit Web3: Consumer distribution

**Dependencies:**
- Underlying DeFi protocols (Aave, Morpho, Euler, Pendle, Uniswap, etc.) -- whitelisted in Merkle trees
- Bridge providers (Hyperlane, LayerZero, CCIP)
- Offchain oracle system for exchange rate updates
- Third-party solvers for withdrawal queue fulfillment

**Risk Level: MEDIUM** -- Doxxed team with institutional backing and extensive partnerships. Offset by lack of published incident response plan and dependency on offchain infrastructure.

## Critical Risks

1. **No timelock on Merkle root changes (HIGH).** The OWNER_ROLE can instantly update the Merkle root on the Manager, potentially whitelisting a malicious contract to drain vault funds. This is the most critical operational risk. A compromised or malicious owner key could execute a rug in a single transaction.

2. **Centralized offchain oracle for exchange rates (MEDIUM-HIGH).** The Accountant relies on offchain rate updates. While onchain bounds and automatic pause provide safety rails, the oracle operator could manipulate rates within bounds over time.

3. **Undisclosed multisig configurations (MEDIUM).** Users cannot independently verify the number of signers, threshold, or identities of the accounts controlling OWNER_ROLE and MULTISIG_ROLE for specific vault deployments without on-chain investigation.

4. **No protocol-wide insurance fund (MEDIUM).** In the event of a smart contract exploit or strategy loss, there is no documented mechanism to make depositors whole.

## Peer Comparison

| Feature | Veda | Yearn Finance V3 | Morpho (Curated Vaults) |
|---------|------|-------------------|------------------------|
| TVL | ~$1.2B | ~$140M | ~$6.8B |
| Timelock | None documented | Governance timelock | Curator-specific |
| Multisig | UNVERIFIED (Auth roles) | DAO governance | Curator-dependent |
| Audits | 14+ (0xMacro, Spearbit, Hexens, Secure3) | Multiple (ChainSecurity, etc.) | Multiple |
| Oracle | Offchain + onchain bounds | Chainlink / on-chain | Market-based (lending) |
| Insurance/TVL | Undisclosed | Treasury-backed | Per-market |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | $1M (Immunefi) | $500K (Immunefi) | $500K |
| Admin Controls | Owner can change Merkle root instantly | DAO vote + timelock | Curator-specific |
| Strategy Restrictions | Merkle tree verification | Strategy review + governance | Market parameters |

**Key Takeaway:** Veda has the strongest strategy restriction mechanism (Merkle tree verification) among vault protocols, but lags behind peers in governance decentralization and timelock protections. Yearn and Morpho both have more transparent governance structures.

## Recommendations

1. **For depositors:** Verify the specific vault's owner and authority configuration on-chain before depositing. Use Etherscan or block explorers to check if the OWNER_ROLE is a multisig (e.g., Gnosis Safe) and what threshold it uses. Do not rely solely on documentation.

2. **For the protocol:** Implement a timelock (minimum 24-48 hours) on `setManageRoot()` and Accountant parameter changes. This is the single highest-impact security improvement Veda could make.

3. **For the protocol:** Publish multisig configurations (threshold, signer count, signer identities or at minimum signer categories) for all deployed vaults in official documentation.

4. **For the protocol:** Document the offchain oracle architecture, including what data sources feed exchange rate updates and what monitoring systems detect anomalies.

5. **For the protocol:** Establish and publish an incident response plan, including communication channels and escalation procedures.

6. **For the protocol:** Consider establishing a protocol-wide insurance fund or integrating with DeFi insurance protocols (Nexus Mutual, etc.).

7. **For depositors:** Monitor TVL trends -- the 34.7% decline over 90 days warrants attention, though it may reflect broader market conditions rather than protocol-specific issues.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? **YES** -- OWNER_ROLE can update Merkle root to whitelist new protocols/assets instantly
- [ ] Admin can change oracle sources arbitrarily? **YES** -- OWNER_ROLE can update rate providers and exchange rate bounds
- [ ] Admin can modify withdrawal limits? **YES** -- Queue parameters are configurable per asset
- [ ] Multisig has low threshold (2/N with small N)? **UNVERIFIED** -- multisig configuration not publicly documented
- [ ] Zero or short timelock on governance actions? **YES** -- No timelock on Merkle root updates or parameter changes
- [ ] Pre-signed transaction risk (durable nonce on Solana)? **N/A** -- EVM protocol
- [ ] Social engineering surface area (anon multisig signers)? **PARTIAL** -- Team is doxxed but specific multisig signers are not publicly identified

**Drift pattern match: 4/6 applicable flags triggered.** This is a significant concern. The Merkle tree verification mitigates the impact (strategists cannot execute arbitrary actions even if the root is changed, until a rebalance is triggered), but the instant root update capability is a Drift-type vulnerability.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? **UNLIKELY** -- Vault deposits are in major assets (ETH, BTC, USD stables), but strategy deployment into low-liquidity venues is possible
- [ ] Single oracle source without TWAP? **YES** -- Offchain oracle without documented TWAP or multi-source verification
- [ ] No circuit breaker on price movements? **NO** -- Accountant has automatic pause on deviation breach (circuit breaker exists)
- [ ] Insufficient insurance fund relative to TVL? **YES** -- No insurance fund documented

**Euler pattern match: 2/4 flags triggered.** The automatic pause mechanism is a strong defense, but the single oracle source and absent insurance fund are concerns.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? **PARTIAL** -- Hyperlane and LayerZero have decentralized validation but with varying security models
- [ ] Admin keys stored in hot wallets? **UNVERIFIED** -- Key storage practices not documented
- [ ] No key rotation policy? **UNVERIFIED** -- Key rotation practices not documented

**Ronin pattern match: 1/3 flags partially triggered.** Cross-chain operations increase surface area but the use of established bridge providers mitigates risk.

## Information Gaps

The following questions could NOT be answered from publicly available information:

1. **Multisig configuration for deployed vaults.** What is the threshold and signer count for OWNER_ROLE and MULTISIG_ROLE on major vault deployments (ether.fi Liquid, Lombard DeFi Vault)? Who are the signers?
2. **Timelock status.** Is there any timelock contract deployed in the authority chain for any vault, even if not enforced at the smart contract level?
3. **Offchain oracle architecture.** What data sources feed the Accountant's exchange rate updates? Is there redundancy? What monitoring exists?
4. **Key management practices.** How are admin keys stored? HSM, MPC, or standard hot/cold wallets? Is there key rotation?
5. **Insurance or coverage.** Is there any insurance fund, risk reserve, or integration with DeFi insurance protocols?
6. **Per-vault authority configurations.** The Auth pattern allows each vault to have a different Authority contract. What are the actual Authority contracts deployed for major vaults?
7. **TVL decline cause.** The 34.7% TVL decline over 90 days is notable -- is this user withdrawals, market movement, or strategic reallocation?
8. **Incident response plan.** No public documentation of incident response procedures found.
9. **Secure3 and Hexens audit details.** These auditors are referenced in documentation but specific report links, dates, and scopes are not provided.
10. **Cross-chain admin structure.** Whether each chain has independent admin keys or a single cross-chain governance structure.

These gaps represent significant unknown risks. The absence of transparent governance documentation for a protocol managing $1.2B+ in TVL is itself a material risk signal.

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
