--[[
    WindUI Hub — Performance Monitor + Player Stats
    Автор: сгенерировано на основе WindUI by Footagesus
    Требует: WindUI (загружается автоматически)
]]

local RunService   = game:GetService("RunService")
local Players      = game:GetService("Players")
local Stats        = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local HttpService  = game:GetService("HttpService")

local cloneref = (cloneref or clonereference or function(i) return i end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

-- ════════════════════════════════════════════
--  Загрузка WindUI
-- ════════════════════════════════════════════
local WindUI
do
    local ok, result = pcall(function() return require("./src/Init") end)
    if ok then
        WindUI = result
    else
        if cloneref(RunService):IsStudio() then
            WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

-- ════════════════════════════════════════════
--  Вспомогательные переменные
-- ════════════════════════════════════════════
local LocalPlayer  = Players.LocalPlayer
local Camera       = workspace.CurrentCamera

-- Цвета
local Green  = Color3.fromHex("#10C550")
local Blue   = Color3.fromHex("#257AF7")
local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Red    = Color3.fromHex("#EF4F1D")
local Grey   = Color3.fromHex("#83889E")
local Cyan   = Color3.fromHex("#00D4FF")

-- ════════════════════════════════════════════
--  Счётчик FPS (скользящее среднее 60 кадров)
-- ════════════════════════════════════════════
local FPS_SAMPLES = 60
local fpsBuf, fpsBufIdx, fpsSum = {}, 1, 0
for i = 1, FPS_SAMPLES do fpsBuf[i] = 60 end
fpsSum = 60 * FPS_SAMPLES

local currentFPS = 60
local lastT = tick()

RunService.Heartbeat:Connect(function()
    local now = tick()
    local dt  = now - lastT
    lastT = now
    if dt <= 0 then return end

    local sample = math.clamp(1 / dt, 0, 1000)
    fpsSum = fpsSum - fpsBuf[fpsBufIdx] + sample
    fpsBuf[fpsBufIdx] = sample
    fpsBufIdx = (fpsBufIdx % FPS_SAMPLES) + 1
    currentFPS = fpsSum / FPS_SAMPLES
end)

-- ════════════════════════════════════════════
--  Утилиты
-- ════════════════════════════════════════════
local function getPing()
    return math.floor(Stats.Network.ServerStatsItem["Data Ping"].Value)
end

local function getMemoryMB()
    return math.floor(Stats:GetTotalMemoryUsageMb())
end

local function getFPS()
    return math.floor(currentFPS)
end

local function getPlayerPos()
    local char = LocalPlayer.Character
    if not char then return "—" end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return "—" end
    local p = root.Position
    return string.format("X:%.1f  Y:%.1f  Z:%.1f", p.X, p.Y, p.Z)
end

local function getPlayerSpeed()
    local char = LocalPlayer.Character
    if not char then return 0 end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return 0 end
    return math.floor(root.Velocity.Magnitude)
end

local function getHealth()
    local char = LocalPlayer.Character
    if not char then return 0, 100 end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return 0, 100 end
    return math.floor(hum.Health), math.floor(hum.MaxHealth)
end

local function getWalkSpeed()
    local char = LocalPlayer.Character
    if not char then return 16 end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return 16 end
    return math.floor(hum.WalkSpeed)
end

local function getJumpPower()
    local char = LocalPlayer.Character
    if not char then return 50 end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return 50 end
    return math.floor(hum.JumpPower)
end

local function fpsColor(fps)
    if fps >= 55 then return Green
    elseif fps >= 30 then return Yellow
    else return Red end
end

local function pingColor(ping)
    if ping < 80 then return Green
    elseif ping < 150 then return Yellow
    else return Red end
end

-- ════════════════════════════════════════════
--  Создание окна
-- ════════════════════════════════════════════
local Window = WindUI:CreateWindow({
    Title       = "Performance Hub",
    Folder      = "PerfHub",
    Icon        = "activity",
    NewElements = true,
    HideSearchBar = false,

    OpenButton = {
        Title        = "📊 Perf Hub",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled      = true,
        Draggable    = true,
        OnlyMobile   = false,
        Scale        = 0.5,
        Color        = ColorSequence.new(
            Color3.fromHex("#00D4FF"),
            Color3.fromHex("#7775F2")
        ),
    },

    Topbar = {
        Height      = 44,
        ButtonsType = "Mac",
    },
})

-- Кнопка закрытия клавишей
Window:SetToggleKey(Enum.KeyCode.RightShift)

-- Версия тег
Window:Tag({
    Title  = "v1.0",
    Icon   = "activity",
    Color  = Color3.fromHex("#1c1c1c"),
    Border = true,
})

-- ════════════════════════════════════════════
--  Секции
-- ════════════════════════════════════════════
local StatsSection   = Window:Section({ Title = "Мониторинг" })
local PlayerSection  = Window:Section({ Title = "Игрок" })
local SettingsSection= Window:Section({ Title = "Настройки" })

-- ════════════════════════════════════════════
--  ТАБ: FPS & Сеть
-- ════════════════════════════════════════════
do
    local PerfTab = StatsSection:Tab({
        Title     = "FPS & Сеть",
        Icon      = "activity",
        IconColor = Green,
        Border    = true,
    })

    -- ── Live-метки (обновляются каждый кадр) ──
    local fpsLabel  = PerfTab:Section({ Title = "FPS: —",  TextSize = 28, FontWeight = Enum.FontWeight.Bold })
    local pingLabel = PerfTab:Section({ Title = "Пинг: —", TextSize = 22 })
    local memLabel  = PerfTab:Section({ Title = "ОЗУ: — MB",TextSize = 22 })

    PerfTab:Space({ Columns = 2 })

    -- История FPS (последние 30 значений)
    local fpsHistory = {}
    local fpsHistoryLabel = PerfTab:Section({
        Title = "История FPS (последние 30 сек):",
        TextSize = 14,
        TextTransparency = 0.4,
    })

    local historyText = PerfTab:Section({
        Title = "",
        TextSize = 13,
        TextTransparency = 0.3,
    })

    PerfTab:Space()

    -- Статус соединения
    local connStatus = PerfTab:Section({ Title = "Статус: —", TextSize = 16 })

    -- Интервал обновления
    local updateInterval = 0.5
    local elapsed = 0
    local historyElapsed = 0
    local histBuf = {}

    RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        historyElapsed = historyElapsed + dt

        if elapsed >= updateInterval then
            elapsed = 0

            local fps  = getFPS()
            local ping = getPing()
            local mem  = getMemoryMB()

            -- Обновляем заголовки секций через pcall (они могут быть уничтожены)
            pcall(function()
                local fpsStr  = string.format("FPS: %d", fps)
                local pingStr = string.format("Пинг: %d мс", ping)
                local memStr  = string.format("ОЗУ: %d МБ", mem)

                -- WindUI не даёт напрямую менять Title у Section после создания,
                -- поэтому используем Desc (описание) если доступно, иначе пересоздаём.
                -- Workaround: обновляем через RichText если поддерживается,
                -- иначе просто выводим в консоль (для отладки).
                -- Настоящий вывод — через Notify или через Label-элементы.

                -- Попытка через rawset объекта
                if fpsLabel and fpsLabel.SetTitle then
                    fpsLabel:SetTitle(fpsStr)
                elseif fpsLabel and fpsLabel.TitleLabel then
                    fpsLabel.TitleLabel.Text = fpsStr
                end
                if pingLabel and pingLabel.SetTitle then
                    pingLabel:SetTitle(pingStr)
                elseif pingLabel and pingLabel.TitleLabel then
                    pingLabel.TitleLabel.Text = pingStr
                end
                if memLabel and memLabel.SetTitle then
                    memLabel:SetTitle(memStr)
                elseif memLabel and memLabel.TitleLabel then
                    memLabel.TitleLabel.Text = memStr
                end

                -- Статус соединения
                local statusStr
                if ping < 80 then
                    statusStr = "✅ Соединение: Отличное"
                elseif ping < 150 then
                    statusStr = "⚠️ Соединение: Нормальное"
                else
                    statusStr = "❌ Соединение: Плохое"
                end
                if connStatus and connStatus.TitleLabel then
                    connStatus.TitleLabel.Text = statusStr
                end
            end)
        end

        -- История FPS раз в секунду
        if historyElapsed >= 1 then
            historyElapsed = 0
            table.insert(histBuf, getFPS())
            if #histBuf > 30 then table.remove(histBuf, 1) end

            pcall(function()
                local bars = ""
                for _, v in ipairs(histBuf) do
                    if v >= 55 then bars = bars .. "█"
                    elseif v >= 30 then bars = bars .. "▓"
                    else bars = bars .. "░" end
                end
                if historyText and historyText.TitleLabel then
                    historyText.TitleLabel.Text = bars
                end
            end)
        end
    end)

    -- Кнопка — скопировать stats
    PerfTab:Space()
    PerfTab:Button({
        Title   = "Скопировать статистику",
        Icon    = "copy",
        Justify = "Center",
        Callback = function()
            local fps  = getFPS()
            local ping = getPing()
            local mem  = getMemoryMB()
            local text = string.format(
                "FPS: %d | Пинг: %d мс | ОЗУ: %d МБ | Игра: %s | Игрок: %s",
                fps, ping, mem,
                game.Name or "Roblox",
                LocalPlayer.Name
            )
            if setclipboard then
                setclipboard(text)
                WindUI:Notify({
                    Title   = "Скопировано!",
                    Content = text,
                    Icon    = "check",
                    Duration = 4,
                })
            end
        end,
    })
