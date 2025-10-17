# 📋 CI/CD 速查手册

## 🚀 快速命令

### 本地开发

```bash
# 启动所有服务
./scripts/local-dev.sh

# 停止所有服务
cd deploy/docker-compose && docker-compose down

# 查看日志
docker-compose logs -f server web
```

### 构建和推送

```bash
# 构建镜像
export TAG=v1.0.0
./scripts/build.sh

# 推送镜像
export DOCKER_USERNAME=your-username
export DOCKER_PASSWORD=your-password
./scripts/push.sh
```

### 部署

```bash
# 部署到开发环境
./scripts/deploy.sh dev

# 部署到测试环境
./scripts/deploy.sh staging

# 部署到生产环境
./scripts/deploy.sh prod v1.0.0
```

### 回滚

```bash
# 回滚到上一版本
./scripts/rollback.sh prod

# 回滚到指定版本
./scripts/rollback.sh prod 5
```

## 📊 Kubernetes 常用命令

### 查看资源

```bash
# 查看 Pods
kubectl get pods -n gva-prod

# 查看 Deployments
kubectl get deployments -n gva-prod

# 查看 Services
kubectl get svc -n gva-prod

# 查看所有资源
kubectl get all -n gva-prod
```

### 查看详情

```bash
# Pod 详情
kubectl describe pod <pod-name> -n gva-prod

# Deployment 详情
kubectl describe deployment gva-server -n gva-prod

# 查看事件
kubectl get events -n gva-prod --sort-by='.lastTimestamp'
```

### 查看日志

```bash
# 实时日志
kubectl logs -f deployment/gva-server -n gva-prod

# 最近100行
kubectl logs deployment/gva-server -n gva-prod --tail=100

# 所有容器日志
kubectl logs -f deployment/gva-server --all-containers=true -n gva-prod
```

### 执行命令

```bash
# 进入容器
kubectl exec -it <pod-name> -n gva-prod -- /bin/sh

# 执行单个命令
kubectl exec <pod-name> -n gva-prod -- ls -la
```

### 扩缩容

```bash
# 手动扩容
kubectl scale deployment/gva-server --replicas=3 -n gva-prod

# 查看扩容状态
kubectl get hpa -n gva-prod
```

## 🔄 部署历史

```bash
# 查看部署历史
kubectl rollout history deployment/gva-server -n gva-prod

# 查看特定版本
kubectl rollout history deployment/gva-server --revision=5 -n gva-prod

# 回滚到上一版本
kubectl rollout undo deployment/gva-server -n gva-prod

# 回滚到指定版本
kubectl rollout undo deployment/gva-server --to-revision=5 -n gva-prod

# 暂停部署
kubectl rollout pause deployment/gva-server -n gva-prod

# 恢复部署
kubectl rollout resume deployment/gva-server -n gva-prod
```

## 🐳 Docker 常用命令

### 镜像管理

```bash
# 构建镜像
docker build -t registry.cn-hangzhou.aliyuncs.com/gva/server:v1.0.0 .

# 推送镜像
docker push registry.cn-hangzhou.aliyuncs.com/gva/server:v1.0.0

# 拉取镜像
docker pull registry.cn-hangzhou.aliyuncs.com/gva/server:v1.0.0

# 查看镜像
docker images | grep gva

# 删除镜像
docker rmi registry.cn-hangzhou.aliyuncs.com/gva/server:v1.0.0

# 清理未使用的镜像
docker image prune -a
```

### 容器管理

```bash
# 启动容器
docker-compose up -d

# 停止容器
docker-compose down

# 重启容器
docker-compose restart server

# 查看日志
docker logs -f gva-server

# 进入容器
docker exec -it gva-server /bin/sh

# 查看容器资源使用
docker stats
```

## 🔍 故障排查

### CI 构建失败

```bash
# 1. 查看 GitHub Actions 日志
# 2. 本地复现
cd server && go test ./...
cd web && pnpm lint

# 3. 查看具体错误
docker build -t test-image .
```

### 部署失败

