#!/usr/bin/env bash
set -Eeuo pipefail

# manage-services.sh - Orchestrate multiple docker-compose files
# Discovers compose files in /home/chris/apps and /home/chris/github/hephaestus-infra
# Provides commands: up, down, restart, ps, logs, pull, build

# Usage:
# ./manage-services.sh up --category app
# ./manage-services.sh down --category app
# ./manage-services.sh restart --category app
# ./manage-services.sh ps --category app
# ./manage-services.sh logs --category app
# ./manage-services.sh pull --category app
# ./manage-services.sh up --service n8n --env-file apps/n8n/.env

ROOT_DIR="/home/chris"
APPS_DIR="$ROOT_DIR/apps"
INFRA_DIR="$ROOT_DIR/github/hephaestus-infra"
LOG_DIR="$ROOT_DIR/logs"
CONFIG_FILE="$ROOT_DIR/homelab.config"
CATEGORY_MAP_FILE="$ROOT_DIR/service-categories.yml"

DRY_RUN=false
VERBOSE=false
PARALLEL=false
CONCURRENCY=3
ENV_FILE=""
PROFILE=""

log() {
	local level="$1"; shift
	local ts
	ts="$(date '+%Y-%m-%d %H:%M:%S')"
	if [ "$VERBOSE" = true ] || [ "$level" != "DEBUG" ]; then
		printf "%s [%s] %s\n" "$ts" "$level" "$*" | tee -a "$LOG_DIR/homelab-$(date '+%Y%m%d').log"
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
Usage: $(basename "$0") <command> [options]
Commands:
  up            Bring up services
  down          Stop services
  restart       Restart services
  ps            List services
  logs          Tail logs
  pull          Pull images
  build         Build images
  ls-files      Print matching compose file paths (machine-readable)

Options:
  --category CAT       Filter by category (infra|db|app|monitoring)
  --service NAME       Filter by service name (matches path or file)
  --path PATH          Filter by path substring
  --env-file FILE      Pass through to docker compose
  --profile NAME       Pass through to docker compose
  --parallel           Run in parallel (safe ops only)
  --concurrency N      Limit parallelism (default: 3)
  --dry-run            Print actions without executing
  --verbose            Verbose output
  -h, --help           Show this help
EOF
}

# Load optional config
if [ -f "$CONFIG_FILE" ]; then
	# shellcheck disable=SC1090
	. "$CONFIG_FILE"
fi

mkdir -p "$LOG_DIR"

# Discover compose files (prefer *-homelab.yml)
discover_compose_files() {
	local found=()
    if [ -d "$INFRA_DIR" ]; then
        while IFS= read -r -d '' file; do
            # Skip backup root-folder compose files
            if [[ "$file" == *"/root-folder/"* ]]; then continue; fi
            found+=("$file")
        done < <(find "$INFRA_DIR" -type f \( -name 'docker-compose-homelab.yml' -o -name 'docker-compose.yml' -o -name 'docker-compose*.yml' \) -print0 2>/dev/null)
    fi
	if [ -d "$APPS_DIR" ]; then
		while IFS= read -r -d '' file; do found+=("$file"); done < <(find "$APPS_DIR" -mindepth 2 -maxdepth 2 -type f \( -name 'docker-compose-homelab.yml' -o -name 'docker-compose.yml' -o -name 'docker-compose*.yml' \) -print0 2>/dev/null)
	fi
	# Prefer homelab files when both exist in same dir
	# Build unique by dir, picking best
	declare -A best
	for f in "${found[@]}"; do
		dir="$(dirname "$f")"
		name="$(basename "$f")"
		if [[ -z "${best[$dir]:-}" ]]; then
			best[$dir]="$f"
		else
			case "$name" in
				docker-compose-homelab.yml) best[$dir]="$f";;
				docker-compose.yml)
					[[ "${best[$dir]}" != *"docker-compose-homelab.yml" ]] && best[$dir]="$f" ;;
				*) [[ "${best[$dir]}" == *"docker-compose.yml"* ]] && best[$dir]="$f" ;;
			esac
		fi
	done
	for dir in "${!best[@]}"; do echo "${best[$dir]}"; done
}

