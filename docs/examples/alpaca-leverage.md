# DeFi Security Audit: Alpaca Finance

## Overview
- Protocol: Alpaca Finance
- Chain: BNB Chain (BSC), Fantom
- Type: Leveraged Yield Farming / Lending / Perpetual Futures
- TVL: $41,360,060 (BSC: $41.36M, Fantom: $3K) as of 2026-04-06
- TVL Trend: -1.1% (7d) / -4.6% (30d) / -28.8% (90d)
- Launch Date: Q1 2021 (fair launch)
- Audit Date: 2026-04-06
- Source Code: Open (GitHub: alpaca-finance)
- Token: ALPACA (BEP-20, 0x8F0528cE5eF7B51152A59745bEfDD91D97091d2F on BSC)

**CRITICAL CONTEXT: Alpaca Finance announced on May 26, 2025 that it will shut down operations by end of 2025. Leveraged yield farming positions were auto-closed by June 30, 2025. The perpetual futures exchange (Alperp) was set to reduce-only mode. Front-end access and withdrawals remain available until December 31, 2025. The protocol cited sustained operating losses for over two years and the Binance ALPACA delisting in May 2025 as proximate causes. As of April 2026, the protocol appears to still have ~$41M TVL on BSC, which may represent residual or locked positions.**

## Quick Triage Score: 19

Red flags found: 7

Calculation (mechanical, per scoring rubric):

CRITICAL flags:
- [x] GoPlus: owner_change_balance = 1 -- owner can modify token balances (-25)

HIGH flags:
- [x] Zero audits listed on DeFiLlama (-15) -- NOTE: Alpaca claims 23 audits from Certik, PeckShield, SlowMist, Inspex, BlockSec, etc. DeFiLlama metadata is incomplete. Actual audit count is strong.
- [x] Anonymous team with no prior track record (-15)

MEDIUM flags:
- [x] GoPlus: is_mintable = 1 (-8)
- [x] Multisig threshold < 3 signers (reported as fewer than 4) (-8)

LOW flags:
- [x] Undisclosed multisig signer identities (-5)
- [x] Insurance fund / TVL undisclosed (-5)

Score: 100 - 25 - 15 - 15 - 8 - 8 - 5 - 5 = 19 (CRITICAL by formula)

**Important caveat**: The mechanical score of 19 is heavily penalized by DeFiLlama showing 0 audits, which is a metadata gap -- Alpaca actually has one of the most extensive audit histories in BSC DeFi (~23 audits). Without this false flag, the score would be 34 (HIGH). The protocol shutdown announcement is the dominant real-world risk factor and is not captured by the scoring rubric.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Not publicly disclosed; revenue-based backstop | Venus: dedicated fund; Beefy: per-vault safety scores | HIGH |
| Audit Coverage Score | 3.0+ (see below) | Venus: ~3.5; Beefy: ~2.0 | LOW |
| Governance Decentralization | Snapshot + Timelock + dev multisig | Venus: on-chain VIP governance | MEDIUM |
| Timelock Duration | 24h | Venus: 48h (Normal), 6h (Fast-track) | MEDIUM |
| Multisig Threshold | <4 signers (UNVERIFIED exact config) | Venus: Guardian multisig + timelock | HIGH |
| GoPlus Risk Flags | 1 HIGH (owner_change_balance) / 1 MED (mintable) | -- | HIGH |

**Audit Coverage Score Calculation:**
- Certik (multiple audits, 2021-2022): 0.25 x 3 = 0.75 (>2 years old)
- PeckShield (v1.0, 2021): 0.25 (>2 years old)
- SlowMist (multiple, 2021-2022): 0.25 x 2 = 0.50 (>2 years old)
- Inspex (multiple, 2021-2023): 0.25 x 2 + 0.5 x 2 = 1.50
- BlockSec (Delta Neutral Vault, ~2023): 0.5 (1-2 years old)
- Other auditors (est. 8-10 additional): ~1.5 estimated
- Total estimate: ~5.0+ (LOW risk -- excellent audit coverage historically)
- Note: No audits appear to have been conducted after 2023, and the protocol is now in shutdown mode

