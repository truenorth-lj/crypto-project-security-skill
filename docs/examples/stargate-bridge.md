# DeFi Security Audit: Stargate Finance

**Audit Date:** April 5, 2026
**Protocol:** Stargate Finance -- LayerZero-based cross-chain bridge

## Overview
- Protocol: Stargate Finance (V2)
- Chain: Ethereum, Arbitrum, Base, Scroll, BSC, Mantle, OP Mainnet, Avalanche, Metis, Sonic, Polygon, Linea, Kava, Gnosis, and 15+ others
- Type: Cross-chain bridge / Liquidity transport
- TVL: ~$115.8M (across all chains, excluding staking)
- TVL Trend: Stable / Moderate (see below)
- Launch Date: March 17, 2022 (V1); May 31, 2024 (V2)
- Audit Date: April 5, 2026
- Source Code: Open (GitHub: stargate-protocol/stargate, stargate-protocol/stargate-v2)
- Note: On August 25, 2025, the Stargate DAO approved LayerZero's $110M acquisition. The DAO has been dissolved; STG tokens are being swapped for ZRO at a fixed ratio (1 STG = 0.08634 ZRO). Revenue now flows to the LayerZero ecosystem.

## Quick Triage Score: 62/100

- Red flags found: 5
  - MEDIUM: Token is mintable (-8)
  - MEDIUM: Creator address has deployed 2 honeypot contracts (note: these are unrelated contracts, not STG itself) (-8)
  - INFO: DVN configuration changeable by multisig without timelock (-5)
  - INFO: Planner role can reallocate credits across chains (centralized) (-5)
  - INFO: DAO dissolved post-acquisition -- governance transitioning to LayerZero Foundation (-5)
  - INFO: No on-chain timelock verified for admin actions (-5)
  - MEDIUM: 3/6 multisig threshold is below best-in-class for $115M TVL (-8)

Score: 100 - 8 - 8 - 5 - 5 - 5 - 5 - 8 = **56** (adjusted to 62 after accounting for strong team, audit history, and track record as mitigating factors)

Score meaning: 50-79 = MEDIUM risk

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | UNVERIFIED (no public insurance fund data) | 1-5% (Across, Wormhole) | HIGH |
| Audit Coverage Score | 1.75 (V1 audits: 3 x 0.25 = 0.75; V2 Zellic: 1 x 1.0 = 1.0) | 3.0+ (Aave) | MEDIUM |
| Governance Decentralization | DAO dissolved; LayerZero Foundation now controls | DAO (Aave, Wormhole) | MEDIUM |
| Timelock Duration | UNVERIFIED (no public timelock confirmed) | 24-48h (Aave, Across) | HIGH |
| Multisig Threshold | 3/6 (StargateMultisig on Ethereum per L2BEAT) | 4/7+ (Wormhole), 6/10 (Aave) | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW |

### Audit Coverage Score Calculation
- Quantstamp V1 audit (Feb 2022): >2 years old = 0.25
- Zellic V1 audit (Mar 2022): >2 years old = 0.25
- Zokyo V1 audit (Mar 2022): >2 years old = 0.25
- Zellic V2 audit (2024): 1-2 years old = 1.0 (estimated ~May 2024, now ~2 years)
- **Total: 1.75** -- MEDIUM risk (threshold: >= 3.0 = LOW)

## GoPlus Token Security (STG on Ethereum)

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
| Holders | 39,551 | -- |
| Trust List | No | -- |
| Creator Honeypot History | 2 honeypots from same creator | MEDIUM |
| CEX Listed | Binance, Coinbase | -- |
| Top Holder | 0x...dead (82.25% -- burned tokens) | -- |

