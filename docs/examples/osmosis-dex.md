# DeFi Security Audit: Osmosis

**Audit Date:** April 6, 2026
**Protocol:** Osmosis -- Cosmos SDK appchain DEX

## Overview
- Protocol: Osmosis
- Chain: Osmosis (Cosmos SDK appchain, IBC-enabled)
- Type: Decentralized exchange (AMM with concentrated liquidity)
- TVL: ~$15.2M (DeFiLlama, DEX-only; ~$50M including chain-level TVL on some trackers)
- TVL Trend: +0.9% / -3.3% / -32.9% (7d / 30d / 90d)
- Launch Date: June 2021
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: osmosis-labs/osmosis)

## Quick Triage Score: 52/100

Red flags found: 6

```
Start at 100.

HIGH flags (-15 each):
  [x] Zero audits listed on DeFiLlama                          -15

MEDIUM flags (-8 each):
  [x] TVL dropped > 30% in 90 days (-32.9%)                     -8
  [x] Multisig threshold < 3 signers for strategic reserve       -8
    (genesis multisig composition UNVERIFIED for current state)

LOW flags (-5 each):
  [x] No documented timelock on admin actions (governance        -5
      proposals have voting period but no execution delay)
  [x] No bug bounty program on Immunefi                         -5
  [x] Insurance fund / TVL undisclosed                           -5
  [x] Undisclosed multisig signer identities (strategic reserve) -5

Subtotal deductions: -51
Adjustments: +3 (open source appchain with active validator set)
```

**Score: 52** -- MEDIUM risk (50-79 range)

Note: The user-provided TVL of ~$476M does not match current DeFiLlama data ($15.2M DEX TVL). This discrepancy may reflect inclusion of staked OSMO or a data source difference. The audit uses DeFiLlama's DEX-specific figure.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | UNDISCLOSED (community pool ~101M OSMO, but not earmarked as insurance) | 1-5% (Uniswap, dYdX) | HIGH |
| Audit Coverage Score | 0.25 (1 partial CertiK audit >2 years old) | 3.0+ (Aave, Uniswap) | HIGH |
| Governance Decentralization | On-chain governance, 20% quorum, 5-day voting | On-chain (Uniswap, dYdX) | LOW |
| Timelock Duration | 0h (no execution delay after vote passes) | 24-48h (Aave, Compound) | HIGH |
| Multisig Threshold | N/A (validator governance, no admin multisig for core protocol) | 4/7+ (comparable protocols) | MEDIUM |
| GoPlus Risk Flags | N/A (Cosmos-native, not EVM) | -- | N/A |

### Audit Coverage Score Calculation
- CertiK partial audit (~2022): >2 years old, partial scope = 0.25
- Oak Security ecosystem audit slots funded by grants (2023): scope unclear, not Osmosis-specific = 0.0
- **Total: 0.25** -- HIGH risk (threshold: >= 3.0 = LOW)

## GoPlus Token Security

**N/A** -- OSMO is a Cosmos SDK native token, not an EVM contract. GoPlus token security API does not support Cosmos-native chains. Token-level contract risks (honeypot, hidden owner, etc.) are not applicable to Cosmos SDK tokens, which are governed by the chain's staking and governance modules rather than smart contract code.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **LOW** | On-chain governance with validator consensus; no single admin key | Partial |
| Oracle & Price Feeds | **MEDIUM** | TWAP-based internal oracle; no external oracle fallback | Partial |
| Economic Mechanism | **MEDIUM** | Superfluid staking complexity; concentrated liquidity transition | Partial |
| Smart Contract | **HIGH** | Minimal audit history; past $5M exploit from LP calculation bug | Partial |
| Token Contract (GoPlus) | **N/A** | Cosmos-native token; GoPlus not applicable | N/A |
| Cross-Chain & Bridge | **MEDIUM** | IBC dependency; rate limits in place but cross-chain attack surface exists | Partial |
| Operational Security | **LOW** | Doxxed team; chain halt capability; active development | Y |
| **Overall Risk** | **MEDIUM** | **Significant TVL decline, weak audit coverage, and past exploit offset by strong governance model and open-source codebase** | |

## Detailed Findings

### 1. Governance & Admin Key

**Risk: LOW**

Osmosis operates as a sovereign Cosmos SDK appchain, meaning the protocol is governed by its validator set and on-chain governance module rather than traditional admin keys or multisig-controlled smart contracts. This is a fundamentally different security model from EVM-based DeFi protocols.

**Governance process:**
- Proposals require an OSMO deposit (burned if proposal fails to reach deposit threshold within 2 weeks)
- Voting period: 5 days (UNVERIFIED for current parameter)
- Quorum: 20% of staked OSMO must participate
- Pass threshold: >50% Yes votes
- Veto threshold: 33.4% NoWithVeto votes burn the deposit
- All staked OSMO holders (validators and delegators) can vote

