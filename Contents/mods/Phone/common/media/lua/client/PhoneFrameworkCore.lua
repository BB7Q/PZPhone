-- 手机框架核心
-- 负责应用管理、一级页面显示和整体框架协调

PhoneFrameworkCore = {}
PhoneFrameworkCore.instance = nil
PhoneFrameworkCore.currentView = nil -- 当前显示的视图
PhoneFrameworkCore.apps = {} -- 注册的应用列表
PhoneFrameworkCore.phoneWindow = nil -- 手机主窗口
PhoneFrameworkCore.appIcons = {} -- 应用图标按钮列表

-- 应用基类
PhoneFrameworkCore.App = {}
PhoneFrameworkCore.App.__index = PhoneFrameworkCore.App

-- 应用基类构造函数
function PhoneFrameworkCore.App:new(name, icon, displayName, description)
    local obj = {}
    setmetatable(obj, self)
    
    -- 基本信息
    obj.name = name or "UnknownApp"
    obj.icon = icon or ""
    obj.displayName = displayName or name
    obj.description = description or ""
    
    -- 应用状态
    obj.webView = nil
    obj.isActive = false
    
    return obj
end

-- 应用生命周期方法
function PhoneFrameworkCore.App:onCreate(webView)
    -- 应用创建时调用，子类可重写
    print("[PhoneFrameworkCore] App created: " .. self.name)
end

function PhoneFrameworkCore.App:onDestroy()
    -- 应用销毁时调用，子类可重写
    print("[PhoneFrameworkCore] App destroyed: " .. self.name)
end

function PhoneFrameworkCore.App:onResume()
    -- 应用恢复到前台时调用，子类可重写
    print("[PhoneFrameworkCore] App resumed: " .. self.name)
end

function PhoneFrameworkCore.App:onPause()
    -- 应用暂停到后台时调用，子类可重写
    print("[PhoneFrameworkCore] App paused: " .. self.name)
end

-- 注册应用
function PhoneFrameworkCore.registerApp(app)
    if not app or not app.name then
        print("[PhoneFrameworkCore] Error: Invalid app object")
        return false
    end
    
    -- 检查是否已注册同名应用
    for i, existingApp in ipairs(PhoneFrameworkCore.apps) do
        if existingApp.name == app.name then
            print("[PhoneFrameworkCore] Warning: App with name '" .. app.name .. "' already exists, replacing...")
            table.remove(PhoneFrameworkCore.apps, i)
            break
        end
    end
    
    table.insert(PhoneFrameworkCore.apps, app)
    print("[PhoneFrameworkCore] App registered: " .. app.name)
    
    -- 如果手机窗口已经创建，更新应用图标
    if PhoneFrameworkCore.phoneWindow then
        PhoneFrameworkCore.updateAppGrid()
    end
    
    return true
end

-- 打开应用
function PhoneFrameworkCore.openApp(app)
    if not app then
        print("[PhoneFrameworkCore] Error: Cannot open nil app")
        return false
    end
    
    -- 如果当前有应用在运行，先暂停它
    if PhoneFrameworkCore.currentView and PhoneFrameworkCore.currentView.app then
        local currentApp = PhoneFrameworkCore.currentView.app
        currentApp:onPause()
        currentApp.isActive = false
    end
    
    -- 创建PhoneWebView容器
    local webView = PhoneWebView:new(
        PhoneFrameworkCore.phoneWindow.innerX,
        PhoneFrameworkCore.phoneWindow.innerY,
        PhoneFrameworkCore.phoneWindow.innerWidth,
        PhoneFrameworkCore.phoneWindow.innerHeight
    )
    
    -- 设置WebView标题
    webView:setTitle(app.displayName)
    
    -- 关联应用和WebView
    app.webView = webView
    webView.app = app
    
    -- 设置WebView回调
    function webView.panel:onWebViewBack(view)
        PhoneFrameworkCore.returnToHome()
    end
    
    function webView.panel:onWebViewClose(view)
        if view.app and view.app.onDestroy then
            view.app:onDestroy()
        end
        PhoneFrameworkCore.returnToHome()
    end
    
    -- 创建应用内容
    if app.onCreate then
        app:onCreate(webView)
    end
    
    -- 设置当前视图
    PhoneFrameworkCore.currentView = webView
    app.isActive = true
    
    -- 添加到手机窗口并隐藏应用图标
    PhoneFrameworkCore.phoneWindow:addChild(webView.panel)
    PhoneFrameworkCore.hideAppIcons()
    
    -- 调用应用恢复方法
    if app.onResume then
        app:onResume()
    end
    
    print("[PhoneFrameworkCore] App opened: " .. app.name)
    return true
end

