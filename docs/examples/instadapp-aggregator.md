# DeFi Security Audit: Instadapp / Fluid

**Audit Date:** April 6, 2026
**Protocol:** Instadapp (rebranded to Fluid, December 2024) -- Multi-chain DeFi Aggregator / Lending / DEX

## Overview
- Protocol: Fluid (formerly Instadapp)
- Chain: Ethereum (primary), Arbitrum, Base, Polygon, Plasma
- Type: DeFi Smart Accounts / Lending / DEX / Yield Aggregator
- TVL: ~$916M combined (~$731M Fluid Lending + ~$185M Fluid Lite)
- TVL Trend: -0.6% / -29.1% / -53.8% (7d / 30d / 90d)
- Launch Date: 2019 (Instadapp); 2024 (Fluid Lending); December 2024 (Fluid rebrand)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: Instadapp/fluid-contracts-public)

## Quick Triage Score: 67/100

Starting at 100, deductions:

- [-8] GoPlus: is_proxy = 1 -- upgradeable proxy pattern; timelock exists but governance-controlled (cross-referenced with Step 2)
- [-5] No documented timelock on admin actions for Guardian emergency role (Guardian can pause without timelock)
- [-5] Undisclosed multisig signer identities (community multisig signers not publicly named)
- [-5] Insurance fund / TVL undisclosed (no explicit insurance fund documented)
- [-5] Single oracle provider concern (Chainlink + Uniswap TWAP mitigates, but admin can change oracle sources -- UNVERIFIED)
- [-5] DAO governance partially centralized (team retains significant influence during foundation transition)

Score: 67 = **MEDIUM risk**

Red flags found: 6 (all LOW-to-MEDIUM severity; no CRITICAL flags)

## Quantitative Metrics

| Metric | Value | Benchmark (Aave / Compound) | Rating |
|--------|-------|-----------------------------|--------|
| Insurance Fund / TVL | Undisclosed | 1-5% (Aave ~2%) | HIGH |
| Audit Coverage Score | 3.5 (est.) | 9+ (Aave) / 3+ (Compound) | LOW risk |
| Governance Decentralization | DAO + Guardian + Team multisig | DAO + Guardian (Aave) | MEDIUM |
| Timelock Duration | 48h (governance); 10d (legacy DSA) | 24-168h (Aave) | LOW risk |
| Multisig Threshold | UNVERIFIED (community multisig) | 6/10 (Aave Guardian) | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 1 MED (proxy) | 0 HIGH / 1 MED (Aave) | LOW risk |

### Audit Coverage Score Calculation

| Audit | Firm | Date | Age Score |
|-------|------|------|-----------|
| Fluid Liquidity Layer | Statemind | Dec 2023 | 0.25 (>2yr) |
| Fluid Vault Protocol | MixBytes | Jun 2024 | 0.5 (1-2yr) |
| Fluid DEX (Cantina competition) | Cantina | Sep-Oct 2024 | 0.5 (1-2yr) |
| Fluid DEX audit | MixBytes | Dec 2024 | 1.0 (<1yr) |
| OpenZeppelin (legacy DSA) | OpenZeppelin | 2019 | 0.25 (>2yr) |
| Cantina DEX report published | Cantina | Jan 2025 | 1.0 (<1yr) |

**Estimated Audit Coverage Score: ~3.5 = LOW risk**

## GoPlus Token Security (FLUID on Ethereum: 0x6f40d4A6237C257fff2dB00FA0510DeEECd303eb)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | Yes (upgradeable) | MEDIUM |
| Mintable | Not flagged | -- |
| Owner Can Change Balance | Not flagged | -- |
| Hidden Owner | Not flagged | -- |
| Selfdestruct | Not flagged | -- |
| Transfer Pausable | Not flagged | -- |
| Blacklist | Not flagged | -- |
| Slippage Modifiable | Not flagged | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 11,098 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No | -- |

