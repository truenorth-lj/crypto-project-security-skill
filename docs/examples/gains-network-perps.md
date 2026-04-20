# DeFi Security Audit: Gains Network (gTrade)

**Audit Date:** April 20, 2026
**Protocol:** Gains Network -- Decentralized Leveraged Trading Platform (gTrade)

## Overview
- Protocol: Gains Network (gTrade)
- Chain: Multi-chain -- Arbitrum (primary), Polygon, Base, ApeChain, MegaETH
- Type: Derivatives / Perpetuals (Synthetic)
- TVL: ~$19.4M (DeFiLlama, April 2026)
- TVL Trend: +2.9% / -4.4% / -21.7% (7d / 30d / 90d)
- Token: GNS (ERC-20, Arbitrum: 0x18c11FD286C5EC11c3b683Caa813B77f5163A122)
- Launch Date: December 2021 (Polygon); January 2023 (Arbitrum)
- Audit Date: April 20, 2026
- Valid Until: July 19, 2026 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Open (GitHub: GainsNetwork-org)

## Quick Triage Score: 19/100 | Data Confidence: 60/100

Starting at 100, subtracting:

**CRITICAL flags (-25 each):**
- [x] GoPlus: hidden_owner = 1 (-25)
- [x] GoPlus: owner_change_balance = 1 (-25)

**HIGH flags (-15 each):**
- (none)

**MEDIUM flags (-8 each):**
- [x] GoPlus: is_mintable = 1 (-8)
- [x] No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations (-8)

**LOW flags (-5 each):**
- [x] Single oracle provider (Chainlink) (-5)
- [x] Undisclosed multisig signer identities (-5)
- [x] Insurance fund / TVL ratio undisclosed (-5)

Total deductions: -81. Raw score: 19. **Score: 19/100 (CRITICAL risk)**

**Data Confidence Score: 60/100 (MEDIUM confidence)**

```
[x] +15  Source code is open and verified on block explorer
[x] +15  GoPlus token scan completed
[x] +10  At least 1 audit report publicly available (CertiK x8)
[ ] +10  Multisig configuration verified on-chain (Safe API) -- treasury 4/7 verified; primary admin multisig UNVERIFIED
[x] +10  Timelock duration verified on-chain or in docs (14d owner)
[ ] +10  Team identities publicly known -- pseudonymous only
[ ] +10  Insurance fund size publicly disclosed
[x] +5   Bug bounty program details publicly listed (Immunefi)
[x] +5   Governance process documented (Snapshot)
[x] +5   Oracle provider(s) confirmed (Chainlink DON + Data Streams)
[ ] +5   Incident response plan published
[ ] +5   SOC 2 Type II or ISO 27001 certification verified
[ ] +5   Published key management policy
[ ] +5   Regular penetration testing disclosed
[ ] +5   Bridge DVN/verifier configuration publicly documented
= 60/100
```

Red flags found: 2 CRITICAL (GoPlus), 0 HIGH, 2 MEDIUM, 3 LOW

**Important context:** The GoPlus hidden_owner and owner_change_balance flags remain the primary drivers of this score. The GNS token contract uses AccessControlEnumerable with MINTER_ROLE and BURNER_ROLE, which GoPlus detects as hidden ownership mechanisms. The mintable flag aligns with the known GNS mint/burn buyback mechanism. These are likely intentional design features, but they represent significant centralization risk at the token-contract level. The protocol has operated without exploits for over 4 years and $56.5B+ in cumulative volume.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Overcollateralization layer (OC); exact ratio undisclosed | GMX: ~3-5% | MEDIUM |
| Audit Coverage Score | 3.25 (see calculation) | 2-3 avg | LOW |
| Governance Decentralization | Snapshot voting, anon team, 4/7 treasury multisig | GMX: 3/6, dYdX: on-chain DAO | MEDIUM |
| Timelock Duration | 14d (owner), 3d (manager), 0 (admin) | 24-48h avg | LOW |
| Multisig Threshold | 4/7 (treasury, VERIFIED) | 3/5 avg | LOW |
| GoPlus Risk Flags | 2 HIGH / 1 MED | -- | HIGH |

