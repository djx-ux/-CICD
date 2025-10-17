<template>
  <div class="page-container">
    <div class="card">
      <!-- 搜索条件 -->
      <el-form :model="searchForm" inline class="toolbar">
        <el-form-item label="用户UID">
          <el-input v-model="searchForm.uid" placeholder="输入用户UID" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="公会ID">
          <el-input v-model="searchForm.guildId" placeholder="输入公会ID" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="Broker状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable style="width: 180px">
            <el-option label="全部状态" value="" />
            <el-option label="正常" value="normal" />
            <el-option label="被移除" value="removed" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 批量操作区 -->
      <div class="batch-bar">
        <div>已选择 {{ multipleSelection.length }} 项</div>
        <div class="gap-12">
          <el-button type="danger" @click="batchRemove" :disabled="!multipleSelection.length">批量移除</el-button>
        </div>
      </div>

      <!-- 数据表格 -->
      <el-table 
        :data="tableData" 
        @selection-change="handleSelectionChange" 
        v-loading="loading"
        style="width: 100%"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column label="用户UID" prop="uid" min-width="130" />
        <el-table-column label="昵称" prop="nick" min-width="140" />
        <el-table-column label="公会ID" prop="guildId" width="110" />
        <el-table-column label="公会名称" prop="guildName" min-width="180" />
        <el-table-column label="Broker状态" prop="status" width="120">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)">{{ statusLabel(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="Broker分成" prop="commission" width="120">
          <template #default="{ row }">{{ row.commission }}%</template>
        </el-table-column>
        <el-table-column label="加入时间" prop="joinTime" width="140" />
        <el-table-column label="操作" width="280" align="center" fixed="right">
          <template #default="{ row }">
            <el-button 
              size="small" 
              type="warning" 
              @click="openEditCommission(row)"
              :disabled="row.status === 'removed'"
            >
              修改分成
            </el-button>
            <el-button 
              size="small" 
              type="danger" 
              @click="removeBroker(row)"
              :disabled="row.status === 'removed'"
            >
              移除
            </el-button>
            <el-button size="small" @click="viewDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pageInfo.page"
          v-model:page-size="pageInfo.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="pageInfo.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </div>

    <!-- 修改分成弹窗 -->
    <el-dialog v-model="commissionVisible" title="修改Broker分成" width="500px">
      <el-form :model="commissionForm" label-width="120px">
        <el-form-item label="用户UID">
          <el-input v-model="commissionForm.uid" disabled />
        </el-form-item>
        <el-form-item label="昵称">
          <el-input v-model="commissionForm.nick" disabled />
        </el-form-item>
        <el-form-item label="当前分成">
          <el-input v-model="commissionForm.currentCommission" disabled>
            <template #append>%</template>
          </el-input>
        </el-form-item>
        <el-form-item label="新分成比例" required>
          <el-input-number 
            v-model="commissionForm.newCommission" 
            :min="0" 
            :max="100" 
            :precision="0"
            style="width: 100%"
          />
          <div class="form-tip">请输入0-100之间的整数</div>
        </el-form-item>
        <el-form-item label="备注">
          <el-input 
            v-model="commissionForm.remark" 
            type="textarea" 
            :rows="3" 
            placeholder="请输入修改原因（可选）"
            maxlength="200"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="commissionVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmEditCommission">确认修改</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
defineOptions({ name: 'BrokerManagement' })
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

// 搜索表单
const searchForm = ref({
  uid: '',
  guildId: '',
  status: ''
})

// 加载状态
const loading = ref(false)

// 表格数据
const tableData = ref([
  {
    uid: 'broker_001',
    nick: '金牌经纪人A',
    guildId: 3001,
    guildName: '阿里系-公会壹号',
    status: 'normal',
    commission: 30,
    joinTime: '2023-01-15'
  },
  {
    uid: 'broker_002',
    nick: '王牌经纪人B',
    guildId: 4001,
    guildName: '小米系-公会甲',
    status: 'normal',
    commission: 25,
    joinTime: '2023-03-20'
  },
  {
    uid: 'broker_003',
    nick: '前经纪人C',
    guildId: 3001,
    guildName: '阿里系-公会壹号',
    status: 'removed',
    commission: 20,
    joinTime: '2022-11-10'
  },
  {
    uid: 'broker_004',
    nick: '新晋经纪人D',
    guildId: 5001,
    guildName: '字节系-公会丙',
    status: 'normal',
    commission: 35,
    joinTime: '2023-08-05'
  }
])

