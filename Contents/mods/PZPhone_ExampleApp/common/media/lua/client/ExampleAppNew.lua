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
        "", 
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

-- 应用创建方法 - 在PhoneWebView中创建UI
function ExampleAppNew.App:onCreate(webView)
    print("[ExampleAppNew] Creating app UI...")
    
    -- 获取内容面板
    local contentPanel = webView:getContentPanel()
    
    -- -- 创建主容器面板
    self.mainPanel = ISPanel:new(20, 20, contentPanel.width - 40, contentPanel.height - 40)
    self.mainPanel:initialise()
    self.mainPanel.backgroundColor = {r=0.95, g=0.95, b=0.95, a=0.9}
    contentPanel:addChild(self.mainPanel)
    
    -- 标题文本（使用drawText绘制）
    self.titleText = getText("UI_ExampleAppNew_Title")
    self.titleX = 20
    self.titleY = 20
    self.titleWidth = self.mainPanel.width - 40
    
    -- 创建功能按钮区域
    local buttonSection = ISPanel:new(0, 70, self.mainPanel.width, 120)
    buttonSection:initialise()
    buttonSection.backgroundColor = {r=0.9, g=0.9, b=0.9, a=0.5}
    self.mainPanel:addChild(buttonSection)
    
    -- 创建功能按钮1
    local button1 = ISButton:new(20, 20, 150, 35, getText("UI_ExampleAppNew_Button1"), 
        self, self.onButton1Click)
    button1:initialise()
    button1.backgroundColor = {r=0.2, g=0.5, b=0.8, a=0.9}
    button1.borderColor = {r=0.1, g=0.3, b=0.5, a=1}
    buttonSection:addChild(button1)
    
    -- 创建功能按钮2
    local button2 = ISButton:new(190, 20, 150, 35, getText("UI_ExampleAppNew_Button2"), 
        self, self.onButton2Click)
    button2:initialise()
    button2.backgroundColor = {r=0.8, g=0.5, b=0.2, a=0.9}
    button2.borderColor = {r=0.5, g=0.3, b=0.1, a=1}
    buttonSection:addChild(button2)
    
    -- 计数器文本（使用drawText绘制）
    self.counterText = getText("UI_ExampleAppNew_Counter") .. ": 0"
    self.counterX = 20
    self.counterY = 70
    self.counterWidth = 200
    
    -- 创建信息面板
    self.infoSection = ISPanel:new(0, 210, self.mainPanel.width, 120)
    self.infoSection:initialise()
    self.infoSection.backgroundColor = {r=0.85, g=0.85, b=0.85, a=0.5}
    self.mainPanel:addChild(self.infoSection)
    
    -- 信息文本（使用drawText绘制）
    self.infoText = getText("UI_ExampleAppNew_Welcome")
    self.infoX = 20
    self.infoY = 20
    self.infoWidth = self.infoSection.width - 40
    
    -- 创建重置按钮
    local resetButton = ISButton:new(20, 70, 100, 30, getText("UI_ExampleAppNew_Reset"), 
        self, self.onResetClick)
    resetButton:initialise()
    resetButton.backgroundColor = {r=0.7, g=0.2, b=0.2, a=0.9}
    resetButton.borderColor = {r=0.4, g=0.1, b=0.1, a=1}
    self.infoSection:addChild(resetButton)
    
    -- 设置渲染函数
    self:setRenderFunction()
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

-- 渲染函数
function ExampleAppNew.App:render()
    -- 绘制标题文本
    if self.titleText then
        local textWidth = getTextManager():MeasureStringX(UIFont.Medium, self.titleText)
        local textX = self.titleX + (self.titleWidth - textWidth) / 2
        
        self.mainPanel:drawText(self.titleText, textX, self.titleY, 0.1, 0.1, 0.1, 1, UIFont.Medium)
    end
    
    -- 绘制计数器文本
    if self.counterText then
        local textWidth = getTextManager():MeasureStringX(UIFont.Small, self.counterText)
        local textX = self.counterX + (self.counterWidth - textWidth) / 2
        
        self.mainPanel:drawText(self.counterText, textX, self.counterY, 0.3, 0.3, 0.3, 1, UIFont.Small)
    end
    
    -- 绘制信息文本（在信息面板上绘制）
    if self.infoText and self.infoSection then
        local textWidth = getTextManager():MeasureStringX(UIFont.Small, self.infoText)
        local textX = self.infoX + (self.infoWidth - textWidth) / 2
        
        self.infoSection:drawText(self.infoText, textX, self.infoY, 0.3, 0.3, 0.3, 1, UIFont.Small)
    end
end

-- 设置渲染函数
function ExampleAppNew.App:setRenderFunction()
    if self.mainPanel then
        self.mainPanel.render = function()
            self:render()
        end
    end
end