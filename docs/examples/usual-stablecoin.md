# DeFi Security Audit: Usual (USD0)

**Audit Date:** April 20, 2026
**Protocol:** Usual -- RWA-backed stablecoin protocol
**Valid Until:** July 19, 2026 (or sooner if: TVL changes >30%, governance upgrade, or security incident)

## Overview
- Protocol: Usual (USD0 stablecoin, USD0++ / bUSD0 bond token, USUAL governance token)
- Chain: Ethereum
- Type: RWA-backed Stablecoin
- TVL: ~$101.3M (USD0 protocol only; peaked at ~$1.87B in late 2024)
- TVL Trend: -0.7% / -4.8% / -24.7% (7d / 30d / 90d)
- Launch Date: July 2024
- Audit Date: April 20, 2026
- Valid Until: July 19, 2026
- Source Code: Open (verified on Etherscan)

## Quick Triage Score: 41/100 (HIGH) | Data Confidence: 55/100 (MEDIUM)

### Triage Score Calculation

Starting at 100:

**CRITICAL flags (-25 each):** None

**HIGH flags (-15 each):** None

**MEDIUM flags (-8 each):**
- [x] GoPlus: is_proxy = 1 AND no documented timelock on upgrades (-8) -- USUAL and USD0 are both proxy contracts; timelock duration not publicly documented
- [x] GoPlus: is_mintable = 1 (-8) -- USD0 is mintable by design (stablecoin minting engine)
- [x] No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations (-8)

Note: TVL dropped ~24.7% in 90 days (below the 30% threshold; not counted). Peak-to-current decline is ~94.6% but occurred over >90-day window.

**LOW flags (-5 each):**
- [x] No documented timelock on admin actions (-5)
- [x] Single oracle provider (-5) -- oracle details not publicly documented
- [x] GoPlus: is_blacklisted = 1 (-5) -- USD0 has blacklist functionality (BLACKLIST_ROLE in access control)
- [x] Undisclosed multisig signer identities (-5)
- [x] No published key management policy (HSM, MPC, key ceremony) (-5)
- [x] No disclosed penetration testing (infrastructure, not just smart contract audit) (-5)
- [x] Custodial dependency without disclosed custodian certification (-5) -- depends on Hashnote/BNY Mellon custody

**Score: 100 - 24 - 35 = 41/100 (HIGH risk)**

### Data Confidence Score Calculation

Starting at 0:

- [x] +15 Source code is open and verified on block explorer
- [x] +15 GoPlus token scan completed (not N/A or UNAVAILABLE)
- [x] +10 At least 1 audit report publicly available (3 audits: Spearbit/Cantina, Halborn, Sherlock)
- [ ] +10 Multisig configuration verified on-chain (Safe API or Squads) -- NOT verified; multisig address undisclosed
- [ ] +10 Timelock duration verified on-chain or in docs -- NOT verified
- [x] +10 Team identities publicly known (doxxed) -- Pierre Person (CEO), Adli Takkal Bataille, Hugo Salle de Chou
- [ ] +10 Insurance fund size publicly disclosed -- no explicit insurance fund
- [x] +5 Bug bounty program details publicly listed ($16M via Sherlock)
- [ ] +5 Governance process documented -- partially; DAO mentioned but specifics sparse
- [ ] +5 Oracle provider(s) confirmed -- oracle architecture not publicly documented
- [ ] +5 Incident response plan published -- no published plan
- [ ] +5 SOC 2 Type II or ISO 27001 certification verified
- [ ] +5 Published key management policy
- [ ] +5 Regular penetration testing disclosed
- [ ] +5 Bridge DVN/verifier configuration (N/A, single chain)

**Data Confidence Score: 55/100 (MEDIUM confidence)**

- Red flags found: 3 MEDIUM, 7 LOW (10 total)
- Data points verified: 5 / 14 checkable (Bridge DVN N/A)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | 1-5% (Maker: ~5%) | HIGH |
| Audit Coverage Score | 3.0 (3 audits, all <1 year old: 3 x 1.0) | 3.0+ = LOW | LOW |
| Governance Decentralization | DAO (details sparse) | Maker MKR DAO | MEDIUM |
| Timelock Duration | UNVERIFIED | 24-48h (peers) | HIGH |
| Multisig Threshold | UNVERIFIED | 3/5 avg | HIGH |
| GoPlus Risk Flags | 0 HIGH / 3 MED (proxy x2, mintable) | -- | MEDIUM |

