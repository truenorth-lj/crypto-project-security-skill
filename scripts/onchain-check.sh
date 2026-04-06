#!/usr/bin/env bash
#
# onchain-check.sh -- On-chain verification for DeFi security audits
#
# Queries public blockchain APIs to verify multisig configuration, contract
# verification status, program upgrade authority, and account metadata.
#
# Usage:
#   ./scripts/onchain-check.sh safe            <safe_address> [chain]
#   ./scripts/onchain-check.sh etherscan       <contract_address> <chain_id> [api_key]
#   ./scripts/onchain-check.sh solana-program  <program_id>
#   ./scripts/onchain-check.sh solana-account  <address>
#
# Subcommands:
#   safe            Query Gnosis Safe Transaction Service for multisig config
#   etherscan       Query Etherscan-family APIs for contract verification/proxy
#   solana-program  Query Solana RPC for program upgrade authority
#   solana-account  Query SolanaFM for account type and label
#
# Chain names (safe):  ethereum, arbitrum, polygon, optimism, base, gnosis,
#                      avalanche, scroll, linea, zksync, celo
#
# Chain IDs (etherscan): 1=Ethereum, 56=BSC, 137=Polygon, 42161=Arbitrum,
#                        10=Optimism, 43114=Avalanche, 8453=Base, 324=zkSync
#
# Examples:
#   ./scripts/onchain-check.sh safe 0xA9BE...1234 ethereum
#   ./scripts/onchain-check.sh etherscan 0xdAC1...ec7 1 YourApiKey
#   ./scripts/onchain-check.sh solana-program PERPHjGBqRHArX4DySjwM6UJHiR3sWAatqfdBS2qQJu
#   ./scripts/onchain-check.sh solana-account 5ZZkJcs...abc

set -euo pipefail

# ─── Common utilities ──────────────────────────────────────────────

fmt() {
    if command -v jq &>/dev/null; then
        jq .
    else
        cat
    fi
}

# Fetch with automatic retry (matches goplus-check.sh pattern)
fetch() {
    local url="$1"
    local response
    response=$(curl -sL --max-time 15 "$url" 2>/dev/null) || true
    if [ -z "$response" ]; then
        echo "First request failed, retrying in 5s..." >&2
        sleep 5
        response=$(curl -sL --max-time 15 "$url" 2>/dev/null) || true
        if [ -z "$response" ]; then
            echo "Error: API unavailable after retry" >&2
            echo '{"error": "API unavailable"}'
            return 1
        fi
    fi
    echo "$response"
}

# POST request with retry (for Solana JSON-RPC)
fetch_post() {
    local url="$1"
    local data="$2"
    local response
    response=$(curl -s --max-time 15 -X POST -H "Content-Type: application/json" -d "$data" "$url" 2>/dev/null) || true
    if [ -z "$response" ]; then
        echo "First request failed, retrying in 5s..." >&2
        sleep 5
        response=$(curl -s --max-time 15 -X POST -H "Content-Type: application/json" -d "$data" "$url" 2>/dev/null) || true
        if [ -z "$response" ]; then
            echo "Error: RPC unavailable after retry" >&2
            echo '{"error": "RPC unavailable"}'
            return 1
        fi
    fi
    echo "$response"
}

validate_evm_address() {
    local addr="$1"
    if [[ ! "$addr" =~ ^0x[0-9a-fA-F]{40}$ ]]; then
        echo "Warning: '$addr' does not look like a valid EVM address (expected 0x + 40 hex chars)" >&2
    fi
}

