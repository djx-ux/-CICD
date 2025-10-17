# 🚀 CI/CD 流水线设计方案

## 📋 项目技术栈

- **前端**: Vue 3 + Vite + Element Plus + pnpm
- **后端**: Go + Gin Framework
- **数据库**: MySQL 8.0 + Redis 6.0
- **容器化**: Docker + Docker Compose
- **编排**: Kubernetes (K8s)
- **镜像仓库**: 阿里云容器镜像服务 (registry.cn-hangzhou.aliyuncs.com)

## 🎯 CI/CD 流程设计

### 完整流程图

```
开发者提交代码
    ↓
[Git Push]
    ↓
┌─────────────────────────────────────────────────────┐
│             CI 阶段 (持续集成)                       │
├─────────────────────────────────────────────────────┤
│ 1. 代码检查 (Lint)                                  │
│    ├─ 前端: ESLint                                  │
│    └─ 后端: golangci-lint                           │
│                                                      │
│ 2. 单元测试 (Test)                                  │
│    ├─ 前端: Vitest                                  │
│    └─ 后端: go test                                 │
│                                                      │
│ 3. 安全扫描 (Security)                              │
│    ├─ 依赖扫描: npm audit / go mod verify          │
│    └─ 代码扫描: Trivy / Snyk                       │
│                                                      │
│ 4. 构建镜像 (Build)                                 │
│    ├─ 前端镜像: gva/web:${TAG}                     │
│    └─ 后端镜像: gva/server:${TAG}                  │
│                                                      │
│ 5. 推送镜像 (Push)                                  │
│    └─ 推送到阿里云镜像仓库                          │
└─────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────┐
│             CD 阶段 (持续部署)                       │
├─────────────────────────────────────────────────────┤
│ 6. 部署到测试环境 (Dev/Staging)                      │
│    ├─ 更新 K8s Deployment                           │
│    ├─ 健康检查                                       │
│    └─ 自动化测试                                     │
│                                                      │
│ 7. 部署到生产环境 (Production) [需人工审批]         │
│    ├─ 灰度发布 (Canary)                             │
│    ├─ 滚动更新 (Rolling Update)                     │
│    ├─ 健康检查                                       │
│    └─ 监控告警                                       │
│                                                      │
│ 8. 回滚机制 (Rollback)                              │
│    └─ 出现问题自动回滚到上一版本                     │
└─────────────────────────────────────────────────────┘
    ↓
部署完成
```

## 🌿 分支策略

### Git Flow 模型

```
main (master)
  ├─ 生产环境代码
  └─ 只接受来自 release 分支的合并

develop
  ├─ 开发环境代码
  └─ 日常开发的主分支

feature/*
  ├─ 功能开发分支
  └─ 从 develop 分出，完成后合并回 develop

release/*
  ├─ 预发布分支
  └─ 从 develop 分出，测试通过后合并到 main 和 develop

hotfix/*
  ├─ 紧急修复分支
  └─ 从 main 分出，修复后合并回 main 和 develop
```

### 分支与环境对应

| 分支 | 触发条件 | 部署环境 | 自动部署 |
|------|---------|---------|---------|
| `feature/*` | Push | 不部署 | - |
| `develop` | Push/Merge | 开发环境 (Dev) | ✅ 自动 |
| `release/*` | Push/Merge | 测试环境 (Staging) | ✅ 自动 |
| `main` | Merge | 生产环境 (Production) | ⚠️ 需审批 |

## 🔄 CI 流程详解

### 阶段1：代码质量检查 (2-3分钟)

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      # 前端检查
      - name: ESLint 检查
        run: cd web && pnpm lint
      
      # 后端检查
      - name: Go Lint 检查
        run: cd server && golangci-lint run
      
      # 代码格式检查
      - name: 代码格式化检查
        run: |
          cd server && go fmt ./...
          cd web && pnpm format:check
