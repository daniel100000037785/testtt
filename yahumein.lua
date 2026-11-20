--// YAHU REDEEMER v6 — SENDER INTEGRATED
--// Everything in one file.

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")

local player    = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================
local CFG_PATH = "yahu_redeemer_config.json"
local cfg = {
    autoScan = true, autoSubmit = true, submitAfterCollect = false,
    checkpoints = { 3 }, triggerKeyword = "code is", triggerEnabled = true,
    uppercaseOnly = false, delayMs = 0,
    posX = -120, posY = -120,
    minimized = false, miniConsoleMinimized = false,
    activeTab = 1, uiScale = 0.9, themeKey = "teal", rfMode = false,
    senderEnabled = false,
}

local function saveConfig()
    if not writefile then return end
    pcall(function() writefile(CFG_PATH, HttpService:JSONEncode(cfg)) end)
end

local function loadConfig()
    if not (readfile and isfile and isfile(CFG_PATH)) then return end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(CFG_PATH)) end)
    if not ok or type(data) ~= "table" then return end
    if type(data.autoScan) == "boolean" then cfg.autoScan = data.autoScan end
    if type(data.autoSubmit) == "boolean" then cfg.autoSubmit = data.autoSubmit
    elseif type(data.autoCode) == "boolean" then cfg.autoSubmit = data.autoCode end
    if type(data.submitAfterCollect) == "boolean" then cfg.submitAfterCollect = data.submitAfterCollect end
    if type(data.checkpoints) == "table" then
        local cleaned = {}
        for _, v in ipairs(data.checkpoints) do
            local n = tonumber(v); if n and n >= 1 and n <= 5 then table.insert(cleaned, math.floor(n)) end
        end
        table.sort(cleaned); cfg.checkpoints = cleaned
    end
    if type(data.triggerKeyword) == "string" then cfg.triggerKeyword = data.triggerKeyword
    elseif type(data.keywords) == "table" and type(data.keywords[1]) == "string" then cfg.triggerKeyword = data.keywords[1] end
    if type(data.triggerEnabled) == "boolean" then cfg.triggerEnabled = data.triggerEnabled end
    if type(data.uppercaseOnly) == "boolean" then cfg.uppercaseOnly = data.uppercaseOnly end
    if type(data.delayMs) == "number" then cfg.delayMs = math.clamp(math.floor(data.delayMs + 0.5), 0, 5000) end
    if type(data.posX) == "number" then cfg.posX = data.posX end
    if type(data.posY) == "number" then cfg.posY = data.posY end
    if type(data.minimized) == "boolean" then cfg.minimized = data.minimized end
    if type(data.miniConsoleMinimized) == "boolean" then cfg.miniConsoleMinimized = data.miniConsoleMinimized end
    if type(data.uiScale) == "number" then cfg.uiScale = math.clamp(data.uiScale, 0.5, 1.2) end
    if type(data.themeKey) == "string" then cfg.themeKey = data.themeKey end
    if type(data.rfMode) == "boolean" then cfg.rfMode = data.rfMode end
    if type(data.activeTab) == "number" then cfg.activeTab = math.clamp(math.floor(data.activeTab), 1, 4) end
    if type(data.senderEnabled) == "boolean" then cfg.senderEnabled = data.senderEnabled end
end

loadConfig()

