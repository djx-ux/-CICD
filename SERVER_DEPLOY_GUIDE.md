# 🚀 腾讯云服务器 CI/CD 部署指南

> 适用于：单台服务器部署（使用 Docker Compose）

---

## 📋 你的服务器信息

- **公网 IP**: `119.29.95.149`
- **用户名**: `root`
- **部署方式**: Docker Compose
- **已运行**: docker-compose-web, docker-compose-serv

---

## 🎯 3步完成配置（5分钟）

### 第1步：配置 GitHub Secrets（2分钟）

访问你的 GitHub 仓库设置页面：
```
https://github.com/你的用户名/gin-vue-admin/settings/secrets/actions
```

点击 **"New repository secret"**，添加以下 Secret：

#### SERVER_SSH_KEY

**Name**: `SERVER_SSH_KEY`

**Secret**: （你的私钥，完整内容）
```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACD84jYWEqraE9+rb6uToRbGMHnxN9fgbXhdSLX79bpPHwAAAKAycg75MnIO
+QAAAAtzc2gtZWQyNTUxOQAAACD84jYWEqraE9+rb6uToRbGMHnxN9fgbXhdSLX79bpPHw
AAAEA6S7x5izDScoc1KdDCf/1jNa9lLCf0dEdoxMF74g33bPziNhYSqtoT36tvq5OhFsYw
efE31+BteF1Itfv1uk8fAAAAFnlvdXJfZW1haWxAZXhhbXBsZS5jb20BAgMEBQYH
-----END OPENSSH PRIVATE KEY-----
```

**重要**：
- 包含开头的 `-----BEGIN OPENSSH PRIVATE KEY-----`
- 包含结尾的 `-----END OPENSSH PRIVATE KEY-----`
- 复制完整内容，不要遗漏任何字符

---

### 第2步：准备服务器环境（2分钟）

SSH 连接到你的服务器：

```bash
ssh root@119.29.95.149
```

确保已安装 Docker 和 Docker Compose：

```bash
# 检查 Docker
docker --version

# 检查 Docker Compose
docker-compose --version

# 如果没有安装，运行：
curl -fsSL https://get.docker.com | sh
```

创建部署目录：

```bash
# 创建部署目录
mkdir -p /opt/gin-vue-admin

# 设置权限
chmod 755 /opt/gin-vue-admin
```

---

### 第3步：推送代码触发部署（1分钟）

```bash
# 在你的本地项目目录
cd /Users/ykmz/Desktop/哈雷彗星/gin-vue-admin

# 确保代码已提交
git add .
git commit -m "feat: 配置服务器自动化部署"

# 推送到 GitHub
git push origin main
# 或推送到 develop 分支
# git push origin develop
```

---

## 📊 观察部署过程

### 在 GitHub 查看

1. 访问你的 GitHub Actions：
   ```
   https://github.com/你的用户名/gin-vue-admin/actions
   ```

2. 你会看到工作流 "部署到腾讯云服务器" 正在运行

3. 点击进入查看详细日志：
   - ✅ 代码检查和测试
   - ✅ SSH 连接
   - ✅ 同步代码
   - ✅ 构建镜像
   - ✅ 部署容器

### 在服务器查看

SSH 连接到服务器，实时查看部署：

```bash
# 连接到服务器
ssh root@119.29.95.149

# 查看容器状态
docker ps

# 查看实时日志
docker-compose -f /opt/gin-vue-admin/deploy/docker-compose/docker-compose.yaml logs -f

# 或查看特定容器日志
docker logs -f docker-compose-web
docker logs -f docker-compose-serv
```

---

## 🌐 访问你的应用

部署完成后，通过浏览器访问：

- **前端**: http://119.29.95.149
- **后端**: http://119.29.95.149:8888

---

## 🔄 部署流程图

```
开发者推送代码到 GitHub
         ↓
GitHub Actions 自动触发
         ↓
    代码检查和测试
         ↓
    SSH 连接到服务器
         ↓
    同步代码文件
         ↓
    构建 Docker 镜像
         ↓
    停止旧容器 → 启动新容器
         ↓
    验证部署状态
         ↓
    部署完成！🎉
```

---

## 🛠️ 常用运维命令

### 查看服务状态

```bash
# SSH 到服务器
ssh root@119.29.95.149

# 查看所有容器
docker ps -a

# 查看容器日志
docker logs -f docker-compose-web
docker logs -f docker-compose-serv

# 查看资源使用
docker stats
```

### 手动重启服务

```bash
# 进入项目目录
cd /opt/gin-vue-admin

# 使用 docker-compose
cd deploy/docker-compose

# 重启所有服务
docker-compose restart

# 重启单个服务
docker-compose restart web
docker-compose restart server

# 查看服务状态
docker-compose ps
```

### 手动部署（不通过 GitHub Actions）

```bash
# SSH 到服务器
ssh root@119.29.95.149

# 进入项目目录
cd /opt/gin-vue-admin/deploy/docker-compose

# 拉取最新代码（如果服务器上是 git 仓库）
# git pull

# 重新构建并启动
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# 查看日志
docker-compose logs -f
```

### 查看部署日志

```bash
# 查看容器日志（最近100行）
docker logs --tail 100 docker-compose-web
docker logs --tail 100 docker-compose-serv

# 实时查看日志
docker logs -f docker-compose-web

# 查看 docker-compose 日志
cd /opt/gin-vue-admin/deploy/docker-compose
docker-compose logs -f
```

---

## 🐛 故障排查

### 问题1：SSH 连接失败

