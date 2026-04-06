# DeFi Security Audit: Morpho

**Audit Date:** April 6, 2026
**Protocol:** Morpho -- Permissionless lending infrastructure (Morpho Blue + MetaMorpho Vaults)

## Overview
- Protocol: Morpho (Morpho Blue V1 + MetaMorpho Vaults V2)
- Chain: Ethereum, Base, Hyperliquid L1, Katana, Monad, Arbitrum, + 28 others (34 total)
- Type: Lending / Borrowing (permissionless market creation)
- TVL: ~$7.06B (supply-side); ~$8.06B borrowed
- TVL Trend: +1.3% / +6.5% / +8.1% (7d / 30d / 90d)
- Launch Date: January 2024 (Morpho Blue); Morpho Optimizers launched 2022
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: morpho-org)

## Quick Triage Score: 82/100

Starting at 100, deductions applied mechanically:

- MEDIUM: GoPlus: is_proxy = 1 (token contract is upgradeable proxy) -- however, the core Morpho Blue lending contract is immutable; this flag applies only to the MORPHO token contract (-8)
- LOW: Undisclosed multisig signer identities (not all 9 signers are publicly doxxed with full identity) (-5)
- LOW: Insurance fund / TVL -- no protocol-level insurance fund; bad debt is socialized to lenders in affected markets (-5)

**Score: 82 (LOW risk)**

No CRITICAL or HIGH triage flags triggered. TVL is healthy and growing. Protocol has 12+ audits. Doxxed team. Open-source contracts. 5/9 multisig governance. Core lending contract is immutable with no admin keys.

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | 0% (no protocol insurance fund) | 1-5% (Aave ~2%) | HIGH |
| Audit Coverage Score | ~5.5 (12 audits; ~4 within 2 yrs, others older) | 1-3 avg | LOW risk |
| Governance Decentralization | Snapshot DAO + 5/9 multisig | Aave 6/10, Compound 4/6 | LOW risk |
| Timelock Duration | Per-vault configurable; 2-week minimum for timelock reduction | 24-48h avg | LOW risk |
| Multisig Threshold | 5/9 (governance) | 3/5 avg | LOW risk |
| GoPlus Risk Flags | 0 HIGH / 1 MED | -- | LOW risk |

## GoPlus Token Security (MORPHO on Ethereum)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | -- |
| Open Source | Yes (1) | -- |
| Proxy | Yes (1) | MEDIUM |
| Mintable | Not flagged | -- |
| Owner Can Change Balance | Not flagged | -- |
| Hidden Owner | Not flagged | -- |
| Selfdestruct | Not flagged | -- |
| Transfer Pausable | Not flagged | -- |
| Blacklist | Not flagged | -- |
| Slippage Modifiable | Not flagged | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 19,076 | -- |
| Trust List | Not flagged | -- |
| Creator Honeypot History | No (0) | -- |

GoPlus assessment: **LOW RISK**. The only flag is the proxy (upgradeable) pattern on the MORPHO token contract, which is expected -- token upgrades are governed by the Morpho DAO via 5/9 multisig. No honeypot, no hidden owner, no tax, no trading restrictions. The top holder (contract at 0x9d03...5123) holds ~57.9% of supply, which is likely the governance treasury/DAO contract. Creator balance is 0.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | **LOW** | Immutable core; 5/9 multisig for limited governance powers | Partial |
| Oracle & Price Feeds | **MEDIUM** | Oracle-agnostic design shifts risk to market creators; past oracle misconfiguration exploit ($230K) | Partial |
| Economic Mechanism | **MEDIUM** | No protocol insurance fund; bad debt socialized to lenders per-market | Partial |
| Smart Contract | **LOW** | 12 audits, formal verification, $2.5M bug bounty, immutable core (~650 LOC) | Y |
| Token Contract (GoPlus) | **LOW** | Proxy token (DAO-governed); no honeypot, no hidden owner, no tax | Y |
| Cross-Chain & Bridge | **MEDIUM** | 34 chains; independent deployments but LayerZero for token bridging | Partial |
| Operational Security | **LOW** | Doxxed founders, strong track record, active incident response | Y |
| **Overall Risk** | **LOW** | **Strong security posture with immutable core; oracle and insurance gaps are primary concerns** | |

## Detailed Findings

### 1. Governance & Admin Key -- LOW

**Immutable Core Contract**: Morpho Blue's core lending contract is immutable with no admin keys, no proxy pattern, and no upgrade mechanism. This is a fundamental design choice that eliminates the most dangerous class of admin key attacks. The contract is approximately 650 lines of Solidity, deliberately minimal to reduce attack surface.

