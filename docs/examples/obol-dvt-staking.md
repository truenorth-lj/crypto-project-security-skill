# DeFi Security Audit: Obol Network

**Audit Date:** April 6, 2026
**Protocol:** Obol Network -- Distributed Validator Technology (DVT) / Staking Infrastructure

## Overview
- Protocol: Obol Network (Obol Collective)
- Chain: Ethereum
- Type: Distributed Validator Technology (DVT) / Staking Infrastructure
- TVL: ~$1.3B ETH secured across DVT integrations (DeFiLlama on-chain tracker shows ~$100K direct staking pool TVL)
- TVL Trend (DeFiLlama direct): -25.7% / -50.8% / -74.2% (7d / 30d / 90d)
- Launch Date: May 2025 (token TGE); Charon mainnet v1.0 released earlier
- Audit Date: 2026-04-06
- Source Code: Open (GitHub -- github.com/ObolNetwork)

**Note on TVL:** DeFiLlama tracks Obol's direct staking pool TVL (~$100K), which does not reflect the ~$1.3B in ETH secured through Obol DVT integrations with Lido (~82 clusters), EtherFi (~$1.5B or 23% of EtherFi TVL), StakeWise, Swell, and institutional operators. The protocol's systemic importance far exceeds its direct TVL.

## Quick Triage Score: 44/100

Flags applied:

CRITICAL flags (-25 each): None

HIGH flags (-15 each):
- [x] Zero audits listed on DeFiLlama (-15) -- DeFiLlama shows "audits: 0" despite multiple actual audits existing (data gap)

MEDIUM flags (-8 each):
- [x] GoPlus: is_mintable = 1 (-8)
- [x] TVL dropped > 30% in 90 days (-8) -- DeFiLlama direct TVL dropped 74% in 90d
- [x] GoPlus: transfer_pausable = 0, slippage_modifiable = 0 -- no flags here

LOW flags (-5 each):
- [x] No documented timelock on admin actions (-5)
- [x] No bug bounty program (-5) -- no active Immunefi listing found
- [x] Insurance fund / TVL < 1% or undisclosed (-5)
- [x] Undisclosed multisig signer identities (-5)
- [x] DAO governance paused or dissolved (-5)

Score: 100 - 15 - 8 - 8 - 5 - 5 - 5 - 5 - 5 = **44**

Rounded triage: **44/100 = HIGH risk**

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed / N/A | 1-5% (Lido Safety Module ~2%) | HIGH risk |
| Audit Coverage Score | 2.75 (est.) | 3+ (Lido, SSV) | MEDIUM risk |
| Governance Decentralization | Paused DAO, Obol Association controls | DAO + multisig avg | HIGH risk |
| Timelock Duration | Undisclosed | 24-48h avg | HIGH risk |
| Multisig Threshold | UNVERIFIED | 3/5 - 6/10 avg | HIGH risk |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW risk |

**Audit Coverage Score calculation:**
- Sigma Prime (Charon) -- est. 2023-2024: 0.5
- Quantstamp (Charon v0.19.1) -- est. 2024: 0.5
- Zach Obront (Splits) -- est. 2023-2024: 0.5
- Sayfer (DV Launchpad pentest) -- March 2024: 0.5
- Nethermind (Splits V2, V3) -- 2025: 1.0 + partial
- Ethereal Ventures (dev process review) -- older: 0.25
- Total: ~2.75 (MEDIUM risk threshold: 1.5-2.99)

## GoPlus Token Security (OBOL on Ethereum)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | -- |
| Open Source | Yes (1) | -- |
| Proxy | No (0) | -- |
| Mintable | Yes (1) | MEDIUM |
| Owner Can Change Balance | No (0) | -- |
| Hidden Owner | No (0) | -- |
| Selfdestruct | No (0) | -- |
| Transfer Pausable | No (0) | -- |
| Blacklist | No (0) | -- |
| Slippage Modifiable | No (0) | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 6,580 | -- |
| Trust List | No (0) | -- |
| Creator Honeypot History | No (0) | -- |

**Top holder concentration:** Top 5 holders control ~40.3% of supply. All top 5 are contracts (likely treasury, vesting, staking contracts). First EOA holder appears at position 7 with 3.6%.