end

-- ════════════════════════════════════════════
--  ТАБ: Игрок
-- ════════════════════════════════════════════
do
    local PlayerTab = PlayerSection:Tab({
        Title     = "Игрок",
        Icon      = "user",
        IconColor = Blue,
        Border    = true,
    })

    -- Информация об аккаунте
    local infoSection = PlayerTab:Section({
        Title = "Информация об аккаунте",
        Box   = true,
        BoxBorder = true,
        Opened = true,
    })

    infoSection:Section({ Title = "👤 " .. LocalPlayer.Name, TextSize = 20, FontWeight = Enum.FontWeight.Bold })
    infoSection:Section({ Title = "🆔 UserID: " .. tostring(LocalPlayer.UserId), TextSize = 15, TextTransparency = 0.3 })
    infoSection:Section({ Title = "🎭 DisplayName: " .. LocalPlayer.DisplayName, TextSize = 15, TextTransparency = 0.3 })

    -- Подробности игры
    infoSection:Space()
    infoSection:Section({ Title = "🎮 " .. (game.Name or "Roblox"), TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })
    infoSection:Section({ Title = "📋 PlaceID: " .. tostring(game.PlaceId), TextSize = 14, TextTransparency = 0.4 })
    infoSection:Section({ Title = "🌐 JobID: " .. tostring(game.JobId):sub(1,18) .. "...", TextSize = 13, TextTransparency = 0.4 })

    PlayerTab:Space()

    -- Живые показатели персонажа
    local charSection = PlayerTab:Section({
        Title = "Персонаж",
        Box   = true,
        BoxBorder = true,
        Opened = true,
    })

    local hpLabel    = charSection:Section({ Title = "❤️ HP: — / —",     TextSize = 16 })
    local speedLabel = charSection:Section({ Title = "🏃 Скорость: —",    TextSize = 15, TextTransparency = 0.2 })
    local posLabel   = charSection:Section({ Title = "📍 Позиция: —",     TextSize = 14, TextTransparency = 0.3 })
    local wsLabel    = charSection:Section({ Title = "🦵 WalkSpeed: —",   TextSize = 14, TextTransparency = 0.3 })
    local jpLabel    = charSection:Section({ Title = "⬆️ JumpPower: —",   TextSize = 14, TextTransparency = 0.3 })

    RunService.Heartbeat:Connect(function()
        pcall(function()
            local hp, maxhp = getHealth()
            local speed = getPlayerSpeed()
            local pos   = getPlayerPos()
            local ws    = getWalkSpeed()
            local jp    = getJumpPower()

            if hpLabel and hpLabel.TitleLabel then
                hpLabel.TitleLabel.Text    = string.format("❤️ HP: %d / %d", hp, maxhp)
            end
            if speedLabel and speedLabel.TitleLabel then
                speedLabel.TitleLabel.Text = string.format("🏃 Скорость: %d", speed)
            end
            if posLabel and posLabel.TitleLabel then
                posLabel.TitleLabel.Text   = "📍 " .. pos
            end
            if wsLabel and wsLabel.TitleLabel then
                wsLabel.TitleLabel.Text    = string.format("🦵 WalkSpeed: %d", ws)
            end
            if jpLabel and jpLabel.TitleLabel then
                jpLabel.TitleLabel.Text    = string.format("⬆️ JumpPower: %d", jp)
            end
        end)
    end)

    PlayerTab:Space()

    -- Кнопки действий
    local actionsSection = PlayerTab:Section({
        Title = "Действия",
        Box   = true,
        BoxBorder = true,
        Opened = true,
    })

    local wsSlider = actionsSection:Slider({
        Title = "WalkSpeed",
        Step  = 1,
        Value = { Min = 0, Max = 500, Default = 16 },
        Callback = function(v)
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end,
    })

    actionsSection:Space()

    local jpSlider = actionsSection:Slider({
        Title = "JumpPower",
        Step  = 1,
        Value = { Min = 0, Max = 500, Default = 50 },
        Callback = function(v)
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = v end
        end,
    })

    actionsSection:Space()

    actionsSection:Button({
        Title   = "Сбросить персонажа",
        Icon    = "refresh-cw",
        Color   = Red,
        Justify = "Center",
        Callback = function()
            LocalPlayer:LoadCharacter()
        end,
    })

    actionsSection:Space()

    actionsSection:Button({
        Title   = "Телепорт в Спавн",
        Icon    = "map-pin",
        Justify = "Center",
        Callback = function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
            if spawn then
                root.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
            else
                root.CFrame = CFrame.new(0, 10, 0)
            end
        end,
    })
