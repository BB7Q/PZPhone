-- 示例应用 - 展示新框架的使用方式
-- 使用PhoneFrameworkCore和PhoneWebView实现

ExampleAppNew = {}
ExampleAppNew.App = {}

-- 延迟设置元表，确保PhoneFrameworkCore已加载
local function setupMetatable()
    if PhoneFrameworkCore and PhoneFrameworkCore.App then
        setmetatable(ExampleAppNew.App, {__index = PhoneFrameworkCore.App})
        return true
    end
    return false
end

-- 尝试设置元表
if not setupMetatable() then
    -- 如果失败，添加到游戏启动事件中
    Events.OnGameStart.Add(setupMetatable)
end

-- 示例应用构造函数
function ExampleAppNew.App:new()
    local obj = PhoneFrameworkCore.App:new(
        "ExampleAppNew", 
        getTexture("media/ui/app_icon.png"), 
        getText("UI_ExampleAppNew_Name"),
        getText("UI_ExampleAppNew_Description")
    )
    setmetatable(obj, {__index = self})
    
    -- 应用特定属性
    obj.buttonClickCount = 0
    obj.lastAction = ""
    obj.infoLabel = nil
    
    return obj
end

-- 应用创建方法 - 在PhoneWebView中创建UI（现代化设计）
function ExampleAppNew.App:onCreate(webView)
    print("[ExampleAppNew] Creating modern app UI...")
    
    -- 获取内容面板
    local contentPanel = webView:getContentPanel()
    
    -- 创建自定义顶部栏（现代设计）
    self.headerPanel = ISPanel:new(0, 0, contentPanel.width, 60)
    self.headerPanel:initialise()
    self.headerPanel.backgroundColor = {r=0.98, g=0.98, b=0.98, a=0.95}
    contentPanel:addChild(self.headerPanel)
    
    -- 应用标题（现代风格）
    self.titleText = getText("UI_ExampleAppNew_Title")
    
    -- 关闭按钮（现代风格，右上角）
    self.closeButton = ISButton:new(contentPanel.width - 45, 15, 30, 30, "×", 
        self, self.onCloseClick)
    self.closeButton:initialise()
    self.closeButton.backgroundColor = {r=0.95, g=0.95, b=0.95, a=0.8}
    self.closeButton.borderColor = {r=0.7, g=0.7, b=0.7, a=1}
    self.closeButton.textColor = {r=0.3, g=0.3, b=0.3, a=1}
    self.headerPanel:addChild(self.closeButton)
    
    -- 创建主容器面板（内容区域）
    self.mainPanel = ISPanel:new(0, 60, contentPanel.width, contentPanel.height - 60)
    self.mainPanel:initialise()
    self.mainPanel.backgroundColor = {r=0.95, g=0.95, b=0.95, a=0.9}
    contentPanel:addChild(self.mainPanel)
    
    -- 创建功能卡片区域
    local cardSection = ISPanel:new(20, 20, self.mainPanel.width - 40, 180)
    cardSection:initialise()
    cardSection.backgroundColor = {r=1, g=1, b=1, a=0.9}
    cardSection.borderColor = {r=0.9, g=0.9, b=0.9, a=1}
    self.mainPanel:addChild(cardSection)
    
    -- 创建功能按钮1（现代风格）
    local button1 = ISButton:new(30, 30, 200, 50, getText("UI_ExampleAppNew_Button1"), 
        self, self.onButton1Click)
    button1:initialise()
    button1.backgroundColor = {r=0.1, g=0.5, b=0.9, a=0.9}
    button1.borderColor = {r=0.08, g=0.4, b=0.8, a=1}
    button1.textColor = {r=1, g=1, b=1, a=1}
    cardSection:addChild(button1)
    
    -- 创建功能按钮2（现代风格）
    local button2 = ISButton:new(250, 30, 200, 50, getText("UI_ExampleAppNew_Button2"), 
        self, self.onButton2Click)
    button2:initialise()
    button2.backgroundColor = {r=0.9, g=0.5, b=0.1, a=0.9}
    button2.borderColor = {r=0.8, g=0.4, b=0.08, a=1}
    button2.textColor = {r=1, g=1, b=1, a=1}
    cardSection:addChild(button2)
    
    -- 计数器显示（现代风格）
    self.counterText = getText("UI_ExampleAppNew_Counter") .. ": 0"
    
    -- 创建信息卡片
    self.infoCard = ISPanel:new(20, 220, self.mainPanel.width - 40, 120)
    self.infoCard:initialise()
    self.infoCard.backgroundColor = {r=1, g=1, b=1, a=0.9}
    self.infoCard.borderColor = {r=0.9, g=0.9, b=0.9, a=1}
    self.mainPanel:addChild(self.infoCard)
    
    -- 信息文本
    self.infoText = getText("UI_ExampleAppNew_Welcome")
    
    -- 创建重置按钮（现代风格）
    local resetButton = ISButton:new(20, 70, 100, 35, getText("UI_ExampleAppNew_Reset"), 
        self, self.onResetClick)
    resetButton:initialise()
    resetButton.backgroundColor = {r=0.8, g=0.2, b=0.2, a=0.9}
    resetButton.borderColor = {r=0.6, g=0.1, b=0.1, a=1}
    resetButton.textColor = {r=1, g=1, b=1, a=1}
    self.infoCard:addChild(resetButton)
    
    -- 设置渲染函数到主面板
    self.mainPanel.render = function()
        -- 绘制顶部栏标题（左对齐）
        if self.titleText then
            self.headerPanel:drawText(self.titleText, 20, 20, 0.1, 0.1, 0.1, 1, UIFont.Large)
        end
        
        -- 绘制计数器文本（左对齐）
        if self.counterText then
            self.mainPanel:drawText(self.counterText, 30, 100, 0.2, 0.2, 0.2, 1, UIFont.Medium)
        end
        
        -- 绘制信息文本（左对齐）
        if self.infoText and self.infoCard then
            self.infoCard:drawText(self.infoText, 20, 20, 0.3, 0.3, 0.3, 1, UIFont.Small)
        end
    end