```

### 阶段2：自动化测试 (3-5分钟)

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
      redis:
        image: redis:6.0
    steps:
      # 后端单元测试
      - name: Go 单元测试
        run: cd server && go test -v -cover ./...
      
      # 前端单元测试
      - name: Vue 组件测试
        run: cd web && pnpm test:unit
      
      # 生成测试报告
      - name: 上传测试报告
        uses: codecov/codecov-action@v3
```

### 阶段3：构建镜像 (5-10分钟)

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      # 构建前端镜像
      - name: Build Web Image
        run: |
          cd web
          docker build -t $REPOSITORY/web:$TAG .
      
      # 构建后端镜像
      - name: Build Server Image
        run: |
          cd server
          docker build -t $REPOSITORY/server:$TAG .
      
      # 推送到镜像仓库
      - name: Push Images
        run: |
          docker push $REPOSITORY/web:$TAG
          docker push $REPOSITORY/server:$TAG
```

### 阶段4：部署 (2-3分钟)

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      # 更新 K8s Deployment
      - name: Deploy to Kubernetes
        run: |
          kubectl set image deployment/gva-server \
            gin-vue-admin-container=$REPOSITORY/server:$TAG
          kubectl set image deployment/gva-web \
            gva-web-container=$REPOSITORY/web:$TAG
      
      # 等待部署完成
      - name: Wait for Rollout
        run: |
          kubectl rollout status deployment/gva-server
          kubectl rollout status deployment/gva-web
      
      # 健康检查
      - name: Health Check
        run: |
          curl -f http://your-domain/api/health || exit 1
```

## 🎨 环境配置

### 开发环境 (Dev)

- **分支**: `develop`
- **命名空间**: `gva-dev`
- **域名**: `dev.yourdomain.com`
- **数据库**: 开发数据库
- **自动部署**: ✅ 是
- **回滚**: 自动

### 测试环境 (Staging)

- **分支**: `release/*`
- **命名空间**: `gva-staging`
- **域名**: `staging.yourdomain.com`
- **数据库**: 测试数据库
- **自动部署**: ✅ 是
- **回滚**: 自动

### 生产环境 (Production)

- **分支**: `main`
- **命名空间**: `gva-prod`
- **域名**: `www.yourdomain.com`
- **数据库**: 生产数据库
- **自动部署**: ⚠️ 需人工审批
- **回滚**: 手动/自动

## 🔐 密钥管理

### 需要配置的密钥 (GitHub Secrets)

```yaml
# Docker Registry
DOCKER_REGISTRY: registry.cn-hangzhou.aliyuncs.com
DOCKER_USERNAME: your-username
DOCKER_PASSWORD: your-password

# Kubernetes
KUBE_CONFIG: base64-encoded-kubeconfig
K8S_NAMESPACE_DEV: gva-dev
K8S_NAMESPACE_STAGING: gva-staging
K8S_NAMESPACE_PROD: gva-prod

# Database
DB_HOST_DEV: mysql-dev.yourdomain.com
DB_PASSWORD_DEV: dev-password
DB_HOST_PROD: mysql-prod.yourdomain.com
DB_PASSWORD_PROD: prod-password

# Redis
REDIS_HOST_DEV: redis-dev.yourdomain.com
REDIS_PASSWORD_DEV: dev-redis-password
```

## 📦 镜像标签策略

```
格式: {branch}-{commit-sha}-{timestamp}

示例:
- develop-abc1234-20251016150000
- release-1.0.0-def5678-20251016160000
- main-1.0.0-20251016170000

特殊标签:
- latest: 指向最新的 main 分支构建
- stable: 指向最新的稳定版本
```

## 🔄 部署策略

### 1. 蓝绿部署 (Blue-Green)

```
适用场景: 生产环境重大更新
优点: 可以快速回滚
缺点: 需要双倍资源
```

### 2. 滚动更新 (Rolling Update)

```
适用场景: 日常更新
优点: 节省资源，平滑升级
缺点: 回滚较慢
```

### 3. 金丝雀发布 (Canary)

