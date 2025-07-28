-- 加载OrionLib库（增加重试和备用链接）
local OrionLib
local retries = 3  -- 最多重试3次
local success, err

while retries > 0 do
    success, err = pcall(function()
        OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/FUEx0f3G", true))()
    end)
    if success and OrionLib then break end
    retries = retries - 1
    task.wait(1)  -- 重试间隔1秒
end

if not success or not OrionLib then
    warn("Orion库加载失败: ".. (err or "未知错误"))
    -- 尝试使用备用链接
    local success2, err2 = pcall(function()
        OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/OrionLibTeam/Orion/main/source", true))()
    end)
    if not success2 or not OrionLib then
        warn("备用链接也加载失败: ".. (err2 or "未知错误"))
        return
    end
end

-- 服务与变量初始化
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local spinVelocity = nil  -- 旋转功能变量
local espConnection = nil  -- 透视功能连接

-- 工具函数：创建圆角
local function makeRound(obj, radius)
    if obj and obj:IsA("GuiObject") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = radius or UDim.new(0.5, 0)
        corner.Parent = obj
    end
end

-- 创建主窗口
local Window = OrionLib:MakeWindow({
    Name = "菁脚本",
    SaveConfig = true,
    IntroText = "菁脚本 - 功能加载完成",
    Theme = "FlatBlue",
    Icon = "rbxassetid://118894209472715"
})

-- 欢迎通知
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "菁脚本",
        Text = "欢迎使用，功能已就绪",
        Duration = 4,
        Icon = "rbxassetid://118894209472715"
    })
end)

-- 作者信息标签页
local AuthorTab = Window:MakeTab({Name = "作者信息", Icon = "rbxassetid://4483345998"})
AuthorTab:AddParagraph("作者", "Hfh916")
AuthorTab:AddParagraph("作者QQ", "1357377308")

-- 圆形按钮生成器（优化内存管理）
local function addRoundButton(tab, config)
    local btn = tab:AddButton(config)
    if btn.Instance and btn.Instance:IsA("GuiButton") then
        btn.Instance.Size = UDim2.new(0, 120, 0, 36)
        makeRound(btn.Instance)
        
        local hover = Instance.new("UIScale")
        hover.Scale = 1
        hover.Parent = btn.Instance
        
        local enterConn = btn.Instance.MouseEnter:Connect(function() hover.Scale = 1.05 end)
        local leaveConn = btn.Instance.MouseLeave:Connect(function() hover.Scale = 1 end)
        
        -- 增加按钮销毁时的清理
        local cleanup = function()
            enterConn:Disconnect()
            leaveConn:Disconnect()
            hover:Destroy()
        end
        
        btn.Instance.AncestryChanged:Connect(function(_, parent)
            if not parent then cleanup() end
        end)
        -- 超时自动清理（防止内存泄漏）
        task.delay(300, function()
            if btn.Instance and btn.Instance.Parent then
                cleanup()
            end
        end)
    end
    return btn
end

-- 作者信息页按钮
addRoundButton(AuthorTab, {
    Name = "复制作者QQ",
    Callback = function()
        if setclipboard then
            setclipboard("1357377308")
            OrionLib:MakeNotification({Name = "成功", Content = "QQ已复制", Time = 2})
        end
    end,
    Color = Color3.fromRGB(70, 130, 255)
})

addRoundButton(AuthorTab, {
    Name = "复制QQ群",
    Callback = function()
        if setclipboard then
            setclipboard("无")
            OrionLib:MakeNotification({Name = "成功", Content = "QQ群已复制", Time = 2})
        end
    end,
    Color = Color3.fromRGB(100, 200, 100)
})

-- 玩家信息标签页
local PlayerTab = Window:MakeTab({Name = "玩家信息", Icon = "rbxassetid://4483345998"})
local executorName = "未知"
pcall(function() executorName = identifyexecutor() or "未知" end)

PlayerTab:AddParagraph("用户名", player.Name)
PlayerTab:AddParagraph("用户ID", tostring(player.UserId))
PlayerTab:AddParagraph("注入器", executorName)
PlayerTab:AddParagraph("服务器ID", tostring(game.GameId))

