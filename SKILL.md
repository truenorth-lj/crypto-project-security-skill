---
name: defi-security-audit
description: Analyze a DeFi protocol for vulnerabilities, mechanism safety, and risk factors. Use when the user wants to audit a DeFi project, check protocol security, or assess risk. Trigger words include "audit defi", "analyze protocol", "check security", "defi risk", "protocol vulnerability", "is it safe".
version: 1.2.0
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch
metadata:
  openclaw:
    requires:
      bins:
        - curl
        - jq
    optional_bins:
        - solana
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

1. **DeFiLlama data check**:
   First, resolve the protocol name to the correct DeFiLlama slug (slugs are non-obvious, e.g., "maker" not "sky", "pancakeswap" not "pancake-swap"):
   ```bash
   # Fetch all protocols and fuzzy-match by name
   curl -s 'https://api.llama.fi/protocols' | jq -r '.[] | select(.name | test("{protocol}"; "i")) | "\(.slug) -- \(.name) -- TVL: \(.tvl)"'
   ```
   If no match, try partial name or check the protocol's website for its DeFiLlama listing.
   Then fetch full data with the resolved slug: `curl -s 'https://api.llama.fi/protocol/{slug}'` to get:
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

   **Solana token fallback**: GoPlus does not support Solana SPL tokens. For Solana protocols, use these alternatives instead:
   - **RugCheck**: `curl -s 'https://api.rugcheck.xyz/v1/tokens/{mint_address}/report'` -- returns risk score, mutable metadata, freeze authority, mint authority, top holders, LP lock status
   - **Birdeye**: `curl -s -H 'X-API-KEY: public' 'https://public-api.birdeye.so/public/token_security?address={mint_address}'` -- holder concentration, LP info
   - **Manual checks**: On Solana Explorer, verify: (1) mint authority (revoked = safer), (2) freeze authority (revoked = safer), (3) metadata mutability, (4) top holder concentration
   Record the source as "RugCheck" or "Birdeye" instead of "GoPlus" in the report. If none of the alternatives return data, record "Solana Token Check: UNAVAILABLE" and note the gap.

   **Error handling**: GoPlus is a free API with undocumented rate limits. If the API returns an error, empty result, or times out:
   - Record "GoPlus: UNAVAILABLE" in the report rather than omitting the section
   - Wait 5 seconds and retry once
   - If still failing, proceed with the audit without GoPlus data and note the gap in Information Gaps

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
5. **Quick Triage Score** (compute for the report, 0-100):
   ```
   Start at 100. Subtract EXACTLY the listed points for each flag that applies.
   Do NOT adjust, round, or add mitigating bonuses -- the score is mechanical.

   CRITICAL flags (-25 each):
     [ ] GoPlus: is_honeypot = 1
     [ ] GoPlus: honeypot_with_same_creator = 1
     [ ] GoPlus: hidden_owner = 1
     [ ] GoPlus: owner_change_balance = 1
     [ ] TVL = $0
     [ ] Admin/deployer address flagged as malicious

   HIGH flags (-15 each):
     [ ] Closed-source contracts (is_open_source = 0)
     [ ] Zero audits listed on DeFiLlama
     [ ] Anonymous team with no prior track record
     [ ] GoPlus: selfdestruct = 1
     [ ] GoPlus: can_take_back_ownership = 1
     [ ] No multisig (single EOA admin key)
     [ ] Single bridge provider for cross-chain deployments on 5+ chains (Kelp lesson)

   MEDIUM flags (-8 each):
     [ ] GoPlus: is_proxy = 1 AND no timelock on upgrades
     [ ] GoPlus: is_mintable = 1
     [ ] Protocol age < 6 months with TVL > $50M
     [ ] TVL dropped > 30% in 90 days
     [ ] Multisig threshold < 3 signers (e.g., 2/N)
     [ ] GoPlus: slippage_modifiable = 1
     [ ] GoPlus: transfer_pausable = 1
     [ ] No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations
     [ ] Bridge token accepted as lending collateral on 3+ protocols without rate limits

   LOW flags (-5 each):
     [ ] No documented timelock on admin actions
     [ ] No bug bounty program
     [ ] Single oracle provider
     [ ] GoPlus: is_blacklisted = 1
     [ ] Insurance fund / TVL < 1% or undisclosed
     [ ] Undisclosed multisig signer identities
     [ ] DAO governance paused or dissolved
     [ ] No published key management policy (HSM, MPC, key ceremony)
     [ ] No disclosed penetration testing (infrastructure, not just smart contract audit)
     [ ] Custodial dependency without disclosed custodian certification

   Floor at 0. Score meaning:
     80-100 = LOW risk | 50-79 = MEDIUM | 20-49 = HIGH | 0-19 = CRITICAL
   ```

   **Data Confidence Score** (compute alongside triage, 0-100):
   ```
   Start at 0. Add points for each verified data point.
   This measures HOW MUCH we could verify, not whether it's safe.
   A high triage score with low confidence is MORE suspicious than a
   moderate triage score with high confidence.

   Verification points (+):
     [ ] +15  Source code is open and verified on block explorer
     [ ] +15  GoPlus token scan completed (not N/A or UNAVAILABLE)
     [ ] +10  At least 1 audit report publicly available
     [ ] +10  Multisig configuration verified on-chain (Safe API or Squads)
     [ ] +10  Timelock duration verified on-chain or in docs
     [ ] +10  Team identities publicly known (doxxed)
     [ ] +10  Insurance fund size publicly disclosed
     [ ] +5   Bug bounty program details publicly listed
     [ ] +5   Governance process documented
     [ ] +5   Oracle provider(s) confirmed
     [ ] +5   Incident response plan published
     [ ] +5   SOC 2 Type II or ISO 27001 certification verified
     [ ] +5   Published key management policy (HSM, MPC, key ceremony)
     [ ] +5   Regular penetration testing disclosed (infrastructure-level)
     [ ] +5   Bridge DVN/verifier configuration publicly documented (if cross-chain)

   Report both scores together: "Triage: 75/100 | Confidence: 40/100"
   Interpretation:
     80-100 = HIGH confidence (most claims verified)
     50-79  = MEDIUM confidence (significant gaps remain)
     0-49   = LOW confidence (most claims unverified -- treat score with skepticism)
   ```
