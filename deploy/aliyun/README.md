# 阿里云新加坡服务器部署（Open WebUI）

访问地址：https://cbrlzy.com:8444（用 IP 访问会有证书警告）。
本目录只放配置，**密钥、证书私钥不入库**。服务器上已有的测评平台、nginx 80/8443、xray 443 均不受影响。

## 文件
- `open-webui.service`：systemd 服务（/etc/systemd/system/），监听 127.0.0.1:8081，内存上限 1200M
- `open-webui-8444.conf`：nginx 反代（/etc/nginx/conf.d/），8444 TLS + websocket
- `secret.env.example`：密钥模板，实际文件为 /etc/open-webui/secret.env

## 安装步骤
1. **加 2G swap**（2G 内存机器必需）
   ```bash
   fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
   echo '/swapfile none swap sw 0 0' >> /etc/fstab
   ```
2. **建用户与目录**：`useradd -r -m -d /opt/open-webui openwebui`
3. **uv + Python 3.11 安装**（以 openwebui 用户）
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   uv python install 3.11
   uv venv --python 3.11 /opt/open-webui/venv
   uv pip install --python /opt/open-webui/venv open-webui
   ```
4. **嵌入模型离线**：从 ModelScope 下载 all-MiniLM-L6-v2 到 `/opt/open-webui/data/models/`（服务已设 HF_HUB_OFFLINE=1）。
5. **密钥**：按 `secret.env.example` 创建 `/etc/open-webui/secret.env`，`chmod 600`。
6. **systemd**：复制 service 文件，`systemctl daemon-reload && systemctl enable --now open-webui`
7. **nginx**：复制 conf，证书放 /etc/changban/tls/（不入库），`nginx -t && systemctl reload nginx`
8. **防火墙**：阿里云轻量服务器控制台 → 防火墙 → 添加 TCP 8444。

## 首次使用
- 第一个注册的账号自动成为管理员。
- 注册后在「管理员设置」关闭新用户注册（也可将 service 中 `ENABLE_SIGNUP` 改为 false 后重启）。
- 「外部连接」添加 MiniMax：地址 `https://api.minimaxi.com/v1`，填 API Key（Key 只在界面里填，不入库）。

## 升级与品牌
升级 `uv pip install -U open-webui` 会覆盖品牌图标。原始图标备份在 `/opt/open-webui/brand-backup`；升级后把本库 `brand/` 下的文件重新复制到 venv 内 `open_webui/static` 与 `open_webui/frontend/static`，再 `systemctl restart open-webui`。

## 已知
- 未装 ffmpeg，语音转文字不可用。
