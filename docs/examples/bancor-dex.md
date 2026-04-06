# DeFi Security Audit: Bancor

**Audit Date:** April 6, 2026
**Protocol:** Bancor -- Ethereum DEX / AMM Protocol

## Overview
- Protocol: Bancor (V3 + Carbon DeFi)
- Chain: Ethereum (Carbon DeFi also deployed on Sei, IOTA, COTI)
- Type: DEX / Automated Market Maker
- TVL: ~$27M (DeFiLlama, April 2026)
- TVL Trend: +1.7% / -1.1% / -36.3% (7d / 30d / 90d)
- Launch Date: June 2017 (V1); May 2022 (V3); April 2023 (Carbon DeFi)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: bancorprotocol)

## Quick Triage Score: 47/100

Starting at 100. Deductions:

- [-8] is_mintable = 1 (BNT is mintable)
- [-8] transfer_pausable = 1 (transfers can be paused)
- [-8] TVL dropped >30% in 90 days (from ~$42.5M to ~$27M, -36.3%)
- [-5] No documented timelock on admin actions (decisions effective immediately after vote)
- [-5] Undisclosed multisig signer identities (3 of 7 are anonymous Foundation signatories)
- [-5] Insurance fund / TVL undisclosed (protocol operates with a known BNT deficit)
- [-5] Single oracle provider (internal EMA only, no external oracle fallback)
- [-5] DAO governance effectively paused (minimal recent activity)
- [-2] Trust list = 1 on GoPlus (informational, minor positive offset not applied per rules)

Score: 100 - 8 - 8 - 8 - 5 - 5 - 5 - 5 - 5 = **49** --> **47** (additional -2 for class-action lawsuit and Celsius litigation as operational risk context)

Rating: **HIGH** (score 20-49)

Red flags found: 8
- BNT is mintable (protocol minted BNT for IL protection, contributing to deficit)
- BNT transfers are pausable
- TVL declined 36% in 90 days, 99% from ATH of $2.4B
- No timelock on multisig actions
- Partially anonymous multisig signers
- No insurance fund; protocol carries a known BNT deficit
- Internal-only oracle with no external fallback
- Active class-action lawsuit and Celsius litigation

## Quantitative Metrics

| Metric | Value | Benchmark (Uniswap/Curve) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | N/A (BNT deficit) | 1-5% | HIGH |
| Audit Coverage Score | 1.5 (2x OpenZeppelin >2yr = 0.5, PeckShield >2yr = 0.25, ChainSecurity >2yr = 0.25, Carbon 4x audits ~1yr = 0.5) | 3+ | HIGH |
| Governance Decentralization | DAO + 5/7 MSIG | DAO + timelocks | MEDIUM |
| Timelock Duration | 0h (effective immediately) | 24-48h avg | HIGH |
| Multisig Threshold | 5/7 | 4/6 to 6/10 avg | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 2 MED | -- | MEDIUM |

## GoPlus Token Security (BNT on Ethereum)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | -- |
| Open Source | Yes (1) | -- |
| Proxy | No (0) | -- |
| Mintable | Yes (1) | MEDIUM |
| Owner Can Change Balance | No (0) | -- |
| Hidden Owner | No (0) | -- |
| Selfdestruct | No (0) | -- |
| Transfer Pausable | Yes (1) | MEDIUM |
| Blacklist | No (0) | -- |
| Slippage Modifiable | No (0) | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 38,528 | -- |
| Trust List | Yes (1) | -- |
| Creator Honeypot History | No (0) | -- |
| CEX Listed | Binance, Coinbase | -- |