GoPlus assessment: **LOW RISK** overall. The token is mintable (MEDIUM flag), which means the owner could theoretically mint additional STG. The creator address has 2 honeypot contracts associated with it -- these are likely unrelated deployments, but this warrants monitoring. The dominant holder is the burn address (82.25%), indicating significant token supply reduction. No honeypot, no hidden owner, no tax, no pause, no blacklist.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **MEDIUM** | 3/6 multisig; DAO dissolved; no confirmed on-chain timelock | Partial |
| Oracle & Price Feeds | **LOW** | Bridge-native; no oracle dependency for core operations | Partial |
| Economic Mechanism | **MEDIUM** | Unified liquidity pools with centralized Planner role for credit allocation | Partial |
| Smart Contract | **LOW** | 4 audits, $10M bug bounty, open source, 4+ years live | Y |
| Token Contract (GoPlus) | **LOW** | Mintable flag; creator honeypot history (likely unrelated) | Y |
| Cross-Chain & Bridge | **MEDIUM** | DVN config changeable by multisig; 2-of-2 DVN quorum; Planner centralization | Partial |
| Operational Security | **LOW** | Doxxed team (Bryan Pellegrino / LayerZero Labs); strong VC backing | Y |
| **Overall Risk** | **MEDIUM** | **Well-established bridge with strong track record but centralization risks in DVN configuration, Planner role, and governance transition post-acquisition** | |

## Detailed Findings

### 1. Governance & Admin Key -- MEDIUM

**Multisig Configuration:**
- Stargate is controlled by a 3/6 StargateMultisig on Ethereum (per L2BEAT data).
- The threshold of 3/6 (50%) is moderate but below best-in-class bridges. For comparison, Wormhole uses a 13/19 Guardian set.
- Whether all chains share the same multisig or have independent multisigs is UNVERIFIED.

**Timelock:**
- No publicly documented timelock on admin actions could be confirmed.
- L2BEAT notes that the StargateMultisig can change the DVN configuration "at any time," suggesting no timelock exists or it can be bypassed.
- This is a significant concern: without a timelock, the multisig could redirect message validation to malicious DVNs instantly.

**Governance Model:**
- The Stargate DAO (veSTG-based) has been dissolved following the August 2025 LayerZero acquisition.
- Governance now flows through LayerZero Foundation.
- The 95% approval vote by 15,000+ addresses demonstrated strong community support, but the transition means governance is now more centralized under LayerZero Labs.
- veSTG stakers receive half of Stargate's revenue for six months post-acquisition; after that, all revenue flows to LayerZero.

**Key Concern:** The combination of a 3/6 multisig with no confirmed timelock and a dissolved DAO creates a governance setup where 3 compromised keys could theoretically modify critical protocol parameters immediately.

### 2. Oracle & Price Feeds -- LOW

- Stargate is a bridge/liquidity transport protocol, not a lending or derivatives protocol. It does not rely on price oracles for its core bridging operations.
- The Delta algorithm handles liquidity rebalancing across chains based on pool utilization, not external price feeds.
- Cross-chain message validation relies on DVNs (Decentralized Verifier Networks), not oracles in the traditional sense.
- No known oracle manipulation risk for the bridging mechanism itself.
- Users bridging assets face the standard slippage risk inherent to any AMM-style liquidity pool, but this is bounded by pool depth and configurable parameters.

### 3. Economic Mechanism -- MEDIUM

**Unified Liquidity Model:**
- Stargate's key innovation is unified liquidity pools that allow native asset bridging across chains with instant guaranteed finality.
- V2 introduced a lock+mint and burn+redeem mechanism (OFT standard), reducing liquidity fragmentation.
- The Delta algorithm dynamically allocates liquidity across chains.

**Planner Role:**
- A permissioned "Planner" role can allocate credits between chains off-chain and submit credit allocations to the bridge.
- Per L2BEAT: "Funds can be frozen if the permissioned Planner moves all credits away from the users' chain, preventing them from bridging."
- The Planner cannot steal funds (cannot mint credits, only reallocate), but can deny service.
- This is a centralization risk -- a compromised or malicious Planner could freeze liquidity on specific chains.

**Treasurer Role:**
- A "Treasurer" role can add and withdraw from the treasury inside Stargate contracts.
- This role is assigned by the Owner (3/6 multisig).
- The extent of Treasurer withdrawal powers is UNVERIFIED.

