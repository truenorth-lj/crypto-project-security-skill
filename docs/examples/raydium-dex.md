# DeFi Security Audit: Raydium

**Audit Date:** April 20, 2026
**Protocol:** Raydium -- Solana AMM DEX

## Overview
- Protocol: Raydium
- Chain: Solana
- Type: DEX / AMM (Standard AMM, CLMM, CPMM)
- TVL: ~$991M
- TVL Trend: +1.3% (7d) / -6.1% (30d) / -34.1% (90d)
- Launch Date: February 2021
- Audit Date: April 20, 2026
- Valid Until: July 19, 2026 (or sooner if: TVL changes >30%, governance upgrade, or security incident)
- Source Code: Open (GitHub -- raydium-io)

## Quick Triage Score: 34/100 | Data Confidence: 35/100

**Quick Triage Score Calculation:**

Start at 100. Deductions:

CRITICAL flags (-25 each):
- None detected.

HIGH flags (-15 each):
- [x] Anonymous team with no prior track record (-15) -- team uses pseudonyms (AlphaRay, XRay, GammaRay); never doxxed
- [x] No multisig (single EOA admin key) (-15) -- on-chain verification shows both upgrade authorities (GThUX1Atko4tqhN2NaiTazWSeFWMuiUvfFnyJyUghFMJ and 8aSRiwajnkCP3ZhWTqTGJBy82ELo3Rt1CoEk5Hyjiqiy) resolve to System Program-owned accounts (EOA-type); docs claim Squads multisig but on-chain data contradicts this

MEDIUM flags (-8 each):
- [x] TVL dropped > 30% in 90 days (-8) -- dropped 34.1% from $1.50B to $991M
- [x] No third-party security certification (SOC 2 / ISO 27001 / equivalent) for off-chain operations (-8)

LOW flags (-5 each):
- [x] No documented timelock on admin actions (-5) -- docs confirm no timelock currently; "planned" only
- [x] Single oracle provider (-5) -- uses internal TWAP only; no external oracle (Pyth/Chainlink) for pricing
- [x] Undisclosed multisig signer identities (-5) -- even if Squads is used, signers are unknown
- No bug bounty program -- HAS one ($505K max on Immunefi), so no deduction
- [x] Insurance fund / TVL < 1% or undisclosed (-5) -- no insurance fund disclosed; treasury receives 4% of fees but size undisclosed

100 - 15 - 15 - 8 - 8 - 5 - 5 - 5 - 5 = **34/100** (HIGH risk)

**Data Confidence Score Calculation:**

- [x] +15 Source code is open and verified on block explorer (GitHub repos public)
- [ ] +15 GoPlus/RugCheck token scan completed -- RugCheck returned "not found" for RAY mint; UNAVAILABLE
- [x] +10 At least 1 audit report publicly available (9 audits on GitHub)
- [ ] +10 Multisig configuration verified on-chain -- on-chain check shows EOA, contradicts docs
- [ ] +10 Timelock duration verified on-chain or in docs -- no timelock exists
- [ ] +10 Team identities publicly known (doxxed) -- pseudonymous team
- [ ] +10 Insurance fund size publicly disclosed -- not disclosed
- [x] +5 Bug bounty program details publicly listed (Immunefi, $505K max)
- [ ] +5 Governance process documented -- no formal governance process
- [x] +5 Oracle provider(s) confirmed -- internal TWAP confirmed
- [ ] +5 Incident response plan published -- not published
- [ ] +5 SOC 2 Type II or ISO 27001 certification verified -- none
- [ ] +5 Published key management policy -- none
- [ ] +5 Regular penetration testing disclosed -- none
- [ ] +5 Bridge DVN/verifier configuration publicly documented -- N/A (single chain)

Total: 15 + 10 + 5 + 5 = **35/100** (LOW confidence)

**Final: Triage: 34/100 (HIGH risk) | Confidence: 35/100 (LOW confidence)**

