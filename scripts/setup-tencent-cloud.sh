#!/bin/bash

# ============================================
# 腾讯云 CI/CD 快速配置脚本
# ============================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  腾讯云 CI/CD 快速配置脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# ============================================
# 1. 收集腾讯云配置信息
# ============================================
echo -e "${BLUE}📝 步骤 1/5: 收集腾讯云配置信息${NC}"
echo ""

# TCR 镜像仓库地址
echo -e "${YELLOW}请输入你的腾讯云容器镜像仓库地址${NC}"
echo -e "示例: ${GREEN}xxxxxx.tencentcloudcr.com${NC}"
read -p "TCR Registry: " TCR_REGISTRY

# TCR 用户名
echo ""
echo -e "${YELLOW}请输入你的 TCR 用户名${NC}"
echo -e "示例: ${GREEN}100012345678${NC}"
read -p "TCR Username: " TCR_USERNAME

# TCR 密码
echo ""
echo -e "${YELLOW}请输入你的 TCR 访问令牌${NC}"
read -s -p "TCR Password: " TCR_PASSWORD
echo ""

# 验证输入
if [ -z "$TCR_REGISTRY" ] || [ -z "$TCR_USERNAME" ] || [ -z "$TCR_PASSWORD" ]; then
    echo -e "${RED}❌ 错误: 所有字段都是必填的${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ 配置信息收集完成${NC}"

# ============================================
# 2. 更新 Kubernetes 配置文件
# ============================================
echo ""
echo -e "${BLUE}📝 步骤 2/5: 更新 Kubernetes 配置文件${NC}"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

# 备份原文件
BACKUP_DIR="./backup/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "💾 备份原配置文件..."
cp deploy/kubernetes/server/gva-server-deployment.yaml "$BACKUP_DIR/" 2>/dev/null || true
cp deploy/kubernetes/web/gva-web-deploymemt.yaml "$BACKUP_DIR/" 2>/dev/null || true
echo "✅ 备份保存到: $BACKUP_DIR"

echo ""
echo "🔧 更新后端 Deployment..."

# 更新后端配置
if [ -f "deploy/kubernetes/server/gva-server-deployment.yaml" ]; then
    # 更新镜像地址
    sed -i.bak "s|image: .*registry.*aliyuncs.com.*server.*|image: ${TCR_REGISTRY}/gva/server:latest|g" deploy/kubernetes/server/gva-server-deployment.yaml
    sed -i.bak "s|image: .*tencentcloudcr.com.*server.*|image: ${TCR_REGISTRY}/gva/server:latest|g" deploy/kubernetes/server/gva-server-deployment.yaml
    
    # 确保有 imagePullSecrets
    if ! grep -q "imagePullSecrets" deploy/kubernetes/server/gva-server-deployment.yaml; then
        # 在 spec.template.spec 下添加 imagePullSecrets
        sed -i.bak '/spec:/a\
      imagePullSecrets:\
        - name: tcr-secret' deploy/kubernetes/server/gva-server-deployment.yaml
    fi
    
    rm -f deploy/kubernetes/server/gva-server-deployment.yaml.bak
    echo "✅ 后端配置已更新"
else
    echo -e "${YELLOW}⚠️  后端配置文件不存在${NC}"
fi

echo ""
echo "🔧 更新前端 Deployment..."

# 更新前端配置
if [ -f "deploy/kubernetes/web/gva-web-deploymemt.yaml" ]; then
    # 更新镜像地址
    sed -i.bak "s|image: .*registry.*aliyuncs.com.*web.*|image: ${TCR_REGISTRY}/gva/web:latest|g" deploy/kubernetes/web/gva-web-deploymemt.yaml
    sed -i.bak "s|image: .*tencentcloudcr.com.*web.*|image: ${TCR_REGISTRY}/gva/web:latest|g" deploy/kubernetes/web/gva-web-deploymemt.yaml
    
    # 确保有 imagePullSecrets
    if ! grep -q "imagePullSecrets" deploy/kubernetes/web/gva-web-deploymemt.yaml; then
        sed -i.bak '/spec:/a\
      imagePullSecrets:\
        - name: tcr-secret' deploy/kubernetes/web/gva-web-deploymemt.yaml
    fi
    
    rm -f deploy/kubernetes/web/gva-web-deploymemt.yaml.bak
    echo "✅ 前端配置已更新"
