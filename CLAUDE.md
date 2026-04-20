# Crypto Project Security Skill

## Overview

This repo contains a Claude Code skill (`SKILL.md`) for performing comprehensive DeFi protocol security audits. It evaluates governance architecture, oracle design, admin privileges, economic mechanisms, and operational security.

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
mkdir -p .claude/skills/defi-security-audit
cp SKILL.md .claude/skills/defi-security-audit/SKILL.md
```

## Trigger Phrases

- `audit defi [protocol]`
- `analyze protocol [protocol]`
- `check security of [protocol]`
- `defi risk [protocol]`
- `is [protocol] safe?`

## Key Design Decisions

- **Governance-first approach**: Built in response to the Drift Protocol hack, which exploited governance architecture (not code bugs). The skill prioritizes admin key analysis, timelock verification, and multisig configuration.
- **Source code review**: Targeted review of open-source contracts — verifies governance claims from docs against actual code, inventories admin functions, scans for high-impact vulnerability patterns (reentrancy, oracle manipulation, flash loan surfaces, proxy upgrade risks). Not a full line-by-line audit, but catches discrepancies between what teams claim and what the code does.
- **Quantitative metrics**: Includes computable ratios (Insurance/TVL, Audit Coverage Score, etc.) to reduce subjectivity and enable cross-protocol comparison.
- **Attack pattern matching**: Cross-references findings against three exploit categories (Drift-type, Euler/Mango-type, Ronin/Harmony-type) with specific indicator checklists.
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
- Always include disclaimer about this not being a formal audit