-- 玩家功能标签页
local FunctionTab = Window:MakeTab({Name = "玩家功能", Icon = "rbxassetid://4483345998"})

-- 文本框配置函数
local function addSettingTextbox(tab, config)
    tab:AddTextbox({
        Name = config.Name,
        Placeholder = config.Placeholder or "",
        Callback = function(Value)
            local num = tonumber(Value)
            if not num or num <= 0 then
                return OrionLib:MakeNotification({Name = "错误", Content = "请输入正数", Time = 2})
            end
            local success, err = pcall(config.Callback, num)
            if not success then
                OrionLib:MakeNotification({Name = "错误", Content = "设置失败: " .. err, Time = 2})
            end
        end
    })
end

-- 移动设置
addSettingTextbox(FunctionTab, {
    Name = "跳跃高度",
    Callback = function(num)
        if not player.Character then
            error("角色不存在")
        end
        local humanoid = player.Character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.JumpPower = num
        else
            error("未找到Humanoid")
        end
    end
})

addSettingTextbox(FunctionTab, {
    Name = "移动速度",
    Callback = function(num)
        if not player.Character then
            error("角色不存在")
        end
        local humanoid = player.Character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.WalkSpeed = num
        else
            error("未找到Humanoid")
        end
    end
})

-- 相机焦距输入调节
local function addCameraTextbox(tab, config)
    local textboxObj
    textboxObj = tab:AddTextbox({
        Name = config.Name,
        Placeholder = config.Placeholder,
        Callback = function(Value)
            local num = tonumber(Value)
            if not num or num < config.Min or num > config.Max then
                return OrionLib:MakeNotification({
                    Name = "错误", 
                    Content = "请输入" .. config.Min .. "-" .. config.Max .. "之间的数值", 
                    Time = 2
                })
            end
            config.Callback(num)
            OrionLib:MakeNotification({
                Name = "已调整", 
                Content = config.SuccessText .. num, 
                Time = 1.5
            })
            -- 清空输入框
            task.delay(0.1, function()
                if textboxObj and textboxObj.Instance then
                    local inputField = textboxObj.Instance:FindFirstChildOfClass("TextBox")
                    if inputField then
                        inputField.Text = ""
                    end
                end
            end)
        end
    })
end

-- 添加相机调节功能
addCameraTextbox(FunctionTab, {
    Name = "相机最大缩放距离",
    Placeholder = "输入数值（1-200000）",
    Min = 1,
    Max = 200000,
    SuccessText = "最大缩放距离: ",
    Callback = function(num)
        player.CameraMaxZoomDistance = num
    end
})

addCameraTextbox(FunctionTab, {
    Name = "相机视野角度【正常70】",
    Placeholder = "输入数值（10-120）",
    Min = 10,
    Max = 120,
    SuccessText = "视野角度: ",
    Callback = function(num)
        workspace.CurrentCamera.FieldOfView = num
    end
})

-- 飞行功能
addRoundButton(FunctionTab, {
    Name = "飞行功能",
    Callback = function()
        OrionLib:MakeNotification({Name = "提示", Content = "正在加载飞行功能...", Time = 3})
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/HXB20111/roblox-/refs/heads/main/%E9%BB%84%E9%A3%9E%E8%A1%8C"))()
            end)
            if success then
                OrionLib:MakeNotification({Name = "成功", Content = "飞行功能加载完成", Time = 3})
            else
                OrionLib:MakeNotification({Name = "失败", Content = "加载错误: " .. err, Time = 3})
            end
        end)
    end,
    Color = Color3.fromRGB(135, 206, 235)
})

-- 夜视模式
FunctionTab:AddToggle({
    Name = "夜视模式",
    Default = false,
    Callback = function(enabled)
        Lighting.Ambient = enabled and Color3.new(0.5, 0.5, 0.5) or Color3.new(0, 0, 0)
        Lighting.Brightness = enabled and 2 or 1
    end,
    Color = Color3.fromRGB(255, 165, 0)
})

-- 穿墙模式（优化性能）
local Clipon = false
local Stepped

