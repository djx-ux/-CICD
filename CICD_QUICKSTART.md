# 🚀 CI/CD 快速开始指南

## 📋 前置条件

### 1. 必备工具

- ✅ Git (版本控制)
- ✅ Docker (容器化)
- ✅ kubectl (Kubernetes 客户端)
- ✅ GitHub/GitLab 账号

### 2. 环境准备

```bash
# 检查工具版本
git --version
docker --version
kubectl version --client
```

## 🎯 5分钟快速配置

### 第1步：配置 GitHub Secrets

进入 GitHub 仓库 → Settings → Secrets and variables → Actions

添加以下 Secrets:

```yaml
# Docker 镜像仓库
DOCKER_USERNAME: your-username
DOCKER_PASSWORD: your-password

# Kubernetes (开发环境)
KUBE_CONFIG_DEV: |
  base64编码的kubeconfig内容

# Kubernetes (生产环境)  
KUBE_CONFIG_PROD: |
  base64编码的kubeconfig内容

# 钉钉通知 (可选)
DINGTALK_WEBHOOK: https://oapi.dingtalk.com/robot/send?access_token=xxx
```

#### 如何获取 base64 编码的 kubeconfig:

```bash
# 方法1: 直接编码
cat ~/.kube/config | base64

# 方法2: 在 macOS 上复制到剪贴板
cat ~/.kube/config | base64 | pbcopy

# 方法3: 在 Linux 上
cat ~/.kube/config | base64 | xclip -selection clipboard
```

### 第2步：创建 Kubernetes 资源

```bash
# 应用 Kubernetes 配置
kubectl apply -f deploy/kubernetes/server/
kubectl apply -f deploy/kubernetes/web/
```

### 第3步：推送代码触发 CI/CD

```bash
# 推送到 develop 分支 → 自动部署到开发环境
git checkout develop
git add .
git commit -m "feat: 启用 CI/CD"
git push origin develop

# 推送到 main 分支 → 部署到生产环境（需审批）
git checkout main
git merge develop
git push origin main
```

## 📊 CI/CD 流程说明

### 自动化流程

```
代码推送
  ↓
✅ CI - 代码检查和测试 (2-3分钟)
  ├─ ESLint 检查
  ├─ Go Lint 检查
  ├─ 单元测试
  ├─ 安全扫描
  └─ 构建镜像
  ↓
✅ CD - 自动部署 (5-10分钟)
  ├─ develop → 开发环境 (自动)
  ├─ release/* → 测试环境 (自动)
  └─ main → 生产环境 (需审批)
  ↓
✅ 部署完成
  ├─ 健康检查
  ├─ 监控验证
  └─ 通知发送
```

### 触发条件

| 分支 | CI | CD | 环境 | 审批 |
|------|----|----|------|------|
| `feature/*` | ✅ | ❌ | - | - |
| `develop` | ✅ | ✅ | Dev | 否 |
| `release/*` | ✅ | ✅ | Staging | 否 |
| `main` | ✅ | ✅ | Production | 是 |
| `hotfix/*` | ✅ | ❌ | - | - |

## 🔧 本地使用脚本

### 1. 本地开发环境

```bash
# 启动本地开发环境
chmod +x scripts/*.sh
./scripts/local-dev.sh
```

### 2. 构建 Docker 镜像

```bash
# 构建所有镜像
export TAG=v1.0.0
./scripts/build.sh

# 只构建后端
export BUILD_WEB=false
./scripts/build.sh

# 只构建前端
export BUILD_SERVER=false
./scripts/build.sh
```

### 3. 推送镜像

```bash
# 设置镜像仓库凭证
export DOCKER_USERNAME=your-username
export DOCKER_PASSWORD=your-password

# 推送镜像
./scripts/push.sh
```

### 4. 部署到 Kubernetes

```bash
# 部署到开发环境
./scripts/deploy.sh dev

# 部署到测试环境
./scripts/deploy.sh staging

# 部署到生产环境
./scripts/deploy.sh prod v1.0.0
```

### 5. 回滚

```bash
# 回滚到上一版本
./scripts/rollback.sh prod

# 回滚到指定版本
./scripts/rollback.sh prod 5
```

## 📁 文件结构

```
gin-vue-admin/
├── .github/
│   └── workflows/
│       ├── ci.yml              # CI 持续集成
│       ├── cd-dev.yml          # CD 开发环境部署
│       ├── cd-prod.yml         # CD 生产环境部署
│       └── rollback.yml        # 回滚工作流
├── .gitlab-ci.yml              # GitLab CI 配置
├── scripts/
│   ├── build.sh                # 构建脚本
│   ├── push.sh                 # 推送脚本
│   ├── deploy.sh               # 部署脚本
│   ├── rollback.sh             # 回滚脚本
│   └── local-dev.sh            # 本地开发启动
├── deploy/
│   ├── docker-compose/
│   │   └── docker-compose.yaml
│   └── kubernetes/
│       ├── server/             # 后端 K8s 配置
│       └── web/                # 前端 K8s 配置
├── .env.example                # 环境变量示例
└── CICD_DESIGN.md              # CI/CD 设计文档
```

## 🎬 完整工作流示例

### 场景1：开发新功能

```bash
# 1. 创建功能分支
git checkout -b feature/add-broker-list develop

# 2. 开发功能
# ... 编写代码 ...

# 3. 本地测试
./scripts/local-dev.sh

# 4. 提交代码
git add .
git commit -m "feat: 添加 Broker 列表功能"
git push origin feature/add-broker-list

# 5. 创建 Pull Request
# → CI 自动运行检查和测试

# 6. 代码审查通过后合并到 develop
# → 自动部署到开发环境
```

