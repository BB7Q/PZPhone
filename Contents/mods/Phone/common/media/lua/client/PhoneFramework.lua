-- 手机框架主文件
-- 提供网格布局和应用管理功能

PhoneFramework = {};
PhoneFramework.instance = nil;
PhoneFramework.apps = {}; -- 注册的应用列表
PhoneFramework.currentApp = nil; -- 当前运行的应用

-- 应用基类定义
PhoneFramework.App = {}
PhoneFramework.App.__index = PhoneFramework.App

-- 应用基类构造函数
function PhoneFramework.App:new(name, icon, displayName)
    local obj = {}
    setmetatable(obj, self)
    obj.name = name or "UnknownApp"
    obj.icon = icon or ""
    obj.displayName = displayName or name
    obj.appWindow = nil
    obj.appTitle = displayName or name
    return obj
end

-- 应用启动方法 - 框架提供基础布局
function PhoneFramework.App:onStart(parentWindow)
    -- 创建应用基础布局
    self:createAppLayout(parentWindow)
    
    -- 调用应用的初始化方法
    if self.onAppInit then
        self:onAppInit()
    end
    
    print("[PhoneFramework] App started: " .. self.name)
end

-- 应用关闭方法
function PhoneFramework.App:onClose()
    -- 调用应用的清理方法
    if self.onAppClose then
        self:onAppClose()
    end
    
    -- 清理应用窗口
    if self.appWindow then
        self.appWindow:setVisible(false)
        self.appWindow:removeFromUIManager()
        self.appWindow = nil
    end
    
    print("[PhoneFramework] App closed: " .. self.name)
end

-- 创建应用基础布局
function PhoneFramework.App:createAppLayout(parentWindow)
    -- 使用父窗口的内屏区域作为应用界面
    local innerX = parentWindow.innerX
    local innerY = parentWindow.innerY + 40 -- 留出顶部返回区域（40px）
    local innerWidth = parentWindow.innerWidth
    local innerHeight = parentWindow.innerHeight - 40
    
    -- 创建应用窗口
    self.appWindow = ISPanel:new(innerX, innerY, innerWidth, innerHeight)
    self.appWindow:initialise()
    self.appWindow:setVisible(true)
    self.appWindow.backgroundColor = {r=0.9, g=0.9, b=0.9, a=1}
    parentWindow:addChild(self.appWindow)
    
    -- 创建标题区域（高度调整为40px）
    self.headerPanel = ISPanel:new(0, 0, innerWidth, 40)
    self.headerPanel:initialise()
    self.headerPanel.backgroundColor = {r=0.8, g=0.8, b=0.8, a=0.9}
    self.appWindow:addChild(self.headerPanel)
    
    -- 创建应用标题（居中显示在header区域）
    self.titleLabel = ISLabel:new(innerWidth/2 - 100, 10, 200, self.appTitle or self.displayName, 0.1, 0.1, 0.1, 1, UIFont.Medium, true)
    self.titleLabel:initialise()
    self.headerPanel:addChild(self.titleLabel)
    
    -- 创建内容区域（应用可以在这里添加自己的内容）
    self.contentPanel = ISPanel:new(20, 60, innerWidth - 40, innerHeight - 80)
    self.contentPanel:initialise()
    self.contentPanel.backgroundColor = {r=1, g=1, b=1, a=0.9}
    self.appWindow:addChild(self.contentPanel)
    
    -- 应用可以重写此方法来初始化自己的内容
    if self.initAppContent then
        self:initAppContent()
    end
end