### Audit Coverage Score Calculation

Known audits:

**Less than 1 year old (1.0 each):**
- No confirmed audit less than 1 year old. v10 (Aug 2025) likely audited but report not public -- 0.0

**1-2 years old (0.5 each):**
- v8 Diamond refactor audit by CertiK (May 2024) -- 0.5
- v9 update audit by CertiK (mid-2024) -- 0.5
- Estimated v10 pre-launch audit (mid-2025) -- 0.5

**Older than 2 years (0.25 each):**
- CertiK audits #1-6 (various, 2022-2023) -- 6 x 0.25 = 1.5
- Halborn audit (2023) -- 0.25
- Cyberscope audit -- UNVERIFIED date, counted as older -- 0.25

**Total Audit Coverage Score: ~3.5 (LOW risk -- above 3.0 threshold)**

Note: CertiK Skynet lists 8 audits for Gains Network with a score of 92/100. The most recent CertiK audit on their public page dates to June 2022, though the protocol has had subsequent audits for v8/v9/v10 that are referenced in blog posts but whose full reports are not individually linked on CertiK Skynet. DeFiLlama lists "2" audits.

### UPDATE from previous report (April 6, 2026):

**Key changes identified:**
1. **Treasury multisig VERIFIED**: The treasury multisig at 0xc07EEd650aB255190CA9766162CfB47cFDf72f3a is a **4/7 Gnosis Safe** (Safe v1.3.0+L2), resolving the previous conflicting "2/3 vs 4+ signers" discrepancy. This is a significant improvement from the previously suspected 2/3 threshold.
2. **Bug bounty reduced**: Maximum payout decreased from $400,000 to $200,000 (updated January 29, 2026). Total paid to date: $364,280.
3. **TVL trend improved**: 7d trend flipped positive (+2.9%), though 90d remains negative (-21.7% vs -28.0% previously).
4. **Holder count decreased**: 14,167 holders (down from 14,220 on April 6).
5. **2026 roadmap**: Solana expansion planned; cross-chain vault unification; RWA market expansion; no governance changes announced.
6. **GoPlus flags unchanged**: hidden_owner=1, owner_change_balance=1, is_mintable=1 persist.

## GoPlus Token Security (GNS on Arbitrum, chain_id=42161)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | LOW |
| Open Source | Yes (1) | LOW |
| Proxy | No (0) | LOW |
| Mintable | Yes (1) | MEDIUM |
| Owner Can Change Balance | Yes (1) | HIGH |
| Hidden Owner | Yes (1) | HIGH |
| Selfdestruct | No (0) | LOW |
| Transfer Pausable | No (0) | LOW |
| Blacklist | No (0) | LOW |
| Slippage Modifiable | No (0) | LOW |
| Buy Tax / Sell Tax | N/A / N/A | LOW |
| Holders | 14,167 | -- |
| Trust List | Not listed | -- |
| Creator Honeypot History | No (0) | LOW |
| CEX Listed | Yes (Binance) | -- |

**Key concern:** The hidden_owner and owner_change_balance flags persist. The GNS token contract (GainsNetworkToken) uses ERC20Capped with AccessControlEnumerable, implementing MINTER_ROLE and BURNER_ROLE. The maximum supply cap is 100M GNS (current supply: ~17.6M). GoPlus detects the role-based access control as "hidden ownership" because roles can be granted/revoked without a transparent single-owner pattern. The owner_change_balance flag likely reflects the MINTER_ROLE's ability to mint new tokens, which is used for the vault undercollateralization recovery mechanism.

**Top holders (Arbitrum):**
1. 0x7edde...d015 (contract): 26.4%
2. 0x4beef...9f4 (contract): 15.3%
3. 0x4f2c2...569 (EOA): 5.1%
4. 0x49a3b...dac (EOA): 4.6%
5. 0xff162...169 (contract): 3.9%
6. 0xb38e8...91d (EOA): 3.1%
7. 0x9b6ff...3a6 (CamelotV3 LP): 2.7%
8. 0xdead0...069 (burn address): 1.8%
9. 0x3e10a...e21 (EOA): 1.7%
10. 0xa9da7...69b (contract): 1.7%

