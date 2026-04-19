# DeFi Security Audit: Kelp DAO -- Post-Exploit Analysis (2026-04-19)

## Status: EXPLOITED

- Protocol: Kelp DAO (part of KernelDAO ecosystem)
- Chain: Ethereum (primary) + 16 L2 chains via LayerZero OFT
- Type: Liquid Restaking (EigenLayer)
- TVL (pre-exploit): $1,258,124,492
- TVL (post-exploit): TBD -- protocol paused, rsETH peg under pressure
- Exploit Date: 2026-04-18 17:35 UTC
- Exploit Amount: $292M (116,500 rsETH, ~18% of circulating supply)
- Report Date: 2026-04-19
- Pre-Hack Audit: [kelp-liquid-restaking.md](kelp-liquid-restaking.md) (2026-04-06, rated MEDIUM)
- Post-Exploit Risk: **CRITICAL**

## What Happened

On April 18, 2026, an attacker exploited Kelp DAO's LayerZero-powered bridge to drain **116,500 rsETH (~$292M)** -- approximately 18% of rsETH's circulating supply. This is the largest DeFi exploit of 2026, surpassing the Drift Protocol hack ($285M).

### Attack Sequence

1. **Funding (~10h before)**: Attacker used Tornado Cash 1-ETH pool for transaction obfuscation
2. **Bridge message spoofing (17:35 UTC)**: Attacker forged a cross-chain message via `lzReceive` on LayerZero's EndpointV2 contract, tricking Kelp's bridge into believing a valid transfer instruction had arrived from another network
3. **rsETH drain**: The spoofed message triggered Kelp's bridge to release 116,500 rsETH to an attacker-controlled address
4. **DeFi composability cascade**: Attacker deposited stolen rsETH as collateral on Aave V3, Compound V3, and Euler, and borrowed WETH against it. Since the drained rsETH was no longer backed by real underlying assets, the collateral was effectively worthless
5. **Bad debt creation**: The attacker built $236M+ in debt positions that cannot be liquidated through normal mechanisms. On-chain data shows ~74,000 ETH consolidated post-exploit
6. **Failed follow-ups (18:26, 18:28 UTC)**: Two additional attempts for 40,000 rsETH each (~$100M) both reverted -- same LayerZero packet format

### Response Timeline

| Time (UTC) | Event |
|------------|-------|
| 17:35 | Exploit executed -- 116,500 rsETH drained |
| ~14:52 | First flagged by ZachXBT |
| 18:21 | Kelp emergency pauser multisig froze core contracts (**46 minutes after drain**) |
| 18:26, 18:28 | Two follow-up drain attempts reverted |
| Hours later | Aave froze rsETH markets on V3 and V4 |
| Hours later | SparkLend, Fluid, Upshift froze rsETH markets |

### Cascade Impact

- rsETH on 20+ L2 chains now potentially unbacked (bridge held reserves backing all L2 rsETH)
- Aave carrying ~$290M in bad debt from unbacked rsETH collateral
- AAVE token fell ~10% on the news
- SparkLend, Fluid, Upshift all froze rsETH markets
- rsETH peg under severe pressure; redemption ability in doubt

## Attack Pattern: Bridge Message Spoofing + Composability Cascade

This exploit represents a **new attack pattern** not fully covered by existing categories (Ronin/Harmony-type covers bridge key compromise, not message spoofing):

```
Bridge Spoofing        →  Unbacked Token Minting  →  Lending Collateral  →  Borrow Real Assets
(forge lzReceive)         (116,500 rsETH)             (Aave/Compound/Euler)   (74,000 ETH out)
                                                                               ↓
                                                                          Bad Debt Cascade
                                                                          ($290M+ across protocols)
```

**Key insight**: The attacker does not need to keep or sell the stolen tokens. By using them as collateral in lending protocols, the damage cascades far beyond the initially exploited protocol. Protocols that were never directly exploited (Aave, Compound, Euler) absorb the loss.

