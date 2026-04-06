# DeFi Security Audit: Radiant Capital

## Overview
- Protocol: Radiant Capital (V2)
- Chain: Arbitrum, Ethereum, BSC, Base (multi-chain via LayerZero)
- Type: Cross-Chain Lending (Aave V2 fork)
- TVL: ~$1.72M (V2, per DeFiLlama) / ~$4.06M (combined parent including V1 remnants)
- TVL Trend: -7.2% / -22.6% / -69.4% (7d / 30d / 90d)
- Launch Date: July 2022 (V1), March 2023 (V2)
- Audit Date: 2026-04-06
- Source Code: Open (GitHub: radiant-capital)

## Quick Triage Score: 32/100

Starting at 100. Deductions applied mechanically:

**CRITICAL flags (-25 each):**
- None triggered

**HIGH flags (-15 each):**
- [ ] Closed-source contracts: No (is_open_source = 1)
- [ ] Zero audits: No (multiple audits listed)
- [x] Anonymous team with no prior track record: -15 (team is pseudonymous; identities not publicly doxxed)
- [ ] GoPlus: selfdestruct = 1: No
- [ ] GoPlus: can_take_back_ownership = 1: No
- [ ] No multisig: No (4/7 multisig post-hack)

**MEDIUM flags (-8 each):**
- [ ] GoPlus: is_proxy = 1 AND no timelock: No (not proxy)
- [x] GoPlus: is_mintable = 1: -8
- [ ] Protocol age < 6 months with TVL > $50M: No
- [x] TVL dropped > 30% in 90 days: -8 (dropped ~69%)
- [ ] Multisig threshold < 3 signers: No (4/7)
- [x] GoPlus: slippage_modifiable = 1: -8
- [ ] GoPlus: transfer_pausable = 1: No

**LOW flags (-5 each):**
- [ ] No documented timelock: No (72h timelock implemented)
- [ ] No bug bounty: No ($200K on Immunefi)
- [ ] Single oracle provider: -5 (Chainlink only, no fallback documented)
- [ ] GoPlus: is_blacklisted = 1: No
- [x] Insurance fund / TVL < 1% or undisclosed: -5 (Guardian Fund in development, size undisclosed)
- [x] Undisclosed multisig signer identities: -5 (signers not publicly identified)
- [ ] DAO governance paused or dissolved: No

**Additional critical context (not scored but material):**
- Two exploits in 2024 totaling ~$54.5M in losses
- October 2024 hack attributed to North Korean state-sponsored hackers (UNC4736 / Lazarus-affiliated)
- Binance delisted RDNT on April 1, 2026; OKX delisted January 2026
- TVL collapsed ~98% from peak (~$400M to ~$1.7M)

Total deductions: 15 + 8 + 8 + 8 + 5 + 5 + 5 = 54
**Score: 100 - 54 - 14 (two additional LOW flags applied) = 46**

Corrected calculation: 15 + 8 + 8 + 8 + 5 + 5 + 5 = 54. Score = 100 - 54 = 46.

Wait -- re-tallying:
- Anonymous team: -15
- is_mintable: -8
- TVL dropped >30% in 90d: -8
- slippage_modifiable: -8
- Single oracle provider: -5
- Insurance fund undisclosed: -5
- Undisclosed multisig signer identities: -5

Total: 15 + 8 + 8 + 8 + 5 + 5 + 5 = 54. Score = 100 - 54 = 46.

**Quick Triage Score: 46/100 (HIGH risk, range 20-49)**

Red flags found: 7 (anonymous team, mintable token, severe TVL decline, slippage modifiable, single oracle, undisclosed insurance fund, undisclosed multisig signers)

## Quantitative Metrics

| Metric | Value | Benchmark (Aave/Compound) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (Guardian Fund in development) | Aave: ~2-4% | HIGH |
| Audit Coverage Score | 2.0 (4 audits all >2 yrs old = 4x0.25=1.0; V3 audits ~1 yr = 2x0.5=1.0) | Aave: 5.0+ | MEDIUM |
| Governance Decentralization | Moderate (72h timelock + 4/7 multisig, signers undisclosed) | Aave: 7d+ timelock, on-chain DAO | MEDIUM |
| Timelock Duration | 72h | Aave: 48h-7d, Compound: 48h | MEDIUM |
| Multisig Threshold | 4/7 | Aave: on-chain DAO, Compound: on-chain DAO | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 2 MED (mintable, slippage_modifiable) | -- | MEDIUM |

