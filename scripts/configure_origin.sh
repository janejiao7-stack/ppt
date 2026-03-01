#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  echo "用法: $0 <origin-url> [branch]"
  echo "示例: $0 https://github.com/janejiao7-stack/ppt.git main"
  exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "用法: $0 <origin-url> [branch]" >&2
  echo "示例: $0 https://github.com/janejiao7-stack/ppt.git main" >&2
  exit 1
fi

ORIGIN_URL="$1"
TARGET_BRANCH="${2:-main}"

if git remote get-url origin >/dev/null 2>&1; then
  CURRENT_URL="$(git remote get-url origin)"
  if [[ "$CURRENT_URL" != "$ORIGIN_URL" ]]; then
    git remote set-url origin "$ORIGIN_URL"
    echo "已更新 origin: $CURRENT_URL -> $ORIGIN_URL"
  else
    echo "origin 已是目标地址: $ORIGIN_URL"
  fi
else
  git remote add origin "$ORIGIN_URL"
  echo "已新增 origin: $ORIGIN_URL"
fi

echo "尝试获取远端分支信息..."
if ! git fetch origin --prune; then
  echo "警告: git fetch 失败（可能是网络/权限限制），但 origin 已配置完成。"
fi

echo "当前分支: $(git rev-parse --abbrev-ref HEAD)"
if git ls-remote --heads origin "$TARGET_BRANCH" 2>/dev/null | rg -q "$TARGET_BRANCH$"; then
  echo "检测到远端分支 origin/$TARGET_BRANCH"
else
  echo "提示: 未确认到远端分支 origin/$TARGET_BRANCH（可稍后手动 push -u）。"
fi

echo "完成。可用命令:"
echo "  git remote -v"
echo "  git push -u origin $(git rev-parse --abbrev-ref HEAD)"
