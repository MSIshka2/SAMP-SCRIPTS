script_version '4.0.6'

require('lib.moonloader')
local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local cp = encoding.CP1251
local function recode(u8) return encoding.UTF8:decode(u8) end
local new = imgui.new
local dlstatus = require "moonloader".download_status
local sampev = require 'samp.events'
local effil = require("effil")
local inicfg = require('inicfg')
local ffi = require('ffi')
ffi.cdef 'void __stdcall ExitProcess(unsigned int)'
local bitex = require 'bitex'
local memory = require 'memory'
local faicons = require('fAwesome6')
local IniFilename = 'fatalitytg.ini'

local ini = inicfg.load({
    telegramtc = {
        token = 'token',
        chat_id = 'chat_id',
        theme = 4,
        style = 1,
        hp = false,
        bind1 = {}
    }
}, IniFilename)
inicfg.save(ini, IniFilename)

function update()
    local updatePath = os.getenv('TEMP')..'\\Update.json'
    sampAddChatMessage((u8:decode('[Update]: Поиск обновления')), 0xFFFFFF)
    downloadUrlToFile("https://raw.githubusercontent.com/MSIshka2/fatality/refs/heads/main/fatality.json", updatePath, function(id, status, p1, p2)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            local file = io.open(updatePath, 'r')
            if file and doesFileExist(updatePath) then
                local info = decodeJson(file:read("*a"))
                file:close(); os.remove(updatePath)
                if info.version ~= thisScript().version then
                    lua_thread.create(function()
                        wait(2000)
                        sampAddChatMessage((u8:decode('[Update]: Идёт обновление')), 0xFFFFFF)
                        downloadUrlToFile("https://raw.githubusercontent.com/MSIshka2/fatality/refs/heads/main/fatality-launcher.lua", thisScript().path, function(id, status, p1, p2)
                            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                                sampAddChatMessage((u8:decode('[Update]: Обновление установлено')), 0xFFFFFF)
                                thisScript():reload()
                            end
                        end)
                    end)
                else
                    sampAddChatMessage((u8:decode('[Update]: У вас и так последняя версия! Обновление отменено')), 0xFFFFFF)
                end
            end
        end
    end)
end


