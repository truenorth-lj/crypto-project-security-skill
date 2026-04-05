---
name: defi-security-audit
description: Analyze a DeFi protocol for vulnerabilities, mechanism safety, and risk factors. Use when the user wants to audit a DeFi project, check protocol security, or assess risk. Trigger words include "audit defi", "analyze protocol", "check security", "defi risk", "protocol vulnerability", "is it safe".
---

# DeFi Security Audit Skill

Perform a comprehensive security and mechanism analysis of a DeFi protocol. This skill systematically evaluates governance, oracle design, admin privileges, economic mechanisms, and historical risk factors.

## Input

The user provides one or more of:
- Protocol name (e.g., "Aave", "Drift", "GMX")
- Protocol website or DeFiLlama URL
- Contract addresses or chain

## Workflow

### Step 0: Quick Triage (Red Flag Scan)

Before deep analysis, run a quick triage to decide audit priority:

1. **DeFiLlama data check**: Use `curl -s 'https://api.llama.fi/protocol/{slug}'` to get:
   - Current TVL and TVL history (sharp drops = red flag)
   - Number of audits listed
   - Chain(s)
2. **GoPlus token security check**: If the protocol has a governance/utility token on an EVM chain, run `./scripts/goplus-check.sh token <chain_id> <contract_address>` or call the API directly:
   ```bash
   curl -s "https://api.gopluslabs.io/api/v1/token_security/<chain_id>?contract_addresses=<address>"
   ```
   Extract these red flags from the response:
   - `is_honeypot = 1` -- token is a honeypot (CRITICAL)
   - `honeypot_with_same_creator = 1` -- creator has deployed honeypots (CRITICAL)
   - `is_open_source = 0` -- contract not verified (HIGH)
   - `hidden_owner = 1` -- hidden ownership mechanism (HIGH)
   - `owner_change_balance = 1` -- owner can modify balances (HIGH)
   - `selfdestruct = 1` -- contract can self-destruct (HIGH)
   - `can_take_back_ownership = 1` -- can reclaim ownership after renouncing (HIGH)
   - `is_proxy = 1` -- upgradeable proxy (MEDIUM, cross-reference with Step 2)
   - `is_mintable = 1` -- unlimited minting possible (MEDIUM)
   - `slippage_modifiable = 1` -- owner can change tax/slippage (MEDIUM)
   - `transfer_pausable = 1` -- transfers can be paused (MEDIUM)
   - `is_blacklisted = 1` -- has blacklist functionality (MEDIUM)

   Also note: `buy_tax`, `sell_tax`, `holder_count`, `lp_holders` (lock status), and `trust_list` status.

   **Chain IDs**: 1=Ethereum, 56=BSC, 137=Polygon, 42161=Arbitrum, 10=Optimism, 43114=Avalanche, 8453=Base, 324=zkSync. Solana is NOT supported by GoPlus token security API.

3. **GoPlus address check** (optional): If specific admin/deployer addresses are known, check for malicious history:
   ```bash
   curl -s "https://api.gopluslabs.io/api/v1/address_security/<address>?chain_id=<chain_id>"
   ```
   Flags: `cybercrime`, `money_laundering`, `phishing_activities`, `stealing_attack`, `sanctioned`, `honeypot_related_address`, `malicious_mining_activities`, `number_of_malicious_contracts_created`.

4. **Immediate red flags** (any = escalate to CRITICAL triage):
   - TVL = $0 or dropped >50% in 30 days
   - No audits listed on DeFiLlama
   - Protocol age < 6 months with TVL > $50M
   - Anonymous team with no prior track record
   - Closed-source contracts
   - GoPlus: honeypot detected or creator has honeypot history
   - GoPlus: hidden owner or owner can change balances
   - GoPlus: admin/deployer address flagged as malicious
