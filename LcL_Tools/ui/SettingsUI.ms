-- LcL Tools 设置界面
-- 基于SyncBlender改写，用于配置同步和过滤规则

-- 全局设置变量，默认填充过滤列表
global LcL_FilterSettings = #("Camera", "pickshape")
global LcL_ExportSettings = undefined
global LcL_SettingsDialog = undefined

-- 导出设置结构
struct LcL_ExportConfig
(
    includeAnimation = true,
    fileFormat = "Binary",     -- "Binary" 或 "ASCII"
    convertUnit = "cm",        -- "cm" 或 "m"
    upAxis = "Y",             -- "Y" 或 "Z"
    bakeAnimation = true
)

-- 颜色设置结构
struct LcL_ColorConfig
(
    vertexIndexColor = [255,255,0],    -- 顶点索引颜色（黄色）
    faceIndexColor = [0,255,255],      -- 面索引颜色（青色）
    vertexIndexEnabled = false,        -- 顶点索引开关状态
    faceIndexEnabled = false           -- 面索引开关状态
)

-- 全局颜色设置变量
global LcL_ColorSettings = undefined

-- 初始化默认设置
fn LcL_InitDefaultSettings = 
(
    -- 强制初始化过滤设置，确保默认值存在
    global LcL_FilterSettings = #("Camera", "pickshape")
    format "✅ 初始化默认过滤设置: %\n" LcL_FilterSettings
    
    -- 初始化导出设置
    if LcL_ExportSettings == undefined then
    (
        global LcL_ExportSettings = LcL_ExportConfig()
        format "✅ 初始化默认导出设置\n"
    )
    
    -- 初始化颜色设置
    if LcL_ColorSettings == undefined then
    (
        global LcL_ColorSettings = LcL_ColorConfig()
        -- 同步到索引显示模块
        if LcL_VertexIndexColor != undefined then
        (
            global LcL_VertexIndexColor = LcL_ColorSettings.vertexIndexColor
            global LcL_FaceIndexColor = LcL_ColorSettings.faceIndexColor
        )
        format "✅ 初始化默认颜色设置\n"
    )
)

-- 保存所有设置到文件
fn LcL_SaveAllSettings = 
(
    settingsFile = (sysInfo.tempdir + "LcL_Tools_Settings.ini")
    fileOut = createFile settingsFile
    if fileOut != undefined then
    (
        -- 保存导出设置
        format "# LcL Tools Settings\n" to:fileOut
        format "[Export]\n" to:fileOut
        format "includeAnimation=%\n" LcL_ExportSettings.includeAnimation to:fileOut
        format "fileFormat=%\n" LcL_ExportSettings.fileFormat to:fileOut
        format "convertUnit=%\n" LcL_ExportSettings.convertUnit to:fileOut
        format "upAxis=%\n" LcL_ExportSettings.upAxis to:fileOut
        format "bakeAnimation=%\n" LcL_ExportSettings.bakeAnimation to:fileOut
        
        -- 保存过滤设置
        format "[Filter]\n" to:fileOut
        for filter in LcL_FilterSettings do
        (
            format "filter=%\n" filter to:fileOut
        )
        
        -- 保存颜色设置
        format "[Colors]\n" to:fileOut
        format "vertexIndexColor=%,%,%\n" LcL_ColorSettings.vertexIndexColor[1] LcL_ColorSettings.vertexIndexColor[2] LcL_ColorSettings.vertexIndexColor[3] to:fileOut
        format "faceIndexColor=%,%,%\n" LcL_ColorSettings.faceIndexColor[1] LcL_ColorSettings.faceIndexColor[2] LcL_ColorSettings.faceIndexColor[3] to:fileOut
        format "vertexIndexEnabled=%\n" LcL_ColorSettings.vertexIndexEnabled to:fileOut
        format "faceIndexEnabled=%\n" LcL_ColorSettings.faceIndexEnabled to:fileOut
        close fileOut
        format "✅ 所有设置已保存到: %\n" settingsFile
    )
)