GoPlus assessment: **LOW RISK**. The only flag is mintable (is_mintable = 1), which may relate to the team minting remaining supply for transparency (per community forum announcement). No honeypot, no hidden owner, no tax, no trading restrictions. Owner address is empty (renounced or no single owner). Low holder count (6,580) reflects relatively recent token launch (May 2025).

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **HIGH** | DAO governance paused; Obol Association has unilateral control; no public multisig/timelock details | N |
| Oracle & Price Feeds | **LOW** | DVT does not rely on price oracles; Ethereum consensus layer is the trust anchor | Y |
| Economic Mechanism | **MEDIUM** | No insurance fund; DVT risk is validator slashing, mitigated by BFT threshold design | Partial |
| Smart Contract | **MEDIUM** | 6 audits from reputable firms; Splits contracts audited; Charon is off-chain middleware | Partial |
| Token Contract (GoPlus) | **LOW** | Clean GoPlus profile; mintable flag only concern; owner renounced | Y |
| Cross-Chain & Bridge | **N/A** | Ethereum-only protocol | -- |
| Operational Security | **MEDIUM** | Doxxed team, strong backers; but governance in transition, no public incident response plan | Partial |
| **Overall Risk** | **MEDIUM** | **Strong DVT technology with solid audits, but governance centralization and transparency gaps are concerning** | |

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Governance Status: PAUSED**

Obol formally paused all governance activities including Token House voting, delegate-based voting, and the Delegate Reputation Score system. Reasons cited include structural weaknesses in DAO governance, the shutdown of Tally (their governance interface), and regulatory considerations.

**Current Control Structure:**
- The Obol Association (a legal entity, likely Swiss-based) currently stewards all treasury funds and protocol decisions
- No public multisig address or threshold has been disclosed for protocol admin operations
- No documented timelock on administrative actions
- The Association states it is "gradually transferring governance roles to the Obol Collective" but no timeline is provided

**Token Concentration:**
- Total supply: 500M OBOL
- Ecosystem Treasury & RAF: 38.8% (controlled by Obol Association)
- Investors: 23.7% (Pantera Capital, Archetype, BlockTower, Nascent, Coinbase, Binance, others)
- Team: 19%
- Community Incentives: 7.5%
- Airdrop: 7.5%
- Public Sale (CoinList): 3.6%
- Team + Investor allocation (42.7%) significantly exceeds community allocation

**Key Concern:** With governance paused and no public multisig/timelock, the Obol Association effectively has centralized control over protocol direction and treasury. This is a significant governance risk for a protocol securing ~$1.3B in staked ETH across the ecosystem.

### 2. Oracle & Price Feeds -- LOW

Obol's DVT does not rely on external price oracles. The protocol operates at the Ethereum consensus layer, where:
- Validator duties are assigned by the beacon chain
- BLS signature aggregation is deterministic
- No price feeds are needed for core validator operations
- The Obol Splits contracts (for reward distribution) use fixed addresses and percentages, not oracle-dependent calculations

This is a fundamental architectural advantage -- DVT eliminates an entire class of oracle manipulation attacks that plague DeFi lending/trading protocols.

### 3. Economic Mechanism -- MEDIUM

**DVT Design and Slashing Risk:**
- Distributed validators use M-of-N threshold BLS key shares
- Byzantine fault tolerance: system tolerates up to 1/3 malicious/offline nodes
- If more than 2/3 of cluster nodes are malicious, safety guarantees are lost
- DKG (Distributed Key Generation) via FROST algorithm ensures no single operator ever sees the full private key
- Slashing protection: individual validator clients maintain anti-slashing databases and refuse to sign conflicting messages even if Charon is compromised

