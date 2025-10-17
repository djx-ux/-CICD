#!/bin/bash

# ============================================
# Docker 镜像构建脚本
# ============================================

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置
REGISTRY="${DOCKER_REGISTRY:-registry.cn-hangzhou.aliyuncs.com}"
IMAGE_NAME="${IMAGE_NAME:-gva}"
TAG="${TAG:-latest}"
BUILD_WEB="${BUILD_WEB:-true}"
BUILD_SERVER="${BUILD_SERVER:-true}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Docker 镜像构建脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "📦 镜像仓库: $REGISTRY"
echo "🏷️  镜像标签: $TAG"
echo "🌐 构建前端: $BUILD_WEB"
echo "⚙️  构建后端: $BUILD_SERVER"
echo ""

# 进入项目根目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

# ============================================
# 构建后端镜像
# ============================================
if [ "$BUILD_SERVER" == "true" ]; then
    echo -e "${YELLOW}🔨 开始构建后端镜像...${NC}"
    
    cd server
    
    # 构建镜像
    docker build \
        --build-arg GO_PROXY=https://goproxy.cn,direct \
        --tag "${REGISTRY}/${IMAGE_NAME}/server:${TAG}" \
        --tag "${REGISTRY}/${IMAGE_NAME}/server:latest" \
        --file Dockerfile \
        .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 后端镜像构建成功${NC}"
        echo "   镜像: ${REGISTRY}/${IMAGE_NAME}/server:${TAG}"
    else
        echo -e "${RED}❌ 后端镜像构建失败${NC}"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
fi

# ============================================
# 构建前端镜像
# ============================================
if [ "$BUILD_WEB" == "true" ]; then
    echo ""
    echo -e "${YELLOW}🔨 开始构建前端镜像...${NC}"
    
    cd web
    
    # 构建镜像
    docker build \
        --tag "${REGISTRY}/${IMAGE_NAME}/web:${TAG}" \
        --tag "${REGISTRY}/${IMAGE_NAME}/web:latest" \
        --file Dockerfile \
        .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 前端镜像构建成功${NC}"
        echo "   镜像: ${REGISTRY}/${IMAGE_NAME}/web:${TAG}"
    else
        echo -e "${RED}❌ 前端镜像构建失败${NC}"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
fi

# ============================================
# 显示镜像信息
# ============================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  构建完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "📦 构建的镜像:"
docker images | grep "${REGISTRY}/${IMAGE_NAME}" | head -n 4

# 镜像大小
echo ""
echo "💾 镜像大小:"
if [ "$BUILD_SERVER" == "true" ]; then
    SERVER_SIZE=$(docker images "${REGISTRY}/${IMAGE_NAME}/server:${TAG}" --format "{{.Size}}")
    echo "   后端: $SERVER_SIZE"
fi
if [ "$BUILD_WEB" == "true" ]; then
    WEB_SIZE=$(docker images "${REGISTRY}/${IMAGE_NAME}/web:${TAG}" --format "{{.Size}}")
    echo "   前端: $WEB_SIZE"
fi

echo ""
echo -e "${GREEN}✅ 所有镜像构建完成！${NC}"
echo ""
echo "下一步:"
echo "  1. 推送镜像: ./scripts/push.sh"
echo "  2. 部署到环境: ./scripts/deploy.sh dev"
echo ""