-- 渲染应用界面
function PhoneFramework.App:prerender()
    if self.appWindow then
        -- 绘制应用背景
        self.appWindow:drawRect(0, 0, self.appWindow.width, self.appWindow.height, 0.95, 0.95, 0.95, 0.9)
        
        -- 绘制应用边框
        self.appWindow:drawRectBorder(0, 0, self.appWindow.width, self.appWindow.height, 0.3, 0.3, 0.3, 1)
        
        -- 绘制header区域边框
        if self.headerPanel then
            self.headerPanel:drawRect(0, 0, self.headerPanel.width, self.headerPanel.height, 0.8, 0.8, 0.8, 0.9)
            self.headerPanel:drawRectBorder(0, 0, self.headerPanel.width, self.headerPanel.height, 0.3, 0.3, 0.3, 1)
        end
        
        -- 绘制内容区域背景
        if self.contentPanel then
            self.contentPanel:drawRect(0, 0, self.contentPanel.width, self.contentPanel.height, 1, 1, 1, 0.9)
            self.contentPanel:drawRectBorder(0, 0, self.contentPanel.width, self.contentPanel.height, 0.2, 0.2, 0.2, 1)
        end
        
        -- 调用应用的渲染方法
        if self.onAppRender then
            self:onAppRender()
        end
    end
end

-- 手机界面类定义
PhoneFramework.PhoneWindow = ISPanel:derive("PhoneFramework_PhoneWindow");

-- 构造函数
function PhoneFramework.PhoneWindow:initialise()
    ISPanel.initialise(self);
end

-- 创建界面元素
function PhoneFramework.PhoneWindow:createChildren()
    -- 计算内屏区域
    self.innerX = 14;
    self.innerY = 20;
    self.innerWidth = 1004;
    self.innerHeight = 704;
    
    -- 创建关闭按钮（40x40方形，与内屏区域对齐）
    self.closeButton = ISButton:new(self.innerX + self.innerWidth - 40, self.innerY, 40, 40, "X", self, PhoneFramework.PhoneWindow.onClose);
    self.closeButton:initialise();
    self.closeButton.backgroundColor = {r=0.8, g=0.1, b=0.1, a=0.8};
    self.closeButton.borderColor = {r=0.5, g=0, b=0, a=1};
    self:addChild(self.closeButton);
    
    -- 一级页面不显示标题（根据用户要求）
    -- self.titleLabel = ISLabel:new(self.innerX + self.innerWidth/2 - 100, self.innerY + 30, 50, getText("UI_Phone_Title"), 1, 1, 1, 1, UIFont.Large, true);
    -- self.titleLabel:initialise();
    -- self:addChild(self.titleLabel);
    
    -- 创建应用图标容器
    self:createAppGrid();
end

-- 创建应用网格布局
function PhoneFramework.PhoneWindow:createAppGrid()
    -- 网格配置：每行4个应用，共3行
    self.gridColumns = 4;
    self.gridRows = 3;
    self.iconSize = 150; -- 图标大小
    self.iconSpacing = 30; -- 图标间距
    
    -- 计算网格起始位置
    local gridWidth = (self.iconSize + self.iconSpacing) * self.gridColumns - self.iconSpacing;
    local gridHeight = (self.iconSize + self.iconSpacing) * self.gridRows - self.iconSpacing;
    
    self.gridStartX = self.innerX + (self.innerWidth - gridWidth) / 2;
    self.gridStartY = self.innerY + 100;
    
    -- 创建应用图标按钮
    self.appButtons = {};
    
    for i, app in ipairs(PhoneFramework.apps) do
        local row = math.floor((i - 1) / self.gridColumns);
        local col = (i - 1) % self.gridColumns;
        
        local x = self.gridStartX + col * (self.iconSize + self.iconSpacing);
        local y = self.gridStartY + row * (self.iconSize + self.iconSpacing);
        
        -- 创建应用图标按钮
        local appButton = ISButton:new(x, y, self.iconSize, self.iconSize, app.displayName, self, PhoneFramework.PhoneWindow.onAppClick);
        appButton:initialise();
        appButton.app = app; -- 关联应用对象
        appButton.backgroundColor = {r=0.2, g=0.4, b=0.8, a=0.8};
        appButton.borderColor = {r=0.1, g=0.2, b=0.4, a=1};
        appButton.tooltip = app.displayName;
        
        self:addChild(appButton);
        table.insert(self.appButtons, appButton);
    end
    
    -- 如果没有应用，显示提示信息
    if #PhoneFramework.apps == 0 then
        self.noAppsLabel = ISLabel:new(self.gridStartX, self.gridStartY + 100, 400, getText("UI_Phone_NoApps"), 0.6, 0.6, 0.6, 1, UIFont.Medium, true);
        self.noAppsLabel:initialise();
        self:addChild(self.noAppsLabel);
    end
