#!/usr/bin/env bash
#
# goplus-check.sh -- Query GoPlus Security API for token and address risk data
#
# Usage:
#   ./scripts/goplus-check.sh token  <chain_id> <contract_address>
#   ./scripts/goplus-check.sh address <address> [chain_id]
#   ./scripts/goplus-check.sh nft <chain_id> <contract_address>
#   ./scripts/goplus-check.sh approval <chain_id> <contract_address>
#   ./scripts/goplus-check.sh dapp <url>
#
# Chain IDs:  1=Ethereum, 56=BSC, 137=Polygon, 42161=Arbitrum, 10=Optimism,
#             43114=Avalanche, 8453=Base, 324=zkSync, 59144=Linea, 534352=Scroll
#             (Solana not supported by GoPlus token security API)
#
# Examples:
#   ./scripts/goplus-check.sh token 1 0xdac17f958d2ee523a2206206994597c13d831ec7
#   ./scripts/goplus-check.sh address 0x1234...
#   ./scripts/goplus-check.sh dapp https://app.uniswap.org

set -euo pipefail

GOPLUS_BASE="https://api.gopluslabs.io/api/v1"

usage() {
    echo "Usage:"
    echo "  $0 token    <chain_id> <contract_address>   Token security check"
    echo "  $0 address  <address> [chain_id]             Malicious address check"
    echo "  $0 nft      <chain_id> <contract_address>   NFT security check"
    echo "  $0 approval <chain_id> <contract_address>   Approval risk check"
    echo "  $0 dapp     <url>                            dApp security check"
    exit 1
}

# Format JSON output: use jq if available, otherwise cat raw
fmt() {
    if command -v jq &>/dev/null; then
        jq .
    else
        cat
    fi
}

