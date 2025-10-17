-- ============================================
-- 主播关系管理菜单更新脚本
-- 执行前请确保备份数据库
-- ============================================

-- 查看当前 systemTools 菜单的 ID
-- SELECT id FROM sys_base_menus WHERE name = 'systemTools';

-- ============================================
-- 方法一：删除重建所有菜单（推荐，适合测试环境）
-- ============================================

-- 1. 删除菜单权限关联
-- DELETE FROM casbin_rule WHERE v1 LIKE '/menu/%' OR v1 LIKE '/authority/%';

-- 2. 清空菜单相关表
-- TRUNCATE TABLE sys_base_menus;
-- TRUNCATE TABLE sys_base_menu_btns;
-- TRUNCATE TABLE sys_base_menu_parameters;

-- 3. 重启服务，菜单会自动重新初始化


-- ============================================
-- 方法二：仅添加缺失的子菜单（适合生产环境）
-- ============================================

-- 设置变量存储 systemTools 的 ID
SET @systemtools_id = (SELECT id FROM sys_base_menus WHERE name = 'systemTools' LIMIT 1);

-- 检查是否找到父菜单
SELECT @systemtools_id AS 'systemTools菜单ID';

-- 如果上面查询结果为 NULL，说明父菜单不存在，需要先创建父菜单
-- INSERT INTO sys_base_menus (created_at, updated_at, menu_level, hidden, parent_id, path, name, component, sort, meta) 
-- VALUES (NOW(), NOW(), 0, 0, 0, 'systemTools', 'systemTools', 'view/systemTools/index.vue', 5, '{"title":"主播关系管理","icon":"tools"}');
-- SET @systemtools_id = LAST_INSERT_ID();

-- 删除可能已存在的旧子菜单（避免重复）
DELETE FROM sys_base_menus WHERE parent_id = @systemtools_id AND name IN ('anchorEnter', 'anchorBlacklist', 'anchorTransfer', 'anchorStatus');

-- 插入新的子菜单（按正确顺序）
INSERT INTO sys_base_menus (created_at, updated_at, menu_level, hidden, parent_id, path, name, component, sort, meta) VALUES
(NOW(), NOW(), 1, 0, @systemtools_id, 'anchorEnter', 'anchorEnter', 'view/systemTools/anchorEnter/index.vue', 1, '{"title":"主播入驻审核","icon":"user-filled"}'),
(NOW(), NOW(), 1, 0, @systemtools_id, 'anchorStatus', 'anchorStatus', 'view/systemTools/anchorStatus/index.vue', 2, '{"title":"主播状态变更","icon":"edit"}'),
(NOW(), NOW(), 1, 0, @systemtools_id, 'anchorTransfer', 'anchorTransfer', 'view/systemTools/anchorTransfer/index.vue', 3, '{"title":"主播转会","icon":"sort"}'),
(NOW(), NOW(), 1, 0, @systemtools_id, 'anchorBlacklist', 'anchorBlacklist', 'view/systemTools/anchorBlacklist/index.vue', 4, '{"title":"主播黑名单","icon":"circle-close-filled"}');

-- 查看插入结果
SELECT id, name, parent_id, path, component, meta FROM sys_base_menus WHERE parent_id = @systemtools_id;

-- ============================================
-- 为管理员角色添加菜单权限
-- ============================================

-- 查询管理员角色ID（通常是 888）
SELECT authority_id FROM sys_authorities WHERE authority_name = '管理员' OR authority_id = '888';

-- 为管理员角色添加新菜单权限
INSERT IGNORE INTO sys_authority_menus (sys_base_menu_id, sys_authority_authority_id)
SELECT id, '888' FROM sys_base_menus WHERE name IN ('anchorEnter', 'anchorBlacklist', 'anchorTransfer', 'anchorStatus');

-- 验证权限配置
SELECT 
    m.id,
    m.name,
    m.meta,
    am.sys_authority_authority_id
FROM sys_base_menus m
LEFT JOIN sys_authority_menus am ON m.id = am.sys_base_menu_id
WHERE m.parent_id = @systemtools_id
ORDER BY m.sort;

-- ============================================
-- PostgreSQL 版本（如果使用 PostgreSQL）
-- ============================================

/*
-- 设置变量
DO $$
DECLARE
    systemtools_id INTEGER;
BEGIN
    -- 获取 systemTools 的 ID
    SELECT id INTO systemtools_id FROM sys_base_menus WHERE name = 'systemTools' LIMIT 1;
    
    -- 删除旧数据
    DELETE FROM sys_base_menus WHERE parent_id = systemtools_id AND name IN ('anchorEnter', 'anchorBlacklist', 'anchorTransfer', 'anchorStatus');
    
    -- 插入新菜单
    INSERT INTO sys_base_menus (created_at, updated_at, menu_level, hidden, parent_id, path, name, component, sort, meta) VALUES
    (NOW(), NOW(), 1, false, systemtools_id, 'anchorEnter', 'anchorEnter', 'view/systemTools/anchorEnter/index.vue', 1, '{"title":"主播入驻审核","icon":"user-filled"}'),
    (NOW(), NOW(), 1, false, systemtools_id, 'anchorBlacklist', 'anchorBlacklist', 'view/systemTools/anchorBlacklist/index.vue', 2, '{"title":"主播黑名单","icon":"circle-close-filled"}'),
    (NOW(), NOW(), 1, false, systemtools_id, 'anchorTransfer', 'anchorTransfer', 'view/systemTools/anchorTransfer/index.vue', 3, '{"title":"主播转会","icon":"sort"}'),
    (NOW(), NOW(), 1, false, systemtools_id, 'anchorStatus', 'anchorStatus', 'view/systemTools/anchorStatus/index.vue', 4, '{"title":"主播状态变更","icon":"edit"}');
END $$;
*/

-- ============================================
-- 执行完成后的验证步骤
-- ============================================

-- 1. 查看菜单树结构
SELECT 
    CONCAT(
        CASE WHEN m.parent_id = 0 THEN '' ELSE '  └─ ' END,
        m.meta
    ) AS menu_tree,
    m.name,
    m.component
FROM sys_base_menus m
WHERE m.name = 'systemTools' OR m.parent_id IN (SELECT id FROM sys_base_menus WHERE name = 'systemTools')
ORDER BY m.parent_id, m.sort;

-- 2. 检查权限配置
SELECT 
    a.authority_name,
    m.name,
    JSON_EXTRACT(m.meta, '$.title') as title
FROM sys_authority_menus am
JOIN sys_base_menus m ON am.sys_base_menu_id = m.id
JOIN sys_authorities a ON am.sys_authority_authority_id = a.authority_id
WHERE m.parent_id IN (SELECT id FROM sys_base_menus WHERE name = 'systemTools')
ORDER BY a.authority_id, m.sort;

