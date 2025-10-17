<template>
  <div class="page-container">
    <div class="card">
      <el-form :model="searchForm" inline class="toolbar">
        <el-form-item label="开始日期"><el-date-picker v-model="searchForm.start" type="date" value-format="YYYY-MM-DD" /></el-form-item>
        <el-form-item label="结束日期"><el-date-picker v-model="searchForm.end" type="date" value-format="YYYY-MM-DD" /></el-form-item>
        <el-form-item label="操作人"><el-input v-model="searchForm.operator" placeholder="输入操作人" clearable /></el-form-item>
        <el-form-item label="用户UID"><el-input v-model="searchForm.uid" placeholder="输入用户UID" clearable /></el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
        <el-form-item>
          <el-button type="danger" @click="openAdd">添加黑名单</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" v-loading="loading">
        <el-table-column label="用户UID" prop="uid" min-width="120" />
        <el-table-column label="昵称" prop="nick" min-width="120" />
        <el-table-column label="加入黑名单时间" prop="time" width="160" />
        <el-table-column label="加入黑名单理由" prop="reason" min-width="220" />
        <el-table-column label="操作人" prop="operator" width="120" />
        <el-table-column label="操作" width="100" align="center">
          <template #default="{ row }"><el-button size="small" @click="removeRow(row)">移除</el-button></template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog v-model="addVisible" title="添加黑名单" width="520px">
      <el-form :model="addForm" label-width="100px">
        <el-form-item label="用户UID"><el-input v-model="addForm.uid" /></el-form-item>
        <el-form-item label="昵称"><el-input v-model="addForm.nick" /></el-form-item>
        <el-form-item label="理由"><el-input v-model="addForm.reason" type="textarea" :rows="3" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addVisible=false">取消</el-button>
        <el-button type="primary" @click="confirmAdd">添加</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
defineOptions({ name: 'AnchorBlacklist' })
import { ref } from 'vue'
import { ElMessage } from 'element-plus'

const searchForm = ref({ start: '', end: '', operator: '', uid: '' })
const loading = ref(false)
const tableData = ref([
  { uid: 'user_104', nick: '小透明', time: '2023-07-30', reason: '资料不符合要求', operator: 'Admin_01' },
  { uid: 'user_xyz', nick: '违规用户', time: '2023-08-01', reason: '历史多次违规，禁止申请主播', operator: 'Sys_Auto' }
])

const handleSearch = () => {}
const handleReset = () => (searchForm.value = { start: '', end: '', operator: '', uid: '' })

const addVisible = ref(false)
const addForm = ref({ uid: '', nick: '', reason: '' })
const openAdd = () => (addVisible.value = true)
const confirmAdd = () => {
  tableData.value.unshift({ ...addForm.value, time: new Date().toISOString().slice(0,10), operator: 'Admin_01' })
  addVisible.value = false
  addForm.value = { uid: '', nick: '', reason: '' }
  ElMessage.success('已添加到黑名单（示例）')
}

const removeRow = (row) => {
  tableData.value = tableData.value.filter((r) => r !== row)
  ElMessage.success('已移除（示例）')
}
</script>

<style scoped>
.page-container{padding:24px}
.card{background:#fff;border-radius:12px;padding:16px}
.toolbar{margin-bottom:12px}
</style>






