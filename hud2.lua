local imgui = require('imgui')
local fa = require 'fAwesome5'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local weapons = require 'game.weapons'
local sampev = require 'lib.samp.events'
local memory = require 'memory'
local ffi = require 'ffi'
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
ffi.cdef
[[
    void *malloc(size_t size);
    void free(void *ptr);
]]
local inicfg = require 'inicfg'
local directIni = 'HUD.ini'
local ini = inicfg.load(inicfg.load({
    main = {
        enabled = true,
        size = 1,
        rep = 2149,
        time = 77,
        hp1 = 0,
        hp2 = 1,
        rank = "nil",
        rankid = 2133,
    },
    pos = {
        x = select(1, getScreenResolution()) - 390 - 50,
        y = 100,
    },
    datepos = {
        x = 50,
        y = select(2, getScreenResolution()) - 300,
    }
}, directIni))
inicfg.save(ini, directIni)

local weapIcons = {}
local POSEDIT = false
local pos = {x = ini.pos.x, y = ini.pos.y}
local curWinPos = {x = 0, y = 0}
local curDateWinPos = {x = 0, y = 0}
local datepos = {x = ini.datepos.x, y = ini.datepos.y}
local tag = '{ff004d}[Hud]: {ffffff}'

local fatalityLogo = imgui.ImBool(false)
local fireLogo = imgui.ImBool(false)
local rankLogo = imgui.ImBool(false)
local window = imgui.ImBool(false)
local serverIP = "46.174.54.87"
local dateTime = imgui.ImBool(false)
local font_ammo = nil
local font_ammo2 = nil
local font_money = nil
local font_namesrv = nil
local font_namesrv2 = nil
local font_dubnamesrv = nil
local font_dubnamesrv2 = nil
local fa_font = nil
local font_arzlogo = nil
local font_arzlogo_server = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local fatality = nil
local emoji_gear = nil
local emoji_fire = nil
local developer = nil
local tester = nil
local player = nil
local player1 = nil
local player2 = nil
local waveTime = 0
local baseAmplitude = 5.0
local minAmplitude = 5.0 
local maxAmplitude = 7.0
local amplitudeSpeed = 1.5
local repid = 0
local textdraws_to_hide = {2149, 2141, 2140, 2143, 2145, 2148, 2144, 0, 1, 2146, 2147, 2142, 58,59,60,61,63,66,65,74,754,73,70,71,72,57,56,55,68,62,69,67,75,64}
local textdrawR = false
local stopslovo = false


function random(min, max)
    kf = math.random(min, max)
    math.randomseed(os.time() * kf)
    rand = math.random(min, max)
    return tonumber(rand)
end

