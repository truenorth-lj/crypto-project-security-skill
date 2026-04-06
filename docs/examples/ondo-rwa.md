# DeFi Security Audit: Ondo Finance

**Audit Date:** April 6, 2026
**Protocol:** Ondo Finance -- Tokenized Real-World Assets (RWA) protocol

## Overview
- Protocol: Ondo Finance (OUSG / USDY / rOUSG / rUSDY / Ondo Global Markets)
- Chain: Ethereum (primary), Solana, Sui, Aptos, Arbitrum, Mantle, Noble, Stellar, Sei, Plume, BSC, XRP Ledger, Polygon (12+ chains)
- Type: RWA / Tokenized US Treasuries
- TVL: ~$3.51B
- TVL Trend: +21.1% / +30.3% / +80.7% (7d / 30d / 90d)
- Launch Date: 2022 (v1 vaults); January 2023 (OUSG); December 2023 (USDY)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: ondoprotocol)

## Quick Triage Score: 62/100

Starting at 100, the following deductions apply:

- (-8) MEDIUM: `transfer_pausable = 1` on ONDO token -- admin can pause all token transfers
- (-8) MEDIUM: `anti_whale_modifiable = 1` on ONDO token -- admin can modify anti-whale parameters
- (-5) LOW: No documented public timelock on admin actions for product contracts (OUSG/USDY)
- (-5) LOW: Undisclosed multisig signer identities -- Management Multisig signers not publicly doxxed
- (-5) LOW: Insurance fund / TVL ratio undisclosed
- (-5) LOW: Single oracle provider for NAV pricing (Ondo-operated oracle)
- (-2) INFO: Extreme token concentration -- top holder (Multisig 2) controls ~59% of ONDO supply

Red flags found: 0 CRITICAL, 0 HIGH, 2 MEDIUM, 4 LOW

Score meaning: 50-79 = MEDIUM risk. The score reflects the protocol's centralized trust model inherent to RWA tokenization, not smart contract weaknesses per se.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | 1-5% (Centrifuge: varies) | HIGH |
| Audit Coverage Score | 7.75 | 2-4 avg | LOW |
| Governance Decentralization | Centralized (team-operated multisig) | DAO vote avg | HIGH |
| Timelock Duration | Not publicly documented | 24-48h avg | HIGH |
| Multisig Threshold | UNVERIFIED (Safe-based, threshold not public) | 3/5 avg | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 2 MED | -- | LOW |

**Audit Coverage Score Calculation:**
- Cantina/Spearbit Feb 2026 (GM Limit Order): <1yr = 1.0
- Zellic Dec 2025 (GM Solana): <1yr = 1.0
- Cantina Dec 2025 (GM general): <1yr = 1.0
- Cantina Nov 2025 (Synthetic Shares): <1yr = 1.0
- FYEO Nov 2025 (GM Solana): <1yr = 1.0
- Cantina Oct 2025 (Bridge Registrar): <1yr = 1.0
- Spearbit Mar 2025 (Funds/USDY): 1-2yr = 0.5
- Halborn Feb 2025 (Funds/USDY): 1-2yr = 0.5
- Cyfrin Apr 2024 (Funds): 1-2yr = 0.5
- Code4rena Apr 2024: 1-2yr = 0.5
- Code4rena Sep 2023: >2yr = 0.25
- Zokyo Aug 2023: >2yr = 0.25
- NetherMind Apr 2023: >2yr = 0.25
- Total: 7.75 (LOW risk threshold: >= 3.0)

## GoPlus Token Security

### ONDO (0xfAbA6f8e4a5E8Ab82F62fe7C39859FA577269BE3, Ethereum)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | -- |
| Open Source | Yes (1) | -- |
| Proxy | No (0) | -- |
| Mintable | No (0) | -- |
| Owner Can Change Balance | No (0) | -- |
| Hidden Owner | No (0) | -- |
| Selfdestruct | No (0) | -- |
| Transfer Pausable | Yes (1) | MEDIUM |
| Blacklist | No (0) | -- |
| Slippage Modifiable | No (0) | MEDIUM |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 188,577 | -- |
| Trust List | Not listed | -- |
| Creator Honeypot History | No (0) | -- |
| Anti-Whale Modifiable | Yes (1) | MEDIUM |

**ONDO Top Holder Concentration:**
- Top holder: `0x677f...1a1` (Ondo Finance: Multisig 2) -- 59.04% of total supply (~$1.48B in ONDO)
- Top 5 holders control ~69.6% of supply
- The largest holder is a contract (Gnosis Safe multisig), likely team/treasury allocation
- Second largest holder: `0x460a...537` (EOA) -- 6.19%
- This extreme concentration means the team effectively controls governance unilaterally

