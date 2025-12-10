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
    obj.icon = icon or nil
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
    
    -- 创建PhoneWebView容器（现代化设计）
    local webView = PhoneWebView:new(
        PhoneFrameworkCore.phoneWindow.innerX,
        PhoneFrameworkCore.phoneWindow.innerY,
        PhoneFrameworkCore.phoneWindow.innerWidth,
        PhoneFrameworkCore.phoneWindow.innerHeight,
        PhoneFrameworkCore.phoneWindow
    )
    
    -- 关联应用和WebView
    app.webView = webView
    webView.app = app
    
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
    
    -- 网格配置：6列5行
    local gridColumns = 6
    local gridRows = 5
    
    -- 计算等分单元格大小（考虑内屏边距）
    local horizontalMargin = 40  -- 水平边距
    local verticalMargin = 40    -- 垂直边距
    local availableWidth = PhoneFrameworkCore.phoneWindow.innerWidth - horizontalMargin * 2
    local availableHeight = PhoneFrameworkCore.phoneWindow.innerHeight - verticalMargin * 2
    
    local cellWidth = math.floor(availableWidth / gridColumns)  -- 单元格宽度
    local cellHeight = math.floor(availableHeight / gridRows)   -- 单元格高度
    
    -- 图标大小（固定80x80像素）
    local iconSize = 80
    
    -- 计算网格起始位置（居中）
    local gridWidth = cellWidth * gridColumns
    local gridHeight = cellHeight * gridRows
    
    local gridStartX = PhoneFrameworkCore.phoneWindow.innerX + (PhoneFrameworkCore.phoneWindow.innerWidth - gridWidth) / 2
    local gridStartY = PhoneFrameworkCore.phoneWindow.innerY + verticalMargin
    
    -- 调试信息
    print(string.format("[PhoneFrameworkCore] Grid layout: %dx%d cells, cell=%dx%d, icon=%d, grid=%dx%d, inner=%dx%d", 
        gridColumns, gridRows, cellWidth, cellHeight, iconSize, gridWidth, gridHeight, 
        PhoneFrameworkCore.phoneWindow.innerWidth, PhoneFrameworkCore.phoneWindow.innerHeight))
    
    -- 创建应用图标按钮
    for i, app in ipairs(PhoneFrameworkCore.apps) do
        local row = math.floor((i - 1) / gridColumns)
        local col = (i - 1) % gridColumns
        
        -- 计算单元格位置
        local cellX = gridStartX + col * cellWidth
        local cellY = gridStartY + row * cellHeight
        
        -- 计算图标在单元格内的位置（居中）
        local iconX = cellX + (cellWidth - iconSize) / 2
        local iconY = cellY + (cellHeight - iconSize) / 3  -- 图标在单元格上1/3位置
        
        -- 创建应用图标按钮
        local appButton = ISButton:new(iconX, iconY, iconSize, iconSize, "", 
            PhoneFrameworkCore.phoneWindow, PhoneFrameworkCore.onAppIconClick)
        appButton:initialise()
        appButton.app = app
        appButton.target = PhoneFrameworkCore.phoneWindow
        appButton.backgroundColor = {r=0, g=0, b=0, a=0}  -- 透明背景
        appButton.borderColor = {r=0, g=0, b=0, a=0}      -- 透明边框
        appButton.tooltip = app.displayName
        
        -- 设置应用图标纹理
        local iconTexture = nil
        if app.icon then
            iconTexture = app.icon
        else
            -- 使用默认应用图标
            iconTexture = getTexture("media/ui/phone_app_icon.png")
        end
        appButton.texture = iconTexture
        
        -- 设置按钮的渲染函数来显示图标
        function appButton:prerender()
            if self.texture then
                self:drawTexture(self.texture, 0, 0, 1, 1, 1, 1)
            end
        end
        
        PhoneFrameworkCore.phoneWindow:addChild(appButton)
        table.insert(PhoneFrameworkCore.appIcons, appButton)
        
        -- 存储应用标题信息，在窗口渲染时绘制（而不是按钮内）
        PhoneFrameworkCore.phoneWindow.appTitles = PhoneFrameworkCore.phoneWindow.appTitles or {}
        table.insert(PhoneFrameworkCore.phoneWindow.appTitles, {
            text = app.displayName,
            x = cellX,
            y = cellY + cellHeight - 20,
            width = cellWidth
        })
    end
    
    -- 如果没有应用，显示提示信息
    if #PhoneFrameworkCore.apps == 0 then
        PhoneFrameworkCore.phoneWindow.noAppsText = getText("UI_Phone_NoApps")
        PhoneFrameworkCore.phoneWindow.noAppsX = gridStartX
        PhoneFrameworkCore.phoneWindow.noAppsY = gridStartY + gridHeight + 20
        
        -- 修改手机窗口的渲染函数来显示提示信息
        local originalRender = PhoneFrameworkCore.phoneWindow.prerender
        function PhoneFrameworkCore.phoneWindow:prerender()
            originalRender(self)
            
            -- 绘制无应用提示
            if self.noAppsText then
                local textWidth = getTextManager():MeasureStringX(UIFont.Medium, self.noAppsText)
                local textX = self.noAppsX + (400 - textWidth) / 2
                self:drawText(self.noAppsText, textX, self.noAppsY, 0.6, 0.6, 0.6, 1, UIFont.Medium)
            end
        end
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
    -- 绘制手机背景图片（包含壁纸）
    if PhoneFrameworkCore.phoneWindow.backgroundTexture then
        PhoneFrameworkCore.phoneWindow:drawTexture(
            PhoneFrameworkCore.phoneWindow.backgroundTexture, 0, 0, 1, 1, 1, 1
        )
    end
    
    -- 绘制内屏边框（保留边框，移除白色背景）
    PhoneFrameworkCore.phoneWindow:drawRectBorder(
        PhoneFrameworkCore.phoneWindow.innerX, PhoneFrameworkCore.phoneWindow.innerY,
        PhoneFrameworkCore.phoneWindow.innerWidth, PhoneFrameworkCore.phoneWindow.innerHeight,
        0.2, 0.2, 0.2, 1
    )
    
    -- 绘制应用标题（白色文字，在壁纸上清晰可见）
    if PhoneFrameworkCore.phoneWindow.appTitles then
        for _, titleInfo in ipairs(PhoneFrameworkCore.phoneWindow.appTitles) do
            local textWidth = getTextManager():MeasureStringX(UIFont.Small, titleInfo.text)
            local textX = titleInfo.x + (titleInfo.width - textWidth) / 2
            PhoneFrameworkCore.phoneWindow:drawText(titleInfo.text, textX, titleInfo.y, 1, 1, 1, 1, UIFont.Small)
        end
    end
    
    -- 绘制无应用提示（如果有，也改为白色）
    if PhoneFrameworkCore.phoneWindow.noAppsText then
        local textWidth = getTextManager():MeasureStringX(UIFont.Medium, PhoneFrameworkCore.phoneWindow.noAppsText)
        local textX = PhoneFrameworkCore.phoneWindow.noAppsX + (400 - textWidth) / 2
        PhoneFrameworkCore.phoneWindow:drawText(PhoneFrameworkCore.phoneWindow.noAppsText, textX, PhoneFrameworkCore.phoneWindow.noAppsY, 1, 1, 1, 1, UIFont.Medium)
    end
end

-- 创建测试应用
function PhoneFrameworkCore.createTestApps()
    -- 清除现有应用
    PhoneFrameworkCore.apps = {}
    
    -- 创建30个测试应用（6列×5行=30个位置）
    for i = 1, 30 do
        local app = PhoneFrameworkCore.App:new(
            "TestApp" .. i,
            "media/ui/app_icon.png",  -- 使用默认图标
            "App " .. i,
            "测试应用 " .. i
        )
        PhoneFrameworkCore.registerApp(app)
    end
    
    print("[PhoneFrameworkCore] Created 30 test apps for grid layout testing")
end

-- 初始化函数
function PhoneFrameworkCore.init()
    -- 注册右键菜单事件
    Events.OnFillInventoryObjectContextMenu.Add(PhoneFrameworkCore.onPhoneContextMenu)
    
    -- 创建测试应用（用于布局验证）
    -- PhoneFrameworkCore.createTestApps()
    
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