--==================================================
-- THEMES
--==================================================
local THEMES = {
    teal = { bg0=Color3.fromRGB(7,12,21), bg1=Color3.fromRGB(11,18,30), bg2=Color3.fromRGB(17,28,43), bg3=Color3.fromRGB(21,36,54), bg4=Color3.fromRGB(28,47,68), accent=Color3.fromRGB(48,215,190), accentBright=Color3.fromRGB(111,245,220), accentDim=Color3.fromRGB(28,115,108), toggleOn=Color3.fromRGB(35,169,151), toggleOff=Color3.fromRGB(43,58,74), text=Color3.fromRGB(238,247,249), muted=Color3.fromRGB(139,160,176), input=Color3.fromRGB(7,13,22), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    blue = { bg0=Color3.fromRGB(6,11,24), bg1=Color3.fromRGB(10,17,34), bg2=Color3.fromRGB(16,27,52), bg3=Color3.fromRGB(23,37,68), bg4=Color3.fromRGB(32,50,88), accent=Color3.fromRGB(80,160,255), accentBright=Color3.fromRGB(160,205,255), accentDim=Color3.fromRGB(38,82,148), toggleOn=Color3.fromRGB(55,125,215), toggleOff=Color3.fromRGB(40,55,82), text=Color3.fromRGB(235,242,252), muted=Color3.fromRGB(135,158,185), input=Color3.fromRGB(8,14,26), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    purple = { bg0=Color3.fromRGB(11,7,21), bg1=Color3.fromRGB(17,11,31), bg2=Color3.fromRGB(26,17,45), bg3=Color3.fromRGB(36,24,61), bg4=Color3.fromRGB(48,32,80), accent=Color3.fromRGB(180,120,255), accentBright=Color3.fromRGB(215,180,255), accentDim=Color3.fromRGB(88,55,140), toggleOn=Color3.fromRGB(140,85,210), toggleOff=Color3.fromRGB(48,40,68), text=Color3.fromRGB(245,238,252), muted=Color3.fromRGB(160,145,185), input=Color3.fromRGB(14,9,24), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    red = { bg0=Color3.fromRGB(20,7,10), bg1=Color3.fromRGB(30,11,15), bg2=Color3.fromRGB(45,17,22), bg3=Color3.fromRGB(60,24,31), bg4=Color3.fromRGB(80,32,41), accent=Color3.fromRGB(255,90,110), accentBright=Color3.fromRGB(255,160,175), accentDim=Color3.fromRGB(140,45,60), toggleOn=Color3.fromRGB(215,65,85), toggleOff=Color3.fromRGB(72,45,52), text=Color3.fromRGB(252,235,238), muted=Color3.fromRGB(185,145,152), input=Color3.fromRGB(24,9,13), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    orange = { bg0=Color3.fromRGB(20,13,5), bg1=Color3.fromRGB(31,20,8), bg2=Color3.fromRGB(47,30,13), bg3=Color3.fromRGB(63,41,18), bg4=Color3.fromRGB(84,55,24), accent=Color3.fromRGB(255,160,70), accentBright=Color3.fromRGB(255,205,145), accentDim=Color3.fromRGB(140,82,34), toggleOn=Color3.fromRGB(215,130,50), toggleOff=Color3.fromRGB(75,55,36), text=Color3.fromRGB(252,242,232), muted=Color3.fromRGB(185,158,125), input=Color3.fromRGB(24,15,6), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    pink = { bg0=Color3.fromRGB(20,7,15), bg1=Color3.fromRGB(30,11,22), bg2=Color3.fromRGB(45,17,33), bg3=Color3.fromRGB(60,24,44), bg4=Color3.fromRGB(80,32,58), accent=Color3.fromRGB(255,120,195), accentBright=Color3.fromRGB(255,180,225), accentDim=Color3.fromRGB(140,55,105), toggleOn=Color3.fromRGB(220,90,165), toggleOff=Color3.fromRGB(72,45,60), text=Color3.fromRGB(252,235,245), muted=Color3.fromRGB(185,148,172), input=Color3.fromRGB(24,9,18), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    green = { bg0=Color3.fromRGB(5,16,10), bg1=Color3.fromRGB(9,24,16), bg2=Color3.fromRGB(15,36,24), bg3=Color3.fromRGB(22,50,34), bg4=Color3.fromRGB(32,68,46), accent=Color3.fromRGB(90,235,150), accentBright=Color3.fromRGB(170,255,200), accentDim=Color3.fromRGB(45,130,85), toggleOn=Color3.fromRGB(65,200,125), toggleOff=Color3.fromRGB(40,60,48), text=Color3.fromRGB(235,252,240), muted=Color3.fromRGB(140,180,155), input=Color3.fromRGB(6,20,13), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    gray = { bg0=Color3.fromRGB(12,13,15), bg1=Color3.fromRGB(18,19,22), bg2=Color3.fromRGB(26,28,32), bg3=Color3.fromRGB(36,39,44), bg4=Color3.fromRGB(48,52,58), accent=Color3.fromRGB(180,188,198), accentBright=Color3.fromRGB(225,232,240), accentDim=Color3.fromRGB(90,96,105), toggleOn=Color3.fromRGB(120,130,145), toggleOff=Color3.fromRGB(50,54,60), text=Color3.fromRGB(240,244,248), muted=Color3.fromRGB(160,168,178), input=Color3.fromRGB(14,15,18), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    cyan = { bg0=Color3.fromRGB(5,15,20), bg1=Color3.fromRGB(8,22,30), bg2=Color3.fromRGB(13,33,44), bg3=Color3.fromRGB(19,46,60), bg4=Color3.fromRGB(28,62,80), accent=Color3.fromRGB(70,220,240), accentBright=Color3.fromRGB(150,245,255), accentDim=Color3.fromRGB(35,115,130), toggleOn=Color3.fromRGB(50,180,200), toggleOff=Color3.fromRGB(38,58,68), text=Color3.fromRGB(235,250,252), muted=Color3.fromRGB(135,175,185), input=Color3.fromRGB(6,18,24), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    yellow = { bg0=Color3.fromRGB(20,18,5), bg1=Color3.fromRGB(31,28,8), bg2=Color3.fromRGB(47,42,13), bg3=Color3.fromRGB(63,56,18), bg4=Color3.fromRGB(84,74,24), accent=Color3.fromRGB(250,220,80), accentBright=Color3.fromRGB(255,240,160), accentDim=Color3.fromRGB(140,120,34), toggleOn=Color3.fromRGB(210,180,50), toggleOff=Color3.fromRGB(72,65,36), text=Color3.fromRGB(252,250,232), muted=Color3.fromRGB(185,175,125), input=Color3.fromRGB(24,21,6), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    silver = { bg0=Color3.fromRGB(14,15,18), bg1=Color3.fromRGB(20,22,26), bg2=Color3.fromRGB(30,33,38), bg3=Color3.fromRGB(42,46,52), bg4=Color3.fromRGB(56,60,68), accent=Color3.fromRGB(210,215,225), accentBright=Color3.fromRGB(245,248,252), accentDim=Color3.fromRGB(105,110,122), toggleOn=Color3.fromRGB(160,168,180), toggleOff=Color3.fromRGB(55,58,65), text=Color3.fromRGB(248,250,252), muted=Color3.fromRGB(170,175,185), input=Color3.fromRGB(16,17,20), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    gold = { bg0=Color3.fromRGB(20,15,5), bg1=Color3.fromRGB(31,24,8), bg2=Color3.fromRGB(47,36,13), bg3=Color3.fromRGB(63,49,18), bg4=Color3.fromRGB(84,65,24), accent=Color3.fromRGB(240,195,90), accentBright=Color3.fromRGB(255,225,150), accentDim=Color3.fromRGB(135,100,40), toggleOn=Color3.fromRGB(210,165,60), toggleOff=Color3.fromRGB(72,58,36), text=Color3.fromRGB(252,245,230), muted=Color3.fromRGB(190,170,130), input=Color3.fromRGB(24,18,6), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    lime = { bg0=Color3.fromRGB(12,18,5), bg1=Color3.fromRGB(18,28,8), bg2=Color3.fromRGB(28,43,13), bg3=Color3.fromRGB(40,60,19), bg4=Color3.fromRGB(54,80,28), accent=Color3.fromRGB(180,240,70), accentBright=Color3.fromRGB(215,255,145), accentDim=Color3.fromRGB(95,135,34), toggleOn=Color3.fromRGB(150,210,55), toggleOff=Color3.fromRGB(52,68,36), text=Color3.fromRGB(245,252,232), muted=Color3.fromRGB(170,190,130), input=Color3.fromRGB(15,22,6), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    skyblue = { bg0=Color3.fromRGB(5,14,22), bg1=Color3.fromRGB(8,22,34), bg2=Color3.fromRGB(13,34,50), bg3=Color3.fromRGB(19,48,70), bg4=Color3.fromRGB(28,66,92), accent=Color3.fromRGB(120,200,245), accentBright=Color3.fromRGB(180,230,255), accentDim=Color3.fromRGB(55,110,145), toggleOn=Color3.fromRGB(90,165,210), toggleOff=Color3.fromRGB(42,60,78), text=Color3.fromRGB(238,248,255), muted=Color3.fromRGB(140,168,190), input=Color3.fromRGB(6,18,28), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    indigo = { bg0=Color3.fromRGB(8,8,22), bg1=Color3.fromRGB(13,13,34), bg2=Color3.fromRGB(22,22,52), bg3=Color3.fromRGB(32,32,72), bg4=Color3.fromRGB(44,44,96), accent=Color3.fromRGB(110,115,245), accentBright=Color3.fromRGB(175,180,255), accentDim=Color3.fromRGB(55,58,145), toggleOn=Color3.fromRGB(85,90,210), toggleOff=Color3.fromRGB(44,46,78), text=Color3.fromRGB(238,238,252), muted=Color3.fromRGB(148,150,190), input=Color3.fromRGB(10,10,28), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    magenta = { bg0=Color3.fromRGB(20,5,18), bg1=Color3.fromRGB(31,8,28), bg2=Color3.fromRGB(47,13,42), bg3=Color3.fromRGB(63,19,56), bg4=Color3.fromRGB(84,28,74), accent=Color3.fromRGB(245,75,220), accentBright=Color3.fromRGB(255,160,240), accentDim=Color3.fromRGB(135,40,120), toggleOn=Color3.fromRGB(210,55,185), toggleOff=Color3.fromRGB(72,36,66), text=Color3.fromRGB(252,235,250), muted=Color3.fromRGB(190,140,180), input=Color3.fromRGB(24,6,20), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    violet = { bg0=Color3.fromRGB(15,6,24), bg1=Color3.fromRGB(23,10,36), bg2=Color3.fromRGB(35,15,55), bg3=Color3.fromRGB(48,22,74), bg4=Color3.fromRGB(64,30,98), accent=Color3.fromRGB(170,100,245), accentBright=Color3.fromRGB(215,175,255), accentDim=Color3.fromRGB(85,48,130), toggleOn=Color3.fromRGB(140,75,210), toggleOff=Color3.fromRGB(52,38,78), text=Color3.fromRGB(245,238,255), muted=Color3.fromRGB(165,148,200), input=Color3.fromRGB(17,8,28), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    crimson = { bg0=Color3.fromRGB(22,5,8), bg1=Color3.fromRGB(34,8,12), bg2=Color3.fromRGB(50,13,18), bg3=Color3.fromRGB(66,19,26), bg4=Color3.fromRGB(86,28,36), accent=Color3.fromRGB(230,40,65), accentBright=Color3.fromRGB(255,140,155), accentDim=Color3.fromRGB(120,30,45), toggleOn=Color3.fromRGB(200,30,55), toggleOff=Color3.fromRGB(72,40,46), text=Color3.fromRGB(252,232,236), muted=Color3.fromRGB(190,140,148), input=Color3.fromRGB(26,7,11), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    rose = { bg0=Color3.fromRGB(22,8,14), bg1=Color3.fromRGB(34,12,22), bg2=Color3.fromRGB(50,18,32), bg3=Color3.fromRGB(66,26,44), bg4=Color3.fromRGB(86,36,60), accent=Color3.fromRGB(245,130,175), accentBright=Color3.fromRGB(255,190,220), accentDim=Color3.fromRGB(130,62,92), toggleOn=Color3.fromRGB(210,100,145), toggleOff=Color3.fromRGB(74,44,58), text=Color3.fromRGB(255,240,246), muted=Color3.fromRGB(195,155,175), input=Color3.fromRGB(26,10,18), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    mint = { bg0=Color3.fromRGB(6,18,14), bg1=Color3.fromRGB(10,28,22), bg2=Color3.fromRGB(16,42,33), bg3=Color3.fromRGB(24,58,46), bg4=Color3.fromRGB(34,78,62), accent=Color3.fromRGB(120,245,200), accentBright=Color3.fromRGB(185,255,230), accentDim=Color3.fromRGB(55,130,105), toggleOn=Color3.fromRGB(85,205,165), toggleOff=Color3.fromRGB(44,66,58), text=Color3.fromRGB(238,255,250), muted=Color3.fromRGB(145,190,175), input=Color3.fromRGB(7,22,17), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
    aqua = { bg0=Color3.fromRGB(5,18,18), bg1=Color3.fromRGB(8,28,28), bg2=Color3.fromRGB(13,42,42), bg3=Color3.fromRGB(19,58,58), bg4=Color3.fromRGB(28,78,78), accent=Color3.fromRGB(100,245,235), accentBright=Color3.fromRGB(170,255,250), accentDim=Color3.fromRGB(45,130,125), toggleOn=Color3.fromRGB(70,205,195), toggleOff=Color3.fromRGB(42,66,66), text=Color3.fromRGB(238,255,254), muted=Color3.fromRGB(140,190,188), input=Color3.fromRGB(6,22,22), green=Color3.fromRGB(105,235,160), red=Color3.fromRGB(255,105,125), yellow=Color3.fromRGB(255,215,115), knob=Color3.fromRGB(241,255,252) },
}
local THEME_ORDER = { "teal","blue","purple","red","orange","pink","green","gray","cyan","yellow","silver","gold","lime","skyblue","indigo","magenta","violet","crimson","rose","mint","aqua" }
local COLOR_SLOTS = { "bg0","bg1","bg2","bg3","bg4","accent","accentBright","accentDim","toggleOn","toggleOff","text","muted","input","green","red","yellow","knob" }

local C = {
    tweenFast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    tweenMed  = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    knob = Color3.fromRGB(241, 255, 252),
}
local reg = { bg = {}, stroke = {}, text = {}, scroll = {} }
local function trackBg(i,s) reg.bg[i]=s; return i end
local function trackStroke(i,s) reg.stroke[i]=s; return i end
local function trackText(i,s) reg.text[i]=s; return i end
local function trackScroll(sf) reg.scroll[sf]=true; return sf end

local function applyThemeInstant(key)
    local t = THEMES[key] or THEMES.teal
    for _, slot in ipairs(COLOR_SLOTS) do if t[slot] ~= nil then C[slot] = t[slot] end end
    cfg.themeKey = key
end
local function repaintAll()
    for inst, slot in pairs(reg.bg) do
        if inst and inst.Parent and C[slot] then TweenService:Create(inst, C.tweenMed, { BackgroundColor3 = C[slot] }):Play() end end
    for st, slot in pairs(reg.stroke) do
        if st and st.Parent and C[slot] then TweenService:Create(st, C.tweenMed, { Color = C[slot] }):Play() end end
    for inst, slot in pairs(reg.text) do
        if inst and inst.Parent and C[slot] then TweenService:Create(inst, C.tweenMed, { TextColor3 = C[slot] }):Play() end end
    for sf in pairs(reg.scroll) do
        if sf and sf.Parent then TweenService:Create(sf, C.tweenMed, { ScrollBarImageColor3 = C.accent }):Play() end end
end
applyThemeInstant(cfg.themeKey)

local LOG_COLOR = {
    gray = Color3.fromRGB(200,210,220), green = Color3.fromRGB(105,235,160),
    red = Color3.fromRGB(255,105,125), yellow = Color3.fromRGB(255,215,115),
    blue = Color3.fromRGB(120,190,255), purple = Color3.fromRGB(190,145,255),
}
local function corner(inst, r)
    local c = Instance.new("UICorner"); c.CornerRadius = r or UDim.new(0,8); c.Parent = inst
end
local function stroke(inst, slot, th)
    slot = slot or "accent"
    local s = Instance.new("UIStroke")
    s.Color = C[slot] or C.accent; s.Thickness = th or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = inst
    trackStroke(s, slot); return s
end

--==================================================
-- SENDER STRING
--==================================================
local SENDER_SRC = [==[
--=============================================================
-- YAHU SENDER · v3.2 — Redeemer Style + Perfect Minimize
--=============================================================
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local RS        = ReplicatedStorage
local Net       = RS:WaitForChild("Packages"):WaitForChild("Net")

if typeof(firesignal) ~= "function" then
    warn("[YahuSender] executor has no 'firesignal'.")
    return
end

local function resolveRemote()
    if _G.PhiNotifyRemote then return _G.PhiNotifyRemote end
    local getinfo = debug and (debug.getinfo or debug.info)
    if getgc and getinfo then
        if getconnections then
            for _, d in ipairs(Net:GetDescendants()) do
                if d:IsA("RemoteEvent") then
                    local ok, cs = pcall(getconnections, d.OnClientEvent)
                    if ok then
                        for _, c in ipairs(cs) do
                            local f, fn = pcall(function() return c.Function end)
                            if f and type(fn) == "function" then
                                local i, info = pcall(getinfo, fn)
                                if i and tostring(info.short_src or info.source or ""):find("NotificationController", 1, true) then
                                    return d
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local remote = resolveRemote()
if not remote then
    warn("[YahuSender] notify remote not found — load Phi first.")
    return
end
print("[YahuSender] using remote:", remote.Name)

local function fire(txt)
    txt = (txt or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if txt == "" then return end
    firesignal(remote.OnClientEvent, txt, 5.5, "Sounds.Sfx.Blop", "Top", 2678001507)
end

local THEMES = {
    teal   = { bg0=Color3.fromRGB(7,12,21),   bg1=Color3.fromRGB(11,18,30),  bg2=Color3.fromRGB(17,28,43),  bg3=Color3.fromRGB(21,36,54),  accent=Color3.fromRGB(48,215,190),  accentBright=Color3.fromRGB(111,245,220), accentDim=Color3.fromRGB(28,115,108), toggleOn=Color3.fromRGB(35,169,151), toggleOff=Color3.fromRGB(43,58,74),  text=Color3.fromRGB(238,247,249), muted=Color3.fromRGB(139,160,176), input=Color3.fromRGB(7,13,22),   knob=Color3.fromRGB(241,255,252) },
    blue   = { bg0=Color3.fromRGB(6,11,24),   bg1=Color3.fromRGB(10,17,34),  bg2=Color3.fromRGB(16,27,52),  bg3=Color3.fromRGB(23,37,68),  accent=Color3.fromRGB(80,160,255),  accentBright=Color3.fromRGB(160,205,255), accentDim=Color3.fromRGB(38,82,148),  toggleOn=Color3.fromRGB(55,125,215), toggleOff=Color3.fromRGB(40,55,82),  text=Color3.fromRGB(235,242,252), muted=Color3.fromRGB(135,158,185), input=Color3.fromRGB(8,14,26),   knob=Color3.fromRGB(241,255,252) },
    purple = { bg0=Color3.fromRGB(11,7,21),   bg1=Color3.fromRGB(17,11,31),  bg2=Color3.fromRGB(26,17,45),  bg3=Color3.fromRGB(36,24,61),  accent=Color3.fromRGB(180,120,255), accentBright=Color3.fromRGB(215,180,255), accentDim=Color3.fromRGB(88,55,140),  toggleOn=Color3.fromRGB(140,85,210), toggleOff=Color3.fromRGB(48,40,68),  text=Color3.fromRGB(245,238,252), muted=Color3.fromRGB(160,145,185), input=Color3.fromRGB(14,9,24),   knob=Color3.fromRGB(241,255,252) },
    red    = { bg0=Color3.fromRGB(20,7,10),   bg1=Color3.fromRGB(30,11,15),  bg2=Color3.fromRGB(45,17,22),  bg3=Color3.fromRGB(60,24,31),  accent=Color3.fromRGB(255,90,110),  accentBright=Color3.fromRGB(255,160,175), accentDim=Color3.fromRGB(140,45,60),  toggleOn=Color3.fromRGB(215,65,85),  toggleOff=Color3.fromRGB(72,45,52),  text=Color3.fromRGB(252,235,238), muted=Color3.fromRGB(185,145,152), input=Color3.fromRGB(24,9,13),   knob=Color3.fromRGB(241,255,252) },
    green  = { bg0=Color3.fromRGB(5,16,10),   bg1=Color3.fromRGB(9,24,16),   bg2=Color3.fromRGB(15,36,24),  bg3=Color3.fromRGB(22,50,34),  accent=Color3.fromRGB(90,235,150),  accentBright=Color3.fromRGB(170,255,200), accentDim=Color3.fromRGB(45,130,85),  toggleOn=Color3.fromRGB(65,200,125), toggleOff=Color3.fromRGB(40,60,48),  text=Color3.fromRGB(235,252,240), muted=Color3.fromRGB(140,180,155), input=Color3.fromRGB(6,20,13),   knob=Color3.fromRGB(241,255,252) },
    cyan   = { bg0=Color3.fromRGB(5,15,20),   bg1=Color3.fromRGB(8,22,30),   bg2=Color3.fromRGB(13,33,44),  bg3=Color3.fromRGB(19,46,60),  accent=Color3.fromRGB(70,220,240),  accentBright=Color3.fromRGB(150,245,255), accentDim=Color3.fromRGB(35,115,130), toggleOn=Color3.fromRGB(50,180,200), toggleOff=Color3.fromRGB(38,58,68),  text=Color3.fromRGB(235,250,252), muted=Color3.fromRGB(135,175,185), input=Color3.fromRGB(6,18,24),   knob=Color3.fromRGB(241,255,252) },
    magenta= { bg0=Color3.fromRGB(20,5,18),   bg1=Color3.fromRGB(31,8,28),   bg2=Color3.fromRGB(47,13,42),  bg3=Color3.fromRGB(63,19,56),  accent=Color3.fromRGB(245,75,220),  accentBright=Color3.fromRGB(255,160,240), accentDim=Color3.fromRGB(135,40,120), toggleOn=Color3.fromRGB(210,55,185), toggleOff=Color3.fromRGB(72,36,66),  text=Color3.fromRGB(252,235,250), muted=Color3.fromRGB(190,140,180), input=Color3.fromRGB(24,6,20),   knob=Color3.fromRGB(241,255,252) },
    gold   = { bg0=Color3.fromRGB(20,15,5),   bg1=Color3.fromRGB(31,24,8),   bg2=Color3.fromRGB(47,36,13),  bg3=Color3.fromRGB(63,49,18),  accent=Color3.fromRGB(240,195,90),  accentBright=Color3.fromRGB(255,225,150), accentDim=Color3.fromRGB(135,100,40), toggleOn=Color3.fromRGB(210,165,60), toggleOff=Color3.fromRGB(72,58,36),  text=Color3.fromRGB(252,245,230), muted=Color3.fromRGB(190,170,130), input=Color3.fromRGB(24,18,6),   knob=Color3.fromRGB(241,255,252) },
}
local THEME_ORDER = { "teal","blue","purple","red","green","cyan","magenta","gold" }
local COLOR_SLOTS = { "bg0","bg1","bg2","bg3","accent","accentBright","accentDim","toggleOn","toggleOff","text","muted","input","knob" }

local C = {
    tweenFast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    tweenMed  = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    knob = Color3.fromRGB(241,255,252),
}
local reg = { bg = {}, stroke = {}, text = {}, scroll = {} }
local function trackBg(i,s) reg.bg[i]=s; return i end
local function trackStroke(i,s) reg.stroke[i]=s; return i end
local function trackText(i,s) reg.text[i]=s; return i end

local currentThemeKey = "teal"
local function applyThemeInstant(key)
    local t = THEMES[key] or THEMES.teal
    for _, slot in ipairs(COLOR_SLOTS) do if t[slot] ~= nil then C[slot] = t[slot] end end
    currentThemeKey = key
end
local function repaintAll()
    for inst, slot in pairs(reg.bg) do
        if inst and inst.Parent and C[slot] then
            TweenService:Create(inst, C.tweenMed, { BackgroundColor3 = C[slot] }):Play() end end
    for st, slot in pairs(reg.stroke) do
        if st and st.Parent and C[slot] then
            TweenService:Create(st, C.tweenMed, { Color = C[slot] }):Play() end end
    for inst, slot in pairs(reg.text) do
        if inst and inst.Parent and C[slot] then
            TweenService:Create(inst, C.tweenMed, { TextColor3 = C[slot] }):Play() end end
end
applyThemeInstant(currentThemeKey)

local function corner(inst, r)
    local c = Instance.new("UICorner"); c.CornerRadius = r or UDim.new(0,8); c.Parent = inst
end
local function stroke(inst, slot, th)
    slot = slot or "accent"
    local s = Instance.new("UIStroke")
    s.Color = C[slot] or C.accent; s.Thickness = th or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = inst
    trackStroke(s, slot); return s
end

local popupGui, popupContainer, popupList = nil, nil, {}
local popupColors = {
    success = Color3.fromRGB(105,235,160),
    error   = Color3.fromRGB(255,105,125),
    info    = Color3.fromRGB(238,247,249),
    detect  = Color3.fromRGB(111,245,220),
}
local function getPopupScreenGui()
    if popupGui and popupGui.Parent then return popupGui end
    popupGui = Instance.new("ScreenGui")
    popupGui.Name = "YahuSenderPopups"; popupGui.ResetOnSpawn = false
    popupGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    popupGui.IgnoreGuiInset = true; popupGui.Parent = PlayerGui
    popupContainer = Instance.new("Frame"); popupContainer.Name = "Stack"
    popupContainer.BackgroundTransparency = 1; popupContainer.AnchorPoint = Vector2.new(1,1)
    popupContainer.Position = UDim2.new(1,-18,1,-80); popupContainer.Size = UDim2.new(0,300,0,400)
    popupContainer.Parent = popupGui
    local l = Instance.new("UIListLayout")
    l.FillDirection = Enum.FillDirection.Vertical
    l.HorizontalAlignment = Enum.HorizontalAlignment.Right
    l.VerticalAlignment = Enum.VerticalAlignment.Bottom
    l.SortOrder = Enum.SortOrder.LayoutOrder; l.Padding = UDim.new(0,8); l.Parent = popupContainer
    return popupGui
end
local function reflowPopupOrders()
    for i, e in ipairs(popupList) do e.frame.LayoutOrder = i end
end
local function removePopup(entry)
    if not entry or entry.removing then return end
    entry.removing = true
    for i, e in ipairs(popupList) do if e == entry then table.remove(popupList, i); break end end
    reflowPopupOrders()
    TweenService:Create(entry.frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
        { BackgroundTransparency = 1, Position = entry.frame.Position + UDim2.new(0,50,0,0) }):Play()
    TweenService:Create(entry.stroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
        { Transparency = 1 }):Play()
    for _, ch in ipairs(entry.frame:GetChildren()) do
        if ch:IsA("TextLabel") then
            TweenService:Create(ch, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                { TextTransparency = 1 }):Play() end
    end
    task.delay(0.45, function() entry.frame:Destroy() end)
end
local function notify(kind, title, subtitle, icon, duration)
    getPopupScreenGui()
    duration = duration or 3.2; icon = icon or "•"
    local accent = popupColors[kind] or popupColors.info
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,56); frame.BackgroundColor3 = C.bg2
    frame.BackgroundTransparency = 0.05; frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0,50,0,0); frame.Parent = popupContainer
    trackBg(frame, "bg2"); corner(frame, UDim.new(0,8))
    local uis = Instance.new("UIStroke"); uis.Color = accent; uis.Thickness = 1.2
    uis.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; uis.Transparency = 0.15; uis.Parent = frame
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0,3,1,-14); bar.Position = UDim2.new(0,0,0,7)
    bar.BackgroundColor3 = accent; bar.BorderSizePixel = 0; bar.Parent = frame
    corner(bar, UDim.new(1,0))
    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(0,26,1,0); ic.Position = UDim2.new(0,10,0,0); ic.BackgroundTransparency = 1
    ic.Font = Enum.Font.GothamBlack; ic.TextSize = 18; ic.TextColor3 = accent
    ic.TextXAlignment = Enum.TextXAlignment.Left; ic.Text = icon; ic.Parent = frame
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1,-50,0,22); tl.Position = UDim2.new(0,40,0,8); tl.BackgroundTransparency = 1
    tl.Font = Enum.Font.GothamBold; tl.TextSize = 13; tl.TextColor3 = C.text
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.TextTruncate = Enum.TextTruncate.AtEnd
    tl.Text = title or ""; tl.Parent = frame; trackText(tl, "text")
    local sl = Instance.new("TextLabel")
    sl.Size = UDim2.new(1,-50,0,16); sl.Position = UDim2.new(0,40,0,30); sl.BackgroundTransparency = 1
    sl.Font = Enum.Font.Code; sl.TextSize = 11; sl.TextColor3 = C.muted
    sl.TextXAlignment = Enum.TextXAlignment.Left; sl.TextTruncate = Enum.TextTruncate.AtEnd
    sl.Text = subtitle or ""; sl.Parent = frame; trackText(sl, "muted")
    TweenService:Create(frame, TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Position = UDim2.new(0,0,0,0) }):Play()
    local entry = { frame = frame, stroke = uis, removing = false }
    table.insert(popupList, entry); reflowPopupOrders()
    task.delay(duration, function() removePopup(entry) end)
    return entry
end

local TITLE_H  = 52
local MAIN_W   = 340
local MAIN_H   = 240

local screenGui, scaleWrapper, uiScaleRef
local mainFrame, titleBarRef, body
local themeBtnRef, minBtnRef, sendBtnRef, testBtnRef, inputBoxRef
local cfg = { themeKey = "teal", uiScale = 0.95, minimized = false, posX = 0, posY = 0 }

local function applyUiScale()
    cfg.uiScale = math.clamp(cfg.uiScale or 0.95, 0.5, 1.2)
    if uiScaleRef then uiScaleRef.Scale = cfg.uiScale end
end

local function setMinimized(v)
    v = v and true or false
    if cfg.minimized == v then return end
    cfg.minimized = v

    if v then
        for _, d in ipairs(body:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                d.TextTransparency = 1
            elseif d:IsA("Frame") and d ~= body then
                local slot = reg.bg[d]
                if slot then d.BackgroundTransparency = 1 end
            elseif d:IsA("UIStroke") then
                d.Transparency = 1
            end
        end
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, MAIN_W, 0, TITLE_H) }):Play()
        if minBtnRef then minBtnRef.Text = "+" end
        task.delay(0.3, function()
            if cfg.minimized then body.Visible = false end
        end)
    else
        body.Visible = true
        TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, MAIN_W, 0, MAIN_H) }):Play()
        if minBtnRef then minBtnRef.Text = "–" end
        task.delay(0.15, function()
            if cfg.minimized then return end
            for _, d in ipairs(body:GetDescendants()) do
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                    TweenService:Create(d, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { TextTransparency = 0 }):Play()
                elseif d:IsA("Frame") and d ~= body then
                    local slot = reg.bg[d]
                    if slot then
                        local target = 1
                        if slot == "bg2" then target = 0.05
                        elseif slot == "bg3" or slot == "input" then target = 0
                        elseif slot == "accentDim" then target = 0.12
                        else target = 0 end
                        TweenService:Create(d, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                            { BackgroundTransparency = target }):Play()
                    end
                elseif d:IsA("UIStroke") then
                    TweenService:Create(d, TweenInfo.new(0.22), { Transparency = 0.2 }):Play()
                end
            end
        end)
    end
end

local old = PlayerGui:FindFirstChild("PhiYahuSender"); if old then old:Destroy() end
local oldP = PlayerGui:FindFirstChild("YahuSenderPopups"); if oldP then oldP:Destroy() end
screenGui = Instance.new("ScreenGui")
screenGui.Name = "PhiYahuSender"; screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; screenGui.Parent = PlayerGui

scaleWrapper = Instance.new("Frame"); scaleWrapper.Name = "Scaler"
scaleWrapper.BackgroundTransparency = 1; scaleWrapper.Size = UDim2.new(1,0,1,0)
scaleWrapper.Parent = screenGui

uiScaleRef = Instance.new("UIScale"); uiScaleRef.Scale = cfg.uiScale; uiScaleRef.Parent = scaleWrapper

mainFrame = Instance.new("Frame"); mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, cfg.posX, 0.5, cfg.posY)
mainFrame.BackgroundColor3 = C.bg1; mainFrame.BackgroundTransparency = 0.02
mainFrame.BorderSizePixel = 0; mainFrame.Active = true; mainFrame.ClipsDescendants = true
mainFrame.Parent = scaleWrapper
trackBg(mainFrame, "bg1"); corner(mainFrame, UDim.new(0,12)); stroke(mainFrame, "accentDim", 1.2)

titleBarRef = Instance.new("Frame")
titleBarRef.Size = UDim2.new(1,0,0,TITLE_H); titleBarRef.BackgroundColor3 = C.bg0
titleBarRef.BorderSizePixel = 0; titleBarRef.Active = true; titleBarRef.Parent = mainFrame
trackBg(titleBarRef, "bg0"); corner(titleBarRef, UDim.new(0,12))

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1,-120,0,24); titleLbl.Position = UDim2.new(0,15,0,6)
titleLbl.BackgroundTransparency = 1; titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 18; titleLbl.TextColor3 = C.accentBright
titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.Text = "Yahu Sender"
titleLbl.Parent = titleBarRef; trackText(titleLbl, "accentBright")

local subLbl = Instance.new("TextLabel")
subLbl.Size = UDim2.new(1,-120,0,14); subLbl.Position = UDim2.new(0,16,0,28)
subLbl.BackgroundTransparency = 1; subLbl.Font = Enum.Font.GothamMedium
subLbl.TextSize = 9; subLbl.TextColor3 = C.muted
subLbl.TextXAlignment = Enum.TextXAlignment.Left; subLbl.Text = "NOTIFICATION DISPATCH"
subLbl.Parent = titleBarRef; trackText(subLbl, "muted")

themeBtnRef = Instance.new("TextButton")
themeBtnRef.Size = UDim2.new(0,60,0,22); themeBtnRef.AnchorPoint = Vector2.new(1,0.5)
themeBtnRef.Position = UDim2.new(1,-46,0.5,0); themeBtnRef.BackgroundColor3 = C.bg3
themeBtnRef.BorderSizePixel = 0; themeBtnRef.AutoButtonColor = false
themeBtnRef.Font = Enum.Font.GothamBold; themeBtnRef.TextSize = 10
themeBtnRef.TextColor3 = C.accentBright; themeBtnRef.Text = "THEME"
themeBtnRef.Parent = titleBarRef
trackBg(themeBtnRef, "bg3"); trackText(themeBtnRef, "accentBright")
corner(themeBtnRef, UDim.new(0,6)); stroke(themeBtnRef, "accentDim", 1)

local function cycleTheme()
    local idx = 1
    for i, k in ipairs(THEME_ORDER) do if k == currentThemeKey then idx = i; break end end
    local n = THEME_ORDER[(idx % #THEME_ORDER) + 1]
    applyThemeInstant(n); cfg.themeKey = n; repaintAll()
    notify("info","Theme", n, "◐", 2)
end
themeBtnRef.MouseButton1Click:Connect(cycleTheme)

minBtnRef = Instance.new("TextButton")
minBtnRef.Size = UDim2.new(0,24,0,22); minBtnRef.AnchorPoint = Vector2.new(1,0.5)
minBtnRef.Position = UDim2.new(1,-12,0.5,0); minBtnRef.BackgroundColor3 = C.bg3
minBtnRef.BorderSizePixel = 0; minBtnRef.AutoButtonColor = false
minBtnRef.Font = Enum.Font.GothamBlack; minBtnRef.TextSize = 16
minBtnRef.TextColor3 = C.accentBright; minBtnRef.Text = "–"; minBtnRef.Parent = titleBarRef
trackBg(minBtnRef, "bg3"); trackText(minBtnRef, "accentBright")
corner(minBtnRef, UDim.new(0,6)); stroke(minBtnRef, "accentDim", 1)
minBtnRef.MouseButton1Click:Connect(function() setMinimized(not cfg.minimized) end)

local line = Instance.new("Frame")
line.Size = UDim2.new(1,-20,0,1); line.Position = UDim2.new(0,10,1,-1)
line.BackgroundColor3 = C.accent; line.BackgroundTransparency = 0.25
line.BorderSizePixel = 0; line.Parent = titleBarRef; trackBg(line, "accent")

body = Instance.new("Frame"); body.Name = "Body"
body.Position = UDim2.new(0,0,0,TITLE_H); body.Size = UDim2.new(1,0,1,-TITLE_H)
body.BackgroundTransparency = 1; body.ClipsDescendants = true; body.Parent = mainFrame

local inputCard = Instance.new("Frame")
inputCard.Position = UDim2.new(0,12,0,12); inputCard.Size = UDim2.new(1,-24,0,50)
inputCard.BackgroundColor3 = C.bg2; inputCard.BorderSizePixel = 0
inputCard.Parent = body
trackBg(inputCard, "bg2"); corner(inputCard, UDim.new(0,9)); stroke(inputCard, "accentDim", 1)

inputBoxRef = Instance.new("TextBox")
inputBoxRef.Size = UDim2.new(1,-20,1,-14); inputBoxRef.Position = UDim2.new(0,10,0,7)
inputBoxRef.BackgroundColor3 = C.input; inputBoxRef.BorderSizePixel = 0
inputBoxRef.Font = Enum.Font.Code; inputBoxRef.TextSize = 13
inputBoxRef.TextColor3 = C.text; inputBoxRef.PlaceholderText = "type a message..."
inputBoxRef.PlaceholderColor3 = C.muted; inputBoxRef.Text = ""
inputBoxRef.ClearTextOnFocus = false; inputBoxRef.TextXAlignment = Enum.TextXAlignment.Left
inputBoxRef.Parent = inputCard
trackBg(inputBoxRef, "input"); trackText(inputBoxRef, "text")
corner(inputBoxRef, UDim.new(0,5)); stroke(inputBoxRef, "accentDim", 1)

sendBtnRef = Instance.new("TextButton")
sendBtnRef.Position = UDim2.new(0,12,0,74); sendBtnRef.Size = UDim2.new(0.6,-18,0,38)
sendBtnRef.BackgroundColor3 = C.accentDim; sendBtnRef.BackgroundTransparency = 0.12
sendBtnRef.BorderSizePixel = 0; sendBtnRef.AutoButtonColor = false
sendBtnRef.Font = Enum.Font.GothamBold; sendBtnRef.TextSize = 14
sendBtnRef.TextColor3 = C.text; sendBtnRef.Text = "SEND"
sendBtnRef.Parent = body
trackBg(sendBtnRef, "accentDim"); trackText(sendBtnRef, "text")
corner(sendBtnRef, UDim.new(0,9)); stroke(sendBtnRef, "accent", 1)

testBtnRef = Instance.new("TextButton")
testBtnRef.Position = UDim2.new(0.6,6,0,74); testBtnRef.Size = UDim2.new(0.4,-18,0,38)
testBtnRef.BackgroundColor3 = C.bg3; testBtnRef.BorderSizePixel = 0; testBtnRef.AutoButtonColor = false
testBtnRef.Font = Enum.Font.GothamBold; testBtnRef.TextSize = 13
testBtnRef.TextColor3 = C.accentBright; testBtnRef.Text = "TEST CODE"
testBtnRef.Parent = body
trackBg(testBtnRef, "bg3"); trackText(testBtnRef, "accentBright")
corner(testBtnRef, UDim.new(0,9)); stroke(testBtnRef, "accentDim", 1)

local function doSend(text)
    text = (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then
        notify("error","Empty message","type something first","✕",2.5); return
    end
    local ok, err = pcall(fire, text)
    if ok then notify("success","Sent", text, "✓", 2.5)
    else notify("error","Send failed", tostring(err), "✕", 3) end
end

sendBtnRef.MouseButton1Click:Connect(function() doSend(inputBoxRef.Text); inputBoxRef.Text = "" end)
inputBoxRef.FocusLost:Connect(function(enter) if enter then doSend(inputBoxRef.Text); inputBoxRef.Text = "" end end)
testBtnRef.MouseButton1Click:Connect(function() doSend("TESTCODE" .. tostring(math.random(1000, 9999))) end)

local function hoverBtn(btn, offSlot, primary)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, C.tweenFast, { BackgroundColor3 = C.toggleOn }):Play()
        if primary then TweenService:Create(btn, C.tweenFast, { BackgroundTransparency = 0 }):Play() end
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, C.tweenFast, { BackgroundColor3 = C[offSlot] }):Play()
        if primary then TweenService:Create(btn, C.tweenFast, { BackgroundTransparency = 0.12 }):Play() end
    end)
end
hoverBtn(sendBtnRef, "accentDim", true)
hoverBtn(testBtnRef, "bg3", false)

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1,-24,0,14); hint.Position = UDim2.new(0,12,1,-24)
hint.BackgroundTransparency = 1; hint.Font = Enum.Font.Code; hint.TextSize = 9
hint.TextColor3 = C.muted; hint.TextXAlignment = Enum.TextXAlignment.Left
hint.TextTruncate = Enum.TextTruncate.AtEnd
hint.Text = "firesignal · " .. tostring(remote.Name)
hint.Parent = body; trackText(hint, "muted")

mainFrame.Size = UDim2.new(0, MAIN_W - 40, 0, 40)
mainFrame.BackgroundTransparency = 1
task.wait()
TweenService:Create(mainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Size = UDim2.new(0, MAIN_W, 0, MAIN_H), BackgroundTransparency = 0.02 }):Play()

do
    local dragging, dragStart, startPos = false, nil, nil
    titleBarRef.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

applyUiScale()
notify("detect","Sender ready", "remote: " .. remote.Name, "●", 3)
print("[YahuSender] ready.")
]==]

--==================================================
-- SENDER LAUNCHER
--==================================================
local senderRunning = false
local function startSender()
    if senderRunning then return true end
    senderRunning = true
    local ok, err = pcall(function() loadstring(SENDER_SRC)() end)
    if not ok then
        senderRunning = false
        warn("[Yahu] Sender failed: " .. tostring(err))
        return false, tostring(err)
    end
    task.wait()
    if not PlayerGui:FindFirstChild("PhiYahuSender") then
        senderRunning = false
        return false, "Sender GUI not found (remote maybe missing)"
    end
    return true
end
local function stopSender()
    if not senderRunning then return true end
    senderRunning = false
    for _, n in ipairs({ "PhiYahuSender", "YahuSenderPopups" }) do
        local g = PlayerGui:FindFirstChild(n)
        if g then g:Destroy() end
    end
    return true
end

--==================================================
-- POPUPS (REDEEMER)
--==================================================
local popupGui, popupContainer, popupList = nil, nil, {}
local popupColors = {
    detect = Color3.fromRGB(255,215,115), assemble = Color3.fromRGB(255,215,115),
    success = Color3.fromRGB(105,235,160), soldout = Color3.fromRGB(255,190,60),
    error = Color3.fromRGB(255,105,125), info = Color3.fromRGB(238,247,249),
}
local POPUP_W = 300
local function getPopupScreenGui()
    if popupGui and popupGui.Parent then return popupGui end
    popupGui = Instance.new("ScreenGui")
    popupGui.Name = "YahuRedeemerPopups"; popupGui.ResetOnSpawn = false
    popupGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    popupGui.IgnoreGuiInset = true; popupGui.Parent = PlayerGui
    popupContainer = Instance.new("Frame"); popupContainer.Name = "Stack"
    popupContainer.BackgroundTransparency = 1; popupContainer.AnchorPoint = Vector2.new(1,1)
    popupContainer.Position = UDim2.new(1,-18,1,-60); popupContainer.Size = UDim2.new(0,POPUP_W,0,500)
    popupContainer.Parent = popupGui
    local l = Instance.new("UIListLayout")
    l.FillDirection = Enum.FillDirection.Vertical
    l.HorizontalAlignment = Enum.HorizontalAlignment.Right
    l.VerticalAlignment = Enum.VerticalAlignment.Bottom
    l.SortOrder = Enum.SortOrder.LayoutOrder; l.Padding = UDim.new(0,8); l.Parent = popupContainer
    return popupGui
end

local function reflowPopupOrders()
    for i, e in ipairs(popupList) do
        e.frame.LayoutOrder = i
        local depth = #popupList - i
        if e.frame then e.frame.BackgroundTransparency = math.clamp(0.08 + depth * 0.04, 0.08, 0.35) end
    end
end

local function killTimers(entry)
    if entry.timer then pcall(task.cancel, entry.timer); entry.timer = nil end
end

local function removePopup(entry)
    if not entry or entry.removing then return end
    entry.removing = true; killTimers(entry)
    for i, e in ipairs(popupList) do if e == entry then table.remove(popupList, i); break end end
    reflowPopupOrders()
    local outTween = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    TweenService:Create(entry.frame, outTween, {
        BackgroundTransparency = 1, Position = entry.frame.Position + UDim2.new(0, 40, 0, 0),
    }):Play()
    if entry.stroke then TweenService:Create(entry.stroke, outTween, { Transparency = 1 }):Play() end
    for _, child in ipairs(entry.frame:GetDescendants()) do
        if child:IsA("TextLabel") then TweenService:Create(child, outTween, { TextTransparency = 1 }):Play()
        elseif child:IsA("Frame") then TweenService:Create(child, outTween, { BackgroundTransparency = 1 }):Play()
        elseif child:IsA("UIStroke") then TweenService:Create(child, outTween, { Transparency = 1 }):Play() end
    end
    task.delay(0.32, function() entry.frame:Destroy() end)
end

local function scheduleDismiss(entry, duration)
    killTimers(entry)
    entry.timer = task.delay(duration, function() removePopup(entry) end)
end

local function notify(kind, title, subtitle, icon, duration)
    getPopupScreenGui()
    duration = duration or 3.5; icon = icon or "•"
    local accent = popupColors[kind] or popupColors.info
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,64)
    frame.BackgroundColor3 = C.bg2; frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0; frame.Position = UDim2.new(0,30,0,0)
    frame.ClipsDescendants = true; frame.Parent = popupContainer
    trackBg(frame, "bg2"); corner(frame, UDim.new(0,8))

    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1,4,1,4); shadow.Position = UDim2.new(0,2,0,3)
    shadow.BackgroundColor3 = Color3.fromRGB(0,0,0); shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0; shadow.ZIndex = 0; shadow.Parent = frame
    corner(shadow, UDim.new(0,10))

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,0,1,0); content.BackgroundTransparency = 1
    content.ZIndex = 1; content.Parent = frame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = accent; uiStroke.Thickness = 1.2
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.Transparency = 1; uiStroke.Parent = frame

    local iconBg = Instance.new("Frame")
    iconBg.Size = UDim2.new(0,32,0,32); iconBg.Position = UDim2.new(0,12,0,16)
    iconBg.BackgroundColor3 = accent; iconBg.BackgroundTransparency = 1
    iconBg.BorderSizePixel = 0; iconBg.Parent = content
    corner(iconBg, UDim.new(1,0))
    local iconStroke = Instance.new("UIStroke")
    iconStroke.Color = accent; iconStroke.Thickness = 1; iconStroke.Transparency = 1; iconStroke.Parent = iconBg
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1,0,1,0); iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBlack; iconLabel.TextSize = 16
    iconLabel.TextColor3 = accent; iconLabel.TextTransparency = 1
    iconLabel.Text = icon; iconLabel.Parent = iconBg

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1,-60,0,18); titleLabel.Position = UDim2.new(0,54,0,12)
    titleLabel.BackgroundTransparency = 1; titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13; titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    titleLabel.TextTransparency = 1; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = string.upper(title or ""); titleLabel.Parent = content

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(1,-60,0,22); 
    subtitleLabel.Position = UDim2.new(0,54,0,30); subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Font = Enum.Font.GothamMedium; subtitleLabel.TextSize = 12
    subtitleLabel.TextColor3 = Color3.fromRGB(200,200,210); subtitleLabel.TextTransparency = 1
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.TextYAlignment = Enum.TextYAlignment.Top
    subtitleLabel.TextWrapped = true; subtitleLabel.Text = subtitle or ""
    subtitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    subtitleLabel.Parent = content

    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1,-24,0,2); progressBg.Position = UDim2.new(0,12,1,-6)
    progressBg.BackgroundColor3 = Color3.fromRGB(80,80,90); progressBg.BackgroundTransparency = 0.5
    progressBg.BorderSizePixel = 0; progressBg.Parent = content
    corner(progressBg, UDim.new(1,0))
    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(1,0,1,0); progress.BackgroundColor3 = accent
    progress.BorderSizePixel = 0; progress.Parent = progressBg
    corner(progress, UDim.new(1,0))

    TweenService:Create(frame, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0,0,0,0), BackgroundTransparency = 0.08,
    }):Play()
    TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0,0,1,0) }):Play()
    TweenService:Create(uiStroke, TweenInfo.new(0.32), { Transparency = 0 }):Play()
    TweenService:Create(iconBg, TweenInfo.new(0.32), { BackgroundTransparency = 0.8 }):Play()
    TweenService:Create(iconStroke, TweenInfo.new(0.32), { Transparency = 0.3 }):Play()
    TweenService:Create(iconLabel, TweenInfo.new(0.32), { TextTransparency = 0 }):Play()
    TweenService:Create(titleLabel, TweenInfo.new(0.32), { TextTransparency = 0 }):Play()
    TweenService:Create(subtitleLabel, TweenInfo.new(0.32), { TextTransparency = 0 }):Play()

    local entry = { frame = frame, stroke = uiStroke, progress = progress, removing = false }
    table.insert(popupList, entry); reflowPopupOrders()
    scheduleDismiss(entry, duration)

    frame.MouseEnter:Connect(function()
        killTimers(entry)
    end)
    frame.MouseLeave:Connect(function()
        if not entry.removing then scheduleDismiss(entry, duration) end
    end)
    local dismissBtn = Instance.new("TextButton")
    dismissBtn.Size = UDim2.new(1,0,1,0); dismissBtn.BackgroundTransparency = 1
    dismissBtn.Text = ""; dismissBtn.ZIndex = 2; dismissBtn.Parent = content
    dismissBtn.MouseButton1Click:Connect(function() removePopup(entry) end)

    return entry
