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

## Audit Reports

Validated against 79 protocols spanning DeFiLlama's top 100 by TVL plus all major perp exchanges (20 covered). Full index with all reports: **[docs/audit-reports.md](docs/audit-reports.md)**

**Risk distribution:** 7 LOW | 38 MEDIUM | 22 HIGH | 12 CRITICAL

### Top Protocols by TVL

| Protocol | Type | TVL | Risk | Key Finding |
|----------|------|-----|------|-------------|
| [**Aave**](docs/examples/aave-top-protocol.md) | Lending | $23.6B | **LOW** | Gold standard; dual timelock + 6yr track record |
| [**Lido**](docs/examples/lido-liquid-staking.md) | Liquid Staking | $19.0B | **LOW** | Industry-leading staking with mature security |
| [**SSV Network**](docs/examples/ssv-network-staking.md) | DVT/Staking | $15.0B | **MEDIUM** | No insurance for $15B; data breach; 4/6 multisig |
| [**EigenLayer**](docs/examples/eigenlayer-restaking.md) | Restaking | $8.26B | **MEDIUM** | Strong governance; novel systemic slashing risk |
| [**WBTC**](docs/examples/wbtc-wrapped-bitcoin.md) | Wrapped BTC | $7.8B | **MEDIUM** | 2-of-3 custody; Justin Sun/BiT Global controversy |
| [**Morpho**](docs/examples/morpho-lending.md) | Lending | $7.06B | **LOW** | Immutable core (~650 LOC); 12+ audits; no admin keys |
| [**Ethena**](docs/examples/ethena-stablecoin.md) | Synthetic Dollar | $6.64B | **MEDIUM** | Strong contracts; custodial/CEX counterparty risk |
| [**Sky**](docs/examples/sky-lending-cdp.md) | CDP/Stablecoin | $6.58B | **LOW** | Pioneer CDP; strongest governance track record |
| [**Hyperliquid**](docs/examples/hyperliquid-perps.md) | Perps | $4.87B | **HIGH** | CoreWriter godmode; 4-validator bridge; closed-source L1 |
| [**EtherFi**](docs/examples/etherfi-liquid-restaking.md) | Liquid Restaking | $4.8B | **MEDIUM** | Good audits; governance gaps; TVL decline |
| [**Ondo**](docs/examples/ondo-rwa.md) | RWA/Treasuries | $3.51B | **MEDIUM** | 20+ audits; centralized admin; 59% team token |
| [**Uniswap**](docs/examples/uniswap-dex.md) | DEX | $3.09B | **LOW** | No admin keys; 48h timelock; $15.5M bug bounty |

### Protocols Rated HIGH / CRITICAL -- Exercise Caution

