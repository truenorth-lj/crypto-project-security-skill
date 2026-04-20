# DeFi Security Audit: Spiko

## Overview
- Protocol: Spiko
- Chain: Ethereum, Arbitrum, Polygon, Base, Stellar, Starknet, Etherlink (7 chains)
- Type: RWA (Tokenized Money Market Funds)
- TVL: $1.233B
- TVL Trend: +6.15% (7d) / +0.35% (30d) / +48.1% (90d)
- Launch Date: August 2024 (DeFiLlama listing: Aug 13, 2024)
- Audit Date: 2026-04-20
- Valid Until: 2026-07-19 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Open (GitHub: spiko-tech/contracts, verified on Etherscan)

## Quick Triage Score: 41/100 | Data Confidence: 55/100

- Red flags found: 10 (3 MEDIUM, 7 LOW -- see breakdown below)
- Data points verified: 5 / 15

### Triage Score Breakdown

Start at 100. Subtract mechanically per flag.

**CRITICAL flags (-25 each): NONE**
- [x] GoPlus: is_honeypot -- not returned (incomplete scan)
- [x] GoPlus: honeypot_with_same_creator = 0 (CLEAR)
- [x] GoPlus: hidden_owner -- not returned (incomplete scan)
- [x] GoPlus: owner_change_balance -- not returned (incomplete scan)
- [x] TVL = $1.233B (not zero)
- [x] No malicious address flags found

**HIGH flags (-15 each): NONE**
- [x] GoPlus: is_open_source = 1 (CLEAR)
- [x] DeFiLlama audits = 2 (Trail of Bits + Halborn)
- [x] Team is doxxed with strong track record
- [x] GoPlus: selfdestruct -- not returned
- [x] GoPlus: can_take_back_ownership -- not returned
- [x] Super-admin described as multisig (not single EOA) -- UNVERIFIED on-chain

**MEDIUM flags (-8 each): 3 flags = -24**
- [x] GoPlus: is_proxy = 1 AND no verified timelock on upgrades (-8)
- [x] Transfer pausable: exceptional-operator role can pause/unpause (-8) -- confirmed via tech blog
- [x] No third-party security certification (SOC 2 / ISO 27001) for off-chain operations (-8)

**LOW flags (-5 each): 7 flags = -35**
- [x] No documented timelock on admin actions (-5)
- [x] No bug bounty program (-5)
- [x] Single oracle provider: Chainlink only (-5)
- [x] Allowlist-only model = effective blacklisting for non-KYC addresses (-5)
- [x] Undisclosed multisig signer identities (-5)
- [x] No published key management policy -- Dfns MPC custody mentioned but no formal policy (-5)
- [x] No disclosed penetration testing (infrastructure-level) (-5)

**Total: 100 - 24 - 35 = 41/100 (HIGH risk)**

> Note: The HIGH-risk triage score is driven primarily by information gaps (7 LOW flags) and unverified governance controls (MEDIUM flags), not by detected exploits or critical vulnerabilities. Spiko is an EU-regulated, AMF-licensed investment firm with institutional partners (Amundi, CACEIS, Chainlink). The gap between regulatory credibility and on-chain verifiability is the core risk signal.

### Data Confidence Breakdown

Start at 0. Add points for each verified data point.

- [x] +15 Source code is open and verified on block explorer
- [x] +15 GoPlus token scan completed (partial -- many fields not returned, but scan executed)
- [x] +10 At least 1 audit report publicly available (Trail of Bits Oct 2023, Halborn Sep 2025)
- [ ] +10 Multisig configuration verified on-chain -- NOT VERIFIED
- [ ] +10 Timelock duration verified on-chain or in docs -- NOT VERIFIED
- [x] +10 Team identities publicly known (doxxed)
- [ ] +10 Insurance fund size publicly disclosed -- N/A (RWA fund backed by sovereign debt, not DeFi insurance model)
- [ ] +5 Bug bounty program details publicly listed -- NOT FOUND
- [ ] +5 Governance process documented -- centralized company, no DAO governance
- [x] +5 Oracle provider(s) confirmed (Chainlink SmartData + CCIP)
- [ ] +5 Incident response plan published -- NOT FOUND
- [ ] +5 SOC 2 Type II or ISO 27001 certification verified -- NOT FOUND
- [ ] +5 Published key management policy -- partial (Dfns MPC mentioned, no formal policy)
- [ ] +5 Regular penetration testing disclosed -- NOT FOUND
- [ ] +5 Bridge DVN/verifier configuration publicly documented -- Chainlink CCIP used, config not publicly documented