Top 5 holders control ~55.3% of supply (down from ~58.2%). Top 2 are contracts (likely protocol vaults/staking). Three EOA wallets in top 6 holding ~12.8% combined is moderate concentration risk. Burn address at 1.8% confirms buyback/burn activity.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | MEDIUM | 4/7 treasury multisig verified; anonymous signers; strong tiered timelock | S/O | Partial |
| Oracle & Price Feeds | MEDIUM | Chainlink-only dependency; custom DON + Data Streams adds robustness | S | Partial |
| Economic Mechanism | MEDIUM | Synthetic counterparty model; GNS mint as backstop creates dilution risk | S | Partial |
| Smart Contract | MEDIUM | Diamond proxy pattern highly upgradeable; 8+ CertiK audits mitigate | S | Partial |
| Token Contract (GoPlus) | HIGH | Hidden owner + owner can change balances + mintable | S | Y |
| Cross-Chain & Bridge | MEDIUM | 5 chains with Solana planned; CCIP integration; per-chain admin separation unclear | S/O | N |
| Off-Chain Security | HIGH | Anonymous team; no SOC 2/ISO 27001; no published key management policy | O | N |
| Operational Security | MEDIUM | Anonymous team; 4+ year clean track record; Immunefi bounty active | S/O | Partial |
| **Overall Risk** | **HIGH** | **Persistent token-level centralization flags (GoPlus) and opaque off-chain security practices; partially offset by strong operational history and verified 4/7 multisig** | | |

**Overall Risk aggregation (mechanical):** Token Contract = HIGH, Off-Chain Security = HIGH. 2+ categories at HIGH -> **Overall = HIGH.**

## Detailed Findings

### 1. Governance & Admin Key

**Multisig Configuration (PARTIALLY VERIFIED):**

The treasury/governance multisig at `0xc07EEd650aB255190CA9766162CfB47cFDf72f3a` has been verified on-chain via the Safe Transaction Service:
- **Threshold: 4 of 7** (Gnosis Safe v1.3.0+L2)
- **7 owners confirmed:**
  1. 0x44C590465402Bc56F401dE4F699680559aB4b1E4
  2. 0x211999E5eE74Af3E8dAcBCd5c4e608CD7D8086FA
  3. 0x727695E7888853af9e673EA66F30F26a791DdfB0
  4. 0x52a722BC2B0D8ce869a478956865744D7C3beBd3
  5. 0x6a9fe023F2D5930249081EBfa1909350CEbe1605
  6. 0x9cdfe21adfa1038318321e1729a2de2251A0803A
  7. 0x6d3f427807598Be703f4AC11462D206A40620226
- **No modules attached** (no bypass vector)
- **No guard** set

This resolves the previous report's conflicting information about "2/3 vs 4+ signers." The 4/7 threshold is above industry average and significantly more secure than the previously suspected 2/3.

Additional multisig addresses documented:
- ARB Delegator: 0xF8E93a7D954F7d31D5Fa54Bc0Eb0E384412a158d
- ARB STIP: 0xc5fCA2c19c5Ca269a10e15ee4A800ed82F53787D
- ApeChain: 0x34F4911911a0883856E8D15E99fda2d8E0FDBF60

The primary admin multisig (referenced at 0x28694A5F7B670586c4Fb113d7F52B070B86f0FFe in previous reports) returned no data from the Safe API -- it may not be a Gnosis Safe or may use a different format. UNVERIFIED.

**Tiered Timelock System:**
The protocol implements a tiered admin role system for gToken vaults:
- **GTokenAdmin**: No timelock. For urgent actions that do not impact user funds (e.g., pausing).
- **GTokenManager**: 3-day timelock. For non-urgent actions that do not impact user funds.
- **GTokenOwner**: 14-day timelock. For actions that could impact user funds (e.g., upgrades).

