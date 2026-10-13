#!/usr/bin/env bash
# 升级 Open WebUI 后重新替换长伴图标并重启服务
set -euo pipefail
# shellcheck source=scripts/common.sh
source "$(dirname "$0")/common.sh"
apply_brand
restart_service
wait_health
