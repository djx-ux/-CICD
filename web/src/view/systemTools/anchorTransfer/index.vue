<template>
  <div class="page-container">
    <div class="card">
      <el-form :model="searchForm" inline class="toolbar">
        <el-form-item label="用户UID"><el-input v-model="searchForm.uid" clearable /></el-form-item>
        <el-form-item label="公会ID"><el-input v-model="searchForm.guildId" clearable /></el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <div class="batch-bar">
        <div>已选择 {{ multipleSelection.length }} 项</div>
        <div class="gap-12">
          <el-button type="primary" @click="openTransfer" :disabled="!multipleSelection.length">移转主播身份</el-button>
        </div>
      </div>

      <el-table :data="tableData" @selection-change="selChange" v-loading="loading">
        <el-table-column type="selection" width="48" />
        <el-table-column label="用户UID" prop="uid" min-width="120" />
        <el-table-column label="昵称" prop="nick" min-width="120" />
        <el-table-column label="当前公会ID" prop="guildId" width="120" />
        <el-table-column label="当前公会名称" prop="guildName" min-width="160" />
        <el-table-column label="加入时间" prop="joinTime" width="140" />
        <el-table-column label="操作" width="90" align="center">
          <template #default="{ row }"><el-button size="small" @click="openTransfer(row)">编辑</el-button></template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog v-model="transferVisible" title="转会" width="520px">
      <el-form label-width="96px">
        <el-form-item label="目标公会">
          <el-select v-model="targetGuild" placeholder="请选择目标公会" style="width: 100%">
            <el-option v-for="g in guildOptions" :key="g.value" :label="g.label" :value="g.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="transferRemark" type="textarea" :rows="3" placeholder="请输入备注（可选）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="transferVisible=false">取消</el-button>
        <el-button type="primary" @click="confirmTransfer">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
defineOptions({ name: 'AnchorTransfer' })
import { ref } from 'vue'
import { ElMessage } from 'element-plus'

const searchForm = ref({ uid: '', guildId: '' })
const loading = ref(false)
const tableData = ref([
  { uid: 'user_302', nick: '电竞猎人', guildId: 3001, guildName: '阿里系-公会壹号', joinTime: '2023-06-10' },
  { uid: 'user_401', nick: '流行歌手', guildId: 4001, guildName: '小米系-公会甲', joinTime: '2023-05-15' },
  { uid: 'user_101', nick: '闪亮新星', guildId: 1001, guildName: '待审核公会A', joinTime: '2023-08-12' }
])

const multipleSelection = ref([])
const selChange = (v) => (multipleSelection.value = v)

const handleSearch = () => {}
const handleReset = () => (searchForm.value = { uid: '', guildId: '' })

const transferVisible = ref(false)
const targetGuild = ref(null)
const transferRemark = ref('')
const guildOptions = [
  { label: '官方公会1(自由)', value: 1 },
  { label: '阿里系-公会壹号', value: 3001 },
  { label: '小米系-公会甲', value: 4001 },
  { label: '字节系-公会丙', value: 5001 }
]

const openTransfer = () => { transferVisible.value = true }
const confirmTransfer = () => {
  transferVisible.value = false
  targetGuild.value = null
  transferRemark.value = ''
  ElMessage.success('已提交转会申请（示例）')
}
</script>

<style scoped>
.page-container{padding:24px}
.card{background:#fff;border-radius:12px;padding:16px}
.toolbar{margin-bottom:12px}
.batch-bar{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;background:#f5f7fa;padding:10px 12px;border-radius:8px}
.gap-12{display:flex;gap:12px}
</style>



