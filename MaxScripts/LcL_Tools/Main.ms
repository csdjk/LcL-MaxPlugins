-- LcL工具集合主面板
macroScript LcL_Tools
category:"LcL"
toolTip:"LcL工具集合"
Icon:#("button", 1)
(
    pluginPath = GetDir #maxroot + "Plugins\\LcL_Tools\\"

    -- 定义目标目录
    targetDirectory = pluginPath + "core\\"

    -- 获取目标目录下的所有 .ms 文件
    fileList = getFiles (targetDirectory + "*.ms")

    -- 遍历并 fileIn 每个文件
    for file in fileList do
    (
        filein file
    )

    targetFilePath = pluginPath + "ui/MainUI.ms"
    filein targetFilePath

    fn PluginAction =
    (
        Create_LcL_Tools_Dialog()
    )

    PluginAction()
)

-- FBX快速导入工具
macroScript LcL_FBXImporter
category:"LcL"
toolTip:"FBX快速导入"
buttonText:"Import"
(
    -- 直接导入，不依赖外部文件
    defaultPath = "E:\\Temp\\output.fbx"
    
    if doesFileExist defaultPath then
    (
        try
        (
            -- 直接导入FBX文件
            importFile defaultPath #noPrompt using:FBXIMP
            
            -- 成功时在监听器输出信息，不弹窗
            format "✅ 导入完成: %\n" (getFilenameFile defaultPath)
        )
        catch
        (
            -- 失败时弹窗
            messagebox ("导入失败: " + (getFilenameFile defaultPath)) title:"导入错误"
        )
    )
    else
    (
        messagebox ("文件不存在: " + defaultPath) title:"文件不存在"
    )
)

-- 顶点色显示工具
macroScript LcL_VertexColors
category:"LcL"
toolTip:"切换顶点色显示"
buttonText:"VC"
(
    try
    (
        if selection.count == 0 then
        (
            messagebox "请先选择一个物体再切换顶点色显示" title:"提示"
            return()
        )
        
        if viewport.getType() != #view_none then
        (
            -- 切换顶点色显示状态
            $.showVertexColors = not $.showVertexColors
            $.vertexColorsShaded = $.showVertexColors
            
            if $.showVertexColors then
                format "✅ 顶点色显示已开启\n"
            else
                format "❌ 顶点色显示已关闭\n"
        )
        else
        (
            messagebox "请先激活一个视口" title:"提示"
        )
    )
    catch
    (
        messagebox "切换顶点色显示失败，可能当前物体不支持此功能" title:"错误"
    )
)

-- 顶点索引显示工具
macroScript LcL_VertexIndex
category:"LcL"
toolTip:"切换顶点索引显示"
buttonText:"VI"
(
    try
    (
        LcL_ToggleVertexIndex()
    )
    catch
    (
        format "⚠️ 切换顶点索引显示失败\n"
    )
)

-- 面索引显示工具
macroScript LcL_FaceIndex
category:"LcL"
toolTip:"切换面索引显示"
buttonText:"FI"
(
    try
    (
        LcL_ToggleFaceIndex()
    )
    catch
    (
        format "⚠️ 切换面索引显示失败\n"
    )
)
