-- LcL Tools - 优化整合版本
-- 统一的工具集，每个功能都有对应的macroScript

-- ===== 配置常量 =====
global LCL_MENU_TITLE = "LcL Tools"
global LCL_MENU_CATEGORY = "LcL"
global LCL_ERROR_TITLE = "LcL Tools"

-- 工具提示文本
global LCL_MAIN_TOOLTIP = "LcL 工具主界面"
global LCL_SYNC_TOOLTIP = "Max ⇄ Blender 同步"
global LCL_VISUAL_TOOLTIP = "可视化显示工具"
global LCL_SETTINGS_TOOLTIP = "同步和过滤设置"

-- 按钮文本
global LCL_EXPORT_TEXT = "Max To Blender"
global LCL_IMPORT_TEXT = "Blender To Max" 
global LCL_VISUAL_TEXT = "可视化"
global LCL_SETTINGS_TEXT = "设置"
-- =====================

-- 获取插件路径
pluginPath = getFilenamePath (getThisScriptFilename())

-- 加载核心模块 - 按功能分类
fn LcL_LoadCoreModules = 
(
    -- 加载同步核心功能（导出）
    syncExportFile = pluginPath + "core\\sync\\ExportCore.ms"
    if doesFileExist syncExportFile then
        fileIn syncExportFile
    else
        format "❌ 找不到同步导出核心文件: %\n" syncExportFile

    -- 加载同步核心功能（导入）
    syncImportFile = pluginPath + "core\\sync\\ImportCore.ms"
    if doesFileExist syncImportFile then
        fileIn syncImportFile
    else
        format "❌ 找不到同步导入核心文件: %\n" syncImportFile

    -- 加载可视化工具
    visualFile = pluginPath + "core\\visual\\IndexDisplay.ms"
    if doesFileExist visualFile then
        fileIn visualFile
    else
        format "❌ 找不到可视化工具文件: %\n" visualFile

    -- 加载设置界面
    settingsFile = pluginPath + "ui\\SettingsUI.ms"
    if doesFileExist settingsFile then
        fileIn settingsFile
    else
        format "❌ 找不到设置界面文件: %\n" settingsFile

    -- 加载主界面
    mainUIFile = pluginPath + "ui\\MainUI.ms"
    if doesFileExist mainUIFile then
        fileIn mainUIFile
    else
        format "❌ 找不到主界面文件: %\n" mainUIFile
)

-- ===== macroScript 定义 =====

-- 1. 主工具界面
macroScript LcL_MainTools
category:LCL_MENU_CATEGORY
toolTip:LCL_MAIN_TOOLTIP
buttonText:"LcL Tools"
Icon:#("button", 1)
(
    on execute do
    (
        LcL_LoadCoreModules()
        
        if Create_LcL_Tools_Dialog != undefined then
            Create_LcL_Tools_Dialog()
        else
            messageBox "无法加载LcL Tools主界面！" title:LCL_ERROR_TITLE
    )
)

-- 2. 导出到Blender
macroScript LcL_ExportToBlender
category:LCL_MENU_CATEGORY
toolTip:"导出选中对象到Blender"
buttonText:LCL_EXPORT_TEXT
(
    on execute do
    (
        if LcL_QuickExport != undefined then
            LcL_QuickExport()
        else
        (
            LcL_LoadCoreModules()
            if LcL_QuickExport != undefined then
                LcL_QuickExport()
            else
                messageBox "无法加载导出功能！" title:LCL_ERROR_TITLE
        )
    )
)

-- 3. 从Blender导入
macroScript LcL_ImportFromBlender
category:LCL_MENU_CATEGORY
toolTip:"从Blender导入模型"
buttonText:LCL_IMPORT_TEXT
(
    on execute do
    (
        if LcL_QuickImport != undefined then
            LcL_QuickImport()
        else
        (
            LcL_LoadCoreModules()
            if LcL_QuickImport != undefined then
                LcL_QuickImport()
            else
                messageBox "无法加载导入功能！" title:LCL_ERROR_TITLE
        )
    )
)

-- 4. 可视化工具面板
macroScript LcL_VisualTools
category:LCL_MENU_CATEGORY
toolTip:LCL_VISUAL_TOOLTIP
buttonText:LCL_VISUAL_TEXT
(
    on execute do
    (
        LcL_LoadCoreModules()
        
        if LcL_ShowVisualDialog != undefined then
            LcL_ShowVisualDialog()
        else
            messageBox "无法加载可视化工具！" title:LCL_ERROR_TITLE
    )
)

-- 5. 同步设置
macroScript LcL_SyncSettings
category:LCL_MENU_CATEGORY
toolTip:LCL_SETTINGS_TOOLTIP
buttonText:LCL_SETTINGS_TEXT
(
    on execute do
    (
        LcL_LoadCoreModules()
        
        if LcL_ShowSettingsDialog != undefined then
            LcL_ShowSettingsDialog()
        else
            messageBox "无法加载设置界面！" title:LCL_ERROR_TITLE
    )
)

-- 6. 快速顶点色切换
macroScript LcL_QuickVertexColors
category:LCL_MENU_CATEGORY
toolTip:"快速切换选中对象的顶点色显示"
buttonText:"VC"
(
    on execute do
    (
        if selection.count == 0 then
        (
            messagebox "请先选择一个物体" title:"提示"
            return false
        )
        
        try
        (
            $.showVertexColors = not $.showVertexColors
            $.vertexColorsShaded = $.showVertexColors
            
            local statusText = if $.showVertexColors then "开启" else "关闭"
            format "顶点色显示已%\n" statusText
        )
        catch
        (
            messageBox "切换顶点色显示失败" title:"错误"
        )
    )
)

