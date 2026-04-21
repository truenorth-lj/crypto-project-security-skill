---
name: defi-risk-analysis
description: Analyze a DeFi protocol's risk profile across smart contract, off-chain, and track-record dimensions. Use when the user wants a risk analysis of a DeFi project, to check protocol security, or to assess risk. Trigger words include "risk analysis", "analyze protocol", "audit defi", "check security", "defi risk", "protocol vulnerability", "is it safe".
version: 2.1.0
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

# DeFi Risk Analysis Skill

Perform a comprehensive risk analysis of a DeFi protocol. This skill systematically evaluates smart contract risk, off-chain risk (governance, team, operations), and track record (historical incidents, battle-testing, response capability).

This is a structured **risk analysis**, NOT a formal smart contract audit — it reviews publicly available information and on-chain state to surface risk signals. Formal audits require line-by-line code review by professional auditing firms.

## Input

The user provides one or more of:
- Protocol name (e.g., "Aave", "Drift", "GMX")
- Protocol website or DeFiLlama URL
- Contract addresses or chain

## Workflow

### Step 0: Quick Triage (Red Flag Scan)

Before deep analysis, run a quick triage to decide analysis priority:

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
   - If still failing, proceed with the analysis without GoPlus data and note the gap in Information Gaps

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
     [ ] Lending/CDP protocol accepts LRT, bridge token, or synthetic asset as collateral without a *binding* per-asset cap (supplyCap < 20% of total collateral TVL; see Step 4.5.5). This flag fires regardless of current % exposure -- ungated collateral can grow. Insurance-vs-largest-exposure is rated separately in Step 4.5 and must not also be flagged here.

   MEDIUM flags (-8 each):
     [ ] GoPlus: is_proxy = 1 AND no timelock on upgrades
     [ ] GoPlus: is_mintable = 1
     [ ] Protocol age < 6 months with TVL > $50M
     [ ] TVL dropped > 30% in 90 days
     [ ] Multisig threshold < 3 signers (e.g., 2/N)
     [ ] GoPlus: slippage_modifiable = 1
     [ ] GoPlus: transfer_pausable = 1
     [ ] No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations
     [ ] **This protocol's** bridge/wrapped/LRT token is accepted as collateral on 3+ external lending protocols without rate limits (issuer-side downstream-cascade risk; for the inverse — this protocol *accepting* such collateral — see Step 4.5 / the HIGH flag above)

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
4. **Security incidents**:
   - Search: `"{protocol}" exploit OR hack OR vulnerability OR "security incident"`
   - Search: `"{protocol}" site:rekt.news`
   - Search: `"{protocol}" post-mortem OR postmortem`

5. **Audit discovery** — run these sources IN ORDER and deduplicate. Missing an audit is a common failure mode (e.g., Apyx publishes Quantstamp/Certora/Zellic reports at `docs.apyx.fi/resources/audits` that generic web search often misses). Do not stop at the first source — cross-check all four.

   a. **DeFiLlama protocol payload** (authoritative if populated). From the Step 0 data, parse these fields:
      ```bash
      curl -s 'https://api.llama.fi/protocol/{slug}' | jq '{audits, audit_note, audit_links}'
      ```
      - `audits`: numeric count (0/1/2/3)
      - `audit_note`: free-text summary
      - `audit_links`: array of URLs to audit PDFs

   b. **Protocol documentation** — try these paths explicitly (substitute the protocol's docs domain; many use `docs.{domain}` or `{domain}/docs`):
      ```
      https://docs.{domain}/audits
      https://docs.{domain}/resources/audits
      https://docs.{domain}/security/audits
      https://docs.{domain}/security
      https://{domain}/audits
      https://{domain}/security
      ```
      Use WebFetch to pull each candidate page. Many protocols list audits here that are not indexed on DeFiLlama. Record firm name, date, and PDF URL for each.

   c. **GitHub audits folder** — check the protocol's main contracts repo for an `audits/` or `/audit/` directory:
      ```
      https://github.com/{org}/{repo}/tree/main/audits
      https://github.com/{org}/audits
      https://github.com/{org}/{repo}-audits
      ```
      Trail of Bits, ConsenSys Diligence, OpenZeppelin, Zellic, Spearbit, Cantina commonly drop PDFs here.

   d. **Web search fallback** (only after a/b/c are exhausted):
      - Search: `"{protocol}" audit report site:github.com`
      - Search: `"{protocol}" audit filetype:pdf`
      - Search: `site:code4rena.com "{protocol}"` (contest audits)
      - Search: `site:sherlock.xyz "{protocol}"` (contest audits)

   For each discovered audit, record: firm, date, scope/commit hash (if cited in the report), and source (DeFiLlama / docs / GitHub / search). If DeFiLlama's count differs from what you found in b/c, use your discovered list as authoritative and note the DeFiLlama gap under Information Gaps.

6. **Governance and admin configuration**:
   - Search: `"{protocol}" multisig OR timelock OR governance OR "admin key"`
7. **Bug bounty**:
   - Search: `"{protocol}" site:immunefi.com`
8. **Peer comparison**: identify 2-3 comparable protocols for benchmarking. Selection criteria:
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

#### 4.5 Collateral Source Risk (lending / CDP / money-market protocols only)

Skip for non-lending protocols (DEX, perps without external collateral, single-asset vaults).

The Kelp incident showed that a lending protocol's risk is dominated by the *worst* collateral it accepts, not the average. A single LRT, bridge token, or synthetic asset depeg can create bad debt that exceeds the insurance fund, even if every other collateral is pristine. Step 7.3 covers the inverse (this protocol's token used as collateral elsewhere); 4.5 covers collateral *accepted into* this protocol.

