#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="/home/chris"

usage() {
	cat <<EOF
Usage: $(basename "$0") [options]
Options:
  --skip-health          Do not run health checks between categories
  --parallel             Start services in parallel per category
  --concurrency N        Parallel concurrency (default: 3)
  --category CAT         Only start a single category
  --service NAME         Limit to a specific service match
  --dry-run              Print actions without executing
  --verbose              Verbose output
  -h, --help             Show this help
EOF
}

SKIP_HEALTH=false
PARALLEL=false
CONCURRENCY=3
CATEGORY=""
SERVICE=""
DRY_RUN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
	case "$1" in
		--skip-health) SKIP_HEALTH=true; shift;;
		--parallel) PARALLEL=true; shift;;
		--concurrency) CONCURRENCY="$2"; shift 2;;
		--category) CATEGORY="$2"; shift 2;;
		--service) SERVICE="$2"; shift 2;;
		--dry-run) DRY_RUN=true; shift;;
		--verbose) VERBOSE=true; shift;;
		-h|--help) usage; exit 0;;
		*) echo "Unknown option: $1"; usage; exit 2;;
	esac
done

run() {
	if [ "$DRY_RUN" = true ]; then
		echo "DRY-RUN: $*"
		return 0
	fi
	"$@"
}

"$ROOT_DIR/setup-networks.sh" ${DRY_RUN:+--dry-run} ${VERBOSE:+--verbose}

categories=(infra db app monitoring)
if [[ -n "$CATEGORY" ]]; then categories=("$CATEGORY"); fi

for cat in "${categories[@]}"; do
	echo "Starting category: $cat"
	run "$ROOT_DIR/manage-services.sh" up --category "$cat" ${PARALLEL:+--parallel} --concurrency "$CONCURRENCY" ${SERVICE:+--service "$SERVICE"} ${DRY_RUN:+--dry-run} ${VERBOSE:+--verbose}
	if [[ "$SKIP_HEALTH" != true ]]; then
		echo "Running health checks for: $cat"
		run "$ROOT_DIR/check-services.sh" --category "$cat" ${DRY_RUN:+--dry-run}
	fi
done