**Admin surface area:**
- No single admin key controls the protocol
- Chain upgrades require validator consensus (2/3+ voting power must upgrade)
- Smart contract deployment on mainnet requires governance proposal approval
- Contract migration requires governance proposal
- CosmWasm pool code whitelisting requires governance proposal

**Strategic reserve multisig:**
- At genesis, 50M OSMO strategic reserve was controlled by a multisig composed of development team members
- Current composition, threshold, and signer identities: UNVERIFIED
- This represents a potential centralization vector, though the reserve's current balance and influence relative to total supply are unclear

**Strengths:**
- Appchain model eliminates single-point-of-failure admin key risk
- Validator set of up to 150 active validators provides distributed control
- Slashing penalties (5% for double-signing, jailing for downtime) create accountability
- Governance has been actively used for IBC rate limit proposals, parameter changes, and upgrades

**Weaknesses:**
- No timelock/execution delay between proposal passing and implementation
- Validator voting power concentration is UNVERIFIED
- Strategic reserve multisig details are opaque

### 2. Oracle & Price Feeds

**Risk: MEDIUM**

Osmosis uses an internal TWAP (Time-Weighted Average Price) module as its primary price oracle mechanism. This is fundamentally different from protocols that rely on external oracles like Chainlink or Pyth.

**TWAP architecture:**
- Tracks spot price changes for every AMM pool at the end of each block
- Uses arithmetic mean averaging over configurable time windows
- AMM hooks trigger on swaps, LP additions, and LP removals
- Uses SDK Transient Store for gas-efficient tracking within blocks

**Strengths:**
- TWAP design resists single-block price manipulation and flash loan attacks
- No external oracle dependency for core AMM operations (reduces external attack surface)
- Pyth oracles are available on Osmosis for protocols that need external price feeds (e.g., Mars Protocol)

**Weaknesses:**
- Internal TWAP is only as reliable as the liquidity depth of Osmosis pools
- Low-liquidity pools could produce manipulable TWAP values
- No documented circuit breaker for extreme price movements
- No multi-oracle fallback for core protocol operations
- Mars Protocol (which builds on Osmosis) noted that relying on Osmosis TWAP "significantly limits the selection of assets that can be listed"

**No admin override:** Oracle sources cannot be arbitrarily changed by an admin key -- any changes go through governance.

### 3. Economic Mechanism

**Risk: MEDIUM**

**AMM design:**
- Originally launched with Balancer-style weighted pools
- Transitioned to concentrated liquidity ("Supercharged Liquidity") in 2023
- Integrated Astroport's Passive Concentrated Liquidity (PCL) pools in Q1 2024
- CosmWasm pool module allows new pool types without chain upgrades

**Superfluid staking:**
- Allows LP token holders to simultaneously earn swap fees and staking rewards
- Works by minting synthetic OSMO representative of LP share value, delegated to validators
- Increases capital efficiency but adds complexity
- Risk: If LP share valuation is incorrect (as in the June 2022 exploit), superfluid staking could amplify losses

**Liquidation mechanism:**
- Osmosis is a DEX, not a lending protocol -- no direct liquidation mechanism
- However, protocols built on Osmosis (Mars Protocol, etc.) use Osmosis liquidity for liquidations
- Thin liquidity during market stress could impair downstream protocol liquidations

**Insurance / bad debt handling:**
- No formal insurance fund exists
- Community pool contains approximately 101M OSMO (~$50M at $0.50/OSMO, but highly variable)
- A governance proposal to burn 50% of community pool OSMO was under discussion as of early 2026
- After the June 2022 exploit, Osmosis Labs guaranteed they would cover all $5M in losses -- recovery was largely achieved through fund identification and clawback

**Withdrawal/deposit limits:**
- IBC rate limiting module caps net flows per channel per 24h period
- Rate limits are configurable via governance
- This is a significant security feature that limits blast radius of exploits

### 4. Smart Contract Security

**Risk: HIGH**

**Audit history:**
- CertiK conducted a partial audit of Osmosis contracts (pre-2022), but the audit did NOT cover the file that contained the June 2022 exploit (x/gamm/pool-models/internal/cfmm_common/lp.go)
- Oak Security audit slots were funded via grants for Osmosis ecosystem projects starting January 2023, but these were for ecosystem projects, not the core Osmosis chain
- DeFiLlama lists 0 audits for Osmosis DEX
- No comprehensive, recent (post-2024) security audit of the full Osmosis codebase is publicly documented