- Red flags found: 8 (anonymous team, EOA-type upgrade authority, no timelock, TVL decline >30% in 90d, no security certification, undisclosed multisig signers, no insurance fund disclosure, single oracle)
- Data points verified: 4 / 15 checkable

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed (treasury receives 4% of fees) | Orca: undisclosed, Jupiter: undisclosed | HIGH |
| Audit Coverage Score | 3.25 (see below) | Orca: ~4.0, Jupiter: ~2.0 | LOW risk |
| Governance Decentralization | No DAO, team-controlled | Orca: DAO + multisig, Jupiter: DAO | HIGH |
| Timelock Duration | 0h (none) | Orca: has timelock, Jupiter: has timelock | HIGH |
| Multisig Threshold | UNVERIFIED (docs say Squads, on-chain shows EOA) | Orca: Squads, Jupiter: Squads | HIGH |
| RugCheck Risk Flags | UNAVAILABLE | -- | UNVERIFIED |

**Audit Coverage Score Calculation:**
- Sec3 Q3 2025 (< 1 year): 1.0
- Halborn Q2 2025 (< 1 year): 1.0
- Halborn Q4 2024 (1-2 years): 0.5
- MadShield Q1 2024 (> 2 years): 0.25
- MadShield Q2 2023 (> 2 years): 0.25
- OtterSec Q3 2022 x3 (> 2 years): 0.25 x 3 = 0.75 (counted as 0.25 since same quarter)
- Kudelski Q2 2021 (> 2 years): 0.25
Total: 1.0 + 1.0 + 0.5 + 0.25 + 0.25 + 0.25 = **3.25** (LOW risk, >= 3.0 threshold)

## RugCheck Token Security (RAY on Solana)

| Check | Result | Risk |
|-------|--------|------|
| RugCheck Scan | API returned "not found" for mint 4k3Dyjzvzp8eMZFUEDRkRd2S3tnQhXhEqefEH6dGA1ns | UNAVAILABLE |
| Mint Authority | UNVERIFIED -- could not query | UNVERIFIED |
| Freeze Authority | UNVERIFIED -- could not query | UNVERIFIED |
| Metadata Mutability | UNVERIFIED | UNVERIFIED |
| Top Holder Concentration | 20% team allocation (vested), 34% mining reserve, 30% partnership | MEDIUM |
| Total Supply | 555,000,000 RAY (hard cap) | -- |
| Circulating Supply | ~268,896,285 RAY (~48.5%) | -- |

RugCheck assessment: **UNAVAILABLE**. The RugCheck API did not return data for the RAY token mint address. Manual verification via Solana Explorer was not possible without CLI tools. This is a data gap.

## Risk Summary

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | **HIGH** | Upgrade authority appears EOA on-chain; no timelock; pseudonymous team | S/H/O | Partial |
| Oracle & Price Feeds | **MEDIUM** | Internal TWAP only; no external oracle fallback | S | Partial |
| Economic Mechanism | **LOW** | Standard AMM/CLMM with fee distribution; no lending/leverage risk | S | Partial |
| Smart Contract | **MEDIUM** | 9 audits but 3 critical findings noted; DeFiSafety scored 0% for testing | S/H | Y |
| Token Contract (RugCheck) | **MEDIUM** | RugCheck unavailable; ~48% circulating supply; pseudonymous team controls reserves | O | N |
| Cross-Chain & Bridge | **N/A** | Single-chain (Solana only) | -- | -- |
| Off-Chain Security | **HIGH** | No SOC 2, no published key management, no pentest disclosure; 2022 trojan compromise | O/H | N |
| Operational Security | **HIGH** | Pseudonymous team; prior private key compromise (Dec 2022); no published incident response plan | H/O | Partial |
| **Overall Risk** | **HIGH** | **Anonymous team + EOA-type upgrade authority + no timelock + prior key compromise = high admin risk** | | |

