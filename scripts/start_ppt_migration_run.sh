#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  bash scripts/start_ppt_migration_run.sh --run-id <id> --source-file <file> --theme-file <file>
USAGE
}

RUN_ID=""
SOURCE_FILE=""
THEME_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --run-id)
      RUN_ID="$2"
      shift 2
      ;;
    --source-file)
      SOURCE_FILE="$2"
      shift 2
      ;;
    --theme-file)
      THEME_FILE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$RUN_ID" || -z "$SOURCE_FILE" || -z "$THEME_FILE" ]]; then
  echo "Missing required arguments."
  usage
  exit 1
fi

BASE_DIR="runs/${RUN_ID}"
INPUT_DIR="${BASE_DIR}/input"
WORK_DIR="${BASE_DIR}/work"
OUTPUT_DIR="${BASE_DIR}/output"

mkdir -p "$INPUT_DIR" "$WORK_DIR" "$OUTPUT_DIR"

if [[ ! -f "${BASE_DIR}/run-config.yaml" ]]; then
  cp "templates/run-config.template.yaml" "${BASE_DIR}/run-config.yaml"
fi
if [[ ! -f "${BASE_DIR}/checklist.md" ]]; then
  cp "templates/checklist.template.md" "${BASE_DIR}/checklist.md"
fi

if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "Source file not found: $SOURCE_FILE"
  exit 1
fi
if [[ ! -f "$THEME_FILE" ]]; then
  echo "Theme file not found: $THEME_FILE"
  exit 1
fi

if [[ ! -f "${INPUT_DIR}/source.pptx" ]]; then
  cp "$SOURCE_FILE" "${INPUT_DIR}/source.pptx"
fi

THEME_TARGET_EXT=".pptx"
if [[ "$THEME_FILE" == *.thmx ]]; then
  THEME_TARGET_EXT=".thmx"
fi
if [[ ! -f "${INPUT_DIR}/theme${THEME_TARGET_EXT}" ]]; then
  cp "$THEME_FILE" "${INPUT_DIR}/theme${THEME_TARGET_EXT}"
fi

echo "Run initialized: ${RUN_ID}"
echo "- Put/verify files in: ${INPUT_DIR}"
echo "- Edit config: ${BASE_DIR}/run-config.yaml"
echo "- Execute following SOP/checklist docs for delivery"
