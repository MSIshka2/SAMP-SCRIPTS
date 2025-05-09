require('lib.moonloader')
local imgui = require('imgui')
local fa = require 'fAwesome5'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local sampev = require 'samp.events'
local memory = require 'memory'
local ffi = require 'ffi'

ffi.cdef
[[
    void *malloc(size_t size);
    void free(void *ptr);
]]
local inicfg = require 'inicfg'
local directIni = 'SPEEDOMETER.ini'
local ini = inicfg.load(inicfg.load({
    main = {
        enabled = true
    },
}, directIni))
inicfg.save(ini, directIni)


local tag = '{ff004d}[Speedometer]: {ffffff}'
local curWinPos = {x = 0, y = 0}
local fa_font = nil
local fa_font_2 = nil
local font_speed = nil
local font_kmh = nil
local font_huinya = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local serverIP = "46.174.54.87"

local speedometer = imgui.ImBool(false)
local turn_signals = {
    left = {
        active = false,
        start_time = 0,
        blinking = false,
        last_blink = 0
    },
    right = {
        active = false,
        start_time = 0,
        blinking = false,
        last_blink = 0
    }
}
local TURN_SIGNAL_DELAY = 0.8  -- Задержка в секундах для активации поворотника
local BLINK_INTERVAL = 0.5     -- Интервал мигания в секундах


local serverIP = "46.174.54.87"

function main()
    while not isSampAvailable() do wait(200) end
    sampAddChatMessage(tag..u8:decode('Скрипт >> {ff004d}Speedometer{ffffff} << загружен'), -1)
    if not doesDirectoryExist(getWorkingDirectory()..'\\resource\\fonts') then createDirectory(getWorkingDirectory()..'\\resource\\fonts') print(tag..'Папка '..getWorkingDirectory()..'\\resource\\fonts создана') end
    if not doesFileExist(getWorkingDirectory()..'\\resource\\fonts\\unineueheavy-italic.ttf') then
        print('Шрифт unineueheavy-italic.ttf не найден! Скачайте его отсюда: https://ffont.ru/font/uni-neue-heavy и переместите его в папку '..getWorkingDirectory()..'\\resource\\fonts')
        sampAddChatMessage(tag..u8:decode('ШРИФТ unineueheavy-italic.ttf НЕ НАЙДЕН, ССЫЛКА НА СКАЧИВАНИЕ В КОНСОЛИ!'), -1)
        thisScript():unload()
    end
    if not doesFileExist(getWorkingDirectory()..'\\resource\\fonts\\fa-solid-900.ttf') then
        print('Шрифт fa-solid-900.ttf не найден! Скачайте его отсюда: https://github.com/FortAwesome/Font-Awesome/raw/master/webfonts/fa-solid-900.ttf и переместите его в папку '..getWorkingDirectory()..'\\resource\\fonts')
        sampAddChatMessage(tag..u8:decode('ШРИФТ fa-solid-900.ttf НЕ НАЙДЕН, ССЫЛКА НА СКАЧИВАНИЕ В КОНСОЛИ!'), -1)
        thisScript():unload()
    end
    imgui.Process = false
    speedometer.v = ini.main.enabled
    sampRegisterChatCommand('speedometer', function()
        speedometer.v = not speedometer.v
        sampAddChatMessage(tag..(speedometer.v and u8:decode('Включен') or u8:decode('Выключен')), -1)
        ini.main.enabled = speedometer.v
        inicfg.save(ini, directIni)
    end)
    while true do
        wait(0)
        imgui.Process = speedometer.v
        processTurnSignals()
    end
end

function onScriptTerminate(s, q)
    if s == thisScript() then
        displayHud(true)
    end
end

function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true

        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 18.0, font_config, fa_glyph_ranges)
    end
    if fa_font_2 == nil then
        fa_font_2 = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 25.0, font_config, fa_glyph_ranges)
    end
    if font_speed == nil then
        font_speed = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/unineueheavy-italic.ttf', 50.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if font_kmh == nil then
        font_kmh = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/unineueheavy-italic.ttf', 30.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if font_huinya == nil then
        font_huinya = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/unineueheavy-italic.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
end