**Past exploits:**
- **June 8, 2022: $5M LP calculation exploit.** After the v9.0 upgrade, a bug in MaximalExactRatioJoin issued 50% too many LP shares per join operation. Attackers could add liquidity and withdraw for a 150% return, repeating the process to drain pools. The chain was halted by validators. Four individuals accounted for 95%+ of the exploit amount. The largest exploiter took ~$3.5M. Approximately $2M was returned. Osmosis guaranteed coverage of all losses.

**Key concern:** The 2022 exploit was in core Go module code, not in a CosmWasm smart contract. This means that traditional smart contract audits may not cover the full attack surface of a Cosmos SDK appchain. The chain's custom modules (gamm, concentrated-liquidity, superfluid, ibc-rate-limit, twap, cosmwasmpool) all represent potential exploit vectors that require specialized Cosmos SDK security review.

**Bug bounty:**
- No active Osmosis bug bounty program found on Immunefi
- No public bug bounty program with disclosed maximum payout identified
- This is a significant gap for a protocol that has already experienced a $5M exploit

**Battle testing:**
- Live since June 2021 (~4.8 years)
- Peak TVL: $1.83B (March 2022)
- One major exploit ($5M in June 2022)
- Open source: Yes (GitHub: osmosis-labs/osmosis)
- Active development with regular chain upgrades

### 5. Cross-Chain & Bridge

**Risk: MEDIUM**

Osmosis is deeply integrated with the Cosmos IBC (Inter-Blockchain Communication) ecosystem. Cross-chain functionality is core to its value proposition, not an optional add-on.

**IBC architecture:**
- IBC uses light client verification -- each connected chain verifies the other's consensus proofs
- No centralized relayer trust assumption; relayers are permissionless
- Security depends on the security of both the sending and receiving chain's validator sets
- IBC is considered one of the more trust-minimized cross-chain communication protocols

**IBC rate limiting:**
- Implemented in Osmosis v13 as a safety control
- Rate limits are configurable per channel via governance
- Measures net flow (inflows vs. outflows) over 24-hour periods
- If a channel's quota is exceeded, further IBC transfers are blocked until the next period
- Designed to slow down exploits and give validators time to respond

**Non-IBC bridges:**
- Axelar bridge provides connectivity to EVM chains (Ethereum, Polygon, etc.)
- Axelar has its own validator set securing cross-chain messages
- Assets bridged via Axelar carry Axelar's security assumptions in addition to Osmosis's

**Cross-chain governance:**
- Osmosis governance is Osmosis-chain-only; no cross-chain governance relay mechanism
- A compromised connected chain could potentially send malicious IBC packets, but rate limits cap the damage

**Risks:**
- If a connected chain suffers a governance takeover, its IBC tokens on Osmosis could become worthless
- Shared validator overlap between Cosmos chains could create correlated failure risk
- Axelar bridge adds a trusted third-party dependency for non-Cosmos assets

### 6. Operational Security

**Risk: LOW**

**Team:**
- Co-founded by Sunny Aggarwal and Josh Lee in February 2021
- Sunny Aggarwal is publicly doxxed: former Cosmos/Tendermint contributor, UC Berkeley, active on social media and conferences
- Josh Lee is publicly doxxed: former Cosmos contributor
- Osmosis Labs is the primary development entity
- Strong track record in the Cosmos ecosystem

**Incident response:**
- During the June 2022 exploit, validators halted the chain within hours
- Chain halt capability is a double-edged sword: it stops exploits but creates centralization risk
- Communication during the 2022 incident was transparent (public post-mortems, identification of exploiters)
- No published formal incident response plan found

**Dependencies:**
- Cosmos SDK and Tendermint/CometBFT consensus engine
- IBC protocol implementation
- CosmWasm runtime for smart contract pools
- Axelar bridge for non-Cosmos asset connectivity
- If Cosmos SDK or CometBFT has a critical vulnerability, Osmosis is affected

## Critical Risks (if any)

1. **HIGH: Insufficient audit coverage.** Zero comprehensive audits listed on DeFiLlama. The partial CertiK audit missed the exact code path that was later exploited for $5M. No evidence of a recent full security audit of the Osmosis codebase, which includes custom Cosmos SDK modules (gamm, concentrated-liquidity, superfluid, twap, cosmwasmpool, ibc-rate-limit).

2. **HIGH: No active bug bounty program.** No Immunefi listing found. For a protocol with $15M+ TVL, a history of exploitation, and complex custom code, the absence of a bug bounty program is a significant gap.

3. **HIGH: Significant TVL decline.** TVL has dropped from a peak of $1.83B (March 2022) to $15.2M -- a 99.2% decline. While much of this reflects broader market conditions and the Terra collapse impact, the 90-day decline of -32.9% suggests continued capital flight.

## Peer Comparison