# Simple category mapping
map_category() {
	local path="$1"
	local lc
	lc="${path,,}"
	if [[ -f "$CATEGORY_MAP_FILE" ]]; then
		# naive parse: service path substring match: category
		while IFS= read -r line; do
			[[ -z "$line" || "$line" =~ ^# ]] && continue
			local key cat
			key="${line%%:*}"; cat="${line##*:}"
			key="${key//[[:space:]]/}"; cat="${cat//[[:space:]]/}"
			if [[ "$lc" == *"${key,,}"* ]]; then
				echo "$cat"; return
			fi
		done < "$CATEGORY_MAP_FILE"
	fi
	if [[ "$lc" == *"github/hephaestus-infra"* || "$lc" == *"proxy"* ]]; then echo infra; return; fi
	if [[ "$lc" == *"mongo"* || "$lc" == *"postgres"* || "$lc" == *"redis"* ]]; then echo db; return; fi
	if [[ "$lc" == *"grafana"* || "$lc" == *"prometheus"* || "$lc" == *"uptime"* || "$lc" == *"exporter"* ]]; then echo monitoring; return; fi
	echo app
}

filter_paths() {
	local category_filter="${1:-}"
	local service_filter="${2:-}"
	local path_filter="${3:-}"
	while IFS= read -r p; do
		local cat
		cat=$(map_category "$p")
		if [[ -n "$category_filter" && "$cat" != "$category_filter" ]]; then continue; fi
		if [[ -n "$service_filter" && "$p" != *"$service_filter"* ]]; then continue; fi
		if [[ -n "$path_filter" && "$p" != *"$path_filter"* ]]; then continue; fi
		echo "$p|$cat"
	done < <(discover_compose_files | sort)
}

compose_cmd() {
	local file="$1"; shift
	local args=(docker compose -f "$file")
	if [[ -n "$ENV_FILE" ]]; then args+=(--env-file "$ENV_FILE"); fi
	if [[ -n "$PROFILE" ]]; then args+=(--profile "$PROFILE"); fi
	"printf" "%q " "${args[@]}"; printf "%s" "$*"
}

# Detect a suitable .env for a given compose file path
detect_env_file() {
	local file="$1"
	local dir
	dir="$(dirname "$file")"
	# 1) .env next to the compose file
	if [[ -f "$dir/.env" ]]; then echo "$dir/.env"; return; fi
	# 2) repo-level .env for infra
	if [[ "$dir" == $INFRA_DIR* && -f "$INFRA_DIR/.env" ]]; then echo "$INFRA_DIR/.env"; return; fi
	# 3) app-level .env in parent app directory
	local parent
	parent="$(dirname "$dir")"
	if [[ -f "$parent/.env" ]]; then echo "$parent/.env"; return; fi
	# none
	echo ""
}

ensure_network() {
	"$ROOT_DIR/setup-networks.sh" --network-name homelab-web --subnet 172.20.0.0/16 ${DRY_RUN:+--dry-run} ${VERBOSE:+--verbose}
}

exec_for_paths() {
	local cmd="$1"; shift
	local parallel="$1"; shift
	local concurrency="$1"; shift
	local -a items=()
	while IFS= read -r item; do items+=("$item"); done
	if [[ ${#items[@]} -eq 0 ]]; then
		log INFO "No matching compose files found"
		return 0
	fi
	if [[ "$cmd" == "up" ]]; then ensure_network; fi
	if [[ "$parallel" == true ]]; then
		log INFO "Running in parallel with concurrency=$concurrency"
		run_parallel "$cmd" "$concurrency" "${items[@]}"
	else
		for item in "${items[@]}"; do
			local file cat
			file="${item%%|*}"; cat="${item##*|}"
			local per_file_env
			per_file_env="$(detect_env_file "$file")"
			log INFO "[$cat] $cmd -> $file"
			case "$cmd" in
				up)   ENV_FILE="$per_file_env" run sh -c "$(compose_cmd "$file" up -d)" ;;
				down) ENV_FILE="$per_file_env" run sh -c "$(compose_cmd "$file" down)" ;;
				restart) ENV_FILE="$per_file_env" run sh -c "$(compose_cmd "$file" restart)" ;;
				ps)   ENV_FILE="$per_file_env" run sh -c "$(compose_cmd "$file" ps)" ;;
				logs) ENV_FILE="$per_file_env" run sh -c "$(compose_cmd "$file" logs --no-color --tail=200)" ;;
				pull) ENV_FILE="$per_file_env" run sh -c "$(compose_cmd "$file" pull)" ;;
				build) ENV_FILE="$per_file_env" run sh -c "$(compose_cmd "$file" build)" ;;
				*) log ERROR "Unknown command $cmd"; return 2;;
			esac
		done
	fi
}