# Compute EIP-55 checksummed address (Safe API requires it)
checksum_address() {
    local addr="$1"
    local raw="${addr#0x}"

    # Strict validation: only hex chars allowed (prevents code injection into Python/Node)
    if [[ ! "$raw" =~ ^[0-9a-fA-F]{40}$ ]]; then
        echo "Error: invalid address for checksum: '$addr'" >&2
        echo "$addr"
        return 1
    fi

    # EIP-55 uses Keccak-256 (NOT NIST SHA3-256)
    if command -v python3 &>/dev/null; then
        python3 -c "
import sys, os
addr = sys.argv[1].lower()
try:
    from web3 import Web3
    print(Web3.to_checksum_address('0x' + addr))
    sys.exit(0)
except ImportError:
    pass
try:
    from Crypto.Hash import keccak
    h = keccak.new(digest_bits=256, data=addr.encode()).hexdigest()
except ImportError:
    try:
        import _pysha3 as sha3
        h = sha3.keccak_256(addr.encode()).hexdigest()
    except ImportError:
        print('0x' + addr)
        sys.exit(0)
result = '0x'
for i, c in enumerate(addr):
    if c in '0123456789':
        result += c
    elif int(h[i], 16) >= 8:
        result += c.upper()
    else:
        result += c.lower()
print(result)
" "$raw" 2>/dev/null
    elif command -v node &>/dev/null; then
        node -e "
const addr = process.argv[1].toLowerCase();
try {
    const { getAddress } = require('ethers');
    console.log(getAddress('0x' + addr));
} catch {
    console.log('0x' + addr);
}
" "$raw" 2>/dev/null
    else
        echo "$addr"
    fi
}

validate_solana_address() {
    local addr="$1"
    if [[ ! "$addr" =~ ^[1-9A-HJ-NP-Za-km-z]{32,44}$ ]]; then
        echo "Warning: '$addr' does not look like a valid Solana address (expected base58, 32-44 chars)" >&2
    fi
}

usage() {
    echo "Usage:"
    echo "  $0 safe            <safe_address> [chain]                 Gnosis Safe multisig config"
    echo "  $0 etherscan       <contract_address> <chain_id> [api_key] Contract verification & proxy"
    echo "  $0 solana-program  <program_id>                           Program upgrade authority"
    echo "  $0 solana-account  <address>                              Account type via SolanaFM"
    echo ""
    echo "Chain names (safe): ethereum, arbitrum, polygon, optimism, base, gnosis, avalanche"
    echo "Chain IDs (etherscan): 1=Ethereum, 56=BSC, 137=Polygon, 42161=Arbitrum, 10=Optimism, 8453=Base"
    exit 1
}

# ─── safe: Gnosis Safe Transaction Service ─────────────────────────

# Map chain name to Safe Transaction Service subdomain
safe_service_url() {
    local chain="$1"
    case "$chain" in
        ethereum|mainnet|eth)
            echo "https://safe-transaction-mainnet.safe.global" ;;
        arbitrum|arb)
            echo "https://safe-transaction-arbitrum.safe.global" ;;
        polygon|matic)
            echo "https://safe-transaction-polygon.safe.global" ;;
        optimism|op)
            echo "https://safe-transaction-optimism.safe.global" ;;
        base)
            echo "https://safe-transaction-base.safe.global" ;;
        gnosis|xdai)
            echo "https://safe-transaction-gnosis-chain.safe.global" ;;
        avalanche|avax)
            echo "https://safe-transaction-avalanche.safe.global" ;;
        scroll)
            echo "https://safe-transaction-scroll.safe.global" ;;
        linea)
            echo "https://safe-transaction-linea.safe.global" ;;
        zksync)
            echo "https://safe-transaction-zksync.safe.global" ;;
        celo)
            echo "https://safe-transaction-celo.safe.global" ;;
        bsc|bnb)
            echo "https://safe-transaction-bsc.safe.global" ;;
        *)
            echo "Error: unknown chain '$chain'. Use: ethereum, arbitrum, polygon, optimism, base, gnosis, avalanche, bsc, scroll, linea, zksync, celo" >&2
            return 1 ;;
    esac
}

