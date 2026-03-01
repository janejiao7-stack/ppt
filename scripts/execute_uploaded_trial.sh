#!/usr/bin/env bash
set -euo pipefail

RUN_ID="${1:-uploaded-trial}"
REPORT_DIR="runs/${RUN_ID}/work"
OUT_DIR="runs/${RUN_ID}/output"
mkdir -p "$REPORT_DIR" "$OUT_DIR"
REPORT_FILE="${REPORT_DIR}/execution-report.md"

# 仅扫描 runs/*/input，避免误用仓库中的本地测试样例。
mapfile -t source_candidates < <(find runs -type f \( -iname '*.pptx' -o -iname '*.pptm' \) -path '*/input/*' | sort)
mapfile -t theme_candidates < <(find runs -type f -iname '*.thmx' -path '*/input/*' | sort)

now="$(date '+%Y-%m-%d %H:%M:%S')"
{
  echo "# 自动执行报告"
  echo
  echo "- 时间：${now}"
  echo "- run_id：${RUN_ID}"
  echo
  echo "## 输入扫描（仅 runs/*/input）"
  echo
  echo "- 检测到 PPT/PPTM 文件数：${#source_candidates[@]}"
  echo "- 检测到 THMX 文件数：${#theme_candidates[@]}"
  echo
} > "$REPORT_FILE"

if (( ${#source_candidates[@]} < 1 )); then
  {
    echo "## 执行结果"
    echo
    echo "- 未执行主题替换：在 runs/*/input 下未找到源PPT文件（*.pptx/*.pptm）。"
    echo "- 请先同步远端并确认你的文件已经存在于 runs/<run-id>/input/ 目录。"
  } >> "$REPORT_FILE"
  echo "Report generated (no inputs): $REPORT_FILE"
  exit 2
fi

SOURCE="${source_candidates[0]}"
TEMPLATE=""
if (( ${#theme_candidates[@]} >= 1 )); then
  TEMPLATE="${theme_candidates[0]}"
elif (( ${#source_candidates[@]} >= 2 )); then
  TEMPLATE="${source_candidates[1]}"
else
  {
    echo "## 执行结果"
    echo
    echo "- 未执行主题替换：未找到模板（*.thmx）且未检测到第二个PPT文件可作为模板。"
    echo "- 请将模板放入 runs/<run-id>/input/ 后重试。"
  } >> "$REPORT_FILE"
  echo "Report generated (missing template): $REPORT_FILE"
  exit 2
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
