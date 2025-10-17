# 🎯 腾讯云 CI/CD 部署 - 从这里开始

> 你正在查看：快速指引页面  
> 📅 创建时间：2025-10-17

---

## ✅ 已为你准备好的文件

### 📚 文档（3个）

| 文档 | 描述 | 适合人群 |
|------|------|---------|
| **[TENCENT_QUICKSTART.md](./TENCENT_QUICKSTART.md)** | 10分钟快速开始指南 | ⭐ 所有人 |
| **[TENCENT_CLOUD_DEPLOY.md](./TENCENT_CLOUD_DEPLOY.md)** | 完整部署文档 | 深入学习 |
| **[README_TENCENT_CICD.md](./README_TENCENT_CICD.md)** | 功能特性和架构 | 了解全貌 |

### ⚙️ GitHub Actions 工作流（3个）

| 工作流 | 文件 | 功能 |
|-------|------|------|
| CI | `.github/workflows/tencent-ci.yml` | 代码检查、测试、构建镜像 |
| CD-Dev | `.github/workflows/tencent-cd-dev.yml` | 自动部署到开发环境 |
| CD-Prod | `.github/workflows/tencent-cd-prod.yml` | 审批部署到生产环境 |

### 🛠️ 工具脚本（1个）

| 脚本 | 功能 |
|------|------|
| `scripts/setup-tencent-cloud.sh` | 自动配置脚本 |

---

## 🚀 3种开始方式

### 方式 1：最快上手（推荐）⭐

```bash
# 1. 阅读快速指南
open TENCENT_QUICKSTART.md

# 2. 运行配置脚本
./scripts/setup-tencent-cloud.sh

# 3. 按提示完成配置

# 总耗时：约 10-15 分钟
```

### 方式 2：一步一步来

```bash
# 1. 打开快速指南
open TENCENT_QUICKSTART.md

# 2. 按照文档逐步操作
#    - 步骤 1：腾讯云服务配置（5分钟）
#    - 步骤 2：GitHub 仓库配置（3分钟）
#    - 步骤 3：Kubernetes 集群初始化（2分钟）
#    - 步骤 4：触发第一次部署（立即）

# 总耗时：约 10 分钟配置 + 10 分钟部署
```

### 方式 3：深入了解

```bash
# 1. 先了解整体架构
open README_TENCENT_CICD.md

# 2. 阅读完整部署文档
open TENCENT_CLOUD_DEPLOY.md

# 3. 按照文档配置

# 适合：想要深入理解每个步骤的用户
```

---

## 📋 配置前准备清单

### 必需准备

