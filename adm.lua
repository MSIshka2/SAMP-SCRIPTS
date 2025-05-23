require('lib.moonloader')
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local cp = encoding.CP1251
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
local fa = require 'fAwesome5'

local IniFilename = 'SettingsADM.ini'
local ini = inicfg.load({
    nicknames = {},

}, IniFilename)
inicfg.save(ini, IniFilename)

local StatsFilename = 'PlayerStats.json'

local SettingsState = new.bool()
local nickBuffer = new.char[256]()
local idBuffer = new.int()
local fa_font = nil
local iconRanges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
local cool = false

function utext(text)
    text = u8:decode(text)
    return text
end

function cptext(text)
    text = cp:decode(text)
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

function imgui.NewInputText(lable, val, width, hint, hintpos)
    local hint = hint and hint or ''
    local hintpos = tonumber(hintpos) and tonumber(hintpos) or 1
    local cPos = imgui.GetCursorPos()
    imgui.PushItemWidth(width)
    local result = imgui.InputText(lable, val, sizeof(val))
    if #str(val) == 0 then
        local hintSize = imgui.CalcTextSize(hint)
        if hintpos == 2 then imgui.SameLine(cPos.x + (width - hintSize.x) / 2)
        elseif hintpos == 3 then imgui.SameLine(cPos.x + (width - hintSize.x - 5))
        else imgui.SameLine(cPos.x + 5) end
        imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 0.40), tostring(hint))
    end
    imgui.PopItemWidth()
    return result
end

function imgui.NewInputNumber(label, val, width, hint, hintpos)
    local hint = hint or ''
    local hintpos = tonumber(hintpos) or 1
    local cPos = imgui.GetCursorPos()
    imgui.PushItemWidth(width)

    -- Ограничиваем ввод только числами
    local input, changed = imgui.InputInt(label, val, 0)

    if val == 0 then
        local hintSize = imgui.CalcTextSize(hint)
        if hintpos == 2 then imgui.SameLine(cPos.x + (width - hintSize.x) / 2)
        elseif hintpos == 3 then imgui.SameLine(cPos.x + (width - hintSize.x - 5))
        else imgui.SameLine(cPos.x + 5) end
        imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 0.40), tostring(hint))
    end

    imgui.PopItemWidth()

    -- Преобразуем введённое значение в число
    local numberValue = tonumber(val) or 0
    return numberValue, changed
end

function imgui.ColoredButton(text,hex,trans,size)
    local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
    if tonumber(trans) ~= nil and tonumber(trans) < 101 and tonumber(trans) > 0 then a = trans else a = 60 end
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r/255, g/255, b/255, a/100))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r/255, g/255, b/255, a/100))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r/255, g/255, b/255, a/100))
    local button = imgui.Button(text, size)
    imgui.PopStyleColor(3)
    return button
end

function addNicknameToIni(nickname)
    local iniData = inicfg.load(nil, IniFilename)

    -- Создаём секцию, если её нет
    if not iniData.nicknames then
        iniData.nicknames = {}
    end

    -- Проверяем, есть ли уже такой ник
    for _, existingNick in pairs(iniData.nicknames) do
        if tostring(existingNick) == tostring(nickname) then
            return
        end
    end

    -- Находим первый свободный ключ
    local key = 1
    while iniData.nicknames[key] do
        key = key + 1
    end

    iniData.nicknames[key] = nickname
    inicfg.save(iniData, IniFilename)
end

function addNicknameIDToIni(idN)
    local iniData = inicfg.load(nil, IniFilename)
    
    if not iniData.nicknames then
        iniData.nicknames = {}
    end
    local myID = select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))
    if idN ~= nil then
        print(idN)
        if sampIsPlayerConnected(idN) then
            nickname = sampGetPlayerNickname(idN)
            print(nickname)
        end
    end
    if idN == myID then
        print(idN)
        nickname = sampGetPlayerNickname(myID)
        print(nickname)
    end
    for _, existingNick in pairs(iniData.nicknames) do
        if tostring(existingNick) == tostring(nickname) then
            return
        end
    end

    -- Находим первый свободный ключ
    local key = 1
    while iniData.nicknames[key] do
        key = key + 1
    end

    iniData.nicknames[key] = nickname
    inicfg.save(iniData, IniFilename)
    