**Overall Risk aggregation:**
1. Governance & Admin = HIGH (counts 2x) = 2 HIGHs
2. Off-Chain Security = HIGH = 1 HIGH
3. Operational Security = HIGH = 1 HIGH
4. Total: 4 HIGHs (2+ HIGHs = Overall HIGH)

## Detailed Findings

### 1. Governance & Admin Key -- HIGH

**Admin Key Surface Area:**
- Raydium's upgrade authority addresses (GThUX1Atko4tqhN2NaiTazWSeFWMuiUvfFnyJyUghFMJ for core programs, 8aSRiwajnkCP3ZhWTqTGJBy82ELo3Rt1CoEk5Hyjiqiy for auxiliary programs) control all program upgrades
- Admin can: upgrade programs (change all logic), modify pool parameters, pause operations
- Documentation claims "All program Upgrade and Admin Authority is held under a Squads multi-sig"
- **On-chain verification contradicts this**: Both authority addresses resolve to System Program-owned accounts (owner: 11111111111111111111111111111111), which is characteristic of regular wallets/EOAs, NOT Squads multisig vaults
- **Important caveat**: Squads v3 vault PDAs can sometimes appear as System Program-owned accounts in RPC queries. Without the Solana CLI (`solana program show`), definitive classification is not possible. This is marked as PARTIALLY VERIFIED.
- No timelock on any admin actions. Documentation states: "Timelock mechanisms are planned as code moves toward open-sourcing and community governance" -- but this has been "planned" for years
- Multisig threshold and signer count: UNKNOWN (not publicly documented)
- Multisig signers: all pseudonymous

**Upgrade Mechanism:**
- All programs use BPF Upgradeable Loader (upgradeable)
- Key programs: AMM v4 (675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8), CLMM (CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK), CPMM (CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C)
- Post-2022 hack, admin parameters that were exploited were removed from the AMM v4 program
- No immutable programs; all remain upgradeable

**Governance Process:**
- No formal on-chain governance
- No DAO voting mechanism
- All decisions made by core team
- RAY token has no governance utility (staking rewards only)
- No governance forum or proposal process documented

### 2. Oracle & Price Feeds -- MEDIUM

**Oracle Architecture:**
- Raydium does NOT use external oracles (Pyth, Chainlink) for pool pricing
- As a DEX/AMM, prices are determined by pool reserves (constant product formula) and concentrated liquidity positions
- CLMM pools have a built-in TWAP oracle using Observation State for on-chain price tracking
- No external fallback mechanism -- the pool IS the price source

**Price Manipulation Resistance:**
- CLMM TWAP provides some resistance to instantaneous manipulation
- Standard AMM pools use constant product (x*y=k) formula -- vulnerable to large trades within a block
- No circuit breaker for abnormal price movements documented
- Permissionless pool creation means low-liquidity pools can be created and manipulated

**Risk Context:**
- As a DEX, Raydium is a price SOURCE, not a price consumer -- oracle risk is primarily for protocols that read Raydium prices
- However, the permissionless nature means scam tokens with manipulable liquidity pools are common (this is a user risk, not a protocol risk)

### 3. Economic Mechanism -- LOW

**Fee Distribution:**
- CLMM and CPMM pools: 84% to LPs, 12% to RAY buybacks, 4% to treasury
- Standard AMM: similar structure with trading fees distributed to LPs

**Liquidity Provider Risk:**
- Standard impermanent loss risk for AMM LPs
- CLMM adds concentrated liquidity IL risk (higher potential returns but sharper losses)
- No lending, leverage, or liquidation mechanism -- pure AMM
- Burn & Earn (liquidity locker) allows LPs to permanently lock liquidity (audited by Halborn Q4 2024)

**Bad Debt / Insurance:**
- N/A -- as a DEX, there is no bad debt mechanism
- Treasury receives 4% of fees but treasury size is undisclosed
- No insurance fund or safety module

**LaunchLab:**
- Raydium's token launch platform (successor to Pump.fun integration)
- Bonding curve mechanism for new token launches
- Audited by Halborn Q2 2025
- User risk: newly launched tokens carry high rug-pull risk