end

--==================================================
-- FORWARD DECLARATIONS
--==================================================
local logStatus, getMsgProgressText, updateMsgLabels
local updateSuccessCounter, updateCaptureCounter
local resetSequence, clearStatusLog, clearMiniConsole
local formatStopwatch, resetStopwatchText, resetMsgState
local submitCode, setLastFoundCode, handleWord
local dispatch, tryDispatch, watchObject, hookContainers
local cycleTheme, updateDelayLabel, stepDelay
local setPage, applyUiScale, setMinimized
local refreshFastUpvalues, resolveFastRefs, invalidateFastRefs, fastRedeem

--==================================================
-- STATE
--==================================================
local autoScan           = cfg.autoScan ~= false
local autoSubmit         = cfg.autoSubmit == true
local submitAfterCollect = cfg.submitAfterCollect == true
local uppercaseOnly      = cfg.uppercaseOnly == true
local delayMs = math.clamp(math.floor(tonumber(cfg.delayMs) or 0), 0, 5000)
local checkpointSet, checkpoints = {}, {}
for _, n in ipairs(cfg.checkpoints or {}) do
    local v = math.floor(tonumber(n) or 0); if v >= 1 and v <= 5 then checkpointSet[v] = true end
end
local function rebuildCheckpointList()
    checkpoints = {}
    for n = 1, 5 do if checkpointSet[n] then table.insert(checkpoints, n) end end
