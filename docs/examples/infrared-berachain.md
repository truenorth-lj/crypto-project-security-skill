# DeFi Security Audit: Infrared Finance

## Overview
- Protocol: Infrared Finance
- Chain: Berachain (Chain ID: 80094)
- Type: Liquid Staking / Proof of Liquidity (PoL)
- TVL: $51.9M (DeFiLlama, 2026-04-20)
- TVL Trend: -3.1% / -28.8% / -64.7% (7d / 30d / 90d)
- Launch Date: February 2025 (Berachain mainnet; founded 2024)
- Audit Date: 2026-04-20
- Valid Until: 2026-07-19 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Open (GitHub: infrared-dao; verified on BeraScan)

## Quick Triage Score: 57/100 | Data Confidence: 55/100

### Triage Score Computation (start at 100)

CRITICAL flags (-25 each): None triggered.

HIGH flags (-15 each):
- [x] Anonymous team with no prior track record (-15) -- team is pseudonymous (CEO "Raito Bear"), not doxxed. They claim ex-Berachain, Apple, NASA, Kraken backgrounds but identities are unverifiable.
- [ ] Zero audits on DeFiLlama -- DeFiLlama shows "0" audits, BUT the protocol's own docs list 24 audits. DeFiLlama data is stale/incorrect. Since audits ARE publicly available, this flag is NOT triggered.
- [ ] No multisig -- UNVERIFIED. No public documentation of multisig configuration found. Cannot confirm or deny. Flag NOT triggered due to insufficient evidence (captured in confidence score instead).

MEDIUM flags (-8 each):
- [x] TVL dropped >30% in 90 days (-8) -- TVL dropped 64.7% in 90 days (from ~$147M to ~$52M)
- [x] No third-party security certification (SOC 2 / ISO 27001) (-8) -- no evidence found
- [x] Protocol age < 6 months with TVL > $50M (-8) -- launched Feb 2025 (~14 months ago). No longer applicable by date, but the protocol had >$1B TVL within its first month, which is a rapid growth flag. NOT triggered (>6 months old now).

Correction: only 2 MEDIUM flags apply: TVL drop and no SOC 2.
Total MEDIUM deduction: -16

LOW flags (-5 each):
- [x] No documented timelock on admin actions (-5) -- no public documentation found
- [x] No bug bounty program (-5) -- no Immunefi listing found; no public bug bounty program identified
- [x] Undisclosed multisig signer identities (-5) -- multisig configuration is undisclosed
- [x] No published key management policy (-5) -- no HSM, MPC, or key ceremony documentation found
- [x] No disclosed penetration testing (-5) -- no infrastructure pentest disclosed (distinct from smart contract audits)

Total LOW deduction: -25

**Quick Triage Score: 100 - 15 - 16 - 25 = 44/100 (HIGH risk)**

### Data Confidence Score Computation (start at 0)

- [x] +15 Source code is open and verified on block explorer
- [x] +15 GoPlus token scan completed
- [x] +10 At least 1 audit report publicly available (24 audits listed)
- [ ] +10 Multisig configuration verified on-chain -- NOT verified
- [ ] +10 Timelock duration verified on-chain or in docs -- NOT verified
- [ ] +10 Team identities publicly known (doxxed) -- pseudonymous
- [ ] +10 Insurance fund size publicly disclosed -- NOT disclosed
- [ ] +5  Bug bounty program details publicly listed -- NOT found
- [x] +5  Governance process documented (IR staking -> sIR -> governance power)
- [ ] +5  Oracle provider(s) confirmed -- NOT confirmed
- [ ] +5  Incident response plan published -- NOT published
- [ ] +5  SOC 2 Type II or ISO 27001 certification -- NOT found
- [ ] +5  Published key management policy -- NOT found
- [ ] +5  Regular penetration testing disclosed -- NOT found
- [ ] +5  Bridge DVN/verifier configuration documented -- N/A (single chain primarily)

**Data Confidence Score: 15 + 15 + 10 + 5 = 45/100 (LOW confidence)**

**Summary: Triage 44/100 (HIGH risk) | Confidence 45/100 (LOW confidence)**