run_parallel() {
	local cmd="$1"; shift
	local concurrency="$1"; shift
	local -a queue=("$@")
	local -i active=0 i=0
	while [[ $i -lt ${#queue[@]} ]]; do
		if [[ $active -lt $concurrency ]]; then
			local item="${queue[$i]}"; i=$((i+1))
			(
				set -Eeuo pipefail
				file="${item%%|*}"; cat="${item##*|}"
				per_file_env="$(detect_env_file "$file")"
				log INFO "[$cat] $cmd -> $file"
				case "$cmd" in
					up)    ENV_FILE="$per_file_env" eval "$(compose_cmd "$file" up -d)" ;;
					down)  ENV_FILE="$per_file_env" eval "$(compose_cmd "$file" down)" ;;
					restart) ENV_FILE="$per_file_env" eval "$(compose_cmd "$file" restart)" ;;
					ps)    ENV_FILE="$per_file_env" eval "$(compose_cmd "$file" ps)" ;;
					logs)  ENV_FILE="$per_file_env" eval "$(compose_cmd "$file" logs --no-color --tail=200)" ;;
					pull)  ENV_FILE="$per_file_env" eval "$(compose_cmd "$file" pull)" ;;
					build) ENV_FILE="$per_file_env" eval "$(compose_cmd "$file" build)" ;;
					*) exit 2;;
				esac
			) &
			active=$((active+1))
		else
			wait -n || true
			active=$((active-1))
		fi
	done
	# Wait for remaining
	wait || true
}

main() {
	local cmd="${1:-}"; shift || true
	local category="" service="" path_filter=""
	while [[ $# -gt 0 ]]; do
		case "$1" in
			--category) category="$2"; shift 2;;
			--service) service="$2"; shift 2;;
			--path) path_filter="$2"; shift 2;;
			--env-file) ENV_FILE="$2"; shift 2;;
			--profile) PROFILE="$2"; shift 2;;
			--parallel) PARALLEL=true; shift;;
			--concurrency) CONCURRENCY="$2"; shift 2;;
			--dry-run) DRY_RUN=true; shift;;
			--verbose) VERBOSE=true; shift;;
			-h|--help) usage; exit 0;;
			*) log ERROR "Unknown option: $1"; usage; exit 2;;
		esac
	done
	if [[ -z "$cmd" ]]; then usage; exit 2; fi

	local ordered=(infra db app monitoring)
	if [[ -n "$category" ]]; then ordered=("$category"); fi

	for cat in "${ordered[@]}"; do
    log INFO "Processing category: $cat"
    if [[ "$cmd" == "ls-files" ]]; then
      # For ls-files, just output the file list for the given filters
      while IFS= read -r line; do
        file="${line%%|*}"
        echo "$file"
      done < <(filter_paths "$cat" "$service" "$path_filter")
    else
      exec_for_paths "$cmd" "$PARALLEL" "$CONCURRENCY" < <(filter_paths "$cat" "$service" "$path_filter")
    fi
	done
}

main "$@"
