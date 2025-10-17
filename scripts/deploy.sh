#!/bin/bash

# ============================================
# Kubernetes 部署脚本
# ============================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查参数
if [ $# -eq 0 ]; then
    echo -e "${RED}错误: 请指定部署环境${NC}"
    echo ""
    echo "用法: $0 <environment> [version]"
    echo ""
    echo "环境选项:"
    echo "  dev       - 开发环境"
    echo "  staging   - 测试环境"
    echo "  prod      - 生产环境"
    echo ""
    echo "示例:"
    echo "  $0 dev"
    echo "  $0 prod v1.0.0"
    exit 1
fi

ENVIRONMENT=$1
VERSION=${2:-latest}

# 配置
REGISTRY="registry.cn-hangzhou.aliyuncs.com"
IMAGE_NAME="gva"

# 根据环境设置命名空间
case "$ENVIRONMENT" in
    "dev"|"development")
        NAMESPACE="gva-dev"
        ENV_NAME="开发环境"
        ;;
    "staging"|"test")
        NAMESPACE="gva-staging"
        ENV_NAME="测试环境"
        ;;
    "prod"|"production")
        NAMESPACE="gva-prod"
        ENV_NAME="生产环境"
        ;;
    *)
        echo -e "${RED}错误: 无效的环境 '$ENVIRONMENT'${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Kubernetes 部署脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "🌍 环境: $ENV_NAME"
echo "📦 命名空间: $NAMESPACE"
echo "🏷️  版本: $VERSION"
echo ""

# ============================================
# 部署前确认
# ============================================
if [ "$ENVIRONMENT" == "prod" ] || [ "$ENVIRONMENT" == "production" ]; then
    echo -e "${RED}⚠️  警告: 即将部署到生产环境！${NC}"
    echo ""
    read -p "请输入 'YES' 确认部署: " CONFIRM
    if [ "$CONFIRM" != "YES" ]; then
        echo "部署已取消"
        exit 0
    fi
fi

# ============================================
# 检查 kubectl 连接
# ============================================
echo -e "${BLUE}🔍 检查 Kubernetes 连接...${NC}"
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ 无法连接到 Kubernetes 集群${NC}"
    echo "请检查 kubectl 配置"
    exit 1
fi
echo -e "${GREEN}✅ Kubernetes 连接正常${NC}"

# ============================================
# 创建命名空间（如果不存在）
# ============================================
echo ""
echo -e "${BLUE}📁 确保命名空间存在...${NC}"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✅ 命名空间就绪${NC}"

# ============================================
# 备份当前部署
# ============================================
echo ""
echo -e "${BLUE}💾 备份当前部署配置...${NC}"

BACKUP_DIR="./backup/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

kubectl get deployment gva-server -n "$NAMESPACE" -o yaml > "$BACKUP_DIR/server-deployment.yaml" 2>/dev/null || echo "后端服务不存在，跳过备份"
kubectl get deployment gva-web -n "$NAMESPACE" -o yaml > "$BACKUP_DIR/web-deployment.yaml" 2>/dev/null || echo "前端服务不存在，跳过备份"

echo -e "${GREEN}✅ 备份保存到: $BACKUP_DIR${NC}"

# ============================================
# 更新后端服务
# ============================================
echo ""
echo -e "${BLUE}🚀 部署后端服务...${NC}"

SERVER_IMAGE="${REGISTRY}/${IMAGE_NAME}/server:${VERSION}"
echo "   镜像: $SERVER_IMAGE"

# 检查镜像是否存在
if docker manifest inspect "$SERVER_IMAGE" > /dev/null 2>&1; then
    kubectl set image deployment/gva-server \
        gin-vue-admin-container="$SERVER_IMAGE" \
        -n "$NAMESPACE"
    
    echo "   等待后端服务就绪..."
    kubectl rollout status deployment/gva-server -n "$NAMESPACE" --timeout=5m
    
    echo -e "${GREEN}✅ 后端服务部署成功${NC}"
else
    echo -e "${RED}❌ 镜像不存在: $SERVER_IMAGE${NC}"
    exit 1
fi

# ============================================
# 更新前端服务
# ============================================
echo ""
echo -e "${BLUE}🚀 部署前端服务...${NC}"

WEB_IMAGE="${REGISTRY}/${IMAGE_NAME}/web:${VERSION}"
echo "   镜像: $WEB_IMAGE"

# 检查镜像是否存在
if docker manifest inspect "$WEB_IMAGE" > /dev/null 2>&1; then
    kubectl set image deployment/gva-web \
        gva-web-container="$WEB_IMAGE" \
        -n "$NAMESPACE"
    
    echo "   等待前端服务就绪..."
    kubectl rollout status deployment/gva-web -n "$NAMESPACE" --timeout=5m
    
    echo -e "${GREEN}✅ 前端服务部署成功${NC}"
else
    echo -e "${RED}❌ 镜像不存在: $WEB_IMAGE${NC}"
    exit 1
fi

# ============================================
# 验证部署
# ============================================
echo ""
echo -e "${BLUE}🔍 验证部署状态...${NC}"

# 检查 Pod 状态
echo ""
echo "Pod 状态:"
kubectl get pods -n "$NAMESPACE" -l app=gva-server
kubectl get pods -n "$NAMESPACE" -l app=gva-web

# 检查服务状态
echo ""
echo "Service 状态:"
kubectl get svc -n "$NAMESPACE"

# 等待服务稳定
echo ""
echo "⏱️  等待服务稳定 (30秒)..."
sleep 30

# 健康检查
echo ""
echo -e "${BLUE}🏥 执行健康检查...${NC}"

# 获取服务地址
SERVICE_URL=$(kubectl get svc gva-server -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")

if [ -n "$SERVICE_URL" ]; then
    echo "   服务地址: http://$SERVICE_URL:8888"
    # 健康检查（如果有健康检查端点）
    # if curl -f -s "http://$SERVICE_URL:8888/health" > /dev/null; then
    #     echo -e "${GREEN}✅ 健康检查通过${NC}"
    # else
    #     echo -e "${RED}❌ 健康检查失败${NC}"
    #     exit 1
    # fi
else
    echo "   ⚠️  无法获取外部访问地址，跳过健康检查"
fi

# ============================================
# 完成
# ============================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  🎉 部署完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "📊 部署信息:"
echo "   环境: $ENV_NAME"
echo "   命名空间: $NAMESPACE"
echo "   版本: $VERSION"
echo "   备份位置: $BACKUP_DIR"
echo ""
echo "🔧 常用命令:"
echo "   查看 Pod: kubectl get pods -n $NAMESPACE"
echo "   查看日志: kubectl logs -f deployment/gva-server -n $NAMESPACE"
echo "   回滚: ./scripts/rollback.sh $ENVIRONMENT"
echo ""



