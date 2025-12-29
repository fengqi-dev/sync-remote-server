#!/usr/bin/env bash
set -e
cd $HOME

echo "==> 安装基础依赖"
apt-get update -y
apt-get install -y curl tar jq

echo "==> 获取最新的 Cursor Server 版本号"
JSON=$(curl -s -L \
  "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=latest")
COMMIT=$(echo "$JSON" | jq -r '.commitSha')
REH_URL=$(echo "$JSON" | jq -r '.rehUrl')
echo "最新版本号: $COMMIT, url: $REH_URL"

SERVER_DIR="$HOME/.cursor-server/bin/$COMMIT"

if [ -d "$SERVER_DIR" ]; then
  echo "==> Cursor Server 已存在：$SERVER_DIR"
else
  echo "==> 创建目录: $SERVER_DIR"
  mkdir -p "$SERVER_DIR"

  echo "==> 下载 Cursor Server"
  curl -L -o /tmp/cursor-server.tar.gz "$REH_URL"

  echo "==> 解压"
  tar -xzf /tmp/cursor-server.tar.gz -C "$SERVER_DIR" --strip-components=1

  echo "==> 清理"
  rm /tmp/cursor-server.tar.gz

  chmod +x "$SERVER_DIR/bin/cursor-server"
fi

echo "==> 安装插件"

plugins=(
  "anyscalecompute.anyscale-workspaces"
  "ms-python.python"
  "ms-toolsai.jupyter-renderers"
  "ms-toolsai.jupyter-keymap"
  "ms-toolsai.jupyter"
)

for plugin in "${plugins[@]}"; do
  echo "安装插件: $plugin"
  "$SERVER_DIR/bin/cursor-server" \
    --install-extension "$plugin" \
    --force
done

echo "==> 查看已安装扩展"
"$SERVER_DIR/bin/cursor-server" --list-extensions --show-versions

echo "==> 打包extensions目录"
tar -czf "$HOME/cursor-server.tar.gz" -C "$HOME/.cursor-server" extensions
echo "打包完成: $HOME/cursor-server.tar.gz"