-- 加载所有设置文件
fn LcL_LoadAllSettings = 
(
    settingsFile = (sysInfo.tempdir + "LcL_Tools_Settings.ini")
    if doesFileExist settingsFile then
    (
        fileIn = openFile settingsFile
        if fileIn != undefined then
        (
            LcL_FilterSettings = #()
            if LcL_ExportSettings == undefined then
                global LcL_ExportSettings = LcL_ExportConfig()
            if LcL_ColorSettings == undefined then
                global LcL_ColorSettings = LcL_ColorConfig()
            
            currentSection = ""
            while not eof fileIn do
            (
                line = readLine fileIn
                line = trimLeft (trimRight line)
                
                if line != "" and line[1] != "#" then
                (
                    -- 检查是否是节标题
                    if line[1] == "[" and line[line.count] == "]" then
                    (
                        currentSection = substring line 2 (line.count - 2)
                    )
                    else
                    (
                        -- 解析键值对
                        eqPos = findString line "="
                        if eqPos != undefined then
                        (
                            key = trimRight (substring line 1 (eqPos - 1))
                            value = trimLeft (substring line (eqPos + 1) -1)
                            
                            if currentSection == "Export" then
                            (
                                case key of
                                (
                                    "includeAnimation": LcL_ExportSettings.includeAnimation = (value == "true")
                                    "fileFormat": LcL_ExportSettings.fileFormat = value
                                    "convertUnit": LcL_ExportSettings.convertUnit = value
                                    "upAxis": LcL_ExportSettings.upAxis = value
                                    "bakeAnimation": LcL_ExportSettings.bakeAnimation = (value == "true")
                                )
                            )
                            else if currentSection == "Filter" then
                            (
                                if key == "filter" then
                                    append LcL_FilterSettings value
                            )
                            else if currentSection == "Colors" then
                            (
                                case key of
                                (
                                    "vertexIndexColor": (
                                        local colorValues = filterString value ","
                                        if colorValues.count == 3 then
                                            LcL_ColorSettings.vertexIndexColor = [colorValues[1] as integer, colorValues[2] as integer, colorValues[3] as integer]
                                    )
                                    "faceIndexColor": (
                                        local colorValues = filterString value ","
                                        if colorValues.count == 3 then
                                            LcL_ColorSettings.faceIndexColor = [colorValues[1] as integer, colorValues[2] as integer, colorValues[3] as integer]
                                    )
                                    "vertexIndexEnabled": LcL_ColorSettings.vertexIndexEnabled = (value == "true")
                                    "faceIndexEnabled": LcL_ColorSettings.faceIndexEnabled = (value == "true")
                                )
                            )
                        )
                    )
                )
            )
            close fileIn
            format "✅ 设置已加载: % 个过滤规则\n" LcL_FilterSettings.count
        )
    )
    else
    (
        LcL_InitDefaultSettings()
    )
)

-- 兼容性函数
fn LcL_SaveSettings = LcL_SaveAllSettings
fn LcL_LoadSettings = LcL_LoadAllSettings

-- 检查对象是否应该被过滤
fn LcL_ShouldFilterObject obj = 
(
    -- 确保全局设置存在
    if LcL_FilterSettings == undefined or LcL_FilterSettings.count == 0 then
        return false
        
    objName = obj.name as string
    for filter in LcL_FilterSettings do
    (
        if matchPattern objName pattern:("*" + filter + "*") ignoreCase:true then
        (
            format "🔍 过滤对象: % (匹配: %)\n" objName filter
            return true
        )
    )
    return false
)

-- ===== 优化后的设置对话框 =====

