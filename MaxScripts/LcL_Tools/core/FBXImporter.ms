-- FBX导入工具 - 优化版
-- 支持用户输入路径和文件浏览

-- 全局变量存储最后使用的路径
if g_lastFBXPath == undefined do
    global g_lastFBXPath = "E:\\Temp\\output.fbx"

-- 导入FBX文件的核心函数
fn ImportFBXFile filePath =
(
    -- 检查文件是否存在
    if doesFileExist filePath then
    (
        try
        (
            -- 导入FBX文件
            importFile filePath #noPrompt using:FBXIMP
            messagebox ("✅ 成功导入FBX文件:\n" + filePath) title:"导入成功"
            
            -- 更新最后使用的路径
            g_lastFBXPath = filePath
            
            return true
        )
        catch (e)
        (
            messagebox ("❌ 导入FBX文件失败:\n" + filePath + "\n\n错误信息:\n" + e as string) title:"导入失败"
            return false
        )
    )
    else
    (
        messagebox ("❌ 文件不存在:\n" + filePath) title:"文件不存在"
        return false
    )
)

-- 静默导入FBX文件（成功时不弹窗）
fn ImportFBXFileSilent filePath =
(
    try
    (
        -- 直接导入FBX文件，不做过多检查
        importFile filePath #noPrompt using:FBXIMP
        
        -- 更新最后使用的路径
        g_lastFBXPath = filePath
        
        -- 在监听器中输出成功信息，但不弹窗
        format "✅ 导入完成: %\n" filePath
        
        return true
    )
    catch
    (
        -- 导入失败时简单提示
        messagebox ("导入失败: " + (getFilenameFile filePath)) title:"导入错误"
        return false
    )
)

-- 使用默认路径导入
fn ImportDefaultFBX =
(
    ImportFBXFile g_lastFBXPath
)

-- 浏览并导入FBX文件
fn BrowseAndImportFBX =
(
    -- 获取当前路径的目录作为初始目录
    initialDir = getFilenamePath g_lastFBXPath
    if not doesDirectoryExist initialDir then
        initialDir = "C:\\"
    
    -- 打开文件浏览对话框
    fbxFile = getOpenFileName \
        caption:"选择要导入的FBX文件" \
        types:"FBX文件 (*.fbx)|*.fbx|所有文件 (*.*)|*.*|" \
        initialDir:initialDir
    
    if fbxFile != undefined then
    (
        ImportFBXFile fbxFile
    )
)

-- 从用户输入的路径导入
fn ImportFromUserPath userPath =
(
    if userPath != undefined and userPath != "" then
    (
        -- 处理路径格式
        cleanPath = substituteString userPath "/" "\\"
        
        -- 如果没有扩展名，自动添加.fbx
        if getFilenameType cleanPath == "" then
            cleanPath = cleanPath + ".fbx"
        
        ImportFBXFile cleanPath
    )
    else
    (
        messagebox "请输入有效的文件路径" title:"路径错误"
    )
)

-- 获取最近使用的路径
fn GetRecentFBXPath =
(
    return g_lastFBXPath
)

-- 设置默认路径
fn SetDefaultFBXPath newPath =
(
    if newPath != undefined and newPath != "" then
        g_lastFBXPath = newPath
)
