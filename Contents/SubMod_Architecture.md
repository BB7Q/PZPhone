# 子Mod架构说明

## 概述

手机框架系统采用了子mod架构，将测试应用作为独立的子mod，这样可以利用PZ的mod加载顺序确保框架先于应用加载。

## 目录结构

```
Contents/mods/
├── PZPhone/                      # 核心框架mod
│   ├── common/
│   │   ├── mod.info
│   │   ├── media/lua/
│   │   │   ├── shared/
│   │   │   │   ├── Main.lua      # 主加载文件
│   │   │   │   └── Translate/   # 翻译文件
│   │   │   └── client/
│   │   │       ├── PhoneLoader.lua      # 框架加载器
│   │   │       ├── PhoneFrameworkCore.lua # 框架核心
│   │   │       ├── WebView.lua          # UI容器
│   │   │       └── EBook.lua           # 内置应用
│   └── 42/
├── PZPhone_ExampleApp/            # 示例应用子mod
│   ├── mod.info
│   └── common/media/lua/client/
│       └── ExampleAppNew.lua
└── PZPhone_NotesApp/              # 笔记应用子mod
    ├── mod.info
    └── common/media/lua/client/
        └── NotesApp.lua
```

## Mod依赖关系

1. **PZPhone** (核心框架)
   - 不依赖任何手机相关的mod
   - 提供基础框架功能

2. **PZPhone_ExampleApp** (示例应用)
   - 依赖: `PZPhone`
   - 在框架加载后自动注册自己

3. **PZPhone_NotesApp** (笔记应用)
   - 依赖: `PZPhone`
   - 在框架加载后自动注册自己

## 加载顺序

PZ的mod系统会按以下顺序加载：

1. 首先加载PZPhone核心框架
2. 然后加载依赖PZPhone的子mod（如PZPhone_ExampleApp和PZPhone_NotesApp）

这确保了当应用代码执行时，PhoneFrameworkCore已经完全初始化。

## Mod信息文件

每个子mod的mod.info文件都包含：

```
name=PZPhone_ExampleApp
id=PZPhone_ExampleApp
description=手机框架示例应用
depends=PZPhone
```

`depends=PZPhone`确保了框架先于应用加载。

## 应用注册

每个应用在OnGameStart事件中注册自己：

```lua
-- 注册应用函数
local appInstance = nil

function ExampleAppNew.init()
    -- 创建应用实例并注册到框架
    appInstance = ExampleAppNew.App:new()
    PhoneFrameworkCore.registerApp(appInstance)
    print("[ExampleAppNew] Example app module loaded")
end

-- 在游戏启动时注册应用
Events.OnGameStart.Add(ExampleAppNew.init)
```

由于PZ的mod加载顺序，PhoneFrameworkCore在应用代码执行前已经初始化，所以不需要延迟或复杂的事件处理。

## 优势

1. **清晰分离**：框架和应用完全分离，各自是独立的mod
2. **加载顺序保证**：利用PZ的依赖系统确保正确的加载顺序
3. **简化代码**：应用不需要复杂的延迟加载逻辑
4. **模块化**：每个应用是独立的mod，可以单独开发和发布
5. **易于扩展**：添加新应用只需创建新的子mod

## 如何添加新应用

1. 创建新的子mod目录，如`PZPhone_MyApp`
2. 在子mod中创建mod.info文件，指定`depends=PZPhone`
3. 创建应用文件，实现应用类和功能
4. 在OnGameStart事件中注册应用到框架

## 翻译文件

核心框架的翻译在PZPhone/mods/common/media/lua/shared/Translate/目录
应用的翻译可以在各自的子mod中提供，或者继续使用核心框架的翻译文件。

这种子mod架构提供了一个清晰的模块化系统，使得框架和应用的开发和维护更加简单。