end
local function getMaxCheckpoint()
    local m = 0; for _, n in ipairs(checkpoints) do if n > m then m = n end end; return m
end
rebuildCheckpointList()
local triggerKeyword = tostring(cfg.triggerKeyword or "code is")
local triggerEnabled = cfg.triggerEnabled ~= false
local phase = "idle"
local collectBuf, wordCount = {}, 0
local lastFoundCode = ""
local successfullyExecuted = 0
local capturedNotifications = 0
local stopwatchStart, stopwatchLabel, stopwatchBox
local seen = {}
local statusScrollRef, miniStatusScrollRef
local statusLog = {}
local miniMsgLabel, mainMsgLabel

--==================================================
-- FAST REDEEM PATH
--==================================================
local fastRefs = { textBox=nil, clickSignal=nil, activatedSignal=nil, ready=false, resolving=false }
local fastTextBox, fastClickSignal, fastActivatedSignal
local fastActivatedOk = false
local firesignalChecked, firesignalWorks = false, false

function refreshFastUpvalues()
    fastTextBox = fastRefs.textBox; fastClickSignal = fastRefs.clickSignal
    fastActivatedSignal = fastRefs.activatedSignal; fastActivatedOk = fastActivatedSignal ~= nil
    if not firesignalChecked then
        firesignalChecked = true; firesignalWorks = typeof(firesignal) == "function"
    end
end

function resolveFastRefs()
    if fastRefs.ready or fastRefs.resolving then return end
    fastRefs.resolving = true
    task.spawn(function()
        local ok = pcall(function()
            local codesGui = PlayerGui:WaitForChild("Codes", 10); if not codesGui then return end
            local codes = codesGui:WaitForChild("Codes", 10); if not codes then return end
            local codeRedeem = codes:WaitForChild("CodeRedeem", 10); if not codeRedeem then return end
            local textBox = codeRedeem:WaitForChild("TextBox", 10)
            local confirmButton = codes:WaitForChild("Confirm", 10)
            if not textBox or not confirmButton then return end
            local button = confirmButton:FindFirstChildWhichIsA("TextButton") or confirmButton
            if not button then return end
            fastRefs.textBox = textBox; fastRefs.clickSignal = button.MouseButton1Click
            fastRefs.activatedSignal = button.Activated; fastRefs.ready = true
        end)
        if ok and fastRefs.ready then
            refreshFastUpvalues()
            if logStatus then logStatus("Fast redeem path ready", "gray") end
        end
        fastRefs.resolving = false
    end)
end

function invalidateFastRefs()
    fastRefs.textBox, fastRefs.clickSignal, fastRefs.activatedSignal = nil, nil, nil
    fastRefs.ready = false; fastTextBox, fastClickSignal, fastActivatedSignal = nil, nil, nil
    fastActivatedOk = false
end

function fastRedeem(code)
    if not fastRefs.ready then resolveFastRefs(); return false, "Fast path not ready yet" end
    if not firesignalWorks then return false, "firesignal is unavailable" end
    if not fastTextBox or not fastClickSignal then invalidateFastRefs(); return false, "Cached refs invalid" end
    fastTextBox.Text = code
    local clickOk = pcall(firesignal, fastClickSignal)
    local activatedOk = false
    if fastActivatedOk then activatedOk = pcall(firesignal, fastActivatedSignal) end
    if clickOk or activatedOk then return true end
    return false, "Unable to fire submit signals"
end

--==================================================
-- RF MODE
--==================================================
local useRemote    = cfg.rfMode == true
local RF_Event     = nil
local _rfDetecting = false
local rfToggleRef  = nil

