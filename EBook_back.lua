-- 手机主文件

Phone = {};



-- **********************************************************************************
-- 通用阅读书籍处理函数
-- **********************************************************************************
EBook.processReadBook = function(player, bookType)
	print("Simulating reading book: " .. bookType);
	
	-- 使用instanceItem获取物品对象数据
	local tempBook = instanceItem(bookType);
	if not tempBook then
		print("Failed to create book instance: " .. bookType);
		return;
	end
	
	-- 获取书籍属性
	local fullType = tempBook:getFullType();
	local totalPages = tempBook:getNumberOfPages();
	
	-- 直接设置玩家记录的已读页数，不需要实体书籍
	player:setAlreadyReadPages(fullType, totalPages);
	print("Book pages: " .. totalPages .. ", marked as read");
	
	-- 1. 处理配方书籍
	if tempBook:getTeachedRecipes() and not tempBook:getTeachedRecipes():isEmpty() then
		print("Book contains recipes, learning them");
		
		-- 遍历所有配方并学习它们
		local recipes = tempBook:getTeachedRecipes();
		for i = 0, recipes:size()-1 do
			local recipe = recipes:get(i);
			
			-- 尝试学习配方或特质
			if player:getTraits():contains(recipe) then
				print("Already have trait: " .. recipe);
			else
				-- 尝试添加特质
				local traitAdded = false;
				if TraitFactory and TraitFactory.getTrait(recipe) then
					player:getTraits():add(recipe);
					print("Added trait: " .. recipe);
					traitAdded = true;
				end
				
				-- 如果不是特质，则作为配方学习
				if not traitAdded then
					player:learnRecipe(recipe);
					print("Learned recipe: " .. recipe);
				end
			end
		end
		
		-- 配方书籍立即添加到已读列表（这是参考代码中的处理方式）
		player:getAlreadyReadBook():add(fullType);
		
		-- 确保所有配方都被标记为已知
		if not player:getKnownRecipes():containsAll(recipes) then
			for i = 0, recipes:size()-1 do
				local recipe = recipes:get(i);
				if not player:getKnownRecipes():contains(recipe) then
					player:getKnownRecipes():add(recipe);
					print("Added to known recipes: " .. recipe);
				end
			end
		end
	