end

-- 应用销毁方法
function ExampleAppNew.App:onDestroy()
    print("[ExampleAppNew] Destroying app...")
    
    -- 清理资源
    self.mainPanel = nil
    self.infoLabel = nil
    self.counterLabel = nil
    
    -- 调用父类方法
    PhoneFrameworkCore.App.onDestroy(self)
end

-- 应用恢复方法
function ExampleAppNew.App:onResume()
    print("[ExampleAppNew] App resumed")
    
    -- 更新信息文本显示当前时间
    self.infoText = getText("UI_ExampleAppNew_Resumed") .. "\n" .. 
        getText("UI_ExampleAppNew_LastAction") .. ": " .. self.lastAction .. 
        "\n" .. getText("UI_ExampleAppNew_Time") .. ": " .. os.date("%H:%M:%S")
    
    -- 调用父类方法
    PhoneFrameworkCore.App.onResume(self)
end

-- 应用暂停方法
function ExampleAppNew.App:onPause()
    print("[ExampleAppNew] App paused")
    self.lastAction = getText("UI_ExampleAppNew_Paused")
    
    -- 调用父类方法
    PhoneFrameworkCore.App.onPause(self)
end

-- 按钮1点击事件
function ExampleAppNew.App:onButton1Click()
    self.buttonClickCount = self.buttonClickCount + 1
    self.lastAction = getText("UI_ExampleAppNew_Action1")
    
    -- 更新计数器文本
    self.counterText = getText("UI_ExampleAppNew_Counter") .. ": " .. self.buttonClickCount
    
    -- 更新信息文本
    self.infoText = getText("UI_ExampleAppNew_Action1") .. "\n" .. 
        getText("UI_ExampleAppNew_ClickCount") .. ": " .. self.buttonClickCount .. 
        "\n" .. getText("UI_ExampleAppNew_Time") .. ": " .. os.date("%H:%M:%S")
    
    -- 播放角色语音
    getSpecificPlayer(0):Say(getText("UI_ExampleAppNew_Say1") .. " (" .. self.buttonClickCount .. ")")
end

-- 按钮2点击事件
function ExampleAppNew.App:onButton2Click()
    self.buttonClickCount = self.buttonClickCount + 1
    self.lastAction = getText("UI_ExampleAppNew_Action2")
    
    -- 更新计数器文本
    self.counterText = getText("UI_ExampleAppNew_Counter") .. ": " .. self.buttonClickCount
    
    -- 更新信息文本
    self.infoText = getText("UI_ExampleAppNew_Action2") .. "\n" .. 
        getText("UI_ExampleAppNew_ClickCount") .. ": " .. self.buttonClickCount .. 
        "\n" .. getText("UI_ExampleAppNew_Time") .. ": " .. os.date("%H:%M:%S")
    
    -- 播放角色语音
    getSpecificPlayer(0):Say(getText("UI_ExampleAppNew_Say2") .. " (" .. self.buttonClickCount .. ")")
end

-- 关闭按钮点击事件
function ExampleAppNew.App:onCloseClick()
    print("[ExampleAppNew] Close button clicked")
    
    -- 使用WebView的关闭方法
    if self.webView and self.webView.close then
        self.webView:close()
    else
        -- 备用方法：通过框架返回主页
        if PhoneFrameworkCore and PhoneFrameworkCore.returnToHome then
            PhoneFrameworkCore.returnToHome()
        end
    end
end

-- 重置按钮点击事件
function ExampleAppNew.App:onResetClick()
    self.buttonClickCount = 0
    self.lastAction = getText("UI_ExampleAppNew_ResetAction")
    
    -- 更新计数器文本
    self.counterText = getText("UI_ExampleAppNew_Counter") .. ": 0"
    
    -- 更新信息文本
    self.infoText = getText("UI_ExampleAppNew_Welcome") .. "\n" .. 
        getText("UI_ExampleAppNew_ResetCompleted") .. 
        "\n" .. getText("UI_ExampleAppNew_Time") .. ": " .. os.date("%H:%M:%S")
    
    -- 播放角色语音
    getSpecificPlayer(0):Say(getText("UI_ExampleAppNew_ResetSay"))
end

-- 注册应用函数
local appInstance = nil

function ExampleAppNew.registerApp()
    if not PhoneFrameworkCore then
        print("[ExampleAppNew] Framework not found, waiting...")
        return false
    end
    
    -- 创建应用实例并注册到框架
    appInstance = ExampleAppNew.App:new()
    PhoneFrameworkCore.registerApp(appInstance)
    print("[ExampleAppNew] Example app registered")
    return true
end

-- 尝试立即注册应用
if not ExampleAppNew.registerApp() then
    -- 如果失败，等待框架初始化
    Events.OnGameStart.Add(ExampleAppNew.registerApp)
end



