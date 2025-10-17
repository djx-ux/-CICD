# 哈雷彗星后台管理系统 MCP 配置

## 📋 MCP (Model Context Protocol) 简介

MCP 是 Cursor AI 的模型上下文协议，允许为特定项目定制 AI 的行为和规则。通过 MCP 配置，我们可以确保 AI 生成的代码完全符合项目的开发规范。

## 📁 文件结构

```
.cursor/
├── mcp.json           # MCP 主配置文件
├── mcp-server.js      # MCP 服务器脚本
└── MCP_README.md      # 配置说明文档
```

## ⚙️ 配置文件说明

### 1. `mcp.json` - 主配置文件

包含以下主要配置节：

#### 项目配置 (`projectConfig`)
```json
{
  "name": "哈雷彗星后台管理系统",
  "version": "2.8.5",
  "techStack": {
    "frontend": "Vue 3.5.7",
    "build": "Vite 6.2.3",
    "ui": "Element Plus 2.10.2"
  }
}
```

#### 开发规则 (`developmentRules`)
```json
{
  "mandatory": {
    "useCompositionAPI": true,
    "useScriptSetup": true,
    "includeErrorHandling": true
  },
  "forbidden": {
    "optionsAPI": true,
    "directDOMManipulation": true
  }
}
```

#### 业务规则 (`businessRules`)
```json
{
  "inputRestriction": {
    "guildName": "英文字符和数字",
    "caseInsensitive": true,
    "duplicateCheck": true
  },
  "defaultValues": {
    "guildGroup": "默认分组"
  }
}
```

### 2. `mcp-server.js` - 服务器脚本

提供以下功能：

- **代码模板管理**: 预定义的 Vue 组件、API、Store 模板
- **代码验证**: 检查生成的代码是否符合规范
- **规则查询**: 提供项目特定的开发规则
- **动态生成**: 根据参数生成符合规范的代码

## 🚀 使用方法

### 1. 启用 MCP 服务器

在 Cursor 中，MCP 服务器会自动启动并加载配置。你可以通过以下方式验证：

```bash
# 手动测试 MCP 服务器
node .cursor/mcp-server.js
```

### 2. AI 代码生成

当你使用 Cursor AI 生成代码时，它会自动：

- 读取 `mcp.json` 中的项目规则
- 使用预定义的代码模板
- 验证生成的代码是否符合规范
- 应用项目特定的业务逻辑

### 3. 自定义提示

你可以在对话中引用 MCP 配置：

```
请根据 MCP 配置生成一个新的 Vue 组件
请按照项目的表单验证规则创建验证函数
根据业务规则实现公会名称的重复检查
```

## 🎯 核心特性

### 1. 技术栈约束

MCP 确保 AI 只使用项目批准的技术栈：

- ✅ Vue 3 Composition API
- ✅ Element Plus 组件
- ✅ UnoCSS 样式
- ✅ Pinia 状态管理
- ❌ Vue 2 Options API
- ❌ 其他 UI 框架

### 2. 代码规范强制

自动应用项目的代码规范：

```javascript
// ✅ 符合规范的代码
<script setup>
defineOptions({ name: 'ComponentName' })
const loading = ref(false)
</script>

// ❌ 不符合规范的代码
<script>
export default {
  name: 'ComponentName',
  data() { return { loading: false } }
}
</script>
```

### 3. 业务逻辑集成

自动应用项目特定的业务规则：

```javascript
// 自动生成的输入验证
const validateGuildName = (rule, value, callback) => {
  // 只允许英文字符和数字
  if (!/^[A-Za-z0-9]+$/.test(value)) {
    callback(new Error('只能包含英文字符和数字'))
    return
  }
  
  // 不区分大小写的重复检查
  const isDuplicate = existingNames.some(name => 
    name.toLowerCase() === value.toLowerCase()
  )
  
  if (isDuplicate) {
    callback(new Error('名称已存在'))
    return
  }
  
  callback()
}
```

### 4. 错误处理标准

自动包含完整的错误处理：

```javascript
// 自动生成的 API 调用
const handleSubmit = async () => {
  try {
    loading.value = true
    const res = await apiFunction(formData)
    
    if (res.code === 0) {
      ElMessage.success('操作成功')
    } else {
      ElMessage.error(res.msg || '操作失败')
    }
  } catch (error) {
    console.error('提交失败:', error)
    ElMessage.error('网络错误，请重试')
  } finally {
    loading.value = false
  }
}
```

## 🔧 自定义配置

### 1. 添加新的代码模板

在 `mcp-server.js` 中添加新模板：

```javascript
this.templates = {
  // 现有模板...
  
  customComponent: `
    // 你的自定义组件模板
  `
}
```

### 2. 修改业务规则

在 `mcp.json` 中更新业务规则：

```json
{
  "businessRules": {
    "inputRestriction": {
      "newField": "新的验证规则",
      "customPattern": "/^[A-Z][a-z]+$/"
    }
  }
}
```

### 3. 添加新的验证规则

在 `mcp-server.js` 的 `validateCode` 方法中添加：

```javascript
case 'custom':
  if (!code.includes('customRequirement')) {
    violations.push('必须包含自定义要求');
  }
  break;
```

## 📊 MCP 优势

### 1. 一致性保证
- 所有 AI 生成的代码都符合项目规范
- 减少代码审查中的规范性问题
- 提高代码质量和可维护性

### 2. 开发效率
- 自动应用最佳实践
- 减少重复的模板代码编写
- 快速生成符合规范的代码

### 3. 知识传承
- 将项目经验编码到 MCP 配置中
- 新团队成员快速上手
- 避免常见的开发陷阱

### 4. 业务逻辑集成
- 自动应用项目特定的业务规则
- 减少业务逻辑错误
- 提高代码的业务一致性

## 🐛 故障排除

### 1. MCP 服务器未启动

```bash
# 检查 Node.js 版本
node --version

# 手动启动服务器
node .cursor/mcp-server.js
```

### 2. 配置文件格式错误

```bash
# 验证 JSON 格式
node -e "console.log(JSON.parse(require('fs').readFileSync('.cursor/mcp.json', 'utf8')))"
```

### 3. AI 未遵循规则

- 检查 `.cursorrules` 文件是否存在
- 确认 MCP 配置是否正确加载
- 重启 Cursor 应用程序

## 📚 参考资料

- [Cursor MCP 官方文档](https://cursor.sh/docs/mcp)
- [Model Context Protocol 规范](https://modelcontextprotocol.io/)
- [项目开发规范文档](../DEVELOPMENT_STANDARDS.md)

## 🔄 更新日志

### v1.0.0 (2024-12)
- ✅ 初始 MCP 配置
- ✅ 基础代码模板
- ✅ 项目规则定义
- ✅ 业务逻辑集成

---

**最后更新**: 2024年12月  
**配置版本**: v1.0.0
