# 🚀 开始使用 CI/CD - 3步配置指南

## 📦 已为你准备好的完整方案

### ✅ 自动化工作流 (4个)
- `.github/workflows/ci.yml` - 代码检查、测试、构建
- `.github/workflows/cd-dev.yml` - 开发环境自动部署
- `.github/workflows/cd-prod.yml` - 生产环境审批部署
- `.github/workflows/rollback.yml` - 一键回滚

### ✅ 便捷脚本 (5个)
- `scripts/local-dev.sh` - 本地开发 ⭐ 最常用
- `scripts/build.sh` - 构建镜像
- `scripts/push.sh` - 推送镜像
- `scripts/deploy.sh` - 部署到K8s
- `scripts/rollback.sh` - 回滚部署

### ✅ 完整文档 (5个)
- `README_CICD.md` - 总览文档 ⭐ 从这里开始
- `CICD_DESIGN.md` - 详细设计方案
- `CICD_QUICKSTART.md` - 快速上手教程
- `CICD_CHEATSHEET.md` - 速查手册
- `CICD_IMPLEMENTATION.md` - 实施清单

## 🎯 3步启动 CI/CD

### 📍 第1步：配置 GitHub Secrets (5分钟)

#### 1.1 访问 GitHub Secrets 设置
```
https://github.com/你的用户名/你的仓库/settings/secrets/actions
```

#### 1.2 添加 Docker 凭证
```
名称: DOCKER_USERNAME
值: 你的阿里云账号

名称: DOCKER_PASSWORD  
值: 你的阿里云密码
```

#### 1.3 添加 Kubernetes 配置
```bash
# 在终端执行（生成 base64 编码）
cat ~/.kube/config | base64 | pbcopy
```

```
名称: KUBE_CONFIG_DEV
值: 粘贴刚才复制的内容

名称: KUBE_CONFIG_PROD
值: 粘贴生产环境的 kubeconfig (base64编码)
```

#### 1.4 添加钉钉通知 (可选)
```
名称: DINGTALK_WEBHOOK
值: https://oapi.dingtalk.com/robot/send?access_token=你的token
```

### 📍 第2步：初始化 Kubernetes (3分钟)

```bash
# 创建命名空间
kubectl create namespace gva-dev
kubectl create namespace gva-prod

# 部署后端服务配置
kubectl apply -f deploy/kubernetes/server/gva-server-configmap.yaml -n gva-dev
kubectl apply -f deploy/kubernetes/server/gva-server-deployment.yaml -n gva-dev
kubectl apply -f deploy/kubernetes/server/gva-server-service.yaml -n gva-dev

# 部署前端服务配置
kubectl apply -f deploy/kubernetes/web/gva-web-configmap.yaml -n gva-dev
kubectl apply -f deploy/kubernetes/web/gva-web-deploymemt.yaml -n gva-dev
kubectl apply -f deploy/kubernetes/web/gva-web-service.yaml -n gva-dev

# 生产环境同理（替换 -n gva-dev 为 -n gva-prod）
```

### 📍 第3步：触发第一个流水线 (2分钟)

```bash
# 提交并推送代码
git add .
git commit -m "feat: 启用 CI/CD 流水线"
git push origin develop
```

然后：
1. 访问 `https://github.com/你的仓库/actions`
2. 观察 CI 工作流运行
3. 等待约 5-10 分钟
4. 部署完成后访问开发环境验证

## 🎬 完整演示流程

### 场景：发布新版本到生产环境

```bash
# ============================================
# 步骤1：开发新功能
# ============================================
git checkout -b feature/new-broker-page develop
# ... 开发代码 ...
git add .
git commit -m "feat: 添加 Broker 管理页面"
git push origin feature/new-broker-page

# → GitHub Actions 自动运行 CI 检查
#   ✅ ESLint 通过
#   ✅ Go Lint 通过
#   ✅ 单元测试通过
#   ✅ 安全扫描通过
#   ✅ 构建成功

# ============================================
# 步骤2：合并到 develop（开发环境）
# ============================================
# 在 GitHub 上创建 Pull Request
# Code Review 通过后合并到 develop

# → GitHub Actions 自动部署到开发环境
#   ✅ 构建镜像
#   ✅ 推送镜像
#   ✅ 更新 K8s Deployment
#   ✅ 健康检查
#   ✅ 钉钉通知

# 验证: https://dev.yourdomain.com

# ============================================
# 步骤3：发布到测试环境
# ============================================
git checkout -b release/v1.0.0 develop
git push origin release/v1.0.0

# → 自动部署到测试环境
# 在测试环境进行完整验证（建议 24小时）

# 验证: https://staging.yourdomain.com

# ============================================
# 步骤4：发布到生产环境
# ============================================
git checkout main
git merge --no-ff release/v1.0.0
git tag v1.0.0
git push origin main --tags

# → 触发生产部署工作流
# 在 GitHub Actions 中点击 "Approve" 审批

# → 执行金丝雀发布:
#   ✅ 部署 10% 流量
#   ✅ 监控 60 秒
#   ✅ 全量发布
#   ✅ 健康检查
#   ✅ 通知发送

# 验证: https://www.yourdomain.com

# ============================================
# 步骤5：如果出现问题，一键回滚
# ============================================
# 方法1：在 GitHub Actions 手动触发回滚
# 方法2：使用脚本
./scripts/rollback.sh prod

# → 自动回滚到上一稳定版本
```

## 🎯 日常使用

### 本地开发（每天使用）

```bash
# 启动本地环境
./scripts/local-dev.sh

# 前端: http://localhost:8080
# 后端: http://localhost:8888

# 停止环境
cd deploy/docker-compose && docker-compose down
```

