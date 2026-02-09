# LcL Tools v2.0 - 3ds Max 优化工具集

## 📋 简介
LcL Tools 是专为 3ds Max 和 Blender 工作流程优化的同步工具包，提供简洁高效的数据交换和可视化功能。v2.0 版本经过全面重构，删除冗余功能，每个工具都有对应的 macroScript 支持。

## ✨ 主要功能

### 🔄 Max ⇄ Blender 同步（核心功能）
- **一键导出**: 智能FBX导出到Blender（自动过滤、格式优化）
- **一键导入**: 从Blender快速导入模型
- **智能过滤**: 按对象名称关键词自动过滤不需要的对象
- **格式控制**: Binary/ASCII格式，cm/m单位，Y/Z轴向
- **动画支持**: 可选包含动画数据和烘焙设置

### 🎨 可视化工具
- **顶点色显示**: 快速切换和控制顶点色显示
- **索引显示**: 实时显示顶点/面索引（支持编辑模式）
- **独立工具窗口**: 专用可视化工具对话框

### 🛠️ macroScript 完整支持
- **LcL_MainTools**: 主工具界面
- **LcL_ExportToBlender**: 导出到Blender
- **LcL_ImportFromBlender**: 从Blender导入
- **LcL_VisualTools**: 可视化工具面板
- **LcL_SyncSettings**: 同步设置
- **LcL_QuickVertexColors**: 快速顶点色切换
- **LcL_QuickIndexDisplay**: 快速索引显示

## 📁 项目结构（优化后）

```
LcL_Tools/
├── Main.ms                     # 主程序 + 所有macroScript定义
├── core/                       # 核心功能模块
│   ├── sync/                   # 同步功能（Max⇄Blender）
│   │   ├── ExportCore.ms      # FBX导出核心
│   │   └── ImportCore.ms      # FBX导入核心
│   └── visual/                # 可视化工具核心
│       └── IndexDisplay.ms    # 顶点/面索引显示
├── ui/                        # 用户界面（精简设计）
│   ├── MainUI.ms             # 主界面 + 可视化工具对话框
│   └── SettingsUI.ms        # 设置界面（优化版）
├── icon/                     # 图标资源
└── README.md                # 本文档
```

## 🚀 安装和使用

### 📦 安装步骤
1. 将 `LcL_Tools` 文件夹复制到 3ds Max 插件目录
   - 通常: `C:\Program Files\Autodesk\3ds Max [版本]\Plugins\`
2. 重启 3ds Max
3. 菜单栏会出现 "LcL Tools" 菜单（精简版，10个选项）

### 💡 使用方法

#### 主要工作流程
1. **打开主界面**: `LcL Tools > LcL Tools`（主界面集成了所有核心功能）
2. **导出**: 选择对象 → 点击 "→ 导出到Blender" → 自动导出FBX
3. **导入**: 从Blender导出FBX后 → 点击 "← 从Blender导入"
4. **设置**: 通过 "同步设置..." 配置过滤规则和导出参数

#### 快速操作（macroScript支持）
- **快速导出**: `LcL_ExportToBlender` → 可绑定快捷键
- **快速导入**: `LcL_ImportFromBlender` → 可绑定快捷键  
- **顶点色切换**: `LcL_QuickVertexColors` → 一键切换
- **索引显示**: `LcL_QuickIndexDisplay` → 选择顶点或面索引

#### 可视化工具
- **独立窗口**: `LcL Tools > 可视化工具` 打开专用可视化面板
- **集成控制**: 主界面的 "快速工具" 区域提供常用可视化功能

## 🎯 macroScript 支持（完整版）

所有功能都有对应的 macroScript，支持快捷键绑定、工具栏定制：

### 主要功能 macroScript
- **`LcL_MainTools`**: 主工具界面（推荐绑定 Ctrl+Shift+L）
- **`LcL_ExportToBlender`**: 导出到Blender（推荐 Ctrl+E）
- **`LcL_ImportFromBlender`**: 从Blender导入（推荐 Ctrl+I）
- **`LcL_VisualTools`**: 可视化工具面板
- **`LcL_SyncSettings`**: 同步设置界面

### ⚡ 快速操作 macroScript  
- **`LcL_QuickVertexColors`**: 快速顶点色切换（推荐 V）
- **`LcL_QuickIndexDisplay`**: 快速索引显示选择器

### 🔧 自定义建议
1. **快捷键绑定**: `自定义 > 自定义用户界面 > 键盘` → 类别选择 "LcL"
2. **工具栏按钮**: 拖拽 macroScript 到工具栏创建专用按钮
3. **四边面板**: 添加常用功能到四边面板以快速访问

### 📱 推荐快捷键配置
```
Ctrl+Shift+L  →  LcL_MainTools         (主界面)
Ctrl+E        →  LcL_ExportToBlender   (导出)  
Ctrl+I        →  LcL_ImportFromBlender (导入)
V             →  LcL_QuickVertexColors (顶点色)
Ctrl+Shift+V  →  LcL_VisualTools       (可视化面板)
```

## 🛡️ 技术特性

### 架构优化
- **模块化设计**: 按功能分类，便于维护
- **精简界面**: 删除冗余控件，提高效率
- **智能加载**: 按需加载功能模块
- **统一错误处理**: 完善的异常处理机制

### 兼容性
- **3ds Max版本**: 2020+
- **macroScript支持**: 完整的快捷键和工具栏定制
- **设置持久化**: 自动保存用户配置
- **临时文件管理**: 使用系统临时目录

## 📋 菜单结构（优化后）

```
LcL Tools
├── LcL Tools               # 主界面
├── ──────────────
├── → 导出到Blender          # 快速导出
├── ← 从Blender导入          # 快速导入
├── ──────────────
├── 可视化工具              # 独立可视化面板
├── 快速顶点色切换           # 一键顶点色
├── 快速索引显示             # 选择索引类型
├── ──────────────
└── 同步设置                # 配置和过滤
```

## 🔄 更新日志

### v2.0 (当前版本 - 优化版)
- ✅ **重构架构**: 全面优化代码结构
- ✅ **精简界面**: 删除冗余菜单，简化操作
- ✅ **macroScript完整支持**: 每个功能都有对应的macroScript
- ✅ **统一错误处理**: 改进异常处理和用户提示
- ✅ **优化设置界面**: 简化选项，提高易用性
- ✅ **独立可视化工具**: 专用可视化工具对话框
- ✅ **状态反馈**: 实时操作状态显示

### v1.0 (基础版)
- 基本同步功能
- 简单可视化工具
- 基础界面设计

## ⚠️ 注意事项

1. **首次使用**: 建议先检查同步设置，配置合适的过滤规则
2. **文件路径**: 确保Max和Blender能访问相同的临时目录
3. **编辑模式**: 顶点/面索引显示需要进入相应的编辑模式
4. **对象选择**: 顶点色功能需要先选择支持顶点色的对象
5. **性能优化**: 合理使用过滤设置以提高大场景的导出效率

---

**LcL Tools v2.0** - 为Max和Blender工作流程优化的专业工具包