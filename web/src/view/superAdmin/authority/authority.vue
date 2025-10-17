<template>
  <div class="authority-container">
    <div class="content-card">
      <!-- 头部区域 -->
      <div class="header-section">
        <h2 class="page-title">分组列表</h2>
        <el-button type="primary" @click="handleAdd" class="add-btn">
          新增分组
        </el-button>
      </div>

      <!-- 数据表格 -->
      <el-table
        :data="tableData"
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
        row-key="authorityId"
        style="width: 100%"
        v-loading="loading"
        class="data-table"
      >
        <el-table-column label="分组名称" prop="authorityName" min-width="200" />
        <el-table-column label="负责人账号" min-width="200">
          <template #default="scope">
            admin_{{ String(scope.row.authorityId).padStart(2, '0') }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" align="center">
          <template #default="scope">
            <el-button
              class="edit-btn"
              @click="handleEdit(scope.row)"
            >
              编辑
            </el-button>
            <el-button
              class="delete-btn"
              :class="{ 'disabled-btn': scope.row.isDefault }"
              :disabled="scope.row.isDefault"
              @click="handleDelete(scope.row)"
            >
              {{ scope.row.isDefault ? '删除' : '删除' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="500px"
      @close="handleClose"
      class="custom-dialog"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-width="100px"
        class="form-content"
      >
        <el-form-item label="分组名称" prop="authorityName">
          <el-input
            v-model="formData.authorityName"
            placeholder="请输入分组名称"
            maxlength="50"
            show-word-limit
          />
        </el-form-item>
        <el-form-item label="负责人账号" prop="authorityId">
          <el-input
            v-model.number="formData.authorityId"
            :disabled="isEdit"
            placeholder="请输入负责人账号ID（仅数字）"
          />
          <div v-if="!isEdit" class="form-tip">
            负责人账号将显示为：admin_{{ formData.authorityId ? String(formData.authorityId).padStart(2, '0') : '00' }}
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false" class="cancel-btn">取消</el-button>
          <el-button type="primary" @click="handleSubmit" class="confirm-btn">确定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
defineOptions({
  name: 'Authority'
})

import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Setting, CopyDocument, Edit, Delete } from '@element-plus/icons-vue'
import {
  getAuthorityList,
  createAuthority,
  updateAuthority,
  deleteAuthority,
  copyAuthority
} from '@/api/authority'
import { getBaseMenuTree, getMenuAuthority, addMenuAuthority } from '@/api/menu'

// Mock 数据
const mockData = [
  {
    authorityId: 101,
    authorityName: '默认分组',
    createdAt: '2024-01-15T10:30:00',
    parentId: 0,
    isDefault: true  // 标记为默认分组，不可删除
  },
  {
    authorityId: 102,
    authorityName: 'ali',
    createdAt: '2024-02-20T14:20:00',
    parentId: 0,
    isDefault: false
  },
  {
    authorityId: 103,
    authorityName: 'xiaomi',
    createdAt: '2024-03-10T09:15:00',
    parentId: 0,
    isDefault: false
  }
]

// 数据状态
const loading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增分组')
const isEdit = ref(false)
const formRef = ref(null)
const formData = ref({
  authorityId: '',
  authorityName: '',
  parentId: 0
})

// 权限设置相关
const permissionDialogVisible = ref(false)
const menuTreeData = ref([])
const checkedKeys = ref([])
const treeRef = ref(null)
const currentAuthority = ref(null)

// 表单验证规则
const rules = {
  authorityId: [
    { required: true, message: '请输入负责人账号ID', trigger: 'blur' },
    { 
      type: 'number', 
      message: '负责人账号ID必须是数字', 
      trigger: 'blur',
      transform: (value) => Number(value)
    }
  ],
  authorityName: [
    { required: true, message: '请输入分组名称', trigger: 'blur' }
  ]
}

// 格式化日期
const formatDate = (date) => {
  if (!date) return ''
  const d = new Date(date)
  return d.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

// 获取分组列表
const getTableData = async () => {
  loading.value = true
  
  // 使用 Mock 数据
  setTimeout(() => {
    tableData.value = [...mockData]
    loading.value = false
  }, 500)
  
  // 实际 API 调用（暂时注释）
  // try {
  //   const res = await getAuthorityList({ page: 1, pageSize: 999 })
  //   if (res.code === 0) {
  //     tableData.value = res.data.list || []
  //   }
  // } catch (error) {
  //   ElMessage.error('获取分组列表失败')
  // } finally {
  //   loading.value = false
  // }
}

// 新增分组
const handleAdd = () => {
  dialogTitle.value = '新增分组'
  isEdit.value = false
  formData.value = {
    authorityId: '',
    authorityName: '',
    parentId: 0
  }
  dialogVisible.value = true
}

// 新增子分组
const handleAddChild = (row) => {
  dialogTitle.value = '新增子分组'
  isEdit.value = false
  formData.value = {
    authorityId: '',
    authorityName: '',
    parentId: row.authorityId
  }
  dialogVisible.value = true
}

// 编辑分组
const handleEdit = (row) => {
  dialogTitle.value = '编辑分组'
  isEdit.value = true
  formData.value = {
    authorityId: row.authorityId,
    authorityName: row.authorityName,
    parentId: row.parentId || 0
  }
  dialogVisible.value = true
}

// 删除分组
const handleDelete = (row) => {
  // 检查是否为默认分组
  if (row.isDefault) {
    ElMessage.warning('默认分组不能删除')
    return
  }
  
  ElMessageBox.confirm(
    `确定要删除分组"${row.authorityName}"吗？删除后该分组下的所有公会将被移除。`,
    '删除确认',
    {
      confirmButtonText: '确定删除',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    // Mock 删除
    const index = mockData.findIndex(item => item.authorityId === row.authorityId)
    if (index !== -1) {
      mockData.splice(index, 1)
      ElMessage.success('删除成功')
      await getTableData()
    }
    
    // 实际 API 调用（暂时注释）
    // try {
    //   const res = await deleteAuthority({ authorityId: row.authorityId })
    //   if (res.code === 0) {
    //     ElMessage.success('删除成功')
    //     await getTableData()
    //   }
    // } catch (error) {
    //   ElMessage.error('删除失败')
    // }
  }).catch(() => {})
}

// 提交表单
const handleSubmit = () => {
  formRef.value.validate(async (valid) => {
    if (valid) {
      // Mock 提交
      if (isEdit.value) {
        // 编辑：只能修改分组名称
        const index = mockData.findIndex(item => item.authorityId === formData.value.authorityId)
        if (index !== -1) {
          mockData[index] = { 
            ...mockData[index],
            authorityName: formData.value.authorityName
          }
        }
        ElMessage.success('分组信息更新成功')
      } else {
        // 新增：检查 authorityId 是否已存在
        const exists = mockData.some(item => item.authorityId === formData.value.authorityId)
        if (exists) {
          ElMessage.error('该负责人账号ID已存在，请使用其他ID')
          return
        }
        
        mockData.push({
          ...formData.value,
          createdAt: new Date().toISOString(),
          isDefault: false
        })
        ElMessage.success('分组创建成功')
      }
      dialogVisible.value = false
      await getTableData()
      
      // 实际 API 调用（暂时注释）
      // try {
      //   const api = isEdit.value ? updateAuthority : createAuthority
      //   const res = await api(formData.value)
      //   if (res.code === 0) {
      //     ElMessage.success(isEdit.value ? '更新成功' : '创建成功')
      //     dialogVisible.value = false
      //     await getTableData()
      //   }
      // } catch (error) {
      //   ElMessage.error(isEdit.value ? '更新失败' : '创建失败')
      // }
    }
  })
}

// 设置权限
const handleSetPermission = async (row) => {
  currentAuthority.value = row
  
  // 获取菜单树
  try {
    const menuRes = await getBaseMenuTree()
    if (menuRes.code === 0) {
      menuTreeData.value = menuRes.data.menus || []
    }

    // 获取当前角色已有的权限
    const authRes = await getMenuAuthority({ authorityId: row.authorityId })
    if (authRes.code === 0) {
      checkedKeys.value = authRes.data.menus?.map(item => item.ID) || []
    }

    permissionDialogVisible.value = true
  } catch (error) {
    ElMessage.error('获取权限数据失败')
  }
}

// 保存权限设置
const handleSavePermission = async () => {
  const checkedNodes = treeRef.value.getCheckedKeys()
  const halfCheckedNodes = treeRef.value.getHalfCheckedKeys()
  const menus = [...checkedNodes, ...halfCheckedNodes]

  try {
    const res = await addMenuAuthority({
      authorityId: currentAuthority.value.authorityId,
      menus
    })
    if (res.code === 0) {
      ElMessage.success('权限设置成功')
      permissionDialogVisible.value = false
    }
  } catch (error) {
    ElMessage.error('权限设置失败')
  }
}

// 关闭对话框
const handleClose = () => {
  formRef.value?.resetFields()
}

// 初始化
onMounted(() => {
  getTableData()
})
</script>

<style scoped lang="scss">
.authority-container {
  padding: 24px;
  min-height: 100vh;

  .content-card {
    background: #fff;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);

    .header-section {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 24px;

      .page-title {
        font-size: 20px;
        font-weight: 500;
        color: #1f2937;
        margin: 0;
      }

      .add-btn {
        padding: 10px 24px;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 500;
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

      .edit-btn {
        padding: 8px 20px;
        background-color: #6b7280;
        color: #fff;
        border: none;
        border-radius: 6px;
        font-size: 14px;
        margin-right: 8px;

        &:hover {
          background-color: #4b5563;
        }
      }

      .delete-btn {
        padding: 8px 20px;
        background-color: #ef4444;
        color: #fff;
        border: none;
        border-radius: 6px;
        font-size: 14px;

        &:hover {
          background-color: #dc2626;
        }

        &.disabled-btn {
          background-color: #d1d5db;
          cursor: not-allowed;

          &:hover {
            background-color: #d1d5db;
          }
        }
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

  .form-content {
    .el-form-item {
      margin-bottom: 20px;

      :deep(.el-form-item__label) {
        color: #374151;
        font-weight: 500;
      }

      :deep(.el-input__inner) {
        border-radius: 6px;
      }
    }

    .form-tip {
      margin-top: 8px;
      font-size: 12px;
      color: #6b7280;
      line-height: 1.5;
    }
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
</style>