### 场景2：发布到生产

```bash
# 1. 创建 release 分支
git checkout -b release/v1.0.0 develop

# 2. 推送触发测试环境部署
git push origin release/v1.0.0
# → 自动部署到测试环境

# 3. 测试通过后合并到 main
git checkout main
git merge --no-ff release/v1.0.0
git tag v1.0.0
git push origin main --tags

# 4. 在 GitHub Actions 中手动审批
# → 审批通过后自动部署到生产环境
```

### 场景3：紧急修复

```bash
# 1. 从 main 创建 hotfix 分支
git checkout -b hotfix/critical-bug main

# 2. 修复 Bug
# ... 修改代码 ...

# 3. 测试并提交
git commit -am "fix: 修复关键 Bug"

# 4. 合并回 main 和 develop
git checkout main
git merge --no-ff hotfix/critical-bug
git tag v1.0.1
git push origin main --tags

git checkout develop
git merge --no-ff hotfix/critical-bug
git push origin develop

# → 自动触发生产环境部署
```

## ⚙️ GitHub Actions 使用

### 查看工作流运行状态

```
GitHub 仓库 → Actions 标签
```

### 手动触发部署

```
1. 进入 Actions 标签
2. 选择 "CD - 生产环境部署"
3. 点击 "Run workflow"
4. 选择分支和版本
5. 点击 "Run workflow" 确认
```

### 手动触发回滚

```
1. 进入 Actions 标签
2. 选择 "生产环境回滚"
3. 点击 "Run workflow"
4. 选择环境和版本
5. 点击 "Run workflow" 确认
```

## 📊 监控和日志

### 查看部署状态

```bash
# 查看所有命名空间的 Pod
kubectl get pods --all-namespaces

# 查看特定环境的 Pod
kubectl get pods -n gva-dev
kubectl get pods -n gva-prod

# 查看服务状态
kubectl get svc -n gva-prod
```

### 查看日志

```bash
# 查看后端日志
kubectl logs -f deployment/gva-server -n gva-prod

# 查看前端日志
kubectl logs -f deployment/gva-web -n gva-prod

# 查看最近的事件
kubectl get events -n gva-prod --sort-by='.lastTimestamp'
```

### 查看部署历史

```bash
# 查看部署历史
kubectl rollout history deployment/gva-server -n gva-prod

# 查看特定版本的详情
kubectl rollout history deployment/gva-server --revision=5 -n gva-prod
```

## 🛡️ 安全最佳实践

### 1. 密钥管理

```
❌ 不要: 将密钥提交到代码仓库
✅ 应该: 使用 GitHub Secrets 或 K8s Secrets
✅ 应该: 使用专用的密钥管理服务 (Vault, AWS Secrets Manager)
```

### 2. 镜像安全

```
✅ 定期扫描镜像漏洞 (Trivy)
✅ 使用最小化的基础镜像 (alpine)
✅ 不在镜像中包含敏感信息
✅ 使用多阶段构建
```

### 3. 访问控制

```
✅ 使用 RBAC 控制 K8s 访问权限
✅ 限制生产环境的部署权限
✅ 启用审计日志
```

## 🔍 故障排查

### CI 构建失败

```bash
# 1. 查看 Actions 日志
GitHub → Actions → 点击失败的工作流

# 2. 本地复现问题
./scripts/build.sh

# 3. 检查依赖
cd web && pnpm install
cd server && go mod tidy
```

### 部署失败

```bash
# 1. 查看 Pod 状态
kubectl describe pod <pod-name> -n gva-prod

# 2. 查看日志
kubectl logs <pod-name> -n gva-prod

# 3. 检查镜像
docker pull registry.cn-hangzhou.aliyuncs.com/gva/server:latest
```

### 回滚不成功

```bash
# 1. 查看回滚历史
kubectl rollout history deployment/gva-server -n gva-prod

# 2. 手动回滚
kubectl rollout undo deployment/gva-server -n gva-prod

# 3. 检查配置
kubectl get deployment gva-server -n gva-prod -o yaml
```

## 📞 获取帮助

### 常见问题

参考文档:
- 📖 `CICD_DESIGN.md` - 完整设计方案
- 📖 `.github/workflows/ci.yml` - CI 配置详解
- 📖 `scripts/` - 各个脚本的使用说明

### 需要支持

1. 查看工作流日志
2. 检查 Kubernetes 事件
3. 查看应用日志
4. 联系运维团队

## 🎉 成功标志

CI/CD 正常运行的标志:

- ✅ 每次推送代码都会触发 CI
- ✅ CI 检查都能通过
- ✅ develop 分支自动部署到开发环境
- ✅ main 分支可以部署到生产环境
- ✅ 部署失败会自动回滚
- ✅ 收到钉钉/邮件通知

## 📈 进阶功能

### 1. 金丝雀发布

编辑 `.github/workflows/cd-prod.yml`，启用金丝雀发布逻辑

### 2. A/B 测试

使用 Kubernetes Ingress + 流量分割

### 3. 自动化测试

添加端到端测试到 CI 流程

### 4. 性能监控

集成 Prometheus + Grafana

---

**准备时间**: 30分钟  
**学习成本**: 1-2天  
**收益**: 巨大！自动化部署省时省力  
**推荐度**: ⭐⭐⭐⭐⭐

现在就开始配置你的第一个 CI/CD 流水线吧！🚀