## GoPlus Token Security (USUAL on Ethereum)

Token address: `0xC4441c2BE5d8fA8126822B9929CA0b81Ea0DE38E`

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | Yes (upgradeable) | MEDIUM |
| Mintable | N/A (not flagged) | -- |
| Owner Can Change Balance | N/A (not flagged) | -- |
| Hidden Owner | N/A (not flagged) | -- |
| Selfdestruct | N/A (not flagged) | -- |
| Transfer Pausable | N/A (not flagged) | -- |
| Blacklist | N/A (not flagged) | -- |
| Slippage Modifiable | N/A (not flagged) | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 23,743 | -- |
| Trust List | N/A | -- |
| Creator Honeypot History | No | -- |
| CEX Listed | Binance | -- |

GoPlus assessment for USUAL: **LOW RISK**. Only flag is proxy (upgradeable) pattern. No honeypot, no hidden owner, no tax.

## GoPlus Token Security (USD0 on Ethereum)

Token address: `0x73A15FeD60Bf67631dC6cd7Bc5B6e8da8190aCF5`

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | Yes (upgradeable) | MEDIUM |
| Mintable | Yes (by design -- stablecoin mint engine) | MEDIUM |
| Owner Can Change Balance | N/A (not flagged) | -- |
| Hidden Owner | N/A (not flagged) | -- |
| Selfdestruct | N/A (not flagged) | -- |
| Transfer Pausable | Yes (PAUSING_CONTRACTS_ROLE) | MEDIUM |
| Blacklist | Yes (BLACKLIST_ROLE) | LOW |
| Slippage Modifiable | N/A (not flagged) | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 124,133 | -- |
| Trust List | N/A | -- |
| Creator Honeypot History | No | -- |

GoPlus assessment for USD0: **MEDIUM RISK**. Proxy, mintable, pausable, and blacklist flags. For a stablecoin, mintability and blacklist are expected features (required for compliance and minting/redeeming). The proxy pattern requires trust in the upgrade governance.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **HIGH** | Multisig threshold and timelock undisclosed; upgradeable proxies with unclear governance | S/O | Partial |
| Oracle & Price Feeds | **MEDIUM** | Oracle architecture for RWA pricing not publicly documented | S | N |
| Economic Mechanism | **MEDIUM** | USD0++ depeg to $0.87 in Jan 2025 revealed redemption mechanism risks; TVL down 94% from peak | S/H | Partial |
| Smart Contract | **LOW** | 3 audits (Spearbit/Cantina, Halborn, Sherlock); $16M bug bounty; open source | S | Y |
| Token Contract (GoPlus) | **MEDIUM** | Proxy + mintable + pausable + blacklist on USD0 (expected for stablecoin) | S | Y |
| Cross-Chain & Bridge | **N/A** | Single-chain (Ethereum) | -- | -- |
| Off-Chain Security | **HIGH** | No SOC 2 / ISO 27001; no published key management; custodial dependency on Hashnote/BNY Mellon | O | N |
| Operational Security | **MEDIUM** | Doxxed team (ex-French politician CEO); Jan 2025 depeg was governance decision, not exploit | S/H/O | Partial |
| **Overall Risk** | **HIGH** | **Governance opacity + off-chain security gaps; strong audit profile offset by lack of transparency on admin controls** | | |

**Overall Risk aggregation**: Governance & Admin is HIGH (counts as 2x = 2 HIGHs), Off-Chain Security is HIGH (1 HIGH). That gives 3 HIGHs total, which exceeds the 2+ threshold. **Overall = HIGH.**

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Admin Key Surface Area:**
- USD0 contracts use a role-based access control system with a RegistryAccess contract
- Key roles include: DEFAULT_ADMIN_ROLE, PAUSING_CONTRACTS_ROLE, BLACKLIST_ROLE, USUALS_BURN, DISTRIBUTION_ALLOCATOR_ROLE, DISTRIBUTION_OPERATOR_ROLE, DISTRIBUTION_CHALLENGER_ROLE, FEE_RATE_SETTER_ROLE
- The DAO controls which collateral is accepted, fees, and parameters for USUAL and other products
- **All contracts are upgradeable proxies**, meaning whoever controls the proxy admin can change implementation logic

**Multisig:**
- The protocol documentation mentions a multisig but does not publicly disclose the address, threshold, or signer identities
- UNVERIFIED: Cannot confirm if admin is a Gnosis Safe or EOA without an address

