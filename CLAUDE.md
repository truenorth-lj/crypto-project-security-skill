# Crypto Project Security Skill

## Overview

This repo contains a Claude Code skill (`SKILL.md`) that performs structured **risk analysis** on DeFi protocols across three dimensions: **smart contract**, **off-chain** (governance, team, operations), and **track record** (historical incidents, battle-testing, response capability). It is a research tool that surfaces risk signals — it is **not a formal smart contract audit**.

## Repo Structure

```
.
├── CLAUDE.md              # This file -- project guide for Claude Code
├── README.md              # Public-facing documentation
├── SKILL.md               # The Claude Code skill definition (copy to .claude/skills/)
├── LICENSE                # MIT
├── scripts/
│   ├── goplus-check.sh    # GoPlus Security API helper script (token, address, dApp checks)
│   └── onchain-check.sh   # On-chain verification (Safe multisig, Etherscan, Solana RPC)
└── docs/
    ├── methodology.md     # Audit framework design principles and methodology
    ├── audit-reports.md   # Full index of all 79 audit reports (sortable by risk/TVL)
    └── examples/          # 79 audit reports covering DeFiLlama top 100 protocols + all major perp exchanges
        ├── (12 CRITICAL, 22 HIGH, 38 MEDIUM, 7 LOW)
        └── See docs/audit-reports.md for the full index
```

## Skill Installation

Install via skills.sh, ClawHub, or manually:

```bash
# Via skills.sh (Vercel)
npx skills add truenorth-lj/crypto-project-security-skill

# Via ClawHub (OpenClaw)
clawhub install truenorth-lj/crypto-project-security-skill

# Manual
mkdir -p .claude/skills/defi-risk-analysis
cp SKILL.md .claude/skills/defi-risk-analysis/SKILL.md
```

## Trigger Phrases

- `risk analysis of [protocol]`
- `analyze protocol [protocol]`
- `check security of [protocol]`
- `defi risk [protocol]`
- `is [protocol] safe?`
- `audit defi [protocol]` (legacy trigger)

## Key Design Decisions

- **Three-dimension risk model**: Risk is grouped into Smart Contract / Off-Chain / Track Record. Each dimension has sub-categories with independent ratings; the dimension is MAX of sub-categories with weighting rules (Governance 2x in Off-Chain, Cross-Chain 2x in Smart Contract for 5+ chain deployments). Overall risk aggregates across dimensions.
- **"Risk analysis", not "audit"**: This skill produces a *risk analysis* — it surfaces signals from public data and on-chain state. Formal audits require licensed firms doing line-by-line review. The distinction is drilled into terminology, report titles, and the disclaimer.
- **Governance-first approach**: Built in response to the Drift Protocol hack, which exploited governance architecture (not code bugs). The skill prioritizes admin key analysis, timelock verification, and multisig configuration.
- **Multi-source audit discovery**: Step 1.5 explicitly checks DeFiLlama payload → protocol docs paths (`/audits`, `/resources/audits`, `/security`) → GitHub `/audits` folder → web search fallback. Missing an audit (e.g., Apyx at `docs.apyx.fi/resources/audits`) is a common failure mode when relying solely on web search.
- **Source code review (Step 5.4)**: Targeted review of open-source contracts — verifies governance claims from docs against actual code, inventories admin functions, scans for high-impact vulnerability patterns (reentrancy, oracle manipulation, flash loan surfaces, proxy upgrade risks). Not a full line-by-line audit, but catches discrepancies between what teams claim and what the code does.
- **Audited vs Deployed drift (Step 5.5)**: Cross-references what was audited against what is running. Extracts audit commit hashes, detects post-audit proxy upgrades via `contract-age` subcommand, and (when commits are cited) supports source-level diff. A commonly ignored risk.
- **Quantitative metrics**: Includes computable ratios (Insurance/TVL, Audit Coverage Score, etc.) to reduce subjectivity and enable cross-protocol comparison.
- **Attack pattern matching**: Cross-references findings against exploit categories (Drift-type, Euler/Mango-type, Ronin/Harmony-type, Kelp-type, Beanstalk-type, Cream/bZx-type, Curve-type, UST/LUNA-type) with specific indicator checklists.
- **Information gap reporting**: Explicitly lists what could NOT be determined -- absence of public information is itself a risk signal.
- **DeFiLlama API integration**: Uses `curl` against DeFiLlama endpoints for TVL data, audit counts, and protocol metadata.
- **GoPlus Security API integration**: Automated token-level contract scanning (honeypot detection, owner privilege analysis, trading restrictions, holder concentration, malicious address checks) via free API. Complements the governance-first approach by covering contract-level risks that manual research may miss. Helper script at `scripts/goplus-check.sh`.

## Adding New Example Reports

When adding new audit reports to `docs/examples/`:

1. Follow the report template defined in `SKILL.md` (Step 9)
2. Use kebab-case filename: `{protocol-name}-{context}.md`
3. **Always update `README.md`** after adding a new report:
   - Add a row to the "Test Results" table with: protocol name (linked to report), type, TVL, risk rating, GoPlus result, audit date, and key finding
   - Update the repo structure tree in CLAUDE.md if needed
   - Update the "Validated against N protocols" count
4. Include all sections: Overview, Quantitative Metrics, Risk Summary, Detailed Findings, Hack Pattern Check, Information Gaps

## Style

- All content in English
- No emojis
- Risk ratings: LOW / MEDIUM / HIGH / CRITICAL (no other scales)
- Mark unverified claims as "UNVERIFIED"
- Always include disclaimer about this being a risk analysis, NOT a formal audit
- Use "risk analysis" (not "audit") for this skill's output; reserve "audit" for third-party firm reports