**Insurance Fund:**
- No public insurance fund or safety module has been identified for Stargate.
- This contrasts with Aave's Safety Module (~2% of TVL) or Across's insurance mechanisms.
- In the event of a bridge exploit, there is no known insurance backstop for LPs.

**Revenue and TVL:**
- $4B monthly bridge volume (July 2025 data).
- $345M TVL at peak (2025); currently ~$115.8M -- a significant decline, likely related to DAO dissolution and token swap.
- Treasury of ~$92M in stablecoins and ETH (pre-acquisition).

### 4. Smart Contract Security -- LOW

**Audit History:**
- Quantstamp V1 (February 2022): comprehensive audit of Stargate V1 contracts
- Zellic V1 (March 2022): security assessment of core bridge contracts
- Zokyo V1 (March 2022): independent audit of V1 contracts
- Zellic V2 (2024): audit of Stargate V2 / LayerZero V2 integration
- All audit reports are publicly available on GitHub (stargate-protocol/stargate/tree/main/audit)

**Bug Bounty:**
- Active on Immunefi with up to $10,000,000 maximum payout (originally $15M, appears adjusted)
- Scope covers smart contract vulnerabilities
- Excludes: griefing attacks, economic/governance attacks (e.g., 51% attack), and attacks requiring privileged access

**Battle Testing:**
- Live since March 2022 (4+ years)
- Peak TVL ~$345M+
- $65B+ in cumulative on-chain transfers (per protocol claims -- UNVERIFIED)
- No direct smart contract exploit in production to date

**Dual-Layer Protection:**
- "The Dome" -- shields against external contract attacks
- "Pre-Crime" -- monitors and addresses internal threats before execution
- Both are defensive layers within the Stargate Relayer infrastructure

**Past Incidents:**
- Alameda Research wallet compromise (2023): Not a Stargate contract exploit. Alameda wallets holding STG were compromised by a third party. Stargate DAO responded by reissuing STG tokens (March 2023).
- LayerZero vulnerability disclosure (2023): A reported vulnerability in LayerZero's default configuration could allow the LayerZero team to modify message payloads. LayerZero CEO Bryan Pellegrino disputed the severity, stating it only affected applications using default (unmodified) configuration. Stargate uses custom configuration, mitigating this risk.

### 5. Cross-Chain & Bridge -- MEDIUM

**This is the most critical section for a bridge protocol.**

#### 5.1 Multi-Chain Deployment
- Stargate is deployed on 25+ EVM chains (Ethereum, Arbitrum, Base, Scroll, BSC, Mantle, OP Mainnet, Avalanche, Metis, Sonic, Polygon, Linea, Kava, Gnosis, Hemi, Aurora, Swellchain, Abstract, Unichain, Soneium, Sei, LightLink, Manta, and others).
- Whether each chain has an independent admin multisig or shares the same 3/6 multisig is UNVERIFIED.
- Risk parameters appear to be independently configurable per chain, but configuration authority is centralized.

#### 5.2 Bridge Architecture (LayerZero V2)
- Stargate V2 is built on LayerZero V2, a generalized cross-chain messaging protocol.
- Architecture: Users deposit on source chain -> LayerZero message sent -> DVNs validate message -> Executor delivers on destination chain.
- Stargate V2 is classified as a "Hybrid Bridge (mainly Liquidity Network)" by L2BEAT.
- Key property: No new tokens are minted on the destination chain for standard bridging. Users receive native assets from pre-existing liquidity pools. This means bridge risk is transient (only during the bridging window), not persistent.

#### 5.3 DVN (Decentralized Verifier Network) Configuration
- **Current Ethereum configuration: 2 required DVNs -- Nethermind and LayerZero.**
- Both DVNs must agree on a message for it to be verified and executed.
- **This is a 2-of-2 quorum**, meaning:
  - **Censorship risk**: If either DVN goes down or refuses to approve, transactions are blocked.
  - **Collusion risk**: If both DVNs collude, they can submit fraudulent messages and potentially steal funds.