**Limited Governance Powers**: The Morpho DAO (via MORPHO token holders on Snapshot) controls only:
- MORPHO tokens in the governance treasury (~57.9% of supply held by DAO contract)
- Ownership of the upgradeable MORPHO token contract
- Activating/adjusting the fee switch (capped at 25% of borrower interest)
- Setting the fee recipient address
- Whitelisting new LLTVs (Liquidation Loan-to-Value ratios) and IRMs (Interest Rate Models)

**Multisig**: 5/9 governance multisig executes DAO-approved actions. Signer membership is decided by governance vote. Recent MIP-91 replaced two signers (Vincent Danos and Pierre Laurent) with Guillaume Nervo and Pablo Veyrat (Morpho Association advisors). Not all 9 signers appear to be fully publicly identified with verifiable real-world identities.

**Vault-Level Governance**: MetaMorpho Vaults have their own admin roles (Owner, Curator, Guardian, Allocator). Each vault can configure per-function timelocks. Decreasing a timelock requires a mandatory 2-week waiting period, preventing instant reduction of safety delays. Recommended setup is a 4-of-6 multisig or institutional MPC wallet as vault owner.

**Timelock Bypass**: No known bypass mechanism for the core protocol (since it is immutable). Vault-level timelocks are enforced by the MetaMorpho smart contract. Vault owners/curators could theoretically set short timelocks at vault creation, but the 2-week minimum delay for reducing timelocks prevents post-deployment attacks.

**Token Concentration**: The top holder (DAO treasury contract) controls ~57.9% of supply. The next largest holders are contracts and EOAs in the 1-4% range. Proposal submission requires 500K MORPHO tokens. The concentration of tokens in the DAO treasury means that distributed governance voting power is more diluted than the raw supply suggests, which limits whale unilateral governance attacks.

### 2. Oracle & Price Feeds -- MEDIUM

**Oracle-Agnostic Design**: Morpho Blue does not mandate a specific oracle provider. Each market specifies its oracle at creation time. Supported oracle types include Chainlink Price Feeds, Pyth, Redstone, API3, Chronicle, exchange rate oracles (for wrapped/rebasing tokens), and fixed-price oracles.

**Chainlink Primary Integration**: Morpho Labs developed an official ChainlinkOracle wrapper contract, and most high-TVL markets use Chainlink price feeds. The partnership with Chainlink was formalized to provide "hundreds of high-quality, industry-standard Price Feeds."

**Oracle Risk is Shifted to Market Creators**: Because market creation is permissionless, anyone can deploy a market with any oracle. This design means the protocol itself has minimal oracle risk, but individual markets may use poorly configured oracles. This was demonstrated in the October 2024 PAXG/USDC exploit.

**Past Oracle Exploit ($230K, October 2024)**: A market deployer misconfigured the SCALE_FACTOR in the oracle for a PAXG/USDC market, failing to account for decimal differences between USDC (6 decimals) and PAXG (18 decimals). An attacker deposited $350 of PAXG and withdrew $230K by exploiting the inflated valuation. This was a market-creator error, not a protocol bug, but it demonstrates the risk of permissionless market creation without oracle validation.

**No Protocol-Level Oracle Validation**: The Morpho Blue protocol does not enforce automated checks on oracle quality or correctness. Market creators bear full responsibility for oracle configuration. MetaMorpho Vault curators provide a layer of due diligence by selecting which markets to allocate to, but this is trust-based.

### 3. Economic Mechanism -- MEDIUM

**Liquidation**: When a position's LTV exceeds the market's LLTV, anyone can liquidate by repaying debt in exchange for collateral plus an incentive. Collateral is not rehypothecated, which eliminates a systemic risk present in other lending protocols. Liquidation is permissionless and incentive-aligned.

**Bad Debt Handling**: There is no protocol-level insurance fund. Bad debt is socialized proportionally among lenders in the affected market. In MetaMorpho Vault V2, losses are detected via the realAssets() function and distributed through share price depreciation. Users can subscribe to third-party insurance (e.g., Nexus Mutual) for coverage.

**Bad Debt Socialization Attack**: A known attack vector exists where an adversarial supplier can liquidate an underwater position, withdraw their own assets before socialization occurs, and profit from the liquidation while other suppliers bear disproportionate losses. This is a documented risk in Morpho's security documentation.

**Interest Rate Model**: The only governance-approved IRM is the AdaptiveCurveIRM, which targets 90% utilization. It uses a dual mechanism: a curve for short-term rate adjustments and an adaptive mechanism that continuously shifts the curve based on utilization distance from target. The model is immutable per-market (set at creation) and cannot be changed afterward.

**No Withdrawal Limits**: The Morpho Blue protocol does not impose withdrawal rate limits. Users can withdraw available liquidity at any time. During high-utilization periods, withdrawals may be constrained by available liquidity rather than admin-imposed limits. Vault-level withdrawal limits may be configured by vault curators.

### 4. Smart Contract Security -- LOW