**Timelock:**
- No publicly documented timelock on admin actions or contract upgrades
- This is a significant gap: proxy upgrades without a timelock allow instantaneous implementation changes

**Governance Process:**
- DAO governance via USUAL token is described in documentation
- The DAO decides on collateral acceptance, fee structures, and protocol expansion
- Specific voting mechanics (quorum, voting period, on-chain vs off-chain) are not clearly documented

**Upgrade Mechanism:**
- Both USD0 and USUAL tokens are upgradeable proxy contracts (confirmed by GoPlus)
- The DaoCollateral contract is also upgradeable
- Upgrade governance details (who controls proxy admin, timelock on upgrades) are not publicly documented

**January 2025 Governance Incident:**
- The USD0++ redemption rule change that triggered the depeg was a unilateral protocol decision, not a DAO vote
- This demonstrated that the team can make significant economic parameter changes outside of formal governance
- Pierre Person (CEO) defended the decision but the process raised governance transparency concerns

### 2. Oracle & Price Feeds -- MEDIUM

**Oracle Architecture:**
- USD0 collateral (USYC from Hashnote) is priced via an oracle feed
- The specific oracle provider is not publicly documented (not Chainlink or Pyth explicitly)
- Assets and token prices are "published via oracle feed" per documentation, but implementation details are opaque
- DeFiLlama lists no oracle for the protocol

**RWA Price Feed Challenges:**
- US Treasury Bill pricing is relatively stable, reducing oracle manipulation risk
- However, the mechanism for on-chain pricing of off-chain assets introduces a trust assumption
- The oracle could become a single point of failure if it malfunctions or is compromised

**Collateral Valuation:**
- USYC (Hashnote) represents shares in a money market fund investing in T-Bills and reverse repos
- The fund is custodied at Bank of New York Mellon
- NAV is calculated off-chain and published on-chain, creating a trust dependency

### 3. Economic Mechanism -- MEDIUM

**USD0 Minting/Redemption:**
- USD0 is minted 1:1 against approved RWA collateral (primarily USYC)
- Redemption follows the same 1:1 path
- The DaoCollateral contract manages the swap between collateral and USD0

**USD0++ (bUSD0) Bond Token:**
- USD0++ is a 4-year bond token that locks USD0 and earns yield (T-Bill yield + USUAL emissions)
- The January 2025 depeg was caused by a change to USD0++ redemption: the floor price was set to $0.87 (reflecting the time value of a 4-year zero-coupon bond), down from the previous 1:1 redemption
- This caused panic selling, with USD0++ dropping to $0.89 before recovering to ~$0.92
- A "1:1 Early Unstaking" option was later introduced, but required forfeiting all earned rewards

**Revenue Model:**
- Protocol revenue comes from T-Bill yields on the underlying collateral
- A "revenue switch" activated in January 2025 distributes up to $5M/month to the community
- USUAL stakers earn 22% of daily USUAL emissions

**TVL Decline:**
- Peak TVL was ~$1.87B (late 2024)
- Current TVL is ~$101.3M, a decline of ~94.6%
- The massive decline correlates with the USD0++ depeg event and subsequent loss of confidence
- This represents a significant structural concern about the protocol's ability to maintain deposits

**Insurance Fund:**
- No explicit insurance fund is documented
- The protocol relies on overcollateralization (1:1 RWA backing) rather than an insurance mechanism

### 4. Smart Contract Security -- LOW

**Audit History:**
- Spearbit/Cantina: Usual Pegasus Phase 2 audit
- Halborn: Usual V1 Audit
- Sherlock: Usual V1 Audit Competition Report
- All audits are within the last 2 years
- Audit Coverage Score: 3 x 1.0 = 3.0 (all audits within last year)

**Bug Bounty:**
- $16M maximum payout via Sherlock (launched March 2026)
- Described as the "largest bug bounty in tech history"
- Scaling model: 10% of at-risk funds, capped at $16M
- Scope covers full smart contract suite including stablecoin infrastructure, yield distribution, and governance contracts

**Battle Testing:**
- Protocol live since July 2024 (~21 months)
- Peak TVL handled: ~$1.87B
- No smart contract exploits reported
- The USD0++ depeg was a governance/economic mechanism issue, not a code vulnerability
- Not listed on rekt.news

**Open Source:**
- All contracts are open source and verified on Etherscan

