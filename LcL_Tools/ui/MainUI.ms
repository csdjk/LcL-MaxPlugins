-- ===== 全局对话框变量和函数定义 =====
global LcL_MainDialog = undefined
global LcL_VisualDialog = undefined

-- 前向声明可视化工具对话框
rollout VisualToolsDialog "可视化工具" width:250 height:200
(
    group "顶点显示控制"
    (
        checkbox chk_showVC "显示顶点色" width:100 across:2
        checkbox chk_shadeVC "着色显示" width:100
        button btn_quickVC "快速切换" width:200 height:24
    )
    
    group "索引显示控制"
    (
        button btn_vertexIdx "顶点索引" width:95 height:30 across:2
        button btn_faceIdx "面索引" width:95 height:30
        
        label lbl_status "" width:200 height:20 align:#center
    )
    
    -- 事件处理
    on chk_showVC changed state do
    (
        if selection.count > 0 then
        (
            try ($.showVertexColors = state)
            catch (lbl_status.text = "顶点色设置失败")
        )
        else lbl_status.text = "请先选择对象"
    )
    
    on chk_shadeVC changed state do
    (
        if selection.count > 0 then
        (
            try ($.vertexColorsShaded = state)
            catch (lbl_status.text = "着色设置失败")
        )
        else lbl_status.text = "请先选择对象"
    )
    
    on btn_quickVC pressed do
    (
        if selection.count > 0 then
        (
            try
            (
                $.showVertexColors = not $.showVertexColors
                $.vertexColorsShaded = $.showVertexColors
                chk_showVC.checked = $.showVertexColors
                chk_shadeVC.checked = $.vertexColorsShaded
                lbl_status.text = if $.showVertexColors then "已开启" else "已关闭"
            )
            catch (lbl_status.text = "切换失败")
        )
        else lbl_status.text = "请先选择对象"
    )
    
    on btn_vertexIdx pressed do
    (
        try
        (
            if LcL_ToggleVertexIndex != undefined then
            (
                LcL_ToggleVertexIndex()
                lbl_status.text = if LcL_GetVertexIndexState() then "顶点索引：开" else "顶点索引：关"
            )
            else lbl_status.text = "索引功能未加载"
        )
        catch (lbl_status.text = "顶点索引失败")
    )
    
    on btn_faceIdx pressed do
    (
        try
        (
            if LcL_ToggleFaceIndex != undefined then
            (
                LcL_ToggleFaceIndex()
                lbl_status.text = if LcL_GetFaceIndexState() then "面索引：开" else "面索引：关"
            )
            else lbl_status.text = "索引功能未加载"
        )
        catch (lbl_status.text = "面索引失败")
    )
    
    on VisualToolsDialog open do
    (
        lbl_status.text = "可视化工具已就绪"
        
        if selection.count > 0 then
        (
            try
            (
                chk_showVC.checked = $.showVertexColors
                chk_shadeVC.checked = $.vertexColorsShaded
            )
            catch
            (
                chk_showVC.checked = false
                chk_shadeVC.checked = false
            )
        )
    )
)

-- 创建可视化工具对话框函数
fn LcL_ShowVisualDialog =
(
    if LcL_VisualDialog != undefined do destroyDialog LcL_VisualDialog
    LcL_VisualDialog = createDialog VisualToolsDialog modal:false
)

-- ===== 主界面卷展栏 =====

