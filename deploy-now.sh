#!/bin/bash

# 立即部署到服务器
SERVER_HOST="119.29.95.149"
SERVER_USER="root"

echo "🚀 开始部署到服务器..."
echo ""

# 1. 同步代码到服务器
echo "📦 同步代码到服务器..."
rsync -avz --exclude='.git' \
  --exclude='node_modules' \
  --exclude='web/dist' \
  --exclude='web/node_modules' \
  ./ ${SERVER_USER}@${SERVER_HOST}:/opt/gin-vue-admin/

echo ""
echo "✅ 代码同步完成"
echo ""

# 2. 在服务器上构建和启动
echo "🔨 在服务器上构建和启动容器..."
ssh ${SERVER_USER}@${SERVER_HOST} << 'ENDSSH'
set -e
cd /opt/gin-vue-admin/deploy/docker-compose

echo "📊 当前容器状态:"
docker ps -a

echo ""
echo "⏹️  停止所有旧容器..."
docker-compose down || true

echo ""
echo "🧹 清理..."
docker container prune -f
docker image prune -f

echo ""
echo "🔨 构建镜像..."
docker-compose build --no-cache

echo ""
echo "🚀 启动所有服务..."
docker-compose up -d

echo ""
echo "⏳ 等待服务启动（30秒）..."
sleep 30

echo ""
echo "📊 最终容器状态:"
docker ps

echo ""
echo "✅ 部署完成！"
ENDSSH

echo ""
echo "🎉 部署成功！"
echo ""
echo "📍 访问地址:"
echo "  前端: http://119.29.95.149:8080"
echo "  后端: http://119.29.95.149:8888"
echo ""