5. **Quantitative baselines** (compute these for the report):
   - `Insurance Fund / TVL ratio` (healthy: >5%, concerning: <1%)
   - `Audit coverage score`: (number of audits) x (recency weight) -- audits >1 year old get 0.5 weight
   - `Governance decentralization score`: timelock hours + multisig threshold ratio + signer doxxing
   - `TVL trend`: 7d, 30d, 90d change percentages
   - `GoPlus risk flags`: count of HIGH + MEDIUM flags from token security check

### Step 1: Gather Protocol Information

Use web search to collect:
1. **Basic info**: chain, TVL, token, launch date, team (doxxed or anon)
2. **Protocol type**: lending, DEX, perps, yield, bridge, etc.
3. **Architecture**: key smart contracts, upgrade mechanisms
4. **Recent news**: any past exploits, incidents, or security concerns
5. **Peer comparison**: identify 2-3 comparable protocols for benchmarking (same chain + category)

Also check DeFiLlama for current TVL and TVL trend data.

### Step 2: Governance & Admin Key Analysis

Evaluate the following and assign risk ratings (LOW / MEDIUM / HIGH / CRITICAL).
Do NOT use compound ratings like "LOW-MEDIUM" -- pick exactly one level per category.

#### 2.1 Admin Key Surface Area
- What can the admin key do? (pause, upgrade, change params, drain)
- Is there a multisig? What is the threshold (e.g., 3/5)?
- Is there a timelock on admin actions? How long?
- Can admin list new collateral / markets without timelock?
- Can admin change oracle sources?
- Can admin modify withdrawal limits or risk parameters?
- Are multisig signers doxxed or anonymous?

#### 2.2 Upgrade Mechanism
- Are contracts upgradeable (proxy pattern)?
- Who controls upgrades?
- Is there a timelock on upgrades?
- Has the protocol ever done an emergency upgrade?

#### 2.3 Governance Process
- On-chain vs off-chain governance?
- Minimum voting period?
- Quorum requirements?
- Can governance be bypassed via Security Council or emergency multisig?

### Step 3: Oracle & Price Feed Analysis

#### 3.1 Oracle Architecture
- Which oracle providers? (Pyth, Chainlink, custom, TWAP)
- Single oracle or multi-source?
- Fallback mechanism if oracle fails?
- Can admin override oracle source?

#### 3.2 Collateral / Market Listing
- How are new assets listed? (governance vote, admin action, permissionless)
- Is there liquidity depth requirement for collateral?
- Are there automated checks on price feed quality?
- Can low-liquidity tokens be used as collateral?

#### 3.3 Price Manipulation Resistance
- TWAP window length (if applicable)
- Circuit breaker for abnormal price movements?
- Maximum collateral factor for volatile assets?

### Step 4: Economic Mechanism Analysis

#### 4.1 Liquidation Mechanism
- How does liquidation work?
- Is there a liquidation delay or buffer?
- Are liquidators incentivized sufficiently?
- What happens during extreme market conditions?

#### 4.2 Bad Debt Handling
- Insurance fund size relative to TVL?
- Socialized loss mechanism?
- Historical bad debt events?

#### 4.3 Interest Rate / Funding Rate Model
- Is the model well-tested?
- Are there edge cases that could cause extreme rates?
- Can rates be manipulated?

#### 4.4 Withdrawal & Deposit Limits
- Are there rate limits on withdrawals?
- Can limits be changed by admin?
- Is there a hard cap that even admin cannot override?

### Step 5: Smart Contract Security

#### 5.1 Audit History
- How many audits? By whom?
- When was the last audit?
- Were critical findings fixed?
- Has the code changed significantly since last audit?

#### 5.2 Bug Bounty
- Active bug bounty program?
- Maximum payout?
- Scope coverage?

#### 5.3 Battle Testing
- How long has the protocol been live?
- Peak TVL handled?
- Any past exploits or near-misses?
- Open source code?

### Step 6: Operational Security