Note: OUSG and USDY tokens are permissioned (KYC-gated) and not freely tradeable on DEXes, so GoPlus token checks are not applicable to the product tokens themselves. The ONDO governance token analysis above is the relevant GoPlus check.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | HIGH | Team-controlled multisig with undisclosed threshold; no public timelock; 59% token concentration | Partial |
| Oracle & Price Feeds | MEDIUM | Ondo-operated NAV oracle; no independent on-chain price feed for RWA pricing | N |
| Economic Mechanism | MEDIUM | Counterparty risk on custodians (Coinbase, BlackRock BUIDL); redemption depends on off-chain processes | Partial |
| Smart Contract | LOW | Extensive audit coverage (7.75 score); open source; $1M bug bounty on Immunefi | Y |
| Token Contract (GoPlus) | LOW | No critical flags; transfer pausable is expected for compliance token | Y |
| Cross-Chain & Bridge | MEDIUM | LayerZero/Axelar bridge dependencies across 12+ chains; burn-and-mint model | Partial |
| Operational Security | LOW | Doxxed team (ex-Goldman Sachs CEO); SEC investigation closed without charges; no past exploits | Y |
| **Overall Risk** | **MEDIUM** | **Strong audit coverage and institutional backing offset by centralized admin control, off-chain custodial dependencies, and opaque governance parameters** | |

## Detailed Findings

### 1. Governance & Admin Key

**Risk: HIGH**

Ondo Finance operates with a fundamentally centralized governance model, which is partly by design given RWA regulatory requirements but still represents concentrated risk:

**Multisig Configuration:**
- **Management Multisig** (`0xaed4...8367`): Safe (Gnosis Safe) Singleton 1.3.0. Controls product contract administration (OUSG/USDY minting, redemption, KYC registry updates, oracle updates). Exact threshold is NOT publicly documented. Created ~3 years ago.
- **Multisig 2** (`0x677f...1a1`): Safe Singleton 1.3.0. Holds ~5.9 billion ONDO tokens (~59% of total supply, worth ~$1.48B). This is the treasury/team allocation wallet.
- Signer identities for both multisigs are NOT publicly disclosed.

**Timelock:**
- No publicly documented timelock contract on admin actions for OUSG, USDY, or rOUSG contracts.
- No timelock address listed in the official smart contract addresses documentation.
- This means admin actions (parameter changes, upgrades, KYC list modifications) could potentially execute immediately upon multisig approval.

**Upgrade Mechanism:**
- OUSG and USDY use the Transparent Upgradeable Proxy pattern.
- The proxy admin (likely the Management Multisig) can upgrade contract logic.
- No documented delay between upgrade proposal and execution.

**DAO Governance:**
- Ondo DAO exists with on-chain voting via ONDO token.
- Proposal threshold: 100 million ONDO required to submit a proposal.
- However, given 59% of tokens are held by the team multisig, the team can unilaterally pass any proposal.
- DAO governance scope includes fee adjustments, new product launches, partnership approvals, and treasury allocation.
- In practice, day-to-day operations appear to be managed by the team multisig, not DAO votes.

**Key Concern:** The combination of undisclosed multisig threshold, undisclosed signer identities, no public timelock, and 59% token concentration means the Ondo team has effectively unchecked control over all protocol parameters and user funds. While this is common in regulated RWA protocols, it represents a trust assumption users must accept.

### 2. Oracle & Price Feeds

**Risk: MEDIUM**

Ondo's oracle architecture is fundamentally different from traditional DeFi protocols because the underlying assets (US Treasuries) are priced off-chain:

**NAV Oracle:**
- OndoOracle (`0x9Cad...094`) on Ethereum provides the OUSG price/NAV.
- USDY has a Redemption Price Oracle (`0xA021...De0`).
- These oracles are operated by Ondo Finance itself -- they are NOT Chainlink or Pyth feeds.
- NAV is calculated based on the underlying BlackRock BUIDL fund and other treasury holdings.
- Daily NAV updates reflect actual treasury yields and fund performance.

**Verification:**
- Ankura Trust Company provides daily third-party attestation of holdings for Ondo Global Markets (since October 2025).
- NAV Consulting is listed as a partner for fund administration.
- However, the attestation process for OUSG/USDY specifically (as opposed to Ondo Global Markets) is less clearly documented.