end

-- 渲染界面
function PhoneFramework.PhoneWindow:prerender()
    -- 绘制手机背景图片
    if self.backgroundTexture then
        self:drawTexture(self.backgroundTexture, 0, 0, 1, 1, 1, 1);
    end
    
    -- 绘制内屏区域
    self:drawRect(self.innerX, self.innerY, self.innerWidth, self.innerHeight, 0.95, 0.95, 0.95, 0.9);
    
    -- 绘制内屏边框
    self:drawRectBorder(self.innerX, self.innerY, self.innerWidth, self.innerHeight, 1, 0.2, 0.2, 0.2);
    
    -- 如果当前有运行的应用，显示返回按钮
    if PhoneFramework.currentApp then
        self:drawRect(self.innerX, self.innerY, self.innerWidth, 60, 0.8, 0.8, 0.8, 0.9);
        self:drawText("< " .. getText("UI_Phone_BackToHome"), self.innerX + 20, self.innerY + 20, 0.2, 0.2, 0.2, 1, UIFont.Medium);
    end
end

-- 关闭按钮点击事件
function PhoneFramework.PhoneWindow:onClose()
    -- 如果当前有运行的应用，先关闭应用
    if PhoneFramework.currentApp then
        self:closeCurrentApp();
    end
    
    -- 关闭手机窗口
    self:setVisible(false);
    self:removeFromUIManager();
    PhoneFramework.instance = nil;
end

-- 应用图标点击事件
function PhoneFramework.PhoneWindow:onAppClick(button, x, y)
    -- 双击检测（简单实现，实际应该用时间间隔判断）
    if button.app then
        self:openApp(button.app);
    end
end

-- 打开应用
function PhoneFramework.PhoneWindow:openApp(app)
    if PhoneFramework.currentApp then
        self:closeCurrentApp();
    end
    
    PhoneFramework.currentApp = app;
    
    -- 隐藏所有应用图标
    for _, button in ipairs(self.appButtons) do
        button:setVisible(false);
    end
    
    if self.noAppsLabel then
        self.noAppsLabel:setVisible(false);
    end
    
    -- 调用应用的启动方法
    if app and app.onStart then
        app:onStart(self);
        
        print("[PhoneFramework] Open app: " .. app.name);
    else
        print("[PhoneFramework] Error: Invalid app object");
    end
end

-- 关闭当前应用
function PhoneFramework.PhoneWindow:closeCurrentApp()
    if PhoneFramework.currentApp and PhoneFramework.currentApp.onClose then
        PhoneFramework.currentApp:onClose();
        PhoneFramework.currentApp = nil;
        
        -- 显示所有应用图标
        for _, button in ipairs(self.appButtons) do
            button:setVisible(true);
        end
        
        if self.noAppsLabel then
            self.noAppsLabel:setVisible(true);
        end
        
        print("[PhoneFramework] Close current app");
    else
        print("[PhoneFramework] No app to close or invalid app object");
    end
end

-- 鼠标点击事件处理
function PhoneFramework.PhoneWindow:onMouseDown(x, y)
    -- 如果当前有运行的应用，点击顶部区域返回主页（高度调整为40px）
    if PhoneFramework.currentApp and y >= self.innerY and y <= self.innerY + 40 and x >= self.innerX and x <= self.innerX + self.innerWidth then
        self:closeCurrentApp();
        return true;
    end
    
    return ISPanel.onMouseDown(self, x, y);
end

