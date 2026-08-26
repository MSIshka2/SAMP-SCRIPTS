local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
cp = encoding.CP1251

local effil = require("effil")
local memory = require 'memory'
local sampev = require 'lib.samp.events'
local ffi = require 'ffi'
local vector3d = require('vector3d')
local shell32 = ffi.load('shell32');
local imgui = require('mimgui')
local new = imgui.new
local bit = require 'bit'
local messages = {}
local query = {}
local npcquery = {}
local sizeX, sizeY = getScreenResolution()

ffi.cdef[[
    int GetKeyboardLayoutNameA(char* pwszKLID);
    short GetAsyncKeyState(int vKey);
    int VirtualProtect(void* lpAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* lpflOldProtect);
    void* VirtualAlloc(void* lpAddress, unsigned long dwSize, unsigned long  flAllocationType, unsigned long flProtect);
    int VirtualFree(void* lpAddress, unsigned long dwSize, unsigned long dwFreeType);
	
	struct stChatEntry 
	{ 
		uint32_t SystemTime; 
		char szPrefix[28]; 
		char szText[144]; 
		uint8_t unknown[64]; 
		int iType; // 2 - text + prefix, 4 - text (server msg), 8 - text (debug) 
		int clTextColor; 
		int clPrefixColor; // or textOnly colour 
	}__attribute__((packed)); 

	typedef struct stChatInfoMin 
	{ 
		struct stChatEntry chatEntry[100]; 
	} chatInfoMin;
	
	typedef void(__cdecl *CMDPROC)(char *); 
	struct stInputInfo 
	{ 
		void *pD3DDevice; 
		void *pDXUTDialog; 
		struct stInputBox *pDXUTEditBox; 
		CMDPROC pCMDs[144]; 
		char szCMDNames[144][33]; 
		int iCMDCount; 
		int iInputEnabled; 
		char szInputBuffer[129]; 
		char szRecallBufffer[10][129]; 
		char szCurrentBuffer[129]; 
		int iCurrentRecall; 
		int iTotalRecalls; 
		CMDPROC pszDefaultCMD; 
	}__attribute__((packed));
	
	typedef char CHAR;
	typedef CHAR *PCHAR;

	int GetLocaleInfoA(int Locale, int LCType, PCHAR lpLCData, int cchData);
	bool GetKeyboardLayoutNameA(char* pwszKLID);

    typedef int BOOL;
    typedef unsigned int DWORD;
    typedef unsigned int UINT;
    typedef intptr_t HANDLE;
    typedef intptr_t HWND;
    typedef intptr_t HICON;
    typedef intptr_t HINSTANCE;
    typedef struct {int Data[4];} GUID;

    typedef struct {
        DWORD cbSize;
        HWND  hWnd;
        UINT  uID;
        UINT  uFlags;
        UINT  uCallbackMessage;
        HICON hIcon;
        char  szTip[128];
        DWORD dwState;
        DWORD dwStateMask;
        char  szInfo[256];
        union {
            UINT uTimeout;
            UINT uVersion;
        };
        char  szInfoTitle[64];
        DWORD dwInfoFlags;
        GUID  guidItem;
        HICON hBalloonIcon;
        } NOTIFYICONDATAA;

        BOOL Shell_NotifyIconA(
        int dwMessage,
        NOTIFYICONDATAA * lpData
        );
        HICON LoadIconA(
        HINSTANCE hInstance,
        intptr_t IconCode
        );
        BOOL DestroyIcon(
        HICON hIcon
    );
    int __stdcall GetModuleHandleA(const char* lpModuleName);
    typedef short SHORT;
    SHORT __stdcall GetKeyState(int nVirtKey);
]]
do
    local langIdBuffer = ffi.new("char[9]")
    local langTables = {
        ["00000409"] = "EN",
        ["00000419"] = "RU",
        ["00020422"] = "UA"
    }
    
    function getCurrentLanguageName()
        if ffi.C.GetKeyboardLayoutNameA(langIdBuffer) then
            return langTables[ffi.string(langIdBuffer)] or "WTF?"
        end
        return "FUCK!"
    end
end

function isCapsLockActive()
    local state = ffi.C.GetKeyState(0x14)
    return bit.band(state, 0x01) == 1
end

local bit = require 'bit'

