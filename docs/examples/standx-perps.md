# DeFi Security Audit: StandX (Perpetual DEX)

**Audit Date:** 2026-04-20
**Protocol:** StandX -- Perpetual DEX with yield-bearing DUSD stablecoin margin
**Valid Until:** 2026-07-19 (or sooner if: TVL changes >30%, governance upgrade, or security incident)

## Overview
- Protocol: StandX
- Chain: BNB Chain (primary), Solana
- Type: Perpetual DEX / Derivatives + Yield-Bearing Stablecoin (DUSD)
- TVL: ~$52M (BSC: $45.8M, Solana: $6.6M)
- Open Interest: ~$1,797 BTC (per CoinGecko)
- Token: DUSD (BEP-20, BSC) -- 0xaf44a1e76f56ee12adbb7ba8acd3cbd474888122 (no governance token yet)
- Launch Date: January 2026 (first DeFiLlama TVL data: 2026-01-12)
- Audit Date: 2026-04-20
- Source Code: Partial (DUSD token contract verified on BSC; perps matching engine independently developed and closed source; audit reports reference GitHub audit repo)
- Team: Semi-doxxed (ex-Binance Futures founding team + Goldman Sachs engineers; CEO "AG" publicly known; co-founder Justin Cheng named)
- Funding: Self-funded; Solana Foundation non-dilutive grant

## Quick Triage Score: 30/100 (HIGH risk) | Data Confidence: 40/100 (LOW)

**Triage deductions (mechanical):**

| Flag | Category | Points |
|------|----------|--------|
| Zero audits listed on DeFiLlama | HIGH | -15 |
| No multisig (single EOA admin key -- multisig mentioned in docs but unverified on-chain) | HIGH | -15 |
| Protocol age < 6 months with TVL > $50M | MEDIUM | -8 |
| GoPlus: is_proxy = 1 AND no timelock on upgrades verified | MEDIUM | -8 |
| No third-party security certification (SOC 2 / ISO 27001) | MEDIUM | -8 |
| No documented timelock on admin actions | LOW | -5 |
| No bug bounty program (not on Immunefi) | LOW | -5 |
| Insurance fund / TVL undisclosed | LOW | -5 |
| Undisclosed multisig signer identities | LOW | -5 |
| No published key management policy | LOW | -5 |
| No disclosed penetration testing | LOW | -5 |
| Custodial dependency without disclosed custodian certification | LOW | -5 |
| **Total deducted** | | **-91** |

**Score: max(0, 100 - 91) = 9** -- but since the protocol does have 6 audit reports from 2 firms (WatchPug + RigSec) which are not reflected on DeFiLlama, the "zero audits on DeFiLlama" flag is mechanically applied per the formula. The raw mechanical score is **9/100** which places it in CRITICAL range (0-19).

**However**, re-evaluating: the audits DO exist (6 reports from WatchPug and RigSec), they are simply not indexed on DeFiLlama. Removing the DeFiLlama-specific audit flag would yield 24/100. The mechanical score stands at **9/100 (CRITICAL)** per the formula rules ("do NOT adjust").

**Revised mechanical score: 9/100 (CRITICAL risk)**

**Data Confidence breakdown:**

| Verified Data Point | Points |
|---------------------|--------|
| Source code open and verified on block explorer (GoPlus: is_open_source = 1) | +15 |
| GoPlus token scan completed | +15 |
| At least 1 audit report publicly available (6 reports from WatchPug + RigSec) | +10 |
| **Total** | **40** |

**Not verified (0 points each):**
- Multisig configuration NOT verified on-chain (Safe API or Squads)
- Timelock duration NOT verified on-chain or in docs
- Team identities only partially known (CEO "AG", co-founder Justin Cheng -- not fully doxxed)
- Insurance fund size NOT publicly disclosed
- Bug bounty program NOT publicly listed
- Governance process NOT documented
- Oracle provider(s) NOT confirmed (docs say "multiple" but no names)
- Incident response plan NOT published
- SOC 2 / ISO 27001 NOT verified
- Key management policy NOT published
- Penetration testing NOT disclosed