**Risk Factors:**
- The Ondo-operated oracle is a single point of failure -- if compromised, incorrect NAV could be posted.
- No documented circuit breaker for abnormal NAV changes.
- No fallback oracle mechanism.
- Admin can presumably update oracle addresses via multisig without timelock.

**Mitigating Factor:** US Treasury pricing is inherently stable and publicly verifiable, making oracle manipulation less impactful than for volatile DeFi assets. The risk is more about operational failure than manipulation.

### 3. Economic Mechanism

**Risk: MEDIUM**

**OUSG (Ondo Short-Term US Government Bond Fund):**
- Qualified Purchaser / Accredited Investor access only (KYC required).
- Backed primarily by BlackRock BUIDL fund (tokenized US Treasuries).
- Additional investments in Fidelity, Franklin Templeton, and WisdomTree products.
- Instant mint/redeem via OUSG_InstantManager for amounts >= $5,000.
- Larger redemptions go through a request/claim flow with off-chain settlement.
- Structured as a private fund under Section 3(c)(7) of the Investment Company Act of 1940.

**USDY (Ondo US Dollar Yield Token):**
- General access (KYC required, but not limited to accredited investors).
- Backed by short-term US Treasuries and US bank demand deposits.
- Structured as a special purpose vehicle with bankruptcy isolation.
- Managed by Ankura Trust Company as security agent.
- FinCEN-registered as a money services business.
- Transfer restrictions: users must be on allowlist, not on blocklist or sanctions list.

**rOUSG / rUSDY (Rebasing Variants):**
- Rebasing tokens that automatically adjust balance to reflect yield accrual.
- Same underlying backing as OUSG/USDY respectively.

**Risk Factors:**
- **Custodial dependency**: Funds ultimately depend on Coinbase (crypto custody) and traditional custodians (Clear Street, BlackRock) for underlying asset custody. A custodian failure or freeze could prevent redemptions.
- **Redemption risk**: Instant redemptions depend on available USDC/PYUSD liquidity in the InstantManager contracts. Large-scale redemptions require off-chain asset liquidation.
- **Regulatory risk**: USDY operates as a regulated instrument. Changes in US regulatory stance toward tokenized securities could force product modifications or wind-down. The SEC closed its investigation without charges, which is positive, but regulatory risk persists.
- **Insurance fund**: No publicly documented insurance or reserve fund to cover smart contract exploits or operational failures. Unlike lending protocols, the "insurance" is the underlying treasury backing itself.
- **Counterparty concentration**: Heavy reliance on BlackRock BUIDL for OUSG backing creates single-counterparty risk, though BlackRock is among the most creditworthy counterparties available.

### 4. Smart Contract Security

**Risk: LOW**

Ondo Finance has one of the most comprehensive audit histories in the RWA space:

**Audit History (20+ audits total):**
- **Ondo Global Markets**: 10 audits from June 2025 to February 2026, by Spearbit/Cantina, Cyfrin, FYEO, and Zellic.
- **Ondo Funds & USDY (Ethereum)**: 8 audits from January 2023 to March 2025, by Code4rena, Cyfrin, Halborn, Zokyo, NetherMind, and Spearbit.
- **Ondo Funds & USDY (Noble)**: 2 audits by Halborn (June-July 2024).
- **Deprecated products**: 6 additional audits from 2021-2022.

**Notable Audit Findings:**
- Code4rena March 2024: 1 HIGH, 4 MEDIUM findings. All mitigated.
- Cyfrin April 2024: 7 LOW findings, all mitigated.
- iosiro January 2022: HIGH-risk vulnerability in Tranche Token contracts that could have drained $50M. Disclosed responsibly and fixed before exploitation. $25K bounty paid.

**Bug Bounty:**
- Active on Immunefi with up to $1,000,000 max payout.
- 88 assets in scope across multiple chains.
- Critical: $50K-$1M (10% of funds at risk). High: $11K-$50K. Medium: $10K. Low: $1K.
- PoC and KYC required for all payouts.

**Code Quality:**
- Open source on GitHub (ondoprotocol).
- Contracts use well-known patterns (OpenZeppelin Transparent Proxy, Safe multisig).
- Permissioned token model (KYCRegistry) adds complexity but is well-audited.

**Battle Testing:**
- Protocol has been live since early 2023 with no exploits.
- Currently managing ~$3.5B TVL across 12+ chains.
- No rekt.news entries for Ondo Finance.

### 5. Cross-Chain & Bridge

**Risk: MEDIUM**

Ondo operates across 12+ chains, making cross-chain security a significant surface area:

**Bridge Architecture:**
- **LayerZero OFT Standard**: Primary bridge for USDY and Ondo Global Markets tokens.
- **Axelar Integration**: Additional cross-chain messaging layer.
- **Burn-and-mint model**: Tokens are burned on source chain and minted on destination chain, avoiding wrapped asset risks.
- **Multi-Message Aggregation (MMA)**: Uses multiple DVNs (Decentralized Verifier Networks) including Polyhedra Network (ZK prover), Axelar (POS blockchain), and LayerZero Labs DVN for cross-chain message verification.

**Chain Deployments (by TVL):**
- Ethereum: $2.16B (61.6%)
- BSC: $265M (7.6%)
- Solana: $263M (7.5%)
- XRPL: $222M (6.3%)
- Plume: $200M (5.7%)
- Stellar: $123M (3.5%)
- Aptos: $105M (3.0%)
- Sei: $103M (2.9%)
- Mantle: $30M, Sui: $17M, Noble: $15M, Arbitrum: $6M

**Risk Factors:**
- Bridge compromise could allow unauthorized minting on destination chains.
- Each chain deployment may have different admin configurations -- unclear if per-chain multisigs exist or if one key controls all.
- LayerZero and Axelar are third-party dependencies with their own security models.
- Non-EVM chains (Solana, Aptos, Sui, XRPL, Stellar) have separate smart contract implementations, each requiring independent security review.

**Mitigating Factors:**
- Burn-and-mint avoids wrapped asset depegging risk.
- MMA approach with three independent verification methods is more robust than single-DVN.
- Separate FYEO and Zellic audits specifically cover Solana implementations.

### 6. Operational Security

**Risk: LOW**

**Team:**
- Nathan Allman, Founder & CEO: Stanford MBA, ex-Goldman Sachs (Digital Assets, Global Markets, GS Accelerate). Previously founded ChainStreet Capital. Brown University BA. Fully doxxed with public LinkedIn and X presence.
- Team page publicly listed at ondo.finance/team.
- Institutional backing: investments from notable crypto VCs and TradFi partnerships (BlackRock, Fidelity, Franklin Templeton, Morgan Stanley).

**Regulatory Standing:**
- SEC investigation (opened under Biden administration) formally closed without charges in 2025. This is a significant positive signal for regulatory compliance.
- USDY registered with FinCEN as a money services business.
- KYC/AML/CFT compliance enforced at the smart contract level via KYCRegistry.
- Bank Secrecy Act compliance.

**Incident Response:**
- Emergency pause capability exists (transfer_pausable on ONDO token; KYCRegistry can restrict addresses).
- Blocklist functionality on USDY for sanctions compliance.
- No public incident response plan documented, but the team's handling of the 2022 iosiro vulnerability disclosure was responsible and timely.

**Dependencies:**
- BlackRock BUIDL fund (primary OUSG backing)
- Coinbase / Circle (USDC on/off-ramp)
- Clear Street (traditional custody)
- Ankura Trust Company (attestation, security agent)
- NAV Consulting (fund administration)
- LayerZero / Axelar (cross-chain messaging)

## Critical Risks (if any)

No CRITICAL-severity risks identified. The following HIGH risks warrant attention:

1. **Centralized Admin Control Without Public Timelock**: The Management Multisig can potentially execute upgrades and parameter changes to OUSG/USDY contracts immediately. There is no publicly documented timelock. For a protocol managing $3.5B, this is a significant trust assumption. A compromised or malicious multisig could theoretically upgrade contract logic to drain funds.

2. **Opaque Multisig Configuration**: Neither the threshold (e.g., 3/5, 4/7) nor the signer identities for the Management Multisig are publicly disclosed. Users cannot independently verify the security of the admin key setup.

3. **Unilateral Governance Power**: With 59% of ONDO supply held by the team multisig, the team can pass any governance proposal without external consensus. DAO governance is effectively advisory.

## Peer Comparison

| Feature | Ondo Finance | Centrifuge | Maple Finance |
|---------|-------------|------------|---------------|
| Timelock | Not documented | 48h on-chain | 48h on-chain |
| Multisig | Safe (threshold UNVERIFIED) | 3/6 multisig | 3/5 multisig |
| Audits (count) | 20+ | 8 | 6 |
| Oracle | Ondo-operated (NAV) | Chainlink + custom | Chainlink |
| Insurance/TVL | Undisclosed | Pool-level reserves | Pool-level reserves |
| Open Source | Yes | Yes | Yes |
| KYC Required | Yes (all products) | Per-pool | Per-pool |
| TVL | ~$3.51B | ~$550M | ~$780M |
| Bug Bounty | $1M (Immunefi) | $250K (Immunefi) | $100K (Immunefi) |
| Cross-Chain | 12+ chains | 2 chains | 1 chain |