-- 7. 快速顶点索引显示
macroScript LcL_QuickVertexIndex
category:LCL_MENU_CATEGORY
toolTip:"快速切换顶点索引显示"
buttonText:"Vertex Index"
(
    on execute do
    (
        LcL_LoadCoreModules()
        
        if LcL_ToggleVertexIndex != undefined then
        (
            LcL_ToggleVertexIndex()
            local state = if LcL_GetVertexIndexState != undefined then LcL_GetVertexIndexState() else false
            format "顶点索引显示: %\n" (if state then "开启" else "关闭")
        )
        else
            messageBox "顶点索引功能未加载" title:LCL_ERROR_TITLE
    )
)

-- 8. 快速面索引显示
macroScript LcL_QuickFaceIndex
category:LCL_MENU_CATEGORY
toolTip:"快速切换面索引显示"
buttonText:"Face Index"
(
    on execute do
    (
        LcL_LoadCoreModules()
        
        if LcL_ToggleFaceIndex != undefined then
        (
            LcL_ToggleFaceIndex()
            local state = if LcL_GetFaceIndexState != undefined then LcL_GetFaceIndexState() else false
            format "面索引显示: %\n" (if state then "开启" else "关闭")
        )
        else
            messageBox "面索引功能未加载" title:LCL_ERROR_TITLE
    )
)

-- 9. 快速显示顶点色（不含着色）
macroScript LcL_ShowVertexColor
category:LCL_MENU_CATEGORY
toolTip:"快速显示/隐藏顶点色"
buttonText:"Show Vertex Color"
(
    on execute do
    (
        if selection.count == 0 then
        (
            messagebox "请先选择一个物体" title:"提示"
            return false
        )
        
        try
        (
            $.showVertexColors = not $.showVertexColors
            local statusText = if $.showVertexColors then "开启" else "关闭"
            format "顶点色显示已%\n" statusText
        )
        catch
        (
            messageBox "切换顶点色显示失败" title:"错误"
        )
    )
)

-- 10. 快速顶点色着色
macroScript LcL_VertexColorShaded
category:LCL_MENU_CATEGORY
toolTip:"快速切换顶点色着色模式"
buttonText:"Vertex Color Shaded"
(
    on execute do
    (
        if selection.count == 0 then
        (
            messagebox "请先选择一个物体" title:"提示"
            return false
        )
        
        try
        (
            -- 如果要开启着色模式，先确保顶点色显示开启
            if not $.vertexColorsShaded and not $.showVertexColors then
                $.showVertexColors = true
                
            $.vertexColorsShaded = not $.vertexColorsShaded
            local statusText = if $.vertexColorsShaded then "开启" else "关闭"
            format "顶点色着色已%\n" statusText
        )
        catch
        (
            messageBox "切换顶点色着色失败" title:"错误"
        )
    )
)

-- ===== 菜单管理函数 =====

-- 删除旧菜单
fn LcL_RemoveMenu = 
(
    mainMenuBar = menuMan.getMainMenuBar()
    
    for i = mainMenuBar.numItems() to 1 by -1 do
    (
        menuItem = mainMenuBar.getItem i
        if menuItem.getTitle() == LCL_MENU_TITLE then
        (
            mainMenuBar.removeItem menuItem
            format "清理旧菜单: %\n" LCL_MENU_TITLE
        )
    )
    
    menuMan.updateMenuBar()
)

-- 创建完整的菜单结构
fn LcL_CreateMenu = 
(
    LcL_RemoveMenu()
    
    -- 获取主菜单栏并创建菜单
    mainMenuBar = menuMan.getMainMenuBar()
    lclMenu = menuMan.createMenu LCL_MENU_TITLE
    
    -- 创建各功能的Action
    mainAction = menuMan.createActionItem "LcL_MainTools" LCL_MENU_CATEGORY
    exportAction = menuMan.createActionItem "LcL_ExportToBlender" LCL_MENU_CATEGORY
    importAction = menuMan.createActionItem "LcL_ImportFromBlender" LCL_MENU_CATEGORY
    
    -- 可视化功能Actions
    showVCAction = menuMan.createActionItem "LcL_ShowVertexColor" LCL_MENU_CATEGORY
    vertexIdxAction = menuMan.createActionItem "LcL_QuickVertexIndex" LCL_MENU_CATEGORY
    faceIdxAction = menuMan.createActionItem "LcL_QuickFaceIndex" LCL_MENU_CATEGORY
    
    -- 构建菜单结构
    lclMenu.addItem mainAction -1                    -- 主界面
    lclMenu.addItem (menuMan.createSeparatorItem()) -1   -- 分隔线
    
    -- 同步功能组
    lclMenu.addItem exportAction -1                  -- Max To Blender
    lclMenu.addItem importAction -1                  -- Blender To Max 
    lclMenu.addItem (menuMan.createSeparatorItem()) -1   -- 分隔线
    
    -- 可视化功能组
    lclMenu.addItem showVCAction -1                  -- Show Vertex Color
    lclMenu.addItem vertexIdxAction -1               -- Vertex Index
    lclMenu.addItem faceIdxAction -1                 -- Face Index
    
    -- 添加到菜单栏
    lclMenuItem = menuMan.createSubMenuItem LCL_MENU_TITLE lclMenu
    mainMenuBar.addItem lclMenuItem -1
    menuMan.updateMenuBar()
    
    format "✅ LcL Tools 菜单创建完成 (完整版: 8个快捷功能)\n"
)

-- 自动创建菜单
LcL_CreateMenu()

format "✅ LcL Tools 主程序加载完成\n"