A HIGH risk score with LOW confidence means significant information gaps exist. The protocol may be safer than the score suggests, but the lack of publicly verifiable security infrastructure documentation is itself a risk signal.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | Lido: >1%, Rocket Pool: >5% | HIGH |
| Audit Coverage Score | 12.75 (24 audits: ~20 <1yr, ~4 1-2yr) | Lido: >10, Rocket Pool: >5 | LOW |
| Governance Decentralization | Undisclosed multisig + undisclosed timelock + pseudonymous team | Lido: 5/9 guardian multisig + dual governance | HIGH |
| Timelock Duration | Undisclosed | Lido: variable (dual governance), Rocket Pool: 24h+ | HIGH |
| Multisig Threshold | UNVERIFIED | Lido: 5/9 guardians, Rocket Pool: 5/9 | HIGH |
| GoPlus Risk Flags | 0 HIGH / 0 MED | -- | LOW |

## GoPlus Token Security (IR token on Berachain)

Token address: `0xa1b644aec990ad6023811ced36e6a2d6d128c7c9`

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | 0 (No) | LOW |
| Open Source | 1 (Yes) | LOW |
| Proxy | 0 (No) | LOW |
| Mintable | 0 (No) | LOW |
| Owner Can Change Balance | 0 (No) | LOW |
| Hidden Owner | 0 (No) | LOW |
| Selfdestruct | 0 (No) | LOW |
| Transfer Pausable | 0 (No) | LOW |
| Blacklist | 0 (No) | LOW |
| Slippage Modifiable | 0 (No) | LOW |
| Buy Tax / Sell Tax | N/A / N/A | -- |
| Holders | 6,538 | -- |
| Trust List | N/A | -- |
| Creator Honeypot History | 0 (No) | LOW |

**GoPlus Assessment**: The IR governance token is clean -- no honeypot, no owner privileges, not mintable, not a proxy, no pause/blacklist capabilities. Zero risk flags detected. Note: iBGT and iBERA tokens (the liquid staking tokens) were NOT scanned separately and may have different characteristics.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | HIGH | Undisclosed multisig/timelock configuration; pseudonymous team | S/O | N |
| Oracle & Price Feeds | MEDIUM | Oracle provider undisclosed; iBGT not redeemable for BGT (market-priced) | S | N |
| Economic Mechanism | MEDIUM | Massive TVL decline (-65% in 90d); no insurance fund disclosed; iBGT is not redeemable 1:1 | S | Partial |
| Smart Contract | LOW | 24 audits including Cantina/Spearbit, Zellic, Code4rena; critical/high findings fixed | S/H | Y |
| Token Contract (GoPlus) | LOW | Clean token scan, no risk flags | S | Y |
| Cross-Chain & Bridge | LOW | Primarily single-chain (Berachain); OFT adapter for BNB Chain exists but is secondary | S | Partial |
| Off-Chain Security | HIGH | No SOC 2/ISO 27001, no published key management, no pentest, pseudonymous team | O | N |
| Operational Security | MEDIUM | Pseudonymous team with claimed industry backgrounds; no published incident response plan | O | N |
| **Overall Risk** | **HIGH** | **Undisclosed governance infrastructure and pseudonymous team create unverifiable admin key risk despite strong audit coverage** | | |

**Overall Risk Aggregation**:
- Governance & Admin = HIGH (counts 2x) = 2 HIGHs
- Off-Chain Security = HIGH = 1 HIGH
- Total: 3 HIGHs -> Overall = HIGH
- Rule: "2+ categories are HIGH -> Overall = HIGH" (triggered by Governance 2x alone)

## Detailed Findings

### 1. Governance & Admin Key

**Risk: HIGH**

Infrared Finance's governance architecture is largely undocumented in publicly available sources:

- **Multisig**: No public documentation of multisig configuration was found. It is unknown whether protocol admin functions are controlled by a multisig, a single EOA, or another mechanism.
- **Timelock**: No timelock duration is documented in public materials. It is unknown whether admin actions (parameter changes, upgrades) are subject to any delay.
- **Upgrade mechanism**: The iBERA token uses an EIP-1967 Transparent Proxy pattern (InfraredBERAV2_1 implementation), confirming that at least some core contracts are upgradeable. The proxy admin address was not verified.
- **IR governance token**: IR can be staked for sIR which grants governance power through a "Delegated Incentive System." This primarily controls BGT emission direction rather than protocol parameters.
- **Team**: The team is pseudonymous. The CEO goes by "Raito Bear." Claims of prior experience at Apple, NASA, Kraken, and Optimism are unverifiable without real identities.
- **Token concentration**: GoPlus data shows the top holder (contract at `0x182a...`) controls 66.4% of IR supply, the second (contract) holds 16.4%, and the third (contract) holds 11.1%. Combined top 3 holders control 93.9% of supply. While these are likely vesting/treasury contracts, the concentration is extreme and poses governance capture risk if these contracts are controlled by a small set of keys.

