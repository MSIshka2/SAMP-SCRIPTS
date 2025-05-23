require "lib.moonloader"
local encoding = require('encoding')
local sampev = require('samp.events')
local vector3d = require('vector3d')
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local bitex = require('bitex')
local memory = require "memory"
local ffi = require 'ffi'
local fa = require('fAwesome6_solid')
local imgui = require('mimgui')
local inicfg = require 'inicfg'
local MainIni = inicfg.load({
    settings = {
        main_theme = 1,
        transparent_bg = 50,
		show_actions_menu = true,
        colored_id = true,
        colored_nickname = true,
        colored_score = true,
        colored_ping = true,
		
    }
}, "MimguiScoreboard.ini")
local new = imgui.new
local renderTAB, renderSettings = new.bool(), new.bool()
local radiobutton_theme1 = MainIni.settings.main_theme == 1
local radiobutton_theme2 = MainIni.settings.main_theme == 2
local radiobutton_theme3 = MainIni.settings.main_theme == 3
local checkbox_fon = new.bool(MainIni.settings.transparent_bg)
local inputField = new.char[256]()
local checkbox1 = new.bool(MainIni.settings.colored_id)
local checkbox2 = new.bool(MainIni.settings.colored_nickname)
local checkbox3 = new.bool(MainIni.settings.colored_score)
local checkbox4 = new.bool(MainIni.settings.colored_ping)
local checkbox5 = new.bool(MainIni.settings.show_actions_menu)
local SliderOne = new.int(MainIni.settings.transparent_bg)
local sizeX, sizeY = getScreenResolution()

local query = {}
local renderChatBuble = imgui.new.bool()
local fontSelected = imgui.new.int()
local fontChanged, fontSizeChanged = false, false
local fontSlider = imgui.new.int()
local fadeInSlider = imgui.new.float()
local fadeOutSlider = imgui.new.float()
local outlineSizeSlider = imgui.new.float()
local heightSlider = imgui.new.float()

local pathconfig = getWorkingDirectory() .. "\\config\\customizable.json"
if not doesFileExist(pathconfig) then
	createDirectory(getWorkingDirectory() .. "\\config\\")
    config = {
        wallhack = false,
        serverdistance = false,
        outline = true,
        outline_size = 0.9,
        font = 'arial.ttf',
        fontsize = 15,
        fade_in = 0.2,
        fade_out = 0.1,
        height = 0.26
    }
    local file = io.open(pathconfig, "wb")
	file:write(encodeJson(config))
    file:flush()
	file:close()
else
    local file = io.open(pathconfig, "rb")
    config = decodeJson(file:read("*a"))
end

function main()

    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end 
	
	sampAddChatMessage(u8:decode('{ff0000}[INFO] {ffffff}Скрипт "Scoreboard" загружен!'), -1)
	
	sampRegisterChatCommand('tab', function()
		renderTAB[0] = not renderTAB[0]
    end)
	
	sampRegisterChatCommand('ccb', function()
        renderChatBuble[0] = not renderChatBuble[0]
    end)

	while true do
		wait(0)
		
		if sampIsScoreboardOpen() then 
			sampToggleScoreboard(false) 
		end
			
		
		
	end
	
end

function explode_argb(argb)
    return bit.band(bit.rshift(argb, 24), 0xFF),
           bit.band(bit.rshift(argb, 16), 0xFF),
           bit.band(bit.rshift(argb, 8), 0xFF),
           bit.band(argb, 0xFF)
end

function hexToArgb(hexStr)
    local argb = tonumber(hexStr:gsub("[{}]", ""), 16)
    return #hexStr == 6 and argb + 0xFF000000 or argb
end

function imgui.drawColoredTextDL(dl, position, color, text)
    if not text:find("{") then dl:AddText(position, imgui.ColorConvertFloat4ToU32(color), text) else text = '{ffffff}' .. text end
    local currentPos = position
    for hex, part in text:gmatch("{([^}]+)}([^{]*)") do
        local a, r, g, b = explode_argb(hexToArgb(hex))
        local vecColor = imgui.ImVec4(r/255, g/255, b/255, color.w)
        dl:AddText(currentPos, imgui.ColorConvertFloat4ToU32(vecColor), part)
        currentPos.x = currentPos.x + imgui.CalcTextSize(part).x
    end
