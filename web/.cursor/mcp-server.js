#!/usr/bin/env node

/**
 * 哈雷彗星后台管理系统 MCP 服务器
 * 为 Cursor AI 提供项目特定的开发规则和上下文
 */

const fs = require('fs');
const path = require('path');

class HalleyCometMCPServer {
  constructor() {
    this.projectRoot = process.cwd();
    this.config = this.loadConfig();
    this.templates = this.loadTemplates();
  }

  /**
   * 加载项目配置
   */
  loadConfig() {
    try {
      const mcpConfigPath = path.join(this.projectRoot, '.cursor/mcp.json');
      return JSON.parse(fs.readFileSync(mcpConfigPath, 'utf8'));
    } catch (error) {
      console.error('无法加载 MCP 配置:', error.message);
      return {};
    }
  }

  /**
   * 加载代码模板
   */
  loadTemplates() {
    return {
      vueComponent: `<template>
  <div class="component-container">
    <!-- 使用 UnoCSS 原子类 -->
    <el-form
      ref="formRef"
      :model="formData"
      :rules="formRules"
      label-width="100px"
      class="form-content"
    >
      <!-- 表单内容 -->
    </el-form>
  </div>
</template>

<script setup>
// 1. 导入依赖
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

// 2. 定义组件选项
defineOptions({
  name: 'ComponentName'
})

// 3. Props 和 Emits
const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue'])

// 4. 响应式数据
const loading = ref(false)
const formRef = ref()
const formData = reactive({
  field1: '',
  field2: ''
})

// 5. 计算属性
const computedValue = computed(() => {
  return formData.field1 + formData.field2
})

// 6. 方法定义
const handleSubmit = async () => {
  try {
    loading.value = true
    
    // API 调用
    const res = await apiFunction(formData)
    
    if (res.code === 0) {
      ElMessage.success('操作成功')
      emit('update:modelValue', res.data)
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

// 7. 生命周期
onMounted(() => {
  // 初始化逻辑
})
</script>

<style lang="scss" scoped>
.component-container {
  @apply p-4 bg-white rounded shadow;
  
  .form-content {
    // 复杂样式使用 SCSS
    .custom-element {
      background: linear-gradient(135deg, #4285f4 0%, #3367d6 100%);
      transition: all 0.3s ease;
      
      &:hover {
        transform: translateY(-2px);
      }
    }
  }
}

// 响应式设计
@media (max-width: 768px) {
  .component-container {
    @apply p-2;
  }
}
</style>`,

      apiFunction: `import service from '@/utils/request'

/**
 * 创建数据
 * @param {Object} data - 数据对象
 * @param {string} data.name - 名称
 * @param {string} data.type - 类型
 * @returns {Promise<ApiResponse>} API响应
 */
// @Summary 创建数据
// @Produce application/json
// @Param data body {name:"string",type:"string"}
// @Router /api/create [post]
export const createData = (data) => {
  return service({
    url: '/api/create',
    method: 'post',
    data: data
  })
}`,

      piniaStore: `import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { apiFunction } from '@/api/module'

/**
 * 数据状态管理
 */
export const useDataStore = defineStore('data', () => {
  // 状态定义
  const dataList = ref([])
  const loading = ref(false)
  const currentData = ref(null)
  
  // 计算属性
  const dataCount = computed(() => dataList.value.length)
  const hasData = computed(() => dataList.value.length > 0)
  
  // 方法定义
  const fetchData = async () => {
    try {
      loading.value = true
      const res = await apiFunction()
      
      if (res.code === 0) {
        dataList.value = res.data
      }
    } catch (error) {
      console.error('获取数据失败:', error)
    } finally {
      loading.value = false
    }
  }
  
  const addData = (data) => {
    dataList.value.push(data)
  }
  
  const removeData = (id) => {
    const index = dataList.value.findIndex(item => item.id === id)
    if (index > -1) {
      dataList.value.splice(index, 1)
    }
  }
  
  const clearData = () => {
    dataList.value = []
    currentData.value = null
  }
  
  return {
    // 状态
    dataList,
    loading,
    currentData,
    
    // 计算属性
    dataCount,
    hasData,
    
    // 方法
    fetchData,
    addData,
    removeData,
    clearData
  }
}, {
  persist: {
    key: 'data-store',
    storage: localStorage,
    paths: ['dataList', 'currentData']
  }
})`,

      formValidation: `// 自定义验证函数
const validateField = (rule, value, callback) => {
  if (!value) {
    callback(new Error('请输入必填字段'))
    return
  }
  
  // 英文字符和数字验证
  if (!/^[A-Za-z0-9]+$/.test(value)) {
    callback(new Error('只能包含英文字符和数字'))
    return
  }
  
  // 长度验证
  if (value.length < 2 || value.length > 50) {
    callback(new Error('长度在2-50个字符'))
    return
  }
  
  // 重复检查 (不区分大小写)
  const isDuplicate = existingNames.some(name => 
    name.toLowerCase() === value.toLowerCase()
  )
  
  if (isDuplicate) {
    callback(new Error('名称已存在，请使用其他名称'))
    return
  }
  
  callback()
}

// 表单验证规则
const formRules = {
  fieldName: [
    { required: true, message: '请输入字段', trigger: 'blur' },
    { validator: validateField, trigger: 'blur' }
  ]
}`
    };
  }