FunctionTab:AddToggle({
    Name = "穿墙模式",
    Default = false,
    Callback = function(enabled)
        Clipon = enabled
        
        -- 断开已有连接
        if Stepped then
            Stepped:Disconnect()
        end
        
        if enabled then
            -- 开启穿墙：禁用角色碰撞
            Stepped = RunService.Stepped:Connect(function()
                if not Clipon then return end
                local playerChar = workspace:FindFirstChild(player.Name)
                if playerChar then
                    for _, part in pairs(playerChar:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            OrionLib:MakeNotification({Name = "成功", Content = "穿墙模式已开启", Time = 2})
        else
            -- 关闭穿墙：恢复碰撞
            local playerChar = workspace:FindFirstChild(player.Name)
            if playerChar then
                for _, part in pairs(playerChar:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            OrionLib:MakeNotification({Name = "提示", Content = "穿墙模式已关闭", Time = 2})
        end
    end,
    Color = Color3.fromRGB(100, 149, 237)
})

-- 透视功能（增加关闭逻辑）
FunctionTab:AddToggle({
    Name = "透视",
    Default = false,
    Callback = function(enabled)
        if enabled then
            -- 先断开已有连接
            if espConnection then 
                pcall(function() espConnection:Disconnect() end)
                espConnection = nil
            end
            -- 加载透视功能
            local success, result = pcall(function()
                return loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()
            end)
            if success then
                OrionLib:MakeNotification({Name = "成功", Content = "透视功能已开启", Time = 2})
                -- 存储关闭函数（假设原脚本返回关闭函数）
                if type(result) == "function" then
                    espConnection = result
                end
            else
                warn("透视加载错误: " .. result)
                OrionLib:MakeNotification({Name = "错误", Content = "透视加载失败", Time = 2})
            end
        else
            -- 关闭透视
            if espConnection and type(espConnection) == "function" then
                pcall(espConnection)
            end
            espConnection = nil
            OrionLib:MakeNotification({Name = "提示", Content = "透视功能已关闭", Time = 2})
        end
    end,
    Color = Color3.fromRGB(128, 0, 128)
})

-- 旋转速度调节（修复角色依赖问题）
addSettingTextbox(FunctionTab, {
    Name = "旋转速度",
    Placeholder = "输入旋转速度值",
    Callback = function(Value)
        local speed = tonumber(Value)
        if not speed then
            return OrionLib:MakeNotification({
                Name = "错误",
                Content = "请输入有效的数字",
                Time = 2
            })
        end
        
        if not player.Character then
            return OrionLib:MakeNotification({
                Name = "错误",
                Content = "角色未加载",
                Time = 2
            })
        end
        
        local humRoot = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humRoot or not humanoid then
            return OrionLib:MakeNotification({
                Name = "错误",
                Content = "找不到角色关键部件",
                Time = 2
            })
        end
        
        humanoid.AutoRotate = false

        if not spinVelocity then
            spinVelocity = Instance.new("AngularVelocity")
            -- 创建独立Attachment避免依赖
            local attach = humRoot:FindFirstChild("RootAttachment") or Instance.new("Attachment")
            if not attach.Parent then
                attach.Name = "RootAttachment"
                attach.Parent = humRoot
            end
            spinVelocity.Attachment0 = attach
            spinVelocity.MaxTorque = math.huge
            spinVelocity.AngularVelocity = Vector3.new(0, speed, 0)
            spinVelocity.Parent = humRoot
            spinVelocity.Name = "Spinbot"
        else
            spinVelocity.AngularVelocity = Vector3.new(0, speed, 0)
        end
        
        OrionLib:MakeNotification({
            Name = "已设置",
            Content = "旋转速度已调整为: " .. speed,
            Time = 1.5
        })
    end
})

-- 停止旋转按钮
addRoundButton(FunctionTab, {
    Name = "停止旋转",
    Callback = function()
        if not player.Character then
            return OrionLib:MakeNotification({
                Name = "错误",
                Content = "角色未加载",
                Time = 2
            })
        end
        
        local humRoot = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humRoot or not humanoid then
            return OrionLib:MakeNotification({
                Name = "错误",
                Content = "找不到角色关键部件",
                Time = 2
            })
        end

        local spinbot = humRoot:FindFirstChild("Spinbot")
        if spinbot then
            spinbot:Destroy()
            spinVelocity = nil
            humanoid.AutoRotate = true
            OrionLib:MakeNotification({
                Name = "已停止",
                Content = "旋转已停止",
                Time = 1.5
            })
        else
            OrionLib:MakeNotification({
                Name = "提示",
                Content = "未处于旋转状态",
                Time = 1.5
            })
        end
    end,
    Color = Color3.fromRGB(255, 99, 71)
})

local ScriptCenterTab = Window:MakeTab({Name = "其他脚本", Icon = "rbxassetid://4483345998"})

addRoundButton(ScriptCenterTab, {
    Name = "皮脚本",
    Callback = function()
        OrionLib:MakeNotification({Name = "提示", Content = "正在加载...", Time = 3})
        task.spawn(function()
            local success, err = pcall(function()
                getgenv().XiaoPi = "皮脚本QQ群1002100032"
                loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua", true))()
            end)
            if success then
                OrionLib:MakeNotification({Name = "成功", Content = "加载完成", Time = 3})
            else
                OrionLib:MakeNotification({Name = "失败", Content = "错误: " .. err, Time = 3})
            end
        end)
    end,
    Color = Color3.fromRGB(123, 104, 238)
})

-- AL中心
addRoundButton(ScriptCenterTab, {
    Name = "大司马脚本",
    Callback = function()
        OrionLib:MakeNotification({Name = "提示", Content = "正在加载大司马脚本...", Time = 3})
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/whenheer/gfop/refs/heads/main/Protected_4687541665942703.lua"))()
            end)
            if success then
                OrionLib:MakeNotification({Name = "成功", Content = "大司马脚本加载完成", Time = 3})
            else
                OrionLib:MakeNotification({Name = "失败", Content = "错误: " .. err, Time = 3})
            end
        end)
    end,
    Color = Color3.fromRGB(255, 99, 71)
})

addRoundButton(ScriptCenterTab, {
    Name = "落叶脚本",
    Callback = function()
        OrionLib:MakeNotification({Name = "提示", Content = "正在加载落叶脚本...", Time = 3})
        task.spawn(function()
            local success, err = pcall(function()
                getgenv().LS = "落叶脚本"
                loadstring(game:HttpGet("https://raw.githubusercontent.com/krlpl/Deciduous-center-LS/main/%E8%90%BD%E5%8F%B6%E4%B8%AD%E5%BF%83%E6%B7%B7%E6%B7%86.txt"))()
            end)
            if success then
                OrionLib:MakeNotification({Name = "成功", Content = "落叶脚本加载完成", Time = 3})
            else
                OrionLib:MakeNotification({Name = "失败", Content = "错误: " .. err, Time = 3})
            end
        end)
    end,
    Color = Color3.fromRGB(139, 69, 19)
})

addRoundButton(ScriptCenterTab, {
    Name = "霖溺脚本",
    Callback = function()
        OrionLib:MakeNotification({Name = "提示", Content = "正在加载霖溺-免费版加载器...", Time = 3})
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/ShenJiaoBen/ScriptLoader/refs/heads/main/Linni_FreeLoader.lua"))()
            end)
            if success then
                OrionLib:MakeNotification({Name = "成功", Content = "霖溺-免费版加载器加载完成", Time = 3})
            else
                OrionLib:MakeNotification({Name = "失败", Content = "错误: " .. err, Time = 3})
            end
        end)
    end,
    Color = Color3.fromRGB(70, 200, 200)
})