else
    echo -e "${YELLOW}⚠️  前端配置文件不存在${NC}"
fi

echo ""
echo -e "${GREEN}✅ Kubernetes 配置文件更新完成${NC}"

# ============================================
# 3. 生成 GitHub Secrets 配置
# ============================================
echo ""
echo -e "${BLUE}📝 步骤 3/5: 生成 GitHub Secrets 配置${NC}"
echo ""

SECRETS_FILE="github-secrets-config.txt"

cat > "$SECRETS_FILE" << EOF
========================================
GitHub Secrets 配置清单
========================================

请访问: https://github.com/你的用户名/gin-vue-admin/settings/secrets/actions
点击 "New repository secret" 添加以下 Secrets:

----------------------------------------
1. DOCKER_REGISTRY
----------------------------------------
Name: DOCKER_REGISTRY
Secret: ${TCR_REGISTRY}

----------------------------------------
2. DOCKER_USERNAME
----------------------------------------
Name: DOCKER_USERNAME
Secret: ${TCR_USERNAME}

----------------------------------------
3. DOCKER_PASSWORD
----------------------------------------
Name: DOCKER_PASSWORD
Secret: ${TCR_PASSWORD}

----------------------------------------
4. KUBE_CONFIG_DEV
----------------------------------------
Name: KUBE_CONFIG_DEV
Secret: <使用以下命令生成>

生成命令（macOS）:
cat ~/.kube/config-tencent | base64 | pbcopy

生成命令（Linux）:
cat ~/.kube/config-tencent | base64 -w 0

然后粘贴生成的 base64 字符串

----------------------------------------
5. KUBE_CONFIG_PROD
----------------------------------------
Name: KUBE_CONFIG_PROD
Secret: <与 KUBE_CONFIG_DEV 相同，或使用生产环境的 kubeconfig>

----------------------------------------
6. WECOM_WEBHOOK (可选)
----------------------------------------
Name: WECOM_WEBHOOK
Secret: https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx

----------------------------------------
7. DINGTALK_WEBHOOK (可选)
----------------------------------------
Name: DINGTALK_WEBHOOK
Secret: https://oapi.dingtalk.com/robot/send?access_token=xxx

========================================
配置完成后，推送代码即可触发自动部署！
========================================
EOF

echo "✅ GitHub Secrets 配置已保存到: $SECRETS_FILE"
echo ""
echo -e "${YELLOW}请按照文件中的说明配置 GitHub Secrets${NC}"

# ============================================
# 4. 生成 Kubernetes 密钥创建命令
# ============================================
echo ""
echo -e "${BLUE}📝 步骤 4/5: 生成 Kubernetes 密钥创建命令${NC}"
echo ""

K8S_SETUP_FILE="setup-k8s-secrets.sh"

cat > "$K8S_SETUP_FILE" << EOF
#!/bin/bash

# ============================================
# Kubernetes 密钥配置脚本
# 自动生成于: $(date)
# ============================================

set -e

echo "创建 Kubernetes 命名空间和密钥..."

# 设置 kubeconfig（如果需要）
# export KUBECONFIG=~/.kube/config-tencent

# 创建命名空间
echo "创建命名空间..."
kubectl create namespace gva-dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace gva-prod --dry-run=client -o yaml | kubectl apply -f -

# 创建开发环境镜像拉取密钥
echo "创建开发环境密钥..."
kubectl create secret docker-registry tcr-secret \\
  --docker-server=${TCR_REGISTRY} \\
  --docker-username=${TCR_USERNAME} \\
  --docker-password='${TCR_PASSWORD}' \\
  --namespace=gva-dev \\
  --dry-run=client -o yaml | kubectl apply -f -

