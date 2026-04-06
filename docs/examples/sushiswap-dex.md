# DeFi Security Audit: SushiSwap

**Audit Date:** April 6, 2026
**Protocol:** SushiSwap -- Multi-Chain Decentralized Exchange (AMM)

## Overview
- Protocol: SushiSwap (Sushi)
- Chain: Multi-chain (Ethereum, Arbitrum, Polygon, Base, Avalanche, BSC, and 30+ others)
- Type: DEX (AMM) / Cross-Chain Swap
- TVL: ~$41M (SushiSwap classic AMM; parent "Sushi" ecosystem broader)
- TVL Trend: -6.4% / -3.6% / -63.1% (7d / 30d / 90d)
- Token: SUSHI (ERC-20: 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2)
- Launch Date: August 2020
- Audit Date: April 6, 2026
- Source Code: Open (GitHub: sushiswap/v3-core, sushi-labs/sushi)

## Quick Triage Score: 37/100

Starting at 100, subtracting:

- -8: TVL dropped >30% in 90 days (-63.1% decline)
- -8: GoPlus: UNAVAILABLE (rate limited, could not verify token contract)
- -5: No documented timelock on newer contracts (RouteProcessor, SushiXSwap); legacy 48h timelock on MasterChef only
- -5: Insurance fund / TVL undisclosed (no dedicated insurance fund)
- -5: Undisclosed multisig signer identities (community-elected but pseudonymous)
- -5: DAO governance effectively paused -- treasury proposal controversy, single-wallet voting dominance
- -8: Multisig threshold concern: Operations Multisig is 3/N (below 4/6 Treasury standard)
- -15: Anonymous/pseudonymous team with governance instability (leadership transitions, SEC subpoena history)
- -5: No bug bounty max payout above $200K (low relative to TVL and peer protocols)
- -5: Single oracle provider concern (Chainlink primary for Kashi; AMM pools use internal TWAP only)

Total deductions: -63. **Score: 37/100 (HIGH risk)**

Red flags found: 0 CRITICAL, 1 HIGH (pseudonymous team with governance instability), 3 MEDIUM (TVL decline, GoPlus unavailable, low multisig threshold), 5 LOW flags

## Quantitative Metrics

| Metric | Value | Benchmark (peers) | Rating |
|--------|-------|--------------------|--------|
| Insurance Fund / TVL | No dedicated fund; treasury ~$6.3M | Uniswap: treasury $3B+; Curve: emergency DAO | HIGH |
| Audit Coverage Score | 1.25 (see below) | Uniswap ~5.0; Curve ~4.0 | HIGH |
| Governance Decentralization | Weak -- single wallet dominated vote, leadership transitions | Uniswap: on-chain DAO; Curve: veCRV | HIGH |
| Timelock Duration | 48h (legacy MasterChef); UNVERIFIED on newer contracts | 24-48h standard | MEDIUM |
| Multisig Threshold | 3/N Ops; 4/6 Treasury | 4/7 to 6/9 avg | MEDIUM |
| GoPlus Risk Flags | UNAVAILABLE | -- | UNVERIFIED |

### Audit Coverage Score Calculation

Known audits:

**Older than 2 years (0.25 each):**
1. PeckShield SushiSwap V1 (2020) -- 0.25
2. Quantstamp SushiSwap (2020, found 10 flaws) -- 0.25
3. PeckShield/DeFiSafety additional review (~2021) -- 0.25

**1-2 years old (0.5 each):**
- No confirmed audits from April 2024 - April 2025 identified in public sources: 0

**Less than 1 year old (1.0 each):**
- No confirmed audits from April 2025 - April 2026 identified in public sources: 0