##### 4.5.1 Inventory Accepted Collateral
For each enabled collateral asset, record:
- Asset symbol, contract address, current TVL deposited, current borrow against it
- Asset category: native (ETH, BTC, stablecoin issued on-chain), LRT (rsETH, weETH, ezETH, pufETH), bridge/wrapped (any token whose backing lives on a different chain or in a custodian), synthetic (USDe, USDX, eUSD)
- Issuer / source protocol (e.g., Kelp for rsETH, EtherFi for weETH, Renzo for ezETH)
- Underlying messaging or bridge layer if applicable (LayerZero, Wormhole, Axelar, native bridge)

##### 4.5.2 Per-Asset Exposure Caps
- Is there a hard supply cap (`supplyCap`) per collateral, enforced in code?
- Is there a borrow cap per asset?
- Can caps be raised without a timelock?
- Largest asset's deposited TVL as a % of total collateral TVL (concentration ratio)

##### 4.5.3 Shared Bridge / Issuer Concentration
Multiple LRTs and synthetic assets may *appear* diversified but share the same bridge layer or issuer. Identify:
- All collaterals that ride the same bridge provider (e.g., rsETH + weETH + ezETH all on LayerZero)
- All collaterals from the same issuer or its corporate group
- Combined exposure across the shared dependency as a % of total collateral TVL
- This combined number is the realistic worst-case loss from a single bridge or issuer failure -- treat it as one position, not many.

##### 4.5.4 Insurance vs. Largest Exposure
- Largest single-collateral exposure (or largest shared-bridge / shared-issuer cluster from 4.5.3), in USD
- Insurance fund / safety module size, in USD
- This absolute-dollar comparison supersedes the "Insurance Fund / TVL %" rule for lending protocols. A 2% Insurance/TVL ratio is meaningless if a single asset is 30% of collateral.
- The insurance vs. exposure delta is an INPUT to the 4.5.5 rating ladder below — do NOT also rate it independently here, otherwise the same condition is counted twice (once in 4.5.4, once in 4.5.5).

##### 4.5.5 Rating Ladder (binding for sub-category A.5)

Apply rows top-to-bottom; the first matching row is the rating. Thresholds use the largest single-asset exposure OR the largest shared-bridge / shared-issuer cluster size (USD) from 4.5.3, whichever is greater.

**"Per-asset cap" qualifier**: a cap counts only if it is *binding* — supplyCap < 20% of total collateral TVL. A 99%-of-TVL cap is treated as no cap.