end

function getNameTagPosForText(handle)
    local localPlayerPos = vector3d(getActiveCameraCoordinates())
    local pPlayerPos = vector3d(getBodyPartCoordinates(8, handle))
    return pPlayerPos.x, pPlayerPos.y, pPlayerPos.z + config.height + (getDistanceBetweenCoords3d(localPlayerPos.x, localPlayerPos.y, localPlayerPos.z, pPlayerPos.x, pPlayerPos.y, pPlayerPos.z) * 0.04)
end

local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
function getBodyPartCoordinates(id, handle)
    local pedptr = getCharPointer(handle)
    local vec = ffi.new("float[3]")
    getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
    return vec[0], vec[1], vec[2]
end

function wallPlayer(handle, distance)
    if doesCharExist(handle) then
        local camX, camY, camZ = getActiveCameraCoordinates()
        local x, y, z = getCharCoordinates(handle)
        local maxDistance = config.serverdistance and distance or 50
        local withinDistance = getDistanceBetweenCoords3d(camX, camY, camZ, x, y, z) <= maxDistance
        
        if not (withinDistance and isCharOnScreen(handle)) then
            return false
        end
        
        return config.wallhack or isLineOfSightClear(camX, camY, camZ, x, y, z, true, false, false, true, false)
    end
end

function getNearestPlayer()
    local distance, handle = 10000, nil
    for k, v in pairs(getAllChars()) do
        if v ~= PLAYER_PED then
            local x, y, z = getCharCoordinates(PLAYER_PED)
            local px, py, pz = getCharCoordinates(v)
            dist = getDistanceBetweenCoords3d(x, y, z, px, py, pz)
            if dist < distance then
                distance, handle = dist, v
            end
        end
    end
    return handle
end

function sampev.onPlayerChatBubble(playerId, color, distance, duration, message)
    query[playerId] = nil

    local a, r, g, b = explode_argb(color)
    query[playerId] = {
        message = message,
        create_time = os.clock(),
        duration = duration / 1000,
        distance = distance,
        fade_in = config.fade_in,
        fade_out = config.fade_out,
        color = imgui.ImVec4(r/255, g/255, b/255, 0.0),
        outline_color = imgui.ImVec4(0.0, 0.0, 0.0, 0.0)
    }
    
    return false
end

function drawOutlinedText(dl, pos, text, text_color, outline_color, outline_size)
    for x = -outline_size, outline_size, outline_size do
        for y = -outline_size, outline_size, outline_size do
            if x ~= 0 or y ~= 0 then
                local formattedText = text:gsub('{......}', '')
                dl:AddText(
                    imgui.ImVec2(pos.x + x, pos.y + y),
                    imgui.ColorConvertFloat4ToU32(outline_color),
                    formattedText
                )
            end
        end
    end
    imgui.drawColoredTextDL(dl, pos, text_color, text)
end