```
适用场景: 风险较高的功能
流程: 
  1. 部署 10% 流量到新版本
  2. 监控 30 分钟
  3. 逐步增加到 50%
  4. 全量发布
```

## 📊 监控与告警

### 监控指标

```yaml
应用监控:
  - HTTP 请求成功率 > 99%
  - API 响应时间 < 500ms
  - 错误率 < 0.1%

资源监控:
  - CPU 使用率 < 80%
  - 内存使用率 < 85%
  - 磁盘使用率 < 90%

业务监控:
  - 用户登录成功率
  - 数据库连接数
  - Redis 命中率
```

### 告警规则

```yaml
级别P0 (紧急):
  - 服务不可用
  - 数据库连接失败
  - 错误率 > 5%
  → 立即通知，自动回滚

级别P1 (重要):
  - API响应时间 > 2s
  - CPU > 90%
  - 内存 > 95%
  → 5分钟内通知

级别P2 (一般):
  - 磁盘使用 > 80%
  - 慢查询增多
  → 30分钟内通知
```

## 🛡️ 质量门禁

### 代码必须通过

- ✅ 所有 Lint 检查通过
- ✅ 单元测试覆盖率 > 60%
- ✅ 没有高危安全漏洞
- ✅ 代码审查 (Code Review) 通过
- ✅ 构建成功

### 发布到生产必须满足

- ✅ 在 Staging 环境运行 > 24小时
- ✅ 性能测试通过
- ✅ 集成测试通过
- ✅ 技术负责人审批
- ✅ 有回滚预案

## 📝 建议的工具链

### CI/CD 平台选择

| 平台 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| **GitHub Actions** | 免费、配置简单、与GitHub深度集成 | 公有云，中国访问慢 | ⭐⭐⭐⭐⭐ |
| **GitLab CI** | 功能强大、可私有部署 | 配置复杂 | ⭐⭐⭐⭐ |
| **Jenkins** | 功能最全、插件丰富 | 维护成本高 | ⭐⭐⭐ |
| **Drone** | 轻量级、Docker原生 | 社区较小 | ⭐⭐⭐ |

### 推荐工具

```yaml
代码质量:
  - ESLint (前端代码检查)
  - golangci-lint (后端代码检查)
  - SonarQube (代码质量分析)

测试:
  - Vitest (前端单元测试)
  - go test (后端单元测试)
  - Postman/Newman (API测试)

镜像:
  - Docker (容器化)
  - Trivy (镜像安全扫描)
  - Dive (镜像分析优化)

部署:
  - Kubernetes (容器编排)
  - Helm (K8s包管理)
  - ArgoCD (GitOps部署)

监控:
  - Prometheus (指标收集)
  - Grafana (可视化)
  - Loki (日志)
  - Jaeger (链路追踪)

通知:
  - 钉钉/企业微信/Slack
  - 邮件通知
```

## 📈 性能优化

### 构建优化

```yaml
前端:
  - 使用 pnpm 代替 npm (更快的依赖安装)
  - 启用 Vite 构建缓存
  - 使用 CDN 加速静态资源
  - 代码分割 (Code Splitting)

后端:
  - 使用 Go 编译缓存
  - 多阶段构建减小镜像体积
  - 使用国内 Go Proxy

Docker:
  - 使用 BuildKit 加速构建
  - 使用镜像缓存
  - 最小化镜像层数
```

### 部署优化

```yaml
Kubernetes:
  - HPA (水平自动扩缩容)
  - 资源限制和请求
  - 就绪探针和存活探针
  - PodDisruptionBudget

数据库:
  - 主从复制
  - 读写分离
  - 连接池优化
```

## 🚦 发布流程

### 1. 功能开发

```bash
# 创建功能分支
git checkout -b feature/new-feature develop

# 开发完成后
git push origin feature/new-feature

# 创建 Pull Request 到 develop
# 等待 CI 通过和代码审查
# 合并到 develop
```

### 2. 测试发布

