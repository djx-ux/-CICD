#!/bin/bash

# ============================================
# 服务器容器修复脚本
# ============================================

set -e

echo "🔧 开始修复服务器容器..."
echo ""

# 服务器信息
SERVER_HOST="119.29.95.149"
SERVER_USER="root"

echo "📡 连接到服务器: ${SERVER_USER}@${SERVER_HOST}"
echo ""

ssh ${SERVER_USER}@${SERVER_HOST} << 'ENDSSH'
set -e

echo "📊 当前容器状态:"
docker ps -a

echo ""
echo "🔍 检查 docker-compose 文件..."

# 查找 docker-compose 文件
if [ -f "/opt/gin-vue-admin/deploy/docker-compose/docker-compose.yaml" ]; then
    COMPOSE_FILE="/opt/gin-vue-admin/deploy/docker-compose/docker-compose.yaml"
    COMPOSE_DIR="/opt/gin-vue-admin/deploy/docker-compose"
elif [ -f "/opt/gin-vue-admin/docker-compose.yaml" ]; then
    COMPOSE_FILE="/opt/gin-vue-admin/docker-compose.yaml"
    COMPOSE_DIR="/opt/gin-vue-admin"
else
    echo "❌ 找不到 docker-compose 文件，需要先同步代码"
    echo ""
    echo "建议执行以下步骤:"
    echo "1. 在本地推送代码: git push origin main"
    echo "2. 等待 GitHub Actions 自动部署"
    exit 1
fi

echo "✅ 找到配置文件: ${COMPOSE_FILE}"
echo ""

cd ${COMPOSE_DIR}

echo "⏹️  停止所有容器..."
docker-compose -f docker-compose.yaml down || true

echo ""
echo "🧹 清理旧容器和镜像..."
docker container prune -f
docker image prune -f

echo ""
echo "🔨 重新构建镜像..."
docker-compose -f docker-compose.yaml build --no-cache

echo ""
echo "🚀 启动所有服务..."
docker-compose -f docker-compose.yaml up -d

echo ""
echo "⏳ 等待服务启动（30秒）..."
sleep 30

echo ""
echo "📊 容器状态:"
docker-compose -f docker-compose.yaml ps

echo ""
echo "✅ 修复完成！"
echo ""
echo "查看日志:"
echo "  docker-compose -f ${COMPOSE_FILE} logs -f web"
echo "  docker-compose -f ${COMPOSE_FILE} logs -f server"

ENDSSH

echo ""
echo "🎉 服务器修复完成！"
echo ""
echo "📍 访问地址:"
echo "  前端: http://119.29.95.149:8080"
echo "  后端: http://119.29.95.149:8888"
echo ""