local function classifyRFResponse(raw)
    local text = tostring(raw or ""); if text == "" then return "invalid", text end
    local lower = text:lower()
    for _, p in ipairs({ "sold out","soldout","sold-out","all codes","codes claimed","claim limit","no more","stock","out of stock","habis","terjual","sold" }) do
        if lower:find(p, 1, true) then return "soldout", text end end
    for _, p in ipairs({ "expired","expire","time is up","too late","kadaluarsa","kedaluwarsa" }) do
        if lower:find(p, 1, true) then return "expired", text end end
    for _, p in ipairs({ "cooldown","wait","slow down","too fast","try again","rate limit","spam" }) do
        if lower:find(p, 1, true) then return "cooldown", text end end
    for _, p in ipairs({ "invalid","not found","does not exist","unknown code","no such code","tidak ditemukan","salah","wrong" }) do
        if lower:find(p, 1, true) then return "invalid", text end end
    return "unknown", text
end

local function tryDetectRF(callback)
    if _rfDetecting then if callback then callback(RF_Event ~= nil and RF_Event.Parent ~= nil) end; return end
    if RF_Event and RF_Event.Parent then if callback then callback(true) end; return end
    if not hookmetamethod or not getnamecallmethod then if callback then callback(false) end; return end
    _rfDetecting = true
    task.spawn(function()
        local orig
        orig = hookmetamethod(game, "__namecall", function(self, ...)
            local m = getnamecallmethod()
            if m == "InvokeServer" and RF_Event == nil then
                if typeof(self) == "Instance" and self:IsA("RemoteFunction") and self.Name:sub(1,3) == "RF/" then
                    RF_Event = self; _G.YahuRFRemote = self
                end
            end
            return orig(self, ...)
        end)
        task.wait(0.15); pcall(submitCode, "YAHUPROBE"); task.wait(1.5)
        pcall(hookmetamethod, game, "__namecall", orig); _rfDetecting = false
        if RF_Event and RF_Event.Parent then logStatus("Detection complete. Cached RF: " .. tostring(RF_Event:GetFullName()), "green")
        else logStatus("Detection complete. No RF/ remote seen.", "red") end
        if callback then callback(RF_Event ~= nil and RF_Event.Parent ~= nil) end
    end)
end

local function submitCodeRemote(code)
    if not (RF_Event and RF_Event.Parent) then
        useRemote = false; cfg.rfMode = false; saveConfig()
        if rfToggleRef and rfToggleRef.set then rfToggleRef.set(false) end
        logStatus("Remote lost — disabled", "red"); notify("error","RF Mode","remote lost, disabled","✕",3)
        return false, "Remote not available", "invalid"
    end
    local ok, r1, r2 = pcall(function() return RF_Event:InvokeServer(code) end)
    if not ok then
        local e = tostring(r1 or "invoke error"); logStatus("Invoke error: " .. e, "red")
        notify("error","RF invoke error",e,"✕",3.5); return false, e, "invalid"
    end
    if r1 then logStatus("Redeemed: " .. code, "green"); notify("success","RF redeem OK",code,"✓",3); return true, nil, "success" end
    local raw = (type(r2) == "string" and r2 ~= "") and r2 or "unknown response"
    local kind = classifyRFResponse(raw)
    if kind == "soldout" then logStatus("SOLD OUT — "..code.." | "..raw,"yellow"); notify("soldout","SOLD OUT",raw,"⚠",5)
    elseif kind == "expired" then logStatus("EXPIRED — "..code.." | "..raw,"yellow"); notify("soldout","EXPIRED",raw,"⌛",4.5)
    elseif kind == "cooldown" then logStatus("COOLDOWN — "..code.." | "..raw,"red"); notify("error","COOLDOWN",raw,"◷",3.5)
    elseif kind == "invalid" then logStatus("INVALID — "..code.." | "..raw,"red"); notify("error","INVALID CODE",raw,"✕",3.5)
    else logStatus("FAILED — "..code.." | "..raw,"red"); notify("error","RF failed",raw,"✕",3.5) end
    return false, raw, kind
end

--==================================================
-- MSG / LOGGING
--==================================================
function getMsgProgressText()
    local total = getMaxCheckpoint(); if total <= 0 then return "MSG: –/–" end
    local current = 0; if phase == "collecting" then current = wordCount end
    if current < 0 then current = 0 end; if current > total then current = total end
    return "MSG: " .. tostring(current) .. "/" .. tostring(total)
end
function updateMsgLabels()
    local t = getMsgProgressText()
    if miniMsgLabel then miniMsgLabel.Text = t end
    if mainMsgLabel then mainMsgLabel.Text = t end
end
function updateSuccessCounter() if _G.YahuRedeemerSuccessLabel then _G.YahuRedeemerSuccessLabel.Text = tostring(successfullyExecuted) end end
function updateCaptureCounter() if _G.YahuRedeemerCaptureLabel then _G.YahuRedeemerCaptureLabel.Text = tostring(capturedNotifications) end end

local function makeStatusLabel(parent, entry, kind)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-12,0,0); l.AutomaticSize = Enum.AutomaticSize.Y
    l.BackgroundTransparency = 1; l.Font = Enum.Font.Code; l.TextSize = 13
    l.TextColor3 = LOG_COLOR[kind] or LOG_COLOR.gray
    l.TextXAlignment = Enum.TextXAlignment.Left; l.TextYAlignment = Enum.TextYAlignment.Top
    l.TextWrapped = true; l.RichText = false; l.Text = entry; l.Parent = parent
    return l
end

local function scrollToBottom(sf)
    task.defer(function()
        if sf then sf.CanvasPosition = Vector2.new(0, math.max(0, sf.AbsoluteCanvasSize.Y)) end
    end)
end

logStatus = function(message, kind)
    kind = kind or "gray"
    local entry = "[" .. os.date("%H:%M:%S") .. "] " .. tostring(message)
    table.insert(statusLog, { text = entry, kind = kind })
    print("[YAHU] " .. entry)
    task.defer(function()
        if statusScrollRef then makeStatusLabel(statusScrollRef, entry, kind); scrollToBottom(statusScrollRef) end
        if miniStatusScrollRef then makeStatusLabel(miniStatusScrollRef, entry, kind); scrollToBottom(miniStatusScrollRef) end
    end)
end

function resetSequence() phase = "idle"; collectBuf = {}; wordCount = 0; updateMsgLabels() end
function clearStatusLog()
    table.clear(statusLog)
    if statusScrollRef then
        for _, ch in ipairs(statusScrollRef:GetChildren()) do if ch:IsA("TextLabel") then ch:Destroy() end end
    end
    logStatus("Console cleared", "gray")
end
function formatStopwatch(ms)
    if type(ms) ~= "number" or ms ~= ms then ms = 0 end; if ms < 0 then ms = 0 end
    return string.format("STOPWATCH: %.2f ms", ms)
end
function resetStopwatchText()
    stopwatchStart = nil
    if stopwatchLabel then stopwatchLabel.Text = "STOPWATCH: 0.00 ms"; stopwatchLabel.TextColor3 = C.accentBright end
end
function resetMsgState() resetSequence(); resetStopwatchText(); logStatus("MSG state reset", "yellow") end
function clearMiniConsole()
    if miniStatusScrollRef then
        for _, ch in ipairs(miniStatusScrollRef:GetChildren()) do if ch:IsA("TextLabel") then ch:Destroy() end end
    end
end

local function isOwnedByUs(obj)
    local cur = obj; while cur and cur ~= game do if cur == screenGui then return true end; cur = cur.Parent end; return false
end
local function getText(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then return obj.Text end
end
local function matchesKeyword(text)
    if not text or text == "" then return false end
    if not triggerEnabled then return true end
    local kw = triggerKeyword; if kw == "" then return true end
    return text:lower():find(kw:lower(), 1, true) ~= nil
end
local function extractCode(text)
    if type(text) ~= "string" or text == "" then return "" end
    if uppercaseOnly then local f = (text:gsub("[^A-Z0-9]", "")); return f end
    return text
end

--==================================================
-- SUBMIT / DISPATCH
--==================================================
function submitCode(code)
    if code == nil or code == "" then return false, "Empty code" end
    if delayMs > 0 then task.wait(delayMs * 0.001) end
    if useRemote then
        local t0 = os.clock(); local ok, err, kind = submitCodeRemote(code); local t1 = os.clock()
        if ok then
            local ms = math.max(0, (t1 - t0) * 1000)
            if stopwatchLabel then stopwatchLabel.Text = formatStopwatch(ms) end
            successfullyExecuted = successfullyExecuted + 1; task.defer(updateSuccessCounter); return true
        end
        task.defer(function()
            logStatus("RF submission failed ("..tostring(kind or "unknown")..")"..(err and (": "..err) or ""),
                (kind == "soldout" or kind == "expired") and "yellow" or "red")
        end)
        return false, err
    end
    local t0 = os.clock(); local ok, err = fastRedeem(code); local t1 = os.clock()
    if ok then
        local ms = math.max(0, (t1 - t0) * 1000)
        if stopwatchLabel then stopwatchLabel.Text = formatStopwatch(ms) end
        stopwatchStart = nil; successfullyExecuted = successfullyExecuted + 1
        task.defer(function()
            updateSuccessCounter(); logStatus("Submission successful: "..code, "green")
            notify("success","Code redeemed successfully",code,"✓",3.5)
        end)
        return true
    end
    stopwatchStart = nil
    task.defer(function()
        logStatus("Submission failed"..(err and (": "..err) or ""), "red")
        notify("error","Code execution failed",err or "unknown error","✕",4.5)
    end)
    return false, err
end

function setLastFoundCode(code)
    if type(code) ~= "string" or code == "" then return end
    lastFoundCode = code; logStatus("Latest found code: "..lastFoundCode, "gray")
end

function handleWord(text)
    phase = "collecting"; table.insert(collectBuf, text); wordCount = wordCount + 1
    local joined = table.concat(collectBuf); local maxCP = getMaxCheckpoint()
    updateMsgLabels(); logStatus("Collected Word "..tostring(wordCount).."/"..tostring(maxCP), "purple")
    local should = submitAfterCollect or (wordCount >= maxCP)
    if should then
        logStatus("Submitting words 1.."..tostring(wordCount)..(submitAfterCollect and " (Submit After Collect ON)" or " (collection complete)"), "yellow")
        setLastFoundCode(joined); notify("assemble","Code assembled at word "..tostring(wordCount), joined, "◆", 2.5)
        if autoSubmit then submitCode(joined)
        else logStatus("Auto Submit is OFF","red"); notify("info","Code ready — Auto Submit is OFF",joined,"•",3.5) end
    end
    if wordCount >= maxCP then logStatus("Sequence complete at word "..tostring(wordCount).." → resetting","gray"); resetSequence() end
end

function dispatch(text)
    if not text or text == "" then return end
    if not autoScan then return end
    local filtered = extractCode(text); local has = filtered ~= ""
    capturedNotifications = capturedNotifications + 1; task.defer(updateCaptureCounter)
    if getMaxCheckpoint() > 0 then
        if not triggerEnabled then
            if not has then return end
            task.defer(function() if phase == "idle" then collectBuf = {}; wordCount = 0 end; handleWord(filtered) end); return
        end
        if phase == "collecting" then
            if not has then return end; task.defer(function() handleWord(filtered) end)
        elseif phase == "armed" then
            if not has then return end
            task.defer(function() collectBuf = {}; wordCount = 0; notify("detect","Word 1 detected",text,"●",2.5); handleWord(filtered) end)
        else
            if matchesKeyword(text) then
                phase = "armed"
                task.defer(function() updateMsgLabels(); logStatus("Trigger detected","blue"); logStatus("Waiting for Word 1","yellow"); notify("detect","Trigger detected — waiting for Word 1",text,"◉",2.5) end)
            end
        end; return
    end
    if not triggerEnabled then
        if not has then return end; setLastFoundCode(text); notify("detect","Code detected",text,"●",2.5)
        if autoSubmit then submitCode(filtered) else logStatus("Auto Submit is OFF","red"); notify("info","Code ready — Auto Submit is OFF",text,"•",3.5) end
        return
    end
    if matchesKeyword(text) then
        setLastFoundCode(text); logStatus("Trigger detected","blue"); notify("detect","Code detected",text,"●",2.5)
        if not has then return end
        if autoSubmit then submitCode(filtered) else logStatus("Auto Submit is OFF","red"); notify("info","Code ready — Auto Submit is OFF",text,"•",3.5) end
    end
end

local lastSeenText = {}
function tryDispatch(obj, text)
    if not text or text == "" then return end
    if lastSeenText[obj] == text then return end
    lastSeenText[obj] = text; logStatus("ND: "..text, "blue"); dispatch(text)
end
function watchObject(obj)
    if seen[obj] then return end; if isOwnedByUs(obj) then return end
    seen[obj] = true
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        if obj.Text and obj.Text ~= "" then task.defer(function() tryDispatch(obj, obj.Text) end) end
        obj:GetPropertyChangedSignal("Text"):Connect(function() if isOwnedByUs(obj) then return end; tryDispatch(obj, obj.Text) end)
    end
    for _, c in ipairs(obj:GetDescendants()) do watchObject(c) end
    obj.DescendantAdded:Connect(function(c)
        if isOwnedByUs(c) then return end
        local was = seen[c]; watchObject(c)
        if not was and getText(c) and c.Text ~= "" then task.defer(function() tryDispatch(c, c.Text) end) end
    end)
    obj.Destroying:Connect(function() lastSeenText[obj] = nil; for _, c in ipairs(obj:GetDescendants()) do lastSeenText[c] = nil end end)
end
function hookContainers()
    local names = { "TopNotification" }
    for _, n in ipairs(names) do local e = PlayerGui:FindFirstChild(n); if e then watchObject(e) end end
    PlayerGui.ChildAdded:Connect(function(c) for _, n in ipairs(names) do if c.Name == n then watchObject(c) end end end)
    logStatus("Notification watcher connected","gray")
end

--==================================================
-- UI FOUNDATION
--==================================================
local TITLE_H   = 52
local SIDEBAR_W = 100
local MAIN_W    = 460
local MAIN_H    = 540

local screenGui, scaleWrapper, uiScaleRef
local mainFrame, sidebarFrame, contentFrame
local pageFrames = {}
local navButtons, navBars = {}, {}
local themeValueRef, scaleValueRef
local delayValueRef
local triggerBoxRef
local checkpointButtonsRef = {}
local minBtnRef, titleBarRef

local function bindToggleTrack(track, knob, getState, onSlot, offSlot)
    local function slot()
        return getState() and (onSlot or "toggleOn") or (offSlot or "toggleOff")
    end
    local function refresh() reg.bg[track] = slot() end
    refresh()
    return refresh
end

local function makeToggleRow(parent, order, labelText, getValue, setValue, onToggle)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,50); row.BackgroundColor3 = C.bg2
    row.BorderSizePixel = 0; row.LayoutOrder = order; row.Parent = parent
    trackBg(row, "bg2"); corner(row, UDim.new(0,9)); stroke(row, "accentDim", 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-80,1,0); lbl.Position = UDim2.new(0,13,0,0); lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 15; lbl.TextColor3 = C.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Text = labelText; lbl.Parent = row
    trackText(lbl, "text")

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0,46,0,24); track.AnchorPoint = Vector2.new(1,0.5)
    track.Position = UDim2.new(1,-12,0.5,0); track.BackgroundColor3 = getValue() and C.toggleOn or C.toggleOff
    track.BorderSizePixel = 0; track.Parent = row; corner(track, UDim.new(1,0))

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,20,0,20)
    knob.Position = getValue() and UDim2.new(0,24,0.5,-10) or UDim2.new(0,2,0.5,-10)
    knob.BackgroundColor3 = C.knob; knob.BorderSizePixel = 0; knob.Parent = track; corner(knob, UDim.new(1,0))

    local refreshTrackSlot = bindToggleTrack(track, knob, getValue)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = row

    local function applyVisual(v)
        TweenService:Create(track, C.tweenFast, { BackgroundColor3 = v and C.toggleOn or C.toggleOff }):Play()
        TweenService:Create(knob, C.tweenFast, {
            Position = v and UDim2.new(0,24,0.5,-10) or UDim2.new(0,2,0.5,-10) }):Play()
        refreshTrackSlot()
    end

    btn.MouseButton1Click:Connect(function()
        local nextV = not getValue()
        setValue(nextV); applyVisual(nextV)
        if onToggle then onToggle(nextV) end
    end)

    return { row = row, track = track, knob = knob, apply = applyVisual, refreshSlot = refreshTrackSlot }