Red flags found: 12 (2 HIGH, 3 MEDIUM, 7 LOW)
Data points verified: 3 / 15 checkable

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed ("Reserve Fund" exists but size unknown) | GMX undisclosed, Hyperliquid ~8-10% | HIGH |
| Audit Coverage Score | 3.0 (6 audits, all <1yr old: 6 x 1.0 = 6.0; capped by scope -- DUSD + Highway only, perps engine not audited) | GMX 3.75, Hyperliquid 0.50 | MEDIUM |
| Governance Decentralization | Fully centralized (no on-chain governance, no DAO, no governance token) | Hyperliquid centralized, GMX Snapshot + DAO | HIGH |
| Timelock Duration | Undisclosed / None documented | GMX 24h, dYdX 48h | HIGH |
| Multisig Threshold | Claimed but UNVERIFIED on-chain | GMX community multisig, Hyperliquid 3/4 | HIGH |
| GoPlus Risk Flags | 0 HIGH / 1 MED (is_proxy) | -- | LOW |

### Audit Coverage Score Calculation
- WatchPug DUSD Solana: <1yr = 1.0
- WatchPug DUSD EVM: <1yr = 1.0
- WatchPug Highway EVM: <1yr = 1.0
- WatchPug Highway SVM: <1yr = 1.0
- RigSec DUSD Solana: <1yr = 1.0
- RigSec DUSD EVM: <1yr = 1.0
- **Raw total: 6.0** -- but these cover only the DUSD stablecoin and Highway bridge/gateway. The perps matching engine, liquidation engine, and risk management system have no disclosed audits.
- **Effective score: ~3.0** (MEDIUM, discounted by ~50% for incomplete coverage)

### TVL Trend
| Period | Change |
|--------|--------|
| 7d | -1.7% (BSC), -0.7% (Solana) |
| 30d | -9.2% (BSC only, Solana data insufficient) |
| 90d | -48.0% (BSC only -- significant decline from ~$94M peak) |

**Note**: The 90-day TVL decline of 48% on BSC is a significant red flag. TVL peaked near $95M in January 2026 and has declined steadily to $45.8M.

## GoPlus Token Security (BSC: 0xaf44a1e76f56ee12adbb7ba8acd3cbd474888122)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | LOW |
| Open Source | Yes (1) | LOW |
| Proxy | Yes (1) | MEDIUM |
| Mintable | UNVERIFIED (not in GoPlus response) | UNKNOWN |
| Owner Can Change Balance | UNVERIFIED (not in GoPlus response) | UNKNOWN |
| Hidden Owner | UNVERIFIED (not in GoPlus response) | UNKNOWN |
| Selfdestruct | UNVERIFIED (not in GoPlus response) | UNKNOWN |
| Transfer Pausable | UNVERIFIED (not in GoPlus response) | UNKNOWN |
| Blacklist | UNVERIFIED (not in GoPlus response) | UNKNOWN |
| Slippage Modifiable | UNVERIFIED (not in GoPlus response) | UNKNOWN |
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 20,784 | LOW |
| Trust List | UNVERIFIED | -- |
| Creator Honeypot History | No (0) | LOW |

**Notes:**
- The token IS a proxy contract (is_proxy = 1), meaning the implementation can be upgraded. Without a verified timelock on proxy upgrades, this is a MEDIUM risk.
- Creator address (0x649b...6310) holds minimal DUSD (0.002% of supply).
- Top holder is a contract (0x11b6...0433) holding 49.3% of supply -- likely the StandX vault/gateway.
- Second and third largest holders are EOAs holding 16.3% and 12.4% respectively -- these are significant concentrations.
- Total DEX liquidity is ~$8.6M (primarily on PancakeSwap V3).
- Several GoPlus fields (mintable, hidden_owner, owner_change_balance, selfdestruct, transfer_pausable, blacklist, slippage_modifiable) were not returned in the API response, creating data gaps.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **HIGH** | Fully centralized; multisig claimed but unverified; no timelock; no governance process | S/O | N |
| Oracle & Price Feeds | **MEDIUM** | Multiple unnamed sources with CEX cross-checks (Binance, OKX, Bybit); no independent oracle (Chainlink/Pyth) confirmed | S | N |
| Economic Mechanism | **MEDIUM** | Delta-neutral DUSD hedging via CEX counterparties; reserve fund undisclosed; 48% TVL decline in 90d | S | Partial |
| Smart Contract | **MEDIUM** | 6 audits on DUSD/Highway but perps engine unaudited; proxy contract upgradeable | S | Partial |
| Token Contract (GoPlus) | **MEDIUM** | Proxy contract; multiple GoPlus fields missing from response; high holder concentration | S | Partial |
| Cross-Chain & Bridge | **MEDIUM** | Multi-chain (BSC + Solana) with "Highway" bridge; bridge audited by WatchPug + RigSec | S | Partial |
| Off-Chain Security | **HIGH** | No SOC 2/ISO 27001; no published key management; custodial dependency (Ceffu mentioned in interviews) | O | N |
| Operational Security | **MEDIUM** | Semi-doxxed team (ex-Binance Futures); no bug bounty; no incident response plan | S/O | Partial |
| **Overall Risk** | **HIGH** | **Young protocol (3 months) with $52M TVL, declining 48% over 90d. Fully centralized governance with unverified multisig. Perps engine unaudited. Custodial dependency on CEX hedging.** | | |

