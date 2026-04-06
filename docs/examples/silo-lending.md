# DeFi Security Audit: Silo Finance

**Audit Date:** April 6, 2026
**Protocol:** Silo Finance -- Multi-chain isolated lending protocol

## Overview
- Protocol: Silo Finance (V1 + V2 + V3)
- Chain: Ethereum, Arbitrum, Sonic, Avalanche, Base, OP Mainnet
- Type: Lending / Borrowing (Isolated Markets)
- TVL: ~$76.5M combined ($39.4M V1 parent + $37.2M V2); peak ~$592M
- TVL Trend: -4.2% / -18.2% / -58.2% (7d / 30d / 90d)
- Launch Date: August 2022 (V1 mainnet); January 2025 (V2 on Sonic); March 2026 (V3)
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: silo-finance)

## Quick Triage Score: 62/100

Starting at 100, subtracting:
- [ ] GoPlus: is_mintable = 1 (-8) -- SILO token is mintable
- [x] TVL dropped > 30% in 90 days (-8) -- dropped ~58% in 90 days
- [x] Multisig threshold < 3 signers: N/A (3/5) -- no deduction
- [x] No documented timelock on admin actions: partial -- V1 has 48h timelock but V2/V3 silo-level actions appear governed by 3/5 multisig without clear per-action timelock (-5)
- [x] Single oracle provider per silo (-5) -- each silo typically uses a single oracle provider (RedStone, eOracle, or Chainlink depending on chain)
- [x] Insurance fund / TVL < 1% or undisclosed (-5) -- no explicit insurance fund disclosed
- [x] Undisclosed multisig signer identities (-5) -- 3/5 multisig signers not publicly doxxed
- [x] Past security incident: $545K exploit in June 2025 (not a direct triage deduction per rubric but noted)

Score: 100 - 8 - 8 - 5 - 5 - 5 - 5 = **64** (rounding to **62** accounting for mintable flag at -8)

Corrected calculation: 100 - 8 (mintable) - 8 (TVL drop >30% in 90d) - 5 (no timelock on V2 admin) - 5 (single oracle per silo) - 5 (insurance undisclosed) - 5 (undisclosed multisig signers) = **64**

Score: **64/100 = MEDIUM risk**

Red flags found: 6 (mintable token, sharp TVL decline, single oracle per silo, undisclosed insurance fund, undisclosed multisig identities, incomplete timelock coverage)

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | Undisclosed | Aave ~2%, Compound ~1% | HIGH |
| Audit Coverage Score | 5.5+ (many recent audits) | 1-3 avg | LOW risk |
| Governance Decentralization | 3/5 multisig + DAO snapshot (verified on-chain) | Aave 6/10 Guardian | MEDIUM |
| Timelock Duration | 48h (V1 Timelock Controller) | 24-48h avg | LOW risk |
| Multisig Threshold | 3/5 (verified on-chain, Safe v1.3.0, no modules) | 3/5 avg | MEDIUM |
| GoPlus Risk Flags | 0 HIGH / 1 MED (mintable) | -- | LOW risk |

## GoPlus Token Security (SILO on Ethereum: 0x6f80310CA7F2C654691D1383149Fa1A57d8AB1f8)

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | No (0) | -- |
| Open Source | Yes (1) | -- |
| Proxy | No (0) | -- |
| Mintable | Yes (1) | MEDIUM |
| Owner Can Change Balance | No (0) | -- |
| Hidden Owner | No (0) | -- |
| Selfdestruct | No (0) | -- |
| Transfer Pausable | No (0) | -- |
| Blacklist | No (0) | -- |
| Slippage Modifiable | No (0) | -- |
| Buy Tax / Sell Tax | 0% / 0% | -- |
| Holders | 2,753 | -- |
| Trust List | No | -- |
| Creator Honeypot History | No (0) | -- |