function main()
    while not isSampAvailable() do wait(200) end
    sampAddChatMessage(tag..u8:decode('Загружен, автор: {ff004d}Harry_Pattersone{ffffff} and{ff004d} navalny_vandal'), -1)
    sampAddChatMessage(tag..u8:decode('Включить/Выключить худ: {ff004d}/hud2{ffffff}, положение: {ff004d}/hud2.pos{ffffff}, размер: {ff004d}/hud2.size'), -1)
    if not doesDirectoryExist(getWorkingDirectory()..'\\resource\\fonts') then createDirectory(getWorkingDirectory()..'\\resource\\fonts') print(tag..'Папка '..getWorkingDirectory()..'\\resource\\fonts создана') end
    if not doesDirectoryExist(getWorkingDirectory()..'\\resource\\Hud') then createDirectory(getWorkingDirectory()..'\\resource\\Hud') print(tag..'Папка '..getWorkingDirectory()..'\\resource\\Hud создана') end
    if not doesFileExist(getWorkingDirectory()..'\\resource\\fonts\\unineueheavy-italic.ttf') then
        print('Шрифт unineueheavy-italic.ttf не найден! Скачайте его отсюда: https://ffont.ru/font/uni-neue-heavy и переместите его в папку '..getWorkingDirectory()..'\\resource\\fonts')
        sampAddChatMessage(tag..u8:decode('ШРИФТ unineueheavy-italic.ttf НЕ НАЙДЕН, ССЫЛКА НА СКАЧИВАНИЕ В КОНСОЛИ!'), -1)
        thisScript():unload()
    end
    imgui.Process = false
    window.v = ini.main.enabled  --show window
    sampRegisterChatCommand('hud2', function()
        window.v = not window.v
        sampAddChatMessage(tag..(window.v and u8:decode('Включен') or u8:decode('Выключен')), -1)
        displayHud(not window.v)
        ini.main.enabled = window.v
        inicfg.save(ini, directIni)
    end)
    sampRegisterChatCommand('hud2.reload', function()
        thisScript().reload()
    end)
    sampRegisterChatCommand('hud2.size', function(arg)
        if arg:find('(%d+)') then
            local newSize = arg:match('(%d+)')
            if newSize >= tostring("3") then
                sampAddChatMessage(tag..u8:decode('Куда ещё больше?'), -1)
                return
            elseif newSize <= tostring("0") then
                sampAddChatMessage(tag..u8:decode('Куда ещё меньше?'), -1)
            else
                ini.main.size = tonumber(newSize)
                inicfg.save(ini, directIni)
            end
        else
            sampAddChatMessage(tag..u8:decode('Ошибка. Используйте {ff004d}/hud2.size (1-2){ffffff} что бы изменить размер.'), -1)
        end
    end)
    sampRegisterChatCommand('hud2.pos', function(arg)
        if arg:find('(.+)') then 
            if arg:find('(%d+) (%d+)') then
                local newX, newY = arg:match('(%d+) (%d+)')
                pos.x, pos.y = tonumber(newX), tonumber(newY)
            else
                sampAddChatMessage(tag..u8:decode('Ошибка. Используйте {ff004d}/hud2.pos{ffffff} что бы перемещать мышью или {ff004d}/hud2.pos [X] [Y]{ffffff} для'), -1)
                sampAddChatMessage(tag..u8:decode('установки точного положения'), -1)
            end
        else
            POSEDIT = not POSEDIT 
            sampToggleCursor(POSEDIT)
            if POSEDIT then
                sampAddChatMessage(tag..u8:decode('вы вошли в режим редактирования положения'), -1)
                sampAddChatMessage(tag..u8:decode('перемещайте худ курсором. Для сохранения пропишите команду {ff004d}/hud2.pos'), -1)
                sampAddChatMessage(tag..u8:decode('так же вы можете использовать: {ff004d}/hud2.pos [X] [Y]'), -1)
            else
                sampAddChatMessage(tag..u8:decode('положение сохранено (X: {ff004d}'..curWinPos.x..'{ffffff}, Y: {ff004d}'..curWinPos.y..'{ffffff})'), -1)
                ini.pos.x, ini.pos.y = curWinPos.x, curWinPos.y
                ini.datepos.x, ini.datepos.y = curDateWinPos.x, curDateWinPos.y
                inicfg.save(ini, directIni)
            end
        end
    end)
    displayHud(not window.v)
    
    if doesFileExist(getGameDirectory() .. "\\cef\\hud\\assets\\developer.png") then
        developer = imgui.CreateTextureFromFile(getGameDirectory() .. "\\cef\\hud\\assets\\developer.png")
    else
        print('DEVELOPER ICON NOT FOUND')
    end

    if doesFileExist(getGameDirectory() .. "\\cef\\hud\\assets\\tester.png") then
        tester = imgui.CreateTextureFromFile(getGameDirectory() .. "\\cef\\hud\\assets\\tester.png")
    else
        print('TESTER ICON NOT FOUND')
    end
    if doesFileExist(getGameDirectory() .. "\\cef\\hud\\assets\\player.png") then
        player = imgui.CreateTextureFromFile(getGameDirectory() .. "\\cef\\hud\\assets\\player.png")
    else
        print('PLAYER ICON NOT FOUND')
    end

    if doesFileExist(getGameDirectory() .. "\\cef\\hud\\assets\\player1.png") then
        player1 = imgui.CreateTextureFromFile(getGameDirectory() .. "\\cef\\hud\\assets\\player1.png")
    else
        print('PLAYER1 ICON NOT FOUND')
    end

    if doesFileExist(getGameDirectory() .. "\\cef\\hud\\assets\\player2.png") then
        player2 = imgui.CreateTextureFromFile(getGameDirectory() .. "\\cef\\hud\\assets\\player2.png")
    else
        print('PLAYER2 ICON NOT FOUND')
    end

    if doesFileExist(getGameDirectory() .. "\\cef\\hud\\assets\\ftl.png") then
        fatality = imgui.CreateTextureFromFile(getGameDirectory() .. "\\cef\\hud\\assets\\ftl.png")
    else
        print('FATALITY ICON NOT FOUND')
    end

	if doesFileExist(getGameDirectory() .. "\\cef\\hud\\assets\\fire.png") then
        emoji_fire = imgui.CreateTextureFromFile(getGameDirectory() .. "\\cef\\hud\\assets\\fire.png")
    else
        print('FIRE EMOJI NOT FOUND')
    end
    --==[LOAD ICONS]==--
    for i = 0, 46 do
        if weapIcons[i] == nil then
            if doesFileExist(getWorkingDirectory()..'\\resource\\Hud\\'..i..'.png') then 
                weapIcons[i] = imgui.CreateTextureFromFile(getWorkingDirectory()..'\\resource\\Hud\\'..i..'.png')
            else
                print('ICON '..i..' NOT FOUND')
            end
        end
    end
    while true do
        wait(0)
        dateTime.v = window.v
		fireLogo.v = window.v
        fatalityLogo.v = window.v
        rankLogo.v = window.v
        imgui.Process = window.v
        sampTextdrawCreate(ini.main.hp1, "", -9999, -9999)
        sampTextdrawCreate(ini.main.hp2, "", -9999, -9999)
        sampTextdrawCreate(ini.main.time, "", -9999, -9999)

        waveTime = waveTime + 0.016 -- Примерно 60 FPS
    end
end

function onExitScript()
    if ini.main.rank ~= "nil" then
        ini.main.rank = "nil"
        inicfg.save(ini, directIni)
    end
end

function onQuitGame()
    if ini.main.rank ~= "nil" then
        ini.main.rank = "nil"
        inicfg.save(ini, directIni)
    end
end

function onScriptTerminate(s, q)
    if s == thisScript() then
        ini.main.rank = "nil"
        inicfg.save(ini, directIni)
        displayHud(true)
    end
end

function onServerDisconnect()
    if ini.main.rank ~= "nil" then
        ini.main.rank = "nil"
        inicfg.save(ini, directIni)
    end
end

function drawWeaponIcon(info, scale)
    imgui.SetCursorPos(imgui.ImVec2(80, -4))
    if weapIcons[info.weapon] == nil then
        imgui.Button(weapons.get_name(info.weapon)..'\n(ID: '..info.weapon..')\nicon\nnot found', imgui.ImVec2(80, 80))
    else
        imgui.Image(weapIcons[info.weapon], imgui.ImVec2(70 + scale*6, 70 + scale*6))
    end
