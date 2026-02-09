-- LcL Tools - 同步导入核心功能
-- 基于SyncBlender改写，专门处理Blender到Max的导入

-- 导入FBX函数
fn LcL_ImportFBX = 
(
    -- 使用与导出相同的临时目录和文件
    local fbxFilePath = ""
    if lclSyncConfig == undefined then
    (
        format "⚠ 导出配置未加载，使用默认路径\n"
        local tempDir = (sysInfo.tempdir + "LcL_Tools_Exchange\\")
        fbxFilePath = tempDir + "export_model.fbx"
    )
    else
    (
        fbxFilePath = lclSyncConfig.exportFile
    )
    
    -- 检查FBX文件是否存在
    if not (doesFileExist fbxFilePath) then
    (
        errorMsg = "未找到FBX文件！\n\n请先从Blender导出文件到：\n" + fbxFilePath
        messageBox errorMsg title:"文件不存在"
        return false
    )
    
    format "🚀 开始导入FBX文件: %\n" fbxFilePath
    
    -- 简化导入，使用FBXIMP导入器
    try
    (
        importFile fbxFilePath #noPrompt using:FBXIMP
        format "✅ 导入成功！\n"
        format "📁 文件位置: %\n" fbxFilePath
    )
    catch
    (
        format "❌ 导入失败: %\n" (getCurrentException())
        return false
    )
    
    return true
)

-- 快速导入函数（B2M - Blender to Max）
fn LcL_QuickImport = 
(
    result = LcL_ImportFBX()
    
    -- 导入成功时不弹窗，只在监听器输出信息
    if result then
    (
        local fileName = if lclSyncConfig != undefined then 
            (filenameFromPath lclSyncConfig.exportFile) 
        else 
            "export_model.fbx"
        format "📥 导入完成：%\n" fileName
    )
    
    return result
)

-- 获取导入信息
fn LcL_GetImportInfo = 
(
    info = ""
    
    local importFile = if lclSyncConfig != undefined then 
        lclSyncConfig.exportFile 
    else 
        ((sysInfo.tempdir + "LcL_Tools_Exchange\\") + "export_model.fbx")
        
    info += "导入文件: " + (filenameFromPath importFile) + "\n"
    info += "文件路径: " + importFile + "\n"
    
    if (doesFileExist importFile) then
    (
        fileInfo = getFileSize importFile
        info += "文件大小: " + (fileInfo / 1024.0) as string + " KB\n"
        info += "文件状态: 存在\n"
    )
    else
    (
        info += "文件状态: 不存在\n"
    )
    
    return info
)

format "✅ LcL Tools 同步导入核心加载完成\n"