end

function removeNicknameFromIni(nickname)
    local iniData = inicfg.load(nil, IniFilename)
    if not iniData.nicknames then return end

    for key, value in pairs(iniData.nicknames) do
        if value == nickname then
            iniData.nicknames[key] = nil
            break
        end
    end
    
    inicfg.save(iniData, IniFilename)
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

function renderNicknamesFromIni()
    local iniData = inicfg.load(nil, IniFilename)
    
    if not iniData.nicknames then
        iniData.nicknames = {}
    end
    
    for _, nickname in pairs(iniData.nicknames) do
        if nickname and nickname ~= "" then
            local popup_id = "Функции_" .. nickname
            local icon = fa.ICON_FA_USER
            local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
            local mynickname = sampGetPlayerNickname(myid)
            local id = sampGetPlayerIdByNickname(nickname)
            local button_text = nickname
            if imgui.Button(tostring(button_text)) then
                imgui.OpenPopup(popup_id)
            end
            imgui.SameLine()
            if id ~= nil then
                if sampIsPlayerConnected(id) then
                    imgui.TextColored(imgui.ImVec4(0.0,1.0,0.0,1.0), icon)
                elseif nickname == mynickname then
                    imgui.TextColored(imgui.ImVec4(0.0,1.0,0.0,1.0), icon)
                end
            else
                imgui.TextColored(imgui.ImVec4(1.0,0.0,0.0,1.0), icon)
            end
            if imgui.BeginPopup(popup_id) then
                if imgui.Button("Удалить из чекера") then
                    removeNicknameFromIni(nickname)
                    imgui.CloseCurrentPopup()
                end
                if imgui.Button("Посмотреть статистику") then
                    local stats = loadStatsFromJson()
                    
                    if stats[tostring(nickname)] and not imgui.IsKeyDown(VK_SHIFT) then
                        -- Если есть сохраненная статистика и не нажата клавиша Shift,
                        -- показываем сохраненную информацию
                        showSavedStats(nickname)
                    else
                        -- Если статистики нет или нажата клавиша Shift,
                        -- запрашиваем обновление статистики
                        updatePlayerStats(nickname)
                    end
                    
                    imgui.CloseCurrentPopup()
                end
                if imgui.IsItemHovered() then
                    imgui.BeginTooltip()
                    imgui.TextUnformatted("Нажмите SHIFT + кнопку для принудительного обновления статистики")
                    imgui.EndTooltip()
                end
                if imgui.Button("Скопировать ник") then
                    setClipboardText(nickname)
                end
                imgui.EndPopup()
            end
        end
    end
end

imgui.OnInitialize(function()
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    theme.change()
    style.change()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local iconRanges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromFileTTF('trebucbd.ttf', 15.0, nil, glyph_ranges)
    icon = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 14.0, config, iconRanges)
end)