function imgui.OnDrawFrame()
    if speedometer.v then
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 450, 350

        local posX = resX - sizeX - 50
        local posY = resY - sizeY - 50

        imgui.SetNextWindowPos(imgui.ImVec2(posX+20, posY-10), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX-110, sizeY+40), imgui.Cond.FirstUseEver)
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0 / 255, 0 / 255, 0 / 255, 0))
        imgui.Begin('Speedometer', speedometer, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
        curWinPos = imgui.GetWindowPos()
        imgui.ShowCursor = false
        imgui.SetCursorPos(imgui.ImVec2(0, 0))
        imgui.PushFont(font_speed)
        imgui.SameLine()
        if isCharInAnyCar(PLAYER_PED) then
            local result_speed, speed = getCarSpeed(storeCarCharIsInNoSave(PLAYER_PED), true)
            local engine = isCarEngineOn(storeCarCharIsInNoSave(PLAYER_PED)) or false
            local hp = getCarHealth(storeCarCharIsInNoSave(PLAYER_PED)) or 0
            local status = getCarDoorLockStatus(storeCarCharIsInNoSave(PLAYER_PED)) or 1
            local gear = getCarCurrentGear(storeCarCharIsInNoSave(PLAYER_PED))
            local textdraw = sampTextdrawGetString(2122)
            if textdraw then
                local ip, port = sampGetCurrentServerAddress()
                if ip == serverIP then
                    fuel = textdraw:match("%s*HEAL:%s*%d+~n~SPEED:%s*%d+~n~FUEL:%s*~g~(%d+)~n~~w~STATUS:%s*~.+~.+~n~~w~")
                    fuel = tonumber(fuel) or 0
                else
                    fuel = 100
                end
                if result_speed then
                    imgui.Speedometer(speed, tonumber(hp), tonumber(fuel), status, engine, gear, 300)
                end
            else
                if result_speed then
                    imgui.Speedometer(speed, 0, 0, "LOCK", "OFF", 300)
                end
            end
        end
        imgui.PopFont()
        imgui.End()
        imgui.PopStyleColor()
    end
end

function imgui.Speedometer(speed, hp, fuel, status, engine, gear, size)
    local size = size or 120
    local pos = imgui.GetCursorScreenPos()
    local center = imgui.ImVec2(pos.x+20 + size/2, pos.y+90 + size/2)
    local radius = size/2 - 5
    local thickness = 10
    
    -- Создаем область для отрисовки
    imgui.Dummy(imgui.ImVec2(size, size))
    
    -- Используем imgui.ImDrawList только один раз
    local draw_list = imgui.GetWindowDrawList()
    
    -- Создаем таблицу цветов заранее
    local colors = {
        background = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.2, 0.2, 0.2, 0.7)),
        speed = {
            low = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0, 0.8, 0.2, 1)),
            medium = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.8, 0.7, 0, 1)),
            high = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.8, 0.4, 0, 1)),
            veryhigh = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.8, 0.2, 0, 1)),
            extreme = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 0, 0, 1))
        },
        fuel = {
            verylow = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.6, 0, 0, 1)),
            low = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.8, 0.4, 0, 1)),
            medium = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.8, 0.6, 0, 1)),
            high = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0, 0.8, 0.2, 1))
        },
        white = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 1, 1, 1)),
        gray = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.5, 0.5, 0.5, 1)),
        red = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.8, 0, 0.2, 1)),
        green = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0, 0.8, 0.2, 1))
    }

    -- Оптимизированная функция рисования дуги
    local function drawArc(start_angle, end_angle, color)
        draw_list:PathClear()
        draw_list:PathArcTo(center, radius, math.rad(start_angle), math.rad(end_angle), 16)
        draw_list:PathStroke(color, false, thickness)
    end
    
    -- Фон для полукруга скорости (левая половина)
    drawArc(180, 317, colors.background)
    
    -- Отрисовка спидометра - используем одну функцию для всех скоростей
    local max_speed = 300
    local normal_speed = math.min(speed, max_speed)
    local speed_angle = 180 + (137 * (normal_speed / max_speed))
    
    -- Выбор цвета на основе скорости
    local speed_color
    if speed < 80 then
        speed_color = colors.speed.low
    elseif speed < 160 then
        speed_color = colors.speed.medium
    elseif speed < 200 then
        speed_color = colors.speed.high
    elseif speed < 270 then
        speed_color = colors.speed.veryhigh
    else
        speed_color = colors.speed.extreme
    end
    
    if speed > 0 then
        drawArc(180, speed_angle, speed_color)
    end
    
    -- Фон для полукруга топлива (правая половина)
    drawArc(320, 360, colors.background)
    
    -- Индикатор топлива
    local max_fuel = 100
    local normal_fuel = math.min(fuel, max_fuel)
    local fuel_angle = 360 - (40 * (normal_fuel / max_fuel))
    
    -- Выбор цвета на основе уровня топлива
    local fuel_color
    if fuel < 35 then
        fuel_color = colors.fuel.verylow
    elseif fuel < 50 then
        fuel_color = colors.fuel.low
    elseif fuel < 75 then
        fuel_color = colors.fuel.medium
    else
        fuel_color = colors.fuel.high
    end
    
    if fuel > 0 then
        drawArc(360, fuel_angle, fuel_color)
    end
    
    -- Круг для фона текста - уменьшаем сегменты для оптимизации
    draw_list:AddCircleFilled(
        center,
        radius - thickness,
        imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0, 0, 0, 0)), 
        16
    )
    
    -- Медиа контролы сверху
    imgui.PushFont(fa_font_2)
    local arrow_left = fa.ICON_FA_ARROW_LEFT
    local arrow_size = imgui.CalcTextSize(arrow_left)
    local left_color = colors.gray
    if turn_signals.left.blinking then
        if math.floor((os.clock() / BLINK_INTERVAL) % 2) == 0 then
            left_color = colors.speed.high
        end
    end
    draw_list:AddText(
        imgui.ImVec2(center.x - arrow_size.x * 2, center.y - radius + 25),
        left_color,
        arrow_left
    )
    
    local parking = fa.ICON_FA_PARKING
    local parking_size = imgui.CalcTextSize(parking)
    local parking_color = isDriverSeat() and isKeyDown(0x20) and colors.red or colors.gray
    draw_list:AddText(
        imgui.ImVec2(center.x - parking_size.x / 2.8, center.y - radius + 25),
        parking_color,
        parking
    )
    
    local arrow_right = fa.ICON_FA_ARROW_RIGHT
    local right_color = colors.gray
    if turn_signals.right.blinking then
        if math.floor((os.clock() / BLINK_INTERVAL) % 2) == 0 then
            right_color = colors.speed.high
        end
    end
    local arrow_right = fa.ICON_FA_ARROW_RIGHT
    draw_list:AddText(
        imgui.ImVec2(center.x - arrow_size.x * -1.3, center.y - radius + 25),
        right_color,
        arrow_right
    )
    imgui.PopFont()
    
    -- Текст скорости в центре
    local speed_text = string.format("%03d", math.floor(speed))
    imgui.PushFont(font_speed)
    local text_size = imgui.CalcTextSize(speed_text)
    draw_list:AddText(
        imgui.ImVec2(center.x - text_size.x / 2.3, center.y - text_size.y * 1.2),
        colors.white,
        speed_text
    )
    imgui.PopFont()
    
    if gear == 0 then -- Сначала проверяем заднюю передачу
        local gear_text = "R"
        imgui.PushFont(font_kmh)
        local kmh_size = imgui.CalcTextSize(tostring(gear_text))
        draw_list:AddText(
            imgui.ImVec2(center.x - kmh_size.x / 2.3, center.y - kmh_size.y * 3),
            colors.white,
            tostring(gear_text)
        )
        imgui.PopFont()
    elseif gear == 1 then
        local gear_text = "M1"
        imgui.PushFont(font_kmh)
        local kmh_size = imgui.CalcTextSize(tostring(gear_text))
        draw_list:AddText(
            imgui.ImVec2(center.x - kmh_size.x / 2.3, center.y - kmh_size.y * 3),
            colors.white,
            tostring(gear_text)
        )
        imgui.PopFont()
    elseif gear == 2 then
        local gear_text = "M2"
        imgui.PushFont(font_kmh)
        local kmh_size = imgui.CalcTextSize(tostring(gear_text))
        draw_list:AddText(
            imgui.ImVec2(center.x - kmh_size.x / 2.3, center.y - kmh_size.y * 3),
            colors.white,
            tostring(gear_text)
        )
        imgui.PopFont()
    elseif gear == 3 then
        local gear_text = "M3"
        imgui.PushFont(font_kmh)
        local kmh_size = imgui.CalcTextSize(tostring(gear_text))
        draw_list:AddText(
            imgui.ImVec2(center.x - kmh_size.x / 2.3, center.y - kmh_size.y * 3),
            colors.white,
            tostring(gear_text)
        )
        imgui.PopFont()
    elseif gear == 4 then
        local gear_text = "M4"
        imgui.PushFont(font_kmh)
        local kmh_size = imgui.CalcTextSize(tostring(gear_text))
        draw_list:AddText(
            imgui.ImVec2(center.x - kmh_size.x / 2.3, center.y - kmh_size.y * 3),
            colors.white,
            tostring(gear_text)
        )
        imgui.PopFont()
    elseif gear == 5 then
        local gear_text = "M5"
        imgui.PushFont(font_kmh)
        local kmh_size = imgui.CalcTextSize(tostring(gear_text))
        draw_list:AddText(
            imgui.ImVec2(center.x - kmh_size.x / 2.3, center.y - kmh_size.y * 3),
            colors.white,
            tostring(gear_text)
        )
        imgui.PopFont()
    elseif gear == 6 then
        local gear_text = "M6"
        imgui.PushFont(font_kmh)
        local kmh_size = imgui.CalcTextSize(tostring(gear_text))
        draw_list:AddText(
            imgui.ImVec2(center.x - kmh_size.x / 2.3, center.y - kmh_size.y * 3),
            colors.white,
            tostring(gear_text)
        )
        imgui.PopFont()
    elseif speed == 0 and isKeyDown(0x20) then -- Затем проверяем парковку
        local gear_text = "P"
        imgui.PushFont(font_kmh)
        local kmh_size = imgui.CalcTextSize(tostring(gear_text))
        draw_list:AddText(
            imgui.ImVec2(center.x - kmh_size.x / 2.3, center.y - kmh_size.y * 3),
            colors.white,
            tostring(gear_text)
        )
        imgui.PopFont()
    elseif speed == 0 and not isKeyDown(0x20) then -- Затем нейтральную
        local gear_text = "N"
        imgui.PushFont(font_kmh)
        local kmh_size = imgui.CalcTextSize(tostring(gear_text))
        draw_list:AddText(
            imgui.ImVec2(center.x - kmh_size.x / 2.3, center.y - kmh_size.y * 3),
            colors.white,
            tostring(gear_text)
        )
        imgui.PopFont()
    elseif speed > 0 then -- И наконец текущую передачу при движении
        local gear_text = gear or "N"
        imgui.PushFont(font_kmh)
        local kmh_size = imgui.CalcTextSize(tostring(gear_text))
        draw_list:AddText(
            imgui.ImVec2(center.x - kmh_size.x / 2.3, center.y - kmh_size.y * 3),
            colors.white,
            tostring(gear_text)
        )
        imgui.PopFont()
    end
    -- Текст KM/H под скоростью
    local kmh_text = "KM/H"
    imgui.PushFont(font_kmh)
    local kmh_size = imgui.CalcTextSize(kmh_text)
    draw_list:AddText(
        imgui.ImVec2(center.x - kmh_size.x / 2.3, center.y - kmh_size.y / 2),
        colors.white,
        kmh_text
    )
    imgui.PopFont()
    
    -- Иконки внизу
    local icon_y = center.y + radius - 25
    local icon_spacing = radius / 3
    
    -- Иконки статуса
    imgui.PushFont(fa_font)
    
    -- Иконка ключа
    local key_color = engine == true and colors.green or colors.red
    draw_list:AddText(
        imgui.ImVec2(center.x - icon_spacing, icon_y-90),
        key_color,
        fa.ICON_FA_KEY
    )
    
    -- Иконка двигателя
    local engine_color
    if hp >= 651 then
        engine_color = colors.gray
    elseif hp > 350 then
        engine_color = colors.speed.high
    else
        engine_color = colors.red
    end
    draw_list:AddText(
        imgui.ImVec2(center.x, icon_y - 90),
        engine_color,
        fa.ICON_FA_THERMOMETER_EMPTY
    )
    
    -- Иконка замка
    local lock_color = status == 0 and colors.green or colors.red
    draw_list:AddText(
        imgui.ImVec2(center.x + icon_spacing - 10, icon_y-90),
        lock_color,
        fa.ICON_FA_LOCK
    )
    imgui.PopFont()