-- 1. Max ⇄ Blender 同步工具
rollout BlenderSyncRollout "Max ⇄ Blender 同步工具" width:280
(
    button btn_export "Max To Blender" width:240 height:32 tooltip:"导出选中对象到Blender"
    button btn_import "Blender To Max" width:240 height:32 tooltip:"从Blender导入模型"
    
    label lbl_info "" width:240 height:16 align:#center
    button btn_settings "同步设置..." width:240 height:24 tooltip:"配置导入导出参数"
    
    -- 导出处理
    on btn_export pressed do
    (
        try
        (
            if LcL_QuickExport != undefined then
            (
                LcL_QuickExport()
                lbl_info.text = "导出完成"
            )
            else
                messageBox "导出功能未加载" title:"错误"
        )
        catch (e)
        (
            messageBox ("导出失败: " + e as string) title:"导出错误"
            lbl_info.text = "导出失败"
        )
    )
    
    -- 导入处理
    on btn_import pressed do
    (
        try
        (
            if LcL_QuickImport != undefined then
            (
                LcL_QuickImport()
                lbl_info.text = "导入完成"
            )
            else
                messageBox "导入功能未加载" title:"错误"
        )
        catch (e)
        (
            messageBox ("导入失败: " + e as string) title:"导入错误"
            lbl_info.text = "导入失败"
        )
    )
    
    -- 设置按钮
    on btn_settings pressed do
    (
        if LcL_ShowSettingsDialog != undefined then
            LcL_ShowSettingsDialog()
        else
            messageBox "设置功能未加载" title:"错误"
    )
    
    -- 初始化
    on BlenderSyncRollout open do
    (
        local selCount = selection.count
        if selCount > 0 then
            lbl_info.text = "已选择 " + selCount as string + " 个对象"
        else
            lbl_info.text = "请选择要导出的对象"
    )
)

-- 2. 顶点色可视化工具
rollout VertexColorRollout "顶点色可视化" width:280 
(
    checkbox chk_vertexColors "Show Vertex Color" width:110 height:20 across:2
    checkbox chk_vertexShaded "Vertex Color Shaded" width:110 height:20
    button btn_toggleVC "快速切换" width:240 height:24 tooltip:"快速切换选中对象的顶点色显示"
    
    label lbl_vcStatus "" width:240 height:16 align:#center
    
    -- 顶点色复选框事件
    on chk_vertexColors changed state do
    (
        if selection.count == 0 then
        (
            lbl_vcStatus.text = "请先选择一个物体"
            chk_vertexColors.checked = false
            return()
        )
        
        try
        (
            $.showVertexColors = state
            
            -- 如果关闭Show Vertex Color，则自动关闭Vertex Color Shaded
            if not state then
            (
                chk_vertexShaded.checked = false
                $.vertexColorsShaded = false
            )
            
            lbl_vcStatus.text = if state then "顶点色已显示" else "顶点色已隐藏"
        )
        catch
        (
            lbl_vcStatus.text = "设置失败，物体可能不支持顶点色"
            chk_vertexColors.checked = false
        )
    )
    
    on chk_vertexShaded changed state do
    (
        if selection.count == 0 then
        (
            lbl_vcStatus.text = "请先选择一个物体"
            chk_vertexShaded.checked = false
            return()
        )
        
        try 
        (
            -- 如果要开启Vertex Color Shaded，必须先开启Show Vertex Color
            if state and not $.showVertexColors then
            (
                chk_vertexColors.checked = true
                $.showVertexColors = true
                lbl_vcStatus.text = "已自动开启顶点色显示"
            )
            
            $.vertexColorsShaded = state
            if not (state and not chk_vertexColors.checked) then
                lbl_vcStatus.text = if state then "着色模式已开启" else "着色模式已关闭"
        )
        catch 
        (
            lbl_vcStatus.text = "设置着色模式失败"
            chk_vertexShaded.checked = false
        )
    )
    
    -- 快速切换顶点色按钮
    on btn_toggleVC pressed do
    (
        if selection.count == 0 then
        (
            lbl_vcStatus.text = "请先选择一个物体"
            return()
        )
        
        try
        (
            $.showVertexColors = not $.showVertexColors
            $.vertexColorsShaded = $.showVertexColors
            
            chk_vertexColors.checked = $.showVertexColors
            chk_vertexShaded.checked = $.vertexColorsShaded
            
            lbl_vcStatus.text = if $.showVertexColors then "顶点色已开启" else "顶点色已关闭"
        )
        catch
        (
            lbl_vcStatus.text = "切换失败"
        )
    )
    
    -- 初始化状态
    on VertexColorRollout open do
    (
        try
        (
            if selection.count > 0 then
            (
                chk_vertexColors.checked = $.showVertexColors
                chk_vertexShaded.checked = $.vertexColorsShaded
                lbl_vcStatus.text = "顶点色工具就绪"
            )
            else
                lbl_vcStatus.text = "请选择要操作的对象"
        )
        catch
        (
            chk_vertexColors.checked = false
            chk_vertexShaded.checked = false
            lbl_vcStatus.text = "请选择要操作的对象"
        )
    )
)

