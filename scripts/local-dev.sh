#!/bin/bash

# ============================================
# 本地开发环境启动脚本
# ============================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  本地开发环境启动${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 进入项目根目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

# ============================================
# 启动 Docker Compose
# ============================================
echo -e "${BLUE}🐳 启动 Docker 服务...${NC}"

cd deploy/docker-compose

# 检查是否已经运行
if docker-compose ps | grep -q "Up"; then
    echo -e "${YELLOW}⚠️  服务已在运行，先停止...${NC}"
    docker-compose down
fi

# 启动服务
echo "启动 MySQL, Redis, Server, Web..."
docker-compose up -d

# 等待服务启动
echo ""
echo "⏱️  等待服务启动..."
sleep 10

# 检查服务状态
echo ""
echo "📊 服务状态:"
docker-compose ps

# ============================================
# 检查服务健康
# ============================================
echo ""
echo -e "${BLUE}🏥 检查服务健康状态...${NC}"

# 等待 MySQL 就绪
echo -n "等待 MySQL 就绪..."
for i in {1..30}; do
    if docker exec gva-mysql mysqladmin ping -h localhost -ugva -pAa@6447985 2>/dev/null | grep -q "alive"; then
        echo -e " ${GREEN}✅${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# 等待 Redis 就绪
echo -n "等待 Redis 就绪..."
for i in {1..30}; do
    if docker exec gva-redis redis-cli ping 2>/dev/null | grep -q "PONG"; then
        echo -e " ${GREEN}✅${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# 等待后端服务就绪
echo -n "等待后端服务就绪..."
for i in {1..30}; do
    if curl -s http://localhost:8888 > /dev/null 2>&1; then
        echo -e " ${GREEN}✅${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# 等待前端服务就绪
echo -n "等待前端服务就绪..."
for i in {1..30}; do
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo -e " ${GREEN}✅${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# ============================================
# 显示访问信息
# ============================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 开发环境已启动！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "🌐 访问地址:"
echo "   前端: http://localhost:8080"
echo "   后端: http://localhost:8888"
echo "   MySQL: localhost:13306"
echo "   Redis: localhost:16379"
echo ""
echo "🔧 常用命令:"
echo "   查看日志: docker-compose logs -f"
echo "   查看后端日志: docker logs -f gva-server"
echo "   查看前端日志: docker logs -f gva-web"
echo "   停止服务: docker-compose down"
echo "   重启服务: docker-compose restart"
echo ""
echo "💾 数据库信息:"
echo "   数据库名: qmPlus"
echo "   用户名: gva"
echo "   密码: Aa@6447985"
echo "   端口: 13306"
echo ""
echo "📝 开发提示:"
echo "   - 修改后端代码后需要重启: docker-compose restart server"
echo "   - 修改前端代码后需要重新构建: docker-compose up -d --build web"
echo "   - 查看实时日志: docker-compose logs -f server web"
echo ""