end

local function makeNavButton(order, labelText)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-12,0,38); btn.LayoutOrder = order; btn.BackgroundColor3 = C.bg2
    btn.BackgroundTransparency = 1; btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; btn.TextColor3 = C.muted
    btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Text = "   "..labelText
    btn.Parent = sidebarFrame; trackBg(btn, "bg2"); trackText(btn, "muted"); corner(btn, UDim.new(0,6))
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0,3,0.7,0); bar.Position = UDim2.new(0,0,0.15,0)
    bar.BackgroundColor3 = C.accent; bar.BorderSizePixel = 0; bar.Visible = false
    bar.Parent = btn; corner(bar, UDim.new(1,0)); trackBg(bar, "accent")
    navBars[order] = bar; navButtons[order] = btn
    btn.MouseEnter:Connect(function()
        if cfg.activeTab ~= order then
            TweenService:Create(btn, C.tweenFast, { BackgroundTransparency = 0.4 }):Play()
            TweenService:Create(btn, C.tweenFast, { BackgroundColor3 = C.bg2 }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if cfg.activeTab ~= order then
            TweenService:Create(btn, C.tweenFast, { BackgroundTransparency = 1 }):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function() setPage(order) end)
    return btn
end

local function makePage(parent, order)
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1,-18,1,-18); sf.Position = UDim2.new(0,9,0,9)
    sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0; sf.ScrollBarThickness = 4
    sf.ScrollBarImageColor3 = C.accent; sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.CanvasSize = UDim2.new(0,0,0,0); sf.ScrollingDirection = Enum.ScrollingDirection.Y
    sf.LayoutOrder = order; sf.Visible = false; sf.Parent = parent; trackScroll(sf)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0,4); p.PaddingRight = UDim.new(0,4)
    p.PaddingTop = UDim.new(0,4); p.PaddingBottom = UDim.new(0,12); p.Parent = sf
    local l = Instance.new("UIListLayout")
    l.FillDirection = Enum.FillDirection.Vertical; l.Padding = UDim.new(0,9)
    l.SortOrder = Enum.SortOrder.LayoutOrder; l.Parent = sf
    return sf
end

local function makeCard(parent, order, height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,0,0,height or 60); card.BackgroundColor3 = C.bg2
    card.BorderSizePixel = 0; card.LayoutOrder = order; card.Parent = parent
    trackBg(card, "bg2"); corner(card, UDim.new(0,9)); stroke(card, "accentDim", 1)
    return card
end

--==================================================
-- BUILD ROOT
--==================================================
do
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YahuRedeemer"; screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; screenGui.Parent = PlayerGui

    scaleWrapper = Instance.new("Frame"); scaleWrapper.Name = "Scaler"
    scaleWrapper.BackgroundTransparency = 1; scaleWrapper.BorderSizePixel = 0
    scaleWrapper.Size = UDim2.new(1,0,1,0); scaleWrapper.Parent = screenGui

    uiScaleRef = Instance.new("UIScale"); uiScaleRef.Scale = cfg.uiScale or 0.9
    uiScaleRef.Parent = scaleWrapper

    mainFrame = Instance.new("Frame"); mainFrame.Name = "Main"
    mainFrame.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
    mainFrame.Position = UDim2.new(0.5, cfg.posX, 0.5, cfg.posY)
    mainFrame.BackgroundColor3 = C.bg1; mainFrame.BackgroundTransparency = 0.02
    mainFrame.BorderSizePixel = 0; mainFrame.Active = true; mainFrame.Parent = scaleWrapper
    mainFrame.ClipsDescendants = true
    trackBg(mainFrame, "bg1"); corner(mainFrame, UDim.new(0,12)); stroke(mainFrame, "accentDim", 1.2)

    titleBarRef = Instance.new("Frame")
    titleBarRef.Size = UDim2.new(1,0,0,TITLE_H); titleBarRef.BackgroundColor3 = C.bg0
    titleBarRef.BorderSizePixel = 0; titleBarRef.Active = true; titleBarRef.Parent = mainFrame
    trackBg(titleBarRef, "bg0"); corner(titleBarRef, UDim.new(0,12))

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1,-80,0,24); titleLbl.Position = UDim2.new(0,15,0,6)
    titleLbl.BackgroundTransparency = 1; titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.TextSize = 18; titleLbl.TextColor3 = C.accentBright
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.Text = "Yahu Redeemer"
    titleLbl.Parent = titleBarRef; trackText(titleLbl, "accentBright")

    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(1,-80,0,14); subLbl.Position = UDim2.new(0,16,0,28)
    subLbl.BackgroundTransparency = 1; subLbl.Font = Enum.Font.GothamMedium
    subLbl.TextSize = 9; subLbl.TextColor3 = C.muted
    subLbl.TextXAlignment = Enum.TextXAlignment.Left; subLbl.Text = "AUTOMATIC CODE SUBMISSION"
    subLbl.Parent = titleBarRef; trackText(subLbl, "muted")

    minBtnRef = Instance.new("TextButton")
    minBtnRef.Size = UDim2.new(0,30,0,24); minBtnRef.AnchorPoint = Vector2.new(1,0.5)
    minBtnRef.Position = UDim2.new(1,-10,0.5,0); minBtnRef.BackgroundColor3 = C.bg3
    minBtnRef.BorderSizePixel = 0; minBtnRef.AutoButtonColor = false
    minBtnRef.Font = Enum.Font.GothamBlack; minBtnRef.TextSize = 17
    minBtnRef.TextColor3 = C.accentBright; minBtnRef.Text = "–"; minBtnRef.Parent = titleBarRef
    trackBg(minBtnRef, "bg3"); trackText(minBtnRef, "accentBright")
    corner(minBtnRef, UDim.new(0,6)); stroke(minBtnRef, "accentDim", 1)

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1,-20,0,1); line.Position = UDim2.new(0,10,1,-1)
    line.BackgroundColor3 = C.accent; line.BackgroundTransparency = 0.25
    line.BorderSizePixel = 0; line.Parent = titleBarRef; trackBg(line, "accent")

    sidebarFrame = Instance.new("Frame")
    sidebarFrame.Position = UDim2.new(0,0,0,TITLE_H); sidebarFrame.Size = UDim2.new(0,SIDEBAR_W,1,-TITLE_H)
    sidebarFrame.BackgroundColor3 = C.bg0; sidebarFrame.BackgroundTransparency = 0.15
    sidebarFrame.BorderSizePixel = 0; sidebarFrame.Parent = mainFrame; trackBg(sidebarFrame, "bg0")
    local sbPad = Instance.new("UIPadding")
    sbPad.PaddingLeft = UDim.new(0,6); sbPad.PaddingRight = UDim.new(0,6)
    sbPad.PaddingTop = UDim.new(0,10); sbPad.PaddingBottom = UDim.new(0,10); sbPad.Parent = sidebarFrame
    local sbLay = Instance.new("UIListLayout")
    sbLay.FillDirection = Enum.FillDirection.Vertical; sbLay.Padding = UDim.new(0,6)
    sbLay.SortOrder = Enum.SortOrder.LayoutOrder; sbLay.Parent = sidebarFrame

    contentFrame = Instance.new("Frame")
    contentFrame.Position = UDim2.new(0, SIDEBAR_W, 0, TITLE_H)
    contentFrame.Size = UDim2.new(1,-SIDEBAR_W,1,-TITLE_H)
    contentFrame.BackgroundTransparency = 1; contentFrame.Parent = mainFrame

    pageFrames[1] = makePage(contentFrame, 1)
    pageFrames[2] = makePage(contentFrame, 2)
    pageFrames[3] = makePage(contentFrame, 3)
    pageFrames[4] = makePage(contentFrame, 4)

    makeNavButton(1, "Dashboard"); makeNavButton(2, "RF MODE")
    makeNavButton(3, "Console");   makeNavButton(4, "Settings")
end

--==================================================
-- PAGE / SCALE / MINIMIZE / DRAG
--==================================================
setPage = function(id)
    id = math.clamp(tonumber(id) or 1, 1, 4)
    cfg.activeTab = id; saveConfig()
    for i = 1, 4 do
        local active = (i == id)
        local btn, bar, page = navButtons[i], navBars[i], pageFrames[i]
        if btn then
            TweenService:Create(btn, C.tweenFast, {
                BackgroundColor3 = active and C.accentDim or C.bg2,
                BackgroundTransparency = active and 0.15 or 1,
                TextColor3 = active and C.accentBright or C.muted }):Play()
            reg.bg[btn] = active and "accentDim" or "bg2"
            reg.text[btn] = active and "accentBright" or "muted"
        end
        if bar then bar.Visible = active end
        if page then page.Visible = active end
    end
end

applyUiScale = function()
    local s = math.clamp(cfg.uiScale or 0.9, 0.5, 1.2)
    cfg.uiScale = s
    if uiScaleRef then uiScaleRef.Scale = s end
    if scaleValueRef then scaleValueRef.Text = string.format("%.0f%%", s * 100) end
    saveConfig()
end

setMinimized = function(v)
    cfg.minimized = v and true or false
    if mainFrame then
        TweenService:Create(mainFrame, C.tweenMed,
            { Size = UDim2.new(0, MAIN_W, 0, v and TITLE_H or MAIN_H) }):Play()
    end
    if sidebarFrame then sidebarFrame.Visible = not v end
    if contentFrame then contentFrame.Visible = not v end
    if minBtnRef then minBtnRef.Text = v and "+" or "–" end
    saveConfig()
end

minBtnRef.MouseButton1Click:Connect(function() setMinimized(not cfg.minimized) end)

-- Drag
do
    local dragging, dragStart, startPos = false, nil, nil
    titleBarRef.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    cfg.posX = mainFrame.Position.X.Offset
                    cfg.posY = mainFrame.Position.Y.Offset
                    saveConfig()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