#### 6.1 Team & Track Record
- Team doxxed or anonymous?
- Previous projects?
- Any past security incidents under their management?

#### 6.2 Incident Response
- Published incident response plan?
- Emergency pause capability?
- Communication channels for security alerts?

#### 6.3 Dependencies
- Key external dependencies (bridges, oracles, other protocols)
- Composability risk (what breaks if a dependency fails?)

### Step 7: On-Chain Verification (when possible)

For Solana protocols, attempt to verify key claims on-chain:
- Check multisig configuration via Squads or similar (search for program authority)
- Verify timelock settings if contract is open source
- Check recent admin transactions for unusual patterns

For EVM protocols:
- Check Etherscan/block explorer for proxy admin, timelock contracts
- Verify multisig via Gnosis Safe / similar
- Check recent governance proposals and execution history

Mark any claim that could NOT be verified on-chain as "UNVERIFIED" in the report.

### Step 8: Generate Risk Report

Compile findings into a structured report:

```
# DeFi Security Audit: {Protocol Name}

## Overview
- Protocol: {name}
- Chain: {chain}
- Type: {type}
- TVL: {tvl}
- TVL Trend: {7d}% / {30d}% / {90d}%
- Launch Date: {date}
- Audit Date: {today}
- Source Code: Open / Closed / Partial

## Quick Triage Score: {0-100}
- Red flags found: {count} ({list})

## Quantitative Metrics
| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | {x}% | {peer avg}% | {rating} |
| Audit Coverage Score | {x} | {peer avg} | {rating} |
| Governance Decentralization | {x} | {peer avg} | {rating} |
| Timelock Duration | {x}h | {peer avg}h | {rating} |
| Multisig Threshold | {m/n} | {peer avg} | {rating} |
| GoPlus Risk Flags | {high_count} HIGH / {med_count} MED | -- | {rating} |

## GoPlus Token Security (if EVM token available)
| Check | Result | Risk |
|-------|--------|------|
| Honeypot | {is_honeypot} | |
| Open Source | {is_open_source} | |
| Proxy | {is_proxy} | |
| Mintable | {is_mintable} | |
| Owner Can Change Balance | {owner_change_balance} | |
| Hidden Owner | {hidden_owner} | |
| Selfdestruct | {selfdestruct} | |
| Transfer Pausable | {transfer_pausable} | |
| Blacklist | {is_blacklisted} | |
| Slippage Modifiable | {slippage_modifiable} | |
| Buy Tax / Sell Tax | {buy_tax}% / {sell_tax}% | |
| Holders | {holder_count} | |
| Trust List | {trust_list} | |
| Creator Honeypot History | {honeypot_with_same_creator} | |

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | {LOW/MED/HIGH/CRIT} | {one-line} | {Y/N/Partial} |
| Oracle & Price Feeds | {LOW/MED/HIGH/CRIT} | {one-line} | {Y/N/Partial} |
| Economic Mechanism | {LOW/MED/HIGH/CRIT} | {one-line} | {Y/N/Partial} |
| Smart Contract | {LOW/MED/HIGH/CRIT} | {one-line} | {Y/N/Partial} |
| Operational Security | {LOW/MED/HIGH/CRIT} | {one-line} | {Y/N/Partial} |
| **Overall Risk** | **{level}** | **{summary}** | |

## Detailed Findings

### 1. Governance & Admin Key
{detailed analysis with specific findings}

### 2. Oracle & Price Feeds
{detailed analysis}

### 3. Economic Mechanism
{detailed analysis}

### 4. Smart Contract Security
{detailed analysis}

### 5. Operational Security
{detailed analysis}

## Critical Risks (if any)
- {numbered list of CRITICAL or HIGH findings that could lead to fund loss}

## Peer Comparison
| Feature | {This Protocol} | {Peer 1} | {Peer 2} |
|---------|----------------|----------|----------|
| Timelock | | | |
| Multisig | | | |
| Audits | | | |
| Oracle | | | |
| Insurance/TVL | | | |
| Open Source | | | |

## Recommendations
- {actionable suggestions for users}

## Historical DeFi Hack Pattern Check
Cross-reference against known DeFi attack vectors:

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock?
- [ ] Admin can change oracle sources arbitrarily?
- [ ] Admin can modify withdrawal limits?
- [ ] Multisig has low threshold (2/N with small N)?
- [ ] Zero or short timelock on governance actions?
- [ ] Pre-signed transaction risk (durable nonce on Solana)?
- [ ] Social engineering surface area (anon multisig signers)?

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted?
- [ ] Single oracle source without TWAP?
- [ ] No circuit breaker on price movements?
- [ ] Insufficient insurance fund relative to TVL?

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators?
- [ ] Admin keys stored in hot wallets?
- [ ] No key rotation policy?

## Information Gaps
- {list of questions that could NOT be answered from public info}
- {these represent unknown risks -- absence of evidence is not evidence of absence}

## Disclaimer
This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
```