6. **Quantitative baselines** (compute these for the report):
   - `Insurance Fund / TVL ratio` (healthy: >5%, concerning: <1%)
   - `Audit Coverage Score`:
     ```
     Sum across all known audits:
       1.0 per audit less than 1 year old
       0.5 per audit 1-2 years old
       0.25 per audit older than 2 years
     Risk thresholds: >= 3.0 = LOW | 1.5-2.99 = MEDIUM | < 1.5 = HIGH
     ```
   - `Governance decentralization score`: timelock hours + multisig threshold ratio + signer doxxing
   - `TVL trend`: 7d, 30d, 90d change percentages
   - `GoPlus risk flags`: count of HIGH + MEDIUM flags from token security check

### Step 1: Gather Protocol Information

Use web search to collect the following. Run these specific queries (replace `{protocol}` with the protocol name):

1. **Basic info**: chain, TVL, token, launch date, team (doxxed or anon)
   - Search: `"{protocol}" DeFi protocol overview`
2. **Protocol type**: lending, DEX, perps, yield, bridge, etc.
3. **Architecture**: key smart contracts, upgrade mechanisms
   - Search: `"{protocol}" docs architecture OR contracts OR "smart contract"`
4. **Security incidents and audits**:
   - Search: `"{protocol}" exploit OR hack OR vulnerability OR "security incident"`
   - Search: `"{protocol}" site:rekt.news`
   - Search: `"{protocol}" audit report site:github.com`
5. **Governance and admin configuration**:
   - Search: `"{protocol}" multisig OR timelock OR governance OR "admin key"`
6. **Bug bounty**:
   - Search: `"{protocol}" site:immunefi.com`
7. **Peer comparison**: identify 2-3 comparable protocols for benchmarking. Selection criteria:
   - **Same category** (e.g., lending vs lending, DEX vs DEX, perps vs perps)
   - **Similar TVL tier**: within 5x of each other (e.g., $1B protocol compared to $200M-$5B peers, not $50M or $50B)
   - **Prefer same chain** when possible, but cross-chain is acceptable if same-chain peers are unavailable
   - **Prefer well-known protocols** with established security track records as at least one peer (provides a "gold standard" benchmark)
   - **Never compare against the protocol's own forks** (e.g., don't compare Aave V3 to Aave V2)

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

