#!/usr/bin/env bash
# 长伴咨询 Open WebUI 一键安装（macOS，无 Docker，可重复执行）
set -euo pipefail
# shellcheck source=scripts/common.sh
source "$(dirname "$0")/common.sh"

[ "$(uname)" = "Darwin" ] || { echo "仅支持 macOS" >&2; exit 1; }

# 1. uv
if ! command -v uv >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/uv" ]; then
  echo "安装 uv ..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
export PATH="$HOME/.local/bin:$PATH"

# 2. Open WebUI
if [ -x "$HOME/.local/bin/open-webui" ]; then
  echo "Open WebUI 已安装，跳过（升级请运行: uv tool upgrade open-webui，然后 scripts/apply-brand.sh）"
else
  uv tool install --python 3.11 open-webui
fi

# 3. 向量模型（ModelScope 国内镜像）
MODEL_DIR="$DATA_DIR/models/all-MiniLM-L6-v2"
BASE="https://www.modelscope.cn/models/sentence-transformers/all-MiniLM-L6-v2/resolve/master"
mkdir -p "$MODEL_DIR/1_Pooling"
for f in config.json config_sentence_transformers.json modules.json sentence_bert_config.json \
         special_tokens_map.json tokenizer.json tokenizer_config.json vocab.txt model.safetensors \
         1_Pooling/config.json; do
  if [ -s "$MODEL_DIR/$f" ]; then
    echo "已存在: $f"
  else
    echo "下载: $f"
    curl -fL --retry 3 -o "$MODEL_DIR/$f.part" "$BASE/$f"
    mv "$MODEL_DIR/$f.part" "$MODEL_DIR/$f"
  fi
done

# 4. launchd 服务
mkdir -p "$HOME/Library/LaunchAgents" "$DATA_DIR"
sed "s#\$HOME#$HOME#g" "$REPO_DIR/launchd/$LABEL.plist" > "$PLIST_DST"
plutil -lint "$PLIST_DST" >/dev/null

# 5. 品牌图标
apply_brand

# 6. 启动并检查
restart_service
wait_health