local hasWebcore, webcore = pcall(require, 'webcore')
local browser2 = nil
local json = require 'cjson'
local inicfg = require('inicfg')
local chatActive = false

local IniFilename = 'SettingsCEF-CHAT.ini'
local ini = inicfg.load({
    settings = 
    {
        chatfontsize = 15,
        chatsize = 47,
        inputfontsize = 15,
        chatcolor = "rgba(0, 0, 0, 0.5)",
        uved1 = "false",
        uved2 = "false",
        uved3 = "false",
        customemoji = "false",
        fontChat = "Arial",
        fontInput = "Arial",
    }

}, IniFilename)
inicfg.save(ini, IniFilename)

local showSettings = new.bool(false)
local chatSizeVal = new.int(ini.settings.chatsize)
local chatFontSizeVal = new.int(ini.settings.chatfontsize)
local inputFontSizeVal = new.int(ini.settings.inputfontsize)
local uved1Val = new.bool(ini.settings.uved1)
local uved2Val = new.bool(ini.settings.uved2)
local uved3Val = new.bool(ini.settings.uved3)
local customEmojiVal = new.bool(ini.settings.customemoji)
local fontChatVal = new.char[256]()
local fontInputVal = new.char[256]()
ffi.copy(fontChatVal, ini.settings.fontChat)
ffi.copy(fontInputVal, ini.settings.fontInput)
local chatColorVal = imgui.new.float[4](0,0,0,0.5)
local fontList = {'Arial','Arial Black','Calibri','Calibri Light','Cambria','Cambria Math','Candara','Comic Sans MS','Consolas','Constantia','Corbel','Courier New','Ebrima','Franklin Gothic','Gabriola','Georgia','Impact','Leelawadee UI','Lucida Console','Malgun Gothic','Microsoft Sans Serif','Microsoft YaHei','MS Gothic','MV Boli','Palatino Linotype','Segoe UI','Segoe UI Emoji','SimSun','Sitka Text','Sylfaen','Tahoma','Times New Roman','Trebuchet MS','Verdana','Yu Gothic'}
local fontListPtrs = new['const char*'][#fontList](fontList)
local fontChatIdx = new.int(0)
local fontInputIdx = new.int(0)
for i, name in ipairs(fontList) do
    if name == ini.settings.fontChat then fontChatIdx[0] = i - 1 end
    if name == ini.settings.fontInput then fontInputIdx[0] = i - 1 end
end

local WindowsNotificationIcon = {
    None = 0,
    Application = 32512,
    Error = 32513,
    Question = 32514,
    Warning = 32515,
    Information = 32516,
    Security = 32518
}

function showWindowsNotification(iconType, title, text)
    local noIcon = iconType == nil;
    local hInstance = noIcon and ffi.C.GetModuleHandleA(ffi.NULL) or 0;
    local iconType = noIcon and 100 or (iconType or 0);
    local function copy_string(dest_array_ptr, str)
        ffi.copy(dest_array_ptr, (str or ""):sub(1, ffi.sizeof(dest_array_ptr) - 1));
    end

    --// Create tray icon
    local tray_icon_handle = ffi.C.LoadIconA(hInstance, iconType == 0 and 100 or iconType);
    local balloon_icon_handle = ffi.C.LoadIconA(hInstance, iconType);
    local notify_icon_data = ffi.new('NOTIFYICONDATAA');
    notify_icon_data.cbSize = ffi.sizeof(notify_icon_data);
    notify_icon_data.hWnd = ffi.cast('int', readMemory(0x00C8CF88, 4, false));
    notify_icon_data.uFlags = 1 + 2;
    notify_icon_data.hIcon = tray_icon_handle;
    notify_icon_data.uVersion = 4;
    notify_icon_data.hBalloonIcon = balloon_icon_handle;
    shell32.Shell_NotifyIconA(0, notify_icon_data);
    shell32.Shell_NotifyIconA(4, notify_icon_data);

    --// Show notification
    notify_icon_data.uFlags = 1 + 2 + 16;
    notify_icon_data.dwInfoFlags = iconType == 0 and 0 or 4 + 32;
    copy_string(notify_icon_data.szInfoTitle, title);
    copy_string(notify_icon_data.szInfo, text);
    shell32.Shell_NotifyIconA(1, notify_icon_data);
    lua_thread.create(function()
        wait(500);
        --// Remove tray icon and notification
        shell32.Shell_NotifyIconA(2, notify_icon_data);
        ffi.C.DestroyIcon(balloon_icon_handle);
        ffi.C.DestroyIcon(tray_icon_handle);
    end)
end

local hook = {hooks = {}}
addEventHandler('onScriptTerminate', function(scr)
    if scr == script.this then
        for i, hook in ipairs(hook.hooks) do
            if hook.status then
                hook.stop()
            end
        end
    end
end)

local CHAT_VISIBLE_ADDR = 0xCAA65C
ffi.cdef [[
    int __stdcall VirtualProtect(void* lpAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* lpflOldProtect);
]]


local isChatActive = false

function utext(text)
    text = u8:decode(text)
    return text
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

function toggleChat(state)
    if state ~= nil then
        isChatActive = state
    else
        isChatActive = not isChatActive
    end

    if browser2 then
        browser2:set_input(isChatActive)
        browser2:execute_js(string.format("openCloseChat(%s, '%s', '%s')", tostring(isChatActive), tostring(ini.settings.chatcolor), tostring(ini.settings.chatsize)))
        if isChatActive then
            browser2:execute_js(string.format("openCloseChat(true, '%s', '%s');", tostring(ini.settings.chatcolor), tostring(ini.settings.chatsize)))
        else
            browser2:execute_js("document.querySelector('.chatlog[data-chat-id]').scrollTop = document.querySelector('.chatlog[data-chat-id]').scrollHeight")
        end
    end
end

local currentLayout = "RU"
local chatClosed = false
local isProcessing = false

function onWindowMessage(msg, wparam, lparam)
    if msg == 0x0100 then
        if wparam == 0x76 and not isProcessing then
            isProcessing = true
            lua_thread.create(function()
                wait(200)
                chatClosed = not chatClosed
                
                if chatClosed then
                    browser2:execute_js("document.getElementById('chat-input').style.display = 'none';")
                    browser2:execute_js("document.querySelector('.chatlog[data-chat-id]').style.display = 'none';")
                    browser2:execute_js("document.getElementById('lang').style.display = 'none';")
                    browser2:execute_js("document.getElementById('settings').style.display = 'none';")
                else
                    browser2:execute_js("document.querySelector('.chatlog[data-chat-id]').style.display = 'block';")
                    browser2:execute_js("document.getElementById('settings').style.display = 'flex';")
                end
                
                isProcessing = false
            end)
        end
    end
    if not isChatActive then return false end
    
    if msg == 0x0100 then
        local allowedKeys = {
            [0x1B] = true,
            [0x0D] = true,
            [0x75] = true,
            [0x54] = true,
            [0x74] = true,
            [0x08] = true,
            [0x25] = true,
            [0x27] = true,
            [0x26] = true,
            [0x28] = true,
            [0x02] = true,
        }

        if wparam == 0x08 and isChatActive then
            consumeWindowMessage(false, true)
            return false
        end

        local isCtrlPressed = ffi.C.GetAsyncKeyState(0xA2) == -32768
        
        if isCtrlPressed or allowedKeys[wparam] then
            return false
        else
            consumeWindowMessage(true, true)
            return true
        end
    end


    if msg == 0x0051 then
        local langCode = wparam and 0xFFFF
        currentLayout = (langCode == 0x409) and "EN" or "RU"
        
        browser2:execute_js("document.getElementById('lang').textContent = '"..currentLayout.."'")
    end
    
    return false
end
function hook.new(cast, callback, hook_addr, size, trampoline, org_bytes_tramp)
    local size = size or 5
    local trampoline = trampoline or false
    local new_hook, mt = {}, {}
    local detour_addr = tonumber(ffi.cast('intptr_t', ffi.cast('void*', ffi.cast(cast, callback))))
    local void_addr = ffi.cast('void*', hook_addr)
    local old_prot = ffi.new('unsigned long[1]')
    local org_bytes = ffi.new('uint8_t[?]', size)
    ffi.copy(org_bytes, void_addr, size)
    if trampoline then
        local alloc_addr = ffi.gc(ffi.C.VirtualAlloc(nil, size + 5, 0x1000, 0x40), function(addr) ffi.C.VirtualFree(addr, 0, 0x8000) end)
        local trampoline_bytes = ffi.new('uint8_t[?]', size + 5, 0x90)
        if org_bytes_tramp then
            local bytes = {}
            for byte in org_bytes_tramp:gmatch('(%x%x)') do
                table.insert(bytes, tonumber(byte, 16))
            end
            trampoline_bytes = ffi.new('uint8_t[?]', size + 5, bytes)
        else
            ffi.copy(trampoline_bytes, org_bytes, size)
        end
        trampoline_bytes[size] = 0xE9
        ffi.cast('uint32_t*', trampoline_bytes + size + 1)[0] = hook_addr - tonumber(ffi.cast('intptr_t', ffi.cast('void*', ffi.cast(cast, alloc_addr)))) - size
        ffi.copy(alloc_addr, trampoline_bytes, size + 5)
        new_hook.call = ffi.cast(cast, alloc_addr)
        mt = {__call = function(self, ...)
            return self.call(...)
        end}
    else
        new_hook.call = ffi.cast(cast, hook_addr)
        mt = {__call = function(self, ...)
            self.stop()
            local res = self.call(...)
            self.start()
            return res
        end}
    end
    local hook_bytes = ffi.new('uint8_t[?]', size, 0x90)
    hook_bytes[0] = 0xE9
    ffi.cast('uint32_t*', hook_bytes + 1)[0] = detour_addr - hook_addr - 5
    new_hook.status = false
    local function set_status(bool)
        new_hook.status = bool
        ffi.C.VirtualProtect(void_addr, size, 0x40, old_prot)
        ffi.copy(void_addr, bool and hook_bytes or org_bytes, size)
        ffi.C.VirtualProtect(void_addr, size, old_prot[0], old_prot)
    end
    new_hook.stop = function() set_status(false) end
    new_hook.start = function() set_status(true) end
    new_hook.start()
    if org_bytes[0] == 0xE9 or org_bytes[0] == 0xE8 then
        if trampoline then
            print('[WARNING] rewrote another hook (old hook is disabled, through trampoline)')
        else
            print('[WARNING] rewrote another hook')
        end
    end
    table.insert(hook.hooks, new_hook)
    return setmetatable(new_hook, mt)
end

function ARGBtoRGB(color) return bit32 or bit.band(color, 0xFFFFFF) end

function sampChatHook(this, type, text, prefix, color, pcolor)
    local color1 = bit.tohex(ARGBtoRGB(color)):gsub('^00', '')
    local texta = ffi.string(text)
    local shouldHide = false
    
    local myID = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
    local myNick = sampGetPlayerNickname(myID)

    
    if texta:find("@" .. myNick) or texta:find("@" .. myNick:lower()) or texta:find("@" .. myNick:upper()) or texta:find("@" .. myID) or texta:find(myNick .. ",") or texta:find(myNick:lower() .. ",") or texta:find(myNick:upper() .. ",") then
        if ini.settings.uved3 == true then
            showWindowsNotification(WindowsNotificationIcon.Information, u8:decode("Вас упомянули в чате!"), texta)
        end
    end

    if texta:find("@all") or texta:find("@everyone") or texta:find("all,") or texta:find("everyone,") or texta:find("all:") or texta:find("everyone:") then
        if ini.settings.uved3 == true then
            showWindowsNotification(WindowsNotificationIcon.Information, u8:decode("Вас упомянули в чате!"), texta)
        end
    end

    if not shouldHide then
        if type == 2 then
            local prefixcolor = bit.tohex(ARGBtoRGB(pcolor)):gsub('^00', '')
            texta = '{'..prefixcolor..'}'..ffi.string(prefix)..': {'..color1..'}'..texta
        end
        
        table.insert(messages, { 
            text = texta, 
            color = '{'..color1..'}', 
            timestamp = os.date('[%H:%M:%S]') 
        })
        
        -- Отправляем в чат CEF
        sendToCEFChat("{"..color1.."}" .. os.date('[%H:%M:%S]') .. ' ' .. u8:encode(texta))
    end
    
    -- Вызываем оригинальную функцию
    sampChatHook(this, type, text, prefix, color, pcolor)
end

function escapePattern(s)
    return s:gsub("([^%w])", "%%%1")
end

function convertSampColorToHtml(text)
    if type(text) ~= "string" then return "" end
    return text:gsub("{(%x%x%x%x%x%x)}", "#%1")
end

function sendToCEFChat(text)
    if not browser2 then return end
    
    local myID = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
    local myNick = sampGetPlayerNickname(myID)
    
    if convertSampColorToHtml then
        text = convertSampColorToHtml(text)
    end
    
    -- Экранируем спецсимволы для JS
    text = text:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("'", "\\'"):gsub("\r", "\\r"):gsub("\n", "\\n"):gsub("\b", "\\b"):gsub("\f", "\\f")
    
    browser2:execute_js(string.format([[
        try {
            window.myPlayerData = {
                id: %d,
                nick: "%s"
            };
            processIncomingMessage("%s");
        } catch(e) { console.error('CEF Error:', e); }
    ]], myID, myNick:gsub('"', '\\"'), text))
end

function explode_argb(argb)
    return bit.band(bit.rshift(argb, 24), 0xFF),  -- Alpha
           bit.band(bit.rshift(argb, 16), 0xFF),  -- Red
           bit.band(bit.rshift(argb, 8), 0xFF),   -- Green
           bit.band(argb, 0xFF)                    -- Blue
end

local activateChatAddr = getModuleHandle("samp.dll") + 0x64F50

local initDone = false

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

imgui.OnInitialize(function()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local path = getFolderPath(0x14) .. '\\arial.ttf'
    imgui.GetIO().Fonts:Clear()
    imgui.GetIO().Fonts:AddFontFromFileTTF(path, 18.0, nil, glyph_ranges)
    imgui.GetIO().IniFilename = nil

    SoftBlueTheme()
    theme[1].change()
    u32 = imgui.ColorConvertFloat4ToU32
end)

imgui.OnFrame(
    function() return showSettings[0] end,
    function()
        imgui.SetNextWindowSize(imgui.ImVec2(0, 0), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin('Настройки чата', showSettings, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse)

        local blue = imgui.ImVec4(0.29, 0.70, 1.0, 1.0)
        local gray = imgui.ImVec4(0.5, 0.5, 0.5, 1.0)

        imgui.PushStyleColor(imgui.Col.Text, blue)
        imgui.Text('Оформление')
        imgui.PopStyleColor()
        imgui.Separator()
        imgui.Spacing()

        imgui.Text('Цвет чата:')
        imgui.SameLine()
        if imgui.ColorEdit4('##', chatColorVal, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.AlphaBar) then
            local color = join_argb(chatColorVal[3]*255, chatColorVal[0]*255, chatColorVal[1]*255, chatColorVal[2]*255)
            local a, r, g, b = explode_argb(color)
            ini.settings.chatcolor = string.format('rgba(%d, %d, %d, %.2f)', r, g, b, a/255)
            inicfg.save(ini, IniFilename)
            browser2:execute_js(string.format("document.querySelector('.chatlog[data-chat-id]').style.backgroundColor = '%s'", ini.settings.chatcolor))
            browser2:execute_js(string.format("document.getElementById('chat-input').style.backgroundColor = '%s'", ini.settings.chatcolor))
            browser2:execute_js(string.format("document.getElementById('lang').style.backgroundColor = '%s'", ini.settings.chatcolor))
        end
        toggleChat(false)

        imgui.Text('Размер чата')
        imgui.SameLine()
        imgui.PushItemWidth(200)
        if imgui.SliderInt('##chatsize', chatSizeVal, 10, 100, '%d%%') then
            ini.settings.chatsize = chatSizeVal[0]
            inicfg.save(ini, IniFilename)
            browser2:execute_js(string.format("document.querySelectorAll('.chatlog[data-chat-id]').forEach(c=>c.style.width='%d%%')", chatSizeVal[0]))
            
        end
        imgui.PopItemWidth()

        imgui.Text('Шрифт чата')
        imgui.SameLine()
        imgui.PushItemWidth(200)
        if imgui.SliderInt('##chatfontsize', chatFontSizeVal, 11, 20, '%dpx') then
            ini.settings.chatfontsize = chatFontSizeVal[0]
            inicfg.save(ini, IniFilename)
            browser2:execute_js(string.format("document.querySelectorAll('.chatlog[data-chat-id]').forEach(c=>c.style.fontSize='%dpx')", chatFontSizeVal[0]))
        end
        imgui.PopItemWidth()

        imgui.Text('Шрифт ввода')
        imgui.SameLine()
        imgui.PushItemWidth(200)
        if imgui.SliderInt('##inputfontsize', inputFontSizeVal, 11, 20, '%dpx') then
            ini.settings.inputfontsize = inputFontSizeVal[0]
            inicfg.save(ini, IniFilename)
            browser2:execute_js(string.format("document.getElementById('chat-input').style.fontSize='%dpx'", inputFontSizeVal[0]))
        end
        imgui.PopItemWidth()

        imgui.Spacing()
        imgui.PushStyleColor(imgui.Col.Text, blue)
        imgui.Text('Шрифты')
        imgui.PopStyleColor()
        imgui.Separator()
        imgui.Spacing()

        imgui.Text('Шрифт чата')
        imgui.SameLine()
        imgui.PushItemWidth(200)
        if imgui.Combo('##fontChat', fontChatIdx, fontListPtrs, #fontList) then
            local name = fontList[fontChatIdx[0] + 1]
            ini.settings.fontChat = name
            inicfg.save(ini, IniFilename)
            browser2:execute_js(string.format("document.querySelectorAll('.chatlog[data-chat-id]').forEach(c=>c.style.fontFamily='%s')", name))
        end
        imgui.PopItemWidth()

        imgui.Text('Шрифт ввода')
        imgui.SameLine()
        imgui.PushItemWidth(200)
        if imgui.Combo('##fontInput', fontInputIdx, fontListPtrs, #fontList) then
            local name = fontList[fontInputIdx[0] + 1]
            ini.settings.fontInput = name
            inicfg.save(ini, IniFilename)
            browser2:execute_js(string.format("document.querySelector('.chat-input').style.fontFamily='%s, sans-serif'", name))
        end
        imgui.PopItemWidth()

        imgui.Spacing()
        imgui.PushStyleColor(imgui.Col.Text, blue)
        imgui.Text('Уведомления')
        imgui.PopStyleColor()
        imgui.Separator()
        imgui.Spacing()

        if imgui.Checkbox('Уведомления в чате', uved1Val) then
            ini.settings.uved1 = tostring(uved1Val[0])
            browser2:execute_js(string.format("uvedChat = %s", tostring(ini.settings.uved1)))
            inicfg.save(ini, IniFilename)
        end
        if imgui.Checkbox('Уведомления звуком', uved2Val) then
            ini.settings.uved2 = tostring(uved2Val[0])
            browser2:execute_js(string.format("uvedSound = %s", tostring(ini.settings.uved2)))
            inicfg.save(ini, IniFilename)
        end
        if imgui.Checkbox('Уведомления Windows', uved3Val) then
            ini.settings.uved3 = tostring(uved3Val[0])
            browser2:execute_js(string.format("uvedWindows = %s", tostring(ini.settings.uved3)))
            inicfg.save(ini, IniFilename)
        end
       
        imgui.Spacing()
        imgui.PushStyleColor(imgui.Col.Text, blue)
        imgui.Text('Дополнительно')
        imgui.PopStyleColor()
        imgui.Separator()
        imgui.Spacing()

        if imgui.Checkbox('Кастомные эмодзи', customEmojiVal) then
            ini.settings.customemoji = tostring(customEmojiVal[0])
            browser2:execute_js(string.format("toggleCustomEmoji = %s", tostring(ini.settings.customemoji)))
            inicfg.save(ini, IniFilename)
        end

        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()
        imgui.TextColored(gray, '/cefchat - открыть/закрыть настройки')

        imgui.End()
    end
)

imgui.OnFrame(
    function() return true end,
    function(this)
        if not initDone and hasWebcore and webcore.inited() then
            initDone = true

            browser2 = webcore:create_fullscreen("file:///moonloader/cef/chat/chat.html")
            pcall(function() browser2:set_offscreen(true) end)
            pcall(function() browser2:set_input(false) end)

            browser2:set_create_cb(
                function (_)
                    browser2:add_function("sendMessage", function(_, name, args)
                        sampProcessChatInput(u8:decode(args[1]))
                    end)
                    browser2:add_function("sendLog", function(_, name, args)
                        print(u8:decode(args[1] or nil))
                    end)
            end)

            browser2:set_loading_cb(function(_, status)
                if status == 0 then
                    print("CEF-CHAT: Loaded")
                    browser2:execute_js(string.format("document.getElementById('chat-input').style.fontSize = '%dpx'", ini.settings.inputfontsize))
                    browser2:execute_js(string.format("document.getElementById('chat-input').style.width = '%s%%'", ini.settings.chatsize))
                    browser2:execute_js(string.format("uvedChat = %s", tostring(ini.settings.uved1)))
                    browser2:execute_js(string.format("uvedSound = %s", tostring(ini.settings.uved2)))
                    browser2:execute_js(string.format("uvedWindows = %s", tostring(ini.settings.uved3)))
                    browser2:execute_js(string.format("toggleCustomEmoji = %s", tostring(ini.settings.customemoji)))
                    browser2:execute_js(string.format([[
                        document.querySelectorAll('.chatlog[data-chat-id]').forEach(chat => {
                            chat.style.fontFamily = '%s';
                            chat.style.fontSize = '%spx';
                            chat.style.width = '%s%%';
                        });
                    ]], ini.settings.fontChat, ini.settings.chatfontsize, ini.settings.chatsize))
                    browser2:execute_js(string.format("document.querySelector('.chat-input').style.fontFamily = '%s, sans-serif'", ini.settings.fontInput))
                    browser2:execute_js(string.format([[
                        document.querySelector('.chat-input').style.backgroundColor = '%s';
                    ]], ini.settings.chatcolor))
                    browser2:execute_js(string.format([[
                        document.querySelector('.input-language').style.backgroundColor = '%s';
                    ]], ini.settings.chatcolor))
                    browser2:execute_js(string.format([[
                        document.querySelector('.calculation-result').style.backgroundColor = '%s';
                    ]], ini.settings.chatcolor))

                    browser2:execute_js([[document.querySelectorAll('.chatlog[data-chat-id]').forEach(chat => {
                        chat.scrollTop = chat.scrollHeight;
                    });]]);

                    browser2:execute_js("document.getElementById('lang').style.display = 'none';")

                    browser2:execute_js("document.querySelector('.chatlog[data-chat-id]').scrollTop = document.querySelector('.chatlog[data-chat-id]').scrollHeight")
                end
            end)
        end

        if not browser2 then return end
        this.HideCursor = true
        local BGDL = imgui.GetBackgroundDrawList()
        local texRaw = browser2:get_texture()
        local tex = texRaw and ffi.cast('void*', texRaw)
        if not tex then return end
        BGDL:AddImage(
            tex,
            imgui.ImVec2(0, 0),
            imgui.ImVec2(sizeX, sizeY),
            imgui.ImVec2(0, 0),
            imgui.ImVec2(1, 1),
            imgui.GetColorU32Vec4(imgui.ImVec4(1, 1, 1, 1))
        )
    end
)

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end  -- Скрываем вывод сообщений SAMP

    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("cefchat", function()
        showSettings[0] = not showSettings[0]
    end)

    sampRegisterChatCommand("testscroll", function()
            for i = 1, 500 do
                sendToCEFChat("scroll")
            end
                sendToCEFChat("[SUCCESS]: scroll500")
            
    end)

    local chatEntry = ffi.cast('chatInfoMin*', sampGetChatInfoPtr() + 306).chatEntry
	pInput = ffi.cast('struct stInputInfo*', sampGetInputInfoPtr())[0]
	for i = 0, 99 do
		if chatEntry[i].clTextColor ~= 0 and chatEntry[i].szText ~= '' then
			local color = bit.tohex(ARGBtoRGB(chatEntry[i].clTextColor)):gsub('^00', '')
			local text = ffi.string(chatEntry[i].szText)
			if chatEntry[i].iType == 2 then
				local prefixcolor = bit.tohex(ARGBtoRGB(chatEntry[i].clPrefixColor)):gsub('^00', '')
				text = '{'..prefixcolor..'}'..ffi.string(chatEntry[i].szPrefix)..' {'..color..'}'..text
			end
			table.insert(messages, { text = u8(text), color = '{'..color..'}', timestamp = os.date('[%H:%M:%S]', chatEntry[i].SystemTime) })
		end
	end
    sampChatHook = hook.new('void(__thiscall *)(void *this, uint32_t type, const char* text, const char* prefix, uint32_t color, uint32_t pcolor)', sampChatHook, getModuleHandle('samp.dll') + 0x64010, 5, false, '55 56 8B E9 57')
    memory.setuint8(sampGetBase() + 0x71480, 0xEB, true)

    local sampBase = getModuleHandle('samp.dll')
    if sampBase == 0 then return end

    -- Правильный адрес функции CChat::Activate
    local activateChatAddr = sampBase + 0x657E0

    -- Хук на функцию активации чата
    hook.new(
        'void(__thiscall *)(void* this)',
        function(this)
            -- Не вызываем оригинальную функцию — тем самым блокируем открытие чата
        end,
        activateChatAddr,
        5 -- размер JMP инструкции
    )

    if not hasWebcore then
        return
    end

    while not webcore.inited() do wait(100) end

    while true do
        if browser2 then
            browser2:set_active(true)
            if not isSampfuncsConsoleActive() and not isPauseMenuActive() then
                if (isKeyJustPressed(0x75) or isKeyJustPressed(0x54)) and not chatClosed and not sampIsDialogActive() and not isPauseMenuActive() then
                    toggleChat(true)
                end

                if isChatActive and isKeyJustPressed(0x1B) and not isPauseMenuActive() then
                    toggleChat(false)
                end

                if isChatActive and isKeyJustPressed(0x0D) and not isPauseMenuActive() then
                    toggleChat(false)
                end

                if isCapsLockActive() then
                    browser2:execute_js(string.format("document.getElementById('lang').textContent = '%s'", getCurrentLanguageName():upper()))
                else
                    browser2:execute_js(string.format("document.getElementById('lang').textContent = '%s'", getCurrentLanguageName():lower()))
                end
            
            end
        end
        
        wait(0)
    end
end
addEventHandler('onWindowMessage', onWindowMessage)

function onScriptTerminate(s, q)
    if s == thisScript() then
        webcore:close(browser2)
            browser2 = nil
    end
end


function SoftBlueTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    style.WindowPadding      = imgui.ImVec2(16, 16)
    style.WindowRounding     = 20.0
    style.ChildRounding      = 4.0
    style.FramePadding       = imgui.ImVec2(12, 8)
    style.FrameRounding      = 10.0
    style.ItemSpacing        = imgui.ImVec2(8, 12)
    style.ItemInnerSpacing   = imgui.ImVec2(8, 8)
    style.IndentSpacing      = 22.0
    style.ScrollbarSize      = 12.0
    style.ScrollbarRounding  = 4.0
    style.GrabMinSize        = 12.0
    style.GrabRounding       = 6.0
    style.PopupRounding      = 10.0
    style.WindowTitleAlign   = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign    = imgui.ImVec2(0.5, 0.5)
    style.TabRounding        = 4.0
    style.ChildBorderSize    = 1.0
    style.FrameBorderSize    = 2.0
    style.WindowBorderSize   = 5.0
end

theme = {
    {
        change = function()
            local ImVec4 = imgui.ImVec4
            imgui.SwitchContext()
            imgui.GetStyle().Colors[imgui.Col.Text]                   = ImVec4(0.93, 0.93, 0.93, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = ImVec4(0.62, 0.62, 0.62, 1.00)
            imgui.GetStyle().Colors[imgui.Col.WindowBg]               = ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ChildBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PopupBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Border]                 = ImVec4(0.40, 0.40, 0.40, 1.00)
            imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = ImVec4(0.20, 0.20, 0.20, 0.85)
            imgui.GetStyle().Colors[imgui.Col.TitleBg]                = ImVec4(0.25, 0.25, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.25, 0.25, 0.25, 0.75)
            imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = ImVec4(0.25, 0.25, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Button]                 = ImVec4(0.25, 0.25, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = ImVec4(0.40, 0.40, 0.40, 1.00)
            imgui.GetStyle().Colors[imgui.Col.CheckMark]              = ImVec4(0.80, 0.80, 0.80, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = ImVec4(0.20, 0.60, 0.86, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = ImVec4(0.40, 0.73, 0.93, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Header]                 = ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = ImVec4(0.30, 0.30, 0.30, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = ImVec4(0.50, 0.50, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Tab]                    = ImVec4(0.15, 0.15, 0.15, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabHovered]             = ImVec4(0.30, 0.30, 0.30, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabActive]              = ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Separator]              = ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = ImVec4(0.40, 0.73, 0.93, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = ImVec4(0.10, 0.10, 0.10, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = ImVec4(0.30, 0.30, 0.30, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(0.40, 0.40, 0.40, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = ImVec4(0.40, 0.40, 0.40, 0.35)
            imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = ImVec4(0.12, 0.12, 0.12, 0.75)
        end
    }
}

