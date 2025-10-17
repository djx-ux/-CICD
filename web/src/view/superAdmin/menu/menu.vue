<template>
  <div class="menu-container">
    <div class="content-card">
      <!-- 头部操作区域 -->
      <div class="header-section">
        <el-select
          v-model="selectedGroup"
          placeholder="请选择分组查看详情"
          class="group-select"
          @change="handleGroupChange"
        >
          <el-option
            v-for="group in groupList"
            :key="group.value"
            :label="group.label"
            :value="group.value"
          />
        </el-select>
        
        <div class="action-buttons">
          <el-button 
            type="primary" 
            class="transfer-btn"
            :disabled="!hasSelection"
            @click="handleTransfer"
          >
            转移选中公会
          </el-button>
          <el-button 
            class="batch-add-btn"
            @click="handleBatchAdd"
          >
            批量添加公会
          </el-button>
        </div>
      </div>

      <!-- 数据表格 -->
      <el-table
        ref="tableRef"
        :data="tableData"
        row-key="ID"
        style="width: 100%"
        v-loading="loading"
        class="data-table"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column label="公会ID" prop="ID" min-width="150" />
        <el-table-column label="公会名称" min-width="200">
          <template #default="scope">
            {{ scope.row.meta?.title || scope.row.name || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="成立时间" prop="createdAt" min-width="200">
          <template #default="scope">
            {{ formatDate(scope.row.createdAt) }}
          </template>
        </el-table-column>
      </el-table>

      <!-- 空状态提示 -->
      <div v-if="!selectedGroup && !loading" class="empty-state">
        <div class="empty-icon">📋</div>
        <div class="empty-text">请先选择一个分组查看详情</div>
      </div>
    </div>

    <!-- 批量添加对话框 -->
    <el-dialog
      v-model="batchAddDialogVisible"
      title="批量添加公会"
      width="600px"
      class="custom-dialog"
    >
      <el-form
        ref="formRef"
        :model="formData"
        label-width="120px"
      >
        <el-form-item label="选择分组">
          <el-select v-model="formData.groupId" placeholder="请选择分组" style="width: 100%">
            <el-option
              v-for="group in groupList"
              :key="group.value"
              :label="group.label"
              :value="group.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="公会ID列表">
          <el-input
            v-model="formData.guildList"
            type="textarea"
            :rows="8"
            placeholder="请输入公会ID，每行一个，例如：&#10;1001&#10;1002&#10;1003"
          />
          <div class="form-tip">
            * 每行输入一个公会ID，系统将自动创建对应的公会
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="batchAddDialogVisible = false" class="cancel-btn">取消</el-button>
          <el-button type="primary" @click="handleBatchAddSubmit" class="confirm-btn">确定</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 转移对话框 -->
    <el-dialog
      v-model="transferDialogVisible"
      title="转移公会"
      width="500px"
      class="custom-dialog"
    >
      <el-form label-width="100px">
        <el-form-item label="目标分组">
          <el-select v-model="transferTargetGroup" placeholder="请选择目标分组" style="width: 100%">
            <el-option
              v-for="group in groupList"
              :key="group.value"
              :label="group.label"
              :value="group.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="已选择">
          <div class="selected-info">{{ selectedRows.length }} 个公会</div>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="transferDialogVisible = false" class="cancel-btn">取消</el-button>
          <el-button type="primary" @click="handleTransferSubmit" class="confirm-btn">确定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
defineOptions({
  name: 'Menu'
})

import { ref, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { getMenuList } from '@/api/menu'
import { getAuthorityList } from '@/api/authority'

// Mock 分组数据
const mockGroups = [
  { label: '默认分组', value: 101 },
  { label: 'ali', value: 102 },
  { label: 'xiaomi', value: 103 }
]

// Mock 公会数据（按分组）
const mockGuilds = {
  101: [
    { ID: 1001, name: '默认公会01', createdAt: '2024-01-15T10:30:00', meta: { title: '默认公会01' } },
    { ID: 1002, name: '默认公会02', createdAt: '2024-01-16T11:20:00', meta: { title: '默认公会02' } },
    { ID: 1003, name: '默认公会03', createdAt: '2024-01-17T14:15:00', meta: { title: '默认公会03' } }
  ],
  102: [
    { ID: 2001, name: 'ali公会01', createdAt: '2024-02-10T09:00:00', meta: { title: 'ali公会01' } },
    { ID: 2002, name: 'ali公会02', createdAt: '2024-02-15T10:30:00', meta: { title: 'ali公会02' } },
    { ID: 2003, name: 'ali公会03', createdAt: '2024-02-20T16:45:00', meta: { title: 'ali公会03' } },
    { ID: 2004, name: 'ali公会04', createdAt: '2024-02-25T12:20:00', meta: { title: 'ali公会04' } }
  ],
  103: [
    { ID: 3001, name: 'xiaomi公会01', createdAt: '2024-03-05T08:30:00', meta: { title: 'xiaomi公会01' } },
    { ID: 3002, name: 'xiaomi公会02', createdAt: '2024-03-10T11:15:00', meta: { title: 'xiaomi公会02' } },
    { ID: 3003, name: 'xiaomi公会03', createdAt: '2024-03-15T14:40:00', meta: { title: 'xiaomi公会03' } },
    { ID: 3004, name: 'xiaomi公会04', createdAt: '2024-03-20T10:10:00', meta: { title: 'xiaomi公会04' } },
    { ID: 3005, name: 'xiaomi公会05', createdAt: '2024-03-25T16:25:00', meta: { title: 'xiaomi公会05' } }
  ]
}

// 数据状态
const loading = ref(false)
const tableData = ref([])
const tableRef = ref(null)
const formRef = ref(null)

// 分组相关
const selectedGroup = ref('')
const groupList = ref([])

// 对话框状态
const batchAddDialogVisible = ref(false)
const transferDialogVisible = ref(false)

// 选中的行
const selectedRows = ref([])
const hasSelection = computed(() => selectedRows.value.length > 0)

// 转移目标分组
const transferTargetGroup = ref('')

// 表单数据
const formData = ref({
  groupId: '',
  guildList: ''
})

// 格式化日期
const formatDate = (date) => {
  if (!date) return '-'
  const d = new Date(date)
  return d.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 获取分组列表
const getGroupList = async () => {
  // 使用 Mock 数据
  setTimeout(() => {
    groupList.value = [...mockGroups]
  }, 300)
  
  // 实际 API 调用（暂时注释）
  // try {
  //   const res = await getAuthorityList({ page: 1, pageSize: 999 })
  //   if (res.code === 0) {
  //     groupList.value = (res.data.list || []).map(item => ({
  //       label: item.authorityName,
  //       value: item.authorityId
  //     }))
  //   }
  // } catch (error) {
  //   ElMessage.error('获取分组列表失败')
  // }
}

// 获取公会列表（基于选中的分组）
const getTableData = async () => {
  if (!selectedGroup.value) {
    tableData.value = []
    return
  }
  
  loading.value = true
  
  // 使用 Mock 数据
  setTimeout(() => {
    tableData.value = mockGuilds[selectedGroup.value] || []
    loading.value = false
  }, 500)
  
  // 实际 API 调用（暂时注释）
  // try {
  //   const res = await getMenuList({ 
  //     page: 1, 
  //     pageSize: 999,
  //     authorityId: selectedGroup.value 
  //   })
  //   if (res.code === 0) {
  //     tableData.value = res.data.list || []
  //   }
  // } catch (error) {
  //   ElMessage.error('获取公会列表失败')
  // } finally {
  //   loading.value = false
  // }
}

// 分组切换
const handleGroupChange = (value) => {
  selectedGroup.value = value
  selectedRows.value = []
  getTableData()
}

// 选中变化
const handleSelectionChange = (selection) => {
  selectedRows.value = selection
}

// 批量添加
const handleBatchAdd = () => {
  formData.value = {
    groupId: selectedGroup.value || '',
    guildList: ''
  }
  batchAddDialogVisible.value = true
}

// 批量添加提交
const handleBatchAddSubmit = () => {
  if (!formData.value.groupId) {
    ElMessage.warning('请选择分组')
    return
  }
  if (!formData.value.guildList.trim()) {
    ElMessage.warning('请输入公会ID')
    return
  }
  
  // Mock 批量添加
  const guildIds = formData.value.guildList.split('\n').filter(id => id.trim())
  const targetGroupGuilds = mockGuilds[formData.value.groupId] || []
  
  guildIds.forEach((id, index) => {
    const newId = Date.now() + index
    targetGroupGuilds.push({
      ID: newId,
      name: `公会_${id.trim()}`,
      createdAt: new Date().toISOString(),
      meta: { title: `公会_${id.trim()}` }
    })
  })
  
  mockGuilds[formData.value.groupId] = targetGroupGuilds
  
  ElMessage.success(`成功添加 ${guildIds.length} 个公会`)
  batchAddDialogVisible.value = false
  
  // 如果当前选中的就是目标分组，刷新列表
  if (selectedGroup.value === formData.value.groupId) {
    getTableData()
  }
}

// 转移
const handleTransfer = () => {
  if (!hasSelection.value) {
    ElMessage.warning('请先选择要转移的公会')
    return
  }
  transferTargetGroup.value = ''
  transferDialogVisible.value = true
}

// 转移提交
const handleTransferSubmit = () => {
  if (!transferTargetGroup.value) {
    ElMessage.warning('请选择目标分组')
    return
  }
  
  if (transferTargetGroup.value === selectedGroup.value) {
    ElMessage.warning('目标分组不能与当前分组相同')
    return
  }
  
  // Mock 转移
  const sourceGuilds = mockGuilds[selectedGroup.value] || []
  const targetGuilds = mockGuilds[transferTargetGroup.value] || []
  
  // 从源分组移除选中的公会
  const selectedIds = selectedRows.value.map(row => row.ID)
  mockGuilds[selectedGroup.value] = sourceGuilds.filter(guild => !selectedIds.includes(guild.ID))
  
  // 添加到目标分组
  selectedRows.value.forEach(row => {
    targetGuilds.push({ ...row })
  })
  mockGuilds[transferTargetGroup.value] = targetGuilds
  
  ElMessage.success(`已转移 ${selectedRows.value.length} 个公会`)
  transferDialogVisible.value = false
  selectedRows.value = []
  getTableData()
}

// 初始化
onMounted(() => {
  getGroupList()
})
</script>

<style scoped lang="scss">
.menu-container {
  padding: 24px;
  min-height: 100vh;

  .content-card {
    background: #fff;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    position: relative;

    .header-section {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 24px;
      gap: 16px;

      .group-select {
        flex: 0 0 350px;
        
        :deep(.el-input__wrapper) {
          border-radius: 8px;
          padding: 10px 16px;
          border: 1px solid #3b82f6;
          background-color: #fff;
        }

        :deep(.el-input__inner) {
          font-size: 14px;
          color: #1f2937;
        }
      }

      .action-buttons {
        display: flex;
        gap: 12px;

        .transfer-btn {
          padding: 10px 24px;
          border-radius: 8px;
          font-size: 14px;
          font-weight: 500;
          background-color: #3b82f6;
          border-color: #3b82f6;

          &:hover {
            background-color: #2563eb;
            border-color: #2563eb;
          }
        }

        .batch-add-btn {
          padding: 10px 24px;
          border-radius: 8px;
          font-size: 14px;
          font-weight: 500;
          background-color: #6b7280;
          color: #fff;
          border: none;

          &:hover {
            background-color: #4b5563;
          }
        }
      }
    }

    .data-table {
      :deep(.el-table__header) {
        th {
          background-color: #f9fafb;
          color: #374151;
          font-weight: 500;
          font-size: 14px;
          border-bottom: 1px solid #e5e7eb;
        }
      }

      :deep(.el-table__body) {
        tr {
          &:hover {
            background-color: #f9fafb;
          }
        }

        td {
          padding: 16px 0;
          color: #1f2937;
          font-size: 14px;
          border-bottom: 1px solid #f3f4f6;
        }
      }

      :deep(.el-checkbox__inner) {
        border-radius: 4px;
      }
    }

    .empty-state {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 400px;
      background-color: #f9fafb;
      border-radius: 8px;
      margin-top: 24px;

      .empty-icon {
        font-size: 64px;
        margin-bottom: 16px;
      }

      .empty-text {
        font-size: 16px;
        color: #9ca3af;
      }
    }
  }
}

.custom-dialog {
  :deep(.el-dialog__header) {
    padding: 20px 24px;
    border-bottom: 1px solid #f3f4f6;

    .el-dialog__title {
      font-size: 18px;
      font-weight: 500;
      color: #1f2937;
    }
  }

  :deep(.el-dialog__body) {
    padding: 24px;
  }

  .selected-info {
    padding: 8px 12px;
    background-color: #f3f4f6;
    border-radius: 6px;
    color: #374151;
    font-size: 14px;
  }

  .form-tip {
    margin-top: 8px;
    font-size: 12px;
    color: #6b7280;
    line-height: 1.5;
  }

  .dialog-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    padding: 16px 24px;
    border-top: 1px solid #f3f4f6;

    .cancel-btn {
      padding: 8px 20px;
      border-radius: 6px;
    }

    .confirm-btn {
      padding: 8px 20px;
      border-radius: 6px;
    }
  }
}

:deep(.el-table) {
  border-radius: 8px;
  overflow: hidden;
}

:deep(.el-select-dropdown) {
  border-radius: 8px;
}
</style>