```bash
# 从 develop 创建 release 分支
git checkout -b release/v1.0.0 develop

# 推送触发 CI/CD
git push origin release/v1.0.0

# 自动部署到 Staging 环境
# 执行测试和验证
```

### 3. 生产发布

```bash
# 测试通过后，合并到 main
git checkout main
git merge --no-ff release/v1.0.0
git tag v1.0.0
git push origin main --tags

# 需要人工审批
# 审批通过后自动部署到生产环境
```

### 4. 紧急修复

```bash
# 从 main 创建 hotfix 分支
git checkout -b hotfix/urgent-fix main

# 修复完成后
git checkout main
git merge --no-ff hotfix/urgent-fix
git tag v1.0.1

git checkout develop
git merge --no-ff hotfix/urgent-fix

git push origin main develop --tags
```

## 📋 CI/CD 配置清单

我将为你创建以下配置文件：

- [ ] `.github/workflows/ci.yml` - 持续集成配置
- [ ] `.github/workflows/cd-dev.yml` - 开发环境部署
- [ ] `.github/workflows/cd-staging.yml` - 测试环境部署
- [ ] `.github/workflows/cd-prod.yml` - 生产环境部署
- [ ] `.gitlab-ci.yml` - GitLab CI 配置（备选）
- [ ] `scripts/build.sh` - 构建脚本
- [ ] `scripts/deploy.sh` - 部署脚本
- [ ] `scripts/rollback.sh` - 回滚脚本
- [ ] `deploy/kubernetes/*/kustomization.yaml` - Kustomize 配置

## 🎯 预期收益

### 开发效率提升

- ⚡ 自动化测试：减少手动测试时间 70%
- ⚡ 自动化部署：部署时间从 1小时 → 5分钟
- ⚡ 快速反馈：问题发现时间从 天级 → 分钟级

### 代码质量提升

- 📈 代码覆盖率：从 30% → 60%+
- 🐛 Bug 发现：提前到开发阶段
- 🔒 安全性：自动扫描依赖漏洞

### 稳定性提升

- 🛡️ 故障率：降低 80%
- ⏱️ 恢复时间：从 小时级 → 分钟级
- 🔄 发布频率：从 周级 → 日级

## 💰 成本估算

### GitHub Actions (推荐)

```
免费额度:
- 公开仓库: 无限制
- 私有仓库: 2000分钟/月

预估使用:
- 每次 CI: 10分钟
- 每天推送: 20次
- 月使用: 10 × 20 × 30 = 6000分钟

费用: ~$50/月 (超出免费额度部分)
```

### 自建 Jenkins (备选)

```
服务器成本:
- 2核4G: ¥300/月
- 4核8G: ¥600/月 (推荐)

人力成本:
- 运维 0.5人/月: ¥10000/月

总成本: ~¥10600/月
```

## 🎓 最佳实践

### 1. 构建缓存

```dockerfile
# 使用多阶段构建
FROM golang:alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download  # ← 缓存依赖
COPY . .
RUN go build -o server
```

### 2. 镜像优化

```dockerfile
# 使用更小的基础镜像
FROM alpine:latest  # 5MB
# 而不是 FROM ubuntu:latest  # 72MB

# 清理不必要的文件
RUN apk add --no-cache ca-certificates \
    && rm -rf /var/cache/apk/*
```

### 3. 配置管理

```yaml
# 使用 ConfigMap 和 Secret
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database-host: mysql-service
  
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
data:
  database-password: base64-encoded-password
```

## 🔗 下一步

我将为你创建：
1. ✅ GitHub Actions 完整配置
2. ✅ 构建和部署脚本
3. ✅ Kubernetes 完整配置
4. ✅ 环境变量管理方案
5. ✅ 监控和日志方案

---

**准备时间**: 2-3天  
**ROI**: 3-6个月回本  
**推荐度**: ⭐⭐⭐⭐⭐

准备好开始实施了吗？我将为你创建所有必要的配置文件！