| Rating | Conditions (all must hold for the row) |
|---|---|
| CRITICAL | Largest exposure > 30% of collateral AND insurance < that exposure AND (no per-asset rate limit AND no oracle circuit breaker on that collateral). Missing only one of the two protections → falls through to HIGH. |
| HIGH | Any of: (a) LRT/bridge/synthetic collateral exists without a binding per-asset cap (regardless of % — ungated growth is the risk), (b) largest exposure > 10% of collateral AND insurance < largest exposure, (c) shared-bridge/shared-issuer cluster size (USD) > insurance, (d) single native asset > 50% of collateral AND insurance < that exposure |
| MEDIUM | Some bridge/LRT/synthetic collateral exists, every such asset has a binding per-asset cap, AND insurance ≥ largest exposure |
| LOW | All collateral is native (ETH, BTC, on-chain stablecoins), no single asset > 50% of collateral, AND insurance ≥ largest exposure |

Notes:
- The CRITICAL row requires BOTH protections missing (no rate limit AND no circuit breaker) on top of the >30% / underinsured conditions; missing exactly one protection stays at HIGH. This is the intentional reading of the AND.
- A protocol with a single native asset (e.g., wstETH-dominant) at >50% of collateral and insurance < that exposure is HIGH via row (d), not LOW.
- Sub-10% LRT/bridge/synthetic with no binding cap still rates HIGH via row (a) — small uncapped positions can grow.
- Cross-check findings here against the Kelp-type pattern checklist in Step 9; A.5 conditions and the Kelp-type indicators must agree, otherwise revisit one or the other.

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

#### 5.5 Audited vs Deployed Drift

The most commonly ignored smart-contract risk is that audited code is NOT what is running in production. This can happen in several ways:

- The team commissions an audit, then deploys a NEWER version that was never re-audited.
- A proxy's implementation is upgraded after the audit without a new audit round.
- The audit covers only a subset of the deployed contracts.
- The audit was performed on a commit that was never deployed (vaporware audit).

This sub-step cross-references what was audited against what is running. Skip only if (a) no audits exist OR (b) all contracts are closed-source AND not verified on any explorer.

##### 5.5.1 Extract Audit Scope

From each audit report discovered in Step 1.5, record:

- **Firm** and **date**
- **Commit hash / git tag** reviewed (most reports state this in the Scope or Methodology section)
- **Contracts in scope** (list of file names or addresses)
- **Findings status** (how many fixed vs acknowledged vs unresolved)

If a report does NOT cite a commit or tag, flag as HIGH info gap — the audit cannot be independently reproduced or re-verified.

##### 5.5.2 Post-Audit Upgrade Detection

For each known proxy contract on an EVM chain, check the implementation's deployment timestamp against the latest audit date.

```bash
./scripts/onchain-check.sh contract-age <address> <chain_id> [api_key]
```
Returns the creation timestamp of the contract AND (if it is a proxy) the current implementation's deployment timestamp.