**Timelock bypass detection** (critical -- a timelock is only as strong as its bypass):
- Does any role (emergency multisig, security council, guardian) bypass the timelock?
- What powers does the bypass role have? (pause-only is LOW risk; full upgrade/drain is HIGH)
- Is the bypass role itself behind a multisig? What threshold?
- Are there on-chain constraints on what the bypass role can do, or is it trust-based?
- Example: "48h timelock with a 3/5 emergency multisig that can only pause" = LOW risk. "48h timelock with a 2/3 security council that can upgrade" = HIGH risk.

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

#### 2.4 Token Concentration & Whale Risk (if on-chain governance)
- What percentage of voting supply do the top 5 holders control?
- Are top holders contracts (treasury, staking, vesting) or EOAs?
- Can a single whale meet quorum or pass a proposal unilaterally?
- Is there vote delegation, and how concentrated is delegated power?
- Cross-reference GoPlus `holders` data if available from Step 0

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

#### 5.4 Source Code Review

If the protocol's smart contracts are open source (GitHub or verified on block explorer), perform a targeted source code review. This is NOT a full line-by-line audit — it focuses on verifying governance claims from Step 2 and detecting high-impact vulnerability patterns.

**Skip this step if**: contracts are closed-source AND not verified on any block explorer.

##### 5.4.1 Obtain Source Code

Try these sources in order:
1. **Etherscan/block explorer**: Fetch verified source from the chain's block explorer. For proxy contracts, fetch BOTH the proxy and implementation source.
   ```bash
   # Etherscan (Ethereum)
   curl -s "https://api.etherscan.io/api?module=contract&action=getsourcecode&address=<address>&apikey=<key>"
   # Arbiscan (Arbitrum)
   curl -s "https://api.arbiscan.io/api?module=contract&action=getsourcecode&address=<address>&apikey=<key>"
   ```
2. **GitHub**: Search for the protocol's contract repository.
   - Search: `"{protocol}" smart contracts site:github.com`
   - Common patterns: `github.com/{org}/contracts`, `github.com/{org}/{protocol}-core`
3. **Audit reports**: If no public repo exists, check if audit reports contain code snippets or contract interfaces.

Record source availability: "Full source (GitHub + verified)", "Partial (verified on explorer only)", "Closed source".

##### 5.4.2 Admin & Access Control Patterns

Search the source code for these patterns. Each finding should cross-reference the governance analysis from Step 2.

**Owner/admin functions** — search for functions that can modify critical state:
```
Search for: onlyOwner, onlyAdmin, onlyRole, onlyGovernance, _checkRole, requiresAuth
Search for: function set*, function update*, function change*, function pause, function unpause
Search for: function upgrade*, function migrate*, _authorizeUpgrade
```

For each admin function found, document:
- What it can do (change parameters, pause, upgrade, drain)
- What access control guards it (Ownable, AccessControl role, custom modifier)
- Whether it has a timelock wrapper or can be called directly
- Whether it matches claims from Step 2 (e.g., "team claims 48h timelock" — verify the timelock is actually enforced in code)

**Proxy upgrade pattern** — identify which pattern is used:
```
Search for: TransparentUpgradeableProxy, UUPSUpgradeable, _authorizeUpgrade, ERC1967Upgrade
Search for: Diamond, DiamondCut, LibDiamond (EIP-2535)
Search for: Beacon, BeaconProxy, UpgradeableBeacon
```
- UUPS: upgrade logic is in the implementation — check `_authorizeUpgrade` for access control
- Transparent: upgrade logic is in the ProxyAdmin — check who owns ProxyAdmin
- Diamond: facets can be added/removed — check who controls `diamondCut`

**Emergency/bypass roles** — verify claims about emergency powers:
```
Search for: emergency, guardian, pauser, EMERGENCY_ROLE, GUARDIAN_ROLE
Search for: delay, setDelay, updateDelay, minDelay, getMinDelay
```
- Does the emergency role only pause, or can it upgrade/drain?
- Can the timelock delay be set to 0? By whom?

