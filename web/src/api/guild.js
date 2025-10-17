import service from '@/utils/request'

/**
 * 公会管理 API
 */

// 获取公会列表
export const getGuildList = (data) => {
  return service({
    url: '/guild/getGuildList',
    method: 'post',
    data
  })
}

// 获取公会详情
export const getGuildDetail = (data) => {
  return service({
    url: '/guild/getGuildDetail',
    method: 'post',
    data
  })
}

// 创建公会
export const createGuild = (data) => {
  return service({
    url: '/guild/createGuild',
    method: 'post',
    data
  })
}

// 更新公会信息
export const updateGuild = (data) => {
  return service({
    url: '/guild/updateGuild',
    method: 'post',
    data
  })
}

// 删除公会
export const deleteGuild = (data) => {
  return service({
    url: '/guild/deleteGuild',
    method: 'post',
    data
  })
}

// 修改公会状态
export const updateGuildStatus = (data) => {
  return service({
    url: '/guild/updateGuildStatus',
    method: 'post',
    data
  })
}

// 批量添加公会到分组
export const batchAddGuilds = (data) => {
  return service({
    url: '/guild/batchAddGuilds',
    method: 'post',
    data
  })
}

// 转移公会到其他分组
export const transferGuilds = (data) => {
  return service({
    url: '/guild/transferGuilds',
    method: 'post',
    data
  })
}

// 获取公会分组列表
export const getGuildGroups = () => {
  return service({
    url: '/guild/getGuildGroups',
    method: 'post'
  })
}

// 获取公会名称列表
export const getGuildNames = (data) => {
  return service({
    url: '/guild/getGuildNames',
    method: 'post',
    data
  })
}