local WinState = new.bool()
local WinState1 = new.bool()
local fileContent = ''
local fileContent2 = ''
local fileContent3 = ''
local fileContent4 = ''
local inputField = new.char[256]()
local inputField2 = new.char[256]()
local messages = {}
local act = true
local checkboxone = new.bool()
local checkx = imgui.new.float(500)
local checky = imgui.new.float(150)
local carbuffer = new.char[256]()
local skinbuffer = new.char[256]()
local searchResults = {}
local showSearchWindow = imgui.new.bool()
local selectedText = ""
local isSelecting = false
local startIdx, endIdx = nil, nil
local favoritesVehicles = {}
local favoritesSkins = {}
local inputa1 = new.char[256]()
local inputa2 = new.char[256]()
local activation = new.bool()
local password = new.char[256]()
local dostup = new.bool()
local savedCoordinates = {x = nil, y = nil, z = nil}
local hp = new.bool()
local status = false
local status1 = false
local tokenbuffer = new.char[256]()
local chatidbuffer = new.char[256]()
local colorList = {'Красная', 'Зелёная','Бело-синяя','Чёрно-фиолетовая','Дефолт', 'CS 1.6'}
local colorListNumber = new.int()
local colorListBuffer = new['const char*'][#colorList](colorList)
local styleList = {'Дефолт', 'Стиль 1','Стиль2', 'CS 1.6'}
local styleListNumber = new.int()
local styleListBuffer = new['const char*'][#styleList](styleList)
local gm = false
local col = false
local repint = new.int()
local changelog = 0
local active = false
local helloText = [[
===================================================================
В данном меню будет показана вся информация по новым обновлениям.
Данный скрипт был создан для облегчения работы.
Он является многофункциональным.
Если у вас есть идея, вы можете описать ее игроку с ником: Harry_Pattersone.
Автором скрипта является: Harry_Pattersone.
Главный придумыватель идей является: Denis_Angelov 
===================================================================
Последние обновления:
- 1. Удалён [BOT]
]]

local bus_info = false

local rtext1 = false
local rtext2 = false
local rtext3 = false

local count1 = 0
local count2 = 0
local count3 = 0

local race = 0

local rep1 = 0
local rep2 = 0
local rep3 = 0

local sl1 = 0
local sl2 = 0
local sl3 = 0


theme = {
    {
        change = function()
            local ImVec4 = imgui.ImVec4
            imgui.SwitchContext()
            imgui.GetStyle().Colors[imgui.Col.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.WindowBg]               = ImVec4(0.10, 0.06, 0.06, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ChildBg]                = ImVec4(1.00, 1.00, 1.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
            imgui.GetStyle().Colors[imgui.Col.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
            imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
            imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
            imgui.GetStyle().Colors[imgui.Col.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
            imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
            imgui.GetStyle().Colors[imgui.Col.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
            imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
            imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
            imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Separator]              = ImVec4(0.43, 0.43, 0.50, 0.50)
            imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
            imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
            imgui.GetStyle().Colors[imgui.Col.Tab]                    = ImVec4(0.98, 0.26, 0.26, 0.40)
            imgui.GetStyle().Colors[imgui.Col.TabHovered]             = ImVec4(0.98, 0.26, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabActive]              = ImVec4(0.98, 0.06, 0.06, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = ImVec4(0.98, 0.26, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = ImVec4(0.98, 0.26, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
        end
    },
    {
        change = function()
            local ImVec4 = imgui.ImVec4
            imgui.SwitchContext()
            imgui.GetStyle().Colors[imgui.Col.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00)
            imgui.GetStyle().Colors[imgui.Col.WindowBg]               = ImVec4(0.08, 0.10, 0.08, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ChildBg]                = ImVec4(0.10, 0.10, 0.10, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Border]                 = ImVec4(0.70, 0.70, 0.70, 0.40)
            imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
            imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
            imgui.GetStyle().Colors[imgui.Col.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 0.80)
            imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = ImVec4(0.00, 0.74, 0.36, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.00, 0.69, 0.33, 0.50)
            imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = ImVec4(0.00, 0.80, 0.38, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
            imgui.GetStyle().Colors[imgui.Col.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Button]                 = ImVec4(0.00, 0.69, 0.00, 0.40)
            imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = ImVec4(0.00, 0.16, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = ImVec4(0.00, 0.60, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Header]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = ImVec4(0.00, 0.76, 0.37, 0.57)
            imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = ImVec4(0.00, 0.88, 0.42, 0.89)
            imgui.GetStyle().Colors[imgui.Col.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
            imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
            imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
            imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Tab]                    = ImVec4(0.00, 0.69, 0.00, 0.40)
            imgui.GetStyle().Colors[imgui.Col.TabHovered]             = ImVec4(0.00, 0.16, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabActive]              = ImVec4(0.00, 0.60, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = ImVec4(0.00, 0.76, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = ImVec4(0.00, 0.76, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLines]              = ImVec4(0.00, 0.69, 0.33, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = ImVec4(0.00, 0.74, 0.36, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = ImVec4(0.00, 0.69, 0.33, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = ImVec4(0.00, 0.69, 0.33, 0.72)
        end
    },
    {
        change = function()
            local ImVec4 = imgui.ImVec4
            imgui.SwitchContext()
            imgui.GetStyle().Colors[imgui.Col.FrameBg]                = ImVec4(0.66, 0.66, 0.66, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
            imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
            imgui.GetStyle().Colors[imgui.Col.TitleBg]                = ImVec4(0.16, 0.29, 0.48, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
            imgui.GetStyle().Colors[imgui.Col.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Button]                 = ImVec4(0.00, 0.49, 1.00, 0.59)
            imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = ImVec4(0.00, 0.49, 1.00, 0.71)
            imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = ImVec4(0.00, 0.49, 1.00, 0.78)
            imgui.GetStyle().Colors[imgui.Col.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
            imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
            imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Separator]              = ImVec4(0.43, 0.43, 0.50, 0.50)
            imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
            imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
            imgui.GetStyle().Colors[imgui.Col.Tab]                    = ImVec4(0.26, 0.59, 0.98, 0.80)
            imgui.GetStyle().Colors[imgui.Col.TabHovered]             = ImVec4(0.26, 0.59, 0.78, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabActive]              = ImVec4(0.00, 0.29, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = ImVec4(0.00, 0.00, 0.40, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = ImVec4(0.00, 0.00, 0.40, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Text]                   = ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.WindowBg]               = ImVec4(1.00, 1.00, 1.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ChildBg]                = ImVec4(0.67, 0.67, 0.67, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PopupBg]                = ImVec4(0.06, 0.53, 0.68, 0.80)
            imgui.GetStyle().Colors[imgui.Col.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
            imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = ImVec4(0.00, 0.59, 1.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        end
    
    },
    {
        change = function()
            local ImVec4 = imgui.ImVec4
            imgui.SwitchContext()
            imgui.GetStyle().Colors[imgui.Col.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ChildBg]                = ImVec4(1.00, 1.00, 1.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
            imgui.GetStyle().Colors[imgui.Col.Border]                 = ImVec4(0.35, 0.06, 0.35, 0.50)
            imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBg]                = ImVec4(0.35, 0.06, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = ImVec4(0.50, 0.06, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = ImVec4(0.50, 0.06, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = ImVec4(0.50, 0.06, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
            imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
            imgui.GetStyle().Colors[imgui.Col.CheckMark]              = ImVec4(0.70, 0.06, 0.70, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Button]                 = ImVec4(0.35, 0.06, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = ImVec4(0.50, 0.06, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = ImVec4(0.50, 0.06, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Header]                 = ImVec4(0.50, 0.06, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = ImVec4(0.45, 0.06, 0.45, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Separator]              = ImVec4(0.43, 0.43, 0.50, 0.50)
            imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
            imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
            imgui.GetStyle().Colors[imgui.Col.Tab]                    = ImVec4(0.35, 0.06, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabHovered]             = ImVec4(0.50, 0.06, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabActive]              = ImVec4(0.45, 0.06, 0.46, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = ImVec4(0.98, 0.26, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = ImVec4(0.98, 0.26, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
        end
    },
    {
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
    },
    {
        change = function()
            local ImVec4 = imgui.ImVec4
            imgui.SwitchContext()
            imgui.GetStyle().Colors[imgui.Col.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.WindowBg]               = ImVec4(0.29, 0.34, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ChildBg]                = ImVec4(0.29, 0.34, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PopupBg]                = ImVec4(0.24, 0.27, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Border]                 = ImVec4(0.54, 0.57, 0.51, 0.50)
            imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = ImVec4(0.14, 0.16, 0.11, 0.52)
            imgui.GetStyle().Colors[imgui.Col.FrameBg]                = ImVec4(0.24, 0.27, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = ImVec4(0.27, 0.30, 0.23, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = ImVec4(0.00, 0.00, 0.00, 0.51)
            imgui.GetStyle().Colors[imgui.Col.TitleBg]                = ImVec4(0.24, 0.27, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = ImVec4(0.29, 0.34, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
            imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = ImVec4(0.24, 0.27, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = ImVec4(0.35, 0.42, 0.31, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.28, 0.32, 0.24, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.25, 0.30, 0.22, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.23, 0.27, 0.21, 1.00)
            imgui.GetStyle().Colors[imgui.Col.CheckMark]              = ImVec4(0.59, 0.54, 0.18, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = ImVec4(0.35, 0.42, 0.31, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = ImVec4(0.54, 0.57, 0.51, 0.50)
            imgui.GetStyle().Colors[imgui.Col.Button]                 = ImVec4(0.29, 0.34, 0.26, 0.40)
            imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = ImVec4(0.35, 0.42, 0.31, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = ImVec4(0.54, 0.57, 0.51, 0.50)
            imgui.GetStyle().Colors[imgui.Col.Header]                 = ImVec4(0.35, 0.42, 0.31, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = ImVec4(0.35, 0.42, 0.31, 0.6)
            imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = ImVec4(0.54, 0.57, 0.51, 0.50)
            imgui.GetStyle().Colors[imgui.Col.Separator]              = ImVec4(0.14, 0.16, 0.11, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = ImVec4(0.54, 0.57, 0.51, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = ImVec4(0.59, 0.54, 0.18, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = ImVec4(0.19, 0.23, 0.18, 0.00)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.54, 0.57, 0.51, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = ImVec4(0.59, 0.54, 0.18, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Tab]                    = ImVec4(0.35, 0.42, 0.31, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabHovered]             = ImVec4(0.54, 0.57, 0.51, 0.78)
            imgui.GetStyle().Colors[imgui.Col.TabActive]              = ImVec4(0.59, 0.54, 0.18, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = ImVec4(0.24, 0.27, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = ImVec4(0.35, 0.42, 0.31, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = ImVec4(0.59, 0.54, 0.18, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = ImVec4(1.00, 0.78, 0.28, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = ImVec4(0.59, 0.54, 0.18, 1.00)
        end
    }
    
    
}

style = {
    {
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
    },
    {
        change = function()
            imgui.SwitchContext()
            local style = imgui.GetStyle()
            style.WindowPadding = imgui.ImVec2(15, 15)
            style.WindowRounding = 3.0
            style.ChildRounding = 3.0
            style.FramePadding = imgui.ImVec2(8, 7)
            style.FrameRounding = 3.0
            style.ItemSpacing = imgui.ImVec2(8, 8)
            style.ItemInnerSpacing = imgui.ImVec2(10, 6)
            style.IndentSpacing = 25.0
            style.ScrollbarSize = 13.0
            style.ScrollbarRounding = 1.0
            style.GrabMinSize = 10.0
            style.GrabRounding = 3.0
            style.PopupRounding = 3
            style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
            style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
            style.WindowBorderSize = 1
            style.ChildBorderSize = 1
            style.PopupBorderSize = 1
            style.FrameBorderSize = 1
            style.TabBorderSize = 1
        end
    },
    {
        change = function()
            imgui.SwitchContext()
            local style = imgui.GetStyle()
            style.WindowPadding = imgui.ImVec2(15, 15)
            style.WindowRounding = 20.0
            style.ChildRounding = 12.0
            style.FramePadding = imgui.ImVec2(8, 7)
            style.FrameRounding = 16.0
            style.ItemSpacing = imgui.ImVec2(8, 8)
            style.ItemInnerSpacing = imgui.ImVec2(10, 6)
            style.IndentSpacing = 25.0
            style.ScrollbarSize = 13.0
            style.ScrollbarRounding = 24.0
            style.GrabMinSize = 10.0
            style.GrabRounding = 12.0
            style.PopupRounding = 16
            style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
            style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
            style.WindowBorderSize = 1
            style.ChildBorderSize = 1
            style.PopupBorderSize = 1
            style.FrameBorderSize = 1
            style.TabBorderSize = 1
        end
    },
    {
        change = function()
            imgui.SwitchContext()
            local style = imgui.GetStyle()
            style.ItemSpacing = imgui.ImVec2(5, 5)
            style.ItemInnerSpacing = imgui.ImVec2(2, 2)
            style.TouchExtraPadding = imgui.ImVec2(0, 0)
            style.IndentSpacing = 0
            style.ScrollbarSize = 10
            style.GrabMinSize = 10
            style.WindowBorderSize = 1
            style.ChildBorderSize = 1
            style.PopupBorderSize = 1
            style.FrameBorderSize = 1
            style.TabBorderSize = 1
            style.WindowRounding = 0
            style.ChildRounding = 0
            style.FrameRounding = 0
            style.PopupRounding = 0
            style.ScrollbarRounding = 0
            style.GrabRounding = 0
            style.TabRounding = 0
            style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
            style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        end
    }
}


local commands1 = {
    "/atops - Рейтинг основателей",
    "/zpanel - Панель админа(все функции доступны)",
    "/ripmans - Список игроков в RIP",
    "/rconsay - RCON чат",
    "/offgivedonate - Выдать донат очки оффлайн",
    "/offalvladmin - Выдать админку оффлайн",
    "/caseon - Вкл кейсы/подарки",
    "/caseoff - Выкл кейсы/подарки",
    "/ratingon - Вкл рейтинги",
    "/ratingoff - Выкл рейтинги",
    "/ablow - Покупка салюта",
    "/agiverub - Выдача рублей",
    "/mpwin - Огласить победителя",
    "/tps - Новое телепорт-меню",
    "/apanel - Панель основателя",
    "/dostup - Выдать fd1",
    "/undostup - Снять fd1",
    "/glava - Выдать 16 lvl",
    "/unglava - Снять 16 lvl",
    "/delvipcase - Удалить кейс",
    "/givecmd - Выдача команд",
    "/setminigun - Разрешение на миниган",
    "/farmer - Поставить ограничение",
    "/unfarmer - Снять ограничение",
    "/akkreset - Аннулировать все донат очки",
    "/unbanall - Разбанить всех игроков",
    "/unconpens - Разрешить повторный ввод компенсации и промокодов"
}
local commands2 = {
    "/antierror - Снять ошибку безопасности",
    "/offawarn - Выдать оффлайн выговор",
    "/podarok - Открыть НГ подарок",
    "/aban - Бан навсегда",
    "/offleader - Убрать лидера",
    "/amute - Админ-затычка",
    "/look - Вид от 1 лица (в ТС)",
    "/neon - Неон на домашний ТС",
    "/jetpack - Получить ранец",
    "/ahostname - Изменить название сервера",
    "/apassword - Изменить пароль сервера",
    "/ops - Режим тех. работ",
    "/asban - Тихий бан навсегда",
    "/iban - Бан навсегда 2",
    "/sban - Тихий бан",
    "/offgiverub - Выдача рублей оффлайн",
    "/offgivestars - Выдача баллов оффлайн",
    "/onprom - Разрешить ввод промокодов",
    "/offleaders - Оффлайн лидеры",
    "/geton - Последний заход игрока",
    "/cuff - Надеть наручники",
    "/aclub - Все пункты доступны",
    "/setquest - Управление квестом у игрока",
    "/aquest - Вкл/выкл квест у игрока",
    "/clubload - Загрузка клубов",
    "/atext - Сделать важное объявление",
    "/title - Выдача титулов",
    "/giveclist - Выдать радужный клист",
    "/giveguns - Выдать набор цветов на оружия",
    "/givepay - Выдать команды /rpay /dpay",
    "/givedice - Выдать команды /rdice /ddice",
    "/holkinacc - Удалить аккаунт",
    "/getakk - Посмотреть пароль игрока",
    "/osnova - Выдача основателя",
    "/unosnova - Снятие основателя",
}
local commands3 = {
    "/setpass - Сменить пароль игрока",
    "/atp - Принудительно телепортировать всех к себе",
    "/aconnect - Видеть чат, смс, ввод комманд",
    "/ajoin - Вкл/выкл /mp /givegun /agivegun /sethp /asethp /slap",
    "/amenu - Панель статистики",
    "/atitle - Проверить титул у игрока",
    "/ahack - Отнять деньги, деньги в банке, дом, бизнес, азс",
    "/people - Показать топ по разным типам",
    "/block - Заблокировать/разблокировать ввод prefix, quest, dpanel, donate",
    "/createprom - Создание промокодов",
    "/rinfo - Проверить местоположение игрока",
    "/giveitems - Выдать особые объекты",
    "/givevip - Выдача VIP",
    "/setarm - Изменение брони игрока",
    "/setcarhp - Изменение здоровья ТС игрока",
    "/settime - Изменение времени сервера",
    "/setweather - Изменение погоды сервера",
    "/fatality - Новые аксессуары"
}
local commands4 = {
    "/gifts - Просмотр логов подарков",
    "/addgift - Выдача подарков",
    "/testmp - Мероприятие 'Угадай цифру'",
    "/abanip - Быстрый BanIP",
    "/nosave - Заморозить аккаунт",
    "/rip - Выдать вечный бан",
    "/unrip - Снять вечный бан",
    "/glist - Игроки с G.Auth",
    "/gdelete - Удалить G.Auth у игрока",
    "/asms - Предупреждение от модератора",
    "/remont - Ремонт в квартире",
    "/asetint - Изменить INT игрока",
    "/asetvw - Изменить виртуальный мир игрока",
    "/inter - ТП в интерьеры",
    "/pmall - Ответ от админа всем игрокам",
    "/savemans - Игроки с запретом на сохранение аккаунта",
    "/userdelete - Очистить игрока в таблице gifts",
    "/usluga - Услуга 'Анти-снятие'",
    "/allusluga - Пакет услуг",
    "/neusluga - Снять услугу 'Анти-снятие'",
    "/jailusluga - Услуга 'Анти-jail'",
    "/nejailusluga - Снять услугу 'Анти-Jail'",
    "/arep - Выдать понизить репутацию(БЛАТ ЗАПРЕЩЕН)",
    "/neallusluga - Снять все услуги"
}
local commands5 = {
    "/setduel - Изменить настройки дуэля у игрока",
    "/present2 - Поставить пикап с подарком (/time)",
    "/present1 - Изменить таймер подарка (/time)",
    "/giveblow - Выдача салюта игроку",
    "/givepoints - Выдача баллов ATOP (БЛАТ ЗАПРЕЩЕН)",
    "/competition - Настройка голосования",
    "/afk - Список AFK-игроков",
    "/break - Установить ограждение",
    "/akick - Выгнать из любой семьи",
    "/fbanlist - Список ограниченных семей",
    "/fban - Ограничить семью",
    "/unfban - Снять ограничение семьи",
    "/afamily - Вкл/выкл 'галочку' семьи",
    "/virus - Настроить заражение игрока",
    "/startvirus - Начать зомби-апокалипсис",
    "/zombieoff - Закончить зомби-апокалипсис",
    "/alogs - Логирование наказаний",
    "/repedit - Изменение кол-ва репутации (БЛАТ ЗАПРЕЩЕН)",
    "/inviteclub - Изменение кол-ва часов для вступления в семью через /mm",
    "/offrepedit - изменение оффлайн репутации (БЛАТ ЗАПРЕЩЕН)"
}
local commands6 = {
    "/unvigall - Снять всем выговоры",
    "/offgivepoints - Изменение оффлайн кол-ва /atops",
    "/module - Вкл/откл модулей сервера(обновления)",
    "/aip - Список Online основателей с их IP's",
    "/spt - Написать текст от имени игрока",
    "/spdo - Использовать /do от имени игрока",
    "/spme - Использовать /me от имени игрока",
    "/testkick - Кикнуть игрока по 'шутке'",
    "/testban - Забанить игрока по 'шутке'",
    "/gocord - Телепортация по координатам",
    "/v - Будущий 'Админ' чат",
    "/lego - Включить режим 'Лего'",
    "/ohelp - Список команд для режима 'Лего'",
    "/newobj - Создание объекта",
    "/delast - Удалить последний созданный объект",
    "/editobj - Редактирование объекта",
    "/newactor - Создание актёра",
    "/editactor - Редактирование актёра",
    "/hbject - Создание объектов на игроке",
    "/hbjectedit - Редактирование объектов на игроке",
    "/offleaders - Просмотр оффлайн лидеров",
    "/eplayers - Список игроков с непройденной регистрацией",
    "/offadmins - Просмотр оффлайн админов 15+ уровня",
    "/tempfamily - Вступить в любую семью",
    "/allfamily - Список всех семей",
    "/giveday - Изменить кол-во бонусных дней (БЛАТ ЗАПРЕЩЕН)",
    "/offgiveday - Изменить оффлайн кол-во бонусных дней",
    "/abonus - Получение бонусов без ограничения времени",
    "/asetsex - Изменение пола игрока",
    "/addzone - Изменение ZZ (ограничить /veh /aveh /acar)",
    "/temproom - Вступить в приватную комнату"
}
local commands7 = {
    "/act - Настройки рейтингов",
    "/offosnova - Команда /osnova, но оффлайн",
    "/setklass - Установить класс дому",
    "/asetpos - Сменить позицию пикапа дома",
    "/setposcar - Сменить позицию спавна машин в доме",
    "/setcena - Изменить цену дома",
    "/delpos - Удалить позицию пикапа дома",
    "/asellhouse - Продать дом",
    "/savehouse - Сохранение дома"
}
local commands8 = {
    "/addexp - Добавление опыта в семью",
    "/oi - Мини-троллинг",
    "/uptop - Принудительно обновить рейтинги",
    "/gpci - Бан по железу (/gpci [id] [2]) - опасно!",
    "/addbiz - Создать бизнес",
    "/klad - Телепорт к кладу",
    "/squest - Изменить прогресс заданий у игрока",
    "/alogs - Версия 2.0",
    "/captchalog - Логирование ввода капчи",
    "/server - Статистика сервера + мини-настройки",
    "/settings - Настройки цен и прочего для /donate (опасно)"
}
local commands9 = {
    "/fixmysql - Исправление чтения базы данных при '?????'",
    "/reloadnews - Принудительная загрузка новостей сервера",
    "/unawarn - Снятие выговоров администратором",
    "/arip - Полная блокировка разом (IP,аккаунт,железо) ОПАСНО!",
    "/addquest - Всеобщая доступность квестов(/quest) ОПАСНО!",
    "/age - Установка даты рождения игроков",
    "/oi - Тролинг игрока который приведет к кику через 5 минут",
    "/gzcolor - Возможность перекрашивать гетто",
    "/mtest - Взаимодействие на расстоянии (замена ALT+ПКМ)",
    "/prizeyear - Чисто прикол",
    "/addbiz - Создание бизнесов ОПАСНО!",
    "/aobj2 - Выдача уникальных предметов самому себе",
    "/iinfo - Узнать название любого предмета по номеру (от 311 до 645)",
    "/bank - Использовать возможности банка на расстоянии",
    "/setsale - Открыть/закрыть распродажу на админки",
    "/finditem - Найди название предмета по словам"
}


local oskm = {
    currentm = 1,
    "Еблан", "еблан", "ЕБЛАН", "Ебланы", "ебланы", "ЕБЛАНЫ", "Долбоёб", "долбоёб", "ДОЛБОЁБ", "Долбоёбы", "ДОЛБОЁБЫ", "долбоёбы", "Долбоеб", "долбоеб","ДОЛБОЕБ", "MQ", "mq", "Mq", "mQ", "Маме", "МАМЕ" , "маме", "МАМУ", "маму", "Маму",
    "Пидор", "пидор", "ПИДОР" , "Пидоры", "пидоры", "ПИДОРЫ" , "Пидорас", "пидорас", "Пидорасы", "ПИДОРАСЫ", "ЧМО", "чмо", "Чмо", "Чмошник", "чмошник", "ЧМОШНИК", "МРАЗЬ", "Мразь", "мразь", "Тварь", "ТВАРЬ", "тварь", "Шлюха", "ШЛЮХА",
    "шлюха", "Мудак", "МУДАК", "мудак", "МУДАКИ", "мудаки", "Мудаки", "МАМКУ", "Мамку", "мамку"
}
local nicki = {
    currentn = 1,
    "Svyatik_Mironov", "svyatik_mironov", "Andrey_Holkin", "andrey_holkin", "Denis_Angelov", "denis_angelov", "Harry_Pattersone", "harry_pattersone", "Klayc_Holkin", "klayc_holkin", "Justin_Biever", "justin_biever",
    "Lucas_Oldman", "lucas_oldman", "Devin_Martynov", "devin_martynov", "kevin_legens", "Kevin_Legens", "Ywo_Legend", "ywo_legend", "Akito_Ito", "akito_ito", "navalny_vandal", "Navalny_Vandal", "Yuto_Hasegawa", "yuto_hasegawa",
    "Harry_Test"
}

local updateid
function threadHandle(runner, url, args, resolve, reject)
    local t = runner(url, args)
    local r = t:get(0)
    while not r do
        r = t:get(0)
        wait(0)
    end
    local status = t:status()
    if status == 'completed' then
        local ok, result = r[1], r[2]
        if ok then resolve(result) else reject(result) end
    elseif err then
        reject(err)
    elseif status == 'canceled' then
        reject(status)
    end
    t:cancel(0)
end

function requestRunner()
    return effil.thread(function(u, a)
        local https = require 'ssl.https'
        local ok, result = pcall(https.request, u, a)
        if ok then
            return {true, result}
        else
            return {false, result}
        end
    end)
end


function async_http_request(url, args, resolve, reject)
    local runner = requestRunner()
    if not reject then reject = function() end end
    lua_thread.create(function()
        threadHandle(runner, url, args, resolve, reject)
    end)
end

function encodeUrl(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return u8:encode(str, 'CP1251')
end

function sendTelegramNotification(msg) -- функция для отправки сообщения юзеру
    msg = msg:gsub('{......}', '') --тут типо убираем цвет
    msg = encodeUrl(msg) -- ну тут мы закодируем строку
    async_http_request('https://api.telegram.org/bot' .. ini.telegramtc.token .. '/sendMessage?chat_id=' .. ini.telegramtc.chat_id .. '&text='..msg,'', function(result) end) -- а тут уже отправка
end

function get_telegram_updates() -- функция получения сообщений от юзера
    while not updateid do wait(1) end -- ждем пока не узнаем последний ID
    local runner = requestRunner()
    local reject = function() end
    local args = ''
    while true do
        url = 'https://api.telegram.org/bot'..ini.telegramtc.token..'/getUpdates?chat_id='..ini.telegramtc.chat_id..'&offset=-1' -- создаем ссылку
        threadHandle(runner, url, args, processing_telegram_messages, reject)
        wait(0)
    end
end

function processing_telegram_messages(result) -- функция проверОчки того что отправил чел
    if result then
        -- тута мы проверяем все ли верно
        local proc_table = decodeJson(result)
        if proc_table.ok then
            if #proc_table.result > 0 then
                local res_table = proc_table.result[1]
                if res_table then
                    if res_table.update_id ~= updateid then
                        updateid = res_table.update_id
                        local message_from_user = res_table.message.text
                        if message_from_user then
                            -- и тут если чел отправил текст мы сверяем
                            local text = u8:decode(message_from_user) .. ' ' --добавляем в конец пробел дабы не произошли тех. шоколадки с командами(типо чтоб !q не считалось как !qq)
                            if text:match('^!qq') then
                                sendTelegramNotification(u8:decode('Ку'))
                            elseif text:match('^!q') then
                                sendTelegramNotification(u8:decode('Привет!'))
                            elseif text:match('^!online') then
                                online = sampGetPlayerCount(false)
                                local g = select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))
                                local name = sampGetPlayerNickname(g)
                                sendTelegramNotification(u8:decode('Онлайн на сервере: '..online))
                                sendTelegramNotification(u8:decode('Вы: ' ..name.. '['..g..']'))
                                for i = 0, sampGetMaxPlayerId() do
                                    wait(100)
                                    if sampIsPlayerConnected(i) then
                                        local nickp = sampGetPlayerNickname(i)
                                        sendTelegramNotification(u8:decode('Игрок: '..nickp..'['..i..']'))
                                    else
                                        sendTelegramNotification(u8:decode('Игрок с идом ['..i..'] не найден'))
                                    end
                                end
                            elseif text:match('^!send') then
                                local arg = text:gsub('!send%s','',1) -- вот так мы получаем аргумент команды
                                    if #arg > 0 then
                                    sampSendChat(arg)
                                    sendTelegramNotification(u8:decode(arg))
                                end
                            elseif text:match('^!pm') then
                                local arg = text:gsub('!pm%s','',1) -- вот так мы получаем аргумент команды
                                    if #arg > 0 then
                                    sampSendChat('/pm ' .. arg)
                                    sendTelegramNotification(u8:decode('/pm ' .. arg))
                                end
                            elseif text:match('^!ans') then
                                local arg = text:gsub('!ans%s','',1) -- вот так мы получаем аргумент команды
                                    if #arg > 0 then
                                    sampSendChat('/ans ' .. arg)
                                    sendTelegramNotification(u8:decode('/ans ' .. arg))
                                end
                            elseif text:match('^!sms') then
                                local arg = text:gsub('!sms%s','',1) -- вот так мы получаем аргумент команды
                                    if #arg > 0 then
                                    sampSendChat('/sms ' .. arg)
                                    sendTelegramNotification(u8:decode('/sms ' .. arg))
                                end
                            elseif text:match(u8:decode('^!amute')) then
                                local arg = text:gsub(u8:decode('!amute%s'),'',1) -- вот так мы получаем аргумент команды
                                    if #arg > 0 then
                                    sampSendChat('/amute ' .. arg)
                                    sendTelegramNotification(u8:decode('/amute ' .. arg))
                                end
                            elseif text:match('^!a') then
                                local arg = text:gsub('!a%s','',1) -- вот так мы получаем аргумент команды
                                    if #arg > 0 then
                                    sampSendChat('/a ' .. arg)
                                    sendTelegramNotification(u8:decode('/a ' .. arg))
                                end
                            elseif text:match(u8:decode('^!mute')) then
                                local arg = text:gsub(u8:decode('!мут%s'),'',1) -- вот так мы получаем аргумент команды
                                    if #arg > 0 then
                                    sampSendChat('/mute ' .. arg)
                                    sendTelegramNotification(u8:decode('/mute ' .. arg))
                                end
                            elseif text:match(u8:decode('^!rep')) then
                                local arg = text:gsub(u8:decode('!rep%s'),'',1) -- вот так мы получаем аргумент команды
                                    if #arg > 0 then
                                    sampSendChat('/addreps ' .. arg)
                                    sendTelegramNotification(u8:decode('/addreps ' .. arg))
                                end
                            elseif text:match(u8:decode('^!exit')) then
                                    lua_thread.create(function()
                                        sendTelegramNotification(u8:decode('/exit  ВЫХОЖУ ИЗ ИГРЫ ЧЕРЕЗ 5 СЕКУНД'))
                                        sampSendChat(u8:decode('/a [Авто-выход] Выхожу из игры через 5 секунд.'))
                                        wait(5000)
                                        ffi.C.ExitProcess(0)
                                    end)
                            elseif text:match(u8:decode('^!recon')) then
                                lua_thread.create(function()
                                    local ip, port = sampGetCurrentServerAddress()
                                    sendTelegramNotification(u8:decode('/recon Перезахожу в игру через 5 секунд'))
                                    wait(5000)
                                    sampConnectToServer(ip,port)
                                end)
                            elseif text:match(u8:decode('^!shutdown')) then
                                lua_thread.create(function()
                                    sendTelegramNotification(u8:decode('/shutdown Выключаю компьютер'))
                                    wait(1000)
                                    os.execute('shutdown /s /t 5')
                                end)
                            else -- если же не найдется ни одна из команд выше, выведем сообщение
                                sendTelegramNotification(u8:decode('Неизвестная команда!'))
                            end
                        end
                    end
                end
            end
        end
    end
end

function getLastUpdate() -- тут мы получаем последний ID сообщения, если же у вас в коде будет настройка токена и chat_id, вызовите эту функцию для того чтоб получить последнее сообщение
    async_http_request('https://api.telegram.org/bot'..ini.telegramtc.token..'/getUpdates?chat_id='..ini.telegramtc.chat_id..'&offset=-1','',function(result)
        if result then
            local proc_table = decodeJson(result)
            if proc_table.ok then
                if #proc_table.result > 0 then
                    local res_table = proc_table.result[1]
                    if res_table then
                        updateid = res_table.update_id
                    end
                else
                    updateid = 1 -- тут зададим значение 1, если таблица будет пустая
                end
            end
        end
    end)
end

function sampev.onServerMessage(color, text)
    if act then
        local playerid2 = select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))
        local name = sampGetPlayerNickname(playerid2)
        local text1 = name .. '%sначал%sработу%sводителя%sавтобуса%sна%sмаршруте%s«Городской%sмаршрут»'
        local text2 = name .. '%sначал%sработу%sводителя%sавтобуса%sна%sмаршруте%s«Лос'
        local text3 = name .. '%sначал%sработу%sводителя%sавтобуса%sна%sмаршруте%s«ЖДЛС'
        local text4 = 'Остановка.%sЖдите%sпассажиров'

        if text:find(u8:decode("к%s") .. name ) then
            if text:find(u8:decode("(%d+)%sскример(%d+)")) then
                sampAddChatMessage(u8:decode('skip'), -1)
            elseif text:find(u8:decode("(%d+)%sgay")) then
                sampAddChatMessage(u8:decode('skip'), -1)
            elseif text:find(u8:decode("(%d+)%sнг(%d+)")) then
                sampAddChatMessage(u8:decode('skip'), -1)
            else
                table.insert(messages, u8(text))
                sendTelegramNotification(text)
                addOneOffSound(0.0, 0.0, 0.0, 1054)
            end
        end
        lua_thread.create(function()
            wait(1000)
        if text:find(u8:decode("@") .. name) or text:find(u8:decode("@") .. name:lower()) then
                if text:find(u8:decode("-")) then
                    sampSendChat(u8:decode('[А-О] Бегу отвечать! Ср. время ожидания: 2 мин.'))
                    wait(500)
                    sampSendChat(u8:decode('[А-О] Если прошло 5 мин. и я не ответил,'))
                    wait(500)
                    sampSendChat(u8:decode('[А-О] Повторите. Флуд карается МУТОМ!'))

                elseif text:find(u8:decode("от%sсаппорта%s(%w+_%w+):")) then
                    local nicka = text:match(u8:decode("от%sсаппорта%s(%w+_%w+):"))
                    local ida = sampGetPlayerIdByNickname(nicka)
                    sampSendChat(u8:decode('/pm ') .. ida .. u8:decode(' [А-О] Бегу отвечать! Ср. время ожидания: 2 мин.'))
                    sampSendChat(u8:decode('/pm ') .. ida .. u8:decode(' [А-О] Если прошло 5 мин. и я не ответил,'))
                    sampSendChat(u8:decode('/pm ') .. ida .. u8:decode(' [А-О] Повторите. Флуд карается МУТОМ!'))
                    goto end_chat
                
                elseif text:find(u8:decode("от%sадмина%s(%w+_%w+):")) then
                    local nicka = text:match(u8:decode("от%sадмина%s(%w+_%w+):"))
                    local ida = sampGetPlayerIdByNickname(nicka)
                    sampSendChat(u8:decode('/pm ') .. ida .. u8:decode(' [А-О] Бегу отвечать! Ср. время ожидания: 2 мин.'))
                    sampSendChat(u8:decode('/pm ') .. ida .. u8:decode(' [А-О] Если прошло 5 мин. и я не ответил,'))
                    sampSendChat(u8:decode('/pm ') .. ida .. u8:decode(' [А-О] Повторите. Флуд карается МУТОМ!'))
                    goto end_chat
                elseif text:find(u8:decode('/a%s@' .. name)) or text:find(u8:decode('/a%s@' .. name:lower()))  then
                        sampAddChatMessage('Пропускаю СПАМ!!!',-1)
                else
                    sampSendChat(u8:decode('/a [А-О] Бегу отвечать! Ср. время ожидания: 2 мин.'))
                    wait(1000)
                    sampSendChat(u8:decode('/a [А-О] Если прошло 5 мин. и я не ответил,'))
                    wait(1000)
                    sampSendChat(u8:decode('/a [А-О] Повторите. Флуд карается МУТОМ!'))
                end
            ::end_chat::
            sendTelegramNotification(text)
        end 
    end)
    if text:find(u8:decode("Вы%sполучили%sбан%sчата")) then
        sampSendChat('/unmute ' .. playerid2)
    end
        if text:find(u8:decode("%[%+%]")) then
            if text:find(u8:decode("@") .. name) or text:find(u8:decode("@") .. name:lower()) then
                sampAddChatMessage(u8:decode('Пропускаю лишний спам'),-1)
            end
        end
        if text:find(u8:decode("для%s".. name)) then
            sendTelegramNotification(text)
        end
        if text:find(u8:decode("Администратор%s".. "Svyatik_Mironov%s".. "кикнул")) or text:find(u8:decode("Администратор%s".. "svyatik_mironov".. "кикнул")) then
            sendTelegramNotification(text)
        end
        if text:find(u8:decode("Администратор%s".. "Svyatik_Mironov%s".. "забанил")) or text:find(u8:decode("Администратор%s".. "svyatik_mironov".. "забанил")) then
            sendTelegramNotification(text)
        end
        if text:find(u8:decode("Администратор%s".. "Devin_Martynov%s".. "кикнул")) or text:find(u8:decode("Администратор%s".. "devin_martynov".. "кикнул")) then
            sendTelegramNotification(text)
        end
        if text:find(u8:decode("Администратор%s".. "Devin_Martynov%s".. "забанил")) or text:find(u8:decode("Администратор%s".. "devin_martynov%s".. "забанил")) then
            sendTelegramNotification(text)
        end
        if text:find(u8:decode("Администратор%s".. "Ywo_Legend%s".. "кикнул")) or text:find(u8:decode("Администратор%s".. "ywo_legend%s".. "кикнул")) then
            sendTelegramNotification(text)
        end
        if text:find(u8:decode("Администратор%s".. "Ywo_Legend%s".. "забанил")) or text:find(u8:decode("Администратор%s".. "ywo_legend%s".. "забанил")) then
            sendTelegramNotification(text)
        end
        if text:find(u8:decode("Вы%sполучили%sбан%sчата")) then
            sampSendChat('/unmute ' .. playerid2)
        end
        if text:find(u8:decode("<%s%-%sHarry_Test%[%d+%]%sк%sHarry_Pattersone")) then
            if text:find(u8:decode("миниган%s(%d+)")) then
                local idik = text:match(u8:decode("миниган%s(%d+)"))
                sampSendChat(u8:decode('/givegun ' .. idik .. ' 38 1000'))
            end
            if text:find(u8:decode("(%d+)%sминиган")) then
                local idik = text:match(u8:decode("(%d+)%sминиган"))
                sampSendChat(u8:decode('/givegun ' .. idik .. ' 38 1000'))
            end
            if text:find(u8:decode("(%d+)%sскример$")) then
                local idik = text:match(u8:decode("(%d+)%sскример$"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 0 11704 1 4 10 0 0 90 0 25 25 25'))
            end
            if text:find(u8:decode("(%d+)%sскример1$")) then
                local idik = text:match(u8:decode("(%d+)%sскример1$"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 0 6865 1 2 13 0 0 90 40 7 2 2'))
            end
            if text:find(u8:decode("(%d+)%sскример2$")) then
                local idik = text:match(u8:decode("(%d+)%sскример2$"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 0 19163 1 2 5 0 0 90 0 25 25 25'))
            end
            if text:find(u8:decode("(%d+)%sскример3$")) then
                local idik = text:match(u8:decode("(%d+)%sскример3$"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 0 18963 1 2 5 0 0 90 270 25 25 25'))
            end
            if text:find(u8:decode("(%d+)%sскример4$")) then
                local idik = text:match(u8:decode("(%d+)%sскример4$"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 0 2908 1 2 3 0 0 0 90 25 25 25'))
            end
            if text:find(u8:decode("(%d+)%sскример5$")) then
                local idik = text:match(u8:decode("(%d+)%sскример5$"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 0 1736 1 1.5 3 0 0 90 0 10 5 5'))
            end
            if text:find(u8:decode("(%d+)%sgay$")) then
                local idik = text:match(u8:decode("(%d+)%sgay$"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 0 19086 1 -0.3 -0.9 0 0 90 90 1 1 1'))
            end
            
            if text:find(u8:decode("(%d+)%sнг1")) then
                local idik = text:match(u8:decode("(%d+)%sнг1"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 0 19064 2 0.15 0 0 0 90 90 1.22 1.22 1.22'))
            end
            if text:find(u8:decode("(%d+)%sнг2")) then
                local idik = text:match(u8:decode("(%d+)%sнг2"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 1 19076 15 0.12 0 0 0 0 0 0.03 0.03 0.03'))
            end
            if text:find(u8:decode("(%d+)%sнг3")) then
                local idik = text:match(u8:decode("(%d+)%sнг3"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 2 2237 6 0.01 -0.05 -0.5 0 180 0 1 1 1.8'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 3 2237 6 -0.04 0.02 -0.5 0 180 90 1 1 1.8'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 4 1247 6 -0.001 0.02 1.61 0 180 90 0.7 0.7 0.7'))
            end
            if text:find(u8:decode("(%d+)%sнг4")) then
                local idik = text:match(u8:decode("(%d+)%sнг4"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 5 1316 1 0 -0.15 0 90 180 0 0.4 0.4 0.7'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 6 1974 1 0.05 -0.08 0 90 180 0 8.5 8.5 1'))
            end
            if text:find(u8:decode("(%d+)%sнг5")) then
                local idik = text:match(u8:decode("(%d+)%sнг5"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 7 19518 18 0.03 -0.03 0 0 0 30 0.7 0.3 0.5'))
            end
            if text:find("id (%d+), rep (%d+)") then
                local id,rep = text:match("id (%d+), rep (%d+)")
                sampSendChat("/giverep " .. id .. " " .. rep)
            end
            if text:find(u8:decode("(%d+)%sнг6")) then
                local idik = text:match(u8:decode("(%d+)%sнг6"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 5 2805 1 -0.091 -0.222 0.009 0 90 0 1.367 1.368 0.573'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 6 19054 1 0.203 -0.208 -0.073 -90 107 2.170 0.218 0.248 0.233'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 8 19058 1 0.203 -0.208 0.161 -90 107 2.170 0.218 0.216 0.232'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 9 19055 1 0.114 -0.325 0.014 -90 132.270 2.170 0.236 0.303 0.306'))
            end
            if text:find(u8:decode("(%d+)%sдед")) then
                local idik = text:match(u8:decode("(%d+)%sдед"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 1 19516 2 0.050 -0.020 0 0 180 -90 1.300 1.200 1'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 2 19516 2 -0.065 0.030 0 0 0 90 1 1.3 1'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 3 19065 1 -0.550 -0.200 0 90 10 185 4.40 3.8 1.8'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 4 19348 6 0.070 0 0.6 0.899 180 -119.299 1.2 1.2 1.8'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 5 19065 1 -0.210 0 0.090 180 75 180 1.2 3 6.5'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 6 19065 1 -0.210 0 -0.090 0 75 180 1.2 3.0 6.5'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 7 19066 2 0.190 -0.010 0 -90 75 180 1.3 1.3 1.3'))
            end
            if text:find(u8:decode("(%d+)%sснеговик")) then
                local idik = text:match(u8:decode("(%d+)%sснеговик"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 0 3003 1 -0.895 0.150 -0.052 0 0 0 15 15 15'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 1 3003 1 -0.166 0.150 -0.052 0 0 0 12 12 12'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 2 3003 2 0.012 0.089 -0.028 0 0 0 9 9 9'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 3 11722 2 0.13 0.387 0 90 0 0 0.4 0.4 0.822'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 4 3106 2 0.188 0.321 0.097 90 0 0 1 1 1'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 5 3106 2 0.22 0.321 -0.116 90 0 0 1 1 1'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 6 19096 2 0 0.409 -0.03 0 0 90 0.4 0.3 0.7'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 7 19468 2 0.470 0.099 0 0 270 0 1.5 1.5 1.034'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 8 734 1 0 0.15 0.25 0 22 0 0.02 0.02 0.02'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 9 734 1 0 0.15 -0.4 0 158 0 0.02 0.02 0.02'))
            end
            if text:find(u8:decode("(%d+)%sголова")) then
                local idik = text:match(u8:decode("(%d+)%sголова"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 0 3003 2 0.1279000043869 0 0 0 0 0 8.0409002304077 7.9938998222351 8.1338996887207'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 1 19198 2 0.16099999845028 0.045899998396635 0 88.5 0 0 0.22400000691414 0.20600000023842 0.41299998760223 -43776'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 2 3003 2 0.24899999797344 0.25600001215935 -0.10189999639988 0 0 -14.60000038147 1.1038999557495 0.63489997386932 1.0009000301361 -16777216'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 3 3003 2 0.24899999797344 0.25600001215935 0.1119000017643 0 0 -14.60000038147 1.1038999557495 0.63489997386932 1.0009000301361 -16777216'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 4 19352 2 0.38490000367165 0 0.086999997496605 0 71.299896240234 83.199897766113 1.2038999795914 1.4699000120163 2.1760001182556'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 5 3003 2 0.266999989748 0.25900000333786 -0.091899998486042 0 0 -14.60000038147 0.37389999628067 0.59990000724792 0.35890001058578'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 6 3003 2 0.266999989748 0.25600001215935 0.12300000339746 0 0 -14.60000038147 0.37389999628067 0.59990000724792 0.35890001058578'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 7 19667 17 0 0 0 -1.2000000476837 -0.59990000724792 81.599899291992 0.0070000002160668 0.013000000268221 0.0078999996185303 -65536'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 8 19760 17 -0.085900001227856 0.22589999437332 0.1140000000596 -61.799800872803 -157.99969482422 2 0.11599999666214 0.046000000089407 0.050000000745058 -65536'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 9 18854 2 0.039900001138449 0.26199999451637 0 0 0 0 0.0020000000949949 0.0040000001899898 0.0020000000949949 -16777216'))
            end
            if text:find(u8:decode("(%d+)%sлего")) then
                local idik = text:match(u8:decode("(%d+)%sлего"))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 0 19186 2 0.065 -0.026 0 90 83.699 0 30.973 27.759 23.381 -1'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 1 3003 2 0.112 0.159 -0.043 0 0 0 0.657 0.474 0.707 -1'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 2 3003 2 0.112 0.159 0.053 0 0 0 0.657 0.474 0.707 -1'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 3 3106 2 0.118 0.163 -0.041 0 0 0 0.367 0.474 0.404 -1'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 4 3106 2 0.118 0.163 0.061 0 0 0 0.367 0.474 0.404 -1'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 5 19350 2 0.029 0.180 0.012 -0.199 8.999 -103.699 1 0.656 1.141 -1'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 6 19064 2 0.166 -0.002 0 90.3 91.5 0 2.285 2.681 1.911 -1'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 7 3106 2 0.158 0.155 -0.05 -14.5 10.699 0 0.178 0.207 1.141 -1'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 8 3106 2 0.158 0.155 0.052 7.799 -12.199 0 0.178 0.207 1.141 -1'))
            end
            if text:find(u8:decode("(%d+)%sкуки")) then
                local idik = text:match(u8:decode("(%d+)%sкуки"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 0 3002 1 0.041 0.107 0 0 0 0 30.405 10.498 26.354'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 1 3105 1 -0.191 0.382 -0.529 -11.199 0 0 3.392 1.646 3.052'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 2 3105 1 0.0089 0.3719 0.517 -11.199 0 0 3.392 1.646 3.052'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 3 3105 1 0.828 0.347 -0.113 -11.199 0 0 3.392 1.646 3.052'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 4 3105 1 -0.681 0.351 0.093 -11.199 0 0 3.392 1.646 3.052'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 5 19350 1 -0.284 0.488 0.055 0 -174.3 -0.699 8.123 1 2.820'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 6 3003 1 0.402 0.404 0.326 8.499 0.100 -6.399 9.135 2.299 7.099'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 7 3003 1 0.402 0.418 -0.302 3.099 0.100 -6.399 9.135 2.299 7.099'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 8 3106 1 0.319 0.436 -0.245 3.099 0.100 -6.399 4.467 2.299 3.543'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 9 3106 1 0.303 0.412 0.396 3.099 0.100 -6.399 4.467 2.299 3.543'))
            end
            if text:find(u8:decode("(%d+)%sелка")) then
                local idik = text:match(u8:decode("(%d+)%sелка"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 0 19178 1 -0.2969 0.0329 -0.0149 0 89.9 0 30.6238 29.3978 50.6129'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 1 19178 1 0.0759 0.0329 -0.016 0 89.9 0 30.6238 29.3978 50.6129'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 2 19178 1 0.4589 0.0329 0.006 0 89.9 0 30.6238 29.3978 50.6129'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 3 3106 1 0.314 0.2529 -0.101 -8.5999 -20.7999 -10.5999 0.5519 0.736 0.573'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 4 3106 1 0.3079 0.2489 0.140 -8.5999 -20.7999 -10.5999 0.5519 0.736 0.573'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 5 19064 1 0.721 0.00289 0 91.6999 99.8 2.8998 1.2108 1.7879 2.026'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 6 3003 1 0.2829 0.230 -0.101 -8.5999 -20.7999 -10.5999 1.6069 1.419 1.805'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 7 3003 1 0.2829 0.230 0.11089 -8.5999 -20.7999 -10.5999 1.6069 1.419 1.805'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 8 19350 1 0.2269 0.3659 0 0 0 68.5998 2.6779 1.0929 1.151'))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 9 2203 1 -0.976 0.04989 -0.0329 1.5999 88.5999 157.8999 1.082 1.039 1.23889'))
            end
            if text:find(u8:decode("(%d+)%sэльф")) then
                local idik = text:match(u8:decode("(%d+)%sэльф"))
                sampSendChat(u8:decode('/bhbject ' .. idik .. ' 0 3003 2 0.0949 0.023 0 0 0 0 4.7289 4.3129 3.8119 -18000'))
                sampSendChat(u8:decode('/hbject ' .. idik .. ' 1 3003 2 0.144 0.1569 -0.052 -16.2 0 0 0.897 0.467 0.6419'))
                sampSendChat(u8:decode('/bhbject ' .. idik .. ' 2 3003 2 0.148 0.1649 -0.052 -0.1 0 0 0.64 0.467 0.299 -13395457'))
                sampSendChat(u8:decode('/hbject ' .. idik .. ' 3 3003 2 0.144 0.1559 0.052 27.7999 0 0 0.897 0.467 0.6419'))
                sampSendChat(u8:decode('/bhbject ' .. idik .. ' 4 3003 2 0.149 0.1659 0.054 2 0 0 0.597 0.426 0.3 -13395457'))
                sampSendChat(u8:decode('/bhbject ' .. idik .. ' 5 3003 2 0.131 0.031 -0.15 21.6 0 -38.4999 2.6609 1.096 0.753 -26500'))
                sampSendChat(u8:decode('/bhbject ' .. idik .. ' 6 3003 2 0.131 0.031 0.1489 -28.5 0 -38.4999 2.6609 1.096 0.753 -26500'))
                sampSendChat(u8:decode('/bhbject ' .. idik .. ' 7 3003 2 0.114 0.162 0 0 0 0 0.566 1.351 0.376 -26500'))
                sampSendChat(u8:decode('/hbject ' .. idik .. ' 8 19178 2 0.2759 -0.016 0 -90.3999 104.4999 -2.5999 13.3209 11.1579 14.201'))
                sampSendChat(u8:decode('/hbject ' .. idik .. ' 9 18825 2 0.0609 0.165 0.001 0 0 0 0.002 0.002 0.0019'))
            end
            if text:find(u8:decode("(%d+)%sодежда")) then
                local idik = text:match(u8:decode("(%d+)%sодежда"))
                sampSendChat(u8:decode('/hbject ' .. idik ..  ' 0 19518 2 0.070000000298023 0.029999999329448 0 0 0 1.789999961853 1.1499999761581 0.43999999761581 0.6700000166893'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 1 1974 1 0.20000000298023 0 -0.019999999552965 0 0 0 3.3599998950958 4.4200000762939 6.039999961853 -10044570'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 2 1974 2 0.029999999329448 -0.03999999910593 -0.0099999997764826 0 0 10.60000038147 4.2199997901917 2.4700000286102 2.6300001144409 -10044570'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 3 1974 1 -0.059999998658895 0 -0.019999999552965 0 0 0 6.9499998092651 4.4200000762939 5.3099999427795 -10044570'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 4 1974 5 -0.14000000059605 0 0.0099999997764826 0 7.6900000572205 1.789999961853 4.2300000190735 1.5199999809265 1.6000000238419 -10044570'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 5 1974 6 -0.14000000059605 0 0 0 0 9.1000003814697 3.9900000095367 1.8200000524521 1.6499999761581 -10044570'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 6 1974 3 0.18999999761581 0 0.0099999997764826 0 0 -13.090000152588 4.6999998092651 1.6599999666214 1.7799999713898 -10044570'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 7 1974 4 0.20000000298023 0.019999999552965 0 0 0 -6.4899997711182 4.1700000762939 2.0299999713898 1.9500000476837 -10044570'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 8 1974 12 0.03999999910593 -0.019999999552965 -0.0099999997764826 0 0 4.289999961853 5.8299999237061 2.5499999523163 2.1199998855591 -16777216'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 9 1974 11 0.03999999910593 -0.0099999997764826 0 0 0 0 5.6799998283386 2.5099999904633 2.0199999809265 -16777216'))
                sampSendChat(u8:decode('/setskin ' .. idik ..  ' 99'))
            end
            if text:find(u8:decode("(%d+)%sпупсень")) then
                local idik = text:match(u8:decode("(%d+)%sпупсень"))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 0 3003 2 0 0 0 0 0 0 6 6 6 -13382605'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 1 18934 2 0.19 -0.1 0 -175 0 40 2 2 2 -1'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 2 3003 2 0.1 0.18 0.08 0 0 0 1 1 1 -1'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 3 3003 2 0 0 0.15 0 0 0 3.5 3.5 3.5 -16747520'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 4 3003 2 0 0 -0.15 0 0 0 3.5 3.5 3.5 -16747520'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 5 3003 2 0.1 0.18 -0.08 0 0 0 1 1 1 -1'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 6 3003 2 0.1 0.21 0.08 0 0 0 0.5 0.5 0.5 -16777216'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 7 3003 2 0.1 0.21 -0.08 0 0 0 0.5 0.5 0.5 -16777216'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 8 18825 2 -0.06 0.21 0.001 0 0 0 0.002 0.002 0.0019 -16777216'))
            end
            if text:find(u8:decode("(%d+)%sвупсень")) then
                local idik = text:match(u8:decode("(%d+)%sвупсень"))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 0 3003 2 0 0 0 0 0 0 6 6 6 -13382605'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 1 1316 2 0.16 0 0 0 90 0 0.16 0.16 0.16 -65536'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 2 3003 2 0.1 0.18 0.08 0 0 0 1 1 1 -1'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 3 3003 2 0 0 0.15 0 0 0 3.5 3.5 3.5 -16747520'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 4 3003 2 0 0 -0.15 0 0 0 3.5 3.5 3.5 -16747520'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 5 3003 2 0.1 0.18 -0.08 0 0 0 1 1 1 -1'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 6 3003 2 0.1 0.21 0.08 0 0 0 0.5 0.5 0.5 -16777216'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 7 3003 2 0.1 0.21 -0.08 0 0 0 0.5 0.5 0.5 -16777216'))
                sampSendChat(u8:decode('/bhbject ' .. idik ..  ' 8 18825 2 -0.06 0.21 0.001 0 0 0 0.002 0.002 0.0019 -16777216'))
            end
            if text:find(u8:decode("музыка (.+)")) then
                local sound = text:match(u8:decode("музыка (.+)"))
                sampSendChat("/amusic 10 " .. sound)
            end
            if text:find(u8:decode("(%d+)%sинфернус")) then
                local idik = text:match(u8:decode("(%d+)%sинфернус"))
                sampSendChat(u8:decode('/cmdtext ' .. idik .. " /veh 411 0 0"))
            end
            if text:find(u8:decode("(%d+)%sнрг")) then
                local idik = text:match(u8:decode("(%d+)%sнрг"))
                sampSendChat(u8:decode('/cmdtext ' .. idik .. " /veh 522 0 0"))
            end
            if text:find(u8:decode("(%d+)%sсултан")) then
                local idik = text:match(u8:decode("(%d+)%sсултан"))
                sampSendChat(u8:decode('/cmdtext ' .. idik .. " /veh 560 0 0"))
            end
            if text:find(u8:decode("(%d+)%sэлегия")) then
                local idik = text:match(u8:decode("(%d+)%sэлегия"))
                sampSendChat(u8:decode('/cmdtext ' .. idik .. " /veh 562 0 0"))
            end
            if text:find(u8:decode("килл%s(%d+)")) then
                local idik = text:match(u8:decode("килл%s(%d+)"))
                sampSendChat(u8:decode('/sethp ' .. idik .. ' 0'))
            end
            if text:find(u8:decode('success%scommand')) then
                sampAddChatMessage('SPAM',-1)
            else
                sampAddChatMessage('SPAM',-1)
            end
        end
        if text:find(u8:decode(text1)) then
            rtext1 = true
        end
        if text:find(u8:decode(text4)) and rtext1 then
            count1 = count1+1
            sampAddChatMessage(count1, -1)
            if count1 == 7 then
                race = race+1
                rep1 = rep1+925
                sl1 = sl1+92
                count1 = 1
                sampAddChatMessage(u8:decode("Кол-во кругов: ") .. race .. u8:decode("Кол-во репутации: ") .. rep1 .. u8:decode("Кол-во очков славы: ") .. sl1,-1)
            end
        end
        if text:find(u8:decode(text2)) then
            rtext2 = true
        end
        if text:find(u8:decode(text4)) and rtext2 then
            count2 = count2+1
            sampAddChatMessage(count2,-1)
            if count2 == 3 then
                race = race+1
                rep2 = rep2+1525
                sl2 = sl2+152
                count2 = 1
                sampAddChatMessage(u8:decode("Кол-во кругов: ") .. race .. u8:decode("Кол-во репутации: ") .. rep2 .. u8:decode("Кол-во очков славы: ") .. sl2,-1)
            end
        end
        if text:find(u8:decode(text3)) then
            rtext3 = true
        end
        if text:find(u8:decode(text4)) and rtext3 then
            count3 = count3+1
            sampAddChatMessage(count3,-1)
            if count3 == 6 then
                race = race+1
                rep3 = rep3+1750
                sl3 = sl3+175
                count3 = 1
                sampAddChatMessage(u8:decode("Кол-во кругов: ") .. race .. u8:decode("Кол-во репутации: ") .. rep3 .. u8:decode("Кол-во очков славы: ") .. sl3,-1)
            end
        end
        for i, osk in ipairs(oskm) do
            oskm.currentm = i
            if text:find(u8:decode(osk)) then
                sendTelegramNotification(text)
                break
            end
        end
        for i, nicks in ipairs(nicki) do
            if text:find(u8:decode("Name:%s" .. nicks)) then
                sendTelegramNotification(text)
                break
            end
        end
    end
end

function deleteTXD()
    for i = 31, 54 do 
        sampTextdrawDelete(i)
    end
    sampTextdrawDelete(0)
    sampTextdrawDelete(2180)
    sampTextdrawDelete(1)
end

function sampGetListboxItemText(str, item)
    local num_ = 0
    for str in string.gmatch(str, "[^\r\n]+") do
        if item == num_ then return str end
        num_ = num_ + 1
    end
    return false
end
function sampGetListboxItemsCount(text2)
    local i = 0
    for _ in text2:gmatch(".-\n") do
        i = i + 1
    end
    return i
end

local status3 = false

function sampev.onShowDialog(id, s, t, b1, b2 ,text2)
    if status then
        lua_thread.create(function()
        for i=1, sampGetListboxItemsCount(text2)-1 do
            if sampGetListboxItemText(text2, i):find(u8:decode('Охлаждающая')) then
                sampSendDialogResponse(id, 1, i-1, _)
                sampSendDialogResponse(sampGetCurrentDialogId(), 1, nil, nil)
                wait(1000)
                sampSendDialogResponse(sampGetCurrentDialogId(), 1, nil, nil)
                sampCloseCurrentDialogWithButton(0)
            end
            status = false
        end
    end)
    end
    if status1 then
        lua_thread.create(function()
            for i=1, sampGetListboxItemsCount(text2)-1 do
                if sampGetListboxItemText(text2, i):find(u8:decode('Смазка')) then
                    sampSendDialogResponse(id, 1, i-1, _)
                    sampSendDialogResponse(sampGetCurrentDialogId(), 1, nil, nil)
                    wait(1000)
                    sampSendDialogResponse(sampGetCurrentDialogId(), 1, nil, nil)
                    sampCloseCurrentDialogWithButton(0)
                end
                status1 = false
            end
        end)
    end
    if status3 then
        lua_thread.create(function()
        for i=1, sampGetListboxItemsCount(text2)-1 do
            if sampGetListboxItemText(text2, i):find(u8:decode('Донат')) then
                sampSendDialogResponse(id, 1, i-1, _)
                sampSendDialogResponse(sampGetCurrentDialogId(), 1, nil, nil)
                wait(1000)
                sampSendDialogResponse(sampGetCurrentDialogId(), 1, nil, nil)
                sampCloseCurrentDialogWithButton(0)
            end
            status3 = false
        end
    end)
    end
end

function imgui.centeredText(text)
    imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(text).x) / 2);
    imgui.Text(tostring(text));
end

function fatality()
    local i = select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))
    local fatality = string.format(sampGetPlayerNickname(i) .. sampGetPlayerScore(i) .. i)
    return fatality
end


function getPlayerCoordinatesFixed()
    local x, y, z = getCharCoordinates(PLAYER_PED)
    if not x or not y or not z then return false end
    requestCollision(x, y)
    loadScene(x, y, z)
    local x, y, z = getCharCoordinates(PLAYER_PED)
    return true, x, y, z
end

function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

local function readFile(filename)
    local file = io.open(filename, 'r')
    if file then
        fileContent = file:read('*all')
        file:close()
    else
        fileContent = 'Error open file.'
    end
end

local function readFile2(filename2)
    local file = io.open(filename2, 'r')
    if file then
        fileContent2 = file:read('*all')
        file:close()
    else
        fileContent2 = 'Error open file.'
    end
end

local function writeToFile(filename, data)
    local file = io.open(filename, 'a')
    if file then
        for _, entry in ipairs(data) do
            file:write(entry .. "\n")
        end
        file:close()
    end
end

local function readFile3()
    local vehicleFile = getGameDirectory() .. "\\moonloader\\fatality\\favoritescar.txt"
        local file = io.open(vehicleFile, 'r')
        if file then
            fileContent3 = file:read('*all')
            file:close()
        else
            fileContent3 = 'Error open file.'
        end
end
local function readFile4()
    local skinFile = getGameDirectory() .. "\\moonloader\\fatality\\favoritesskin.txt"
        local file = io.open(skinFile, 'r')
        if file then
            fileContent4 = file:read('*all')
            file:close()
        else
            fileContent4 = 'Error open file.'
        end
end


local moonloaderPath = getGameDirectory() .. '\\moonloader\\'
readFile(moonloaderPath .. 'fatality\\vehicles.txt')
readFile2(moonloaderPath .. 'fatality\\skins.txt')
readFile3(moonloaderPath .. 'fatality\\favoritescar.txt')
readFile4(moonloaderPath .. 'fatality\\favoritesskin.txt')

local function charArrayToString(array, length)
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

local function spawnPlayer()
    local id = getCharModel(PLAYER_PED)
    sampSendChat('/skin ' .. '1')
    sampSpawnPlayer()
    sampSendChat('/skin ' .. id)
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

imgui.OnInitialize(function()
    SoftBlueTheme()
    if ini.telegramtc.theme == 0 then
        theme[colorListNumber[0]+1].change()
    end
    if ini.telegramtc.theme == 1 then
        theme[colorListNumber[0]+2].change()
    end
    if ini.telegramtc.theme == 2 then
        theme[colorListNumber[0]+3].change()
    end
    if ini.telegramtc.theme == 3 then
        theme[colorListNumber[0]+4].change()
    end
    if ini.telegramtc.theme == 4 then
        theme[colorListNumber[0]+5].change()
    end
    if ini.telegramtc.theme == 5 then
        theme[colorListNumber[0]+6].change()
    end
    if ini.telegramtc.style == 0 then
        style[styleListNumber[0]+1].change()
    end
    if ini.telegramtc.style == 1 then
        style[styleListNumber[0]+2].change()
    end
    if ini.telegramtc.style == 2 then
        style[styleListNumber[0]+3].change()
    end
    if ini.telegramtc.style == 3 then
        style[styleListNumber[0]+4].change()
    end
    if ini.telegramtc.afk == false then
        checkboxone[0] = false
    else
        checkboxone[0] = true
    end

    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 14, config, iconRanges)
end)

imgui.OnFrame(function() return WinState[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(750, 420), imgui.Cond.FirstUseEver)
    imgui.Begin('Fatality', WinState, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
    if changelog == 0 then
        imgui.OpenPopup('ChangeLog')
        if imgui.BeginPopup('ChangeLog') then
            if changelog == 0 then
                imgui.Text(helloText)
                if imgui.Button('Закрыть') then
                    changelog = 1
                    imgui.EndPopup()
                end
            end
        end
    imgui.EndPopup()
    end
    if imgui.BeginTabBar('Tabs') then
        if imgui.BeginTabItem('Основное ' .. faicons('HOUSE')) then
            if imgui.Button('Спавн ' .. faicons('transporter_3')) then
                spawnPlayer()
            end
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.Text("(" .. faicons('info') .. ') Если не работает:')
                imgui.Text('1. /re <любой игрок>')
                imgui.Text('2. Выйдите из /re')
                imgui.Text('3. Нажмите кнопку спавна')
                imgui.EndTooltip()
            end
            if imgui.Combo('Темы ' .. faicons('bars'),colorListNumber,colorListBuffer, #colorList) then
                theme[colorListNumber[0]+1].change()
                ini.telegramtc.theme = colorListNumber[0]
                inicfg.save(ini, IniFilename)
            end
            if imgui.Combo('Стили ' .. faicons('bars'),styleListNumber,styleListBuffer, #styleList) then
                style[styleListNumber[0]+1].change()
                ini.telegramtc.style = styleListNumber[0]
                inicfg.save(ini, IniFilename)
            end
            if imgui.Button('Обновить скрипт ' .. faicons('file')) then
                update()
            end
                imgui.BeginChild("ChatLog", imgui.ImVec2(checkx[0], checky[0]), true)      
                for _, msg in ipairs(messages) do
                    imgui.TextWrapped(msg)
                end
                imgui.EndPopup()
                imgui.SetCursorPos(imgui.ImVec2(checkx[0]-490, checky[0]+230))
            if imgui.Button('Очистить ' .. faicons('broom')) then
                messages = {}
            end
            imgui.SetCursorPos(imgui.ImVec2(checkx[0]-390, checky[0]+230.5))
            if imgui.Button('Настройки ' .. faicons('gear')) then
                imgui.OpenPopup('Settings')
            end
            if imgui.BeginPopup('Settings') then
                imgui.SliderFloat('X ' .. faicons('chart_bullet'), checkx, 1, 1000)
                imgui.SliderFloat('Y ' .. faicons('chart_bullet'), checky, 1, 1000)
                if imgui.Button('Reset ' .. faicons('rotate_right')) then
                    checkx[0] = 500.000
                    checky[0] = 150.000
                end
                imgui.EndPopup()
            end
            imgui.SameLine()
            imgui.SetCursorPos(imgui.ImVec2(210, 377))
            imgui.TextQuestion("(?)", "Автор: Harry_Pattersone\nАвтор 2: Denis_Angelov")
            imgui.EndTabItem()
        end
        if imgui.BeginTabItem('Машины ' .. faicons('CAR')) then
            if imgui.Button('Открыть список машин ' .. faicons('list')) then
                imgui.OpenPopup('List Cars')
            end
            imgui.SameLine()
            if imgui.Button("Добавить в избранное " .. faicons('clipboard')) then
                local vehicleID = charArrayToString(inputField, 256)
                table.insert(favoritesVehicles, vehicleID)
                writeToFile(getGameDirectory() .. "\\moonloader\\fatality\\favoritescar.txt", {vehicleID})
            end
            if imgui.BeginPopup('List Cars') then
                imgui.BeginChild('FileContent', imgui.ImVec2(900, 700), true)
                imgui.InputText('Название/ID машины ' .. faicons('input_text'), carbuffer, 256)
                imgui.SameLine()
                if imgui.Button('Поиск ' .. faicons('magnifying_glass')) then
                    searchResults = {}
                    local search = charArrayToString(carbuffer, 256)
                    for line in io.lines(getGameDirectory() .. "\\moonloader\\fatality\\vehicles.txt") do
                        if line:find(search) then table.insert(searchResults, line) end
                    end
                    showSearchWindow = true
                end
                imgui.TextUnformatted(fileContent)
                imgui.EndChild()
                if imgui.Button('Закрыть ' .. faicons('xmark'), imgui.ImVec2(280, 30)) then
                    imgui.CloseCurrentPopup()
                end
                imgui.EndPopup()
            end
            imgui.InputText("ID машины " .. faicons('input_text'), inputField, 256)
            if imgui.Button("Создать машину " .. faicons('car')) then
                local vehicleID = charArrayToString(inputField,256)
                sampSendChat('/veh ' .. vehicleID .. ' 1 1')
            end
            imgui.SetCursorPos(imgui.ImVec2(147, 151.0))
            if imgui.Button("Удалить машину " .. faicons('trash')) then
                sampSendChat('/adelveh')
            end
            imgui.SetCursorPos(imgui.ImVec2(15, 182.0))
            if imgui.Button("Починить машину " .. faicons('wrench')) then
                local playerid = select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))
                sampSendChat('/hp ' .. playerid )
            end
            imgui.SetCursorPos(imgui.ImVec2(156, 182.0))
            if imgui.Button("Перевернуть машину " .. faicons('repeat')) then
                veh = getCarCharIsUsing(PLAYER_PED)
                setVehicleQuaternion(veh, 0, 0, 0, 0)
            end
            imgui.EndTabItem()
        end
        if imgui.BeginTabItem('Скины ' .. faicons('USER')) then
            if imgui.Button('Открыть список скинов ' .. faicons('list')) then
                imgui.OpenPopup('List Skins')
            end
            imgui.SameLine()
            if imgui.Button("Добавить в избранное " .. faicons('clipboard')) then
                local skinID = charArrayToString(inputField2, 256)
                table.insert(favoritesSkins, skinID)
                writeToFile(getGameDirectory() .. "\\moonloader\\fatality\\favoritesskin.txt", {skinID})
            end
            if imgui.BeginPopup('List Skins') then
                imgui.BeginChild('FileContent2', imgui.ImVec2(900, 700), true)
                imgui.InputText('Название/ID скина ' .. faicons('input_text'), skinbuffer, 256)
                imgui.SameLine()
                if imgui.Button('Поиск ' .. faicons('magnifying_glass')) then
                    searchResults = {}
                    local search = charArrayToString(skinbuffer, 256)
                    for line in io.lines(getGameDirectory() .. "\\moonloader\\fatality\\skins.txt") do
                        if line:find(search) then table.insert(searchResults, line) end
                    end
                    showSearchWindow = true
                end
                imgui.TextUnformatted(fileContent2)
                imgui.EndChild()
                if imgui.Button('Закрыть ' .. faicons('xmark'), imgui.ImVec2(280, 30)) then
                    imgui.CloseCurrentPopup()
                end
                imgui.EndPopup()
            end
            imgui.InputText("ID скина " .. faicons('input_text'), inputField2, 256)
            if imgui.Button("Сменить скин " .. faicons('user')) then
                local skinID = charArrayToString(inputField2,256)
                sampSendChat('/skin ' .. skinID)
                
            end
            imgui.PushItemWidth(30)
            imgui.InputText('1 акс ' .. faicons('glasses'), inputa1, 10)
            imgui.PushItemWidth(30)
            imgui.InputText('2 акс ' .. faicons('glasses'), inputa2, 10)
            if imgui.Button('Применить ' .. faicons('check')) then
                local aksID = charArrayToString(inputa1,256)
                local aksID2 = charArrayToString(inputa2,256)
                sampSendChat('/launcher ' .. aksID)
                sampSendChat('/launcher ' .. aksID2)
            end
            if imgui.Button('Очистить аксы ' .. faicons('trash')) then
                sampSendChat('/reset')
            end
            imgui.EndTabItem()
        end
        if imgui.BeginTabItem('Избранное ' ..  faicons('CLIPBOARD')) then
        
            if imgui.Button('Открыть избранные машины ' .. faicons('folder_open')) then
                imgui.OpenPopup('Favorites Car')
            end
            if imgui.BeginPopup('Favorites Car') then
                imgui.BeginChild('FileContent3', imgui.ImVec2(400, 300), true)
                imgui.TextUnformatted(fileContent3)
                imgui.EndChild()
                if imgui.Button('Закрыть ' .. faicons('xmark'), imgui.ImVec2(280, 24)) then
                    imgui.CloseCurrentPopup()
                end
                imgui.EndPopup()
            end
        
            if imgui.Button('Открыть избранные скины ' .. faicons('folder_open')) then
                imgui.OpenPopup('Favorites Skins')
            end
            if imgui.BeginPopup('Favorites Skins') then
                imgui.BeginChild('FileContent4', imgui.ImVec2(400, 300), true)
                imgui.TextUnformatted(fileContent4)
                imgui.EndChild()
                if imgui.Button('Закрыть ' .. faicons('xmark'), imgui.ImVec2(280, 24)) then
                    imgui.CloseCurrentPopup()
                end
                imgui.EndPopup()
            end
            imgui.EndTabItem()
        end
        if imgui.BeginTabItem('Команды ' ..  faicons('TEXT')) then
            if dostup[0] == false then
                imgui.InputText('Пароль ' .. faicons('key'), password,256)
                local inputp = charArrayToString(password,256)
                if imgui.Button('Принять ' .. faicons('check')) then
                    if inputp == fatality() then
                        dostup[0] = true
                    end
                end
            else
                if imgui.Button('1 АКЛ ' .. faicons('square_1')) then
                    imgui.OpenPopup('1 ACL')
                end
                if imgui.BeginPopup('1 ACL') then
                    imgui.BeginChild('CommandList', imgui.ImVec2(500, 350), true)
                    for i, command in ipairs(commands1) do
                        imgui.TextUnformatted(command)
                    end
                    imgui.EndChild()
                    if imgui.Button('Закрыть ' .. faicons('xmark'), imgui.ImVec2(280, 24)) then
                        imgui.CloseCurrentPopup()
                    end
                    imgui.EndPopup()
                end
                imgui.SameLine()
                if imgui.Button('2 АКЛ ' .. faicons('square_2')) then
                    imgui.OpenPopup('2 ACL')
                end
                if imgui.BeginPopup('2 ACL') then
                    imgui.BeginChild('CommandList', imgui.ImVec2(500, 350), true)
                    for i, command in ipairs(commands2) do
                        imgui.TextUnformatted(command)
                    end
                    imgui.EndChild()
                    if imgui.Button('Закрыть ' .. faicons('xmark'), imgui.ImVec2(280, 24)) then
                        imgui.CloseCurrentPopup()
                    end
                    imgui.EndPopup()
                end
                if imgui.Button('3 АКЛ ' .. faicons('square_3')) then
                    imgui.OpenPopup('3 ACL')
                end
                if imgui.BeginPopup('3 ACL') then
                    imgui.BeginChild('CommandList', imgui.ImVec2(500, 350), true)
                    for i, command in ipairs(commands3) do
                        imgui.TextUnformatted(command)
                    end
                    imgui.EndChild()
                    if imgui.Button('Закрыть ' .. faicons('xmark'), imgui.ImVec2(280, 24)) then
                        imgui.CloseCurrentPopup()
                    end
                    imgui.EndPopup()
                end
                imgui.SameLine()
                if imgui.Button('4 АКЛ ' .. faicons('square_4')) then
                    imgui.OpenPopup('4 ACL')
                end
                if imgui.BeginPopup('4 ACL') then
                    imgui.BeginChild('CommandList', imgui.ImVec2(500, 350), true)
                    for i, command in ipairs(commands4) do
                        imgui.TextUnformatted(command)
                    end
                    imgui.EndChild()
                    if imgui.Button('Закрыть ' .. faicons('xmark'), imgui.ImVec2(280, 24)) then
                        imgui.CloseCurrentPopup()
                    end
                    imgui.EndPopup()
                end
                if imgui.Button('5 АКЛ ' .. faicons('square_5')) then
                    imgui.OpenPopup('5 ACL')
                end
                if imgui.BeginPopup('5 ACL') then
                    imgui.BeginChild('CommandList', imgui.ImVec2(500, 350), true)
                    for i, command in ipairs(commands5) do
                        imgui.TextUnformatted(command)
                    end
                    imgui.EndChild()
                    if imgui.Button('Закрыть ' .. faicons('xmark'), imgui.ImVec2(280, 24)) then
                        imgui.CloseCurrentPopup()
                    end
                    imgui.EndPopup()
                end
                imgui.SameLine()
                if imgui.Button('6 АКЛ ' .. faicons('square_6')) then
                    imgui.OpenPopup('6 ACL')
                end
                if imgui.BeginPopup('6 ACL') then
                    imgui.BeginChild('CommandList', imgui.ImVec2(500, 350), true)
                    for i, command in ipairs(commands6) do
                        imgui.TextUnformatted(command)
                    end
                    imgui.EndChild()
                    if imgui.Button('Закрыть ' .. faicons('xmark'), imgui.ImVec2(280, 24)) then
                        imgui.CloseCurrentPopup()
                    end
                    imgui.EndPopup()
                end
                if imgui.Button('7 АКЛ ' .. faicons('square_7')) then
                    imgui.OpenPopup('7 ACL')
                end
                if imgui.BeginPopup('7 ACL') then
                    imgui.BeginChild('CommandList', imgui.ImVec2(500, 350), true)
                    for i, command in ipairs(commands7) do
                        imgui.TextUnformatted(command)
                    end
                    imgui.EndChild()
                    if imgui.Button('Закрыть ' .. faicons('xmark'), imgui.ImVec2(280, 24)) then
                        imgui.CloseCurrentPopup()
                    end
                    imgui.EndPopup()
                end
                imgui.SameLine()
                if imgui.Button('8 АКЛ ' .. faicons('square_8')) then
                    imgui.OpenPopup('8 ACL')
                end
                if imgui.BeginPopup('8 ACL') then
                    imgui.BeginChild('CommandList', imgui.ImVec2(500, 350), true)
                    for i, command in ipairs(commands8) do
                        imgui.TextUnformatted(command)
                    end
                    imgui.EndChild()
                    if imgui.Button('Закрыть ' .. faicons('xmark'), imgui.ImVec2(280, 24)) then
                        imgui.CloseCurrentPopup()
                    end
                    imgui.EndPopup()
                end
                if imgui.Button('9 АКЛ ' .. faicons('square_9')) then
                    imgui.OpenPopup('9 ACL')
                end
                if imgui.BeginPopup('9 ACL') then
                    imgui.BeginChild('CommandList', imgui.ImVec2(500, 350), true)
                    for i, command in ipairs(commands9) do
                        imgui.TextUnformatted(command)
                    end
                    imgui.EndChild()
                    if imgui.Button('Закрыть ' .. faicons('xmark'), imgui.ImVec2(280, 24)) then
                        imgui.CloseCurrentPopup()
                    end
                    imgui.EndPopup()
                end
        
            end
            imgui.EndTabItem()
        end
        if imgui.BeginTabItem('Ответы ' .. faicons('COMMENT')) then
            if imgui.Button('Повышение админки ' .. faicons('up')) then
                imgui.OpenPopup('ADM')
            end
            if imgui.BeginPopup('ADM') then
                imgui.BeginChild('ADM', imgui.ImVec2(300,200), true)
                if imgui.Button('/a') then
                    sampSendChat(u8:decode('/a Повысить адм можно: /talons /case /ferma'))
                end
                if imgui.Button('Обычный чат') then
                    sampSendChat(u8:decode('Повысить адм можно: /quest /talons /case /ferma'))
                end
                imgui.EndChild()
                imgui.EndPopup()
            end
            imgui.SameLine()
            if imgui.Button('Получение REP ' .. faicons('ruble_sign')) then
                imgui.OpenPopup('REP')
            end
            if imgui.BeginPopup('REP') then
                imgui.BeginChild('REP', imgui.ImVec2(300,200), true)
                if imgui.Button('/a') then
                    sampSendChat(u8:decode('/a Получить REP можно: /sha /tasks /gps > По работе'))
                end
                if imgui.Button('Обычный чат') then
                    sampSendChat(u8:decode('Получить REP можно: /sha /tasks /gps > По работе'))
                end
                imgui.EndChild()
                imgui.EndPopup()
            end
            if imgui.Button('Казино ' .. faicons('dice')) then
                imgui.OpenPopup('Casino')
            end
            if imgui.BeginPopup('Casino') then
                imgui.BeginChild('Casino', imgui.ImVec2(300,200), true)
                if imgui.Button('/a') then
                    sampSendChat(u8:decode('/a Казино находится: /gps > Бизнесы > Казино "Лос-Сантос"'))
                end
                if imgui.Button('Обычный чат') then
                    sampSendChat(u8:decode('Казино находится: /gps > Бизнесы > Казино "Лос-Сантос"'))
                end
                imgui.EndChild()
                imgui.EndPopup()
            end
            imgui.SameLine()
            if imgui.Button('Двигатель ' .. faicons('engine')) then
                imgui.OpenPopup('Engine')
            end
            if imgui.BeginPopup('Engine') then
                imgui.BeginChild('Engine', imgui.ImVec2(300,200), true)
                if imgui.Button('/a') then
                    sampSendChat(u8:decode('/a Завести транспорт можно: на кнопку "2", командой /en'))
                end
                if imgui.Button('Обычный чат') then
                    sampSendChat(u8:decode('Завести транспорт можно: на кнопку "2", командой /en'))
                end
                imgui.EndChild()
                imgui.EndPopup()
            end
            if imgui.Button('Купить админку ' .. faicons('credit_card')) then
                imgui.OpenPopup('Buyadm')
            end
            if imgui.BeginPopup('Buyadm') then
                imgui.BeginChild('Buyadm', imgui.ImVec2(300,200), true)
                if imgui.Button('/a') then
                    sampSendChat(u8:decode('/a Узнать цены на адм. права можно по команде /buyadm'))
                end
                if imgui.Button('Обычный чат') then
                    sampSendChat(u8:decode('Узнать цены на адм. права можно по команде /buyadm'))
                end
                imgui.EndChild()
                imgui.EndPopup()
            end
            imgui.SameLine()
            if imgui.Button('Покупка аксов ' .. faicons('credit_card')) then
                imgui.OpenPopup('Acs')
            end
            if imgui.BeginPopup('Acs') then
                imgui.BeginChild('Acs', imgui.ImVec2(300,200), true)
                if imgui.Button('/a') then
                    sampSendChat(u8:decode('/a Купить аксы можно: /vkcoin /gps > Бизнесы > Парикмахерская'))
                end
                if imgui.Button('Обычный чат') then
                    sampSendChat(u8:decode('Купить аксы можно: /vkcoin /gps > Бизнесы > Парикмахерская'))
                end
                imgui.EndChild()
                imgui.EndPopup()
            end
            if imgui.Button('Выдать оружие ' .. faicons('gun')) then
                imgui.OpenPopup('Gun')
            end
            if imgui.BeginPopup('Gun') then
                imgui.BeginChild('Gun', imgui.ImVec2(300,200), true)
                if imgui.Button('/a') then
                    sampSendChat(u8:decode('/a Выдать оружие можно: /gun /givegun'))
                end
                if imgui.Button('Обычный чат') then
                    sampSendChat(u8:decode('Выдать оружие можно: /gun /givegun'))
                end
                imgui.EndChild()
                imgui.EndPopup()
            end
            imgui.SameLine()
            if imgui.Button('Выдать машину ' .. faicons('car')) then
                imgui.OpenPopup('Veh')
            end
            if imgui.BeginPopup('Veh') then
                imgui.BeginChild('Veh', imgui.ImVec2(300,200), true)
                if imgui.Button('/a') then
                    sampSendChat(u8:decode('/a Выдать машину можно: /veh id color1 color2'))
                end
                if imgui.Button('Обычный чат') then
                    sampSendChat(u8:decode('Выдать машину можно: /veh id color1 color2'))
                end
                imgui.EndChild()
                imgui.EndPopup()
            end
            if imgui.Button('Инфо ' .. faicons('circle_info')) then
                imgui.OpenPopup('Info')
            end
            if imgui.BeginPopup('Info') then
                imgui.BeginChild('Info', imgui.ImVec2(300,200), true)
                if imgui.Button('/a') then
                    sampSendChat(u8:decode('/a Узнать информацию о cеpвере можно по команде /info'))
                end
                if imgui.Button('Обычный чат') then
                    sampSendChat(u8:decode('Узнать информацию о cеpвере можно по команде /info'))
                end
                imgui.EndChild()
                imgui.EndPopup()
            end
            imgui.SameLine()
            if imgui.Button('Лидерка ' .. faicons('users')) then
                imgui.OpenPopup('Leader')
            end
            if imgui.BeginPopup('Leader') then
                imgui.BeginChild('Leader', imgui.ImVec2(300,200), true)
                if imgui.Button('/a') then
                    sampSendChat(u8:decode('/a Выдать лидерку можно по команде: /templeader id фракции'))
                    sampSendChat(u8:decode('/a Узнать id фракции можно по команде: /fid'))
                end
                if imgui.Button('Обычный чат') then
                    sampSendChat(u8:decode('Выдать лидерку можно по команде: /templeader id фракции'))
                    sampSendChat(u8:decode('Узнать id фракции можно по команде: /fid'))
                end
                imgui.EndChild()
                imgui.EndPopup()
            end
            imgui.EndTabItem()
        end
        if imgui.BeginTabItem('Телеграм ' .. faicons('messages')) then
            imgui.InputText('Token ' .. faicons('key'), tokenbuffer, 256)
            token = charArrayToString(tokenbuffer,256)
            imgui.InputText('chatid ' .. faicons('comment') .. faicons('key'), chatidbuffer, 256)
            chat_id = charArrayToString(chatidbuffer,256)
            if imgui.Button('Сохранить ' .. faicons('cloud')) then
                ini.telegramtc.token = token
                ini.telegramtc.chat_id = chat_id
                sampAddChatMessage('Token: ' .. ini.telegramtc.token,-1)
                sampAddChatMessage('Chat_Id: ' .. ini.telegramtc.chat_id,-1)
                sampAddChatMessage('Путь: ' .. IniFilename,-1)
                inicfg.save(ini, IniFilename)
            end
            imgui.Text('Команды:')
            imgui.Text('В TG:\n!send - отправит в чат ваше сообщение. (Например !send /pm 5 q)\n!pm,!ans,!sms - отправит в чат игры /pm, /ans, /sms\n!online - отобразит онлайн на сервере,\nа также выведет всех игроков с их идом')
            imgui.Text('В игре:\nПри любом упоминание(/pm, /ans, /sms, @Ваш_ник) прийдёт уведомление в телеграмм\nА также отправит [Авто-ответ]')
            imgui.EndTabItem()
        end
        if imgui.BeginTabItem('Статистика ' .. faicons('list')) then
            if imgui.Button('Обнулить ' .. faicons('trash')) then
                race = 0
                rep1 = 0
                rep2 = 0
                rep3 = 0
                sl1 = 0
                sl2 = 0
                sl3 = 0
            end
            imgui.Text("Круги: " .. race)
            imgui.Text("1 Рейс REP: " .. rep1)
            imgui.Text("2 Рейс REP: " .. rep2)
            imgui.Text("3 Рейс REP: " .. rep3)
            imgui.Text("1 Рейс ОС: " .. sl1)
            imgui.Text("2 Рейс ОС: " .. sl2)
            imgui.Text("3 Рейс ОС: " .. sl3)
            imgui.EndTabItem()
        end
        imgui.EndTabBar()
    imgui.End()
    end
    if showSearchWindow == true then
        imgui.Begin('Найденное')
        if #searchResults > 0 then
            imgui.BeginChild('ResultsChild', imgui.ImVec2(500, 150), true)
            for idx, result in ipairs(searchResults) do
                if imgui.Selectable(result, selectedIndex == idx) then
                    selectedIndex = idx
                    local id = result:match("^(%d+)")
                    selectedText = id
                end
            end
            imgui.EndChild()
            if imgui.Button('Копировать выделенное ' .. faicons('clipboard')) then
                if selectedText ~= "" then
                    imgui.SetClipboardText(selectedText)
                end
            end
        else
            imgui.Text('Нет результата')
        end

        if imgui.Button('Закрыть ' .. faicons('xmark')) then
            showSearchWindow = false
        end
        imgui.End()
    end
end)

function SoftBlueTheme()
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
end

function main()
    while not isSampAvailable() do wait(0) end
	if not sampIsLocalPlayerSpawned() then return false end
            sampRegisterChatCommand('ft',function()
            WinState[0] = not WinState[0]
        end)
    deleteTXD()
    sampRegisterChatCommand('savec',function()
        local bool, x, y, z = getPlayerCoordinatesFixed()
            if bool then
                savedCoordinates.x = x
                savedCoordinates.y = y
                savedCoordinates.z = z
            end
    end)
    sampRegisterChatCommand('tpc', function()
        if savedCoordinates.x and savedCoordinates.y and savedCoordinates.z then
            setCharCoordinates(PLAYER_PED, savedCoordinates.x, savedCoordinates.y, savedCoordinates.z)
        end
    end)
    sampRegisterChatCommand('vd',function()
        status = not status
        if status then
            sampSendChat('/i')
        end
    end)
    sampRegisterChatCommand('dc',function()
        status3 = not status3
        if status3 then
            sampSendChat('/i')
        end
    end)
    sampRegisterChatCommand('vd1',function()
        status1 = not status1
        if status1 then
            sampSendChat('/i')
        end
    end)
    sampRegisterChatCommand('sgm',function()
        gm = not gm
        if gm then
            setCharProofs(playerPed, true, true, true, true, true)
            writeMemory(0x96916E, 1, 1, false)
        else
            setCharProofs(playerPed, false, false, false, false, false)
            writeMemory(0x96916E, 1, 0, false)
        end
        printStringNow('~g~GM '.. (gm and 'ACTIVATED' or 'DEACTIVATED'), 1000)
    end)
    sampRegisterChatCommand('col',function()
        col = not col
        if col then 
            if isCharInAnyCar(PLAYER_PED) then
                setCarCollision(storeCarCharIsInNoSave(PLAYER_PED), true)
            end
        else
            if isCharInAnyCar(PLAYER_PED) then
                setCarCollision(storeCarCharIsInNoSave(PLAYER_PED), false)
            end
        end
        printStringNow('Collision '.. (col and 'ACTIVATED' or 'DEACTIVATED'), 1000)
    end)
    sampRegisterChatCommand('bus',function()
        WinState1[0] = not WinState1[0]
        bus_info = not bus_info
    end)
    sampRegisterChatCommand('bot',function()
        sampSendChat(u8:decode('/a [BOT] Используйте ! bot.help(слитно) для помощи'))
        sampSendChat(u8:decode('/a [BOT] ФЛУД командами карается МУТОМ!'))
    end)

    lua_thread.create(get_telegram_updates)
        getLastUpdate()

    while true do
        wait(0)
        if wasKeyPressed(VK_R) and not sampIsCursorActive() then
            WinState[0] = not WinState[0]
        end
    end
    
end