#!/usr/bin/env bash
set -euo pipefail

RUN_ID="${1:-run-sync}"
REPORT_DIR="runs/${RUN_ID}/work"
mkdir -p "$REPORT_DIR"
SYNC_REPORT="${REPORT_DIR}/sync-report.md"

now="$(date '+%Y-%m-%d %H:%M:%S')"
branch="$(git branch --show-current || echo unknown)"

{
  echo "# 同步与执行报告"
  echo
  echo "- 时间：${now}"
  echo "- 分支：${branch}"
  echo
  echo "## Git 同步"
  echo
} > "$SYNC_REPORT"

if ! git remote get-url origin >/dev/null 2>&1; then
  {
    echo "- 状态：未执行远端同步。"
    echo "- 原因：当前仓库未配置 origin 远端。"
  } >> "$SYNC_REPORT"
else
  {
    echo "- 远端：$(git remote get-url origin)"
    echo "- 操作：git fetch origin"
  } >> "$SYNC_REPORT"
  git fetch origin >> "$SYNC_REPORT" 2>&1 || true

  {
    echo "- 操作：git pull --rebase origin ${branch}"
  } >> "$SYNC_REPORT"
  git pull --rebase origin "${branch}" >> "$SYNC_REPORT" 2>&1 || true
fi

{
  echo
  echo "## 输入文件扫描"
  echo
} >> "$SYNC_REPORT"
find . -type f \( -iname '*.pptx' -o -iname '*.pptm' -o -iname '*.thmx' \) ! -path './runs/*' | sort > "${REPORT_DIR}/detected-input-files.txt"
count=$(wc -l < "${REPORT_DIR}/detected-input-files.txt" | tr -d ' ')
{
  echo "- 检测到文件数：${count}"
  if [[ "$count" -gt 0 ]]; then
    echo "- 明细见：\`runs/${RUN_ID}/work/detected-input-files.txt\`"
  else
    echo "- 未检测到输入PPT/THMX文件。"
  fi
} >> "$SYNC_REPORT"

bash scripts/execute_uploaded_trial.sh "$RUN_ID" >> "$SYNC_REPORT" 2>&1 || true

echo "Sync & execute report: $SYNC_REPORT"