cmd_safe() {
    local address="${1:-}"
    local chain="${2:-ethereum}"

    if [ -z "$address" ]; then
        echo "Error: safe address required"
        echo "Usage: $0 safe <safe_address> [chain]"
        exit 1
    fi

    validate_evm_address "$address"

    # EIP-55 checksum required by Safe API
    local checksummed
    checksummed=$(checksum_address "$address")
    if [ -n "$checksummed" ]; then
        address="$checksummed"
    fi

    local base_url
    base_url=$(safe_service_url "$chain") || exit 1

    echo "Querying Safe Transaction Service..."
    echo "Address: $address | Chain: $chain"
    echo ""

    local response
    response=$(fetch "${base_url}/api/v1/safes/${address}/")

    # Check for error (404 = not a Safe, 422 = checksum error, etc.)
    if echo "$response" | jq -e '.detail // .code // .error' &>/dev/null 2>&1; then
        local has_threshold
        has_threshold=$(echo "$response" | jq -r '.threshold // empty' 2>/dev/null)
        if [ -z "$has_threshold" ]; then
            local err
            err=$(echo "$response" | jq -r '.detail // .message // .error // "Unknown error"')
            echo "Error from Safe API: $err"
            echo ""
            echo "This address may not be a Gnosis Safe on $chain, or the address checksum is incorrect."
            echo "Try converting to checksummed format: https://ethsum.netlify.app/"
            return 1
        fi
    fi

    if ! command -v jq &>/dev/null; then
        echo "$response"
        echo ""
        echo "(install jq for formatted summary)"
        return
    fi

    # Parse Safe data
    local threshold owners_count nonce fallback_handler version guard
    threshold=$(echo "$response" | jq -r '.threshold // "unknown"')
    owners_count=$(echo "$response" | jq -r '.owners | length // 0')
    nonce=$(echo "$response" | jq -r '.nonce // "unknown"')
    fallback_handler=$(echo "$response" | jq -r '.fallbackHandler // "none"')
    version=$(echo "$response" | jq -r '.version // "unknown"')
    guard=$(echo "$response" | jq -r '.guard // "none"')

    echo "========================================="
    echo " Safe Multisig Verification"
    echo "========================================="
    echo ""
    echo "Safe Version:  $version"
    echo "Threshold:     $threshold / $owners_count"
    echo "Tx Count:      $nonce"
    echo ""

    # List owners
    echo "Owners ($owners_count):"
    echo "$response" | jq -r '.owners[]' | while read -r owner; do
        echo "  $owner"
    done
    echo ""

    # Modules (if any)
    local modules_count
    modules_count=$(echo "$response" | jq -r '.modules | length // 0')
    if [ "$modules_count" -gt 0 ]; then
        echo "Modules ($modules_count):"
        echo "$response" | jq -r '.modules[]' | while read -r mod; do
            echo "  $mod"
        done
        echo ""
    fi

    # Guard
    if [ "$guard" != "none" ] && [ "$guard" != "null" ] && [ "$guard" != "0x0000000000000000000000000000000000000000" ]; then
        echo "Guard: $guard"
        echo ""
    fi

    # Risk assessment
    echo "-----------------------------------------"
    echo " Risk Assessment"
    echo "-----------------------------------------"

    if [ "$threshold" = "unknown" ]; then
        echo "  [?] Threshold could not be determined"
    elif [ "$threshold" -le 1 ]; then
        echo "  [!] CRITICAL: Single-signer Safe ($threshold/$owners_count) -- equivalent to EOA"
    elif [ "$threshold" -le 2 ] && [ "$owners_count" -ge 4 ]; then
        echo "  [!] HIGH: Low threshold ($threshold/$owners_count) -- vulnerable to social engineering (Drift-type attack)"
    elif [ "$threshold" -le 2 ]; then
        echo "  [~] MEDIUM: Threshold $threshold/$owners_count -- consider increasing"
    else
        local ratio
        ratio=$(echo "$threshold $owners_count" | awk '{printf "%.0f", ($1/$2)*100}')
        if [ "$ratio" -ge 60 ]; then
            echo "  [+] LOW: Good threshold ($threshold/$owners_count, ${ratio}%)"
        else
            echo "  [~] MEDIUM: Threshold $threshold/$owners_count (${ratio}%) -- could be higher"
        fi
    fi

    if [ "$modules_count" -gt 0 ]; then
        echo "  [~] MEDIUM: $modules_count module(s) attached -- modules can bypass threshold requirement"
    fi

    if [ "$owners_count" -le 2 ]; then
        echo "  [~] MEDIUM: Only $owners_count owners -- limited key compromise resilience"
    fi

    echo ""
    echo "========================================="
}