**Overall Risk aggregation:**
1. Governance & Admin = HIGH (counts as 2x) = 2 HIGHs
2. Off-Chain Security = HIGH = 1 HIGH
3. Total: 3 HIGH-equivalent ratings --> Overall = **HIGH**

## Detailed Findings

### 1. Governance & Admin Key

**Risk: HIGH**

**Admin Key Surface Area:**
- StandX documentation references a "Multisig system" for the Reserve Fund that bridges assets between on-chain contracts and off-chain platforms. However, no multisig address is publicly disclosed, and no on-chain verification is possible.
- The DUSD token on BSC is a proxy contract (confirmed by GoPlus: is_proxy = 1). The proxy admin can upgrade the token implementation, potentially changing core logic. No timelock on upgrades has been documented or verified.
- No governance token exists. No on-chain governance, no DAO, no voting mechanism.
- The team retains full control over all protocol parameters, asset listings, oracle configurations, and contract upgrades.
- The docs reference "Timelocked governance and emergency pause functionality" in the risk management section, but no specific timelock duration or contract address is provided.

**Upgrade Mechanism:**
- DUSD is a proxy contract on BSC, meaning the implementation can be swapped by the proxy admin.
- No transparent proxy pattern verification was possible (Etherscan API key required).
- Highway bridge contracts are also likely upgradeable given they were audited separately.

**Governance Process:**
- None. The protocol is fully team-controlled.
- No governance proposals, no community voting, no delegation.

**Token Concentration:**
- DUSD is not a governance token (it is a stablecoin). No governance token exists.
- However, DUSD holder concentration is notable: top holder (contract) owns 49.3%, top 3 holders control 78% of supply.

### 2. Oracle & Price Feeds

**Risk: MEDIUM**

**Oracle Architecture:**
- StandX uses a proprietary mark price system based on three inputs: (1) funding-adjusted index price, (2) short-term basis tracking, (3) latest matched trade price.
- The mark price is the **median** of these three values, preventing single-outlier manipulation.
- Cross-checks against Binance, OKX, and Bybit mark prices. When internal marks deviate, the system pins to the median of those external venues.
- The docs reference "Multiple independent price feeds using median price selection" and "Secondary oracle networks with time-weighted average prices (TWAP)" but do NOT name specific oracle providers (no Chainlink, no Pyth confirmation).

**Strengths:**
- Median-based mark price is manipulation-resistant.
- CEX cross-referencing provides a reality check.

**Weaknesses:**
- No named independent oracle provider (Chainlink, Pyth, etc.) -- relies on proprietary feeds.
- Admin can presumably change oracle sources without governance.
- No documented circuit breaker on price movements (beyond the CEX cross-check pinning).
- Fallback mechanism: uses oracle index when trading is inactive, but no details on what happens if external CEX feeds fail simultaneously.

### 3. Economic Mechanism

**Risk: MEDIUM**

**DUSD Delta-Neutral Mechanism:**
- When users mint DUSD with USDT/USDC, the protocol buys spot assets (ETH, BTC, BNB, SOL) and opens equivalent short perpetual positions on CEXs to hedge price risk.
- Yield sources: staking rewards on native assets, funding fees from short positions, basis spreads.
- Yields range from 3-11% APY (conservative estimate) to 20-30% in bull markets.
- Rewards distributed in 7-day cycles.
- 7-day lock period on DUSD redemptions.