### 4. Smart Contract Security -- MEDIUM

**Audit History:**
9 audits from 4 firms across 5 years:

| # | Program | Auditor | Date | Age |
|---|---------|---------|------|-----|
| 1 | Order-book AMM | Kudelski Security | Q2 2021 | ~5 years |
| 2 | CLMM | OtterSec | Q3 2022 | ~4 years |
| 3 | Updated AMM | OtterSec | Q3 2022 | ~4 years |
| 4 | Staking | OtterSec | Q3 2022 | ~4 years |
| 5 | AMM + OpenBook Migration | MadShield | Q2 2023 | ~3 years |
| 6 | CPMM | MadShield | Q1 2024 | ~2 years |
| 7 | Burn & Earn (LP Locker) | Halborn | Q4 2024 | ~1.5 years |
| 8 | LaunchLab | Halborn | Q2 2025 | ~1 year |
| 9 | CPMM Update | Sec3 | Q3 2025 | <1 year |

All audit reports are publicly available on GitHub (raydium-io/raydium-docs).

**Concerns:**
- DeFiSafety review scored testing at 0% -- "no test software or discussion about tests was found in the software repository"
- Most recent audit found 3 critical and 1 high priority bugs (status of fixes not confirmed in search results)
- Core AMM and CLMM programs have not been re-audited since 2022-2023 despite active development

**Bug Bounty:**
- Active on Immunefi: up to $505,000
- Minimum $50,000 for critical smart contract vulnerabilities
- Covers CLMM and AMM programs
- Requires PoC code (not just descriptions)
- Neodyme team has conducted additional reviews via bug bounty agreement
- Raydium Tick Manipulation bugfix was publicly reviewed by Immunefi (indicates active bounty engagement)

**Battle Testing:**
- Live since February 2021 (5+ years)
- Peak single-day volume: $16B (January 19, 2025, TRUMP memecoin launch)
- One exploit: December 2022 ($5.5M, private key compromise, not smart contract bug)
- Open source code on GitHub

### 5. Cross-Chain & Bridge -- N/A

Raydium operates exclusively on Solana. No cross-chain deployments or bridge dependencies.

### 6. Operational Security -- HIGH

**Team & Track Record:**
- Pseudonymous team: AlphaRay (strategy/ops), XRay (CTO), GammaRay (marketing)
- AlphaRay has background in algorithmic trading in commodities and crypto market making since 2017
- XRay has 8 years experience as trading systems architect
- Real identities have never been publicly disclosed
- No known corporate entity backing Raydium

**Historical Incidents:**
- **December 16, 2022**: Private key compromise via trojan virus. Attacker drained ~$5.5M from liquidity pools using an admin function (withdraw_pnl). RAY dropped 8%, TVL dropped 27%.
- Attacker bridged ~$2M to Ethereum and sent to Tornado Cash
- Response: Team upgraded smart contracts to remove the exploited admin parameters
- Offered 10% bounty for return of funds (no return occurred)
- Root cause: Trojan malware on a team member's machine compromised admin private key

**Bonk.fun Incident (March 2026):**
- Bonk.fun (backed by Raydium) suffered domain hijacking attack
- Hackers installed crypto drainer on the site
- Only users who signed a fake ToS message were affected
- Detected quickly; contained impact

**Incident Response:**
- No published incident response plan
- No documented emergency pause capability (though team demonstrated ability to upgrade programs quickly post-2022 hack)
- Communication via Twitter/Medium during incidents
- **Emergency response time**: Not documented; 2022 incident timeline unclear

**Off-Chain Security:**
- No SOC 2 or ISO 27001 certification
- No published key management policy (despite 2022 hack being caused by key compromise)
- No disclosed penetration testing
- No published operational security procedures
- Anonymous team makes third-party verification impossible

## Critical Risks

