# DeFi Security Audit: Ethena (USDe)

**Audit Date:** April 5, 2026
**Protocol:** Ethena -- Synthetic dollar protocol (USDe stablecoin)

## Overview
- Protocol: Ethena (USDe / sUSDe / USDtb)
- Chain: Ethereum (primary), plus 23+ chains via LayerZero OFT
- Type: Synthetic Dollar / Stablecoin (delta-neutral hedging)
- TVL: ~$6.64B
- TVL Trend: +0.1% / -0.9% / +2.4% (7d / 30d / 90d)
- Launch Date: December 2023
- Audit Date: April 5, 2026
- Source Code: Open (GitHub: ethena-labs)

## Quick Triage Score: 59/100

Starting at 100, the following deductions apply:

- (-8) MEDIUM: `is_mintable = 1` on USDe -- expected for a stablecoin minting contract but still a privileged function
- (-8) MEDIUM: `is_mintable = 1` on ENA -- governance token is mintable
- (-5) INFO: Centralized custodian dependency (Fireblocks, Copper, Ceffu) -- not a smart contract risk but a counterparty risk
- (-5) INFO: Centralized exchange counterparty exposure for hedging positions (Binance, Bybit, OKX, Deribit)
- (-5) INFO: Reserve fund / TVL ratio at ~1.18% is below the 5% healthy threshold
- (-5) INFO: Oracle architecture for internal pricing not fully transparent
- (-2) Minor: Reserve fund multisig is 4/10, lower threshold than the main protocol multisig (5/11)
- (-3) MEDIUM: Protocol multisig threshold is 5/11 (45%), significantly lower than the previously claimed 7/10 (70%) -- verified on-chain (Safe API, April 2026)

Red flags found: 0 CRITICAL, 0 HIGH, 3 MEDIUM, 4 INFO

Score meaning: 50-79 = MEDIUM risk. The score reflects the protocol's inherent custodial and counterparty dependencies rather than smart contract weaknesses.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | ~1.18% (~$77M) | 1-5% (DAI: ~5%, FRAX: ~2%) | MEDIUM |
| Audit Coverage Score | 3.25 | 2-4 avg | LOW |
| Governance Decentralization | Multisig + Governance Forum | DAO vote avg | MEDIUM |
| Timelock Duration | Present (exact hours UNVERIFIED) | 24-48h avg | MEDIUM |
| Multisig Threshold | 5/11 (protocol, verified on-chain) / 4/10 (reserve) | 3/5 avg | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 2 MED (mintable x2) | -- | LOW |

**Audit Coverage Score Calculation:**
- Code4rena (Oct 2023): >2yr old = 0.25
- Pashov (May 2024): ~2yr old = 0.5
- Pashov (Sep 2024): ~1.5yr old = 0.5
- Quantstamp (Oct 2024): ~1.5yr old = 0.5
- Cyfrin (Oct 2024): ~1.5yr old = 0.5
- Code4rena Invitational (Nov 2024): ~1.5yr old = 0.5
- Pashov (Oct 2024, USDtb): ~1.5yr old = 0.5
- Total: 3.25 (LOW risk threshold: >= 3.0)

## GoPlus Token Security

### USDe (0x4c9EDD5852cd905f086C759E8383e09bff1E68B3)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | No | -- |
| Mintable | Yes | MEDIUM |
| Owner Can Change Balance | No | -- |
| Hidden Owner | No | -- |
| Selfdestruct | No | -- |
| Transfer Pausable | No | -- |
| Blacklist | No | -- |
| Slippage Modifiable | No | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 45,562 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No | -- |

USDe top holder concentration: Top 3 holders (all contracts) control ~88.4% of supply. The largest holder (0x9d39...3497) holds ~59.9%, likely the sUSDe staking contract or minting contract. This is expected for a stablecoin where large contract integrations dominate.

### ENA (0x57e114B691Db790C35207b2e685D4A43181e6061)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No | -- |
| Open Source | Yes | -- |
| Proxy | No | -- |
| Mintable | Yes | MEDIUM |
| Owner Can Change Balance | No | -- |
| Hidden Owner | No | -- |
| Selfdestruct | No | -- |
| Transfer Pausable | No | -- |
| Blacklist | No | -- |
| Slippage Modifiable | No | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 90,082 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No | -- |
| CEX Listed | Binance, Coinbase | -- |

