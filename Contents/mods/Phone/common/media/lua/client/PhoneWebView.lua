-- PhoneWebView容器组件（现代化设计）
-- 提供类似WebView的功能，支持自定义顶部栏和手势关闭
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
    
    -- 创建全屏内容区域
    obj:createContentArea()
    
    -- 手势检测相关变量
    obj.touchStartY = 0
    obj.isDragging = false
    obj.dragStartY = 0
    obj.currentOffsetY = 0
    
    -- 设置渲染函数
    obj:setRenderFunction()
    
    return obj
end

-- 创建全屏内容区域
function PhoneWebView:createContentArea()
    -- 内容面板覆盖整个WebView
    self.contentPanel = ISPanel:new(0, 0, self.width, self.height)
    self.contentPanel:initialise()
    self.contentPanel.backgroundColor = {r=0.95, g=0.95, b=0.95, a=0.9}
    self.panel:addChild(self.contentPanel)
    
    -- 创建底部关闭控件（大点击区域，小视觉线条）
    self.closeControl = ISPanel:new(
        (self.width - 80) / 2, 
        self.height - 30, 
        80, 20
    )
    self.closeControl:initialise()
    self.closeControl.backgroundColor = {r=0, g=0, b=0, a=0} -- 透明背景
    self.closeControl.borderColor = {r=0, g=0, b=0, a=0} -- 透明边框
    self.closeControl.view = self -- 设置回调引用
    self.panel:addChild(self.closeControl)
    
    -- 创建视觉线条（实际显示的线条）
    self.closeLine = ISPanel:new(
        (self.width - 80) / 2, 
        self.height - 20, 
        80, 3
    )
    self.closeLine:initialise()
    self.closeLine.backgroundColor = {r=0.4, g=0.4, b=0.4, a=0.8}
    self.closeLine.borderColor = {r=0.6, g=0.6, b=0.6, a=0.9}
    self.panel:addChild(self.closeLine)
    
    -- 设置关闭控件的点击事件（修复self.view问题）
    function self.closeControl:onMouseDown(x, y)
        if self.view and self.view.performClose then
            self.view:performClose()
        end
        return true
    end
end

-- 设置渲染函数
function PhoneWebView:setRenderFunction()
    self.panel.render = function()
        self:render()
    end
end

-- 渲染函数
function PhoneWebView:render()
    -- 绘制关闭控件文本
    if self.closeText and self.closeControl then
        self.closeControl:drawText(self.closeText, self.closeTextX, self.closeTextY, 1, 1, 1, 1, UIFont.Small)
    end
end

-- 执行关闭操作
function PhoneWebView:performClose()
    print("[PhoneWebView] Performing close...")
    
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

-- 编程式关闭方法（供应用调用）
function PhoneWebView:close()
    self:performClose()
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