### Pattern Indicators (for future detection)

1. Protocol uses cross-chain bridge for token minting or reserve release
2. Bridge message validation relies on single messaging layer without independent verification
3. DVN/relayer/verifier configuration not publicly documented or auditable
4. No rate limiting on bridge-released token volume per transaction or time window
5. Bridged token accepted as collateral on lending protocols
6. No circuit breaker to pause if bridge-released volume exceeds normal thresholds
7. Emergency pause response time > 15 minutes
8. Token deployed on 5+ chains via same bridge provider (single point of failure)

## Pre-Hack Audit Retrospective

The [pre-hack audit](kelp-liquid-restaking.md) (2026-04-06) correctly identified several risk factors but underweighted them:

### Correctly Identified

| Finding | Pre-Hack Rating | Should Have Been |
|---------|----------------|-----------------|
| LayerZero single bridge dependency across 16 chains | MEDIUM | HIGH |
| DVN configuration UNVERIFIED | Information Gap | HIGH flag |
| "Whether cross-chain OFT deployments are under same 6/8 multisig" | Information Gap | Should have escalated to HIGH |
| Ronin/Harmony pattern: "Bridge dependency with centralized validators" | PARTIAL match | Should have been weighted higher |

### Missed or Underweighted

1. **Cross-chain bridge risk should have been HIGH, not MEDIUM** -- 16-chain deployment via single bridge provider was a critical concentration risk that warranted 2x weight
2. **Did not model the composability cascade** -- the pre-hack audit did not consider the scenario where stolen/unbacked tokens get deposited as collateral in lending protocols to amplify damage
3. **Overall risk should have been HIGH** -- if bridge had been rated HIGH (bridge HIGH + economic MEDIUM = 2 HIGHs → Overall HIGH per aggregation rule)
4. **46-minute response time was not flagged** -- emergency pause capability existed but no benchmark for acceptable response time was applied
5. **No assessment of downstream lending exposure** -- the report did not check whether rsETH was accepted as collateral on Aave/Compound/Euler and what the cascade risk would be

### Lessons for the Skill

These gaps led to the following skill updates:

1. **New attack pattern added**: Kelp-type (Bridge Message Spoofing + Composability Cascade)
2. **Cross-Chain & Bridge now 2x weight** when protocol is deployed on 5+ chains
3. **New triage flags**: bridge token as lending collateral, single bridge provider on 5+ chains
4. **Emergency response time benchmark** added to Step 7
5. **Downstream lending exposure** check added to Step 7.3
6. **Off-chain controls assessment** added (Step 7.4) per team feedback

## Risk Summary (Post-Exploit)

| Category | Risk Level | Key Concern | Source | Verified? |
|----------|-----------|-------------|--------|-----------|
| Governance & Admin | LOW | 6/8 multisig with 10-day timelock; governance was not the attack vector | S | Y |
| Oracle & Price Feeds | MEDIUM | Single Chainlink; hardcoded stETH/ETH = 1 | S | Partial |
| Economic Mechanism | HIGH | $292M drained; rsETH peg broken; no insurance fund for losses | S/H | Y |
| Smart Contract | LOW | Core contracts not exploited; bridge integration was the vector | S | Y |
| Token Contract (GoPlus) | LOW | Token contract itself was not compromised | S | Y |
| Cross-Chain & Bridge | **CRITICAL** | **EXPLOITED: LayerZero bridge message spoofing drained 116,500 rsETH** | S/H | Y |
| Off-Chain Security | MEDIUM | 46-min response time; no published off-chain security certifications | O | Partial |
| Operational Security | MEDIUM | Doxxed team but emergency response too slow for bridge exploit | S/O | Partial |
| **Overall Risk** | **CRITICAL** | **$292M exploited + $290M+ bad debt cascade across Aave/Compound/Euler** | | |

## Peer Comparison (Post-Exploit Context)

