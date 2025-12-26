rollout ToolsRollout "可视化工具" width:270
(
    group "顶点色可视化"
    (
        checkbox chkShowVertexColors "显示顶点色" width:180 height:20 align:#left
        checkbox chkVertexColorsShaded "顶点色着色" width:180 height:20 align:#left
    )
    
    group "Vertex Index可视化"
    (
        checkbox chkShowVertexIndex "显示顶点索引" width:180 height:20 align:#left
        checkbox chkShowFaceIndex "显示面索引" width:180 height:20 align:#left
    )
    
    
    -- 显示顶点色事件
    on chkShowVertexColors changed state do
    (
        try
        (
            if selection.count == 0 then
            (
                messagebox "请先选择一个物体再设置顶点色显示" title:"提示"
                chkShowVertexColors.checked = false
                return()
            )
            
            if viewport.getType() != #view_none then
            (
                $.showVertexColors = state
                if state then
                    format "✅ 顶点色显示已开启\n"
                else
                    format "❌ 顶点色显示已关闭\n"
            )
            else
            (
                messagebox "请先激活一个视口" title:"提示"
                chkShowVertexColors.checked = false
            )
        )
        catch
        (
            messagebox "设置顶点色显示失败，可能当前物体不支持此功能" title:"错误"
            chkShowVertexColors.checked = false
        )
    )
    
    -- 顶点色着色事件
    on chkVertexColorsShaded changed state do
    (
        try
        (
            if selection.count == 0 then
            (
                messagebox "请先选择一个物体再设置顶点色着色" title:"提示"
                chkVertexColorsShaded.checked = false
                return()
            )
            
            if viewport.getType() != #view_none then
            (
                $.vertexColorsShaded = state
                if state then
                    format "✅ 顶点色着色已开启\n"
                else
                    format "❌ 顶点色着色已关闭\n"
            )
            else
            (
                messagebox "请先激活一个视口" title:"提示"
                chkVertexColorsShaded.checked = false
            )
        )
        catch
        (
            messagebox "设置顶点色着色失败，可能当前物体不支持此功能" title:"错误"
            chkVertexColorsShaded.checked = false
        )
    )
    
    -- 顶点索引显示事件
    on chkShowVertexIndex changed state do
    (
        try
        (
            if state then (
                local result = LcL_EnableVertexIndex()
                if not result then
                    chkShowVertexIndex.checked = false
            )
            else
                LcL_DisableVertexIndex()
        )
        catch
        (
            format "⚠️ 设置顶点索引显示失败\n"
            chkShowVertexIndex.checked = false
        )
    )
    
    -- 面索引显示事件
    on chkShowFaceIndex changed state do
    (
        try
        (
            if state then (
                local result = LcL_EnableFaceIndex()
                if not result then
                    chkShowFaceIndex.checked = false
            )
            else
                LcL_DisableFaceIndex()
        )
        catch
        (
            format "⚠️ 设置面索引显示失败\n"
            chkShowFaceIndex.checked = false
        )
    )
    
    -- 初始化复选框状态
    on ToolsRollout open do
    (
        try
        (
            if viewport.getType() != #view_none then
            (
                chkShowVertexColors.checked = $.showVertexColors
                chkVertexColorsShaded.checked = $.vertexColorsShaded
            )
            else
            (
                chkShowVertexColors.checked = false
                chkVertexColorsShaded.checked = false
            )
            
            -- 设置索引显示状态
            chkShowVertexIndex.checked = LcL_GetVertexIndexState()
            chkShowFaceIndex.checked = LcL_GetFaceIndexState()
        )
        catch
        (
            -- 如果获取状态失败，默认设为false，不弹窗
            chkShowVertexColors.checked = false
            chkVertexColorsShaded.checked = false
            chkShowVertexIndex.checked = false
            chkShowFaceIndex.checked = false
        )
    )
)

-- 主对话框
rollout MainLcLDialog "LcL工具集合" width:300 height:400
(
    -- 使用文本标题代替图片，增大字体
    label lblTitle "" pos:[0,15] width:300 height:35 align:#center
    
    -- 定义子卷展栏控件
    subRollout sr_main pos:[10,55] width:280 height:335

    on MainLcLDialog open do
    (
        -- 设置标题样式和大字体
        lblTitle.caption = "LcL Tools"
        
        -- 尝试设置更大的字体
        try
        (
            lblTitle.font = dotNetObject "System.Drawing.Font" "Arial" 16 ((dotNetClass "System.Drawing.FontStyle").Bold)
        )
        catch
        (
            -- 如果设置字体失败，使用默认字体但调整文本
            lblTitle.caption = "LcL Tools"
        )
        
        -- 添加子卷展栏
        addSubRollout MainLcLDialog.sr_main ToolsRollout
        
        -- 展开第一个卷展栏
        for i in MainLcLDialog.sr_main.rollouts do
        (
            i.open = true
            exit -- 只展开第一个
        )
    )
)

-- 创建对话框的函数
fn Create_LcL_Tools_Dialog =
(
    if MainLcLDialog != undefined do destroyDialog MainLcLDialog
    createDialog MainLcLDialog style:#(#style_toolwindow, #style_sysmenu)
)