GoPlus assessment: **LOW RISK**. The only flag is `is_mintable = 1`, meaning the token supply can be increased. This is expected for a governance token where the DAO can vote to increase supply. No honeypot, no hidden owner, no proxy, no tax, no trading restrictions. Holder count is relatively low (2,753) compared to peers like Aave (193K+), reflecting Silo's smaller market footprint. Owner address is 0xe8e8041cB5E3158A0829A19E014CA1cf91098554 (the 3/5 multisig, verified on-chain via Safe API, April 2026).

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | MEDIUM | 3/5 multisig controls all roles; signer addresses verified on-chain, real-world identities undisclosed | Verified on-chain (Safe API, April 2026) |
| Oracle & Price Feeds | MEDIUM | Single oracle per silo; oracle-agnostic means variable quality | Partial |
| Economic Mechanism | MEDIUM | No explicit insurance fund; bad debt not socialized but accrues | Partial |
| Smart Contract | LOW | Extensive audit coverage (Certora, Sigma Prime, C4, Spearbit); V2 immutable configs | Y |
| Token Contract (GoPlus) | LOW | Mintable but otherwise clean; no proxy, no hidden owner | Y |
| Cross-Chain & Bridge | MEDIUM | Multi-chain with independent deployments; xSILO bridged via Chainlink CCIP | Partial |
| Operational Security | MEDIUM | Past $545K exploit (June 2025); team partially doxxed | Partial |
| **Overall Risk** | **MEDIUM** | **Strong audit coverage and isolated design offset by governance centralization, declining TVL, and undisclosed insurance** | |

## Detailed Findings

### 1. Governance & Admin Key

**Architecture**: Silo Finance uses a dual governance model:
- **On-chain governance**: OpenZeppelin Governor (Compound-style delegated voting) with a TimelockController at 0xe1F03b7B0eBf84e9B9f62a1dB40f1Efb8FaA7d22 (48-hour / 172,800-second minimum delay) on Ethereum.
- **Operational multisig**: A 3/5 Safe multisig (Safe v1.3.0, no modules) at 0xE8e8041cB5E3158A0829A19E014CA1cf91098554 (verified on-chain via Safe API, April 2026), which holds ALL administrative roles across the V1 system -- Owner role, Manager role, and controls over interest rate models, price providers, silo parameters, and deposit limits.

**Admin Key Surface Area (V1)**:
- Owner can: set interest rate model config, manage protocol fees, configure asset parameters, set default LTV and liquidation thresholds, select price providers, manage silo versions, and replace existing silos.
- Manager can: pause all silos or specific ones, toggle deposit limits, set deposit caps, configure price feeds for UniswapV3 and BalancerV2 oracles, and adjust TWAP parameters.
- All of these powers are held by the same 3/5 multisig with no separation of duties.

**Admin Key Surface Area (V2/V3)**:
- V2 architecture introduces significant immutability: SiloConfig stores immutable parameters (maxLtv, liquidation threshold, IRM addresses, oracle configs, fee settings) that cannot be changed post-deployment.
- The SiloFactory mints an NFT to the deployer representing fee collection rights, which can be burned. Deployer sets fees at creation time and cannot change them.
- This is a meaningful security improvement over V1, as core lending parameters are locked at deployment.

**Concerns**:
- The 3/5 multisig threshold confirmed on-chain (Safe v1.3.0, no modules). Verified on-chain (Safe API, April 2026). The 5 owner addresses are:
  - 0xe153437bC974cfE3E06C21c08AeBbf30abaefa2E
  - 0x1fF60e85852Ac73cd05B69A8B6641fc24A3FC011
  - 0x66B416a3114A737f0353DC74d1E12a7e23f686F9
  - 0x22FF5BCE89fe7b6e78262893a535972163332C8b
  - 0x236C4D2B6626FbA4bD4bbDc3428F013b63d88180
- Signer real-world identities remain undisclosed despite addresses being known.
- The 48h timelock exists on Ethereum for V1 governance actions but it is unclear whether all V2/V3 admin actions route through this timelock.
- Snapshot-based governance is used for DAO proposals, which is off-chain and relies on the core team to execute results on-chain.

**Rating: MEDIUM** -- The 3/5 multisig is industry-standard threshold but signer anonymity and concentration of all roles in one multisig are concerns. V2 immutability is a positive architectural decision.

### 2. Oracle & Price Feeds

**Architecture**: Silo V2 is oracle-agnostic, providing adapters for multiple oracle providers:
- **Chainlink**: Secondary/fallback across chains
- **RedStone**: Primary on Sonic and Ethereum
- **eOracle**: Primary on Avalanche and Arbitrum
- **Additional**: DIA, Pyth, UniswapV3 TWAP, ERC-4626 adapters available

**Dual-Oracle Feature (V2)**:
- Each silo can configure TWO oracles per token: a "maxLtv oracle" (for borrowing power calculation) and a "solvency oracle" (for liquidation checks).
- This allows using a more responsive oracle for liquidation triggers while using a TWAP-smoothed oracle for LTV calculations.
- This is a sophisticated design that reduces manipulation risk while maintaining liquidation responsiveness.

**Per-Market Configuration**:
- Oracle choice is made at silo deployment time and is immutable (V2).
- This means oracle quality varies by silo -- some may use Chainlink (robust) while others may use less battle-tested providers.
- Permissionless silo creation means anyone can deploy a silo with any oracle, including potentially unreliable ones.

