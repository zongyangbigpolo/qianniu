#!/usr/bin/env bash
#
# 千牛 (QianNiu) 更新部署脚本
#
# 拉取 GHCR 上最新的 :main 镜像并用新镜像重建容器（mysql/redis 数据不受影响）。
# 适用于「代码已经 push、GitHub Actions 已经构建成功」之后，在 ECS 上更新正在运行的服务。
#
# 用法（在 /opt/qianniu 目录下）：
#   bash deploy/update.sh
# 或者配置好别名后：
#   docker-update-polo
#
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.prod.yml}"

if [ ! -f "${COMPOSE_FILE}" ]; then
  echo "❌ 找不到 ${COMPOSE_FILE}，请在 /opt/qianniu 目录下执行本脚本"
  exit 1
fi

echo "🐮 千牛 (QianNiu) 更新部署"
echo ""

echo "⬇️  拉取最新镜像..."
docker compose -f "${COMPOSE_FILE}" pull

echo ""
echo "🚀 用新镜像重建容器..."
docker compose -f "${COMPOSE_FILE}" up -d

echo ""
echo "📋 当前服务状态:"
docker compose -f "${COMPOSE_FILE}" ps

echo ""
echo "✅ 更新完成！查看后端启动日志: docker compose -f ${COMPOSE_FILE} logs -f server"
