-- ============================================================
--  Rayfield — Полноценный GUI (Secure Mode)
--  Документация: https://docs.sirius.menu/rayfield
-- ============================================================

-- Secure Mode: блокирует все детектируемые ассеты Roblox
getgenv().RAYFIELD_SECURE    = true
getgenv().RAYFIELD_ASSET_ID  = 123456789   -- Замените на свой re-uploaded model ID

-- Загрузка библиотеки
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ============================================================
--  ОКНО
-- ============================================================

local Window = Rayfield:CreateWindow({
    Name             = "My Hub",
    Icon             = 0,                          -- 0 = без иконки; строка Lucide или число Roblox image ID
    LoadingTitle     = "My Hub — Loading",
    LoadingSubtitle  = "Пожалуйста, подождите...",
    ShowText         = "My Hub",                   -- текст кнопки для мобильных

    Theme            = "Default",                  -- Default / AmberGlow / Bloom / Dark / etc.
    ToggleUIKeybind  = "RightCtrl",                -- клавиша показа/скрытия GUI

    DisableRayfieldPrompts  = false,
    DisableBuildWarnings    = false,

    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "MyHub",       -- папка в executor filesystem
        FileName   = "MyHubConfig"  -- имя файла конфига
    },

    Discord = {
        Enabled      = false,
        Invite       = "ABCD1234",  -- discord.gg/ABCD1234
        RememberJoins = true
    },

    KeySystem = false,  -- true — включить систему ключей
    KeySettings = {
        Title    = "My Hub — Key System",
        Subtitle = "Введите ключ для доступа",
        Note     = "Получите ключ на нашем Discord-сервере",
        FileName = "MyHubKey",
        SaveKey  = true,
        GrabKeyFromSite = false,
        Key      = {"myhub-2024"}
    }
})

-- ============================================================
--  ТАБ 1: Главная
-- ============================================================

local MainTab = Window:CreateTab("Главная", "house")

-- Параграф с описанием
local InfoParagraph = MainTab:CreateParagraph({
    Title   = "Добро пожаловать!",
    Content = "Это пример полноценного GUI на Rayfield. Используйте вкладки слева для навигации по разделам."
})

MainTab:CreateDivider()

-- Секция «Статус»
local StatusSection = MainTab:CreateSection("Статус скрипта")

local StatusLabel = MainTab:CreateLabel("● Скрипт активен", "check-circle", Color3.fromRGB(100, 220, 130), true)

MainTab:CreateDivider()

-- Секция «Быстрые действия»
local QuickSection = MainTab:CreateSection("Быстрые действия")

local ReloadButton = MainTab:CreateButton({
    Name = "Перезагрузить конфиг",
    Callback = function()
        Rayfield:Notify({
            Title    = "Конфиг",
            Content  = "Конфигурация перезагружена",
            Image    = "refresh-cw",
            Duration = 3
        })
    end
})