# 创建生产环境镜像拉取密钥
echo "创建生产环境密钥..."
kubectl create secret docker-registry tcr-secret \\
  --docker-server=${TCR_REGISTRY} \\
  --docker-username=${TCR_USERNAME} \\
  --docker-password='${TCR_PASSWORD}' \\
  --namespace=gva-prod \\
  --dry-run=client -o yaml | kubectl apply -f -

# 验证
echo ""
echo "验证密钥创建成功:"
kubectl get secret tcr-secret -n gva-dev
kubectl get secret tcr-secret -n gva-prod

echo ""
echo "✅ Kubernetes 密钥配置完成！"
EOF

chmod +x "$K8S_SETUP_FILE"

echo "✅ Kubernetes 配置脚本已生成: $K8S_SETUP_FILE"
echo ""
echo -e "${YELLOW}提示: 运行以下命令创建 Kubernetes 密钥:${NC}"
echo -e "${GREEN}./$K8S_SETUP_FILE${NC}"

# ============================================
# 5. 生成本地测试脚本
# ============================================
echo ""
echo -e "${BLUE}📝 步骤 5/5: 生成本地测试脚本${NC}"
echo ""

TEST_LOGIN_FILE="test-tcr-login.sh"

cat > "$TEST_LOGIN_FILE" << EOF
#!/bin/bash

# ============================================
# 测试腾讯云 TCR 登录
# ============================================

echo "测试腾讯云容器镜像服务登录..."

docker login ${TCR_REGISTRY} \\
  -u ${TCR_USERNAME} \\
  -p '${TCR_PASSWORD}'

if [ \$? -eq 0 ]; then
    echo "✅ TCR 登录成功！"
else
    echo "❌ TCR 登录失败，请检查凭证"
    exit 1
fi
EOF

chmod +x "$TEST_LOGIN_FILE"

echo "✅ 测试脚本已生成: $TEST_LOGIN_FILE"

# ============================================
# 完成
# ============================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 配置完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${PURPLE}📋 已生成的文件:${NC}"
echo "  1. $SECRETS_FILE - GitHub Secrets 配置清单"
echo "  2. $K8S_SETUP_FILE - Kubernetes 密钥配置脚本"
echo "  3. $TEST_LOGIN_FILE - TCR 登录测试脚本"
echo "  4. $BACKUP_DIR/ - 配置文件备份"
echo ""
echo -e "${PURPLE}📝 后续步骤:${NC}"
echo ""
echo -e "${YELLOW}1. 配置 GitHub Secrets${NC}"
echo "   查看: cat $SECRETS_FILE"
echo "   访问: https://github.com/你的用户名/gin-vue-admin/settings/secrets/actions"
echo ""
echo -e "${YELLOW}2. 配置 Kubernetes 密钥${NC}"
echo "   运行: ./$K8S_SETUP_FILE"
echo ""
echo -e "${YELLOW}3. 测试 TCR 登录（可选）${NC}"
echo "   运行: ./$TEST_LOGIN_FILE"
echo ""
echo -e "${YELLOW}4. 提交并推送代码${NC}"
echo "   git add ."
echo "   git commit -m 'chore: 配置腾讯云CI/CD'"
echo "   git push origin develop"
echo ""
echo -e "${YELLOW}5. 查看 GitHub Actions${NC}"
echo "   访问: https://github.com/你的用户名/gin-vue-admin/actions"
echo ""
echo -e "${GREEN}🎉 准备工作完成，开始你的自动化部署之旅吧！${NC}"
echo ""

# 显示更新的配置文件
echo -e "${BLUE}📄 更新的镜像地址预览:${NC}"
echo ""
if [ -f "deploy/kubernetes/server/gva-server-deployment.yaml" ]; then
    echo "后端镜像:"
    grep "image:" deploy/kubernetes/server/gva-server-deployment.yaml | head -1
fi
if [ -f "deploy/kubernetes/web/gva-web-deploymemt.yaml" ]; then
    echo "前端镜像:"
    grep "image:" deploy/kubernetes/web/gva-web-deploymemt.yaml | head -1
fi
echo ""