- [ ] 腾讯云账号（[注册](https://cloud.tencent.com/)）
- [ ] GitHub 账号
- [ ] 本地已安装：`git`、`kubectl`
- [ ] 已将代码推送到 GitHub

### 腾讯云服务

- [ ] 已开通**容器镜像服务（TCR）**
- [ ] 已开通**容器服务（TKE）**
- [ ] 已创建 TKE 集群
- [ ] 已获取集群访问凭证（kubeconfig）

### TCR 信息

- [ ] TCR 镜像仓库地址：`xxx.tencentcloudcr.com`
- [ ] TCR 用户名：`100012345678`
- [ ] TCR 访问令牌：`ey...`

---

## 🎯 推荐路径

### 新手推荐路径

```
1. 阅读 TENCENT_QUICKSTART.md（5分钟）
   ↓
2. 运行 setup-tencent-cloud.sh（2分钟）
   ↓
3. 配置 GitHub Secrets（3分钟）
   ↓
4. 配置 Kubernetes 密钥（1分钟）
   ↓
5. 推送代码触发部署（1分钟）
   ↓
6. 观察部署过程（10分钟）
```

**总时间：约 22 分钟**

### 高级用户路径

```
1. 阅读 README_TENCENT_CICD.md 了解架构
   ↓
2. 查看 TENCENT_CLOUD_DEPLOY.md 了解细节
   ↓
3. 手动配置所有服务
   ↓
4. 根据需求调整工作流
   ↓
5. 配置监控和告警
```

---

## 📞 常见问题

### Q1: 我应该从哪个文档开始？

**A**: 推荐从 [TENCENT_QUICKSTART.md](./TENCENT_QUICKSTART.md) 开始，它包含了最快的上手步骤。

### Q2: 配置脚本做了什么？

**A**: `setup-tencent-cloud.sh` 会：
- 更新 Kubernetes 配置文件中的镜像地址
- 生成 GitHub Secrets 配置清单
- 生成 Kubernetes 密钥创建脚本
- 生成测试脚本

### Q3: 必须使用腾讯云吗？

**A**: 不是。如果你使用阿里云，可以使用原有的工作流：
- `.github/workflows/ci.yml`
- `.github/workflows/cd-dev.yml`
- `.github/workflows/cd-prod.yml`

### Q4: 需要多长时间才能完成部署？

**A**: 
- 配置时间：10-15 分钟
- 首次部署：10-15 分钟
- 后续部署：5-8 分钟

### Q5: 部署失败怎么办？

**A**: 
1. 查看 GitHub Actions 日志
2. 查看 Kubernetes Pod 日志：`kubectl logs -f deployment/gva-server -n gva-dev`
3. 查看 [故障排查指南](./TENCENT_CLOUD_DEPLOY.md#6-常见问题)

---

## 🎓 学习路径

### 第1天：快速开始

```bash
✅ 运行配置脚本
✅ 配置 GitHub 和 Kubernetes
✅ 完成第一次部署
✅ 访问部署的应用
```

### 第2天：深入理解

```bash
✅ 阅读完整部署文档
✅ 了解 CI/CD 工作流程
✅ 学习 Kubernetes 基础操作
✅ 查看监控和日志
```

### 第3天：优化和扩展

```bash
✅ 配置域名和 HTTPS
✅ 配置告警
✅ 优化资源配置
✅ 添加自动化测试
```

---

## 💡 温馨提示

### ✅ 推荐做法

- 先在开发环境测试，确认无误后再部署生产环境
- 定期备份重要数据
- 配置监控和告警
- 保持文档同步更新

### ⚠️ 注意事项

- 不要将敏感信息提交到代码仓库
- 生产环境部署前务必在测试环境验证
- 重要更新建议在低峰时段发布
- 保持访问令牌的安全

---

## 🚀 现在就开始

### 选项 A：快速开始（10分钟）

```bash
# 运行配置脚本
./scripts/setup-tencent-cloud.sh

# 然后按照生成的文件 github-secrets-config.txt 配置 GitHub
# 运行 setup-k8s-secrets.sh 配置 Kubernetes
# 推送代码即可触发部署
```

### 选项 B：阅读文档（5分钟）

```bash
# 打开快速开始指南
open TENCENT_QUICKSTART.md

# 或在终端查看
less TENCENT_QUICKSTART.md
```

---

## 📊 项目状态

| 项目 | 状态 |
|------|------|
| 文档 | ✅ 完成 |
| GitHub Actions 工作流 | ✅ 完成 |
| 配置脚本 | ✅ 完成 |
| Kubernetes 配置 | ⚠️ 需要更新镜像地址 |
| GitHub Secrets | ❌ 待配置 |
| 腾讯云服务 | ❌ 待开通 |

---

## 📈 成功指标

部署成功的标志：

- ✅ GitHub Actions 工作流运行成功
- ✅ 镜像成功推送到腾讯云 TCR
- ✅ Pod 状态为 Running
- ✅ Service 已分配外部 IP
- ✅ 可以通过浏览器访问应用
- ✅ 收到企业微信/钉钉通知

---

## 🎯 行动计划

### 今天（30分钟）

1. ⬜ 阅读快速开始指南
2. ⬜ 运行配置脚本
3. ⬜ 配置 GitHub Secrets

### 明天（30分钟）

1. ⬜ 配置 Kubernetes 密钥
2. ⬜ 推送代码触发部署
3. ⬜ 验证部署成功

### 本周（2小时）

1. ⬜ 阅读完整文档
2. ⬜ 配置生产环境
3. ⬜ 配置监控告警

---

## 🎉 准备好了吗？

**让我们开始吧！**

```bash
# 方式 1：运行配置脚本（最快）
./scripts/setup-tencent-cloud.sh

# 方式 2：阅读快速指南
open TENCENT_QUICKSTART.md

# 方式 3：了解整体架构
open README_TENCENT_CICD.md
```

---

## 📞 需要帮助？

- 📖 **文档**: [快速开始](./TENCENT_QUICKSTART.md) | [完整指南](./TENCENT_CLOUD_DEPLOY.md)
- 🐛 **问题**: [提交 Issue](https://github.com/你的用户名/gin-vue-admin/issues)
- 💬 **讨论**: [GitHub Discussions](https://github.com/你的用户名/gin-vue-admin/discussions)

---

**文档版本**: v1.0.0  
**更新时间**: 2025-10-17  
**维护者**: AI Assistant

**祝你部署顺利！** 🚀

