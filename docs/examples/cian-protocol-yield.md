# DeFi Security Audit: CIAN Protocol

## Overview
- Protocol: CIAN Protocol
- Chain: Multi-chain (Ethereum, Mantle, Arbitrum, Avalanche, Polygon, OP Mainnet, Base, BSC, Scroll)
- Type: Yield Automation / LST-LRT Strategy Platform
- TVL: $374.5M (Mantle: $221.3M, Ethereum: $150.4M, Arbitrum: $1.8M, others < $1M)
- TVL Trend: -5.6% / +20.1% / -32.9% (7d / 30d / 90d)
- Launch Date: 2022
- Audit Date: 2026-04-06
- Source Code: Partial (GitHub repos exist with minimal code; Yield Layer contracts not fully open-sourced)

## Quick Triage Score: 57

Red flags found: 6

| Flag | Severity | Points |
|------|----------|--------|
| Zero audits listed on DeFiLlama | HIGH | -15 |
| TVL dropped >30% in 90 days | MEDIUM | -8 |
| No documented timelock on admin actions | LOW | -5 |
| No bug bounty program | LOW | -5 |
| Undisclosed multisig signer identities | LOW | -5 |
| Insurance fund / TVL undisclosed | LOW | -5 |

Score: 100 - 15 - 8 - 5 - 5 - 5 - 5 = **57 (MEDIUM)**

Note: DeFiLlama lists zero audits despite CIAN having multiple audit reports on their docs site. This discrepancy itself is a minor transparency concern. CIAN has no governance/utility token on any EVM chain (no token address, no CoinGecko ID), so GoPlus token security checks are not applicable.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | Yearn: undisclosed, Beefy: undisclosed | HIGH |
| Audit Coverage Score | 1.75 | Yearn: ~2.0, Beefy: ~2.0 | MEDIUM |
| Governance Decentralization | Centralized (no DAO, no token) | Yearn: YFI governance, Beefy: BIFI governance | HIGH |
| Timelock Duration | UNVERIFIED (blog mentions 48h voting) | Yearn: 72h, Beefy: 48h | HIGH |
| Multisig Threshold | Undisclosed ("multi-sig" mentioned) | Yearn: 6/9, Beefy: variable | HIGH |
| GoPlus Risk Flags | N/A (no token) | -- | N/A |

### Audit Coverage Score Breakdown

| Auditor | Scope | Date | Age Weight | Score |
|---------|-------|------|------------|-------|
| Ackee Blockchain | Yield Layer (Ethereum) | Feb 2025 | 1-2 years | 0.50 |
| Omniscia | Ethereum contracts | ~2023 (est.) | >2 years | 0.25 |
| PeckShield | Avalanche contracts | ~2022 | >2 years | 0.25 |
| Paladin | Ethereum contracts | Sep 2022 | >2 years | 0.25 |
| Paladin | Avalanche contracts | Oct 2022 | >2 years | 0.25 |
| Paladin | Polygon contracts | Jan 2023 | >2 years | 0.25 |
| **Total** | | | | **1.75** |

Risk threshold: 1.5-2.99 = MEDIUM

## GoPlus Token Security

N/A -- CIAN does not have a governance or utility token on any EVM chain. Token is listed as "Coming soon" in documentation. No contract address exists for GoPlus scanning.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | HIGH | Fully centralized; no DAO, no public multisig details, no confirmed timelock | N |
| Oracle & Price Feeds | MEDIUM | Oracle provider and fallback mechanisms undisclosed; relies on underlying protocol oracles | N |
| Economic Mechanism | MEDIUM | High leverage strategies (up to 10x) with liquidation protection, but insurance fund undisclosed | Partial |
| Smart Contract | MEDIUM | 6 audits but most are >2 years old; Ackee audit flagged centralization as key risk | Y |
| Token Contract (GoPlus) | N/A | No token exists yet | N/A |
| Cross-Chain & Bridge | MEDIUM | Multi-chain deployment with bridging abstraction; bridge security details undisclosed | N |
| Operational Security | MEDIUM | Doxxed founder (Luffy He), Matrixport/Bybit partnerships, but no bug bounty or incident response plan | Partial |
| **Overall Risk** | **MEDIUM** | **Centralized yield automation platform with significant admin control over $374M TVL; strong institutional partnerships but weak transparency on governance controls** | |