| Feature | Kelp DAO | Drift Protocol | Radiant Capital |
|---------|----------|---------------|-----------------|
| Exploit Date | 2026-04-18 | 2026-04-01 | 2024-10-16 |
| Amount Lost | $292M | $285M | $50M+ |
| Attack Vector | Bridge message spoofing | Governance + oracle + social engineering | DPRK social engineering + key compromise |
| Root Cause | LayerZero DVN/validation bypass | 2/5 multisig, no timelock, arbitrary oracle | Compromised signer devices via malware |
| On-chain vs Off-chain | On-chain (bridge layer) | Hybrid (governance + social) | Off-chain (device compromise) |
| Response Time | 46 minutes | ~12 minutes | Hours |
| Cascade Damage | $290M+ bad debt on Aave/Compound/Euler | Contained to Drift | Contained to Radiant |
| Pre-hack audit rating | MEDIUM (underweighted bridge) | CRITICAL (correctly identified) | HIGH |

## Recommendations

### For rsETH holders (immediate)
- Monitor Kelp's official channels for recovery plan and timeline
- rsETH on L2 chains may be unbacked -- do NOT assume 1:1 redemption
- If holding rsETH as collateral on lending protocols, assess liquidation risk

### For lending protocols
- Implement **collateral circuit breakers**: automatically freeze a collateral type if its backing protocol pauses or if bridge volume anomalies are detected
- Require cross-chain tokens to have **rate-limited bridges** before accepting as collateral
- Monitor bridge health as an oracle input for collateral risk parameters

### For bridge-dependent protocols
- **Multi-DVN verification**: require 2+ independent verification networks, not just LayerZero default
- **Rate limiting**: cap per-transaction and per-hour bridge release volumes (e.g., max 5% of reserves per hour)
- **Emergency pause < 15 minutes**: automated monitoring + rapid-response pause mechanism
- **Publicly document DVN configuration**: which verifiers, what threshold, how they're selected
- **Bridge admin governance**: ensure bridge config (trusted remotes, rate limits) is under same timelock as core protocol

### For the skill
- The Kelp exploit validates that bridge risk should receive 2x weight for multi-chain protocols
- Composability cascade risk (stolen tokens → lending collateral → bad debt) is a distinct risk category that must be assessed independently
- "Information Gap" items about bridge configuration should automatically escalate to HIGH risk, not just be listed

## Sources

- [CoinDesk: 2026's biggest crypto exploit -- $292M drained from Kelp DAO](https://www.coindesk.com/tech/2026/04/19/2026-s-biggest-crypto-exploit-kelp-dao-hit-for-usd292-million-with-wrapped-ether-stranded-across-20-chains)
- [CryptoBriefing: Kelp DAO hit by $292M bridge hack](https://cryptobriefing.com/kelp-dao-bridge-hack-292m-loss/)
- [DL News: Hackers target DeFi protocol Kelp DAO in massive $300m exploit](https://www.dlnews.com/articles/defi/kelp-dao-defi-protocol-hacked-for-300-million/)
- [Bitcoin.com: ZachXBT flags $280M+ KelpDAO exploit](https://news.bitcoin.com/zachxbt-flags-280m-kelpdao-exploit-hitting-ethereum-defi-lending-markets/)
- [StartupFortune: KelpDAO rsETH exploit creates $290M bad debt on Aave](https://startupfortune.com/kelpdao-rseth-exploit-creates-290m-bad-debt-on-aave/)
- [LiveBitcoinNews: Kelp DAO's rsETH bridge hit by $292M exploit](https://www.livebitcoinnews.com/kelp-daos-rseth-bridge-hit-by-292m-exploit-in-suspected-layerzero-attack/)

## Disclaimer

This analysis is based on publicly available information as of 2026-04-19. The investigation is ongoing -- the specific vulnerability in LayerZero's validation logic has not been publicly disclosed. Details may change as post-mortem reports are released. This is NOT a formal smart contract audit. Always DYOR.
