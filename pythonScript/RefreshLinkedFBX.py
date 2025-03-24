# 示例：my_max_plugin.py
import MaxPlus

def create_box():
    # 创建一个标准盒子
    box = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Box)
    box.ParameterBlock.Width.Value = 50.0
    box.ParameterBlock.Length.Value = 50.0
    box.ParameterBlock.Height.Value = 50.0
    
    # 将对象添加到场景
    node = MaxPlus.Factory.CreateNode(box)
    node.SetName("PythonBox")
    
    # 选择创建的对象
    selection = MaxPlus.SelectionManager
    selection.ClearNodeSelection()
    selection.SelectNode(node)

# 测试函数
create_box()
