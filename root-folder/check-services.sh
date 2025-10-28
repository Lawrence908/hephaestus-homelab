#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="/home/chris"
APPS_DIR="$ROOT_DIR/apps"
INFRA_DIR="$ROOT_DIR/github/hephaestus-infra"
HEALTH_DEFAULT_PATH="/"
MAX_RETRIES=10
INTERVAL=5
TIMEOUT=5
DRY_RUN=false

usage() {
	cat <<EOF
Usage: $(basename "$0") [options]
Options:
  --category CAT       Filter by category
  --service NAME       Filter by service substring
  --max-retries N      Retries (default: 10)
  --interval SECS      Interval seconds (default: 5)
  --timeout SECS       Connect timeout (default: 5)
  --dry-run            Print actions without executing
  -h, --help           Show help
EOF
}

CATEGORY=""
SERVICE=""

while [[ $# -gt 0 ]]; do
	case "$1" in
		--category) CATEGORY="$2"; shift 2;;
		--service) SERVICE="$2"; shift 2;;
		--max-retries) MAX_RETRIES="$2"; shift 2;;
		--interval) INTERVAL="$2"; shift 2;;
		--timeout) TIMEOUT="$2"; shift 2;;
		--dry-run) DRY_RUN=true; shift;;
		-h|--help) usage; exit 0;;
		*) echo "Unknown option: $1"; usage; exit 2;;
	esac
done

# Discover containers by reading compose files and asking docker for names
list_services() {
    local files
    files=$("$ROOT_DIR/manage-services.sh" ls-files --category "$CATEGORY" ${SERVICE:+--service "$SERVICE"} || true)
    local name
    while IFS= read -r f; do
        # Ask docker compose for JSON if available; fall back to names list
        if docker compose -f "$f" ps --format json >/dev/null 2>&1; then
            docker compose -f "$f" ps --format json | jq -r '.[].Name' 2>/dev/null || true
        else
            docker compose -f "$f" ps --format '{{.Name}}' 2>/dev/null || true
        fi
    done <<< "$files" | sed '/^$/d' | sort -u
}

http_ok() {
	local url="$1"
	curl -fsS --max-time "$TIMEOUT" "$url" >/dev/null 2>&1
}

tcp_ok() {
	local host="$1" port="$2"
	nc -z -w "$TIMEOUT" "$host" "$port" >/dev/null 2>&1
}

check_container_health() {
	local name="$1"
	local status
	status=$(docker inspect --format '{{.State.Health.Status}}' "$name" 2>/dev/null || echo "unknown")
	[[ "$status" == "healthy" ]]
}

backoff_sleep() {
	local attempt="$1"
	sleep "$(( INTERVAL + attempt ))"
}

main() {
	local failed=0
	local svc
	for svc in $(list_services); do
		local attempt=1
		echo "Health checking: $svc"
		while [[ $attempt -le $MAX_RETRIES ]]; do
			# Try HEALTHCHECK status first
			if check_container_health "$svc"; then
				echo "OK: $svc (HEALTHCHECK)"
				break
			fi
			# Try HTTP default
			if http_ok "http://$svc$HEALTH_DEFAULT_PATH"; then
				echo "OK: $svc (HTTP)"
				break
			fi
			# Try common ports: 80, 443, 8080, 3000, 5000, 6379, 9090
			for port in 80 443 8080 3000 5000 6379 9090 9000 25565; do
				if tcp_ok "$svc" "$port"; then
					echo "OK: $svc (TCP:$port)"
					attempt=$((MAX_RETRIES+1))
					break
				fi
			done
			if [[ $attempt -le $MAX_RETRIES ]]; then
				echo "Waiting ($attempt/$MAX_RETRIES) for $svc..."
				backoff_sleep "$attempt"
				attempt=$((attempt+1))
			fi
		done
		if [[ $attempt -gt $MAX_RETRIES ]]; then
			echo "FAIL: $svc did not become healthy"
			failed=$((failed+1))
		fi
	done
	[[ $failed -eq 0 ]]
}

main "$@"