GoPlus assessment: **LOW RISK**. The only flag is the proxy (upgradeable) pattern, which is standard for governance-upgradeable tokens. Owner address is empty (renounced or governance-controlled). No honeypot indicators, no hidden owner, no tax, no trading restrictions. Note: Several fields (is_mintable, hidden_owner, selfdestruct, etc.) were not present in the GoPlus response, which typically indicates they are not flagged.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | Guardian can pause without timelock; multisig signer identities undisclosed | Partial |
| Oracle & Price Feeds | **LOW** | Dual-source (Chainlink + Uniswap TWAP); Redstone OEV integration | Partial |
| Economic Mechanism | **MEDIUM** | No explicit insurance fund; innovative liquidation model is newer/less battle-tested | Partial |
| Smart Contract | **LOW** | 6+ audits, 7 years zero exploits, open source, $500K bounty | Y |
| Token Contract (GoPlus) | **LOW** | Proxy only (governance-controlled); no honeypot, no hidden owner, no tax | Y |
| Cross-Chain & Bridge | **MEDIUM** | Multi-chain via Chainlink CCIP; per-chain admin config unclear | Partial |
| Operational Security | **LOW** | Doxxed founders, 7-year track record, active Immunefi bounty | Y |
| **Overall Risk** | **MEDIUM** | **Strong track record and audits offset by governance opacity and missing insurance fund** | |

## Detailed Findings

### 1. Governance & Admin Key

**Admin Key Surface Area:**
- Fluid's core Liquidity Layer is controlled through an AdminModule (adminModule/main.sol) that manages user classification, rate configurations, protocol whitelisting, and risk parameter changes.
- The AdminModule can add/remove protocols from the Liquidity Layer, change rate curves, set LTV ratios, and configure operational limits.
- A "Guardian" role exists as a security backstop that can pause subprotocol access to the Liquidity Layer in emergencies. At launch, all subprotocols are Class 0 (guardian-pausable). Over time, governance can upgrade them to Class 1 (guardian cannot pause).
- The Guardian pause does NOT require a timelock, which is standard for emergency functions but expands the trust surface.