rollout LcL_SettingsRollout "LcL Tools 设置" width:400 height:350
(
    -- 导出设置组（精简版）
    group "FBX 导出设置"
    (
        checkbox chk_animation "包含动画数据" checked:true width:180
        radioButtons rad_fileFormat "格式:" labels:#("二进制", "ASCII") default:1 columns:2
        radioButtons rad_unit "单位:" labels:#("厘米", "米") default:1 columns:2
        radioButtons rad_upAxis "轴向:" labels:#("Y轴向上", "Z轴向上") default:1 columns:2
    )
    
    -- 过滤设置组（简化版）
    group "对象过滤 (按名称关键词)"
    (
        listBox lst_filters height:5 items:#()
        
        editText edt_newFilter "" width:240 across:2 tooltip:"输入要过滤的对象名称关键词"
        button btn_addFilter "添加" width:50 tooltip:"添加过滤关键词"
        
        button btn_removeFilter "删除" width:70 across:3 tooltip:"删除选中的过滤词"
        button btn_clear "清空" width:70 tooltip:"清空所有过滤词"
        button btn_reset "默认" width:70 tooltip:"重置为默认过滤设置"
    )
    
    -- 信息和操作
    group ""
    (
        label lbl_status "" width:300 height:20 align:#center
        
        button btn_save "保存并关闭" width:120 height:28 across:2
        button btn_cancel "取消" width:120 height:28
    )
    
    -- ===== 界面更新函数（优化版）=====
    
    fn updateUI = 
    (
        -- 更新过滤列表显示
        if LcL_FilterSettings != undefined and LcL_FilterSettings.count > 0 then
            lst_filters.items = LcL_FilterSettings
        else
            lst_filters.items = #()
        
        -- 更新导出设置显示
        if LcL_ExportSettings != undefined then
        (
            chk_animation.checked = LcL_ExportSettings.includeAnimation
            rad_fileFormat.state = if LcL_ExportSettings.fileFormat == "Binary" then 1 else 2
            rad_unit.state = if LcL_ExportSettings.convertUnit == "cm" then 1 else 2
            rad_upAxis.state = if LcL_ExportSettings.upAxis == "Y" then 1 else 2
        )
        
        
        -- 更新状态信息
        local filterCount = if LcL_FilterSettings != undefined then LcL_FilterSettings.count else 0
        lbl_status.text = "当前有 " + filterCount as string + " 个过滤规则"
    )
    
    fn updateSettingsFromUI = 
    (
        if LcL_ExportSettings != undefined then
        (
            LcL_ExportSettings.includeAnimation = chk_animation.checked
            LcL_ExportSettings.fileFormat = if rad_fileFormat.state == 1 then "Binary" else "ASCII"
            LcL_ExportSettings.convertUnit = if rad_unit.state == 1 then "cm" else "m"
            LcL_ExportSettings.upAxis = if rad_upAxis.state == 1 then "Y" else "Z"
            LcL_ExportSettings.bakeAnimation = chk_animation.checked
        )
        
    )
    
    -- ===== 事件处理（优化版）=====
    
    on LcL_SettingsRollout open do
    (
        -- 确保全局变量初始化
        if LcL_FilterSettings == undefined or LcL_FilterSettings.count == 0 then
            global LcL_FilterSettings = #("Camera", "pickshape")
        if LcL_ExportSettings == undefined then
            global LcL_ExportSettings = LcL_ExportConfig()
        if LcL_ColorSettings == undefined then
            global LcL_ColorSettings = LcL_ColorConfig()
        
        updateUI()
        format "设置界面已打开\n"
    )
    
    -- 导出设置实时更新
    on chk_animation changed state do updateSettingsFromUI()
    on rad_fileFormat changed state do updateSettingsFromUI()
    on rad_unit changed state do updateSettingsFromUI()
    on rad_upAxis changed state do updateSettingsFromUI()
    
    
    -- 过滤词管理
    on btn_addFilter pressed do
    (
        local newFilter = trimLeft (trimRight edt_newFilter.text)
        if newFilter != "" then
        (
            if findItem LcL_FilterSettings newFilter == 0 then
            (
                append LcL_FilterSettings newFilter
                edt_newFilter.text = ""
                updateUI()
                lbl_status.text = "已添加: " + newFilter
            )
            else
            (
                lbl_status.text = "过滤词已存在: " + newFilter
            )
        )
        else
        (
            lbl_status.text = "请输入过滤关键词"
        )
    )
    
    -- 回车快速添加
    on edt_newFilter entered text do
    (
        local newFilter = trimLeft (trimRight text)
        if newFilter != "" and findItem LcL_FilterSettings newFilter == 0 then
        (
            append LcL_FilterSettings newFilter
            edt_newFilter.text = ""
            updateUI()
            lbl_status.text = "已添加: " + newFilter
        )
    )
    
    -- 删除选中项
    on btn_removeFilter pressed do
    (
        if lst_filters.selection > 0 then
        (
            local removedFilter = LcL_FilterSettings[lst_filters.selection]
            deleteItem LcL_FilterSettings lst_filters.selection
            updateUI()
            lbl_status.text = "已删除: " + removedFilter
        )
        else
        (
            lbl_status.text = "请先选择要删除的项目"
        )
    )
    
    -- 清空所有
    on btn_clear pressed do
    (
        if queryBox "确定清空所有过滤设置？" title:"确认" then
        (
            LcL_FilterSettings = #()
            updateUI()
            lbl_status.text = "已清空所有过滤规则"
        )
    )
    
    -- 重置默认
    on btn_reset pressed do
    (
        if queryBox "重置为默认过滤设置？" title:"确认" then
        (
            LcL_FilterSettings = #("Camera", "pickshape")
            updateUI()
            lbl_status.text = "已重置为默认设置"
        )
    )
    
    -- 保存并关闭
    on btn_save pressed do
    (
        updateSettingsFromUI()
        LcL_SaveSettings()
        lbl_status.text = "设置已保存"
        LcL_CloseSettingsDialog()
    )
    
    -- 取消
    on btn_cancel pressed do
    (
        LcL_CloseSettingsDialog()
    )
)