**Audit History**: 12 audits from top firms including Trail of Bits, Pessimistic, Chainsecurity, Spearbit, and Omniscia. Audit Coverage Score is estimated at ~5.5 (well above the LOW risk threshold of 3.0).

**Formal Verification**: Morpho Blue completed formal verification with Certora's Prover, led by Quentin Garchery in collaboration with Certora's Jochen Hoenicke and a16z's Daejun Park.

**Bug Bounty**: Active Immunefi program with tiered rewards:
- Morpho Blue core: up to $2,500,000 (minimum $250,000 for critical)
- MetaMorpho and periphery: up to $1,500,000 (minimum $150,000 for critical)
- Morpho Optimizer: up to $555,555 (minimum $55,000 for critical)
- Also listed on Cantina.xyz

**Minimal Code Surface**: Core Morpho Blue contract is ~650 lines of Solidity. This is deliberately minimal compared to protocols with tens of thousands of lines, significantly reducing the attack surface.

**Battle Testing**: Live since January 2024 (Morpho Blue). Peak TVL exceeds $7B. Handled the Resolv USR incident (March 2026) without any contract vulnerability -- only vault-level exposure through curator allocation decisions. The April 2025 $2.6M frontend vulnerability was intercepted by a white hat and all funds were returned; the Morpho Blue smart contracts were not affected.

**Open Source**: All core contracts are open source on GitHub (morpho-org).

### 5. Cross-Chain & Bridge -- MEDIUM

**Multi-Chain Deployment**: Morpho is deployed on 34 chains. Primary TVL is on Ethereum ($3.77B) and Base ($2.18B), with growing presence on Hyperliquid L1 ($432M), Katana ($295M), and Monad ($143M).

**Independent Deployments**: Each chain has independent Morpho Blue contract deployments. Risk parameters (LLTVs, IRMs, oracles) are independently configured per chain per market. There is no cross-chain message relaying for governance -- each deployment operates autonomously.

**Token Bridging**: The MORPHO token uses LayerZero OFT (Omnichain Fungible Token) for cross-chain bridging, with a lock/release pattern on Ethereum and mint/burn on other chains (e.g., Arbitrum per MIP-113). LayerZero is a third-party bridge with its own validator/relayer set.

**Bridge Risk Assessment**: The protocol itself does not depend on bridges for lending operations. Each chain's lending markets are self-contained. The bridge dependency is limited to MORPHO token transfers, which affects governance token distribution but not lending market security. If LayerZero were compromised, it could affect MORPHO token supply on non-Ethereum chains but would not directly threaten lending market funds.

### 6. Operational Security -- LOW

**Team**: Fully doxxed founding team:
- Paul Frambot (CEO) -- Master's from Institut Polytechnique de Paris; recognized as "Best Young Talent" at The Big Whale Awards 2024
- Merlin Egalite -- Computer Science from CentraleSupelec; former white hat at Kleros, software engineer at Commons Stack
- Mathis Gontier Delaunay -- co-author of the Morpho Blue whitepaper
- Julien Thomas -- Engineer's Degree from Telecom Paris, Master's from Polytechnique Montreal

**Funding**: $50M+ raised from top-tier investors. Apollo Global Management ($938B AUM) signed a cooperation agreement to acquire up to 90M MORPHO tokens (9% of supply) over 48 months.

**Incident Response**: Demonstrated effective response during the April 2025 frontend vulnerability (rolled back within hours, white hat returned all funds) and the March 2026 Resolv incident (Paul Frambot publicly communicated impact within hours, clarified no contract vulnerability). Active communication via Twitter/X and governance forum.

**Dependencies**: Key external dependencies include oracle providers (Chainlink primary), LayerZero (token bridging), and third-party vault curators (Gauntlet, Re7 Labs, etc.). The immutable core design limits composability risk -- if an oracle fails, only the affected market is impacted, not the entire protocol.

**Security Practices**: Formal verification, mutation testing, fuzzing, unit testing, peer reviews, and a dedicated morpho-security GitHub repository with security-focused guides and checklists.

## Critical Risks (if any)

No CRITICAL risks identified. Notable HIGH-attention items:

1. **No protocol-level insurance fund**: Bad debt is fully socialized to lenders in affected markets. Users relying on MetaMorpho Vaults are exposed to curator allocation decisions and must trust curators to avoid high-risk markets. The Insurance Fund / TVL ratio is effectively 0%.

2. **Oracle misconfiguration risk in permissionless markets**: The October 2024 $230K exploit demonstrated that market creators can deploy markets with misconfigured oracles. While the protocol itself is not at fault, users depositing into vaults that allocate to poorly configured markets bear this risk.

3. **Bad debt socialization attack vector**: The documented attack where a supplier can front-run bad debt socialization to avoid losses while profiting from liquidation remains an inherent design trade-off.

