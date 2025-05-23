------------------------------------------------------------------------------------------------
-------------------------------------------ЛИБЫ-------------------------------------------------
------------------------------------------------------------------------------------------------
require('lib.moonloader')
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local sampev = require 'samp.events'
local inicfg = require('inicfg')
local imgui = require 'mimgui'
local hotkey = require('mimgui_hotkeys')
local Matrix3X3 = require "matrix3x3"
local Vector3D = require "vector3d"
local ffi = require 'ffi'
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local json = require("cjson")
local http = require("socket.http")
local requests = require 'requests'
local effil = require 'effil'
local https = require("ssl.https")
------------------------------------------------------------------------------------------------
-------------------------------------------ЛИБЫ-------------------------------------------------
------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------
-------------------------------------------Переменные-------------------------------------------
------------------------------------------------------------------------------------------------
local inputColor = new.char[256]()
local colorpalitra = imgui.new.float[3]()
local bindCallback = function() -- функция, которая сработает при нажатии на кнопки бинда
    sampAddChatMessage('BIND ACTIVATED', 0xFFff004d)
end
local bind
local newbind
local AdminCommands = {"/re {id}", "/g {id}", "/gethere {id}", "/offstats {nick}", "/stats {id}", "/adminka {nick}", "/rinfo {id}", "/abanip {id}"}
local PlayerPopup = { id = 'none', nick = 'none', lvl = 'none', ping = 'none' }

ffi.cdef('struct CVector2D {float x, y;}')
local CRadar_TransformRealWorldPointToRadarSpace = ffi.cast('void (__cdecl*)(struct CVector2D*, struct CVector2D*)', 0x583530)
local CRadar_TransformRadarPointToScreenSpace = ffi.cast('void (__cdecl*)(struct CVector2D*, struct CVector2D*)', 0x583480)
local CRadar_IsPointInsideRadar = ffi.cast('bool (__cdecl*)(struct CVector2D*)', 0x584D40)


local ipData = {}
local vpnData = {}
local font = {}
local rpc = {
    Receive = {83,14,22,21,67,124,128,129,86,87,74,19,15,153,156,157,12},
    send = {128,129,52,55,83}
}
target_keys = -1
isSpectating = false
keyToggle = VK_MBUTTON
keyApply = VK_LBUTTON

local keys = {
	onfoot = {},
	vehicle = {}
}

local SettingsState = new.bool()
local RINFO = new.bool()
local IniFilename = 'ChatSettings.ini'
local ini = inicfg.load({
    chat = {
        aChatColor = '{319AFF}',
        aNickChatColor = '{FFCD00}',
        aCmdChatColor = '{00ff00}',
        banChatColor = '{ffffff}',
        banNickChatColor = '{FFCD00}',
        banCmdChatColor = '{ff0000}',
        muteChatColor = '{ffffff}',
        muteNickChatColor = '{FFCD00}',
        muteCmdChatColor = '{ff0000}',
        kickChatColor = '{ffffff}',
        kickNickChatColor = '{FFCD00}',
        kickCmdChatColor = '{ff0000}',
        warnChatColor = '{ffffff}',
        warnNickChatColor = '{FFCD00}',
        warnCmdChatColor = '{ff0000}',
        awarnChatColor = '{ffffff}',
        awarnNickChatColor = '{FFCD00}',
        awarnCmdChatColor = '{ff0000}',
        amuteChatColor = '{ffffff}',
        amuteNickChatColor = '{FFCD00}',
        amuteCmdChatColor = '{ff0000}',
        jailChatColor = '{ffffff}',
        jailNickChatColor = '{FFCD00}',
        jailCmdChatColor = '{ff0000}',
        successChatColor = '{319AFF}',
        successNickChatColor = '{FFCD00}',
        successCmdChatColor = '{00ff00}',
        unknownChatColor = '{319AFF}',
        unknownNickChatColor = '{FFCD00}',
        unknownCmdChatColor = '{ff0000}',
        itemChatColor = '{ffffff}',
        itemNickChatColor = '{FFCD00}',
        itemShtChatColor = '{ff0000}',
        dItemChatColor = '{ffffff}',
        dItemNickChatColor = '{FFCD00}',
        dItemShtChatColor = '{ff0000}',
        botChatColor = '{9370db}',
        botPrefixChatColor = '{ff0000}',
        botNickChatColor = '{FFCD00}',
    },
    cmd = {
        chat = true,
        achat = true,
        banchat = true,
        mutechat = true,
        kickchat = true,
        warnchat = true,
        awarnchat = true,
        amutechat = true,
        jailchat = true,
        successchat = true,
        unknownchat = true,
        itemchat = true,
        ditemchat = true,
        botchat = true
    },
    bind = {
        SettingKey = "[164, 67]",
        cmd = "chatsettings"
    }

}, IniFilename)
inicfg.save(ini, IniFilename)

local inputText = new.char[256](ini.bind.cmd or "")
local currentCommand = ini.bind.cmd or ""
local bindKeys = decodeJson(ini.bind.SettingKey)
local bindCallback = function()
    SettingsState[0] = not SettingsState[0]
end

