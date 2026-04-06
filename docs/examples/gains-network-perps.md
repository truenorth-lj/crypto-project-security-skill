# DeFi Security Audit: Gains Network (gTrade)

**Audit Date:** April 6, 2026
**Protocol:** Gains Network -- Decentralized Leveraged Trading Platform (gTrade)

## Overview
- Protocol: Gains Network (gTrade)
- Chain: Multi-chain -- Arbitrum (primary), Polygon, Base, ApeChain, MegaETH
- Type: Derivatives / Perpetuals (Synthetic)
- TVL: ~$19.1M (DeFiLlama, April 2026)
- TVL Trend: -2.2% / -12.4% / -28.0% (7d / 30d / 90d)
- Token: GNS (ERC-20, Arbitrum: 0x18c11FD286C5EC11c3b683Caa813B77f5163A122)
- Launch Date: December 2021 (Polygon); January 2023 (Arbitrum)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: GainsNetwork-org)

## Quick Triage Score: 19/100

Starting at 100, subtracting:

**CRITICAL flags (-25 each):**
- [x] GoPlus: hidden_owner = 1 (-25)
- [x] GoPlus: owner_change_balance = 1 (-25)

**HIGH flags (-15 each):**
- [ ] No CRITICAL HIGH flags beyond GoPlus

**MEDIUM flags (-8 each):**
- [x] GoPlus: is_mintable = 1 (-8)
- [x] Multisig threshold < 3 signers: 2/3 (-8)

**LOW flags (-5 each):**
- [x] Single oracle provider (Chainlink) (-5)
- [x] Undisclosed multisig signer identities (-5)
- [x] Insurance fund / TVL ratio undisclosed (-5)

Total deductions: -81. Raw score: 19. **Score: 19/100 (CRITICAL risk)**

**Important context:** The GoPlus hidden_owner and owner_change_balance flags are the primary drivers of this score. These flags indicate that the GNS token contract on Arbitrum has mechanisms that could allow ownership reassertion and balance modification. While these may be intentional design features (e.g., for the mint/burn buyback mechanism), they represent significant centralization risk at the token-contract level. The protocol itself has operated without exploits for over 4 years, which mitigates some concern but does not eliminate the structural risk.

Red flags found: 2 CRITICAL (GoPlus), 0 HIGH, 2 MEDIUM, 3 LOW

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Overcollateralization layer (OC); exact ratio undisclosed | GMX: ~3-5% | MEDIUM |
| Audit Coverage Score | 4.0 (see calculation) | 2-3 avg | LOW |
| Governance Decentralization | Snapshot voting, anon team, 2/3 multisig | GMX: 3/6, dYdX: on-chain DAO | HIGH |
| Timelock Duration | 14d (owner), 3d (manager), 0 (admin) | 24-48h avg | MEDIUM |
| Multisig Threshold | 2/3 (UNVERIFIED -- conflicting reports of 4+ signers) | 3/5 avg | HIGH |
| GoPlus Risk Flags | 2 HIGH / 1 MED | -- | HIGH |

### Audit Coverage Score Calculation

Known audits:

**Less than 1 year old (1.0 each):**
- Estimated v10 audit (Aug 2025 launch) -- 1.0

**1-2 years old (0.5 each):**
- v8 Diamond refactor audit by CertiK (May 2024) -- 0.5
- v9 update audit by CertiK (mid-2024) -- 0.5

**Older than 2 years (0.25 each):**
- CertiK audit #1-6 (various, 2022-2023) -- 6 x 0.25 = 1.5
- Halborn audit (2023) -- 0.25
- Cyberscope audit -- 0.25

**Total Audit Coverage Score: ~4.0 (LOW risk -- above 3.0 threshold)**

Note: DeFiLlama lists "2" audits, but CertiK has conducted 8+ audits over the protocol's lifetime, and Halborn has also audited the contracts. The exact dates and scopes of individual CertiK audits are not all publicly enumerable with specific reports.

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
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 14,220 | -- |
| Trust List | Not listed | -- |
| Creator Honeypot History | No (0) | LOW |