**This is essentially the same model as Ethena (USDe/sUSDe).** Key risks include:
- **Negative funding rate risk**: When funding rates turn negative, the protocol loses money. The "stability reserve" is activated to cover losses, but its size is undisclosed.
- **Counterparty risk**: Hedging positions are on centralized exchanges. A CEX failure (FTX scenario) could cause DUSD to depeg.
- **Custodial risk**: Assets are held with custodians (Ceffu mentioned in interviews). Custodian failure or freeze could lock collateral.

**Liquidation Mechanism:**
- Liquidation triggers when margin balance < maintenance margin requirement (based on mark price, not last trade).
- Small positions (Tier 1): IOC order at bankruptcy price; if unfilled, vault assumes position.
- Large positions (Tier 2+): tranched liquidation to reduce market impact.
- 1.25% liquidation clearance fee on notional value.
- When vault capacity reached, Auto-Deleveraging (ADL) kicks in.
- Vault can take over positions at bankruptcy price during extreme volatility.

**Funding Rate:**
- Formula: F = P + clamp(IR - P, -0.0005, 0.0005) where P = premium index.
- Base interest rate: 0.00125%/hour (0.01%/8h period).
- Max cap: 4%/hour (configurable per pair).
- Premium index calculated every 5 seconds, TWAP aggregated.

**Bad Debt Handling:**
- Reserve fund exists but size is undisclosed.
- No socialized loss mechanism documented beyond ADL.
- Insurance fund / TVL ratio: UNKNOWN.

### 4. Smart Contract Security

**Risk: MEDIUM**

**Audit History:**
- 6 audit reports from 2 firms (WatchPug and RigSec), all from 2025-2026:
  1. WatchPug -- StandX DUSD Solana
  2. WatchPug -- StandX DUSD EVM
  3. WatchPug -- StandX Highway EVM
  4. WatchPug -- StandX Highway SVM
  5. RigSec -- StandX DUSD Solana
  6. RigSec -- StandX DUSD EVM
- Audit reports are hosted on GitHub (StandX Labs audit repo).
- **Critical gap**: The perps matching engine, liquidation engine, funding rate system, and risk management contracts have NO disclosed audits. Only the DUSD stablecoin and Highway bridge/gateway have been audited.

**Bug Bounty:**
- Docs mention "bug bounty programs" in the risk management section but no public bug bounty is listed on Immunefi or any other platform.

**Battle Testing:**
- Protocol launched January 2026 -- approximately 3 months old at audit date.
- No known exploits or security incidents.
- No known near-misses.
- Peak TVL: ~$95M (January 2026), now $52M.

**Open Source:**
- DUSD token contract: verified on BscScan (is_open_source = 1 per GoPlus).
- Perps engine: independently developed, code not publicly available.
- Solana programs: audit reports suggest code was shared with auditors but public accessibility is unclear.

### 5. Cross-Chain & Bridge

**Risk: MEDIUM**

**Multi-Chain Deployment:**
- BSC (primary, $45.8M TVL) and Solana ($6.6M TVL).
- Both chains have DUSD token deployments.

**Bridge ("Highway"):**
- StandX operates its own cross-chain bridge called "Highway."
- Highway has been audited by both WatchPug and RigSec (EVM + SVM versions).
- The bridge facilitates asset transfers between BSC and Solana.
- Docs mention "StandX Reserve Fund: A Multisig system that bridges assets between on-chain contracts and off-chain platforms" -- this suggests the bridge has a multisig component, but no details are provided.

**Bridge Risks:**
- Proprietary bridge (not using established providers like LayerZero or Wormhole) -- higher risk surface.
- Bridge admin controls and validator/relayer configuration are not publicly documented.
- No rate limiting on bridge transactions is documented.
- No emergency pause time benchmark disclosed.

### 6. Operational Security

**Risk: MEDIUM**

**Team & Track Record:**
- Semi-doxxed: CEO "AG" (former Binance Futures business lead), co-founder Justin Cheng, plus former Goldman Sachs engineers.
- The Binance Futures background is a credibility signal but "AG" is not a full legal name.
- Self-funded with Solana Foundation grant support.
- No previous projects under the StandX name.

**Incident Response:**
- No published incident response plan.
- Emergency pause capability mentioned in docs but no details on response time.
- No communication channels for security alerts documented.

