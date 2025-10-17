# ⚡ 快速开始 - 服务器部署版

> 3步配置，5分钟完成！

---

## ✅ 你的服务器信息（已确认）

- **服务器IP**: `119.29.95.149`
- **SSH用户**: `root`
- **已运行**: Docker 容器
- **部署方式**: Docker Compose

---

## 🎯 立即开始（3步）

### 步骤 1️⃣：配置 GitHub Secret（2分钟）

#### 1.1 打开 GitHub Secrets 页面

如果你的 GitHub 仓库是：`https://github.com/用户名/gin-vue-admin`

访问：
```
https://github.com/用户名/gin-vue-admin/settings/secrets/actions
```

#### 1.2 添加 SSH 密钥

点击 **"New repository secret"**

- **Name**: 输入 `SERVER_SSH_KEY`
- **Secret**: 粘贴以下内容（你的完整私钥）

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACD84jYWEqraE9+rb6uToRbGMHnxN9fgbXhdSLX79bpPHwAAAKAycg75MnIO
+QAAAAtzc2gtZWQyNTUxOQAAACD84jYWEqraE9+rb6uToRbGMHnxN9fgbXhdSLX79bpPHw
AAAEA6S7x5izDScoc1KdDCf/1jNa9lLCf0dEdoxMF74g33bPziNhYSqtoT36tvq5OhFsYw
efE31+BteF1Itfv1uk8fAAAAFnlvdXJfZW1haWxAZXhhbXBsZS5jb20BAgMEBQYH
-----END OPENSSH PRIVATE KEY-----
```

⚠️ **重要**：
- 必须包含 `-----BEGIN OPENSSH PRIVATE KEY-----` 开头
- 必须包含 `-----END OPENSSH PRIVATE KEY-----` 结尾
- 完整复制所有内容

点击 **"Add secret"** 保存。

---

### 步骤 2️⃣：准备服务器（1分钟）

打开终端，SSH 到服务器：

```bash
ssh root@119.29.95.149
```

运行以下命令：

```bash
# 创建部署目录
mkdir -p /opt/gin-vue-admin

# 检查 Docker（应该已安装）
docker --version
docker-compose --version

# 如果显示版本号，说明已安装 ✅
# 如果没有安装，运行：
# curl -fsSL https://get.docker.com | sh
```

---

### 步骤 3️⃣：推送代码触发部署（1分钟）

在你的本地项目目录运行：

```bash
cd /Users/ykmz/Desktop/哈雷彗星/gin-vue-admin

# 添加所有文件
git add .

# 提交
git commit -m "feat: 配置自动化部署到服务器"

# 推送（触发自动部署）
git push origin main
```

---

## 📊 观察部署

### 方法 1：在 GitHub 查看

```
https://github.com/你的用户名/gin-vue-admin/actions
```

你会看到工作流 **"部署到腾讯云服务器"** 正在运行 🚀

### 方法 2：在服务器查看

```bash
# SSH 到服务器
ssh root@119.29.95.149

# 实时查看容器
watch -n 1 docker ps

# 查看日志
cd /opt/gin-vue-admin/deploy/docker-compose
docker-compose logs -f
```

---

## 🌐 访问你的应用

部署完成后（约3-5分钟），访问：

- **前端**: http://119.29.95.149
- **后端API**: http://119.29.95.149:8888

---

## ✅ 验证部署成功

运行以下命令检查：

```bash
# SSH 到服务器
ssh root@119.29.95.149

# 查看容器状态（应该都是 Up）
docker ps

# 查看日志（应该无严重错误）
docker logs docker-compose-web
docker logs docker-compose-serv

# 测试访问
curl -I http://localhost:80
curl -I http://localhost:8888
```

如果都正常，恭喜你部署成功！🎉

---

## 🔄 日常使用

### 每次更新代码

```bash
# 1. 修改代码
# ... 编写代码 ...

# 2. 提交并推送
git add .
git commit -m "feat: 更新功能"
git push origin main

# 3. 等待自动部署（3-5分钟）

# 4. 刷新浏览器查看更新
```

就这么简单！✨

---

## 🛠️ 常用命令速查

### 服务器管理

```bash
# 连接服务器
ssh root@119.29.95.149

# 查看容器
docker ps

# 查看日志
docker logs -f docker-compose-web
docker logs -f docker-compose-serv

# 重启服务
cd /opt/gin-vue-admin/deploy/docker-compose
docker-compose restart

# 查看资源使用
docker stats
```

### Git 操作

```bash
# 查看状态
git status

# 查看远程仓库
git remote -v

# 查看提交历史
git log --oneline -10

# 推送到 GitHub
git push origin main
```

---

## 🐛 遇到问题？

### 问题 1：SSH 连接失败

**GitHub Actions 报错**：`Permission denied (publickey)`

**解决**：
1. 检查 GitHub Secret `SERVER_SSH_KEY` 是否正确配置
2. 确保复制了完整的私钥（包括开头和结尾）
3. 检查服务器 SSH 服务是否运行：`systemctl status sshd`

### 问题 2：容器无法访问

**检查步骤**：

```bash
# 1. 检查容器是否运行
docker ps

# 2. 检查端口
netstat -tlnp | grep :80
netstat -tlnp | grep :8888

# 3. 检查防火墙
ufw status

# 4. 检查腾讯云安全组
# 登录腾讯云控制台 → 云服务器 → 安全组
# 确保开放了 80 和 8888 端口
```

### 问题 3：部署失败

**查看详细日志**：
1. 访问 GitHub Actions 页面
2. 点击失败的工作流
3. 查看红色❌的步骤
4. 展开日志查看错误信息

**常见原因**：
- `docker-compose.yaml` 文件路径不对
- Docker 镜像构建失败
- 端口被占用

---

## 📞 获取帮助

如果遇到问题：

1. **查看文档**: [SERVER_DEPLOY_GUIDE.md](./SERVER_DEPLOY_GUIDE.md)
2. **查看日志**: GitHub Actions 日志 + 服务器容器日志
3. **检查状态**: `docker ps` + `docker logs`

---

## 🎉 恭喜！

你现在拥有了：

✅ **自动化部署** - 推送代码自动部署到服务器  
✅ **实时监控** - GitHub Actions 实时反馈部署状态  
✅ **简单维护** - SSH 随时查看和管理服务  
✅ **快速回滚** - Git revert + push 即可回滚  

---

**准备好了吗？现在就开始第1步！** 🚀

👉 [配置 GitHub Secret](#步骤-1️⃣配置-github-secret2分钟)

