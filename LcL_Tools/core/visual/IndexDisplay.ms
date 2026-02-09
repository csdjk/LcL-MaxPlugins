-- 索引显示工具 - 集成到LcL Tools
-- 基于 Laszlo Sebo 的原始脚本修改
-- 显示选中顶点和面的索引

-- 全局变量
global LcL_VertexIndexShow = false
global LcL_FaceIndexShow = false
global LcL_lastviewport
global LcL_callbacks = 0

-- 颜色配置变量
global LcL_VertexIndexColor = [231,217,55]   -- 默认黄色
global LcL_FaceIndexColor = [0,255,255]      -- 亮青色 - 在红色背景下更明显

-- 通用屏幕更新函数
fn LcL_redrawscr = gw.updatescreen()

-- 顶点索引显示函数 - 显示选中的顶点索引
fn LcL_VertexShow = (
    if viewport.activeViewport != LcL_lastviewport do (
        completeredraw()
        LcL_lastViewport = viewport.activeViewport 
    )
    if (selection.count == 1) and ((classof $.baseobject == Editable_Mesh) or (classof $.baseobject == Editable_Poly)) then
    (
        gw.setTransform (matrix3 1)
        if (classof $ == Editable_Mesh) then
            for gw_i in (getvertselection $) do
                gw.wtext ((gw.wTransPoint (getvert $ gw_i)) + [5,-5,0]) (gw_i as string) color:LcL_VertexIndexColor
        else
            for gw_i in (polyop.getvertselection $.baseobject) do
                gw.wtext ((gw.wTransPoint (polyop.getvert $ gw_i)) + [5,-5,0]) (gw_i as string) color:LcL_VertexIndexColor
        gw.enlargeupdaterect #whole
    )
)

-- 面索引显示函数 - 显示选中的面索引
fn LcL_FaceShow = (
    if viewport.activeViewport != LcL_lastviewport do (
        completeredraw()
        LcL_lastViewport = viewport.activeViewport 
    )
    if (selection.count == 1) and ((classof $.baseobject == Editable_Mesh) or (classof $.baseobject == Editable_Poly)) then
    (
        gw.setTransform (matrix3 1)
        if (classof $ == Editable_Mesh) then
            for gw_i in (getfaceselection $) do (
                local face_i = meshop.getfacecenter $ gw_i
                gw.wtext ((gw.wTransPoint face_i)+[0,0,100]) (gw_i as string) color:LcL_FaceIndexColor
            )
        else (
            for gw_i in (polyop.getfaceselection $.baseobject) do (
                local face_i = polyop.getfacecenter $ gw_i
                gw.wtext ((gw.wTransPoint face_i)+[0,0,100]) (gw_i as string) color:LcL_FaceIndexColor
            )
        )               
        gw.enlargeupdaterect #whole
    )
)

-- 检查是否在顶点编辑模式
fn LcL_CheckVertexMode = (
    if selection.count == 0 then (
        format "⚠️ 请先选择一个Editable Mesh或Editable Poly对象\n"
        return false
    )
    
    local obj = selection[1]
    if not ((classof obj.baseobject == Editable_Mesh) or (classof obj.baseobject == Editable_Poly)) then (
        format "⚠️ 请选择Editable Mesh或Editable Poly对象\n"
        return false
    )
    
    if subobjectLevel != 1 then (
        format "⚠️ 请先进入顶点编辑模式（Vertex模式）\n"
        return false
    )
    
    return true
)

-- 检查是否在面编辑模式
fn LcL_CheckFaceMode = (
    if selection.count == 0 then (
        format "⚠️ 请先选择一个Editable Mesh或Editable Poly对象\n"
        return false
    )
    
    local obj = selection[1]
    if not ((classof obj.baseobject == Editable_Mesh) or (classof obj.baseobject == Editable_Poly)) then (
        format "⚠️ 请选择Editable Mesh或Editable Poly对象\n"
        return false
    )
    
    local faceLevel = if (classof obj.baseobject == Editable_Mesh) then 3 else 4
    if subobjectLevel != faceLevel then (
        local modeName = if (classof obj.baseobject == Editable_Mesh) then "Face模式" else "Polygon模式"
        format "⚠️ 请先进入面编辑模式（%）\n" modeName
        return false
    )
    
    return true
)

-- 启用顶点索引显示
fn LcL_EnableVertexIndex = (
    if not LcL_CheckVertexMode() then return false
    
    if not LcL_VertexIndexShow then (
        LcL_callbacks += 1
        registerRedrawviewscallback LcL_VertexShow
        if LcL_callbacks == 1 then registerRedrawviewsCallback LcL_redrawscr
        LcL_VertexIndexShow = true
        format "✅ 顶点索引显示已开启\n"
    )
    return true
)

-- 禁用顶点索引显示
fn LcL_DisableVertexIndex = (
    if LcL_VertexIndexShow then (
        LcL_callbacks -= 1
        unregisterRedrawviewscallback LcL_VertexShow
        if LcL_callbacks == 0 then unregisterRedrawViewsCallback LcL_redrawscr
        LcL_VertexIndexShow = false
        format "❌ 顶点索引显示已关闭\n"
    )
    return true
)

-- 启用面索引显示
fn LcL_EnableFaceIndex = (
    if not LcL_CheckFaceMode() then return false
        
    if not LcL_FaceIndexShow then (
        LcL_callbacks += 1
        registerRedrawviewscallback LcL_FaceShow
        if LcL_callbacks == 1 then registerRedrawviewsCallback LcL_redrawscr
        LcL_FaceIndexShow = true
        format "✅ 面索引显示已开启\n"
    )
    return true
)

-- 禁用面索引显示
fn LcL_DisableFaceIndex = (
    if LcL_FaceIndexShow then (
        LcL_callbacks -= 1
        unregisterRedrawviewscallback LcL_FaceShow
        if LcL_callbacks == 0 then unregisterRedrawViewsCallback LcL_redrawscr
        LcL_FaceIndexShow = false
        format "❌ 面索引显示已关闭\n"
    )
    return true
)

-- 切换顶点索引显示
fn LcL_ToggleVertexIndex = (
    if LcL_VertexIndexShow then
        LcL_DisableVertexIndex()
    else
        LcL_EnableVertexIndex()
    forcecompleteredraw()
)

-- 切换面索引显示
fn LcL_ToggleFaceIndex = (
    if LcL_FaceIndexShow then
        LcL_DisableFaceIndex()
    else
        LcL_EnableFaceIndex()
    forcecompleteredraw()
)

-- 获取当前状态
fn LcL_GetVertexIndexState = LcL_VertexIndexShow
fn LcL_GetFaceIndexState = LcL_FaceIndexShow