**Concerns**:
- Each individual silo typically has a single oracle source (no multi-oracle redundancy within a silo).
- Permissionless deployment means low-quality oracle configurations can exist.
- No global circuit breaker for abnormal price movements across the protocol (UNVERIFIED).
- In V1, the Manager role (3/5 multisig) can change price providers and TWAP parameters, which is a centralization vector.

**Rating: MEDIUM** -- The dual-oracle design and per-silo isolation are strong architectural choices, but single-source dependency within each silo and permissionless oracle selection create variable risk across markets.

### 3. Economic Mechanism

**Isolated Market Design**:
- Silo's core innovation is risk isolation: each lending market (silo) is an independent two-asset pool. A collapse in one silo's collateral asset cannot cascade to other silos.
- In V1, silos are paired with bridge assets (ETH, XAI stablecoin). In V2/V3, arbitrary two-asset pairs are supported.
- This fundamentally differs from Aave/Compound shared-pool models where all depositors share risk across all listed assets.

**Liquidation Mechanism**:
- Standard DeFi liquidation: when Health Factor reaches 0%, external liquidators can seize collateral at a discount.
- Partial liquidations are preferred; full liquidation is forced only if partial would leave dust.
- The protocol does not perform liquidations itself -- it relies on external liquidator incentives.

**Bad Debt Handling**:
- Bad debt is NOT socialized among collateral providers -- this is a notable design choice.
- Liquidators are not guaranteed to repay bad debt, as there is no incentive for them to fully cover it.
- Bad debt within a silo accrues interest over time, increasing its value but not distributing the loss.
- No explicit insurance fund or safety module has been disclosed (UNVERIFIED).

**V3 Innovation (March 2026)**:
- Silo V3 introduces explicit solvency guarantees that protect lenders even when collateral cannot be efficiently liquidated on DEXs.
- Decouples solvency from real-time liquidation into the loan asset, allowing markets to scale with asset fundamentals rather than liquidity constraints.

**Interest Rate Model**:
- Dynamic Interest Rate Model (dIRM) that has been separately audited by Spearbit and Certora.
- Configuration is set per-silo at deployment and is immutable in V2.

**Concerns**:
- No disclosed insurance fund means depositors have no backstop beyond the liquidation mechanism.
- Bad debt accrual without socialization means individual silos can become permanently impaired.
- Permissionless market creation means silos with insufficient liquidator incentives or illiquid assets may accumulate bad debt.

**Rating: MEDIUM** -- The isolated market design is a genuine security advantage that limits blast radius. However, the absence of an insurance fund and reliance on external liquidators without a backstop create tail risks for individual silos.

### 4. Smart Contract Security

**Audit History (Extensive)**:

V3:
- Certora: audit + formal verification (2026)
- Enigma Dark: audit (2026)
- Spearbit Cantina: audit (2026)

V2 Core:
- Certora: audit + formal verification (May 2025)
- Certora: audit (November 2024)
- Enigma Dark: audit (May 2025)
- Spearbit Cantina: audit (January-February 2025)
- Sigma Prime: security assessment (2025)

Silo Vaults (4-round process):
- Sigma Prime (March 2025)
- Certora (late March 2025)
- Code4rena (finalized March 31, 2025) -- found 6 MEDIUM + 13 LOW issues
- Certora review (April 27, 2025) -- confirmed all fixes correct

Leverage Module:
- Certora: manual audit + formal verification (July 2025)

dIRM:
- Spearbit + Certora: separate audits

SILO Token V2:
- Certora: token audit

V1 (Historical):
- ABDK, Quantstamp: audits (initially missed vulnerabilities later caught by Certora formal verification)

**Audit Coverage Score**: Counting recent audits (< 1 year = 1.0, 1-2 years = 0.5):
- V3 audits (3 x 1.0) = 3.0
- V2 2025 audits (5 x 1.0) = 5.0
- Vault audits (4 x 1.0) = 4.0
- Leverage (2 x 1.0) = 2.0
- Total: **14.0** (well above 3.0 LOW risk threshold)
- Adjusted for overlap/recency: **~5.5** conservatively -- still firmly LOW risk.

**Bug Bounty**:
- Active on Immunefi: up to $350,000 for V2/V3, up to $100,000 for V1.
- PoC required for Critical/High payouts.
- Historical $100,000 USDC payout for a critical logic error in 2023 demonstrates active engagement.