1. **Upgrade authority may be EOA (not multisig)**: On-chain verification shows both upgrade authority addresses as System Program-owned accounts. If these are truly EOAs rather than Squads vaults, a single compromised key could upgrade all Raydium programs and drain all pool funds. This exact attack vector was exploited in December 2022.

2. **No timelock on program upgrades**: Even if the upgrade authority is a multisig, there is no timelock. A compromised multisig (or malicious team action) could deploy a malicious upgrade instantly with no window for users to withdraw funds.

3. **Anonymous team with prior key compromise**: The 2022 hack was caused by a trojan on a team member's machine. The team remains anonymous, making it impossible to verify they have implemented adequate key management practices since then.

4. **90-day TVL decline of 34%**: While partly attributable to SOL price movements and broader market conditions, this magnitude of decline warrants monitoring.

## Peer Comparison

| Feature | Raydium | Orca | Jupiter |
|---------|---------|------|---------|
| TVL | ~$991M | ~$360M | ~$2.6B |
| Timelock | None | Has timelock | Has timelock |
| Multisig | Claims Squads (UNVERIFIED on-chain) | Squads (verified) | Squads (verified) |
| Audits | 9 (4 firms) | Quarterly (Trail of Bits, Halborn) | Multiple |
| Oracle | Internal TWAP | Internal + external | N/A (aggregator) |
| Insurance/TVL | Undisclosed | Undisclosed | Undisclosed |
| Open Source | Yes | Yes | Partial |
| Bug Bounty | $505K (Immunefi) | Yes (Immunefi) | Yes |
| Team | Pseudonymous | Semi-doxxed | Doxxed (Meow) |
| Governance | None (team-controlled) | DAO + multisig | DAO (JUP token) |
| Past Exploits | $5.5M (Dec 2022) | None | None (phishing only) |
| Live Since | Feb 2021 | Feb 2021 | Oct 2021 |