**Insurance Fund:**
- No dedicated insurance fund exists for Obol DVT operations
- Slashing risk is borne by the stakers/protocols using Obol DVT (e.g., Lido's Safety Module covers their DVT validators)
- No socialized loss mechanism at the Obol protocol level

**Reward Distribution:**
- Obol Splits contracts handle reward splitting between operators
- Execution layer rewards directed to split addresses via fee recipient configuration
- Withdrawal credentials set during cluster setup; principal address receives 32 ETH and consensus layer rewards on exit

### 4. Smart Contract Security -- MEDIUM

**Audit History (6 known audits):**

| Auditor | Scope | Date (est.) | Status |
|---------|-------|-------------|--------|
| Ethereal Ventures | Development processes | Pre-2024 | Completed |
| Sigma Prime | Charon security assessment | 2023-2024 | Released as v0.16.0 |
| Quantstamp | Charon assessment | 2024 | Released as v0.19.1 |
| Zach Obront | Obol Splits (Solidity) | 2023-2024 | Completed |
| Sayfer | DV Launchpad penetration test | March 2024 | Certificate issued |
| Nethermind Security | Splits V2 and V3 (Solidity) | 2025 | Two reports |

**Key Observations:**
- Charon (the core DVT middleware) is written in Go, not Solidity -- it runs off-chain as HTTP middleware between consensus clients and validator clients
- On-chain smart contracts are limited to Splits/Splitter contracts for reward distribution
- Splits contracts have been audited multiple times (Zach Obront, Nethermind x2)
- The DV Launchpad (web UI for cluster creation) had a dedicated penetration test
- DeFiLlama incorrectly shows "audits: 0" -- this is a metadata gap, not a security gap

**Bug Bounty:**
- No active Immunefi listing found for Obol Network
- Documentation references a vulnerability disclosure page but no public bounty program with stated payouts
- This is a gap for a protocol of this systemic importance

**Open Source:**
- Charon: fully open source on GitHub (ObolNetwork/charon)
- Splits contracts: open source
- DV Launchpad: open source
- GoPlus confirms token contract is verified (is_open_source = 1)

### 5. Operational Security -- MEDIUM

**Team:**
- Collin Myers: CEO & Founder (doxxed, ex-ConsenSys, public LinkedIn)
- Oisin Kyne: CTO (doxxed)
- Team is publicly identifiable through LinkedIn, Crunchbase, and conferences

**Funding:**
- $6.15M (2021): Ethereal Ventures, Acrylic Capital Management
- $18.8M (2023): Pantera Capital, Archetype, BlockTower, Nascent, Spartan, Coinbase Ventures, ConsenSys, Binance Labs, Placeholder
- Total: ~$24.9M raised from top-tier crypto investors

**Incident History:**
- No known security incidents, exploits, or fund losses
- No rekt.news coverage
- No reported slashing events from Obol DVT clusters

**Incident Response:**
- No publicly documented incident response plan
- Emergency pause capability for DV clusters would depend on individual operator actions (shutting down Charon nodes)
- No protocol-level emergency pause mechanism (by design -- DVT is infrastructure, not a custodial protocol)

**Dependencies:**
- Ethereum beacon chain (consensus layer)
- Validator clients (Lighthouse, Teku, Lodestar, Nimbus, Prysm)
- Consensus clients (Geth, Nethermind, Besu, Erigon)
- Libp2p relay infrastructure for Charon node communication
- 0xSplits contracts for reward distribution

**Ecosystem Integration Risk:**
- Lido uses Obol DVT for 36+ clusters in Simple DVT module
- EtherFi routes ~23% ($1.5B) of its TVL through Obol DVT
- StakeWise, Swell, Bitcoin Suisse also use Obol
- A critical vulnerability in Charon could affect multiple major staking protocols simultaneously -- this is systemic risk

## Critical Risks

1. **Governance Centralization (HIGH):** DAO governance is paused. The Obol Association has unilateral control over treasury (~38.8% of token supply) and protocol decisions. No public multisig address, signer identities, or timelock configuration has been disclosed. For a protocol securing $1.3B+ in staked ETH, this opacity is concerning.

2. **Systemic Risk via Integrations (MEDIUM-HIGH):** Obol DVT is deeply embedded in Lido, EtherFi, and other major staking protocols. A critical Charon vulnerability could cascade across the staking ecosystem, potentially affecting billions in staked ETH beyond Obol's direct TVL.

3. **No Bug Bounty Program (MEDIUM):** No active Immunefi or equivalent bug bounty listing was found. For infrastructure securing $1.3B+ in ETH, this creates a gap in the security feedback loop.

## Peer Comparison

| Feature | Obol Network | SSV Network | Lido | Rocket Pool |
|---------|-------------|-------------|------|-------------|
| Timelock | Undisclosed | On-chain DAO | 1d-7d (dual) | On-chain DAO |
| Multisig | UNVERIFIED | DAO-governed | 6/9 | oDAO 9/17 |
| Audits | 6 (Sigma Prime, Quantstamp, Nethermind) | 5+ (multiple firms) | 10+ firms | 5+ firms |
| Oracle | N/A (consensus layer) | N/A (consensus layer) | Chainlink (for stETH) | Chainlink (for rETH) |
| Insurance/TVL | None / undisclosed | None | ~2% Safety Module | RPL collateral |
| Open Source | Yes | Yes | Yes | Yes |
| Governance | Paused (Association control) | Active DAO | Active DAO | Active DAO |
| Bug Bounty | Not found | Immunefi | Immunefi $2M | Immunefi |

## Recommendations

1. **Monitor governance restoration:** The paused DAO is the single largest risk factor. Users and integrators should track Obol's community forum for governance reopening announcements and demand transparency on treasury multisig configuration.

2. **Verify multisig and timelock on-chain:** Before increasing exposure to Obol DVT, integrators (Lido, EtherFi) should publicly verify the Obol Association's admin key setup, including multisig threshold and signer identities.

3. **Demand a bug bounty program:** Given Obol's systemic importance to Ethereum staking, the absence of a public bug bounty program is a significant gap. A program with payouts proportional to the value secured ($1.3B+) should be established.

4. **Assess Charon update risk:** Charon middleware updates are distributed to node operators. Understand how updates are coordinated and whether a malicious update could compromise cluster key material.

5. **For stakers using Obol DVT via Lido/EtherFi:** Your primary risk management is through those protocols' own safety mechanisms (Lido Safety Module, etc.), not Obol directly. Ensure the wrapper protocol has adequate slashing insurance.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- **N/A**, Obol is not a lending protocol
- [ ] Admin can change oracle sources arbitrarily? -- **N/A**, no oracle dependency
- [ ] Admin can modify withdrawal limits? -- **UNCLEAR**, withdrawal credentials set at cluster creation; admin modification powers UNVERIFIED
- [x] Multisig has low threshold (2/N with small N)? -- **UNKNOWN**, multisig details not publicly disclosed
- [x] Zero or short timelock on governance actions? -- **UNKNOWN**, timelock details not publicly disclosed
- [ ] Pre-signed transaction risk? -- **N/A**, EVM-based
- [x] Social engineering surface area (anon multisig signers)? -- **YES**, multisig signer identities not disclosed

**2-3/7 flags matched (uncertain).** The lack of transparency on governance controls means several flags cannot be cleared.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- **N/A**, no collateral system
- [ ] Single oracle source without TWAP? -- **N/A**, no price oracle
- [ ] No circuit breaker on price movements? -- **N/A**
- [ ] Insufficient insurance fund relative to TVL? -- **YES**, no insurance fund

**1/4 flags matched.** Limited applicability given DVT architecture.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- **NO**, Ethereum-only
- [ ] Admin keys stored in hot wallets? -- **UNKNOWN**
- [ ] No key rotation policy? -- **UNKNOWN** for admin keys; DV cluster keys use DKG with no built-in rotation

**0-2/3 flags matched (uncertain).**

## Information Gaps

- **Multisig configuration:** No public address, threshold, or signer identities for protocol admin operations
- **Timelock duration:** No documented timelock on any administrative actions
- **Treasury management:** How the 38.8% Ecosystem Treasury allocation is secured and governed
- **Charon update authority:** Who controls Charon binary releases and how operators verify authenticity
- **Relay infrastructure:** Who operates the libp2p relay servers, and what happens if they are compromised or censored
- **Insurance/slashing coverage:** No protocol-level insurance; unclear if integrators (Lido, EtherFi) fully cover DVT-related slashing
- **Governance restart timeline:** No stated timeline for resuming DAO governance
- **Key rotation:** No documented process for rotating DV cluster keys or admin keys
- **Bug bounty details:** No public bounty program with stated scope and payouts
- **DeFiLlama TVL discrepancy:** DeFiLlama shows ~$100K TVL while Obol claims ~$1.3B+ secured via integrations; the true "TVL at risk" through Obol infrastructure is unclear
- **Regulatory entity:** Obol Association's jurisdiction, legal structure, and regulatory status

## Disclaimer

This analysis is based on publicly available information and web research as of April 6, 2026.
It is NOT a formal smart contract audit. The Obol protocol includes significant off-chain
infrastructure (Charon middleware) that cannot be fully assessed through public documentation
alone. Always DYOR and consider professional auditing services for investment decisions.