##### 5.4.3 Common Vulnerability Patterns

Scan for these high-impact patterns:

**Reentrancy**:
```
Search for: .call{value:, .call(, (bool success,) =
Check: Is there a reentrancy guard (nonReentrant, ReentrancyGuard)?
Check: Does the contract follow checks-effects-interactions pattern?
```
Flag if: external calls are made before state updates, AND no reentrancy guard exists.

**Oracle manipulation**:
```
Search for: getPrice, latestAnswer, latestRoundData, getUnderlyingPrice, twap, TWAP
Search for: slot0 (Uniswap V3 spot price — manipulable via flash loans)
```
Flag if: spot price is used without TWAP protection, OR single oracle with no fallback.

**Flash loan attack surface**:
```
Search for: flashLoan, flashMint, IERC3156, IFlashLoanReceiver
Check: Can flash-loaned tokens be used as collateral or voting power in the same transaction?
```

**Unchecked return values**:
```
Search for: .transfer(, .send(, .approve(
Check: Are return values checked? (SafeERC20 usage = good)
```

**Centralization in token contract**:
```
Search for: mint(, burn(, _mint(, _burn(, blacklist, freeze, pause
Check: Who can call these? Is there a cap on minting?
```

##### 5.4.4 Cross-Reference with Governance Claims

This is the most important part. Compare what the code actually does vs. what the team/docs claim:

| Claim from Step 2 | Code verification | Match? |
|---|---|---|
| "48h timelock on upgrades" | Check: is timelock enforced in proxy admin? Can it be bypassed? | |
| "3/5 multisig controls admin" | Check: is the admin address actually the claimed multisig? | |
| "Oracle uses Chainlink" | Check: is Chainlink actually imported and used? Any fallback? | |
| "Insurance fund covers bad debt" | Check: does the liquidation flow actually transfer to insurance fund? | |
| "Immutable core contracts" | Check: are there really no upgrade functions? No selfdestruct? | |

Record any discrepancies as HIGH or CRITICAL findings.

##### 5.4.5 Report Format

Add to the Smart Contract Security section of the risk report:

```
#### Source Code Review

**Source availability**: [Full/Partial/Closed]
**Contracts reviewed**: [list of key contracts and addresses]

**Admin function inventory**:
| Function | Contract | Access Control | Timelock? | Impact |
|----------|----------|---------------|-----------|--------|

**Vulnerability scan**:
| Pattern | Found? | Details | Severity |
|---------|--------|---------|----------|

**Governance claim verification**:
| Claim | Code evidence | Verified? |
|-------|-------------|-----------|

**Source code review conclusion**: [summary of findings]
```

### Step 6: Cross-Chain & Bridge Risk

Skip this step if the protocol operates on a single chain with no bridge dependencies.

#### 6.1 Multi-Chain Deployment
- How many chains is the protocol deployed on?
- Does each chain deployment have its own admin multisig, or does one key control all?
- Are risk parameters (collateral factors, rate limits) independently configured per chain?
- Is there a canonical "home chain" for governance, with message relaying to others?

#### 6.2 Bridge Dependencies
- Does the protocol depend on a bridge for cross-chain messaging or asset transfers?
- Is the bridge a canonical chain bridge (e.g., Arbitrum native) or third-party (e.g., LayerZero, Wormhole)?
- What is the bridge's validator/relayer set? (centralized vs. decentralized)
- What happens to the protocol if the bridge goes down or is compromised?

#### 6.3 Cross-Chain Message Security
- How are cross-chain governance actions validated?
- Is there a timelock on cross-chain messages?
- Can a compromised bridge forge governance actions on a remote chain?
- Has the bridge been audited independently of the protocol?

### Step 7: Operational Security

#### 7.1 Team & Track Record
- Team doxxed or anonymous?
- Previous projects?
- Any past security incidents under their management?

#### 7.2 Incident Response
- Published incident response plan?
- Emergency pause capability?
- Communication channels for security alerts?
- **Emergency response time benchmark**: How fast can the team pause the protocol? (Kelp took 46 minutes; best practice is <15 minutes for bridge exploits)