Risk rating (use the CURRENT implementation's creation date):

- Implementation created BEFORE last audit date → LOW (audited code is running)
- Implementation created AFTER last audit but within 90 days of a re-audit announcement → LOW
- Implementation created AFTER last audit, NO re-audit → HIGH (post-audit drift)
- 3+ post-audit upgrades detected (scan proxy `Upgraded` events for a full history) → CRITICAL

To enumerate all historical upgrades for a proxy, query `Upgraded(address)` events via Etherscan's `getLogs`:

```bash
# EIP-1967 Upgraded event topic: 0xbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b
curl -s "https://api.etherscan.io/api?module=logs&action=getLogs&address={proxy}&topic0=0xbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b&apikey={key}"
```
Each log entry is an implementation change; the log timestamp is an upgrade event.

##### 5.5.3 Source Diff (when audit commit is cited)

If the audit report cites a commit and the deployed source is verified on Etherscan:

1. Clone the repo at the audited commit: `git clone {repo} && git checkout {commit}`
2. Fetch Etherscan's verified source (returned by the `etherscan` subcommand of `onchain-check.sh`) and save it as local files.
3. Compare file-by-file. Useful signals:
   - **File set diff** — are the deployed file names a superset/subset of the audit scope?
   - **Line count delta** per file — flag >5% change.
   - **New admin functions** — grep the deployed source for `onlyOwner`, `onlyRole`, `_checkRole` modifier uses that do NOT exist in the audited source. Any new admin function added post-audit is HIGH.
   - **New mint / upgrade / setOracle / setFeed** functions — CRITICAL if added post-audit without re-audit.
   - **Removed checks** — if `require(...)` statements decreased, scrutinize carefully.

This is approximate — not a formal audit. It catches obvious drift (new admin functions, removed checks, added backdoors) but can miss subtle logic changes. For definitive matching, compile the audited commit with the same solc version + optimizer settings and compare bytecode; that is out of scope for this skill.

##### 5.5.4 Report Format

Populate sub-category **A.2 Audited vs Deployed Drift** in the Risk Summary using this format:

```
#### A.2 Audited vs Deployed Drift

| Audit | Date | Commit Cited | Scope | Deployed Match? |
|---|---|---|---|---|
| Trail of Bits | 2024-08-15 | a1b2c3 | Vault, PriceFeed | Partial |
| Certora | 2025-03-10 | d4e5f6 | Vault | Yes |

**Post-audit implementation changes**:
- Proxy 0x...abc: current impl deployed 2026-02-14 (6 months after Trail of Bits audit, no re-audit)
- Proxy 0x...def: matches audited commit

**Drift rating**: HIGH
**Justification**: Vault implementation upgraded 2026-02-14 with no re-audit announcement. Source diff shows 2 new `onlyOwner` functions (setFeeTier, setReserveFactor) not in the audited source.
```

If the protocol has no proxies and all contracts are immutable, A.2 can be rated LOW with justification "all contracts immutable, no post-deployment drift possible".

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
- Never block the analysis due to API failures -- proceed with available data

### Step 9: Generate Risk Report

Compile findings into a structured report:

```
# DeFi Risk Analysis: {Protocol Name}

## Overview
- Protocol: {name}
- Chain: {chain}
- Type: {type}
- TVL: {tvl}
- TVL Trend: {7d}% / {30d}% / {90d}%
- Launch Date: {date}
- Analysis Date: {today}
- Valid Until: {today + 90 days} (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Open / Closed / Partial

## Quick Triage Score: {0-100} | Data Confidence: {0-100}
- Red flags found: {count} ({list})
- Data points verified: {count} / {total checkable}

## Quantitative Metrics
| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | {x}% | {peer avg}% | {rating — for lending/CDP protocols this is informational only; the binding metric is the next row (see Step 4.5.4)} |
| Insurance Fund (USD) vs Largest Single-Collateral Exposure (USD) | ${ins} vs ${exp} | -- | {rating} |
| Largest Shared-Bridge / Shared-Issuer Collateral Cluster | ${cluster} ({pct}% of collateral) | -- | {rating} |
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

Risk is grouped into **three top-level dimensions**. Each dimension has sub-categories; the dimension rating is the MAX of its sub-categories (with the weighting rules below).

### A. Smart Contract Risk

Everything that depends on what the code does and how it's deployed on-chain.

| Sub-category | Risk | Key Concern | Verified? |
|---|---|---|---|
| Code Quality & Audit Coverage | {LOW/MEDIUM/HIGH/CRITICAL} | {one-line} | {Y/N/Partial} |
| Audited vs Deployed Drift | {LOW/MEDIUM/HIGH/CRITICAL/N/A} | {one-line} | {Y/N/Partial} |
| Oracle & Price Feeds | {LOW/MEDIUM/HIGH/CRITICAL} | {one-line} | {Y/N/Partial} |
| Economic Mechanism | {LOW/MEDIUM/HIGH/CRITICAL} | {one-line} | {Y/N/Partial} |
| Collateral Source Risk | {LOW/MEDIUM/HIGH/CRITICAL/N/A} | {one-line} | {Y/N/Partial} |
| Token Contract (GoPlus) | {LOW/MEDIUM/HIGH/CRITICAL/N/A} | {one-line} | {Y/N/Partial} |
| Cross-Chain & Bridge | {LOW/MEDIUM/HIGH/CRITICAL/N/A} | {one-line} | {Y/N/Partial} |

### B. Off-Chain Risk

Everything that cannot be verified from the blockchain alone — people, processes, procedures.

| Sub-category | Risk | Key Concern | Verified? |
|---|---|---|---|
| Governance & Admin Rights | {LOW/MEDIUM/HIGH/CRITICAL} | {one-line} | {Y/N/Partial} |
| Team & Operations | {LOW/MEDIUM/HIGH/CRITICAL} | {one-line} | {Y/N/Partial} |
| Key Management & Certifications | {LOW/MEDIUM/HIGH/CRITICAL} | {one-line} | {Y/N/Partial} |

### C. Track Record

Historical signal — what has actually happened, not what could theoretically happen.

| Sub-category | Risk | Key Concern | Verified? |
|---|---|---|---|
| Security Incidents History | {LOW/MEDIUM/HIGH/CRITICAL} | {one-line} | {Y/N/Partial} |
| Battle-Tested Duration | {LOW/MEDIUM/HIGH} | {one-line} | {Y/N/Partial} |
| Audit Recency | {LOW/MEDIUM/HIGH} | {one-line} | {Y/N/Partial} |
| TVL Stability | {LOW/MEDIUM/HIGH} | {one-line} | {Y/N/Partial} |
| Incident Response Capability | {LOW/MEDIUM/HIGH/CRITICAL} | {one-line} | {Y/N/Partial} |

### Top-Level Aggregation

| Dimension | Risk Level | Key Driver |
|---|---|---|
| A. Smart Contract | {MAX of A} | {which sub-category drove it} |
| B. Off-Chain | {MAX of B, Governance 2x} | {driver} |
| C. Track Record | {MAX of C} | {driver} |
| **Overall Risk** | **{level}** | **{summary}** |

**Aggregation rule** (mechanical -- do NOT override with judgment):
```
1. DIMENSION rating = MAX of its sub-category ratings, subject to weighting:
   - B. Off-Chain: Governance & Admin Rights counts 2x
     (HIGH Governance alone → dimension = HIGH)
   - A. Smart Contract: Cross-Chain & Bridge counts 2x if deployed on 5+ chains
     (Kelp lesson — bridge risk cascades into composability)

2. OVERALL rating aggregates across the 3 dimensions:
   - ANY dimension CRITICAL    → Overall = CRITICAL
   - 2+ dimensions HIGH        → Overall = HIGH
   - 1 dimension HIGH, or
     2+ dimensions MEDIUM      → Overall = MEDIUM
   - Otherwise                 → Overall = LOW

3. Sub-categories rated N/A are excluded from the MAX.
```

## Detailed Findings

### A. Smart Contract Risk

#### A.1 Code Quality & Audit Coverage
{audit count, firms, recency, findings fixed; bug bounty; battle testing; source code review from Step 5.4}

#### A.2 Audited vs Deployed Drift
{from Step 5.5 — is the audited code actually what's running in production?}

#### A.3 Oracle & Price Feeds
{detailed analysis from Step 3}

#### A.4 Economic Mechanism
{detailed analysis from Step 4 — liquidation, insurance fund, rate model, withdrawal limits}

#### A.5 Collateral Source Risk
{from Step 4.5 — only for lending/CDP/money-market protocols. Inventory of accepted collateral by category (native / LRT / bridge / synthetic), per-asset caps, shared-bridge or shared-issuer clusters, insurance vs largest exposure in absolute USD. Omit (mark N/A) for non-lending protocols.}

#### A.6 Token Contract (GoPlus)
{GoPlus findings — omit if no token / Solana / API unavailable}

#### A.7 Cross-Chain & Bridge
{detailed analysis from Step 6 — omit if single-chain with no bridge dependencies}

### B. Off-Chain Risk

#### B.1 Governance & Admin Rights
{from Step 2 — admin key surface, upgrade mechanism, governance process, token concentration, timelock bypass}

#### B.2 Team & Operations
{from Step 7.1, 7.2, 7.3 — team track record, incident response plan, dependencies}

#### B.3 Key Management & Certifications
{from Step 7.4 — SOC 2 / ISO 27001, HSM/MPC, custodial counterparty, pentest, operational segregation}

### C. Track Record

#### C.1 Security Incidents History
{prior exploits, near-misses, postmortems, fund recovery outcomes}

#### C.2 Battle-Tested Duration
{time live, peak TVL handled, protocol age vs TVL}

#### C.3 Audit Recency
{date of most recent audit vs today; stale audits = weaker signal; also flag if code changed since last audit — see A.2}

#### C.4 TVL Stability
{7d/30d/90d trend, sharp declines, withdrawal patterns}

#### C.5 Incident Response Capability
{emergency pause latency (benchmark <15min), historical response examples, communication channels, bug bounty payouts}

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
This is a **risk analysis**, not a formal smart contract audit. It is based on
publicly available information, on-chain state, and web research. Always DYOR
and consider professional auditing services for investment decisions. "Risk
analysis" and "audit" are distinct: only licensed auditing firms produce the
latter.
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
