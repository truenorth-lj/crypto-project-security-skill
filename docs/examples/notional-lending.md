# DeFi Security Audit: Notional Finance

**Audit Date:** April 6, 2026
**Protocol:** Notional Finance -- Fixed-rate lending protocol (DEFUNCT as of November 2025)

## Overview
- Protocol: Notional Finance (V3)
- Chain: Ethereum, Arbitrum
- Type: Fixed-Rate Lending / Leveraged Yield Vaults
- TVL: ~$843 (effectively $0; protocol wound down November 2025)
- TVL at Peak: ~$548M (March 2024)
- TVL Trend: -100% / -100% / -100% (7d / 30d / 90d -- protocol is dead)
- Launch Date: March 2021 (V1), November 2021 (V2), November 2023 (V3)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub)
- Status: **DEFUNCT** -- V3 wound down after Balancer V2 exploit (November 3, 2025). Successor product "Notional Exponent" launched January 26, 2026.

## Quick Triage Score: 17/100

Starting at 100. Deductions:

CRITICAL flags:
- [x] TVL = $0 (-25)

HIGH flags:
- None from GoPlus

MEDIUM flags:
- [x] GoPlus: is_proxy = 1 AND no timelock on upgrades (3/5 multisig, no timelock deployed) (-8)
- [x] TVL dropped > 30% in 90 days (dropped 100%) (-8)
- [x] Multisig threshold < 3 signers -- threshold is 3/5 but see note (-0, threshold meets minimum)

LOW flags:
- [x] No documented timelock on admin actions (-5)
- [x] No bug bounty program for V3 (V3 is defunct; Exponent has one) (-5)
- [x] Single oracle provider (Chainlink primary) (-5)
- [x] Insurance fund / TVL < 1% -- reserves were ~$484K total vs ~$50M TVL at time of hack (-5)
- [x] Undisclosed multisig signer identities (3 of 5 are "community members", not publicly named) (-5)
- [x] DAO governance paused or dissolved (V3 wound down) (-5)
- [x] GoPlus: is_blacklisted -- not flagged (-0)

Additional mechanical deductions:
- [x] Protocol is dead/defunct (equivalent to TVL = $0, already counted) (-0)
- [x] Historical exploit with user fund loss (Balancer hack) -- captured via TVL drop (-0)

**Score: 100 - 25 - 8 - 8 - 5 - 5 - 5 - 5 - 5 - 5 = 29 (HIGH risk)**

Adjusted to 17 given the protocol is fully defunct with confirmed user losses (56% haircut on Mainnet ETH lenders). The mechanical score of 29 understates the severity because the triage formula does not have a dedicated deduction for "protocol suffered exploit resulting in permanent shutdown and user fund losses."

**Final Triage Score: 17/100 -- CRITICAL**

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | ~0.5% at time of hack (~$484K vs ~$50M TVL) | 1-5% (Aave ~2%) | HIGH |
| Audit Coverage Score | 2.5 (2x Sherlock 2023, 1x OZ 2021) | >= 3.0 = LOW | MEDIUM |
| Governance Decentralization | 3/5 multisig, no timelock deployed | DAO + timelock avg | HIGH |
| Timelock Duration | 0h (no timelock deployed) | 24-48h avg | CRITICAL |
| Multisig Threshold | 3/5 | 3/5 avg | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 1 MED (proxy) | -- | LOW |

**Audit Coverage Score Calculation:**
- OpenZeppelin V1/V2 audit (2021) -- >4 years old: 0.25
- Sherlock V3 contest (March 2023) -- ~3 years old: 0.25
- Sherlock V3 contest (October 2023) -- ~2.5 years old: 0.25
- Sherlock V3 Update 5 (December 2023) -- ~2.3 years old: 0.25
- Code4rena V2 contest (2021/2022) -- >3 years old: 0.25
- Total: ~1.25 (recency-adjusted) -- below 1.5 threshold = **HIGH risk**

Revised to 1.25 with strict recency weighting. All audits are over 2 years old.

## GoPlus Token Security (NOTE on Ethereum)

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
| Holders | 1,790 | LOW (thin holder base) |
| Trust List | Not flagged | -- |
| Creator Honeypot History | No | -- |

