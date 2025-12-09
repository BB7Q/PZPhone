-- 示例应用文件
-- 展示如何使用手机框架创建自定义应用

ExampleApp = {}

-- 简单的示例应用类
ExampleApp.ExampleApp = {}

-- 应用构造函数
function ExampleApp.ExampleApp:new()
    local obj = {}
    obj.name = "ExampleApp"
    obj.icon = ""
    obj.displayName = getText("UI_ExampleApp_Name")
    obj.appTitle = getText("UI_ExampleApp_Title") -- 应用标题
    obj.appWindow = nil
    
    -- 设置元表以支持继承和方法调用
    setmetatable(obj, self)
    self.__index = self
    
    return obj
end

-- 应用启动方法 - 手动创建布局（避免继承问题）
function ExampleApp.ExampleApp:onStart(parentWindow)
    -- 手动创建应用布局，避免复杂的继承问题
    self:createAppLayout(parentWindow)
    
    -- 初始化应用内容
    self:initAppContent()
    
    print("[ExampleApp] App started: " .. self.name)
end

-- 创建应用基础布局
function ExampleApp.ExampleApp:createAppLayout(parentWindow)
    -- 使用框架提供的应用窗口
    self.appWindow = parentWindow
    
    -- 获取内容区域（框架已提供）
    self.contentPanel = ISPanel:new(20, 60, parentWindow.innerWidth - 20, parentWindow.innerHeight - 60)
    self.contentPanel:initialise()
    self.contentPanel.backgroundColor = {r=1, g=1, b=1, a=0.9}
    parentWindow:addChild(self.contentPanel)
end

-- 应用内容初始化方法
function ExampleApp.ExampleApp:initAppContent()
    print("[ExampleApp] Initialize app content")
    
    -- 在框架提供的内容区域中添加应用特定内容
    if not self.contentPanel then return end
    
    -- 创建功能按钮区域
    local buttonSection = ISPanel:new(20, 20, self.contentPanel.width - 40, 120)
    buttonSection:initialise()
    buttonSection.backgroundColor = {r=0.95, g=0.95, b=0.95, a=0.5}
    self.contentPanel:addChild(buttonSection)
    
    -- 创建功能按钮1
    local button1 = ISButton:new(20, 20, 150, 35, getText("UI_ExampleApp_Button1"), self, self.onButton1Click)
    button1:initialise()
    button1.backgroundColor = {r=0.2, g=0.5, b=0.8, a=0.9}
    button1.borderColor = {r=0.1, g=0.3, b=0.5, a=1}
    self.contentPanel:addChild(button1)
    
    -- 创建功能按钮2
    local button2 = ISButton:new(190, 20, 150, 35, getText("UI_ExampleApp_Button2"), self, self.onButton2Click)
    button2:initialise()
    button2.backgroundColor = {r=0.8, g=0.5, b=0.2, a=0.9}
    button2.borderColor = {r=0.5, g=0.3, b=0.1, a=1}
    self.contentPanel:addChild(button2)
    
    -- 应用信息文本
    self.appInfoLabel = ISLabel:new(20, 80, self.contentPanel.width - 40, getText("UI_ExampleApp_Info"), 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.appInfoLabel:initialise()
    self.contentPanel:addChild(self.appInfoLabel)
    
    -- 创建关闭应用按钮
    local closeButton = ISButton:new(self.contentPanel.width/2 - 80, 200, 160, 35, getText("UI_ExampleApp_Close"), self, self.onCloseApp)
    closeButton:initialise()
    closeButton.backgroundColor = {r=0.9, g=0.2, b=0.2, a=0.9}
    closeButton.borderColor = {r=0.6, g=0.1, b=0.1, a=1}
    self.contentPanel:addChild(closeButton)
end

-- 按钮1点击事件
function ExampleApp.ExampleApp:onButton1Click(button, x, y)
    getSpecificPlayer(0):Say("Example App Function 1 Activated")
    
    -- 更新信息面板
    if self.appInfoLabel then
        self.appInfoLabel.name = getText("UI_ExampleApp_Action1") .. "\nThis demonstrates the button click functionality.\nTime: " .. os.date("%H:%M:%S")
    end
end

-- 按钮2点击事件
function ExampleApp.ExampleApp:onButton2Click(button, x, y)
    getSpecificPlayer(0):Say("Example App Function 2 Activated")
    
    -- 更新信息面板
    if self.appInfoLabel then
        self.appInfoLabel.name = getText("UI_ExampleApp_Action2") .. "\nThis shows the framework's event handling.\nTime: " .. os.date("%H:%M:%S")
    end
end

-- 应用关闭方法
function ExampleApp.ExampleApp:onClose()
    print("[ExampleApp] App closed")
    
    -- 清理应用特定的资源
    if self.appWindow then
        self.appWindow:setVisible(false)
        self.appWindow:removeFromUIManager()
        self.appWindow = nil
    end
end

-- 应用渲染方法（可选）
function ExampleApp.ExampleApp:onAppRender()
    -- 可以在这里添加应用特定的渲染逻辑
    -- 框架已经提供了基础渲染
end

-- 关闭应用按钮点击事件
function ExampleApp.ExampleApp:onCloseApp(button, x, y)
    getSpecificPlayer(0):Say("Example App Closed")
    
    -- 通过框架关闭当前应用
    if PhoneFramework.currentApp then
        PhoneFramework.instance:closeCurrentApp()
    end
end



-- 初始化函数
function ExampleApp.init()
    -- 创建应用实例并注册到框架
    local exampleApp = ExampleApp.ExampleApp:new()
    PhoneFramework.registerApp(exampleApp)
    
    print("[ExampleApp] Example app module loaded")
end

-- 在框架初始化后注册应用
Events.OnGameStart.Add(ExampleApp.init)