## Detailed Findings

### 1. Governance & Admin Key

**Risk: HIGH**

CIAN operates as a fully centralized protocol with no decentralized governance mechanism:

- **No governance token**: Documentation lists token as "Coming soon." There is no on-chain governance, no voting, and no DAO structure.
- **Multisig claimed but unverified**: The protocol's blog and documentation reference "a sophisticated multi-signature wallet that dynamically distributes depositors' funds" and "multi-party consensus for fund allocation and parameter changes." However, the multisig threshold (m/n), signer identities, and on-chain addresses are not publicly disclosed.
- **48-hour voting period claimed**: One blog post mentions "48-hour voting periods for major changes," but this appears to reference internal team processes rather than on-chain governance. No timelock contract address has been published. UNVERIFIED.
- **Broad admin powers**: Documentation states "we reserve the right to amend, rectify, edit, or otherwise alter transaction data" and "the right to restrict your access to the Services." The team can "change or update the Services...at any time, for any reason, at our sole discretion."
- **Batched execution with manual review**: Withdrawals are processed through a batched system with manual review, meaning the team has operational control over withdrawal timing.

The Ackee Blockchain audit (Feb 2025) explicitly flagged: "centralization, making its correct functioning highly dependent on the protocol owners." Users must trust protocol operators, as "withdrawal confirmation and amounts are externally controlled."

### 2. Oracle & Price Feeds

**Risk: MEDIUM**

Oracle architecture is poorly documented:

- **No specific oracle provider disclosed**: CIAN's documentation does not name Chainlink, Pyth, or any specific oracle provider. The system references "24/7 pricing infrastructure" for RWA-related yield sources, but details are absent.
- **Dependency on underlying protocols**: Since CIAN builds strategies on top of Aave, Lido, Compound, and other lending protocols, it inherits their oracle infrastructure. Aave uses Chainlink; Lido uses beacon chain data. However, CIAN's own LTV monitoring and deleveraging decisions likely require internal price feeds, which are not documented.
- **No fallback mechanism documented**: There is no public information about oracle fallback, circuit breakers, or price manipulation resistance at the CIAN layer.
- **Depeg risk handling**: Documentation mentions "automatic reallocation to liquidity pools for price stabilization" during depeg events, but the triggering oracle mechanism is not specified.

### 3. Economic Mechanism

**Risk: MEDIUM**

CIAN's yield strategies involve significant leverage and composability risk:

- **Recursive Restaking (up to 10x leverage)**: Users deposit 1 LRT, the protocol borrows 9x ETH from lending protocols and restakes it. This creates 10x exposure to LRT yields but also 10x exposure to depeg, liquidation, and smart contract risk across multiple protocols.
- **Hybrid Long-Short Strategy**: Deposits 1 LRT as collateral, borrows ~1.35x in stablecoins, uses 80% for more LRT and 20% for a 4x short hedge. Complex multi-leg strategy with multiple failure points.
- **Liquidation protection**: CIAN implements automatic deleveraging when LTV exceeds safe thresholds. Max LTV for looping is 75-80% depending on the asset. Over-leveraged positions tolerate 10% gaps while under-leveraged tolerate 3%.
- **Insurance fund**: Not disclosed. No public information about bad debt handling, socialized loss mechanisms, or insurance fund size relative to TVL.
- **Liquidity reserves**: SLF (Stablecoin Lending Fund) maintains 20% reserves for instant withdrawals while deploying 80% for yield. This means during high-demand periods, withdrawals could be delayed.
- **Position locks**: YT (Yield Token) listings lock 100% of collateral until maturity, purchase, or cancellation. External assets carry "T+x days redemption periods."
- **No known bad debt events**: The protocol claims no exploits or liquidations in its operating history.

### 4. Smart Contract Security

**Risk: MEDIUM**