**Total: 55/100 (MEDIUM confidence)**

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | N/A (regulated fund, assets in sovereign debt) | N/A for RWA category | N/A |
| Audit Coverage Score | 1.25 (1.0 for Halborn 2025 + 0.25 for ToB 2023) | Ondo: ~1.5, BUIDL: 0 | MEDIUM |
| Governance Decentralization | LOW (centralized company, no DAO) | Ondo: token governance; BUIDL: centralized | LOW |
| Timelock Duration | UNVERIFIED (no timelock contract documented) | Ondo: N/A; BUIDL: N/A | HIGH |
| Multisig Threshold | UNVERIFIED (claimed multisig, config not public) | Ondo: UNVERIFIED; BUIDL: UNVERIFIED | HIGH |
| GoPlus Risk Flags | 0 HIGH / 1 MED (proxy) | -- | LOW |

### TVL Trend
- 7d: +6.15% (healthy growth)
- 30d: +0.35% (stable)
- 90d: +48.1% (strong growth from ~$833M to $1.233B)
- No TVL drops detected. Growth trajectory is consistently upward since launch.

### Chain Distribution
| Chain | TVL | % of Total |
|-------|-----|------------|
| Stellar | $556M | 45.1% |
| Arbitrum | $417M | 33.8% |
| Polygon | $123M | 10.0% |
| Ethereum | $71M | 5.7% |
| Starknet | $34M | 2.8% |
| Base | $23M | 1.8% |
| Etherlink | $10M | 0.8% |

## GoPlus Token Security (USTBL on Ethereum)

Token: 0xe4880249745eac5f1ed9d8f7df844792d560e750

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | NOT RETURNED | UNKNOWN |
| Open Source | 1 (verified) | LOW |
| Proxy | 1 (UUPS upgradeable) | MEDIUM |
| Mintable | NOT RETURNED | UNKNOWN |
| Owner Can Change Balance | NOT RETURNED | UNKNOWN |
| Hidden Owner | NOT RETURNED | UNKNOWN |
| Selfdestruct | NOT RETURNED | UNKNOWN |
| Transfer Pausable | NOT RETURNED (confirmed via docs) | MEDIUM |
| Blacklist | NOT RETURNED (allowlist model per docs) | LOW |
| Slippage Modifiable | NOT RETURNED | UNKNOWN |
| Buy Tax / Sell Tax | N/A (not traded on DEX) | N/A |
| Holders | 23 (USTBL), 25 (EUTBL) | N/A |
| Trust List | NOT RETURNED | UNKNOWN |
| Creator Honeypot History | 0 (CLEAR) | LOW |

> GoPlus returned incomplete data for this token. Many standard fields were not present in the API response. This is likely because USTBL/EUTBL are not DEX-traded tokens -- they are permissioned, allowlisted fund shares. GoPlus analysis is designed for freely tradeable tokens and has limited applicability to permissioned RWA tokens.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | MEDIUM | Multisig claimed but threshold/signers unverified; no timelock documented; UUPS upgrade power in super-admin | S/O | Partial |
| Oracle & Price Feeds | LOW | Chainlink SmartData for NAV; single provider but institutional-grade | S | Y |
| Economic Mechanism | LOW | Sovereign debt backing; regulated UCITS fund; no algorithmic risk | S | Y |
| Smart Contract | MEDIUM | 2 audits but ToB audit is 2.5 years old; UUPS proxy upgradeable; code may have changed since | S | Partial |
| Token Contract (GoPlus) | LOW | Open source, no honeypot history; GoPlus scan incomplete for permissioned token | S | Partial |
| Cross-Chain & Bridge | MEDIUM | 7 chains via Chainlink CCIP; bridge config not publicly documented; single bridge provider | S | Partial |
| Off-Chain Security | MEDIUM | No SOC 2/ISO 27001; Dfns MPC custody but no published key management policy; no disclosed pentest | O | N |
| Operational Security | LOW | Doxxed team, AMF-regulated, Amundi/CACEIS partnerships; strong institutional credibility | O | Y |
| **Overall Risk** | **MEDIUM** | **Strong regulatory foundation but significant on-chain governance opacity -- multisig config, timelock, and upgrade controls are unverified** | | |

