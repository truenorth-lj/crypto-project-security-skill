# DeFi Security Audit: Binance Staked ETH (WBETH)

**Audit Date:** 2026-04-21
**Protocol:** Binance Staked ETH -- CEX-operated liquid staking derivative

## Overview
- Protocol: Binance Staked ETH (WBETH)
- Chain: Ethereum (primary, ~$8.04B), BNB Chain (~$0.48B)
- Type: Liquid Staking Derivative (CEX-operated)
- TVL: ~$8.52B (DeFiLlama)
- TVL Trend: Stable and among the top 2 LSDs globally; growth tied to Binance's retail and institutional staking flows.
- Launch Date: April 2023 (WBETH launched as wrapper over BETH)
- Token Contract (Ethereum): `0xa2E3356610840701BDf5611a53974510Ae27E2e1`
- Audit Date: 2026-04-21
- Source Code: Partially open (audited bytecode published, internal components closed)

## Quick Triage Score: 60/100
- Red flags found: Proxy with Binance-controlled owner; custodial model; closed-source off-chain components.
- GoPlus token security: 0 HIGH / 2 MEDIUM flags (proxy + owner controllable).

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Binance SAFU fund ($1B+, UNVERIFIED allocation to WBETH) | 1-5% dedicated | MEDIUM |
| Audit Coverage Score | 2 firms (PeckShield + one other; limited recency) | 1-3 avg | MEDIUM risk |
| Governance Decentralization | None (Binance-controlled) | DAO or multisig avg | HIGH risk |
| Timelock Duration | None (centralized operator) | 24-48h avg | HIGH risk |
| Multisig Threshold | UNVERIFIED; on-chain owner is a Binance EOA/proxy admin | 3/5 avg | HIGH risk |
| GoPlus Risk Flags | 0 HIGH / 2 MED | -- | MEDIUM risk |

## GoPlus Token Security (WBETH on Ethereum)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | Yes (upgradeable) | MEDIUM |
| Mintable | Not flagged, but owner-controlled mint/burn expected for deposits | MEDIUM |
| Owner Address | `0xa3ee6926edcce93bacf05f4222c243c4d9f6d853` (Binance-controlled) | MEDIUM |
| Hidden Owner | No | -- |
| Selfdestruct | No | -- |
| Transfer Pausable | Not flagged | -- |
| Blacklist | Not flagged | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 6,717 | -- |
| Creator Honeypot History | No (0 honeypots from creator) | -- |
| DEX Liquidity | UniswapV4, UniswapV3 (multiple pools; modest secondary-market depth vs. TVL) | MEDIUM |

GoPlus assessment: **MEDIUM RISK**. The token is a proxy with a known Binance-controlled owner. No honeypot, no taxes, no blacklist flags -- but trust in the token is trust in Binance's custodianship of staked ETH. Holder count is modest (6,717) because most WBETH is held by Binance custody and redeemed via the CEX rather than traded on-chain.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **HIGH** | Binance-controlled proxy, no DAO, no public timelock | Y |
| Oracle & Price Feeds | **MEDIUM** | Exchange rate posted by Binance (single operator) | Y |
| Economic Mechanism | **MEDIUM** | Non-rebasing wrapper over BETH; redemption gated by Binance | Y |
| Smart Contract | **MEDIUM** | Only 1 public audit report (PeckShield); limited peer coverage | Y |
| Token Contract (GoPlus) | **MEDIUM** | Proxy + owner-controlled; no honeypot/tax | Y |
| Operational Security | **MEDIUM** | Large exchange with strong security record but custodial SPOF | Partial |
| **Overall Risk** | **MEDIUM** | **Dominant CEX-operated LSD; custodial trust, not smart-contract trust** | |

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Control Model:**
- WBETH is a Binance-operated liquid staking derivative. There is no DAO, no LDO/RPL-equivalent governance token, no on-chain vote.
- The Ethereum contract at `0xa2E3356610840701BDf5611a53974510Ae27E2e1` is an upgradeable proxy; owner is `0xa3ee6926edcce93bacf05f4222c243c4d9f6d853`, an address attributed to Binance.
- All mint/burn (deposit/redemption) authority sits with Binance systems.

**Timelock / Multisig:**
- No public timelock is advertised for WBETH proxy upgrades. UNVERIFIED whether the owner address is an EOA, a Safe multisig, or a custom admin contract.
- Binance uses internal multi-approver key management infrastructure for its reserves, but that is off-chain and opaque to outside observers.

**Assessment:** The governance surface is entirely Binance. From a Drift-hack-style governance analysis, this is effectively single-entity control. Trust in WBETH is trust in Binance corporate risk management, not in decentralized checks. This is the primary source of the overall MEDIUM rating rather than LOW.

### 2. Oracle & Price Feeds -- MEDIUM