- The StargateMultisig (3/6) can change DVN configuration at any time (per L2BEAT), potentially pointing to malicious DVNs.
- Over 30 DVNs exist in the LayerZero ecosystem (including Polyhedra, Google Cloud, Animoca, etc.), but Stargate currently only uses 2.

**Critical concern:** The combination of (a) only 2 required DVNs, (b) multisig can change DVN config without timelock, and (c) one DVN is operated by LayerZero itself creates a trust assumption that is more centralized than it appears. If LayerZero Labs (which now owns Stargate) and Nethermind collude or are both compromised, funds could be at risk.

#### 5.4 Cross-Chain Message Security
- Cross-chain messages are validated by the DVN quorum before execution.
- No confirmed timelock on cross-chain governance actions.
- A compromised StargateMultisig could change DVN configuration on any chain, potentially enabling fraudulent cross-chain messages.
- The "Pre-Crime" system provides an additional defense layer, monitoring for suspicious patterns before execution.
- LayerZero V2 has been independently audited, but the DVN infrastructure security varies by individual DVN operator.

#### 5.5 Planner and Credit System
- The Planner role manages credit allocation across chains, enabling efficient capital utilization.
- Credits can be moved between chains but cannot be minted -- the Planner cannot create value from nothing.
- However, a malicious Planner can freeze user funds by moving all credits away from a chain.
- No on-chain constraints on Planner actions have been confirmed (UNVERIFIED).

### 6. Operational Security -- LOW

**Team:**
- Bryan Pellegrino (CEO, LayerZero Labs) -- fully doxxed, public figure, Sequoia-featured.
- LayerZero Labs team is based in Vancouver, Canada.
- Strong VC backing: a]6z, Sequoia Capital, FTX Ventures (pre-collapse), Multicoin Capital, and others.
- LayerZero Labs raised $135M+ in funding.

**Incident Response:**
- "The Dome" and "Pre-Crime" dual-layer protection system.
- Emergency pause capability exists (UNVERIFIED whether it requires multisig or single key).
- Active Immunefi bug bounty ($10M) provides incentive for white-hat disclosure.
- Past incident (Alameda wallet compromise) was handled proactively by the DAO.

**Dependencies:**
- Core dependency: LayerZero V2 messaging protocol (now under same ownership post-acquisition).
- DVN dependencies: Nethermind and LayerZero DVN operations.
- Chain-specific dependencies: native RPC infrastructure for each of 25+ chains.
- After acquisition, Stargate and LayerZero are effectively a single entity, reducing counterparty risk between them but increasing concentration risk.

## Critical Risks (if any)

1. **DVN Configuration Change Without Timelock (HIGH)**: The StargateMultisig can change DVN configuration at any time. If 3 of 6 multisig signers are compromised, an attacker could point message validation to malicious DVNs and potentially drain liquidity pools across all chains.

2. **2-of-2 DVN Quorum (MEDIUM)**: Only two DVNs (Nethermind + LayerZero) validate messages. This is a narrow trust assumption for a protocol securing $115M+. Collusion or simultaneous compromise of both could enable fraudulent cross-chain messages.

3. **Planner Freeze Risk (MEDIUM)**: The centralized Planner role can freeze user funds on any chain by reallocating all credits elsewhere. No on-chain constraints on this power have been confirmed.

## Peer Comparison

| Feature | Stargate Finance | Across Protocol | Wormhole |
|---------|-----------------|-----------------|----------|
| Timelock | UNVERIFIED (none confirmed) | 24h (UNVERIFIED) | Guardian-controlled |
| Multisig | 3/6 | UNVERIFIED | 13/19 Guardians |
| Audits | 4 (V1: 3, V2: 1) | Multiple | Multiple |
| Validator Set | 2 DVNs (Nethermind, LayerZero) | UMA optimistic oracle | 13/19 Guardian quorum |
| Insurance/TVL | UNVERIFIED (no known fund) | Risk pools | UNVERIFIED |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | $10M (Immunefi) | $2.5M (Immunefi) | $2.5M (Immunefi) |
| TVL | ~$115.8M | ~$500M+ | ~$2B+ |
| Chains | 25+ | ~10 | 30+ |
| Live Since | March 2022 | November 2022 | August 2021 |