-- 3. 顶点和面索引可视化工具
rollout IndexVisualizationRollout "顶点和面Index可视化" width:280
(
    label lbl_indexTip "提示：需要选择可编辑对象才能显示Index" width:240 height:16 align:#center
    
    checkbox chk_vertexIndex "Vertex Index" width:80 height:20 across:2 tooltip:"显示/隐藏顶点Index号"
    colorPicker cp_vertexColor "Color" color:[255,255,0] width:90 height:20 fieldWidth:25 tooltip:"顶点Index显示颜色"
    
    checkbox chk_faceIndex "Face Index" width:80 height:20 across:2 tooltip:"显示/隐藏面Index号"  
    colorPicker cp_faceColor "Color" color:[0,255,255] width:90 height:20 fieldWidth:25 tooltip:"面Index显示颜色"
    
    label lbl_indexStatus "" width:240 height:16 align:#center
    
    -- 顶点索引复选框
    on chk_vertexIndex changed state do
    (
        try
        (
            if LcL_ToggleVertexIndex != undefined then
            (
                -- 如果当前状态与目标状态不同才切换
                local currentState = if LcL_GetVertexIndexState != undefined then LcL_GetVertexIndexState() else false
                if currentState != state then
                    LcL_ToggleVertexIndex()
                    
                -- 更新并保存设置
                if LcL_ColorSettings != undefined then
                (
                    LcL_ColorSettings.vertexIndexEnabled = state
                    LcL_SaveSettings()
                )
                    
                lbl_indexStatus.text = "顶点Index: " + (if state then "开启" else "关闭")
            )
            else
            (
                lbl_indexStatus.text = "顶点Index功能未加载"
                chk_vertexIndex.checked = false
            )
        )
        catch
        (
            lbl_indexStatus.text = "顶点Index切换失败"
            chk_vertexIndex.checked = false
        )
    )
    
    -- 面索引复选框
    on chk_faceIndex changed state do
    (
        try
        (
            if LcL_ToggleFaceIndex != undefined then
            (
                -- 如果当前状态与目标状态不同才切换
                local currentState = if LcL_GetFaceIndexState != undefined then LcL_GetFaceIndexState() else false
                if currentState != state then
                    LcL_ToggleFaceIndex()
                    
                -- 更新并保存设置
                if LcL_ColorSettings != undefined then
                (
                    LcL_ColorSettings.faceIndexEnabled = state
                    LcL_SaveSettings()
                )
                    
                lbl_indexStatus.text = "面Index: " + (if state then "开启" else "关闭")
            )
            else
            (
                lbl_indexStatus.text = "面Index功能未加载"
                chk_faceIndex.checked = false
            )
        )
        catch
        (
            lbl_indexStatus.text = "面Index切换失败"
            chk_faceIndex.checked = false
        )
    )
    
    -- 颜色设置事件处理
    on cp_vertexColor changed col do
    (
        if LcL_ColorSettings != undefined then
        (
            LcL_ColorSettings.vertexIndexColor = col
            global LcL_VertexIndexColor = col
            lbl_indexStatus.text = "顶点颜色已更新"
            
            -- 自动保存设置
            LcL_SaveSettings()
            
            -- 如果索引显示开启，立即重绘
            if LcL_VertexIndexShow then forcecompleteredraw()
        )
    )
    
    on cp_faceColor changed col do
    (
        if LcL_ColorSettings != undefined then
        (
            LcL_ColorSettings.faceIndexColor = col
            global LcL_FaceIndexColor = col
            lbl_indexStatus.text = "面颜色已更新"
            
            -- 自动保存设置
            LcL_SaveSettings()
            
            -- 如果索引显示开启，立即重绘
            if LcL_FaceIndexShow then forcecompleteredraw()
        )
    )
    
    
    -- 初始化
    on IndexVisualizationRollout open do
    (
        try
        (
            -- 同步当前状态到复选框
            if LcL_GetVertexIndexState != undefined then
                chk_vertexIndex.checked = LcL_GetVertexIndexState()
            if LcL_GetFaceIndexState != undefined then
                chk_faceIndex.checked = LcL_GetFaceIndexState()
            
            -- 从设置文件中恢复开关状态
            if LcL_ColorSettings != undefined then
            (
                -- 同步颜色设置
                cp_vertexColor.color = LcL_ColorSettings.vertexIndexColor
                cp_faceColor.color = LcL_ColorSettings.faceIndexColor
                
                -- 恢复开关状态 (如果保存的状态与当前状态不同，则同步)
                if LcL_ColorSettings.vertexIndexEnabled != undefined then
                    chk_vertexIndex.checked = LcL_ColorSettings.vertexIndexEnabled
                if LcL_ColorSettings.faceIndexEnabled != undefined then
                    chk_faceIndex.checked = LcL_ColorSettings.faceIndexEnabled
            )
            else if LcL_VertexIndexColor != undefined and LcL_FaceIndexColor != undefined then
            (
                cp_vertexColor.color = LcL_VertexIndexColor
                cp_faceColor.color = LcL_FaceIndexColor
            )
                
            lbl_indexStatus.text = "Index可视化工具就绪"
        )
        catch
        (
            chk_vertexIndex.checked = false
            chk_faceIndex.checked = false
            cp_vertexColor.color = [255,255,0]
            cp_faceColor.color = [0,255,255]
            lbl_indexStatus.text = "Index工具就绪"
        )
    )
)

