/* 
    LcL-Tools 脚本
    ----------------
    这是一个 3ds Max 的自定义工具脚本，提供以下功能：
    
    1. 链接FBX文件：
       - 使用“链接FBX”按钮导入指定路径的 FBX 文件。
       - 默认路径为 "F:\\Temp\\output.fbx"。
       - 如果文件不存在，会弹出错误提示。

    2. 刷新FBX链接：
       - 使用“刷新FBX”按钮删除当前场景中的所有对象，并重新导入指定路径的 FBX 文件。
       - 默认路径为 "F:\\Temp\\output.fbx"。
       - 如果文件不存在，会弹出错误提示。

    3. 自动添加菜单：
       - 在 3ds Max 的主菜单栏中自动添加一个名为“LcL-Tools”的菜单。
       - 菜单中包含“链接FBX”和“刷新FBX”两个按钮。

    使用方法：
    1. 将此脚本保存为 .ms 文件。
    2. 在 3ds Max 中运行脚本。
    3. 在主菜单栏中找到“LcL-Tools”菜单，使用其中的功能按钮。

    注意：
    - 默认的 FBX 文件路径为 "F:\\Temp\\output.fbx"，可以根据需要修改脚本中的路径。
    - 如果需要添加图标，可以使用 3ds Max 的内置图标或自定义图标。
*/

-- 定义全局变量 fbxLinkPath
global fbxLinkPath = "F:\\Temp\\output.fbx"

-- 链接FBX文件的宏脚本
macroScript LinkFBXFile
category:"LcL-Tools" 
buttonText:"链接FBX"
tooltip:"链接指定路径的FBX文件"
(
    try
    (
        if doesFileExist fbxLinkPath then
        (
            importFile fbxLinkPath #noPrompt using:FBXIMP
            format "成功导入文件: %\n" fbxLinkPath
        )
        else
        (
            messageBox ("文件不存在: " + fbxLinkPath) title:"错误"
        )
    )
    catch
    (
        messageBox ("操作失败: " + getCurrentException()) title:"错误"
    )
)

-- 刷新FBX链接的宏脚本
macroScript RefreshFBXLink
category:"LcL-Tools" 
buttonText:"刷新FBX"
tooltip:"刷新并重新链接FBX文件"
(
    try
    (
        if doesFileExist fbxLinkPath then
        (
            -- 删除当前场景中的所有对象
            delete objects
            
            -- 重新导入FBX文件
            importFile fbxLinkPath #noPrompt using:FBXIMP
            format "成功刷新并重新导入文件: %\n" fbxLinkPath
        )
        else
        (
            messageBox ("文件不存在: " + fbxLinkPath) title:"错误"
        )
    )
    catch
    (
        messageBox ("操作失败: " + getCurrentException()) title:"错误"
    )
)

-- 自动将按钮添加到主菜单栏
try
(
    -- 获取主菜单栏
    mainMenuBar = menuMan.getMainMenuBar()
    
    -- 检查是否已经存在“LcL-Tools”菜单，避免重复添加
    myMenu = menuMan.findMenu "LcL-Tools"
    if myMenu == undefined then
    (
        -- 创建新菜单
        myMenu = menuMan.createMenu "LcL-Tools"
        
        -- 创建“链接FBX”菜单项
        linkAction = menuMan.createActionItem "LinkFBXFile" "LcL-Tools"
        myMenu.addItem linkAction -1

        -- 创建“刷新FBX”菜单项
        refreshAction = menuMan.createActionItem "RefreshFBXLink" "LcL-Tools"
        myMenu.addItem refreshAction -1
        
        -- 创建子菜单
        subMenu = menuMan.createSubMenuItem "LcL-Tools" myMenu
        
        -- 添加到主菜单栏
        mainMenuBar.addItem subMenu -1
        
        -- 更新菜单显示
        menuMan.updateMenuBar()
    )
)
catch
(
    messageBox ("操作失败: " + getCurrentException()) title:"错误"
)