GoPlus assessment: **LOW RISK** for both tokens. The only flag is `is_mintable = 1`, which is expected -- USDe must be mintable for its core function, and ENA is a governance token with controlled minting. No honeypot, no hidden owner, no tax, no trading restrictions, no self-destruct, no pause capability.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | 5/11 multisig (45% threshold) is weaker than previously claimed 7/10 (70%); timelock specifics and bypass powers are not fully transparent | Verified on-chain (Safe API, April 2026) |
| Oracle & Price Feeds | **MEDIUM** | Internal pricing for delta-neutral positions; USDe/USD feeds on Chainlink/Pyth exist for DeFi consumers | Partial |
| Economic Mechanism | **HIGH** | Funding rate risk, CEX counterparty exposure, reserve fund at 1.18% of TVL | Partial |
| Smart Contract | **LOW** | 7+ audits from reputable firms, no critical findings, $3M bug bounty | Y |
| Token Contract (GoPlus) | **LOW** | Mintable (expected), no honeypot, no hidden owner, no tax | Y |
| Cross-Chain & Bridge | **MEDIUM** | LayerZero OFT across 23+ chains; third-party bridge dependency | Partial |
| Operational Security | **LOW** | Doxxed team (Guy Young), established TradFi backgrounds, Immunefi bounty | Y |
| **Overall Risk** | **MEDIUM** | **Strong smart contract security offset by significant custodial and economic mechanism risks** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**Multisig Configuration (Verified on-chain via Safe Transaction Service API, April 2026):**
- Protocol smart contract ownership is held by a Gnosis Safe v1.3.0 multisig at `0x3b0AAf6e6fCd4a7cEEf8c92C32DFea9E64DC1862`
- On-chain verification shows **5/11 threshold** (45%), not the 7/10 (70%) previously claimed in documentation -- this is a materially weaker security posture
- 11 owner addresses verified on-chain:
  - `0x18d32B1AB042b5E9a3430e77fDE8B4783A019234`
  - `0xb93C042c688F1Cf038bab03C4F832F2630Bb7d8F`
  - `0x66892C66711B2640360C3123E6C23C0cFa50550F`
  - `0xE3F95F2e1aDEC092337FB5D93C1fE87558658b11`
  - `0x99682F56F4ccCF61BD7e449924f2f62D395e1E45`
  - `0x980742eDEA6b0df3566C19Ff4945c57E95449a13`
  - `0x690d1E0fac0599874b849EE88AeA27F7b348e1f2`
  - `0x54D0D64f7326b128959bf37Ed7B5f2510656a471`
  - `0xFBE49A82CB2BFF6Fa4C2b1F0d165A5E1175Aac83`
  - `0xE987E14b2E204fdf5827a3cFCa7D476E8Df6a99E`
  - `0xe5cA87dA3A209aD85FdcbB515e1bD92644e9E1A6`
- No Safe modules enabled (reduces module-based bypass risk)
- Keys are geographically distributed across both internal Ethena Labs team members and external stakeholders
- All multisig keys are cold wallets
- The multisig is used solely for contract ownership, not for holding funds
- **NOTE:** A 45% threshold means only 5 of 11 signers need to collude or be compromised for full admin control. This is below the commonly recommended 60%+ threshold for high-value DeFi protocols

**Admin Powers (DEFAULT_ADMIN_ROLE via multisig):**
- Transfer ownership of contracts
- Add/remove supported collateral assets
- Add/remove custodian addresses
- Set USDe contract address
- These are sensitive functions that could redirect minting or change the protocol's operational parameters

**Timelock:**
- Documentation confirms timelocks exist on sensitive role changes (e.g., GATEKEEPER_ROLE)
- Exact timelock durations are not clearly published in available documentation -- UNVERIFIED
- Whether emergency bypass roles exist is not documented publicly -- UNVERIFIED

**Reserve Fund Multisig:**
- The reserve fund is controlled by a separate 4/10 multisig
- All keys held by Ethena Labs contributors (no external signers disclosed)
- Lower threshold than protocol multisig (4/10 vs 5/11) -- this is a weaker link

**Governance Process:**
- ENA token holders vote on key protocol decisions via Snapshot-style governance
- Bi-annual Risk Committee elections
- Recent governance actions include fee switch activation and Ethereal integration (99.6% approval)
- Governance is still relatively centralized with Ethena Labs having significant influence