**Key concern:** The hidden_owner and owner_change_balance flags are significant. The mintable flag aligns with the known GNS mint/burn mechanism used for vault undercollateralization recovery. However, the ability to change balances and the hidden owner mechanism indicate centralized control over the token that could be exploited if admin keys are compromised.

**Top holders (Arbitrum):**
1. 0x7edde...d015 (contract): 26.9%
2. 0x4beef...9f4 (contract): 16.3%
3. 0xff162...169 (contract): 5.3%
4. 0x4f2c2...569 (EOA): 5.1%
5. 0x49a3b...dac (EOA): 4.6%

Top 5 holders control ~58.2% of supply. Top 3 are contracts (likely protocol vaults/staking), which is typical. Two EOA wallets holding ~9.7% combined is a moderate concentration risk.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | HIGH | 2/3 multisig with anonymous signers; conflicting docs on signer count | Partial |
| Oracle & Price Feeds | MEDIUM | Chainlink-only dependency; custom DON adds complexity | Partial |
| Economic Mechanism | MEDIUM | Synthetic counterparty model; GNS mint as backstop creates dilution risk | Partial |
| Smart Contract | MEDIUM | Diamond proxy pattern highly upgradeable; 8+ CertiK audits mitigate | Partial |
| Token Contract (GoPlus) | HIGH | Hidden owner + owner can change balances + mintable | Y |
| Cross-Chain & Bridge | MEDIUM | 5 chains with unclear per-chain admin separation | N |
| Operational Security | MEDIUM | Anonymous team; 4+ year clean track record; Immunefi bounty active | Partial |
| **Overall Risk** | **MEDIUM** | **Strong operational history offset by concerning token-level centralization and low multisig threshold** | |

## Detailed Findings

### 1. Governance & Admin Key

**Multisig Configuration (conflicting information):**
- One source (Exponential DeFi / DeFiSafety) reports the multisig consists of "at least 4 signers" with a "48-hour timelock."
- Another source identifies the multisig wallet as 0x28694A5F7B670586c4Fb113d7F52B070B86f0FFe with a **2/3 threshold**, which is below industry standard.
- The official docs list two separate multisig addresses for treasury (0xc07EEd650aB255190CA9766162CfB47cFDf72f3a) and ARB delegation (0xF8E93a7D954F7d31D5Fa54Bc0Eb0E384412a158d).
- The discrepancy between "at least 4 signers" and "2 of 3" is concerning. This could indicate different multisigs for different functions, or outdated information. UNVERIFIED.

**Tiered Timelock System:**
The protocol implements a sophisticated tiered admin role system for gToken vaults:
- **GTokenAdmin**: No timelock. For urgent actions that do not impact user funds (e.g., pausing).
- **GTokenManager**: 3-day timelock. For non-urgent actions that do not impact user funds.
- **GTokenOwner**: 14-day timelock. For actions that could impact user funds (e.g., upgrades).

This tiered approach is well-designed. The 14-day timelock for fund-impacting changes is significantly above industry average (24-48h). However, the GTokenAdmin role with zero timelock is a potential bypass vector -- its scope needs verification.

**Governance:**
- Uses Snapshot (off-chain) governance at gains-network.eth.
- No on-chain binding governance. Snapshot proposals are advisory only; execution depends on the team.
- No documented quorum requirements or minimum voting periods found.

**Risk: HIGH** -- The 2/3 multisig threshold (if accurate) with anonymous signers is a significant weakness, despite the strong timelock architecture.

### 2. Oracle & Price Feeds

**Architecture:**
gTrade uses a custom Chainlink Decentralized Oracle Network (DON) purpose-built for the platform:

1. **8 Chainlink on-demand nodes** each query 7 exchange APIs and take the median price.
2. **Aggregator contract** collects node responses, filters outliers by comparing against the corresponding Chainlink Price Feed (>1.5% deviation = rejected).
3. **Minimum 3 valid answers** required; final price is the median of accepted answers.

This is a well-designed oracle system with multiple layers of validation. The 1.5% outlier filter against Chainlink Price Feeds provides a secondary check.

**Chainlink Data Streams Integration:**
As of 2024, gTrade announced integration of Chainlink Data Streams (high-frequency, low-latency market data) and CCIP (cross-chain interoperability). Data Streams would replace the custom DON for trade execution, conditional orders, and liquidations.

**Concerns:**
- Single oracle provider dependency (Chainlink). If Chainlink infrastructure fails across all layers (DON + Price Feeds + Data Streams), the platform has no fallback.
- The custom DON adds a layer of complexity that could introduce bugs not covered by standard Chainlink audits.
- Admin ability to change oracle sources is UNVERIFIED.

**Risk: MEDIUM** -- The multi-layered Chainlink architecture is robust, but single-provider dependency and lack of a non-Chainlink fallback is a concern for a protocol handling leveraged positions.

### 3. Economic Mechanism

**Synthetic Trading Model:**
gTrade uses a fully synthetic trading model where no actual underlying assets are bought or sold. Traders open positions against the gToken vault (formerly gDAI), which acts as the counterparty to all trades.

- When traders win: winnings paid from the vault.
- When traders lose: losses flow to the vault.
- The vault also receives a portion of trading fees (10-25%).

This model is extremely capital efficient (reportedly $100M daily volume on $10M TVL), but concentrates counterparty risk in a single vault per collateral type.

**Overcollateralization (OC) Layer:**
- The OC layer acts as a buffer between traders and vault depositors.
- When vault is >100% collateralized: the OC absorbs trader PnL first.
- When vault is >130% collateralized: excess is used to buy back and burn GNS via OTC using a 1-hour TWAP.
- When vault is <100% collateralized: GNS is minted and sold for the vault collateral asset, diluting GNS holders.

**GNS as Backstop Risk:**
The GNS mint mechanism is the last line of defense. In extreme scenarios (massive trader wins), unlimited GNS minting could cause a death spiral:
1. Vault undercollateralized -> mint GNS
2. GNS sell pressure -> price drops
3. Need to mint more GNS to cover same dollar value
4. Repeat