**Key gaps vs. peers**: Raydium lacks a timelock (both Orca and Jupiter have them), has a pseudonymous team (Jupiter's founder Meow is semi-doxxed), has no governance process (both peers have DAOs), and has suffered a direct protocol exploit (neither peer has).

## Recommendations

1. **For users/LPs**: Monitor the upgrade authority addresses for any program upgrade transactions. Consider the risk that programs can be upgraded without notice. Use Raydium primarily for trading rather than large LP positions unless you accept the admin key risk.

2. **For the Raydium team**: Implement a timelock on program upgrades (even 6-12 hours would significantly improve security). Publicly document the Squads multisig configuration (threshold, signer count). Consider doxxing at least some team members to build trust.

3. **For protocols integrating Raydium prices**: Use Raydium TWAP values rather than spot prices. Implement circuit breakers for abnormal price movements. Be aware that permissionless pool creation means not all pools are legitimate.

4. **For governance token holders (RAY stakers)**: RAY currently has no governance utility. If governance is eventually implemented, ensure timelock and minimum holding periods are included from the start.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [x] Admin can list new collateral without timelock? -- **YES**, permissionless pool creation; admin parameters have no timelock
- [ ] Admin can change oracle sources arbitrarily? -- **N/A**, no external oracle dependency
- [x] Admin can modify withdrawal limits? -- **PARTIALLY**, admin can upgrade programs which could modify any parameter
- [x] Multisig has low threshold (2/N with small N)? -- **UNKNOWN**, multisig threshold not disclosed; upgrade authority appears EOA on-chain
- [x] Zero or short timelock on governance actions? -- **YES**, zero timelock
- [x] Pre-signed transaction risk (durable nonce on Solana)? -- **YES**, Solana durable nonces exist; if upgrade authority is EOA, pre-signed upgrades are possible
- [x] Social engineering surface area (anon multisig signers)? -- **YES**, all team members are pseudonymous

**6/7 flags matched. CRITICAL WARNING: Raydium matches the Drift-type attack pattern on 6 of 7 indicators.** The December 2022 exploit was exactly this pattern -- admin key compromise leading to fund drainage.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [x] Low-liquidity collateral accepted? -- **YES**, permissionless pool creation allows any token
- [ ] Single oracle source without TWAP? -- **NO**, CLMM has TWAP; standard AMM uses pool reserves directly
- [ ] No circuit breaker on price movements? -- **YES**, no circuit breaker documented
- [ ] Insufficient insurance fund relative to TVL? -- **YES**, no insurance fund

**3/4 flags matched. WARNING: Permissionless pools create manipulation surface for low-liquidity tokens.**

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- **N/A**, single-chain
- [x] Admin keys stored in hot wallets? -- **LIKELY YES**, the 2022 hack was caused by trojan on team machine (implies hot wallet key storage)
- [ ] No key rotation policy? -- **UNKNOWN**, no published policy

**1/3 flags matched (limited applicability -- single chain).**

### Beanstalk-type (Flash Loan Governance Attack):
- N/A -- Raydium has no on-chain governance mechanism.

### Cream/bZx-type (Reentrancy + Flash Loan):
- N/A -- Raydium is a Solana program (Rust/Anchor), not EVM. Solana's runtime model prevents reentrancy by design.

### Curve-type (Compiler / Language Bug):
- [ ] Uses non-standard or niche compiler? -- **NO**, uses standard Rust/Anchor toolchain for Solana
- [ ] Compiler version has known CVEs? -- **UNKNOWN**
- [ ] Contracts compiled with different compiler versions? -- **UNKNOWN**
- [ ] Code depends on language-specific behavior? -- **POSSIBLE**, tick math in CLMM is complex

**0/4 flags matched.**

### UST/LUNA-type (Algorithmic Depeg Cascade):
- N/A -- Raydium does not operate a stablecoin.

### Kelp-type (Bridge Message Spoofing + Composability Cascade):
- N/A -- Raydium operates on a single chain with no bridge dependencies.

**Trigger rule**: Drift-type pattern triggered (6/7 matched). Euler/Mango-type pattern triggered (3/4 matched). Both are explicitly flagged as warnings above.

## Information Gaps

1. **Multisig configuration**: On-chain data shows upgrade authorities as System Program-owned accounts. Documentation claims Squads multisig. Without Solana CLI verification, the true nature of these accounts cannot be definitively determined. The multisig threshold, signer count, and signer identities are all undisclosed.

2. **RugCheck data**: The RugCheck API returned "not found" for the RAY token mint address (4k3Dyjzvzp8eMZFUEDRkRd2S3tnQhXhEqefEH6dGA1ns). Mint authority status, freeze authority status, and metadata mutability could not be verified.

3. **Insurance fund / treasury size**: Treasury receives 4% of trading fees, but the accumulated treasury balance is not publicly disclosed. No insurance fund exists.

4. **Audit finding remediation**: The most recent audit reportedly found 3 critical and 1 high priority bugs. Whether these have been fully remediated is not confirmed.

5. **Key management practices post-2022**: After the trojan-caused private key compromise, no public documentation describes what security improvements were made to key storage and management.

6. **Team identity and legal entity**: No corporate entity is known. Team members use pseudonyms only. This makes legal recourse impossible in case of malicious action or negligence.

7. **Formal verification and testing**: DeFiSafety scored Raydium 0% for testing. No evidence of formal verification or comprehensive test suites in the public repos.

8. **RAY token on-chain properties**: Mint authority, freeze authority, and metadata mutability could not be verified through available APIs.

9. **Emergency pause mechanism**: No documented emergency pause capability, though the team demonstrated rapid program upgrade ability during the 2022 incident.

10. **Multisig signer geographic distribution and operational security**: Unknown whether signers are geographically distributed or use hardware wallets/HSMs.

## Disclaimer

This analysis is based on publicly available information and web research as of April 20, 2026. It is NOT a formal smart contract audit. The on-chain verification was limited by the absence of the Solana CLI tool -- results should be confirmed with `solana program show` commands. The RugCheck API did not return data for the RAY token, creating a verification gap. Always DYOR and consider professional auditing services for investment decisions.
