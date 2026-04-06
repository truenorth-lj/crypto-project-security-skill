# DeFi Security Audit: Grove Finance

**Audit Date:** April 6, 2026
**Protocol:** Grove Finance -- Onchain Capital Allocator (Sky Ecosystem Star)

## Overview
- Protocol: Grove Finance
- Chain: Ethereum, Base, Avalanche, Plume Mainnet
- Type: Onchain Capital Allocator (RWA Credit Infrastructure)
- TVL: ~$2.87B
- TVL Trend: +16.8% / +32.7% / +77.6% (7d / 30d / 90d)
- Launch Date: June 25, 2025
- Audit Date: April 6, 2026
- Source Code: Partial (ALM controller architecture forked from open-source Spark; Grove-specific contracts not independently published on a public Grove GitHub)

## Quick Triage Score: 42/100

Scoring breakdown (start at 100, subtract mechanically):

- [-15] Zero audits listed on DeFiLlama (audits exist via ChainSecurity but not indexed)
- [-8] Protocol age < 6 months with TVL > $50M at time of rapid scaling (launched June 2025, hit $1.6B within months)
- [-5] No documented timelock on admin actions (not publicly disclosed)
- [-5] No bug bounty program (Grove-specific; parent Sky has one)
- [-5] Insurance fund / TVL undisclosed
- [-5] Undisclosed multisig signer identities (Grove-level multisig details not public)
- [-5] Single oracle provider (relies on Centrifuge/RWA pricing, not decentralized oracle network)
- [-8] Multisig threshold undisclosed (cannot confirm >= 3 signers)
- [-2] Steakhouse Financial DNS hijack incident (March 2026) -- operational security concern (not a listed flag, but contextually relevant)

**Score: 42 = HIGH risk**

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | 1-5% (Aave ~2%) | HIGH |
| Audit Coverage Score | 1.5 (2 audits < 1yr old by ChainSecurity, partial scope) | 3.0+ (Aave 9+, Morpho 3+) | MEDIUM |
| Governance Decentralization | Sky Atlas framework; Grove-level governance UNVERIFIED | DAO + multisig (peers) | HIGH |
| Timelock Duration | Undisclosed (Sky-level timelocks exist; Grove-specific unknown) | 24-48h (peers) | HIGH |
| Multisig Threshold | Undisclosed | 3/5 to 6/10 (peers) | HIGH |
| GoPlus Risk Flags | N/A (no EVM governance token) | -- | N/A |

## GoPlus Token Security

N/A -- Grove Finance does not have a live governance token on EVM chains. The protocol confirmed it is "too early to launch a governance token." No token contract to scan. GroveCoin (GRV) found on CoinMarketCap is an unrelated project.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **HIGH** | Grove-level multisig/timelock undisclosed; relies on Sky Atlas framework | Partial |
| Oracle & Price Feeds | **MEDIUM** | RWA pricing via Centrifuge/fund managers; no decentralized oracle for NAV | N |
| Economic Mechanism | **MEDIUM** | Capital deployed into illiquid RWA (CLOs); redemption mechanics unclear | N |
| Smart Contract | **MEDIUM** | ChainSecurity audits of xchain-helpers and governance relay; ALM controller architecture from Spark (well-audited) | Partial |
| Token Contract (GoPlus) | **N/A** | No governance token deployed | N/A |
| Cross-Chain & Bridge | **MEDIUM** | 4-chain deployment using CCTP v2, LayerZero V2; audited xchain-helpers | Partial |
| Operational Security | **HIGH** | Steakhouse Financial DNS hijack (March 2026); doxxed team but parent entity compromised | Y |
| **Overall Risk** | **HIGH** | **Rapid TVL growth with limited public transparency on governance controls; parent entity recently compromised; RWA illiquidity risk** | |

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

Grove operates as a "Star" (SubDAO) within the Sky ecosystem, governed under the Sky Atlas framework. Key findings:

- **Sky-level governance**: Executive proposals on vote.sky.money control Grove allocations. Sky governance uses on-chain voting with MKR/SKY tokens, executive spells, and a pause delay mechanism. Sky has "MOM" contracts for emergency response (debt ceiling breakers, liquidation circuit breakers, SparkLend freezer).
- **StarGuard mechanism**: Grove proxy spells must be whitelisted in the Grove StarGuard with specific code hashes before execution. This provides a security boundary between Sky governance and Grove operations.
- **Grove-level admin controls**: UNVERIFIED. The specific multisig configuration, signer identities, and threshold for Grove's own admin operations are not publicly documented. The ALM controller architecture (forked from Spark) defines three permission tiers: DEFAULT_ADMIN_ROLE (governance), RELAYER (rate-limited, assumed compromisable), and FREEZER (emergency stop). However, who holds these roles for Grove is not disclosed.
- **No public timelock disclosure**: While Sky governance has delay mechanisms, Grove-specific timelocks for admin actions (parameter changes, rate limit adjustments, new allocation targets) are not documented.
- **Rate limits on relayers**: The ALM controller enforces rate limits on fund movements, preventing a compromised relayer from draining funds instantly. This is a meaningful security control inherited from Spark's architecture.

