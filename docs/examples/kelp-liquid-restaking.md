# DeFi Security Audit: Kelp DAO

## Overview
- Protocol: Kelp DAO (part of KernelDAO ecosystem)
- Chain: Ethereum (primary), Arbitrum, Base, Optimism, Scroll, Linea, zkSync Era, Blast, Mode, Sonic, Berachain, Zircuit, Swellchain, Manta, Hemi, X Layer (16 chains)
- Type: Liquid Restaking (EigenLayer)
- TVL: $1,258,124,492 (as of 2026-04-06)
- TVL Trend: +4.1% (7d) / +8.6% (30d) / +5.3% (90d)
- Peak TVL: $2,094,243,976
- Launch Date: December 2023
- Audit Date: 2026-04-06
- Source Code: Open (https://github.com/Kelp-DAO/LRT-rsETH)
- Token: rsETH (ERC-20, 0xA1290d69c65A6Fe4DF752f95823fae25cB99e5A7 on Ethereum)
- Governance Token: KERNEL (TGE April 14, 2025; unified token across Kernel, Kelp, and Gain)

## Quick Triage Score: 72

Red flags found: 4

- MEDIUM: GoPlus is_proxy = 1, though timelock (10 days) is present on upgrades -- (-0, mitigated by timelock; proxy without timelock would be -8)
- MEDIUM: GoPlus honeypot_with_same_creator = 1 -- creator address has deployed a contract flagged as honeypot by GoPlus heuristics. This is likely a false positive (the creator 0x7aad... is Kelp DAO Deployer, a known entity), but warrants noting -- (-8)
- LOW: No documented dedicated insurance fund / TVL ratio (recently partnered with Nexus Mutual but no on-protocol reserve disclosed) -- (-5)
- LOW: Multisig signer addresses verified on-chain, but real-world identities not publicly disclosed -- (-5)
- LOW: Single oracle provider (Chainlink) for LST price feeds -- (-5)
- LOW: No documented on-chain governance for Kelp specifically (KERNEL governance in early stages) -- (-5)

Calculation: 100 - 8 - 5 - 5 - 5 - 5 = 72 (MEDIUM risk)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Not disclosed (Nexus Mutual partnership only) | ether.fi: undisclosed; Renzo: undisclosed | HIGH |
| Audit Coverage Score | 3.0 (see below) | ether.fi: ~3.5; Renzo: ~2.5 | LOW |
| Governance Decentralization | 6/8 multisig + 10-day timelock; KERNEL governance nascent. Verified on-chain (Safe API, April 2026) | ether.fi: multisig + DAO; Renzo: 4+ signers + 48h timelock | MEDIUM |
| Timelock Duration | 240h (10 days) | ether.fi: UNVERIFIED; Renzo: 48h | LOW |
| Multisig Threshold | 6/8 (verified on-chain, Safe v1.3.0, no modules) | ether.fi: UNVERIFIED; Renzo: 4/N | LOW |
| GoPlus Risk Flags | 0 HIGH / 1 MED (proxy) | -- | LOW |

**Audit Coverage Score Calculation:**
- Code4rena competitive audit (Nov 2023): 0.25 (>2 years old)
- MixBytes audit (Mar 2024): 0.5 (1-2 years old)
- SigmaPrime audit #1 (2024, pre-withdrawal): 0.5 (1-2 years old)
- SigmaPrime audit #2 -- Withdrawals (Jun 2024): 0.5 (1-2 years old)
- SigmaPrime audit #3 (additional scope, 2024): 0.5 (1-2 years old)
- Additional audits referenced on GitBook: ~0.75
- Total: ~3.0 (LOW risk -- meets threshold of >= 3.0)

## GoPlus Token Security (Ethereum, Chain ID 1)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | LOW |
| Open Source | Yes (1) | LOW |
| Proxy | Yes (1) | MEDIUM |
| Mintable | Not flagged | LOW |
| Owner Can Change Balance | Not flagged | LOW |
| Hidden Owner | Not flagged | LOW |
| Selfdestruct | Not flagged | LOW |
| Transfer Pausable | Not flagged | LOW |
| Blacklist | Not flagged | LOW |
| Slippage Modifiable | Not flagged | LOW |
| Buy Tax / Sell Tax | 0% / 0% | LOW |
| Holders | 22,871 | LOW |
| Trust List | Not whitelisted (0) | -- |
| Creator Honeypot History | Yes (1) | MEDIUM |

**Top Holder Analysis** (from GoPlus):
- Top holder (73.3%): 0x2d62...07b1 (contract) -- likely LRTDepositPool or NodeDelegator vault holding rsETH collateral
- #2 (21.3%): 0x85d4...ef3 (contract) -- likely protocol-related vault contract
- #3 (1.0%): 0x2216...ea7c (EOA) -- largest individual holder
- #4 (0.8%): 0xa175...e94 (contract) -- likely DeFi integration
- #5 (0.7%): 0x856f...062 (contract) -- likely DeFi integration
- Top 2 holders (contracts) control ~94.5% of supply, consistent with LRT protocol architecture where most rsETH is held in protocol vaults
- Top EOA holder controls only ~1% -- whale risk is LOW

**Note on honeypot_with_same_creator:** The creator address 0x7aad74b7... is identified on Etherscan as "Kelp DAO: Deployer." The honeypot flag likely stems from GoPlus heuristics flagging a test or auxiliary contract deployed by the same address. This is assessed as a likely false positive given the deployer is a known, labeled entity. However, it cannot be fully dismissed without manual review of all contracts deployed by this address.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | LOW | 6/8 multisig with 10-day timelock on upgrades; strong configuration. Verified on-chain (Safe API, April 2026) | Y |
| Oracle & Price Feeds | MEDIUM | Single oracle provider (Chainlink); hardcoded stETH/ETH = 1 assumption | Partial |
| Economic Mechanism | MEDIUM | EigenLayer slashing risk not yet fully activated; no dedicated insurance fund | N |
| Smart Contract | LOW | Multiple audits by reputable firms; open source; transparent proxy pattern | Y |
| Token Contract (GoPlus) | LOW | Clean token profile; proxy expected for upgradeable LRT; creator honeypot flag likely false positive | Y |
| Cross-Chain & Bridge | MEDIUM | LayerZero OFT across 16 chains; centralized relayer dependency | Partial |
| Operational Security | LOW | Doxxed team (Stader Labs founders); Immunefi bug bounty active | Partial |
| **Overall Risk** | **MEDIUM** | **Strong governance controls; main risks are EigenLayer dependency, cross-chain bridge exposure, and oracle concentration** | |

## Detailed Findings

### 1. Governance & Admin Key

**Rating: LOW**

Kelp DAO has one of the stronger governance configurations among liquid restaking protocols:

**Multisig:** The Kelp External Admin is a 6/8 Gnosis Safe multisig at 0xb3696a817D01C8623E66D156B6798291fa10a46d. Verified on-chain (Safe API, April 2026): Safe v1.3.0, threshold 6/8, no modules enabled. The 6/8 threshold (75%) is above industry best practices (typically 60-70% threshold is considered adequate). This is significantly better than many peers.

**Verified Multisig Owners (8):**
- 0xd4C9d49bBda1F074ba8363bfc5D72Fd2a9dFC77F
- 0x3392fd462d9710Fbf3A5703818b9920C119DC080
- 0x33307eFcFB13FA15d5DcDA4CF6AdADF298175544
- 0x7AAd74b7f0d60D5867B59dbD377a71783425af47
- 0xFCc1C98F887C93C38Deb5e38A6Fb820AD3fB9DFD
- 0x61f45F63e06aa0DAE039BcFDa2c4Aab017441Ee7
- 0x7Da5A697980E53Ecc137c0f7E96F4Cb656130098
- 0x746d6a9f789999799AE7f5d62Aa70422F86826b6

**Timelock:** All core contracts are behind TransparentUpgradeableProxy with a TimelockController at 0x49bD9989E31aD35B0A62c20BE86335196A3135B1, enforcing a minimum 10-day delay on upgrades. This is among the longest timelocks in the liquid restaking space and exceeds the 48-hour standard seen at Renzo and many lending protocols.

**Roles:**
- DEFAULT_ADMIN_ROLE: Kelp External Admin 6/8 multisig
- PROPOSER_ROLE: Assigned to the multisig for proposing upgrades
- CANCELLER_ROLE: Can cancel queued timelock transactions

**Admin Powers:**
- Upgrade contract implementations (via timelock)
- Unpause the protocol
- Update price feeds
- Update LRT configuration
- Add/remove NodeDelegator contracts

**Concerns:**
- Multisig signer addresses are verified on-chain (see above), but the real-world identities or institutional affiliations behind each address remain undisclosed.
- No on-chain governance for Kelp-specific decisions yet. KERNEL token governance launched in April 2025 but specifics of Kelp-level governance delegation remain unclear.
- The admin can update price feeds and add/remove NodeDelegator contracts. While these go through the timelock, they represent significant power vectors.

**Timelock Bypass Detection:** No evidence of emergency bypass roles or security council that can skip the 10-day timelock. The protocol does have a pause capability, which appears to be controlled by the admin multisig directly (not timelocked), which is appropriate for emergency pauses.

### 2. Oracle & Price Feeds

**Rating: MEDIUM**

**Architecture:** The LRTOracle contract fetches prices of accepted LSTs (stETH, ETHx) from Chainlink price feeds and uses them to compute the rsETH/ETH exchange rate.

**Exchange Rate Mechanism:** rsETH price = totalLockedETH / rsETHSupply. The contract iterates through all supported assets in the pool, multiplying each asset amount by its Chainlink-derived exchange rate, then divides total ETH value by rsETH supply.

**Concerns:**
- **Single oracle provider:** Kelp relies exclusively on Chainlink for LST price feeds. No documented fallback oracle mechanism. If Chainlink feeds become stale or are manipulated, the rsETH minting rate could be affected.
- **Hardcoded stETH/ETH assumption:** The LlamaRisk assessment flagged that stETH uses a hardcoded exchange rate of 1:1 with ETH. If stETH were to depeg (e.g., from validator slashing), this could cause incorrect rsETH pricing and potential arbitrage at the expense of existing holders.
- **Chainlink deviation threshold:** The rETH/ETH Chainlink feed has a deviation threshold of approximately 2%, meaning the on-chain price can lag spot by up to 2% for 24 hours. The Code4rena audit identified this as a HIGH finding (Issue #584) -- "Possible arbitrage from Chainlink price discrepancy."
- **No circuit breaker:** No documented circuit breaker mechanism for abnormal price movements.

**Mitigating factors:**
- Chainlink is the industry standard oracle provider with strong track record
- The 10-day timelock on oracle source changes prevents rapid manipulation of price feed addresses
- The rsETH exchange rate is non-rebasing and gradually increases, making sudden manipulations more detectable

### 3. Economic Mechanism

**Rating: MEDIUM**

**Restaking Mechanism:** Users deposit ETH or LSTs (stETH, ETHx) into the LRTDepositPool, which mints rsETH proportional to the deposited value. The DepositPool transfers assets to NodeDelegator contracts, which delegate to EigenLayer strategies.

**Withdrawal Mechanism:** Users can unstake rsETH through the WithdrawalManager, subject to a 7-10 day delay (7 days imposed by EigenLayer + Kelp processing time). Alternatively, users can sell rsETH on secondary markets (Uniswap V3/V4) for immediate liquidity.

**Operator Selection:** Kelp delegates to three professional node operators:
- Kiln (4.52% network penetration)
- AllNodes (2.98% network penetration)
- Luganodes (0.34% network penetration)

All are well-established operators with high attestation rates. Operator selection is managed by the admin team, not permissionless.

**EigenLayer Slashing Risk:** As of the audit date, EigenLayer slashing is being gradually activated (announced April 2025). Key risks:
- Delegators have no technical mechanism to prevent their operator from opting into higher-risk AVSs
- If slashing is activated and an operator is slashed, rsETH holders bear the loss proportionally
- The extent of slashing penalties is determined by AVS-specific conditions, which are still being defined

**Insurance / Bad Debt:**
- No dedicated on-protocol insurance fund disclosed
- In January 2026, Kelp partnered with Nexus Mutual and Edge Capital for a DeFi vault with integrated insurance coverage, but this covers specific vault products, not the core rsETH protocol
- No socialized loss mechanism documented
- Insurance/TVL ratio: effectively 0% for core protocol (HIGH concern)

**Depeg History:** rsETH has generally maintained its peg well, with only one notable deviation of -1.5% in late April 2024, which quickly corrected after withdrawals were enabled.

**Fee Structure:** 10% fee on staking rewards for direct ETH deposits; no fee on LST deposits.

### 4. Smart Contract Security

**Rating: LOW**

**Audit History (comprehensive):**

1. **Code4rena** (Nov 2023): Competitive audit with $28K reward pool. Found 5 unique vulnerabilities (3 HIGH, 2 MEDIUM). Key findings included inflation attack vectors and Chainlink price feed arbitrage opportunities. All critical findings were addressed.

2. **MixBytes** (Mar 2024): Found 4 HIGH severity vulnerabilities (absent in deployed version). Notably flagged the Admin role's significant authority over contract implementations and RSETH minter/burner designation.

3. **SigmaPrime** -- multiple engagements:
   - Core protocol assessment (2024)
   - Withdrawals security assessment (Jun 2024, v2.1): Found issues including stakedButUnverifiedNativeETH accounting bug, normalization errors, NDC index shuffling, and potential inflation attack via LRTConverter.
   - Additional scope reviews

**Code Quality:** Open source on GitHub (Kelp-DAO/LRT-rsETH). Uses OpenZeppelin's TransparentUpgradeableProxy pattern. Contracts are verified on Etherscan.

**Bug Bounty:** Active on Immunefi with up to $250,000 for critical smart contract bugs (10% of funds at risk, capped). KYC required for payouts. The Kelp DAO program has received the Immunefi Standard Badge, indicating adherence to best practices.

**Battle Testing:** Live since December 2023 (~28 months). Peak TVL of ~$2.1B. No exploits or significant security incidents reported to date.

**Concern:** The $250K bug bounty cap is relatively low for a ~$1.3B TVL protocol. Industry best practice suggests bug bounties should be proportional to TVL (typically 0.1-1% of TVL for critical bugs). At $250K / $1.3B, this is ~0.02%.

### 5. Cross-Chain & Bridge

**Rating: MEDIUM**

**Multi-Chain Deployment:** rsETH is deployed as a LayerZero OFT (Omnichain Fungible Token) across 16 chains. The core restaking logic resides on Ethereum, with rsETH bridged to L2s for DeFi usage.

**Bridge Technology:** LayerZero is the sole bridge provider. The bridge is accessible at bridge.kelpdao.xyz. LayerZero uses a configurable security model with oracles and relayers:
- LayerZero v2 uses Decentralized Verifier Networks (DVNs) for message verification
- The specific DVN configuration for Kelp's OFT deployments is not publicly documented (UNVERIFIED)

**Risks:**
- **Single bridge dependency:** All cross-chain rsETH transfers depend on LayerZero. A LayerZero compromise could affect rsETH on all 16 L2 chains simultaneously.
- **Bridge admin controls:** LayerZero OFT configuration (rate limits, trusted remotes) is typically controlled by the deployer. It is UNVERIFIED whether these controls are behind the same 6/8 multisig and 10-day timelock as core contracts, or under separate admin keys.
- **16 chains = large attack surface:** Each chain deployment represents a separate contract that could potentially be targeted. Configuration drift across chains is a risk.

**Mitigating factors:**
- LayerZero is one of the most widely used and audited cross-chain messaging protocols
- The core restaking logic (deposits, withdrawals, EigenLayer delegation) only occurs on Ethereum mainnet. L2 rsETH is a bridged representation.
- Users can always bridge back to Ethereum and withdraw via the native mechanism

### 6. Operational Security

**Rating: LOW**

**Team:** Kelp DAO was founded by Amitej Gajjala and Dheeraj Borra, who previously co-founded Stader Labs (multichain liquid staking, $500M+ TVL). Amitej has a documented background: IIT Madras (B.E.), IIM Calcutta (MBA), prior roles at ZS Associates, A.T. Kearney, and Swiggy. The team is doxxed and has meaningful track record in the staking/restaking space.

**Prior Projects:** Stader Labs has been operational since April 2021 with no major security incidents. This establishes a positive track record for the team.

**Incident Response:**
- Emergency pause capability exists (controlled by admin multisig, not timelocked -- appropriate for emergencies)
- No publicly documented incident response plan (UNVERIFIED)
- Active Immunefi bug bounty for responsible disclosure

**Dependencies:**
- **EigenLayer:** Core dependency. Kelp's entire value proposition depends on EigenLayer functioning correctly. EigenLayer smart contract risk, slashing mechanism changes, or governance decisions directly impact Kelp.
- **Chainlink:** Oracle dependency for LST price feeds
- **LayerZero:** Cross-chain bridge dependency for all L2 deployments
- **LST Protocols:** stETH (Lido) and ETHx (Stader) are accepted collateral. A major incident in either protocol would impact rsETH.

**KernelDAO Ecosystem:** Kelp is now part of the broader KernelDAO ecosystem (Kelp + Kernel + Gain). The KERNEL token (TGE April 2025) is the unified governance token. The team allocation is 20% with 6-month lock-up and 24-month vesting. This alignment is standard but means the team has significant governance power in early phases.

## Critical Risks (if any)

1. **EigenLayer Slashing Activation (HIGH):** As EigenLayer activates slashing, rsETH holders are exposed to potential loss of principal if a Kelp-delegated operator is slashed. The protocol has no disclosed insurance mechanism to cover slashing losses. Users must trust the operator selection process (currently admin-controlled) to mitigate this risk.

2. **LayerZero Bridge Dependency Across 16 Chains (MEDIUM-HIGH):** A compromise of LayerZero or misconfiguration of OFT trusted remotes could affect rsETH across all 16 L2 deployments simultaneously. The governance controls over cross-chain configuration are UNVERIFIED.

3. **Oracle Concentration on Chainlink (MEDIUM):** Single oracle provider with no documented fallback. The hardcoded stETH/ETH = 1 assumption could cause mispricing during a stETH depeg event.

## Peer Comparison

| Feature | Kelp DAO (rsETH) | ether.fi (eETH) | Renzo (ezETH) |
|---------|------------------|------------------|----------------|
| Timelock | 10 days (240h) | UNVERIFIED | 48h |
| Multisig | 6/8 | UNVERIFIED | 4/N+ |
| Audits | 5+ (Code4rena, MixBytes, SigmaPrime x3) | Multiple (reputable firms) | Multiple |
| Oracle | Chainlink (single) | Chainlink | Chainlink |
| Insurance/TVL | ~0% (no dedicated fund) | Undisclosed | Undisclosed |
| Open Source | Yes | Yes | Yes |
| Chains | 16 | Multiple | Multiple (incl. Solana) |
| TVL | ~$1.3B | ~$2.8B | ~$1.1B |
| Bug Bounty | $250K (Immunefi) | Active (Immunefi) | Active (Immunefi) |
| EigenLayer Operators | 3 (Kiln, AllNodes, Luganodes) | Multiple | Multiple |

**Assessment:** Kelp has the strongest documented governance controls among liquid restaking peers, with the highest timelock duration (10 days vs. 48h for Renzo) and the highest multisig threshold (6/8). However, the lack of a dedicated insurance fund and the broad cross-chain footprint (16 chains) increase operational risk exposure.

## Recommendations

1. **For users:** Kelp is one of the better-governed liquid restaking protocols. The 10-day timelock and 6/8 multisig provide meaningful protection. However, users should understand they are exposed to (a) EigenLayer slashing risk as it activates, (b) Chainlink oracle risk, and (c) LayerZero bridge risk on L2s. Consider maintaining positions primarily on Ethereum mainnet where the native withdrawal mechanism is available.

2. **For the protocol:**
   - Disclose multisig signer real-world identities or at minimum their institutional affiliations (addresses now verified on-chain)
   - Add a secondary oracle provider (e.g., Redstone, Pyth) as a fallback for LST price feeds
   - Remove the hardcoded stETH/ETH = 1 assumption and use a live price feed
   - Increase bug bounty cap -- $250K is low for $1.3B TVL; consider scaling to $1M+
   - Establish a dedicated insurance fund for slashing events before EigenLayer slashing is fully activated
   - Document cross-chain OFT governance controls publicly (which multisig controls LayerZero configuration per chain)
   - Publish an incident response plan

3. **For institutions:** The Nexus Mutual partnership (Jan 2026) provides some insurance coverage for vault products but does not cover core rsETH protocol risk. Institutional users should seek additional coverage through DeFi insurance protocols or evaluate the Gain vault with embedded insurance.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- NO, 10-day timelock on configuration changes
- [ ] Admin can change oracle sources arbitrarily? -- NO, oracle updates go through timelock
- [x] Admin can modify withdrawal limits? -- UNVERIFIED, likely admin-controlled but timelocked
- [ ] Multisig has low threshold (2/N with small N)? -- NO, 6/8 threshold is strong
- [ ] Zero or short timelock on governance actions? -- NO, 10-day timelock
- [ ] Pre-signed transaction risk? -- N/A (EVM, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- YES, signer addresses verified on-chain but real-world identities undisclosed

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- NO, only ETH, stETH, ETHx (highly liquid)
- [x] Single oracle source without TWAP? -- YES, Chainlink only (no TWAP)
- [ ] No circuit breaker on price movements? -- UNVERIFIED, likely no dedicated circuit breaker
- [x] Insufficient insurance fund relative to TVL? -- YES, no dedicated insurance fund

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- PARTIAL, LayerZero DVN model; specific Kelp DVN config UNVERIFIED
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED, 6/8 multisig suggests cold storage likely
- [ ] No key rotation policy? -- UNVERIFIED

**Pattern match assessment:** Kelp does not closely match the Drift-type attack pattern (governance controls are strong). There is partial exposure to Euler/Mango-type risk via oracle concentration and lack of insurance. The Ronin/Harmony bridge pattern is the most relevant concern given the 16-chain deployment via LayerZero.

## Information Gaps

- ~~Multisig signer addresses~~ (RESOLVED: 8 owner addresses verified on-chain via Safe API, April 2026). Real-world identities or institutional affiliations of the 8 signers remain undisclosed
- Whether cross-chain OFT deployments (LayerZero) are under the same 6/8 multisig and 10-day timelock as core Ethereum contracts
- LayerZero DVN configuration for Kelp's OFT (which verifiers, what threshold)
- Exact size and scope of Nexus Mutual insurance coverage relative to protocol TVL
- Whether the admin pause function has any scope limitations or is unlimited
- Detailed incident response plan and escalation procedures
- KERNEL token governance specifics for Kelp protocol decisions (voting parameters, quorum, proposal threshold)
- Whether the hardcoded stETH/ETH = 1 assumption has been addressed since the LlamaRisk assessment
- EigenLayer AVS selection criteria and risk assessment process for operator delegation decisions
- Rate limit configuration on LayerZero OFT bridges per chain
- Key rotation policy for multisig signers
- Whether any emergency bypass role exists that is not publicly documented

## Disclaimer

This analysis is based on publicly available information and web research conducted on 2026-04-06. It is NOT a formal smart contract audit. The protocol's risk profile may change as EigenLayer slashing mechanisms are activated and KERNEL governance matures. Always DYOR and consider professional auditing services for investment decisions.