GoPlus assessment: **LOW RISK** on the token contract itself. The only flag is the proxy (upgradeable) pattern, which is expected for a governance token. However, DEX liquidity is essentially zero (UniV2 liquidity: $0.00068, UniV3 liquidity: near zero). The NOTE token is effectively illiquid. Top holder controls 29.2% of supply (contract), second holder (Balancer vault) holds 20.1%.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **HIGH** | 3/5 multisig with no timelock; 2 founders + 3 unnamed community signers | Partial |
| Oracle & Price Feeds | **MEDIUM** | Chainlink primary with custom fCash oracle rate; no manipulation incidents pre-hack | Partial |
| Economic Mechanism | **CRITICAL** | Leveraged vaults created catastrophic composability risk; insufficient reserves for bad debt | Y |
| Smart Contract | **MEDIUM** | Multiple audits but all >2 years old; V3 code not re-audited for Balancer integration changes | Partial |
| Token Contract (GoPlus) | **LOW** | Proxy pattern only flag; zero DEX liquidity is a concern | Y |
| Cross-Chain & Bridge | **MEDIUM** | Deployed on Ethereum + Arbitrum; shared admin key across chains | Partial |
| Operational Security | **MEDIUM** | Doxxed founders, rapid incident response (2:52 AM detection), but insufficient insurance | Y |
| **Overall Risk** | **CRITICAL** | **Protocol is defunct. V3 shut down after Balancer V2 exploit caused ~721.6 ETH bad debt. Mainnet ETH lenders took 56% haircut. Leveraged vault users lost 100%.** | |

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Multisig Configuration:**
- 3/5 multisig controls protocol upgrades and parameter changes
- 2 signers are founders (Teddy Woodward and Jeff Wu)
- 3 signers are "community members" whose identities are not publicly disclosed
- Founders hold 2 of 3 required signatures, meaning only 1 community signer needs to agree

**Timelock:**
- No timelock was ever deployed for Notional V2 or V3
- The team stated plans to "gradually decentralize" to a Timelock + Governor Alpha system, but this was never implemented before the protocol's shutdown
- On-chain governance existed with a 2-day review period + 3-day voting period + 2-day timelock queue (totaling ~1 week), but the multisig retained the ability to bypass this for emergencies

**Governance Process:**
- Snapshot voting for non-emergency decisions
- On-chain governance proposals require 4,000,000 NOTE votes and majority
- Multisig committed to only act on successful snapshot votes OR emergency situations
- In practice, the multisig paused the entire protocol unilaterally during the Balancer hack (appropriate emergency use)

**Risk Assessment:** The absence of a timelock on the 3/5 multisig is a significant governance weakness. While the founders are doxxed and acted responsibly during the hack, the architecture allowed instant protocol changes without delay. This is below industry standard for a protocol that held >$500M TVL at peak.

### 2. Oracle & Price Feeds -- MEDIUM

**Oracle Architecture:**
- Chainlink price feeds for collateral valuation on Ethereum and Arbitrum
- Custom "oracle rates" for fCash valuation: lagged, dampened rates that converge to last traded interest rate over a time window
- The fCash oracle design was specifically built to resist price manipulation by using time-weighted convergence rather than spot prices

**Strengths:**
- Chainlink is industry standard
- fCash oracle rate design provides manipulation resistance
- No known oracle manipulation exploit occurred

**Weaknesses:**
- Single oracle provider (Chainlink) -- no fallback documented
- Admin (multisig) could change oracle sources without timelock
- The Balancer hack bypassed oracle protections entirely by attacking the underlying collateral pool rather than the oracle itself

### 3. Economic Mechanism -- CRITICAL

**fCash Fixed-Rate System:**
- fCash tokens represent fixed-rate lending/borrowing positions at specific maturities
- Novel AMM design for interest rate discovery
- Maturity rollover risk: positions must be rolled at maturity, creating periodic liquidity pressure

**Prime Cash System (V3):**
- Variable-rate lending layer that deployed idle funds to external protocols (Aave, Compound) for yield
- Created composability dependency: Notional's solvency partially depended on external protocols

**Leveraged Vaults -- THE CRITICAL FAILURE:**
- Leveraged vaults allowed users to take leveraged positions in Balancer V2 and Curve LP pools
- Notional lent funds to vault users who deployed them into external LP positions
- When Balancer V2 was hacked on November 3, 2025, collateral in affected vaults went to zero instantly
- Affected vaults: rETH/WETH, wstETH/WETH, rsETH/WETH (Arbitrum); ezETH/WETH, rsETH/WETH (Mainnet)
- Total bad debt: ~721.6 ETH (~632.8 ETH Mainnet + ~80.2 ETH Arbitrum)

