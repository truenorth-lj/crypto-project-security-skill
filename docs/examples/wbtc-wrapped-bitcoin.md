# DeFi Security Audit: Wrapped Bitcoin (WBTC)

**Audit Date:** April 6, 2026
**Protocol:** Wrapped Bitcoin (WBTC) -- Custodial wrapped BTC on Ethereum

## Overview
- Protocol: Wrapped Bitcoin (WBTC)
- Chain: Ethereum (primary), Solana (via Hyperlane bridge, launched Feb 2026)
- Type: Bridge / Wrapped Asset (custodial)
- TVL: ~$7.8B (DeFiLlama)
- TVL Trend: +0.6% / -2.9% / -32.7% (7d / 30d / 90d)
- Launch Date: January 2019
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: WrappedBTC/bitcoin-token-smart-contracts)

## Quick Triage Score: 52/100

Scoring (start at 100, subtract mechanically):

- [x] MEDIUM: is_mintable = 1 (-8)
- [x] MEDIUM: transfer_pausable = 1 (-8)
- [x] MEDIUM: Multisig threshold < 3 signers on custody keys (2-of-3) (-8)
- [x] LOW: No documented timelock on admin actions (-5)
- [x] LOW: No bug bounty program on Immunefi (-5)
- [x] LOW: Undisclosed multisig signer identities (BiT Global personnel not fully doxxed) (-5)
- [x] LOW: Insurance fund / TVL undisclosed (-5)
- [x] MEDIUM: TVL dropped >30% in 90 days (-8)

Score: 100 - 8 - 8 - 8 - 5 - 5 - 5 - 5 - 8 = **52**

Score meaning: 50-79 = MEDIUM risk

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | N/A (no insurance fund; custodial model) | N/A for custodial assets | MEDIUM |
| Audit Coverage Score | 0.75 (ChainSecurity 2019 = 0.25; 2 others ~2019 = 0.50; Solana bridge 2025 = 1.0; total ~1.75) | 3.0+ (Aave) | MEDIUM |
| Governance Decentralization | DAO multisig 8/13; custody keys 2-of-3 | DAO (Aave 6/10) | MEDIUM |
| Timelock Duration | None confirmed on custody or minting | 24-48h (Aave, Compound) | HIGH |
| Multisig Threshold (Custody) | 2-of-3 (BitGo US, BitGo SG, BiT Global HK) | 4/7+ (institutional standard) | HIGH |
| Multisig Threshold (DAO) | 8-of-13 | 6/10 (Aave) | LOW |
| GoPlus Risk Flags | 0 HIGH / 2 MED (mintable, pausable) | -- | LOW |

### Audit Coverage Score Calculation
- ChainSecurity WBTC audit (~2019): >2 years old = 0.25
- Two additional audits (~2019, per DeFiLlama "audits: 2"): >2 years old = 0.25 each = 0.50
- ChainSecurity Solana Bridge audit (~2025): <1 year old = 1.0
- **Total: ~1.75** -- MEDIUM risk (threshold: >= 3.0 = LOW)

## GoPlus Token Security (WBTC on Ethereum: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599)

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
| Holders | 178,429 | -- |
| Trust List | Yes (1) | -- |
| Creator Honeypot History | No (0) | -- |

GoPlus assessment: **LOW RISK** at the token contract level. WBTC is mintable (by design -- minting creates new WBTC when BTC is deposited) and transfers are pausable (admin can halt transfers). Both are expected for a custodial wrapped asset but represent centralization vectors. The token is on GoPlus trust list, open source, not a proxy, no hidden owner, no honeypot, no tax. 178K+ holders indicate deep adoption.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **HIGH** | 2-of-3 custody multisig with BiT Global (Justin Sun-linked); no timelock on minting/burning | Partial |
| Oracle & Price Feeds | **LOW** | Chainlink Proof of Reserve provides on-chain BTC reserve verification | Y |
| Economic Mechanism | **MEDIUM** | Custodial trust model; no insurance fund; merchant-custodian minting process | Partial |
| Smart Contract | **LOW** | Audited, open source, 7+ years live with no contract exploits | Y |
| Token Contract (GoPlus) | **LOW** | Mintable and pausable by design; no hidden owner or honeypot flags | Y |
| Cross-Chain & Bridge | **MEDIUM** | New Solana bridge via Hyperlane (Feb 2026); limited track record | Partial |
| Operational Security | **MEDIUM** | BitGo is doxxed and reputable; BiT Global association raises counterparty concerns | Partial |
| **Overall Risk** | **MEDIUM** | **Largest wrapped BTC by market share but custodial centralization risk amplified by Justin Sun/BiT Global involvement; 2-of-3 custody key structure is below institutional best practice for $7.8B in assets** | |

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Custody Key Structure (Critical):**
WBTC uses a 2-of-3 multi-signature cold storage model for the underlying BTC reserves. After the October 2024 migration to multi-jurisdictional custody, the three keys are held by:
1. BitGo Inc. (United States)
2. BitGo Singapore
3. BiT Global (Hong Kong) -- a Justin Sun-linked entity

