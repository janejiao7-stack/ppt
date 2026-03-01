#!/usr/bin/env bash
set -euo pipefail

RUN_ID="${1:-uploaded-trial}"
REPORT_DIR="runs/${RUN_ID}/work"
OUT_DIR="runs/${RUN_ID}/output"
mkdir -p "$REPORT_DIR" "$OUT_DIR"
REPORT_FILE="${REPORT_DIR}/execution-report.md"

mapfile -t pptx_files < <(find . -type f \( -iname '*.pptx' -o -iname '*.pptm' \) ! -path './runs/*' | sort)
mapfile -t thmx_files < <(find . -type f -iname '*.thmx' ! -path './runs/*' | sort)

now="$(date '+%Y-%m-%d %H:%M:%S')"
{
  echo "# 自动执行报告"
  echo
  echo "- 时间：${now}"
  echo "- run_id：${RUN_ID}"
  echo
  echo "## 输入扫描"
  echo
  echo "- 检测到 PPT/PPTM 文件数：${#pptx_files[@]}"
  echo "- 检测到 THMX 文件数：${#thmx_files[@]}"
  echo
} > "$REPORT_FILE"

if (( ${#pptx_files[@]} < 1 )); then
  {
    echo "## 执行结果"
    echo
    echo "- 未执行主题替换：未找到源PPT文件（*.pptx/*.pptm）。"
    echo "- 请将源PPT与模板放入仓库后重试。"
  } >> "$REPORT_FILE"
  echo "Report generated (no inputs): $REPORT_FILE"
  exit 0
fi

SOURCE="${pptx_files[0]}"
TEMPLATE=""
if (( ${#thmx_files[@]} >= 1 )); then
  TEMPLATE="${thmx_files[0]}"
elif (( ${#pptx_files[@]} >= 2 )); then
  TEMPLATE="${pptx_files[1]}"
else
  {
    echo "## 执行结果"
    echo
    echo "- 未执行主题替换：未找到模板（*.thmx）且未检测到第二个PPT文件可作为模板。"
  } >> "$REPORT_FILE"
  echo "Report generated (missing template): $REPORT_FILE"
  exit 0
fi

bash scripts/execute_theme_swap_trial.sh --run-id "$RUN_ID" --source "$SOURCE" --template "$TEMPLATE"

{
  echo
  echo "## 执行结果"
  echo
  echo "- 已执行主题替换试跑。"
  echo "- 源文件：\`${SOURCE}\`"
  echo "- 模板文件：\`${TEMPLATE}\`"
  echo "- 输出文件：\`runs/${RUN_ID}/output/trial_theme_swapped.pptx\`"
  echo "- 详细报告：\`runs/${RUN_ID}/work/theme-swap-report.md\`"
} >> "$REPORT_FILE"

echo "Report generated: $REPORT_FILE"
