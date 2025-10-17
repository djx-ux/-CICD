/**
 * 菜单名称映射配置
 * 
 * 用途：在前端临时修改菜单显示名称，无需等待后端修改
 * 
 * 使用方法：
 * 1. 在下方映射表中添加需要修改的菜单
 * 2. key: 后端返回的菜单 name（路由名称）
 * 3. value: 前端显示的菜单标题
 * 
 * 注意：后端更新后记得删除对应的映射项
 */

export const menuNameMapping = {
  // 前端菜单映射已禁用，改为直接修改后端配置
  // 如需临时修改菜单名称，在此添加映射配置
}

/**
 * 应用菜单名称映射
 * @param {Array} menus - 菜单数组
 * @returns {Array} 处理后的菜单数组
 */
export function applyMenuNameMapping(menus) {
  if (!menus || !Array.isArray(menus)) {
    return menus
  }

  return menus.map(menu => {
    // 创建菜单副本，避免修改原对象
    const mappedMenu = { ...menu }

    // 如果存在映射，则替换菜单标题
    if (menuNameMapping[menu.name]) {
      mappedMenu.meta = {
        ...mappedMenu.meta,
        title: menuNameMapping[menu.name]
      }
      
      console.log(`✅ 菜单名称已映射: ${menu.name} -> "${menuNameMapping[menu.name]}"`)
    }

    // 递归处理子菜单
    if (mappedMenu.children && mappedMenu.children.length > 0) {
      mappedMenu.children = applyMenuNameMapping(mappedMenu.children)
    }

    return mappedMenu
  })
}

/**
 * 批量应用菜单名称映射（支持多级菜单）
 * @param {Array} menus - 菜单数组
 * @returns {Array} 处理后的菜单数组
 */
export function batchApplyMenuNameMapping(menus) {
  const enableMapping = Object.keys(menuNameMapping).length > 0
  
  if (!enableMapping) {
    console.log('ℹ️  菜单名称映射未配置，使用后端原始名称')
    return menus
  }

  console.log('🔄 开始应用菜单名称映射...')
  const result = applyMenuNameMapping(menus)
  console.log('✅ 菜单名称映射完成')
  
  return result
}