end

-- ════════════════════════════════════════════
--  ТАБ: Настройки
-- ════════════════════════════════════════════
do
    local SettingsTab = SettingsSection:Tab({
        Title     = "Настройки",
        Icon      = "settings",
        IconColor = Purple,
        Border    = true,
    })

    SettingsTab:Toggle({
        Title = "Показать фон панели",
        Value = not Window.HidePanelBackground,
        Callback = function(v)
            Window:SetPanelBackground(v)
        end,
    })

    SettingsTab:Space()

    SettingsTab:Keybind({
        Title = "Клавиша открытия",
        Value = "RightShift",
        Callback = function(v)
            local ok, key = pcall(function() return Enum.KeyCode[v] end)
            if ok and key then
                Window:SetToggleKey(key)
            end
        end,
    })

    SettingsTab:Space()

    SettingsTab:Dropdown({
        Title  = "Тема интерфейса",
        Values = { "Default", "Dark", "Mellowsi", "Rose", "Ocean" },
        Value  = "Default",
        Callback = function(theme)
            pcall(function() Window:SetTheme(theme) end)
        end,
    })

    SettingsTab:Space()

    SettingsTab:Button({
        Title   = "Уничтожить GUI",
        Icon    = "trash-2",
        Color   = Red,
        Justify = "Center",
        Callback = function()
            Window:Destroy()
        end,
    })

    SettingsTab:Space()

    SettingsTab:Section({
        Title = "Горячие клавиши:\nRightShift — открыть/закрыть GUI",
        TextSize = 13,
        TextTransparency = 0.4,
    })
end

-- ════════════════════════════════════════════
--  Уведомление при запуске
-- ════════════════════════════════════════════
task.delay(1.5, function()
    WindUI:Notify({
        Title    = "Performance Hub",
        Content  = "Привет, " .. LocalPlayer.DisplayName .. "! GUI загружен. RightShift — открыть/закрыть.",
        Icon     = "activity",
        Duration = 6,
    })
end)