**可能原因**：
- SSH 密钥配置错误
- 服务器防火墙阻止

**解决方法**：

```bash
# 本地测试 SSH 连接
ssh -i ~/.ssh/id_ed25519 root@119.29.95.149

# 检查服务器 SSH 服务
ssh root@119.29.95.149
systemctl status sshd

# 检查防火墙（如果使用）
ufw status
```

### 问题2：部署失败

**查看 GitHub Actions 日志**：
1. 访问 Actions 页面
2. 点击失败的工作流
3. 查看具体错误信息

**常见错误**：
- `Permission denied`: SSH 密钥权限问题
- `Cannot connect`: 网络连接问题
- `docker: command not found`: Docker 未安装

### 问题3：容器无法访问

**检查容器状态**：

```bash
# 查看容器是否运行
docker ps

# 如果容器退出了，查看日志
docker logs docker-compose-web
docker logs docker-compose-serv

# 检查端口占用
netstat -tulpn | grep :80
netstat -tulpn | grep :8888
```

**检查防火墙**：

```bash
# 检查端口是否开放
ufw status

# 开放端口（如果需要）
ufw allow 80
ufw allow 8888
```

**检查腾讯云安全组**：
1. 登录腾讯云控制台
2. 进入云服务器详情
3. 检查安全组规则
4. 确保开放了 80 和 8888 端口

### 问题4：镜像构建失败

```bash
# SSH 到服务器
ssh root@119.29.95.149

# 进入项目目录
cd /opt/gin-vue-admin

# 查看 docker-compose 文件
cat deploy/docker-compose/docker-compose.yaml

# 手动构建测试
cd deploy/docker-compose
docker-compose build --no-cache web
docker-compose build --no-cache server

# 查看构建日志
```

---

## 🔒 安全建议

### 1. 保护 SSH 密钥

✅ **推荐做法**：
- GitHub Secrets 中的密钥会自动加密
- 不要将私钥提交到代码仓库
- 定期更换 SSH 密钥

### 2. 配置防火墙

```bash
# 安装 ufw
apt-get install ufw

# 允许 SSH
ufw allow 22

# 允许 HTTP/HTTPS
ufw allow 80
ufw allow 443

# 允许后端 API
ufw allow 8888

# 启用防火墙
ufw enable
```

### 3. 配置腾讯云安全组

在腾讯云控制台配置安全组规则：
- 入站规则：
  - SSH (22) - 仅允许你的 IP
  - HTTP (80) - 允许所有
  - HTTPS (443) - 允许所有
  - 自定义 (8888) - 允许所有或特定 IP

---

## 📈 性能优化

### 1. Docker 镜像优化

```dockerfile
# 使用多阶段构建
# 减小镜像体积
# 参考项目中的 Dockerfile
```

### 2. 启用日志轮转

```bash
# 配置 Docker 日志轮转
cat > /etc/docker/daemon.json << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# 重启 Docker
systemctl restart docker
```

### 3. 配置 Nginx（可选）

如果需要反向代理和 HTTPS：

```bash
# 安装 Nginx
apt-get install nginx

# 配置反向代理
# 参考 Nginx 配置文档
```

---

## 🎓 日常使用流程

### 开发新功能

```bash
# 1. 在本地开发
# ... 编写代码 ...

# 2. 测试
npm run dev  # 前端
go run main.go  # 后端

# 3. 提交代码
git add .
git commit -m "feat: 新功能"

# 4. 推送触发自动部署
git push origin main

# 5. 等待 GitHub Actions 完成（约3-5分钟）

# 6. 访问 http://119.29.95.149 验证
```

### 紧急回滚

```bash
# 方法1：通过 Git 回滚
git revert HEAD
git push origin main
# 等待自动部署

# 方法2：直接在服务器操作
ssh root@119.29.95.149
cd /opt/gin-vue-admin/deploy/docker-compose
docker-compose down
docker-compose up -d  # 使用之前的镜像
```

---

## 📊 监控和日志

### 实时监控

```bash
# 查看容器资源使用
docker stats

# 查看系统资源
htop
# 或
top

# 查看磁盘使用
df -h

# 查看 Docker 磁盘使用
docker system df
```

### 日志管理

```bash
# 查看最近的日志
docker logs --tail 100 docker-compose-web

# 按时间过滤
docker logs --since 30m docker-compose-web

# 保存日志到文件
docker logs docker-compose-web > web.log 2>&1
```

---

## ✅ 验证清单

部署成功的标志：

- [ ] GitHub Actions 工作流显示绿色✓
- [ ] SSH 可以连接到服务器
- [ ] `docker ps` 显示容器运行中
- [ ] http://119.29.95.149 可以访问前端
- [ ] http://119.29.95.149:8888 可以访问后端
- [ ] 容器日志无严重错误

---

## 🎉 完成！

现在你的项目已经配置了自动化 CI/CD！

**后续操作**：
1. 每次推送代码到 main 或 develop 分支，都会自动部署
2. 可以在 GitHub Actions 查看部署历史
3. 可以随时 SSH 到服务器查看服务状态

**访问地址**：
- 前端：http://119.29.95.149
- 后端：http://119.29.95.149:8888

---

## 📞 需要帮助？

- 查看 GitHub Actions 日志
- 查看服务器容器日志：`docker logs -f container_name`
- 检查服务器状态：`ssh root@119.29.95.149`

---

**文档创建时间**: 2025-10-17  
**适用版本**: Docker Compose 部署方案  
**服务器**: 119.29.95.149