A dedicated GNS Timelock Owner contract exists at 0x5f5E4892BAB94d94DC57a3edeA3c138167c4DF0F (Arbitrum), using OpenZeppelin's TimelockController with proposers, executors, and admin roles.

The 14-day timelock for fund-impacting changes is best-in-class among perps DEXs. However, the GTokenAdmin role with zero timelock remains a potential bypass vector -- its scope needs verification.

**Governance:**
- Uses Snapshot (off-chain) governance at gains-network.eth.
- No on-chain binding governance. Snapshot proposals are advisory only; execution depends on the team.
- No documented quorum requirements or minimum voting periods found.
- 2026 roadmap mentions future DAO transition with GNS or veGNS governance, but no timeline.

**Risk: MEDIUM** -- The verified 4/7 multisig with no modules is a strong positive. Anonymous signers and off-chain-only governance remain weaknesses, but the tiered timelock architecture is well-designed.

### 2. Oracle & Price Feeds

**Architecture:**
gTrade uses a custom Chainlink Decentralized Oracle Network (DON) purpose-built for the platform:

1. **8 Chainlink on-demand nodes** each query 7 exchange APIs and take the median price.
2. **Aggregator contract** collects node responses, filters outliers by comparing against the corresponding Chainlink Price Feed (>1.5% deviation = rejected).
3. **Minimum 3 valid answers** required; final price is the median of accepted answers.

**Chainlink Data Streams Integration:**
As of 2024-2025, gTrade integrated Chainlink Data Streams (high-frequency, low-latency market data) and CCIP (cross-chain interoperability). Data Streams replaces the custom DON for trade execution, conditional orders, and liquidations on supported markets.

**2026 Updates:**
- DON upgrades planned for improved schedules, sources, and futures-based pricing for RWA markets.
- Extended trading hours beyond legacy calendars for RWA markets.

**Concerns:**
- Single oracle provider dependency (Chainlink). If Chainlink infrastructure fails across all layers (DON + Price Feeds + Data Streams), the platform has no fallback.
- The custom DON adds a layer of complexity that could introduce bugs not covered by standard Chainlink audits.
- Admin ability to change oracle sources is UNVERIFIED.

**Risk: MEDIUM** -- The multi-layered Chainlink architecture is robust, but single-provider dependency and lack of a non-Chainlink fallback is a concern for a protocol handling leveraged positions.

### 3. Economic Mechanism

**Synthetic Trading Model:**
gTrade uses a fully synthetic trading model where no actual underlying assets are bought or sold. Traders open positions against the gToken vault, which acts as the counterparty to all trades.

- When traders win: winnings paid from the vault.
- When traders lose: losses flow to the vault.
- The vault also receives a portion of trading fees (10-25%).

This model is extremely capital efficient (reportedly $100M daily volume on $10M TVL), but concentrates counterparty risk in a single vault per collateral type.

**v10 Changes (August 2025):**
- Major crypto markets shifted from borrowing fees to market-driven funding fee model.
- Holding costs for traders dropped >90%.
- Price impact conditions improved ~2x.
- This is a significant economic mechanism change that reduces trader friction but may alter vault PnL dynamics.

**Overcollateralization (OC) Layer:**
- The OC layer acts as a buffer between traders and vault depositors.
- When vault is >100% collateralized: the OC absorbs trader PnL first.
- When vault is >130% collateralized: excess is used to buy back and burn GNS via OTC using a 1-hour TWAP.
- When vault is <100% collateralized: GNS is minted and sold for the vault collateral asset, diluting GNS holders.

**GNS as Backstop Risk:**
The GNS mint mechanism is the last line of defense. In extreme scenarios (massive trader wins), the GNS mint mechanism could trigger a self-reinforcing devaluation cycle (death spiral). The ERC20Capped contract limits total supply to 100M GNS (current supply: ~17.6M), which provides a hard cap not present in all backstop mechanisms. However, 100M / 17.6M = ~5.7x potential dilution is still significant.

