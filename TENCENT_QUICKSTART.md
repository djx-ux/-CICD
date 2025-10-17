# 🚀 腾讯云CI/CD快速开始 - 10分钟上手指南

> 从零到部署，只需10分钟！跟着这份指南，你将完成从腾讯云配置到自动化部署的全过程。

---

## 📋 准备清单

在开始之前，请确保你有：

- [ ] 腾讯云账号（[注册地址](https://cloud.tencent.com/)）
- [ ] GitHub账号
- [ ] 本地已安装：git、kubectl、docker（可选）
- [ ] 一个域名（可选，用于生产环境访问）

---

## 🎯 步骤 1：腾讯云服务配置（5分钟）

### 1.1 开通容器镜像服务（TCR）

```bash
# 访问腾讯云控制台
https://console.cloud.tencent.com/tcr

# 点击「新建实例」
实例名称：gin-vue-admin-registry
实例类型：个人版（免费）
地域：广州（或你的服务器所在地域）

# 创建命名空间
命名空间名称：gva
访问级别：私有

# 获取访问凭证（重要！）
访问凭证页面 → 生成临时访问令牌（或长期令牌）
```

**记录以下信息**（稍后需要）：
```
TCR_REGISTRY=xxxxxx.tencentcloudcr.com
TCR_USERNAME=100012345678
TCR_PASSWORD=ey... (你的访问令牌)
```

### 1.2 开通容器服务（TKE）

```bash
# 访问容器服务控制台
https://console.cloud.tencent.com/tke2

# 点击「新建集群」
集群名称：gin-vue-admin-cluster
Kubernetes版本：1.26+
网络：默认VPC（自动创建）
节点配置：2核4G（标准SA2，按需选择）
节点数量：2个（开发环境1个也可以）

# 等待集群创建（约3-5分钟）
```

### 1.3 获取集群访问凭证

```bash
# 在 TKE 集群详情页
基本信息 → 集群凭证 → 复制内容或下载

# 保存为本地文件
mkdir -p ~/.kube
# 将复制的内容保存到 ~/.kube/config-tencent
vi ~/.kube/config-tencent  # 粘贴内容

# 测试连接
export KUBECONFIG=~/.kube/config-tencent
kubectl cluster-info
kubectl get nodes  # 应该看到你的节点列表
```

---

## 🎯 步骤 2：GitHub 仓库配置（3分钟）

### 2.1 推送代码到 GitHub

```bash
# 如果还没有推送到 GitHub
cd /Users/ykmz/Desktop/哈雷彗星/gin-vue-admin

# 初始化（如果需要）
git init
git add .
git commit -m "initial commit"

# 在 GitHub 创建仓库
# https://github.com/new
# 仓库名：gin-vue-admin

# 关联远程仓库
git remote add origin https://github.com/你的用户名/gin-vue-admin.git
git branch -M main
git push -u origin main

# 创建 develop 分支
git checkout -b develop
git push -u origin develop
```

### 2.2 配置 GitHub Secrets

访问：`https://github.com/你的用户名/gin-vue-admin/settings/secrets/actions`

点击「New repository secret」添加以下 Secrets：

#### Secret 1: DOCKER_REGISTRY
```
Name: DOCKER_REGISTRY
Secret: xxxxxx.tencentcloudcr.com
```
（你的TCR镜像仓库地址）

#### Secret 2: DOCKER_USERNAME
```
Name: DOCKER_USERNAME
Secret: 100012345678
```
（你的TCR用户名）

#### Secret 3: DOCKER_PASSWORD
```
Name: DOCKER_PASSWORD
Secret: ey...
```
（你的TCR访问令牌）

#### Secret 4: KUBE_CONFIG_DEV
```bash
# 在终端执行
cat ~/.kube/config-tencent | base64

# macOS 用户可以直接复制到剪贴板
cat ~/.kube/config-tencent | base64 | pbcopy

# Linux 用户
cat ~/.kube/config-tencent | base64 -w 0 | xclip -selection clipboard
```

```
Name: KUBE_CONFIG_DEV
Secret: [粘贴上面生成的 base64 字符串]
```

#### Secret 5: KUBE_CONFIG_PROD
```
Name: KUBE_CONFIG_PROD
Secret: [同样的 base64 字符串，生产环境可以先用相同的]
```

#### Secret 6: WECOM_WEBHOOK（可选）
```
Name: WECOM_WEBHOOK
Secret: https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx
```
（如果要接收企业微信通知）

---

## 🎯 步骤 3：Kubernetes 集群初始化（2分钟）

### 3.1 创建命名空间和密钥

```bash
# 确保使用腾讯云集群
export KUBECONFIG=~/.kube/config-tencent

# 创建命名空间
kubectl create namespace gva-dev
kubectl create namespace gva-prod

# 为每个命名空间创建镜像拉取密钥
# 替换下面的值为你的实际值
TCR_REGISTRY="xxxxxx.tencentcloudcr.com"
TCR_USERNAME="100012345678"
TCR_PASSWORD="你的令牌"

# 创建开发环境密钥
kubectl create secret docker-registry tcr-secret \
  --docker-server=${TCR_REGISTRY} \
  --docker-username=${TCR_USERNAME} \
  --docker-password=${TCR_PASSWORD} \
  --namespace=gva-dev

# 创建生产环境密钥
kubectl create secret docker-registry tcr-secret \
  --docker-server=${TCR_REGISTRY} \
  --docker-username=${TCR_USERNAME} \
  --docker-password=${TCR_PASSWORD} \
  --namespace=gva-prod

# 验证密钥创建成功
kubectl get secret tcr-secret -n gva-dev
kubectl get secret tcr-secret -n gva-prod
```

### 3.2 更新 Kubernetes 配置文件

编辑以下文件，更新镜像仓库地址：

**文件1**: `deploy/kubernetes/server/gva-server-deployment.yaml`

找到并修改：
```yaml
spec:
  template:
    spec:
      imagePullSecrets:
        - name: tcr-secret  # 添加这一行
      containers:
      - name: gin-vue-admin-container
        image: xxxxxx.tencentcloudcr.com/gva/server:latest  # 修改为你的TCR地址
```

**文件2**: `deploy/kubernetes/web/gva-web-deploymemt.yaml`

找到并修改：
```yaml
spec:
  template:
    spec:
      imagePullSecrets:
        - name: tcr-secret  # 添加这一行
      containers:
      - name: gva-web-container
        image: xxxxxx.tencentcloudcr.com/gva/web:latest  # 修改为你的TCR地址
```

提交修改：
```bash
git add deploy/kubernetes/
git commit -m "chore: 配置腾讯云镜像仓库"
git push origin develop
```

---

## 🎯 步骤 4：触发第一次部署！（立即）

```bash
# 方式1：直接推送代码触发
git checkout develop
git commit --allow-empty -m "feat: 触发第一次CI/CD部署"
git push origin develop

# 方式2：手动触发（在GitHub网页操作）
# 访问：https://github.com/你的用户名/gin-vue-admin/actions
# 选择「CD - 腾讯云开发环境部署」
# 点击「Run workflow」
```

---

## 📊 观察部署过程

### 4.1 查看 GitHub Actions

访问：`https://github.com/你的用户名/gin-vue-admin/actions`

你会看到两个工作流在运行：

1. **CI - 腾讯云持续集成**（5-8分钟）
   - ✅ 前端代码检查
   - ✅ 后端代码检查
   - ✅ 构建Docker镜像
   - ✅ 推送到腾讯云TCR

2. **CD - 腾讯云开发环境部署**（3-5分钟）
   - ✅ 配置kubectl
   - ✅ 更新镜像
   - ✅ 等待服务就绪
   - ✅ 健康检查

### 4.2 在本地查看部署状态

```bash
# 实时查看 Pod 状态
kubectl get pods -n gva-dev -w

# 你会看到类似输出：
# NAME                          READY   STATUS    RESTARTS   AGE
# gva-server-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
# gva-web-xxxxxxxxxx-xxxxx      1/1     Running   0          2m

# 查看服务
kubectl get svc -n gva-dev

# 查看详细部署信息
kubectl get all -n gva-dev
```

### 4.3 查看应用日志

```bash
# 查看后端日志
kubectl logs -f deployment/gva-server -n gva-dev

# 查看前端日志
kubectl logs -f deployment/gva-web -n gva-dev
```

---

## 🌐 访问你的应用

### 方式1：通过 LoadBalancer IP

```bash
# 获取外部访问地址
kubectl get svc -n gva-dev

# 输出示例：
# NAME         TYPE           EXTERNAL-IP      PORT(S)
# gva-web      LoadBalancer   43.xxx.xxx.xxx   80:30080/TCP
# gva-server   LoadBalancer   43.xxx.xxx.xxx   8888:30888/TCP

# 在浏览器访问：
# 前端：http://43.xxx.xxx.xxx
# 后端：http://43.xxx.xxx.xxx:8888
```

### 方式2：通过端口转发（本地测试）

```bash
# 转发前端服务
kubectl port-forward svc/gva-web 8080:80 -n gva-dev

# 在浏览器访问：http://localhost:8080

# 转发后端服务（新开一个终端）
kubectl port-forward svc/gva-server 8888:8888 -n gva-dev

# 访问后端 API：http://localhost:8888
```

### 方式3：配置域名（推荐生产环境）

```bash
# 1. 在腾讯云DNS控制台添加A记录
# https://console.cloud.tencent.com/cns
记录类型：A
主机记录：dev（或 www）
记录值：LoadBalancer的外部IP

# 2. 等待DNS生效（1-5分钟）

# 3. 访问：http://dev.yourdomain.com
```

---

## ✅ 验证部署成功

运行以下命令检查所有组件：

```bash
# 1. 检查 Pod 状态（应该都是 Running）
kubectl get pods -n gva-dev

# 2. 检查 Service（应该有 EXTERNAL-IP）
kubectl get svc -n gva-dev

# 3. 检查 Deployment
kubectl get deployment -n gva-dev

# 4. 查看最近的事件
kubectl get events -n gva-dev --sort-by='.lastTimestamp' | head -20

# 5. 快速健康检查
kubectl get pods -n gva-dev -o json | jq '.items[] | {name:.metadata.name, status:.status.phase, ready:.status.containerStatuses[0].ready}'
```

如果所有 Pod 状态都是 `Running` 并且 `ready: true`，恭喜你，部署成功了！🎉

---

## 🔄 日常使用流程

### 开发新功能

```bash
# 1. 创建功能分支
git checkout -b feature/add-user-list develop

# 2. 开发和测试
# ... 编写代码 ...

# 3. 提交代码
git add .
git commit -m "feat: 添加用户列表功能"
git push origin feature/add-user-list

# 4. 在 GitHub 创建 Pull Request
# → CI 自动运行检查和测试

# 5. PR 合并到 develop 后
# → 自动部署到开发环境！
```

### 发布到生产环境

```bash
# 1. 从 develop 创建 release 分支
git checkout develop
git pull
git checkout -b release/v1.0.0

# 2. 推送并打标签
git push origin release/v1.0.0
git checkout main
git merge --no-ff release/v1.0.0
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin main --tags

# 3. 在 GitHub Actions 中审批
# 访问 Actions 页面 → 点击 "Review deployments" → "Approve"

# 4. 等待自动部署完成
# → 金丝雀发布 → 健康检查 → 全量发布

# 5. 访问生产环境验证
# http://www.yourdomain.com
```

---

## 🛠️ 常用运维命令

### 查看服务状态

```bash
# 查看所有资源
kubectl get all -n gva-dev

# 查看 Pod 详情
kubectl describe pod <pod-name> -n gva-dev

# 实时查看日志
kubectl logs -f deployment/gva-server -n gva-dev

# 查看最近的事件
kubectl get events -n gva-dev --sort-by='.lastTimestamp'
```

### 更新配置

```bash
# 编辑 ConfigMap
kubectl edit configmap gva-server-config -n gva-dev

# 重启服务使配置生效
kubectl rollout restart deployment/gva-server -n gva-dev
```

### 扩缩容

```bash
# 扩容到3个副本
kubectl scale deployment gva-server --replicas=3 -n gva-dev

# 查看扩容状态
kubectl get pods -n gva-dev -w
```

### 手动回滚

```bash
# 查看部署历史
kubectl rollout history deployment/gva-server -n gva-dev

# 回滚到上一版本
kubectl rollout undo deployment/gva-server -n gva-dev

# 回滚到指定版本
kubectl rollout undo deployment/gva-server --to-revision=2 -n gva-dev
```

---

## 🐛 常见问题解决

### 问题1：ImagePullBackOff

```bash
# 检查密钥是否存在
kubectl get secret tcr-secret -n gva-dev

# 如果不存在，重新创建
kubectl create secret docker-registry tcr-secret \
  --docker-server=xxx.tencentcloudcr.com \
  --docker-username=xxx \
  --docker-password=xxx \
  --namespace=gva-dev

# 检查镜像是否存在
# 访问腾讯云TCR控制台查看镜像列表
```

### 问题2：Pod 一直 Pending

```bash
# 查看详细原因
kubectl describe pod <pod-name> -n gva-dev

# 检查节点资源
kubectl top nodes

# 如果是资源不足，去TKE控制台添加节点
```

### 问题3：无法访问服务

```bash
# 检查 Service 是否有外部IP
kubectl get svc -n gva-dev

# 检查安全组规则
# 在腾讯云控制台 → 容器服务 → 集群 → 节点管理
# 确保安全组开放了 80 和 8888 端口

# 使用端口转发临时测试
kubectl port-forward svc/gva-web 8080:80 -n gva-dev
# 访问 http://localhost:8080
```

### 问题4：GitHub Actions 失败

```bash
# 1. 检查 Secrets 配置是否正确
# Settings → Secrets → Actions

# 2. 查看 Actions 日志找到具体错误
# Actions → 点击失败的工作流 → 查看日志

# 3. 常见错误：
#    - kubeconfig base64 编码错误：重新生成
#    - Docker 登录失败：检查 TCR 凭证
#    - kubectl 连接失败：检查集群状态
```

---

## 📈 监控和告警

### 查看腾讯云监控

```bash
# 访问腾讯云监控控制台
https://console.cloud.tencent.com/monitor/product/tke

# 查看关键指标：
# - CPU 使用率
# - 内存使用率
# - 网络流量
# - Pod 状态
```

### 配置告警（推荐）

```
1. 访问：https://console.cloud.tencent.com/monitor/alarm2/policy
2. 新建告警策略
3. 选择：容器服务 - 集群
4. 配置规则：
   - CPU使用率 > 80%
   - 内存使用率 > 85%
   - Pod 重启次数 > 5次/10分钟
5. 配置通知：短信/邮件/企业微信
```

---

## 🎉 恭喜你！

你已经成功配置了完整的 CI/CD 流水线！

### 现在你拥有的能力：

✅ **代码推送自动部署** - 推送到 develop 分支，自动部署到开发环境  
✅ **质量保障** - 自动代码检查、测试、安全扫描  
✅ **一键发布** - 合并到 main 分支，一键发布到生产环境  
✅ **自动回滚** - 部署失败自动回滚到上一版本  
✅ **实时通知** - 企业微信/钉钉实时接收部署状态  

### 下一步建议：

1. ✅ 配置生产环境域名和 HTTPS
2. ✅ 配置数据库持久化存储
3. ✅ 设置监控和告警
4. ✅ 编写更多自动化测试
5. ✅ 配置备份策略

---

## 📚 更多资源

- [完整部署文档](./TENCENT_CLOUD_DEPLOY.md)
- [腾讯云TKE文档](https://cloud.tencent.com/document/product/457)
- [腾讯云TCR文档](https://cloud.tencent.com/document/product/1141)
- [Kubernetes官方文档](https://kubernetes.io/zh/docs/)

---

## 🆘 需要帮助？

- 查看 [常见问题](./TENCENT_CLOUD_DEPLOY.md#6-常见问题)
- 查看 GitHub Actions 日志
- 查看 Kubernetes 事件日志
- 提交 GitHub Issue

---

**配置时间**: 10分钟  
**首次部署**: 10-15分钟  
**后续部署**: 5-8分钟  
**难度**: ⭐⭐⭐☆☆  
**推荐度**: ⭐⭐⭐⭐⭐

**现在就开始你的第一次自动化部署吧！** 🚀

