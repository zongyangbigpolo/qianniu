#!/usr/bin/env bash
#
# 千牛 (QianNiu) 轻量部署脚本
#
# 仅从 GitHub 下载部署所需的 3 个文件（docker-compose.prod.yml、.env.prod.example、
# sql/mysql/ruoyi-vue-pro.sql），不 clone 整个仓库（~600MB+ 源码）。
# 镜像本身由 GitHub Actions 预先构建好并推送到 GHCR，服务器只需要拉镜像即可。
#
# 用法：
#   curl -fsSL https://raw.githubusercontent.com/zongyangbigpolo/qianniu/main/deploy/quick-deploy.sh -o quick-deploy.sh
#   bash quick-deploy.sh
#
# 或者已经把仓库 clone 下来了，也可以直接在仓库根目录运行： bash deploy/quick-deploy.sh
#
set -euo pipefail

REPO="zongyangbigpolo/qianniu"
BRANCH="${BRANCH:-main}"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
INSTALL_DIR="${INSTALL_DIR:-$(pwd)}"

echo "🐮 千牛 (QianNiu) 轻量部署脚本"
echo "目标目录: ${INSTALL_DIR}"
echo ""

command -v docker >/dev/null 2>&1 || { echo "❌ 未检测到 docker，请先安装 Docker"; exit 1; }
if ! docker compose version >/dev/null 2>&1; then
  echo "❌ 未检测到 docker compose 插件（v2）。请安装 docker-compose-plugin，或用较新版本的 Docker。"
  exit 1
fi

mkdir -p "${INSTALL_DIR}/sql/mysql"
cd "${INSTALL_DIR}"

download() {
  local remote_path="$1"
  local local_path="$2"
  # 已经是本地仓库时直接复制，跳过下载
  if [ -f "${local_path}" ] && [ "${SKIP_DOWNLOAD:-}" = "1" ]; then
    echo "✔️  已存在，跳过: ${local_path}"
    return
  fi
  echo "⬇️  下载 ${remote_path}"
  curl -fsSL "${RAW_BASE}/${remote_path}" -o "${local_path}"
}

download "docker-compose.prod.yml" "docker-compose.prod.yml"
download ".env.prod.example" ".env.prod.example"
download "sql/mysql/ruoyi-vue-pro.sql" "sql/mysql/ruoyi-vue-pro.sql"

if [ ! -f .env ]; then
  cp .env.prod.example .env
  echo ""
  echo "📝 已生成 .env，请务必编辑修改其中的默认密码！"
  echo "   vim .env"
  echo ""
  read -rp "现在编辑 .env 吗？(y/N) " ans
  if [[ "${ans}" =~ ^[Yy]$ ]]; then
    "${EDITOR:-vi}" .env
  fi
else
  echo "✔️  .env 已存在，跳过生成（如需重置请手动删除后重新运行）"
fi

echo ""
echo "🚀 拉取镜像并启动..."
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d

echo ""
echo "✅ 部署完成！查看状态: docker compose -f docker-compose.prod.yml ps"
echo "   查看日志: docker compose -f docker-compose.prod.yml logs -f"
