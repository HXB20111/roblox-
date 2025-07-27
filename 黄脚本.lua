local ScriptName = "黄脚本-" 
local Key = "Hfh916"
local QQ = "1057766561"
local NoKey = "请加入群聊，获得卡密" -- 如果玩家的卡密错误 踢出游戏的提示
function o()
loadstring(game:HttpGet("https://raw.githubusercontent.com/MIAN57/main/refs/heads/main/hi"))()
end

local Info = ""

local ScreenGui = Instance.new("ScreenGui")
local Frame_1 = Instance.new("Frame")
local TextLabel_1 = Instance.new("TextLabel")
local TextBox_1 = Instance.new("TextBox")
local TextLabel_2 = Instance.new("TextLabel")
local TextLabel_3 = Instance.new("TextLabel")
local TextButton_1 = Instance.new("TextButton")
local TextButton_2 = Instance.new("TextButton")
local TextButton_3 = Instance.new("TextButton")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

Frame_1.Parent = ScreenGui
Frame_1.BackgroundColor3 = Color3.fromRGB(255,190,10)
Frame_1.BorderColor3 = Color3.fromRGB(0,0,0)
Frame_1.BorderSizePixel = 0
Frame_1.Position = UDim2.new(0.277888447, 0,0.0896414369, 0)
Frame_1.Size = UDim2.new(0, 300,0, 200)

TextLabel_1.Parent = ScreenGui
TextLabel_1.BackgroundColor3 = Color3.fromRGB(134,94,255)
TextLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
TextLabel_1.BorderSizePixel = 0
TextLabel_1.Position = UDim2.new(0.276892424, 0,0.0896414369, 0)
TextLabel_1.Size = UDim2.new(0, 554,0, 29)
TextLabel_1.Font = Enum.Font.SourceSans
TextLabel_1.Text = ScriptName.."卡密系统"
TextLabel_1.TextColor3 = Color3.fromRGB(255,200,102)
TextLabel_1.TextSize = 30

TextBox_1.Parent = ScreenGui
TextBox_1.Active = true
TextBox_1.BackgroundColor3 = Color3.fromRGB(113,110,156)
TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
TextBox_1.BorderSizePixel = 0
TextBox_1.CursorPosition = -1
TextBox_1.Position = UDim2.new(0.4741036, 0,0.334661365, 0)
TextBox_1.Size = UDim2.new(0, 158,0, 41)
TextBox_1.Font = Enum.Font.SourceSans
TextBox_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
TextBox_1.PlaceholderText = ""
TextBox_1.Text = ""
TextBox_1.TextSize = 14

TextLabel_2.Parent = ScreenGui
TextLabel_2.BackgroundColor3 = Color3.fromRGB(170,170,255)
TextLabel_2.BorderColor3 = Color3.fromRGB(0,0,0)
TextLabel_2.BorderSizePixel = 0
TextLabel_2.Position = UDim2.new(0.4741036, 0,0.416334659, 0)
TextLabel_2.Size = UDim2.new(0, 158,0, 18)
TextLabel_2.Font = Enum.Font.SourceSans
TextLabel_2.Text = "加入群聊1057766561，获得卡密"
TextLabel_2.TextSize = 15

TextLabel_3.Parent = ScreenGui
TextLabel_3.BackgroundColor3 = Color3.fromRGB(170,170,255)
TextLabel_3.BorderColor3 = Color3.fromRGB(0,0,0)
TextLabel_3.BorderSizePixel = 0
TextLabel_3.Position = UDim2.new(0.417330682, 0,0.213147417, 0)
TextLabel_3.Size = UDim2.new(0, 270,0, 40)
TextLabel_3.Font = Enum.Font.SourceSans
TextLabel_3.Text = "请输入卡密"
TextLabel_3.TextColor3 = Color3.fromRGB(130,111,203)
TextLabel_3.TextScaled = true
TextLabel_3.TextSize = 20
TextLabel_3.TextWrapped = true

TextButton_1.Parent = ScreenGui
TextButton_1.Active = true
TextButton_1.BackgroundColor3 = Color3.fromRGB(151,151,255)
TextButton_1.BorderColor3 = Color3.fromRGB(0,0,0)
TextButton_1.BorderSizePixel = 0
TextButton_1.Position = UDim2.new(0.375497997, 0,0.539840639, 0)
TextButton_1.Size = UDim2.new(0, 88,0, 30)
TextButton_1.Font = Enum.Font.SourceSans
TextButton_1.Text = "确认"
TextButton_1.TextSize = 19
TextButton_1.MouseButton1Click:Connect(function()
if TextBox_1.Text == Key then
o() -- bad 
ScreenGui:Destroy()
else
game.Players.LocalPlayer:Kick(NoKey)
end
end)

TextButton_2.Parent = ScreenGui
TextButton_2.Active = true
TextButton_2.BackgroundColor3 = Color3.fromRGB(255,215,0)
TextButton_2.BorderColor3 = Color3.fromRGB(0,0,0)
TextButton_2.BorderSizePixel = 0
TextButton_2.Position = UDim2.new(0.631474078, 0,0.539840639, 0)
TextButton_2.Size = UDim2.new(0, 88,0, 30)
TextButton_2.Font = Enum.Font.SourceSans
TextButton_2.Text = "关闭"
TextButton_2.TextSize = 19
TextButton_2.MouseButton1Click:Connect(function()
ScreenGui:Destroy()
end)

TextButton_3.Parent = ScreenGui
TextButton_3.Active = true
TextButton_3.BackgroundColor3 = Color3.fromRGB(255,215,0)
TextButton_3.BorderColor3 = Color3.fromRGB(0,0,0)
TextButton_3.BorderSizePixel = 0
TextButton_3.Position = UDim2.new(0.75, 0,0.159362555, 0)
TextButton_3.Size = UDim2.new(0, 79,0, 30)
TextButton_3.Font = Enum.Font.SourceSans
TextButton_3.Text = "复制脚本官群"
TextButton_3.TextScaled = true
TextButton_3.TextSize = 10
TextButton_3.TextWrapped = true
TextButton_3.MouseButton1Click:Connect(function()
setclipboard(1057766561)
end)
