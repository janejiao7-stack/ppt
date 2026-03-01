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
    echo "- 状态：失败。"
    echo "- 原因：当前仓库未配置 origin 远端。"
  } >> "$SYNC_REPORT"
  echo "Sync & execute failed: missing origin"
  exit 2
fi

{
  echo "- 远端：$(git remote get-url origin)"
  echo "- 操作：git fetch origin"
} >> "$SYNC_REPORT"

if ! git fetch origin >> "$SYNC_REPORT" 2>&1; then
  {
    echo
    echo "## 执行结果"
    echo
    echo "- 未执行主题替换：远端同步失败，无法保证拿到 GitHub 最新文件。"
    echo "- 请先解决网络/代理后重试。"
  } >> "$SYNC_REPORT"
  echo "Sync & execute failed: fetch error"
  exit 2
fi

{
  echo "- 操作：git pull --rebase origin ${branch}"
} >> "$SYNC_REPORT"

if ! git pull --rebase origin "${branch}" >> "$SYNC_REPORT" 2>&1; then
  {
    echo
    echo "## 执行结果"
    echo
    echo "- 未执行主题替换：pull 失败，无法保证本地为远端最新。"
  } >> "$SYNC_REPORT"
  echo "Sync & execute failed: pull error"
  exit 2
fi

{
  echo
  echo "## 输入文件扫描（仅 runs/*/input）"
  echo
} >> "$SYNC_REPORT"

find runs -type f \( -iname '*.pptx' -o -iname '*.pptm' -o -iname '*.thmx' \) -path '*/input/*' | sort > "${REPORT_DIR}/detected-input-files.txt"
count=$(wc -l < "${REPORT_DIR}/detected-input-files.txt" | tr -d ' ')
{
  echo "- 检测到文件数：${count}"
  if [[ "$count" -gt 0 ]]; then
    echo "- 明细见：\`runs/${RUN_ID}/work/detected-input-files.txt\`"
  else
    echo "- 未检测到输入文件。"
  fi
} >> "$SYNC_REPORT"

bash scripts/execute_uploaded_trial.sh "$RUN_ID" >> "$SYNC_REPORT" 2>&1

echo "Sync & execute report: $SYNC_REPORT"