-- 渲染界面
function PhoneFramework.PhoneWindow:prerender()
    -- 绘制手机背景图片
    if self.backgroundTexture then
        self:drawTexture(self.backgroundTexture, 0, 0, 1, 1, 1, 1);
    end
    
    -- 绘制内屏区域
    self:drawRect(self.innerX, self.innerY, self.innerWidth, self.innerHeight, 0.95, 0.95, 0.95, 0.9);
    
    -- 绘制内屏边框
    self:drawRectBorder(self.innerX, self.innerY, self.innerWidth, self.innerHeight, 0.2, 0.2, 0.2, 1);
    
    -- 如果当前有运行的应用，显示返回按钮和区域
    if PhoneFramework.currentApp then
        -- 绘制返回区域背景（高度调整为40px）
        self:drawRect(self.innerX, self.innerY, self.innerWidth, 40, 0.8, 0.8, 0.8, 0.9);
        
        -- 绘制返回区域边框
        self:drawRectBorder(self.innerX, self.innerY, self.innerWidth, 40, 0.3, 0.3, 0.3, 0.8);
        
        -- 绘制返回箭头和文字（垂直居中）
        self:drawText("< " .. getText("UI_Phone_BackToHome"), self.innerX + 20, self.innerY + 12, 0.2, 0.2, 0.2, 1, UIFont.Small);
    end
end

-- 注册应用
function PhoneFramework.registerApp(app)
    if app and app.name then
        table.insert(PhoneFramework.apps, app);
        print("[PhoneFramework] Register app: " .. app.name);
        return true;
    end
    return false;
end

-- 创建手机界面实例
function PhoneFramework.createPhoneWindow(player, phoneItem)
    if PhoneFramework.instance and PhoneFramework.instance:isVisible() then
        PhoneFramework.instance:setVisible(false);
        PhoneFramework.instance:removeFromUIManager();
        PhoneFramework.instance = nil;
    end
    
    -- 获取屏幕尺寸
    local screenWidth = getCore():getScreenWidth();
    local screenHeight = getCore():getScreenHeight();
    
    -- 计算窗口位置和大小
    local width = 1040;
    local height = 744;
    local x = (screenWidth - width) / 2;
    local y = (screenHeight - height) / 2;
    
    -- 创建窗口
    PhoneFramework.instance = PhoneFramework.PhoneWindow:new(x, y, width, height);
    PhoneFramework.instance:initialise();
    PhoneFramework.instance:addToUIManager();
    PhoneFramework.instance:setVisible(true);
    
    -- 设置手机物品引用
    PhoneFramework.instance.phoneItem = phoneItem;
    
    -- 加载背景图片
    PhoneFramework.instance.backgroundTexture = getTexture("media/ui/phone_open.png");
    
    return PhoneFramework.instance;
end

-- 右键菜单处理函数
PhoneFramework.onPhoneContextMenu = function(player, context, items)
    print("[PhoneFramework] Check right-click menu items...");
    
    -- 参考标准做法检查物品
    if not items or not items[1] or not items[1].items then return end
    
    local phoneItem = nil;
    
    -- 使用ipairs遍历物品列表
    for _, item in ipairs(items[1].items) do
        if instanceof(item, "InventoryItem") and item:getFullType() == "Base.Phone" then
            phoneItem = item;
            print("[PhoneFramework] Found phone item: " .. tostring(item:getFullType()));
            break;
        end
    end
    
    if phoneItem then
        -- 添加打开手机选项
        local openOption = context:addOption(getText("UI_Phone_OpenPhone"), phoneItem, PhoneFramework.openPhone);
        print("[PhoneFramework] Right-click menu option added");
    else
        print("[PhoneFramework] No phone item found");
    end
end

-- 打开手机函数
PhoneFramework.openPhone = function(phoneItem)
    local player = getSpecificPlayer(0);
    PhoneFramework.createPhoneWindow(player, phoneItem);
end

-- 初始化函数
PhoneFramework.init = function()
    -- 注册物品右键菜单事件
    Events.OnFillInventoryObjectContextMenu.Add(PhoneFramework.onPhoneContextMenu);
    
    -- 注册默认应用（示例应用）
    require "ExampleApp";
    
    print("[PhoneFramework] Phone framework module loaded");
end

-- 游戏启动时注册事件
Events.OnGameStart.Add(PhoneFramework.init);