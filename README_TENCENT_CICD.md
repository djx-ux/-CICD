# 🚀 腾讯云 CI/CD 自动化部署方案

> 专为腾讯云优化的 gin-vue-admin CI/CD 完整解决方案

[![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-blue)](https://github.com/features/actions)
[![Tencent Cloud](https://img.shields.io/badge/Tencent-Cloud-blue)](https://cloud.tencent.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.26+-blue)](https://kubernetes.io/)

---

## 📖 文档导航

### 🎯 新手入门

- **[10分钟快速开始](./TENCENT_QUICKSTART.md)** ⭐ 推荐从这里开始
  - 最快的上手方式
  - 分步骤详细指导
  - 包含所有必要命令

### 📚 详细文档

- **[完整部署指南](./TENCENT_CLOUD_DEPLOY.md)**
  - 腾讯云服务配置详解
  - Kubernetes 集群管理
  - 常见问题排查
  - 监控和维护

### 🛠️ 工具和脚本

- **快速配置脚本**: `./scripts/setup-tencent-cloud.sh`
  - 一键更新配置文件
  - 自动生成部署脚本
  - 生成 GitHub Secrets 配置清单

---

## ✨ 功能特性

### 🔄 完整的 CI/CD 流程

```
代码推送 → 自动检查 → 构建镜像 → 推送到TCR → 部署到TKE → 健康检查 → 通知
```

### ✅ 持续集成（CI）

- ✅ 前端代码检查（ESLint）
- ✅ 后端代码检查（golangci-lint）
- ✅ 自动化测试
- ✅ Docker 镜像构建
- ✅ 推送到腾讯云容器镜像服务（TCR）
- ✅ 构建缓存优化

### 🚀 持续部署（CD）

- ✅ 自动部署到开发环境（develop 分支）
- ✅ 审批部署到生产环境（main 分支）
- ✅ 金丝雀发布
- ✅ 滚动更新（零停机）
- ✅ 健康检查
- ✅ 自动回滚（失败时）

### 📱 通知系统

- ✅ 企业微信通知
- ✅ 钉钉通知
- ✅ 实时部署状态反馈

---

## 🎯 5步快速开始

### 步骤 1：运行配置脚本（2分钟）

```bash
cd /Users/ykmz/Desktop/哈雷彗星/gin-vue-admin

# 运行配置脚本
./scripts/setup-tencent-cloud.sh

# 按提示输入：
# - 腾讯云 TCR 镜像仓库地址
# - TCR 用户名
# - TCR 访问令牌
```

脚本会自动：
- ✅ 更新 Kubernetes 配置文件
- ✅ 生成 GitHub Secrets 配置清单
- ✅ 生成 Kubernetes 密钥配置脚本
- ✅ 生成测试脚本

### 步骤 2：配置 Kubernetes（1分钟）

```bash
# 运行生成的脚本
./setup-k8s-secrets.sh

# 或手动执行：
kubectl create namespace gva-dev
kubectl create namespace gva-prod

kubectl create secret docker-registry tcr-secret \
  --docker-server=xxx.tencentcloudcr.com \
  --docker-username=xxx \
  --docker-password=xxx \
  --namespace=gva-dev

kubectl create secret docker-registry tcr-secret \
  --docker-server=xxx.tencentcloudcr.com \
  --docker-username=xxx \
  --docker-password=xxx \
  --namespace=gva-prod
```

### 步骤 3：配置 GitHub Secrets（3分钟）

```bash
# 查看配置清单
cat github-secrets-config.txt

# 访问 GitHub 添加 Secrets
# https://github.com/你的用户名/gin-vue-admin/settings/secrets/actions

# 需要添加的 Secrets:
# - DOCKER_REGISTRY
# - DOCKER_USERNAME
# - DOCKER_PASSWORD
# - KUBE_CONFIG_DEV
# - KUBE_CONFIG_PROD
# - WECOM_WEBHOOK (可选)
```

### 步骤 4：推送代码（1分钟）

```bash
# 提交配置更新
git add .
git commit -m "chore: 配置腾讯云CI/CD"

# 推送到 GitHub
git push origin develop
```

### 步骤 5：观察部署（10分钟）

```bash
# 访问 GitHub Actions
# https://github.com/你的用户名/gin-vue-admin/actions

# 在本地查看部署状态
kubectl get pods -n gva-dev -w

# 查看服务地址
kubectl get svc -n gva-dev

# 访问应用
# http://<EXTERNAL-IP>
```

---

## 📊 架构图

```
┌─────────────┐
│   GitHub    │
│  (代码仓库)  │
└──────┬──────┘
       │
       │ Push/PR
       ↓
┌─────────────────────────────────┐
│     GitHub Actions              │
│  ┌──────────┐  ┌──────────┐    │
│  │ CI 检查  │  │ 构建镜像  │    │
│  └──────────┘  └──────────┘    │
└────────────┬────────────────────┘
             │
             │ Push Image
             ↓
┌─────────────────────────────────┐
│   腾讯云 TCR (容器镜像服务)      │
│   xxx.tencentcloudcr.com        │
└────────────┬────────────────────┘
             │
             │ Pull Image
             ↓
┌─────────────────────────────────┐
│   腾讯云 TKE (容器服务)          │
│  ┌──────────┐  ┌──────────┐    │
│  │  Pod     │  │  Pod     │    │
│  │ Server   │  │  Web     │    │
│  └──────────┘  └──────────┘    │
└────────────┬────────────────────┘
             │
             │ LoadBalancer
             ↓
     ┌──────────────┐
     │   用户访问    │
     └──────────────┘
```

---

## 🔄 工作流程

### 开发环境部署流程

```bash
开发者推送代码到 develop
         ↓
GitHub Actions CI 触发
         ↓
  ┌─────────────┐
  │ 代码检查     │
  ├─────────────┤
  │ - ESLint    │
  │ - Go Lint   │
  │ - Tests     │
  └──────┬──────┘
         ↓
  ┌─────────────┐
  │ 构建镜像     │
  ├─────────────┤
  │ - Server    │
  │ - Web       │
  └──────┬──────┘
         ↓
  推送到腾讯云 TCR
         ↓
GitHub Actions CD 触发
         ↓
  ┌─────────────┐
  │ 部署到 TKE  │
  ├─────────────┤
  │ - 更新镜像   │
  │ - 滚动更新   │
  │ - 健康检查   │
  └──────┬──────┘
         ↓
    部署成功
         ↓
  发送通知（企业微信/钉钉）
```

### 生产环境发布流程

```bash
合并到 main 分支
         ↓
GitHub Actions 触发
         ↓
   等待人工审批
         ↓
  ┌─────────────┐
  │ 金丝雀发布   │
  ├─────────────┤
  │ - 10% 流量  │
  │ - 健康检查   │
  └──────┬──────┘
         ↓
    检查通过？
    ├─ 是 ─→ 全量发布
    └─ 否 ─→ 自动回滚
```

---

## 📁 项目结构

```
gin-vue-admin/
├── .github/
│   └── workflows/
│       ├── tencent-ci.yml           # 腾讯云 CI 工作流
│       ├── tencent-cd-dev.yml       # 开发环境部署
│       └── tencent-cd-prod.yml      # 生产环境部署
│
├── deploy/
│   ├── docker/
│   │   ├── Dockerfile
│   │   └── entrypoint.sh
│   ├── docker-compose/
│   │   └── docker-compose.yaml
│   └── kubernetes/
│       ├── server/                  # 后端 K8s 配置
│       │   ├── gva-server-configmap.yaml
│       │   ├── gva-server-deployment.yaml  ← 需要更新镜像地址
│       │   └── gva-server-service.yaml
│       └── web/                     # 前端 K8s 配置
│           ├── gva-web-configmap.yaml
│           ├── gva-web-deploymemt.yaml     ← 需要更新镜像地址
│           ├── gva-web-service.yaml
│           └── gva-web-ingress.yaml
│
├── scripts/
│   ├── setup-tencent-cloud.sh      # ⭐ 腾讯云配置脚本
│   ├── build.sh                     # 构建脚本
│   ├── deploy.sh                    # 部署脚本
│   ├── rollback.sh                  # 回滚脚本
│   └── local-dev.sh                 # 本地开发
│
├── server/                          # Go 后端
│   ├── Dockerfile
│   └── ...
│
├── web/                             # Vue 前端
│   ├── Dockerfile
│   └── ...
│
├── TENCENT_QUICKSTART.md           # ⭐ 快速开始指南
├── TENCENT_CLOUD_DEPLOY.md         # ⭐ 完整部署文档
└── README_TENCENT_CICD.md          # 本文档
```

---

## 💡 使用场景

### 场景 1：日常开发

```bash
# 开发新功能
git checkout -b feature/new-feature develop

# 编写代码...

# 提交代码
git add .
git commit -m "feat: 添加新功能"
git push origin feature/new-feature

# 创建 PR → CI 自动检查
# 合并到 develop → 自动部署到开发环境
```

**时间**: 推送后 8-10 分钟自动部署完成

### 场景 2：发布生产

```bash
# 创建 release
git checkout -b release/v1.0.0 develop
git push origin release/v1.0.0

# 合并到 main
git checkout main
git merge --no-ff release/v1.0.0
git tag v1.0.0
git push origin main --tags

# GitHub Actions 触发 → 等待审批 → 自动发布
```

**时间**: 审批后 15-20 分钟完成金丝雀+全量发布

### 场景 3：紧急修复

```bash
# 从 main 创建 hotfix
git checkout -b hotfix/critical-bug main

# 修复 bug...
git commit -am "fix: 修复严重bug"

# 合并发布
git checkout main
git merge --no-ff hotfix/critical-bug
git tag v1.0.1
git push origin main --tags

# 自动部署（需审批）
```

**时间**: 审批后 15 分钟完成修复上线

---

## 🛠️ 常用命令

### 本地开发

```bash
# 启动本地环境
./scripts/local-dev.sh

# 或使用 Docker Compose
cd deploy/docker-compose
docker-compose up -d
```

### 查看部署状态

```bash
# 查看 Pod
kubectl get pods -n gva-dev

# 查看 Service
kubectl get svc -n gva-dev

# 查看日志
kubectl logs -f deployment/gva-server -n gva-dev

# 查看事件
kubectl get events -n gva-dev --sort-by='.lastTimestamp'
```

### 手动部署

```bash
# 部署到开发环境
./scripts/deploy.sh dev

# 部署到生产环境
./scripts/deploy.sh prod v1.0.0
```

### 回滚

```bash
# 回滚到上一版本
./scripts/rollback.sh prod

# 或使用 kubectl
kubectl rollout undo deployment/gva-server -n gva-prod
```

---

## 📈 监控和日志

### GitHub Actions 监控

```
访问: https://github.com/你的用户名/gin-vue-admin/actions

可以看到：
- 所有工作流运行历史
- 详细的执行日志
- 成功/失败状态
```

### Kubernetes 监控

```bash
# 查看资源使用
kubectl top nodes
kubectl top pods -n gva-dev

# 查看部署历史
kubectl rollout history deployment/gva-server -n gva-dev
```

### 腾讯云监控

```
访问: https://console.cloud.tencent.com/monitor/product/tke

可以看到：
- CPU/内存使用率
- 网络流量
- Pod 状态
- 告警信息
```

---

## 🔒 安全最佳实践

### 1. 密钥管理

✅ **推荐做法**:
- 使用 GitHub Secrets 存储敏感信息
- 使用 Kubernetes Secrets 存储配置
- 定期轮换访问令牌

❌ **避免做法**:
- 不要将密钥提交到代码仓库
- 不要在日志中打印敏感信息

### 2. 镜像安全

✅ **推荐做法**:
- 使用官方基础镜像
- 定期更新依赖
- 使用多阶段构建

### 3. 访问控制

✅ **推荐做法**:
- 使用 RBAC 控制 Kubernetes 权限
- 限制生产环境访问
- 启用审计日志

---

## 🐛 故障排查

### 问题：ImagePullBackOff

**原因**: 无法拉取镜像

**解决**:
```bash
# 检查密钥
kubectl get secret tcr-secret -n gva-dev

# 重新创建密钥
kubectl create secret docker-registry tcr-secret \
  --docker-server=xxx.tencentcloudcr.com \
  --docker-username=xxx \
  --docker-password=xxx \
  --namespace=gva-dev
```

### 问题：Pod CrashLoopBackOff

**原因**: 容器启动失败

**解决**:
```bash
# 查看日志
kubectl logs <pod-name> -n gva-dev

# 查看详情
kubectl describe pod <pod-name> -n gva-dev
```

### 问题：Service 无外部 IP

**原因**: LoadBalancer 未创建

**解决**:
```bash
# 检查 Service 类型
kubectl get svc -n gva-dev

# 如果需要，修改为 LoadBalancer
kubectl patch svc gva-web -n gva-dev -p '{"spec":{"type":"LoadBalancer"}}'
```

更多问题请查看：[完整故障排查指南](./TENCENT_CLOUD_DEPLOY.md#6-常见问题)

---

## 📚 学习资源

### 官方文档

- [腾讯云 TKE 文档](https://cloud.tencent.com/document/product/457)
- [腾讯云 TCR 文档](https://cloud.tencent.com/document/product/1141)
- [GitHub Actions 文档](https://docs.github.com/cn/actions)
- [Kubernetes 文档](https://kubernetes.io/zh/docs/)

### 相关教程

- [Kubernetes 入门教程](https://kubernetes.io/zh/docs/tutorials/)
- [Docker 最佳实践](https://docs.docker.com/develop/dev-best-practices/)
- [CI/CD 最佳实践](https://www.atlassian.com/continuous-delivery/principles/continuous-integration-vs-delivery-vs-deployment)

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

本项目采用 MIT 许可证

---

## 🎉 开始使用

选择你的方式开始：

### 方式 1：快速开始（推荐新手）

```bash
# 阅读快速开始指南
open TENCENT_QUICKSTART.md

# 或在终端查看
cat TENCENT_QUICKSTART.md
```

### 方式 2：使用配置脚本（推荐）

```bash
# 运行配置脚本
./scripts/setup-tencent-cloud.sh

# 按提示完成配置
```

### 方式 3：手动配置（高级用户）

```bash
# 阅读完整部署文档
open TENCENT_CLOUD_DEPLOY.md

# 按文档逐步配置
```

---

## 📞 获取帮助

- 📖 查看文档：[快速开始](./TENCENT_QUICKSTART.md) | [完整指南](./TENCENT_CLOUD_DEPLOY.md)
- 🐛 提交问题：[GitHub Issues](https://github.com/你的用户名/gin-vue-admin/issues)
- 💬 讨论：[GitHub Discussions](https://github.com/你的用户名/gin-vue-admin/discussions)

---

**准备好了吗？让我们开始自动化部署之旅！** 🚀

```bash
./scripts/setup-tencent-cloud.sh
```