## Peer Comparison

| Feature | Morpho | Aave (V3) | Compound (V3) |
|---------|--------|-----------|----------------|
| Timelock | Per-vault configurable; 2-week min for reduction | 24h / 168h (dual) | 48h |
| Multisig | 5/9 governance | 6/10 Guardian | 4/6 |
| Audits | 12+ (multiple firms) | 20+ | 10+ |
| Oracle | Oracle-agnostic (Chainlink primary) | Chainlink + SVR fallback | Chainlink |
| Insurance/TVL | 0% (socialized per-market) | ~2% (Safety Module) | ~1% |
| Open Source | Yes | Yes | Yes |
| Immutable Core | Yes (no admin keys) | No (upgradeable proxy) | No (upgradeable proxy) |
| Bug Bounty Max | $2,500,000 | $1,000,000 | $500,000 |
| Formal Verification | Certora | Certora | Certora |

**Key Differentiator**: Morpho Blue's immutable core is a significant security advantage over Aave and Compound, which use upgradeable proxy patterns. This eliminates the entire class of admin-key-compromise attacks on the lending protocol itself. However, Morpho lacks the protocol-level insurance fund that Aave provides through its Safety Module.

## Recommendations

- **For depositors**: Prefer MetaMorpho Vaults managed by reputable curators (Gauntlet, Re7 Labs) with meaningful timelocks configured. Verify vault timelock settings before depositing.
- **For large depositors**: Consider third-party insurance (e.g., Nexus Mutual) to cover bad debt risk, since there is no protocol-level insurance fund.
- **For vault curators**: Enforce strict oracle validation before allocating to new markets. The permissionless nature of market creation means due diligence on oracle configuration is critical.
- **For governance participants**: Advocate for full public disclosure of all 9 multisig signer identities with verifiable real-world accountability.
- **For all users**: Monitor vault curator behavior and allocation changes. The 2-week timelock on timelock reductions provides a safety window, but only if users actively monitor.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- **No**. Core protocol is immutable. Vault curators can add markets but subject to vault-level timelocks.
- [ ] Admin can change oracle sources arbitrarily? -- **No**. Oracles are set per-market at creation and cannot be changed (immutable).
- [ ] Admin can modify withdrawal limits? -- **No**. No admin-controlled withdrawal limits on core protocol.
- [ ] Multisig has low threshold (2/N with small N)? -- **No**. 5/9 threshold.
- [ ] Zero or short timelock on governance actions? -- **No**. Vault timelocks are configurable with 2-week minimum for reductions. Core protocol governance limited to fee switch and whitelisting.
- [ ] Pre-signed transaction risk? -- **N/A** (EVM-based, no durable nonce equivalent).
- [ ] Social engineering surface area (anon multisig signers)? -- **Partial risk**. Not all 9 signers are fully publicly identified.

### Euler/Mango-type (Oracle + Economic Manipulation):
- [ ] Low-liquidity collateral accepted? -- **Yes** (permissionless market creation). Vault curators provide a filtering layer but users in direct markets bear full risk.
- [ ] Single oracle source without TWAP? -- **Market-dependent**. Each market uses one oracle; no protocol-enforced TWAP or multi-oracle requirement.
- [ ] No circuit breaker on price movements? -- **Correct**. No protocol-level circuit breaker.
- [ ] Insufficient insurance fund relative to TVL? -- **Yes**. 0% protocol insurance fund.

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- **Limited**. LayerZero used for token bridging only; lending markets are independent per chain.
- [ ] Admin keys stored in hot wallets? -- **Unknown**. Multisig signer key storage practices not publicly documented.
- [ ] No key rotation policy? -- **Unknown**. Recent signer rotation (MIP-91) suggests some rotation occurs, but no formal policy is documented.

## Information Gaps

- **Full multisig signer identity list**: Not all 9 governance multisig signers are publicly identified with verifiable real-world identities. Signer addresses and operational security practices are not fully disclosed.
- **Multisig key storage practices**: Whether signers use hardware wallets, key rotation frequency, and geographic distribution of signers are not publicly documented.
- **Per-chain admin configuration**: Whether each of the 34 chain deployments has an independent multisig or shares governance infrastructure is not clearly documented.
- **Vault curator due diligence standards**: No standardized, enforceable oracle validation requirements for vault curators. Curation quality varies by curator.
- **Bad debt socialization attack mitigations**: Whether any protocol-level mitigations have been implemented for the documented front-running attack on bad debt socialization.
- **Fee switch status**: Whether the fee switch has been activated and current fee rate is not easily discoverable from public documentation.
- **V2 timeline and migration plan**: Morpho V2 (market-driven fixed-rate lending) is the 2026 priority but security implications of migration are not yet publicly assessed.

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