**Overall Risk aggregation**:
1. No CRITICAL categories.
2. No HIGH categories.
3. 4 MEDIUM categories (Governance & Admin counts as 2x = effectively 5 MEDIUM). 3+ MEDIUM = Overall MEDIUM.

## Detailed Findings

### 1. Governance & Admin Key

**Architecture**: Spiko uses a Permission Manager contract with 7 distinct permission groups:

| Group | Capabilities |
|-------|-------------|
| Super-admin | Full upgrade control (UUPS), manage all permissions |
| Exceptional-operator | Emergency pause/unpause of token contracts |
| Daily-operator | Internal relayer for minting and redemptions |
| Oracle-operator | Internal relayer for daily NAV value publishing |
| Burner | Token burning (redemption contract only) |
| Allowlister | KYC-verified investor onboarding |
| Allowlisted | Verified investor addresses permitted to hold tokens |

**Multisig**: The super-admin is described as a "multisig wallet" in Spiko's tech blog, but no specific configuration (threshold, number of signers, signer identities) is publicly disclosed. No Gnosis Safe address has been identified for on-chain verification.

**Timelock**: No timelock contract is documented in Spiko's public materials, GitHub repository, or tech blog. The super-admin appears to have immediate upgrade authority via UUPS proxy pattern.

**Upgrade Mechanism**: Contracts use OpenZeppelin UUPS (Universal Upgradeable Proxy Standard). The super-admin group controls upgrades. No documented delay or community notification requirement before upgrades take effect.

**Risk**: The combination of UUPS proxy + unverified multisig + no timelock means the super-admin could theoretically upgrade contract logic immediately. For a $1.2B protocol, this is a meaningful governance risk, partially mitigated by the regulatory environment (AMF oversight) and institutional partnerships.

**Rating: MEDIUM** -- Multisig is claimed but unverified; no timelock documented; UUPS upgrade power is concentrated. Regulatory oversight provides off-chain mitigation that cannot be verified on-chain.

### 2. Oracle & Price Feeds

**Architecture**: Spiko's Oracle contract implements Chainlink's AggregatorV3Interface standard. Daily Net Asset Values (NAV) are calculated by CACEIS Fund Administration (official fund administrator) and published on-chain by the oracle-operator role.

**Data Flow**: CACEIS calculates NAV -> Chainlink SmartData delivers on-chain -> Oracle contract stores value -> Token pricing reflects NAV.

**Provider**: Chainlink is the sole oracle provider. This is a single point of dependency, but Chainlink is the most battle-tested oracle in DeFi.

**Manipulation Resistance**: NAV is calculated off-chain by a regulated fund administrator (CACEIS) based on actual sovereign debt holdings. This is fundamentally different from DEX-based price feeds and is highly resistant to on-chain manipulation. The risk vector would be CACEIS/Chainlink infrastructure compromise, not market manipulation.

**Admin Override**: The oracle-operator role can publish NAV values. Whether the super-admin can change the oracle source is not documented.

**Rating: LOW** -- Chainlink SmartData with CACEIS as data source is institutional-grade. Single provider risk is offset by the off-chain nature of NAV calculation.

### 3. Economic Mechanism

**Fund Structure**: USTBL and EUTBL are tokenized shares in UCITS-compliant money market funds regulated by the AMF. Assets are invested in:
- US Treasury Bills (USTBL)
- Eurozone Treasury Bills (EUTBL)
- SAFO: Fully collateralized total return swaps with BNP Paribas

**Depositary**: CACEIS acts as depositary bank and fund administrator. Amundi is delegated investment manager for SAFO.

**Redemption**: Token holders redeem via `transferAndCall` to the Redemption Contract, which processes daily batches and burns tokens. Redemptions are settled in fiat or stablecoin.

**Liquidation Risk**: Not applicable -- this is not a lending protocol. There is no leverage, no collateralization ratio, and no liquidation mechanism. The fund holds sovereign debt directly.

