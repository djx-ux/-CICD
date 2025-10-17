# 🚀 公会列表管理页面 - 配置指南

## 📋 页面信息

- **页面路径**：`web/src/view/guild/list.vue`
- **组件名称**：`GuildList`
- **路由路径**：建议 `/guild/list`
- **菜单名称**：公会列表管理

---

## ⚙️ 后端配置方法

### 方法 1：通过管理后台配置（推荐）

1. **登录系统** → 进入「超级管理员」→「菜单管理」

2. **添加父级菜单**（如果不存在）：
   - 路由 Name: `guild`
   - 路由 Path: `guild`
   - 菜单名称: `公会管理`
   - 组件路径: `view/guild/index.vue`
   - 图标: 选择合适的图标（如 `management`）

3. **添加子菜单**：
   - 父级菜单: 选择上面创建的 `guild`
   - 路由 Name: `guildList`
   - 路由 Path: `list`
   - 菜单名称: `公会列表`
   - 组件路径: `view/guild/list.vue`
   - 图标: 选择合适的图标（如 `list`）
   - 排序: 根据需要设置

4. **保存并刷新页面**

---

### 方法 2：直接修改后端代码（适合开发）

编辑 `server/source/system/menu.go`，在 `allMenus` 数组中添加：

```go
// 添加公会管理父菜单
{
  MenuLevel: 0, 
  Hidden: false, 
  ParentId: 0, 
  Path: "guild", 
  Name: "guild", 
  Component: "view/guild/index.vue", 
  Sort: 8, 
  Meta: Meta{
    Title: "公会管理", 
    Icon: "management"
  }
},
```

然后在 `childMenus` 数组中添加：

```go
// 添加公会列表子菜单
{
  MenuLevel: 1, 
  Hidden: false, 
  ParentId: menuNameMap["guild"], 
  Path: "list", 
  Name: "guildList", 
  Component: "view/guild/list.vue", 
  Sort: 1, 
  Meta: Meta{
    Title: "公会列表", 
    Icon: "list", 
    KeepAlive: true
  }
},
```

**注意**：修改后需要重新初始化数据库或手动添加菜单记录。

---

### 方法 3：直接在数据库添加

#### 添加父级菜单

```sql
INSERT INTO sys_base_menus (created_at, updated_at, menu_level, parent_id, path, name, hidden, component, sort, title, icon)
VALUES (
  NOW(), 
  NOW(), 
  0, 
  0, 
  'guild', 
  'guild', 
  0, 
  'view/guild/index.vue', 
  8,
  '公会管理',
  'management'
);
```

#### 添加子菜单

```sql
-- 先获取父菜单 ID
SET @parent_id = (SELECT id FROM sys_base_menus WHERE name = 'guild');

-- 添加子菜单
INSERT INTO sys_base_menus (created_at, updated_at, menu_level, parent_id, path, name, hidden, component, sort, title, icon, keep_alive)
VALUES (
  NOW(), 
  NOW(), 
  1, 
  @parent_id, 
  'list', 
  'guildList', 
  0, 
  'view/guild/list.vue', 
  1,
  '公会列表',
  'list',
  1
);
```

---

## 🔄 菜单名称映射配置

如果你想暂时使用菜单名称映射功能（不修改后端），可以在 `menuNameMapping.js` 中添加：

```javascript
export const menuNameMapping = {
  // ... 其他配置
  
  // 公会管理模块
  'guild': '公会管理',
  'guildList': '公会列表',
}
```

---

## 📁 完整文件结构

```
web/src/view/guild/
├── index.vue           # 路由容器
├── list.vue            # 公会列表页面 ✅ 已创建
├── README.md           # 功能说明
└── SETUP.md            # 配置指南（本文件）

web/src/api/
└── guild.js            # 公会API接口 ✅ 已创建

web/src/pathInfo.json   # ✅ 已注册组件
```

---

## ✅ 已完成的准备工作

- ✅ 创建了公会列表页面 (`guild/list.vue`)
- ✅ 创建了路由容器 (`guild/index.vue`)
- ✅ 注册到 `pathInfo.json`
- ✅ 创建了 API 接口文件 (`api/guild.js`)
- ✅ 添加了 Mock 数据用于测试

---

## 🎯 下一步操作

### 如果后端还没准备好

**临时访问方案**：

1. 手动在浏览器输入 URL：
   ```
   http://localhost:8080/#/layout/guild/list
   ```

2. 或者修改某个现有菜单的 component 路径为 `view/guild/list.vue`

### 如果后端已准备好

1. 按照上面「后端配置方法」添加菜单
2. 刷新页面，菜单应该出现
3. 点击菜单即可访问公会列表页面

---

## 🧪 测试功能

访问页面后，你可以测试：

1. ✅ **搜索功能** - 输入条件查询公会
2. ✅ **状态筛选** - 按分组和状态过滤
3. ✅ **编辑公会** - 点击编辑按钮修改信息
4. ✅ **修改状态** - 点击状态标签修改状态
5. ✅ **分页** - 切换页码和每页数量
6. ✅ **多选** - 复选框选择多个公会

---

## 📞 常见问题

**Q: 菜单没有显示？**  
A: 检查是否在后端添加了菜单配置，或者检查权限是否分配

**Q: 点击菜单没反应？**  
A: 检查组件路径是否正确，控制台是否有错误

**Q: 页面空白？**  
A: 检查 `pathInfo.json` 是否注册，组件是否有 `defineOptions({ name })`

**Q: 想临时测试页面？**  
A: 直接在浏览器访问 `http://localhost:8080/#/layout/guild/list`

---

**创建时间**：2025-10-15  
**状态**：✅ 页面已创建，等待后端配置菜单  
**Mock 数据**：✅ 已配置，可直接测试


