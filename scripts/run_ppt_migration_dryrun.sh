#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  bash scripts/run_ppt_migration_dryrun.sh --run-id <id> --source <source.pptx> --theme <theme.thmx|theme.pptx>
USAGE
}

RUN_ID=""
SOURCE=""
THEME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --run-id)
      RUN_ID="$2"; shift 2 ;;
    --source)
      SOURCE="$2"; shift 2 ;;
    --theme)
      THEME="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1"; usage; exit 1 ;;
  esac
done

if [[ -z "$RUN_ID" || -z "$SOURCE" || -z "$THEME" ]]; then
  usage
  exit 1
fi

python3 scripts/run_ppt_migration_dryrun.py --run-id "$RUN_ID" --source "$SOURCE" --theme "$THEME"