| Protocol | Type | TVL | Risk | Key Finding |
|----------|------|-----|------|-------------|
| [**Kelp DAO**](docs/examples/kelp-post-hack-20260419.md) | Liquid Restaking | $1.3B | **CRITICAL** | $292M exploited via LayerZero bridge spoofing + Aave bad debt cascade (2026-04-18). [Pre-hack audit](docs/examples/kelp-liquid-restaking.md) rated MEDIUM |
| [**Drift Protocol**](docs/examples/drift-protocol-pre-hack.md) | Perps | $550M | **CRITICAL** | Identified all 3 attack vectors before the $285M hack |
| [**Notional Finance**](docs/examples/notional-lending.md) | Lending | $0 | **CRITICAL** | Defunct after Balancer exploit; 56% lender haircut |
| [**Lybra Finance**](docs/examples/lybra-stablecoin.md) | Stablecoin | $337K | **CRITICAL** | Abandoned; 99.9% TVL decline; website dead |
| [**JustLend**](docs/examples/justlend-lending.md) | Lending | $3.3B | **HIGH** | Justin Sun centralization; stale audits; opaque governance |
| [**Grove Finance**](docs/examples/grove-finance-allocator.md) | Allocator | $2.87B | **HIGH** | Undisclosed governance; parent DNS hijack; 10mo old |
| [**Falcon Finance**](docs/examples/falcon-finance-basis.md) | Basis Trading | $1.63B | **HIGH** | DWF Labs affiliation; prior depeg; 0.6% insurance/TVL |
| [**USDD**](docs/examples/usdd-stablecoin.md) | Stablecoin | $1.29B | **HIGH** | Justin Sun unilateral control; reflexive TRX collateral |
| [**Radiant Capital**](docs/examples/radiant-lending.md) | Lending | $1.72M | **HIGH** | $50M+ hack by DPRK; 98% TVL collapse |
| [**SushiSwap**](docs/examples/sushiswap-dex.md) | DEX | $41M | **HIGH** | Governance instability; unaudited routers; 99.5% decline |
| [**Alpaca Finance**](docs/examples/alpaca-leverage.md) | Leverage | $41.4M | **HIGH** | Protocol shutting down; withdraw immediately |
| [**Bancor**](docs/examples/bancor-dex.md) | DEX | $27M | **HIGH** | IL protection collapse; 99% TVL decline; litigation |
| [**Camelot**](docs/examples/camelot-dex.md) | DEX | $24.8M | **HIGH** | 2/3 multisig; no timelock; pseudonymous team |
| [**Aura Finance**](docs/examples/aura-yield.md) | Yield | $96.9M | **HIGH** | Balancer exploit threatens core mechanism |
| [**Resolv**](docs/examples/resolv-stablecoin.md) | Stablecoin | $57.6M | **CRITICAL** | Exploited March 2026 ($25M); USR peg NOT restored; protocol paused |
| [**Vertex**](docs/examples/vertex-perps.md) | Perps | $0 | **CRITICAL** | Shut down Aug 2025; DAO dissolved; team acquired by Ink Foundation |
| [**Paradex**](docs/examples/paradex-perps.md) | Perps | $46.9M | **CRITICAL** | 2/5 multisig + zero timelock; can drain all bridged USDC |
| [**Raydium**](docs/examples/raydium-dex.md) | DEX | $1B+ | **HIGH** | Upgrade authority appears EOA; zero timelock; 2022 key compromise |
| [**Aster**](docs/examples/aster-perps.md) | Perps | $538M | **HIGH** | Anonymous team; suspected wash trading; DeFiLlama delisted once |
| [**Lighter**](docs/examples/lighter-perps.md) | Perps | $502M | **HIGH** | Timelock bypassable to 0s; centralized sequencer outage |
| [**edgeX**](docs/examples/edgex-perps.md) | Perps | $190M | **HIGH** | No multisig/timelock disclosed; $10K bug bounty |
| [**Extended**](docs/examples/extended-perps.md) | Perps | $174.7M | **HIGH** | Doxxed team but unverified multisig; no bug bounty |
| [**Ostium**](docs/examples/ostium-perps.md) | Perps/RWA | $144M | **HIGH** | 6+ audits but governance fully opaque |
| [**ApeX Omni**](docs/examples/apex-omni-perps.md) | Perps | $125M | **HIGH** | Zero governance transparency; 0 DeFiLlama audits |
| [**Usual**](docs/examples/usual-stablecoin.md) | Stablecoin | $101M | **HIGH** | USD0++ depegged; TVL -94.6%; 75.8% token concentration |
| [**GRVT**](docs/examples/grvt-perps.md) | Perps | $63.5M | **HIGH** | 2/3 multisig + 0s timelock; validium risk |
| [**Infrared**](docs/examples/infrared-berachain.md) | Liquid Staking/PoL | $52M | **HIGH** | 24 audits but governance opaque; TVL -97% |
| [**Drift (post-hack)**](docs/examples/drift-protocol-post-hack-20260420.md) | Perps | $241M | **CRITICAL** | All 7/7 pre-hack flags exploited; $148M pledged vs $295M losses |
| [**Variational Omni**](docs/examples/variational-omni-perps.md) | Perps | $0 | **CRITICAL** | $0 TVL; closed-source; strong team but zero on-chain transparency |
| [**Antarctic**](docs/examples/antarctic-perps.md) | Perps | $10M | **CRITICAL** | 0/100 data confidence; fully closed source; zero audits |
| [**GMX**](docs/examples/gmx-derivatives.md) | Derivatives | $346M | **HIGH** | GoPlus hidden_owner; 7-chain Kelp-type bridge risk |
| [**Gains Network**](docs/examples/gains-network-perps.md) | Perps | $28M | **HIGH** | GoPlus hidden_owner persists; bug bounty halved |
| [**StandX**](docs/examples/standx-perps.md) | Perps | $52M | **HIGH** | Perps engine zero audits; DUSD proxy no timelock |

The skill correctly distinguished high-risk from low-risk protocols and identified the specific Drift vulnerabilities that were later exploited.

## Installation

### Via [skills.sh](https://skills.sh/truenorth-lj/crypto-project-security-skill/defi-security-audit) (Vercel)

```bash
npx skills add truenorth-lj/crypto-project-security-skill
```

### Via [ClawHub](https://clawhub.ai/truenorth-lj/defi-security-audit) (OpenClaw)

```bash
clawhub install truenorth-lj/crypto-project-security-skill
```

### Manual

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

The skill cross-references findings against eight major DeFi exploit categories (the full list includes Beanstalk-type, Cream/bZx-type, Curve-type, UST/LUNA-type in `SKILL.md`). Key patterns:

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

### Kelp-type (Bridge Message Spoofing + Composability Cascade) -- NEW
- Bridge message validation relies on single messaging layer
- DVN/verifier configuration not publicly documented
- No rate limiting on bridge-released token volume
- Bridged token accepted as collateral on lending protocols (Aave, Compound, Euler)
- Token deployed on 5+ chains via same bridge provider
- Stolen/unbacked tokens used as collateral → borrow real assets → bad debt cascade

> In the Kelp hack ($292M, April 2026), the attacker forged a LayerZero cross-chain message to drain rsETH, then deposited unbacked rsETH on Aave V3 as collateral to borrow WETH, creating $290M+ in bad debt across multiple lending protocols.

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
