# sync-remote-server

用 Docker 构建并导出远程开发所需的 **VS Code Server** 与 **Cursor Server** 扩展包（extensions）。

本项目会在容器内：
- 拉取 *最新* 的 VS Code Server / Cursor Server 版本
- 安装一组预置扩展
- 将对应的 `extensions` 目录打包为 `tar.gz`
- 将产物放到镜像内的 `/root/dist`，并通过 `make extract` 导出到本机

## 依赖

- Docker（能执行 `docker build/create/cp/rm`）
- Make（或直接用 Docker 命令也可以）

> 构建镜像时需要能访问：
> - `https://update.code.visualstudio.com/`
> - `https://www.cursor.com/`

## 快速开始

在项目根目录执行：

```bash
make build
make extract
```

导出后，本机会得到：

- `./dist/vscode-server.tar.gz`
- `./dist/cursor-server.tar.gz`

## 常用命令

### 构建镜像

```bash
make build
```

默认镜像名：`sync-remote-server:latest`

可覆盖：

```bash
make build IMAGE=my-sync-remote-server:dev
```

### 导出产物（dist）

```bash
make extract
```

默认：
- 从镜像内拷贝 `/root/dist`
- 导出到当前目录（`DEST=.`），因此通常会生成 `./dist/...`

可覆盖导出目录：

```bash
make extract DEST=/tmp
# 产物路径：/tmp/dist/*.tar.gz
```

## 产物说明

镜像最终阶段会包含：

- `/root/dist/vscode-server.tar.gz`
- `/root/dist/cursor-server.tar.gz`

它们分别是以下目录的打包结果：
- VS Code Server：`$HOME/.vscode-server/extensions`
- Cursor Server：`$HOME/.cursor-server/extensions`

## 脚本说明

- `scripts/vscode.sh`
  - 通过更新接口获取 **最新** VS Code Server 版本号（commit/version）
  - 下载并解压 server 到：`$HOME/.vscode-server/bin/<COMMIT>`
  - 使用 `code-server --install-extension` 安装扩展
  - 打包：`$HOME/.vscode-server/extensions` → `$HOME/vscode-server.tar.gz`

- `scripts/cursor.sh`
  - 调 Cursor 下载接口获取 `commitSha` 和 `rehUrl`
  - 下载并解压 server 到：`$HOME/.cursor-server/bin/<COMMIT>`
  - 使用 `cursor-server --install-extension` 安装扩展
  - 打包：`$HOME/.cursor-server/extensions` → `$HOME/cursor-server.tar.gz`

## 预置扩展

两套脚本当前安装相同扩展：

- `anyscalecompute.anyscale-workspaces`
- `ms-python.python`
- `ms-toolsai.jupyter-renderers`
- `ms-toolsai.jupyter-keymap`
- `ms-toolsai.jupyter`

如需增删扩展，编辑：
- `scripts/vscode.sh` 的 `plugins=(...)`
- `scripts/cursor.sh` 的 `plugins=(...)`

## 常见问题

- 构建失败/下载超时：确认容器网络可访问 `update.code.visualstudio.com` / `www.cursor.com`，以及代理/镜像源配置。
- `jq`/`curl` 缺失：脚本已在 Debian 内通过 `apt-get install -y curl tar jq` 安装；如果你改用其它基础镜像，可能需要调整安装命令。

## 目录结构

- `Dockerfile`：构建与产物收集
- `Makefile`：`build` 与 `extract`
- `scripts/`：下载 server、安装扩展、打包 extensions