**Token Concentration (ENA):**
- Top holder (EOA) controls ~9.8% of supply
- Top 10 holders control ~63.6% (mix of EOAs and contracts)
- High concentration, but many top holders appear to be institutional/vesting contracts -- UNVERIFIED

### 2. Oracle & Price Feeds -- MEDIUM

**External Price Feeds:**
- USDe/USD price feeds are available on both Chainlink and Pyth for DeFi integrations
- RedStone also provides Ethena-related price data
- These feeds track the secondary market price of USDe

**Internal Pricing (for delta-neutral positions):**
- The protocol's core mechanism relies on pricing derivatives positions across centralized exchanges
- Internal pricing methodology for calculating NAV and hedge ratios is not fully transparent
- The protocol uses exchange APIs for real-time pricing of perpetual futures positions -- UNVERIFIED

**Key Concerns:**
- No documented circuit breaker for abnormal price movements in the hedging mechanism
- Admin ability to change oracle sources or pricing methodology is not clearly documented
- The protocol's pricing is fundamentally different from collateral-based stablecoins -- it depends on accurate mark-to-market of derivatives positions

### 3. Economic Mechanism -- HIGH

This is the highest-risk area for Ethena, as the protocol's novel design introduces risks not found in traditional stablecoins.

**Delta-Neutral Strategy:**
- USDe is backed by crypto collateral (primarily ETH and BTC) paired with short perpetual futures positions on centralized exchanges
- The short position offsets the price risk of the collateral, creating a "delta-neutral" position
- When funding rates are positive (the historical norm), the protocol earns revenue; when negative, it pays

**Funding Rate Risk:**
- Historical average funding rates for BTC/ETH have been 7.8-9% annualized over the last 3+ years
- However, prolonged bear markets can produce sustained negative funding rates
- During negative funding periods, the reserve fund absorbs losses
- If negative funding persists longer than the reserve fund can cover, USDe could become undercollateralized

**Reserve Fund Adequacy:**
- Current reserve fund: ~$77M (~1.18% of TVL)
- This is below the 5% "healthy" threshold used in the audit methodology
- The fund is growing via protocol revenue allocation, but its current size provides limited runway during extreme negative funding scenarios
- Reserve fund composition: primarily USDtb (BlackRock BUIDL-backed stablecoin) and other liquid stablecoins

**Custodial Counterparty Risk:**
- Assets are held off-exchange via "Off-Exchange Settlement" (OES) with Copper, Fireblocks, and Ceffu
- CEXs (Binance, Bybit, OKX, Deribit) do not hold collateral directly -- positions are mirrored
- However, the protocol still has counterparty exposure: if a CEX becomes insolvent, the short positions could be lost while collateral is safe (creating a net long exposure)
- If a custodian (Copper, Fireblocks, Ceffu) has operational issues, asset availability and settlement could be disrupted

**Redemption Mechanism:**
- Minting and redemption are permissioned -- only 20 whitelisted addresses can mint/redeem
- This is not permissionless like USDC redemption or DAI's vault system
- Users must rely on secondary market liquidity (DEX/CEX) or go through authorized participants
- During stress events, this could limit exit liquidity for retail holders

### 4. Smart Contract Security -- LOW

**Audit History:**
- Code4rena competitive audit (October 2023)
- Pashov audit (May 2024) -- no critical/high findings
- Pashov audit (September 2024) -- no critical/high findings
- Quantstamp audit (October 2024) -- no critical/high findings
- Cyfrin audit (October 2024) -- no critical/high findings
- Code4rena invitational audit (November 2024)
- Additional Pashov audit for USDtb (October 2024) -- no critical/high findings
- Total: 7+ audits from 4 distinct firms/platforms

**Bug Bounty:**
- Active Immunefi program since April 2024
- Maximum payout: $3M for critical smart contract bugs (10% of funds affected)
- Minimum critical reward: $100K
- KYC required for payouts
- Immunefi Standard Badge achieved

**Battle Testing:**
- Protocol live since December 2023 (~2.3 years)
- Peak TVL exceeded $6.6B
- No smart contract exploits in production
- Only security incidents were frontend/DNS-level (September 2024 domain registrar compromise, July 2024 Discord hack) -- neither affected on-chain funds

