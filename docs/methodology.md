# Methodology

## Design Principles

This skill was designed around a core insight from the Drift Protocol hack: **the most dangerous DeFi vulnerabilities are often not in the code, but in the governance architecture surrounding it.**

Traditional smart contract audits focus on code correctness -- reentrancy bugs, integer overflows, logic errors. But the Drift hack (and increasingly, other major exploits) exploited:
- Overpowered admin keys
- Missing timelocks
- Social engineering of multisig signers
- Abuse of legitimate platform features (Solana durable nonces)

This skill focuses on **systemic risk analysis** rather than line-by-line code review.

## Audit Framework

### 1. Red Flag Triage (Step 0)

Quick quantitative scan before deep analysis. Any single red flag escalates the protocol to priority review:

| Red Flag | Why It Matters |
|----------|---------------|
| TVL = $0 or >50% drop in 30d | Protocol may be compromised, abandoned, or in distress |
| No audits listed | No independent code review |
| Age < 6 months with TVL > $50M | Insufficient battle testing for the capital at risk |
| Anonymous team | Reduced accountability, higher social engineering risk |
| Closed-source contracts | Cannot verify security claims |

### 2. Six-Pillar Assessment

Each pillar receives an independent risk rating (LOW / MEDIUM / HIGH / CRITICAL):

1. **Governance & Admin** -- Who holds the keys, and what can they do? Includes timelock bypass detection and token concentration / whale risk for on-chain governance.
2. **Oracle & Price Feeds** -- Can prices be manipulated or fabricated?
3. **Economic Mechanism** -- Does the math hold under stress?
4. **Smart Contract** -- Has the code been reviewed and tested?
5. **Cross-Chain & Bridge** -- Are multi-chain deployments and bridge dependencies secure? (N/A for single-chain protocols with no bridge dependencies.)
6. **Operational Security** -- Is the team trustworthy and prepared?

### 3. Quantitative Metrics

Subjective risk ratings are supplemented with comparable numbers:

| Metric | Formula | Risk Thresholds |
|--------|---------|-----------------|
| Insurance/TVL Ratio | Insurance Fund Balance / Total TVL | >5% = LOW, 1-5% = MEDIUM, <1% = HIGH |
| Audit Coverage Score | sum(1.0 if <1yr, 0.5 if 1-2yr, 0.25 if >2yr) | >=3.0 = LOW, 1.5-2.99 = MEDIUM, <1.5 = HIGH |
| Timelock Duration | Hours of delay on admin actions | >48h = LOW, 24-48h = MEDIUM, <24h = HIGH |
| Multisig Strength | Threshold / Total Signers | >0.6 = LOW, 0.4-0.6 = MEDIUM, <0.4 = HIGH |
| Quick Triage Score | 100 minus penalty per red flag (see SKILL.md) | 80-100 = LOW, 50-79 = MEDIUM, 20-49 = HIGH, 0-19 = CRITICAL |

### 4. Peer Comparison

Risk ratings are meaningless in isolation. A 24-hour timelock is excellent if peers average 0 hours, but concerning if peers average 7 days. Every audit includes a comparison table against 2-3 protocols of the same type and chain.

### 5. Timelock Bypass Detection

A timelock is only as strong as its bypass. The audit explicitly checks:
- Whether any role (emergency multisig, security council, guardian) can bypass the timelock
- What powers the bypass role has (pause-only = LOW risk; full upgrade/drain = HIGH risk)
- Whether the bypass role is itself behind a multisig with a reasonable threshold

### 6. Historical Attack Pattern Matching

Cross-reference findings against eight major exploit categories:

- **Drift-type**: Governance hijack + oracle manipulation + social engineering
- **Euler/Mango-type**: Economic manipulation via low-liquidity collateral
- **Ronin/Harmony-type**: Bridge validator compromise + key theft
- **Beanstalk-type**: Flash loan governance attack (acquire voting power + propose + execute)
- **Cream/bZx-type**: Reentrancy + flash loan (rebasing tokens, cross-contract callbacks)
- **Curve-type**: Compiler or language-level bugs (Vyper reentrancy, compiler CVEs)
- **UST/LUNA-type**: Algorithmic depeg cascade (reflexive collateral, redemption spirals)

Each pattern has a checklist of specific indicators. Matching 3+ indicators in any category triggers an explicit warning.

### 7. Information Gap Reporting

What you **cannot** find is often more important than what you can. The audit explicitly lists unanswered questions, because:
- Closed-source contracts cannot be verified
- Undisclosed multisig configurations could be 1/1
- Missing documentation may indicate missing security measures
- "UNVERIFIED" is itself a risk signal

## Limitations

1. **Not a code audit** -- This skill does not read or analyze smart contract source code line by line. It evaluates the security architecture surrounding the code.

2. **Public information only** -- Analysis is limited to what can be found via web search, DeFiLlama API, block explorers, and official documentation. Protocols may have undisclosed security measures.

3. **Point-in-time snapshot** -- DeFi protocols change frequently. Governance proposals, contract upgrades, and parameter changes can alter the security posture at any time.

4. **No exploit development** -- The skill identifies potential attack surfaces but does not develop proof-of-concept exploits or test actual contract behavior.

5. **Bias toward transparency** -- The framework inherently penalizes closed-source, undocumented, or anonymous projects. This is intentional -- opacity increases risk -- but means some secure-but-private protocols may receive higher risk ratings than warranted.

## Data Sources

| Source | Used For |
|--------|----------|
| DeFiLlama API | TVL, TVL history, audit count, protocol metadata |
| Web search | News, incident reports, team information |
| Official docs | Architecture, governance, oracle design |
| Block explorers | On-chain verification of multisig, timelock, admin transactions |
| CertiK Skynet | Security scores where available |
| Immunefi | Bug bounty program details |
| GitHub | Code openness, recent activity, audit reports |