# Parse risk flags from token security response into a human-readable summary
summarize_token() {
    if ! command -v jq &>/dev/null; then
        echo "(install jq for formatted risk summary)"
        return
    fi

    local json="$1"
    local addr
    addr=$(echo "$json" | jq -r '.result | keys[0] // empty')
    if [ -z "$addr" ]; then
        echo "ERROR: No result returned. Check chain_id and contract address."
        return 1
    fi

    local r=".result[\"$addr\"]"

    echo ""
    echo "========================================="
    echo " GoPlus Token Security Summary"
    echo "========================================="
    echo ""

    # Basic info
    local name
    name=$(echo "$json" | jq -r "$r.token_name // \"unknown\"")
    local symbol
    symbol=$(echo "$json" | jq -r "$r.token_symbol // \"unknown\"")
    echo "Token: $name ($symbol)"
    echo ""

    # Risk flags -- collect HIGH / MEDIUM / INFO
    local high=()
    local medium=()
    local info=()

    # HIGH risk flags
    [ "$(echo "$json" | jq -r "$r.is_honeypot")" = "1" ] && high+=("HONEYPOT DETECTED")
    [ "$(echo "$json" | jq -r "$r.honeypot_with_same_creator")" = "1" ] && high+=("Creator has deployed honeypots before")
    [ "$(echo "$json" | jq -r "$r.selfdestruct")" = "1" ] && high+=("Contract has selfdestruct")
    [ "$(echo "$json" | jq -r "$r.hidden_owner")" = "1" ] && high+=("Hidden owner mechanism")
    [ "$(echo "$json" | jq -r "$r.can_take_back_ownership")" = "1" ] && high+=("Owner can reclaim ownership after renouncing")
    [ "$(echo "$json" | jq -r "$r.owner_change_balance")" = "1" ] && high+=("Owner can modify balances")
    [ "$(echo "$json" | jq -r "$r.is_open_source")" = "0" ] && high+=("Contract is NOT open source")

    # MEDIUM risk flags
    [ "$(echo "$json" | jq -r "$r.is_proxy")" = "1" ] && medium+=("Proxy contract (upgradeable)")
    [ "$(echo "$json" | jq -r "$r.is_mintable")" = "1" ] && medium+=("Token is mintable")
    [ "$(echo "$json" | jq -r "$r.transfer_pausable")" = "1" ] && medium+=("Transfers can be paused")
    [ "$(echo "$json" | jq -r "$r.is_blacklisted")" = "1" ] && medium+=("Has blacklist functionality")
    [ "$(echo "$json" | jq -r "$r.slippage_modifiable")" = "1" ] && medium+=("Owner can modify slippage/tax")
    [ "$(echo "$json" | jq -r "$r.personal_slippage_modifiable")" = "1" ] && medium+=("Per-address slippage can be set")
    [ "$(echo "$json" | jq -r "$r.cannot_sell_all")" = "1" ] && medium+=("Cannot sell full balance")
    [ "$(echo "$json" | jq -r "$r.trading_cooldown")" = "1" ] && medium+=("Trading cooldown enabled")
    [ "$(echo "$json" | jq -r "$r.is_anti_whale")" = "1" ] && medium+=("Anti-whale mechanism")
    [ "$(echo "$json" | jq -r "$r.anti_whale_modifiable")" = "1" ] && medium+=("Anti-whale parameters modifiable")
    [ "$(echo "$json" | jq -r "$r.external_call")" = "1" ] && medium+=("Contract makes external calls")
    [ "$(echo "$json" | jq -r "$r.cannot_buy")" = "1" ] && medium+=("Token cannot be purchased")

    # Tax info
    local buy_tax
    buy_tax=$(echo "$json" | jq -r "$r.buy_tax // \"0\"")
    local sell_tax
    sell_tax=$(echo "$json" | jq -r "$r.sell_tax // \"0\"")
    if [ "$buy_tax" != "0" ] || [ "$sell_tax" != "0" ]; then
        medium+=("Buy tax: ${buy_tax}% / Sell tax: ${sell_tax}%")
    fi

    # INFO
    local holders
    holders=$(echo "$json" | jq -r "$r.holder_count // \"unknown\"")
    local is_in_dex
    is_in_dex=$(echo "$json" | jq -r "$r.is_in_dex // \"0\"")
    local trust
    trust=$(echo "$json" | jq -r "$r.trust_list // \"0\"")
    info+=("Holders: $holders")
    [ "$is_in_dex" = "1" ] && info+=("Listed on DEX") || info+=("NOT listed on DEX")
    [ "$trust" = "1" ] && info+=("On GoPlus trust list")

    # Owner info
    local owner
    owner=$(echo "$json" | jq -r "$r.owner_address // \"none\"")
    [ "$owner" != "none" ] && [ "$owner" != "" ] && info+=("Owner: $owner")

    # Print summary
    if [ ${#high[@]} -gt 0 ]; then
        echo "HIGH RISK:"
        for flag in "${high[@]}"; do
            echo "  [!] $flag"
        done
        echo ""
    fi

    if [ ${#medium[@]} -gt 0 ]; then
        echo "MEDIUM RISK:"
        for flag in "${medium[@]}"; do
            echo "  [~] $flag"
        done
        echo ""
    fi

    echo "INFO:"
    for flag in "${info[@]}"; do
        echo "  [i] $flag"
    done

    # Top holders concentration
    echo ""
    echo "Top Holder Concentration:"
    echo "$json" | jq -r "$r.holders[:5][]? | \"  \\(.address[:10])... \\(.percent)% \\(if .is_contract == 1 then \"(contract)\" else \"\" end)\""

    # LP lock status
    echo ""
    echo "LP Lock Status:"
    echo "$json" | jq -r "$r.lp_holders[:3][]? | \"  \\(.address[:10])... \\(.percent)% locked=\\(.is_locked // 0)\""

    # Overall risk level
    echo ""
    if [ ${#high[@]} -gt 0 ]; then
        echo "OVERALL: HIGH RISK (${#high[@]} high-risk flags)"
    elif [ ${#medium[@]} -gt 3 ]; then
        echo "OVERALL: MEDIUM RISK (${#medium[@]} medium-risk flags)"
    else
        echo "OVERALL: LOW RISK"
    fi
    echo "========================================="
}

# Validation helpers
validate_chain_id() {
    local cid="$1"
    if [[ ! "$cid" =~ ^[0-9]+$ ]]; then
        echo "Error: chain_id must be numeric (got: $cid)"
        echo "Common chain IDs: 1=Ethereum, 56=BSC, 137=Polygon, 42161=Arbitrum, 10=Optimism, 8453=Base"
        exit 1
    fi
}

validate_evm_address() {
    local addr="$1"
    if [[ ! "$addr" =~ ^0x[0-9a-fA-F]{40}$ ]]; then
        echo "Warning: '$addr' does not look like a valid EVM address (expected 0x + 40 hex chars)"
        echo "Proceeding anyway..."
    fi
}

# Fetch with error handling (retry once on failure)
goplus_fetch() {
    local url="$1"
    local response
    response=$(curl -s --max-time 15 "$url")
    local exit_code=$?
    if [ $exit_code -ne 0 ] || [ -z "$response" ]; then
        echo "First request failed (exit=$exit_code), retrying in 5s..." >&2
        sleep 5
        response=$(curl -s --max-time 15 "$url")
        exit_code=$?
        if [ $exit_code -ne 0 ] || [ -z "$response" ]; then
            echo "Error: GoPlus API unavailable after retry (exit=$exit_code)" >&2
            echo '{"error": "API unavailable"}'
            return 1
        fi
    fi
    echo "$response"
}

cmd="${1:-}"
[ -z "$cmd" ] && usage

case "$cmd" in
    token)
        [ $# -lt 3 ] && usage
        chain_id="$2"
        address="$3"
        validate_chain_id "$chain_id"
        validate_evm_address "$address"
        echo "Querying GoPlus Token Security API..."
        echo "Chain: $chain_id | Address: $address"
        echo ""
        response=$(goplus_fetch "${GOPLUS_BASE}/token_security/${chain_id}?contract_addresses=${address}")
        echo "$response" | fmt
        summarize_token "$response"
        ;;
    address)
        [ $# -lt 2 ] && usage
        addr="$2"
        chain="${3:-1}"
        validate_evm_address "$addr"
        validate_chain_id "$chain"
        echo "Querying GoPlus Address Security API..."
        echo "Address: $addr | Chain: $chain"
        echo ""
        goplus_fetch "${GOPLUS_BASE}/address_security/${addr}?chain_id=${chain}" | fmt
        ;;
    nft)
        [ $# -lt 3 ] && usage
        chain_id="$2"
        address="$3"
        validate_chain_id "$chain_id"
        validate_evm_address "$address"
        echo "Querying GoPlus NFT Security API..."
        echo "Chain: $chain_id | Address: $address"
        echo ""
        goplus_fetch "${GOPLUS_BASE}/nft_security/${chain_id}?contract_addresses=${address}" | fmt
        ;;
    approval)
        [ $# -lt 3 ] && usage
        chain_id="$2"
        address="$3"
        validate_chain_id "$chain_id"
        validate_evm_address "$address"
        echo "Querying GoPlus Approval Security API..."
        echo "Chain: $chain_id | Address: $address"
        echo ""
        goplus_fetch "${GOPLUS_BASE}/approval_security/${chain_id}?contract_addresses=${address}" | fmt
        ;;
    dapp)
        [ $# -lt 2 ] && usage
        url="$2"
        echo "Querying GoPlus dApp Security API..."
        echo "URL: $url"
        echo ""
        goplus_fetch "${GOPLUS_BASE}/dapp_security?url=${url}" | fmt
        ;;
    *)
        usage
        ;;
esac
