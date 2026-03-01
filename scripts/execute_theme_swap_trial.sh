#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  bash scripts/execute_theme_swap_trial.sh --run-id <id> --source <source.pptx> --template <template.pptx|template.thmx>
USAGE
}

RUN_ID=""
SOURCE=""
TEMPLATE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --run-id) RUN_ID="$2"; shift 2 ;;
    --source) SOURCE="$2"; shift 2 ;;
    --template) TEMPLATE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

if [[ -z "$RUN_ID" || -z "$SOURCE" || -z "$TEMPLATE" ]]; then
  usage
  exit 1
fi

OUT_DIR="runs/${RUN_ID}/output"
WORK_DIR="runs/${RUN_ID}/work"
mkdir -p "$OUT_DIR" "$WORK_DIR"

python3 scripts/execute_theme_swap_trial.py \
  --source "$SOURCE" \
  --template "$TEMPLATE" \
  --output "$OUT_DIR/trial_theme_swapped.pptx" \
  --report "$WORK_DIR/theme-swap-report.md"