**Insurance / Reserves -- Grossly Insufficient:**
- ETH reserves: ~$100K (Mainnet) + ~$18K (Arbitrum) = ~$118K
- Non-ETH reserves: ~$205K (Mainnet) + ~$161K (Arbitrum) = ~$366K
- Total reserves: ~$484K against bad debt of ~721.6 ETH (~$2.5M+ at ETH prices)
- Insurance/TVL ratio at time of hack: ~0.5% (vs industry benchmark of >5%)
- Result: Mainnet ETH lenders took 56.019% haircut; Arbitrum ETH lenders took 19.244% haircut
- Leveraged vault users lost 100% of their positions

**Socialized Loss Mechanism:**
- sNOTE (staked NOTE in 80/20 NOTE/WETH Balancer LP) was designed as backstop
- In a shortfall, governance could vote to take 50% of sNOTE pool assets to recapitalize
- This mechanism was never invoked during the Balancer hack -- reserves were simply distributed and the protocol was shut down

### 4. Smart Contract Security -- MEDIUM

**Audit History:**
- OpenZeppelin: V1/V2 audit (2021) -- found vulnerabilities in ERC20/ERC777 handling
- Code4rena: V2 contest (August 2021)
- Sherlock: V3 audit contest (March 2023) -- leveraged vault integrations
- Sherlock: V3 contest (October 2023) -- core protocol
- Sherlock: V3 Update 5 (December 2023) -- incremental changes
- Sherlock: Notional Exponent (June 2025) -- successor product

**Vulnerability History:**
- March 2023: Critical vulnerability in V2 discovered that could allow draining of protocol funds. Patched before exploitation. No funds lost.
- nToken redemption bug: Discovered and patched via bug bounty (resulted in $1M Immunefi payout).
- November 2025: Balancer V2 hack caused leveraged vault collateral to go to zero. While not a Notional smart contract bug per se, the composability dependency was the root cause of fund losses.

**Bug Bounty:**
- Immunefi program active for Notional V3 (now defunct)
- Critical payout: 10% of economic damage, minimum $50K
- Notional Exponent: separate program, up to $250K for critical bugs
- Historical $1M payout demonstrates program credibility

**Open Source:** Yes, all contracts on GitHub.

### 5. Cross-Chain & Bridge -- MEDIUM

**Multi-Chain Deployment:**
- Deployed on Ethereum (mainnet) and Arbitrum
- Same 3/5 multisig controlled both deployments
- Risk parameters were configured independently per chain

**Bridge Dependency:**
- Arbitrum uses the canonical Arbitrum bridge (native rollup bridge)
- No third-party bridge dependency for core operations
- Cross-chain governance relied on the same multisig rather than message passing

**Impact During Hack:**
- Both chains were affected simultaneously by the Balancer exploit
- Team paused both deployments using the same multisig
- Different loss magnitudes: Mainnet (56% haircut) vs Arbitrum (19% haircut) due to different vault compositions

### 6. Operational Security -- MEDIUM

**Team:**
- Teddy Woodward (Co-Founder): Background in traditional finance (Ayanda Capital, Barclays Investment Bank, Chicago Trading Company). LSE graduate. Fully doxxed via LinkedIn.
- Jeff Wu (Co-Founder): Fully doxxed via LinkedIn. Engineering background.
- Company: Based in Emeryville, CA. Series A funded (Crunchbase).
- Previous project track record: No known prior security incidents before Notional.

**Incident Response (Balancer Hack):**
- Detection at 2:52 AM ET on November 3, 2025 via monitoring systems
- Disabled all Balancer vaults promptly
- Fully paused protocol on both Mainnet and Arbitrum
- Transparent post-mortem published on blog and X/Twitter
- Decided to wind down rather than attempt restart with bad debt
- Users with cross-currency borrowing positions auto-migrated to Aave
- Response was professional and timely, but reserves were insufficient to prevent user losses

**Dependencies:**
- Balancer V2 (leveraged vaults) -- THIS WAS THE FATAL DEPENDENCY
- Curve (leveraged vaults)
- Chainlink (oracle feeds)
- External lending protocols (Aave, Compound) for Prime Cash idle fund deployment

## Critical Risks

1. **PROTOCOL IS DEFUNCT**: Notional V3 was permanently shut down in November 2025. TVL is effectively $0. Users should not deposit funds.
2. **Balancer V2 Composability Failure**: Leveraged vaults created a direct dependency on Balancer V2. When Balancer was hacked, Notional vault collateral went to zero, creating ~721.6 ETH of bad debt.
3. **Insufficient Insurance Reserves**: ~$484K in reserves against ~$2.5M+ in bad debt. Mainnet ETH lenders lost 56% of their assets. Leveraged vault users lost 100%.
4. **No Timelock**: Despite years of operation and >$500M peak TVL, Notional never deployed a timelock on its multisig. This was below industry standard.
5. **Concentrated Multisig**: 3/5 threshold where 2 signers are founders means only 1 additional signer needed for any action.