-- ===== 主对话框（优化后）=====

-- 主对话框 - 可调整大小设计
rollout MainLcLDialog "LcL Tools v2.0" width:300 height:480
(
    -- 标题区域
    label lblTitle "LcL Tools" pos:[0,10] width:300 height:30 align:#center
    label lblVersion "Max & Blender 工作流工具包" pos:[0,30] width:300 height:15 align:#center
    
    -- 主要功能区域
    subRollout sr_main pos:[10,50] width:280 height:420
    
    -- 响应大小变化
    on MainLcLDialog resized size do
    (
        -- 调整标题标签宽度
        lblTitle.width = size.x
        lblVersion.width = size.x
        
        -- 调整主要功能区域大小和位置
        sr_main.width = size.x - 20  -- 左右各留10像素边距
        sr_main.height = size.y - 60 -- 顶部留60像素给标题
        
        -- 确保最小尺寸
        if size.x < 280 then
        (
            sr_main.width = 260
        )
        
        if size.y < 300 then
        (
            sr_main.height = 240
        )
    )

    on MainLcLDialog open do
    (
        -- 设置标题字体
        try
        (
            lblTitle.font = dotNetObject "System.Drawing.Font" "Arial" 14 ((dotNetClass "System.Drawing.FontStyle").Bold)
            lblVersion.font = dotNetObject "System.Drawing.Font" "Arial" 8
        )
        catch
        (
            lblTitle.caption = "=== LcL Tools ==="
            lblVersion.caption = "Max ⇄ Blender"
        )
        
        -- 添加卷展栏
        addSubRollout MainLcLDialog.sr_main BlenderSyncRollout
        addSubRollout MainLcLDialog.sr_main VertexColorRollout
        addSubRollout MainLcLDialog.sr_main IndexVisualizationRollout
        
        -- 展开所有卷展栏
        for r in MainLcLDialog.sr_main.rollouts do
            r.open = true
    )
    
    on MainLcLDialog close do
    (
        -- 在关闭时自动保存当前设置状态
        try
        (
            if LcL_ColorSettings != undefined and LcL_SaveSettings != undefined then
            (
                -- 保存当前Index开关状态
                if LcL_GetVertexIndexState != undefined then
                    LcL_ColorSettings.vertexIndexEnabled = LcL_GetVertexIndexState()
                if LcL_GetFaceIndexState != undefined then
                    LcL_ColorSettings.faceIndexEnabled = LcL_GetFaceIndexState()
                
                LcL_SaveSettings()
                format "✅ LcL Tools 设置已自动保存\n"
            )
        )
        catch
        (
            format "⚠️ 设置保存失败\n"
        )
        
        format "LcL Tools 界面已关闭\n"
    )
)

-- ===== 主对话框创建函数 =====

-- 创建主对话框
fn Create_LcL_Tools_Dialog =
(
    if LcL_MainDialog != undefined and classof LcL_MainDialog == RolloutClass do 
        destroyDialog LcL_MainDialog
    LcL_MainDialog = createDialog MainLcLDialog style:#(#style_toolwindow, #style_sysmenu, #style_resizing) pos:[100,100]
)