imgui.OnInitialize(function()

    imgui.GetIO().IniFilename = nil
	local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
	imgui.GetIO().Fonts:Clear()
	local fontPath = ('%s\\%s'):format(getFolderPath(0x14), config.font)
	imgui.GetIO().Fonts:AddFontFromFileTTF(fontPath, config.fontsize, nil, glyph_ranges)
	fonts = {}
	fontsArray = {}
	local search, file = findFirstFile(getFolderPath(0x14) .. '\\*.ttf') -- https://www.blast.hk/threads/42895/
	while file do 
		table.insert(fonts, file)
		file = findNextFile(search)
	end

    fontsArray = imgui.new['const char*'][#fonts](fonts)
    fontSlider[0], fadeInSlider[0], fadeOutSlider[0], outlineSizeSlider[0], heightSlider[0] = config.fontsize, config.fade_in, config.fade_out, config.outline_size, config.height
    for k, v in pairs(fonts) do
        if v == config.font then
            fontSelected[0] = k - 1
        end
    end


	fa.Init(14 )
	
    if MainIni.settings.main_theme == 1 then
		dark_theme()
	elseif MainIni.settings.main_theme == 2 then
		blue_theme()
	elseif MainIni.settings.main_theme == 3 then
		fiol_theme()
	end
	
	local alpha = tonumber(SliderOne[0] / 100)
	
	if MainIni.settings.main_theme == 1 then
		imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
		imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
		imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
		imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
		imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
	elseif MainIni.settings.main_theme == 2 then
		imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
		imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
		imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
		imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
		imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
	elseif MainIni.settings.main_theme == 3 then
		imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
		imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
		imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
		imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
		imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
	end
	
end)

local menu = imgui.OnFrame(
    function() return renderChatBuble[0] end,
    function(player1)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 300, 350
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        if imgui.Begin('customizable chatbubbles', renderChatBuble, imgui.WindowFlags.NoResize) then
            if imgui.RadioButtonBool('WallHack', config.wallhack) then config.wallhack = not config.wallhack end
            imgui.SameLine()
            if imgui.RadioButtonBool('Обводка', config.outline) then config.outline = not config.outline end
            if imgui.RadioButtonBool('Рендер на серверном расстоянии', config.serverdistance) then config.serverdistance = not config.serverdistance end
            if imgui.Combo('Шрифт', fontSelected, fontsArray, #fonts) then
                fontChanged = true
            end
            if imgui.SliderInt('Размер', fontSlider, 0, 24) then
                fontSizeChanged = true
            end
            if imgui.SliderFloat('Появление', fadeInSlider, 0.0, 1.0) then
                config.fade_in = fadeInSlider[0]
            end
            if imgui.SliderFloat('Скрытие', fadeOutSlider, 0.0, 1.0) then
                config.fade_out = fadeOutSlider[0]
            end
            if imgui.SliderFloat('Обводка##', outlineSizeSlider, 0.0, 2.0) then
                config.outline_size = outlineSizeSlider[0]
            end
            if imgui.SliderFloat('Высота', heightSlider, 0.0, 1.0) then
                config.height = heightSlider[0]
            end
            if imgui.Button('Тест на ближайшем игроке') then
                local nearstPlayer = getNearestPlayer()
                local res, id = sampGetPlayerIdByCharHandle(nearstPlayer)
                query[id] = nil
                query[id] = {
                    message = u8:decode('Тестовый чат бабл.'),
                    create_time = os.clock(),
                    duration = 3000 / 1000,
                    fade_in = config.fade_in,
                    fade_out = config.fade_out,
                    color = imgui.ImVec4(1.0, 1.0, 1.0, 0.0),
                    outline_color = imgui.ImVec4(0.0, 0.0, 0.0, 0.0)
                }
            end
            imgui.Text('author: Harry')
            imgui.SameLine(200)
            imgui.End()
        end
    end
)

local chatbubbles = imgui.OnFrame(
    function() return true end,
    function (player3)
        if fontChanged then
            fontChanged = false
            local glyphRanges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
            local fontPath = ('%s\\%s'):format(getFolderPath(0x14), fonts[fontSelected[0] + 1])
            imgui.GetIO().Fonts:Clear()
            imgui.GetIO().Fonts:AddFontFromFileTTF(fontPath, fontSlider[0], nil, glyphRanges)
            -- Font texture invalidation forces the font texture to rebuild. It is necessary after font modifications
            imgui.InvalidateFontsTexture()
            config.font = fonts[fontSelected[0] + 1]
        end
        if fontSizeChanged then
            fontSizeChanged = false
            local fonts = imgui.GetIO().Fonts.ConfigData
            for i = 0, fonts:size() - 1 do
                fonts.Data[i].SizePixels = fontSlider[0]
            end
            imgui.GetIO().Fonts:ClearTexData()
            imgui.InvalidateFontsTexture()
            config.fontsize = fontSlider[0]
        end
    end,
    function(self)
        self.HideCursor = true
        local dl = imgui.GetBackgroundDrawList()
        local current_time = os.clock()

        for playerId, data in pairs(query) do
            local elapsed = current_time - data.create_time
            local remaining = data.duration - elapsed

            if elapsed < data.fade_in then
                local progress = elapsed / data.fade_in
                data.color.w = progress
                data.outline_color.w = progress * 0.7
            elseif remaining < data.fade_out then
                local progress = remaining / data.fade_out
                data.color.w = progress
                data.outline_color.w = progress * 0.7
            else
                data.color.w = 1.0
                data.outline_color.w = 0.7
            end

            if elapsed > data.duration then
                query[playerId] = nil
            else
                local res, handle = sampGetCharHandleBySampPlayerId(tonumber(playerId))
                if wallPlayer(handle, data.distance) then
                    if not sampIsCursorActive() or sampIsChatInputActive() then
                        local x, y, z = getNameTagPosForText(handle)
                        local pos = imgui.ImVec2(convert3DCoordsToScreen(x, y, z))
                        local flength = data.message:gsub('{......}', '')
                        local length = (imgui.CalcTextSize(u8(flength)).x) / 2 - 1
                        local text_pos = imgui.ImVec2(pos.x - length, pos.y - 25)
                        
                        if config.outline then
                            drawOutlinedText(
                                dl,
                                text_pos,
                                u8(data.message),
                                data.color,
                                data.outline_color,
                                config.outline_size
                            )
                        else
                            imgui.drawColoredTextDL(dl, text_pos, data.color, u8(data.message))
                        end
                    end
                end
            end
        end
    end
)


local Scoreboard = imgui.OnFrame(
    function() return renderTAB[0] end,
    function(player)
	
		imgui.GetStyle().ScrollbarSize = 10 
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(800 , 573 ), imgui.Cond.FirstUseEver)
		imgui.Begin("##Begin1", renderTAB, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove )
		
		imgui.GetStyle().FrameRounding = 5.0 
		if imgui.Button(fa.GEAR) then	
			renderSettings[0] = true
			renderTAB[0] = false
		end
		if imgui.IsItemHovered() then
			imgui.SetTooltip('Открыть настройки')
		end
		
		imgui.SameLine()
		
		imgui.GetStyle().FrameRounding = 20.0 
		
		if imgui.CenterColumnButton(' ' .. u8:encode((sampGetCurrentServerName())) .. ' | '..sampGetPlayerCount(false) .. ' Игроков') then
			imgui.OpenPopup(fa.GLOBE .. ' Информация о сервере')
		end
		if imgui.BeginPopupModal(fa.GLOBE .. ' Информация о сервере', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
			
			imgui.Text('Название: ' .. u8:encode(sampGetCurrentServerName()))
			imgui.SameLine()
			imgui.PushItemWidth(10 )
			if imgui.Button(fa.COPY .. '##copy_name') then
				setClipboardText(u8:encode(sampGetCurrentServerName()))
			end
			
			local ip, port = sampGetCurrentServerAddress()
			imgui.Text('Адрес: ' .. ip .. ':' .. port)
			imgui.SameLine()
			imgui.PushItemWidth(10 )
			if imgui.Button(fa.COPY .. '##copy_ip') then
				setClipboardText(ip .. ':' .. port)
			end
			
			imgui.Text('Игроки онлайн: ' .. sampGetPlayerCount(false))
			
			if imgui.Button(fa.CIRCLE_XMARK .. ' Close', imgui.ImVec2(250 , 25 )) then
				imgui.CloseCurrentPopup()
			end
			
			imgui.End()
		end	
		
		imgui.SameLine()
		
		imgui.SetCursorPosX( imgui.GetWindowWidth() - 170 )
		imgui.PushItemWidth(135 )
		imgui.GetStyle().FrameRounding = 3.0 
		imgui.InputTextWithHint('', 'Поиск по ID/Nickname', inputField, 256)
		imgui.GetStyle().FrameRounding = 5.0 
		imgui.SameLine()
		
		imgui.SetCursorPosX( imgui.GetWindowWidth() - 30 )
		if imgui.Button(fa.CIRCLE_XMARK) then	
			renderSettings[0] = false
			renderTAB[0] = false
		end
		if imgui.IsItemHovered() then
			imgui.SetTooltip('Закрыть TAB')
		end
	
		imgui.GetStyle().FrameRounding = 20.0 
	
		imgui.Separator()

		if imgui.BeginChild('##binder_edit1', imgui.ImVec2(790 , 528 ), false) then


			if MainIni.settings.show_actions_menu then

				imgui.Columns(5)
				
				imgui.SetColumnWidth(-1, 55 ) imgui.CenterColumnText('ID') imgui.NextColumn()
				imgui.SetColumnWidth(-1, 500 ) imgui.CenterColumnText('Ник') imgui.NextColumn()
				imgui.SetColumnWidth(-1, 105 ) imgui.CenterColumnText('Очки') imgui.NextColumn()
				imgui.SetColumnWidth(-1, 65 ) imgui.CenterColumnText('Пинг') imgui.NextColumn()
				imgui.SetColumnWidth(-1, 65 ) imgui.CenterColumnText('Действие') imgui.NextColumn()
		
			else
				imgui.Columns(4)
				
				imgui.SetColumnWidth(-1, 55 ) imgui.CenterColumnText('ID') imgui.NextColumn()
				imgui.SetColumnWidth(-1, 560 ) imgui.CenterColumnText('Ник') imgui.NextColumn()
				imgui.SetColumnWidth(-1, 105 ) imgui.CenterColumnText('Очки') imgui.NextColumn()
				imgui.SetColumnWidth(-1, 65 ) imgui.CenterColumnText('Пинг') imgui.NextColumn()
			
			end
		
			if u8:decode(ffi.string(inputField)) == "" then
				imgui.Separator()
				local my_id = select(2, sampGetPlayerIdByCharHandle(playerPed))
				drawScoreboardPlayer(my_id)
				for id = 0, sampGetMaxPlayerId(false) do
					if my_id ~= id and sampIsPlayerConnected(id) then
						imgui.Separator()
						drawScoreboardPlayer(id)
					end
				end
			else
				for idd = 0, sampGetMaxPlayerId(false) do
					if sampIsPlayerConnected(idd) then
						if tostring(idd):find(ffi.string(inputField):gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1"))
						   or string.rlower(sampGetPlayerNickname(idd)):find(string.rlower(u8:decode(ffi.string(inputField))):gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")) then
							imgui.Separator()
							drawScoreboardPlayer(idd)
						end
					end
				end
			end
			
			
			imgui.NextColumn()
			imgui.Columns(1)
			imgui.Separator()
		
		imgui.EndChild() end
		
		imgui.End()
		
    end
)
local Settings = imgui.OnFrame(
    function() return renderSettings[0] end,
    function(player2)
	
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(800 , 573 ), imgui.Cond.FirstUseEver)
        imgui.Begin('Основное меню', renderSettings, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
		

		if imgui.Button(fa.CIRCLE_LEFT) then	
			renderSettings[0] = false
			renderTAB[0] = true
		end
		if imgui.IsItemHovered() then
			imgui.SetTooltip('Закрыть настройки')
		end
		
		imgui.SameLine()
		
		imgui.CenterText(fa.GEAR .. " Настройки")	

		imgui.SameLine()
		
		imgui.SetCursorPosX( imgui.GetWindowWidth() - 30 )
		if imgui.Button(fa.CIRCLE_XMARK) then	
			renderSettings[0] = false
			renderTAB[0] = false
		end
		if imgui.IsItemHovered() then
			imgui.SetTooltip('Закрыть')
		end
		
		imgui.Separator()
		
		imgui.CenterText(fa.PALETTE .. " Цветная тема:")
		if imgui.RadioButtonBool(' Темная ', radiobutton_theme1) then
			radiobutton_theme1 = true
			radiobutton_theme2 = false
			radiobutton_theme3 = false
			MainIni.settings.main_theme = 1
			inicfg.save(MainIni,"MimguiScoreboard.ini")
			dark_theme()
		end 
		if imgui.RadioButtonBool(' Синяя ', radiobutton_theme2) then
			radiobutton_theme1 = false
			radiobutton_theme3 = false
			radiobutton_theme2 = true
			MainIni.settings.main_theme = 2
			inicfg.save(MainIni,"MimguiScoreboard.ini")
			blue_theme()
		end
		if imgui.RadioButtonBool(' Фиолетовая ', radiobutton_theme3) then
			radiobutton_theme1 = false
			radiobutton_theme3 = true
			radiobutton_theme2 = false
			MainIni.settings.main_theme = 3
			inicfg.save(MainIni,"MimguiScoreboard.ini")
			fiol_theme()
		end
		imgui.Separator()
		imgui.CenterText(fa.PALETTE .. " Прозрачность:")
		imgui.PushItemWidth( imgui.GetWindowWidth() - (15 ))
		if imgui.SliderInt('', SliderOne, 0, 100) then
		
			local alpha = tonumber(SliderOne[0] / 100)
		
			MainIni.settings.transparent_bg = SliderOne[0]
			inicfg.save(MainIni,"MimguiScoreboard.ini")
		
			if MainIni.settings.main_theme == 1 then
				imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
			elseif MainIni.settings.main_theme == 2 then
				imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
			elseif MainIni.settings.main_theme == 3 then
				imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
			end
		
			
		
		
		end
		
		imgui.Separator()
		imgui.CenterText(fa.PALETTE .. (" Показ цветных элементов по клисту игрока:"))
		if imgui.Checkbox(' Цветной ID', checkbox1) then
			MainIni.settings.colored_id = checkbox1[0]
			inicfg.save(MainIni,"MimguiScoreboard.ini")
		end
		
		if imgui.Checkbox(' Цветной ник', checkbox2) then
			MainIni.settings.colored_nickname = checkbox2[0]
			inicfg.save(MainIni,"MimguiScoreboard.ini")
		end
		
		if imgui.Checkbox(' Цветные очки', checkbox3) then
			MainIni.settings.colored_score = checkbox3[0]
			inicfg.save(MainIni,"MimguiScoreboard.ini")
		end
		
		if imgui.Checkbox(' Цветной пинг', checkbox4) then
			MainIni.settings.colored_ping = checkbox4[0]
			inicfg.save(MainIni,"MimguiScoreboard.ini")
		end

		imgui.Separator()
		
		imgui.CenterText(fa. BARS.. ' Меню действий')
		if imgui.Checkbox(' Показывать действия в TAB', checkbox5) then
			MainIni.settings.show_actions_menu = checkbox5[0]
			inicfg.save(MainIni,"MimguiScoreboard.ini")
		end
		imgui.Text('Действия меню кнопок: Копировать ник и вызвать игрока')

		imgui.Separator()
		imgui.CenterText(fa.USER.. " Автор")
		imgui.TextWrapped('\n Создатель "Scoreboard" - Harry')
		imgui.End()
		
    end
)

function drawScoreboardPlayer(id)

	local nickname = u8(sampGetPlayerNickname(id))
	local score = sampGetPlayerScore(id)
	local ping = sampGetPlayerPing(id)
	local color = sampGetPlayerColor(id)
	local r, g, b = bitex.bextract(color, 16, 8), bitex.bextract(color, 8, 8), bitex.bextract(color, 0, 8)
	local imgui_RGBA = imgui.ImVec4(r / 255, g / 255, b / 255, 1)
	
	
	imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(tostring(id)).x / 2)
	if MainIni.settings.colored_id then 
		-- if score == 0 and isPlayingFatality() then
		-- 	imgui.Text(tostring(id))
		-- else
			imgui.TextColored(imgui_RGBA, tostring(id))
		-- end
	else
		imgui.Text(tostring(id))
	end
	imgui.NextColumn()
	
	if MainIni.settings.colored_nickname then 
		-- if score == 0 and isPlayingFatality() then
		-- 	imgui.Text(" "..tostring(nickname)) imgui.SameLine() imgui.Text(u8"[Connecting...]")
		-- else
			imgui.TextColored(imgui_RGBA, ' '..nickname)
		-- end
	else
		-- if score == 0 and isPlayingFatality() then
		-- 	imgui.Text(" "..tostring(nickname)) imgui.SameLine() imgui.Text(u8"[Connecting...]")
		-- else
			imgui.Text(' '..nickname)
		-- end
		
	end
	imgui.NextColumn()	
	
	imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth()/2)) - imgui.CalcTextSize(tostring(score)).x / 2)
	if MainIni.settings.colored_score then 
		-- if score == 0 and isPlayingFatality() then
		-- 	imgui.Text(tostring(score))
		-- else
			imgui.TextColored(imgui_RGBA, tostring(score))
		-- end
	else
		imgui.Text(tostring(score))
	end
	imgui.NextColumn()
	
	if MainIni.settings.colored_ping then 
		-- if score == 0 and isPlayingFatality() then
		-- 	imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(tostring(0)).x / 2)
		-- 	imgui.Text("0")
		-- else
			imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(tostring(ping)).x / 2)
			imgui.TextColored(imgui_RGBA, tostring(ping))
		-- end
	else	
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(tostring(ping)).x / 2)
		imgui.Text(tostring(ping))
	end
	imgui.NextColumn()
	
	if MainIni.settings.show_actions_menu then
	
		if not isPlayingFatality() then
			imgui.Text('   ')
			imgui.SameLine()
		end
	
		if imgui.Button(fa.COPY.."##"..id, imgui.ImVec2(22 ,22.5 )) then
			setClipboardText(tostring(nickname))
		end
		if imgui.IsItemHovered() then
			imgui.SetTooltip("Скопировать ник "..nickname.." в буффер")
		end
		
		if isPlayingFatality() then
		
			imgui.SameLine()
			
			if imgui.Button(fa.MESSAGE.."##"..id, imgui.ImVec2(22 , 22.5 )) then
                sampSetChatInputEnabled(true)
				sampSetChatInputText("/pm "..id.. " ")
			end
			if imgui.IsItemHovered() then
				imgui.SetTooltip("Написать "..nickname)
			end

		end
	
		imgui.NextColumn()
	
	end

	
	