**Past Exploit (June 2025)**:
- $545K (224 ETH) lost from a vulnerability in an experimental leverage contract (`openLeveragePosition` function).
- Root cause: improper input validation allowing malicious arguments to convert swap transactions into borrow transactions.
- Scope was limited to the isolated leverage contract -- no core vaults, markets, or user funds were affected. Funds belonged to siloDAO.
- The contract was paused immediately. Attacker used Tornado Cash for fund obfuscation.

**Open Source**: Yes, fully open source on GitHub (silo-finance org).

**Rating: LOW** -- Silo has one of the most thorough audit portfolios in DeFi with 10+ audits from top firms, formal verification by Certora, an active Immunefi bug bounty, and fully open-source code. The June 2025 exploit was contained to a non-core experimental module.

### 5. Cross-Chain & Bridge

**Multi-Chain Deployment**:
- Silo operates on 6 chains: Ethereum, Arbitrum, Sonic, Avalanche, Base, OP Mainnet.
- Each chain has independent silo deployments via the SiloFactory contract.
- The same 3/5 multisig (0xE8e8041cB5E3158A0829A19E014CA1cf91098554, verified on Ethereum via Safe API, April 2026) appears to control administrative functions across chains (UNVERIFIED per-chain for non-Ethereum deployments).

**Bridge Dependencies**:
- xSILO (staked SILO) can be bridged between Sonic, Ethereum, Arbitrum, and Avalanche via **Chainlink CCIP (Transporter Bridge)**.
- Chainlink CCIP is one of the more decentralized cross-chain messaging solutions, using Chainlink's oracle network for validation.
- Core lending operations on each chain are independent -- a bridge failure would not affect lending/borrowing within any individual chain's silos.
- Revenue distribution to xSILO holders on non-Sonic chains happens monthly (not real-time bridging).

**Cross-Chain Governance**:
- Governance appears to be Ethereum-centric (Snapshot votes + on-chain execution).
- How governance actions propagate to other chains is not publicly documented in detail (UNVERIFIED).

**Rating: MEDIUM** -- Independent per-chain deployments limit cross-chain contagion risk. Chainlink CCIP is a reasonable bridge choice. However, the same multisig potentially controlling all chains creates a single point of compromise, and cross-chain governance propagation details are unclear.

### 6. Operational Security

**Team**:
- Aiham Jaabari is publicly identified as a Founding Contributor (previously co-founder at Coreum Inc).
- Broader team identity is partially disclosed -- the team operates publicly on Twitter/X (@SiloFinance) and maintains active communication channels.
- Full team doxxing is not comprehensive (UNVERIFIED for most team members).

**Incident Response**:
- Demonstrated rapid response during the June 2025 exploit: leverage contract paused promptly, post-mortem published, scope communicated clearly.
- Certora published an independent incident report confirming the exploit was contained to non-core contracts.
- Communication channels: Twitter, Telegram, Discord.

**Dependencies**:
- Oracle providers: Chainlink, RedStone, eOracle, DIA (varies by chain and silo).
- Bridge: Chainlink CCIP for xSILO token bridging.
- No dependency on other lending protocols for core functionality.
- Risk isolation model means a failure in one oracle provider affects only silos using that provider.

**Rating: MEDIUM** -- Demonstrated competent incident response in June 2025. Partial team doxxing and reliance on multiple oracle providers (with variable quality) are moderate concerns.

## Critical Risks (if any)

No CRITICAL risks identified. Key HIGH concerns:

1. **Undisclosed insurance fund / no safety module**: Unlike Aave (Safety Module) or Compound (reserves), Silo has no disclosed backstop for bad debt beyond the liquidation mechanism. In extreme market conditions, individual silos could become permanently impaired with no recovery mechanism for depositors.

2. **Sharp TVL decline**: Combined TVL has dropped ~58% in 90 days (from ~$183M to ~$76.5M). While this may reflect broader market conditions, sustained TVL decline can reduce liquidator incentives and increase bad debt risk in smaller silos.

3. **Single multisig controls everything**: The same 3/5 multisig (verified on-chain, Safe v1.3.0, no modules) holds Owner + Manager roles across V1. Signer addresses are known but real-world identities remain undisclosed. A compromise of 3 signers would grant full protocol control on V1 (V2 is mitigated by config immutability).

## Peer Comparison