## Recommendations

- **For LPs (liquidity providers)**: Be aware that there is no confirmed insurance fund to cover losses in a bridge exploit. Only provide liquidity you can afford to lose.
- **For bridge users**: Stargate's transient risk model (no wrapped tokens) means your exposure is limited to the bridging window. Once assets arrive on the destination chain, you do not carry ongoing bridge risk.
- **Monitor DVN configuration**: Track the StargateMultisig for any DVN configuration changes. A change to the DVN set could signal an impending attack.
- **Diversify bridge usage**: For large transfers, consider splitting across multiple bridges (Stargate, Across, Wormhole) to reduce single-bridge risk.
- **Track post-acquisition governance**: With the DAO dissolved, monitor LayerZero Foundation governance announcements for changes to Stargate's security parameters.

## Historical DeFi Hack Pattern Check

Cross-reference against known DeFi attack vectors:

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- N/A (not a lending protocol)
- [ ] Admin can change oracle sources arbitrarily? -- N/A (no oracle dependency)
- [ ] Admin can modify withdrawal limits? -- UNVERIFIED (Planner can reallocate credits)
- [x] Multisig has low threshold (2/N with small N)? -- 3/6 is moderate, not low, but below best-in-class
- [x] Zero or short timelock on governance actions? -- No confirmed timelock
- [ ] Pre-signed transaction risk (durable nonce on Solana)? -- N/A (EVM only)
- [ ] Social engineering surface area (anon multisig signers)? -- Signers not publicly listed (UNVERIFIED)

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- N/A
- [ ] Single oracle source without TWAP? -- N/A
- [ ] No circuit breaker on price movements? -- N/A
- [ ] Insufficient insurance fund relative to TVL? -- Yes (no known insurance fund)

### Ronin/Harmony-type (Bridge + Key Compromise):
- [x] Bridge dependency with centralized validators? -- 2-of-2 DVN quorum with LayerZero operating one DVN
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED
- **Match: Partial Ronin/Harmony pattern.** The 3/6 multisig controlling DVN configuration, combined with only 2 DVNs (one operated by LayerZero itself), creates a scenario where compromise of 3 multisig keys + 1 DVN operator could enable fund theft. This is mitigated by the Pre-Crime defense layer and the protocol's strong track record, but the structural similarity to the Ronin pattern (bridge + centralized validation + key compromise vector) warrants vigilance.

## Information Gaps

- **Timelock configuration**: No public documentation confirming a timelock on StargateMultisig admin actions. L2BEAT states DVN config can change "at any time."
- **Multisig signer identities**: The 3/6 multisig signers are not publicly identified. Whether they are LayerZero Labs employees, community members, or independent parties is unknown.
- **Per-chain admin configuration**: Whether each of the 25+ chain deployments has its own multisig or shares the same Ethereum multisig is not documented.
- **Insurance fund**: No public information on any insurance fund, safety module, or LP loss coverage mechanism.
- **Planner role constraints**: Whether there are on-chain rate limits or constraints on the Planner's credit reallocation powers is unknown.
- **Treasurer withdrawal limits**: The full scope of the Treasurer role's withdrawal powers is not publicly documented.
- **Emergency pause mechanism**: Whether pause requires multisig approval or can be triggered by a single key is UNVERIFIED.
- **Post-acquisition governance structure**: The specific governance framework under LayerZero Foundation control (replacing the dissolved DAO) has not been fully documented.
- **Key storage practices**: Whether multisig keys are in cold storage, hardware wallets, or institutional custody is unknown.
- **DVN slashing conditions**: Whether the Nethermind and LayerZero DVNs have economic penalties (slashing) for fraudulent validation is UNVERIFIED.

## Disclaimer

This analysis is based on publicly available information and web research as of April 5, 2026.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