**Key concern**: For a protocol managing ~$2.9B, the lack of public documentation on who holds admin keys, what the multisig threshold is, and what timelock delays exist is a significant governance transparency gap.

### 2. Oracle & Price Feeds -- MEDIUM

Grove deploys capital primarily into tokenized RWA assets (CLOs, treasuries) and DeFi lending positions (Aave, Morpho, Curve). Oracle considerations:

- **RWA pricing**: Tokenized CLO and treasury fund NAV is determined by the fund managers (Janus Henderson) and tokenization platform (Centrifuge). This is not a decentralized oracle -- it relies on the fund manager's reported NAV, updated on a schedule (not real-time).
- **DeFi position pricing**: Aave aTokens, Morpho vault shares, and Curve LP positions have on-chain pricing through their respective protocols, which use Chainlink and other oracle providers.
- **No independent price verification**: There is no documented mechanism for Grove to independently verify RWA NAV figures or dispute incorrect pricing.
- **Manipulation risk**: Low for the RWA component (institutional fund managers are regulated), but the lack of decentralized oracle verification means trust is placed in the fund manager and Centrifuge infrastructure.

### 3. Economic Mechanism -- MEDIUM

Grove's core economic model is capital allocation into diversified credit strategies:

- **Capital deployment**: USDS/USDC/DAI deposits are routed via the ALM controller into target strategies: Janus Henderson JAAA (AAA CLOs), JTRSY (treasuries), Aave lending, Morpho vaults, Curve LP, and Galaxy tokenized CLO (GALCO).
- **Liquidity risk**: CLO and treasury positions are inherently less liquid than DeFi lending positions. If depositors seek to withdraw during stress, the protocol may face redemption pressure against illiquid RWA positions. Redemption mechanics and queue priority are not publicly documented.
- **Insurance fund**: No insurance fund or bad debt protection mechanism has been disclosed. The methodology note on DeFiLlama excludes up to $50M of GALCO tokens, suggesting some buffer, but this is not a formal insurance mechanism.
- **Yield source**: Returns come from CLO coupon payments (AAA-rated CLOs historically yield 5-6%), treasury yields, and DeFi lending rates. These are relatively conservative yield sources, reducing economic manipulation risk.
- **Concentration risk**: $1B+ allocated to a single strategy (Janus Henderson JAAA) represents significant concentration. A CLO market disruption or Janus Henderson operational issue could impact a large portion of TVL.
- **No documented liquidation mechanism**: Unlike lending protocols, Grove does not have borrowers to liquidate. The risk is instead on the redemption/withdrawal side -- can depositors exit if underlying assets become illiquid?

### 4. Smart Contract Security -- MEDIUM

- **Architecture**: Grove uses an ALM (Asset Liability Management) controller architecture forked from Spark's open-source spark-alm-controller. The Spark version has been audited by three firms: ChainSecurity, Cantina, and Certora.
- **Grove-specific audits**: ChainSecurity completed two audits (both dated 2025-12-23):
  1. **Grove xchain-helpers**: Reviewed additions to Spark xchain-helpers including Arbitrum ERC-20 gas token support, Circle CCTP v2, and LayerZero V2. Assessment: "good level of security."
  2. **Grove Governance Relay**: Audit of cross-chain governance relay mechanism. Details of findings not publicly available.
  3. **Grove ALM Controller**: Listed on ChainSecurity's audit page (RWA Lending/Leverage category). Report details not publicly available.
- **Audit Coverage Score**: 1.5 (2 audits less than 1 year old = 2.0, but scope is partial -- only xchain-helpers and governance relay confirmed, not full vault/allocation logic). Conservative estimate: 1.5.
- **DeFiLlama audit listing**: Zero audits listed on DeFiLlama, which is a discoverability gap even though audits exist.
- **Open source status**: The Spark ALM controller is open source on GitHub (sparkdotfi/spark-alm-controller). Grove-specific modifications and deployment configurations are not published on a dedicated Grove GitHub repository. Grove Labs describes itself as building "open-source, non-custodial protocols" but the code is not easily discoverable.
- **Bug bounty**: No Grove-specific bug bounty program on Immunefi. The parent Sky protocol has a $10M max bug bounty on Immunefi, which may cover some Grove-related contracts, but scope is unclear.