**Bad Debt Risk**: Minimal -- underlying assets are US and EU government securities. Risk is limited to sovereign default (extremely low probability for US/EU) or operational failure (custodian compromise, smart contract exploit).

**Insurance**: No DeFi-style insurance fund exists. Protection comes from the regulated fund structure: UCITS regulatory framework, CACEIS as depositary (BNP Paribas group), AMF oversight, and investor protection regulations.

**Rating: LOW** -- Sovereign debt backing with regulated UCITS structure eliminates most DeFi-specific economic risks (liquidation cascades, oracle manipulation, reflexive collateral).

### 4. Smart Contract Security

**Audit History**:

| Auditor | Date | Scope | Age | Score |
|---------|------|-------|-----|-------|
| Trail of Bits | October 2023 | EVM contracts (Solidity) | 2.5 years | 0.25 |
| Halborn | September 2025 | Stellar contracts (Soroban) | 7 months | 1.0 |

**Audit Coverage Score**: 1.25 (MEDIUM -- below 1.5 threshold)

**Findings**: 
- Trail of Bits (2023): Report available at `github.com/trailofbits/publications`. Specific finding count not extractable from PDF metadata.
- Halborn (2025): Identified improvements around redemption execution logic (burns from Redemption contract vs user account), admin role renouncement (preventing irrecoverable admin loss), and idempotency/event emission. All findings were addressed by the Spiko team.

**Code Status**: Open source on GitHub (spiko-tech/contracts). Solidity contracts use OpenZeppelin libraries (ERC-20, UUPS proxy, AccessControl). Verified on Etherscan for Ethereum deployments.

**Concern**: The Trail of Bits audit is 2.5 years old and covered EVM contracts. Given that Spiko has expanded to 7 chains and added features (SAFO, CCIP integration) since October 2023, significant code changes may have occurred without re-audit of the EVM contracts. The Halborn audit only covered Stellar contracts.

**Bug Bounty**: No active bug bounty program found on Immunefi or any other platform.

**Battle Testing**: Protocol has been live since August 2024 (~20 months). Peak TVL: $1.233B (current). No known exploits or security incidents.

**Rating: MEDIUM** -- Two audits from reputable firms, but EVM audit is stale (2.5 years). No bug bounty program. Open source code is a positive signal.

### 5. Cross-Chain & Bridge

**Multi-Chain Deployment**: Spiko operates on 7 chains (Ethereum, Arbitrum, Polygon, Base, Stellar, Starknet, Etherlink). This is a significant multi-chain footprint.

**Bridge Provider**: Chainlink CCIP is the sole cross-chain interoperability provider. CCIP enables compliant cross-chain transfers of USTBL and EUTBL tokens with built-in compliance policy enforcement (KYC/AML checks, jurisdictional restrictions).

**Single Bridge Risk**: All 7 chains rely on Chainlink CCIP as the single cross-chain messaging layer. A CCIP compromise could affect token transfers across all chains. However, Chainlink CCIP is one of the most battle-tested and decentralized bridge solutions.

**DVN Configuration**: Not publicly documented. Chainlink CCIP uses its own decentralized oracle network for message verification, but Spiko's specific CCIP configuration (rate limits, lane settings) is not disclosed.

**Governance Per Chain**: It is unclear whether each chain deployment has its own admin multisig or if one key controls all chains. The Permission Manager architecture suggests per-deployment configuration, but this is UNVERIFIED.

**Rating: MEDIUM** -- 7 chains with single bridge provider (Chainlink CCIP). CCIP is high-quality but represents a single point of failure across all chains. Bridge configuration not publicly documented.

### 6. Operational Security

**Team**: Doxxed founders with strong institutional backgrounds:
- Paul-Adrien Hyppolite (CEO): Former deputy head of financial markets division at French Treasury Department; ENS/X-Mines graduate
- Antoine Michon (co-founder): Former senior civil servant, ENS/X-Mines graduate

**Regulatory**: AMF-licensed and ACPR-supervised as a MiFID investment firm in France. UCITS fund compliance. This is among the highest regulatory standards in the RWA space.

**Institutional Partners**:
- Amundi (EUR 2.4T AUM) -- delegated investment manager for SAFO
- CACEIS (BNP Paribas group) -- depositary bank and fund administrator
- Chainlink -- oracle and cross-chain infrastructure
- Dfns -- MPC wallet infrastructure for key management