| Feature | Osmosis | Uniswap (Ethereum) | dYdX (Cosmos appchain) |
|---------|---------|---------------------|------------------------|
| Timelock | None (governance vote only) | 2-day minimum | Governance voting period |
| Multisig | Validator set (150) | Governance + Uniswap Labs | Validator set |
| Audits | 1 partial (CertiK, 2022) | Multiple (Trail of Bits, OpenZeppelin, etc.) | Multiple (Peckshield, Informal Systems) |
| Oracle | Internal TWAP | N/A (AMM-native) | Pyth, Skip |
| Insurance/TVL | Undisclosed | N/A | Insurance fund disclosed |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | None found | $15.5M (Immunefi) | $1M+ (Immunefi) |
| TVL | $15.2M | $4.5B+ | $300M+ |

## Recommendations

1. **For users/LPs:** Osmosis remains a functional and actively developed DEX, but the significant TVL decline and audit gaps warrant caution. Consider limiting exposure relative to total portfolio. The IBC rate limiting module provides some protection against catastrophic loss events.

2. **For the protocol:** Commission a comprehensive security audit of all custom Cosmos SDK modules, especially concentrated liquidity, superfluid staking, and the CosmWasm pool module. The 2022 exploit demonstrated that standard smart contract audits are insufficient for appchain security -- a specialized Cosmos SDK audit firm (e.g., Informal Systems, Oak Security) should review the full codebase.

3. **For the protocol:** Establish a formal bug bounty program on Immunefi or a comparable platform. Given the protocol's complexity and history, a maximum payout of at least $500K-$1M would be appropriate.

4. **For the protocol:** Add a timelock/execution delay for governance proposals. While the validator governance model is robust, an execution delay (24-48 hours) after proposal passage would give the community time to react to potentially malicious proposals.

5. **For users:** Monitor IBC rate limit governance proposals, as changes to these limits directly affect the blast radius of potential exploits.

6. **For users:** Be aware that assets bridged via Axelar carry additional trust assumptions beyond Osmosis's native security model.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- N/A (DEX, not lending; new assets listed permissionlessly for pools)
- [ ] Admin can change oracle sources arbitrarily? -- No, TWAP is protocol-native; changes require governance
- [ ] Admin can modify withdrawal limits? -- No single admin; IBC rate limits changed via governance
- [ ] Multisig has low threshold (2/N with small N)? -- N/A (validator governance model)
- [x] Zero or short timelock on governance actions? -- **Yes, no execution delay after governance vote passes**
- [ ] Pre-signed transaction risk? -- N/A (not Solana)
- [ ] Social engineering surface area (anon multisig signers)? -- Low (validator set is large and diverse; team is doxxed)

### Euler/Mango-type (Oracle + Economic Manipulation):
- [x] Low-liquidity collateral accepted? -- **Yes, any token can be used in pools; low-liquidity pools produce unreliable TWAPs**
- [ ] Single oracle source without TWAP? -- TWAP is the primary mechanism
- [x] No circuit breaker on price movements? -- **No documented circuit breaker on TWAP or pool-level price movements**
- [x] Insufficient insurance fund relative to TVL? -- **Community pool exists but is not earmarked as insurance; no formal insurance fund**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Axelar bridge has its own validator set (partially centralized); IBC is trust-minimized
- [ ] Admin keys stored in hot wallets? -- N/A (validator key management varies)
- [ ] No key rotation policy? -- Validator key management is per-operator; no chain-level policy documented

## Information Gaps

- **Current strategic reserve multisig composition:** The genesis 50M OSMO strategic reserve was controlled by a team multisig. Current signers, threshold, and remaining balance are UNVERIFIED.
- **Comprehensive audit reports:** No publicly available full security audit report for the Osmosis codebase was found. The CertiK audit was partial and did not cover the exploited code path.
- **Validator voting power distribution:** The concentration of voting power among top validators is UNVERIFIED. High concentration could enable governance attacks.
- **Community pool governance controls:** Whether the community pool has any spending limits or controls beyond standard governance proposals is UNVERIFIED.
- **Formal incident response plan:** No published incident response playbook found, despite the 2022 exploit demonstrating the need for one.
- **Bug bounty program status:** Whether Osmosis has or had a bug bounty program outside of Immunefi is UNVERIFIED.
- **Insurance fund or reserve earmarking:** No evidence that any portion of the community pool or other funds is formally designated as an insurance fund for user loss coverage.
- **Current chain upgrade cadence and review process:** How thoroughly chain upgrades are reviewed before deployment is UNVERIFIED. The 2022 exploit was introduced via a chain upgrade (v9.0).
- **TVL discrepancy:** The user-provided ~$476M TVL figure could not be confirmed. DeFiLlama shows $15.2M for Osmosis DEX and some trackers show ~$50M for chain-level TVL. The source and methodology behind $476M is unknown.

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