end
function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end
function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
function imgui.CenterColumnButton(text)

	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
	
    if imgui.Button(text) then
		return true
	else
		return false
	end
end

function blue_theme()
   
	imgui.SwitchContext()
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5 , 5 )
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 , 5 )
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 , 5 )
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 , 2 )
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 
    imgui.GetStyle().GrabMinSize = 10 
    imgui.GetStyle().WindowBorderSize = 1 
    imgui.GetStyle().ChildBorderSize = 1 
    imgui.GetStyle().PopupBorderSize = 1 
    imgui.GetStyle().FrameBorderSize = 1 
    imgui.GetStyle().TabBorderSize = 1 
	imgui.GetStyle().WindowRounding = 8 
    imgui.GetStyle().ChildRounding = 8 
    imgui.GetStyle().FrameRounding = 8 
    imgui.GetStyle().PopupRounding = 8 
    imgui.GetStyle().ScrollbarRounding = 8 
    imgui.GetStyle().GrabRounding = 8 
    imgui.GetStyle().TabRounding = 8 
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)


    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.16, 0.29, 0.48, 0.54)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.26, 0.59, 0.98, 0.40)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.26, 0.59, 0.98, 0.67)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.04, 0.04, 0.04, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.16, 0.29, 0.48, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.51)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.24, 0.52, 0.88, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.26, 0.59, 0.98, 0.40)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.06, 0.53, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.26, 0.59, 0.98, 0.31)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.26, 0.59, 0.98, 0.80)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.26, 0.59, 0.98, 0.40)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.26, 0.59, 0.98, 0.78)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.26, 0.59, 0.98, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.26, 0.59, 0.98, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.26, 0.59, 0.98, 0.95)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.26, 0.59, 0.98, 0.35)
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(1.00, 1.00, 1.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.08, 0.08, 0.08, 0.94)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.43, 0.43, 0.50, 0.50)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.14, 0.14, 0.14, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.02, 0.02, 0.02, 0.53)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.31, 0.31, 0.31, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
	
	local alpha = tonumber(SliderOne[0] / 100)
		
			
		
			if MainIni.settings.main_theme == 1 then
				imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
			elseif MainIni.settings.main_theme == 2 then
				imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
			elseif MainIni.settings.main_theme == 3 then
				imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
			end
	
