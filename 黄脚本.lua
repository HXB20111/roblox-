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

-- 卡密格式验证
local function checkFormat(cardKey)
    if #cardKey < 6 or #cardKey > 12 then
        return false, "长度需为6-12位"
    end
    local hasDigit = string.match(cardKey, "%d")
    local hasAlpha = string.match(cardKey, "%a")
    if not hasDigit or not hasAlpha then
        return false, "必须包含数字和字母"
    end
    return true
end

-- 卡密验证主逻辑
local function verifyCard(cardKey)
    if not cardKey or cardKey == "" then
        return false, "请输入卡密"
    end
    local formatOk, formatMsg = checkFormat(cardKey)
    if not formatOk then
        return false, "格式错误：" .. formatMsg
    end
    local cardInfo = validCards[cardKey]
    if not cardInfo then
        return false, "卡密不存在"
    end
    if cardInfo.status == "expired" then
        return false, "卡密已过期（到期日：" .. cardInfo.expire .. "）"
    end
    -- 验证成功后执行指定脚本
    local success, result = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MIAN57/main/refs/heads/main/hi"))()
    end)
    if not success then
        return true, "验证成功，但脚本执行失败：" .. result
    end
    return true, "验证成功！已执行指定脚本（到期日：" .. cardInfo.expire .. "）"
end

-- 关闭窗口函数
local function closeUI()
    uiElements.isOpen = false
    print("\n窗口已关闭")
end

-- 渲染UI与交互
local function renderUI()
    -- 标题栏显示（右上角关闭按钮）
    print("\n==========================")
    print("      卡密验证系统      " .. uiElements.closeBtn.text)
    print("==========================")
    print("提示：加入QQ群1057766561获得卡密 | " .. uiElements.closeBtn.tip)
    io.write("请输入卡密：")
    local input = io.read()
    
    -- 检测关闭指令
    if input == uiElements.closeBtn.text then
        closeUI()
        return
    end
    
    -- 执行验证
    local success, msg = verifyCard(input)
    print("\n" .. msg)
end

-- 启动程序
while uiElements.isOpen do
    renderUI()
end