## GoPlus Token Security (BSC, Chain ID 56)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | LOW |
| Open Source | Yes (1) | LOW |
| Proxy | No (0) | LOW |
| Mintable | Yes (1) | MEDIUM |
| Owner Can Change Balance | Yes (1) | HIGH |
| Hidden Owner | No (0) | LOW |
| Selfdestruct | No (0) | LOW |
| Transfer Pausable | No (0) | LOW |
| Blacklist | No (0) | LOW |
| Slippage Modifiable | No (0) | LOW |
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 82,119 | LOW |
| Trust List | Yes (1) | LOW |
| Creator Honeypot History | No (0) | LOW |
| CEX Listed | Yes (Binance -- note: delisted May 2025) | MEDIUM |

**Top Holder Analysis** (from GoPlus):
- #1 (18.7%): 0x0000...dead (burn address, locked) -- deflationary burn mechanism
- #2 (8.5%): 0xf3ce...3083 (PancakeV1 LP contract) -- liquidity
- #3 (6.8%): 0x91dc...dc92 (EOA) -- whale, not locked
- #4 (5.1%): 0x1099...e43 (PancakeV2 LP contract) -- liquidity
- #5 (2.6%): 0xa227...d8 (EOA) -- whale, not locked
- Top 5 control ~41.7% of supply; ~18.7% is burned, ~13.6% in LP contracts, ~9.4% in EOA wallets
- Two large EOA holders (~9.4% combined) represent moderate whale concentration risk

**Creator Address Security Check** (0xc44f82b07ab3e691f826951a6e335e1bc1bb0b51):
- All flags clean: no cybercrime, phishing, sanctions, or malicious contract creation detected

**Key concern**: owner_change_balance = 1 means the token owner address (0xa625ab01b08ce023b2a342dbb12a16f2c8489a8f, a contract holding ~0.2% of supply) has the ability to modify balances. This is a significant centralization risk, though the owner is a contract (likely the Timelock or governance contract) rather than an EOA.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | HIGH | Anonymous team, small multisig (<4 signers), 24h timelock; protocol shutting down | Partial |
| Oracle & Price Feeds | LOW | Chainlink integration for LYF; Pyth for perps; Alpaca Guard anti-manipulation | Partial |
| Economic Mechanism | HIGH | Protocol in shutdown; leveraged positions auto-closed; residual TVL at wind-down risk | Partial |
| Smart Contract | LOW | 23 audits, 4+ years battle-tested, open source, no direct exploits | Partial |
| Token Contract (GoPlus) | HIGH | owner_change_balance = 1; mintable; Binance delisted | Y |
| Cross-Chain & Bridge | LOW | Minimal cross-chain (BSC + Fantom independently deployed; no bridge dependency) | Partial |
| Operational Security | CRITICAL | Protocol announced shutdown; team winding down; no future maintenance expected | Partial |
| **Overall Risk** | **HIGH** | **Protocol is in active wind-down with Dec 2025 deadline. Residual TVL at elevated counterparty risk. Strong historical security record undermined by shutdown status.** | |

## Detailed Findings

### 1. Governance & Admin Key

**Admin Key Surface Area:**
- The Timelock contract (0x2D5408f2287BF9F9B05404794459a846651D0a59) owns all major protocol contracts
- 24-hour delay on all admin actions passing through Timelock
- Dev multisig controls submissions to Timelock
- Multisig reportedly has fewer than 4 signers (exact threshold UNVERIFIED)
- Admin can: pause contracts, modify parameters, upgrade proxy contracts, change oracle sources
- Governance proposals use Snapshot (off-chain) at alpacafinance.eth

**Timelock Bypass Detection:**
- No publicly documented emergency bypass mechanism
- The small multisig size means fewer signers need to be compromised for malicious action
- During shutdown, the team retains full admin control with reduced community oversight

**Upgrade Mechanism:**
- Proxy Admin contract at 0x5379F32C8D5F663EACb61eeF63F722950294f452
- Contracts use AdminUpgradeabilityProxy pattern (upgradeable)
- Upgrades controlled via Timelock + multisig
- AF2.0 introduced permissionless asset listing in isolation tier, but core parameter changes require admin

