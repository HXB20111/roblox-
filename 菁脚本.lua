    local CoreGui = game:GetService("StarterGui")

CoreGui:SetCore("SendNotification", {
    Title = "你的脚本名称（菁脚本）",
    Text = "正在加载",
    Duration = 5, 
})

print("反挂机开启")
		local vu = game:GetService("VirtualUser")
		game:GetService("Players").LocalPlayer.Idled:connect(function()
		   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		   wait(1)
		   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		end)
		
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/HXB20111/roblox-/refs/heads/main/%E9%BB%84%E8%84%9A%E6%9C%ACUI.lua'))()
local Window = OrionLib:MakeWindow({Name = "菁脚本", HidePremium = false, SaveConfig = true,IntroText = "欢迎使用菁脚本", ConfigFolder = "欢迎菁脚本"})

local about = Window:MakeTab({
    Name = "玩家信息",
    Icon = "rbxassetid://11109742737",
    PremiumOnly = false
})

about:AddParagraph("您的用户名:"," "..game.Players.LocalPlayer.Name.."")
about:AddParagraph("您的注入器:"," "..identifyexecutor().."")
about:AddParagraph("QQ群 : ","未知")

local Tab = Window:MakeTab({
  Name = "玩家功能",
  Icon = "rbxassetid://4483345998",
  PremiumOnly = false
  })

-- 文本框配置函数
local function addSettingTextbox(tab, config)
    tab:AddTextbox({
        Name = config.Name,
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
Tab:AddButton({
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


Tab:AddButton({
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

-- 相机焦距输入调节（输入后自动清空）
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
            -- 执行设置
            config.Callback(num)
            -- 显示成功通知
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
        game.Players.LocalPlayer.CameraMaxZoomDistance = num
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
Tab:AddButton({
    Name = "夜视模式",
    Default = false,
    Callback = function(enabled)
        Lighting.Ambient = enabled and Color3.new(0.5, 0.5, 0.5) or Color3.new(0, 0, 0)
        Lighting.Brightness = enabled and 2 or 1
    end,
    Color = Color3.fromRGB(255, 165, 0)
})

-- 穿墙模式
local Clipon = false
local Stepped

Tab:AddButton({
    Name = "穿墙模式",
    Default = false,
    Callback = function(enabled)
        Clipon = enabled
        local Workspace = game:GetService("Workspace")
        local Players = game:GetService("Players")
        
        -- 断开已有连接
        if Stepped then
            Stepped:Disconnect()
        end
        
        if enabled then
            -- 开启穿墙：禁用角色碰撞
            Stepped = game:GetService("RunService").Stepped:Connect(function()
                if Clipon then
                    local playerChar = Workspace:FindFirstChild(Players.LocalPlayer.Name)
                    if playerChar then
                        for _, part in pairs(playerChar:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                else
                    Stepped:Disconnect()
                end
            end)
            OrionLib:MakeNotification({Name = "成功", Content = "穿墙模式已开启", Time = 2})
        else
            -- 关闭穿墙：恢复碰撞
            local playerChar = Workspace:FindFirstChild(Players.LocalPlayer.Name)
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

-- 透视功能
Tab:AddButton({
    Name = "透视",
    Default = false,
    Callback = function(enabled)
        if enabled then
            -- 加载透视功能
            pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()
                OrionLib:MakeNotification({Name = "成功", Content = "透视功能已开启", Time = 2})
            end)
        else
            -- 尝试关闭透视（根据实际实现补充关闭逻辑）
            -- 若原透视脚本有卸载函数，可在此调用，示例：
            -- if typeof(StopESP) == "function" then StopESP() end
            OrionLib:MakeNotification({Name = "提示", Content = "透视功能已关闭", Time = 2})
        end
    end,
    Color = Color3.fromRGB(128, 0, 128) -- 紫色标识
})

-- 旋转速度调节
Tab:AddButton({
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
        
        local plr = game:GetService("Players").LocalPlayer
        repeat task.wait() until plr.Character
        local humRoot = plr.Character:WaitForChild("HumanoidRootPart")
        local humanoid = plr.Character:WaitForChild("Humanoid")
        humanoid.AutoRotate = false

        if not spinVelocity then
            spinVelocity = Instance.new("AngularVelocity")
            spinVelocity.Attachment0 = humRoot:WaitForChild("RootAttachment")
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
Tab:AddButton({
    Name = "停止旋转",
    Callback = function()
        local plr = game:GetService("Players").LocalPlayer
        repeat task.wait() until plr.Character
        local humRoot = plr.Character:WaitForChild("HumanoidRootPart")
        local humanoid = plr.Character:WaitForChild("Humanoid")

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

local Tab = Window:MakeTab({Name = "其他脚本", Icon = "rbxassetid://4483345998"})

Tab:AddButton({
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
Tab:AddButton({
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

Tab:AddButton({
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

Tab:AddButton({
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
Tab:AddButton({
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
Tab:AddButton({
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
Tab:AddButton({
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

Tab:AddButton({
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

Tab:AddButton({
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

Tab:AddButton({
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