  /**
   * 获取项目规则
   */
  getProjectRules() {
    return {
      techStack: this.config.projectConfig?.techStack || {},
      codeStandards: this.config.projectConfig?.codeStandards || {},
      businessRules: this.config.projectConfig?.businessRules || {},
      developmentRules: this.config.developmentRules || {}
    };
  }

  /**
   * 获取代码模板
   */
  getTemplate(templateName) {
    return this.templates[templateName] || '';
  }

  /**
   * 验证代码是否符合规范
   */
  validateCode(code, type) {
    const rules = this.getProjectRules();
    const violations = [];

    switch (type) {
      case 'vue':
        if (!code.includes('<script setup>')) {
          violations.push('必须使用 <script setup> 语法');
        }
        if (!code.includes('defineOptions')) {
          violations.push('必须使用 defineOptions 定义组件名');
        }
        if (code.includes('export default {')) {
          violations.push('禁止使用 Options API');
        }
        break;

      case 'api':
        if (!code.includes('/**')) {
          violations.push('API函数必须包含 JSDoc 注释');
        }
        if (!code.includes('@Summary')) {
          violations.push('API函数必须包含 Swagger 注释');
        }
        break;

      case 'store':
        if (!code.includes('defineStore')) {
          violations.push('必须使用 Pinia defineStore');
        }
        if (code.includes('export default')) {
          violations.push('Store 必须使用命名导出');
        }
        break;
    }

    return {
      isValid: violations.length === 0,
      violations
    };
  }

  /**
   * 生成符合规范的代码
   */
  generateCode(type, options = {}) {
    const template = this.getTemplate(type);
    
    if (!template) {
      throw new Error(`未找到 ${type} 类型的模板`);
    }

    // 根据选项替换模板中的占位符
    let code = template;
    
    Object.entries(options).forEach(([key, value]) => {
      const placeholder = new RegExp(`{{${key}}}`, 'g');
      code = code.replace(placeholder, value);
    });

    return code;
  }

  /**
   * 启动 MCP 服务器
   */
  start() {
    console.log('🚀 哈雷彗星后台管理系统 MCP 服务器已启动');
    console.log('📋 项目配置:', this.config.projectConfig?.name || '未知项目');
    console.log('🔧 技术栈:', Object.values(this.config.projectConfig?.techStack || {}).join(', '));
    
    // 监听标准输入，处理 MCP 协议消息
    process.stdin.on('data', (data) => {
      try {
        const message = JSON.parse(data.toString());
        this.handleMessage(message);
      } catch (error) {
        console.error('处理消息失败:', error.message);
      }
    });
  }

  /**
   * 处理 MCP 消息
   */
  handleMessage(message) {
    const { method, params } = message;

    switch (method) {
      case 'getProjectRules':
        this.sendResponse(message.id, this.getProjectRules());
        break;

      case 'getTemplate':
        this.sendResponse(message.id, this.getTemplate(params.templateName));
        break;

      case 'validateCode':
        this.sendResponse(message.id, this.validateCode(params.code, params.type));
        break;

      case 'generateCode':
        try {
          const code = this.generateCode(params.type, params.options);
          this.sendResponse(message.id, { code });
        } catch (error) {
          this.sendError(message.id, error.message);
        }
        break;

      default:
        this.sendError(message.id, `未知方法: ${method}`);
    }
  }

  /**
   * 发送响应
   */
  sendResponse(id, result) {
    const response = {
      jsonrpc: '2.0',
      id,
      result
    };
    
    process.stdout.write(JSON.stringify(response) + '\n');
  }

  /**
   * 发送错误
   */
  sendError(id, message) {
    const response = {
      jsonrpc: '2.0',
      id,
      error: {
        code: -1,
        message
      }
    };
    
    process.stdout.write(JSON.stringify(response) + '\n');
  }
}

// 启动服务器
if (require.main === module) {
  const server = new HalleyCometMCPServer();
  server.start();
}

module.exports = HalleyCometMCPServer;