local DestroyButton = MainTab:CreateButton({
    Name = "Закрыть GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})

-- ============================================================
--  ТАБ 2: Игрок
-- ============================================================

local PlayerTab = Window:CreateTab("Игрок", "user")

-- Секция «Движение»
local MovementSection = PlayerTab:CreateSection("Движение")

local WalkspeedSlider = PlayerTab:CreateSlider({
    Name         = "Скорость ходьбы",
    Range        = {16, 500},
    Increment    = 1,
    Suffix       = "units/s",
    CurrentValue = 16,
    Flag         = "WalkSpeed",
    Callback     = function(Value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Value
        end
    end
})

local JumpSlider = PlayerTab:CreateSlider({
    Name         = "Высота прыжка",
    Range        = {50, 500},
    Increment    = 5,
    Suffix       = "units",
    CurrentValue = 50,
    Flag         = "JumpPower",
    Callback     = function(Value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Value
        end
    end
})

PlayerTab:CreateDivider()

-- Секция «Способности»
local AbilitySection = PlayerTab:CreateSection("Способности")

local NoclipToggle = PlayerTab:CreateToggle({
    Name         = "Noclip",
    CurrentValue = false,
    Flag         = "Noclip",
    Callback     = function(Value)
        -- Логика noclip здесь
        Rayfield:Notify({
            Title    = "Noclip",
            Content  = Value and "Включён" or "Выключен",
            Image    = Value and "shield-off" or "shield",
            Duration = 2
        })
    end
})

local InfiniteJumpToggle = PlayerTab:CreateToggle({
    Name         = "Бесконечный прыжок",
    CurrentValue = false,
    Flag         = "InfiniteJump",
    Callback     = function(Value)
        -- Логика infinite jump
    end
})

local FlyToggle = PlayerTab:CreateToggle({
    Name         = "Полёт",
    CurrentValue = false,
    Flag         = "Fly",
    Callback     = function(Value)
        Rayfield:Notify({
            Title    = "Полёт",
            Content  = Value and "Активирован" or "Деактивирован",
            Image    = "plane",
            Duration = 2
        })
    end
})

PlayerTab:CreateDivider()

-- Секция «Внешний вид»
local AppearanceSection = PlayerTab:CreateSection("Внешний вид")

local TransparencySlider = PlayerTab:CreateSlider({
    Name         = "Прозрачность персонажа",
    Range        = {0, 100},
    Increment    = 5,
    Suffix       = "%",
    CurrentValue = 0,
    Flag         = "CharTransparency",
    Callback     = function(Value)
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = Value / 100
                end
            end
        end
    end
})

-- ============================================================
--  ТАБ 3: Визуал
-- ============================================================

local VisualTab = Window:CreateTab("Визуал", "eye")

-- Секция «ESP»
local ESPSection = VisualTab:CreateSection("ESP / Подсветка")

local ESPToggle = VisualTab:CreateToggle({
    Name         = "ESP игроков",
    CurrentValue = false,
    Flag         = "PlayerESP",
    Callback     = function(Value)
        -- Логика ESP
    end
})

local ESPColorPicker = VisualTab:CreateColorPicker({
    Name     = "Цвет ESP",
    Color    = Color3.fromRGB(255, 50, 50),
    Flag     = "ESPColor",
    Callback = function(Value)
        -- Обновить цвет ESP
    end
})

local ESPDistanceSlider = VisualTab:CreateSlider({
    Name         = "Дистанция ESP",
    Range        = {50, 2000},
    Increment    = 50,
    Suffix       = "studs",
    CurrentValue = 500,
    Flag         = "ESPDistance",
    Callback     = function(Value)
        -- Обновить дистанцию ESP
    end
})

VisualTab:CreateDivider()

-- Секция «Прицел»
local CrosshairSection = VisualTab:CreateSection("Прицел")

local CrosshairToggle = VisualTab:CreateToggle({
    Name         = "Кастомный прицел",
    CurrentValue = false,
    Flag         = "CustomCrosshair",
    Callback     = function(Value)
        -- Логика прицела
    end
})

local CrosshairColor = VisualTab:CreateColorPicker({
    Name     = "Цвет прицела",
    Color    = Color3.fromRGB(255, 255, 255),
    Flag     = "CrosshairColor",
    Callback = function(Value)
        -- Обновить цвет прицела
    end
})

local CrosshairSizeSlider = VisualTab:CreateSlider({
    Name         = "Размер прицела",
    Range        = {5, 50},
    Increment    = 1,
    Suffix       = "px",
    CurrentValue = 15,
    Flag         = "CrosshairSize",
    Callback     = function(Value)
        -- Обновить размер прицела
    end
})

VisualTab:CreateDivider()

-- Секция «Интерфейс»
local UISection = VisualTab:CreateSection("Интерфейс")

local ThemeDropdown = VisualTab:CreateDropdown({
    Name            = "Тема интерфейса",
    Options         = {"Default", "AmberGlow", "Bloom", "Dark", "Macintosh", "Ocean"},
    CurrentOption   = {"Default"},
    MultipleOptions = false,
    Flag            = "UITheme",
    Callback        = function(Options)
        Rayfield:Notify({
            Title    = "Тема",
            Content  = "Выбрана: " .. Options[1],
            Image    = "palette",
            Duration = 2
        })
    end
})

-- ============================================================
--  ТАБ 4: Мир
-- ============================================================

local WorldTab = Window:CreateTab("Мир", "globe")

-- Секция «Освещение»
local LightingSection = WorldTab:CreateSection("Освещение")

local BrightnessSlider = WorldTab:CreateSlider({
    Name         = "Яркость",
    Range        = {0, 10},
    Increment    = 1,
    Suffix       = "",
    CurrentValue = 2,
    Flag         = "Brightness",
    Callback     = function(Value)
        game.Lighting.Brightness = Value
    end
})

local AmbientColor = WorldTab:CreateColorPicker({
    Name     = "Цвет окружения",
    Color    = Color3.fromRGB(70, 70, 70),
    Flag     = "AmbientColor",
    Callback = function(Value)
        game.Lighting.Ambient = Value
    end
})

local FogDropdown = WorldTab:CreateDropdown({
    Name            = "Пресет погоды",
    Options         = {"Ясно", "Туман", "Ночь", "Дождь", "Закат"},
    CurrentOption   = {"Ясно"},
    MultipleOptions = false,
    Flag            = "WeatherPreset",
    Callback        = function(Options)
        local preset = Options[1]
        if preset == "Туман" then
            game.Lighting.FogEnd   = 200
            game.Lighting.FogStart = 0
        elseif preset == "Ночь" then
            game.Lighting.ClockTime = 0
        elseif preset == "Закат" then
            game.Lighting.ClockTime = 18
        elseif preset == "Ясно" then
            game.Lighting.FogEnd   = 100000
            game.Lighting.ClockTime = 14
        end
    end
})

WorldTab:CreateDivider()

-- Секция «Время»
local TimeSection = WorldTab:CreateSection("Время суток")

local TimeSlider = WorldTab:CreateSlider({
    Name         = "Время (0–24)",
    Range        = {0, 24},
    Increment    = 1,
    Suffix       = ":00",
    CurrentValue = 14,
    Flag         = "GameTime",
    Callback     = function(Value)
        game.Lighting.ClockTime = Value
    end
})

WorldTab:CreateDivider()

-- Секция «Гравитация»
local PhysicsSection = WorldTab:CreateSection("Физика")

local GravitySlider = WorldTab:CreateSlider({
    Name         = "Гравитация",
    Range        = {10, 500},
    Increment    = 10,
    Suffix       = "units",
    CurrentValue = 196,
    Flag         = "Gravity",
    Callback     = function(Value)
        workspace.Gravity = Value
    end
})

-- ============================================================
--  ТАБ 5: Настройки
-- ============================================================

local SettingsTab = Window:CreateTab("Настройки", "settings")

-- Секция «Управление»
local ControlsSection = SettingsTab:CreateSection("Управление")

local ToggleKeybind = SettingsTab:CreateKeybind({
    Name           = "Горячая клавиша GUI",
    CurrentKeybind = "RightCtrl",
    HoldToInteract = false,
    Flag           = "ToggleGUI",
    Callback       = function(Key)
        -- вызывается при нажатии клавиши
        Rayfield:SetVisibility(not Rayfield:IsVisible())
    end
})

local NotifKeybind = SettingsTab:CreateKeybind({
    Name           = "Тест уведомления",
    CurrentKeybind = "F9",
    HoldToInteract = false,
    Flag           = "TestNotif",
    Callback       = function()
        Rayfield:Notify({
            Title    = "Тест",
            Content  = "Горячая клавиша уведомления работает!",
            Image    = "bell",
            Duration = 3
        })
    end
})

SettingsTab:CreateDivider()

-- Секция «Конфиг»
local ConfigSection = SettingsTab:CreateSection("Конфигурация")

local ConfigNameInput = SettingsTab:CreateInput({
    Name                    = "Имя профиля",
    CurrentValue            = "Default",
    PlaceholderText         = "Введите имя...",
    RemoveTextAfterFocusLost = false,
    Flag                    = "ProfileName",
    Callback                = function(Text)
        -- Сохранить имя профиля
    end
})

local SaveConfigButton = SettingsTab:CreateButton({
    Name = "Сохранить конфиг",
    Callback = function()
        Rayfield:Notify({
            Title    = "Конфиг",
            Content  = "Конфигурация сохранена",
            Image    = "save",
            Duration = 3
        })
    end
})

local LoadConfigButton = SettingsTab:CreateButton({
    Name = "Загрузить конфиг",
    Callback = function()
        Rayfield:Notify({
            Title    = "Конфиг",
            Content  = "Конфигурация загружена",
            Image    = "folder-open",
            Duration = 3
        })
    end
})

SettingsTab:CreateDivider()

-- Секция «Интерфейс»
local GUISection = SettingsTab:CreateSection("Интерфейс")

local ToggleAnimToggle = SettingsTab:CreateToggle({
    Name         = "Анимации GUI",
    CurrentValue = true,
    Flag         = "GUIAnimations",
    Callback     = function(Value)
        -- Логика анимаций
    end
})

local NotifToggle = SettingsTab:CreateToggle({
    Name         = "Показывать уведомления",
    CurrentValue = true,
    Flag         = "ShowNotifs",
    Callback     = function(Value)
        -- Логика уведомлений
    end
})

SettingsTab:CreateDivider()

-- Секция «О программе»
local AboutSection = SettingsTab:CreateSection("О программе")

local AboutParagraph = SettingsTab:CreateParagraph({
    Title   = "My Hub v1.0",
    Content = "Сборка: 1.0.0\nРежим: Secure Mode\nДокументация: docs.sirius.menu/rayfield\n\nВсе права защищены."
})

-- ============================================================
--  СТАРТОВОЕ УВЕДОМЛЕНИЕ
-- ============================================================

Rayfield:Notify({
    Title    = "My Hub",
    Content  = "Скрипт успешно загружен. Добро пожаловать!",
    Image    = "check-circle",
    Duration = 5
})