**Buyback/Burn Performance:**
- Over $10.8M in buyback/burn revenue in 2025.
- 25.7% of total supply burned by end of 2025.
- Burn address (0xdead...2069) holds 1.8% of current supply on-chain.

**Risk: MEDIUM** -- The synthetic model with GNS backstop is well-tested over 4+ years. The ERC20Capped supply cap provides a guardrail. The v10 funding fee model change is a positive for trader experience but introduces a new economic dynamic that has less battle-testing history.

### 4. Smart Contract Security

**Architecture:**
gTrade v8 introduced the Diamond Pattern (EIP-2535), making the protocol highly modular and upgradeable. Individual facets can be updated or replaced without migrating the entire system. v10 built on this architecture with the funding fee model change.

**Audit History:**
- CertiK: 8 audits listed on Skynet (score: 92/100). Most recent public audit on CertiK Skynet dates to June 2022 (7 findings: 0 critical, 1 major [centralization -- acknowledged], 1 medium, 4 minor, 1 informational). Subsequent audits for v8/v9/v10 are referenced in Medium posts but individual reports are not publicly linked on CertiK Skynet.
- Halborn: Audited contract version (date UNVERIFIED).
- Cyberscope: Additional audit (date UNVERIFIED).
- Code coverage in CertiK audit: ~19.36% full match -- indicating partial coverage of the contract ecosystem.

**Bug Bounty:**
- Active on Immunefi. **Maximum payout reduced to $200,000** (down from $400,000 as of January 29, 2026).
- Smart Contract Critical: up to $200,000 (10% of funds affected, minimum $25,000).
- 27 in-scope assets. Total paid to date: $364,280.
- PoC required for all submissions. Payouts in GNS + DAI.
- The reduction in maximum bounty is a negative signal -- $200K is below peers (GMX: $5M).

**Battle Testing:**
- Live since December 2021 (4+ years).
- No known exploits or security incidents on rekt.news or elsewhere.
- Over $56.5B in cumulative trading volume processed.
- v10 launched August 2025 without incident.
- Open source on GitHub (GainsNetwork-org).
- Listed on Binance CEX.

**Risk: MEDIUM** -- Extensive audit history and zero-exploit track record are strong positives. The Diamond proxy pattern adds upgrade flexibility but also upgrade risk. The reduced $200K bug bounty is a concern relative to peers.

### 5. Cross-Chain & Bridge

**Multi-Chain Deployment:**
gTrade operates on 5 chains: Arbitrum (primary, ~73% of TVL at $14.2M), Base ($3.8M), Polygon ($0.9M), MegaETH ($0.2M), ApeChain ($0.2M).

**2026 Expansion:**
- Solana expansion planned in the 2026 roadmap.
- Cross-chain vault unification planned (users trade without knowing which chain).
- Chain abstraction and gasless trading flows in development.

**Admin Separation:**
Each chain has a documented multisig address (e.g., ApeChain: 0x34F4911911a0883856E8D15E99fda2d8E0FDBF60). However, whether these multisigs have the same signers or independent key sets is UNVERIFIED.

**Bridge Dependencies:**
- Chainlink CCIP is being integrated for cross-chain functionality (staking, vaults, liquidity unification).
- Native chain bridges (Arbitrum native bridge, Polygon bridge) used for asset transfers.
- No third-party bridge dependency documented for core trading functionality.

**Risk: MEDIUM** -- Multi-chain presence across 5 chains (6 with Solana) increases attack surface. The reliance on native bridges is safer than third-party bridges, but CCIP integration introduces additional dependency. Per-chain admin separation is not documented.

### 6. Off-Chain Security

**Assessment:**
- No SOC 2 Type II or ISO 27001 certification found.
- No published key management policy (HSM, MPC, key ceremony).
- No disclosed penetration testing (infrastructure-level).
- Anonymous team -- no verifiable security practices for operational security.
- No published incident response plan.

