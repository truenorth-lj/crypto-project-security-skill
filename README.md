# Crypto Project Security Skill

A Claude Code skill that performs comprehensive security audits on DeFi protocols. Systematically evaluates governance, oracle design, admin privileges, economic mechanisms, and historical risk factors to identify vulnerabilities before they are exploited.

## Background

This skill was built in response to the [Drift Protocol $285M hack](https://www.ccn.com/news/crypto/drift-protocol-285m-biggest-hack-2026-april-fools-day/) on April 1, 2026 -- where attackers combined fake token creation, Solana durable nonce abuse, and social engineering to drain the largest perpetual futures DEX on Solana in 12 minutes.

The hack was **not a smart contract bug**. It exploited governance architecture weaknesses (2/5 multisig with zero timelock, arbitrary oracle assignment, admin-controlled withdrawal limits) that were all detectable from publicly available information before the attack.

This skill automates that kind of pre-incident analysis.

## What It Does

Given a protocol name, the skill:

1. **Quick Triage** -- Pulls TVL data from DeFiLlama API, scans for immediate red flags (TVL collapse, no audits, closed-source code, anon team)
2. **Governance & Admin Analysis** -- Maps admin key powers, multisig config, timelock duration, upgrade mechanisms
3. **Oracle & Price Feed Analysis** -- Checks oracle providers, fallback mechanisms, collateral listing process, manipulation resistance
4. **Economic Mechanism Analysis** -- Evaluates liquidation design, insurance fund adequacy, withdrawal limits
5. **Smart Contract Security** -- Reviews audit history, bug bounty programs, battle testing, code openness
6. **Operational Security** -- Assesses team track record, incident response capability, external dependencies
7. **On-Chain Verification** -- Attempts to verify claims against actual on-chain state (Squads multisig, Etherscan, etc.)
8. **Generates Risk Report** -- Structured report with quantitative metrics, peer comparison, and cross-reference against known attack patterns

## Test Results

Validated against three protocols:

| Protocol | Type | TVL | Risk Rating | Key Finding |
|----------|------|-----|-------------|-------------|
| [**Drift Protocol** (pre-hack)](docs/examples/drift-protocol-pre-hack.md) | Top | $550M | **CRITICAL** | Successfully identified all 3 attack vectors before the hack |
| [**Aave**](docs/examples/aave-top-protocol.md) | Top | $23.6B | **LOW** | Confirmed robust DAO governance + dual timelock + 6yr track record |
| [**Zeta Markets**](docs/examples/zeta-markets-tail-protocol.md) | Tail | $0 | **HIGH** | Flagged no audits, closed-source, undisclosed multisig config |

The skill correctly distinguished high-risk from low-risk protocols and identified the specific Drift vulnerabilities that were later exploited.

## Installation

### As a Claude Code Skill

Copy the `SKILL.md` file into your project's Claude Code skills directory:

```bash
mkdir -p .claude/skills/defi-security-audit
cp SKILL.md .claude/skills/defi-security-audit/SKILL.md
```

### Usage

In Claude Code, use any of these trigger phrases:
- "audit defi [protocol name]"
- "analyze protocol [protocol name]"  
- "check security of [protocol name]"
- "is [protocol name] safe?"

## Attack Pattern Detection

The skill cross-references findings against three major DeFi exploit categories:

### Drift-type (Governance + Oracle + Social Engineering)
- Admin can list new collateral without timelock
- Admin can change oracle sources arbitrarily
- Admin can modify withdrawal limits
- Low multisig threshold (2/N with small N)
- Zero or short timelock on governance actions
- Pre-signed transaction risk (durable nonce on Solana)
- Social engineering surface area (anonymous multisig signers)

### Euler/Mango-type (Oracle + Economic Manipulation)
- Low-liquidity collateral accepted
- Single oracle source without TWAP
- No circuit breaker on price movements
- Insufficient insurance fund relative to TVL

### Ronin/Harmony-type (Bridge + Key Compromise)
- Bridge dependency with centralized validators
- Admin keys stored in hot wallets
- No key rotation policy

## Quantitative Metrics

The skill computes comparable metrics across protocols:

| Metric | Healthy | Concerning | Critical |
|--------|---------|------------|----------|
| Insurance Fund / TVL | >5% | 1-5% | <1% |
| Timelock Duration | >48h | 1-48h | 0h |
| Multisig Threshold | >3/5 | 2/5 | 1/N or no multisig |
| Audit Coverage | Multiple recent | 1 old audit | None |

## Limitations

- This is a **research tool**, not a formal smart contract audit
- Analysis is based on publicly available information -- protocols may have undisclosed security measures (or vulnerabilities)
- Closed-source protocols receive limited analysis by design
- On-chain verification depends on block explorer availability and contract transparency
- DeFi protocols change frequently -- audit results have a short shelf life

## DeFiLlama API Reference

The skill uses these endpoints for data gathering:

```
Protocol info:  https://api.llama.fi/protocol/{slug}
All protocols:  https://api.llama.fi/protocols
Yields:         https://yields.llama.fi/pools
```

## License

MIT
