#!/usr/bin/env bash
set -e
cd $HOME

echo "==> 安装基础依赖"
apt-get update -y
apt-get install -y curl tar jq

echo "==> 获取最新的 VS Code Server 版本号"
COMMIT=$(curl -s -L \
  "https://update.code.visualstudio.com/api/update/linux-x64/stable/latest" \
  | jq -r '.version')
echo "最新版本号: $COMMIT"

SERVER_DIR="$HOME/.vscode-server/bin/$COMMIT"

if [ -d "$SERVER_DIR" ]; then
  echo "==> VS Code Server 已存在：$SERVER_DIR"
else
  echo "==> 创建目录: $SERVER_DIR"
  mkdir -p "$SERVER_DIR"

  echo "==> 下载 VS Code Server"
  curl -L -o /tmp/vscode-server.tar.gz \
"https://update.code.visualstudio.com/commit:$COMMIT/server-linux-x64/stable"

  echo "==> 解压"
  tar -xzf /tmp/vscode-server.tar.gz -C "$SERVER_DIR" --strip-components=1

  echo "==> 清理"
  rm /tmp/vscode-server.tar.gz

  chmod +x "$SERVER_DIR/bin/code-server"
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
  "$SERVER_DIR/bin/code-server" \
    --install-extension "$plugin" \
    --force
done

echo "==> 查看已安装扩展"
"$SERVER_DIR/bin/code-server" --list-extensions --show-versions

echo "==> 打包extensions目录"
tar -czf "$HOME/vscode-server.tar.gz" -C "$HOME/.vscode-server" extensions
echo "打包完成: $HOME/vscode-server.tar.gz"