#### 7.3 Dependencies
- Key external dependencies (bridges, oracles, other protocols)
- Composability risk (what breaks if a dependency fails?)
- **Downstream lending exposure**: Is the protocol's token accepted as collateral on Aave, Compound, Euler, or other lending protocols? If so, an exploit could cascade into bad debt across those protocols (see Kelp-type pattern)

#### 7.4 Off-Chain Controls & Certifications

On-chain security can be verified by reading contracts. Off-chain controls (key management, operational procedures, access controls) CANNOT be verified from public blockchain data alone -- they require third-party attestation.

Evaluate the following. Search: `"{protocol}" SOC 2 OR ISO 27001 OR "security certification" OR "key management" OR "penetration test"`

- **Third-party security certifications**: Does the protocol or its operating entity hold SOC 2 Type II, ISO 27001, or ISO 27017? These are the industry standards for verifying operational security controls.
- **Key management**: Does the team use HSMs (Hardware Security Modules), MPC (Multi-Party Computation) custody (e.g., Fireblocks, Fordefi), or documented key ceremony procedures? Is there a key rotation policy?
- **Custodial counterparty risk**: If the protocol uses centralized custody (e.g., Ethena uses Copper/Ceffu), does the custodian hold independent security certifications? What insurance coverage exists?
- **Penetration testing**: Has the protocol undergone infrastructure/application penetration testing (distinct from smart contract audits)? Are results published?
- **Operational segregation**: Do developers have production key access? Is there separation of duties between development, deployment, and admin operations?
- **Employee / insider threat controls**: Background checks, access logging, principle of least privilege -- especially relevant after DPRK social engineering attacks (Radiant Capital, Drift Protocol)

**Rating guidance**:
- Has SOC 2 + published key management + regular pentest → LOW
- Has at least one certification OR published security practices → MEDIUM
- No certifications, no published security practices, opaque operations → HIGH
- Anonymous team with no verifiable security practices → CRITICAL

### Step 8: On-Chain Verification

Run automated on-chain checks using `./scripts/onchain-check.sh`. Execute ALL applicable checks for the protocol's chain(s). Record every result in the report; mark anything the script could not determine as "UNVERIFIED".

#### For EVM protocols:

1. **Gnosis Safe multisig verification** -- if admin/owner/treasury addresses are known and suspected to be a Safe:
   ```bash
   ./scripts/onchain-check.sh safe <safe_address> <chain>
   # chain: ethereum, arbitrum, polygon, optimism, base, gnosis, avalanche, bsc, scroll, linea, zksync, celo
   ```
   Extract from the output: threshold (m/n), owner count, owner addresses, modules, guard.
   - threshold <= 2 with N >= 4: flag as HIGH (Drift-type attack surface)
   - threshold = 1: flag as CRITICAL (equivalent to EOA)
   - modules attached: flag as MEDIUM (can bypass threshold)

2. **Contract verification & proxy detection** -- for key contract addresses (token, proxy admin, timelock):
   ```bash
   ./scripts/onchain-check.sh etherscan <contract_address> <chain_id> [ETHERSCAN_API_KEY]
   # Reads ETHERSCAN_API_KEY env var if not passed as argument
   # chain_id: 1=Ethereum, 56=BSC, 137=Polygon, 42161=Arbitrum, 10=Optimism, 8453=Base
   ```
   Extract: source verification status, proxy status, implementation address.
   - Source not verified: flag as HIGH
   - Proxy contract: flag as MEDIUM, verify implementation is also verified

#### For Solana protocols:

1. **Program upgrade authority** -- for each program ID:
   ```bash
   ./scripts/onchain-check.sh solana-program <program_id>
   ```
   Extract: upgrade authority address, frozen status.
   - Authority = None: program is immutable (LOW risk for admin key, but no bug fixes)
   - Authority exists: proceed to step 2 to identify if it's a multisig or EOA

2. **Authority account type** -- for the upgrade authority address:
   ```bash
   ./scripts/onchain-check.sh solana-account <authority_address>
   ```
   Detects whether the authority is:
   - Squads v3/v4 multisig: follow up at https://v4.squads.so/ for threshold/members
   - System Program-owned (EOA): flag as HIGH (single key controls upgrades)
   - Unknown: record as UNVERIFIED