**Risk: HIGH** -- Anonymous team with no verifiable off-chain security practices. While the 4+ year clean track record suggests competent operations, the complete opacity of off-chain controls is a structural risk that cannot be mitigated by on-chain mechanisms alone.

### 7. Operational Security

**Team:**
- Founded by pseudonymous developer "Seb" in 2021.
- Team members have only revealed first names.
- No prior track record of team members in other projects is publicly documented.
- Anonymous team is a governance risk factor but is common in DeFi.

**Incident Response:**
- All contract upgrades are pre-announced and audited.
- Emergency pause capability exists (GTokenAdmin role, no timelock).
- No published formal incident response plan found.
- Active community communication via Medium, X (Twitter), and Discord.

**Dependencies:**
- Chainlink (oracle, Data Streams, CCIP) -- primary external dependency.
- No significant composability with other DeFi protocols documented (gTrade is relatively self-contained).

**Track Record:**
- 4+ years of operation with zero exploits.
- Clean execution of major upgrades (v6 through v10) without incident.
- $10.8M in buyback/burn revenue in 2025 demonstrates operational sustainability.
- Over 25.7% of GNS supply burned by end of 2025.
- Bug bounty program has paid $364,280 to date (indicating active security researcher engagement).

**Risk: MEDIUM** -- Anonymous team is a persistent risk factor, but the 4+ year clean operational history and active security practices (audits, Immunefi, timelocks) demonstrate responsible management.

## Critical Risks

1. **GoPlus: Hidden Owner + Owner Can Change Balances (HIGH):** The GNS token contract uses AccessControlEnumerable with MINTER_ROLE and BURNER_ROLE, which GoPlus detects as hidden ownership and balance modification capabilities. While these are designed features for the mint/burn mechanism, they represent a single-point-of-failure if role-holding keys are compromised. The ERC20Capped 100M supply cap provides a hard limit on minting damage.

2. **Off-Chain Security Opacity (HIGH):** Anonymous team with no published key management policy, no SOC 2/ISO 27001, and no disclosed penetration testing. Key compromise via social engineering (Radiant Capital-type attack) cannot be ruled out.

3. **GNS Death Spiral Risk (MEDIUM):** In extreme market conditions where traders win massively, the GNS mint mechanism could trigger a self-reinforcing devaluation cycle. The 100M supply cap limits but does not eliminate this risk (~5.7x potential dilution from current supply).

4. **Bug Bounty Reduction (MEDIUM):** Maximum bounty reduced from $400K to $200K in January 2026. This is 40x below GMX ($5M) and may reduce security researcher incentive to disclose critical vulnerabilities responsibly.

5. **Single Oracle Provider (MEDIUM):** Complete dependency on Chainlink across all oracle layers means a Chainlink outage or compromise would halt all trading and potentially cause liquidation errors.

## Peer Comparison

| Feature | Gains Network (gTrade) | GMX | dYdX |
|---------|----------------------|-----|------|
| Timelock | 14d (owner) / 3d (manager) / 0 (admin) | 24h | On-chain governance |
| Multisig | 4/7 (treasury, VERIFIED) | 3/6 (partially doxxed) | Validator set (60+ validators) |
| Audits | 8+ (CertiK, Halborn) | 5+ (ABDK, Guardians) | 10+ (Trail of Bits, Informal) |
| Oracle | Chainlink custom DON + Data Streams | Chainlink + custom keeper | In-house + Pyth |
| Insurance/TVL | OC layer (undisclosed %) | ~3-5% (GLP fees) | Insurance fund (~2%) |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | $200K (Immunefi) | $5M (Immunefi) | $250K |
| Trading Model | Synthetic (single vault counterparty) | Real assets (GM pools) | Order book (CLOB) |
| Max Leverage | 1000x (forex) | 100x | 20x |
| TVL | ~$19M | ~$500M | ~$300M |
| Team | Pseudonymous | Partially doxxed | Fully doxxed |