**Code Quality:**
- Open source on GitHub (ethena-labs)
- Contracts are not proxies (per GoPlus), reducing upgrade risk for the token contracts themselves
- Core minting/staking contracts use well-understood patterns

### 5. Cross-Chain & Bridge -- MEDIUM

**Multi-Chain Deployment:**
- USDe is deployed on 23+ chains via LayerZero's OFT (Omnichain Fungible Token) standard
- Chains include Ethereum (canonical), Arbitrum, Base, Optimism, Solana, BNB Chain, Mantle, Mode, Frax, and others
- sUSDe staking accessible from 18 chains via LayerZero OVault

**Bridge Architecture:**
- LayerZero serves as the primary cross-chain infrastructure
- LayerZero is a third-party bridge with its own security model (DVN-based validation)
- USDe on non-Ethereum chains is a bridged representation, not natively minted

**Key Concerns:**
- A LayerZero vulnerability or compromise could affect USDe on all 23+ chains simultaneously
- Governance actions presumably originate from Ethereum -- cross-chain message security details are not publicly documented
- Whether each chain has independent admin controls or all are managed from Ethereum is UNVERIFIED
- LayerZero has been independently audited, but the integration-specific security for Ethena's OFT deployment is not separately documented

### 6. Operational Security -- LOW

**Team:**
- Founder/CEO: Guy Young -- doxxed, former TradFi professional (Cerberus Capital Management, 2016-2022)
- Head of Risk: Seraphim Czecker -- former Head of Risk at Euler Labs, Goldman Sachs EM FX trader
- Director of Research: Conor Ryder -- former Kaiko research analyst
- COO: Elliot Parker -- former Paradigm product manager
- Strong TradFi and crypto risk management backgrounds

**Incident Response:**
- Demonstrated incident response during September 2024 frontend compromise (domain registrar hack)
- Quickly deactivated frontend and communicated via social channels
- Protocol funds were unaffected
- Emergency pause capability exists via GATEKEEPER_ROLE -- UNVERIFIED whether it can pause all operations

**Key Dependencies:**
- Custodians: Copper, Fireblocks, Ceffu (all established institutional-grade custody providers)
- CEXs: Binance, Bybit, OKX, Deribit (for hedging positions)
- LayerZero: for cross-chain USDe
- BlackRock BUIDL: backing for USDtb and reserve fund assets
- Failure of any single CEX or custodian would create material risk

**Transparency:**
- Regular reserve fund updates published on governance forum
- Third-party attestations of backing -- UNVERIFIED frequency and scope
- GitHub is open source

## Critical Risks (if any)

1. **CEX Counterparty Insolvency (HIGH):** If a major centralized exchange holding Ethena's short positions becomes insolvent (FTX-style event), the protocol would lose hedge positions while retaining collateral, creating a net long exposure that could destabilize the peg. The OES mechanism mitigates this by keeping collateral off-exchange, but the short side remains exposed.

2. **Sustained Negative Funding (HIGH):** A prolonged bear market with deeply negative funding rates could drain the ~$77M reserve fund. At 1.18% of TVL, the reserve provides limited runway. If exhausted, sUSDe yields would go negative and the USDe peg could break.

3. **Custodian Failure (MEDIUM):** Operational disruption at Copper, Fireblocks, or Ceffu could temporarily freeze access to backing assets, preventing mints/redemptions and potentially causing secondary market de-pegging.

## Peer Comparison

| Feature | Ethena (USDe) | MakerDAO / Sky (DAI/USDS) | Frax (FRAX) |
|---------|--------------|---------------------------|-------------|
| Timelock | Present (duration UNVERIFIED) | 48h (GSM) | 24-72h |
| Multisig | 5/11 Gnosis Safe (verified on-chain) | Governance DAO vote | 3/5 multisig |
| Audits | 7+ (Code4rena, Pashov, Quantstamp, Cyfrin) | 20+ (Trail of Bits, others) | 10+ |
| Oracle | Internal pricing + Chainlink/Pyth/RedStone | Chainlink + Maker oracles | Chainlink + Frax oracles |
| Insurance/TVL | ~1.18% | ~5%+ (Surplus Buffer) | ~2% |
| Open Source | Yes | Yes | Yes |
| Mechanism | Delta-neutral hedging | Overcollateralized vaults | Hybrid (AMO + collateral) |
| Custodian Risk | High (Copper, Fireblocks, Ceffu, CEXs) | Low (on-chain) | Low (on-chain) |
| Time in Production | ~2.3 years | ~8+ years | ~4+ years |