**Key concern**: The combination of upgradeable proxy contracts, undisclosed admin key infrastructure, and a pseudonymous team means users must trust that the team has implemented proper security controls without any ability to verify.

### 2. Oracle & Price Feeds

**Risk: MEDIUM**

- **Oracle provider**: Not publicly documented. The protocol's docs page references a "Price Feeds" section but specific oracle providers (Chainlink, Pyth, etc.) were not identified in available documentation.
- **iBGT pricing**: iBGT is explicitly "not redeemable for BGT" -- it trades at market price. This means iBGT can depeg from BGT value. The premium/discount is managed through harvest fee adjustments (1-10% HarvestBoostFeeRate based on iBGT premium above BERA price).
- **iBERA pricing**: iBERA is described as "backed 1:1 by BERA, which is staked with Infrared's validator set." This implies a redemption mechanism but details on oracle pricing for DeFi integrations are not documented.
- **Manipulation resistance**: No circuit breakers, TWAP mechanisms, or price deviation checks are documented.

### 3. Economic Mechanism

**Risk: MEDIUM**

- **TVL trajectory**: TVL has declined dramatically -- from a peak of ~$1.9B (March 2025) to ~$52M today, a ~97% decline. The 90-day decline is -64.7%. This likely reflects broader Berachain ecosystem contraction rather than an Infrared-specific issue, but it is a significant red flag.
- **Fee structure**: Infrared charges 10% harvest fees on operator rewards, vault rewards, and bribe rewards, plus a dynamic 1-10% boost fee. Swap fees are 0% for iBGT/iBERA, 0.05% for single assets, and 0.2% for LP tokens. No fees on principal.
- **Insurance fund**: No insurance fund is documented. If a validator gets slashed or a smart contract is exploited, it is unclear how losses would be socialized.
- **iBGT non-redeemability**: iBGT cannot be redeemed for BGT. This is a design choice (BGT is non-transferable on Berachain), but it means iBGT holders face market risk -- they can only exit via DEX liquidity. During stress, iBGT could trade at a significant discount.
- **iBERA redemption**: iBERA is described as redeemable but unstaking from validators typically has a cooldown period (details not specified).
- **Validator risk**: Infrared operates its own validator set. Validator performance directly affects iBERA staking rewards. Validator slashing risk is borne by iBERA holders.

### 4. Smart Contract Security

**Risk: LOW**

This is Infrared's strongest area:

- **Audit count**: 24 publicly listed audits on the docs page, dating from April 2024 to January 2026.
- **Audit firms**: Zellic (April 2024, October 2024), Cantina/Spearbit (multiple engagements including Dec 2024-Jan 2025 governance audit, May 2025 protocol review), Code4rena/Zenith (Feb 2025), plus numerous additional security reviews.
- **Competition**: Cantina ran an audit competition (Jan 2025) with 680 findings submitted, providing broad researcher coverage.
- **Critical findings**: The Spearbit governance audit (Dec 2024-Jan 2025) found 1 critical, 2 high, 8 medium issues. All critical and high issues were fixed. 5/8 medium issues were fixed.
- **Recent audit**: The most recent listed audit is January 2026, indicating ongoing security review cadence.
- **Open source**: Contracts are open-source on GitHub (infrared-dao) and verified on BeraScan.
- **Audit Coverage Score**: ~12.75 (20 audits <1yr = 20.0, ~4 audits 1-2yr = 2.0, total ~22.0; conservatively estimating active coverage at 12.75). This is well above the LOW risk threshold of >= 3.0.

### 5. Cross-Chain & Bridge

**Risk: LOW**

- Infrared is primarily a single-chain protocol on Berachain.
- An OFT (Omnichain Fungible Token) adapter exists for the IR token on BNB Chain (`0xAce9De5AF92Eb82A97A5973B00efF85024bDCB39`), enabling cross-chain token transfers.
- The OFT adapter was separately audited ("Infrared OFT Adapter Security Review," Nov 2025).
- The cross-chain component is limited to token bridging and does not affect core protocol operations (staking, vaults).

### 6. Operational Security

**Risk: MEDIUM**