### 5. Cross-Chain & Bridge -- MEDIUM

Grove operates across 4 chains: Ethereum (~$2.54B), Avalanche (~$257M), Plume (~$51M), and Base (~$17M).

- **Bridge infrastructure**: The ChainSecurity-audited xchain-helpers support Circle CCTP v2 (for USDC transfers) and LayerZero V2 (for cross-chain messaging). Both are established bridge protocols.
- **Governance relay**: Cross-chain governance actions are relayed via the audited Grove Gov Relay system, allowing Ethereum-based governance to control operations on other chains.
- **Single governance origin**: All governance flows from Ethereum mainnet, reducing the attack surface of independent L2 governance compromise.
- **Bridge risk**: CCTP v2 is Circle-operated (centralized but institutional-grade). LayerZero V2 uses a decentralized verification network. A bridge compromise could affect cross-chain governance messaging, though rate limits on the ALM controller would constrain immediate fund extraction.
- **Chain-specific risk**: Plume Mainnet is a relatively new chain (RWA-focused), adding a less battle-tested infrastructure dependency.

### 6. Operational Security -- HIGH

- **Team**: Doxxed founders -- Mark Phillips, Kevin Chan, Sam Paderewski -- with backgrounds at Deloitte, Citigroup, BlockTower Capital, and Hildene Capital Management. The team has facilitated over $5B in onchain capital allocations via Steakhouse Financial.
- **Steakhouse Financial DNS hijack (March 30-31, 2026)**: A social engineering attack against OVH Cloud hosting resulted in DNS hijacking of Steakhouse Financial's website and app. The attacker used Angelferno/Angel Drainer code to deploy phishing pages. Steakhouse confirmed no smart contracts or user deposits were compromised, but the incident demonstrates operational security vulnerability at the parent organization level. This is particularly concerning because Steakhouse Financial is the entity that incubated Grove and presumably manages some of its infrastructure.
- **Incident response**: Steakhouse responded by reverting DNS changes, pointing to blank records during investigation, and communicating transparently via Twitter/X. Response was within hours, which is adequate.
- **Infrastructure risk**: The DNS attack vector (social engineering the hosting provider) could theoretically be repeated against Grove's own frontend. No information is available about whether Grove has implemented additional protections (e.g., DNSSEC, multiple registrar controls, hardware security for DNS management).
- **Key dependencies**: Centrifuge (RWA tokenization), Janus Henderson (fund management), Circle (CCTP bridging), LayerZero (cross-chain messaging), Aave, Morpho, Curve (DeFi integrations). A failure in any major dependency could impact Grove operations.

## Critical Risks

1. **Governance transparency gap (HIGH)**: For a $2.9B protocol, the multisig configuration, signer identities, timelock durations, and admin key permissions are not publicly documented at the Grove level. Users must trust that Sky Atlas governance and StarGuard provide adequate protection, but cannot independently verify Grove-specific controls.

2. **Steakhouse Financial compromise (HIGH)**: The parent entity was compromised via social engineering just days ago (March 2026). While no funds were lost, this demonstrates a live operational security vulnerability in the organization responsible for building and maintaining Grove.

3. **RWA illiquidity risk (MEDIUM)**: A large portion of TVL is deployed into tokenized CLOs and treasury positions that cannot be instantly redeemed. Withdrawal mechanics during stress scenarios are not documented.

4. **Rapid TVL growth with limited track record (MEDIUM)**: Growing from $1.6B to $2.9B in ~90 days (77.6% increase) with only ~10 months of operating history. The protocol has not been tested through a major market stress event.

## Peer Comparison

| Feature | Grove Finance | Spark (Sky Star) | Aave |
|---------|-------------|-----------------|------|
| TVL | ~$2.9B | ~$4.8B | ~$23.6B |
| Timelock | Undisclosed | Sky governance delays | 24h / 168h |
| Multisig | Undisclosed | Sky governance | 6/10 Guardian |
| Audits | 2-3 (ChainSecurity, 2025) | 3+ firms (ChainSecurity, Cantina, Certora) | 6+ firms, formal verification |
| Oracle | Centrifuge NAV / fund manager | Chainlink + Chronicle | Chainlink + SVR fallback |
| Insurance/TVL | Undisclosed | Sky surplus buffer | ~2% Safety Module |
| Open Source | Partial (Spark fork public) | Yes (GitHub) | Yes (GitHub) |
| Bug Bounty | None (Grove-specific) | $10M via Sky Immunefi | $1M Immunefi |
| Governance Token | None (planned) | SPK | AAVE |

