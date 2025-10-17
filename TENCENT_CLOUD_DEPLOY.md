# 🚀 腾讯云 CI/CD 部署完整指南

## 📋 目录

1. [腾讯云服务准备](#1-腾讯云服务准备)
2. [GitHub仓库配置](#2-github仓库配置)
3. [Kubernetes集群配置](#3-kubernetes集群配置)
4. [部署流程](#4-部署流程)
5. [监控和维护](#5-监控和维护)
6. [常见问题](#6-常见问题)

---

## 1. 腾讯云服务准备

### 1.1 开通容器镜像服务（TCR）

#### 步骤1：创建镜像仓库实例

1. 登录[腾讯云容器镜像服务控制台](https://console.cloud.tencent.com/tcr)
2. 点击「新建」创建实例
   - 实例名称：`gin-vue-admin`
   - 实例类型：个人版（免费）或企业版
   - 地域：选择你的服务器所在地域（如：广州）

#### 步骤2：创建命名空间

```bash
命名空间名称：gva
类型：私有
```

#### 步骤3：获取访问凭证

```bash
# 在「访问凭证」页面创建访问令牌
用户名：你会看到一个自动生成的用户名（通常是数字）
密码：创建临时或长期令牌
```

**记录以下信息**：
```bash
TCR_REGISTRY=xxx.tencentcloudcr.com  # 你的镜像仓库地址
TCR_USERNAME=100012345678            # 你的用户名
TCR_PASSWORD=your-token-here         # 你的访问令牌
```

### 1.2 开通容器服务（TKE）

#### 步骤1：创建集群

1. 登录[腾讯云容器服务控制台](https://console.cloud.tencent.com/tke2)
2. 点击「新建」创建集群
   - 集群类型：标准集群
   - Kubernetes版本：1.26 或更高
   - 网络：VPC网络（会自动创建）
   - 节点：选择合适的机器配置（建议：2核4G起步）

#### 步骤2：获取集群访问凭证

```bash
# 在集群详情页，点击「基本信息」→「集群凭证」
# 下载 kubeconfig 文件
```

保存为：`~/.kube/config-tencent`

#### 步骤3：测试连接

```bash
# 测试集群连接
export KUBECONFIG=~/.kube/config-tencent
kubectl cluster-info
kubectl get nodes
```

### 1.3 配置镜像仓库与TKE的访问

```bash
# 在 TKE 集群中创建镜像仓库访问密钥
kubectl create secret docker-registry tcr-secret \
  --docker-server=xxx.tencentcloudcr.com \
  --docker-username=100012345678 \
  --docker-password=your-token-here \
  --namespace=default

# 为其他命名空间也创建（如需要）
kubectl create secret docker-registry tcr-secret \
  --docker-server=xxx.tencentcloudcr.com \
  --docker-username=100012345678 \
  --docker-password=your-token-here \
  --namespace=gva-dev

kubectl create secret docker-registry tcr-secret \
  --docker-server=xxx.tencentcloudcr.com \
  --docker-username=100012345678 \
  --docker-password=your-token-here \
  --namespace=gva-prod
```

---

## 2. GitHub仓库配置

### 2.1 添加 GitHub Secrets

访问你的GitHub仓库：`https://github.com/你的用户名/gin-vue-admin/settings/secrets/actions`

添加以下Secrets：

```yaml
# 腾讯云容器镜像服务凭证
DOCKER_REGISTRY: xxx.tencentcloudcr.com
DOCKER_USERNAME: 100012345678
DOCKER_PASSWORD: your-token-here

# Kubernetes 配置（base64编码）
KUBE_CONFIG_DEV: |
  <base64编码的kubeconfig内容>

KUBE_CONFIG_PROD: |
  <base64编码的kubeconfig内容>

# 钉钉/企业微信通知（可选）
DINGTALK_WEBHOOK: https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx
WECOM_WEBHOOK: https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx
```

#### 如何生成 base64 编码的 kubeconfig：

```bash
# macOS
cat ~/.kube/config-tencent | base64 | pbcopy

# Linux
cat ~/.kube/config-tencent | base64 -w 0 | xclip -selection clipboard

# 然后粘贴到 GitHub Secrets
```

### 2.2 推送代码到GitHub

```bash
# 如果还没有推送到GitHub
git remote add origin https://github.com/你的用户名/gin-vue-admin.git
git branch -M main
git push -u origin main

# 创建 develop 分支
git checkout -b develop
git push -u origin develop
```

---

## 3. Kubernetes集群配置

### 3.1 更新 Kubernetes 配置文件

需要更新以下文件中的镜像仓库地址和添加 imagePullSecrets：

#### 更新后端 Deployment

编辑 `deploy/kubernetes/server/gva-server-deployment.yaml`：

```yaml
spec:
  template:
    spec:
      imagePullSecrets:
        - name: tcr-secret  # 添加这行
      containers:
      - name: gin-vue-admin-container
        image: xxx.tencentcloudcr.com/gva/server:latest  # 修改镜像地址
```

#### 更新前端 Deployment

编辑 `deploy/kubernetes/web/gva-web-deploymemt.yaml`：

```yaml
spec:
  template:
    spec:
      imagePullSecrets:
        - name: tcr-secret  # 添加这行
      containers:
      - name: gva-web-container
        image: xxx.tencentcloudcr.com/gva/web:latest  # 修改镜像地址
```

### 3.2 创建命名空间和部署资源

```bash
# 设置 kubeconfig
export KUBECONFIG=~/.kube/config-tencent

# 创建命名空间
kubectl create namespace gva-dev
kubectl create namespace gva-prod

# 为每个命名空间创建镜像拉取密钥
kubectl create secret docker-registry tcr-secret \
  --docker-server=xxx.tencentcloudcr.com \
  --docker-username=100012345678 \
  --docker-password=your-token-here \
  --namespace=gva-dev

kubectl create secret docker-registry tcr-secret \
  --docker-server=xxx.tencentcloudcr.com \
  --docker-username=100012345678 \
  --docker-password=your-token-here \
  --namespace=gva-prod

# 部署后端服务到开发环境
kubectl apply -f deploy/kubernetes/server/gva-server-configmap.yaml -n gva-dev
kubectl apply -f deploy/kubernetes/server/gva-server-deployment.yaml -n gva-dev
kubectl apply -f deploy/kubernetes/server/gva-server-service.yaml -n gva-dev

# 部署前端服务到开发环境
kubectl apply -f deploy/kubernetes/web/gva-web-configmap.yaml -n gva-dev
kubectl apply -f deploy/kubernetes/web/gva-web-deploymemt.yaml -n gva-dev
kubectl apply -f deploy/kubernetes/web/gva-web-service.yaml -n gva-dev
kubectl apply -f deploy/kubernetes/web/gva-web-ingress.yaml -n gva-dev

# 同样部署到生产环境（替换 -n gva-dev 为 -n gva-prod）
```

### 3.3 配置负载均衡和域名

#### 方法1：使用 LoadBalancer（推荐）

```bash
# 查看 LoadBalancer 外部IP
kubectl get svc -n gva-dev

# 你会看到类似：
# NAME         TYPE           EXTERNAL-IP      PORT(S)
# gva-web      LoadBalancer   43.xxx.xxx.xxx   80:30080/TCP
# gva-server   LoadBalancer   43.xxx.xxx.xxx   8888:30888/TCP
```

#### 方法2：使用 Ingress

编辑 `deploy/kubernetes/web/gva-web-ingress.yaml`：

```yaml
spec:
  rules:
  - host: dev.yourdomain.com  # 修改为你的域名
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: gva-web
            port:
              number: 80
  - host: api.yourdomain.com  # API域名
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: gva-server
            port:
              number: 8888
```

应用配置：

```bash
kubectl apply -f deploy/kubernetes/web/gva-web-ingress.yaml -n gva-dev
```

#### 配置腾讯云DNS

1. 登录[腾讯云DNS控制台](https://console.cloud.tencent.com/cns)
2. 添加域名解析记录：
   ```
   类型：A记录
   主机记录：dev（或 www/api）
   记录值：LoadBalancer的外部IP或Ingress的IP
   ```

---

## 4. 部署流程

### 4.1 首次部署

```bash
# 1. 确保所有配置正确
git status

# 2. 提交代码到 develop 分支
git checkout develop
git add .
git commit -m "feat: 配置腾讯云CI/CD"
git push origin develop

# 3. 访问 GitHub Actions 查看构建
# https://github.com/你的用户名/gin-vue-admin/actions

# 4. 等待 CI 完成（约5-10分钟）
# - 代码检查
# - 构建镜像
# - 推送到腾讯云TCR
# - 自动部署到开发环境

# 5. 验证部署
kubectl get pods -n gva-dev
kubectl get svc -n gva-dev

# 6. 访问应用
# http://dev.yourdomain.com
# 或使用 LoadBalancer IP
```

### 4.2 日常开发流程

```bash
# 开发新功能
git checkout -b feature/new-feature develop

# 修改代码...

# 提交代码
git add .
git commit -m "feat: 添加新功能"
git push origin feature/new-feature

# 在GitHub创建 Pull Request
# → CI 自动运行检查

# PR合并到 develop 后
# → 自动部署到开发环境
```

### 4.3 发布到生产环境

```bash
# 1. 从 develop 创建 release 分支
git checkout develop
git pull origin develop
git checkout -b release/v1.0.0

# 2. 推送到 GitHub
git push origin release/v1.0.0
# → 可选：部署到测试环境

# 3. 测试通过后，合并到 main
git checkout main
git merge --no-ff release/v1.0.0

# 4. 打标签
git tag -a v1.0.0 -m "Release version 1.0.0"

# 5. 推送到 GitHub
git push origin main
git push origin v1.0.0

# 6. 在 GitHub Actions 中审批部署
# → 访问 Actions 页面
# → 点击 "Approve" 按钮
# → 自动部署到生产环境

# 7. 验证生产环境
# https://www.yourdomain.com
```

---

## 5. 监控和维护

### 5.1 查看服务状态

```bash
# 查看所有资源
kubectl get all -n gva-prod

# 查看 Pod 详情
kubectl describe pod <pod-name> -n gva-prod

# 查看实时日志
kubectl logs -f deployment/gva-server -n gva-prod
kubectl logs -f deployment/gva-web -n gva-prod

# 查看最近的事件
kubectl get events -n gva-prod --sort-by='.lastTimestamp'
```

### 5.2 查看部署历史

```bash
# 查看部署历史
kubectl rollout history deployment/gva-server -n gva-prod

# 查看特定版本详情
kubectl rollout history deployment/gva-server --revision=5 -n gva-prod
```

### 5.3 手动回滚

```bash
# 回滚到上一版本
kubectl rollout undo deployment/gva-server -n gva-prod
kubectl rollout undo deployment/gva-web -n gva-prod

# 回滚到指定版本
kubectl rollout undo deployment/gva-server --to-revision=5 -n gva-prod

# 或使用脚本
./scripts/rollback.sh prod
```

### 5.4 性能监控

#### 使用腾讯云监控

1. 访问[腾讯云监控控制台](https://console.cloud.tencent.com/monitor)
2. 查看TKE集群监控指标：
   - CPU使用率
   - 内存使用率
   - 网络流量
   - Pod状态

#### 配置告警（可选）

```bash
# 在腾讯云监控中配置告警策略
# 触发条件：
#   - CPU使用率 > 80%
#   - 内存使用率 > 85%
#   - Pod 异常重启
#   - 服务不可用
```

---

## 6. 常见问题

### 6.1 镜像拉取失败

**错误**: `ImagePullBackOff` 或 `ErrImagePull`

**解决方案**:

```bash
# 1. 检查镜像是否存在
# 访问腾讯云TCR控制台，查看镜像列表

# 2. 检查 imagePullSecret
kubectl get secret tcr-secret -n gva-dev

# 3. 如果不存在，重新创建
kubectl create secret docker-registry tcr-secret \
  --docker-server=xxx.tencentcloudcr.com \
  --docker-username=your-username \
  --docker-password=your-password \
  --namespace=gva-dev

# 4. 确保 Deployment 中配置了 imagePullSecrets
kubectl edit deployment gva-server -n gva-dev
# 添加：
# spec:
#   template:
#     spec:
#       imagePullSecrets:
#         - name: tcr-secret
```

### 6.2 Pod 一直 Pending

**可能原因**:
- 节点资源不足
- 镜像拉取失败
- 存储卷挂载失败

**解决方案**:

```bash
# 查看 Pod 详情
kubectl describe pod <pod-name> -n gva-dev

# 查看节点资源
kubectl top nodes

# 如果是资源不足，可以：
# 1. 在腾讯云TKE控制台添加节点
# 2. 或调整Pod资源请求
kubectl edit deployment gva-server -n gva-dev
```

### 6.3 服务无法访问

**检查步骤**:

```bash
# 1. 检查 Pod 是否运行
kubectl get pods -n gva-dev

# 2. 检查 Service
kubectl get svc -n gva-dev

# 3. 检查 LoadBalancer 是否分配了外部IP
kubectl describe svc gva-web -n gva-dev

# 4. 检查端口转发（临时测试）
kubectl port-forward svc/gva-web 8080:80 -n gva-dev
# 访问 http://localhost:8080

# 5. 检查安全组
# 在腾讯云控制台，确保TKE节点的安全组开放了相应端口
```

### 6.4 GitHub Actions 构建失败

**常见原因**:

1. **Secrets 未配置或错误**
   ```bash
   # 检查 GitHub Secrets 是否正确配置
   # Settings → Secrets → Actions
   ```

2. **Docker 登录失败**
   ```bash
   # 本地测试登录
   docker login xxx.tencentcloudcr.com \
     -u your-username \
     -p your-password
   ```

3. **kubeconfig 格式错误**
   ```bash
   # 重新生成 base64 编码
   cat ~/.kube/config-tencent | base64 -w 0
   ```

### 6.5 数据库连接失败

**解决方案**:

```bash
# 1. 检查数据库服务是否运行
kubectl get pods -n gva-dev

# 2. 检查 ConfigMap 配置
kubectl get configmap gva-server-config -n gva-dev -o yaml

# 3. 检查数据库连接配置
# 确保以下配置正确：
#   - mysql.host
#   - mysql.port
#   - mysql.username
#   - mysql.password
#   - mysql.database

# 4. 测试数据库连接（进入Pod）
kubectl exec -it <pod-name> -n gva-dev -- sh
# 在Pod内测试
ping mysql-service
nc -zv mysql-service 3306
```

---

## 📊 部署检查清单

### 部署前检查

- [ ] 腾讯云TCR已创建并配置
- [ ] 腾讯云TKE集群已创建
- [ ] GitHub Secrets 已全部配置
- [ ] Kubernetes配置文件已更新镜像地址
- [ ] imagePullSecrets 已配置
- [ ] 域名DNS已配置（如需要）

### 部署后验证

- [ ] Pod 状态全部为 Running
- [ ] Service 已分配外部IP
- [ ] 应用可以正常访问
- [ ] 健康检查通过
- [ ] 日志无异常错误
- [ ] 数据库连接正常

---

## 🎯 快速命令参考

```bash
# 部署相关
kubectl get pods -n gva-dev                    # 查看Pod
kubectl get svc -n gva-dev                     # 查看Service
kubectl logs -f deployment/gva-server -n gva-dev   # 查看日志
kubectl describe pod <pod-name> -n gva-dev     # 查看详情

# 更新部署
kubectl set image deployment/gva-server \
  gin-vue-admin-container=xxx.tencentcloudcr.com/gva/server:v1.0.0 \
  -n gva-prod

# 扩缩容
kubectl scale deployment gva-server --replicas=3 -n gva-prod

# 回滚
kubectl rollout undo deployment/gva-server -n gva-prod

# 重启
kubectl rollout restart deployment/gva-server -n gva-prod
```

---

## 🆘 获取帮助

### 文档资源

- [腾讯云TKE文档](https://cloud.tencent.com/document/product/457)
- [腾讯云TCR文档](https://cloud.tencent.com/document/product/1141)
- [Kubernetes官方文档](https://kubernetes.io/zh/docs/)
- [GitHub Actions文档](https://docs.github.com/cn/actions)

### 联系支持

- 腾讯云工单系统
- GitHub Issues
- 团队内部技术支持

---

## 🎉 恭喜！

你现在已经完成了腾讯云的CI/CD配置！

**下一步：推送代码到GitHub，观看自动化部署的魔法发生！** 🚀

```bash
git push origin develop
```

然后访问：`https://github.com/你的用户名/gin-vue-admin/actions`

---

**文档版本**: v1.0.0  
**更新时间**: 2025-10-17  
**适用范围**: 腾讯云TKE + TCR + GitHub Actions

