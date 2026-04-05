# DeFi Security Audit: Zeta Markets

**Audit Date:** April 5, 2026
**Protocol:** Zeta Markets -- Solana derivatives DEX (DISCONTINUED)

## Overview
- Protocol: Zeta Markets
- Chain: Solana
- Type: Perpetual Futures DEX
- TVL: $0 (protocol shut down May 2025, migrated to Bullet)
- Launch Date: ~2022
- Peak TVL: ~$15M
- Source Code: **Closed** (only SDKs and tooling are open source)

## Quick Triage Score: 18/100
- Red flags found: 4 (TVL = $0, no audits on DeFiLlama, closed-source core contracts, undisclosed multisig config)

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **HIGH** | Squads multisig but unknown threshold, no timelock found | N |
| Oracle & Price Feeds | MEDIUM | Pyth + Chainlink fallback, but oracle override capability unknown | N |
| Economic Mechanism | MEDIUM | Reasonable insurance fund design, USDC-only collateral | Partial |
| Smart Contract | **HIGH** | Zero audits listed, closed-source core program | N |
| Operational Security | **HIGH** | Protocol discontinued, team migrated to new project | Partial |
| **Overall Risk** | **HIGH** | **Defunct protocol with significant transparency gaps** | |

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

- Program upgrade authority delegated to Squads multisig (confirmed via Squads docs)
- **Threshold and signer count: UNKNOWN** -- not publicly disclosed
- **Timelock: No evidence found** in documentation or on-chain
- Admin powers: Standard Solana program upgrade authority (can modify entire program)
- No public constraints documented beyond the multisig requirement

### 2. Oracle & Price Feeds -- MEDIUM

- Primary: Pyth Network (per-slot updates)
- Fallback: Chainlink when Pyth data is stale
- USDC-only collateral reduces oracle manipulation surface
- **Whether admin could swap oracle sources: UNKNOWN** (closed-source)

### 3. Economic Mechanism -- MEDIUM

- Insurance fund funded by platform fees + 35% of liquidation incentives + initial seed
- Permissionless liquidation (anyone can liquidate)
- Liquidator receives 30% of maintenance margin; 35% to insurance fund
- Margin-system enforced withdrawals (blocked if would cause bankruptcy)
- No documented hard withdrawal caps

### 4. Smart Contract Security -- HIGH

- **DeFiLlama audits: 0** -- no formal audit reports found
- CertiK Skynet score: 68.34 / BB rating (moderate)
- **Core Solana program is CLOSED-SOURCE**
- Only SDKs, indexers, and market-maker tools are open on GitHub
- Bug bounty: "Global Bounty Program" existed but scope/payout unclear
- No known exploits before shutdown

### 5. Operational Security -- HIGH

- Protocol discontinued May 2025
- Team migrated to "Bullet" network (ZEX token converting 1:1 to BULLET)
- Stated reasons: Solana congestion issues, pivot to Bitcoin yield strategies
- Not a hack -- voluntary shutdown

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock -- USDC-only, but **no timelock found** (MEDIUM)
- [ ] Admin can change oracle sources arbitrarily -- **UNKNOWN, closed-source** (HIGH)
- [ ] Admin can modify withdrawal limits -- Likely via program upgrade, **no timelock** (HIGH)
- [ ] Multisig has low threshold -- **UNKNOWN, not publicly disclosed** (HIGH)
- [ ] Zero or short timelock -- **No evidence of any timelock** (CRITICAL)
- [ ] Pre-signed transaction risk -- Not assessed (protocol defunct)
- [ ] Social engineering surface area -- Unknown signer identities (HIGH)

**5/7 flags rated HIGH or above** due to lack of transparency.

## Information Gaps

- Multisig threshold and signer identities -- UNKNOWN
- Whether admin could override oracle sources -- UNKNOWN (closed-source)
- Timelock configuration -- no evidence found, likely absent
- Full admin key capability scope -- closed-source prevents verification
- Insurance fund actual balance vs TVL at peak -- UNKNOWN

## Key Takeaway

Zeta Markets is a textbook example of **transparency risk**. The protocol may have been perfectly secure in practice, but the combination of closed-source contracts, undisclosed governance configuration, and zero public audits made it impossible to verify. For an external auditor, inability to verify is itself a risk -- you cannot distinguish "secure but private" from "insecure and hiding it."

The protocol's voluntary shutdown and migration to Bullet further complicates the picture: users holding ZEX tokens are now dependent on a new, even less battle-tested system.