--==================================================
-- DASHBOARD
--==================================================
do
    local page = pageFrames[1]

    -- Delay
    local delayRow = makeCard(page, 0, 50)
    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(0,80,1,0); dl.Position = UDim2.new(0,13,0,0); dl.BackgroundTransparency = 1
    dl.Font = Enum.Font.GothamBold; dl.TextSize = 15; dl.TextColor3 = C.text
    dl.TextXAlignment = Enum.TextXAlignment.Left; dl.Text = "Delay"; dl.Parent = delayRow
    trackText(dl, "text")

    local dvBox = Instance.new("Frame")
    dvBox.Size = UDim2.new(0,100,0,26); dvBox.AnchorPoint = Vector2.new(1,0.5)
    dvBox.Position = UDim2.new(1,-80,0.5,0); dvBox.BackgroundColor3 = C.bg3
    dvBox.BorderSizePixel = 0; dvBox.Parent = delayRow
    trackBg(dvBox, "bg3"); corner(dvBox, UDim.new(0,5)); stroke(dvBox, "accentDim", 1)

    delayValueRef = Instance.new("TextLabel")
    delayValueRef.Size = UDim2.new(1,-10,1,0); delayValueRef.Position = UDim2.new(0,5,0,0)
    delayValueRef.BackgroundTransparency = 1; delayValueRef.Font = Enum.Font.Code
    delayValueRef.TextSize = 12; delayValueRef.TextColor3 = C.accentBright
    delayValueRef.TextXAlignment = Enum.TextXAlignment.Center
    delayValueRef.TextYAlignment = Enum.TextYAlignment.Center
    delayValueRef.Text = "DELAY: "..tostring(delayMs).." ms"; delayValueRef.Parent = dvBox
    trackText(delayValueRef, "accentBright")

    local leftBtn = Instance.new("TextButton")
    leftBtn.Size = UDim2.new(0,26,0,26); leftBtn.AnchorPoint = Vector2.new(1,0.5)
    leftBtn.Position = UDim2.new(1,-38,0.5,0); leftBtn.BackgroundColor3 = C.bg3
    leftBtn.BorderSizePixel = 0; leftBtn.AutoButtonColor = false
    leftBtn.Font = Enum.Font.GothamBlack; leftBtn.TextSize = 16
    leftBtn.TextColor3 = C.accentBright; leftBtn.Text = "◀"; leftBtn.Parent = delayRow
    trackBg(leftBtn, "bg3"); trackText(leftBtn, "accentBright")
    corner(leftBtn, UDim.new(0,5)); stroke(leftBtn, "accentDim", 1)

    local rightBtn = Instance.new("TextButton")
    rightBtn.Size = UDim2.new(0,26,0,26); rightBtn.AnchorPoint = Vector2.new(1,0.5)
    rightBtn.Position = UDim2.new(1,-8,0.5,0); rightBtn.BackgroundColor3 = C.bg3
    rightBtn.BorderSizePixel = 0; rightBtn.AutoButtonColor = false
    rightBtn.Font = Enum.Font.GothamBlack; rightBtn.TextSize = 16
    rightBtn.TextColor3 = C.accentBright; rightBtn.Text = "▶"; rightBtn.Parent = delayRow
    trackBg(rightBtn, "bg3"); trackText(rightBtn, "accentBright")
    corner(rightBtn, UDim.new(0,5)); stroke(rightBtn, "accentDim", 1)

    local DELAY_STEPS = { 0,50,100,250,500,1000 }
    local function nearest(cur)
        local bi, bd = 1, math.abs(DELAY_STEPS[1]-cur)
        for i=2,#DELAY_STEPS do local d = math.abs(DELAY_STEPS[i]-cur); if d<bd then bd=d; bi=i end end
        return bi
    end
    function updateDelayLabel()
        if delayValueRef then delayValueRef.Text = "DELAY: "..tostring(delayMs).." ms" end
    end
    function stepDelay(dir)
        local i = nearest(delayMs)
        local n = DELAY_STEPS[math.clamp(dir>0 and i+1 or i-1, 1, #DELAY_STEPS)]
        if n ~= delayMs then delayMs = n; cfg.delayMs = n; updateDelayLabel(); saveConfig()
            logStatus("Delay set to "..n.." ms", "gray") end
    end
    leftBtn.MouseButton1Click:Connect(function() stepDelay(-1) end)
    rightBtn.MouseButton1Click:Connect(function() stepDelay(1) end)

    -- MSG
    local msgRow = makeCard(page, 1, 48)
    miniMsgLabel = Instance.new("TextLabel")
    miniMsgLabel.Size = UDim2.new(0,90,1,0); miniMsgLabel.Position = UDim2.new(0,13,0,0)
    miniMsgLabel.BackgroundTransparency = 1; miniMsgLabel.Font = Enum.Font.GothamBold
    miniMsgLabel.TextSize = 15; miniMsgLabel.TextColor3 = C.green
    miniMsgLabel.TextXAlignment = Enum.TextXAlignment.Left
    miniMsgLabel.TextYAlignment = Enum.TextYAlignment.Center
    miniMsgLabel.Text = getMsgProgressText(); miniMsgLabel.Parent = msgRow
    trackText(miniMsgLabel, "green")

    stopwatchBox = Instance.new("Frame")
    stopwatchBox.Size = UDim2.new(0,130,0,26); stopwatchBox.Position = UDim2.new(0,105,0.5,-13)
    stopwatchBox.BackgroundColor3 = C.bg3; stopwatchBox.BorderSizePixel = 0
    stopwatchBox.Parent = msgRow
    trackBg(stopwatchBox, "bg3"); corner(stopwatchBox, UDim.new(0,5)); stroke(stopwatchBox, "accentDim", 1)

    stopwatchLabel = Instance.new("TextLabel")
    stopwatchLabel.Size = UDim2.new(1,-10,1,0); stopwatchLabel.Position = UDim2.new(0,5,0,0)
    stopwatchLabel.BackgroundTransparency = 1; stopwatchLabel.Font = Enum.Font.Code
    stopwatchLabel.TextSize = 12; stopwatchLabel.TextColor3 = C.accentBright
    stopwatchLabel.TextXAlignment = Enum.TextXAlignment.Center
    stopwatchLabel.TextYAlignment = Enum.TextYAlignment.Center
    stopwatchLabel.Text = "STOPWATCH: 0.00 ms"; stopwatchLabel.Parent = stopwatchBox
    trackText(stopwatchLabel, "accentBright")

    local msgClr = Instance.new("TextButton")
    msgClr.Size = UDim2.new(0,58,0,30); msgClr.AnchorPoint = Vector2.new(1,0.5)
    msgClr.Position = UDim2.new(1,-12,0.5,0); msgClr.BackgroundColor3 = C.bg3
    msgClr.BorderSizePixel = 0; msgClr.AutoButtonColor = false
    msgClr.Font = Enum.Font.GothamBold; msgClr.TextSize = 13
    msgClr.TextColor3 = C.red; msgClr.Text = "CLR"; msgClr.Parent = msgRow
    trackBg(msgClr, "bg3"); trackText(msgClr, "red")
    corner(msgClr, UDim.new(0,6)); stroke(msgClr, "accentDim", 1)
    msgClr.MouseButton1Click:Connect(function() resetMsgState() end)

    -- Force Submit
    local forceRow = Instance.new("Frame")
    forceRow.Size = UDim2.new(1,0,0,52); forceRow.BackgroundColor3 = C.accentDim
    forceRow.BackgroundTransparency = 0.12; forceRow.LayoutOrder = 2; forceRow.Parent = page
    trackBg(forceRow, "accentDim"); corner(forceRow, UDim.new(0,9)); stroke(forceRow, "accent", 1)

    local forceBtn = Instance.new("TextButton")
    forceBtn.Size = UDim2.new(1,0,1,0); forceBtn.BackgroundTransparency = 1
    forceBtn.AutoButtonColor = false; forceBtn.Font = Enum.Font.GothamBold
    forceBtn.TextSize = 16; forceBtn.TextColor3 = C.text
    forceBtn.Text = "Force Submit"; forceBtn.Parent = forceRow
    trackText(forceBtn, "text")
    forceBtn.MouseEnter:Connect(function()
        TweenService:Create(forceRow, C.tweenFast, { BackgroundColor3 = C.toggleOn }):Play()
    end)
    forceBtn.MouseLeave:Connect(function()
        TweenService:Create(forceRow, C.tweenFast, { BackgroundColor3 = C.accentDim }):Play()
    end)
    forceBtn.MouseButton1Click:Connect(function()
        local payload = nil
        if phase == "collecting" and #collectBuf > 0 then payload = table.concat(collectBuf)
        elseif lastFoundCode ~= "" then payload = lastFoundCode end
        if not payload or payload == "" then
            logStatus("Force Submit failed — no code yet","red")
            notify("error","Force Submit failed","no code found yet","✕",3.5); return
        end
        logStatus("Force Submit → "..payload,"blue"); notify("info","Force Submit",payload,"➤",2.5)
        submitCode(payload)
    end)

    -- Toggles
    makeToggleRow(page, 3, "Auto Scan",
        function() return autoScan end,
        function(v) autoScan = v; cfg.autoScan = v; saveConfig() end,
        function(v) resetSequence(); logStatus("Auto Scan: "..(v and "ON" or "OFF"), v and "green" or "red") end)

    makeToggleRow(page, 4, "Auto Submit",
        function() return autoSubmit end,
        function(v) autoSubmit = v; cfg.autoSubmit = v; saveConfig() end,
        function(v) logStatus("Auto Submit: "..(v and "ON" or "OFF"), v and "green" or "red") end)

    makeToggleRow(page, 5, "Submit After Collect",
        function() return submitAfterCollect end,
        function(v) submitAfterCollect = v; cfg.submitAfterCollect = v; saveConfig() end,
        function(v) logStatus("Submit After Collect: "..(v and "ON" or "OFF"), v and "green" or "red") end)

    -- Checkpoints
    local cpRow = makeCard(page, 6, 72)
    local cpTitle = Instance.new("TextLabel")
    cpTitle.Size = UDim2.new(1,-24,0,20); cpTitle.Position = UDim2.new(0,13,0,8)
    cpTitle.BackgroundTransparency = 1; cpTitle.Font = Enum.Font.GothamBold
    cpTitle.TextSize = 14; cpTitle.TextColor3 = C.text
    cpTitle.TextXAlignment = Enum.TextXAlignment.Left; cpTitle.Text = "Submit After"; cpTitle.Parent = cpRow
    trackText(cpTitle, "text")

    local checkRow = Instance.new("Frame")
    checkRow.Size = UDim2.new(1,-24,0,32); checkRow.Position = UDim2.new(0,12,0,32)
    checkRow.BackgroundTransparency = 1; checkRow.Parent = cpRow
    local cl = Instance.new("UIListLayout")
    cl.FillDirection = Enum.FillDirection.Horizontal; cl.Padding = UDim.new(0,6)
    cl.SortOrder = Enum.SortOrder.LayoutOrder
    cl.HorizontalAlignment = Enum.HorizontalAlignment.Left
    cl.VerticalAlignment = Enum.VerticalAlignment.Center; cl.Parent = checkRow

    local function setCheckpoint(n, enabled, silent)
        if enabled then checkpointSet[n] = true else checkpointSet[n] = nil end
        rebuildCheckpointList()
        cfg.checkpoints = {}
        for _, v in ipairs(checkpoints) do table.insert(cfg.checkpoints, v) end
        updateMsgLabels(); saveConfig()
        local b = checkpointButtonsRef[n]
        if b then
            TweenService:Create(b, C.tweenFast, { BackgroundColor3 = enabled and C.toggleOn or C.bg3 }):Play()
            b.TextColor3 = enabled and C.knob or C.muted
            reg.bg[b] = enabled and "toggleOn" or "bg3"
            reg.text[b] = enabled and "knob" or "muted"
        end
        if not silent then logStatus("Checkpoint "..n..": "..(enabled and "ON" or "OFF"), "gray") end
    end

    for i = 1, 5 do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,56,0,28); b.LayoutOrder = i
        b.BackgroundColor3 = checkpointSet[i] and C.toggleOn or C.bg3
        b.BorderSizePixel = 0; b.AutoButtonColor = false; b.Font = Enum.Font.GothamBold
        b.TextSize = 13; b.TextColor3 = checkpointSet[i] and C.knob or C.muted
        b.Text = tostring(i); b.Parent = checkRow; corner(b, UDim.new(0,6))
        trackBg(b, checkpointSet[i] and "toggleOn" or "bg3")
        trackText(b, checkpointSet[i] and "knob" or "muted")
        checkpointButtonsRef[i] = b
        b.MouseButton1Click:Connect(function()
            setCheckpoint(i, not (checkpointSet[i] == true), false)
        end)
    end

    -- Trigger toggle
    makeToggleRow(page, 7, "Trigger",
        function() return triggerEnabled end,
        function(v) triggerEnabled = v; cfg.triggerEnabled = v; saveConfig() end,
        function(v) logStatus("Trigger: "..(v and "ON" or "OFF"), v and "green" or "red") end)

    -- Keyword
    local kwRow = makeCard(page, 8, 56)
    local kwLbl = Instance.new("TextLabel")
    kwLbl.Size = UDim2.new(0,80,1,0); kwLbl.Position = UDim2.new(0,13,0,0); kwLbl.BackgroundTransparency = 1
    kwLbl.Font = Enum.Font.GothamBold; kwLbl.TextSize = 15; kwLbl.TextColor3 = C.text
    kwLbl.TextXAlignment = Enum.TextXAlignment.Left; kwLbl.Text = "Keyword"; kwLbl.Parent = kwRow
    trackText(kwLbl, "text")

    local kwBox = Instance.new("TextBox")
    kwBox.Size = UDim2.new(0,200,0,30); kwBox.AnchorPoint = Vector2.new(1,0.5)
    kwBox.Position = UDim2.new(1,-12,0.5,0); kwBox.BackgroundColor3 = C.input
    kwBox.BorderSizePixel = 0; kwBox.Font = Enum.Font.Code; kwBox.TextSize = 12
    kwBox.TextColor3 = C.text; kwBox.PlaceholderText = "trigger phrase"
    kwBox.PlaceholderColor3 = C.muted; kwBox.Text = triggerKeyword
    kwBox.ClearTextOnFocus = false; kwBox.Parent = kwRow
    trackBg(kwBox, "input"); trackText(kwBox, "text")
    corner(kwBox, UDim.new(0,5)); stroke(kwBox, "accentDim", 1)
    triggerBoxRef = kwBox
    kwBox.FocusLost:Connect(function()
        triggerKeyword = kwBox.Text; cfg.triggerKeyword = triggerKeyword; saveConfig()
        logStatus("Trigger keyword: \""..triggerKeyword.."\"", "gray")
    end)

    -- Uppercase Only
    makeToggleRow(page, 9, "Uppercase Only",
        function() return uppercaseOnly end,
        function(v) uppercaseOnly = v; cfg.uppercaseOnly = v; saveConfig() end,
        function(v) logStatus("Uppercase Only: "..(v and "ON" or "OFF"), v and "green" or "red") end)
end

--==================================================
-- REDEEMER
--==================================================
do
    local page = pageFrames[2]

    local rfCard = makeCard(page, 0, 64)
    local rfTitle = Instance.new("TextLabel")
    rfTitle.Size = UDim2.new(1,-120,0,20); rfTitle.Position = UDim2.new(0,12,0,8)
    rfTitle.BackgroundTransparency = 1; rfTitle.Font = Enum.Font.GothamBold
    rfTitle.TextSize = 14; rfTitle.TextColor3 = C.text
    rfTitle.TextXAlignment = Enum.TextXAlignment.Left; rfTitle.Text = "RF Mode"
    rfTitle.Parent = rfCard; trackText(rfTitle, "text")

    local rfDesc = Instance.new("TextLabel")
    rfDesc.Size = UDim2.new(1,-120,0,28); rfDesc.Position = UDim2.new(0,12,0,28)
    rfDesc.BackgroundTransparency = 1; rfDesc.Font = Enum.Font.Code
    rfDesc.TextSize = 10; rfDesc.TextColor3 = C.muted
    rfDesc.TextXAlignment = Enum.TextXAlignment.Left; rfDesc.TextWrapped = true
    rfDesc.Text = "Route submissions through RemoteFunction."
    rfDesc.Parent = rfCard; trackText(rfDesc, "muted")

    local rfTrack = Instance.new("TextButton")
    rfTrack.Size = UDim2.new(0,48,0,24); rfTrack.AnchorPoint = Vector2.new(1,0.5)
    rfTrack.Position = UDim2.new(1,-14,0.5,0)
    rfTrack.BackgroundColor3 = cfg.rfMode and C.toggleOn or C.toggleOff
    rfTrack.BorderSizePixel = 0; rfTrack.AutoButtonColor = false; rfTrack.Text = ""
    rfTrack.Parent = rfCard
    corner(rfTrack, UDim.new(1,0))

    local rfKnob = Instance.new("Frame")
    rfKnob.Size = UDim2.new(0,18,0,18)
    rfKnob.Position = cfg.rfMode and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
    rfKnob.BackgroundColor3 = C.knob; rfKnob.BorderSizePixel = 0; rfKnob.Parent = rfTrack
    corner(rfKnob, UDim.new(1,0))

    local refreshRfSlot = bindToggleTrack(rfTrack, rfKnob, function() return cfg.rfMode end)

    local function syncRF()
        rfTrack.BackgroundColor3 = cfg.rfMode and C.toggleOn or C.toggleOff
        TweenService:Create(rfKnob, C.tweenFast, {
            Position = cfg.rfMode and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9) }):Play()
        refreshRfSlot()
    end
    rfToggleRef = { set = function(v)
        cfg.rfMode = v and true or false; useRemote = cfg.rfMode; saveConfig(); syncRF() end }

    rfTrack.MouseButton1Click:Connect(function()
        cfg.rfMode = not cfg.rfMode; useRemote = cfg.rfMode; saveConfig(); syncRF()
        logStatus("RF Mode "..(cfg.rfMode and "enabled" or "disabled"), "gray")
        if cfg.rfMode then tryDetectRF(nil) end
    end)
    syncRF()

    local detCard = makeCard(page, 1, 64)
    local detTitle = Instance.new("TextLabel")
    detTitle.Size = UDim2.new(1,-120,0,20); detTitle.Position = UDim2.new(0,12,0,8)
    detTitle.BackgroundTransparency = 1; detTitle.Font = Enum.Font.GothamBold
    detTitle.TextSize = 14; detTitle.TextColor3 = C.text
    detTitle.TextXAlignment = Enum.TextXAlignment.Left; detTitle.Text = "Remote Detection"
    detTitle.Parent = detCard; trackText(detTitle, "text")

    local detDesc = Instance.new("TextLabel")
    detDesc.Size = UDim2.new(1,-120,0,28); detDesc.Position = UDim2.new(0,12,0,28)
    detDesc.BackgroundTransparency = 1; detDesc.Font = Enum.Font.Code
    detDesc.TextSize = 10; detDesc.TextColor3 = C.muted
    detDesc.TextXAlignment = Enum.TextXAlignment.Left; detDesc.TextWrapped = true
    detDesc.Text = "MAY BE DETECTED SOME DAY USE AT YOUR OWN RISK AND MAY BE SLOWER OR FASTER."
    detDesc.Parent = detCard; trackText(detDesc, "muted")

    local detBtn = Instance.new("TextButton")
    detBtn.Size = UDim2.new(0,80,0,26); detBtn.AnchorPoint = Vector2.new(1,0.5)
    detBtn.Position = UDim2.new(1,-14,0.5,0); detBtn.BackgroundColor3 = C.bg3
    detBtn.BorderSizePixel = 0; detBtn.AutoButtonColor = false
    detBtn.Font = Enum.Font.GothamBold; detBtn.TextSize = 11
    detBtn.TextColor3 = C.accentBright; detBtn.Text = "Detect"; detBtn.Parent = detCard
    trackBg(detBtn, "bg3"); trackText(detBtn, "accentBright")
    corner(detBtn, UDim.new(0,6)); stroke(detBtn, "accentDim", 1)
    detBtn.MouseButton1Click:Connect(function() logStatus("RF detection requested","blue"); tryDetectRF(nil) end)
