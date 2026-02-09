-- LcL Tools - 同步导出核心功能
-- 基于SyncBlender改写，专门处理Max到Blender的导出

-- 全局变量 - 使用系统临时目录
global LcL_TempDir = (sysInfo.tempdir + "LcL_Tools_Exchange\\")

-- 导出设置结构
struct LcL_SyncConfig
(
    tempDir = LcL_TempDir,
    exportFile = LcL_TempDir + "export_model.fbx",
    includeAnimation = true,  
    openFolderAfter = true
)

-- 全局配置实例
global lclSyncConfig = LcL_SyncConfig()

-- 设置FBX导出参数
fn LcL_SetupFBXExport = 
(
    -- 获取用户设置，如果未定义则使用默认值
    local exportSettings = LcL_ExportSettings
    if exportSettings == undefined then
    (
        format "⚠ 导出设置未加载，使用默认设置\n"
        -- 如果结构未定义，创建临时结构
        if LcL_ExportConfig == undefined then
        (
            struct TempExportConfig
            (
                includeAnimation = true,
                fileFormat = "Binary",
                convertUnit = "cm",
                upAxis = "Y",
                bakeAnimation = true
            )
            exportSettings = TempExportConfig()
        )
        else
        (
            exportSettings = LcL_ExportConfig()
            exportSettings.includeAnimation = true
            exportSettings.fileFormat = "Binary"
            exportSettings.convertUnit = "cm"
            exportSettings.upAxis = "Y"
            exportSettings.bakeAnimation = true
        )
    )
    
    -- 设置动画相关参数
    FBXExporterSetParam "Animation" exportSettings.includeAnimation
    FBXExporterSetParam "BakeAnimation" exportSettings.bakeAnimation
    if exportSettings.includeAnimation then
    (
        FBXExporterSetParam "BakeFrameStart" animationRange.start.frame
        FBXExporterSetParam "BakeFrameEnd" animationRange.end.frame
    )
    
    -- 使用用户设置的单位和轴向（转换为符号格式）
    local unitSymbol = if exportSettings.convertUnit == "cm" then #cm else #m
    local axisSymbol = if exportSettings.upAxis == "Y" then #Y else #Z
    local formatSymbol = if exportSettings.fileFormat == "Binary" then #binary else #ascii
    
    FBXExporterSetParam "ConvertUnit" unitSymbol
    FBXExporterSetParam "UpAxis" axisSymbol
    FBXExporterSetParam "FileFormat" formatSymbol
    FBXExporterSetParam "ASCIIFormat" "6.0"
    
    -- 关键设置：只导出可见对象
    FBXExporterSetParam "FilterKeyReducer" false
    FBXExporterSetParam "NormalsPerVertex" true
    FBXExporterSetParam "TangentSpaceExport" true
    
    -- 尝试设置只导出可见对象
    try (FBXExporterSetParam "ExportHiddenObjects" false) catch()
    try (FBXExporterSetParam "IncludeHidden" false) catch()
    
    return true
)

-- 创建临时文件夹
fn LcL_CreateTempDir = 
(
    makeDir lclSyncConfig.tempDir
    return true
)

-- 核心导出函数
fn LcL_ExportFBX = 
(
    -- 创建临时文件夹
    LcL_CreateTempDir()
    
    -- 设置FBX参数
    LcL_SetupFBXExport()
    
    -- 确保过滤函数和设置存在
    if LcL_ShouldFilterObject == undefined then
    (
        format "⚠ 过滤函数未加载，尝试加载设置文件...\n"
        -- 尝试加载设置文件
        pluginPath = getFilenamePath (getThisScriptFilename())
        -- 获取上两级目录到ui
        parentDir = getFilenamePath (substring pluginPath 1 (pluginPath.count - 1))
        parentDir = getFilenamePath (substring parentDir 1 (parentDir.count - 1))
        settingsFile = parentDir + "ui\\SettingsUI.ms"
        if doesFileExist settingsFile then
            fileIn settingsFile
        
        -- 如果仍然未定义，创建临时空过滤函数
        if LcL_ShouldFilterObject == undefined then
        (
            format "⚠ 无法加载过滤设置，使用空过滤函数\n"
            fn LcL_ShouldFilterObject obj = false
        )
        else
        (
            format "✅ 过滤函数已加载\n"
        )
    )
    
    -- 应用过滤设置 - 创建需要导出的对象选择集
    totalObjects = objects.count
    filteredCount = 0
    exportObjects = #()
    
    -- 收集需要导出的对象
    for obj in objects do
    (
        if LcL_ShouldFilterObject obj then
            filteredCount += 1
        else
            append exportObjects obj
    )
    
    exportCount = totalObjects - filteredCount
    format "🚀 开始导出对象到: %\n" lclSyncConfig.exportFile
    format "📊 总对象: % 个，过滤: % 个，导出: % 个\n" totalObjects filteredCount exportCount
    
    -- 备份当前选择
    oldSelection = selection as array
    
    -- 选中要导出的对象
    select exportObjects
    
    -- 执行导出 - 只导出选中对象
    exportFile lclSyncConfig.exportFile #noPrompt selectedOnly:true
    
    -- 恢复原始选择
    select oldSelection
    
    -- 成功提示
    format "✅ 导出成功！\n"
    format "📁 文件位置: %\n" lclSyncConfig.exportFile
    format "📊 实际导出: % 个对象\n" exportCount
    
    return true
)

-- 快速导出函数（M2B - Max to Blender）
fn LcL_QuickExport = 
(
    result = LcL_ExportFBX()
    
    if result then
    (
        -- 显示简洁的成功提示
        messageBox "已发送到Blender" title:"LcL Tools"
    )
    
    return result
)

-- 获取导出信息
fn LcL_GetExportInfo = 
(
    info = ""
    info += "临时文件夹: " + lclSyncConfig.tempDir + "\n"
    info += "导出文件: " + (filenameFromPath lclSyncConfig.exportFile) + "\n"
    
    -- 根据设置显示信息
    if LcL_ExportSettings != undefined then
    (
        info += "包含动画: " + (if LcL_ExportSettings.includeAnimation then "是" else "否") + "\n"
        info += "文件格式: " + LcL_ExportSettings.fileFormat + "\n"
        info += "单位转换: " + LcL_ExportSettings.convertUnit + "\n"
        info += "向上轴: " + LcL_ExportSettings.upAxis + "\n"
    )
    else
    (
        info += "包含动画: 是（默认）\n"
        info += "文件格式: Binary（默认）\n"
        info += "单位转换: cm（默认）\n"
        info += "向上轴: Y（默认）\n"
    )
    
    info += "当前选择: " + selection.count as string + " 个对象\n"
    
    return info
)

format "✅ LcL Tools 同步导出核心加载完成\n"