-- 叶脚本
addRoundButton(ScriptCenterTab, {
    Name = "叶脚本",
    Callback = function()
        OrionLib:MakeNotification({Name = "提示", Content = "正在加载叶脚本...", Time = 3})
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua"))()
            end)
            if success then
                OrionLib:MakeNotification({Name = "成功", Content = "叶脚本加载完成", Time = 3})
            else
                OrionLib:MakeNotification({Name = "失败", Content = "错误: " .. err, Time = 3})
            end
        end)
    end,
    Color = Color3.fromRGB(123, 200, 91)
})

-- 刹脚本
addRoundButton(ScriptCenterTab, {
    Name = "刹脚本",
    Callback = function()
        OrionLib:MakeNotification({Name = "提示", Content = "正在加载刹脚本...", Time = 3})
        task.spawn(function()
            local success, err = pcall(function()
                SHA_SCRIPT = "殺脚本"
                loadstring(game:HttpGet("https://raw.githubusercontent.com/FengYu-3/FengYu/refs/heads/main/shascript.lua"))()
            end)
            if success then
                OrionLib:MakeNotification({Name = "成功", Content = "刹脚本加载完成", Time = 3})
            else
                OrionLib:MakeNotification({Name = "失败", Content = "错误: " .. err, Time = 3})
            end
        end)
    end,
    Color = Color3.fromRGB(200, 70, 70)
})