-- 返回主页
function PhoneFrameworkCore.returnToHome()
    -- 如果当前有应用在运行，暂停它
    if PhoneFrameworkCore.currentView and PhoneFrameworkCore.currentView.app then
        local app = PhoneFrameworkCore.currentView.app
        if app.onPause then
            app:onPause()
        end
        app.isActive = false
    end
    
    -- 移除当前视图
    if PhoneFrameworkCore.currentView then
        PhoneFrameworkCore.phoneWindow:removeChild(PhoneFrameworkCore.currentView.panel)
        PhoneFrameworkCore.currentView = nil
    end
    
    -- 显示应用图标
    PhoneFrameworkCore.showAppIcons()
    
    print("[PhoneFrameworkCore] Returned to home screen")
end

-- 创建手机窗口
function PhoneFrameworkCore.createPhoneWindow(player, phoneItem)
    -- 如果手机窗口已经存在，先关闭它
    if PhoneFrameworkCore.phoneWindow and PhoneFrameworkCore.phoneWindow:isVisible() then
        PhoneFrameworkCore.phoneWindow:setVisible(false)
        PhoneFrameworkCore.phoneWindow:removeFromUIManager()
    end
    
    -- 获取屏幕尺寸
    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()
    
    -- 计算窗口位置和大小
    local width = 1040
    local height = 744
    local x = (screenWidth - width) / 2
    local y = (screenHeight - height) / 2
    
    -- 创建手机窗口
    PhoneFrameworkCore.phoneWindow = ISPanel:new(x, y, width, height)
    PhoneFrameworkCore.phoneWindow:initialise()
    PhoneFrameworkCore.phoneWindow:addToUIManager()
    PhoneFrameworkCore.phoneWindow:setVisible(true)
    PhoneFrameworkCore.phoneWindow.view = PhoneFrameworkCore -- 设置回调引用
    
    -- 计算内屏区域
    PhoneFrameworkCore.phoneWindow.innerX = 14
    PhoneFrameworkCore.phoneWindow.innerY = 20
    PhoneFrameworkCore.phoneWindow.innerWidth = 1004
    PhoneFrameworkCore.phoneWindow.innerHeight = 704
    
    -- 设置手机物品引用
    PhoneFrameworkCore.phoneWindow.phoneItem = phoneItem
    
    -- 创建关闭按钮
    local closeButton = ISButton:new(
        PhoneFrameworkCore.phoneWindow.innerX + PhoneFrameworkCore.phoneWindow.innerWidth - 40,
        PhoneFrameworkCore.phoneWindow.innerY, 40, 40, "X",
        PhoneFrameworkCore.phoneWindow, PhoneFrameworkCore.onClosePhone
    )
    closeButton:initialise()
    closeButton.backgroundColor = {r=0.8, g=0.1, b=0.1, a=0.8}
    closeButton.borderColor = {r=0.5, g=0, b=0, a=1}
    PhoneFrameworkCore.phoneWindow:addChild(closeButton)
    
    -- 设置渲染函数
    PhoneFrameworkCore.phoneWindow.prerender = PhoneFrameworkCore.renderPhoneWindow
    
    -- 创建应用图标网格
    PhoneFrameworkCore.updateAppGrid()
    
    -- 加载背景图片
    PhoneFrameworkCore.phoneWindow.backgroundTexture = getTexture("media/ui/phone_open.png")
    
    return PhoneFrameworkCore.phoneWindow
end

-- 更新应用图标网格
function PhoneFrameworkCore.updateAppGrid()
    if not PhoneFrameworkCore.phoneWindow then
        return
    end
    
    -- 清除现有图标
    PhoneFrameworkCore.clearAppIcons()
    
    -- 网格配置
    local gridColumns = 4
    local gridRows = 3
    local iconSize = 150
    local iconSpacing = 30
    
    -- 计算网格起始位置
    local gridWidth = (iconSize + iconSpacing) * gridColumns - iconSpacing
    local gridHeight = (iconSize + iconSpacing) * gridRows - iconSpacing
    
    local gridStartX = PhoneFrameworkCore.phoneWindow.innerX + (PhoneFrameworkCore.phoneWindow.innerWidth - gridWidth) / 2
    local gridStartY = PhoneFrameworkCore.phoneWindow.innerY + 100
    
    -- 创建应用图标按钮
    for i, app in ipairs(PhoneFrameworkCore.apps) do
        local row = math.floor((i - 1) / gridColumns)
        local col = (i - 1) % gridColumns
        
        local x = gridStartX + col * (iconSize + iconSpacing)
        local y = gridStartY + row * (iconSize + iconSpacing)
        
        -- 创建应用图标按钮
        local appButton = ISButton:new(x, y, iconSize, iconSize, app.displayName, 
            PhoneFrameworkCore.phoneWindow, PhoneFrameworkCore.onAppIconClick)
        appButton:initialise()
        appButton.app = app
        appButton.target = PhoneFrameworkCore.phoneWindow
        appButton.backgroundColor = {r=0.2, g=0.4, b=0.8, a=0.8}
        appButton.borderColor = {r=0.1, g=0.2, b=0.4, a=1}
        appButton.tooltip = app.displayName
        
        PhoneFrameworkCore.phoneWindow:addChild(appButton)
        table.insert(PhoneFrameworkCore.appIcons, appButton)
    end
    
    -- 如果没有应用，显示提示信息
    if #PhoneFrameworkCore.apps == 0 then
        local noAppsLabel = ISLabel:new(gridStartX, gridStartY + 100, 400, 
            getText("UI_Phone_NoApps"), 0.6, 0.6, 0.6, 1, UIFont.Medium, true)
        noAppsLabel:initialise()
        PhoneFrameworkCore.phoneWindow:addChild(noAppsLabel)
        table.insert(PhoneFrameworkCore.appIcons, noAppsLabel)
    end