end

function drawAmmo(info, scale)
    ammoText = info.ammoInClip..'/'..info.ammo
    if scale == 1 then
        imgui.PushFont(font_ammo)
        imgui.SetCursorPos(imgui.ImVec2(75 + 40 - imgui.CalcTextSize(ammoText).x / 2 + scale*2, 60+scale*3))
        imgui.TextWithShadow(ammoText, 0.5)
        imgui.PopFont()
    elseif scale == 2 then
        imgui.PushFont(font_ammo2)
        imgui.SetCursorPos(imgui.ImVec2(75 + 40 - imgui.CalcTextSize(ammoText).x / 2 + scale*2, 60+scale*3.5))
        imgui.TextWithShadow(ammoText, 0.5)
        imgui.PopFont()
    end
end

function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true

        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 18.0, font_config, fa_glyph_ranges)
    end

    if fa_fontREP == nil then
        fa_fontREP = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 25.0, font_config, fa_glyph_ranges)
    end
    
    if font_ammo == nil then
        font_ammo = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/unineueheavy-italic.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if font_ammo2 == nil then
        font_ammo2 = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/unineueheavy-italic.ttf', 22.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if font_bar == nil then
        font_bar = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/unineueheavy-italic.ttf', 15.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if font_money == nil then
        font_money = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/unineueheavy-italic.ttf', 28.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
	if font_namesrv == nil then
        font_namesrv = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/Montserrat-Bold.ttf', 36.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if font_namesrv2 == nil then
        font_namesrv2 = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/Montserrat-Bold.ttf', 38.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
	if font_dubnamesrv == nil then
        font_dubnamesrv = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/Montserrat-Bold.ttf', 16.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if font_dubnamesrv2 == nil then
        font_dubnamesrv2 = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/Montserrat-Bold.ttf', 18.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if font_arzlogo == nil then
        font_arzlogo = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/unineueheavy-italic.ttf', 50.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if font_arzlogo_server == nil then
        font_arzlogo_server = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/unineueheavy-italic.ttf', 40.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
end