### Step 9: Present Results

Output the complete report to the user. Highlight any CRITICAL or HIGH risk items prominently. If the protocol has characteristics similar to the Drift hack pattern (weak admin controls, no timelock, flexible oracle assignment), explicitly call this out.

## Important Notes

- Always search for the LATEST information - DeFi protocols change frequently
- Check for recent governance proposals that may have changed security parameters
- TVL trends matter: rapidly declining TVL can signal risk
- A protocol having been audited does not mean it is safe - check WHEN and WHAT was audited
- Focus on practical risk: what could an attacker actually exploit to drain funds?
- Be honest about uncertainty: if information is not publicly available, say so
- **Mark unverifiable claims as "UNVERIFIED"** - absence of public info is itself a risk signal
- **Closed-source contracts are HIGH risk by default** - if you cannot read the code, assume the worst
- **Always compute quantitative metrics** - ratios and numbers are harder to game than qualitative assessments
- **Peer comparison is mandatory** - a 24h timelock means nothing if peers use 7d; context matters
- **Information gaps go in the report** - what you CANNOT find is often more important than what you can
- This is a research tool, not financial advice - always include the disclaimer

## API Quick Reference

### DeFiLlama

- Protocol info: `https://api.llama.fi/protocol/{slug}`
- All protocols: `https://api.llama.fi/protocols`
- TVL history: included in protocol endpoint response
- Yields: `https://yields.llama.fi/pools`

### GoPlus Security (free, no API key required)

Base URL: `https://api.gopluslabs.io/api/v1`

| Endpoint | Description |
|----------|-------------|
| `token_security/{chain_id}?contract_addresses={addr}` | Token risk profile (honeypot, owner powers, tax, holders, LP) |
| `address_security/{addr}?chain_id={chain_id}` | Malicious address flags (phishing, sanctions, cybercrime) |
| `approval_security/{chain_id}?contract_addresses={addr}` | Contract approval risk (privilege_withdraw, approval_abuse) |
| `nft_security/{chain_id}?contract_addresses={addr}` | NFT-specific risks (privileged mint/burn, copycat detection) |
| `dapp_security?url={url}` | dApp audit status and contract security |
| `rugpull_detecting/{chain_id}?contract_addresses={addr}` | Rug-pull risk detection (Beta) |
| `supported_chains` | List of supported chains and chain IDs |

**Chain IDs**: 1=Ethereum, 56=BSC, 137=Polygon, 42161=Arbitrum, 10=Optimism, 43114=Avalanche, 8453=Base, 324=zkSync, 59144=Linea, 534352=Scroll.

**Helper script**: `./scripts/goplus-check.sh` wraps these endpoints with formatted output. See `./scripts/goplus-check.sh --help` for usage.

Use `curl` via bash to fetch these programmatically when browser data is hard to extract.