## Peer Comparison

| Feature | Notional V3 (defunct) | Aave V3 | Compound V3 |
|---------|----------------------|---------|-------------|
| Timelock | None (planned, never deployed) | 24h / 168h dual | 48h |
| Multisig | 3/5 (2 founders + 3 community) | 6/10 Guardian | 4/8 Community |
| Audits | 5+ (all >2 years old) | 9+ (recent) | 5+ (recent) |
| Oracle | Chainlink (single) | Chainlink + SVR fallback | Chainlink |
| Insurance/TVL | ~0.5% | ~2% (Safety Module) | ~1% |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | $50K-$1M (Immunefi) | $1M (Immunefi) | $150K (Immunefi) |
| Status | DEFUNCT | Active | Active |

## Recommendations

1. **Do NOT deposit funds into Notional V3.** The protocol is permanently shut down with TVL at $0.
2. **If you held positions at the time of the hack**, check the Notional blog and X/Twitter for fund distribution status and claims.
3. **For the NOTE token**: Exercise extreme caution. DEX liquidity is essentially zero. The token's future utility depends entirely on the Notional Exponent successor product.
4. **For Notional Exponent** (successor product launched January 2026): A separate audit should be conducted. While the team demonstrated strong incident response, the same governance weaknesses (multisig without timelock) may carry over. Verify whether Exponent has implemented a timelock and diversified away from single-protocol vault dependencies.
5. **General lesson for DeFi users**: Leveraged vault products that deploy capital into external protocols create hidden composability risk. A hack of ANY integrated protocol can cause cascading losses. Insurance reserves must be sized relative to worst-case composability failures, not just normal market conditions.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- YES (no timelock deployed)
- [ ] Admin can change oracle sources arbitrarily? -- Possible via multisig, but no timelock to bypass
- [x] Admin can modify withdrawal limits? -- YES (multisig controls parameters)
- [ ] Multisig has low threshold (2/N with small N)? -- 3/5 (borderline; 2 founders means effective threshold is lower)
- [x] Zero or short timelock on governance actions? -- YES (zero timelock)
- [ ] Pre-signed transaction risk? -- N/A (EVM, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- YES (3 of 5 signers unnamed)

**Drift-type risk: MEDIUM-HIGH** -- Governance controls were weak but the actual exploit came through composability, not governance.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [x] Low-liquidity collateral accepted? -- Leveraged vaults accepted LP tokens as collateral
- [ ] Single oracle source without TWAP? -- fCash used time-weighted oracle rates
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [x] Insufficient insurance fund relative to TVL? -- YES (~0.5% vs recommended >5%)

**Euler/Mango-type risk: MEDIUM** -- The actual exploit was a composability failure rather than oracle manipulation, but the insufficient insurance fund amplified losses.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Used canonical Arbitrum bridge
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

**Ronin/Harmony-type risk: LOW**

### Actual Attack Vector (Balancer V2 Composability Exploit):
The exploit that killed Notional V3 does not fit neatly into the three canonical patterns above. It represents a distinct attack category: **Composability Cascade Failure**. Notional's leveraged vaults held user funds in Balancer V2 LP positions. When Balancer V2 was hacked by a third party, all collateral in those LP positions went to zero. This created instant insolvency in Notional's vaults, which cascaded into bad debt for Notional's lending pools. The key lesson: even with sound governance and oracles, deep composability dependencies create systemic risk that insurance reserves must cover.

## Information Gaps

- Exact identities of the 3 non-founder multisig signers -- described only as "community members"
- Whether a timelock was ever seriously in development or remained permanently deferred
- Full breakdown of Sherlock audit finding counts (critical/high/medium) for each contest
- Whether sNOTE recapitalization mechanism was ever formally voted on during the Balancer hack wind-down
- Current status of any recovery efforts from the Balancer V2 hacker
- Whether Notional Exponent inherits the same governance architecture (no timelock, 3/5 multisig)
- Prime Cash external deployment percentages -- how much idle capital was lent to Aave/Compound vs held on Notional
- Circuit breaker configuration details for leveraged vault liquidations
- Key storage practices (hardware wallets, key rotation) for multisig signers

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.

**IMPORTANT: Notional V3 is a defunct protocol. It was permanently shut down in November 2025 following a Balancer V2 exploit that caused significant user losses. This audit is provided for historical and educational purposes only. Do not deposit funds.**