function imgui.OnDrawFrame()
    if fatalityLogo.v then
        local resX, resY = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(pos.x+70, pos.y-120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(390, 190), imgui.Cond.FirstUseEver)
        imgui.Begin('Fatality', fatalityLogo, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + (POSEDIT and 0 or 4))
            if fatality then
                local ip, port = sampGetCurrentServerAddress()
                if ip == serverIP then
                    if ini.main.size == 1 then
                        sizeX, sizeY = 200, 142
                        imgui.SetCursorPos(imgui.ImVec2(18, 0))
                        imgui.Image(fatality, imgui.ImVec2(sizeX, sizeY))
					    imgui.PushFont(font_namesrv)
                    elseif ini.main.size == 2 then
                        sizeX, sizeY = 250, 182
                        imgui.SetCursorPos(imgui.ImVec2(-10, -25))
                        imgui.Image(fatality, imgui.ImVec2(sizeX, sizeY))
					    imgui.PushFont(font_namesrv2)
                    end
					imgui.SetCursorPos(imgui.ImVec2(150, 55))
					imgui.TextWithShadow('FATALITY', 0.3)
					imgui.PopFont()
                end
            end
			if emoji_fire then
                local ip, port = sampGetCurrentServerAddress()
                if ip == serverIP then
                    if ini.main.size == 1 then
                        sizeX, sizeY = 18, 18
                        imgui.SetCursorPos(imgui.ImVec2(170, 90))
                        imgui.Image(emoji_fire, imgui.ImVec2(sizeX, sizeY))
                        imgui.PushFont(font_dubnamesrv)
                        imgui.SetCursorPos(imgui.ImVec2(190, 90))
                    elseif ini.main.size == 2 then
                        sizeX, sizeY = 25, 25
                        imgui.SetCursorPos(imgui.ImVec2(160, 90))
                        imgui.Image(emoji_fire, imgui.ImVec2(sizeX, sizeY))
                        imgui.PushFont(font_dubnamesrv2)
                        imgui.SetCursorPos(imgui.ImVec2(190, 93))
                    end
                    imgui.TextWithShadow('First Server', 0.3)
                    imgui.PopFont()
                end
			end
		imgui.End()
    end
    if rankLogo.v then
        local resX, resY = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(resX-1890, resY - 320), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(210, 80), imgui.Cond.FirstUseEver)
        imgui.Begin('Rank', rankLogo, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
        curWinPos = imgui.GetWindowPos()
        imgui.ShowCursor = false
            local ip, port = sampGetCurrentServerAddress()
            if ip == serverIP then
                local local_id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
                    if developer and ini.main.rank == "Developer" then
                        local ip, port = sampGetCurrentServerAddress()
                        if ip == serverIP then
                            sizeX, sizeY = 200, 40
                            imgui.Image(developer, imgui.ImVec2(sizeX, sizeY))
                        end
                    end
                    if tester and ini.main.rank == "Tester" then
                        local ip, port = sampGetCurrentServerAddress()
                        if ip == serverIP then
                            sizeX, sizeY = 200, 40
                            imgui.Image(tester, imgui.ImVec2(sizeX, sizeY))
                        end
                    end
                    if ini.main.rank == "Player" then
                        local ip, port = sampGetCurrentServerAddress()
                        if ip == serverIP then
                            sizeX, sizeY = 200, 40
                            imgui.Image(player, imgui.ImVec2(sizeX, sizeY))
                        end
                    end
                    if ini.main.rank == "Player1" then
                        local ip, port = sampGetCurrentServerAddress()
                        if ip == serverIP then
                            sizeX, sizeY = 200, 40
                            imgui.Image(player1, imgui.ImVec2(sizeX, sizeY))
                        end
                    end
                    if ini.main.rank == "Player2" then
                        local ip, port = sampGetCurrentServerAddress()
                        if ip == serverIP then
                            sizeX, sizeY = 200, 40
                            imgui.Image(player2, imgui.ImVec2(sizeX, sizeY))
                        end
                    end
            end
        imgui.End()
    end
    if window.v then
        local resX, resY = getScreenResolution()     
        imgui.SetNextWindowPos(imgui.ImVec2(pos.x, pos.y), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(390, 110), imgui.Cond.FirstUseEver)
        imgui.Begin('HUD BY HARRY', window, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + (POSEDIT and 0 or 4))
        curWinPos = imgui.GetWindowPos()
        imgui.ShowCursor = false
        local barSize = {x = 250, y = 10}
        local info = getPlayer()

        drawWeaponIcon(info, ini.main.size)
        drawAmmo(info, ini.main.size)
        --==[HEALTH BAR]==--
        imgui.SetCursorPos(imgui.ImVec2(100, 15))
        imgui.DrawBar(info.hp, fa.ICON_FA_HEART, 200, 10, 0x00ffffff, 0xFFff004d, 0xFF000000, true, 2, 3, 0xFFba043b)
        imgui.ValueBar(info.hp, 200, 12)
        --==[ARMOR AND STAMINA BARS]==--
        if info.armour > 0 then
            -- Отрисовка здоровья, брони и стамины
            imgui.SetCursorPos(imgui.ImVec2(100, 35))
            imgui.DrawBar(info.armour, fa.ICON_FA_SHIELD_ALT, 200, 10, 0x00ffffff, 0xFF319aff, 0xFF000000, true, 2, 3, 0xFF2370ba)
            imgui.ValueBar(info.armour, 200, 32)

            -- Проверка на кислород и стамину
            if isCharInWater(PLAYER_PED) then
                imgui.SetCursorPos(imgui.ImVec2(100, 55))
                imgui.DrawBar(info.stamina, fa.ICON_FA_RUNNING, 85, 10, 0x00ffffff, 0xFF06a562, 0xFF000000, true, 2, 3, 0xFF058750) -- Уменьшенный размер
                imgui.ValueBar(info.stamina, 140, 52)

                --==[OXYGEN BAR]==--
                if info.oxygen ~= '100' or info.oxygen == '100' then
                    imgui.SetCursorPos(imgui.ImVec2(215, 55)) -- Правее стамины
                    imgui.DrawBar(info.oxygen, fa.ICON_FA_CIRCLE, 85, 10, 0x00ffffff, 0xFF00b3ff, 0xFF000000, true, 2, 3, 0xFF0089c2) -- Уменьшенный размер
                    imgui.ValueBar(info.oxygen, 260, 52)
                end
            else
                imgui.SetCursorPos(imgui.ImVec2(100, 55))
                imgui.DrawBar(info.stamina, fa.ICON_FA_RUNNING, 200, 10, 0x00ffffff, 0xFF06a562, 0xFF000000, true, 2, 3, 0xFF058750)
                imgui.ValueBar(info.stamina, 200, 52)

                --==[OXYGEN BAR]==--
                if info.oxygen ~= '100' and isCharInWater(PLAYER_PED) then
                    imgui.SetCursorPos(imgui.ImVec2(100, 75)) -- Ниже стамины
                    imgui.DrawBar(info.oxygen, fa.ICON_FA_CIRCLE, 200, 10, 0x00ffffff, 0xFF00b3ff, 0xFF000000, true, 2, 3, 0xFF0089c2)
                    imgui.ValueBar(info.oxygen, 200, 73)
                end
            end
        else
            -- Отрисовка здоровья и стамины, если брони нет
            imgui.SetCursorPos(imgui.ImVec2(100, 35))
            imgui.DrawBar(info.stamina, fa.ICON_FA_RUNNING, 200, 10, 0x00ffffff, 0xFF06a562, 0xFF000000, true, 2, 3, 0xFF058750)
            imgui.ValueBar(info.stamina, 200, 32)

            --==[OXYGEN BAR]==--
            if info.oxygen ~= '100' or info.oxygen == '100' and isCharInWater(PLAYER_PED) then
                imgui.SetCursorPos(imgui.ImVec2(100, 55)) -- Ниже стамины
                imgui.DrawBar(info.oxygen, fa.ICON_FA_CIRCLE, 200, 10, 0x00ffffff, 0xFF00b3ff, 0xFF000000, true, 2, 3, 0xFF0089c2)
                imgui.ValueBar(info.oxygen, 200, 52)
            end
        end
        --imgui.Separator()
        --==[MONEY]==--
        local ip, port = sampGetCurrentServerAddress()
        if ip ~= serverIP then
            if ini.main.size == 1 then
                sizeX, sizeY = 390, 190
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.36, 0.74, 0.35, 0.2))
                imgui.PushFont(font_money)
                if info.money >= 0 then
                    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.36, 0.74, 0.35, 1))
                else
                    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 0.37, 0.37, 1))
                end
                moneyPosY = 50
                imgui.SetCursorPos(imgui.ImVec2(sizeX - imgui.CalcTextSize('$').x - 10, moneyPosY))
                imgui.TextWithShadow('$', 0.5, 0xFF66CC00)
                local moneyText = tostring(info.money)
                imgui.SetCursorPos(imgui.ImVec2(sizeX - imgui.CalcTextSize('$').x - 15 - imgui.CalcTextSize(moneyText).x, moneyPosY))
                imgui.TextWithShadow(moneyText, 0.5)
            elseif ini.main.size == 2 then
                sizeX, sizeY = 410, 190
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.36, 0.74, 0.35, 0.2))
                imgui.PushFont(font_money)
                if info.money >= 0 then
                    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.36, 0.74, 0.35, 1))
                else
                    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 0.37, 0.37, 1))
                end
                moneyPosY = 50
                imgui.SetCursorPos(imgui.ImVec2(sizeX - imgui.CalcTextSize('$').x - 30, moneyPosY))
                imgui.TextWithShadow('$', 0.5, 0xFF66CC00)
                local moneyText = tostring(info.money)
                imgui.SetCursorPos(imgui.ImVec2(sizeX - imgui.CalcTextSize('$').x - 30 - imgui.CalcTextSize(moneyText).x, moneyPosY))
                imgui.TextWithShadow(moneyText, 0.5)
            end
            imgui.PopFont()
        else
            if ini.main.size == 1 then
                sizeX, sizeY = 390, 190
                moneyPosY = 80
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.36, 0.74, 0.35, 0.2))
                imgui.PushFont(font_money)
                if info.money >= 0 then
                    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.36, 0.74, 0.35, 1))
                else
                    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 0.37, 0.37, 1))
                end
                imgui.SetCursorPos(imgui.ImVec2(sizeX - imgui.CalcTextSize('$').x - 10, moneyPosY))
                imgui.TextWithShadow('$', 0.5, 0xFF66CC00)
                local moneyText = tostring(info.money)
                imgui.SetCursorPos(imgui.ImVec2(sizeX - imgui.CalcTextSize('$').x - 15 - imgui.CalcTextSize(moneyText).x, moneyPosY))
                imgui.TextWithShadow(moneyText, 0.5)
                imgui.PopFont()
            elseif ini.main.size == 2 then
                sizeX, sizeY = 410, 210
                moneyPosY = 80
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.36, 0.74, 0.35, 0.2))
                imgui.PushFont(font_money)
                if info.money >= 0 then
                    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.36, 0.74, 0.35, 1))
                else
                    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 0.37, 0.37, 1))
                end
                imgui.SetCursorPos(imgui.ImVec2(sizeX - imgui.CalcTextSize('$').x - 30, moneyPosY))
                imgui.TextWithShadow('$', 0.5, 0xFF66CC00)
                local moneyText = tostring(info.money)
                imgui.SetCursorPos(imgui.ImVec2(sizeX - imgui.CalcTextSize('$').x - 35 - imgui.CalcTextSize(moneyText).x, moneyPosY))
                imgui.TextWithShadow(moneyText, 0.5)
                imgui.PopFont()
            end
        end

        
        --==[REP]==--
        local ip, port = sampGetCurrentServerAddress()
        if ip == serverIP then
            if ini.main.size == 1 then
                sizeX, sizeY = 390, 120
                local REPPosY = 55
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.36, 0.74, 0.35, 0.2))
                imgui.PushFont(font_money)
                if info.playerREP >= "0" then
                    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.16, 0.25, 0.75, 1))
                else
                    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 0.37, 0.37, 1))
                end
                imgui.SetCursorPos(imgui.ImVec2(sizeX - imgui.CalcTextSize("REP").x-175 - 20 + 210, REPPosY))
                imgui.PushFont(font_money)
                imgui.TextWithShadow('R', 0.5, 0xFF66CC00)
                imgui.PopFont()
                local REPText = formatREP(tostring(info.playerREP))
                imgui.SetCursorPos(imgui.ImVec2(sizeX - imgui.CalcTextSize("REP").x-175 - 25 - imgui.CalcTextSize(REPText).x + 210, REPPosY))
                imgui.TextWithShadow(REPText, 0.5)
                imgui.PopFont()
                imgui.PopStyleColor(2)
            elseif ini.main.size == 2 then
                sizeX, sizeY = 410, 210
                local REPPosY = 55
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.36, 0.74, 0.35, 0.2))
                imgui.PushFont(font_money)
                if info.playerREP >= "0" then
                    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.16, 0.25, 0.75, 1))
                else
                    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 0.37, 0.37, 1))
                end
                imgui.SetCursorPos(imgui.ImVec2(sizeX - imgui.CalcTextSize("REP").x-175 - 40 + 210, REPPosY))
                imgui.PushFont(font_money)
                imgui.TextWithShadow('R', 0.5, 0xFF66CC00)
                imgui.PopFont()
                local REPText = formatREP(tostring(info.playerREP))
                imgui.SetCursorPos(imgui.ImVec2(sizeX - imgui.CalcTextSize("REP").x-175 - 45 - imgui.CalcTextSize(REPText).x + 210, REPPosY))
                imgui.TextWithShadow(REPText, 0.5)
                imgui.PopFont()
                imgui.PopStyleColor(2)
            end
        end

        --==[WANTED]==--
        if ini.main.size == 1 then
            sizeX, sizeY = 390, 120
            local wantedText = ''
            for i = 1, info.wanted do
                wantedText = wantedText..fa.ICON_FA_STAR
            end
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 0.87, 0.2, 1))
            imgui.SetCursorPos(imgui.ImVec2(sizeX-100 - imgui.CalcTextSize('P').x - 10 - imgui.CalcTextSize(wantedText).x, moneyPosY-15))
            imgui.TextWithShadow(wantedText, 0.5)
            imgui.PopStyleColor(3)
        elseif ini.main.size == 2 then
            local wantedText = ''
            for i = 1, info.wanted do
                wantedText = wantedText..fa.ICON_FA_STAR
            end
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 0.87, 0.2, 1))
            imgui.SetCursorPos(imgui.ImVec2(sizeX-120 - imgui.CalcTextSize('P').x - 10 - imgui.CalcTextSize(wantedText).x, moneyPosY - 15))
            imgui.TextWithShadow(wantedText, 0.5)
            imgui.PopStyleColor(3)
        end
        --DATE AND TIME

        imgui.End()
    end
	
    if dateTime.v then
        local ip, port = sampGetCurrentServerAddress()
        if ip ~= serverIP then
            local resX, resY = getScreenResolution()
            local sizeX, sizeY = 200, 10
            
            imgui.SetNextWindowPos(imgui.ImVec2(datepos.x + 40, datepos.y-45), imgui.Cond.FirstUseEver)
            imgui.SetNextWindowSize(imgui.ImVec2(sizeX+100, sizeY), imgui.Cond.FirstUseEver)
            imgui.Begin('HUD (date and time)', dateTime, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + (POSEDIT and 0 or 4))
            curDateWinPos = imgui.GetWindowPos()
            imgui.ShowCursor = false
            imgui.TextWithShadow(fa.ICON_FA_CLOCK..os.date(' %H:%M:%S')..'       ' .. fa.ICON_FA_CLOCK..os.date('! %H:%M:%S', os.time() + 3 * 60 * 60) ..'       '..fa.ICON_FA_CALENDAR_ALT..os.date(' %d.%m.%y'), 0.2)
        else
            local resX, resY = getScreenResolution()
            local sizeX, sizeY = 200, 10
            
            imgui.SetNextWindowPos(imgui.ImVec2(datepos.x + 40, datepos.y-10), imgui.Cond.FirstUseEver)
            imgui.SetNextWindowSize(imgui.ImVec2(sizeX+100, sizeY), imgui.Cond.FirstUseEver)
            imgui.Begin('HUD (date and time)', dateTime, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + (POSEDIT and 0 or 4))
            curDateWinPos = imgui.GetWindowPos()
            imgui.ShowCursor = false
            imgui.TextWithShadow(fa.ICON_FA_CLOCK..os.date(' %H:%M:%S')..'       ' .. fa.ICON_FA_CLOCK..os.date('! %H:%M:%S', os.time() + 3 * 60 * 60) ..'       '..fa.ICON_FA_CALENDAR_ALT..os.date(' %d.%m.%y'), 0.2)
        end
        imgui.End()
    end
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