# ─── etherscan: Contract verification & proxy detection ────────────

# Map chain_id to block explorer API base URL
etherscan_api_url() {
    local chain_id="$1"
    case "$chain_id" in
        1)      echo "https://api.etherscan.io/api" ;;
        56)     echo "https://api.bscscan.com/api" ;;
        137)    echo "https://api.polygonscan.com/api" ;;
        42161)  echo "https://api.arbiscan.io/api" ;;
        10)     echo "https://api-optimistic.etherscan.io/api" ;;
        43114)  echo "https://api.snowtrace.io/api" ;;
        8453)   echo "https://api.basescan.org/api" ;;
        324)    echo "https://api-era.zksync.network/api" ;;
        59144)  echo "https://api.lineascan.build/api" ;;
        534352) echo "https://api.scrollscan.com/api" ;;
        *)
            echo "Error: unsupported chain_id '$chain_id' for Etherscan API" >&2
            echo "Supported: 1=Ethereum, 56=BSC, 137=Polygon, 42161=Arbitrum, 10=Optimism, 43114=Avalanche, 8453=Base, 324=zkSync" >&2
            return 1 ;;
    esac
}

cmd_etherscan() {
    local address="${1:-}"
    local chain_id="${2:-}"
    local api_key="${3:-}"

    if [ -z "$address" ] || [ -z "$chain_id" ]; then
        echo "Error: contract address and chain_id required"
        echo "Usage: $0 etherscan <contract_address> <chain_id> [api_key]"
        exit 1
    fi

    validate_evm_address "$address"

    if [ -z "$api_key" ]; then
        # Check environment variable
        api_key="${ETHERSCAN_API_KEY:-}"
    fi

    # Try loading from .env file if still missing
    if [ -z "$api_key" ]; then
        local env_file
        for env_file in ".env" "../.env" "${BASH_SOURCE[0]%/*}/../.env"; do
            if [ -f "$env_file" ]; then
                local loaded
                loaded=$(grep -E '^ETHERSCAN_API_KEY=' "$env_file" 2>/dev/null | head -1 | cut -d'=' -f2- | tr -d '"'"'" )
                if [ -n "$loaded" ]; then
                    api_key="$loaded"
                    break
                fi
            fi
        done
    fi

    if [ -z "$api_key" ]; then
        echo "=========================================" >&2
        echo " ERROR: Etherscan API key required" >&2
        echo "=========================================" >&2
        echo "" >&2
        echo "Contract verification and proxy detection require an Etherscan API key." >&2
        echo "This is a FREE key (5 calls/sec). Without it, a critical verification" >&2
        echo "step will be skipped entirely." >&2
        echo "" >&2
        echo "Setup (choose one):" >&2
        echo "  1. Add to .env file:   echo 'ETHERSCAN_API_KEY=your_key' >> .env" >&2
        echo "  2. Export in shell:     export ETHERSCAN_API_KEY=your_key" >&2
        echo "  3. Pass as argument:    $0 etherscan <addr> <chain_id> <api_key>" >&2
        echo "" >&2
        echo "Get a free key at: https://etherscan.io/myapikey" >&2
        echo "See .env.example for all configurable keys." >&2
        echo "=========================================" >&2
        echo ""
        echo "RESULT: UNAVAILABLE (no API key -- see instructions above)"
        return 1
    fi

    local base_url
    base_url=$(etherscan_api_url "$chain_id") || exit 1

    echo "Querying Etherscan API..."
    echo "Address: $address | Chain ID: $chain_id"
    echo ""

    # Get source code info (includes proxy detection, verification status)
    local response
    response=$(fetch "${base_url}?module=contract&action=getsourcecode&address=${address}&apikey=${api_key}")

    # Check API response status
    local status
    status=$(echo "$response" | jq -r '.status // "0"' 2>/dev/null)
    if [ "$status" != "1" ]; then
        local message
        message=$(echo "$response" | jq -r '.message // .result // "Unknown error"' 2>/dev/null)
        echo "Etherscan API error: $message"
        return 1
    fi

    if ! command -v jq &>/dev/null; then
        echo "$response"
        echo "(install jq for formatted summary)"
        return
    fi

    local r=".result[0]"
    local contract_name source_verified proxy implementation compiler_version
    contract_name=$(echo "$response" | jq -r "$r.ContractName // \"unknown\"")
    source_verified=$(echo "$response" | jq -r "$r.ABI" | grep -q "Contract source code not verified" && echo "NO" || echo "YES")
    proxy=$(echo "$response" | jq -r "$r.Proxy // \"0\"")
    implementation=$(echo "$response" | jq -r "$r.Implementation // \"\"")
    compiler_version=$(echo "$response" | jq -r "$r.CompilerVersion // \"unknown\"")

    echo "========================================="
    echo " Etherscan Contract Verification"
    echo "========================================="
    echo ""
    echo "Contract Name:    $contract_name"
    echo "Source Verified:  $source_verified"
    echo "Compiler:         $compiler_version"
    echo "Proxy:            $([ "$proxy" = "1" ] && echo "YES" || echo "NO")"

    if [ -n "$implementation" ] && [ "$implementation" != "" ] && [ "$implementation" != "null" ]; then
        echo "Implementation:   $implementation"
    fi

    echo ""

    # Risk assessment
    echo "-----------------------------------------"
    echo " Risk Assessment"
    echo "-----------------------------------------"

    if [ "$source_verified" = "NO" ]; then
        echo "  [!] HIGH: Contract source code NOT verified -- cannot audit code"
    else
        echo "  [+] LOW: Source code verified on block explorer"
    fi

    if [ "$proxy" = "1" ]; then
        echo "  [~] MEDIUM: Upgradeable proxy -- admin can change implementation"
        if [ -n "$implementation" ] && [ "$implementation" != "null" ]; then
            echo "       Implementation: $implementation"
            echo "       Verify the implementation is also source-verified"
        fi
    fi

    if [ "$contract_name" = "unknown" ] || [ "$contract_name" = "" ]; then
        echo "  [~] INFO: Contract name unknown -- may not be verified"
    fi

    echo ""
    echo "========================================="
}

