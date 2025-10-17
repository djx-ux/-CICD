#!/bin/bash

# ============================================
# 一键部署脚本
# ============================================

set -e

echo "=========================================="
echo "🚀 开始一键部署流程"
echo "=========================================="
echo ""

# 检查 GitHub Secret
echo "⚠️  重要提醒："
echo "请确保已在 GitHub 配置 Secret: SERVER_SSH_KEY"
echo "访问：https://github.com/djx-ux/-CICD/settings/secrets/actions"
echo ""
read -p "已配置 SERVER_SSH_KEY? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "请先配置 SERVER_SSH_KEY，然后重新运行此脚本"
    exit 1
fi

echo ""
echo "📦 添加文件到 Git..."
git add .

echo ""
echo "💾 提交更改..."
git commit -m "fix: 彻底修复部署问题 - 使用简化工作流"

echo ""
echo "🚀 推送到 GitHub..."
git push origin main

echo ""
echo "=========================================="
echo "✅ 推送成功！"
echo "=========================================="
echo ""
echo "📊 下一步："
echo ""
echo "1. 访问 GitHub Actions 查看部署进度："
echo "   https://github.com/djx-ux/-CICD/actions"
echo ""
echo "2. 等待 3-5 分钟，部署完成后访问："
echo "   前端：http://119.29.95.149:8080"
echo "   后端：http://119.29.95.149:8888"
echo ""
echo "3. 验证服务器："
echo "   ssh root@119.29.95.149"
echo "   docker ps"
echo ""
echo "🎉 部署流程已启动！"
echo ""

