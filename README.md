# Crypto Project Security Skill

A Claude Code skill that performs comprehensive security audits on DeFi protocols. Systematically evaluates governance, oracle design, admin privileges, economic mechanisms, and historical risk factors to identify vulnerabilities before they are exploited.

## Background

This skill was built in response to the [Drift Protocol $285M hack](https://www.ccn.com/news/crypto/drift-protocol-285m-biggest-hack-2026-april-fools-day/) on April 1, 2026 -- where attackers combined fake token creation, Solana durable nonce abuse, and social engineering to drain the largest perpetual futures DEX on Solana in 12 minutes.

The hack was **not a smart contract bug**. It exploited governance architecture weaknesses (2/5 multisig with zero timelock, arbitrary oracle assignment, admin-controlled withdrawal limits) that were all detectable from publicly available information before the attack.

This skill automates that kind of pre-incident analysis.

## What It Does

Given a protocol name, the skill:

1. **Quick Triage** -- Pulls TVL data from DeFiLlama API and token contract risk flags from GoPlus Security API, scans for immediate red flags (TVL collapse, no audits, honeypot, hidden owner, closed-source code, anon team)
2. **Governance & Admin Analysis** -- Maps admin key powers, multisig config, timelock duration, upgrade mechanisms
3. **Oracle & Price Feed Analysis** -- Checks oracle providers, fallback mechanisms, collateral listing process, manipulation resistance
4. **Economic Mechanism Analysis** -- Evaluates liquidation design, insurance fund adequacy, withdrawal limits
5. **Smart Contract Security** -- Reviews audit history, bug bounty programs, battle testing, code openness
6. **Operational Security** -- Assesses team track record, incident response capability, external dependencies
7. **On-Chain Verification** -- Attempts to verify claims against actual on-chain state (Squads multisig, Etherscan, etc.)
8. **Generates Risk Report** -- Structured report with quantitative metrics, peer comparison, and cross-reference against known attack patterns

## Test Results

Validated against three protocols:

| Protocol | Type | TVL | Risk Rating | Audit Date | Key Finding |
|----------|------|-----|-------------|------------|-------------|
| Protocol | Type | TVL | Risk Rating | GoPlus | Audit Date | Key Finding |
|----------|------|-----|-------------|--------|------------|-------------|
| [**Drift Protocol** (pre-hack)](docs/examples/drift-protocol-pre-hack.md) | Top | $550M | **CRITICAL** | N/A (Solana) | 2026-03 (hypothetical) | Successfully identified all 3 attack vectors before the hack |
| [**Aave**](docs/examples/aave-top-protocol.md) | Top | $23.6B | **LOW** | LOW (0 HIGH / 1 MED) | 2026-04-05 | Confirmed robust DAO governance + dual timelock + 6yr track record |
| [**Zeta Markets**](docs/examples/zeta-markets-tail-protocol.md) | Tail | $0 | **HIGH** | N/A (Solana) | 2026-04-05 | Flagged no audits, closed-source, undisclosed multisig config |

The skill correctly distinguished high-risk from low-risk protocols and identified the specific Drift vulnerabilities that were later exploited.

**GoPlus integration note:** Drift and Zeta are Solana-native protocols; GoPlus token security API supports EVM chains only. For Aave (EVM), GoPlus confirmed the token contract is clean -- the only flag is the proxy pattern, which is expected for a DAO-governed upgradeable protocol.

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

## This Skill vs. GoPlus Security

This skill integrates GoPlus Security API data, but the two serve fundamentally different purposes:

| Dimension | This Skill | GoPlus Security |
|-----------|-----------|-----------------|
| **Scope** | Full protocol architecture | Individual token/contract |
| **Method** | Research-driven manual analysis + API data | Automated static + dynamic analysis |
| **Speed** | Minutes per audit | Sub-second API response |
| **Governance analysis** | Core focus (multisig, timelock, admin powers) | Not covered |
| **Oracle risk** | Evaluated (dependency, manipulation resistance) | Not covered |
| **Economic modeling** | Insurance/TVL, liquidation design, bad debt | Not covered |
| **Honeypot detection** | Not covered | Strong (simulation-based) |
| **Malicious address flags** | Not covered | 20+ flags (phishing, sanctions, etc.) |
| **Trading restrictions** | Not covered | Buy/sell tax, pause, blacklist |
| **Chain support** | Any chain (manual research) | 40+ EVM chains (no Solana) |
| **Cost** | Free (Claude Code + public APIs) | Free (no API key required) |
| **Would catch Drift hack** | Yes (designed for this) | No (governance, not token-level) |
| **Would catch honeypot scam** | No (not designed for this) | Yes (designed for this) |

**Key insight:** GoPlus answers "is this token contract safe to interact with?" -- the kind of check a wallet or DEX needs to do millions of times per day. This skill answers "is this protocol's overall design sound?" -- the kind of analysis an investor or researcher does before committing capital. They are complementary: GoPlus catches contract-level scams fast; this skill catches systemic governance and economic risks that automated tools miss.

## Limitations

- This is a **research tool**, not a formal smart contract audit
- Analysis is based on publicly available information -- protocols may have undisclosed security measures (or vulnerabilities)
- Closed-source protocols receive limited analysis by design
- On-chain verification depends on block explorer availability and contract transparency
- DeFi protocols change frequently -- audit results have a short shelf life

## Data Sources

### DeFiLlama API

TVL, audit counts, and protocol metadata:

```
Protocol info:  https://api.llama.fi/protocol/{slug}
All protocols:  https://api.llama.fi/protocols
Yields:         https://yields.llama.fi/pools
```

### GoPlus Security API

Automated token and address security scanning across 40+ EVM chains. Free, no API key required.

```
Base URL:       https://api.gopluslabs.io/api/v1
Token check:    /token_security/{chain_id}?contract_addresses={addr}
Address check:  /address_security/{addr}?chain_id={chain_id}
Approval risk:  /approval_security/{chain_id}?contract_addresses={addr}
dApp check:     /dapp_security?url={url}
```

GoPlus provides automated detection of:
- **Honeypot tokens** -- simulates buy/sell to verify tokens can actually be sold
- **Owner privilege abuse** -- hidden ownership, balance modification, self-destruct
- **Trading restrictions** -- buy/sell tax, slippage modification, transfer pause, blacklist
- **Holder concentration** -- top holder percentages, LP lock status
- **Malicious addresses** -- phishing, sanctions, cybercrime, money laundering flags
- **Creator history** -- whether the deployer has created honeypots before

A helper script is included at `scripts/goplus-check.sh` for quick command-line lookups:

```bash
# Token security check (e.g., USDT on Ethereum)
./scripts/goplus-check.sh token 1 0xdac17f958d2ee523a2206206994597c13d831ec7

# Malicious address check
./scripts/goplus-check.sh address 0x1234...abcd

# dApp security check
./scripts/goplus-check.sh dapp https://app.uniswap.org
```

**Chain IDs**: 1=Ethereum, 56=BSC, 137=Polygon, 42161=Arbitrum, 10=Optimism, 43114=Avalanche, 8453=Base

> **Note**: GoPlus covers token-level contract risks (honeypot, owner powers, trading restrictions). It does NOT evaluate protocol-level governance architecture, oracle design, or economic mechanisms -- those remain covered by the skill's manual analysis workflow. The two approaches are complementary.

## License

MIT