function formatREP(repString)
    -- Убираем 'Р' и ведущие нули
    local number = repString:gsub("P0*", "")
    -- Если строка пустая (были только нули), возвращаем "0"
    if number == "" then return "0" end
    return number
end

function imgui.DrawBar(value, icon, sizeX, sizeY, textColor, barColor, backColor, drawOutline, outlineOpacity, outlineSize, wcolor)
    local cur = imgui.GetCursorPos()
    local col_text_a, col_text_r, col_text_g, col_text_b = explode_argb(textColor)
    local barColor_a, barColor_r, barColor_g, barColor_b = explode_argb(barColor)
    local backColor_a, backColor_r, backColor_g, backColor_b = explode_argb(backColor)

    imgui.SetCursorPos(imgui.ImVec2(cur.x + 60, cur.y - 10))
    imgui.TextWithShadow(icon, 0.2, barColor)

    if drawOutline then
        imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0, 0, 0, 0.0))
        imgui.SetCursorPos(imgui.ImVec2(cur.x + 85, cur.y - 10))
        imgui.PopStyleColor()
    end

    -- Получаем позицию прогресс-бара
    local barPos = imgui.GetCursorScreenPos()
    if ini.main.size == 1 then
        local barEnd = imgui.ImVec2(barPos.x + sizeX, barPos.y + sizeY)

        -- Отрисовка ProgressBar (фон)
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_text_r / 255, col_text_g / 255, col_text_b / 255, col_text_a / 255))
        imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(backColor_r / 255, backColor_g / 255, backColor_b / 255, 0.5))
        imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(barColor_r / 255, barColor_g / 255, barColor_b / 255, barColor_a / 255))
        
        imgui.ProgressBar(value / 100, imgui.ImVec2(sizeX, sizeY))
        imgui.PopStyleColor(3)

        -- Настройки волны

        local dynamicAmplitude = baseAmplitude + math.sin(waveTime * amplitudeSpeed) * ((maxAmplitude - minAmplitude) / 2)

        local time = os.clock() * 2
        local frequency, speed = 3, 1
        local waveColor_a, waveColor_r, waveColor_g, waveColor_b = explode_argb(wcolor)
        local drawList = imgui.GetWindowDrawList()
        local col = imgui.GetColorU32(imgui.ImVec4(waveColor_r / 255, waveColor_g / 255, waveColor_b / 255, waveColor_a / 255))
        local waveThickness = 2

        -- Обрезка области рисования (чтобы волна не выходила за рамки)
        imgui.PushClipRect(barPos, barEnd, true)

        local effectiveWidth = (sizeX * value) / 100
        -- Рисуем волну
        for i = 0, effectiveWidth-3, 1 do
            local waveHeight = dynamicAmplitude * math.sin((i / sizeX) * (math.pi * 2) + time * frequency)+3
            local nextWaveHeight = dynamicAmplitude * math.sin(((i + 1) / sizeX) * (math.pi * 2) + time * frequency) + 10
            
            local pos = imgui.ImVec2(barPos.x + i, barPos.y + (sizeY / 2) + waveHeight)
            local nextPos = imgui.ImVec2(barPos.x + i + 1, barPos.y + (sizeY / 2) + nextWaveHeight)

            -- Дублируем линии для утолщения волны
            for offset = -waveThickness / 1, waveThickness / 1, 1 do
                drawList:AddLine(
                    imgui.ImVec2(pos.x, pos.y + offset),
                    imgui.ImVec2(nextPos.x, nextPos.y + offset),
                    col,
                    2
                )
            end
        end

        imgui.PopClipRect() -- Завершаем область отсечения
    elseif ini.main.size == 2 then
        local barEnd = imgui.ImVec2(barPos.x + sizeX, barPos.y + sizeY+3)

        -- Отрисовка ProgressBar (фон)
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(col_text_r / 255, col_text_g / 255, col_text_b / 255, col_text_a / 255))
        imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(backColor_r / 255, backColor_g / 255, backColor_b / 255, 0.5))
        imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(barColor_r / 255, barColor_g / 255, barColor_b / 255, barColor_a / 255))
        
        imgui.ProgressBar(value / 100, imgui.ImVec2(sizeX+3, sizeY+3))
        imgui.PopStyleColor(3)

        -- Настройки волны

        local dynamicAmplitude = baseAmplitude + math.sin(waveTime * amplitudeSpeed) * ((maxAmplitude - minAmplitude) / 2)

        local time = os.clock() * 2
        local frequency, speed = 3, 1
        local waveColor_a, waveColor_r, waveColor_g, waveColor_b = explode_argb(wcolor)
        local drawList = imgui.GetWindowDrawList()
        local col = imgui.GetColorU32(imgui.ImVec4(waveColor_r / 255, waveColor_g / 255, waveColor_b / 255, waveColor_a / 255))
        local waveThickness = 2

        -- Обрезка области рисования (чтобы волна не выходила за рамки)
        imgui.PushClipRect(barPos, barEnd, true)

        local effectiveWidth = (sizeX * value) / 100
        -- Рисуем волну
        for i = 0, effectiveWidth-3, 1 do
            local waveHeight = dynamicAmplitude * math.sin((i / sizeX+5) * (math.pi * 2) + time * frequency)+3
            local nextWaveHeight = dynamicAmplitude * math.sin(((i + 1) / sizeX+5) * (math.pi * 2) + time * frequency) + 10
            
            local pos = imgui.ImVec2(barPos.x + i, barPos.y + (sizeY-3 / 2) + waveHeight)
            local nextPos = imgui.ImVec2(barPos.x + i + 1, barPos.y + (sizeY-3 / 2) + nextWaveHeight)

            -- Дублируем линии для утолщения волны
            for offset = -waveThickness / 1, waveThickness / 1, 1 do
                drawList:AddLine(
                    imgui.ImVec2(pos.x, pos.y + offset),
                    imgui.ImVec2(nextPos.x, nextPos.y + offset),
                    col,
                    2
                )
            end
        end

        imgui.PopClipRect() -- Завершаем область отсечения
    end