-- 显示设置对话框
fn LcL_ShowSettingsDialog = 
(
    -- 确保全局变量已定义
    if LcL_FilterSettings == undefined then
        global LcL_FilterSettings = #("Camera", "pickshape")
    if LcL_ColorSettings == undefined then
    (
        global LcL_ColorSettings = LcL_ColorConfig()
        global LcL_VertexIndexColor = LcL_ColorSettings.vertexIndexColor
        global LcL_FaceIndexColor = LcL_ColorSettings.faceIndexColor
    )
    
    -- 如果对话框已存在，关闭它
    if LcL_SettingsDialog != undefined then
    (
        -- 检查是否是有效的对话框对象
        if (isKindOf LcL_SettingsDialog RolloutFloater) or (isKindOf LcL_SettingsDialog DialogBox) then
            destroyDialog LcL_SettingsDialog
        else
            format "⚠ 清理无效的对话框状态\n"
            
        LcL_SettingsDialog = undefined
    )
    
    -- 创建新对话框
    LcL_SettingsDialog = createDialog LcL_SettingsRollout modal:false
    format "✅ LcL Tools设置界面已打开\n"
)

-- 关闭设置对话框
fn LcL_CloseSettingsDialog = 
(
    if LcL_SettingsDialog != undefined then
    (
        -- 检查是否是有效的对话框对象
        if (isKindOf LcL_SettingsDialog RolloutFloater) or (isKindOf LcL_SettingsDialog DialogBox) then
        (
            destroyDialog LcL_SettingsDialog
            format "✅ LcL Tools设置界面已关闭\n"
        )
        else
        (
            format "⚠ 清理无效的对话框状态\n"
        )
        
        LcL_SettingsDialog = undefined
    )
)

-- 初始化设置
LcL_LoadSettings()

-- 同步颜色设置到索引显示模块
if LcL_ColorSettings != undefined then
(
    if LcL_VertexIndexColor == undefined then global LcL_VertexIndexColor = LcL_ColorSettings.vertexIndexColor
    if LcL_FaceIndexColor == undefined then global LcL_FaceIndexColor = LcL_ColorSettings.faceIndexColor
    global LcL_VertexIndexColor = LcL_ColorSettings.vertexIndexColor
    global LcL_FaceIndexColor = LcL_ColorSettings.faceIndexColor
)

format "✅ LcL Tools 设置功能加载完成\n"