imgui.OnFrame(function() return SettingsState[0] end, function(player)
    player.HideCursor = false
    imgui.SetNextWindowSize(imgui.ImVec2(750, 420), imgui.Cond.FirstUseEver)
    imgui.Begin('Чекер', SettingsState, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
    imgui.NewInputText("##test", nickBuffer, 180, "Введите ник", 2)
    imgui.SameLine()
    imgui.SetCursorPosX(220)
    imgui.NewInputNumber("##test1", idBuffer, 175, "Введите ид", 2)
    if imgui.Button('Добавить в чекер по нику') then
        addNicknameToIni(utext(str(nickBuffer)))
    end
    imgui.SameLine()
    imgui.SetCursorPosX(220)
    if imgui.Button('Добавить в чекер по иду') then
        addNicknameIDToIni(idBuffer[0])
    end
    imgui.Separator()
    imgui.BeginChild("NicknamesList", imgui.ImVec2(0, 0), true)
        renderNicknamesFromIni()
    imgui.EndChild()
    imgui.End()
end)

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    -- Проверяем, относится ли диалог к статистике игрока
    if dialogId == 0 and title:find(utext("Статистика")) or (title:find("%[0%]")) then
        -- Извлекаем никнейм из заголовка
        local nickname = text:match(utext("Имя:%s*([^%s\n]+)")) or title:match(utext("%[0%] (.+)"))
        nickname = nickname:gsub("%{......%}", ""):gsub("%[.+%]", "")
        if tostring(nickname) then
            -- Создаем новую таблицу для статистики
            local stats = {}
            
            -- Пытаемся прочитать существующий файл
            local file = io.open(StatsFilename, "r")
            if file then
                local content = file:read("*all")
                file:close()
                if content and content ~= "" then
                    local status, oldStats = pcall(json.decode, content)
                    if status and type(oldStats) == "table" then
                        stats = oldStats
                    end
                end
            end
            
            -- Добавляем или обновляем статистику игрока
            stats[tostring(nickname)] = {
                data = cptext(text),
                timestamp = os.time()
            }
            
            -- Отладочная информация
            print("Сохраняем статистику для: " .. tostring(nickname))
            print("Тип никнейма: " .. type(nickname))
            
            -- Сохраняем обновленные данные
            saveStatsToJson(stats)
            print(utext("Статистика игрока " .. nickname .. " сохранена"))
        end
    end
    
    -- Возвращаем false, чтобы не блокировать стандартную обработку диалога
    return true
end

function main()
    if not isSampLoaded() and not isSampfuncsLoaded() then return end
    local file = io.open("checker.json", "a")
    if file then
        print(utext("Скрипт загружен успешно"))
    else
        file:write()
    end
    while not isSampAvailable() do wait(100) end
    sampRegisterChatCommand("am", function()
        SettingsState[0] = not SettingsState[0]
    end)
    repeat wait(10) until sampIsLocalPlayerSpawned()
end

function loadStatsFromJson()
    local file = io.open(StatsFilename, "r")
    if not file then
        print("Файл статистики не найден")
        return {}
    end
    
    local content = file:read("*all")
    file:close()

    if content == "" then
        print("Файл статистики пуст")
        return {}
    end
    
    local status, result = pcall(json.decode, content)
    if status then
        -- Отладочная информация
        print("Загружены данные статистики:")
        for k, _ in pairs(result) do
            print(k .. " (тип: " .. type(k) .. ")")
        end
        return result
    else
        print(utext("Ошибка при чтении файла статистики: " .. tostring(result)))
        return {}
    end
end

function saveStatsToJson(data)
    local file = io.open(StatsFilename, "w")
    if not file then
        print(utext("Не удалось открыть файл для записи"))
        return false
    end
    
    local status, result = pcall(json.encode, data)
    if status then
        file:write(result)
        file:close()
        return true
    else
        print(utext("Ошибка при сохранении статистики: " .. tostring(result)))
        file:close()
        return false
    end
end

function showSavedStats(nickname)
    local stats = loadStatsFromJson()
    local key = tostring(nickname)
    
    if stats[key] then
        local timestamp = os.date("%d.%m.%Y %H:%M:%S", stats[key].timestamp)
        local text = stats[key].data
        
        text = text .. utext("\n\n{AAAAAA}Последнее обновление: ") .. timestamp
        
        SD(1000, "Статистика " .. nickname .. " (из кэша)", u8:encode(text), "Закрыть", "", 0)
        return true
    else
        print("Статистика не найдена для: " .. tostring(nickname))
        updatePlayerStats(nickname)
        return false
    end
end

function updatePlayerStats(nickname)
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local id = sampGetPlayerIdByNickname(tostring(nickname))
    
    if id ~= nil then
        if sampIsPlayerConnected(id) then
            sampSendChat("/stats " .. id)
        else
            if nickname == sampGetPlayerNickname(myid) then
                sampSendChat("/stats " .. myid)
            else
                sampSendChat("/offstats " .. tostring(nickname))
            end
        end
    else
        sampSendChat("/offstats " .. tostring(nickname))
    end
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