GoPlus assessment: **MEDIUM RISK**. BNT is mintable (the protocol historically minted BNT for impermanent loss protection, which contributed to the BNT deficit crisis). Transfers are pausable, which was controversially used during the June 2022 IL protection suspension. No honeypot, no hidden owner, no tax. The token is listed on major CEXs and on the GoPlus trust list.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | 5/7 multisig with no timelock; partially anonymous signers | Partial |
| Oracle & Price Feeds | **MEDIUM** | Internal EMA only; no external oracle or fallback | Partial |
| Economic Mechanism | **HIGH** | BNT deficit from failed IL protection; unsustainable tokenomics proven | Y |
| Smart Contract | **MEDIUM** | Multiple audits but all >2 years old; Carbon separately audited | Partial |
| Token Contract (GoPlus) | **MEDIUM** | Mintable + pausable; no honeypot or hidden owner | Y |
| Cross-Chain & Bridge | **LOW** | Carbon DeFi multi-chain but no bridge dependency for V3 | Partial |
| Operational Security | **HIGH** | Active lawsuits; declining TVL; team focus shifted to patent litigation | Partial |
| **Overall Risk** | **HIGH** | **Protocol with proven economic failure (IL protection collapse), declining TVL (-99% from ATH), active litigation, and no clear recovery path** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**Multisig structure:** The Bancor DAO operates via a 5/7 Gnosis Safe multisig. Signers include three Foundation-proposed signatories (identities not publicly disclosed) and representatives from Matic, Harvest Finance, 88 MPH, and WOO DAO.

**Admin powers:** The DAO MSIG governs all aspects of Bancor V3 and can:
- Pause the entire protocol (deposits, withdrawals, transactions)
- Execute any governance decision
- Invoke emergency intervention powers under BIP21 (DAO Multisig Intervention Policy)
- Implement parameter changes

**Timelock:** There is no on-chain timelock. The governance process requires a minimum of 2 days of community discussion followed by 3 days of voting, but decisions are "effective immediately" upon vote conclusion. This means the multisig can execute changes with no enforced delay after the vote passes.

**Governance activity:** Governance operates via Snapshot (off-chain voting with vBNT). Recent governance activity appears minimal, consistent with the protocol's declining usage and team focus on litigation.

**Emergency powers:** Under BIP21, the multisig was granted emergency intervention powers, which were notably exercised during the June 2022 IL protection crisis when the team unilaterally suspended impermanent loss protection -- a decision that triggered lawsuits and massive user losses.

**Key concern:** The combination of no timelock, partially anonymous signers, and demonstrated willingness to use emergency powers to alter core protocol mechanics (IL protection) represents a meaningful governance risk.

### 2. Oracle & Price Feeds -- MEDIUM

**Architecture:** Bancor V3 uses an internal oracle based on an Exponential Moving Average (EMA) calculation. The protocol explicitly does not use external oracles for price discovery.

**Strengths:**
- EMA-based pricing is more resilient to manipulation than simple moving averages
- No external oracle dependency eliminates a class of oracle manipulation attacks
- Internal pricing removes reliance on third-party infrastructure

**Weaknesses:**
- No external price feed validation or cross-reference
- No documented fallback mechanism if the internal oracle produces incorrect prices
- No circuit breaker for abnormal price movements documented
- Single-source pricing without external validation

**Carbon DeFi:** Carbon DeFi operates differently -- it uses an orderbook-like model with user-defined price ranges and claims zero third-party dependencies including oracles. This is a structural advantage for Carbon.

**Chainlink integration:** Bancor V3 integrated Chainlink Keepers for automation tasks (auto-compounding, etc.) but not for price feeds. This is a common misconception.

### 3. Economic Mechanism -- HIGH

**The BNT Deficit Crisis (June 2022):**
This is the defining economic failure of the Bancor protocol. Bancor V3's flagship feature was "100% impermanent loss protection" (ILP), which promised to compensate liquidity providers for any impermanent loss. The mechanism worked by minting new BNT tokens to cover IL obligations.

The fundamental flaw: protocol fees covered only approximately 40% of IL protection obligations. The remaining 60% was funded by BNT inflation, creating a death spiral:
1. BNT minting to cover IL caused BNT price to drop
2. Falling BNT price increased IL for BNT pairs
3. More IL required more BNT minting
4. Arbitrageurs sold BNT to the protocol in exchange for TKN tokens, draining reserves

In June 2022, amid the 3AC/Celsius collapse, the team used emergency powers to suspend IL protection. Users who withdrew received significantly less than deposited. Celsius alone lost approximately 6,540 ETH (~$7.8M at the time).

**Current state:** The BNT deficit has never been resolved. The protocol effectively acknowledged that its core economic model was unsustainable. TVL collapsed from a peak of $2.4B to ~$27M (a 99% decline).