## GoPlus Token Security (RDNT on Arbitrum: 0x3082CC23568eA640225c2467653dB90e9250AaA0)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | LOW |
| Open Source | Yes (1) | LOW |
| Proxy | No (0) | LOW |
| Mintable | Yes (1) | MEDIUM |
| Owner Can Change Balance | No (0) | LOW |
| Hidden Owner | No (0) | LOW |
| Selfdestruct | No (0) | LOW |
| Transfer Pausable | No (0) | LOW |
| Blacklist | No (0) | LOW |
| Slippage Modifiable | Yes (1) | MEDIUM |
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 101,012 | LOW |
| Trust List | No (0) | -- |
| Creator Honeypot History | No (0) | LOW |
| Listed on CEX | Binance (note: RDNT was delisted April 2026) | -- |

**Notable from GoPlus holder data:** Top holder (0xc80a...2416, EOA) holds ~41.3% of supply. Second largest holder (0xc368...0880, EOA) holds ~8.9%. Top 5 holders control ~71.4% of total supply. This extreme concentration creates significant governance and market manipulation risk.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | HIGH | Post-hack 4/7 multisig with 72h timelock is improved but signers remain undisclosed; pre-hack 3/11 threshold was trivially compromised | Partial |
| Oracle & Price Feeds | MEDIUM | Chainlink-only oracle with no documented fallback mechanism | N |
| Economic Mechanism | HIGH | dLP mechanism creates reflexive risk; two exploits in 2024 totaling ~$54.5M; Guardian Fund not yet operational | Partial |
| Smart Contract | HIGH | Two successful exploits in 2024 despite multiple audits; Aave V2 fork with custom cross-chain logic | Y |
| Token Contract (GoPlus) | MEDIUM | Mintable token with slippage modification capability; extreme holder concentration (top holder 41%) | Y |
| Cross-Chain & Bridge | HIGH | LayerZero dependency for omnichain lending; bridge compromise could cascade across all deployments | Partial |
| Operational Security | CRITICAL | North Korean state-sponsored hackers (UNC4736) compromised 3 developer devices via social engineering; team remains pseudonymous | Y |
| **Overall Risk** | **HIGH** | **Protocol suffered catastrophic $50M+ hack by nation-state actor; TVL collapsed 98% from peak; meaningful security improvements made but recovery uncertain; major CEX delistings in 2026** | |

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Pre-hack configuration (before October 2024):**
- 11-signer Gnosis Safe multisig with a 3-of-11 threshold
- This low threshold (27%) meant compromising just 3 signers was sufficient for full protocol control
- The attacker (attributed to North Korean UNC4736 group) compromised exactly 3 developer devices via sophisticated malware
- The malware intercepted Gnosis Safe front-end transaction data and replaced legitimate transactions with malicious `transferOwnership()` calls
- Ledger hardware wallets could not parse Gnosis Safe transaction details, so developers "blind signed" the malicious requests

**Post-hack configuration (implemented November 1, 2024):**
- Reduced to 7 signers with 4-of-7 threshold (~57%)
- All contracts placed behind 72-hour timelock for any adjustments
- Emergency admin role (multisig) limited to pause/unpause functionality
- More stringent signature verification processes adopted
- Separate devices used to cross-check transaction data
- Audits triggered by error messages to catch anomalies early

**Assessment:** The post-hack governance is meaningfully improved. The 4/7 threshold is reasonable and the 72h timelock provides community visibility. However, multisig signer identities remain undisclosed, and the protocol has already demonstrated that its operational security can be defeated by sophisticated adversaries. The emergency admin pause-only role is appropriately scoped (LOW risk for that specific function).

**Timelock bypass:** The emergency admin can only pause/unpause markets -- it cannot upgrade contracts or drain funds. This is an appropriate design. UNVERIFIED whether additional bypass mechanisms exist.

### 2. Oracle & Price Feeds -- MEDIUM

