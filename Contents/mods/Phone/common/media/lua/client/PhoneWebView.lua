-- PhoneWebView容器组件
-- 提供类似WebView的功能，包含返回、关闭按钮和标题栏
-- 作为应用的基础容器

PhoneWebView = {}
PhoneWebView.__index = PhoneWebView

-- 构造函数
function PhoneWebView:new(x, y, width, height, parent)
    local obj = {}
    setmetatable(obj, self)
    
    -- 位置和尺寸
    obj.x = x or 0
    obj.y = y or 0
    obj.width = width or 800
    obj.height = height or 600
    
    -- 父窗口引用
    obj.parent = parent
    
    -- UI组件
    obj.panel = ISPanel:new(obj.x, obj.y, obj.width, obj.height)
    obj.panel:initialise()
    obj.panel.view = obj -- 设置回调引用
    
    -- 创建头部区域
    obj:createHeader()
    
    -- 创建内容区域
    obj:createContentArea()
    
    -- 设置渲染函数
    obj:setRenderFunction()
    
    return obj
end

-- 创建头部区域
function PhoneWebView:createHeader()
    local headerHeight = 40
    
    -- 头部面板
    self.headerPanel = ISPanel:new(0, 0, self.width, headerHeight)
    self.headerPanel:initialise()
    self.headerPanel.backgroundColor = {r=0.85, g=0.85, b=0.85, a=0.9}
    self.panel:addChild(self.headerPanel)
    
    -- 返回按钮
    local backButton = ISButton:new(5, 5, 30, headerHeight - 10, "<", self.panel, self.onBack)
    backButton:initialise()
    backButton.backgroundColor = {r=0.7, g=0.7, b=0.7, a=0.8}
    backButton.borderColor = {r=0.3, g=0.3, b=0.3, a=1}
    backButton.tooltip = getText("UI_WebView_Back")
    backButton.target = self
    self.headerPanel:addChild(backButton)
    self.backButton = backButton
    
    -- 关闭按钮
    local closeButton = ISButton:new(self.width - 35, 5, 30, headerHeight - 10, "X", self.panel, self.onClose)
    closeButton:initialise()
    closeButton.backgroundColor = {r=0.8, g=0.2, b=0.2, a=0.8}
    closeButton.borderColor = {r=0.5, g=0.1, b=0.1, a=1}
    closeButton.tooltip = getText("UI_WebView_Close")
    self.headerPanel:addChild(closeButton)
    self.closeButton = closeButton
    
    -- 标题文本（使用drawText绘制）
    self.title = "Untitled"
    self.titleX = 40
    self.titleY = 10
    self.titleWidth = self.width - 80
end

-- 创建内容区域
function PhoneWebView:createContentArea()
    local contentY = self.headerPanel.height
    local contentHeight = self.height - contentY
    
    -- 内容面板
    self.contentPanel = ISPanel:new(0, contentY, self.width, contentHeight)
    self.contentPanel:initialise()
    self.contentPanel.backgroundColor = {r=0.95, g=0.95, b=0.95, a=0.9}
    self.panel:addChild(self.contentPanel)
end

-- 设置标题
function PhoneWebView:setTitle(title)
    self.title = title or "Untitled"
    print("[PhoneWebView] Title set to: " .. self.title)
end

-- 设置内容组件
function PhoneWebView:setContent(component)
    -- 清除现有内容
    if self.currentContent then
        self.contentPanel:removeChild(self.currentContent)
    end
    
    -- 设置新内容
    if component then
        self.contentPanel:addChild(component)
        self.currentContent = component
    else
        self.currentContent = nil
    end
end

-- 返回按钮事件
function PhoneWebView:onBack(button)
    -- 获取PhoneWebView实例
    local webView = button.target
    if not webView then return end
    
    -- 查找应用或框架的回调函数
    local callbackTarget = webView.app or webView.parent
    if callbackTarget and callbackTarget.onWebViewBack then
        callbackTarget:onWebViewBack(webView)
    elseif webView.app and PhoneFrameworkCore and PhoneFrameworkCore.returnToHome then
        -- 如果没有特定的回调函数，使用默认返回主页
        PhoneFrameworkCore.returnToHome()
    end
end

-- 关闭按钮事件
function PhoneWebView:onClose()
    -- 查找应用或框架的回调函数
    local callbackTarget = self.app or self.parent
    if callbackTarget and callbackTarget.onWebViewClose then
        callbackTarget:onWebViewClose(self)
    else
        -- 默认行为：返回主页
        if self.app and self.app.onDestroy then
            self.app:onDestroy()
        end
        if PhoneFrameworkCore and PhoneFrameworkCore.returnToHome then
            PhoneFrameworkCore.returnToHome()
        end
    end
end

-- 获取内容面板
function PhoneWebView:getContentPanel()
    return self.contentPanel
end

-- 获取头部面板
function PhoneWebView:getHeaderPanel()
    return self.headerPanel
end

-- 获取主面板
function PhoneWebView:getPanel()
    return self.panel
end

-- 显示/隐藏
function PhoneWebView:setVisible(visible)
    self.panel:setVisible(visible)
end

function PhoneWebView:isVisible()
    return self.panel:isVisible()
end

-- 从UI管理器中移除
function PhoneWebView:removeFromUIManager()
    self.panel:removeFromUIManager()
end

-- 渲染函数
function PhoneWebView:render()
    -- 绘制标题文本
    if self.title then
        local textWidth = getTextManager():MeasureStringX(UIFont.Medium, self.title)
        local textX = self.titleX + (self.titleWidth - textWidth) / 2
        
        self.panel:drawText(self.title, textX, self.titleY, 0.1, 0.1, 0.1, 1, UIFont.Medium)
    end
end

-- 设置渲染函数
function PhoneWebView:setRenderFunction()
    self.panel.render = function()
        self:render()
    end
end