end




function imgui.ValueBar(value, sizeX, sizeY)
    imgui.PushFont(font_bar)
    imgui.SetCursorPos(imgui.ImVec2(sizeX+75, sizeY-9.5))
    imgui.TextWithShadow(tostring(value), 1)
    imgui.PopFont()
end

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

local playerHealth = 100
local playerREP = 0

function onReceiveRpc(id, bs)
    local ip, port = sampGetCurrentServerAddress()
    if ip == serverIP then
        if id == 134 then
            local textdraw = read_bitstream(bs)
            if textdraw.id == 2180 then
                -- Убедимся, что значение не превышает 100
                playerHealth = math.min(textdraw.health, 100)
                return false
            end
        end
    else
        return
    end
end

-- Функция для чтения битстрима текстдрава
function read_bitstream(bs)
    local data = {}
    data.id = raknetBitStreamReadInt16(bs)
    raknetBitStreamIgnoreBits(bs, 104)
    local rawValue = raknetBitStreamReadFloat(bs)
    data.color = raknetBitStreamReadInt32(bs)
    data.x = raknetBitStreamReadFloat(bs)
    data.y = raknetBitStreamReadFloat(bs)
    if data.id == 2180 and data.color == 1083598438 or data.color == 1083598438 then
        data.health = (rawValue / 57.7999) * 100
        data.health = math.floor(data.health + 0.5)
    else
        data.health = 100
    end
    return data