### 5. Cross-Chain & Bridge -- N/A

Usual operates exclusively on Ethereum mainnet. No cross-chain bridge dependencies.

### 6. Operational Security -- MEDIUM

**Team & Track Record:**
- Pierre Person (CEO): Former member of the French National Assembly (2017-2022), doxxed public figure
- Co-founders: Adli Takkal Bataille (known crypto figure in France), Hugo Salle de Chou
- Team is fully doxxed with verifiable backgrounds
- Previous projects: Pierre Person is primarily known for his political career and crypto advocacy

**Funding:**
- $7M seed round led by Kraken Ventures and IOSG Ventures (April 2024)
- $10M Series A led by Binance Labs and Kraken Ventures (December 2024)
- Additional investors: Ondo, Coinbase Ventures, Galaxy Ventures, OKX Ventures, GSR, Ethena

**Incident Response:**
- No published incident response plan
- During the January 2025 depeg, the team responded within days with mitigation measures (revenue switch, 1:1 unstaking option)
- However, the depeg itself was caused by a team-initiated change, raising questions about decision-making processes

**Dependencies:**
- Hashnote (USYC): Primary collateral provider -- now owned by Circle
- Bank of New York Mellon: Custodian for underlying T-Bills
- Ethena (USDtb): Secondary collateral source
- These are institutional-grade dependencies with their own regulatory oversight (CIMA, CFTC)

**Off-Chain Controls:**
- No SOC 2 Type II or ISO 27001 certification disclosed
- No published key management policy
- No disclosed penetration testing
- Custodial dependency on Hashnote/BNY Mellon without disclosed custodian certification from Usual itself
- Rating: **HIGH** (no certifications, no published security practices)

## Critical Risks (if any)

1. **HIGH: Governance Opacity** -- Multisig configuration, timelock duration, and proxy admin governance are not publicly documented. Users cannot verify who controls contract upgrades or how quickly changes can be made.
2. **HIGH: Off-Chain Security Unverified** -- No SOC 2, ISO 27001, published key management, or penetration testing. For a protocol managing $100M+ in RWA assets, this represents a significant operational risk gap.
3. **HIGH: Massive TVL Decline** -- 94.6% decline from $1.87B peak to $101.3M suggests structural confidence issues, likely stemming from the January 2025 USD0++ depeg incident.

## Peer Comparison

| Feature | Usual (USD0) | Maker (DAI/USDS) | Ondo (USDY) |
|---------|-------------|------------------|-------------|
| Timelock | UNVERIFIED | 48h (GSM) | UNVERIFIED |
| Multisig | UNVERIFIED | MKR DAO + MCD Pause Proxy | Multisig (details public) |
| Audits | 3 (Spearbit, Halborn, Sherlock) | 10+ (Trail of Bits, ChainSecurity, etc.) | 3+ |
| Oracle | Undisclosed | Chainlink + Chronicle | Internal + Chainlink |
| Insurance/TVL | Undisclosed | ~5% (Surplus Buffer) | N/A (full collateral) |
| Open Source | Yes | Yes | Partial |
| Bug Bounty | $16M (Sherlock) | $5M (Immunefi) | Not listed |
| TVL | ~$101M | ~$8B+ | ~$600M+ |
| Team | Doxxed (ex-politician) | Doxxed (Rune Christensen) | Doxxed (Nathan Allman) |
| Depeg History | Jan 2025 (USD0++ to $0.87) | Mar 2023 (DAI briefly $0.89) | None known |

**Peer selection rationale:** Maker (DAI/USDS) is the largest decentralized stablecoin and gold-standard benchmark. Ondo (USDY) is a direct RWA-backed stablecoin competitor with similar T-Bill backing. Both are same-chain (Ethereum) and within 5x TVL range considering Usual's historical peak.

## Recommendations