### 提交代码（每天多次）

```bash
# 开发完成后
git add .
git commit -m "feat: 新功能描述"
git push origin feature/xxx

# → CI 自动运行检查
```

### 部署到环境（每周几次）

```bash
# 合并到 develop
git checkout develop
git merge feature/xxx
git push origin develop

# → 自动部署到开发环境
```

### 查看状态（按需）

```bash
# 查看 GitHub Actions
# https://github.com/你的仓库/actions

# 查看 K8s 状态
kubectl get pods -n gva-dev
kubectl logs -f deployment/gva-server -n gva-dev
```

## 📊 关键配置总结

### GitHub Secrets 清单

| Secret 名称 | 用途 | 必需 |
|------------|------|------|
| DOCKER_USERNAME | Docker 仓库用户名 | ✅ 是 |
| DOCKER_PASSWORD | Docker 仓库密码 | ✅ 是 |
| KUBE_CONFIG_DEV | 开发环境 K8s 配置 | ✅ 是 |
| KUBE_CONFIG_PROD | 生产环境 K8s 配置 | ✅ 是 |
| DINGTALK_WEBHOOK | 钉钉通知 Webhook | ⭕ 可选 |

### 环境变量

```bash
# Docker
DOCKER_REGISTRY=registry.cn-hangzhou.aliyuncs.com
IMAGE_NAME=gva

# Kubernetes
K8S_NAMESPACE_DEV=gva-dev
K8S_NAMESPACE_PROD=gva-prod
```

## 🔧 故障快速修复

### CI 构建失败

```bash
# 查看 Actions 日志找到错误
# 本地复现问题
cd server && go test ./...
cd web && pnpm lint

# 修复后重新推送
git add .
git commit -m "fix: 修复构建问题"
git push
```

### 部署失败

```bash
# 查看 Pod 状态
kubectl get pods -n gva-prod

# 查看失败原因
kubectl describe pod <pod-name> -n gva-prod

# 快速回滚
./scripts/rollback.sh prod
```

### 服务异常

```bash
# 1. 查看日志
kubectl logs -f deployment/gva-server -n gva-prod

# 2. 检查资源
kubectl top pods -n gva-prod

# 3. 重启服务
kubectl rollout restart deployment/gva-server -n gva-prod

# 4. 如果无法解决，回滚
./scripts/rollback.sh prod
```

## 📱 移动端访问

### 钉钉群配置

1. 创建钉钉群
2. 添加自定义机器人
3. 选择"自定义关键词" → 输入: 部署, 构建, CI
4. 复制 Webhook URL
5. 添加到 GitHub Secrets

### 通知效果

```
收到通知示例:
━━━━━━━━━━━━━━━━━━━━
🚀 开发环境部署通知

环境: Development
状态: ✅ 成功
分支: develop
版本: develop-abc1234-20251016
提交者: your-name
访问地址: https://dev.yourdomain.com

[查看详情]
━━━━━━━━━━━━━━━━━━━━
```

## 🎓 团队培训建议

### 第1周：基础培训 (2小时)

```
1. CI/CD 概念介绍 (30分钟)
2. Git 分支策略 (30分钟)
3. 演示完整流程 (30分钟)
4. 实际操作练习 (30分钟)
```

### 第2周：进阶培训 (2小时)

```
1. Kubernetes 基础 (30分钟)
2. 监控和日志 (30分钟)
3. 故障排查 (30分钟)
4. 最佳实践 (30分钟)
```

### 第3周：实战演练 (4小时)

```
1. 完整的功能开发和发布 (2小时)
2. 模拟故障和回滚 (1小时)
3. 性能优化 (1小时)
```

## 🎉 立即开始

### 方法1：完整配置（推荐）

```bash
# 1. 配置 GitHub Secrets (5分钟)
# 2. 初始化 K8s (3分钟)
# 3. 推送代码测试 (2分钟)

总时间: 10分钟
```

### 方法2：本地测试

```bash
# 只测试构建流程
./scripts/build.sh

# 启动本地环境
./scripts/local-dev.sh
```

### 方法3：分阶段实施

```
第1天: 配置 CI (代码检查)
第2天: 配置构建流程
第3天: 配置开发环境部署
第1周: 完整测试
第2周: 生产环境上线
```

## 📞 需要帮助？

### 快速查阅

- **快速开始**: `CICD_QUICKSTART.md`
- **命令速查**: `CICD_CHEATSHEET.md`
- **完整方案**: `README_CICD.md`

### 常见问题

**Q: GitHub Actions 免费吗？**
A: 公开仓库免费，私有仓库每月2000分钟免费

**Q: 必须使用 Kubernetes 吗？**
A: 不是，也可以用 Docker Compose，修改脚本即可

**Q: 可以用其他 CI/CD 工具吗？**
A: 可以，已提供 GitLab CI 配置，也可以改用 Jenkins

**Q: 构建很慢怎么办？**
A: 启用缓存、使用 BuildKit、并行构建

---

## ✨ 你现在拥有的能力

```
✅ 代码推送 → 自动检查 → 自动测试 → 自动构建 → 自动部署
✅ 多环境管理 (Dev/Staging/Prod)
✅ 一键回滚
✅ 自动通知
✅ 安全扫描
✅ 质量把控
```

## 🎊 现在就开始

```bash
# 一行命令开始你的 CI/CD 之旅
git push origin develop
```

然后访问: `https://github.com/你的仓库/actions` 

观看你的第一个自动化流水线运行！🚀

---

**准备时间**: 10分钟  
**学习时间**: 1天  
**回报**: 巨大！  
**推荐度**: ⭐⭐⭐⭐⭐