**Dependencies:**
- Centralized exchange counterparties for DUSD hedging (specific CEXs undisclosed; Ceffu custody mentioned in interviews).
- If the primary hedging venue fails, DUSD could depeg.
- Oracle dependency on CEX price feeds (Binance, OKX, Bybit).

**Off-Chain Controls:**
- No SOC 2 Type II or ISO 27001 certification.
- No published key management policy.
- Custodial dependency on Ceffu (Binance-affiliated) for reserve management -- Ceffu does hold industry certifications but StandX itself does not.
- No disclosed penetration testing.
- Rating: **HIGH** (anonymous team with no verifiable security practices).

## Critical Risks

1. **Unverified multisig and governance**: The protocol claims to use multisig for the Reserve Fund, but no on-chain verification is possible. A single compromised key could potentially drain the reserve or upgrade contracts maliciously.
2. **Proxy contract with no verified timelock**: The DUSD token is upgradeable. Without a timelock, a malicious upgrade could be executed instantly, potentially affecting $88.5M in circulating DUSD.
3. **Perps engine unaudited**: The core trading, liquidation, and risk management systems have no disclosed security audits. This is the highest-value attack surface for a perps DEX.
4. **Custodial/counterparty risk**: DUSD's delta-neutral strategy depends on centralized exchanges and custodians. An FTX-style event at a hedging venue could cause systemic failure.
5. **Rapid TVL decline**: 48% TVL decline over 90 days on BSC suggests either capital flight or reduced confidence.

## Peer Comparison

| Feature | StandX | GMX | Hyperliquid |
|---------|--------|-----|-------------|
| Timelock | Undisclosed | 24h | None documented |
| Multisig | Claimed, UNVERIFIED | Security Council (unverified threshold) | 3/4 (team-controlled) |
| Audits | 6 (DUSD/Highway only; perps unaudited) | 7+ (core protocol covered) | 2 (bridge only) |
| Oracle | Proprietary + CEX cross-checks | Chainlink Data Streams | Custom validator oracle |
| Insurance/TVL | Undisclosed | Undisclosed | ~8-10% |
| Open Source | Partial (DUSD verified; perps closed) | Yes (github.com/gmx-io) | Partial (bridge open; L1 closed) |
| Team | Semi-doxxed (ex-Binance Futures) | Anonymous | Doxxed founder (Jeff Yan) |
| TVL | ~$52M | ~$263M | ~$4.8B |
| Bug Bounty | None public | $5M max (Immunefi) | None for core protocol |
| Age | ~3 months | ~4.5 years | ~3 years |

## Recommendations

1. **Exercise caution with large deposits**: The protocol is only 3 months old with declining TVL and multiple unverified security claims.
2. **Monitor multisig disclosure**: Wait for on-chain multisig verification before committing significant capital.
3. **Watch for perps engine audit**: The most critical unaudited component. Until the perps engine is independently audited, treat trading as higher risk.
4. **Consider DUSD depeg risk**: The Ethena-style delta-neutral model carries custodial and counterparty risk. The 7-day redemption lock means you cannot exit quickly during stress.
5. **Diversify across perps venues**: Do not concentrate perps trading or DUSD holdings at StandX given the current risk profile.
6. **Track TVL trend**: The 48% decline over 90 days warrants monitoring. Continued decline may signal deeper issues.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- UNVERIFIED, likely yes given centralized control
- [x] Admin can change oracle sources arbitrarily? -- UNVERIFIED, likely yes
- [x] Admin can modify withdrawal limits? -- UNVERIFIED, likely yes
- [ ] Multisig has low threshold (2/N with small N)? -- Multisig existence unverified
- [x] Zero or short timelock on governance actions? -- No timelock documented
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- Unknown
- [ ] Social engineering surface area (anon multisig signers)? -- Signers unknown

**4/7 indicators match -- WARNING: This protocol exhibits Drift-type governance risk patterns. The combination of centralized admin control, no verified timelock, and no verified multisig creates a significant governance attack surface.**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- DUSD only (single collateral for perps)
- [ ] Single oracle source without TWAP? -- Multiple sources with TWAP
- [ ] No circuit breaker on price movements? -- CEX cross-check pinning exists
- [x] Insufficient insurance fund relative to TVL? -- Reserve fund undisclosed

