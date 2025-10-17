<template>
  <div class="page-container">
    <div class="card">
      <el-form :model="searchForm" inline class="toolbar">
        <el-form-item label="用户UID"><el-input v-model="searchForm.uid" clearable /></el-form-item>
        <el-form-item label="公会ID"><el-input v-model="searchForm.guildId" clearable /></el-form-item>
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

      <div class="batch-bar">
        <div>已选择 {{ multipleSelection.length }} 项</div>
        <div class="gap-12">
          <el-button @click="unbindGuild" type="warning" :disabled="!multipleSelection.length">解除公会绑定</el-button>
          <el-button @click="removeIdentity" type="danger" :disabled="!multipleSelection.length">移除主播身份</el-button>
        </div>
      </div>

      <el-table :data="tableData" @selection-change="selChange" v-loading="loading">
        <el-table-column type="selection" width="48" />
        <el-table-column label="用户UID" prop="uid" min-width="120" />
        <el-table-column label="昵称" prop="nick" min-width="120" />
        <el-table-column label="公会ID" prop="guildId" width="110" />
        <el-table-column label="公会名称" prop="guildName" min-width="160" />
        <el-table-column label="公会状态" prop="guildStatus" width="100">
          <template #default="{ row }"><el-tag :type="guildType(row.guildStatus)">{{ row.guildStatus }}</el-tag></template>
        </el-table-column>
        <el-table-column label="主播状态" prop="anchorStatus" width="110">
          <template #default="{ row }"><el-tag :type="anchorType(row.anchorStatus)">{{ row.anchorStatusLabel }}</el-tag></template>
        </el-table-column>
        <el-table-column label="加入时间" prop="joinTime" width="140" />
        <el-table-column label="操作人" prop="operator" width="100" />
        <el-table-column label="操作" width="90" align="center">
          <template #default="{ row }"><el-button size="small" @click="editRow(row)">编辑</el-button></template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>

<script setup>
defineOptions({ name: 'AnchorStatus' })
import { ref } from 'vue'
import { ElMessage } from 'element-plus'

const searchForm = ref({ uid: '', guildId: '', status: '' })
const statusOptions = [
  { label: '全部状态', value: '' },
  { label: '已认证', value: 'verified' },
  { label: '自由主播', value: 'free' },
  { label: '已移除', value: 'removed' }
]

const loading = ref(false)
const tableData = ref([
  { uid: 'user_102', nick: '游戏大神', guildId: 3001, guildName: '阿里系-公会壹号', guildStatus: '正常', anchorStatus: 'verified', anchorStatusLabel: '已认证', joinTime: '2023-07-25', operator: 'Sys_Auto' },
  { uid: 'user_201', nick: '舞动精灵', guildId: 4001, guildName: '小米系-公会甲', guildStatus: '正常', anchorStatus: 'verified', anchorStatusLabel: '已认证', joinTime: '2023-06-10', operator: 'Admin_02' },
  { uid: 'user_202', nick: '电音狂人', guildId: 1,    guildName: '官方公会1(自由)', guildStatus: '正常', anchorStatus: 'free',     anchorStatusLabel: '自由主播', joinTime: '2023-05-15', operator: 'Admin_01' },
  { uid: 'user_203', nick: '昔日之星', guildId: 5001, guildName: '字节系-公会丙', guildStatus: '冻结', anchorStatus: 'removed', anchorStatusLabel: '已移除', joinTime: '2023-01-20', operator: 'Admin_01' },
  { uid: 'user_204', nick: '实力唱将', guildId: 5001, guildName: '字节系-公会丙', guildStatus: '冻结', anchorStatus: 'verified', anchorStatusLabel: '已认证', joinTime: '2023-08-01', operator: 'Sys_Auto' }
])

const multipleSelection = ref([])
const selChange = (v) => (multipleSelection.value = v)

const guildType = (s) => (s === '正常' ? 'success' : s === '冻结' ? 'danger' : '')
const anchorType = (s) => ({ verified: 'success', free: 'warning', removed: 'info' }[s] || '')

const handleSearch = () => {}
const handleReset = () => (searchForm.value = { uid: '', guildId: '', status: '' })

const unbindGuild = () => {
  if (!multipleSelection.value.length) return
  ElMessage.success('已解除所选主播的公会绑定')
}
const removeIdentity = () => {
  if (!multipleSelection.value.length) return
  multipleSelection.value.forEach((r) => (r.anchorStatus = 'removed', r.anchorStatusLabel = '已移除'))
  ElMessage.success('已移除所选主播身份')
}
const editRow = () => ElMessage.info('示例页面：后续可接编辑弹窗')
</script>

<style scoped>
.page-container{padding:24px}
.card{background:#fff;border-radius:12px;padding:16px}
.toolbar{margin-bottom:12px}
.batch-bar{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;background:#f5f7fa;padding:10px 12px;border-radius:8px}
.gap-12{display:flex;gap:12px}
</style>