end

-- 清除应用图标
function PhoneFrameworkCore.clearAppIcons()
    for _, icon in ipairs(PhoneFrameworkCore.appIcons) do
        PhoneFrameworkCore.phoneWindow:removeChild(icon)
    end
    PhoneFrameworkCore.appIcons = {}
end

-- 隐藏应用图标
function PhoneFrameworkCore.hideAppIcons()
    for _, icon in ipairs(PhoneFrameworkCore.appIcons) do
        icon:setVisible(false)
    end
end

-- 显示应用图标
function PhoneFrameworkCore.showAppIcons()
    for _, icon in ipairs(PhoneFrameworkCore.appIcons) do
        icon:setVisible(true)
    end
end

-- 应用图标点击事件
function PhoneFrameworkCore.onAppIconClick(self, button)
    if button and button.app then
        PhoneFrameworkCore.openApp(button.app)
    else
        print("[PhoneFrameworkCore] Error: Invalid button or app reference")
    end
end

-- 手机窗口关闭事件
function PhoneFrameworkCore.onClosePhone()
    -- 如果当前有应用在运行，销毁它
    if PhoneFrameworkCore.currentView and PhoneFrameworkCore.currentView.app then
        local app = PhoneFrameworkCore.currentView.app
        if app.onDestroy then
            app:onDestroy()
        end
    end
    
    -- 关闭手机窗口
    PhoneFrameworkCore.phoneWindow:setVisible(false)
    PhoneFrameworkCore.phoneWindow:removeFromUIManager()
    PhoneFrameworkCore.phoneWindow = nil
    PhoneFrameworkCore.currentView = nil
end

-- 手机窗口渲染函数
function PhoneFrameworkCore.renderPhoneWindow()
    -- 绘制手机背景图片
    if PhoneFrameworkCore.phoneWindow.backgroundTexture then
        PhoneFrameworkCore.phoneWindow:drawTexture(
            PhoneFrameworkCore.phoneWindow.backgroundTexture, 0, 0, 1, 1, 1, 1
        )
    end
    
    -- 绘制内屏区域
    PhoneFrameworkCore.phoneWindow:drawRect(
        PhoneFrameworkCore.phoneWindow.innerX, PhoneFrameworkCore.phoneWindow.innerY,
        PhoneFrameworkCore.phoneWindow.innerWidth, PhoneFrameworkCore.phoneWindow.innerHeight,
        0.95, 0.95, 0.95, 0.9
    )
    
    -- 绘制内屏边框
    PhoneFrameworkCore.phoneWindow:drawRectBorder(
        PhoneFrameworkCore.phoneWindow.innerX, PhoneFrameworkCore.phoneWindow.innerY,
        PhoneFrameworkCore.phoneWindow.innerWidth, PhoneFrameworkCore.phoneWindow.innerHeight,
        0.2, 0.2, 0.2, 1
    )
end

-- 初始化函数
function PhoneFrameworkCore.init()
    -- 注册右键菜单事件
    Events.OnFillInventoryObjectContextMenu.Add(PhoneFrameworkCore.onPhoneContextMenu)
    
    print("[PhoneFrameworkCore] Phone framework core initialized")
    
    -- 标记框架为已初始化状态
    PhoneFrameworkCore.initialized = true
end

-- 右键菜单处理函数
function PhoneFrameworkCore.onPhoneContextMenu(player, context, items)
    if not items or not items[1] or not items[1].items then return end
    
    local phoneItem = nil
    
    -- 使用ipairs遍历物品列表
    for _, item in ipairs(items[1].items) do
        if instanceof(item, "InventoryItem") and item:getFullType() == "Base.Phone" then
            phoneItem = item
            print("[PhoneFrameworkCore] Found phone item: " .. tostring(item:getFullType()))
            break
        end
    end
    
    if phoneItem then
        -- 添加打开手机选项
        local openOption = context:addOption(getText("UI_Phone_OpenPhone"), phoneItem, 
            PhoneFrameworkCore.openPhone)
        print("[PhoneFrameworkCore] Right-click menu option added")
    else
        print("[PhoneFrameworkCore] No phone item found")
    end
end

-- 打开手机函数
function PhoneFrameworkCore.openPhone(phoneItem)
    local player = getSpecificPlayer(0)
    PhoneFrameworkCore.createPhoneWindow(player, phoneItem)
end

-- 游戏启动时注册事件
Events.OnGameStart.Add(PhoneFrameworkCore.init)