-- xk脚本
addRoundButton(ScriptCenterTab, {
    Name = "RB脚本",
    Callback = function()
        OrionLib:MakeNotification({Name = "提示", Content = "正在加载RB脚本...", Time = 3})
        task.spawn(function()
            local success, err = pcall(function()
                ﻿loadstring(game:HttpGet("https://raw.githubusercontent.com/Yungengxin/roblox/refs/heads/main/Rb-Hub"))()
            end)
            if success then
                OrionLib:MakeNotification({Name = "成功", Content = "RB脚本加载完成", Time = 3})
            else
                OrionLib:MakeNotification({Name = "失败", Content = "错误: " .. err, Time = 3})
            end
        end)
    end,
    Color = Color3.fromRGB(105, 105, 105)
})

addRoundButton(ScriptCenterTab, {
    Name = "汉化脚本",
    Callback = function()
        OrionLib:MakeNotification({Name = "提示", Content = "正在加载汉化脚本...", Time = 3})
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/S-WTB/-/refs/heads/main/ISIS加载器'))()
            end)
            if success then
                OrionLib:MakeNotification({Name = "成功", Content = "汉化脚本加载完成", Time = 3})
            else
                OrionLib:MakeNotification({Name = "失败", Content = "错误: " .. err, Time = 3})
            end
        end)
    end,
    Color = Color3.fromRGB(255, 78, 91)
})

addRoundButton(ScriptCenterTab, {
    Name = "泷脚本",
    Callback = function()
        OrionLib:MakeNotification({Name = "提示", Content = "正在加载泷脚本...", Time = 3})
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://tika-team.xyz/authorization-protection/tika-script/index",true))()
            end)
            if success then
                OrionLib:MakeNotification({Name = "成功", Content = "泷脚本加载完成", Time = 3})
            else
                OrionLib:MakeNotification({Name = "失败", Content = "错误: " .. err, Time = 3})
            end
        end)
    end,
    Color = Color3.fromRGB(255, 78, 91)
})

addRoundButton(ScriptCenterTab, {
    Name = "TX脚本",
    Callback = function()
        OrionLib:MakeNotification({Name = "提示", Content = "正在加载TX脚本...", Time = 3})
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/TX-Free-YYDS/refs/heads/main/FREE-TX-TEAM"))()
            end)
            if success then
                OrionLib:MakeNotification({Name = "成功", Content = "TX脚本加载完成", Time = 3})
            else
                OrionLib:MakeNotification({Name = "失败", Content = "错误: " .. err, Time = 3})
            end
        end)
    end,
    Color = Color3.fromRGB(255, 91, 78)
})

-- 初始化界面
OrionLib:Init()

-- 样式优化
task.delay(0.3, function()
    local mainFrame = Window.Instance:FindFirstChild("MainFrame", true)
    if mainFrame then
        makeRound(mainFrame, UDim.new(0.08, 0))
    end
end)

-- 清理函数
local function cleanUp()
    if Window and Window.Instance then
        Window.Instance:Destroy()
    end
    Lighting.Ambient = Color3.new(0, 0, 0)
    Lighting.Brightness = 1
end