1. **For users considering USD0:** The stablecoin itself (USD0, not USD0++) maintains 1:1 backing by T-Bills and has not lost its peg. However, governance opacity means users should monitor protocol changes closely.
2. **For USD0++ holders:** Understand that USD0++ is a 4-year bond, NOT a stablecoin. It can and will trade below $1.00. The January 2025 depeg was by design (reflecting time value), not a bug.
3. **Monitor governance disclosures:** Demand transparency on multisig configuration, timelock duration, and proxy admin governance before committing significant capital.
4. **Custodial risk awareness:** While Hashnote/BNY Mellon custody provides institutional-grade security for the underlying T-Bills, Usual itself has not published its own operational security certifications.
5. **TVL trajectory is concerning:** The 94.6% decline from peak suggests the protocol may struggle to regain confidence. Monitor whether TVL stabilizes or continues declining.
6. **Bug bounty is a positive signal:** The $16M Sherlock bounty (largest in crypto) demonstrates commitment to contract-level security. This partially offsets governance opacity concerns.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- DAO decides collateral, but timelock on process UNVERIFIED
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED
- [ ] Multisig has low threshold (2/N with small N)? -- UNVERIFIED
- [x] Zero or short timelock on governance actions? -- No documented timelock
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (Ethereum)
- [x] Social engineering surface area (anon multisig signers)? -- Multisig signer identities undisclosed

**WARNING: 3+ indicators match the Drift-type pattern.** While there is no evidence of actual compromise, the governance opacity means this attack surface cannot be ruled out. The protocol's role-based access control system with undisclosed multisig configuration is a structural risk.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- No, T-Bills are highly liquid
- [x] Single oracle source without TWAP? -- Oracle provider undisclosed; likely single source for RWA pricing
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [ ] Insufficient insurance fund relative to TVL? -- No insurance fund documented

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- N/A (single chain)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [x] No key rotation policy? -- No published key management policy

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time (no snapshot)? -- UNVERIFIED
- [ ] Flash loans can be used to acquire voting power? -- UNVERIFIED
- [ ] Proposal + execution in same block or short window? -- UNVERIFIED
- [ ] No minimum holding period for voting eligibility? -- UNVERIFIED

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? -- No, T-Bill tokens only
- [ ] Read-only reentrancy risk? -- UNVERIFIED
- [ ] Flash loan compatible without reentrancy guards? -- UNVERIFIED
- [ ] Composability with protocols that expose callback hooks? -- Limited composability surface

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler? -- Standard Solidity
- [ ] Compiler version has known CVEs? -- UNVERIFIED
- [ ] Contracts compiled with different compiler versions? -- UNVERIFIED
- [ ] Code depends on language-specific behavior? -- Standard patterns

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral (own governance token)? -- No, backed by T-Bills (not USUAL)
- [ ] Redemption mechanism creates sell pressure on collateral? -- No, T-Bill redemption is orderly
- [ ] Oracle delay could mask depegging in progress? -- UNVERIFIED
- [ ] No circuit breaker on redemption volume? -- UNVERIFIED

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- N/A -- single-chain protocol with no bridge dependencies

**Trigger rule**: 3+ indicators matched in the Drift-type category. Explicit warning issued above.

## Information Gaps

The following questions could NOT be answered from publicly available information:

1. **Multisig address and configuration** -- No public disclosure of the multisig address, threshold, or signer list. Cannot verify via Safe API without an address.
2. **Timelock duration** -- No documentation or on-chain evidence of a timelock on admin actions or contract upgrades.
3. **Proxy admin governance** -- Who controls contract upgrades? Is it a multisig, EOA, or DAO vote?
4. **Oracle provider** -- Which oracle is used for RWA pricing? Is there a fallback mechanism?
5. **Insurance fund** -- Is there any insurance or reserve fund beyond the 1:1 collateral backing?
6. **Governance voting mechanics** -- Quorum requirements, voting periods, on-chain vs off-chain execution.
7. **Emergency bypass roles** -- Can any role bypass governance to make emergency changes? What are the constraints?
8. **Key management practices** -- HSM usage, key ceremonies, rotation policies.
9. **Penetration testing** -- Has infrastructure-level security testing been conducted?
10. **Hashnote/USYC oracle update frequency** -- How often is the NAV updated on-chain?
11. **USUAL token whale governance risk** -- Top holder controls 47.5% of supply (contract at 0x06b9...), second holder (likely Binance at 0xf977...) controls 28.3%. Combined, two addresses hold 75.8% of total USUAL supply.

These gaps are significant. For a protocol managing $100M+ in user funds, the lack of publicly verifiable governance infrastructure is a material risk factor. Absence of evidence is not evidence of absence -- these gaps should be treated as potential risk areas until verified.

## Disclaimer

This analysis is based on publicly available information and web research as of April 20, 2026.
It is NOT a formal smart contract audit. The GoPlus token security scan and DeFiLlama data
provide automated checks but do not replace manual code review. Always DYOR and consider
professional auditing services for investment decisions.