end

function sampev.onShowTextDraw(id, data)
    local ip, port = sampGetCurrentServerAddress()
    if ip == serverIP then
        local found_textdraws = {}
        lua_thread.create(function()

            wait(2000)

            if data.text:find("rankTester") then
                ini.main.rankid = id
                inicfg.save(ini, directIni)
                local namerank = sampTextdrawGetString(id)
                print(namerank)
                table.insert(textdraws_to_hide, id)
                if namerank == "Developer" and ini.main.rank == "Player" or ini.main.rank == "Player1" or ini.main.rank == "Player2" then
                    ini.main.rank = "Developer"
                    inicfg.save(ini, directIni)
                elseif namerank == "Tester" and ini.main.rank == "Player" or ini.main.rank == "Player1" or ini.main.rank == "Player2" then
                    ini.main.rank = "Tester"
                    inicfg.save(ini, directIni)
                elseif ini.main.rank == "Developer" then
                    ini.main.rank = "Developer"
                    inicfg.save(ini, directIni)
                elseif ini.main.rank == "Tester" then
                    ini.main.rank = "Tester"
                    inicfg.save(ini, directIni)
                elseif ini.main.rank == "nil" then
                    local randrank = random(0,2)
                    if randrank == 0 then
                        print(randrank)
                        ini.main.rank = "Player"
                        inicfg.save(ini, directIni)
                    elseif randrank == 1 then
                        print(randrank)
                        ini.main.rank = "Player1"
                        inicfg.save(ini, directIni)
                    elseif randrank == 2 then
                        print(randrank)
                        ini.main.rank = "Player2"
                        inicfg.save(ini, directIni)
                    end
                end
            elseif not data.text:find("rankTester") then
                local randrank = random(0,2)
                if randrank == 0 and stopslovo == false then
                    print(randrank)
                    ini.main.rank = "Player"
                    inicfg.save(ini, directIni)
                    stopslovo = true
                elseif randrank == 1 and stopslovo == false then
                    print(randrank)
                    ini.main.rank = "Player1"
                    inicfg.save(ini, directIni)
                    stopslovo = true
                elseif randrank == 2 and stopslovo == false then
                    print(randrank)
                    ini.main.rank = "Player2"
                    inicfg.save(ini, directIni)
                    stopslovo = true
                end
            end

            if data.letterColor == -16776961 or data.letterColor == -1 and data.style == 4 and data.boxColor == -2139062144 and data.lineWidth == 7 and data.color == -1 then
                table.insert(textdraws_to_hide, id)
            end

            --if id == 1 then
                --print("Textdraw 1 detected!")
                --print("Data: " .. tostring(data)) -- Выводим содержимое data
                --for k, v in pairs(data) do
                    --print("Key: " .. tostring(k) .. ", Value: " .. tostring(v)) -- Проверяем структуру data
                --end
            --end

            if data.letterColor == -15856550 and data.shadow == 2 and data.color == -1 and data.style == 4 and data.text == "LD_SPAC:white" then
                table.insert(textdraws_to_hide, id)
                ini.main.hp2 = id
                inicfg.save(ini, directIni)
            end

            if data.letterColor == -16777216 and data.shadow == 2 and data.color == -1 and data.style == 4 and data.text == "LD_SPAC:white" then
                table.insert(textdraws_to_hide, id)
                ini.main.hp1 = id
                inicfg.save(ini, directIni)
            end


            if data.text:find("%d+%-%d+%-%d+%s*%d+%:%d+%:%d+") then
                table.insert(textdraws_to_hide, id)
                ini.main.time = id
                inicfg.save(ini, directIni)
            end

            if data.text:find("R000") then
                ini.main.rep = id
                inicfg.save(ini, directIni)
            end

            if textdrawR == false then
                wait(2500)
                for _, tdid in ipairs(textdraws_to_hide) do
                    if id == tdid then
                        -- Создаём невидимый текстдрав
                        sampTextdrawSetPos(id, -9999, -9999)
                        return false
                    end
                end
                textdrawR = true
            end
        end)
    end