end

function getCarSpeed( vehicleTarget, kilometersBool )
    if not vehicleTarget or type( vehicleTarget ) ~= 'number' then return false end
    if not doesVehicleExist( vehicleTarget ) then return false end
    local x, y, z = getCarSpeedVector( vehicleTarget )
    if not x or not y or not z then x, y, z = 0, 0, 0 end
    local rawSpeed = math.sqrt(x*x + y*y + z*z)
    local speed = rawSpeed * 1.089 -- Новый множитель
    local kmh = math.floor(speed * 3.6) -- км/ч
    local mph = math.floor(speed * 2.23694) -- mph
    if kilometersBool then return true, kmh else return true, mph end
end

function processTurnSignals()
    if not isCharInAnyCar(PLAYER_PED) or not isDriverSeat() then 
        -- Сбрасываем состояние поворотников если игрок не за рулём
        turn_signals.left.active = false
        turn_signals.right.active = false
        turn_signals.left.blinking = false
        turn_signals.right.blinking = false
        return 
    end

    local current_time = os.clock()

    -- Обработка левого поворотника (клавиша A)
    if isKeyDown(0x41) then -- 0x41 это код клавиши A
        if not turn_signals.left.active then
            turn_signals.left.active = true
            turn_signals.left.start_time = current_time
        elseif current_time - turn_signals.left.start_time >= TURN_SIGNAL_DELAY and not turn_signals.left.blinking then
            turn_signals.left.blinking = true
            turn_signals.right.blinking = false -- Выключаем правый поворотник
            turn_signals.left.last_blink = current_time
        end
    else
        turn_signals.left.active = false
        if not isKeyDown(0x41) and not isKeyDown(0x44) then -- Если ни A, ни D не нажаты
            turn_signals.left.blinking = false
        end
    end

    -- Обработка правого поворотника (клавиша D)
    if isKeyDown(0x44) then -- 0x44 это код клавиши D
        if not turn_signals.right.active then
            turn_signals.right.active = true
            turn_signals.right.start_time = current_time
        elseif current_time - turn_signals.right.start_time >= TURN_SIGNAL_DELAY and not turn_signals.right.blinking then
            turn_signals.right.blinking = true
            turn_signals.left.blinking = false -- Выключаем левый поворотник
            turn_signals.right.last_blink = current_time
        end
    else
        turn_signals.right.active = false
        if not isKeyDown(0x41) and not isKeyDown(0x44) then -- Если ни A, ни D не нажаты
            turn_signals.right.blinking = false
        end
    end