- **6 audits from 4 firms**: Ackee Blockchain, PeckShield, Omniscia, and Paladin Blockchain Security have all audited various CIAN contracts. No critical or high-severity findings in any audit.
- **Most recent audit**: Ackee Blockchain (February 2025) audited the Yield Layer. Found 3 medium issues (invalid calculations, insufficient data validation, users lack control over deposited funds), 4 low issues, 9 warnings, and 10 informational items. All findings were addressed through fixes, partial fixes, or acknowledgments.
- **Centralization warning**: The Ackee audit explicitly noted centralization as the primary risk factor. "Users have almost no control over their deposited funds" was classified as a medium-severity finding.
- **GitHub presence**: The cian-ai GitHub organization exists with repos (cian-protocol, cian-protocol-polygon, cian-flashloan-helper), but the main repo has only 2 commits and appears to contain older contract versions. The Yield Layer contracts do not appear to be fully open-sourced. Uses OpenZeppelin upgradeable proxy patterns.
- **Upgradeable contracts**: The protocol uses `@openzeppelin/contracts-upgradeable ^4.5.2`, confirming proxy-upgradeable architecture. Who controls the upgrade admin is not publicly documented.
- **No bug bounty program**: No Immunefi, HackenProof, or self-hosted bug bounty program was found.
- **No rekt.news coverage**: No exploits or security incidents found in public records.

### 5. Cross-Chain & Bridge

**Risk: MEDIUM**

CIAN operates across 9 chains with significant TVL concentration:

- **TVL distribution**: Mantle ($221M, 59%) and Ethereum ($150M, 40%) hold 99% of TVL. Other chains are negligible.
- **Bridging abstraction**: The Yield Layer includes a "Bridging Abstraction" module for cross-chain interoperability. Pools on various chains hold representations of Vault tokens that can be exchanged for deposit tokens. The specific bridge protocol(s) used are not disclosed.
- **Cross-chain admin control**: It is unclear whether each chain deployment has its own multisig or if a single key controls all chains. No documentation addresses this.
- **Mantle dependency**: The largest TVL share ($221M) sits on Mantle, which is itself a relatively newer L2. The Mantle Vault partnership with Bybit crossed $150M AUM and uses Aave as an underlying lending protocol.
- **Bridge risk**: If the bridging abstraction is compromised or the underlying bridge fails, cross-chain Vault token holders could face losses. No bridge audit or bridge-specific security documentation was found.

### 6. Operational Security

**Risk: MEDIUM**

- **Team**: Founded by Luffy He (CEO), who is publicly identified. Team reportedly includes ~30 members with 4+ years crypto experience. One notable former member, Chris Dahmen, has resigned. RootData gives the project a 55% transparency score.
- **Institutional partnerships**: Matrixport (institutional DeFi, March 2023), Bybit (Mantle Vault, December 2025), Mantle Network. These partnerships suggest some level of due diligence by institutional counterparties.
- **Funding**: No fundraising rounds are publicly disclosed. The protocol's capitalization structure is opaque.
- **Incident response**: No published incident response plan. No public security contact or responsible disclosure policy found.
- **Communication**: Active Twitter (@CIAN_protocol), Discord, Medium blog. Regular updates on partnerships and strategy launches.
- **Dependencies**: Heavy reliance on Aave, Lido, Compound, EigenLayer, and various LRT protocols (Renzo, Bedrock, etc.). A failure in any underlying protocol could cascade to CIAN vaults.

## Critical Risks

1. **Centralized admin control over $374M TVL**: The protocol team has broad, unilateral authority to modify services, alter transaction data, restrict access, and control withdrawals through batched manual review. No on-chain timelock or public multisig configuration has been verified.
2. **Users lack control over deposited funds**: The Ackee audit explicitly flagged that "withdrawal confirmation and amounts are externally controlled." This means the protocol team is a critical trust assumption for all depositors.
3. **High leverage composability risk**: Recursive restaking at up to 10x leverage across multiple protocols (Aave + Lido/LRT protocols) creates cascading failure risk. A depeg, oracle failure, or liquidation cascade in any underlying protocol could amplify losses.
4. **Undisclosed insurance/bad debt mechanism**: With $374M TVL and leverage strategies, the absence of a disclosed insurance fund or bad debt handling process is a material gap.

## Peer Comparison

