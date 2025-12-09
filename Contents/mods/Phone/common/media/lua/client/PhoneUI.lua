-- -- 手机界面主文件

-- PhoneUI = {};
-- PhoneUI.instance = nil;

-- -- 手机界面类定义
-- PhoneUI.PhoneWindow = ISPanel:derive("PhoneUI_PhoneWindow");

-- -- 构造函数
-- function PhoneUI.PhoneWindow:initialise()
--     ISPanel.initialise(self);
-- end

-- -- 创建界面元素
-- function PhoneUI.PhoneWindow:createChildren()
--     -- 计算内屏区域（内屏1000×704，相对于1040×744的边框）
--     self.innerX = 20;  -- 左边距（加大一倍）
--     self.innerY = 20;  -- 上边距（加大一倍）
--     self.innerWidth = 1000;
--     self.innerHeight = 704;
    
--     -- 创建关闭按钮（加大尺寸）
--     self.closeButton = ISButton:new(self.width - 60, 20, 40, 40, "X", self, PhoneUI.PhoneWindow.onClose);
--     self.closeButton:initialise();
--     self.closeButton.backgroundColor = {r=0.8, g=0.1, b=0.1, a=0.8};
--     self.closeButton.borderColor = {r=0.5, g=0, b=0, a=1};
--     self:addChild(self.closeButton);
    
--     -- 创建标题（加大字体）
--     self.titleLabel = ISLabel:new(self.innerX + self.innerWidth/2 - 100, self.innerY + 30, 50, getText("UI_Phone_Title"), 1, 1, 1, 1, UIFont.Large, true);
--     self.titleLabel:initialise();
--     self:addChild(self.titleLabel);
    
--     -- 创建功能按钮（在内屏区域内，加大尺寸）
--     self.contactsButton = ISButton:new(self.innerX + 100, self.innerY + 200, 240, 60, getText("UI_Phone_Contacts"), self, PhoneUI.PhoneWindow.onContacts);
--     self.contactsButton:initialise();
--     self.contactsButton.backgroundColor = {r=0.2, g=0.4, b=0.8, a=0.8};
--     self.contactsButton.borderColor = {r=0.1, g=0.2, b=0.4, a=1};
--     self:addChild(self.contactsButton);
    
--     self.messagesButton = ISButton:new(self.innerX + 100, self.innerY + 300, 240, 60, getText("UI_Phone_Messages"), self, PhoneUI.PhoneWindow.onMessages);
--     self.messagesButton:initialise();
--     self.messagesButton.backgroundColor = {r=0.2, g=0.4, b=0.8, a=0.8};
--     self.messagesButton.borderColor = {r=0.1, g=0.2, b=0.4, a=1};
--     self:addChild(self.messagesButton);
    
--     self.settingsButton = ISButton:new(self.innerX + 100, self.innerY + 400, 240, 60, getText("UI_Phone_Settings"), self, PhoneUI.PhoneWindow.onSettings);
--     self.settingsButton:initialise();
--     self.settingsButton.backgroundColor = {r=0.2, g=0.4, b=0.8, a=0.8};
--     self.settingsButton.borderColor = {r=0.1, g=0.2, b=0.4, a=1};
--     self:addChild(self.settingsButton);
    
--     -- 创建状态显示（加大字体）
--     self.statusLabel = ISLabel:new(self.innerX + 100, self.innerY + 540, 400, getText("UI_Phone_Battery"), 0.8, 0.8, 0.8, 1, UIFont.Medium, true);
--     self.statusLabel:initialise();
--     self:addChild(self.statusLabel);
-- end

-- -- 渲染界面
-- function PhoneUI.PhoneWindow:prerender()
--     -- 绘制手机背景图片（使用你提供的素材）
--     if self.backgroundTexture then
--         self:drawTexture(self.backgroundTexture, 0, 0, 1, 1, 1, 1);
--     end
    
