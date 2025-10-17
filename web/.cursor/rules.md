# Cursor AI 代码生成规则

## 项目信息
- 项目名称: 哈雷彗星后台管理系统
- 技术栈: Vue 3 + Vite + Element Plus + Pinia + UnoCSS
- 开发模式: Composition API + `<script setup>`

## 强制要求

### 1. Vue 组件结构
```vue
<template>
  <!-- 使用 UnoCSS 原子类 -->
  <div class="flex items-center p-4 bg-white rounded shadow">
    <el-form ref="formRef" :model="form" :rules="rules">
      <!-- 表单内容 -->
    </el-form>
  </div>
</template>

<script setup>
// 1. 导入依赖
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

// 2. 定义组件名
defineOptions({ name: 'ComponentName' })

// 3. 响应式数据
const loading = ref(false)
const form = reactive({})

// 4. 方法定义
const handleSubmit = async () => {
  try {
    loading.value = true
    // API 调用
  } catch (error) {
    ElMessage.error('操作失败')
  } finally {
    loading.value = false
  }
}

// 5. 生命周期
onMounted(() => {})
</script>

<style lang="scss" scoped>
// 复杂样式使用 SCSS
.custom-style {
  @apply flex items-center; // 可混合 UnoCSS
}
</style>
```

### 2. API 接口规范
```javascript
import service from '@/utils/request'

// 必须包含 JSDoc 注释
/**
 * 创建数据
 * @param {Object} data - 数据对象
 * @returns {Promise} API响应
 */
export const createData = (data) => {
  return service({
    url: '/api/create',
    method: 'post',
    data: data
  })
}
```

### 3. 表单验证规范
```javascript
// 自定义验证函数
const validateField = (rule, value, callback) => {
  if (!value) {
    callback(new Error('请输入必填字段'))
    return
  }
  // 具体验证逻辑
  callback()
}

// 验证规则
const rules = {
  fieldName: [
    { required: true, message: '请输入字段', trigger: 'blur' },
    { validator: validateField, trigger: 'blur' }
  ]
}
```

## 命名规范
- 组件名: PascalCase (`UserManagement`)
- 变量名: camelCase (`userInfo`, `isLoading`)
- 常量名: UPPER_SNAKE_CASE (`API_BASE_URL`)
- CSS类名: kebab-case (`.form-container`)
- API函数: 动词+名词 (`createUser`, `getUserList`)

## 样式规范
- 优先使用 UnoCSS 原子类
- 复杂样式使用 SCSS
- 响应式: 移动端优先
- 主题: 支持深色模式

## 错误处理
```javascript
// 必须包含完整错误处理
try {
  const res = await apiCall()
  if (res.code === 0) {
    ElMessage.success('操作成功')
  } else {
    ElMessage.error(res.msg || '操作失败')
  }
} catch (error) {
  console.error('API调用失败:', error)
  ElMessage.error('网络错误，请重试')
}
```

## 输入验证特殊规则
- 英文+数字: `/^[A-Za-z0-9]+$/`
- 不区分大小写比较: 转换为小写比较
- 实时输入过滤: 使用 `@input` 事件
- 默认值: 下拉选择优先选择"默认"选项

## 权限控制
```vue
<!-- 使用 v-auth 指令 -->
<el-button v-auth="[888, 889]">管理员可见</el-button>
<el-button v-auth.not="[888]">非管理员可见</el-button>
```

## 禁止使用
❌ Vue 2 Options API
❌ 直接操作 DOM
❌ 内联样式
❌ 全局变量
❌ 不安全的 v-html
❌ 未处理的 Promise 错误

## 必须使用
✅ Vue 3 Composition API
✅ `<script setup>` 语法
✅ TypeScript 类型注释 (JSDoc)
✅ 错误边界处理
✅ 响应式设计
✅ UnoCSS + SCSS