| Feature | CIAN Protocol | Yearn Finance | Beefy Finance |
|---------|--------------|---------------|---------------|
| TVL | $374M | $218M | $146M |
| Timelock | UNVERIFIED (48h claimed) | 72h (verified) | 48h |
| Multisig | Undisclosed | 6/9 (doxxed) | Community multisig |
| Audits | 6 (1 recent) | Multiple (ongoing) | Multiple (ongoing) |
| Oracle | Undisclosed | Chainlink (via Aave) | Per-chain |
| Insurance/TVL | Undisclosed | Undisclosed | Undisclosed |
| Open Source | Partial | Yes (full) | Yes (full) |
| Governance Token | None (coming soon) | YFI | BIFI |
| Bug Bounty | None | Yes (Immunefi) | Yes |
| Leverage | Up to 10x | Typically 1x | Typically 1x |

CIAN has higher TVL than both peers but significantly less transparency on governance, admin controls, and code openness. Unlike Yearn and Beefy, which are fully open-source with established governance tokens and bug bounties, CIAN operates as a centralized yield platform that manages user funds with team discretion.

## Recommendations

1. **Users should understand the trust model**: CIAN is not a trustless protocol. Depositors are trusting the CIAN team with custody-like control over fund deployment and withdrawals. This is closer to a CeDeFi product than a pure DeFi protocol.
2. **Demand multisig transparency**: Before depositing large amounts, request public disclosure of multisig addresses, thresholds, and signer identities.
3. **Monitor leverage exposure**: Users in recursive restaking strategies should understand they have up to 10x exposure to depeg and liquidation risk.
4. **Diversify across vaults**: Do not concentrate all DeFi exposure in CIAN. The protocol's centralized control means a single key compromise could affect all chains.
5. **Watch for governance token launch**: The upcoming token may change the governance model. Evaluate whether it introduces meaningful decentralization or is purely a utility/reward token.
6. **Request a bug bounty program**: The absence of a bug bounty for a protocol managing $374M is below industry standard.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- UNVERIFIED, but broad admin powers suggest yes
- [x] Admin can change oracle sources arbitrarily? -- UNVERIFIED, oracle architecture undisclosed
- [x] Admin can modify withdrawal limits? -- Yes, withdrawals are manually reviewed and batched
- [ ] Multisig has low threshold (2/N with small N)? -- Unknown, multisig details undisclosed
- [x] Zero or short timelock on governance actions? -- UNVERIFIED, no on-chain timelock confirmed
- [ ] Pre-signed transaction risk? -- N/A (EVM, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- Yes, multisig signers not identified

**Drift pattern match: 5/7 flags triggered or unverifiable. ELEVATED RISK.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- Strategies focus on major LSTs/LRTs (stETH, mETH, etc.)
- [x] Single oracle source without TWAP? -- UNVERIFIED, oracle architecture not documented
- [x] No circuit breaker on price movements? -- UNVERIFIED
- [x] Insufficient insurance fund relative to TVL? -- Yes, insurance fund undisclosed

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- UNVERIFIED, bridging abstraction details not public
- [x] Admin keys stored in hot wallets? -- Unknown
- [x] No key rotation policy? -- No policy documented

## Information Gaps

The following questions could NOT be answered from publicly available information. Each gap represents an unknown risk:

1. **Multisig configuration**: What is the threshold (m/n)? How many signers? Who are they? What are the on-chain addresses?
2. **Timelock details**: Is there an on-chain timelock contract? What is the delay? What actions does it cover? Can it be bypassed?
3. **Upgrade admin**: Who controls the proxy upgrade admin on each chain? Is it the same entity across all 9 chains?
4. **Oracle provider**: What oracle(s) does CIAN use for its own LTV monitoring and deleveraging decisions?
5. **Insurance fund**: Does one exist? What is its size? How is bad debt handled?
6. **Bridging mechanism**: What bridge protocol(s) does the Bridging Abstraction module use? Has it been audited?
7. **Funding sources**: How is the protocol capitalized? No public funding rounds disclosed.
8. **Code openness**: Are the Yield Layer smart contracts fully open-source? The GitHub repos appear incomplete.
9. **Emergency procedures**: What is the incident response plan? Who can pause the protocol?
10. **Key management**: How are admin keys stored? Is there a key rotation policy?
11. **Strategy risk parameters**: Who sets and can change LTV limits, leverage caps, and deleveraging thresholds?
12. **Cross-chain governance**: How are admin actions coordinated across 9 chains?

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