end
function fiol_theme()
    
	imgui.SwitchContext()
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5 , 5 )
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 , 5 )
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 , 5 )
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 , 2 )
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 
    imgui.GetStyle().GrabMinSize = 10 
    imgui.GetStyle().WindowBorderSize = 1 
    imgui.GetStyle().ChildBorderSize = 1 
    imgui.GetStyle().PopupBorderSize = 1 
    imgui.GetStyle().FrameBorderSize = 1 
    imgui.GetStyle().TabBorderSize = 1 
	imgui.GetStyle().WindowRounding = 8 
    imgui.GetStyle().ChildRounding = 8 
    imgui.GetStyle().FrameRounding = 8 
    imgui.GetStyle().PopupRounding = 8 
    imgui.GetStyle().ScrollbarRounding = 8 
    imgui.GetStyle().GrabRounding = 8 
    imgui.GetStyle().TabRounding = 8 
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)

    imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.14, 0.12, 0.16, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.30, 0.20, 0.39, 0.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.05, 0.05, 0.10, 0.90)
    imgui.GetStyle().Colors[imgui.Col.Border] = imgui.ImVec4(0.89, 0.85, 0.92, 0.30)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.30, 0.20, 0.39, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.41, 0.19, 0.63, 0.68)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.41, 0.19, 0.63, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.41, 0.19, 0.63, 0.45)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.41, 0.19, 0.63, 0.35)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.41, 0.19, 0.63, 0.78)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.30, 0.20, 0.39, 0.57)
	imgui.GetStyle().Colors[imgui.Col.Separator] = imgui.ImVec4(0.41, 0.19, 0.63, 0.44)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.30, 0.20, 0.39, 0.60)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.41, 0.19, 0.63, 0.91)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.41, 0.19, 0.63, 0.78)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.41, 0.19, 0.63, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark] = imgui.ImVec4(0.56, 0.61, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab] = imgui.ImVec4(0.41, 0.19, 0.63, 0.24)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(0.41, 0.19, 0.63, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.41, 0.19, 0.63, 0.44)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.41, 0.19, 0.63, 0.86)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.64, 0.33, 0.94, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header] = imgui.ImVec4(0.41, 0.19, 0.63, 0.76)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.41, 0.19, 0.63, 0.86)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.41, 0.19, 0.63, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip] = imgui.ImVec4(0.41, 0.19, 0.63, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(0.41, 0.19, 0.63, 0.78)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(0.41, 0.19, 0.63, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines] = imgui.ImVec4(0.89, 0.85, 0.92, 0.63)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(0.41, 0.19, 0.63, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.89, 0.85, 0.92, 0.63)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(0.41, 0.19, 0.63, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(0.41, 0.19, 0.63, 0.43)
	
	
	local alpha = tonumber(SliderOne[0] / 100)
		
			
		
			if MainIni.settings.main_theme == 1 then
				imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
			elseif MainIni.settings.main_theme == 2 then
				imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
			elseif MainIni.settings.main_theme == 3 then
				imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
			end
	
end
function dark_theme()

	imgui.SwitchContext()
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5 , 5 )
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 , 5 )
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 , 5 )
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 , 2 )
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 
    imgui.GetStyle().GrabMinSize = 10 
    imgui.GetStyle().WindowBorderSize = 1 
    imgui.GetStyle().ChildBorderSize = 1 
    imgui.GetStyle().PopupBorderSize = 1 
    imgui.GetStyle().FrameBorderSize = 1 
    imgui.GetStyle().TabBorderSize = 1 
	imgui.GetStyle().WindowRounding = 8 
    imgui.GetStyle().ChildRounding = 8 
    imgui.GetStyle().FrameRounding = 8 
    imgui.GetStyle().PopupRounding = 8 
    imgui.GetStyle().ScrollbarRounding = 8 
    imgui.GetStyle().GrabRounding = 8 
    imgui.GetStyle().TabRounding = 8 
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.12, 0.12, 0.12, 0.95)
	
	
	local alpha = tonumber(SliderOne[0] / 100)
		
			
		
			if MainIni.settings.main_theme == 1 then
				imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
				imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.06, 0.06, 0.06, alpha)
			elseif MainIni.settings.main_theme == 2 then
				imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
				imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.16, 0.29, 0.48, alpha)
			elseif MainIni.settings.main_theme == 3 then
				imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
				imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.14, 0.12, 0.16, alpha)
			end
	
end	

local russian_characters = {
	[168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
function string.rlower(s)
	s = s:lower()
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

function isPlayingFatality()
	if sampGetCurrentServerName():find(u8:decode("АДМИНКА")) then
		return true
	else	
		return false
	end
end

--if not isMonetLoader() then

function onWindowMessage(msg, wparam, lparam)
	if(msg == 0x100 or msg == 0x101) then
		if (wparam == VK_ESCAPE and renderTAB[0]) and not isPauseMenuActive() then
			consumeWindowMessage(true, false)
			if (msg == 0x101) then
				renderTAB[0] = false
			end
		elseif (wparam == VK_ESCAPE and renderSettings[0]) and not isPauseMenuActive() then
			consumeWindowMessage(true, false)
			if (msg == 0x101) then
				renderSettings[0] = false
			end
		elseif wparam == VK_TAB and not isKeyDown(VK_TAB) and not isPauseMenuActive() then
			if not renderTAB[0] then
				if not sampIsChatInputActive() then
					renderTAB[0] = true
				end
			else
				renderTAB[0] = false
			end
			consumeWindowMessage(true, false)
		end
	end
end

--end