Ethena's smart contract security is comparable to peers, but its economic mechanism introduces custodial and counterparty risks that fully on-chain stablecoins do not carry.

## Recommendations

1. **For users holding USDe:** Understand that USDe is not a traditional stablecoin. Its peg depends on derivatives markets functioning normally and CEX counterparties remaining solvent. Monitor the reserve fund size relative to TVL.

2. **For sUSDe stakers:** Yields are derived from funding rates, which can turn negative. During bear markets, sUSDe returns may drop to zero or go negative.

3. **For governance (ENA holders):** Advocate for increasing the reserve fund to at least 3-5% of TVL. The current 1.18% provides thin protection during tail events.

4. **For DeFi integrators:** When accepting USDe as collateral, apply conservative collateral factors. The asset carries custodial and economic risks beyond typical stablecoins. Layer additional monitoring for CEX insolvency events.

5. **For all users:** Ethena should be encouraged to publish exact timelock durations and emergency bypass powers transparently. The protocol multisig threshold of 5/11 (45%) is weaker than commonly documented (7/10) and should be raised to at least 7/11 (64%) for a protocol of this TVL. The reserve fund multisig (4/10, internal-only signers) should include external signers.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- UNVERIFIED (admin can add collateral assets)
- [ ] Admin can change oracle sources arbitrarily? -- UNVERIFIED
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED (redemption is permissioned to 20 addresses)
- [x] Multisig has low threshold (2/N with small N)? -- PARTIAL: 5/11 (45%) is below the recommended 60%+ threshold for high-value protocols (verified on-chain, April 2026)
- [ ] Zero or short timelock on governance actions? -- UNVERIFIED (timelocks exist but duration unclear)
- [ ] Pre-signed transaction risk? -- N/A (EVM, not Solana)
- [ ] Social engineering surface area? -- MEDIUM: keys distributed across internal/external parties, but only 5 of 11 needed (lower barrier than expected)

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- NO: primarily ETH and BTC
- [ ] Single oracle source without TWAP? -- UNVERIFIED for internal pricing
- [ ] No circuit breaker on price movements? -- UNVERIFIED
- [x] Insufficient insurance fund relative to TVL? -- YES: 1.18% is below 5% threshold

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- PARTIAL: LayerZero DVN model is semi-decentralized
- [ ] Admin keys stored in hot wallets? -- NO: all cold wallets per documentation
- [ ] No key rotation policy? -- UNVERIFIED

## Information Gaps

The following questions could NOT be answered from publicly available information and represent unknown risks:

1. **Exact timelock durations** for admin actions (hours? days?) -- documentation references timelocks but does not specify durations clearly
2. **Emergency bypass powers** -- whether any role can bypass the timelock for upgrade or drain operations
3. **Internal pricing methodology** -- how the protocol marks derivatives positions to market and calculates NAV
4. **CEX exposure breakdown** -- what percentage of hedging positions are on each exchange (concentration risk)
5. **Custodian SLA details** -- recovery procedures if a custodian experiences operational failure
6. **Cross-chain admin architecture** -- whether each of the 23+ chains has independent admin controls or all are centrally managed
7. **Reserve fund drawdown triggers** -- at what threshold the reserve fund begins paying for negative funding, and whether there is an automatic wind-down mechanism
8. **Third-party attestation schedule** -- how often and by whom backing attestations are performed
9. **Key rotation and operational security policies** -- rotation frequency for multisig signers
10. **Maximum exposure limits per CEX** -- whether there are hard caps on position concentration at any single exchange

These gaps are notable because Ethena's risk profile is dominated by off-chain operational factors (custodians, CEXs, funding rates) rather than on-chain smart contract logic. The off-chain components are inherently less transparent.

## Disclaimer

This analysis is based on publicly available information and web research as of April 5, 2026, with on-chain multisig verification via Safe Transaction Service API performed April 6, 2026. It is NOT a formal smart contract audit. The findings reflect a point-in-time assessment; DeFi protocols change frequently. Always DYOR and consider professional auditing services for investment decisions. Ethena's risk profile is heavily influenced by off-chain factors (custodial arrangements, CEX counterparty exposure, funding rates) that cannot be verified on-chain.
