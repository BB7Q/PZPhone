# PhoneFramework 使用文档

## 框架概述

PhoneFramework 是一个为 Project Zomboid 设计的手机应用框架，允许开发者创建自定义手机应用，在游戏中提供丰富的交互体验。

## 核心组件

### 1. PhoneFrameworkCore
框架核心，负责应用管理、手机窗口显示和整体协调。

### 2. PhoneWebView
现代化应用容器组件，提供全屏内容区域和底部关闭控件，支持手势操作。

**新特性:**
- 现代化界面设计，简洁美观
- 底部细长条关闭控件，视觉上更精致
- 大点击区域设计，提升用户体验
- 支持自定义关闭逻辑

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
        "MyApp",                           -- 应用ID
        getTexture("media/ui/MyApp_icon.png"), -- 图标纹理 (80x80像素)
        getText("UI_MyApp_Name"),          -- 显示名称 (国际化)
        getText("UI_MyApp_Description")     -- 描述 (国际化)
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

-- 获取内容面板（用于放置应用UI）
local contentPanel = webView:getContentPanel()

-- 设置应用内容组件
webView:setContent(component)

-- 显示/隐藏
webView:setVisible(true)
webView:setVisible(false)

-- 编程式关闭
webView:close()

-- 从UI管理器移除
webView:removeFromUIManager()
```

### 现代化关闭控件特性

PhoneWebView采用现代化设计，关闭控件具有以下特点：
- **视觉线条**: 80×3像素的细长条，位于底部20像素处
- **大点击区域**: 80×20像素的透明区域，位于底部30像素处
- **智能关闭**: 点击后自动调用应用或框架的关闭逻辑
- **自定义回调**: 支持 `onWebViewClose` 自定义关闭处理

### 关闭机制

PhoneWebView提供灵活的关闭机制：

#### 1. 默认关闭行为
```lua
-- 点击底部关闭控件时自动执行
webView:performClose()
```

#### 2. 自定义关闭回调
```lua
-- 在应用或父组件中实现
function MyApp:onWebViewClose(webView)
    -- 自定义关闭逻辑
    print("应用关闭中...")
    self:onDestroy()
    PhoneFrameworkCore.returnToHome()
end
```

#### 3. 编程式关闭
```lua
-- 应用内部调用关闭
webView:close()
```

#### 4. 手势关闭（预留）
当前版本保留手势检测变量，为后续手势关闭功能做准备。

### setContent 方法使用场景

`setContent` 方法用于动态更换PhoneWebView中的内容组件，适用于以下场景：

#### 1. 多页面应用切换
```lua
function MyApp:switchToPage(pageComponent)
    -- 切换到新页面
    self.webView:setContent(pageComponent)
end
```

#### 2. 动态内容加载
```lua
function MyApp:onMenuItemClick(menuItem)
    local contentPanel = self:createContentForItem(menuItem)
    self.webView:setContent(contentPanel)
end
```

#### 3. 模态对话框显示
```lua
function MyApp:showModalDialog()
    local modalPanel = self:createModalDialog()
    self.webView:setContent(modalPanel)
end
```

#### 4. 数据刷新界面
```lua
function MyApp:refreshData(newData)
    local updatedPanel = self:createUpdatedUI(newData)
    self.webView:setContent(updatedPanel)
end
```

#### 注意事项：
- `setContent` 会自动清理旧内容并设置新内容
- 适合需要动态界面切换的复杂应用
- 单页面应用（如示例应用）通常不需要使用此方法

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

## 图标纹理规范

### 应用图标要求
- **尺寸**: 应用图标必须为 80×80 像素
- **格式**: PNG格式，支持透明背景
- **路径**: 图标文件应放在应用的 `media/ui/` 目录下
- **命名**: 建议使用应用ID命名，如 `MyApp_icon.png`
- **加载**: 使用 `getTexture()` 函数加载图标纹理，而不是直接使用路径

### 图标示例代码
```lua
-- 应用构造函数中设置图标纹理
function MyApp.App:new()
    local obj = PhoneFrameworkCore.App:new(
        "MyApp",                           -- 应用ID
        getTexture("media/ui/MyApp_icon.png"), -- 图标纹理 (80x80像素)
        getText("UI_MyApp_Name"),          -- 显示名称 (国际化)
        getText("UI_MyApp_Description")     -- 描述 (国际化)
    )
    setmetatable(obj, {__index = self})
    
    -- 应用特定属性
    obj.customData = "示例数据"
    
    return obj
end
```

### 图标设计建议
1. **简洁性**: 保持图标简洁明了，避免过多细节
2. **可识别性**: 确保图标在小尺寸下仍然清晰可辨
3. **对比度**: 使用适当的对比度，确保在不同背景下可见
4. **一致性**: 与游戏整体风格保持一致

### 图标文件结构示例
```
mods/
├── MyApp/
│   ├── common/
│   │   └── media/
│   │       ├── ui/
│   │       │   └── MyApp_icon.png      -- 80x80 应用图标
│   │       └── lua/
│   │           └── client/
│   │               └── MyApp.lua
```

## 示例应用结构

```
mods/
├── MyApp/
│   ├── 42/
│   │   └── mod.info
│   ├── common/
│   │   ├── mod.info
│   │   └── media/
│   │       ├── ui/
│   │       │   └── MyApp_icon.png      -- 80x80 应用图标
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