**Key Management**: Spiko uses Dfns MPC (Multi-Party Computation) wallet infrastructure. Dfns eliminates single private key risk through threshold signature schemes. Supports HSM deployments. However, no formal key management policy or key ceremony documentation is published.

**Incident Response**: No published incident response plan. The exceptional-operator role can pause token contracts in emergencies, but response time benchmarks are not disclosed.

**Funding**: $22M Series A (2025) led by Index Ventures, with White Star Capital, Frst, Rerail, Bpifrance, Blockwall. Angel investors include Revolut co-founder Nikolay Storonsky and Bridge co-founder Zach Abrams.

**Rating: LOW** -- Strong institutional credibility, doxxed team with government/finance background, EU regulatory oversight. Partial gap in published security practices (no SOC 2, no published incident response plan).

## Critical Risks (if any)

No CRITICAL-severity risks identified. Key HIGH-priority concerns:

1. **Unverified multisig configuration**: The super-admin controlling UUPS upgrades across a $1.2B protocol has no publicly verifiable multisig threshold or signer list. An insider compromise or social engineering attack on admin keys could allow immediate contract upgrades without timelock protection.

2. **No timelock on contract upgrades**: UUPS proxy upgrades appear to be executable immediately by the super-admin. For a protocol of this TVL, industry best practice is a 24-72h timelock on all contract upgrades to allow community review.

3. **Stale EVM audit**: The only EVM smart contract audit (Trail of Bits, Oct 2023) is 2.5 years old. The protocol has expanded significantly since then (7 chains, SAFO fund, CCIP integration). EVM contracts may contain unaudited code paths.

## Peer Comparison

| Feature | Spiko | Ondo (OUSG) | BlackRock (BUIDL) |
|---------|-------|-------------|-------------------|
| TVL | $1.23B | $2.73B | $3.04B |
| Chains | 7 | Multiple | Multiple |
| Regulatory | AMF (France) | SEC-cleared (US) | SEC (US) |
| Timelock | UNVERIFIED | UNVERIFIED | UNVERIFIED |
| Multisig | Claimed, unverified | UNVERIFIED | UNVERIFIED |
| Audits | 2 (ToB 2023, Halborn 2025) | 2+ | 0 on DeFiLlama |
| Audit Coverage Score | 1.25 | ~1.5 | 0 |
| Oracle | Chainlink SmartData | Custom + institutional | Chronicle |
| Bug Bounty | None | None found | None found |
| Open Source | Yes (GitHub) | Partial | No |
| Depositary | CACEIS (BNP Paribas) | BNY Mellon | BNY Mellon |
| Cross-Chain | Chainlink CCIP | Wormhole + others | Securitize + Wormhole |
| Insurance/TVL | N/A (regulated fund) | N/A (regulated fund) | N/A (regulated fund) |