Any 2 of these 3 entities can authorize the movement of all ~$7.8B in BTC reserves. This is the single most important risk factor for WBTC: the custody threshold is low relative to the value secured.

**Justin Sun / BiT Global Controversy:**
In August 2024, BitGo announced a "strategic partnership" with BiT Global and Justin Sun to move WBTC to multi-jurisdictional custody. This triggered significant community backlash:
- Coinbase delisted WBTC in December 2024, citing "unacceptable risk that control of wBTC would fall into the hands of Justin Sun"
- MakerDAO stopped accepting new WBTC-backed loans
- Aave governance proposed adjusting WBTC risk parameters
- Net redemptions of ~1,350 BTC (~$90M) occurred in the two weeks following the announcement
- BiT Global sued Coinbase (later dismissed with prejudice in 2025)

Justin Sun has stated his involvement is "entirely strategic" and that he does not control private keys or have the ability to move BTC reserves. BitGo CEO Mike Belshe has defended the arrangement. UNVERIFIED -- these claims cannot be independently verified on-chain for the BTC custody keys.

**DAO Multisig:**
The WBTC DAO operates a separate 8-of-13 multisig (0xB33f8879d4608711cEBb623F293F8Da13B8A37c5) for governance actions on the Ethereum WBTC contract. This is a reasonable threshold. Known signers include BitGo, Kyber, Compound, Loopring, Balancer, Chainlink, Krystal, RiskDAO, and Badger. The DAO migrated to this new multisig after removing 11 inactive signers including the collapsed FTX exchange.

**Minting/Burning Process:**
Only approved "merchants" can initiate minting and burning. The custodian (BitGo) must approve and execute. All minting/burning is expected within 48 hours. There is no on-chain timelock on minting or burning operations -- the process is trust-based and off-chain.

**Timelock:**
No on-chain timelock has been confirmed for custody operations (BTC movement) or ERC-20 admin actions (pause, mint). This is a significant gap for a protocol securing $7.8B.

**Contract Admin Powers:**
The WBTC ERC-20 contract inherits from OwnableContract, MintableToken, BurnableToken, and PausableToken. The owner can:
- Pause all token transfers
- Mint new WBTC tokens
- The contract explicitly blocks renounceOwnership() (reverts with "renouncing ownership is blocked")

### 2. Oracle & Price Feeds -- LOW

**Chainlink Proof of Reserve:**
WBTC uses Chainlink's Proof of Reserve (PoR) mechanism to verify on-chain that WBTC supply is backed 1:1 by BTC in BitGo's custody addresses. The reference contract checks custody wallet balances approximately every 10 minutes (aligned with Bitcoin block times). Chainlink Nodes monitor off-chain and push on-chain updates when reserve changes occur (minting/burning events).

**Verification:**
BitGo's BTC custody addresses are publicly known and verifiable on the Bitcoin blockchain. The WBTC dashboard (wbtc.network/dashboard/audit) provides real-time transparency on reserves. This is a strong setup relative to peers -- many wrapped assets lack on-chain PoR.

**Limitation:**
PoR verifies balances but cannot prevent the custodian from moving BTC. If the 2-of-3 custody keys were compromised, BTC could be drained before the PoR mechanism detects the discrepancy.

### 3. Economic Mechanism -- MEDIUM

**Trust Model:**
WBTC is fundamentally a custodial trust product. Users trust that:
1. BitGo/BiT Global will maintain 1:1 BTC backing
2. Merchants will process minting/burning in a timely manner
3. The custody keys will not be compromised or misused

There is no algorithmic peg, no insurance fund, no socialized loss mechanism, and no on-chain collateral. If the custodian absconds with the BTC, WBTC holders have no on-chain recourse.

**Merchant Model:**
Only approved merchants (institutional entities like Kyber, Ren, etc.) can mint/burn WBTC. Retail users must go through merchants or trade on secondary markets. This adds a counterparty layer but also limits the attack surface for unauthorized minting.

**Market Impact of Custody Controversy:**
The Justin Sun/BiT Global controversy led to significant supply contraction. WBTC TVL dropped from ~$11.6B (90 days ago) to ~$7.8B currently (-32.7%), reflecting both BTC price movements and net redemptions. Competitors like cbBTC and tBTC have gained market share.

### 4. Smart Contract Security -- LOW