end

--==================================================
-- CONSOLE
--==================================================
do
    local page = pageFrames[3]
    local topCard = makeCard(page, 0, 44)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(0.5,0,1,0); t.Position = UDim2.new(0,12,0,0); t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold; t.TextSize = 14; t.TextColor3 = C.accentBright
    t.TextXAlignment = Enum.TextXAlignment.Left; t.Text = "Full Console"; t.Parent = topCard
    trackText(t, "accentBright")

    local clr = Instance.new("TextButton")
    clr.Size = UDim2.new(0,58,0,26); clr.AnchorPoint = Vector2.new(1,0.5)
    clr.Position = UDim2.new(1,-12,0.5,0); clr.BackgroundColor3 = C.bg3
    clr.BorderSizePixel = 0; clr.AutoButtonColor = false
    clr.Font = Enum.Font.GothamBold; clr.TextSize = 12
    clr.TextColor3 = C.red; clr.Text = "CLR"; clr.Parent = topCard
    trackBg(clr, "bg3"); trackText(clr, "red")
    corner(clr, UDim.new(0,6)); stroke(clr, "accentDim", 1)
    clr.MouseButton1Click:Connect(function() clearStatusLog() end)

    local body = Instance.new("Frame")
    body.BackgroundColor3 = C.bg0; body.BackgroundTransparency = 0.1
    body.BorderSizePixel = 0; body.LayoutOrder = 1
    body.Size = UDim2.new(1,0,0,360); body.Parent = page
    trackBg(body, "bg0"); corner(body, UDim.new(0,9)); stroke(body, "accentDim", 1)

    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1,-16,1,-16); sf.Position = UDim2.new(0,8,0,8)
    sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 4; sf.ScrollBarImageColor3 = C.accent
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.CanvasSize = UDim2.new(0,0,0,0); sf.ScrollingDirection = Enum.ScrollingDirection.Y
    sf.Parent = body; trackScroll(sf)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0,4); p.PaddingRight = UDim.new(0,4)
    p.PaddingTop = UDim.new(0,4); p.PaddingBottom = UDim.new(0,4); p.Parent = sf
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0,4); l.SortOrder = Enum.SortOrder.LayoutOrder; l.Parent = sf
    statusScrollRef = sf
    for _, e in ipairs(statusLog) do makeStatusLabel(sf, e.text, e.kind) end
end

--==================================================
-- SETTINGS
--==================================================
do
    local page = pageFrames[4]

    local appear = makeCard(page, 0, 108)
    local aTitle = Instance.new("TextLabel")
    aTitle.Size = UDim2.new(1,-24,0,20); aTitle.Position = UDim2.new(0,12,0,8)
    aTitle.BackgroundTransparency = 1; aTitle.Font = Enum.Font.GothamBold
    aTitle.TextSize = 13; aTitle.TextColor3 = C.accentBright
    aTitle.TextXAlignment = Enum.TextXAlignment.Left; aTitle.Text = "Appearance"; aTitle.Parent = appear
    trackText(aTitle, "accentBright")

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(0,80,0,22); tLbl.Position = UDim2.new(0,12,0,36)
    tLbl.BackgroundTransparency = 1; tLbl.Font = Enum.Font.GothamBold
    tLbl.TextSize = 13; tLbl.TextColor3 = C.text; tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Text = "Theme"; tLbl.Parent = appear; trackText(tLbl, "text")

    themeValueRef = Instance.new("TextLabel")
    themeValueRef.Size = UDim2.new(0,110,0,22); themeValueRef.Position = UDim2.new(0,90,0,36)
    themeValueRef.BackgroundTransparency = 1; themeValueRef.Font = Enum.Font.Code
    themeValueRef.TextSize = 12; themeValueRef.TextColor3 = C.accentBright
    themeValueRef.TextXAlignment = Enum.TextXAlignment.Left; themeValueRef.Text = cfg.themeKey
    themeValueRef.Parent = appear; trackText(themeValueRef, "accentBright")

    local themeBtn = Instance.new("TextButton")
    themeBtn.Size = UDim2.new(0,80,0,22); themeBtn.AnchorPoint = Vector2.new(1,0)
    themeBtn.Position = UDim2.new(1,-12,0,36); themeBtn.BackgroundColor3 = C.bg3
    themeBtn.BorderSizePixel = 0; themeBtn.AutoButtonColor = false
    themeBtn.Font = Enum.Font.GothamBold; themeBtn.TextSize = 11
    themeBtn.TextColor3 = C.accentBright; themeBtn.Text = "Cycle"; themeBtn.Parent = appear
    trackBg(themeBtn, "bg3"); trackText(themeBtn, "accentBright")
    corner(themeBtn, UDim.new(0,6)); stroke(themeBtn, "accentDim", 1)

    cycleTheme = function()
        local idx = 1
        for i, k in ipairs(THEME_ORDER) do if k == cfg.themeKey then idx = i; break end end
        local n = THEME_ORDER[(idx % #THEME_ORDER) + 1]
        applyThemeInstant(n); saveConfig()
        if themeValueRef then themeValueRef.Text = n end
        repaintAll()
        setPage(cfg.activeTab)  -- resync nav highlight after palette swap
        logStatus("Theme: "..n, "gray")
    end
    themeBtn.MouseButton1Click:Connect(function() cycleTheme() end)

    local sLbl = Instance.new("TextLabel")
    sLbl.Size = UDim2.new(0,80,0,22); sLbl.Position = UDim2.new(0,12,0,72)
    sLbl.BackgroundTransparency = 1; sLbl.Font = Enum.Font.GothamBold
    sLbl.TextSize = 13; sLbl.TextColor3 = C.text; sLbl.TextXAlignment = Enum.TextXAlignment.Left
    sLbl.Text = "UI Scale"; sLbl.Parent = appear; trackText(sLbl, "text")

    scaleValueRef = Instance.new("TextLabel")
    scaleValueRef.Size = UDim2.new(0,110,0,22); scaleValueRef.Position = UDim2.new(0,90,0,72)
    scaleValueRef.BackgroundTransparency = 1; scaleValueRef.Font = Enum.Font.Code
    scaleValueRef.TextSize = 12; scaleValueRef.TextColor3 = C.accentBright
    scaleValueRef.TextXAlignment = Enum.TextXAlignment.Left
    scaleValueRef.Text = string.format("%.0f%%", (cfg.uiScale or 0.9) * 100)
    scaleValueRef.Parent = appear; trackText(scaleValueRef, "accentBright")

    local SCALE_STEPS = { 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2 }
    local function stepScale(dir)
        local cur = cfg.uiScale or 0.9
        local bi, bd = 1, math.abs(SCALE_STEPS[1] - cur)
        for i=2,#SCALE_STEPS do local d = math.abs(SCALE_STEPS[i]-cur); if d<bd then bd=d; bi=i end end
        local ni = math.clamp(dir > 0 and bi + 1 or bi - 1, 1, #SCALE_STEPS)
        cfg.uiScale = SCALE_STEPS[ni]; applyUiScale()
    end

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0,26,0,22); minus.AnchorPoint = Vector2.new(1,0)
    minus.Position = UDim2.new(1,-94,0,72); minus.BackgroundColor3 = C.bg3
    minus.BorderSizePixel = 0; minus.AutoButtonColor = false
    minus.Font = Enum.Font.GothamBlack; minus.TextSize = 14
    minus.TextColor3 = C.accentBright; minus.Text = "−"; minus.Parent = appear
    trackBg(minus, "bg3"); trackText(minus, "accentBright")
    corner(minus, UDim.new(0,6)); stroke(minus, "accentDim", 1)
    minus.MouseButton1Click:Connect(function() stepScale(-1) end)

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0,26,0,22); plus.AnchorPoint = Vector2.new(1,0)
    plus.Position = UDim2.new(1,-62,0,72); plus.BackgroundColor3 = C.bg3
    plus.BorderSizePixel = 0; plus.AutoButtonColor = false
    plus.Font = Enum.Font.GothamBlack; plus.TextSize = 14
    plus.TextColor3 = C.accentBright; plus.Text = "+"; plus.Parent = appear
    trackBg(plus, "bg3"); trackText(plus, "accentBright")
    corner(plus, UDim.new(0,6)); stroke(plus, "accentDim", 1)
    plus.MouseButton1Click:Connect(function() stepScale(1) end)

    -- CONFIG CARD
    local configCard = makeCard(page, 1, 70)
    local cT = Instance.new("TextLabel")
    cT.Size = UDim2.new(1,-24,0,20); cT.Position = UDim2.new(0,12,0,8)
    cT.BackgroundTransparency = 1; cT.Font = Enum.Font.GothamBold
    cT.TextSize = 13; cT.TextColor3 = C.accentBright
    cT.TextXAlignment = Enum.TextXAlignment.Left; cT.Text = "Configuration"
    cT.Parent = configCard; trackText(cT, "accentBright")

    local cV = Instance.new("TextLabel")
    cV.Size = UDim2.new(1,-24,0,20); cV.Position = UDim2.new(0,12,0,30)
    cV.BackgroundTransparency = 1; cV.Font = Enum.Font.Code; cV.TextSize = 11
    cV.TextColor3 = C.text; cV.TextXAlignment = Enum.TextXAlignment.Left
    cV.Text = "RF Mode: "..(cfg.rfMode and "ON" or "OFF"); cV.Parent = configCard
    trackText(cV, "text")

    local orig = setPage
    setPage = function(id)
        orig(id)
        if cV and cV.Parent then cV.Text = "RF Mode: "..(cfg.rfMode and "ON" or "OFF") end
    end

    -- YAHU SENDER CARD (Smooth Toggle)
    local senderRow = makeCard(page, 2, 72)
    local sndTitle = Instance.new("TextLabel")
    sndTitle.Size = UDim2.new(1,-120,0,20); sndTitle.Position = UDim2.new(0,12,0,8)
    sndTitle.BackgroundTransparency = 1; sndTitle.Font = Enum.Font.GothamBold
    sndTitle.TextSize = 14; sndTitle.TextColor3 = C.text
    sndTitle.TextXAlignment = Enum.TextXAlignment.Left; sndTitle.Text = "Yahu Sender"
    sndTitle.Parent = senderRow; trackText(sndTitle, "text")

    local sndDesc = Instance.new("TextLabel")
    sndDesc.Size = UDim2.new(1,-120,0,32); sndDesc.Position = UDim2.new(0,12,0,28)
    sndDesc.BackgroundTransparency = 1; sndDesc.Font = Enum.Font.Code
    sndDesc.TextSize = 10; sndDesc.TextColor3 = C.muted
    sndDesc.TextXAlignment = Enum.TextXAlignment.Left; sndDesc.TextWrapped = true
    sndDesc.Text = "Broadcasts notifications to the server."
    sndDesc.Parent = senderRow; trackText(sndDesc, "muted")

    local sndTrack = Instance.new("Frame")
    sndTrack.Size = UDim2.new(0,48,0,24); sndTrack.AnchorPoint = Vector2.new(1,0.5)
    sndTrack.Position = UDim2.new(1,-14,0.5,0)
    sndTrack.BackgroundColor3 = cfg.senderEnabled and C.toggleOn or C.toggleOff
    sndTrack.BorderSizePixel = 0; sndTrack.Parent = senderRow
    corner(sndTrack, UDim.new(1,0))

    local sndKnob = Instance.new("Frame")
    sndKnob.Size = UDim2.new(0,18,0,18)
    sndKnob.Position = cfg.senderEnabled and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
    sndKnob.BackgroundColor3 = C.knob; sndKnob.BorderSizePixel = 0; sndKnob.Parent = sndTrack
    corner(sndKnob, UDim.new(1,0))

    local refreshSenderSlot = bindToggleTrack(sndTrack, sndKnob, function() return cfg.senderEnabled end)

    local function syncSender()
        sndTrack.BackgroundColor3 = cfg.senderEnabled and C.toggleOn or C.toggleOff
        TweenService:Create(sndKnob, C.tweenFast, {
            Position = cfg.senderEnabled and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9) }):Play()
        refreshSenderSlot()
    end
    syncSender()

    local sndBtn = Instance.new("TextButton")
    sndBtn.Size = UDim2.new(1,0,1,0); sndBtn.BackgroundTransparency = 1; sndBtn.Text = ""; sndBtn.Parent = senderRow

    sndBtn.MouseButton1Click:Connect(function()
        cfg.senderEnabled = not cfg.senderEnabled; saveConfig(); syncSender()
        if cfg.senderEnabled then
            local ok, err = startSender()
            if ok then
                logStatus("Yahu Sender: ON", "green")
            else
                cfg.senderEnabled = false; saveConfig(); syncSender()
                logStatus("Yahu Sender: failed — " .. tostring(err), "red")
                notify("error", "Sender Failed", tostring(err), "X", 4)
            end
        else
            stopSender()
            logStatus("Yahu Sender: OFF", "gray")
        end
    end)
end

--==================================================
-- BOOT
--==================================================
if cfg.minimized then
    mainFrame.Size = UDim2.new(0, MAIN_W, 0, TITLE_H)
    sidebarFrame.Visible = false
    contentFrame.Visible = false
    minBtnRef.Text = "+"
end

applyUiScale()
setPage(cfg.activeTab or 1)

task.defer(function()
    resolveFastRefs()
    hookContainers()
    if cfg.senderEnabled then startSender() end
    logStatus("Interface ready", "green")
end)
