# shellcheck shell=bash
# 公共变量（被其他脚本 source）
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LABEL="com.changban.open-webui"
PLIST_DST="$HOME/Library/LaunchAgents/$LABEL.plist"
DATA_DIR="$HOME/open-webui-data"
PKG="$HOME/.local/share/uv/tools/open-webui/lib/python3.11/site-packages/open_webui"
BRAND_FILES="favicon.png logo.png apple-touch-icon.png favicon-96x96.png favicon.ico web-app-manifest-192x192.png web-app-manifest-512x512.png splash.png splash-dark.png"

apply_brand() {
  [ -d "$PKG" ] || { echo "未找到 Open WebUI 安装目录: $PKG" >&2; return 1; }
  local backup="$DATA_DIR/brand/original"
  for sub in static frontend/static; do
    local dir="$PKG/$sub"
    [ -d "$dir" ] || continue
    mkdir -p "$backup/$sub"
    for f in $BRAND_FILES favicon.svg; do
      if [ -f "$dir/$f" ] && [ ! -f "$backup/$sub/$f" ]; then
        cp "$dir/$f" "$backup/$sub/$f"
      fi
    done
    for f in $BRAND_FILES; do
      cp "$REPO_DIR/brand/$f" "$dir/$f"
    done
    rm -f "$dir/favicon.svg"
    echo "已替换图标: $dir"
  done
}

restart_service() {
  launchctl unload "$PLIST_DST" 2>/dev/null || true
  launchctl load "$PLIST_DST"
}

wait_health() {
  echo "等待服务启动（首次可能需要几分钟）..."
  for _ in $(seq 1 120); do
    if curl -fsS http://localhost:8080/health >/dev/null 2>&1; then
      echo "服务已就绪: http://localhost:8080"; return 0
    fi
    sleep 5
  done
  echo "等待超时，请查看日志: $DATA_DIR/server.log" >&2; return 1
}
