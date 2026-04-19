#!/usr/bin/env python3
"""
layerzero-dvn-check.py -- Query LayerZero V2 DVN configurations on-chain.

Reads the DVN verifier setup for any OApp (OFT, OFTAdapter) directly from
LayerZero's SendUln302 and ReceiveUln302 MessageLib contracts on Ethereum.

Usage:
    python scripts/layerzero-dvn-check.py <oapp_address> [--chains CHAIN1,CHAIN2,...] [--rpc URL]

Examples:
    # Check Kelp DAO rsETH OFT Adapter
    python scripts/layerzero-dvn-check.py 0x5e8422345238F34275888049021821E8E08CAa1f

    # Check specific chains only
    python scripts/layerzero-dvn-check.py 0x5e8422345238F34275888049021821E8E08CAa1f --chains arbitrum,base,scroll

Requirements:
    pip install web3
"""

import argparse
import json
import sys

try:
    from web3 import Web3
except ImportError:
    print("Error: web3 not installed. Run: pip install web3", file=sys.stderr)
    sys.exit(1)

# ── Contract addresses (Ethereum mainnet) ─────────────────────────

ENDPOINT_V2 = "0x1a44076050125825900e736c501f859c50fE728c"
SEND_ULN_302 = "0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1"
RECEIVE_ULN_302 = "0xc02Ab410f0734EFa3F14628780e6e695156024C2"

# ── LayerZero V2 Endpoint IDs ─────────────────────────────────────

CHAIN_EIDS = {
    "ethereum": 30101,
    "bsc": 30102,
    "avalanche": 30106,
    "polygon": 30109,
    "arbitrum": 30110,
    "optimism": 30111,
    "base": 30184,
    "scroll": 30214,
    "linea": 30183,
    "blast": 30243,
    "mode": 30260,
    "manta": 30217,
    "mantle": 30181,
    "zksync": 30165,
}

# ── Known DVN addresses ──────────────────────────────────────────

DVN_LABELS = {
    "0x589dEDbD617e0CBcB916A9223F4d1300c294236b": "LayerZero Labs",
    "0xD56e4eAb23cb81f43168F9F45211Eb027b9aC7cc": "Google Cloud",
    "0x8ddf05F9A5c488b4973897E278B58895bF87Cb24": "Polyhedra",
    "0x7E65BDd15C8Db8995F80aBc17c2d2fd5Ff1Ee0C5": "Animoca",
    "0xa59BA433ac34D2927232ECb54B3AFC808238d8C5": "Nethermind",
    "0xDDf0BE73506dE1E1BaF7294dBF92Fd3B0E883B71": "Horizen Labs",
}

_DVN_LOOKUP = {k.lower(): v for k, v in DVN_LABELS.items()}

DEFAULT_RPCS = [
    "https://eth-mainnet.public.blastapi.io",
    "https://eth.drpc.org",
    "https://ethereum.publicnode.com",
    "https://1rpc.io/eth",
]

# ── ABI ──────────────────────────────────────────────────────────

ULN_ABI = [
    {
        "inputs": [
            {"name": "_oapp", "type": "address"},
            {"name": "_remoteEid", "type": "uint32"}
        ],
        "name": "getUlnConfig",
        "outputs": [
            {"components": [
                {"name": "confirmations", "type": "uint64"},
                {"name": "requiredDVNCount", "type": "uint8"},
                {"name": "optionalDVNCount", "type": "uint8"},
                {"name": "optionalDVNThreshold", "type": "uint8"},
                {"name": "requiredDVNs", "type": "address[]"},
                {"name": "optionalDVNs", "type": "address[]"}
            ], "type": "tuple"}
        ],
        "stateMutability": "view",
        "type": "function"
    }
]


def label_dvn(addr: str) -> str:
    name = _DVN_LOOKUP.get(addr.lower(), "Unknown")
    short = addr[:8] + "..." + addr[-4:]
    return f"{short} ({name})"


def assess_risk(req_count: int, opt_count: int, opt_threshold: int) -> str:
    total = req_count + opt_threshold
    if total <= 1:
        return "CRITICAL: 1-of-1 DVN — single node compromise = full bridge exploit"
    elif total == 2 and (req_count + opt_count) <= 2:
        return "HIGH: 2-of-2 DVN — no fault tolerance"
    elif total == 2:
        return f"MEDIUM: 2-of-{req_count + opt_count} DVN"
    else:
        return f"LOW: {total}-of-{req_count + opt_count} DVN"


