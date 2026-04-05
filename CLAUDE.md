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
│   └── goplus-check.sh    # GoPlus Security API helper script (token, address, dApp checks)
└── docs/
    ├── methodology.md     # Audit framework design principles and methodology
    └── examples/          # Example audit reports from validation testing
        ├── drift-protocol-pre-hack.md   # CRITICAL -- validated against actual $285M hack
        ├── aave-top-protocol.md         # LOW -- gold standard lending protocol
        └── zeta-markets-tail-protocol.md # HIGH -- defunct protocol with transparency gaps
```

## Skill Installation

To use this skill in any project, copy `SKILL.md` into the target project:

```bash
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

- **Governance-first approach**: Built in response to the Drift Protocol hack, which exploited governance architecture (not code bugs). The skill prioritizes admin key analysis, timelock verification, and multisig configuration over traditional code review.
- **Quantitative metrics**: Includes computable ratios (Insurance/TVL, Audit Coverage Score, etc.) to reduce subjectivity and enable cross-protocol comparison.
- **Attack pattern matching**: Cross-references findings against three exploit categories (Drift-type, Euler/Mango-type, Ronin/Harmony-type) with specific indicator checklists.
- **Information gap reporting**: Explicitly lists what could NOT be determined -- absence of public information is itself a risk signal.
- **DeFiLlama API integration**: Uses `curl` against DeFiLlama endpoints for TVL data, audit counts, and protocol metadata.
- **GoPlus Security API integration**: Automated token-level contract scanning (honeypot detection, owner privilege analysis, trading restrictions, holder concentration, malicious address checks) via free API. Complements the governance-first approach by covering contract-level risks that manual research may miss. Helper script at `scripts/goplus-check.sh`.

## Adding New Example Reports

When adding new audit reports to `docs/examples/`:

1. Follow the report template defined in `SKILL.md` (Step 8)
2. Use kebab-case filename: `{protocol-name}-{context}.md`
3. Update the test results table in `README.md` with a link to the new report
4. Include all sections: Overview, Quantitative Metrics, Risk Summary, Detailed Findings, Hack Pattern Check, Information Gaps

## Style

- All content in English
- No emojis
- Risk ratings: LOW / MEDIUM / HIGH / CRITICAL (no other scales)
- Mark unverified claims as "UNVERIFIED"
- Always include disclaimer about this not being a formal audit