--     -- 只绘制内屏区域（白色背景）
--     self:drawRect(self.innerX, self.innerY, self.innerWidth, self.innerHeight, 0.95, 0.95, 0.95, 0.9);
    
--     -- 绘制内屏边框
--     self:drawRectBorder(self.innerX, self.innerY, self.innerWidth, self.innerHeight, 1, 0.2, 0.2, 0.2);
-- end

-- -- 关闭按钮点击事件
-- function PhoneUI.PhoneWindow:onClose()
--     self:setVisible(false);
--     self:removeFromUIManager();
--     PhoneUI.instance = nil;
-- end

-- -- 联系人按钮点击事件
-- function PhoneUI.PhoneWindow:onContacts()
--     getSpecificPlayer(0):Say("打开联系人");
-- end

-- -- 短信按钮点击事件
-- function PhoneUI.PhoneWindow:onMessages()
--     getSpecificPlayer(0):Say("打开短信");
-- end

-- -- 设置按钮点击事件
-- function PhoneUI.PhoneWindow:onSettings()
--     getSpecificPlayer(0):Say("打开设置");
-- end

-- -- 创建手机界面实例
-- function PhoneUI.createPhoneWindow(player, phoneItem)
--     if PhoneUI.instance and PhoneUI.instance:isVisible() then
--         PhoneUI.instance:setVisible(false);
--         PhoneUI.instance:removeFromUIManager();
--         PhoneUI.instance = nil;
--     end
    
--     -- 获取屏幕尺寸
--     local screenWidth = getCore():getScreenWidth();
--     local screenHeight = getCore():getScreenHeight();
    
--     -- 计算窗口位置和大小（手机尺寸加大一倍：1040×744，内屏1000×704）
--     local width = 1040;
--     local height = 744;
--     local x = (screenWidth - width) / 2;
--     local y = (screenHeight - height) / 2;
    
--     -- 创建窗口
--     PhoneUI.instance = PhoneUI.PhoneWindow:new(x, y, width, height);
--     PhoneUI.instance:initialise();
--     PhoneUI.instance:addToUIManager();
--     PhoneUI.instance:setVisible(true);
    
--     -- 设置手机物品引用
--     PhoneUI.instance.phoneItem = phoneItem;
    
--     -- 加载背景图片
--     PhoneUI.instance.backgroundTexture = getTexture("media/ui/phone_open.png");
    
--     return PhoneUI.instance;
-- end

-- -- 右键菜单处理函数
-- PhoneUI.onPhoneContextMenu = function(player, context, items)
--     print("[PhoneUI] 检查右键菜单物品...");
    
--     -- 参考标准做法检查物品
--     if not items or not items[1] or not items[1].items then return end
    
--     local phoneItem = nil;
    
--     -- 使用ipairs遍历物品列表
--     for _, item in ipairs(items[1].items) do
--         if instanceof(item, "InventoryItem") and item:getFullType() == "Base.Phone" then
--             phoneItem = item;
--             print("[PhoneUI] 找到手机物品: " .. tostring(item:getFullType()));
--             break;
--         end
--     end
    
--     if phoneItem then
--         -- 添加打开手机选项
--         local openOption = context:addOption(getText("UI_Phone_OpenPhone"), phoneItem, PhoneUI.openPhone);
--         print("[PhoneUI] 右键菜单选项已添加");
--     else
--         print("[PhoneUI] 未找到手机物品");
--     end
-- end

-- -- 打开手机函数
-- PhoneUI.openPhone = function(phoneItem)
--     local player = getSpecificPlayer(0);
--     PhoneUI.createPhoneWindow(player, phoneItem);
-- end

-- -- 初始化函数
-- PhoneUI.init = function()
--     -- 注册物品右键菜单事件
--     Events.OnFillInventoryObjectContextMenu.Add(PhoneUI.onPhoneContextMenu);
    
--     print("[PhoneUI] 手机界面模块已加载");
-- end

-- -- 游戏启动时注册事件
-- Events.OnGameStart.Add(PhoneUI.init);