# 长伴咨询 · Open WebUI 本地部署配置

本仓库保存长伴咨询在 Mac 上本地部署 [Open WebUI](https://github.com/open-webui/open-webui)（0.12.0，不用 Docker）的配置：长伴品牌图标、开机自启服务文件和安装脚本。**不含**程序本身、聊天记录、知识库、账号数据库和任何密钥。

## 目录
- `brand/`：长伴图标（浏览器标签、侧边栏、启动画面等）
- `launchd/com.changban.open-webui.plist`：开机自启服务模板（`$HOME` 安装时自动替换）
- `scripts/install.sh`：一键安装（可重复运行）
- `scripts/apply-brand.sh`：升级后重新替换图标并重启
- `scripts/uninstall.sh`：卸载服务（默认保留数据）

## 安装
```bash
git clone https://github.com/sxxcwj/changban-open-webui.git
cd changban-open-webui
bash scripts/install.sh
```
脚本会：用 `uv` 安装 Open WebUI（Python 3.11）→ 从 ModelScope 下载文档检索模型 all-MiniLM-L6-v2 → 安装开机自启服务 → 替换长伴图标 → 启动并等待就绪。

完成后浏览器打开 http://localhost:8080 ，第一个注册的账号自动成为管理员。数据在 `~/open-webui-data`，日志在 `~/open-webui-data/server.log`。

## 接入 MiniMax
「管理员设置 › 外部连接」中添加 / 编辑 OpenAI 兼容连接：
- URL：`https://api.minimaxi.com/v1`（注意 minimax 后面有个 i）
- Key：MiniMax 开放平台创建的 API Key
- 如果保存后模型列表为空，在「Model IDs」手动添加模型名（如 `MiniMax-M2`，以账号后台可用模型为准）

未安装 Ollama 时，日志里连不上 `localhost:11434` 的报错可以忽略，或在同页关闭 Ollama 连接。

## 注意事项
- **设置不保存**：服务设置了 `ENABLE_PERSISTENT_CONFIG=false`（为解决国内网络导致的启动卡住），网页「管理员设置」里改的部分选项重启后会恢复。需要永久修改请改 plist 里的环境变量后重新运行 `install.sh`。
- **品牌授权**：Open WebUI 许可只允许 30 天内用户不超过 50 人时自定义品牌；超过需购买企业授权。页面名称后的「(Open WebUI)」后缀会保留。
- **升级**：`uv tool upgrade open-webui` 会覆盖图标，升级后运行 `bash scripts/apply-brand.sh`。原版图标备份在 `~/open-webui-data/brand/original`。

## 卸载
```bash
bash scripts/uninstall.sh                # 只移除服务，保留程序和数据
bash scripts/uninstall.sh --remove-app   # 同时卸载程序
bash scripts/uninstall.sh --purge-data   # 删除数据（需输入 yes 确认）
```