**Audit History:**
- ChainSecurity audit of WBTC ERC-20 contract (~2019): Found 2 issues (pausing mechanism and hash collision via abi.encodePacked). Both addressed.
- DeFiLlama lists 2 audits total for the core protocol.
- ChainSecurity audit of WBTC Solana Bridge (~2025): Found only minor issues, all addressed. Covered minting/burning flow, access control, and data account sanitization.

**Code Quality:**
ChainSecurity described WBTC as "a very well-coded smart contract with clean documentation." The ERC-20 contract is straightforward -- it is not upgradeable (no proxy), reducing the risk of malicious upgrades.

**Battle Testing:**
WBTC has been live on Ethereum since January 2019 (7+ years). It has not suffered any direct smart contract exploits. The contract itself is simple by DeFi standards (ERC-20 with mint/burn/pause). Peak TVL exceeded $15B.

**Incidents Involving WBTC:**
WBTC has been involved in third-party exploits (Nomad Bridge hack in August 2022 included WBTC among stolen assets; various DeFi exploits on platforms that use WBTC as collateral), but none targeted the WBTC contract itself. A notable $68M address poisoning attack in 2024 tricked a user into sending WBTC to a wrong address -- this was a social engineering attack, not a contract vulnerability.

**Bug Bounty:**
No dedicated WBTC bug bounty program was found on Immunefi or other platforms. This is a gap for a protocol of this size.

### 5. Cross-Chain & Bridge -- MEDIUM

**Solana Deployment (Feb 2026):**
WBTC recently expanded to Solana via the Hyperlane Nexus bridge. This locks WBTC on Ethereum and mints a canonical representation on Solana. The bridge uses Hyperlane's permissionless messaging infrastructure rather than centralized validators.

**Bridge Security:**
- Hyperlane allows customizable security models for each bridge deployment
- The WBTC integration reportedly uses a "verified implementation" with strong security guarantees
- However, this is a very new deployment (approximately 2 months old as of this audit) with limited battle-testing
- The Solana bridge was audited by ChainSecurity with only minor findings

**Risk:**
If the Hyperlane bridge were compromised, it could result in unbacked WBTC on Solana. The bridge does not introduce risk to the Ethereum WBTC supply directly, but Solana WBTC holders face additional bridge risk on top of the custodial risk.

**Multi-Chain Governance:**
It is UNVERIFIED whether the Solana deployment has independent admin controls or shares governance with the Ethereum DAO multisig.

### 6. Operational Security -- MEDIUM

**Team:**
- BitGo: Founded 2013, CEO Mike Belshe (doxxed, well-known in crypto). Regulated US trust company. Strong institutional reputation.
- BiT Global: Hong Kong-based entity linked to Justin Sun. Relatively new entity with limited public track record independent of the WBTC partnership. Personnel details are not fully public.
- Justin Sun: Tron founder, controversial figure. Involved in multiple crypto ventures. Subject of SEC charges (settled). His stated role in WBTC is "strategic" with no direct key control. UNVERIFIED.

**Incident Response:**
BitGo has demonstrated competent incident response historically -- notably declining Alameda Research's attempt to redeem 3,000 WBTC days before the FTX bankruptcy, preventing potential fund misuse.

**Regulatory Risk:**
WBTC's custody now spans three jurisdictions (US, Singapore, Hong Kong). This introduces regulatory complexity. If any jurisdiction imposed sanctions or seizure orders on the custody keys, it could affect the ability to mint/burn WBTC or even freeze underlying BTC.

**Communication:**
The WBTC project maintains a Twitter (@WrappedBTC), website (wbtc.network), and GitHub (WrappedBTC). Communication during the BiT Global transition was reactive rather than proactive, leading to avoidable community panic.

## Critical Risks

1. **2-of-3 Custody Key Threshold for $7.8B in BTC** -- The low multisig threshold means only 2 entities need to collude or be compromised to drain all reserves. For comparison, institutional best practice for this TVL level would be 4-of-7 or higher. This is the single most consequential risk.

2. **BiT Global / Justin Sun Association** -- The involvement of a Justin Sun-linked entity as one of three custody key holders introduces reputational, regulatory, and counterparty risk. Major institutions (Coinbase, MakerDAO) have already reduced WBTC exposure. Justin Sun's claim of no key access is UNVERIFIED.

3. **No Timelock on Custody Operations** -- BTC reserves can be moved with 2-of-3 approval and no delay. There is no on-chain mechanism to give the community warning before large BTC movements.

4. **No Bug Bounty Program** -- A $7.8B protocol with no formal bug bounty is an outlier. While the ERC-20 contract is simple, the broader system (custody, minting, bridge) would benefit from security researcher incentives.

## Peer Comparison

