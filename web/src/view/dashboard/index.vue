<template>
  <div class="dashboard-container">
   

    <!-- 主内容区域 -->
    <div class="main-content">
    

      <!-- 表单内容 -->
      <div class="form-container">
        <div class="form-card">
          <h2 class="form-title">新建公会</h2>
          
          <el-form
            ref="guildFormRef"
            :model="guildForm"
            :rules="guildRules"
            label-width="100px"
            class="guild-form"
          >
            <el-form-item label="UID" prop="uid">
              <el-input
                v-model="guildForm.uid"
                placeholder="请输入关联的管理员JID (支持英文、数字、下划线、横线)"
                class="form-input"
                @input="handleUidInput"
                maxlength="50"
              />
            </el-form-item>

            <el-form-item label="公会名称" prop="guildName">
              <el-input
                v-model="guildForm.guildName"
                placeholder="请输入公会名称 (仅支持英文字符和数字)"
                class="form-input"
                @input="handleGuildNameInput"
                maxlength="50"
              />
            </el-form-item>

            <el-form-item label="公会分组" prop="guildGroup">
              <el-select
                v-model="guildForm.guildGroup"
                placeholder="请选择一个分组"
                class="form-input"
              >
                <el-option
                  v-for="group in guildGroups"
                  :key="group.value"
                  :label="group.label"
                  :value="group.value"
                />
              </el-select>
            </el-form-item>

            <el-form-item label="公会邮箱" prop="guildEmail">
              <el-input
                v-model="guildForm.guildEmail"
                placeholder="例如：example@guild.com"
                class="form-input"
              />
            </el-form-item>

            <el-form-item label="联系方式" prop="contact">
              <el-input
                v-model="guildForm.contact"
                placeholder="请输入手机号码或其它联系方式"
                class="form-input"
              />
            </el-form-item>

            <el-form-item>
              <el-button
                type="primary"
                class="submit-btn"
                @click="submitForm"
                :loading="loading"
              >
                立即创建
              </el-button>
            </el-form-item>
          </el-form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { createGuild, getGuildGroups, getGuildNames } from '@/api/guild'

defineOptions({
  name: 'Dashboard'
})

// 响应式数据

const loading = ref(false)
const guildFormRef = ref()
const guildGroups = ref([])

// 表单数据
const guildForm = reactive({
  uid: '',
  guildName: '',
  guildGroup: '',
  guildEmail: '',
  contact: ''
})

// 已存在的公会名称列表 (用于重复检查)
const existingGuildNames = ref([])

// 自定义验证函数
const validateGuildName = (rule, value, callback) => {
  if (!value) {
    callback(new Error('请输入公会名称'))
    return
  }
  
  // 检查是否只包含英文字符和数字
  if (!/^[A-Za-z0-9]+$/.test(value)) {
    callback(new Error('公会名称只能包含英文字符和数字'))
    return
  }
  
  // 检查长度
  if (value.length < 2 || value.length > 50) {
    callback(new Error('公会名称长度在 2 到 50 个字符'))
    return
  }
  
  // 检查重复 (不区分大小写)
  const lowerValue = value.toLowerCase()
  const isDuplicate = existingGuildNames.value.some(name => 
    name.toLowerCase() === lowerValue
  )
  
  if (isDuplicate) {
    callback(new Error('公会名称已存在，请使用其他名称'))
    return
  }
  
  callback()
}

// 表单验证规则
const guildRules = {
  uid: [
    { required: true, message: '请输入管理员JID', trigger: 'blur' },
    { pattern: /^[A-Za-z0-9_-]+$/, message: 'JID只能包含英文字符、数字、下划线和横线', trigger: 'blur' }
  ],
  guildName: [
    { validator: validateGuildName, trigger: 'blur' }
  ],
  guildGroup: [
    { required: true, message: '请选择公会分组', trigger: 'change' }
  ],
  guildEmail: [
    { required: true, message: '请输入公会邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  contact: [
    { required: true, message: '请输入联系方式', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$|^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$/, message: '请输入正确的手机号或邮箱', trigger: 'blur' }
  ]
}

// 获取公会分组列表
const fetchGuildGroups = async () => {
  try {
    const res = await getGuildGroups()
    if (res.code === 0) {
      // 确保默认分组在第一位
      const groups = res.data || []
      const defaultGroup = { label: '默认分组', value: 'default' }
      
      // 检查是否已存在默认分组
      const hasDefault = groups.some(group => group.value === 'default')
      
      if (hasDefault) {
        guildGroups.value = groups
      } else {
        guildGroups.value = [defaultGroup, ...groups]
      }
    }
  } catch (error) {
    // 使用默认分组配置
    guildGroups.value = [
      { label: '默认分组', value: 'default' },
      { label: '战斗公会', value: 'battle' },
      { label: '商业公会', value: 'business' },
      { label: '探索公会', value: 'explore' },
      { label: '学术公会', value: 'academic' }
    ]
  }
  
  // 设置默认选中第一个分组（默认分组）
  if (guildGroups.value.length > 0 && !guildForm.guildGroup) {
    guildForm.guildGroup = guildGroups.value[0].value
  }
}

// 获取已存在的公会名称列表
const fetchExistingGuildNames = async () => {
  try {
    const res = await getGuildNames()
    if (res.code === 0) {
      existingGuildNames.value = res.data || []
    } else {
      // 使用模拟数据
      existingGuildNames.value = ['TestGuild', 'AdminGuild', 'VIP', 'Premium']
    }
  } catch (error) {
    console.error('获取公会名称列表失败:', error)
    // 使用模拟数据作为后备
    existingGuildNames.value = ['TestGuild', 'AdminGuild', 'VIP', 'Premium']
  }
}

// 提交表单
const submitForm = async () => {
  if (!guildFormRef.value) return
  
  await guildFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      
      try {
        const res = await createGuild(guildForm)
        
        if (res.code === 0) {
          ElMessage.success('公会创建成功！')
          resetForm()
        } else {
          ElMessage.error(res.msg || '创建失败，请重试')
        }
      } catch (error) {
        console.error('创建公会失败:', error)
        ElMessage.error('网络错误，请检查网络连接')
      } finally {
        loading.value = false
      }
    } else {
      ElMessage.error('请正确填写表单信息')
    }
  })
}