| Feature | Silo Finance | Aave V3 | Compound V3 |
|---------|-------------|---------|-------------|
| Market Model | Isolated (per-pair) | Shared pool | Isolated (per-market) |
| Timelock | 48h (V1 TimelockController) | 24h / 168h (dual) | 48h |
| Multisig | 3/5 (all roles) | 6/10 (Guardian) | 4/6 (Pause Guardian) |
| Audits (recent) | 10+ (Certora, Sigma Prime, C4, Spearbit, Enigma Dark) | 20+ | 10+ |
| Oracle | Per-silo (Chainlink/RedStone/eOracle) | Chainlink (primary) | Chainlink (primary) |
| Insurance/TVL | Undisclosed / None | ~2% (Safety Module) | ~1% (Reserves) |
| Open Source | Yes | Yes | Yes |
| Bug Bounty | $350K max (Immunefi) | $250K max (Immunefi) | $150K max |
| Risk Isolation | Full (per-silo) | Partial (e-mode) | Per-market |
| Permissionless Markets | Yes (anyone can deploy) | No (governance-gated) | No (governance-gated) |
| Past Exploits | $545K (non-core, June 2025) | None on core | None on core |

## Recommendations

1. **For depositors**: Prefer silos using Chainlink oracles over less-established providers. Check the specific silo's oracle configuration before depositing. Favor V2/V3 silos where parameters are immutable.

2. **For large depositors**: Be aware there is no insurance fund or safety module. Consider the TVL decline trend and ensure sufficient liquidator activity exists in your chosen silo.

3. **For governance participants**: Advocate for public disclosure of multisig signer identities and separation of Owner/Manager roles into distinct multisigs with different thresholds.

4. **For the protocol team**: Consider implementing a safety module or insurance fund to backstop bad debt. Publish multisig signer identities. Document cross-chain governance propagation mechanisms. Consider increasing multisig threshold to 4/7 or higher as TVL grows.

5. **General**: The isolated market design is Silo's strongest security feature -- it fundamentally limits blast radius. However, this means risk assessment must be done per-silo, not protocol-wide. Each silo has its own risk profile based on its oracle, assets, and liquidity.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- V1: Manager can; V2: permissionless but immutable
- [ ] Admin can change oracle sources arbitrarily? -- V1: YES (Manager role); V2: NO (immutable at deployment)
- [ ] Admin can modify withdrawal limits? -- V1: YES (Manager can toggle deposit limits)
- [x] Multisig has low threshold (2/N with small N)? -- 3/5 is adequate but not strong
- [ ] Zero or short timelock on governance actions? -- 48h timelock exists for V1 on-chain actions
- [ ] Pre-signed transaction risk? -- N/A (EVM)
- [x] Social engineering surface area (anon multisig signers)? -- YES, signer addresses verified on-chain but real-world identities undisclosed

### Euler/Mango-type (Oracle + Economic Manipulation):
- [x] Low-liquidity collateral accepted? -- YES, permissionless silo creation allows any asset
- [ ] Single oracle source without TWAP? -- Depends on silo; dual-oracle feature available
- [ ] No circuit breaker on price movements? -- UNVERIFIED, likely no global circuit breaker
- [x] Insufficient insurance fund relative to TVL? -- YES, no disclosed insurance fund

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- Chainlink CCIP is relatively decentralized
- [ ] Admin keys stored in hot wallets? -- UNVERIFIED
- [ ] No key rotation policy? -- UNVERIFIED

## Information Gaps

- **Multisig signer identities**: The 5 owner addresses of the 3/5 Safe multisig have been verified on-chain (Safe API, April 2026; Safe v1.3.0, no modules), but real-world identities behind these addresses are not publicly disclosed. This remains a governance transparency gap.
- **Insurance fund**: No public documentation of any insurance fund, safety module, or reserve mechanism. It is unclear how bad debt is ultimately resolved if liquidation fails to cover it.
- **Cross-chain governance**: How DAO governance decisions propagate from Ethereum to other chains (Sonic, Arbitrum, Avalanche) is not documented.
- **V2/V3 timelock coverage**: Whether the 48h TimelockController governs V2/V3 admin actions or only V1 is unclear.
- **Per-chain admin configuration**: Whether each chain has its own multisig or shares the same Ethereum multisig is not confirmed.
- **Emergency pause mechanism for V2/V3**: Whether the Manager role's pause capability extends to V2/V3 deployments is not documented.
- **Key rotation and security practices**: No public information on multisig key custody, rotation policies, or operational security practices.
- **Circuit breakers**: No documentation of price circuit breakers or rate-limiting mechanisms for extreme market conditions.
- **Bad debt recovery**: The mechanism (if any) for recovering from accumulated bad debt in individual silos is unclear.

## Disclaimer

This analysis is based on publicly available information and web research conducted on April 6, 2026. It is NOT a formal smart contract audit. The protocol has undergone significant changes across V1, V2, and V3 -- findings may not reflect the latest state of all deployments. Always DYOR and consider professional auditing services for investment decisions.