## Recommendations

1. **Demand governance transparency**: Before depositing significant capital, users should request public documentation of Grove's multisig configuration, signer identities, timelock durations, and admin key permissions. A $2.9B protocol should meet the same transparency standards as its peers.

2. **Monitor Steakhouse Financial security posture**: Given the March 2026 DNS hijack, verify that Grove's own frontend and infrastructure have been hardened against similar social engineering attacks. Prefer interacting via verified contract addresses rather than web frontends.

3. **Assess redemption risk**: Understand that a significant portion of Grove's TVL is deployed into illiquid RWA positions. In a stress scenario, redemptions may be delayed or subject to queue mechanisms. Do not deposit funds that may need to be withdrawn on short notice.

4. **Diversify across allocators**: Do not treat Grove as a single point of capital deployment. The concentration in Janus Henderson JAAA (~$1B+) and the cross-chain deployment across 4 chains introduces multiple dependency risks.

5. **Track audit publications**: ChainSecurity audits exist but reports are not widely published. Request that Grove publish full audit reports on their documentation site and register them on DeFiLlama.

6. **Establish a bug bounty**: Grove should launch its own Immunefi bug bounty program covering Grove-specific contracts, rather than relying on the parent Sky program whose scope may not explicitly cover Grove.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [?] Admin can list new collateral without timelock? -- UNKNOWN (admin permissions not public)
- [?] Admin can change oracle sources arbitrarily? -- UNKNOWN (RWA pricing is fund-manager-controlled)
- [?] Admin can modify withdrawal limits? -- UNKNOWN (rate limits exist but admin control unclear)
- [?] Multisig has low threshold (2/N with small N)? -- UNKNOWN (multisig not disclosed)
- [?] Zero or short timelock on governance actions? -- UNKNOWN (Grove-level timelock not documented)
- [ ] Pre-signed transaction risk? -- N/A (EVM-based)
- [x] Social engineering surface area -- YES (Steakhouse Financial DNS hijack demonstrates this)

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A (not a lending protocol)
- [x] Single oracle source without TWAP? -- Yes (RWA NAV from fund manager, no decentralized verification)
- [ ] No circuit breaker on price movements? -- UNKNOWN
- [x] Insufficient insurance fund relative to TVL? -- Yes (undisclosed)

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Partial (CCTP is Circle-operated; LayerZero is more decentralized)
- [?] Admin keys stored in hot wallets? -- UNKNOWN
- [?] No key rotation policy? -- UNKNOWN

**Pattern match**: The prevalence of "UNKNOWN" answers is itself a significant risk signal. Multiple Drift-type indicators cannot be ruled out due to lack of public governance documentation. The recent social engineering attack on the parent entity heightens concern about Drift-type (social engineering + governance exploitation) attack vectors.

## Information Gaps

The following questions could NOT be answered from publicly available information:

1. **Multisig configuration**: What is the multisig threshold and signer count for Grove-level admin operations? Who are the signers?
2. **Timelock duration**: What delays exist between admin action proposal and execution at the Grove level?
3. **Admin key permissions**: What specific powers do Grove admin keys have? Can they change allocation targets, modify rate limits, upgrade contracts, or pause operations unilaterally?
4. **Withdrawal mechanics**: How do depositors redeem funds? Is there a queue? What happens if underlying RWA positions cannot be liquidated quickly?
5. **Insurance/bad debt protection**: Is there any insurance fund, surplus buffer, or socialized loss mechanism for Grove depositors?
6. **Contract addresses**: Deployed contract addresses for the ALM Proxy, controllers, and rate limit modules across all 4 chains are not publicly listed in documentation.
7. **Upgrade mechanism**: Can Grove contracts be upgraded? By whom? With what delay?
8. **NAV verification**: How is the NAV of tokenized RWA positions verified on-chain? What happens if the fund manager reports an incorrect NAV?
9. **Emergency powers**: Does Grove have an emergency pause mechanism independent of Sky governance? Who can trigger it?
10. **Post-DNS-hijack remediation**: What specific security improvements were implemented after the Steakhouse Financial DNS compromise?
11. **Sky bug bounty scope**: Does the $10M Sky Immunefi bounty explicitly cover Grove-specific contracts?
12. **Rate limit parameters**: What are the actual rate limit values configured on the ALM controller? How much can a relayer move per time window?

These gaps represent unknown risks. Absence of public information at this TVL level ($2.9B) is itself a risk signal that warrants caution.

## Disclaimer

This analysis is based on publicly available information and web research as of April 6, 2026.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