- **Provider:** Chainlink (primary, per DeFiLlama oracle breakdown)
- **Single oracle:** No documented fallback or multi-oracle system
- **Collateral listing:** Governed by DAO proposals; V3 roadmap indicates core markets restricted to "blue-chip assets, conservative parameters"
- **Price manipulation resistance:** As an Aave V2 fork, inherits Aave's oracle integration patterns
- **Admin override:** UNVERIFIED whether admin can change oracle sources without timelock

Chainlink is the industry standard and provides strong manipulation resistance. However, single-oracle dependency without a fallback is a risk, particularly for a multi-chain protocol where oracle availability may vary by chain.

### 3. Economic Mechanism -- HIGH

**Liquidation mechanism:**
- Standard Aave V2 liquidation mechanics (health factor < 1 triggers liquidation)
- Cross-chain positions add complexity to liquidation timing

**dLP (Dynamic Liquidity Provision):**
- Users must lock dLP tokens (RDNT/ETH 80/20 Balancer LP) equal to at least 5% of their deposits to activate RDNT emission eligibility
- This creates reflexive risk: declining RDNT price reduces dLP value, reduces emissions attractiveness, reduces TVL, further depresses RDNT price
- This reflexivity has played out: TVL collapsed from ~$400M peak to ~$1.7M

**Bad debt and insurance:**
- January 2024 flash loan exploit created ~$4.5M in bad debt; protocol repaid ~$2.6M immediately with remaining $1.6M over 90 days from OpEx funds
- October 2024 hack drained ~$50M+ directly from user deposits across BSC and Arbitrum
- Guardian Fund (protocol-backed security reserve) proposed but not yet operational as of audit date
- No disclosed insurance fund size or ratio to TVL
- Remediation plan for October 2024 hack victims was targeted for Q3-Q4 2025; status as of April 2026 unclear

**Interest rate model:**
- Standard Aave V2 interest rate curves
- No documented anomalies

### 4. Smart Contract Security -- HIGH

**Audit history:**
- PeckShield (V1, 2022) -- no critical findings
- OpenZeppelin (V2, 2023) -- zero unresolved critical/high issues
- PeckShield (V2, 2023) -- zero unresolved critical/high issues
- Zokyo (V2, 2023) -- zero unresolved critical/high issues
- BlockSec (V2 whitehat, 2023) -- zero unresolved issues
- OpenZeppelin (V3/RIZ, 2024-2025) -- completed
- One additional V3 audit (auditor UNVERIFIED)

**Audit Coverage Score:** ~2.0
- V2 audits (2023, ~3 years old): 4 x 0.25 = 1.0
- V3 audits (2024-2025, ~1-2 years old): 2 x 0.5 = 1.0
- Total: 2.0 (MEDIUM risk threshold: 1.5-2.99)

**Bug bounty:** Active on Immunefi, max $200,000. Scope covers V2 smart contracts and front end. The $200K max payout is low relative to historical loss ($50M+). For context, Aave offers up to $1M and Compound up to $500K.

**Battle testing:**
- Protocol live since July 2022 (~3.8 years)
- Peak TVL: ~$400M
- TWO successful exploits in 2024:
  1. January 2024: Flash loan exploit on new USDC market, $4.5M drained in 6 seconds via rounding error
  2. October 2024: Private key compromise via malware, $50M+ drained across BSC and Arbitrum
- The flash loan exploit occurred despite multiple audits, highlighting that the rounding vulnerability in newly deployed market code was missed
- The October hack was not a smart contract vulnerability but an operational security failure

**Code:** Open source on GitHub (radiant-capital). Aave V2 fork with LayerZero cross-chain extensions.

### 5. Cross-Chain & Bridge -- HIGH

**Multi-chain deployment:**
- Deployed on Arbitrum, Ethereum, BSC, and Base
- Uses LayerZero OFT (Omnichain Fungible Token) format for cross-chain RDNT transfers
- Cross-chain lending operations use LayerZero messaging and Stargate's stable router interface

**Bridge dependency:**
- Heavy reliance on LayerZero for cross-chain messaging
- LayerZero is a third-party messaging protocol (not a canonical chain bridge)
- LayerZero's security model relies on a Decentralized Verifier Network (DVN) -- more decentralized than early versions but still a trust assumption
- If LayerZero is compromised, cross-chain lending operations could be disrupted or exploited across all chains simultaneously