**Exchange Rate Mechanism:**
- WBETH is a non-rebasing wrapper: 1 WBETH represents 1 BETH plus accumulated staking rewards. The WBETH/ETH exchange rate is updated by Binance as staking rewards accrue on the Beacon Chain.
- The rate is posted on-chain by a Binance-controlled operator; there is no public multi-signer oracle committee.

**On-Chain Price Feeds (DeFi integrations):**
- Protocols integrating WBETH (e.g., lending markets accepting it as collateral) typically use Chainlink exchange-rate feeds or protocol-specific TWAPs over the Binance-posted rate.
- Risk to DeFi integrators: if Binance misreports the exchange rate (accidental or adversarial), downstream lending markets could mis-price collateral.

**Assessment:** Single-operator oracle is a structural weakness relative to Lido's 5-of-9 committee or Rocket Pool's minipool-level reporting. Mitigated by Binance's strong incentive to keep the peg credible, but the single-point risk is real.

### 3. Economic Mechanism -- MEDIUM

**Staking Model:**
- Users deposit ETH on Binance, receive BETH (account credit), and can wrap BETH into WBETH (on-chain token).
- Accumulated staking rewards: ~3-4% APY (post-Shapella).
- Fee structure: Binance takes a commission on staking rewards (commission rate UNVERIFIED in publicly posted terms; typical CEX LSDs run 10-20%).

**Redemption:**
- WBETH -> BETH conversion happens on Binance (users send WBETH to Binance, receive BETH credit).
- BETH -> ETH redemption is subject to Binance's internal queue and the Ethereum validator exit queue.
- Unlike Lido V2, there is no permissionless on-chain withdrawal path: users must go through the Binance account system.

**Insurance:**
- Binance's SAFU fund (historically $1B+, UNVERIFIED current size) is a general exchange insurance fund, not WBETH-dedicated.
- No dedicated slashing insurance specific to WBETH validators is publicly disclosed.

**Node Operator Set:**
- Binance operates its own Ethereum validators (concentrated operator set).
- No public reporting of validator diversity, client diversity, or slashing history at the level Lido or Rocket Pool provide.

**Assessment:** Economically sound at the CEX level (Binance has strong credit / operational history), but the lack of permissionless withdrawals and the validator concentration are LSD-specific weaknesses. If Binance faced severe operational or regulatory stress, WBETH could temporarily de-peg (as happened briefly during March 2023 stress events in related stETH markets).

### 4. Smart Contract Security -- MEDIUM

**Audits:**
- PeckShield -- WBETH v1.0 audit report published (linked from DeFiLlama).
- DeFiLlama lists 2 total audits; the second firm is not publicly linked in the audit_links field.
- No formal verification reports are publicly available.

**Upgradeable Contracts:**
- WBETH is a proxy controlled by the Binance owner address. Upgrade procedure (timelock, multi-approver) is not publicly documented.

**Bug Bounty:**
- Binance runs a broad exchange bug bounty via HackerOne. Whether WBETH contracts are explicitly in-scope and what the maximum payout is could not be confirmed -- UNVERIFIED.

**Battle Testing:**
- WBETH has been live since April 2023 with no known exploit of the contract itself.

**Assessment:** The on-chain contract is straightforward (ERC-20 proxy with mint/burn + exchange-rate update), reducing the smart-contract attack surface. The main concerns are thin public audit coverage relative to Lido (10+ firms) and the lack of formal verification or a public Immunefi-style bounty scoped specifically to WBETH.

### 5. Operational Security -- MEDIUM

**Operator:**
- Binance is the world's largest crypto exchange by volume. Mature security and custody operations, but it is also the single highest-value target in crypto.
- Past incidents: 2019 Binance hack (~7,000 BTC from hot wallet) -- SAFU fund covered the loss. No WBETH-specific incidents.

**Transparency:**
- Binance publishes Proof-of-Reserve reports covering ETH, but the granularity of WBETH-backing attestation (validator addresses, slashing events) is lower than Lido's quarterly node-operator reports.
- No public incident postmortem repository specific to WBETH.

**Regulatory Posture:**
- Binance has ongoing regulatory exposure in multiple jurisdictions (U.S. DOJ settlement in 2023, various country-level restrictions). A severe regulatory action could theoretically affect operations, including staking services.

**Assessment:** Operationally Binance is one of the strongest entities in crypto, but regulatory concentration risk is a real and ongoing concern. The MEDIUM rating reflects the balance between strong operator security and single-point custodial/regulatory risk.

## Critical Risks

None identified as CRITICAL. The dominant risk is custodial and regulatory concentration (HIGH for governance, but mitigated operationally to MEDIUM overall).

## Peer Comparison