**Governance Process:**
- Off-chain governance via Snapshot
- AIP (Alpaca Improvement Proposal) system for major changes
- Governance Vault with xALPACA (locked ALPACA) for voting power
- With protocol shutting down, governance is effectively defunct

**Token Concentration & Whale Risk:**
- 18.7% of supply burned (deflationary)
- Two EOA whales hold ~9.4% combined -- could influence thin-liquidity markets post-delisting
- Governance vault participation likely minimal given shutdown announcement

**Risk Rating: HIGH** -- Small anonymous multisig with only 24h timelock. Protocol shutdown means governance oversight is effectively ended.

### 2. Oracle & Price Feeds

**Oracle Architecture:**
- Leveraged Yield Farming (LYF): Chainlink Price Feeds as primary oracle
- Perpetual Futures (Alperp): Pyth Network price feeds for low-latency execution
- Alpaca Guard: proprietary anti-manipulation layer that prevents flash liquidation attacks and price manipulation
- Multiple oracle sources across different product lines

**Collateral / Market Listing:**
- AF1.0: Admin-controlled listing of new farming pools
- AF2.0: Permissionless listing in isolation tier (lower-risk design)
- Core collateral types (BNB, BUSD, USDT, BTCB, ETH) have deep Chainlink oracle coverage

**Price Manipulation Resistance:**
- Alpaca Guard acts as a circuit breaker against abnormal price movements
- Flash loans are explicitly blocked by the protocol
- Chainlink aggregation provides TWAP-like smoothing via multiple data sources and heartbeat intervals
- No known oracle manipulation incidents in protocol history

**Risk Rating: LOW** -- Dual oracle providers (Chainlink + Pyth), proprietary Alpaca Guard anti-manipulation, no flash loan attack surface. Well-designed for the protocol's lifetime, though oracles become irrelevant as positions are wound down.

### 3. Economic Mechanism

**Liquidation Mechanism (AF1.0 - Leveraged Yield Farming):**
- Liquidation triggered when Debt Ratio exceeds Kill Threshold (typically 80-83.3%)
- 5% total liquidation bounty (1% to liquidator, 4% to protocol)
- Partial liquidation supported
- At 3x leverage, a ~31% price drop triggers liquidation
- Liquidation bots are permissionless (anyone can liquidate)

**Liquidation Mechanism (AF2.0):**
- "Gentle liquidation" via repurchasing: borrower collateral offered to repurchasers at 5-10% discount
- Scales with Debt Ratio to incentivize early intervention
- Reduces cascading liquidation risk

**Bad Debt Handling:**
- Insurance Plan: up to 50% of future Protocol Revenue directed to Governance Vault would cover losses for up to 1 year
- No dedicated insurance fund with reserved capital
- 40% of Dev Fund allocated to AUSD Peg Insurance Fund
- Revenue-based backstop is weaker than capital reserves (especially now that revenue is near zero)

**Interest Rate Model:**
- Customizable per asset and use case in AF2.0
- Triple-slope interest rate model for lending vaults
- Utilization-based with kink points to manage liquidity

**Withdrawal & Deposit Limits:**
- Users can withdraw until December 31, 2025
- Automated Vault positions were force-closed and converted to base tokens
- LYF positions were auto-closed by June 30, 2025

**Risk Rating: HIGH** -- The economic mechanism was well-designed for normal operations, but the shutdown context changes everything. The revenue-based insurance is worthless with no revenue. Residual TVL of ~$41M exists in what is essentially a zombie protocol with no active development or maintenance.

### 4. Smart Contract Security

**Audit History:**
- 23 audits claimed (one of the highest in BSC DeFi)
- Auditors include: Certik, PeckShield, SlowMist, Inspex, BlockSec
- Coverage spans: core lending, oracle, LYF, automated vaults, delta-neutral vaults, Alperp
- BlockSec audit of Delta Neutral Vault identified high-risk issues that were subsequently fixed
- DeFiLlama lists 0 audits (metadata gap, not reflective of reality)