**Governance Process:**
- Uses Compound Bravo-style governance (deployed at 0x0204Cd037B2ec03605CFdFe482D8e257C765fA1B).
- Proposal threshold: 1% of FLUID supply (1M tokens).
- Quorum: 4% of FLUID supply.
- Voting period: ~3 days.
- Timelock delay: 2 days (48 hours) after vote passes before execution.
- Legacy Instadapp DSA system had a 10-day timelock (IGP #1 transferred admin from team timelock to governance timelock).

**Multisig:**
- A "community multisig" exists that can pause protocols in emergencies.
- Specific multisig address, threshold (m/n), and signer identities are NOT publicly documented. This is a significant transparency gap.
- On Solana (Jupiter Lend partnership), a 12-hour timelock multisig is jointly controlled by Jupiter and Fluid team signers.

**Token Concentration:**
- Top holder (contract): 22.05M FLUID (22.05%) -- likely treasury/staking contract.
- Top 5 holders (all contracts): ~44.6M FLUID (~44.6%).
- All top 10 holders are smart contracts (treasuries, staking, vesting), not EOAs -- this reduces whale governance attack risk but means governance power depends on who controls those contracts.

**Foundation Transition (2026):**
- A February 2026 governance proposal seeks to transfer all IP (smart contracts, front-ends, trademarks) to a non-profit Cayman Islands foundation.
- FLUID token holders would retain ultimate governance control.
- Legal work expected to complete by mid-2026 -- this is still in transition. UNVERIFIED whether foundation structure is finalized.

**Rating: MEDIUM** -- Governance structure follows established patterns (Bravo, timelock, multisig), but the lack of transparency around multisig composition and guardian signer identities is a concern. The 48-hour timelock is adequate but below best-in-class (Aave: 24h short / 168h long dual timelock).

### 2. Oracle & Price Feeds

**Oracle Architecture:**
- Dual-source: Chainlink price feeds + Uniswap V3 TWAP checkpoints.
- Cross-verification between sources reduces single-point-of-failure risk.
- Center price is calculated from both sources, preventing manipulation through one feed alone.

**Redstone OEV Integration:**
- Collaborated with Redstone to build a gas-optimized oracle flow.
- Implements Oracle Extractable Value (OEV) capture -- redirecting MEV from liquidations back to the protocol instead of searchers/bots.

**Manipulation Resistance:**
- TWAP comparison with old checkpoints prevents sudden price manipulation.
- An attacker cannot manipulate the price due to comparisons with old TWAPs (confirmed in Cantina audit).
- However, a Cantina finding noted that an attacker could DOS the oracle by changing tick values in every block by a minimal delta -- this is a liveness risk, not a fund-theft risk.

**Admin Oracle Control:**
- Whether admin can arbitrarily change oracle sources is UNVERIFIED from public documentation. The AdminModule handles configurations, which likely includes oracle parameters.

**Rating: LOW** -- Dual-source oracle with TWAP cross-verification is robust. The Oracle DOS vector was identified and presumably mitigated. Integration with Redstone OEV is innovative.

### 3. Economic Mechanism

**Liquidation Mechanism:**
- Innovative tick-based liquidation: positions are grouped by risk into "ticks" and liquidated in aggregate, enabling batch processing.
- Liquidation penalty as low as 0.1% (vs. 5-10% industry standard), making it significantly cheaper for borrowers.
- Performance improvements claimed at up to 100x over traditional systems.
- Bad debt is made available in liquidity pools at discounted prices, incentivizing traders to clear it through market mechanisms.

**Insurance Fund:**
- No explicit insurance fund is documented in public materials.
- Revenue is directed toward FLUID buybacks (100% of Ethereum mainnet revenue as of October 2025, ~$1.3-1.5M/month).
- Treasury retained 43% of its assets through conservative management.
- The absence of a dedicated insurance fund is a gap compared to Aave (Safety Module ~2% of TVL) and Compound.

**Rate Limits & Circuit Breakers:**
- Automated limits dynamically adjust debt/collateral ceilings every block.
- Withdrawal limits: base withdrawal is unrestricted; beyond the base, capacity increases by a percentage (e.g., 20% over 24 hours).
- This limits sudden large withdrawals, protecting against bank-run scenarios and hack-related drains.

**Revenue:**
- Protocol revenue hit $1.52M in August 2025.
- ~$12M annualized revenue on Ethereum.

**Rating: MEDIUM** -- Innovative liquidation mechanism with lower penalties is user-friendly, but the low liquidation penalty could lead to more bad debt in extreme market conditions. The absence of a dedicated insurance fund is a notable gap. Rate limiting mechanisms are well-designed.

### 4. Smart Contract Security

**Audit History:**
- 6+ professional audits across different components:
  - Statemind: Fluid Liquidity Layer (December 2023)
  - MixBytes: Fluid Vault Protocol (June 2024) -- "no dangerous vulnerabilities"
  - Cantina: Fluid DEX competitive audit (Sep-Oct 2024) -- 13 issues identified
  - MixBytes: Fluid DEX (December 2024)
  - Cantina: DEX report published (January 2025)
  - OpenZeppelin: Legacy DSA contracts (2019)
- The Cantina competition identified 13 issues including a division-by-zero bug in _getPricesAndExchangePrices and an oracle DOS vector.
- All audits are publicly available at docs.fluid.instadapp.io/audits-and-security.html.

**Bug Bounty:**
- Active Immunefi program covering Fluid Liquidity Layer, Lending, and Vault protocols.
- Maximum payout: $500,000 (10% of affected funds, capped).
- Scope: Fluid contracts excluding periphery folder.
- Payouts in stablecoins (USDC, USDT, DAI).

**Battle Testing:**
- 7 years operational (since 2019 as Instadapp).
- Zero dollars lost to smart contract vulnerabilities in entire history.
- No security incidents or exploits on record.
- Open source: all core contracts publicly available on GitHub.
- Code is highly gas-optimized, which auditors noted sacrifices some code clarity.

**Rating: LOW** -- Extensive audit coverage from reputable firms, active bug bounty, open source code, and a 7-year unblemished security track record. The gas-optimized code complexity is offset by thorough audit coverage.

### 5. Cross-Chain & Bridge

**Multi-Chain Deployment:**
- Deployed on Ethereum (primary), Arbitrum, Base, Polygon, and Plasma.
- Fluid DEX on Ethereum, Arbitrum, and Polygon.
- Expanding to Solana via Jupiter partnership (Jupiter Lend).

**Bridge Infrastructure:**
- Cross-chain coordination uses Chainlink CCIP (Cross-Chain Interoperability Protocol).
- CCIP is a well-audited message-passing protocol, reducing bridge-specific risk compared to less established bridges.

**Per-Chain Admin Configuration:**
- Whether each chain has independent admin multisig and risk parameters is UNVERIFIED.
- On Solana, governance uses a 12-hour timelock multisig jointly controlled by Jupiter and Fluid team signers.
- Liquidity support for new chains includes 0.5% of FLUID supply for local DEX markets.

**Key Risk:**
- A compromised CCIP bridge message could theoretically forge governance actions on remote chains. However, CCIP is one of the more robust cross-chain messaging solutions available.
- Each chain deployment may have different security profiles -- Ethereum is likely the most battle-tested.

**Rating: MEDIUM** -- Use of Chainlink CCIP is a strong choice for cross-chain messaging. However, per-chain governance configuration is not transparently documented, and the rapid multi-chain expansion (5+ chains) increases attack surface.

### 6. Operational Security

**Team & Track Record:**
- Founded by Sowmay Jain and Samyak Jain (brothers from Rajasthan, India) -- fully doxxed.
- Samyak Jain: Forbes 30 under 30 India.
- Started at ETHIndia hackathon (August 2018), won the competition.
- Raised $12.4M from Pantera Capital and Naval Ravikant.
- 7-year operational history with zero security incidents.

**Incident Response:**
- Guardian role can pause subprotocols immediately without timelock.
- Liquidity Layer automatically restricts abnormally large borrowings and withdrawals.
- Rate-limiting buys time for community multisig to intervene.
- No publicly documented formal incident response plan (common in DeFi, but a gap compared to institutional-grade protocols).

**Dependencies:**
- Chainlink (oracles + CCIP bridge).
- Uniswap (TWAP oracle data).
- Redstone (OEV oracle optimization).
- Various integrated protocols (Aave, Compound, MakerDAO, Curve) via DSA connectors.
- Composability risk: if an integrated protocol (e.g., Aave) is exploited, DSA users with positions in that protocol would be affected. However, Fluid's Liquidity Layer isolates its own lending/vault from DSA integration risks.

**Rating: LOW** -- Doxxed founding team with strong track record, well-known investors, active community governance, and proven incident mitigation mechanisms (rate limiting, guardian pause).

## Critical Risks

1. **No explicit insurance fund** -- If a black swan event generates bad debt exceeding what liquidation incentives can clear, there is no documented backstop fund. Revenue buybacks go to treasury, not an insurance pool. (HIGH concern)
2. **Undisclosed multisig composition** -- The community multisig signer identities and threshold are not publicly documented. This creates trust assumptions around who can pause the protocol in emergencies. (MEDIUM concern)
3. **TVL declining sharply** -- 53.8% TVL decline over 90 days (from ~$1.58B to ~$731M in Fluid Lending alone) may indicate capital flight or market conditions reducing protocol stability. (MEDIUM concern, needs context -- broader market conditions may explain this)
4. **Foundation transition in progress** -- The Cayman Islands foundation structure is not yet finalized (expected mid-2026). During transition, governance authority may be ambiguous. (LOW-MEDIUM concern)

## Peer Comparison

| Feature | Fluid | Aave | Compound |
|---------|-------|------|----------|
| Timelock | 48h (governance) | 24h / 168h (dual) | 48h |
| Multisig | UNVERIFIED (community) | 6/10 (Guardian) | 4/6 |
| Audits | 6+ (Statemind, MixBytes, Cantina, OZ) | 6+ (Trail of Bits, Certora, Sigma Prime, etc.) | 5+ (Trail of Bits, OpenZeppelin) |
| Oracle | Chainlink + Uniswap TWAP | Chainlink + SVR fallback | Chainlink |
| Insurance/TVL | Undisclosed | ~2% (Safety Module) | ~1% (Reserves) |
| Open Source | Yes | Yes | Yes |
| Bug Bounty Max | $500K | $1M | $150K |
| Zero-Exploit Track Record | 7 years | 6+ years (V3 no exploits) | 6+ years |
| Liquidation Penalty | 0.1% (min) | 5-10% | 5-8% |

## Recommendations

- **For depositors/lenders**: Fluid Lending offers competitive yields and has a strong security track record. The lack of insurance fund is the primary risk -- consider diversifying across multiple lending protocols (Aave, Compound) to reduce single-protocol exposure.
- **For borrowers**: Fluid's 0.1% minimum liquidation penalty and high LTV (up to 95%) are industry-leading, but users should maintain conservative positions given the absence of a safety module backstop.
- **For governance participants**: Push for public disclosure of community multisig signer identities and threshold. Advocate for establishing a dedicated insurance fund or safety module.
- **For all users**: Monitor the foundation transition (expected mid-2026) for any changes to governance authority. Prefer Ethereum mainnet deployment as the most battle-tested chain.
- **Monitor TVL trends**: The 53.8% 90-day TVL decline warrants watching. If TVL continues declining, protocol revenue and liquidator incentives may weaken.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- UNVERIFIED; AdminModule handles configs
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED; likely requires governance
- [ ] Admin can modify withdrawal limits? -- Yes, via AdminModule, but rate-limited by design
- [x] Multisig has low threshold (2/N with small N)? -- UNVERIFIED; threshold not publicly disclosed
- [ ] Zero or short timelock on governance actions? -- No; 48h timelock on governance proposals
- [ ] Pre-signed transaction risk? -- N/A (EVM-based)
- [x] Social engineering surface area (anon multisig signers)? -- Yes; multisig signer identities undisclosed

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- UNVERIFIED; asset listing process not fully documented
- [ ] Single oracle source without TWAP? -- No; dual-source (Chainlink + TWAP)
- [ ] No circuit breaker on price movements? -- No; automated limits adjust every block
- [x] Insufficient insurance fund relative to TVL? -- Yes; no explicit insurance fund documented

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No; uses Chainlink CCIP (decentralized)
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

**Pattern match result**: 3 flags triggered (undisclosed multisig threshold, anon multisig signers, no insurance fund). None are CRITICAL individually but collectively indicate governance transparency gaps. No Drift-type or Ronin-type systemic risks detected.

## Information Gaps

The following questions could NOT be answered from publicly available information:

1. **Community multisig details**: What is the multisig address, threshold (m/n), and who are the signers? This is the single largest transparency gap.
2. **Insurance fund / safety module**: Is there any backstop mechanism for bad debt beyond liquidation market incentives and treasury buybacks?
3. **Per-chain admin configuration**: Does each chain deployment (Arbitrum, Base, Polygon) have an independent admin multisig and independently configured risk parameters?
4. **Guardian role specifics**: Who holds the Guardian role? Is it the same as the community multisig? Can the Guardian do anything beyond pausing (e.g., upgrade contracts)?
5. **Oracle admin controls**: Can the AdminModule change oracle sources without a governance vote and timelock?
6. **Asset listing process**: What is the governance process for listing new collateral types? Is there a liquidity depth requirement?
7. **Admin key storage**: Are admin keys stored in cold wallets? Is there a key rotation policy?
8. **Formal incident response plan**: Is there a published incident response plan with defined roles and communication channels?
9. **Foundation transition governance**: During the Cayman Islands foundation setup (expected mid-2026), who has interim governance authority if disputes arise?
10. **Class 0 vs Class 1 subprotocol status**: Which subprotocols have been upgraded to Class 1 (guardian cannot pause)? Are any still Class 0?

## Disclaimer

This analysis is based on publicly available information and web research as of April 6, 2026.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