This is a known risk shared with similar protocols (e.g., GMX's GLP model, though GMX uses real assets rather than synthetics). The buyback/burn mechanism during profitable periods (>$10.8M in 2025) helps mitigate this but does not eliminate it.

**Liquidation:**
- Leveraged positions are liquidated based on oracle prices.
- Leverage up to 150x (crypto), 1000x (forex), 250x (commodities).
- The extreme leverage on forex and commodities means even small oracle delays or manipulations could cause cascading liquidations.

**Risk: MEDIUM** -- The synthetic model with GNS backstop is well-tested over 4+ years but carries inherent death-spiral risk during extreme market conditions. Capital efficiency is both a strength and a risk amplifier.

### 4. Smart Contract Security

**Architecture:**
gTrade v8 introduced the Diamond Pattern (EIP-2535), making the protocol highly modular and upgradeable. Individual facets can be updated or replaced without migrating the entire system. This pattern:
- Enables rapid iteration and bug fixes.
- Increases upgrade surface area (each facet is an attack vector for malicious upgrades).
- Requires careful access control per facet.

**Audit History:**
- CertiK: 8+ audits across protocol versions (v4 through v8/v9). CertiK Skynet score of 92/100. Known finding: centralization (acknowledged, not resolved).
- Halborn: Audited current contract version.
- Cyberscope: Additional audit.
- All contract upgrades are publicly announced in advance, audited, and contain timelocks.

**Bug Bounty:**
- Active on Immunefi with up to **$400,000** maximum payout.
- Scope: smart contracts, website, and app.
- Focus: preventing direct theft of user funds at rest or in motion.
- PoC required for all submissions.
- Payouts in GNS + DAI (ratio at team discretion).

**Battle Testing:**
- Live since December 2021 (4+ years).
- No known exploits or security incidents on rekt.news or elsewhere.
- Over $56.5B in cumulative trading volume processed.
- v10 launched August 2025 without incident.
- Open source on GitHub (GainsNetwork-org).

**Risk: MEDIUM** -- Extensive audit history and zero-exploit track record are strong positives. The Diamond proxy pattern adds upgrade flexibility but also upgrade risk. The $400K bug bounty is adequate but below top-tier protocols ($10M+).

### 5. Cross-Chain & Bridge

**Multi-Chain Deployment:**
gTrade operates on 5 chains: Arbitrum (primary, ~71% of TVL), Polygon (original), Base, ApeChain, and MegaETH.

**Admin Separation:**
Whether each chain deployment has its own admin multisig or shares a single admin key is UNVERIFIED. The official docs list Arbitrum-specific contract addresses and multisig wallets, but per-chain admin independence is not documented.

**Bridge Dependencies:**
- Chainlink CCIP is being integrated for cross-chain functionality (staking, vaults).
- Native chain bridges (Arbitrum native bridge, Polygon bridge) are used for asset transfers.
- No third-party bridge dependency documented for core trading functionality.

**Risk: MEDIUM** -- Multi-chain presence increases attack surface. The reliance on native bridges is safer than third-party bridges, but the integration of CCIP introduces additional dependency. Per-chain admin separation is not documented.

### 6. Operational Security

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

**Risk: MEDIUM** -- Anonymous team is a persistent risk factor, but the 4+ year clean operational history and active security practices (audits, Immunefi, timelocks) demonstrate responsible management.

## Critical Risks

1. **GoPlus: Hidden Owner + Owner Can Change Balances (CRITICAL):** The GNS token contract on Arbitrum has mechanisms that could allow hidden ownership reassertion and balance modification. While these may be designed features for the mint/burn mechanism, they represent a single-point-of-failure if the owner key is compromised.

2. **Low Multisig Threshold (HIGH):** If the 2/3 multisig configuration is accurate, compromising just 2 keys gives an attacker full control. Combined with anonymous signers, social engineering risk is elevated.

3. **GNS Death Spiral Risk (MEDIUM-HIGH):** In extreme market conditions where traders win massively, the GNS mint mechanism could trigger a self-reinforcing devaluation cycle. This is structural and cannot be fully mitigated.

4. **Single Oracle Provider (MEDIUM):** Complete dependency on Chainlink across all oracle layers means a Chainlink outage or compromise would halt all trading and potentially cause liquidation errors.

## Peer Comparison

| Feature | Gains Network (gTrade) | GMX | dYdX |
|---------|----------------------|-----|------|
| Timelock | 14d (owner) / 3d (manager) / 0 (admin) | 24h | On-chain governance |
| Multisig | 2/3 (UNVERIFIED) | 3/6 (partially doxxed) | Validator set (60+ validators) |
| Audits | 8+ (CertiK, Halborn) | 5+ (ABDK, Guardians) | 10+ (Trail of Bits, Informal) |
| Oracle | Chainlink custom DON + Data Streams | Chainlink + custom keeper | In-house + Pyth |
| Insurance/TVL | OC layer (undisclosed %) | ~3-5% (GLP fees) | Insurance fund (~2%) |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | $400K (Immunefi) | $5M (Immunefi) | $250K |
| Trading Model | Synthetic (single vault counterparty) | Real assets (GM pools) | Order book (CLOB) |
| Max Leverage | 1000x (forex) | 100x | 20x |
| TVL | ~$19M | ~$500M | ~$300M |

**Observations:**
- gTrade's 14-day owner timelock is best-in-class among perps DEXs.
- The 2/3 multisig (if accurate) is the weakest among peers.
- GMX's $5M bug bounty dwarfs gTrade's $400K.
- gTrade's synthetic model enables extreme leverage (1000x forex) that peers do not offer, which is both a competitive advantage and a risk amplifier.
- TVL is significantly lower than peers, suggesting either lower adoption or more capital efficiency.

## Recommendations

1. **Verify multisig configuration on-chain.** The conflicting reports of "2/3" vs "4+ signers" should be resolved by checking the actual Safe/multisig contract on Arbiscan before depositing significant funds.

2. **Monitor vault collateralization.** Track the OC ratio; undercollateralization triggers GNS minting which dilutes holders. The protocol's real-time vault data at gains.trade/vaults provides this information.

3. **Be aware of GoPlus flags.** The hidden_owner and owner_change_balance flags on the GNS token are structural risks. Users holding significant GNS positions should monitor for unusual admin transactions.

4. **Diversify oracle exposure.** The complete Chainlink dependency is a systemic risk. Users should be aware that a Chainlink outage could affect all open positions.

5. **Use conservative leverage.** The 1000x forex leverage amplifies both gains and liquidation risk, especially during oracle latency periods. Consider staying well below maximum leverage.

6. **Prefer Arbitrum deployment.** With ~71% of TVL on Arbitrum, it is the most liquid and likely best-maintained deployment. Smaller chain deployments carry additional risk from lower liquidity and potentially delayed security patches.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- UNVERIFIED
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED (GTokenAdmin has no timelock)
- [x] Multisig has low threshold (2/N with small N)? -- Yes, 2/3 reported
- [ ] Zero or short timelock on governance actions? -- No, 14d for owner actions
- [ ] Pre-signed transaction risk? -- N/A (EVM, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- Yes, all signers anonymous

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- No, synthetic model uses stablecoins + ETH as vault collateral
- [ ] Single oracle source without TWAP? -- No, custom DON uses median of multiple sources + TWAP for OC buybacks
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [ ] Insufficient insurance fund relative to TVL? -- OC layer exists but ratio undisclosed

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- CCIP integration uses Chainlink validators (decentralized)
- [x] Admin keys stored in hot wallets? -- UNVERIFIED (anonymous team, storage method unknown)
- [ ] No key rotation policy? -- UNVERIFIED

**Pattern match summary:** Gains Network shows 2 confirmed Drift-type indicators (low multisig threshold, anonymous signers) and 1 confirmed Ronin-type indicator (unknown key storage). The strong timelock architecture (14d) partially mitigates the Drift-type risk, but the GTokenAdmin role with zero timelock is a potential bypass that needs further investigation.

## Information Gaps

- **Exact multisig configuration**: Conflicting reports of 2/3 vs 4+ signers. Not verified on-chain.
- **GTokenAdmin role scope**: What specific actions can be taken with zero timelock? Can it drain funds or only pause?
- **Per-chain admin separation**: Whether each of the 5 chain deployments has independent admin keys.
- **Overcollateralization ratio**: Current OC% for each vault is not available from public APIs (visible on UI only).
- **Insurance fund size**: No explicit insurance fund separate from the OC mechanism; exact dollar amount of the buffer is undisclosed.
- **Multisig signer identities**: All signers are anonymous. No information on key storage practices (hardware wallet, MPC, etc.).
- **Oracle admin powers**: Whether admin can change oracle sources, add new trading pairs without timelock, or modify oracle parameters.
- **Circuit breaker mechanisms**: Whether the platform has automated circuit breakers for extreme price movements.
- **Cross-chain message validation**: How governance actions propagate across 5 chains and whether a compromised bridge could forge admin actions.
- **Hidden owner mechanism details**: What the GoPlus-detected hidden_owner flag specifically refers to in the GNS contract code.
- **Emergency upgrade history**: Whether the protocol has ever performed an emergency upgrade bypassing the timelock.
- **Key rotation and backup procedures**: No documentation found on operational security practices for admin keys.

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