| Feature | WBTC | cbBTC (Coinbase) | tBTC (Threshold) |
|---------|------|------------------|------------------|
| Custody Model | 2-of-3 multisig (BitGo, BitGo SG, BiT Global) | Single custodian (Coinbase) | Decentralized (Threshold Network nodes) |
| Timelock | None confirmed | None confirmed | N/A (permissionless) |
| Proof of Reserve | Chainlink PoR (on-chain) | None (trust Coinbase) | On-chain (BTC locked in threshold signatures) |
| Audits | 2-3 (ChainSecurity + others) | UNVERIFIED | Multiple (Least Authority, others) |
| Open Source | Yes | UNVERIFIED | Yes |
| TVL | ~$7.8B | ~$2.5B (est.) | ~$220M |
| Bug Bounty | None found | UNVERIFIED | Yes (Immunefi) |
| Regulatory Entity | BitGo Trust (US-regulated) | Coinbase (US publicly traded) | Threshold DAO (decentralized) |
| Centralization | HIGH (custodial, 2-of-3) | CRITICAL (single entity) | LOW (decentralized) |

## Recommendations

1. **Monitor custody key activity** -- Track BitGo's known BTC custody addresses for unusual movements. Chainlink PoR provides near-real-time monitoring.
2. **Diversify wrapped BTC exposure** -- Consider splitting holdings across WBTC, tBTC, and/or cbBTC to reduce single-custodian risk.
3. **Demand timelock implementation** -- Community should advocate for an on-chain timelock on large BTC movements from custody addresses.
4. **Track BiT Global developments** -- Any changes in BiT Global's corporate structure, jurisdiction, or key personnel should be treated as material risk events.
5. **New Solana bridge users should wait** -- The Hyperlane bridge is only ~2 months old. Users with significant positions should wait for further battle-testing before bridging large amounts.
6. **Verify PoR independently** -- Use the WBTC dashboard (wbtc.network/dashboard/audit) and Chainlink PoR contract to independently verify 1:1 backing rather than relying on third-party reporting.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- N/A (not a lending protocol)
- [ ] Admin can change oracle sources arbitrarily? -- No, Chainlink PoR is separate from custody
- [ ] Admin can modify withdrawal limits? -- N/A (merchant model, but custodian controls all BTC movement)
- [x] Multisig has low threshold (2/N with small N)? -- **YES: 2-of-3 on custody keys**
- [x] Zero or short timelock on governance actions? -- **YES: No confirmed timelock on custody operations**
- [ ] Pre-signed transaction risk? -- UNVERIFIED for BTC custody keys
- [x] Social engineering surface area (anon multisig signers)? -- **YES: BiT Global personnel not fully doxxed**

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A
- [ ] Single oracle source without TWAP? -- N/A (PoR is informational, not price-setting)
- [ ] No circuit breaker on price movements? -- N/A
- [ ] Insufficient insurance fund relative to TVL? -- **YES: No insurance fund exists**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- **YES: 2-of-3 custody keys are the ultimate bridge**
- [ ] Admin keys stored in hot wallets? -- No, cold storage confirmed
- [x] No key rotation policy? -- **UNVERIFIED: No public key rotation policy documented**

**Pattern Match: Ronin/Harmony-type risk is ELEVATED.** WBTC's 2-of-3 key structure is structurally similar to the Ronin Bridge (5-of-9 validators compromised, 4 held by Sky Mavis) and Harmony Horizon Bridge (2-of-5 multisig). The Harmony hack in particular exploited a low multisig threshold on a bridge securing hundreds of millions. WBTC's 2-of-3 threshold with $7.8B at stake is a higher-value target with a similarly low threshold.

## Information Gaps

- **BiT Global internal controls**: What security practices does BiT Global use for its custody key? Hardware security modules? Key ceremony procedures? Personnel access controls? -- Not publicly documented.
- **Justin Sun's actual relationship with BiT Global**: The extent of his control, ownership stake, and operational influence remains opaque despite public statements.
- **Key rotation policy**: Whether and how often the 2-of-3 custody keys are rotated is not publicly documented.
- **Emergency procedures**: What happens if one key holder becomes unresponsive, sanctioned, or compromised? Is there a recovery mechanism?
- **Insurance coverage**: Whether BitGo carries institutional insurance covering WBTC custody specifically, and what the coverage limits are.
- **DAO signer identities**: While organizations are named (BitGo, Kyber, Compound, etc.), the specific individuals who sign for the 8-of-13 DAO multisig are not all publicly identified.
- **Solana bridge security model**: The specific Hyperlane security configuration (ISM modules, validator set) used for the WBTC bridge is not fully documented.
- **Regulatory status**: Whether the multi-jurisdictional custody arrangement has received explicit regulatory approval in all three jurisdictions (US, Singapore, Hong Kong).
- **Bug bounty**: No formal program found; unclear if BitGo has an internal responsible disclosure policy for the WBTC system.

## Disclaimer

This analysis is based on publicly available information and web research as of April 6, 2026.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