**Observations:**
- gTrade's 14-day owner timelock remains best-in-class among perps DEXs.
- The verified 4/7 treasury multisig is now on par with peers (previously appeared weakest at 2/3).
- GMX's $5M bug bounty is 25x gTrade's reduced $200K -- a significant gap.
- gTrade's synthetic model enables extreme leverage (1000x forex) that peers do not offer.
- TVL is significantly lower than peers (~$19M vs $300M-$500M), reflecting either lower adoption or higher capital efficiency.
- gTrade is the only protocol with a fully anonymous team among the three.

## Recommendations

1. **Monitor the GTokenAdmin role.** The zero-timelock admin role can pause the protocol. Verify on-chain what actions this role can take beyond pausing -- if it can modify parameters affecting funds, this is a higher risk than currently assessed.

2. **Track vault collateralization.** Monitor the OC ratio; undercollateralization triggers GNS minting which dilutes holders. The protocol's real-time vault data at gains.trade/vaults provides this information.

3. **Be aware of GoPlus flags.** The hidden_owner and owner_change_balance flags are structural features of the role-based access control design. Users holding significant GNS positions should monitor for unusual role grants via AccessControlEnumerable events.

4. **Note the bug bounty reduction.** The halving of the maximum bounty to $200K may reduce responsible disclosure incentives. This is a negative signal worth monitoring.

5. **Prefer Arbitrum deployment.** With ~73% of TVL on Arbitrum, it is the most liquid and likely best-maintained deployment. Smaller chain deployments (ApeChain: $231K, MegaETH: $242K) carry additional risk from lower liquidity.

6. **Use conservative leverage.** The 1000x forex leverage amplifies both gains and liquidation risk, especially during oracle latency periods.