Ondo leads on audit depth and bug bounty size but lags on governance transparency (no public timelock, undisclosed multisig threshold) compared to peers.

## Recommendations

**For Users/Investors:**
1. Understand the trust model: Ondo is fundamentally a centralized issuer of tokenized securities. The smart contracts enforce KYC and transfer restrictions but the team retains broad admin powers. This is a custodial product, not a trustless DeFi protocol.
2. Monitor multisig transactions on Etherscan for the Management Multisig (`0xaed4...8367`) to track any parameter changes or upgrades.
3. Prefer Ethereum deployment over smaller chain deployments given higher battle-testing and liquidity.
4. Be aware of large token unlocks: 1.71B ONDO tokens unlock in January 2027 and January 2028.
5. Verify daily attestation reports from Ankura Trust Company for Ondo Global Markets holdings.

**For the Ondo Team:**
1. Publish multisig threshold and signer identities (or at minimum, signer count and institutional affiliations) for the Management Multisig.
2. Implement and document a public timelock (minimum 24-48 hours) on contract upgrades and critical parameter changes.
3. Consider independent NAV oracle verification (e.g., Chainlink proof-of-reserve) to reduce single-oracle dependency.
4. Publish an explicit incident response plan.
5. Document per-chain admin configurations for all 12+ chain deployments.
6. Publish insurance or reserve fund details, or clarify the recourse mechanism if a smart contract exploit results in loss of tokenized assets.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- N/A (not a lending protocol)
- [x] Admin can change oracle sources arbitrarily? -- UNVERIFIED; likely yes via multisig
- [ ] Admin can modify withdrawal limits? -- Redemption limits managed by InstantManager, admin-controlled
- [?] Multisig has low threshold (2/N with small N)? -- UNVERIFIED; threshold not publicly disclosed
- [x] Zero or short timelock on governance actions? -- No public timelock documented
- [ ] Pre-signed transaction risk? -- N/A (EVM-based)
- [x] Social engineering surface area (anon multisig signers)? -- Signer identities not disclosed

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A (not a lending protocol)
- [x] Single oracle source without TWAP? -- Ondo-operated NAV oracle, single source
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [x] Insufficient insurance fund relative to TVL? -- Insurance fund undisclosed

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- LayerZero DVNs (partially centralized)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

**Pattern Match Assessment:** Ondo does not closely match any of the three exploit archetypes. The primary risk vector is not governance manipulation or oracle exploitation but rather custodial/counterparty failure -- a risk category more common in traditional finance than DeFi. The absence of a public timelock is the most concerning governance finding, as it enables rapid (potentially unauthorized) contract changes if the multisig is compromised.

## Information Gaps

The following questions could NOT be answered from publicly available information:

1. **Multisig threshold**: What is the M-of-N configuration for the Management Multisig (`0xaed4...8367`)? Is it 3/5? 4/7? This is critical for assessing compromise resistance.
2. **Multisig signer identities**: Who are the signers? Are they all Ondo employees, or do external parties (e.g., institutional partners) hold keys?
3. **Timelock existence**: Is there a timelock contract on OUSG/USDY proxy admin upgrades that is simply not documented publicly, or does one truly not exist?
4. **Per-chain admin configuration**: Do non-Ethereum deployments have independent multisigs or are they controlled from Ethereum via cross-chain messages?
5. **Insurance / reserve fund**: Is there any reserve or insurance mechanism to cover smart contract exploit losses beyond the underlying treasury backing?
6. **Oracle update frequency and validation**: How often is the NAV oracle updated, and what validation checks prevent erroneous price posting?
7. **Emergency powers**: Does anyone hold emergency powers (pause, upgrade bypass) outside the multisig? Is there a security council or guardian role?
8. **Key management practices**: Are multisig keys stored in hardware wallets? Is there a key rotation policy?
9. **Custodial insurance**: Do the underlying custodians (Coinbase, Clear Street) carry insurance that would cover losses from their own failure?
10. **Redemption queue limits**: What is the maximum daily/weekly redemption capacity before requiring off-chain liquidation?

These gaps are particularly significant because Ondo manages $3.5B in user funds across 12+ chains. The trust model requires users to accept that the team operates competently and honestly, with limited on-chain verification of admin controls.

## Disclaimer

This analysis is based on publicly available information and web research conducted on April 6, 2026.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
