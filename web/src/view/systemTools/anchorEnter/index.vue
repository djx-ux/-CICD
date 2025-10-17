<template>
  <div class="page-container">
    <div class="card">
      <!-- 搜索条件 -->
      <el-form :model="searchForm" inline class="toolbar">
        <el-form-item label="用户UID">
          <el-input v-model="searchForm.uid" placeholder="输入用户UID" clearable />
        </el-form-item>
        <el-form-item label="公会ID">
          <el-input v-model="searchForm.guildId" placeholder="输入公会ID" clearable />
        </el-form-item>
        <el-form-item label="主播状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable style="width: 160px">
            <el-option v-for="o in statusOptions" :key="o.value" :label="o.label" :value="o.value" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 批量操作 -->
      <div class="batch-bar">
        <div>已选择 {{ multipleSelection.length }} 项</div>
        <div class="gap-12">
          <el-button type="success" @click="batchApprove" :disabled="!multipleSelection.length">通过</el-button>
          <el-button type="danger" @click="openReject" :disabled="!multipleSelection.length">拒绝</el-button>
        </div>
      </div>

      <!-- 列表 -->
      <el-table :data="tableData" @selection-change="handleSelectionChange" v-loading="loading">
        <el-table-column type="selection" width="48" />
        <el-table-column label="用户UID" prop="uid" min-width="120" />
        <el-table-column label="昵称" prop="nick" min-width="140" />
        <el-table-column label="财富等级" prop="wealthLevel" width="100" />
        <el-table-column label="公会ID" prop="guildId" width="110" />
        <el-table-column label="公会名称" prop="guildName" min-width="160" />
        <el-table-column label="申请状态" prop="applyStatus" width="110">
          <template #default="{ row }">
            <el-tag :type="statusType(row.applyStatus)">{{ statusLabel(row.applyStatus) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="申请时间" prop="applyTime" width="140" />
        <el-table-column label="操作" width="100" align="center">
          <template #default="{ row }">
            <el-button size="small" @click="openDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 拒绝弹窗 -->
    <el-dialog v-model="rejectVisible" title="拒绝主播申请" width="520px">
      <el-form label-width="96px">
        <el-form-item label="拒绝理由">
          <el-input v-model="rejectReason" type="textarea" :rows="4" placeholder="请填写拒绝该申请的理由..." />
        </el-form-item>
        <el-form-item>
          <el-checkbox v-model="joinBlacklist">将用户加入黑名单</el-checkbox>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="rejectVisible=false">取消</el-button>
        <el-button type="primary" @click="confirmReject">确认拒绝</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
defineOptions({ name: 'AnchorEnter' })
import { ref } from 'vue'
import { ElMessage } from 'element-plus'

// 搜索与表格状态
const searchForm = ref({ uid: '', guildId: '', status: '' })
const statusOptions = [
  { label: '全部状态', value: '' },
  { label: '待审核', value: 'pending' },
  { label: '已认证', value: 'verified' },
  { label: '已拒绝', value: 'rejected' }
]
const loading = ref(false)
const tableData = ref([
  { uid: 'user_101', nick: '闪亮新星', wealthLevel: 5, guildId: 1001, guildName: '待审核公会A', applyStatus: 'pending', applyTime: '2023-08-10' },
  { uid: 'user_102', nick: '游戏大神', wealthLevel: 12, guildId: 3001, guildName: '阿里系-公会壹号', applyStatus: 'verified', applyTime: '2023-07-25' },
  { uid: 'user_103', nick: '歌后', wealthLevel: 8, guildId: 1001, guildName: '待审核公会A', applyStatus: 'pending', applyTime: '2023-08-11' },
  { uid: 'user_104', nick: '小透明', wealthLevel: 2, guildId: 4001, guildName: '小米系-公会甲', applyStatus: 'rejected', applyTime: '2023-07-30' },
  { uid: 'user_105', nick: '舞王', wealthLevel: 20, guildId: 3001, guildName: '阿里系-公会壹号', applyStatus: 'pending', applyTime: '2023-08-12' }
])

const multipleSelection = ref([])
const handleSelectionChange = (val) => { multipleSelection.value = val }

const statusType = (s) => ({ pending: '', verified: 'success', rejected: 'danger' }[s] || '')
const statusLabel = (s) => ({ pending: '待审核', verified: '已认证', rejected: '已拒绝' }[s] || s)

const handleSearch = () => { /* 此处保留，后续替换为接口 */ }
const handleReset = () => { searchForm.value = { uid: '', guildId: '', status: '' } }

const batchApprove = () => {
  if (!multipleSelection.value.length) return
  multipleSelection.value.forEach((r) => (r.applyStatus = 'verified'))
  ElMessage.success('已批量通过所选申请')
}

const rejectVisible = ref(false)
const rejectReason = ref('')
const joinBlacklist = ref(false)
const openReject = () => { rejectVisible.value = true }
const confirmReject = () => {
  if (!multipleSelection.value.length) return
  multipleSelection.value.forEach((r) => (r.applyStatus = 'rejected'))
  rejectVisible.value = false
  rejectReason.value = ''
  joinBlacklist.value = false
  ElMessage.success('已拒绝所选申请')
}

const openDetail = () => {
  ElMessage.info('示例页面：后续可接详情弹窗')
}
</script>

<style scoped lang="scss">
.page-container { padding: 24px; }
.card { background: #fff; border-radius: 12px; padding: 16px; }
.toolbar { margin-bottom: 12px; }
.batch-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; background: #f5f7fa; padding: 10px 12px; border-radius: 8px; }
.gap-12 { display: flex; gap: 12px; }
</style>



