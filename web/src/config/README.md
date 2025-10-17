# 配置文件说明

## menuNameMapping.js - 菜单名称映射配置

### 用途
在前端临时修改菜单显示名称，无需等待后端修改。适用于：
- 后端暂时无法修改菜单名称
- 需要快速调整前端显示
- 临时性的菜单名称调整

### 使用方法

#### 1. 找到需要修改的菜单 name

打开浏览器控制台，执行：
```javascript
// 查看当前所有菜单的 name 和 title
useRouterStore().asyncRouters[0].children.forEach(menu => {
  console.log(`name: ${menu.name}, title: ${menu.meta?.title}`)
  if (menu.children) {
    menu.children.forEach(child => {
      console.log(`  └─ name: ${child.name}, title: ${child.meta?.title}`)
    })
  }
})
```

#### 2. 在配置文件中添加映射

编辑 `menuNameMapping.js`：

```javascript
export const menuNameMapping = {
  'superAdmin': '公会管理后台',     // 将"超级管理员"改为"公会管理后台"
  'authority': '配置分组',          // 将"角色管理"改为"配置分组"
  'menu': '分组详情页',             // 将"菜单管理"改为"分组详情页"
}
```

#### 3. 刷新页面查看效果

保存文件后，刷新浏览器即可看到新的菜单名称。

### 示例

**修改前（后端返回）：**
```
超级管理员
├─ 角色管理
└─ 菜单管理
```

**修改后（前端显示）：**
```
公会管理后台
├─ 配置分组
└─ 分组详情页
```

### 配置示例

```javascript
export const menuNameMapping = {
  // 一级菜单
  'dashboard': '首页',
  'superAdmin': '公会管理',
  'systemTools': '工具箱',
  
  // 二级菜单
  'authority': '分组配置',
  'menu': '公会列表',
  'user': '用户管理',
  'api': '接口管理',
  
  // 示例菜单
  'upload': '文件上传',
  'customer': '客户列表',
}
```

### 注意事项

⚠️ **重要提醒**：

1. **临时方案**：这是临时解决方案，后端更新后应删除对应映射
2. **name 不是 title**：映射的 key 是路由的 `name` 属性，不是显示的 `title`
3. **支持嵌套**：自动处理多级菜单，包括子菜单
4. **控制台提示**：每次应用映射时会在控制台输出日志
5. **不影响路由**：只修改显示名称，不影响路由跳转

### 如何查找菜单 name

方法1：查看后端返回数据
- 打开浏览器控制台 → Network
- 刷新页面
- 找到 `getMenu` 接口
- 查看返回的 JSON 数据中的 `name` 字段

方法2：查看前端路由配置
- 打开控制台执行：`useRouterStore().asyncRouters`
- 查看路由配置中的 `name` 字段

方法3：查看后端源码
- 打开 `server/source/system/menu.go`
- 查看菜单初始化数据中的 `Name` 字段

### 完整流程示例

假设你要修改"超级管理员"菜单：

1. **找到菜单 name**：查看后端返回，发现是 `superAdmin`
2. **添加映射**：
   ```javascript
   export const menuNameMapping = {
     'superAdmin': '公会管理后台'
   }
   ```
3. **保存并刷新**：刷新浏览器查看效果
4. **验证**：控制台应该显示：
   ```
   🔄 开始应用菜单名称映射...
   ✅ 菜单名称已映射: superAdmin -> "公会管理后台"
   ✅ 菜单名称映射完成
   ```

### 后续处理

当后端修改完成后：

1. 删除 `menuNameMapping` 中对应的映射项
2. 如果所有映射都已删除，可以考虑移除整个映射逻辑
3. 在 `router.js` 中注释或删除 `batchApplyMenuNameMapping` 的调用

---

**创建时间**：2025-10-15  
**适用场景**：临时前端菜单名称调整  
**维护建议**：定期清理已过时的映射配置