7. **Watch Solana expansion.** The planned Solana deployment introduces a fundamentally different runtime (non-EVM), which will require new audit coverage and may introduce new attack surface.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- UNVERIFIED
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED (GTokenAdmin has no timelock)
- [ ] Multisig has low threshold (2/N with small N)? -- No, 4/7 verified for treasury
- [ ] Zero or short timelock on governance actions? -- No, 14d for owner actions
- [ ] Pre-signed transaction risk? -- N/A (EVM, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- Yes, all signers anonymous

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- No, synthetic model uses stablecoins + ETH as vault collateral
- [ ] Single oracle source without TWAP? -- No, custom DON uses median of multiple sources + TWAP for OC buybacks
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [ ] Insufficient insurance fund relative to TVL? -- OC layer exists but ratio undisclosed

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- CCIP uses Chainlink validators (decentralized)
- [x] Admin keys stored in hot wallets? -- UNVERIFIED (anonymous team, storage method unknown)
- [ ] No key rotation policy? -- UNVERIFIED

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time (no snapshot)? -- Uses Snapshot (off-chain)
- [ ] Flash loans can be used to acquire voting power? -- N/A (off-chain governance)
- [ ] Proposal + execution in same block or short window? -- N/A (off-chain governance)
- [ ] No minimum holding period for voting eligibility? -- UNVERIFIED

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral? -- No (stablecoins + ETH only)
- [ ] Read-only reentrancy risk? -- UNVERIFIED
- [ ] Flash loan compatible without reentrancy guards? -- UNVERIFIED
- [ ] Composability with protocols that expose callback hooks? -- Low composability (self-contained)

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler? -- No (Solidity)
- [ ] Compiler version has known CVEs? -- UNVERIFIED
- [ ] Contracts compiled with different compiler versions? -- UNVERIFIED
- [ ] Code depends on language-specific behavior? -- UNVERIFIED

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [x] Stablecoin backed by reflexive collateral (own governance token)? -- GNS mint backstop is reflexive
- [x] Redemption mechanism creates sell pressure on collateral? -- Yes, undercollateralization mints and sells GNS
- [ ] Oracle delay could mask depegging in progress? -- N/A (not a stablecoin)
- [ ] No circuit breaker on redemption volume? -- ERC20Capped at 100M provides a hard cap

**UST/LUNA pattern note:** 2 of 4 indicators match. While gTrade is not a stablecoin protocol, the GNS mint/sell mechanism during vault undercollateralization follows the same reflexive pattern as UST/LUNA. The 100M supply cap and the 4+ year operational history without triggering this mechanism are mitigating factors.

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses a cross-chain bridge for token minting or reserve release? -- CCIP for cross-chain, not for minting
- [ ] Bridge message validation relies on a single messaging layer? -- CCIP only
- [ ] DVN/relayer/verifier configuration not publicly documented? -- UNVERIFIED
- [ ] Bridge can release or mint tokens without rate limiting? -- UNVERIFIED
- [ ] Bridged/wrapped token accepted as collateral on lending protocols? -- GNS not widely used as lending collateral
- [ ] No circuit breaker for bridge-released volume? -- UNVERIFIED
- [ ] Emergency pause response time > 15 minutes? -- UNVERIFIED
- [ ] Bridge admin controls under different governance than core protocol? -- UNVERIFIED
- [ ] Token deployed on 5+ chains via same bridge provider? -- No, native deployments per chain

**Pattern match summary:** 1 confirmed Drift-type indicator (anonymous signers), 1 confirmed Ronin-type indicator (unknown key storage), and 2 UST/LUNA-type indicators (reflexive backstop). The verified 4/7 multisig significantly reduces the Drift-type risk compared to the previous report's suspected 2/3 threshold.

## Information Gaps

- **Primary admin multisig**: The address 0x28694A5F7B670586c4Fb113d7F52B070B86f0FFe returned no data from the Safe Transaction Service. It may not be a Gnosis Safe, or may be a different contract type. The relationship between this address and the verified 4/7 treasury multisig is unclear.
- **GTokenAdmin role scope**: What specific actions can be taken with zero timelock? Can it modify parameters affecting funds, or only pause?
- **Per-chain admin separation**: Whether each of the 5 chain deployments has independent admin keys or shares signers.
- **Overcollateralization ratio**: Current OC% for each vault is not available from public APIs (visible on UI only).
- **Insurance fund size**: No explicit insurance fund separate from the OC mechanism; exact dollar amount of the buffer is undisclosed.
- **Multisig signer identities**: All 7 treasury multisig signers are anonymous. No information on key storage practices (hardware wallet, MPC, etc.).
- **Oracle admin powers**: Whether admin can change oracle sources, add new trading pairs without timelock, or modify oracle parameters.
- **Circuit breaker mechanisms**: Whether the platform has automated circuit breakers for extreme price movements.
- **Cross-chain message validation**: How governance actions propagate across 5 chains and whether a compromised bridge could forge admin actions.
- **Hidden owner mechanism details**: GoPlus flags AccessControlEnumerable as hidden_owner; exact role-granting authority chain needs verification.
- **Recent audit reports**: v8/v9/v10 audit reports are referenced in blog posts but not publicly available as PDFs. CertiK Skynet shows latest public report from June 2022.
- **Key rotation and backup procedures**: No documentation found on operational security practices for admin keys.
- **Bug bounty reduction reasoning**: Why the maximum payout was halved from $400K to $200K in January 2026.
- **Solana expansion details**: Architecture, audit plans, and admin configuration for the planned Solana deployment are not yet documented.
- **v10 economic model audit**: Whether the funding fee model change in v10 was specifically audited for economic edge cases.

## Data Sources

- DeFiLlama API: https://api.llama.fi/protocol/gains-network (TVL, chain breakdown)
- GoPlus Security API: token_security/42161 (GNS token scan, April 20, 2026)
- Safe Transaction Service: arbitrum (treasury multisig verification)
- CertiK Skynet: https://skynet.certik.com/projects/gains-network
- Immunefi: https://immunefi.com/bug-bounty/gainsnetwork/
- Gains Network Medium: https://medium.com/gains-network
- Gains Network Docs: https://docs.gains.trade
- Arbiscan: https://arbiscan.io/token/0x18c11FD286C5EC11c3b683Caa813B77f5163A122

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