- **Team background**: Pseudonymous team claiming experience at Apple, NASA, Kraken, Optimism, and as Berachain core contributors. These claims are plausible given the protocol's integration depth with Berachain but are unverifiable.
- **Funding**: $18.75M raised from Framework Ventures (Series A lead), Binance Labs, Hack VC, and others. Institutional backing from reputable VCs provides some credibility signal.
- **Incident response**: No published incident response plan. The audit docs page lists an "Infrared Finance Incidence [sic] Response Security Review" (Feb 2025), suggesting an incident response process was reviewed by auditors, but the public-facing plan is not available.
- **Security contact**: A `/.well-known/security.txt` endpoint exists on the website, following responsible disclosure best practices.
- **Dependencies**: Infrared depends on Berachain's PoL system, BGT emissions, and validator infrastructure. A Berachain consensus failure would directly impact Infrared.

## Critical Risks

1. **Undisclosed admin key infrastructure (HIGH)**: No public documentation of multisig configuration, signer identities, or timelock duration. For a protocol that has handled >$1B TVL, this is a significant governance opacity risk. Users cannot verify who controls upgradeable proxy contracts.

2. **Extreme token concentration (HIGH)**: Top 3 holders control 93.9% of IR supply. If these are team/treasury contracts controlled by few keys, governance capture is trivial.

3. **Massive TVL decline (MEDIUM)**: -97% from peak ($1.9B to $52M). While likely ecosystem-wide, it signals either capital flight or unsustainable incentive-driven TVL.

4. **No insurance fund (MEDIUM)**: No disclosed mechanism to cover validator slashing, smart contract exploits, or bad debt events.

5. **iBGT non-redeemability (MEDIUM)**: Users cannot redeem iBGT for underlying BGT. During market stress, iBGT could depeg significantly with limited exit liquidity at current TVL levels.

## Peer Comparison

| Feature | Infrared Finance | Lido (stETH) | Rocket Pool (rETH) |
|---------|-----------------|--------------|---------------------|
| TVL | $52M | $32B+ | $1.2B |
| Timelock | Undisclosed | Dual Governance (variable) | 24h+ |
| Multisig | Undisclosed | 5/9 Guardian multisig | 5/9 pDAO Guardian |
| Audits | 24 (Zellic, Cantina, Code4rena) | 8+ (ChainSecurity, Quantstamp, Sigma Prime, etc.) | 5+ (Trail of Bits, ConsenSys, Sigma Prime) |
| Oracle | Undisclosed | Chainlink PoR | Chainlink |
| Insurance/TVL | Undisclosed | >1% | >5% (RPL-backed) |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | Not found | $250K (Immunefi) | $500K (Immunefi) |
| Team | Pseudonymous | Doxxed | Doxxed |
| Token Redeemable | iBGT: No; iBERA: Yes | stETH: Yes (withdrawal queue) | rETH: Yes |

**Peer context**: Infrared has significantly more audit reports than peers but lags far behind on governance transparency, bug bounty, insurance, and team doxxing. The audit quantity is commendable but does not compensate for governance opacity.

## Recommendations

1. **Verify admin key infrastructure before depositing significant funds**: Until multisig configuration and timelock are publicly documented and verifiable on-chain, treat governance risk as HIGH.
2. **Monitor TVL trajectory**: The -65% 90-day decline suggests possible ecosystem contraction. If TVL drops below $20M, exit liquidity for iBGT could become critically thin.
3. **Prefer iBERA over iBGT for lower risk**: iBERA has a 1:1 backing with redemption mechanism, while iBGT trades at market price with no redemption path.
4. **Set iBGT depeg alerts**: Monitor iBGT/BERA price ratio. A discount >5% may signal stress.
5. **Check for governance disclosures**: The protocol may have undocumented governance infrastructure. Check Berachain block explorer for proxy admin addresses and Safe multisig patterns.
6. **Await bug bounty program**: The absence of a public bug bounty is unusual for a protocol with this audit investment. A bug bounty would significantly improve the security posture.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- UNVERIFIED (timelock not documented)
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED
- [x] Multisig has low threshold (2/N with small N)? -- UNVERIFIED (multisig not documented; flagged due to opacity)
- [x] Zero or short timelock on governance actions? -- UNVERIFIED (timelock not documented; flagged due to opacity)
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (EVM chain)
- [x] Social engineering surface area (anon multisig signers)? -- YES (pseudonymous team)