```bash
# 1. 查看 Pod 状态
kubectl get pods -n gva-prod

# 2. 查看 Pod 详情
kubectl describe pod <pod-name> -n gva-prod

# 3. 查看日志
kubectl logs <pod-name> -n gva-prod

# 4. 检查镜像
docker pull registry.cn-hangzhou.aliyuncs.com/gva/server:latest
docker run -it registry.cn-hangzhou.aliyuncs.com/gva/server:latest /bin/sh
```

### 服务不可用

```bash
# 1. 检查 Service
kubectl get svc -n gva-prod

# 2. 检查 Endpoints
kubectl get endpoints -n gva-prod

# 3. 检查 Ingress
kubectl get ingress -n gva-prod

# 4. 测试服务连接
kubectl run curl-test --image=curlimages/curl -it --rm -- curl http://gva-server:8888
```

## 📱 通知配置

### 钉钉机器人

```bash
# 测试钉钉通知
curl -X POST "https://oapi.dingtalk.com/robot/send?access_token=xxx" \
  -H 'Content-Type: application/json' \
  -d '{
    "msgtype": "text",
    "text": {
      "content": "测试通知"
    }
  }'
```

### 企业微信

```bash
# 测试企业微信通知
curl -X POST "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx" \
  -H 'Content-Type: application/json' \
  -d '{
    "msgtype": "text",
    "text": {
      "content": "测试通知"
    }
  }'
```

## 🔐 安全命令

### 密钥生成

```bash
# 生成 JWT Secret (32字符)
openssl rand -hex 16

# 生成 base64 编码
echo "your-secret" | base64

# 解码 base64
echo "encoded-string" | base64 -d
```

### Kubeconfig 编码

```bash
# 编码
cat ~/.kube/config | base64 > kubeconfig.b64

# 解码
cat kubeconfig.b64 | base64 -d > ~/.kube/config
```

## 📊 监控命令

### 资源使用

```bash
# 节点资源
kubectl top nodes

# Pod 资源
kubectl top pods -n gva-prod

# 查看资源限制
kubectl describe resourcequota -n gva-prod
```

### 性能测试

```bash
# HTTP 压测
ab -n 1000 -c 10 http://your-domain/api/health

# 使用 hey
hey -n 1000 -c 50 http://your-domain/api/health
```

## 🎯 常用场景

### 紧急回滚

```bash
# 一行命令回滚
./scripts/rollback.sh prod && echo "回滚完成"
```

### 查看实时日志

```bash
# 同时查看多个服务
kubectl logs -f deployment/gva-server -n gva-prod &
kubectl logs -f deployment/gva-web -n gva-prod &
```

### 更新配置

```bash
# 更新 ConfigMap
kubectl edit configmap app-config -n gva-prod

# 重启 Pod 应用新配置
kubectl rollout restart deployment/gva-server -n gva-prod
```

### 调试问题

```bash
# 临时启动调试 Pod
kubectl run debug-pod --image=alpine -it --rm -n gva-prod -- /bin/sh

# 端口转发到本地
kubectl port-forward svc/gva-server 8888:8888 -n gva-prod

# 复制文件
kubectl cp <pod-name>:/path/to/file ./local-file -n gva-prod
```

## 🎓 Tips

### 提高构建速度

```yaml
# 使用缓存
- uses: actions/cache@v4
  with:
    path: ~/.cache/go-build
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}

# 并行执行
jobs:
  frontend:
  backend:
  # 同时运行，不依赖
```

### 减少镜像大小

```dockerfile
# 使用 alpine 基础镜像
FROM alpine:latest

# 多阶段构建
FROM golang:alpine AS builder
FROM alpine:latest

# 清理缓存
RUN apk add --no-cache xxx && rm -rf /var/cache/apk/*
```

### 加速部署

```yaml
# 使用镜像拉取策略
imagePullPolicy: IfNotPresent

# 减少健康检查时间
livenessProbe:
  initialDelaySeconds: 10  # 从 30 减少到 10
```

---

**💡 提示**: 收藏本页面，随时查阅！