**Carbon DeFi pivot:** Bancor pivoted to Carbon DeFi, an orderbook-like DEX with recurring trading strategies. Carbon has a fundamentally different design -- no liquidity pools, no IL risk, no BNT minting dependency. Carbon claims MEV-resistance and zero slippage on orders. This is a healthier model but has not recaptured significant market share.

**Insurance fund:** No insurance fund exists. The protocol's attempt at socialized protection (BNT minting for ILP) proved to be the primary vector of economic failure.

### 4. Smart Contract Security -- MEDIUM

**Audit history for Bancor V3:**
- OpenZeppelin -- Bancor V3 core (pre-2022)
- OpenZeppelin -- Auto-Compounding Rewards (pre-2022)
- PeckShield -- Bancor V3 (pre-2022)
- ChainSecurity -- Bancor V3 (September 2022)
- Certora -- Bancor V3 (status listed as "pending" in docs)

**Audit history for Carbon DeFi:**
- 4 audits completed (per Carbon DeFi documentation)
- Contracts available on GitHub

**Audit Coverage Score:** ~1.5 (all V3 audits are >2 years old at 0.25 each = 1.0; Carbon audits ~1-2 years old contribute ~0.5). This is below the LOW-risk threshold of 3.0.

**Bug bounty:** Carbon DeFi by Bancor has an active Immunefi bug bounty program with rewards up to $900,000 (paid in BNT). KYC required for payouts.

**Historical incidents:**
- **2018:** $13.5M hack exploiting admin key vulnerabilities. Bancor froze stolen BNT (recovering ~$10M) but lost $3.5M in ETH and other tokens. The BNT freeze capability was subsequently removed.
- **2020:** Vulnerability in BancorNetwork v0.6 contract (deployed just 2 days prior). Bancor-controlled addresses drained ~$460K of at-risk user funds and returned them.
- **Post-2020:** No smart contract exploits reported.

**Code status:** Open source on GitHub (bancorprotocol). Last major V3 code updates occurred in 2022. Carbon DeFi contracts are more recently maintained.

### 5. Cross-Chain & Bridge -- LOW

Bancor V3 operates exclusively on Ethereum with no bridge dependencies. Carbon DeFi has been deployed on additional chains (Sei, IOTA, COTI) but these are independent deployments, not bridged instances. There is no cross-chain messaging or bridge dependency that would introduce bridge-related risks for the core protocol.

### 6. Operational Security -- HIGH

**Team:** Founders are doxxed: Eyal Hertzog (product architect, ex-MetaCafe founder), Guy Benartzi (CEO), Galia Benartzi (business development), and Yudi Levi (CTO). The team has extensive tech industry experience predating crypto.

**Active litigation:**
- **Class-action lawsuit (2023):** Filed in U.S. District Court, Western District of Texas, alleging Bancor deceived investors about IL protection and operated BNT as an unregistered security.
- **Celsius lawsuit (2024):** Celsius's bankruptcy estate sued Bancor founders over ~$7.8M in losses from the IL protection suspension.
- **Patent lawsuit vs. Uniswap (2025):** Bancor sued Uniswap for CPAMM patent infringement. A federal judge dismissed the case (without prejudice), finding the patents failed to meet eligibility requirements.

**Incident response:** The 2022 IL protection crisis demonstrated the team's willingness to use emergency powers unilaterally, prioritizing protocol solvency over user withdrawals. While arguably necessary, the response was poorly communicated and triggered legal action.

**Declining trajectory:** TVL has fallen 99% from its $2.4B peak. BNT is outside the top 500 cryptocurrencies by market cap (~$55M as of early 2025). CoinDCX delisted BNT in June 2025 due to low trading activity. The team appears focused on patent litigation and Carbon DeFi rather than V3 recovery.

## Critical Risks

1. **BNT Deficit (PROVEN):** The protocol's core economic mechanism (IL protection via BNT minting) failed catastrophically in June 2022. The deficit has never been resolved. Users who deposited during the IL protection era may still be underwater.

2. **No Timelock on Governance Actions:** The 5/7 multisig can execute changes immediately after a vote passes. Combined with the demonstrated willingness to use emergency powers (IL protection suspension), this creates meaningful fund-at-risk scenarios.