# ─── solana-program: Program upgrade authority via RPC ─────────────

SOLANA_RPC="${SOLANA_RPC_URL:-https://api.mainnet-beta.solana.com}"

cmd_solana_program() {
    local program_id="${1:-}"

    if [ -z "$program_id" ]; then
        echo "Error: program ID required"
        echo "Usage: $0 solana-program <program_id>"
        exit 1
    fi

    validate_solana_address "$program_id"

    echo "Querying Solana RPC for program info..."
    echo "Program: $program_id"
    echo "RPC: $SOLANA_RPC"
    echo ""

    # First, try using solana CLI if available
    if command -v solana &>/dev/null; then
        echo "Using solana CLI..."
        echo ""
        local cli_output
        cli_output=$(solana program show "$program_id" --url mainnet-beta 2>&1) || true

        if echo "$cli_output" | grep -q "Authority"; then
            echo "========================================="
            echo " Solana Program Verification (CLI)"
            echo "========================================="
            echo ""
            echo "$cli_output"
            echo ""

            # Extract authority
            local authority
            authority=$(echo "$cli_output" | grep -i "authority" | head -1 | awk '{print $NF}')

            echo "-----------------------------------------"
            echo " Risk Assessment"
            echo "-----------------------------------------"

            if [ "$authority" = "None" ] || [ "$authority" = "none" ]; then
                echo "  [+] LOW: Program is FROZEN (no upgrade authority) -- immutable"
                echo "       Cannot be upgraded (eliminates admin key risk, but prevents bug fixes)"
            else
                echo "  [~] INFO: Upgrade authority: $authority"
                echo "       Run: $0 solana-account $authority"
                echo "       to determine if this is a multisig (Squads) or EOA"
            fi

            echo ""
            echo "========================================="
            return
        fi
    fi

    # Fallback: use RPC directly
    echo "solana CLI not found, using RPC directly..."
    echo ""

    # Get account info for the program
    local rpc_data
    rpc_data=$(cat <<RPCEOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "getAccountInfo",
    "params": [
        "$program_id",
        {"encoding": "jsonParsed"}
    ]
}
RPCEOF
)

    local response
    response=$(fetch_post "$SOLANA_RPC" "$rpc_data")

    # Check for error
    if echo "$response" | jq -e '.error' &>/dev/null 2>&1; then
        local err
        err=$(echo "$response" | jq -r '.error.message // "Unknown RPC error"')
        echo "RPC Error: $err"
        return 1
    fi

    if ! command -v jq &>/dev/null; then
        echo "$response"
        echo "(install jq for formatted summary)"
        return
    fi

    local owner executable data_len
    owner=$(echo "$response" | jq -r '.result.value.owner // "unknown"')
    executable=$(echo "$response" | jq -r '.result.value.executable // false')
    data_len=$(echo "$response" | jq -r '.result.value.data | length // 0' 2>/dev/null || echo "unknown")

    echo "========================================="
    echo " Solana Program Verification (RPC)"
    echo "========================================="
    echo ""
    echo "Program ID:   $program_id"
    echo "Owner:        $owner"
    echo "Executable:   $executable"
    echo ""

    if [ "$executable" = "true" ]; then
        echo "This is an executable program."
        echo ""
        echo "NOTE: The upgrade authority is stored in the program's data account,"
        echo "not directly in this response. To get the full authority info:"
        echo "  1. Install solana CLI: sh -c \"\$(curl -sSfL https://release.anza.xyz/stable/install)\""
        echo "  2. Run: solana program show $program_id --url mainnet-beta"
        echo ""
        echo "Or check Solana Explorer:"
        echo "  https://explorer.solana.com/address/$program_id"
    else
        echo "This address is NOT an executable program."
    fi

    echo ""
    echo "-----------------------------------------"
    echo " Risk Assessment"
    echo "-----------------------------------------"

    if [ "$owner" = "BPFLoaderUpgradeab1e11111111111111111111111" ]; then
        echo "  [~] INFO: Uses BPF Upgradeable Loader -- program MAY be upgradeable"
        echo "       Authority must be checked via 'solana program show' or Explorer"
    elif [ "$owner" = "BPFLoader2111111111111111111111111111111111" ]; then
        echo "  [+] LOW: Uses BPF Loader v2 -- program is IMMUTABLE"
    else
        echo "  [?] Owner program: $owner -- unknown loader type"
    fi

    echo ""
    echo "========================================="
}