theme = {
    change = function()
        local ImVec4 = imgui.ImVec4
        imgui.SwitchContext()
        imgui.GetStyle().Colors[imgui.Col.Text]                   = ImVec4(0.90, 0.90, 0.93, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = ImVec4(0.40, 0.40, 0.45, 1.00)
        imgui.GetStyle().Colors[imgui.Col.WindowBg]               = ImVec4(0.12, 0.12, 0.14, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ChildBg]                = ImVec4(0.18, 0.20, 0.22, 0.30)
        imgui.GetStyle().Colors[imgui.Col.PopupBg]                = ImVec4(0.13, 0.13, 0.15, 1.00)
        imgui.GetStyle().Colors[imgui.Col.Border]                 = ImVec4(0.30, 0.30, 0.35, 1.00)
        imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        imgui.GetStyle().Colors[imgui.Col.FrameBg]                = ImVec4(0.18, 0.18, 0.20, 1.00)
        imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = ImVec4(0.25, 0.25, 0.28, 1.00)
        imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = ImVec4(0.30, 0.30, 0.34, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TitleBg]                = ImVec4(0.15, 0.15, 0.17, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.10, 0.10, 0.12, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = ImVec4(0.15, 0.15, 0.17, 1.00)
        imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = ImVec4(0.12, 0.12, 0.14, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = ImVec4(0.12, 0.12, 0.14, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.30, 0.30, 0.35, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.40, 0.40, 0.45, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.50, 0.50, 0.55, 1.00)
        imgui.GetStyle().Colors[imgui.Col.CheckMark]              = ImVec4(0.70, 0.70, 0.90, 1.00)
        imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = ImVec4(0.70, 0.70, 0.90, 1.00)
        imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = ImVec4(0.80, 0.80, 0.90, 1.00)
        imgui.GetStyle().Colors[imgui.Col.Button]                 = ImVec4(0.18, 0.18, 0.20, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = ImVec4(0.60, 0.60, 0.90, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = ImVec4(0.28, 0.56, 0.96, 1.00)
        imgui.GetStyle().Colors[imgui.Col.Header]                 = ImVec4(0.20, 0.20, 0.23, 1.00)
        imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = ImVec4(0.25, 0.25, 0.28, 1.00)
        imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = ImVec4(0.30, 0.30, 0.34, 1.00)
        imgui.GetStyle().Colors[imgui.Col.Separator]              = ImVec4(0.40, 0.40, 0.45, 1.00)
        imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = ImVec4(0.50, 0.50, 0.55, 1.00)
        imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = ImVec4(0.60, 0.60, 0.65, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = ImVec4(0.20, 0.20, 0.23, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.25, 0.25, 0.28, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = ImVec4(0.30, 0.30, 0.34, 1.00)
        imgui.GetStyle().Colors[imgui.Col.PlotLines]              = ImVec4(0.61, 0.61, 0.64, 1.00)
        imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = ImVec4(0.70, 0.70, 0.75, 1.00)
        imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = ImVec4(0.61, 0.61, 0.64, 1.00)
        imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = ImVec4(0.70, 0.70, 0.75, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = ImVec4(0.30, 0.30, 0.34, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = ImVec4(0.10, 0.10, 0.12, 0.80)
        imgui.GetStyle().Colors[imgui.Col.Tab]                    = ImVec4(0.18, 0.20, 0.22, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TabHovered]             = ImVec4(0.60, 0.60, 0.90, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TabActive]              = ImVec4(0.28, 0.56, 0.96, 1.00)
    end
}
style = {
    change = function()
        imgui.SwitchContext()
        local style = imgui.GetStyle()
        style.WindowPadding = imgui.ImVec2(15, 15)
        style.WindowRounding = 10.0
        style.ChildRounding = 6.0
        style.FramePadding = imgui.ImVec2(8, 7)
        style.FrameRounding = 8.0
        style.ItemSpacing = imgui.ImVec2(8, 8)
        style.ItemInnerSpacing = imgui.ImVec2(10, 6)
        style.IndentSpacing = 25.0
        style.ScrollbarSize = 13.0
        style.ScrollbarRounding = 12.0
        style.GrabMinSize = 10.0
        style.GrabRounding = 6.0
        style.PopupRounding = 8
        style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
        style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        style.WindowBorderSize = 1
        style.ChildBorderSize = 1
        style.PopupBorderSize = 1
        style.FrameBorderSize = 1
        style.TabBorderSize = 1
    end
}


local blue = "{319AFF}"
local lightblue = "{8cb3d9}"
local green = "{00ff00}"
local red = "{ff0000}"
local yellow = "{FFCD00}"
local purple = "{9370db}"
local white = "{ffffff}"
local darkpurple = "{a86cfc}"
local darkpink = "{cc3370}"
local orange = "{ff6600}"
local darkblue = "{4466cc}"
local darkred = "{b92228}"
local lightbrown = "{d2a679}"
local lime = "{ccff00}"
local cyan = "{00cc99}"
local lightgreen = "{00cc66}"
local lightred = "{FF6666}"
local pink = "{ff99cc}"
local lightgray = "{cecece}"
local black = "{000000}"
local brown = "{a47259}"
local lightyellow = "{d5ff80}"

--588-736
local items = {
    [346] = lightyellow .. "Лён", [347] = blue .. "Хлопок", [348] = white .. "Бумбокс", [362] = white .. "Камень", [363] = pink .. "Золото", [364] = purple .. "Серебро", [539] = yellow .. "Бронза",
    [540] = lightbrown .. "Металл", [546] = white .. "Карточка победителя", [588] = yellow .. "Пчёлка", [589] = lightblue .. "Дельфин на спину", [590] = darkpurple .. "Визажист", [591] = orange .. "Дракон",
    [592] = darkpurple .. "Попугай Кеша", [593] = red .. "Девушка на спину", [594] = red .. "Кровавая накидка", [595] = yellow .. "Плащ бога", [596] = darkblue .. "НЛО на плечо", [597] = red .. "Мумия",
    [598] = darkred .. "Бог любви", [599] = lightbrown .. "Олень на плечо", [600] = lightblue .. "Улыбчивый смайлик", [601] = lightblue .. "Довольный смайлик", [602] = lightblue .. "Флиртующий смайлик",
    [603] = yellow .. "Лазерный меч", [604] = lime .. "Космонавт", [605] = cyan .. "Купидон", [606] = lightbrown .. "Винни Пух", [607] = green .. "Пучеглаз", [608] = yellow .. "Бананчик",
    [609] = yellow .. "Посох солнца", [610] = yellow .. "Магнит репутации", [612] = orange .. "Царский интерьер", [616] = lightgreen .. "Ангельское кольцо", [619] = lightgreen .. "Новогодний интерьер",
    [625] = lightgreen .. "Сияние ангела", [626] = red .. "Золотой жетон", [627] = yellow .. "Рюкзак шахтёра", [629] = red .. "Повышение админки", [630] = orange .. "Медаль ведьмы",
    [631] = yellow .. "Сохранение оружия после релога", [633] = yellow .. "День рождения", [634] = lightred .. "Карта АДМИНКА №12", [635] = lightred .. "Карта АДМИНКА №13", [636] = lightred .. "Карта АДМИНКА №14",
    [637] = lightred .. "Карта Confident", [638] = lightred .. "Карта Анти-Снятие", [639] = lightred .. "Карта Анти-Jail", [640] = lightred .. "Карта Верификация", [641] = red .. "Карточный сундук",
    [642] = yellow .. "Плеер MP3", [643] = yellow .. "Спанч Боб", [644] = yellow .. "Зомби дед", [645] = yellow .. "Спартанец", [646] = yellow .. "Зеленая смерть", [647] = yellow .. "Дарт Вейдер",
    [648] = yellow .. "Негр с гробом", [649] = red .. "Донат кейс", [650] = orange .. "Лотырейный билет", [651] = red .. "Блокировка инвентаря", [652] = yellow .. "Таракашка", [653] = yellow .. "Феечка",
    [654] = orange .. "Ведьма", [655] = orange .. "Конфеты", [656] = orange .. "Зелье ведьмы", [657] = orange.. "Майнкрафт", [658] = lightblue .. "Черепашка", [659] = lightblue .. "Смешарик",
    [660] = lightblue .. "Стич", [661] = lightblue .. "Кролик", [662] = lightblue .. "Подарок 2022", [663] = yellow .. "Ангел", [664] = yellow .. "Hello Kitty", [665] = red .. "Bitcoin (BTC)",
    [666] = darkpink .. "Влюбчивый смайлик", [667] = lime .. "NVIDIA GTX 1080Ti", [668] = lime .. "NVIDIA RTX 2080Ti", [669] = lime .. "NVIDIA RTX 3090Ti", [670] = red .. "NVIDIA RTX A5000",
    [671] = red .. "Охлаждающая жидкость", [672] = red .. "Смазка для разгона", [673] = pink .. "Свадебный подарок", [674] = yellow .. "Пикачу в шляпе", [675] = yellow .. "Веном", [676] = lightgray .. "Туалетомен",
    [677] = lightblue .. "Сонник", [678] = lightgray .. "Крик", [679] = lightgreen .. "Коронавирус", [680] = yellow .. "Красный Angry Birds", [681] = yellow .. "Черный Angry Birds", [682] = green .. "The Sims",
    [683] = yellow .. "Плюшевый мишка", [684] = red .. "Набор ресурсов", [685] = brown .."Какашечка", [686] = orange .. "Сияние демона", [687] = lightgray .. "Для взрослых 18+", [688] = lime .. "Кузнечик",
    [689] = yellow .. "Люкс интерьер", [690] = yellow .. "Элитный интерьер", [691] = yellow .. "VIP интерьер", [692] = red .. "Рубли", [693] = red .. "Кредитный счёт", [694] = lightblue .. "Подарок 2023",
    [695] = yellow .. "ФБР гитарист", [696] = yellow .. "Коп гитарист", [697] = yellow .. "Тоторо", [698] = yellow .. "Игрушки", [699] = lime .. "Копатыч", [700] = lime .. "Крипер", [701] = lime .. "Лунтик",
    [702] = lime .. "Патрик", [703] = lime .. "Чебурашка", [704] = lime .. "Микки маус", [705] = yellow .. "Лицензия на охоту", [706] = yellow .. "Тушка оленя", [707] = lightblue .. "Удочка", [708] = lightblue .. "Снасти",
    [709] = lightblue .. "Наживка", [710] = yellow .. "Рыба", [711] = orange .. "Halloween №1", [712] = orange .. "Halloween №2", [713] = orange .. "Halloween №3", [714] = lightblue .. "Подарок 2024",
    [715] = purple .. "Финн", [716] = purple .. "Джейк", [717] = purple .."БиМО", [718] = purple .. "Гюнтер", [719] = purple .. "Ягодка", [720] = purple .. "Стэн Марш", [721] = purple .. "Брофловски",
    [722] = purple .. "Маккоромик", [723] = purple .. "Крэйг", [724] = purple .. "Шеф Макэлрой", [725] = purple .. "Слизень", [726] = purple .. "Дракон края", [727] = purple .. "Страж",
    [728] = purple .. "Белый медведь", [729] = purple .. "Кися", [730] = pink .. "Буст x2 PayDay", [731] = pink .. "Буст x3 PayDay", [732] = pink .. "Буст x4 PayDay", [733] = pink .. "Буст x2 Активность",
    [734] = pink .. "Буст x3 Активность", [735] = pink .. "Буст x4 Активность", [736] = red .. "VIP очки"
}

local colors = {
    {name = "Зеленый", value = green},
    {name = "Коричневый", value = brown},
    {name = "Синий", value = blue},
    {name = "Голубой", value = lightblue},
    {name = "Красный", value = red},
    {name = "Жёлтый", value = yellow},
    {name = "Фиолетовый", value = purple},
    {name = "Белый", value = white},
    {name = "Темно-фиолетовый", value = darkpurple},
    {name = "Темно-розовый", value = darkpink},
    {name = "Оранжевый", value = orange},
    {name = "Темно-синий", value = darkblue},
    {name = "Темно-красный", value = darkred},
    {name = "Светло-коричневый", value = lightbrown},
    {name = "Лаймовый", value = lime},
    {name = "Бирюзовый", value = cyan},
    {name = "Светло-серый", value = lightgray},
    {name = "Светло-зеленый", value = lightgreen},
    {name = "Светло-красный", value = lightred},
    {name = "Розовый", value = pink},
    {name = "Черный", value = black},
}

local aChatSettings = {
    { popupName = 'Основной A-цвет', colorKey = 'aChatColor', defaultColor = blue },
    { popupName = 'Ник A-цвет', colorKey = 'aNickChatColor', defaultColor = yellow },
    { popupName = 'Команда A-цвет', colorKey = 'aCmdChatColor', defaultColor = green }
}

-- Конфигурация для Бан-чата
local banChatSettings = {
    { popupName = 'Основной Бан-цвет', colorKey = 'banChatColor', defaultColor = white },
    { popupName = 'Ник Бан-цвет', colorKey = 'banNickChatColor', defaultColor = yellow },
    { popupName = 'Время/причина Бан-цвет', colorKey = 'banCmdChatColor', defaultColor = red }
}

-- Конфигурация для Мут-чата
local muteChatSettings = {
    { popupName = 'Основной Мут-цвет', colorKey = 'muteChatColor', defaultColor = white },
    { popupName = 'Ник Мут-цвет', colorKey = 'muteNickChatColor', defaultColor = yellow },
    { popupName = 'Время/причина Мут-цвет', colorKey = 'muteCmdChatColor', defaultColor = red }
}

-- Конфигурация для Кик-чата
local kickChatSettings = {
    { popupName = 'Основной Кик-цвет', colorKey = 'kickChatColor', defaultColor = white },
    { popupName = 'Ник Кик-цвет', colorKey = 'kickNickChatColor', defaultColor = yellow },
    { popupName = 'Причина Кик-цвет', colorKey = 'kickCmdChatColor', defaultColor = red }
}

-- Конфигурация для Варн-чата
local warnChatSettings = {
    { popupName = 'Основной Варн-цвет', colorKey = 'warnChatColor', defaultColor = white },
    { popupName = 'Ник Варн-цвет', colorKey = 'warnNickChatColor', defaultColor = yellow },
    { popupName = 'Причина Варн-цвет', colorKey = 'warnCmdChatColor', defaultColor = red }
}

local awarnChatSettings = {
    { popupName = 'Основной Аварн-цвет', colorKey = 'awarnChatColor', defaultColor = white },
    { popupName = 'Ник Аварн-цвет', colorKey = 'awarnNickChatColor', defaultColor = yellow },
    { popupName = 'Причина Аварн-цвет', colorKey = 'awarnCmdChatColor', defaultColor = red }
}

-- Конфигурация для Амут-чата
local amuteChatSettings = {
    { popupName = 'Основной Амут-цвет', colorKey = 'amuteChatColor', defaultColor = white },
    { popupName = 'Ник Амут-цвет', colorKey = 'amuteNickChatColor', defaultColor = yellow },
    { popupName = 'Время/причина Амут-цвет', colorKey = 'amuteCmdChatColor', defaultColor = red }
}

local jailChatSettings = {
    { popupName = 'Основной Джайл-цвет', colorKey = 'jailChatColor', defaultColor = white },
    { popupName = 'Ник Джайл-цвет', colorKey = 'jailNickChatColor', defaultColor = yellow },
    { popupName = 'Время/причина Джайл-цвет', colorKey = 'jailCmdChatColor', defaultColor = red }
}

local successChatSettings = {
    { popupName = 'Основной Success-цвет', colorKey = 'successChatColor', defaultColor = blue },
    { popupName = 'Ник Success-цвет', colorKey = 'successNickChatColor', defaultColor = yellow },
    { popupName = 'Команда Success-цвет', colorKey = 'successCmdChatColor', defaultColor = green }
}

local unknownChatSettings = {
    { popupName = 'Основной Unknown-цвет', colorKey = 'unknownChatColor', defaultColor = blue },
    { popupName = 'Ник Unknown-цвет', colorKey = 'unknownNickChatColor', defaultColor = yellow },
    { popupName = 'Команда Unknown-цвет', colorKey = 'unknownCmdChatColor', defaultColor = red }
}

local addItemChatSettings = {
    { popupName = 'Основной Additem-цвет', colorKey = 'itemChatColor', defaultColor = white },
    { popupName = 'Ник Additem-цвет', colorKey = 'itemNickChatColor', defaultColor = yellow },
    { popupName = 'Кол-во Additem-цвет', colorKey = 'itemShtChatColor', defaultColor = red }
}

local delItemChatSettings = {
    { popupName = 'Основной Delitem-цвет', colorKey = 'dItemChatColor', defaultColor = white },
    { popupName = 'Ник Delitem-цвет', colorKey = 'dItemNickChatColor', defaultColor = yellow },
    { popupName = 'Кол-во Delitem-цвет', colorKey = 'dItemShtChatColor', defaultColor = red }
}

local botChatSettings = {
    { popupName = 'Основной Бот-цвет', colorKey = 'botChatColor', defaultColor = purple },
    { popupName = 'Ник Бот-цвет', colorKey = 'botNickChatColor', defaultColor = yellow },
    { popupName = 'Префикс Бот-цвет', colorKey = 'botPrefixChatColor', defaultColor = red }
}

------------------------------------------------------------------------------------------------
-------------------------------------------Переменные-------------------------------------------
------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------
-------------------------------------------Функции----------------------------------------------
------------------------------------------------------------------------------------------------

local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
function string.rlower(s)
    s = tostring(s):lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- Ё
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function utext(text)
    text = u8:decode(text)
    return text
end

function chat(text)
    text = sampSendChat(utext(text))
    return text
end

function find(s, p)
    return string.rlower(s):find(string.rlower(p))
end

function match(s, p)
	return string.rlower(s):match(string.rlower(p))
end

function ACM(text)
    text = sampAddChatMessage(text, -1)
    return text
end

function SD(id, caption, text, button, button1, style)
    return sampShowDialog(id, utext(caption), utext(text), utext(button), utext(button1), style)
end

function TransformRealWorldPointToRadarSpace(x, y)
    local RetVal = ffi.new('struct CVector2D', {0, 0})
    CRadar_TransformRealWorldPointToRadarSpace(RetVal, ffi.new('struct CVector2D', {x, y}))
    return RetVal.x, RetVal.y
end

function TransformRadarPointToScreenSpace(x, y)
    local RetVal = ffi.new('struct CVector2D', {0, 0})
    CRadar_TransformRadarPointToScreenSpace(RetVal, ffi.new('struct CVector2D', {x, y}))
    return RetVal.x, RetVal.y
end

function IsPointInsideRadar(x, y)
    return CRadar_IsPointInsideRadar(ffi.new('struct CVector2D', {x, y}))
end

function argb_to_abgr(argb)
    local a, r, g, b = explode_argb(argb)
    return join_argb(255, b, g, r)
end

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function charArrayToString(array, length)
    local str = ''
    for i = 0, length do
        local char = string.char(array[i])
        if char == '\0' then
            break
        end
        str = str .. char
    end
    return str
end

function stringToCharArray(str, maxLength)
    local charArray = {}
    for i = 1, maxLength do
        charArray[i] = str:sub(i, i) or "\0"
    end
    return charArray
end

function sampGetPlayerIdByNickname(nick)
    nick = tostring(nick)
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if nick == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1003 do
      if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
        return i
      end
    end
end

function isItemList(item)
    if items[item] then
        return true, items[item]
    else
        return false, nil
    end
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4
    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end
    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImVec4(r/255, g/255, b/255, a/255)
    end
    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end
    render_text(text)
end

function RGBToHex(r, g, b)
    return string.format("{#%02x%02x%02x}", r * 255, g * 255, b * 255):gsub(" ", "")
end

function createColorPopup(popupName, colorKey, defaultColors)
    if imgui.Button(popupName) then
        imgui.OpenPopup(popupName)
    end
    if imgui.BeginPopup(popupName) then
        for _, color in ipairs(colors) do
            if imgui.Button(color.name) then
                ini.chat[colorKey] = color.value
                inicfg.save(ini, IniFilename)
            end
        end
        if imgui.Button("Свой цвет") then
            imgui.OpenPopup("ColorMe")
        end
        if imgui.BeginPopup("ColorMe") then
            imgui.InputText("{HTML COLOR}\nили\nпалитра", inputColor, 9)
            local colorme = inputColor
            if imgui.Button("Сохранить") then
                ini.chat[colorKey] = charArrayToString(colorme, 9)
                inicfg.save(ini, IniFilename)
            end
            imgui.ColorPicker3('##1', colorpalitra, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha)
            local colorpalitrahex = RGBToHex(colorpalitra[0], colorpalitra[1], colorpalitra[2])
            if imgui.Button("Сохранить палитру") then
                ini.chat[colorKey] = colorpalitrahex:gsub("#", "")
                inicfg.save(ini, IniFilename)
            end
            imgui.EndPopup()
        end
        imgui.EndPopup()
    end
end

function createChatPopup(chatType, settings, defaultColors)
    if imgui.Button(chatType.buttonText) then
        imgui.OpenPopup(chatType.popupName)
    end
    if imgui.BeginPopup(chatType.popupName) then
        for _, setting in ipairs(settings) do
            createColorPopup(setting.popupName, setting.colorKey, setting.defaultColor)
        end
        if imgui.Button('Вернуть как было') then
            -- Сбрасываем цвета на значения по умолчанию
            for _, setting in ipairs(settings) do
                ini.chat[setting.colorKey] = setting.defaultColor
            end
            inicfg.save(ini, IniFilename)
        end
        imgui.EndPopup()
    end
end

function createChatToggleButton(chatKey, chatName)
    if imgui.Button('Новый ' .. chatName) then
        ini.cmd[chatKey] = not ini.cmd[chatKey]  -- Переключение состояния
        inicfg.save(ini, IniFilename)
    end

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        if ini.cmd[chatKey] then
            imgui.TextColoredRGB(utext(string.format('{ffffff}Сейчас {319AFF}Новый %s {00ff00}включен.', chatName)))
        else
            imgui.TextColoredRGB(utext(string.format('{ffffff}Сейчас {319AFF}Новый %s {ff0000}выключен.', chatName)))
        end
        imgui.EndTooltip()
    end
end

function sampev.onSendPlayerSync(data)
	if spec then
		local sync = samp_create_sync_data('spectator')
		sync.position = data.position
        sync.keysData = data.keysData
		sync.send()
		return false
	end
end
function onSendPacket(id, bitStream, priority, reliability, orderingChannel)
	if nopPlayerSync and id == 207 then return false end
	if nopPlayerSync and id == 204 then return false end
end

function onReceiveRpc(id, bs)
	for i, v in ipairs(rpc.Receive) do
        if obhod and id == v then
            if id == 156 then
                sampSendInteriorChange(0)
            end
            return false
        end
    end
end

function onSendRpc(id, bitStream, priority, reliability, orderingChannel, shiftTs)
	for i, v in ipairs(rpc.send) do
        if obhod and id == v then
            return false
        end
    end
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'

    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    -- copy player's sync data to the allocated memory
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    -- function to send packet
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    -- metatable to access sync data and 'send' function
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end

function emul_rpc(hook, parameters)
    local bs_io = require 'samp.events.bitstream_io'
    local handler = require 'samp.events.handlers'
    local extra_types = require 'samp.events.extra_types'
    local hooks = {

        --[[ Outgoing rpcs
        ['onSendEnterVehicle'] = { 'int16', 'bool8', 26 },
        ['onSendClickPlayer'] = { 'int16', 'int8', 23 },
        ['onSendClientJoin'] = { 'int32', 'int8', 'string8', 'int32', 'string8', 'string8', 'int32', 25 },
        ['onSendEnterEditObject'] = { 'int32', 'int16', 'int32', 'vector3d', 27 },
        ['onSendCommand'] = { 'string32', 50 },
        ['onSendSpawn'] = { 52 },
        ['onSendDeathNotification'] = { 'int8', 'int16', 53 },
        ['onSendDialogResponse'] = { 'int16', 'int8', 'int16', 'string8', 62 },
        ['onSendClickTextDraw'] = { 'int16', 83 },
        ['onSendVehicleTuningNotification'] = { 'int32', 'int32', 'int32', 'int32', 96 },
        ['onSendChat'] = { 'string8', 101 },
        ['onSendClientCheckResponse'] = { 'int8', 'int32', 'int8', 103 },
        ['onSendVehicleDamaged'] = { 'int16', 'int32', 'int32', 'int8', 'int8', 106 },
        ['onSendEditAttachedObject'] = { 'int32', 'int32', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 116 },
        ['onSendEditObject'] = { 'bool', 'int16', 'int32', 'vector3d', 'vector3d', 117 },
        ['onSendInteriorChangeNotification'] = { 'int8', 118 },
        ['onSendMapMarker'] = { 'vector3d', 119 },
        ['onSendRequestClass'] = { 'int32', 128 },
        ['onSendRequestSpawn'] = { 129 },
        ['onSendPickedUpPickup'] = { 'int32', 131 },
        ['onSendMenuSelect'] = { 'int8', 132 },
        ['onSendVehicleDestroyed'] = { 'int16', 136 },
        ['onSendQuitMenu'] = { 140 },
        ['onSendExitVehicle'] = { 'int16', 154 },
        ['onSendUpdateScoresAndPings'] = { 155 },
        ['onSendGiveDamage'] = { 'int16', 'float', 'int32', 'int32', 115 },
        ['onSendTakeDamage'] = { 'int16', 'float', 'int32', 'int32', 115 },]]

        -- Incoming rpcs
        ['onInitGame'] = { 139 },
        ['onPlayerJoin'] = { 'int16', 'int32', 'bool8', 'string8', 137 },
        ['onPlayerQuit'] = { 'int16', 'int8', 138 },
        ['onRequestClassResponse'] = { 'bool8', 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 128 },
        ['onRequestSpawnResponse'] = { 'bool8', 129 },
        ['onSetPlayerName'] = { 'int16', 'string8', 'bool8', 11 },
        ['onSetPlayerPos'] = { 'vector3d', 12 },
        ['onSetPlayerPosFindZ'] = { 'vector3d', 13 },
        ['onSetPlayerHealth'] = { 'float', 14 },
        ['onTogglePlayerControllable'] = { 'bool8', 15 },
        ['onPlaySound'] = { 'int32', 'vector3d', 16 },
        ['onSetWorldBounds'] = { 'float', 'float', 'float', 'float', 17 },
        ['onGivePlayerMoney'] = { 'int32', 18 },
        ['onSetPlayerFacingAngle'] = { 'float', 19 },
        --['onResetPlayerMoney'] = { 20 },
        --['onResetPlayerWeapons'] = { 21 },
        ['onGivePlayerWeapon'] = { 'int32', 'int32', 22 },
        --['onCancelEdit'] = { 28 },
        ['onSetPlayerTime'] = { 'int8', 'int8', 29 },
        ['onSetToggleClock'] = { 'bool8', 30 },
        ['onPlayerStreamIn'] = { 'int16', 'int8', 'int32', 'vector3d', 'float', 'int32', 'int8', 32 },
        ['onSetShopName'] = { 'string256', 33 },
        ['onSetPlayerSkillLevel'] = { 'int16', 'int32', 'int16', 34 },
        ['onSetPlayerDrunk'] = { 'int32', 35 },
        ['onCreate3DText'] = { 'int16', 'int32', 'vector3d', 'float', 'bool8', 'int16', 'int16', 'encodedString4096', 36 },
        --['onDisableCheckpoint'] = { 37 },
        ['onSetRaceCheckpoint'] = { 'int8', 'vector3d', 'vector3d', 'float', 38 },
        --['onDisableRaceCheckpoint'] = { 39 },
        --['onGamemodeRestart'] = { 40 },
        ['onPlayAudioStream'] = { 'string8', 'vector3d', 'float', 'bool8', 41 },
        --['onStopAudioStream'] = { 42 },
        ['onRemoveBuilding'] = { 'int32', 'vector3d', 'float', 43 },
        ['onCreateObject'] = { 44 },
        ['onSetObjectPosition'] = { 'int16', 'vector3d', 45 },
        ['onSetObjectRotation'] = { 'int16', 'vector3d', 46 },
        ['onDestroyObject'] = { 'int16', 47 },
        ['onPlayerDeathNotification'] = { 'int16', 'int16', 'int8', 55 },
        ['onSetMapIcon'] = { 'int8', 'vector3d', 'int8', 'int32', 'int8', 56 },
        ['onRemoveVehicleComponent'] = { 'int16', 'int16', 57 },
        ['onRemove3DTextLabel'] = { 'int16', 58 },
        ['onPlayerChatBubble'] = { 'int16', 'int32', 'float', 'int32', 'string8', 59 },
        ['onUpdateGlobalTimer'] = { 'int32', 60 },
        ['onShowDialog'] = { 'int16', 'int8', 'string8', 'string8', 'string8', 'encodedString4096', 61 },
        ['onDestroyPickup'] = { 'int32', 63 },
        ['onLinkVehicleToInterior'] = { 'int16', 'int8', 65 },
        ['onSetPlayerArmour'] = { 'float', 66 },
        ['onSetPlayerArmedWeapon'] = { 'int32', 67 },
        ['onSetSpawnInfo'] = { 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 68 },
        ['onSetPlayerTeam'] = { 'int16', 'int8', 69 },
        ['onPutPlayerInVehicle'] = { 'int16', 'int8', 70 },
        --['onRemovePlayerFromVehicle'] = { 71 },
        ['onSetPlayerColor'] = { 'int16', 'int32', 72 },
        ['onDisplayGameText'] = { 'int32', 'int32', 'string32', 73 },
        --['onForceClassSelection'] = { 74 },
        ['onAttachObjectToPlayer'] = { 'int16', 'int16', 'vector3d', 'vector3d', 75 },
        ['onInitMenu'] = { 76 },
        ['onShowMenu'] = { 'int8', 77 },
        ['onHideMenu'] = { 'int8', 78 },
        ['onCreateExplosion'] = { 'vector3d', 'int32', 'float', 79 },
        ['onShowPlayerNameTag'] = { 'int16', 'bool8', 80 },
        ['onAttachCameraToObject'] = { 'int16', 81 },
        ['onInterpolateCamera'] = { 'bool', 'vector3d', 'vector3d', 'int32', 'int8', 82 },
        ['onGangZoneStopFlash'] = { 'int16', 85 },
        ['onApplyPlayerAnimation'] = { 'int16', 'string8', 'string8', 'bool', 'bool', 'bool', 'bool', 'int32', 86 },
        ['onClearPlayerAnimation'] = { 'int16', 87 },
        ['onSetPlayerSpecialAction'] = { 'int8', 88 },
        ['onSetPlayerFightingStyle'] = { 'int16', 'int8', 89 },
        ['onSetPlayerVelocity'] = { 'vector3d', 90 },
        ['onSetVehicleVelocity'] = { 'bool8', 'vector3d', 91 },
        ['onServerMessage'] = { 'int32', 'string32', 93 },
        ['onSetWorldTime'] = { 'int8', 94 },
        ['onCreatePickup'] = { 'int32', 'int32', 'int32', 'vector3d', 95 },
        ['onMoveObject'] = { 'int16', 'vector3d', 'vector3d', 'float', 'vector3d', 99 },
        ['onEnableStuntBonus'] = { 'bool', 104 },
        ['onTextDrawSetString'] = { 'int16', 'string16', 105 },
        ['onSetCheckpoint'] = { 'vector3d', 'float', 107 },
        ['onCreateGangZone'] = { 'int16', 'vector2d', 'vector2d', 'int32', 108 },
        ['onPlayCrimeReport'] = { 'int16', 'int32', 'int32', 'int32', 'int32', 'vector3d', 112 },
        ['onGangZoneDestroy'] = { 'int16', 120 },
        ['onGangZoneFlash'] = { 'int16', 'int32', 121 },
        ['onStopObject'] = { 'int16', 122 },
        ['onSetVehicleNumberPlate'] = { 'int16', 'string8', 123 },
        ['onTogglePlayerSpectating'] = { 'bool32', 124 },
        ['onSpectatePlayer'] = { 'int16', 'int8', 126 },
        ['onSpectateVehicle'] = { 'int16', 'int8', 127 },
        ['onShowTextDraw'] = { 134 },
        ['onSetPlayerWantedLevel'] = { 'int8', 133 },
        ['onTextDrawHide'] = { 'int16', 135 },
        ['onRemoveMapIcon'] = { 'int8', 144 },
        ['onSetWeaponAmmo'] = { 'int8', 'int16', 145 },
        ['onSetGravity'] = { 'float', 146 },
        ['onSetVehicleHealth'] = { 'int16', 'float', 147 },
        ['onAttachTrailerToVehicle'] = { 'int16', 'int16', 148 },
        ['onDetachTrailerFromVehicle'] = { 'int16', 149 },
        ['onSetWeather'] = { 'int8', 152 },
        ['onSetPlayerSkin'] = { 'int32', 'int32', 153 },
        ['onSetInterior'] = { 'int8', 156 },
        ['onSetCameraPosition'] = { 'vector3d', 157 },
        ['onSetCameraLookAt'] = { 'vector3d', 'int8', 158 },
        ['onSetVehiclePosition'] = { 'int16', 'vector3d', 159 },
        ['onSetVehicleAngle'] = { 'int16', 'float', 160 },
        ['onSetVehicleParams'] = { 'int16', 'int16', 'bool8', 161 },
        --['onSetCameraBehind'] = { 162 },
        ['onChatMessage'] = { 'int16', 'string8', 101 },
        ['onConnectionRejected'] = { 'int8', 130 },
        ['onPlayerStreamOut'] = { 'int16', 163 },
        ['onVehicleStreamIn'] = { 164 },
        ['onVehicleStreamOut'] = { 'int16', 165 },
        ['onPlayerDeath'] = { 'int16', 166 },
        ['onPlayerEnterVehicle'] = { 'int16', 'int16', 'bool8', 26 },
        ['onUpdateScoresAndPings'] = { 'PlayerScorePingMap', 155 },
        ['onSetObjectMaterial'] = { 84 },
        ['onSetObjectMaterialText'] = { 84 },
        ['onSetVehicleParamsEx'] = { 'int16', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 24 },
        ['onSetPlayerAttachedObject'] = { 'int16', 'int32', 'bool', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 113 }

    }
    local handler_hook = {
        ['onInitGame'] = true,
        ['onCreateObject'] = true,
        ['onInitMenu'] = true,
        ['onShowTextDraw'] = true,
        ['onVehicleStreamIn'] = true,
        ['onSetObjectMaterial'] = true,
        ['onSetObjectMaterialText'] = true
    }
    local extra = {
        ['PlayerScorePingMap'] = true,
        ['Int32Array3'] = true
    }
    local hook_table = hooks[hook]
    if hook_table then
        local bs = raknetNewBitStream()
        if not handler_hook[hook] then
            local max = #hook_table-1
            if max > 0 then
                for i = 1, max do
                    local p = hook_table[i]
                    if extra[p] then extra_types[p]['write'](bs, parameters[i])
                    else bs_io[p]['write'](bs, parameters[i]) end
                end
            end
        else
            if hook == 'onInitGame' then handler.on_init_game_writer(bs, parameters)
            elseif hook == 'onCreateObject' then handler.on_create_object_writer(bs, parameters)
            elseif hook == 'onInitMenu' then handler.on_init_menu_writer(bs, parameters)
            elseif hook == 'onShowTextDraw' then handler.on_show_textdraw_writer(bs, parameters)
            elseif hook == 'onVehicleStreamIn' then handler.on_vehicle_stream_in_writer(bs, parameters)
            elseif hook == 'onSetObjectMaterial' then handler.on_set_object_material_writer(bs, parameters, 1)
            elseif hook == 'onSetObjectMaterialText' then handler.on_set_object_material_writer(bs, parameters, 2) end
        end
        raknetEmulRpcReceiveBitStream(hook_table[#hook_table], bs)
        raknetDeleteBitStream(bs)
    end
end

function isValidTarget(target)
    if target == -1 then 
        return false 
    elseif type(target) == "userdata" then
        return doesCharExist(target)
    elseif type(target) == "number" then
        local result, ped = sampGetCharHandleBySampPlayerId(target)
        if result and doesCharExist(ped) then
            -- Обновляем target_keys, чтобы он хранил ped, а не число
            target_keys = ped
            return true
        else
            return false
        end
    end
    return false
end

function sampev.onDisplayGameText(style, time, text)
    if string.find(text, "RECON") then
        print(utext("DisplayGameText RECON: сброс target_keys"))
        -- Возможно, вы хотите сбрасывать target_keys только при отключении наблюдения
        -- Или делать это однократно
        if isSpectating then
            -- Не сбрасывать target_keys, если наблюдение активно
            -- Или выполнить сброс, но только один раз
            target_keys = -1
            isSpectating = false
        end
        return
    end
end
local textdrawUpdated = false

function sampev.onSpectatePlayer(playerId, camType)
    local result, ped = sampGetCharHandleBySampPlayerId(playerId)
    if result and ped then
        target_keys = ped
        print(utext("SpectatePlayer: target_keys установлен"))
    end
end

function sampev.onTogglePlayerSpectating(state)
    if not state then
        target_keys = -1
        print(utext("Наблюдение выключено"))
        isSpectating = false
    else
        print(utext("Наблюдение включено"))
    end
end

function sampev.onSpectateVehicle(vehicleId, camType)
    print(utext("onSpectateVehicle вызван") .. vehicleId .. " " .. camType)
    print(isSpectating)

    if isSpectating then return end

    lua_thread.create(function()
        wait(500)
        local resultveh, car = sampGetCarHandleBySampVehicleId(vehicleId)-- Логируем
        
        if resultveh then
            local drivercar = getDriverOfCar(car)
            print(utext("getDriverOfCar:") .. drivercar) -- Логируем
            if drivercar and doesCharExist(drivercar) then
                target_keys = drivercar
                isSpectating = true
                print(utext("SpectateVehicle: target_keys установлен" ..  target_keys))
            elseif not drivercar or not doesCharExist(drivercar) then
                print("SpectateVehicle: Водитель не найден или не существует, сброс наблюдения")
                isSpectating = false
                target_keys = -1
            end
        elseif not resultveh then
            print("SpectateVehicle: Машина не найдена, сброс наблюдения")
            isSpectating = false
            target_keys = -1
        end
    end)
end

function sampev.onPlayerSync(playerId, data)
    local result, id = sampGetPlayerIdByCharHandle(target_keys)
    if result and id == playerId then
        keys.onfoot = {}

        keys.onfoot["W"] = (data.upDownKeys == 65408) or nil
        keys.onfoot["A"] = (data.leftRightKeys == 65408) or nil
        keys.onfoot["S"] = (data.upDownKeys == 128) or nil
        keys.onfoot["D"] = (data.leftRightKeys == 128) or nil

        keys.onfoot["Alt"]   = (bit.band(data.keysData, 1024) == 1024) or nil
        keys.onfoot["Shift"] = (bit.band(data.keysData, 8) == 8) or nil
        keys.onfoot["Space"] = (bit.band(data.keysData, 32) == 32) or nil
        keys.onfoot["R"]     = (bit.band(data.keysData, 64) == 64) or nil
        keys.onfoot["F"]     = (bit.band(data.keysData, 16) == 16) or nil
        keys.onfoot["C"]     = (bit.band(data.keysData, 2) == 2) or nil

        keys.onfoot["RKM"]   = (bit.band(data.keysData, 4) == 4) or nil
        keys.onfoot["LKM"]   = (bit.band(data.keysData, 128) == 128) or nil
    end
end
function sampev.onVehicleSync(playerId, vehicleId, data)
    local result, id = sampGetPlayerIdByCharHandle(target_keys)
    if result and id == playerId then
        -- Если нужно отправить данные на транспорт, можно выполнять rpc

        keys.vehicle = {}

        keys.vehicle["W"]     = (bit.band(data.keysData, 8) == 8) or nil
        keys.vehicle["A"]     = (data.leftRightKeys == 65408) or nil
        keys.vehicle["S"]     = (bit.band(data.keysData, 32) == 32) or nil
        keys.vehicle["D"]     = (data.leftRightKeys == 128) or nil

        keys.vehicle["H"]     = (bit.band(data.keysData, 2) == 2) or nil
        keys.vehicle["Space"] = (bit.band(data.keysData, 128) == 128) or nil
        keys.vehicle["Ctrl"]  = (bit.band(data.keysData, 1) == 1) or nil
        keys.vehicle["Alt"]   = (bit.band(data.keysData, 4) == 4) or nil
        keys.vehicle["Q"]     = (bit.band(data.keysData, 256) == 256) or nil
        keys.vehicle["E"]     = (bit.band(data.keysData, 64) == 64) or nil
        keys.vehicle["F"]     = (bit.band(data.keysData, 16) == 16) or nil

        keys.vehicle["Up"]    = (data.upDownKeys == 65408) or nil
        keys.vehicle["Down"]  = (data.upDownKeys == 128) or nil
    end
end

function KeyCap(keyName, isPressed, size)
    local DL = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    local colors = {
        [true] = imgui.ImVec4(0.60, 0.60, 1.00, 1.00),
        [false] = imgui.ImVec4(0.60, 0.60, 1.00, 0.10)
    }

    if KEYCAP == nil then KEYCAP = {} end
    if KEYCAP[keyName] == nil then
        KEYCAP[keyName] = {
            status = isPressed,
            color = colors[isPressed],
            timer = nil
        }
    end

    local K = KEYCAP[keyName]
    if isPressed ~= K.status then
        K.status = isPressed
        K.timer = os.clock()
    end

    local rounding = 3.0
    local A = imgui.ImVec2(p.x, p.y)
    local B = imgui.ImVec2(p.x + size.x, p.y + size.y)
    if K.timer ~= nil then
        K.color = bringVec4To(colors[not isPressed], colors[isPressed], K.timer, 0.1)
    end
    local ts = imgui.CalcTextSize(keyName)
    local text_pos = imgui.ImVec2(p.x + (size.x / 2) - (ts.x / 2), p.y + (size.y / 2) - (ts.y / 2))

    imgui.Dummy(size)
    DL:AddRectFilled(A, B, u32(K.color), rounding)
    DL:AddRect(A, B, u32(colors[true]), rounding, 0, 1)
    DL:AddText(text_pos, 0xFFFFFFFF, keyName)
end

function bringVec4To(from, dest, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return imgui.ImVec4(
            from.x + (count * (dest.x - from.x) / 100),
            from.y + (count * (dest.y - from.y) / 100),
            from.z + (count * (dest.z - from.z) / 100),
            from.w + (count * (dest.w - from.w) / 100)
        ), true
    end
    return (timer > duration) and dest or from, false
end

function initializeRender()
    font = renderCreateFont("Tahoma", 10, FCR_BOLD + FCR_BORDER)
    font2 = renderCreateFont("Arial", 8, FCR_ITALICS + FCR_BORDER)
  end
  
  --- Functions
  function rotateCarAroundUpAxis(car, vec)
    local mat = Matrix3X3(getVehicleRotationMatrix(car))
    local rotAxis = Vector3D(mat.up:get())
    vec:normalize()
    rotAxis:normalize()
    local theta = math.acos(rotAxis:dotProduct(vec))
    if theta ~= 0 then
      rotAxis:crossProduct(vec)
      rotAxis:normalize()
      rotAxis:zeroNearZero()
      mat = mat:rotate(rotAxis, -theta)
    end
    setVehicleRotationMatrix(car, mat:get())
  end
  
  function readFloatArray(ptr, idx)
    return representIntAsFloat(readMemory(ptr + idx * 4, 4, false))
  end
  
  function writeFloatArray(ptr, idx, value)
    writeMemory(ptr + idx * 4, 4, representFloatAsInt(value), false)
  end
  
  function getVehicleRotationMatrix(car)
    local entityPtr = getCarPointer(car)
    if entityPtr ~= 0 then
      local mat = readMemory(entityPtr + 0x14, 4, false)
      if mat ~= 0 then
        local rx, ry, rz, fx, fy, fz, ux, uy, uz
        rx = readFloatArray(mat, 0)
        ry = readFloatArray(mat, 1)
        rz = readFloatArray(mat, 2)
  
        fx = readFloatArray(mat, 4)
        fy = readFloatArray(mat, 5)
        fz = readFloatArray(mat, 6)
  
        ux = readFloatArray(mat, 8)
        uy = readFloatArray(mat, 9)
        uz = readFloatArray(mat, 10)
        return rx, ry, rz, fx, fy, fz, ux, uy, uz
      end
    end
  end
  
  function setVehicleRotationMatrix(car, rx, ry, rz, fx, fy, fz, ux, uy, uz)
    local entityPtr = getCarPointer(car)
    if entityPtr ~= 0 then
      local mat = readMemory(entityPtr + 0x14, 4, false)
      if mat ~= 0 then
        writeFloatArray(mat, 0, rx)
        writeFloatArray(mat, 1, ry)
        writeFloatArray(mat, 2, rz)
  
        writeFloatArray(mat, 4, fx)
        writeFloatArray(mat, 5, fy)
        writeFloatArray(mat, 6, fz)
  
        writeFloatArray(mat, 8, ux)
        writeFloatArray(mat, 9, uy)
        writeFloatArray(mat, 10, uz)
      end
    end
  end
  
  function displayVehicleName(x, y, gxt)
    x, y = convertWindowScreenCoordsToGameScreenCoords(x, y)
    useRenderCommands(true)
    setTextWrapx(640.0)
    setTextProportional(true)
    setTextJustify(false)
    setTextScale(0.23, 0.8)
    setTextDropshadow(0, 0, 0, 0, 0)
    setTextColour(255, 0, 0, 230)
    setTextEdge(1, 0, 0, 0, 100)
    setTextFont(1)
    displayText(x, y, gxt)
  end
  
  function createPointMarker(x, y, z)
    pointMarker = createUser3dMarker(x, y, z + 0.3, 4)
  end
  
  function removePointMarker()
    if pointMarker then
      removeUser3dMarker(pointMarker)
      pointMarker = nil
    end
  end
  
  function getCarFreeSeat(car)
    if doesCharExist(getDriverOfCar(car)) then
      local maxPassengers = getMaximumNumberOfPassengers(car)
      for i = 0, maxPassengers do
        if isCarPassengerSeatFree(car, i) then
          return i + 1
        end
      end
      return nil -- no free seats
    else
      return 0 -- driver seat
    end
  end
  
  function jumpIntoCar(car)
    local seat = getCarFreeSeat(car)
    if not seat then return false end                         -- no free seats
    if seat == 0 then warpCharIntoCar(playerPed, car)         -- driver seat
    else warpCharIntoCarAsPassenger(playerPed, car, seat - 1) -- passenger seat
    end
    restoreCameraJumpcut()
    return true
  end
  
  function teleportPlayer(x, y, z)
    if isCharInAnyCar(playerPed) then
      setCharCoordinates(playerPed, x, y, z)
    end
    setCharCoordinatesDontResetAnim(playerPed, x, y, z)
  end
  
  function setCharCoordinatesDontResetAnim(char, x, y, z)
    if doesCharExist(char) then
      local ptr = getCharPointer(char)
      setEntityCoordinates(ptr, x, y, z)
    end
  end
  
  function setEntityCoordinates(entityPtr, x, y, z)
    if entityPtr ~= 0 then
      local matrixPtr = readMemory(entityPtr + 0x14, 4, false)
      if matrixPtr ~= 0 then
        local posPtr = matrixPtr + 0x30
        writeMemory(posPtr + 0, 4, representFloatAsInt(x), false) -- X
        writeMemory(posPtr + 4, 4, representFloatAsInt(y), false) -- Y
        writeMemory(posPtr + 8, 4, representFloatAsInt(z), false) -- Z
      end
    end
  end
  
function showCursor(toggle)
    if toggle then
      sampSetCursorMode(CMODE_LOCKCAM)
    else
      sampToggleCursor(false)
    end
    cursorEnabled = toggle
end

function haversine(lat1, lon1, lat2, lon2)
    local R = 6371 -- Радиус Земли в километрах
    local dLat = math.rad(lat2 - lat1)
    local dLon = math.rad(lon2 - lon1)

    local a = math.sin(dLat / 2) * math.sin(dLat / 2) +
              math.cos(math.rad(lat1)) * math.cos(math.rad(lat2)) *
              math.sin(dLon / 2) * math.sin(dLon / 2)
    
    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c -- Расстояние в километрах
end

function getGorod(ip)
    -- Проверяем входной параметр
    if not ip or ip == "" or ip == "N/A" then
        return { city = "N/A", country = "N/A", region = "N/A", isp = "N/A", latitude = "N/A", longitude = "N/A" }, "Ошибка: Неправильный Айпи адрес"
    end

    -- Проверяем кеш
    if ipData[ip] then
        return ipData[ip]
    end

    -- Формируем URL
    local url = string.format("https://ipwho.is/%s?lang=ru", ip)
    print(utext("Запрос к URL: ") .. url) -- Логируем запрос

    -- Контейнер для ответа
    local response = {}
    local _, code = https.request{
        url = url,
        sink = ltn12.sink.table(response),
    }

    -- Проверяем код ответа
    if code ~= 200 then
        return { city = "Ошибка", country = "Ошибка", region = "Ошибка", isp = "Ошибка", latitude = "Ошибка", longitude = "Ошибка" }, 
               "Ошибка: Не удалось получить данные. Код ответа: " .. tostring(code)
    end

    -- Объединяем части ответа в строку
    local data = table.concat(response)
    print("Ответ от сервера: " .. data) -- Логируем полученные данные

    -- Парсим JSON
    local success, parsedData = pcall(json.decode, data)
    if not success or not parsedData then
        return { city = "Ошибка", country = "Ошибка", region = "Ошибка", isp = "Ошибка", latitude = "Ошибка", longitude = "Ошибка" }, 
               "Ошибка: Не удалось разобрать JSON. Данные ответа: " .. tostring(data)
    end

    -- Извлекаем данные
    local result = {
        region = parsedData.region or "Неизвестный регион",
        country = parsedData.country or "Неизвестная страна",
        city = parsedData.city or "Неизвестный город",
        isp = parsedData.connection and parsedData.connection.isp or "Неизвестная организация",
        latitude = parsedData.latitude or "Неизвестная широта",
        longitude = parsedData.longitude or "Неизвестная долгота"
    }

    -- Кешируем данные
    ipData[ip] = result

    return result
end

function getVPN(ip)
    -- Проверяем входной параметр
    if not ip or ip == "" or ip == "N/A" then
        return { proxy = "N/A", type = "N/A", risk = "N/A" }, "Ошибка: Неправильный Айпи адрес"
    end

    if vpnData[ip] then
        return vpnData[ip]
    end

    -- Формируем URL
    local url = string.format("https://proxycheck.io/v2/%s?key=422p28-2r1189-49240e-900390&vpn=1&risk=1", ip)
    print(utext("Запрос к URL: ") .. url) -- Логируем URL для отладки

    -- Создаем контейнер для ответа
    local response = {}
    local _, code = https.request{
        url = url,
        sink = ltn12.sink.table(response),
    }

    -- Проверяем код ответа
    if code ~= 200 then
        return { proxy = "Ошибка", type = "Ошибка", risk = "Ошибка" },
            "Ошибка: Не удалось получить данные. Код ответа: " .. tostring(code)
    end

    -- Объединяем части ответа в строку
	local data = table.concat(response)
    print("Ответ от сервера: " .. data) -- Логируем полученные данные

    -- Парсим JSON

    local success, parsedData = pcall(json.decode, data)
    if not success then
        return { proxy = "Ошибка", type = "Ошибка", risk = "Ошибка" },
            "Ошибка: Не удалось разобрать JSON. Проверьте данные ответа: " .. tostring(data)
    end

	local ipData = parsedData[ip]
    if not ipData then
        return { proxy = "Ошибка", type = "Ошибка", risk = "Ошибка" },
            "Ошибка: В ответе отсутствуют данные для указанного IP."
    end

    local result = {
		proxy = ipData.proxy or "Неизвестный vpn",
		type = ipData.type or "Неизвестный тип",
		provider = ipData.provider or "Неизвестный провайдер",
		risk = ipData.risk or "Неизвестный риск",
    }

    vpnData[ip] = result

    return result
end

------------------------------------------------------------------------------------------------
-------------------------------------------Функции----------------------------------------------
------------------------------------------------------------------------------------------------
imgui.OnInitialize(function()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local path = getFolderPath(0x14) .. '\\trebucbd.ttf'
    imgui.GetIO().Fonts:Clear() -- Удаляем стандартный шрифт на 14
    imgui.GetIO().Fonts:AddFontFromFileTTF(path, 15.0, nil, glyph_ranges) -- этот шрифт на 15 будет стандартным
    font_25 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 25.0, nil, glyph_ranges)
    font_40 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 40.0, nil, glyph_ranges)
    theme.change()
    style.change()
    sW, sH = getScreenResolution()
	u32 = imgui.ColorConvertFloat4ToU32
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
end)

local Frame = imgui.OnFrame(
    function() return isSampAvailable() and not sampIsScoreboardOpen() and sampGetChatDisplayMode() == 2 and not isPauseMenuActive() end,
    function(self)
        self.HideCursor = not imgui.IsPopupOpen(('%s ( %s )'):format(PlayerPopup.name, PlayerPopup.id))
        local DL = imgui.GetBackgroundDrawList()
        for _, ped in ipairs(getAllChars()) do
            if ped ~= PLAYER_PED then
                local result, id = sampGetPlayerIdByCharHandle(ped)
                if result then
                    local x, y, z = getCharCoordinates(ped)
                    local radarSpace = imgui.ImVec2(TransformRealWorldPointToRadarSpace(x, y))
                    if IsPointInsideRadar(radarSpace.x, radarSpace.y) then
                        local screenSpace = imgui.ImVec2(TransformRadarPointToScreenSpace(radarSpace.x, radarSpace.y))
                        local textSize = imgui.CalcTextSize(tostring(id))
                        local pos = imgui.ImVec2(screenSpace.x - textSize.x / 2, screenSpace.y)
                        local a, r, g, b = explode_argb(sampGetPlayerColor(id))
                        local PlayerColorVec4 = imgui.ImVec4(r / 255, g / 255, b / 255, 1)
                        DL:AddText(imgui.ImVec2(pos.x - 2, pos.y - 1), 0xCC000000, tostring(id))
                        DL:AddText(imgui.ImVec2(pos.x + 2, pos.y + 1), 0xCC000000, tostring(id))
                        DL:AddText(imgui.ImVec2(pos.x - 2, pos.y + 1), 0xCC000000, tostring(id))
                        DL:AddText(imgui.ImVec2(pos.x + 2, pos.y - 1), 0xCC000000, tostring(id))
                        DL:AddText(pos, imgui.GetColorU32Vec4(PlayerColorVec4), tostring(id))
                        if sampIsCursorActive() then
                            local cur = imgui.ImVec2(getCursorPos())
                            if cur.x >= pos.x and cur.x <= pos.x + textSize.x then
                                if cur.y >= pos.y and cur.y <= pos.y + textSize.y then
                                    DL:AddRect(imgui.ImVec2(pos.x - 2, pos.y - 1), imgui.ImVec2(pos.x + textSize.x, pos.y + textSize.y + 1), 0xFFffffff, 5)--, int rounding_corners_flags = ~0, float thickness = 1.0f)
                                    imgui.PushStyleColor(imgui.Col.Border, PlayerColorVec4)
                                    imgui.BeginTooltip()
                                    imgui.TextColored(PlayerColorVec4, 'ID: ')      imgui.SameLine(35) imgui.Text(tostring(id))
                                    imgui.TextColored(PlayerColorVec4, 'NICK:  ')    imgui.SameLine(50) imgui.Text(sampGetPlayerNickname(id) or 'none')
                                    imgui.TextColored(PlayerColorVec4, 'LVL:  ')     imgui.SameLine(45) imgui.Text(tostring(sampGetPlayerScore(id)) or 'none')
                                    imgui.TextColored(PlayerColorVec4, 'PING:  ')    imgui.SameLine(50) imgui.Text(tostring(sampGetPlayerPing(id)) or 'none')
                                    imgui.EndTooltip()
                                    
                                    imgui.PopStyleColor()
                                    if wasKeyPressed(VK_LBUTTON) then
                                        if id then
                                            PlayerPopup = { 
                                                id = tostring(id), 
                                                nick = sampGetPlayerNickname(id) or 'none', 
                                                lvl = tostring(sampGetPlayerScore(id)), 
                                                ping = tostring(sampGetPlayerPing(id)),
                                            }
                                            imgui.OpenPopup(('%s ( %s )'):format(PlayerPopup.nick, PlayerPopup.id))
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if imgui.BeginPopupModal(('%s ( %s )'):format(PlayerPopup.nick, PlayerPopup.id), nil, imgui.WindowFlags.AlwaysAutoResize  + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse) then 
            local size = imgui.ImVec2(230, 390)
            imgui.SetWindowSizeVec2(size)
            imgui.SetCursorPos(imgui.ImVec2(5, 25))
            if imgui.BeginChild('commands', imgui.ImVec2(size.x+10, size.y - 80), false) then
                for _, command in ipairs(AdminCommands) do
                    imgui.SetCursorPosX(5)
                    local cmd = select(1, command:gsub('{id}', PlayerPopup.id):gsub('{nick}', PlayerPopup.nick))
                    if imgui.Button(cmd, imgui.ImVec2(size.x)) then
                        sampSendChat(cmd)
                        imgui.CloseCurrentPopup()
                    end
                end
                imgui.EndChild()
            end
            
            imgui.SetCursorPos(imgui.ImVec2(10, size.y-29))
            if imgui.Button('Закрыть', imgui.ImVec2(size.x)) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup() 
        end
    end
)


local spectateSyncKeys = imgui.OnFrame(
    function() 
        return target_keys ~= nil and target_keys ~= -1 and doesCharExist(target_keys)
    end,
    function(self)
        self.HideCursor = true
        imgui.SetNextWindowPos(imgui.ImVec2(sW / 1.16, sH - 90), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
        imgui.Begin("##KEYS", nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize)
        if pcall(isCharOnFoot, target_keys) then  -- Проверяем, можно ли вызвать функцию без ошибки
            plState = isCharOnFoot(target_keys) and "onfoot" or "vehicle"
        end
            imgui.BeginGroup()
                imgui.SetCursorPosX(10 + 30 + 5)
                KeyCap("W", (keys[plState]["W"] ~= nil), imgui.ImVec2(30, 30))
                KeyCap("A", (keys[plState]["A"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                KeyCap("S", (keys[plState]["S"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                KeyCap("D", (keys[plState]["D"] ~= nil), imgui.ImVec2(30, 30))
            imgui.EndGroup()
            imgui.SameLine(nil, 20)

            if plState == "onfoot" then
                imgui.BeginGroup()
                    KeyCap("Shift", (keys[plState]["Shift"] ~= nil), imgui.ImVec2(75, 30))
                    imgui.SameLine()
                    KeyCap("Alt", (keys[plState]["Alt"] ~= nil), imgui.ImVec2(55, 30))
                    KeyCap("Space", (keys[plState]["Space"] ~= nil), imgui.ImVec2(135, 30))
                imgui.EndGroup()
                imgui.SameLine()
                imgui.BeginGroup()
                    KeyCap("C", (keys[plState]["C"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("F", (keys[plState]["F"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("R", (keys[plState]["R"] ~= nil), imgui.ImVec2(30, 30))
                    KeyCap("RM", (keys[plState]["RKM"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("LM", (keys[plState]["LKM"] ~= nil), imgui.ImVec2(30, 30))
                imgui.EndGroup()
            else
                imgui.BeginGroup()
                    KeyCap("Ctrl", (keys[plState]["Ctrl"] ~= nil), imgui.ImVec2(65, 30))
                    imgui.SameLine()
                    KeyCap("Alt", (keys[plState]["Alt"] ~= nil), imgui.ImVec2(65, 30))
                    KeyCap("Space", (keys[plState]["Space"] ~= nil), imgui.ImVec2(135, 30))
                imgui.EndGroup()
                imgui.SameLine()
                imgui.BeginGroup()
                    KeyCap("Up", (keys[plState]["Up"] ~= nil), imgui.ImVec2(40, 30))
                    KeyCap("Down", (keys[plState]["Down"] ~= nil), imgui.ImVec2(40, 30))
                imgui.EndGroup()
                imgui.SameLine()
                imgui.BeginGroup()
                    KeyCap("H", (keys[plState]["H"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("F", (keys[plState]["F"] ~= nil), imgui.ImVec2(30, 30))
                    KeyCap("Q", (keys[plState]["Q"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("E", (keys[plState]["E"] ~= nil), imgui.ImVec2(30, 30))
                imgui.EndGroup()
            end
        imgui.End()
    end
)

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    print("DialogId: " .. dialogId .. " Title: " .. title .. " Text: " .. text)
    if dialogId == 0 then
        nick, id, regip, regcountry, regcity, regisp, currentip, currentcounrty, currentcity, currentisp =
            text:match(utext("Проверка игрока: (.+)%[(%d+)%].-IP при регистрации: (%d+%.%d+%.%d+%.%d+).-Страна при регистрации: (.-)\nГород при регистрации: (.-)\nПровайдер при регистрации: (.-)\nТекущий IP: (%d+%.%d+%.%d+%.%d+).-Текущая страна: (.-)\nТекущий город: (.-)\nТекущий провайдер: (.+)"))
        if nick then
            RINFO[0] = true
            local regData = getGorod(regip)
            local currentData = getGorod(currentip)
            APIregcountry = regData.country
            APIregcity = regData.city
            APIregisp = regData.isp

            if regData and currentData and regData.latitude and currentData.latitude then
                APIdistance = haversine(
                    tonumber(regData.latitude), tonumber(regData.longitude),
                    tonumber(currentData.latitude), tonumber(currentData.longitude)
                )
            else
                print("Ошибка: не удалось получить координаты городов")
            end

            APIcurrentcountry = currentData.country
            APIcurrentcity = currentData.city
            APIcurrentisp = currentData.isp

            local VPNregData = getVPN(regip)
            local VPNcurrentData = getVPN(currentip)

            if VPNregData.proxy == "no" then
                VPNregData.proxy = "VPN не найден"
            else
                VPNregData.proxy = "VPN найден"
            end
            
            APIregvpn = VPNregData.proxy
            APIregrisk = VPNregData.risk
            APIcurrentvpn = VPNcurrentData.proxy
            APIcurrentrisk = VPNcurrentData.risk
        end
    end
end

imgui.OnFrame(function() return RINFO[0] end, function(player)
    player.HideCursor = false
    sampCloseCurrentDialogWithButton(0)
    imgui.SetNextWindowSize(imgui.ImVec2(900, 420), imgui.Cond.FirstUseEver)
    imgui.Begin('RegInfo', RINFO, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)

    -- Заголовок с ником и ID
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "Player: " .. (nick and nick:gsub("{......}", "") or "N/A") .. " [" .. (id or "N/A") .. "]")
    imgui.Separator()

    -- Настройка колонок
    imgui.Columns(5, 'RinfoColumns', true)
    imgui.SetColumnWidth(0, 120)
    imgui.SetColumnWidth(1, 180)
    imgui.SetColumnWidth(2, 180)
    imgui.SetColumnWidth(3, 180)
    imgui.SetColumnWidth(4, 180)

    -- Заголовки
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "Параметр")
    imgui.NextColumn()
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "API рег. данные")
    imgui.NextColumn()
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "API текущие данные")
    imgui.NextColumn()
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "Рег. данные")
    imgui.NextColumn()
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "Текущие данные")
    imgui.NextColumn()
    
    imgui.Separator()

    -- Функция для удобного добавления строк
    local function addRow(label, apiValue1, apiValue2, serverValue1, serverValue2)
        imgui.Separator()
        imgui.Text(label or "N/A")
        imgui.NextColumn()
        imgui.Text(apiValue1 or "N/A")
        imgui.NextColumn()
        imgui.Text(apiValue2 or "N/A")
        imgui.NextColumn()
        imgui.Text(serverValue1 or "N/A")
        imgui.NextColumn()
        imgui.Text(serverValue2 or "N/A")
        imgui.NextColumn()
    end

    -- Вставка данных (API остаётся пустым)
    addRow("IP-адрес", regip, currentip, regip, currentip)
    addRow("Страна", APIregcountry, APIcurrentcountry, regcountry, currentcounrty)
    addRow("Город", APIregcity, APIcurrentcity, regcity, currentcity)
    addRow("Провайдер", APIregisp, APIcurrentisp, regisp, currentisp)
    addRow("VPN", APIregvpn .. "\nВероятность VPN: " .. APIregrisk, APIcurrentvpn .. "\nВероятность VPN: " .. APIcurrentrisk, "N/A", "N/A")

    imgui.Columns(1)
    if imgui.Button("Мульти-аккаунты текущего IP") then
        sampSendChat("/lip " .. currentip)
        RINFO[0] = false
    end
    imgui.SameLine()
    if imgui.Button("Мульти-аккаунты рег. IP") then
        sampSendChat("/lip " .. regip)
        RINFO[0] = false
    end
    if imgui.Button("Забанить текущий IP") then
        sampSendChat("/banip " .. currentip)
        RINFO[0] = false
    end
    imgui.SameLine()
    if imgui.Button("Забанить рег. IP") then
        sampSendChat("/banip " .. regip)
        RINFO[0] = false
    end
    imgui.SameLine()
    if imgui.Button("Забанить IP через /abanip") then
        sampSendChat("/abanip " .. id)
        RINFO[0] = false
    end
    imgui.SameLine()
    if imgui.Button("Забанить тот и тот IP") then
        sampSendChat("/banip " .. currentip)
        sampSendChat("/banip " .. regip)
        RINFO[0] = false
    end

    imgui.PushFont(font_25)
        imgui.Text("\n\t\t\t\t\t\t\t\t\tРасстояние между городами: " .. APIdistance .. " км")
    imgui.PopFont()
    imgui.End()
end)


imgui.OnFrame(function() return SettingsState[0] end, function(player)
    player.HideCursor = false
    imgui.SetNextWindowSize(imgui.ImVec2(750, 420), imgui.Cond.FirstUseEver)
    imgui.Begin('ChatSettings', SettingsState, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
    if imgui.BeginTabBar('Tabs') then
        if imgui.BeginTabItem('Основное') then
            createChatToggleButton('chat', 'чат')
            if ini.cmd.chat then
                createChatToggleButton('achat', 'A-чат')
                imgui.SameLine()
                createChatToggleButton('banchat', 'Бан-чат')
                createChatToggleButton('mutechat', 'Мут-чат')
                imgui.SameLine()
                createChatToggleButton('kickchat', 'Кик-чат')
                createChatToggleButton('warnchat', 'Варн-чат')
                imgui.SameLine()
                createChatToggleButton('awarnchat', 'Аварн-чат')
                createChatToggleButton('amutechat', 'Амут-чат')
                imgui.SameLine()
                createChatToggleButton('jailchat', 'Джайл-чат')
                createChatToggleButton('successchat', 'Success-чат')
                imgui.SameLine()
                createChatToggleButton('unknownchat', 'Unknown-чат')
                createChatToggleButton('itemchat', 'Additem-чат')
                imgui.SameLine()
                createChatToggleButton('ditemchat', 'Delitem-чат')
                createChatToggleButton('botchat', 'Бот-чат')
            end
            imgui.EndTabItem()
        end
        if imgui.BeginTabItem('Цвета') then
            createChatPopup({ buttonText = 'A-чат', popupName = 'aColor' }, aChatSettings)
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.TextColoredRGB(string.format(utext('{ffffff}Сейчас выглядит так:%s Игрок%s Test_Test[0]%s использовал команду:%s /a test'), ini.chat.aChatColor, ini.chat.aNickChatColor, ini.chat.aChatColor, ini.chat.aCmdChatColor))
                imgui.EndTooltip()
            end
            imgui.SameLine()


            createChatPopup({ buttonText = 'Бан-чат', popupName = 'BanColor' }, banChatSettings)
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.TextColoredRGB(string.format(utext('{ffffff}Сейчас выглядит так:%s Вас попытался забанить%s Test_Test[0]%s на %s1 %sдн. по причине:%s test'), ini.chat.banChatColor, ini.chat.banNickChatColor, ini.chat.banChatColor, ini.chat.banCmdChatColor, ini.chat.banChatColor, ini.chat.banCmdChatColor))
                imgui.EndTooltip()
            end


            createChatPopup({ buttonText = 'Мут-чат', popupName = 'MuteColor' }, muteChatSettings)
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.TextColoredRGB(string.format(utext('{ffffff}Сейчас выглядит так:%s Вас попытался замутить%s Test_Test[0]%s на %s1 %sм. по причине:%s test'), ini.chat.muteChatColor, ini.chat.muteNickChatColor, ini.chat.muteChatColor, ini.chat.muteCmdChatColor, ini.chat.muteChatColor, ini.chat.muteCmdChatColor))
                imgui.EndTooltip()
            end
            imgui.SameLine()


            createChatPopup({ buttonText = 'Кик-чат', popupName = 'KickColor' }, kickChatSettings)
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.TextColoredRGB(string.format(utext('{ffffff}Сейчас выглядит так:%s Вас попытался кикнуть%s Test_Test[0]%s по причине:%s test'), ini.chat.kickChatColor, ini.chat.kickNickChatColor, ini.chat.kickChatColor, ini.chat.kickCmdChatColor))
                imgui.EndTooltip()
            end


            createChatPopup({ buttonText = 'Варн-чат', popupName = 'WarnColor' }, warnChatSettings)
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.TextColoredRGB(string.format(utext('{ffffff}Сейчас выглядит так:%s Вас попытался заварнить%s Test_Test[0]%s по причине:%s test'), ini.chat.warnChatColor, ini.chat.warnNickChatColor, ini.chat.warnChatColor, ini.chat.warnCmdChatColor))
                imgui.EndTooltip()
            end
            imgui.SameLine()


            createChatPopup({ buttonText = 'Аварн-чат', popupName = 'AwarnColor' }, awarnChatSettings)
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.TextColoredRGB(string.format(utext('{ffffff}Сейчас выглядит так:%s Вас попытался A-заварнить%s Test_Test[0]%s по причине:%s test'), ini.chat.awarnChatColor, ini.chat.awarnNickChatColor, ini.chat.awarnChatColor, ini.chat.awarnCmdChatColor))
                imgui.EndTooltip()
            end


            createChatPopup({ buttonText = 'Амут-чат', popupName = 'AmuteColor' }, amuteChatSettings)
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.TextColoredRGB(string.format(utext('{ffffff}Сейчас выглядит так:%s Вас попытался замутить в админ чате%s Test_Test[0]%s на %s1 %sм. по причине:%s test'), ini.chat.amuteChatColor, ini.chat.amuteNickChatColor, ini.chat.amuteChatColor, ini.chat.amuteCmdChatColor, ini.chat.amuteChatColor, ini.chat.amuteCmdChatColor))
                imgui.EndTooltip()
            end
            imgui.SameLine()


            createChatPopup({ buttonText = 'Джайл-чат', popupName = 'JailColor' }, jailChatSettings)
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.TextColoredRGB(string.format(utext('{ffffff}Сейчас выглядит так:%s Вас попытался заджайлить%s Test_Test[0]%s на %s1 %sм. по причине:%s test'), ini.chat.jailChatColor, ini.chat.jailNickChatColor, ini.chat.jailChatColor, ini.chat.jailCmdChatColor, ini.chat.jailChatColor, ini.chat.jailCmdChatColor))
                imgui.EndTooltip()
            end


            createChatPopup({ buttonText = 'Success-чат', popupName = 'SuccessColor' }, successChatSettings)
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.TextColoredRGB(string.format(utext('{ffffff}Сейчас выглядит так:%s Игрок%s Mark_Brulend[0]%s использовал команду:%s /veh 520 1 1'), ini.chat.successChatColor, ini.chat.successNickChatColor, ini.chat.successChatColor, ini.chat.successCmdChatColor))
                imgui.EndTooltip()
            end
            imgui.SameLine()



            createChatPopup({ buttonText = 'Unknown-чат', popupName = 'UnknownColor' }, unknownChatSettings)
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.TextColoredRGB(string.format(utext('{ffffff}Сейчас выглядит так:%s Игрок%s Denis_Angelov[0]%s неудачно использовал команду:%s /ofban Andrey_Holkin 2000 Теперь это мой сервер'), ini.chat.unknownChatColor, ini.chat.unknownNickChatColor, ini.chat.unknownChatColor, ini.chat.unknownCmdChatColor))
                imgui.EndTooltip()
            end


            createChatPopup({ buttonText = 'Additem-чат', popupName = 'AdditemColor' }, addItemChatSettings)
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.TextColoredRGB(string.format(utext('{ffffff}Сейчас выглядит так:%s Игрок%s Test_Test[0]%s получил предмет [{ff0000}Талон Репутации[538]%s] (%s100 шт.%s)'), ini.chat.itemChatColor, ini.chat.itemNickChatColor, ini.chat.itemChatColor, ini.chat.itemChatColor, ini.chat.itemShtChatColor, ini.chat.itemChatColor))
                imgui.EndTooltip()
            end
            imgui.SameLine()


            createChatPopup({ buttonText = 'Delitem-чат', popupName = 'DelitemColor' }, delItemChatSettings)
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.TextColoredRGB(string.format(utext('{ffffff}Сейчас выглядит так:%s Игрок%s Test_Test[0]%s удалил предмет [{ff0000}Талон Репутации[538]%s] (%s100 шт.%s)'), ini.chat.dItemChatColor, ini.chat.dItemNickChatColor, ini.chat.dItemChatColor, ini.chat.dItemChatColor, ini.chat.dItemShtChatColor, ini.chat.dItemChatColor))
                imgui.EndTooltip()
            end


            createChatPopup({ buttonText = 'Бот-чат', popupName = 'BotColor' }, botChatSettings)
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.TextColoredRGB(string.format(utext('{ffffff}Сейчас выглядит так:%s [BOT]%s Harry_Test[0]:%s Мой хозяин топ! Кто не согласен бан'), ini.chat.botPrefixChatColor, ini.chat.botNickChatColor, ini.chat.botChatColor))
                imgui.EndTooltip()
            end
            imgui.EndTabItem()
        end
        if imgui.BeginTabItem('Настройки') then
            imgui.TextColoredRGB(utext('{ffffff}Бинд для открытия этого меню'))
            if bind:GetHotKey() then
                if bind:ShowHotKey() then
                    ini.bind.SettingKey = encodeJson(bind:GetHotKey())
                    inicfg.save(ini, IniFilename)
                end
                imgui.SameLine()
                if imgui.Button("Удалить бинд") then
                    bind:RemoveHotKey(bind:GetHotKey())
                    ini.bind.SettingKey = "{}"
                    inicfg.save(ini, IniFilename)
                end
            else
                if imgui.Button("Создать бинд") then
                    bind = hotkey.RegisterHotKey('myBind', false, decodeJson("{}"), bindCallback)
                    ini.bind.SettingKey = encodeJson(bind:GetHotKey())
                    inicfg.save(ini, IniFilename)
                end
            end
            imgui.TextColoredRGB(utext("{ffffff}Чтобы удалить бинд нажмите 'Удалить бинд' или нажмите Backspace"))
            if imgui.InputText("Команда для открытия", inputText, sizeof(inputText)) then
                local newCommand = str(inputText)
                if newCommand ~= currentCommand then
                    sampUnregisterChatCommand(currentCommand)
                    ini.bind.cmd = newCommand
                    inicfg.save(ini, IniFilename)
                    sampRegisterChatCommand(newCommand, function()
                        SettingsState[0] = not SettingsState[0]
                    end)
                    currentCommand = newCommand
                end
            end
            imgui.EndTabItem()
        end
    end
end)


function main()
    
    if not isSampLoaded() and not isSampfuncsLoaded() then return end
    initializeRender()
    while not isSampAvailable() do wait(100) end
    sampRegisterChatCommand(ini.bind.cmd, function()
        SettingsState[0] = not SettingsState[0]
    end)
    repeat wait(10) until sampIsLocalPlayerSpawned()
    sampRegisterChatCommand('inv', function()
        spec = not spec
        nopPlayerSync = not nopPlayerSync
        if spec then
            sampAddChatMessage(utext("Невидимка {00ff00}включена"), -1)
        else
            sampAddChatMessage(utext("Невидимка {ff0000}выключена"), -1)
        end
    end)
    sampRegisterChatCommand('check', function(ip)
        if ip and ip:match("^%d+%.%d+%.%d+%.%d+$") then -- Проверяем, что аргумент является корректным IP-адресом
            local gorod = getGorod(ip)
            local vpn = getVPN(ip)
            if gorod then
                sampAddChatMessage(string.format(utext("Город: %s, Страна: %s, Регион: %s, Провайдер: %s"), 
                    utext(gorod.city), utext(gorod.country), utext(gorod.region), utext(gorod.isp)), -1)
            end
            if vpn then
                sampAddChatMessage(string.format(utext("VPN: %s, Тип: %s, Риск: %s"), 
                    utext(vpn.proxy), utext(vpn.type), utext(vpn.risk)), -1)
            end
        else
            sampAddChatMessage(utext("Использование: /check [IP-адрес]"), -1)
            sampAddChatMessage(utext("Пример: /check 8.8.8.8"), -1)
        end
    end)
    sampRegisterChatCommand('checker', function()
        sampAddChatMessage(utext("Чекер работает"), -1)
    end)
    bind = hotkey.RegisterHotKey('myBind', false, bindKeys, bindCallback)
    while true do
        while isPauseMenuActive() do
            if cursorEnabled then
            showCursor(false)
            end
            wait(100)
        end
        if isKeyDown(keyToggle) then
            cursorEnabled = not cursorEnabled
            showCursor(cursorEnabled)
            while isKeyDown(keyToggle) do wait(80) end
        end
        if cursorEnabled and not SettingsState[0] and not RINFO[0] then
            local mode = sampGetCursorMode()
            if mode == 0 then
            showCursor(true)
            end
            local sx, sy = getCursorPos()
            local sw, sh = getScreenResolution()
            -- is cursor in game window bounds?
            if sx >= 0 and sy >= 0 and sx < sw and sy < sh then
            local posX, posY, posZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
            local camX, camY, camZ = getActiveCameraCoordinates()
            -- search for the collision point
            local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, true, true, false, true, false, false, false)
            if result and colpoint.entity ~= 0 then
                local normal = colpoint.normal
                local pos = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
                local zOffset = 300
                if normal[3] >= 0.5 then zOffset = 1 end
                -- search for the ground position vertically down
                local result, colpoint2 = processLineOfSight(pos.x, pos.y, pos.z + zOffset, pos.x, pos.y, pos.z - 0.3,
                true, true, false, true, false, false, false)
                if result then
                pos = Vector3D(colpoint2.pos[1], colpoint2.pos[2], colpoint2.pos[3] + 1)
    
                local curX, curY, curZ  = getCharCoordinates(playerPed)
                local dist              = getDistanceBetweenCoords3d(curX, curY, curZ, pos.x, pos.y, pos.z)
                local hoffs             = renderGetFontDrawHeight(font)
    
                sy = sy - 2
                sx = sx - 2
                renderFontDrawText(font, string.format("%0.2fm", dist), sx, sy - hoffs, 0xEEEEEEEE)
    
                local tpIntoCar = nil
                if colpoint.entityType == 2 then
                    local car = getVehiclePointerHandle(colpoint.entity)
                    if doesVehicleExist(car) and (not isCharInAnyCar(playerPed) or storeCarCharIsInNoSave(playerPed) ~= car) then
                    displayVehicleName(sx, sy - hoffs * 2, getNameOfVehicleModel(getCarModel(car)))
                    local color = 0xAAFFFFFF
                    if isKeyDown(VK_RBUTTON) then
                        tpIntoCar = car
                        color = 0xFF00FF00
                    end
                    renderFontDrawText(font2, "Hold right mouse button to teleport into the car", sx, sy - hoffs * 3, color)
                    end
                end
    
                createPointMarker(pos.x, pos.y, pos.z)
    
                -- teleport!
                if isKeyDown(keyApply) then
                    if tpIntoCar then
                    if not jumpIntoCar(tpIntoCar) then
                        -- teleport to the car if there is no free seats
                        teleportPlayer(pos.x, pos.y, pos.z)
                    end
                    else
                    if isCharInAnyCar(playerPed) then
                        local norm = Vector3D(colpoint.normal[1], colpoint.normal[2], 0)
                        local norm2 = Vector3D(colpoint2.normal[1], colpoint2.normal[2], colpoint2.normal[3])
                        rotateCarAroundUpAxis(storeCarCharIsInNoSave(playerPed), norm2)
                        pos = pos - norm * 1.8
                        pos.z = pos.z - 0.8
                    end
                    teleportPlayer(pos.x, pos.y, pos.z)
                    end
                    removePointMarker()
    
                    while isKeyDown(keyApply) do wait(0) end
                    showCursor(false)
                end
                end
            end
            end
        end
        wait(0)
        removePointMarker()
    end
end

function sampev.onServerMessage(color, text)
    if ini.cmd.chat then
        local BotNick = "Harry_Test"
        local BotID = sampGetPlayerIdByNickname(BotNick)
        local myID = select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))
        local myNick = sampGetPlayerNickname(myID)

        if text:find(utext("%[A%] " .. myNick .. "%[" .. myID .. "%] начал наблюдение за (.+)%[(%d+)%]")) then
            local nickSpec, idSpec = text:match(utext("%[A%] " .. myNick .. "%[" .. myID .. "%] начал наблюдение за (.+)%[(%d+)%]"))
            target_keys = idSpec
            print(idSpec)
        end

        if text:find(utext("%[%+%] (.+)%[(%d+)%] success command: (.+)")) then
            local nick, id, cmd = text:match(utext("%[%+%] (.+)%[(%d+)%] success command: (.+)"))
            if cmd:find("/a (.+)") or cmd:find("/a") then
                if ini.cmd.achat then
                    ACM(string.format(utext("%sИгрок%s %s[%d]%s использовал команду:%s %s"), ini.chat.aChatColor, ini.chat.aNickChatColor, nick, id, ini.chat.aChatColor, ini.chat.aCmdChatColor, cmd))
                    return false
                else
                    return true
                end
            end
            if cmd:find("/ban (%d+) (%d+) (.+)") then
                local id1, time, reasone = text:match(utext("/ban (%d+) (%d+) (.+)"))
                if tonumber(id1) == myID then
                    if ini.cmd.banchat then
                        ACM(string.format(utext("%sВас попытался забанить%s %s[%d]%s на%s %s %sдн. по причине:%s %s"), ini.chat.banChatColor, ini.chat.banNickChatColor, nick, id, ini.chat.banChatColor, ini.chat.banCmdChatColor, time, ini.chat.banChatColor, ini.chat.banCmdChatColor, reasone))
                        return false
                    else
                        return true
                    end
                end
            end
            if cmd:find("/mute (%d+) (%d+) (.+)") then
                local id1, time, reasone = text:match(utext("/mute (%d+) (%d+) (.+)"))
                if tonumber(id1) == myID then
                    if ini.cmd.mutechat then
                        ACM(string.format(utext("%sВас попытался замутить%s %s[%d]%s на%s %s %sм. по причине:%s %s"), ini.chat.muteChatColor, ini.chat.muteNickChatColor, nick, id, ini.chat.muteChatColor, ini.chat.muteCmdChatColor, time, ini.chat.muteChatColor, ini.chat.muteCmdChatColor, reasone))
                        return false
                    else
                        return true
                    end
                end
            end
            if cmd:find("/kick (%d+) (.+)") then
                local id1, reasone = text:match(utext("/kick (%d+) (.+)"))
                if tonumber(id1) == myID then
                    if ini.cmd.kickchat then
                        ACM(string.format(utext("%sВас попытался кикнуть%s %s[%d]%s по причине:%s %s"), ini.chat.kickChatColor, ini.chat.kickNickChatColor, nick, id, ini.chat.kickChatColor, ini.chat.kickCmdChatColor, reasone))
                        return false
                    else
                        return true
                    end
                end
            end
            if cmd:find("/warn (%d+) (.+)") then
                local id1, reasone = text:match(utext("/warn (%d+) (.+)"))
                if tonumber(id1) == myID then
                    if ini.cmd.warnchat then
                        ACM(string.format(utext("%sВас попытался заварнить%s %s[%d]%s по причине:%s %s"), ini.chat.warnChatColor, ini.chat.warnNickChatColor, nick, id, ini.chat.warnChatColor, ini.chat.warnCmdChatColor, reasone))
                        return false
                    else
                        return true
                    end
                end
            end
            if cmd:find("/awarn (%d+) (.+)") then
                local id1, reasone = text:match(utext("/awarn (%d+) (.+)"))
                if tonumber(id1) == myID then
                    if ini.cmd.awarnchat then
                        ACM(string.format(utext("%sВас попытался A-заварнить%s %s[%d]%s по причине:%s %s"), ini.chat.awarnChatColor, ini.chat.awarnNickChatColor, nick, id, ini.chat.awarnChatColor, ini.chat.awarnCmdChatColor, reasone))
                        return false
                    else
                        return true
                    end
                end
            end
            if cmd:find("/amute (%d+) (%d+) (.+)") then
                local id1, time, reasone = text:match(utext("/amute (%d+) (%d+) (.+)"))
                if tonumber(id1) == myID then
                    if ini.cmd.amutechat then
                        ACM(string.format(utext("%sВас попытался замутить в админ-чате%s %s[%d]%s на%s %s %sм. по причине:%s %s"), ini.chat.amuteChatColor, ini.chat.amuteNickChatColor, nick, id, ini.chat.amuteChatColor, ini.chat.amuteCmdChatColor, time, ini.chat.amuteChatColor, ini.chat.amuteCmdChatColor, reasone))
                        return false
                    else
                        return true
                    end
                end
            end
            if cmd:find("/jail (%d+) (%d+) (.+)") then
                local id1, time, reasone = text:match(utext("/jail (%d+) (%d+) (.+)"))
                if tonumber(id1) == myID then
                    if ini.cmd.jailchat then
                        ACM(string.format(utext("%sВас попытался заджайлить%s %s[%d]%s на%s %s %sм. по причине:%s %s"), ini.chat.jailChatColor, ini.chat.jailNickChatColor, nick, id, ini.chat.jailChatColor, ini.chat.jailCmdChatColor, time, ini.chat.jailChatColor, ini.chat.jailCmdChatColor, reasone))
                        return false
                    else
                        return true
                    end
                end
            end
            if nick ~= "Harry_Test" then
                if ini.cmd.successchat then
                    ACM(string.format(utext("%sИгрок%s %s[%d]%s использовал команду:%s %s"), ini.chat.successChatColor, ini.chat.successNickChatColor, nick, id, ini.chat.successChatColor, ini.chat.successCmdChatColor, cmd))
                    return false
                else
                    return true
                end
            else
                if ini.cmd.successchat then
                    return false
                else
                    return true
                end
            end
        end
        if text:find(utext("%[!%] (.+)%[(%d+)%] unknown command: (.+)")) then
            local nick, id, cmd = text:match(utext("%[!%] (.+)%[(%d+)%] unknown command: (.+)"))
            if nick ~= "Harry_Test" then
                if ini.cmd.unknownchat then
                    ACM(string.format(utext("%sИгрок%s %s[%d]%s неудачно использовал команду:%s %s"), ini.chat.unknownChatColor, ini.chat.unknownNickChatColor, nick, id, ini.chat.unknownChatColor, ini.chat.unknownCmdChatColor, cmd))
                    return false
                else
                    return true
                end
            else
                if ini.cmd.botchat then
                    ACM(string.format(utext("%s[BOT] %sHarry_Test: %sНеизвестная команда >>%s %s %s<<"), ini.chat.botPrefixChatColor, ini.chat.botNickChatColor, white, ini.chat.botChatColor, cmd, white ))
                    return false
                else
                    return true
                end
            end
        end
        if text:find(utext("%[!%] (.+)%[(%d+)%] получил предмет №(%d+) %((%d+) шт")) then
            local nick, id, item, sht = text:match(utext("%[!%] (.+)%[(%d+)%] получил предмет №(%d+) %((%d+) шт"))
            local itemId = tonumber(item)
            local exists, itemName = isItemList(itemId)
            if exists then
                if ini.cmd.itemchat then
                    ACM(string.format(utext("%sИгрок%s %s[%d]%s получил предмет [%s[%s]%s] (%s%s шт.%s)"), ini.chat.itemChatColor, ini.chat.itemNickChatColor, nick, id, ini.chat.itemChatColor, utext(itemName), item, ini.chat.itemChatColor, ini.chat.itemShtChatColor, sht, ini.chat.itemChatColor))
                    return false
                else
                    return true
                end
            end
        elseif text:find(utext("%[!%] (.+)%[(%d+)%] получил предмет №(%d+)")) then
            local nick, id, item = text:match(utext("%[!%] (.+)%[(%d+)%] получил предмет №(%d+)"))
            local itemId = tonumber(item)
            local exists, itemName = isItemList(itemId)
            if exists then
                if ini.cmd.itemchat then
                    ACM(string.format(utext("%sИгрок%s %s[%d]%s получил предмет [%s[%s]%s] (%s1 шт.%s)"), ini.chat.itemChatColor, ini.chat.itemNickChatColor, nick, id, ini.chat.itemChatColor, utext(itemName), item, ini.chat.itemChatColor, ini.chat.itemShtChatColor, ini.chat.itemChatColor))
                    return false
                else
                    return true
                end
            end
        end
        if text:find(utext("%[!%] (.+)%[(%d+)%] удалил предмет №(%d+) %((%d+) шт")) then
            local nick, id, item, sht = text:match(utext("%[!%] (.+)%[(%d+)%] удалил предмет №(%d+) %((%d+) шт"))
            local itemId = tonumber(item)
            local exists, itemName = isItemList(itemId)
            if exists then
                if ini.cmd.ditemchat then
                    ACM(string.format(utext("%sИгрок%s %s[%d]%s удалил предмет [%s[%s]%s] (%s%s шт.%s)"), ini.chat.dItemChatColor, ini.chat.dItemNickChatColor, nick, id, ini.chat.dItemChatColor, utext(itemName), item, ini.chat.dItemChatColor, ini.chat.dItemShtChatColor, sht, ini.chat.dItemChatColor))
                    return false
                else
                    return true
                end
            end
        elseif text:find(utext("%[!%] (.+)%[(%d+)%] удалил предмет №(%d+)")) then
            local nick, id, item = text:match(utext("%[!%] (.+)%[(%d+)%] удалил предмет №(%d+)"))
            local itemId = tonumber(item)
            local exists, itemName = isItemList(itemId)
            if exists then
                if ini.cmd.ditemchat then
                    ACM(string.format(utext("%sИгрок%s %s[%d]%s удалил предмет [%s[%s]%s] (%s1 шт.%s)"), ini.chat.dItemChatColor, ini.chat.dItemNickChatColor, nick, id, ini.chat.dItemChatColor, utext(itemName), item, ini.chat.dItemChatColor, ini.chat.dItemShtChatColor, ini.chat.dItemChatColor))
                    return false
                else
                    return true
                end
            end
        end
        if find(text, "%[A%]") then
            if text:find("Harry_Test%[(%d+)%]:") then
                local cmd = text:match(': (.+)')
                if ini.cmd.botchat then
                    ACM(string.format(utext("%s[BOT]%s Harry_Test[%d]:%s %s"), ini.chat.botPrefixChatColor, ini.chat.botNickChatColor, BotID, red, cmd))
                    return false
                else
                    return true
                end
            end
        end
    else
        return true
    end
end

------------------------------------------------------------------------------------------------
-------------------------------------------Диалоги----------------------------------------------
------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------
-------------------------------------------Диалоги----------------------------------------------
------------------------------------------------------------------------------------------------