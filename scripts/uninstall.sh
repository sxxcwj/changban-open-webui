#!/usr/bin/env bash
# 卸载：停止并移除后台服务；可选卸载程序和删除数据
# 用法: scripts/uninstall.sh [--remove-app] [--purge-data]
set -euo pipefail
# shellcheck source=scripts/common.sh
source "$(dirname "$0")/common.sh"
REMOVE_APP=0; PURGE=0
for a in "$@"; do
  case "$a" in
    --remove-app) REMOVE_APP=1 ;;
    --purge-data) PURGE=1 ;;
    *) echo "未知参数: $a" >&2; exit 1 ;;
  esac
done
launchctl unload "$PLIST_DST" 2>/dev/null || true
rm -f "$PLIST_DST"
echo "后台服务已移除"
if [ "$REMOVE_APP" = 1 ]; then
  export PATH="$HOME/.local/bin:$PATH"
  uv tool uninstall open-webui || true
  echo "Open WebUI 程序已卸载"
fi
if [ "$PURGE" = 1 ]; then
  read -r -p "确定删除 $DATA_DIR（聊天记录、知识库、账号）？输入 yes 确认: " ans
  [ "$ans" = "yes" ] && rm -rf "$DATA_DIR" && echo "数据已删除"
else
  echo "数据保留在 $DATA_DIR"
fi