| Feature | WBETH (Binance) | Lido stETH | Coinbase cbETH |
|---------|-----------------|------------|-----------------|
| TVL | ~$8.5B | ~$19B | ~$5B (UNVERIFIED) |
| Governance | Binance (centralized) | DAO + Dual Governance | Coinbase (centralized) |
| Timelock | None public | Dynamic (Dual Governance) | N/A |
| Oracle | Binance-posted rate | 5-of-9 committee | Coinbase-posted |
| Node Operators | Binance-operated | 600+ diversified | Coinbase-operated |
| Audits | 2 (PeckShield + 1) | 10+ firms + formal verification | Coinbase + external |
| Open Source | Partial (contract yes, infra no) | Yes | Partial |
| Withdrawals | Via Binance account only | Permissionless on-chain (V2+) | Via Coinbase account |
| Bug Bounty | HackerOne (general), scope UNVERIFIED | $2M (Immunefi) | Coinbase HackerOne |

## Recommendations

1. **Custodial trust assumption**: Users must be comfortable treating WBETH as a Binance credit instrument wrapped into ERC-20 form. It is not trust-minimized like Lido or Rocket Pool.
2. **Redemption dependency**: Redemption requires a functioning Binance account. Users restricted from Binance (geographic or KYC) may be forced into secondary-market sales, accepting whatever discount is on offer.
3. **Proxy upgrade risk**: The WBETH contract is upgradeable by Binance without public timelock. Users should monitor for proxy upgrades.
4. **DeFi integration caution**: Lending markets using WBETH as collateral should apply conservative LTVs and use robust exchange-rate feeds, given single-operator oracle risk.
5. **Regulatory monitoring**: Binance's regulatory position is dynamic. Any escalation (e.g., forced suspension of staking services in a major jurisdiction) could temporarily impair WBETH redemption.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock -- **N/A**, not a lending protocol, but **YES** for proxy upgrades (centralized admin)
- [x] Admin can change oracle sources arbitrarily -- **YES**, exchange-rate oracle is single-operator
- [x] Admin can modify withdrawal limits -- **YES**, Binance gates redemption entirely
- [x] Multisig has low threshold -- **UNVERIFIED**, but owner is effectively single-entity
- [x] Zero or short timelock -- **YES**, no public timelock on proxy upgrades
- [ ] Pre-signed transaction risk -- **N/A**, EVM-based
- [x] Social engineering surface area -- **MEDIUM-HIGH**, single-operator admin keys at a major exchange

**5-6/7 flags matched** (most flags apply but are mitigated by Binance's operational security rather than protocol design). This is the structural cost of a CEX-operated LSD.

### Euler/Mango-type (Oracle Manipulation + Economic Exploit):
- [ ] Low-liquidity collateral accepted -- **N/A**, not a lending protocol
- [x] Single oracle source without TWAP -- **YES**, Binance-posted rate is single-source
- [ ] No circuit breaker -- Binance can pause minting/redemption off-chain
- [ ] Insufficient insurance -- SAFU fund exists but WBETH-specific allocation UNVERIFIED

**1-2/4 flags matched.**

### Ronin/Harmony-type (Bridge / Validator Key Compromise):
- [x] Small validator/signer set -- **YES**, Binance-operated validators (concentrated)
- [ ] Keys stored in hot wallets -- **UNVERIFIED**, Binance uses HSM/MPC internally
- [ ] Single point of failure in bridge -- **N/A**, no bridge (WBETH on BNB Chain uses separate issuance)
- [ ] No key rotation mechanism -- UNVERIFIED

**1-2/4 flags matched.** Concentration risk, mitigated by Binance's security apparatus.

## Information Gaps

- **Owner address ownership structure**: Whether `0xa3ee6926edcce93bacf05f4222c243c4d9f6d853` is an EOA, a Safe multisig, or a custom admin contract (and the signer threshold if multisig).
- **Proxy upgrade timelock**: No public documentation of a timelock between an upgrade proposal and execution.
- **Commission rate**: Exact fee Binance takes from WBETH staking rewards is not confirmed in publicly posted terms.
- **Validator set**: Number of validators operated for WBETH, client diversity, and historical slashing events are not publicly disclosed at the level Lido/Rocket Pool provide.
- **SAFU fund allocation to WBETH**: Whether WBETH-specific losses would be covered from the general SAFU fund, and any caps, is not disclosed.
- **Second audit firm**: DeFiLlama reports 2 audits but only PeckShield is linked; the second firm and scope are unverified.
- **WBETH on BNB Chain**: The $0.48B WBETH on BNB Chain uses a separate issuance mechanism (bridge vs. native re-mint) that was not verified in this audit.

## Disclaimer

This is a research-based assessment, not a formal smart contract audit. It is based on publicly available information, on-chain data, DeFiLlama metrics, and GoPlus token security scanning as of 2026-04-21. DYOR. Users should form their own view of custodial risk and regulatory risk before holding WBETH.
