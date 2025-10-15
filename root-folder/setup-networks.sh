#!/usr/bin/env bash
set -Eeuo pipefail

# setup-networks.sh - Ensure homelab-web docker network exists
# Usage: setup-networks.sh [--network-name NAME] [--subnet CIDR] [--dry-run] [--verbose]

NETWORK_NAME="homelab-web"
SUBNET="172.20.0.0/16"
DRY_RUN=false
VERBOSE=false

log() {
	local level="$1"; shift
	local ts
	ts="$(date '+%Y-%m-%d %H:%M:%S')"
	if [ "$VERBOSE" = true ] || [ "$level" != "DEBUG" ]; then
		printf "%s [%s] %s\n" "$ts" "$level" "$*"
	fi
}

run() {
	if [ "$DRY_RUN" = true ]; then
		log DEBUG "DRY-RUN: $*"
		return 0
	fi
	"$@"
}

usage() {
	cat <<EOF
Usage: $(basename "$0") [options]
  --network-name NAME   Docker network name (default: homelab-web)
  --subnet CIDR         Subnet CIDR (default: 172.20.0.0/16)
  --dry-run             Print actions without executing
  --verbose             Verbose output
  -h, --help            Show this help
EOF
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--network-name) NETWORK_NAME="$2"; shift 2;;
		--subnet) SUBNET="$2"; shift 2;;
		--dry-run) DRY_RUN=true; shift;;
		--verbose) VERBOSE=true; shift;;
		-h|--help) usage; exit 0;;
		*) log ERROR "Unknown option: $1"; usage; exit 2;;
	esac
done

log INFO "Ensuring docker network '$NETWORK_NAME' exists with subnet $SUBNET"

# Check if network exists
if docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
	log INFO "Network '$NETWORK_NAME' already exists"
	exit 0
fi

# Detect overlapping networks
existing=$(docker network ls --format '{{.Name}}')
while IFS= read -r net; do
	[ -z "$net" ] && continue
	inspect=$(docker network inspect "$net" --format '{{json .IPAM.Config}}' 2>/dev/null || true)
	if [ -n "$inspect" ] && echo "$inspect" | grep -q "$SUBNET"; then
		log ERROR "Subnet $SUBNET already in use by network '$net'"
		exit 1
	fi
done <<< "$existing"

# Create the network
log INFO "Creating network '$NETWORK_NAME'"
run docker network create "$NETWORK_NAME" --driver bridge --subnet "$SUBNET"
log INFO "Network '$NETWORK_NAME' created"