end

function getPlayer()
    local info = {
        wanted = memory.getuint8(0x58DB60),
        id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)),
        name = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))),
        lvl = sampGetPlayerScore(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))),
        money = getPlayerMoney(PLAYER_HANDLE),
        hp = playerHealth,
        playerREP = sampTextdrawGetString(ini.main.rep),
        armour = getCharArmour(PLAYER_PED),
        stamina = ("%.0f"):format(memory.getfloat(0xB7CDB4)/31.47000244),
        oxygen = ("%.0f"):format(memory.getfloat(0xB7CDE0)/39.97000244),
        weapon = getCurrentCharWeapon(PLAYER_PED),
        ammo = getAmmoInCharWeapon(PLAYER_PED, getCurrentCharWeapon(PLAYER_PED)),
        ammoInClip = getAmmoInClip(),
    }
    return info
end

function getAmmoInClip()
    local pointer = getCharPointer(playerPed)
    local weapon = getCurrentCharWeapon(playerPed)
    local slot = getWeapontypeSlot(weapon)
    local cweapon = pointer + 0x5A0
    local current_cweapon = cweapon + slot * 0x1C
    return memory.getuint32(current_cweapon + 0x8)
end

function BH_theme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
 
    style.WindowPadding = ImVec2(6, 4)
    style.WindowRounding = 5.0
    style.ChildWindowRounding = 5.0
    style.FramePadding = ImVec2(5, 2)
    style.FrameRounding = 5.0
    style.ItemSpacing = ImVec2(7, 5)
    style.ItemInnerSpacing = ImVec2(1, 1)
    style.TouchExtraPadding = ImVec2(0, 0)
    style.IndentSpacing = 6.0
    style.ScrollbarSize = 12.0
    style.ScrollbarRounding = 5.0
    style.GrabMinSize = 20.0
    style.GrabRounding = 2.0
    style.WindowTitleAlign = ImVec2(0.5, 0.5)

    colors[clr.Button]               = ImVec4(0.16, 0.18, 0.22, 1)
    colors[clr.WindowBg]             = ImVec4(0.16, 0.18, 0.22, 0)
end
BH_theme()