def find_rpc(rpcs: list) -> Web3:
    for url in rpcs:
        try:
            w3 = Web3(Web3.HTTPProvider(url, request_kwargs={"timeout": 10}))
            if w3.is_connected():
                _ = w3.eth.block_number
                return w3
        except Exception:
            continue
    raise RuntimeError("No working RPC found. Pass --rpc with a valid Ethereum RPC URL.")


def main():
    parser = argparse.ArgumentParser(description="Query LayerZero V2 DVN configurations on-chain")
    parser.add_argument("oapp", help="OApp/OFT contract address")
    parser.add_argument("--chains", default=None, help="Comma-separated chain names (default: all)")
    parser.add_argument("--rpc", default=None, help="Ethereum RPC URL")
    parser.add_argument("--json", action="store_true", help="JSON output")
    args = parser.parse_args()

    if args.rpc:
        w3 = Web3(Web3.HTTPProvider(args.rpc))
        if not w3.is_connected():
            print(f"Error: cannot connect to {args.rpc}", file=sys.stderr)
            sys.exit(1)
    else:
        w3 = find_rpc(DEFAULT_RPCS)

    print(f"Connected to Ethereum (block {w3.eth.block_number})", file=sys.stderr)

    chains = CHAIN_EIDS
    if args.chains:
        names = [c.strip().lower() for c in args.chains.split(",")]
        chains = {n: CHAIN_EIDS[n] for n in names if n in CHAIN_EIDS}

    oapp = Web3.to_checksum_address(args.oapp)
    results = {}
    critical_findings = []

    print(f"\n{'='*60}")
    print(f" LayerZero V2 DVN Configuration Check")
    print(f" OApp: {oapp}")
    print(f"{'='*60}\n")

    send_uln = w3.eth.contract(address=Web3.to_checksum_address(SEND_ULN_302), abi=ULN_ABI)
    recv_uln = w3.eth.contract(address=Web3.to_checksum_address(RECEIVE_ULN_302), abi=ULN_ABI)

    for chain_name, eid in chains.items():
        print(f"--- {chain_name.upper()} (EID {eid}) ---")
        chain_result = {}

        for lib_name, contract in [("Send", send_uln), ("Receive", recv_uln)]:
            try:
                config = contract.functions.getUlnConfig(oapp, eid).call()
                confirmations, req_count, opt_count, opt_threshold, req_dvns, opt_dvns = config

                risk = assess_risk(req_count, opt_count, opt_threshold)

                print(f"  [{lib_name}] Confirmations: {confirmations}")
                print(f"    Required DVNs ({req_count}):")
                for dvn in req_dvns:
                    print(f"      {label_dvn(dvn)}")
                if opt_dvns:
                    print(f"    Optional DVNs ({opt_count}, threshold={opt_threshold}):")
                    for dvn in opt_dvns:
                        print(f"      {label_dvn(dvn)}")
                print(f"    Risk: {risk}")

                if "CRITICAL" in risk:
                    critical_findings.append(f"{chain_name} ({lib_name})")

                chain_result[lib_name] = {
                    "confirmations": confirmations,
                    "requiredDVNCount": req_count,
                    "optionalDVNCount": opt_count,
                    "optionalDVNThreshold": opt_threshold,
                    "requiredDVNs": [str(d) for d in req_dvns],
                    "optionalDVNs": [str(d) for d in opt_dvns],
                    "risk": risk,
                }
            except Exception as e:
                err_msg = str(e)
                if "revert" in err_msg.lower():
                    print(f"  [{lib_name}] Not configured for this chain (or contract paused)")
                else:
                    print(f"  [{lib_name}] Error: {err_msg}")
                chain_result[lib_name] = {"error": err_msg}

        results[chain_name] = chain_result
        print()

    # Summary
    print(f"{'='*60}")
    print(" SUMMARY")
    print(f"{'='*60}")

    if critical_findings:
        print(f"\n  CRITICAL — 1-of-1 DVN on: {', '.join(critical_findings)}")
        print(f"  Single validator compromise = full bridge exploit.")
        print(f"  Recommendation: upgrade to at least 2-of-3 DVN immediately.\n")
    else:
        print(f"\n  No 1-of-1 DVN configurations found.\n")

    if args.json:
        print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