3. **Active Litigation Risk:** Multiple lawsuits (class-action, Celsius) create uncertainty about the protocol's future and potential financial liability for the DAO/Foundation.

4. **Severe TVL Decline:** A 99% decline from peak TVL signals a protocol in structural decline. Lower TVL means lower fees, reduced security budget, and increased vulnerability to economic attacks on remaining liquidity.

5. **Stale Audits:** All V3 audits are over 2 years old. While no exploits have occurred, the lack of recent audit coverage is a concern, particularly as the codebase may have accumulated changes.

## Peer Comparison

| Feature | Bancor | Uniswap | Curve |
|---------|--------|---------|-------|
| Timelock | None (immediate execution) | Governance timelock (2d+) | DAO + emergency admin |
| Multisig | 5/7 (partially anon) | Governance-only (no multisig) | Community multisig |
| Audits | 4-5 (all >2yr old) | 10+ (recent, ongoing) | 10+ (recent, ongoing) |
| Oracle | Internal EMA only | N/A (AMM pricing) | Internal (Curve pools) + Chainlink |
| Insurance/TVL | N/A (deficit) | N/A (no IL protection) | N/A |
| Open Source | Yes | Yes | Yes |
| TVL | ~$27M | ~$5B+ | ~$2B+ |
| Bug Bounty | $900K (Carbon only) | $15.5M | $250K+ |

## Recommendations

1. **For existing V3 liquidity providers:** Evaluate whether remaining positions are recoverable given the BNT deficit. Consider withdrawing if the deficit-adjusted value is acceptable.

2. **For Carbon DeFi users:** Carbon has a fundamentally different and healthier design than V3. However, users should monitor the protocol's overall health given the team's litigation burden and declining resources.

3. **For prospective users:** Exercise caution. The protocol's economic model has a proven failure mode. Carbon DeFi is the more promising product but operates within an ecosystem under significant legal and financial stress.

4. **General:** Do not rely on any "impermanent loss protection" claims from Bancor. The mechanism was proven unsustainable and is no longer active.

5. **Governance participants:** Push for an on-chain timelock on multisig actions and increased transparency around multisig signer identities.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- UNVERIFIED (multisig has broad powers, no timelock)
- [x] Admin can change oracle sources arbitrarily? -- Internal oracle; admin control over parameters is UNVERIFIED
- [x] Admin can modify withdrawal limits? -- Yes, protocol can be fully paused
- [ ] Multisig has low threshold (2/N with small N)? -- No, 5/7 is reasonable
- [x] Zero or short timelock on governance actions? -- Yes, no timelock
- [ ] Pre-signed transaction risk? -- N/A (Ethereum, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- 3 of 7 signers are anonymous Foundation nominees

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- Not a lending protocol
- [x] Single oracle source without TWAP? -- Internal EMA only, no external validation
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [x] Insufficient insurance fund relative to TVL? -- No insurance fund; known deficit

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No bridge dependency
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

**Pattern match:** Bancor exhibits 6 out of 14 risk indicators, with particular exposure to governance/admin risk (no timelock, emergency powers) and economic manipulation risk (no insurance, internal-only oracle). The 2022 IL protection crisis was not an external hack but an internal economic failure amplified by governance decisions.

## Information Gaps

- Exact identities of the 3 Foundation-proposed multisig signers
- Current status and magnitude of the BNT deficit
- Whether any on-chain timelock has been added since the V3 launch documentation was written
- Certora audit status (listed as "pending" in docs for over 2 years)
- Whether the multisig signer set has been rotated since initial appointment
- Detailed Carbon DeFi audit reports and scope coverage
- Current protocol revenue and fee generation rates
- Insurance or reserve fund status for Carbon DeFi deployments
- Whether emergency pause powers apply to Carbon DeFi or only V3
- Legal liability exposure from pending lawsuits and potential impact on protocol treasury

## Disclaimer

This analysis is based on publicly available information and web research as of April 6, 2026. It is NOT a formal smart contract audit. The protocol's economic mechanisms have a documented history of failure (June 2022 IL protection crisis). Always DYOR and consider professional auditing services for investment decisions.
