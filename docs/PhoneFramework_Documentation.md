# PhoneFramework 使用文档

## 框架概述

PhoneFramework 是一个为 Project Zomboid 设计的手机应用框架，允许开发者创建自定义手机应用，在游戏中提供丰富的交互体验。

## 核心组件

### 1. PhoneFrameworkCore
框架核心，负责应用管理、手机窗口显示和整体协调。

### 2. PhoneWebView
应用容器组件，提供标题栏、返回和关闭按钮等功能。

### 3. 应用基类 (PhoneFrameworkCore.App)
所有应用都应继承的基础类，提供标准的生命周期方法。

## 快速开始

### 创建基础应用

```lua
-- 示例应用 - 展示框架使用方式
MyApp = {}
MyApp.App = {}

-- 设置元表继承
setmetatable(MyApp.App, {__index = PhoneFrameworkCore.App})

-- 应用构造函数
function MyApp.App:new()
    local obj = PhoneFrameworkCore.App:new(
        "MyApp",                    -- 应用ID
        "",                         -- 图标路径
        "My App",                   -- 显示名称
        "这是一个示例应用"           -- 描述
    )
    setmetatable(obj, {__index = self})
    
    -- 应用特定属性
    obj.customData = "示例数据"
    
    return obj
end

-- 应用创建方法
function MyApp.App:onCreate(webView)
    print("[MyApp] Creating app UI...")
    
    -- 获取内容面板
    local contentPanel = webView:getContentPanel()
    
    -- 创建主容器
    self.mainPanel = ISPanel:new(20, 20, contentPanel.width - 40, contentPanel.height - 40)
    self.mainPanel:initialise()
    self.mainPanel.backgroundColor = {r=0.95, g=0.95, b=0.95, a=0.9}
    contentPanel:addChild(self.mainPanel)
    
    -- 使用drawText绘制文本
    self.titleText = getText("UI_MyApp_Title")
    self.titleX = 20
    self.titleY = 20
    self.titleWidth = self.mainPanel.width - 40
    
    -- 设置渲染函数
    self:setRenderFunction()
end

-- 渲染函数
function MyApp.App:render()
    if self.titleText then
        local textWidth = getTextManager():MeasureStringX(UIFont.Medium, self.titleText)
        local textX = self.titleX + (self.titleWidth - textWidth) / 2
        
        self.mainPanel:drawText(self.titleText, textX, self.titleY, 0.1, 0.1, 0.1, 1, UIFont.Medium)
    end
end

-- 设置渲染函数
function MyApp.App:setRenderFunction()
    if self.mainPanel then
        self.mainPanel.render = function()
            self:render()
        end
    end
end

-- 注册应用
function MyApp.registerApp()
    if not PhoneFrameworkCore then
        print("[MyApp] Framework not found, waiting...")
        return false
    end
    
    local appInstance = MyApp.App:new()
    PhoneFrameworkCore.registerApp(appInstance)
    print("[MyApp] App registered")
    return true
end

-- 立即注册或等待框架初始化
if not MyApp.registerApp() then
    Events.OnGameStart.Add(MyApp.registerApp)
end
```

## 应用生命周期

### onCreate(webView)
- **调用时机**: 应用首次打开时
- **参数**: `webView` - PhoneWebView实例
- **用途**: 创建应用UI界面

### onDestroy()
- **调用时机**: 应用关闭时
- **用途**: 清理资源，取消事件监听

### onResume()
- **调用时机**: 应用从后台恢复到前台
- **用途**: 更新界面状态，刷新数据

### onPause()
- **调用时机**: 应用切换到后台
- **用途**: 保存临时数据，暂停动画等

## PhoneWebView API

### 基础方法

```lua
-- 创建PhoneWebView
local webView = PhoneWebView:new(x, y, width, height, parent)

-- 设置标题
webView:setTitle("应用标题")

-- 获取内容面板（用于放置应用UI）
local contentPanel = webView:getContentPanel()

-- 显示/隐藏
webView:setVisible(true)
webView:setVisible(false)
```

### 回调函数

```lua
-- 返回按钮回调
function webView:onBack(button)
    -- 自定义返回逻辑
    PhoneFrameworkCore.returnToHome()
end

-- 关闭按钮回调
function webView:onClose()
    -- 自定义关闭逻辑
    if self.app and self.app.onDestroy then
        self.app:onDestroy()
    end
    PhoneFrameworkCore.returnToHome()
end
```

## 最佳实践

### 1. 文本渲染
- 使用 `drawText` 代替 `ISLabel`
- 自动居中显示文本
- 避免参数错误问题

### 2. 面板布局
- 使用相对布局，适应不同屏幕尺寸
- 合理设置边距和间距
- 保持界面一致性

### 3. 事件处理
- 正确处理应用生命周期
- 及时清理资源
- 避免内存泄漏

### 4. 多语言支持
- 使用 `getText()` 函数获取翻译文本
- 在翻译文件中定义所有UI文本

## 示例应用结构

```
mods/
├── MyApp/
│   ├── 42/
│   │   └── mod.info
│   ├── common/
│   │   ├── mod.info
│   │   └── media/
│   │       └── lua/
│   │           ├── client/
│   │           │   └── MyApp.lua
│   │           └── shared/
│   │               └── Translate/
│   │                   ├── CN/
│   │                   │   └── UI_CN.txt
│   │                   └── EN/
│   │                       └── UI_EN.txt
```

## 调试和测试

### 日志输出
使用 `print()` 函数输出调试信息：
```lua
print("[MyApp] Application initialized")
print("[MyApp] Button clicked: " .. buttonName)
```

### 常见问题

1. **应用不显示**
   - 检查是否调用了 `setRenderFunction()`
   - 验证渲染函数是否正确设置

2. **文本重叠**
   - 确保Y坐标设置正确
   - 文本应在对应的面板上绘制

3. **回调函数不触发**
   - 检查函数签名是否正确
   - 验证事件绑定是否正确

## 高级功能

### 自定义事件
```lua
-- 添加自定义按钮事件
function MyApp.App:onCustomButtonClick()
    -- 处理点击事件
    self:updateUI()
end
```

### 数据持久化
```lua
-- 保存应用数据
function MyApp.App:saveData()
    -- 实现数据保存逻辑
end

-- 加载应用数据
function MyApp.App:loadData()
    -- 实现数据加载逻辑
end
```

## 贡献指南

欢迎提交改进建议和bug报告！请确保：
- 代码符合Lua编码规范
- 添加适当的注释
- 测试功能正常
- 更新相关文档

---

**版本**: 1.0  
**最后更新**: 2024-12-10  
**作者**: PhoneFramework Team