end

function isDriverSeat()
    if not isCharInAnyCar(PLAYER_PED) then return false end
    local vehicle = storeCarCharIsInNoSave(PLAYER_PED)
    local driver = getDriverOfCar(vehicle)
    return driver == PLAYER_PED
end

function imgui.TextWithShadow(text, opacity, clr)
	local col_text_a, col_text_r, col_text_g, col_text_b = explode_argb(0xFFFFFFFF)
	if clr == nil then
		col_text_a, col_text_r, col_text_g, col_text_b = explode_argb(0xFFFFFFFF)
	else
		col_text_a, col_text_r, col_text_g, col_text_b = explode_argb(clr)
	end
    local s_shadowSize = {v = 2}
    local pos = imgui.GetCursorPos()
    imgui.SetCursorPos(imgui.ImVec2(pos.x - s_shadowSize.v, pos.y)) imgui.TextColored(imgui.ImVec4(0,0,0, opacity), text)
    imgui.SetCursorPos(imgui.ImVec2(pos.x + s_shadowSize.v, pos.y)) imgui.TextColored(imgui.ImVec4(0,0,0, opacity), text)
    imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y + s_shadowSize.v)) imgui.TextColored(imgui.ImVec4(0,0,0, opacity), text)
    imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y - s_shadowSize.v)) imgui.TextColored(imgui.ImVec4(0,0,0, opacity), text)
    imgui.SetCursorPos(pos)
    --imgui.Text(text)
	imgui.TextColored(imgui.ImVec4(col_text_r / 255, col_text_g / 255, col_text_b / 255, col_text_a / 255), text)
end

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function sampev.onShowTextDraw(id, data)
    local ip, port = sampGetCurrentServerAddress()
    if ip == serverIP then
        local textdraws_to_hide = {2122}
        for _, tdid in ipairs(textdraws_to_hide) do
            if id == tdid then
                sampTextdrawDelete(id)
                sampTextdrawCreate(id, "", 0, 0)
                sampTextdrawSetStyle(id, 0)
                sampTextdrawSetLetterSizeAndColor(id, 0.0, 0.0, 0x00000000)
                sampTextdrawSetPos(id, -9999, -9999)
                return false
            end
        end
    end
end