// 重置表单
const resetForm = () => {
  if (guildFormRef.value) {
    guildFormRef.value.resetFields()
  }
  
  // 重置为初始值
  Object.assign(guildForm, {
    uid: '',
    guildName: '',
    guildGroup: '',
    guildEmail: '',
    contact: ''
  })
}

// 输入限制函数 - 只允许英文字符和数字
const handleGuildNameInput = (event) => {
  const value = event.target.value
  // 过滤掉非英文字符和数字
  const filteredValue = value.replace(/[^A-Za-z0-9]/g, '')
  if (value !== filteredValue) {
    guildForm.guildName = filteredValue
    // 手动触发输入事件以更新视图
    event.target.value = filteredValue
  }
}

// UID输入限制 - 允许英文字符、数字、下划线和横线
const handleUidInput = (event) => {
  const value = event.target.value
  // 过滤掉不允许的字符
  const filteredValue = value.replace(/[^A-Za-z0-9_-]/g, '')
  if (value !== filteredValue) {
    guildForm.uid = filteredValue
    event.target.value = filteredValue
  }
}

// 关闭标签页
const closeTab = (tabName) => {
  console.log('关闭标签页:', tabName)
}

// 组件挂载时获取数据
onMounted(() => {
  fetchGuildGroups()
  fetchExistingGuildNames()
})
</script>

<style lang="scss" scoped>
.dashboard-container {
  display: flex;
  height: 100vh;
  background-color: #f5f5f5;
}



// 主内容区域
.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  background-color: white;
}

// 标签页头部
.tabs-header {
  border-bottom: 1px solid #e4e7ed;
  background-color: #fafafa;
  
  :deep(.custom-tabs) {
    .el-tabs__header {
      margin: 0;
      
      .el-tabs__nav-wrap {
        padding: 0 20px;
        
        .el-tabs__nav {
          border: none;
          
          .el-tabs__item {
            border: none;
            padding: 0 16px;
            height: 40px;
            line-height: 40px;
            color: #606266;
            background-color: transparent;
            
            &.is-active {
              color: #4285f4;
              background-color: white;
              border-radius: 4px 4px 0 0;
            }
            
            .tab-label {
              margin-right: 8px;
            }
            
            .close-icon {
              font-size: 12px;
              opacity: 0.6;
              transition: opacity 0.3s;
              
              &:hover {
                opacity: 1;
              }
            }
          }
        }
      }
      
      .el-tabs__active-bar {
        display: none;
      }
    }
  }
}

// 表单容器
.form-container {
  flex: 1;
  padding: 40px;
  overflow-y: auto;
}

.form-card {
  max-width: 800px;
  margin: 0 auto;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  padding: 40px;
}

.form-title {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 32px;
  padding-bottom: 16px;
  border-bottom: 2px solid #f0f0f0;
}

// 表单样式
.guild-form {
  :deep(.el-form-item) {
    margin-bottom: 24px;
    
    .el-form-item__label {
      font-weight: 500;
      color: #606266;
      line-height: 40px;
    }
    
    .el-form-item__content {
      .form-input {
        .el-input__wrapper {
          border-radius: 6px;
          box-shadow: 0 0 0 1px #dcdfe6;
          transition: all 0.3s;
          
          &:hover {
            box-shadow: 0 0 0 1px #c0c4cc;
          }
          
          &.is-focus {
            box-shadow: 0 0 0 1px #4285f4;
          }
          
          .el-input__inner {
            height: 40px;
            line-height: 40px;
            font-size: 14px;
            
            &::placeholder {
              color: #c0c4cc;
            }
          }
        }
        
        &.el-select {
          .el-select__wrapper {
            border-radius: 6px;
            box-shadow: 0 0 0 1px #dcdfe6;
            
            &:hover {
              box-shadow: 0 0 0 1px #c0c4cc;
            }
            
            &.is-focus {
              box-shadow: 0 0 0 1px #4285f4;
            }
          }
        }
      }
    }
  }
}

// 提交按钮
.submit-btn {
  background: linear-gradient(135deg, #4285f4 0%, #3367d6 100%);
  border: none;
  border-radius: 6px;
  padding: 12px 32px;
  font-size: 16px;
  font-weight: 500;
  height: auto;
  transition: all 0.3s ease;
  
  &:hover {
    background: linear-gradient(135deg, #3367d6 0%, #2851a3 100%);
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(66, 133, 244, 0.3);
  }
  
  &:active {
    transform: translateY(0);
  }
}

// 响应式设计
@media (max-width: 768px) {
  .dashboard-container {
    flex-direction: column;
  }
  
  .sidebar {
    width: 100%;
    height: auto;
    
    .nav-item {
      padding: 12px 16px;
    }
  }
  
  .form-container {
    padding: 20px;
  }
  
  .form-card {
    padding: 24px;
  }
}
</style>
