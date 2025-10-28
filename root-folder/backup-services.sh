#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="/home/chris"
DEST_DIR="$ROOT_DIR/backups"
EXCLUDES_FILE="$ROOT_DIR/backup-exclude.txt"
DRY_RUN=false
VERIFY=false
CATEGORY=""
SERVICE=""

usage() {
	cat <<EOF
Usage: $(basename "$0") [options]
Options:
  --dest DIR        Backup destination directory (default: /home/chris/backups)
  --category CAT    Filter by category
  --service NAME    Filter by service substring
  --dry-run         Print actions without executing
  --verify          Verify archive after creation
  -h, --help        Show help
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--dest) DEST_DIR="$2"; shift 2;;
		--category) CATEGORY="$2"; shift 2;;
		--service) SERVICE="$2"; shift 2;;
		--dry-run) DRY_RUN=true; shift;;
		--verify) VERIFY=true; shift;;
		-h|--help) usage; exit 0;;
		*) echo "Unknown option: $1"; usage; exit 2;;
	esac
done

mkdir -p "$DEST_DIR" "$DEST_DIR/binds"

list_compose_files() {
	"$ROOT_DIR/manage-services.sh" ps --category "$CATEGORY" ${SERVICE:+--service "$SERVICE"} >/dev/null 2>&1 || true
	# Best effort discovery of compose files reusing manage-services.sh
	"$ROOT_DIR/manage-services.sh" pull --dry-run --category "$CATEGORY" ${SERVICE:+--service "$SERVICE"} 2>&1 | grep -oE '-f /[^ ]+' | awk '{print $2}' | sort -u
}

backup_volume() {
	local vol="$1" ts="$2"
	local out="$DEST_DIR/${vol}-${ts}.tgz"
	if [ "$DRY_RUN" = true ]; then echo "DRY-RUN: backup volume $vol -> $out"; return; fi
	docker run --rm -v "$vol:/data" -v "$DEST_DIR:/backup" alpine sh -c "tar -C / -czf /backup/$(basename "$out") data"
	if [ "$VERIFY" = true ]; then tar -tzf "$out" >/dev/null; fi
}

backup_bind() {
	local path="$1" ts="$2"
	local base
	base="$(echo "$path" | sed 's#/#_#g')"
	local out="$DEST_DIR/binds/${base}-${ts}.tgz"
	if [ "$DRY_RUN" = true ]; then echo "DRY-RUN: backup bind $path -> $out"; return; fi
	tar --exclude-from "$EXCLUDES_FILE" -czf "$out" -C / "$path" 2>/dev/null || true
	if [ "$VERIFY" = true ]; then tar -tzf "$out" >/dev/null; fi
}

extract_volumes_and_binds() {
	local file="$1"
	# naive parse: lines with 'source:' where type: volume vs bind
	awk '
		/volumes:/ {invol=1} invol && /source:/ {print}
	' "$file" | awk '{print $2}'
}

main() {
	local ts
	ts="$(date '+%Y%m%d-%H%M%S')"
	local f
	for f in $(list_compose_files); do
		echo "Scanning: $f"
		while IFS= read -r src; do
			# Decide if named volume (no slash) or bind (has /)
			if [[ "$src" == /* ]]; then
				backup_bind "$src" "$ts"
			else
				backup_volume "$src" "$ts"
			fi
		done < <(extract_volumes_and_binds "$f" | sort -u)
	done
	echo "Backup completed to $DEST_DIR"
}

main "$@"