**Bug Bounty:**
- Immunefi program active since June 14, 2021
- Maximum payout: $100,000
- Last updated: December 3, 2024
- Requires PoC for submissions
- Payouts in USDT
- $100K max is low for a protocol that peaked at $900M+ TVL, but adequate for current ~$41M

**Battle Testing:**
- Live since Q1 2021 (~5 years)
- Peak TVL: ~$900M+ (early 2022)
- No direct protocol exploits in history
- Third-party protocols building on Alpaca were exploited (bVaults BUSD strategy, GYM Network) but Alpaca core contracts were not compromised
- Rekt.news "False Prophet" article raised concerns about manual oracle updates (CoinGecko checks every 30 minutes) for certain asset listings -- contradicting claims of full Chainlink integration
- 100% open source on GitHub

**Risk Rating: LOW** -- Exceptional audit coverage and 5-year track record with no direct exploits. The Rekt.news oracle concern is notable but was related to specific new asset listings, not the core oracle infrastructure.

### 5. Cross-Chain & Bridge

**Multi-Chain Deployment:**
- BSC: Primary chain (~$41.36M TVL)
- Fantom: Secondary chain (~$3K TVL, effectively abandoned)
- Each chain has independent deployment
- No cross-chain messaging or bridge dependencies

**Bridge Dependencies:**
- No bridge dependency for core protocol operations
- Users bridge assets to BSC independently via their preferred bridge
- Protocol risk is isolated per chain

**Risk Rating: LOW** -- Independent per-chain deployments with no bridge dependency. Fantom deployment is negligible.

### 6. Operational Security

**Team & Track Record:**
- Fully anonymous/pseudonymous team
- Key pseudonyms: Huacayachief (co-founder), Samsara (Head of Strategy)
- No prior public track record before Alpaca Finance
- Team has stated anonymity is intentional for regulatory reasons
- Protocol operated for 4+ years without team-related incidents
- Team is now in wind-down mode with reduced staffing

**Incident Response:**
- Emergency pause capability exists in contracts
- Discord and Twitter used for communication (Discord reportedly banned users raising oracle concerns per Rekt.news)
- No published formal incident response plan
- With shutdown underway, incident response capacity is severely degraded

**Dependencies:**
- Chainlink (oracle) -- reliable, industry-standard
- Pyth Network (oracle for perps) -- reliable
- PancakeSwap (primary DEX for LP farming) -- operational
- BNB Chain (L1) -- operational
- Binance (CEX listing) -- DELISTED May 2025

**Risk Rating: CRITICAL** -- The protocol is in active shutdown. Anonymous team with no accountability post-shutdown. Incident response capacity is functionally zero. Any exploit or issue discovered now would likely go unpatched. Users with remaining funds face elevated counterparty risk.

## Critical Risks

1. **CRITICAL: Protocol shutdown in progress** -- Alpaca Finance announced closure by end of 2025. No new development, reduced team, no future maintenance. Any smart contract vulnerability discovered post-shutdown will not be patched.

2. **HIGH: owner_change_balance = 1** -- The ALPACA token owner contract can modify balances. While this has not been exploited historically, during a shutdown with anonymous team, the risk of misuse increases.

3. **HIGH: Residual TVL in zombie protocol** -- ~$41M remains locked in BSC contracts of a protocol with no active development team. Users should withdraw immediately.

4. **HIGH: Anonymous team wind-down** -- No accountability mechanism for anonymous team members post-shutdown. Revenue-based insurance is meaningless with zero revenue.

5. **HIGH: Binance delisting** -- ALPACA was delisted from Binance in May 2025, severely reducing token liquidity and price discovery quality. Remaining DEX liquidity is thin (~$16K total across all pools per GoPlus).

## Peer Comparison

| Feature | Alpaca Finance | Venus Protocol | Beefy Finance |
|---------|---------------|----------------|---------------|
| Timelock | 24h | 48h (Normal) / 6h (Fast-track) | N/A (non-upgradeable vaults) |
| Multisig | <4 signers (UNVERIFIED) | Guardian + on-chain governance | Community multisig |
| Audits | 23 (Certik, PeckShield, SlowMist, Inspex, BlockSec) | Multiple (extensive) | Certik + others |
| Oracle | Chainlink + Pyth + Alpaca Guard | Chainlink + Pyth | Per-vault (varies) |
| Insurance/TVL | Revenue-based (no reserve fund) | Dedicated shortfall fund | Per-vault safety scores |
| Open Source | Yes | Yes | Yes |
| TVL | ~$41M (declining, shutdown) | ~$2.8B | ~$300M |
| Status | Shutting down | Active | Active |
| Team | Anonymous | Semi-doxxed | Anonymous |
| Bug Bounty | $100K (Immunefi) | $200K+ (Immunefi) | $100K (Immunefi) |