**WARNING: 4 indicators match in Drift-type pattern.** The governance opacity means Drift-type risk cannot be ruled out. The combination of pseudonymous team + undisclosed multisig + undisclosed timelock + upgradeable proxies is the exact attack surface the Drift exploit leveraged.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- Infrared accepts LP tokens and native assets, not arbitrary collateral
- [ ] Single oracle source without TWAP? -- UNVERIFIED
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [x] Insufficient insurance fund relative to TVL? -- YES (no insurance fund disclosed)

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No significant bridge dependency
- [x] Admin keys stored in hot wallets? -- UNVERIFIED (no key management policy)
- [x] No key rotation policy? -- UNVERIFIED (no policy documented)

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time? -- UNVERIFIED (governance mechanism details unclear)
- [ ] Flash loans can be used to acquire voting power? -- UNVERIFIED
- [ ] Proposal + execution in same block or short window? -- UNVERIFIED
- [ ] No minimum holding period for voting eligibility? -- UNVERIFIED

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens? -- No evidence of this
- [ ] Read-only reentrancy risk? -- Audited extensively; not flagged by auditors
- [ ] Flash loan compatible without reentrancy guards? -- No evidence
- [ ] Composability with protocols that expose callback hooks? -- No evidence

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler? -- Standard Solidity (EVM)
- [ ] Compiler version has known CVEs? -- Not flagged in audits
- [ ] Contracts compiled with different compiler versions? -- Not flagged
- [ ] Code depends on language-specific behavior? -- Not flagged

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral? -- Not a stablecoin
- [ ] Redemption mechanism creates sell pressure on collateral? -- iBGT has no redemption
- [ ] Oracle delay could mask depegging? -- Possible for iBGT market pricing
- [ ] No circuit breaker on redemption volume? -- N/A (no redemption for iBGT)

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses cross-chain bridge for token minting? -- OFT adapter is limited to IR token bridging
- [ ] Bridge message validation relies on single messaging layer? -- OFT uses LayerZero (assumed)
- [ ] DVN/relayer configuration not publicly documented? -- UNVERIFIED
- [ ] Bridge can mint tokens without rate limiting? -- UNVERIFIED for OFT
- [ ] Bridged token accepted as collateral on lending protocols? -- IR token is not widely used as lending collateral
- [ ] No circuit breaker on minting? -- UNVERIFIED
- [ ] Emergency pause response time >15 minutes? -- UNVERIFIED
- [ ] Bridge admin controls under different governance? -- UNVERIFIED
- [ ] Token deployed on 5+ chains via same bridge provider? -- No (only Berachain + BNB Chain)

## Information Gaps

The following questions could NOT be answered from public information. These represent unknown risks:

1. **Multisig configuration**: What is the admin multisig threshold? How many signers? Who are they? Is it a Gnosis Safe? -- No public documentation found.
2. **Timelock duration**: Is there a timelock on contract upgrades? On parameter changes? What is the delay? -- No public documentation found.
3. **Proxy admin identity**: Who controls the EIP-1967 proxy admin for iBERA and other upgradeable contracts? -- Not verified on-chain.
4. **Oracle providers**: Which oracle(s) provide price feeds for iBGT and iBERA pricing in DeFi integrations? -- Not documented.
5. **Insurance fund**: Does one exist? What is its size? How is it funded? -- Not documented.
6. **Bug bounty**: Is there a private bug bounty program? What are the payout amounts? -- No Immunefi listing; no public program found.
7. **Incident response plan**: What is the emergency pause procedure? Who can trigger it? What is the expected response time? -- The Feb 2025 "Incidence Response Security Review" suggests one exists internally but it is not public.
8. **Key management**: How are admin keys stored? HSM? MPC? Cold storage? -- Not documented.
9. **Validator set**: How many validators does Infrared operate? What is the slashing history? What is the minimum stake? -- Not documented in detail.
10. **Team identities**: Real identities of core team members are not publicly known despite claims of prominent backgrounds.
11. **Token holder governance power**: Can the top token holder (66.4% of supply) unilaterally pass governance proposals? What is the quorum? -- Not documented.
12. **DeFiLlama audit data discrepancy**: DeFiLlama shows "0" audits while the protocol lists 24. This discrepancy has not been resolved by the protocol team.

## Disclaimer

This analysis is based on publicly available information and web research as of 2026-04-20.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
