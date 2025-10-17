#!/bin/bash

# ============================================
# Docker 镜像推送脚本
# ============================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 配置
REGISTRY="${DOCKER_REGISTRY:-registry.cn-hangzhou.aliyuncs.com}"
IMAGE_NAME="${IMAGE_NAME:-gva}"
TAG="${TAG:-latest}"
PUSH_WEB="${PUSH_WEB:-true}"
PUSH_SERVER="${PUSH_SERVER:-true}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Docker 镜像推送脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# ============================================
# 登录 Docker Registry
# ============================================
echo -e "${YELLOW}🔐 登录 Docker Registry...${NC}"

if [ -n "$DOCKER_USERNAME" ] && [ -n "$DOCKER_PASSWORD" ]; then
    echo "$DOCKER_PASSWORD" | docker login "$REGISTRY" -u "$DOCKER_USERNAME" --password-stdin
    echo -e "${GREEN}✅ 登录成功${NC}"
else
    echo -e "${YELLOW}⚠️  未设置 DOCKER_USERNAME 和 DOCKER_PASSWORD${NC}"
    echo "   将使用本地已登录的凭证"
fi

# ============================================
# 推送后端镜像
# ============================================
if [ "$PUSH_SERVER" == "true" ]; then
    echo ""
    echo -e "${YELLOW}📤 推送后端镜像...${NC}"
    
    docker push "${REGISTRY}/${IMAGE_NAME}/server:${TAG}"
    
    # 如果不是 latest 标签，也推送 latest
    if [ "$TAG" != "latest" ]; then
        docker push "${REGISTRY}/${IMAGE_NAME}/server:latest"
    fi
    
    echo -e "${GREEN}✅ 后端镜像推送成功${NC}"
    echo "   ${REGISTRY}/${IMAGE_NAME}/server:${TAG}"
fi

# ============================================
# 推送前端镜像
# ============================================
if [ "$PUSH_WEB" == "true" ]; then
    echo ""
    echo -e "${YELLOW}📤 推送前端镜像...${NC}"
    
    docker push "${REGISTRY}/${IMAGE_NAME}/web:${TAG}"
    
    # 如果不是 latest 标签，也推送 latest
    if [ "$TAG" != "latest" ]; then
        docker push "${REGISTRY}/${IMAGE_NAME}/web:latest"
    fi
    
    echo -e "${GREEN}✅ 前端镜像推送成功${NC}"
    echo "   ${REGISTRY}/${IMAGE_NAME}/web:${TAG}"
fi

# ============================================
# 完成
# ============================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  镜像推送完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "📦 已推送的镜像:"
if [ "$PUSH_SERVER" == "true" ]; then
    echo "   - ${REGISTRY}/${IMAGE_NAME}/server:${TAG}"
fi
if [ "$PUSH_WEB" == "true" ]; then
    echo "   - ${REGISTRY}/${IMAGE_NAME}/web:${TAG}"
fi
echo ""
echo "下一步:"
echo "  部署到环境: ./scripts/deploy.sh <environment>"
echo "  environment: dev | staging | prod"
echo ""