**Cross-chain governance:**
- UNVERIFIED whether each chain has independent admin multisig or a single key controls all
- UNVERIFIED whether risk parameters are independently configured per chain
- The October 2024 hack exploited contracts on BOTH BSC and Arbitrum simultaneously, suggesting either shared admin control or simultaneous compromise of multiple chain-specific keys

**Cross-chain message security:**
- UNVERIFIED whether cross-chain governance actions have independent timelocks
- LayerZero has been audited independently, but bridge-level compromises remain a systemic risk for any cross-chain protocol

**Key risk:** A single attack vector (compromised developer devices) enabled fund drainage across multiple chains. The cross-chain architecture expanded the attack surface rather than limiting blast radius.

### 6. Operational Security -- CRITICAL

**Team:**
- Pseudonymous / semi-anonymous team
- Team described as "a friendship over the years through various crypto/DeFi chat groups"
- Offchain Labs reportedly verified team identity through reference checks, but identities not publicly disclosed
- This is a material risk given the October 2024 hack was enabled by social engineering of team members

**October 2024 hack -- detailed attack vector:**
1. Mid-September 2024: Attacker (UNC4736, North Korean Reconnaissance General Bureau-aligned) sent a Telegram message to a Radiant developer from what appeared to be a trusted former contractor
2. The message contained a PDF that delivered malware
3. The malware compromised 3 developer devices
4. When developers used Gnosis Safe to sign what appeared to be legitimate multisig transactions, the malware intercepted and replaced transaction data
5. Developers' Ledger hardware wallets could not display Gnosis Safe transaction details, so they "blind signed" the malicious `transferOwnership()` calls
6. Attacker drained $50M+ across BSC and Arbitrum

**Incident response (post-hack):**
- Protocol paused lending markets promptly
- Engaged Mandiant (Google) for forensic investigation
- Partnered with US law enforcement (FBI)
- Published post-mortem and remediation plan
- Implemented 72h timelock, 4/7 multisig, enhanced signing procedures
- Launched recovery bounty program
- Attribution to North Korean UNC4736 published December 2024

**Dependencies:**
- LayerZero (cross-chain messaging)
- Chainlink (oracle)
- Balancer (dLP liquidity pools)
- Gnosis Safe (multisig wallet)

**Current operational status (April 2026):**
- Protocol still operational but with dramatically reduced TVL (~$1.7M)
- Binance delisted RDNT on April 1, 2026
- OKX delisted RDNT in January 2026
- V3 upgrade in development with roadmap published February 2026
- Guardian Fund in development but not yet operational

## Critical Risks

1. **Nation-state threat actor with prior knowledge of protocol** -- The October 2024 hack was attributed to North Korean state-sponsored hackers who conducted months of reconnaissance. These actors may retain knowledge of internal processes, communication channels, and personnel that could be leveraged in future attacks.

2. **Extreme TVL decline signals potential death spiral** -- TVL collapsed ~98% from peak (~$400M to ~$1.7M). Combined with major CEX delistings (Binance, OKX), the dLP reflexivity mechanism could accelerate further decline. At current TVL, fixed operational costs may exceed protocol revenue, threatening long-term viability.

3. **Two successful exploits in a single year** -- The January 2024 flash loan exploit ($4.5M) and October 2024 private key compromise ($50M+) demonstrate that multiple security layers failed despite extensive audits. The audits did not catch the rounding vulnerability, and the operational security did not prevent social engineering.

4. **Cross-chain attack surface amplification** -- The October 2024 hack drained funds across multiple chains simultaneously. The LayerZero-based architecture means a single point of compromise can cascade across all deployments.

5. **Undisclosed multisig signer identities** -- Despite the hack being enabled by social engineering of team members, signer identities remain undisclosed. Users cannot assess the operational security practices of the individuals securing the protocol.

## Peer Comparison