// 多选
const multipleSelection = ref([])
const handleSelectionChange = (val) => {
  multipleSelection.value = val
}

// 状态显示
const statusType = (status) => {
  return status === 'normal' ? 'success' : 'info'
}
const statusLabel = (status) => {
  return status === 'normal' ? '正常' : '被移除'
}

// 搜索和重置
const handleSearch = () => {
  loading.value = true
  // TODO: 调用API接口
  setTimeout(() => {
    loading.value = false
    ElMessage.success('查询完成')
  }, 500)
}

const handleReset = () => {
  searchForm.value = {
    uid: '',
    guildId: '',
    status: ''
  }
  handleSearch()
}

// 批量移除
const batchRemove = () => {
  if (!multipleSelection.value.length) {
    ElMessage.warning('请先选择要移除的Broker')
    return
  }
  
  const validItems = multipleSelection.value.filter(item => item.status === 'normal')
  if (validItems.length === 0) {
    ElMessage.warning('所选Broker均已被移除')
    return
  }

  ElMessageBox.confirm(
    `确定要批量移除选中的 ${validItems.length} 个Broker吗？移除后他们将无法继续获得分成。`,
    '批量移除确认',
    {
      confirmButtonText: '确定移除',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    // TODO: 调用API接口
    validItems.forEach(item => {
      item.status = 'removed'
    })
    ElMessage.success(`已成功移除 ${validItems.length} 个Broker`)
    multipleSelection.value = []
  }).catch(() => {
    ElMessage.info('已取消操作')
  })
}

// 修改分成
const commissionVisible = ref(false)
const commissionForm = reactive({
  uid: '',
  nick: '',
  currentCommission: 0,
  newCommission: 0,
  remark: ''
})

const openEditCommission = (row) => {
  commissionForm.uid = row.uid
  commissionForm.nick = row.nick
  commissionForm.currentCommission = row.commission
  commissionForm.newCommission = row.commission
  commissionForm.remark = ''
  commissionVisible.value = true
}

const confirmEditCommission = () => {
  if (commissionForm.newCommission < 0 || commissionForm.newCommission > 100) {
    ElMessage.error('分成比例必须在0-100之间')
    return
  }
  
  if (commissionForm.newCommission === commissionForm.currentCommission) {
    ElMessage.warning('新分成比例与当前相同，无需修改')
    return
  }

  // TODO: 调用API接口
  const broker = tableData.value.find(item => item.uid === commissionForm.uid)
  if (broker) {
    broker.commission = commissionForm.newCommission
  }
  
  commissionVisible.value = false
  ElMessage.success(`已将分成比例从 ${commissionForm.currentCommission}% 修改为 ${commissionForm.newCommission}%`)
}

// 移除单个Broker
const removeBroker = (row) => {
  ElMessageBox.confirm(
    `确定要移除Broker "${row.nick}" (${row.uid}) 吗？移除后该Broker将无法继续获得分成。`,
    '移除确认',
    {
      confirmButtonText: '确定移除',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    // TODO: 调用API接口
    row.status = 'removed'
    ElMessage.success('已成功移除该Broker')
  }).catch(() => {
    ElMessage.info('已取消操作')
  })
}

// 查看详情
const viewDetail = (row) => {
  ElMessage.info(`查看 ${row.nick} 的详细信息（功能开发中）`)
}

// 分页
const pageInfo = reactive({
  page: 1,
  pageSize: 10,
  total: 4
})

const handleSizeChange = (val) => {
  pageInfo.pageSize = val
  handleSearch()
}

const handleCurrentChange = (val) => {
  pageInfo.page = val
  handleSearch()
}
</script>

<style scoped lang="scss">
.page-container {
  padding: 24px;
  background: #f5f7fa;
  min-height: calc(100vh - 100px);
}

.card {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
}

.toolbar {
  margin-bottom: 16px;
  
  :deep(.el-form-item) {
    margin-bottom: 12px;
  }
}

.batch-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding: 12px 16px;
  background: #f5f7fa;
  border-radius: 8px;
  font-size: 14px;
  color: #606266;
}

.gap-12 {
  display: flex;
  gap: 12px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.form-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
  line-height: 1.5;
}

:deep(.el-table) {
  .el-table__header th {
    background-color: #f5f7fa;
    color: #606266;
    font-weight: 600;
  }
}
</style>