DeFiLlama lists "3" audits but links only 1 (PeckShield V1). RouteProcessor2 was deployed in April 2023 without a completed audit and was exploited within days. V3 contracts are a Uniswap V3 fork (inheriting Uniswap's audit coverage indirectly, but SushiSwap-specific modifications were not independently audited per public records).

**Total Audit Coverage Score: ~0.75 (HIGH risk -- well below 1.5 threshold)**

Note: Conservative estimate. If unreported audits exist, the score could be higher, but the absence of public audit documentation is itself a risk signal.

## GoPlus Token Security

**UNAVAILABLE** -- GoPlus Security API returned "too many requests" (error code 4029) on all three attempts. Token contract-level checks (honeypot detection, owner privilege scanning, holder concentration analysis) could not be performed for SUSHI (0x6B3595068778DD592e39A122f4f5a5cF09C90fE2) on Ethereum.

| Check | Result | Risk |
|-------|--------|------|
| Honeypot | UNAVAILABLE | UNVERIFIED |
| Open Source | Yes (verified on Etherscan) | LOW |
| Proxy | No (SUSHI token is not upgradeable) | LOW |
| Mintable | Yes (owner/MasterChef can mint SUSHI for rewards) | MEDIUM |
| Owner Can Change Balance | UNAVAILABLE | UNVERIFIED |
| Hidden Owner | UNAVAILABLE | UNVERIFIED |
| Selfdestruct | UNAVAILABLE | UNVERIFIED |
| Transfer Pausable | UNAVAILABLE | UNVERIFIED |
| Blacklist | UNAVAILABLE | UNVERIFIED |
| Slippage Modifiable | UNAVAILABLE | UNVERIFIED |
| Buy Tax / Sell Tax | UNAVAILABLE | UNVERIFIED |
| Holders | UNAVAILABLE | UNVERIFIED |
| Trust List | UNAVAILABLE | UNVERIFIED |
| Creator Honeypot History | UNAVAILABLE | UNVERIFIED |

Note: SUSHI token is a standard ERC-20 with minting capability controlled by the MasterChef contract (behind the legacy 48h timelock). The token contract source code is verified on Etherscan and open source.

## Risk Summary

| Category | Risk Level | Key Concern | Verified? |
|----------|-----------|-------------|-----------|
| Governance & Admin | HIGH | Leadership instability; single-wallet vote dominance; treasury controversy | Partial |
| Oracle & Price Feeds | LOW | AMM uses internal pricing; Chainlink for Kashi (deprecated) | Partial |
| Economic Mechanism | MEDIUM | No insurance fund; 63% TVL decline in 90d; liquidity fragmentation across 30+ chains | Y |
| Smart Contract | HIGH | RouteProcessor2 exploit ($3.3M); no public audit of V3 modifications or newer RouteProcessors | Partial |
| Token Contract (GoPlus) | UNVERIFIED | GoPlus API unavailable; SUSHI is mintable via MasterChef | N |
| Cross-Chain & Bridge | MEDIUM | SushiXSwap depends on Stargate/LayerZero; 30+ chain deployments with unclear per-chain admin controls | Partial |
| Operational Security | HIGH | SEC subpoena history; two leadership transitions; pseudonymous governance signers | Y |
| **Overall Risk** | **HIGH** | **Governance instability, unaudited newer contracts, significant TVL decline, and RouteProcessor exploit history create elevated risk** | |

## Detailed Findings

### 1. Governance & Admin Key

**Risk: HIGH**

SushiSwap's governance history is marked by significant turmoil:

**Leadership Timeline:**
- August 2020: Chef Nomi launches SushiSwap as a Uniswap V2 fork, then controversially drains $14M from dev fund before returning it
- September 2020: Admin key transferred to a timelock contract (48h delay), then to a multisig facilitated by Sam Bankman-Fried
- October 2022: Jared Grey elected "Head Chef" in an on-chain vote dominated by venture capital firms GoldenTree and Cumberland
- March 2023: SEC subpoenas SushiSwap and Jared Grey; DAO creates $3M legal defense fund
- April 2024: Treasury restructuring proposal passes amid allegations that the core team created fresh wallets to inflate voting power (5.5M SUSHIPOWAH votes from a new wallet, plus 3.1M delegated)
- December 2025: Alex McCurry (Synthesis founder) acquires 10M+ SUSHI tokens and assumes control as managing director; Jared Grey moves to advisory role

**Multisig Structure:**
- Treasury Multisig (0xe94b5eec...e4493f4f3): Requires 4 of 6 signatures
- Operations Multisig (0x19b3eb3a...7115a19e7): Requires 3 signatures (threshold UNVERIFIED on-chain)
- Signers are community-elected via Snapshot but identities are pseudonymous

**Timelock:**
- Legacy timelock (0x9a8541dd...1d47bd1): 2-day minimum, 30-day maximum delay (Compound-style), controls MasterChef and SUSHI minting
- Newer contracts (RouteProcessor, SushiXSwap, V3 Factory): Timelock coverage UNVERIFIED. The RouteProcessor contracts appear to be controlled by the Operations Multisig without a mandatory timelock

**Key Concerns:**
- The April 2024 treasury vote controversy demonstrates that governance can be manipulated by insiders with large token holdings
- A governance vote in early 2026 to increase SUSHI emissions was reportedly controlled 99.9% by a single wallet
- Three leadership transitions in five years signals organizational instability
- The new leadership under McCurry/Synthesis represents a concentration of power through token acquisition rather than community consensus

### 2. Oracle & Price Feeds

**Risk: LOW**

As an AMM-style DEX, SushiSwap does not depend on external oracles for its core swap functionality. Prices are determined by the constant product formula (x*y=k for V2) or concentrated liquidity curves (V3).

- **Kashi Lending (deprecated):** Previously integrated Chainlink price feeds for lending/margin markets. Kashi has been deprecated along with Trident.
- **Internal TWAP:** SushiSwap V2 pools can serve as TWAP oracles for other protocols (similar to Uniswap V2 design). Manipulation resistance depends on pool liquidity depth.
- **No admin override risk:** Since prices are market-determined by the AMM formula, there is no admin ability to change oracle sources for core DEX operations.

The low-liquidity pools across many chains (some with only thousands of dollars in TVL) could be targets for price manipulation by other protocols using SushiSwap as an oracle source, but this is an external risk rather than a SushiSwap-specific vulnerability.

### 3. Economic Mechanism

**Risk: MEDIUM**

**Liquidity and TVL:**
- Current TVL of ~$41M is down from a peak of ~$7.87B (a 99.5% decline)
- TVL is fragmented across 30+ chains, with many chains holding negligible liquidity (e.g., Telos: $14, ThunderCore: $6, HAQQ: $0.31)
- Top chains by TVL: Polygon ($4.7M), Arbitrum ($4.6M), Ethereum ($27.2M), Base ($1.5M), Boba ($1M)
- A user in March 2026 experienced 99.9% slippage on a swap routed through a SushiSwap pool with only $73K in liquidity

**Fee Structure:**
- Standard 0.3% swap fee (0.25% to LPs, 0.05% to xSUSHI holders via SushiMaker)
- V3 pools offer tiered fees (0.01%, 0.05%, 0.3%, 1%)
- Protocol claims $10M+ annual revenue achieved in 2024

**Insurance/Treasury:**
- No dedicated insurance fund for user protection
- Treasury Multisig holds approximately $6.3M (as of August 2025)
- Treasury diversification proposal aimed for 70% stablecoins, 20% BTC/ETH, 10% DeFi tokens
- Treasury runway was estimated at 1.5 years as of late 2023
- Insurance Fund / TVL ratio: effectively 0% (no dedicated fund)

**Token Economics:**
- SUSHI is mintable via MasterChef for LP rewards (inflationary)
- xSUSHI staking mechanism provides fee sharing
- Emissions schedule has been subject to governance votes with concentration concerns

### 4. Smart Contract Security

**Risk: HIGH**

**RouteProcessor2 Exploit (April 9, 2023):**
- $3.3M stolen due to a critical input validation bug in RouteProcessor2
- The contract was deployed ("soft launched") only 4 days before exploitation on April 8, 2023
- Root cause: the contract did not validate that the pool parameter was a legitimate Uniswap V3 pool, allowing an attacker to inject a malicious contract
- The exploit affected 14 networks simultaneously
- A whitehat rescue attempt through Immunefi was front-run by MEV bots, worsening the impact
- HYDN security firm recovered ~$600K of user funds

**Audit History:**
- PeckShield audit of SushiSwap V1 (2020): passed with deployment-related issues noted
- Quantstamp audit (2020): identified 10 security flaws in the original codebase
- DeFiLlama lists "3" audits but only links one (PeckShield V1)
- No public audit found for RouteProcessor2 (exploited), RouteProcessor7 (current), V3 modifications, or SushiXSwap cross-chain contracts
- V3 core is a Uniswap V3 fork, which benefits from Uniswap's extensive auditing, but SushiSwap-specific changes and integrations have no confirmed independent audit

**Bug Bounty:**
- Active on Immunefi with max payout of $200K (capped at 10% of economic damage for critical findings)
- Payouts above $100K are paid in SUSHI tokens rather than stablecoins
- Scope covers smart contracts focused on preventing loss of user funds
- The $200K max is low compared to peers (Uniswap: up to $15.5M on their bug bounty)

**Code Quality:**
- Open source on GitHub (sushi-labs/sushi)
- V3 is a well-known fork of Uniswap V3 with concentrated liquidity
- RouteProcessor contracts are the highest-risk component given the 2023 exploit history; the current RouteProcessor7 has been iteratively updated but without confirmed public audit

### 5. Cross-Chain & Bridge

**Risk: MEDIUM**

**Multi-Chain Deployment:**
- Deployed on 38+ chains per DeFiLlama data
- Each chain deployment appears to have independent liquidity pools
- It is UNVERIFIED whether each chain has its own admin multisig or whether a single key controls all deployments
- Risk parameters are unclear per chain -- many low-TVL chains ($0-$100) suggest abandoned or neglected deployments

**SushiXSwap (Cross-Chain Swaps):**
- Uses Stargate (LayerZero) bridge infrastructure for cross-chain token transfers
- Swap flow: source chain swap -> Stargate bridge (via stablecoin conversion) -> destination chain swap
- Stargate uses LayerZero's Ultra Light Node messaging rather than a centralized validator set, which is more decentralized than traditional bridge designs
- A "safety guard" feature converts failed transactions to stablecoins rather than losing funds

**Bridge Risk Assessment:**
- LayerZero/Stargate is a third-party bridge dependency -- if Stargate is compromised, SushiXSwap cross-chain functionality is affected
- LayerZero has had independent audits but is still relatively newer bridge infrastructure
- SushiXSwap contract (0x011e52e4...1e2e581) is controlled by the Operations Multisig -- UNVERIFIED if a timelock protects cross-chain contract upgrades
- The April 2023 RouteProcessor2 exploit demonstrated that new router deployments across multiple chains create a large attack surface

**Abandoned Chain Risk:**
- Heco, Boba_Bnb, Harmony, and several other chain deployments show near-zero TVL
- Contracts on these chains may have outdated code or unpatched vulnerabilities
- Users interacting with abandoned chain deployments face elevated risk

### 6. Operational Security

**Risk: HIGH**

**Team & Track Record:**
- Original creator Chef Nomi is anonymous and exited the project controversially in 2020
- Jared Grey (Head Chef 2022-2025): doxxed, but faced SEC subpoena in March 2023 and governance manipulation allegations in April 2024; moved to advisory December 2025
- Alex McCurry (current Managing Director since December 2025): doxxed, founder of Synthesis and Solidity.io; acquired control via large token purchase rather than community election
- Core team is a mix of doxxed and pseudonymous contributors

**SEC Subpoena (March 2023):**
- Both SushiSwap and Jared Grey personally served with SEC subpoenas
- DAO approved $3M (with $1M contingency) legal defense fund in USDT
- Outcome/resolution not publicly documented as of this audit date
- Ongoing regulatory uncertainty could affect protocol operations and team composition

**Incident Response:**
- The RouteProcessor2 exploit response was criticized: a whitehat rescue attempt leaked to MEV bots, making the situation worse
- BlockSec described it as "a clumsy rescue attempt" that led to copycat attacks
- No published formal incident response plan found
- Emergency pause capability exists through multisig but response speed and coordination are UNVERIFIED

**Key Dependencies:**
- Stargate/LayerZero for cross-chain swaps
- Chainlink (historical, for Kashi -- now deprecated)
- No critical single-protocol dependency for core AMM operations

## Critical Risks

1. **Unaudited Router Contracts**: The current RouteProcessor7 and SushiXSwap contracts have no confirmed public audit, and the predecessor RouteProcessor2 was exploited for $3.3M within days of deployment. This is the single highest-impact risk.
2. **Governance Instability**: Three leadership transitions, a governance vote controlled 99.9% by a single wallet, and a treasury vote tainted by alleged wallet creation to inflate voting power -- all signal that governance can be captured or manipulated.
3. **Severe TVL Decline**: A 63% drop in 90 days and 99.5% from peak suggests waning user trust and liquidity provider departure. Low-liquidity pools create slippage risk and make the protocol less economically viable.
4. **SEC Regulatory Overhang**: The unresolved SEC subpoena creates uncertainty about the protocol's legal standing and could force operational changes.

## Peer Comparison

| Feature | SushiSwap | Uniswap | PancakeSwap |
|---------|-----------|---------|-------------|
| Timelock | 48h (legacy); UNVERIFIED (newer) | Governance timelock (2-7 days) | Timelock on key contracts |
| Multisig | 4/6 Treasury; 3/N Ops | Governance DAO (no multisig needed) | Multisig with CertiK oversight |
| Audits | 3 listed (all from 2020); no recent | 20+ audits (OpenZeppelin, Trail of Bits, ABDK) | CertiK continuous; multiple firms |
| Oracle | Internal AMM pricing | Internal AMM pricing | Internal AMM + Chainlink |
| Insurance/TVL | 0% (no dedicated fund) | Uniswap Foundation treasury $3B+ | CAKE staking backstop |
| Open Source | Yes | Yes | Yes |
| Bug Bounty Max | $200K | $15.5M | $10M+ |
| TVL | ~$41M | ~$5B+ | ~$1.5B+ |
| Chains | 38+ | 12+ | 9+ |

## Recommendations

1. **For users/LPs**: Avoid providing liquidity on low-TVL chains (dozens of chains with <$10K TVL). Concentrate activity on Ethereum, Arbitrum, Polygon, and Base where meaningful liquidity exists.
2. **Revoke old approvals**: Users who interacted with any RouteProcessor contract should verify and revoke token approvals. The April 2023 exploit targeted users who had approved RouteProcessor2.
3. **Monitor governance closely**: Given the history of governance manipulation, monitor Snapshot votes and on-chain proposals for unusual voting patterns or sudden large-wallet participation.
4. **Await audit confirmation**: Before committing significant capital, verify whether RouteProcessor7 and SushiXSwap have undergone independent security audits. The absence of public audit reports for post-2020 contracts is a significant gap.
5. **Evaluate new leadership**: The McCurry/Synthesis transition is recent (December 2025). Allow time to assess whether the new leadership improves operational stability and security practices before increasing exposure.
6. **Use position limits**: Given the thin liquidity on most chains, limit individual position sizes and use slippage protection settings aggressively.

## Historical DeFi Hack Pattern Check

### Drift-type (Governance + Oracle + Social Engineering):
- [ ] Admin can list new collateral without timelock? -- N/A (AMM, not lending)
- [ ] Admin can change oracle sources arbitrarily? -- N/A (AMM uses internal pricing)
- [x] Admin can modify withdrawal limits? -- Operations Multisig can update router contracts which control swap execution
- [x] Multisig has low threshold (2/N with small N)? -- Operations Multisig at 3/N is below best practice; Treasury at 4/6 is acceptable
- [x] Zero or short timelock on governance actions? -- Newer contracts (RouteProcessor, SushiXSwap) have UNVERIFIED timelock coverage
- [ ] Pre-signed transaction risk? -- N/A (EVM, not Solana)
- [x] Social engineering surface area (anon multisig signers)? -- Signers are pseudonymous, community-elected

### Euler/Mango-type (Oracle + Economic Manipulation):
- [x] Low-liquidity collateral accepted? -- Many pools across 30+ chains have negligible liquidity, exploitable for price manipulation
- [ ] Single oracle source without TWAP? -- AMM is self-pricing
- [ ] No circuit breaker on price movements? -- No circuit breaker, but AMM design limits impact
- [x] Insufficient insurance fund relative to TVL? -- No dedicated insurance fund

### Ronin/Harmony-type (Bridge + Key Compromise):
- [ ] Bridge dependency with centralized validators? -- LayerZero/Stargate is relatively decentralized
- [x] Admin keys stored in hot wallets? -- UNVERIFIED; multisig key storage practices not disclosed
- [x] No key rotation policy? -- No published key rotation policy found

**Pattern Match Summary:** SushiSwap shows 8 out of 18 indicators flagged, with concentration in governance weakness and operational security gaps. The protocol does not closely match the Drift-type pattern (governance + oracle attack) but shows Ronin/Harmony-type indicators around key management opacity and multi-chain admin control.

## Information Gaps

- **Current multisig signer identities and key storage practices**: The specific individuals behind the Treasury (4/6) and Operations (3/N) multisigs are not publicly documented with verified identities
- **Timelock coverage on post-2020 contracts**: Whether RouteProcessor7, SushiXSwap, and V3 Factory contracts are behind a timelock is UNVERIFIED
- **Audit status of current production contracts**: No public audit reports found for RouteProcessor3-7, SushiXSwap, or SushiSwap V3 modifications
- **GoPlus token security data**: API was rate-limited during this audit; automated token contract analysis could not be completed
- **SEC subpoena resolution**: The outcome of the March 2023 SEC investigation is not publicly documented
- **Per-chain admin key configuration**: Whether each of the 38+ chain deployments has independent admin controls or shares a single multisig
- **Emergency pause mechanism**: Whether newer contracts have circuit breakers or pause functionality
- **Treasury composition and runway**: Current treasury holdings and burn rate under new McCurry/Synthesis leadership
- **Insurance/backstop mechanism**: Whether any user fund protection exists beyond the general treasury
- **Key rotation and operational security policies**: No published information on how admin keys are managed, rotated, or secured

## Disclaimer

This analysis is based on publicly available information and web research.
It is NOT a formal smart contract audit. Always DYOR and consider
professional auditing services for investment decisions.