#### Error handling:
- If any API returns an error or is unavailable, record "API_UNAVAILABLE" in the report
- Note the gap in the Information Gaps section
- Never block the audit due to API failures -- proceed with available data

### Step 9: Generate Risk Report

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
- Valid Until: {today + 90 days} (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Open / Closed / Partial

## Quick Triage Score: {0-100} | Data Confidence: {0-100}
- Red flags found: {count} ({list})
- Data points verified: {count} / {total checkable}

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

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | {LOW/MEDIUM/HIGH/CRITICAL} | {one-line} | {S/H/O} | {Y/N/Partial} |
| Oracle & Price Feeds | {LOW/MEDIUM/HIGH/CRITICAL} | {one-line} | {S/H/O} | {Y/N/Partial} |
| Economic Mechanism | {LOW/MEDIUM/HIGH/CRITICAL} | {one-line} | {S/H/O} | {Y/N/Partial} |
| Smart Contract | {LOW/MEDIUM/HIGH/CRITICAL} | {one-line} | {S/H/O} | {Y/N/Partial} |
| Token Contract (GoPlus) | {LOW/MEDIUM/HIGH/CRITICAL/N/A} | {one-line} | {S/H/O} | {Y/N/Partial} |
| Cross-Chain & Bridge | {LOW/MEDIUM/HIGH/CRITICAL/N/A} | {one-line} | {S/H/O} | {Y/N/Partial} |
| Off-Chain Security | {LOW/MEDIUM/HIGH/CRITICAL} | {one-line} | {O} | {Y/N/Partial} |
| Operational Security | {LOW/MEDIUM/HIGH/CRITICAL} | {one-line} | {S/H/O} | {Y/N/Partial} |
| **Overall Risk** | **{level}** | **{summary}** | | |

**Source column**: S = STRUCTURAL (current architecture risk), H = HISTORICAL (past incident signal), O = OPERATIONAL (off-chain controls risk). A category can have multiple sources (e.g., S/H).

**Overall Risk aggregation rule** (mechanical -- do NOT override with judgment):
```
1. If ANY category is CRITICAL → Overall = CRITICAL
2. If 2+ categories are HIGH → Overall = HIGH
3. If 1 category is HIGH, or 3+ are MEDIUM → Overall = MEDIUM
4. Otherwise → Overall = LOW

Governance & Admin counts as 2x weight (i.e., HIGH governance alone = 2 HIGHs → Overall HIGH).
Cross-Chain & Bridge counts as 2x weight if protocol is deployed on 5+ chains (Kelp lesson).
Categories rated N/A are excluded from the count.
```

## Detailed Findings

### 1. Governance & Admin Key
{detailed analysis with specific findings}

### 2. Oracle & Price Feeds
{detailed analysis}

### 3. Economic Mechanism
{detailed analysis}

### 4. Smart Contract Security
{detailed analysis}

### 5. Cross-Chain & Bridge (if applicable)
{detailed analysis -- omit section if single-chain with no bridge dependencies}

### 6. Operational Security
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

### Beanstalk-type (Flash Loan Governance Attack):
- [ ] Governance votes weighted by token balance at vote time (no snapshot)?
- [ ] Flash loans can be used to acquire voting power?
- [ ] Proposal + execution in same block or short window?
- [ ] No minimum holding period for voting eligibility?

### Cream/bZx-type (Reentrancy + Flash Loan):
- [ ] Accepts rebasing or fee-on-transfer tokens as collateral?
- [ ] Read-only reentrancy risk (cross-contract callbacks before state update)?
- [ ] Flash loan compatible without reentrancy guards?
- [ ] Composability with protocols that expose callback hooks?

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler (Vyper, Huff)?
- [ ] Compiler version has known CVEs?
- [ ] Contracts compiled with different compiler versions?
- [ ] Code depends on language-specific behavior (storage layout, overflow)?

### UST/LUNA-type (Algorithmic Depeg Cascade):
- [ ] Stablecoin backed by reflexive collateral (own governance token)?
- [ ] Redemption mechanism creates sell pressure on collateral?
- [ ] Oracle delay could mask depegging in progress?
- [ ] No circuit breaker on redemption volume?

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- [ ] Protocol uses a cross-chain bridge (LayerZero, Wormhole, etc.) for token minting or reserve release?
- [ ] Bridge message validation relies on a single messaging layer without independent verification?
- [ ] DVN/relayer/verifier configuration is not publicly documented or auditable?
- [ ] Bridge can release or mint tokens without rate limiting per transaction or per time window?
- [ ] Bridged/wrapped token is accepted as collateral on lending protocols (Aave, Compound, Euler)?
- [ ] No circuit breaker to pause minting if bridge-released volume exceeds normal thresholds?
- [ ] Emergency pause response time > 15 minutes (Kelp took 46 minutes)?
- [ ] Bridge admin controls (trusted remotes, rate limits) are under different governance than core protocol?
- [ ] Token is deployed on 5+ chains via same bridge provider (single point of failure)?

**Why this pattern matters**: The attacker does not need to keep the stolen tokens. By depositing unbacked tokens as collateral in lending protocols and borrowing real assets (ETH, USDC), the damage cascades far beyond the initially exploited protocol. In the Kelp hack ($292M, April 2026), the attacker created $290M+ in bad debt across Aave, Compound, and Euler -- affecting protocols that were never directly exploited.

**Trigger rule**: matching 3+ indicators in any single category triggers an explicit warning in the report.

## Information Gaps
- {list of questions that could NOT be answered from public info}
- {these represent unknown risks -- absence of evidence is not evidence of absence}

## Disclaimer
This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
```

### Step 10: Present Results

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

### On-Chain Verification (via onchain-check.sh)

**Helper script**: `./scripts/onchain-check.sh` wraps the APIs below with formatted output and risk assessment.

#### Safe Transaction Service (free, no API key)

| Chain | Base URL |
|-------|----------|
| Ethereum | `https://safe-transaction-mainnet.safe.global/api/v1` |
| Arbitrum | `https://safe-transaction-arbitrum.safe.global/api/v1` |
| Polygon | `https://safe-transaction-polygon.safe.global/api/v1` |
| Optimism | `https://safe-transaction-optimism.safe.global/api/v1` |
| Base | `https://safe-transaction-base.safe.global/api/v1` |
| BSC | `https://safe-transaction-bsc.safe.global/api/v1` |

| Endpoint | Description |
|----------|-------------|
| `safes/{address}/` | Multisig config: threshold, owners[], nonce, modules, guard, version |

#### Etherscan-family APIs (free tier, API key required)

| Chain ID | API Base URL |
|----------|--------------|
| 1 (Ethereum) | `https://api.etherscan.io/api` |
| 56 (BSC) | `https://api.bscscan.com/api` |
| 137 (Polygon) | `https://api.polygonscan.com/api` |
| 42161 (Arbitrum) | `https://api.arbiscan.io/api` |
| 10 (Optimism) | `https://api-optimistic.etherscan.io/api` |
| 8453 (Base) | `https://api.basescan.org/api` |

| Endpoint | Description |
|----------|-------------|
| `?module=contract&action=getsourcecode&address={addr}` | Source verification, proxy status, implementation, compiler |

#### Solana RPC (free, public)

- **URL**: `https://api.mainnet-beta.solana.com` (or set `SOLANA_RPC_URL` env var)
- **Method**: `getAccountInfo` (JSON-RPC POST) -- returns owner program, executable status, account data
- The script prefers `solana` CLI if available (`solana program show` gives upgrade authority directly)

#### SolanaFM API (free, no key)

| Endpoint | Description |
|----------|-------------|
| `https://api.solana.fm/v0/accounts/{address}` | Account label, owner program, type detection |

**Known Squads program IDs** (for detecting multisig accounts):
- Squads v4: `SMPLecH534Ngo6gTACwFvEq4QYHGBqR1sFoJGDhrknp`, `SQDS4ep65T869zMMBKyuUq6aD6EgTu8psMjkvj52pCf`
- Squads v3: `SMPLKTQhrgo22hFCVq2VGX1KAktTWjeizkhrdB1eauK`