**Observation**: The entire RWA tokenized treasury sector has limited on-chain governance transparency. Spiko, Ondo, and BUIDL all rely heavily on off-chain regulatory compliance rather than on-chain verifiable controls. Spiko differentiates positively with open-source contracts and Chainlink infrastructure, but shares the sector-wide weakness of opaque admin key management.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- N/A (not a lending protocol; only holds sovereign debt)
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED (redemption batching is admin-operated)
- [x] Multisig has low threshold (2/N with small N)? -- UNKNOWN (multisig config not public)
- [x] Zero or short timelock on governance actions? -- YES, no timelock documented
- [ ] Pre-signed transaction risk? -- N/A (EVM, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- YES, multisig signer identities not disclosed

> WARNING: 2 confirmed + 2 unknown indicators in Drift-type category. The combination of unverified multisig, no timelock, and undisclosed signers creates a governance attack surface. Mitigated by AMF regulation and institutional partnerships.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A (not a lending protocol)
- [ ] Single oracle source without TWAP? -- N/A (NAV-based, not market price)
- [ ] No circuit breaker on price movements? -- N/A
- [ ] Insufficient insurance fund relative to TVL? -- N/A

> Not applicable. Spiko is not a lending or trading protocol.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Chainlink CCIP uses decentralized oracle network
- [x] Admin keys stored in hot wallets? -- UNKNOWN (Dfns MPC used, but specifics undisclosed)
- [x] No key rotation policy? -- YES, no published key rotation policy

> 1 confirmed + 1 unknown indicator. Below trigger threshold.

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Not applicable -- Spiko has no on-chain governance token or DAO voting.

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Not applicable -- Spiko does not accept external collateral or interact with DeFi lending.

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler? -- No, standard Solidity + OpenZeppelin
- [ ] Compiler version has known CVEs? -- UNVERIFIED (specific version not checked)
- [ ] Contracts compiled with different compiler versions? -- UNVERIFIED
- [ ] Code depends on language-specific behavior? -- No, uses standard OpenZeppelin patterns

> No flags triggered.

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Not applicable -- USTBL/EUTBL are backed by actual sovereign debt, not algorithmic mechanisms.

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [x] Protocol uses a cross-chain bridge for token minting or reserve release? -- YES, Chainlink CCIP for cross-chain token transfers
- [ ] Bridge message validation relies on a single messaging layer without independent verification? -- Chainlink CCIP uses decentralized validation
- [ ] DVN/relayer/verifier configuration is not publicly documented or auditable? -- Configuration not publicly documented
- [ ] Bridge can release or mint tokens without rate limiting? -- UNKNOWN
- [ ] Bridged/wrapped token is accepted as collateral on lending protocols? -- Not significantly (low DeFi integration due to permissioned nature)
- [ ] No circuit breaker to pause minting if bridge-released volume exceeds normal thresholds? -- UNKNOWN
- [ ] Emergency pause response time > 15 minutes? -- UNKNOWN
- [ ] Bridge admin controls under different governance than core protocol? -- UNKNOWN (Chainlink manages CCIP; Spiko manages token contracts)
- [x] Token is deployed on 5+ chains via same bridge provider? -- YES (7 chains via Chainlink CCIP)

> 2 confirmed indicators. Below the 3-indicator trigger threshold but worth monitoring. The permissioned (allowlisted) nature of USTBL/EUTBL significantly reduces Kelp-type composability cascade risk, since the tokens cannot be freely deposited as collateral on lending protocols without allowlisting.

## Information Gaps

The following questions could NOT be answered from publicly available information. These represent unknown risks.

1. **Multisig configuration**: What is the threshold (m/n)? How many signers? Who are the signers? What Safe address is used? No on-chain verification was possible.
2. **Timelock existence**: Is there any timelock on UUPS proxy upgrades or admin actions? None was found in documentation, GitHub, or tech blog.
3. **EVM contract re-audit**: Have the EVM (Solidity) contracts been re-audited since Trail of Bits in October 2023? The codebase has likely changed significantly with 7-chain expansion and SAFO integration.
4. **Emergency response time**: How quickly can the exceptional-operator pause contracts? No benchmarks or SLAs are published.
5. **Per-chain admin configuration**: Does each chain deployment have independent admin keys, or does one multisig control all 7 chains?
6. **CCIP rate limits**: Are there rate limits on cross-chain token transfers? What is the maximum mint/transfer volume per transaction or time window?
7. **SOC 2 / ISO 27001**: Does Spiko (the company) hold any third-party security certifications? None were found.
8. **Penetration testing**: Has Spiko undergone infrastructure-level penetration testing (distinct from smart contract audits)?
9. **Key rotation**: Does Spiko have a key rotation policy for admin keys, oracle-operator keys, or Dfns MPC key shares?
10. **GoPlus incomplete data**: Multiple GoPlus token security fields (is_honeypot, hidden_owner, owner_change_balance, selfdestruct, is_mintable, slippage_modifiable) were not returned for USTBL/EUTBL tokens, likely due to the permissioned nature of the tokens.
11. **Downstream lending exposure**: Is USTBL/EUTBL accepted as collateral on any lending protocol (Aave, Morpho, etc.)? The allowlist model likely prevents this, but it was not confirmed.

## Disclaimer

This analysis is based on publicly available information and web research as of 2026-04-20. It is NOT a formal smart contract audit. The Quick Triage Score and Data Confidence Score are mechanical calculations that reflect verifiable public data; they do not account for private security measures that may exist but are not disclosed. Spiko operates under AMF regulation, which provides investor protections not captured by on-chain analysis alone. Always DYOR and consider professional auditing services for investment decisions.