-- 2. 处理技能书和普通文艺书籍
	else
		local skillTrained = tempBook:getSkillTrained();
		local modData = tempBook:hasModData() and tempBook:getModData() or nil;
		local isLiterature = false;
		
		-- 检查是否是文艺书籍
		if modData and modData.literatureTitle then
			isLiterature = true;
		elseif not SkillBook[skillTrained] then
			-- 如果不是技能书，默认视为文艺书
			isLiterature = true;
		end
		
		-- 处理文艺书籍
		if isLiterature then
			print("Processing literature book");
			
			-- 检查是否已读过此文艺书
			local isLiteratureRead = false;
			if modData and modData.literatureTitle then
				isLiteratureRead = player:isLiteratureRead(modData.literatureTitle);
			end
			
			-- 如果没有读过，则应用阅读效果
			if not isLiteratureRead then
				player:ReadLiterature(tempBook);
				print("Applied literature effects to player");
				
				-- 在客户端发送服务器命令
				if isClient() then
					local args = { itemId = tempBook:getID() };
					sendServerCommand(player, 'literature', 'readLiterature', args);
				end
			end
		end
		
	-- 3. 处理技能书
		if skillTrained and SkillBook and SkillBook[skillTrained] then
			local perk = SkillBook[skillTrained].perk;
			local lvlSkillTrained = tempBook:getLvlSkillTrained();
			local maxLevelTrained = tempBook:getMaxLevelTrained();
			
			-- 计算并设置经验倍数
			local multiplier = 1;  -- Default multiplier
			if lvlSkillTrained == 1 then
				multiplier = SkillBook[skillTrained].maxMultiplier1;
			elseif lvlSkillTrained == 3 then
				multiplier = SkillBook[skillTrained].maxMultiplier2;
			elseif lvlSkillTrained == 5 then
				multiplier = SkillBook[skillTrained].maxMultiplier3;
			elseif lvlSkillTrained == 7 then
				multiplier = SkillBook[skillTrained].maxMultiplier4;
			elseif lvlSkillTrained == 9 then
				multiplier = SkillBook[skillTrained].maxMultiplier5;
			end
			
			addXpMultiplier(player, perk, multiplier, lvlSkillTrained, maxLevelTrained);
			print("Added " .. skillTrained .. " skill XP multiplier: " .. multiplier);
		end
	end
	
	-- 4. 处理modData中的特殊内容
	if tempBook:hasModData() then
		local modData = tempBook:getModData();
		
		-- 处理teachedRecipe
		if modData.teachedRecipe ~= nil then
			player:learnRecipe(modData.teachedRecipe);
			print("Learned recipe from book modData: " .. modData.teachedRecipe);
		end
		
		-- 处理literatureTitle
		if modData.literatureTitle then
			player:addReadLiterature(modData.literatureTitle);
			print("Added to read literature: " .. modData.literatureTitle);
		end
		
		-- 打印媒体处理（但排除在已读列表之外）
		if modData.printMedia then
			player:addReadPrintMedia(modData.printMedia);
			print("Processed print media: " .. modData.printMedia);
		end
	end
	
	-- 5. 只有非打印媒体才添加到已读列表
	if not (tempBook:hasModData() and tempBook:getModData().printMedia) then
		player:getAlreadyReadBook():add(fullType);
		print("Book marked as read completely (without physical book)");
	end
	
	-- 同步玩家字段
	if isClient() then
		sendSyncPlayerFields(player, 0x00000007);
	end
end

-- **********************************************************************************
-- 测试技能书
-- **********************************************************************************
EBook.testSkillBook = function(player)
	EBook.processReadBook(player, "Base.BookCooking1");
end

-- **********************************************************************************
-- 测试配方书籍
-- **********************************************************************************
EBook.testRecipeBook = function(player)
	EBook.processReadBook(player, "Base.HerbalistMag");
end

-- **********************************************************************************
-- 测试文艺书籍
-- **********************************************************************************
EBook.testLiteratureBook = function(player)
	EBook.processReadBook(player, "Base.Book");
end

-- **********************************************************************************
-- 测试阅读书籍功能（保持原有功能）
-- **********************************************************************************
EBook.testReadBook = function(player)
	EBook.processReadBook(player, "Base.BookCooking1");
end

-- **************************************************************************************
-- 填充世界对象上下文菜单
-- **************************************************************************************
EBook.doWorldContextMenu = function(playerNum, context, worldobjects)
	local player = getSpecificPlayer(playerNum)
	-- 检查玩家是否存活
	if player:isAlive() then
		-- 创建主菜单
		local testMenu = context:addOption("EBook Test", nil, nil);
		local subMenu = context:getNew(context);
		context:addSubMenu(testMenu, subMenu);
		
		-- 添加技能书测试选项
		local skillBookOption = subMenu:addOption("Skill Book Test", nil, function()
			EBook.testSkillBook(player);
		end);
		
		-- 添加配方书籍测试选项
		local recipeBookOption = subMenu:addOption("Recipe Book Test", nil, function()
			EBook.testRecipeBook(player);
		end);
		
		-- 添加文艺书籍测试选项
		local literatureBookOption = subMenu:addOption("Literature Book Test", nil, function()
			EBook.testLiteratureBook(player);
		end);
	end
end


-- **************************************************************************************
-- 初始化，注册事件
-- **************************************************************************************
EBook.init = function()
	Events.OnFillWorldObjectContextMenu.Add(EBook.doWorldContextMenu);
end

-- **************************************************************************************
-- 注册事件
-- **************************************************************************************
Events.OnGameStart.Add(EBook.init)