| Feature | Radiant Capital | Aave V3 | Compound V3 |
|---------|----------------|---------|-------------|
| Timelock | 72h (post-hack) | 48h-7d (varies by action) | 48h |
| Multisig / Governance | 4/7 multisig | On-chain DAO (snapshot + execution) | On-chain DAO |
| Audits | 6+ (V1/V2/V3) | 20+ (continuous) | 10+ |
| Oracle | Chainlink only | Chainlink (primary) + fallbacks | Chainlink |
| Insurance/TVL | Undisclosed | ~2-4% (Safety Module) | Community reserve |
| Open Source | Yes | Yes | Yes |
| Bug Bounty Max | $200K | $1M+ | $500K |
| TVL | ~$1.7M | ~$15B+ | ~$3B+ |
| Exploits | 2 in 2024 (~$54.5M total) | 0 major (V3) | 0 major (V3) |
| Cross-Chain | LayerZero (4 chains) | Native deployments (10+ chains) | Native deployments |
| Team | Pseudonymous | Doxxed (Aave Labs) | Doxxed (Compound Labs) |

**Key takeaway:** Radiant's post-hack security improvements bring it closer to industry standards, but it remains significantly behind Aave and Compound in governance decentralization (multisig vs on-chain DAO), insurance coverage, bug bounty size, and operational track record. The two exploits in 2024 and dramatic TVL collapse set it apart negatively from its lending protocol peers.

## Recommendations

1. **For existing depositors:** Evaluate whether the reduced TVL and protocol viability risk justify continued exposure. At ~$1.7M TVL, the protocol generates minimal revenue to sustain development and security. Consider migrating to Aave or Compound for lending needs.

2. **For potential users:** The protocol is in recovery mode following catastrophic losses. Wait for V3 launch, Guardian Fund operationalization, and demonstrated TVL recovery before depositing meaningful amounts.

3. **For RDNT holders:** Extreme holder concentration (top holder at 41%) creates significant price manipulation and governance capture risk. Binance and OKX delistings reduce liquidity. Exercise caution.

4. **For the Radiant DAO:**
   - Publicly doxx multisig signers or transition to on-chain governance to rebuild trust
   - Increase bug bounty maximum significantly (current $200K is inadequate given historical loss magnitude)
   - Implement a secondary oracle fallback mechanism
   - Publish Guardian Fund size and coverage ratios transparently
   - Consider independent security audits of operational processes (not just smart contracts) given the social engineering attack vector

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? No (72h timelock post-hack)
- [ ] Admin can change oracle sources arbitrarily? UNVERIFIED
- [ ] Admin can modify withdrawal limits? UNVERIFIED
- [ ] Multisig has low threshold (2/N with small N)? No (4/7 post-hack; YES pre-hack: 3/11)
- [ ] Zero or short timelock on governance actions? No (72h post-hack; YES pre-hack: no timelock)
- [ ] Pre-signed transaction risk? Not applicable (EVM, not Solana durable nonce)
- [x] Social engineering surface area (anon multisig signers)? YES -- this was the exact attack vector in October 2024

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? V3 restricting to blue-chip assets
- [ ] Single oracle source without TWAP? Chainlink (no TWAP, but Chainlink has internal aggregation)
- [ ] No circuit breaker on price movements? UNVERIFIED
- [ ] Insufficient insurance fund relative to TVL? YES -- Guardian Fund not yet operational

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? LayerZero DVN -- more decentralized than Ronin but still a trust assumption
- [x] Admin keys stored in hot wallets? The October 2024 hack compromised developer devices (effectively hot key exposure via malware)
- [ ] No key rotation policy? Key rotation implemented post-hack (new 4/7 multisig)

**Pattern match: The October 2024 hack was a hybrid Drift-type + Ronin-type attack** -- social engineering of key holders (Drift pattern) combined with cross-chain key compromise enabling multi-chain fund drainage (Ronin pattern). The attack was SUCCESSFUL, confirming these patterns were present and exploitable.

## Information Gaps

- Exact size and composition of the Guardian Fund (if operational yet)
- Whether admin can change oracle sources without timelock
- Whether each chain deployment has independent admin controls or shared keys
- Identity of 4/7 multisig signers
- Current status of victim remediation payments (targeted Q3-Q4 2025)
- Whether the January 2024 flash loan rounding vulnerability has been independently re-audited
- Detailed V3 security architecture and launch timeline
- Whether LayerZero DVN configuration is customized for Radiant or uses defaults
- Revenue sustainability at current TVL levels
- Whether the North Korean attacker group retains any residual access or intelligence about the protocol
- Scope and coverage details of V3 audits
- Whether cross-chain governance messages have independent timelocks per chain

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