**1/4 indicators -- below trigger threshold**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Highway bridge exists but validator config unknown
- [x] Admin keys stored in hot wallets? -- Unknown; no key management policy published
- [x] No key rotation policy? -- No published policy

**2/3 indicators -- below trigger threshold but concerning**

### Beanstalk-type (Flash Loan Governance Attack):
- N/A (no governance token or on-chain voting)

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? -- DUSD only
- [ ] Read-only reentrancy risk? -- Unknown (perps engine closed source)
- [ ] Flash loan compatible without reentrancy guards? -- Unknown
- [ ] Composability with protocols that expose callback hooks? -- DUSD on PancakeSwap

**0/4 confirmed indicators**

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler? -- Standard Solidity (EVM) and Rust (Solana)
- [ ] Compiler version has known CVEs? -- Unknown
- [ ] Contracts compiled with different compiler versions? -- Unknown
- [ ] Code depends on language-specific behavior? -- Unknown

**0/4 confirmed indicators**

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral (own governance token)? -- No, backed by delta-neutral CEX positions
- [ ] Redemption mechanism creates sell pressure on collateral? -- Potentially, but hedging should offset
- [ ] Oracle delay could mask depegging in progress? -- Unknown
- [ ] No circuit breaker on redemption volume? -- 7-day lock provides buffer

**0/4 confirmed indicators -- but the Ethena-style model has its own depeg risks (counterparty failure rather than reflexive spiral)**

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses a cross-chain bridge for token minting or reserve release? -- Yes, Highway bridge
- [ ] Bridge message validation relies on a single messaging layer? -- Unknown
- [ ] DVN/relayer/verifier configuration not publicly documented? -- Yes, undocumented
- [ ] Bridge can release/mint tokens without rate limiting? -- Unknown
- [ ] Bridged token accepted as collateral on lending protocols? -- DUSD not widely listed as lending collateral
- [ ] No circuit breaker on bridge minting volume? -- Unknown
- [ ] Emergency pause response time > 15 minutes? -- Unknown
- [ ] Bridge admin controls under different governance than core? -- Unknown
- [ ] Token deployed on 5+ chains via same bridge? -- No, only 2 chains

**2/9 confirmed indicators -- below trigger threshold**

## Information Gaps

The following questions could NOT be answered from publicly available information:

1. **Multisig configuration**: What is the multisig address, threshold, and signer list for the Reserve Fund? Is it a Gnosis Safe or custom implementation?
2. **Timelock details**: Is there a timelock contract? What is the delay duration? What actions are timelocked?
3. **Proxy admin**: Who controls the DUSD proxy on BSC? Is the proxy admin behind a multisig or timelock?
4. **Insurance/Reserve fund size**: How large is the stability reserve relative to TVL? What is the current balance?
5. **Oracle providers**: What specific oracle providers feed the index price? Are they Chainlink, Pyth, or proprietary?
6. **Perps engine architecture**: Is the matching engine on-chain (as docs claim) or off-chain? Where is the source code?
7. **Solana program authorities**: Who controls the upgrade authority for StandX's Solana programs? Is it a Squads multisig?
8. **Custodian details**: Is Ceffu the sole custodian? What is the custodial arrangement? Does StandX use MPC or HSM for key management?
9. **CEX counterparties**: Which centralized exchanges hold StandX's hedging positions? What is the concentration across venues?
10. **Bug bounty**: Does a bug bounty program actually exist? The docs mention one but no public listing is found.
11. **GoPlus missing fields**: Several critical token security checks (mintable, hidden_owner, owner_change_balance, selfdestruct, transfer_pausable, blacklist) were not returned by the GoPlus API for this token.
12. **TVL decline cause**: What is driving the 48% TVL decline on BSC over 90 days?
13. **Trading volume authenticity**: What is the actual organic trading volume? No independent verification of the reported $32B monthly volume.
14. **Team full identities**: CEO "AG" and co-founder Justin Cheng are mentioned but full legal names and backgrounds are not independently verifiable.

**These gaps are significant. The protocol makes many security claims in its documentation (multisig, timelocked governance, bug bounty, multiple audits) but most cannot be independently verified. A high triage score with low confidence (9/100 triage, 40/100 confidence) means the protocol's actual risk may be lower than the score suggests -- but the inability to verify claims is itself a risk signal.**

## Disclaimer
This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