## Recommendations

1. **Withdraw all funds immediately.** The protocol is shutting down. Front-end access is stated to remain until December 31, 2025, but there is no guarantee of continued maintenance.

2. **Do not open new positions.** Leveraged yield farming and perpetual futures are in reduce-only mode. There is no rational reason to deposit into a protocol in active wind-down.

3. **Monitor contract state.** If you have remaining positions, monitor the BscScan timelock contract (0x2D5408f2287BF9F9B05404794459a846651D0a59) for any unexpected admin transactions during the shutdown period.

4. **Be aware of thin ALPACA liquidity.** Post-Binance delisting, ALPACA trades on PancakeSwap and other BSC DEXes with very low liquidity. Large sells will face significant slippage.

5. **Do not rely on the insurance plan.** The revenue-based insurance mechanism depends on future protocol revenue, which is effectively zero. There is no capital reserve to cover potential losses.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- No, Timelock covers major actions (24h)
- [x] Admin can change oracle sources arbitrarily? -- UNVERIFIED; admin controls oracle configuration via Timelock
- [x] Admin can modify withdrawal limits? -- Yes, via Timelock
- [x] Multisig has low threshold (2/N with small N)? -- Yes, <4 signers reported
- [ ] Zero or short timelock on governance actions? -- 24h timelock exists (adequate, not excellent)
- [ ] Pre-signed transaction risk? -- N/A (EVM, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- Yes, fully anonymous team

**Drift pattern match: 4/7 indicators** -- Elevated governance risk, especially during shutdown period.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- AF2.0 isolation tier mitigates this
- [ ] Single oracle source without TWAP? -- No, Chainlink provides aggregated feeds
- [ ] No circuit breaker on price movements? -- Alpaca Guard serves as circuit breaker
- [x] Insufficient insurance fund relative to TVL? -- Yes, revenue-based only, no capital reserve

**Euler/Mango pattern match: 1/4 indicators** -- Low economic manipulation risk.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- No bridge dependency
- [x] Admin keys stored in hot wallets? -- UNVERIFIED; anonymous team, unknown key management
- [x] No key rotation policy? -- No public key rotation policy

**Ronin/Harmony pattern match: 2/3 indicators** -- Moderate key management concern, amplified by anonymous team.

## Information Gaps

- **Exact multisig configuration**: Number of signers, threshold, and signer identities are not publicly documented in detail. Reports indicate "fewer than 4 signers" but exact m/n is UNVERIFIED.
- **Key management practices**: No public information on how admin/multisig keys are stored, rotated, or secured.
- **Shutdown timeline compliance**: Whether the Dec 31, 2025 deadline was met or if funds remain accessible beyond that date is unknown as of April 2026.
- **Post-shutdown contract state**: Whether contracts have been frozen, ownership renounced, or if admin keys remain active after shutdown.
- **Insurance fund actual balance**: No public disclosure of any capital reserves for the revenue-based insurance plan.
- **Rekt.news oracle concerns**: The "False Prophet" article alleged manual CoinGecko-based oracle updates for certain assets. The full scope and current status of this issue is unclear.
- **Team composition and continuity**: How many team members remain active during the shutdown phase, and whether any are monitoring contracts for security issues.
- **Fantom deployment status**: With ~$3K TVL, it is unclear if the Fantom deployment is maintained at all.
- **AUSD stablecoin status**: Whether AUSD is still redeemable and what backing remains is not publicly clear.
- **DeFiLlama audit metadata**: DeFiLlama shows 0 audits, which contradicts Alpaca's claim of 23. The reason for this discrepancy (submission issue, metadata format) is unknown.

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
