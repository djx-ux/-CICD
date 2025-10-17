#!/bin/bash

# ============================================
# Kubernetes 回滚脚本
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
    echo -e "${RED}错误: 请指定环境${NC}"
    echo ""
    echo "用法: $0 <environment> [revision]"
    echo ""
    echo "环境选项:"
    echo "  dev       - 开发环境"
    echo "  staging   - 测试环境"
    echo "  prod      - 生产环境"
    echo ""
    echo "revision: 可选，指定回滚到的修订版本号，不指定则回滚到上一版本"
    echo ""
    echo "示例:"
    echo "  $0 prod           # 回滚到上一版本"
    echo "  $0 prod 5         # 回滚到第5个版本"
    exit 1
fi

ENVIRONMENT=$1
REVISION=$2

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

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  ⚠️  Kubernetes 回滚操作${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo "🌍 环境: $ENV_NAME"
echo "📦 命名空间: $NAMESPACE"
if [ -n "$REVISION" ]; then
    echo "🔄 回滚到版本: $REVISION"
else
    echo "🔄 回滚到: 上一版本"
fi
echo ""

# ============================================
# 回滚确认
# ============================================
if [ "$ENVIRONMENT" == "prod" ] || [ "$ENVIRONMENT" == "production" ]; then
    echo -e "${RED}⚠️  警告: 即将回滚生产环境！${NC}"
    echo ""
    read -p "请输入 'YES' 确认回滚: " CONFIRM
    if [ "$CONFIRM" != "YES" ]; then
        echo "回滚已取消"
        exit 0
    fi
fi

# ============================================
# 查看历史版本
# ============================================
echo ""
echo -e "${BLUE}📜 查看部署历史...${NC}"
echo ""
echo "后端服务历史:"
kubectl rollout history deployment/gva-server -n "$NAMESPACE"

echo ""
echo "前端服务历史:"
kubectl rollout history deployment/gva-web -n "$NAMESPACE"

# ============================================
# 执行回滚
# ============================================
echo ""
echo -e "${YELLOW}🔄 开始回滚...${NC}"

if [ -n "$REVISION" ]; then
    # 回滚到指定版本
    echo "回滚后端到版本 $REVISION..."
    kubectl rollout undo deployment/gva-server --to-revision="$REVISION" -n "$NAMESPACE"
    
    echo "回滚前端到版本 $REVISION..."
    kubectl rollout undo deployment/gva-web --to-revision="$REVISION" -n "$NAMESPACE"
else
    # 回滚到上一版本
    echo "回滚后端到上一版本..."
    kubectl rollout undo deployment/gva-server -n "$NAMESPACE"
    
    echo "回滚前端到上一版本..."
    kubectl rollout undo deployment/gva-web -n "$NAMESPACE"
fi

# ============================================
# 等待回滚完成
# ============================================
echo ""
echo -e "${BLUE}⏱️  等待回滚完成...${NC}"

echo "等待后端服务..."
kubectl rollout status deployment/gva-server -n "$NAMESPACE" --timeout=5m

echo "等待前端服务..."
kubectl rollout status deployment/gva-web -n "$NAMESPACE" --timeout=5m

# ============================================
# 验证回滚
# ============================================
echo ""
echo -e "${BLUE}🔍 验证回滚结果...${NC}"

# 检查 Pod 状态
echo ""
echo "Pod 状态:"
kubectl get pods -n "$NAMESPACE"

# 检查最近的事件
echo ""
echo "最近事件:"
kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' | tail -10

# 等待服务稳定
echo ""
echo "⏱️  等待服务稳定 (30秒)..."
sleep 30

# 健康检查
echo ""
echo -e "${BLUE}🏥 执行健康检查...${NC}"

# 获取一个 Pod 进行健康检查
POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l app=gva-server -o jsonpath='{.items[0].metadata.name}')
if [ -n "$POD_NAME" ]; then
    echo "检查 Pod: $POD_NAME"
    kubectl logs "$POD_NAME" -n "$NAMESPACE" --tail=20
else
    echo -e "${RED}❌ 无法找到运行中的 Pod${NC}"
    exit 1
fi

# ============================================
# 完成
# ============================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 回滚完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "📊 当前状态:"
kubectl get deployments -n "$NAMESPACE"
echo ""
echo "🔧 常用命令:"
echo "   查看 Pod: kubectl get pods -n $NAMESPACE"
echo "   查看日志: kubectl logs -f deployment/gva-server -n $NAMESPACE"
echo "   再次回滚: ./scripts/rollback.sh $ENVIRONMENT [revision]"
echo ""



