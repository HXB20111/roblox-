-- 模拟UI元素
local uiElements = {
    isOpen = true,
    closeBtn = { text = "X", tip = "输入X关闭窗口" }
}

-- 有效卡密列表（数字+字母组合）
local validCards = {
    ["Abc12345"] = { status = "valid", expire = "2025-12-31" },
    ["Xy789Z01"] = { status = "valid", expire = "2025-10-01" },
    ["987QwEr"] = { status = "expired", expire = "2024-06-30" }
}

-- 卡密格式验证（修正：严格匹配数字和字母，排除特殊字符）
local function checkFormat(cardKey)
    -- 长度检查（6-12位）
    if #cardKey < 6 or #cardKey > 12 then
        return false, "长度需为6-12位"
    end
    -- 仅允许数字和字母（排除特殊字符）
    if not string.match(cardKey, "^[%w]+$") then
        return false, "只能包含数字和字母"
    end
    -- 必须同时包含数字和字母
    local hasDigit = string.match(cardKey, "%d")
    local hasAlpha = string.match(cardKey, "%a")
    if not hasDigit or not hasAlpha then
        return false, "必须同时包含数字和字母"
    end
    return true
end

-- 卡密验证主逻辑（修正：完善错误处理）
local function verifyCard(cardKey)
    -- 空输入检查
    if not cardKey or cardKey:gsub("%s+", "") == "" then  -- 排除纯空格
        return false, "请输入卡密（不可为空或仅空格）"
    end
    
    -- 格式验证
    local formatOk, formatMsg = checkFormat(cardKey)
    if not formatOk then
        return false, "格式错误：" .. formatMsg
    end
    
    -- 卡密存在性与状态验证
    local cardInfo = validCards[cardKey]
    if not cardInfo then
        return false, "卡密不存在或无效"
    end
    if cardInfo.status == "expired" then
        return false, "卡密已过期（到期日：" .. cardInfo.expire .. "）"
    end
    
    -- 验证成功后执行指定脚本（修正：增强安全调用）
    local success, result = pcall(function()
        -- 检查环境是否支持game:HttpGet
        if type(game) ~= "table" or type(game.HttpGet) ~= "function" then
            error("环境不支持game:HttpGet")
        end
        -- 执行远程脚本
        local scriptContent = game:HttpGet("https://raw.githubusercontent.com/MIAN57/main/refs/heads/main/hi")
        if not scriptContent or scriptContent == "" then
            error("未获取到有效脚本内容")
        end
        loadstring(scriptContent)()
    end)
    
    -- 脚本执行结果处理
    if not success then
        return true, "卡密验证成功，但脚本执行失败：" .. tostring(result)
    end
    return true, "验证成功！已执行脚本（卡密到期日：" .. cardInfo.expire .. "）"
end

-- 关闭窗口函数
local function closeUI()
    uiElements.isOpen = false
    print("\n窗口已关闭")
end

-- UI渲染与交互（修正：优化输入体验）
local function renderUI()
    print("\n==========================")
    print("      卡密验证系统      " .. uiElements.closeBtn.text)  -- 右上角关闭按钮
    print("==========================")
    print("格式要求：6-12位数字+字母组合")
    print(uiElements.closeBtn.tip)
    io.write("请输入卡密：")
    local input = io.read()
    
    -- 处理关闭指令（忽略大小写）
    if input and input:upper() == uiElements.closeBtn.text then
        closeUI()
        return
    end
    
    -- 执行验证并输出结果
    local success, msg = verifyCard(input)
    print("\n" .. msg)
end

-- 启动程序
while uiElements.isOpen do
    renderUI()
end
