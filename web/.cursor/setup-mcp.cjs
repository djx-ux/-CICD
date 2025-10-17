#!/usr/bin/env node

/**
 * 哈雷彗星后台管理系统 MCP 设置脚本
 * 自动配置 Cursor AI 的 MCP 服务器
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

class MCPSetup {
  constructor() {
    this.projectRoot = process.cwd();
    this.cursorConfigDir = path.join(os.homedir(), '.cursor');
    this.globalMCPConfig = path.join(this.cursorConfigDir, 'mcp.json');
    this.projectMCPConfig = path.join(this.projectRoot, '.cursor/mcp.json');
  }

  /**
   * 检查环境
   */
  checkEnvironment() {
    console.log('🔍 检查环境...');
    
    // 检查 Node.js 版本
    const nodeVersion = process.version;
    console.log(`✅ Node.js 版本: ${nodeVersion}`);
    
    // 检查项目根目录
    const packageJsonPath = path.join(this.projectRoot, 'package.json');
    if (!fs.existsSync(packageJsonPath)) {
      throw new Error('❌ 未找到 package.json，请在项目根目录运行此脚本');
    }
    
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
    console.log(`✅ 项目: ${packageJson.name || '哈雷彗星后台管理系统'}`);
    
    // 检查 Cursor 配置目录
    if (!fs.existsSync(this.cursorConfigDir)) {
      fs.mkdirSync(this.cursorConfigDir, { recursive: true });
      console.log(`✅ 创建 Cursor 配置目录: ${this.cursorConfigDir}`);
    }
    
    return true;
  }

  /**
   * 设置全局 MCP 配置
   */
  setupGlobalMCP() {
    console.log('⚙️ 设置全局 MCP 配置...');
    
    let globalConfig = { mcpServers: {} };
    
    // 读取现有配置
    if (fs.existsSync(this.globalMCPConfig)) {
      try {
        globalConfig = JSON.parse(fs.readFileSync(this.globalMCPConfig, 'utf8'));
      } catch (error) {
        console.warn('⚠️ 全局 MCP 配置格式错误，将创建新配置');
      }
    }
    
    // 添加项目 MCP 服务器
    const serverPath = path.join(this.projectRoot, '.cursor/mcp-server.cjs');
    globalConfig.mcpServers['halley-comet-admin'] = {
      command: 'node',
      args: [serverPath],
      env: {
        PROJECT_NAME: '哈雷彗星后台管理系统',
        PROJECT_PATH: this.projectRoot,
        NODE_ENV: 'development'
      }
    };
    
    // 写入全局配置
    fs.writeFileSync(this.globalMCPConfig, JSON.stringify(globalConfig, null, 2));
    console.log(`✅ 全局 MCP 配置已更新: ${this.globalMCPConfig}`);
  }

  /**
   * 验证项目 MCP 配置
   */
  validateProjectMCP() {
    console.log('🔍 验证项目 MCP 配置...');
    
    if (!fs.existsSync(this.projectMCPConfig)) {
      console.log('⚠️ 项目 MCP 配置文件不存在，但这是正常的');
      return true;
    }
    
    try {
      const config = JSON.parse(fs.readFileSync(this.projectMCPConfig, 'utf8'));
      console.log('✅ 项目 MCP 配置验证通过');
      return true;
    } catch (error) {
      console.warn(`⚠️ 项目 MCP 配置验证失败: ${error.message}`);
      return false;
    }
  }

  /**
   * 生成使用说明
   */
  generateUsageGuide() {
    const guide = `
# 🎉 MCP 配置完成！

## 📋 配置文件位置

- **全局配置**: ${this.globalMCPConfig}
- **项目配置**: ${this.projectMCPConfig}
- **规则文件**: ${path.join(this.projectRoot, '.cursorrules')}

## 🚀 使用方法

1. **重启 Cursor**: 关闭并重新打开 Cursor 应用程序
2. **验证加载**: 在 Cursor 中查看是否正确加载项目规则
3. **开始使用**: 使用 AI 生成代码时会自动应用项目规范

## 💡 示例提示

\`\`\`
请根据项目规范生成一个新的 Vue 组件
按照项目标准创建一个 API 接口函数
根据业务规则实现表单验证
创建一个符合项目规范的 Pinia Store
\`\`\`

## 🔧 已配置的规范

✅ Vue 3 Composition API + <script setup>
✅ Element Plus UI 组件
✅ UnoCSS + SCSS 样式方案
✅ Pinia 状态管理
✅ 完整的错误处理
✅ 表单验证规则
✅ 权限控制指令
✅ 响应式设计支持

## 📚 更多信息

- 详细开发规范: ${path.join(this.projectRoot, 'DEVELOPMENT_STANDARDS.md')}
- MCP 说明文档: ${path.join(this.projectRoot, '.cursor/MCP_README.md')}
- Cursor 规则文件: ${path.join(this.projectRoot, '.cursorrules')}
`;

    console.log(guide);
  }

  /**
   * 运行完整设置
   */
  async run() {
    try {
      console.log('🚀 开始设置哈雷彗星后台管理系统 MCP 配置...\n');
      
      // 1. 检查环境
      this.checkEnvironment();
      console.log('');
      
      // 2. 设置全局 MCP
      this.setupGlobalMCP();
      console.log('');
      
      // 3. 验证项目配置
      this.validateProjectMCP();
      console.log('');
      
      // 4. 生成使用说明
      this.generateUsageGuide();
      
      console.log('\n✅ MCP 配置设置完成！请重启 Cursor 以应用新配置。');
      
    } catch (error) {
      console.error('\n❌ 设置失败:', error.message);
      console.error('\n请检查错误信息并重试。');
      process.exit(1);
    }
  }
}

// 运行设置
if (require.main === module) {
  const setup = new MCPSetup();
  setup.run().catch(console.error);
}

module.exports = MCPSetup;