# ─── solana-account: Account metadata via SolanaFM ─────────────────

cmd_solana_account() {
    local address="${1:-}"

    if [ -z "$address" ]; then
        echo "Error: Solana address required"
        echo "Usage: $0 solana-account <address>"
        exit 1
    fi

    validate_solana_address "$address"

    echo "Querying SolanaFM for account info..."
    echo "Address: $address"
    echo ""

    local response
    response=$(fetch "https://api.solana.fm/v0/accounts/${address}")

    # Check for error (non-JSON response, API errors, or empty results)
    local is_valid_json
    is_valid_json=$(echo "$response" | jq -e '.' &>/dev/null 2>&1 && echo "yes" || echo "no")

    if [ "$is_valid_json" = "no" ] || echo "$response" | jq -e '.error // .message // .status_code' &>/dev/null 2>&1; then
        # SolanaFM might not have it, try alternative info
        echo "SolanaFM returned no data for this address."
        echo ""
        echo "Alternative verification methods:"
        echo "  1. Solana Explorer: https://explorer.solana.com/address/$address"
        echo "  2. SolanaFM:        https://solana.fm/address/$address"
        echo "  3. Squads UI:       https://v4.squads.so/"
        echo ""

        # Try to at least get basic account info via RPC
        echo "Falling back to RPC getAccountInfo..."
        echo ""

        local rpc_data
        rpc_data=$(cat <<RPCEOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "getAccountInfo",
    "params": [
        "$address",
        {"encoding": "jsonParsed"}
    ]
}
RPCEOF
)

        local rpc_response
        rpc_response=$(fetch_post "$SOLANA_RPC" "$rpc_data")

        if ! command -v jq &>/dev/null; then
            echo "$rpc_response"
            return
        fi

        local owner executable lamports
        owner=$(echo "$rpc_response" | jq -r '.result.value.owner // "unknown"')
        executable=$(echo "$rpc_response" | jq -r '.result.value.executable // false')
        lamports=$(echo "$rpc_response" | jq -r '.result.value.lamports // 0')

        echo "========================================="
        echo " Solana Account Info (RPC Fallback)"
        echo "========================================="
        echo ""
        echo "Address:     $address"
        echo "Owner:       $owner"
        echo "Executable:  $executable"
        echo "Balance:     $(echo "$lamports" | awk '{printf "%.4f SOL", $1/1000000000}')"
        echo ""

        # Detect known program owners
        echo "-----------------------------------------"
        echo " Account Type Detection"
        echo "-----------------------------------------"

        case "$owner" in
            "SMPLecH534Ngo6gTACwFvEq4QYHGBqR1sFoJGDhrknp"|"SQDS4ep65T869zMMBKyuUq6aD6EgTu8psMjkvj52pCf")
                echo "  [+] VERIFIED: This is a Squads v4 multisig account"
                echo "       Squads UI: https://v4.squads.so/"
                echo "       The multisig threshold and members can be viewed there"
                ;;
            "SMPLKTQhrgo22hFCVq2VGX1KAktTWjeizkhrdB1eauK")
                echo "  [+] VERIFIED: This is a Squads v3 multisig account"
                echo "       Check: https://v3.squads.so/"
                ;;
            "11111111111111111111111111111111")
                echo "  [i] This is a System Program-owned account (regular wallet/EOA)"
                echo "  [!] HIGH: If this is an upgrade authority, it means a SINGLE KEY controls upgrades"
                ;;
            "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
                echo "  [i] This is a Token Program account"
                ;;
            "BPFLoaderUpgradeab1e11111111111111111111111")
                echo "  [i] This is a BPF program data account"
                ;;
            *)
                echo "  [?] Owner program: $owner"
                echo "       Could not automatically determine account type"
                echo "       Check manually: https://explorer.solana.com/address/$address"
                ;;
        esac

        echo ""
        echo "========================================="
        return
    fi

    if ! command -v jq &>/dev/null; then
        echo "$response"
        echo "(install jq for formatted summary)"
        return
    fi

    # Parse SolanaFM response
    local label owner_program
    label=$(echo "$response" | jq -r '.result.data.label // .result.label // "unknown"' 2>/dev/null || echo "unknown")
    owner_program=$(echo "$response" | jq -r '.result.data.ownerProgram // .result.ownerProgram // "unknown"' 2>/dev/null || echo "unknown")

    echo "========================================="
    echo " Solana Account Info (SolanaFM)"
    echo "========================================="
    echo ""
    echo "Address:        $address"
    echo "Label:          $label"
    echo "Owner Program:  $owner_program"
    echo ""

    # Raw response for debugging
    echo "Full response:"
    echo "$response" | jq '.' 2>/dev/null || echo "$response"

    echo ""
    echo "========================================="
}

# ─── Main entry point ──────────────────────────────────────────────

cmd="${1:-}"
[ -z "$cmd" ] && usage

shift

case "$cmd" in
    safe)           cmd_safe "$@" ;;
    etherscan)      cmd_etherscan "$@" ;;
    solana-program) cmd_solana_program "$@" ;;
    solana-account) cmd_solana_account "$@" ;;
    -h|--help)      usage ;;
    *)              echo "Unknown command: $cmd"; echo ""; usage ;;
esac
