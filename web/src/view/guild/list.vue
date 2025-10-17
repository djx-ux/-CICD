<template>
  <div class="guild-list-container">
    <div class="content-card">
      <!-- 搜索条件区域 -->
      <div class="search-section">
        <el-form :model="searchForm" inline class="search-form">
          <el-form-item label="公会ID">
            <el-input
              v-model="searchForm.guildId"
              placeholder="请输入公会ID"
              clearable
              class="search-input"
            />
          </el-form-item>
          
          <el-form-item label="公会名称">
            <el-input
              v-model="searchForm.guildName"
              placeholder="请输入公会名称"
              clearable
              class="search-input"
            />
          </el-form-item>
          
          <el-form-item label="公会长ID">
            <el-input
              v-model="searchForm.leaderId"
              placeholder="请输入公会长ID"
              clearable
              class="search-input"
            />
          </el-form-item>
          
          <el-form-item label="公会分组">
            <el-select
              v-model="searchForm.groupId"
              placeholder="全部分组"
              clearable
              class="search-select"
            >
              <el-option label="全部分组" value="" />
              <el-option
                v-for="group in groupOptions"
                :key="group.value"
                :label="group.label"
                :value="group.value"
              />
            </el-select>
          </el-form-item>
          
          <el-form-item label="公会状态">
            <el-select
              v-model="searchForm.status"
              placeholder="全部状态"
              clearable
              class="search-select"
            >
              <el-option label="全部状态" value="" />
              <el-option
                v-for="status in statusOptions"
                :key="status.value"
                :label="status.label"
                :value="status.value"
              />
            </el-select>
          </el-form-item>
          
          <el-form-item>
            <el-button type="primary" @click="handleSearch" class="search-btn">
              查询
            </el-button>
            <el-button @click="handleReset" class="reset-btn">
              重置
            </el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 数据表格 -->
      <el-table
        ref="tableRef"
        :data="tableData"
        v-loading="loading"
        class="data-table"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column label="公会ID" prop="guildId" min-width="100" />
        <el-table-column label="公会名称" prop="guildName" min-width="150" />
        <el-table-column label="公会长ID" prop="leaderId" min-width="120" />
        <el-table-column label="公会分组" prop="groupName" min-width="120" />
        <el-table-column label="公会状态" min-width="120">
          <template #default="scope">
            <el-tag
              :type="getStatusType(scope.row.status)"
              class="status-tag"
              @click="handleStatusClick(scope.row)"
            >
              {{ getStatusLabel(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" prop="createdAt" min-width="180">
          <template #default="scope">
            {{ formatDate(scope.row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" align="center" fixed="right">
          <template #default="scope">
            <el-button
              class="edit-btn"
              :disabled="scope.row.status === 'removed' || scope.row.status === 'expired'"
              @click="handleEdit(scope.row)"
            >
              编辑
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-section">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.pageSize"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSearch"
          @current-change="handleSearch"
        />
      </div>
    </div>

    <!-- 编辑公会对话框 -->
    <el-dialog
      v-model="editDialogVisible"
      title="编辑公会信息"
      width="600px"
      class="custom-dialog"
      @close="handleDialogClose"
    >
      <el-form
        ref="editFormRef"
        :model="editForm"
        :rules="editRules"
        label-width="100px"
      >
        <el-form-item label="公会ID" prop="guildId">
          <el-input v-model="editForm.guildId" disabled />
        </el-form-item>
        <el-form-item label="公会名称" prop="guildName">
          <el-input
            v-model="editForm.guildName"
            placeholder="请输入公会名称"
            maxlength="50"
            show-word-limit
          />
        </el-form-item>
        <el-form-item label="公会长ID" prop="leaderId">
          <el-input
            v-model="editForm.leaderId"
            placeholder="请输入公会长ID"
          />
        </el-form-item>
        <el-form-item label="公会分组" prop="groupId">
          <el-select
            v-model="editForm.groupId"
            placeholder="请选择公会分组"
            style="width: 100%"
          >
            <el-option
              v-for="group in groupOptions"
              :key="group.value"
              :label="group.label"
              :value="group.value"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="editDialogVisible = false" class="cancel-btn">取消</el-button>
          <el-button type="primary" @click="handleEditSubmit" class="confirm-btn">确定</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 修改状态对话框 -->
    <el-dialog
      v-model="statusDialogVisible"
      title="修改公会状态"
      width="500px"
      class="custom-dialog"
      @close="handleDialogClose"
    >
      <el-form label-width="100px">
        <el-form-item label="公会名称">
          <div class="info-text">{{ currentGuild?.guildName }}</div>
        </el-form-item>
        <el-form-item label="当前状态">
          <el-tag :type="getStatusType(currentGuild?.status)">
            {{ getStatusLabel(currentGuild?.status) }}
          </el-tag>
        </el-form-item>
        <el-form-item label="修改为" required>
          <el-select
            v-model="newStatus"
            placeholder="请选择新状态"
            style="width: 100%"
          >
            <el-option
              v-for="status in getAvailableStatuses(currentGuild?.status)"
              :key="status.value"
              :label="status.label"
              :value="status.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input
            v-model="statusRemark"
            type="textarea"
            :rows="3"
            placeholder="请输入修改原因（可选）"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="statusDialogVisible = false" class="cancel-btn">取消</el-button>
          <el-button type="primary" @click="handleStatusSubmit" class="confirm-btn">确定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
defineOptions({
  name: 'GuildList'
})

import { ref, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

// ==================== Mock 数据 ====================
const mockGuilds = [
  {
    id: 1,
    guildId: '1001',
    guildName: '待审核公会A',
    leaderId: 'leader_001',
    groupId: 101,
    groupName: '默认分组',
    status: 'pending',
    createdAt: '2023-08-01T10:30:00'
  },
  {
    id: 2,
    guildId: '3001',
    guildName: '阿里系-公会壹号',
    leaderId: 'leader_ali_1',
    groupId: 102,
    groupName: 'ali',
    status: 'approved',
    createdAt: '2022-08-10T14:20:00'
  },
  {
    id: 3,
    guildId: '4001',
    guildName: '小米系-公会甲',
    leaderId: 'leader_xm_1',
    groupId: 103,
    groupName: 'xiaomi',
    status: 'testing',
    createdAt: '2023-05-30T09:15:00'
  },
  {
    id: 4,
    guildId: '4002',
    guildName: '已被回公会B',
    leaderId: 'leader_xm_2',
    groupId: 103,
    groupName: 'xiaomi',
    status: 'removed',
    createdAt: '2023-06-15T11:45:00'
  },
  {
    id: 5,
    guildId: '3002',
    guildName: '已移除公会C',
    leaderId: 'leader_ali_2',
    groupId: 102,
    groupName: 'ali',
    status: 'expired',
    createdAt: '2022-09-01T16:30:00'
  },
  {
    id: 6,
    guildId: '1002',
    guildName: '待审核公会D',
    leaderId: 'leader_002',
    groupId: 101,
    groupName: '默认分组',
    status: 'pending',
    createdAt: '2023-08-05T13:20:00'
  },
  {
    id: 7,
    guildId: '4003',
    guildName: '小米系-公会Z',
    leaderId: 'leader_xm_3',
    groupId: 103,
    groupName: 'xiaomi',
    status: 'approved',
    createdAt: '2023-07-01T10:10:00'
  }
]

// 分组选项
const groupOptions = [
  { label: '默认分组', value: 101 },
  { label: 'ali', value: 102 },
  { label: 'xiaomi', value: 103 }
]

// 状态选项
const statusOptions = [
  { label: '待审核', value: 'pending' },
  { label: '已通过', value: 'approved' },
  { label: '已禁用', value: 'disabled' },
  { label: '已移除', value: 'removed' },
  { label: '已过期', value: 'expired' },
  { label: '测试中', value: 'testing' }
]

// ==================== 数据状态 ====================
const loading = ref(false)
const tableData = ref([])
const tableRef = ref(null)
const selectedRows = ref([])

// 搜索表单
const searchForm = ref({
  guildId: '',
  guildName: '',
  leaderId: '',
  groupId: '',
  status: ''
})

// 分页
const pagination = ref({
  page: 1,
  pageSize: 10,
  total: 0
})

// 编辑对话框
const editDialogVisible = ref(false)
const editFormRef = ref(null)
const editForm = ref({
  id: null,
  guildId: '',
  guildName: '',
  leaderId: '',
  groupId: ''
})

// 状态修改对话框
const statusDialogVisible = ref(false)
const currentGuild = ref(null)
const newStatus = ref('')
const statusRemark = ref('')

// 表单验证规则
const editRules = {
  guildName: [
    { required: true, message: '请输入公会名称', trigger: 'blur' }
  ],
  leaderId: [
    { required: true, message: '请输入公会长ID', trigger: 'blur' }
  ],
  groupId: [
    { required: true, message: '请选择公会分组', trigger: 'change' }
  ]
}

// ==================== 工具函数 ====================
// 格式化日期
const formatDate = (date) => {
  if (!date) return '-'
  const d = new Date(date)
  return d.toISOString().split('T')[0]
}

// 获取状态类型（Element Plus Tag）
const getStatusType = (status) => {
  const typeMap = {
    'pending': '',           // 默认蓝色
    'approved': 'success',   // 绿色
    'testing': 'warning',    // 橙色
    'disabled': 'info',      // 灰色
    'removed': 'danger',     // 红色
    'expired': 'info'        // 灰色
  }
  return typeMap[status] || ''
}

// 获取状态标签
const getStatusLabel = (status) => {
  const labelMap = {
    'pending': '待审核',
    'approved': '已通过',
    'testing': '已禁用',
    'disabled': '已禁用',
    'removed': '已移除',
    'expired': '已过期'
  }
  return labelMap[status] || status
}

// 获取可用的状态转换选项
const getAvailableStatuses = (currentStatus) => {
  // 根据当前状态返回可以修改的状态
  const statusFlow = {
    'pending': ['approved', 'removed'],           // 待审核 → 通过/移除
    'approved': ['disabled', 'removed'],          // 已通过 → 禁用/移除
    'testing': ['approved', 'removed'],           // 测试中 → 通过/移除
    'disabled': ['approved'],                     // 已禁用 → 通过
    'removed': [],                                // 已移除 → 不可操作
    'expired': []                                 // 已过期 → 不可操作
  }
  
  const availableStatuses = statusFlow[currentStatus] || []
  return statusOptions.filter(opt => availableStatuses.includes(opt.value))
}

// ==================== 数据加载 ====================
// 获取公会列表
const getTableData = () => {
  loading.value = true
  
  // 模拟 API 延迟
  setTimeout(() => {
    // 筛选数据
    let filteredData = [...mockGuilds]
    
    // 按搜索条件过滤
    if (searchForm.value.guildId) {
      filteredData = filteredData.filter(item => 
        item.guildId.includes(searchForm.value.guildId)
      )
    }
    if (searchForm.value.guildName) {
      filteredData = filteredData.filter(item => 
        item.guildName.includes(searchForm.value.guildName)
      )
    }
    if (searchForm.value.leaderId) {
      filteredData = filteredData.filter(item => 
        item.leaderId.includes(searchForm.value.leaderId)
      )
    }
    if (searchForm.value.groupId) {
      filteredData = filteredData.filter(item => 
        item.groupId === searchForm.value.groupId
      )
    }
    if (searchForm.value.status) {
      filteredData = filteredData.filter(item => 
        item.status === searchForm.value.status
      )
    }
    
    // 分页处理
    pagination.value.total = filteredData.length
    const start = (pagination.value.page - 1) * pagination.value.pageSize
    const end = start + pagination.value.pageSize
    tableData.value = filteredData.slice(start, end)
    
    loading.value = false
  }, 500)
}

// ==================== 事件处理 ====================
// 搜索
const handleSearch = () => {
  pagination.value.page = 1
  getTableData()
}

// 重置
const handleReset = () => {
  searchForm.value = {
    guildId: '',
    guildName: '',
    leaderId: '',
    groupId: '',
    status: ''
  }
  pagination.value.page = 1
  getTableData()
}

// 选中变化
const handleSelectionChange = (selection) => {
  selectedRows.value = selection
}

// 编辑公会
const handleEdit = (row) => {
  // 检查是否可以编辑
  if (row.status === 'removed' || row.status === 'expired') {
    ElMessage.warning('该公会已移除或过期，无法编辑')
    return
  }
  
  editForm.value = {
    id: row.id,
    guildId: row.guildId,
    guildName: row.guildName,
    leaderId: row.leaderId,
    groupId: row.groupId
  }
  editDialogVisible.value = true
}

// 编辑提交
const handleEditSubmit = () => {
  editFormRef.value.validate((valid) => {
    if (valid) {
      // Mock 更新
      const index = mockGuilds.findIndex(item => item.id === editForm.value.id)
      if (index !== -1) {
        const groupName = groupOptions.find(g => g.value === editForm.value.groupId)?.label || ''
        mockGuilds[index] = {
          ...mockGuilds[index],
          guildName: editForm.value.guildName,
          leaderId: editForm.value.leaderId,
          groupId: editForm.value.groupId,
          groupName
        }
      }
      
      ElMessage.success('公会信息更新成功')
      editDialogVisible.value = false
      getTableData()
    }
  })
}

// 点击状态标签
const handleStatusClick = (row) => {
  // 已移除和已过期的公会不能修改状态
  if (row.status === 'removed' || row.status === 'expired') {
    ElMessage.warning('该公会状态不可修改')
    return
  }
  
  currentGuild.value = row
  newStatus.value = ''
  statusRemark.value = ''
  statusDialogVisible.value = true
}

// 状态修改提交
const handleStatusSubmit = () => {
  if (!newStatus.value) {
    ElMessage.warning('请选择新状态')
    return
  }
  
  ElMessageBox.confirm(
    `确定要将公会"${currentGuild.value.guildName}"的状态修改为"${getStatusLabel(newStatus.value)}"吗？`,
    '确认修改',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    // Mock 更新状态
    const index = mockGuilds.findIndex(item => item.id === currentGuild.value.id)
    if (index !== -1) {
      mockGuilds[index].status = newStatus.value
    }
    
    ElMessage.success('公会状态修改成功')
    statusDialogVisible.value = false
    getTableData()
  }).catch(() => {})
}

// 关闭对话框
const handleDialogClose = () => {
  editFormRef.value?.resetFields()
  newStatus.value = ''
  statusRemark.value = ''
}

// ==================== 初始化 ====================
onMounted(() => {
  getTableData()
})
</script>

<style scoped lang="scss">
.guild-list-container {
  padding: 24px;
  min-height: 100vh;

  .content-card {
    background: #fff;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);

    .search-section {
      margin-bottom: 24px;
      padding-bottom: 24px;
      border-bottom: 1px solid #f3f4f6;

      .search-form {
        :deep(.el-form-item) {
          margin-bottom: 16px;
          margin-right: 16px;

          .el-form-item__label {
            color: #374151;
            font-weight: 500;
            font-size: 14px;
          }
        }

        .search-input {
          width: 200px;

          :deep(.el-input__inner) {
            border-radius: 6px;
          }
        }

        .search-select {
          width: 150px;

          :deep(.el-input__inner) {
            border-radius: 6px;
          }
        }

        .search-btn {
          padding: 8px 24px;
          border-radius: 6px;
          background-color: #3b82f6;
          border-color: #3b82f6;

          &:hover {
            background-color: #2563eb;
            border-color: #2563eb;
          }
        }

        .reset-btn {
          padding: 8px 24px;
          border-radius: 6px;
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
        }
      }

      .status-tag {
        cursor: pointer;
        padding: 6px 12px;
        border-radius: 4px;
        font-size: 13px;

        &:hover {
          opacity: 0.8;
        }
      }

      .edit-btn {
        padding: 8px 20px;
        background-color: #3b82f6;
        color: #fff;
        border: none;
        border-radius: 6px;
        font-size: 14px;

        &:hover:not(:disabled) {
          background-color: #2563eb;
        }

        &:disabled {
          background-color: #d1d5db;
          color: #9ca3af;
          cursor: not-allowed;
        }
      }
    }

    .pagination-section {
      margin-top: 24px;
      display: flex;
      justify-content: flex-end;
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

  .info-text {
    color: #1f2937;
    font-size: 14px;
    font-weight: 500;
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

:deep(.el-pagination) {
  .el-pager li {
    border-radius: 4px;
  }
}
</style>


