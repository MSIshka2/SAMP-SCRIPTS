local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
cp = encoding.CP1251

local sampev = require 'lib.samp.events'
local bit = require 'bit'

local imgui = require('mimgui')
local ffi = require 'ffi'
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
ffi.cdef[[
    typedef unsigned long DWORD;
    typedef wchar_t* LPWSTR;
    typedef const wchar_t* LPCWSTR;
    typedef char* LPSTR;
    typedef const char* LPCSTR;
    typedef int BOOL;

    int MultiByteToWideChar(unsigned int CodePage, DWORD dwFlags, const char* lpMultiByteStr, int cbMultiByte, LPWSTR lpWideCharStr, int cchWideChar);
    int WideCharToMultiByte(unsigned int CodePage, DWORD dwFlags, LPCWSTR lpWideCharStr, int cchWideChar, LPSTR lpMultiByteStr, int cbMultiByte, LPCSTR lpDefaultChar, BOOL* lpUsedDefaultChar);
]]

local menuChatBubble = new.bool(false)

local inicfg = require('inicfg')
local IniFilename = 'SettingsCEF-CHATBUBBLES.ini'
local ini = inicfg.load({
    settings = {
        enabled = true,
        max_distance = 50,
        slot_w = 0,
        slot_h = 0,
        local_bubbles = true,
        local_bubble_type = 0,
        visual_style = 0,
        show3dtext = true,
    }
}, IniFilename)

local isEnabled = new.bool(ini.settings.enabled)
local maxDist = new.int(ini.settings.max_distance)
local localBubbles = new.bool(ini.settings.local_bubbles)
local localBubbleType = new.int(ini.settings.local_bubble_type)
local visualStyle = new.int(ini.settings.visual_style)
local show3dtext = new.bool(ini.settings.show3dtext)
local bubbleStyles = {'По умолчанию', 'Минимальный', 'С фоном', 'С фоном 2', 'С фоном 3', 'С фоном 4', 'Динамический фон'}
local stylePtrs = new['const char*'][#bubbleStyles](bubbleStyles)

local lastAppliedStyle = nil
local cssInput = new.char[8192]()
local cssStylePreview = new.int(0)
local customCssDir = getWorkingDirectory() .. "\\chatbubbles\\"

function getCustomCssPath(idx)
    return customCssDir .. "custom_" .. idx .. ".css"
end

function loadCustomCss(idx)
    local f = io.open(getCustomCssPath(idx), "r")
    if f then local c = f:read("*a"); f:close(); return c end
    return nil
end

function saveCustomCss(idx, css)
    local f = io.open(getCustomCssPath(idx), "w")
    if f then f:write(css); f:close() end
end

function deleteCustomCss(idx)
    os.remove(getCustomCssPath(idx))
end

function cp1251_to_utf8(str)
    local u8len = ffi.C.WideCharToMultiByte(65001, 0, wbuf, -1, nil, 0, nil, nil)
    if u8len <= 0 then return str end
    local u8buf = ffi.new("char[?]", u8len)
    ffi.C.WideCharToMultiByte(65001, 0, wbuf, -1, u8buf, u8len, nil, nil)
    return ffi.string(u8buf)
end

function utf16_to_cp1251(wstr)
    local len = ffi.C.WideCharToMultiByte(1251, 0, wstr, -1, nil, 0, nil, nil)
    local buf = ffi.new("char[?]", len)
    ffi.C.WideCharToMultiByte(1251, 0, wstr, -1, buf, len, nil, nil)
    return ffi.string(buf)
end


local query = {}
local hasWebcore, webcore = pcall(require, 'webcore')
local browser = nil

local BUBBLE_SLOT_COUNT = 30
local BUBBLE_SLOT_W = nil
local BUBBLE_SLOT_H = nil
local BUBBLE_SLOT_GAP = nil
local BUBBLE_OFFSET_X = 0

local slotOwner = {}
local playerSlot = {}
local slotDirty = {}
local lastRenderedText = {}
local player3dTexts = {}
local saved3dTexts = {}
local initDone = false

for i = 0, BUBBLE_SLOT_COUNT - 1 do slotOwner[i] = nil end

function escapeText(s)
    s = s:gsub("\\", "\\\\"):gsub("'", "\\'"):gsub('"', '\\"'):gsub("\r", "\\r"):gsub("\n", "\\n")
    s = s:gsub("\b", "\\b"):gsub("\f", "\\f")
    return s
end

function allocSlot(playerId)
    if playerSlot[playerId] then
        slotDirty[playerSlot[playerId]] = true
        return playerSlot[playerId]
    end
    for i = 0, BUBBLE_SLOT_COUNT - 1 do
        if not slotOwner[i] then
            slotOwner[i] = playerId
            playerSlot[playerId] = i
            slotDirty[i] = true
            return i
        end
    end
    return nil
end

function freeSlot(playerId)
    local slotId = playerSlot[playerId]
    if slotId then
        slotOwner[slotId] = nil
        playerSlot[playerId] = nil
        slotDirty[slotId] = true
        lastRenderedText[slotId] = nil
        if browser then
            browser:execute_js(string.format("__bubbleClear(%d)", slotId))
        end
    end
end

function explode_argb(argb)
    return bit.band(bit.rshift(argb, 24), 0xFF),
           bit.band(bit.rshift(argb, 16), 0xFF),
           bit.band(bit.rshift(argb, 8), 0xFF),
           bit.band(argb, 0xFF)
end

function getContrastColor(r, g, b)
    local luminance = 0.299 * r + 0.587 * g + 0.114 * b
    if luminance > 128 then
        return 0, 0, 0
    else
        return 255, 255, 255
    end
end

local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
function getBodyPartCoordinates(id, handle)
    local pedptr = getCharPointer(handle)
    local vec = ffi.new("float[3]")
    getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
    return vec[0], vec[1], vec[2]
end

function getRealCameraCoordinates()
    local CCamera = ffi.cast("float*", 0xB6F028)
    return CCamera[0x20F], CCamera[0x210], CCamera[0x211]
end

function wallPlayer(handle, distance)
    if doesCharExist(handle) then
        local camX, camY, camZ = getRealCameraCoordinates()
        local x, y, z = getCharCoordinates(handle)
        local maxDistance = ini.settings.max_distance
        local withinDistance = getDistanceBetweenCoords3d(camX, camY, camZ, x, y, z) <= maxDistance
        if not (withinDistance and isCharOnScreen(handle)) then
            return false
        end
        return isLineOfSightClear(camX, camY, camZ, x, y, z, true, false, false, true, false)
    end
end

function calcFadeAlpha(elapsed, duration)
    local fadeTime = 0.3
    local alpha
    if elapsed < fadeTime then
        alpha = elapsed / fadeTime
    elseif elapsed > duration - fadeTime then
        alpha = (duration - elapsed) / fadeTime
    else
        alpha = 1.0
    end
    return math.max(0, math.min(1, alpha))
end

function initBubbleCEF()
    local slotStep = BUBBLE_SLOT_H + BUBBLE_SLOT_GAP
    browser:execute_js(string.format(
        "window.__bubbleSlotStep=%d;window.__bubbleSlotW=%d;",
        slotStep, BUBBLE_SLOT_W
    ))
    browser:execute_js([=[

        const emojiReverseMap = {
            "😀": ":D",
            "😁": ":U-2:",
            "😄": ":U-3:",
            "😆": ":U-4:",
            "😂": "xd",
            "🤣": "xdd",
            "😉": ":U-7:",
            "😊": ":U-8:",
            "😋": ":U-9:",
            "😎": ":U-10:",
            "😍": ":U-11:",
            "🥰": ":U-12:",
            "😘": ":U-13:",
            "🙂": ":)",
            "😙": ":U-15:",
            "🤗": ":U-16:",
            "🤩": ":U-17:",
            "🤔": ":U-18:",
            "🤨": ":U-19:",
            "😐": ":U-20:",
            "😑": ":U-21:",
            "😶": ":U-22:",
            "🙄": ":U-23:",
            "😏": ":U-24:",
            "😣": ":U-25:",
            "😮": ":U-26:",
            "😥": ":U-27:",
            "🤐": ":U-28:",
            "😪": ":U-29:",
            "🥱": ":U-30:",
            "😴": ":U-31:",
            "😛": ":U-32:",
            "😒": ":(",
            "🙃": ":U-34:",
            "🤑": ":U-35:",
            "😖": ":U-36:",
            "😤": ":U-37:",
            "😢": ":U-38:",
            "😭": ":U-39:",
            "🤯": ":U-40:",
            "😱": ":U-41:",
            "🥵": ":U-42:",
            "🥶": ":U-43:",
            "🤪": ":U-44:",
            "😵": ":U-45:",
            "😠": ":U-46:",
            "🤬": ":U-47:",
            "🤢": ":U-48:",
            "🤮": ":U-49:",
            "😇": ":U-50:",
            "🥳": ":U-51:",
            "🥺": ":U-52:",
            "🤠": ":U-53:",
            "🤡": ":U-54:",
            "🧐": ":U-55:",
            "🤓": ":U-56:",
            "😈": ":U-57:",
            "👿": ":U-58:",
            "💀": ":U-59:",
            "☠️": ":U-60:",
            "🌚": ":U-61:",
            "🌞": ":U-62:",
            "💩": ":U-63:",
            "👽": ":U-64:",
            "🐵": ":U-65:",
            "🐹": ":U-66:",
            "🐔": ":U-67:",
            "🐷": ":U-68:",
            "🐘": ":U-69:",
            "🐓": ":U-70:",
            "🐞": ":U-71:",
            "🖕": ":U-72:",
            "👍": ":U-73:",
            "👎": ":U-74:",
            "🤘": ":U-75:",
            "🤙": ":U-76:",
            "👋": ":U-77:",
            "👌": ":U-78:",
            "👉": ":U-79:",
            "👈": ":U-80:",
            "❤️": ":U-81:",
            "🔥": ":U-82:",
            "✅": ":U-83:",
            "❌": ":U-84:",
            "⚡": ":U-85:",
            "💥": ":U-86:",
            "♿": ":U-87:",
            "0️⃣": ":U-88:",
            "1️⃣": ":U-89:",
            "2️⃣": ":U-90:",
            "3️⃣": ":U-91:",
            "4️⃣": ":U-92:",
            "5️⃣": ":U-93:",
            "6️⃣": ":U-94:",
            "7️⃣": ":U-95:",
            "8️⃣": ":U-96:",
            "9️⃣": ":U-97:",
            "🔟": ":U-98:",
            "⭐": ":U-99:",
            "🌟": ":U-100:",
            "✨": ":U-101:",
            "🎉": ":U-102:",
            "🎊": ":U-103:",
            "🎈": ":U-104:",
            "🎁": ":U-105:",
            "💫": ":U-106:",
            "💥": ":U-107:",
            "🍕": ":U-108:",
            "🍔": ":U-109:",
            "🍟": ":U-110:",
            "🌭": ":U-111:",
            "🍿": ":U-112:",
            "🍩": ":U-113:",
            "🍪": ":U-114:",
            "🎂": ":U-115:",
            "☕": ":U-116:",
            "🍺": ":U-117:",
            "🍻": ":U-118:",
            "🍷": ":U-119:",
            "🥂": ":U-120:",
            "🍾": ":U-121:",
            "⚽": ":U-122:",
            "🏀": ":U-123:",
            "🏈": ":U-124:",
            "⚾": ":U-125:",
            "🎾": ":U-126:",
            "🏐": ":U-127:",
            "🏓": ":U-128:",
            "🎮": ":U-129:",
            "🕹️": ":U-130:",
            "🎲": ":U-131:",
            "🚗": ":U-132:",
            "🚕": ":U-133:",
            "🚓": ":U-134:",
            "🚑": ":U-135:",
            "🚒": ":U-136:",
            "🚜": ":U-137:",
            "🏍️": ":U-138:",
            "✈️": ":U-139:",
            "🚀": ":U-140:",
            "🛸": ":U-141:",
            "🏠": ":U-142:",
            "🏢": ":U-143:",
            "🏦": ":U-144:",
            "🏥": ":U-145:",
            "🏪": ":U-146:",
            "🏫": ":U-147:",
            "🏭": ":U-148:",
            "📱": ":U-149:",
            "💻": ":U-150:",
            "🖥️": ":U-151:",
            "⌨️": ":U-152:",
            "🖱️": ":U-153:",
            "💾": ":U-154:",
            "💿": ":U-155:",
            "📀": ":U-156:",
            "🔒": ":U-157:",
            "🔓": ":U-158:",
            "🔑": ":U-159:",
            "🗝️": ":U-160:",
            "⚙️": ":U-161:",
            "🛠️": ":U-162:",
            "🔧": ":U-163:",
            "🔨": ":U-164:",
            "📌": ":U-165:",
            "📎": ":U-166:",
            "✂️": ":U-167:",
            "📏": ":U-168:",
            "📝": ":U-169:",
            "📖": ":U-170:",
            "📚": ":U-171:",
            "💡": ":U-172:",
            "🔔": ":U-173:",
            "📢": ":U-174:",
            "📣": ":U-175:",
            "🔊": ":U-176:",
            "🔇": ":U-177:",
            "⏰": ":U-178:",
            "⏳": ":U-179:",
            "⌛": ":U-180:",
            "📅": ":U-181:",
            "📆": ":U-182:",
            "🟢": ":U-183:",
            "🔴": ":U-184:",
            "🟡": ":U-185:",
            "🔵": ":U-186:",
            "⚫": ":U-187:",
            "⚪": ":U-188:",
            "🟣": ":U-189:",
            "🟠": ":U-190:",
            "🟤": ":U-191:",
            "<img src='https://openmoji.org/data/color/svg/E068.svg' style='height: 30px; position: relative; top: 7px;'>": ":js:", // javascript emoji
            "<img src='https://openmoji.org/data/color/svg/E062.svg' style='height: 30px; position: relative; top: 7px;'>": ":C-code:", // C emoji
            "<img src='https://openmoji.org/data/color/svg/E063.svg' style='height: 30px; position: relative; top: 7px;'>": ":C++:", // C++ emoji
            "<img src='https://openmoji.org/data/color/svg/E064.svg' style='height: 30px; position: relative; top: 7px;'>": ":C#:", // C# emoji
            "<img src='https://openmoji.org/data/color/svg/E0FF.svg' style='height: 30px; position: relative; top: 7px;'>": ":ubuntu:", // Ubuntu emoji
            "<img src='https://openmoji.org/data/color/svg/F000.svg' style='height: 30px; position: relative; top: 7px;'>": ":windows:", // Windows emoji
            "<img src='https://openmoji.org/data/color/svg/E061.svg' style='height: 35px; position: relative; top: 7px;'>": ":discord:", // discord emoji
            "<img src='https://cdn-icons-png.flaticon.com/128/2111/2111646.png' style='height: 25px; position: relative; top: 3px;'>": ":telegram:", // telegram emoji
            "<img src='https://cdn-icons-png.flaticon.com/128/5968/5968835.png' style='height: 25px; position: relative; top: 3px;'>": ":vk:", // vk emoji
            "<img src='https://openmoji.org/data/color/svg/E040.svg' style='height: 30px; position: relative; top: 7px;'>": ":twitter:", // Twitter emoji
            "<img src='https://openmoji.org/data/color/svg/E042.svg' style='height: 30px; position: relative; top: 7px;'>": ":facebook:", // Facebook emoji
            "<img src='https://openmoji.org/data/color/svg/E044.svg' style='height: 30px; position: relative; top: 7px;'>": ":youtube:", // Youtube emoji
            "<img src='https://cdn-icons-png.flaticon.com/128/3046/3046121.png' style='height: 30px; position: relative; top: 3px;'>": ":TikTok:", // TikTok emoji
            "<img src='https://openmoji.org/data/color/svg/E045.svg' style='height: 30px; position: relative; top: 7px;'>": ":github:", // Github emoji
            "<img src='https://openmoji.org/data/color/svg/E054.svg' style='height: 30px; position: relative; top: 7px;'>": ":chrome:", // Chrome emoji
            "<img src='https://www.blast.hk/styles/io_dark/images/blasthack/logo_b_new.png' style='height: 30px; position: relative; top: 3px;'>": ":blasthack:", // blasthack emoji
            "<img src='https://cdn-icons-png.flaticon.com/128/588/588314.png' style='height: 30px; position: relative; top: 3px;'>": ":GTA:", // GTA emoji
            "<img src='https://data.chpic.su/stickers/g/gtasaweaponpack/gtasaweaponpack_001.webp?v=1708442103' style='height: 30px; position: relative; top: 3px;'>": ":deagle:", // Deagle emoji
            "<img src='https://data.chpic.su/stickers/g/gtasaweaponpack/gtasaweaponpack_002.webp?v=1708442103' style='height: 30px; position: relative; top: 3px;'>": ":AK47:", // AK47 emoji
            "<img src='https://data.chpic.su/stickers/g/gtasaweaponpack/gtasaweaponpack_027.webp?v=1708442103' style='height: 30px; position: relative; top: 3px;'>": ":M4:", // M4 emoji
            "<img src='https://data.chpic.su/stickers/g/gtasaweaponpack/gtasaweaponpack_004.webp?v=1708442103' style='height: 30px; position: relative; top: 3px;'>": ":ShotGun:", // ShotGun emoji
            "<img src='https://data.chpic.su/stickers/g/gtasaweaponpack/gtasaweaponpack_029.webp?v=1708442103' style='height: 30px; position: relative; top: 3px;'>": ":MiniGun:", // MiniGun emoji
            "<img src='https://cdn3.emoji.gg/emojis/65458-minecraft.png' style='height: 30px; position: relative; top: 3px;'>": ":minecraft:", // MinecraftHeart emoji
            "<img src='https://cdn3.emoji.gg/emojis/85500-minecraftheart.png' style='height: 30px; position: relative; top: 3px;'>": ":mineheart:", // MinecraftHeart emoji
            "<img src='https://cdn3.emoji.gg/emojis/16469-diamond.png' style='height: 30px; position: relative; top: 3px;'>": ":diamond:", // MinecraftDiamond emoji
            "<img src='https://cdn3.emoji.gg/emojis/64587-jeb-spinning.gif' style='height: 30px; position: relative; top: 3px;'>": ":jeb-spinning:", // MinecraftJeb-Spinn emoji
            "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/100997/emodzi-mcbeespin.gif' style='height: 30px; position: relative; top: 3px;'>": ":mcbeespin:", // Minecraftmcbeespin emoji
            "<img src='https://cdn3.emoji.gg/emojis/21980-dance.gif' style='height: 30px; position: relative; top: 3px;'>": ":parrot-dance:", // MinecraftParrot-Dance emoji
            "<img src='https://cdn3.emoji.gg/emojis/77742-pet-the-frog.gif' style='height: 30px; position: relative; top: 3px;'>": ":pet-the-frog:", // MinecraftPet-The-Frog emoji
            "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/105091/emodzi-banned_sign_ban_hammer_bean.gif' style='height: 50px; position: relative; top: 3px;'>": ":ban:", // ban emoji
            "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/106775/emodzi-poopparrot.gif' style='height: 50px; position: relative; top: 3px;'>": ":pparrot:", // poopparrot emoji
            "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/106775/emodzi-middleparrot.gif' style='height: 50px; position: relative; top: 3px;'>": ":mparrot:", // middleparrot emoji
            "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/106022/emodzi-peepo-toxic.gif' style='height: 50px; position: relative; top: 3px;'>": ":pepetoxic:", // pepetoxic emoji
            "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/100526/emodzi-fingerme.gif' style='height: 50px; position: relative; top: 3px;'>": ":fingerme:", // fingerme emoji
            "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/106261/emodzi-pepe-nopes.gif' style='height: 50px; position: relative; top: 3px;'>": ":pepe-nopes:", // pepe-nopes emoji
            "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/106261/emodzi-peepocoffeehiss.gif' style='height: 50px; position: relative; top: 3px;'>": ":pcoffee:", // peepocoffeehiss emoji
            "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/104874/emodzi-pixel-void.gif' style='height: 50px; position: relative; top: 3px;'>": ":pixel-void:", // peepocoffeehiss emoji
            "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/105903/emodzi-bonk.webp' style='height: 50px; position: relative; top: 3px;'>": ":bonk:", // peepocoffeehiss emoji
            "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/107067/emodzi-verified_blue.gif' style='height: 30px; position: relative; top: 3px;'>": ":verify:", // peepocoffeehiss emoji
            "<img src='https://emojiwiki.ru/wp-content/uploads/2021/11/101461/emodzi-yb-angry2.webp' style='height: 50px; position: relative; top: 3px;'>": ":ya-te-blya:", // peepocoffeehiss emoji

        };

        const textToEmojiMap = {};
        for (const emoji in emojiReverseMap) {
            textToEmojiMap[emojiReverseMap[emoji]] = emoji;
        }

        function replaceEmojisWithText(text) {
            text = text.normalize('NFC');
            for (const emoji in emojiReverseMap) {
                const regex = new RegExp(emoji.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, '\\$1'), 'g');
                text = text.replace(regex, emojiReverseMap[emoji]);
            }
            return text;
        }

        const sortedEmojiKeys = Object.keys(textToEmojiMap).sort((a, b) => b.length - a.length);
        const emojiRegexPattern = sortedEmojiKeys
            .map(k => k.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'))
            .join('|');
        const emojiRegex = new RegExp(emojiRegexPattern, 'g');

        function replaceTextWithEmojis(text) {
            const customEmojiRegex = /:([A-Za-z0-9_-]{10,}):/g;
            text = text.replace(customEmojiRegex, (match, base64Code) => {
                const fullCode = `:${base64Code}:`;
                const emojiData = decodeEmojiData(fullCode);
                if (emojiData && emojiData.u) {
                    return `<img src="${emojiData.u}" style="height: ${emojiData.s}; position: relative; top: 3px;">`;
                }
                return textToEmojiMap[fullCode] || match;
            });

            // 2. Используем ОДИН regex для всех эмодзи вместо цикла
            return text.replace(emojiRegex, match =>
                `<span class="unicode-emoji" style="font-size: 24px">${textToEmojiMap[match]}</span>`
            );
        }

        function encodeEmojiData(url, size) {
            // Максимальное сжатие
            const cleanUrl = url
                .replace(/^https?:\/\//, '')
                .replace(/^www\./, '');
            const cleanSize = size.replace('px', '');
            
            // Формат: размер:url (самый компактный разделитель)
            const dataString = `${cleanSize}:${cleanUrl}`;
            
            // Самый короткий Base64
            return `:${btoa(dataString)
                .replace(/\+/g, '')
                .replace(/\//g, '')
                .replace(/=/g, '')}:`;
        }

        function decodeEmojiData(emojiId) {
            try {
                const base64 = emojiId.slice(1, -1);
                const paddedBase64 = base64 + '='.repeat((4 - base64.length % 4) % 4);
                const dataString = atob(paddedBase64);
                
                const colonIndex = dataString.indexOf(':');
                const size = dataString.substring(0, colonIndex);
                const url = dataString.substring(colonIndex + 1);
                
                return {
                    u: 'https://' + url,
                    s: size + 'px'
                };
            } catch (e) {
                return null;
            }
        }

        if (!window.__bubbleCtx) {
            var container = document.getElementById('bubbles-container');
            if (!container) {
                container = document.createElement('div');
                container.id = 'bubbles-container';
            }
            container.style.cssText = 'position:fixed;left:0;top:0;width:0;height:0;overflow:visible;pointer-events:none;';
            document.body.appendChild(container);
            var styleNode = document.createElement('style');
            styleNode.innerHTML = `
                .typing-dots {
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    gap: 4px;
                    height: 20px; /* Фиксируем высоту, чтобы бабл не трясся */
                }
                .typing-dots span {
                    display: inline-block;
                    width: 6px;
                    height: 6px;
                    background-color: currentColor; /* Примет цвет текста, который вы передали из Lua */
                    border-radius: 50%;
                    animation: waveBounce 1.3s infinite ease-in-out;
                }
                .typing-dots span:nth-child(2) { animation-delay: -1.1s; }
                .typing-dots span:nth-child(3) { animation-delay: -0.9s; }

                @keyframes waveBounce {
                    0%, 60%, 100% { transform: translateY(0); }
                    30% { transform: translateY(-6px); } /* Прыжок вверх */
                }
            `;
            document.head.appendChild(styleNode);
            window.__bubbleCtx = { container: container, slots: {} };
        }
        window.__bubbleUpdate = function(slot, text, r, g, b, bgR, bgG, bgB) {
            var ctx = window.__bubbleCtx;
            var wrapper = ctx.slots[slot];
            if (!wrapper) {
                wrapper = document.createElement('div');
                wrapper.className = 'bubble-wrapper';
                wrapper.style.cssText = 'position:absolute;left:0;top:' + (slot * window.__bubbleSlotStep) + 'px;width:' + window.__bubbleSlotW + 'px;text-align:center;transform:none;white-space:pre-wrap;word-break:break-word;line-height: 1.45;';
                ctx.container.appendChild(wrapper);
                ctx.slots[slot] = wrapper;
            }
            var msgDiv = wrapper.querySelector('.bubble-message');
            if (!msgDiv) {
                msgDiv = document.createElement('div');
                msgDiv.className = 'bubble-message';
                wrapper.appendChild(msgDiv);
            }
            msgDiv.style.display = 'inline-block';
            msgDiv.style.textAlign = 'center';
            msgDiv.style.fontFamily = 'Arial, Segoe UI Emoji, sans-serif';
            var cleanText = text.trim();
            if (cleanText === '• • •') {
                msgDiv.innerHTML = '<div class="typing-dots"><span></span><span></span><span></span></div>';
            } else {
                msgDiv.innerHTML = replaceTextWithEmojis(text);
            }
            msgDiv.style.color = 'rgb(' + r + ',' + g + ',' + b + ')';
            if (bgR !== undefined && bgR !== null) {
                msgDiv.style.setProperty('background-color', 'rgb(' + bgR + ',' + bgG + ',' + bgB + ')');
                msgDiv.style.setProperty('border-radius', '10px', '!important');
                msgDiv.style.setProperty('border', '2px solid rgb(' + Math.round(bgR / 6) + ',' + Math.round(bgG / 6) + ',' + Math.round(bgB / 6) + ')', 'important');
            }
        };
        window.__bubbleClear = function(slot) {
            var ctx = window.__bubbleCtx;
            if (ctx.slots[slot]) {
                ctx.slots[slot].innerHTML = '';
            }
        };
        window.__bubbleClearAll = function() {
            var ctx = window.__bubbleCtx;
            for (var key in ctx.slots) {
                if (ctx.slots.hasOwnProperty(key)) {
                    var el = ctx.slots[key];
                    if (el && el.parentNode) {
                        el.parentNode.removeChild(el);
                    }
                }
            }
            ctx.slots = {};
        };
        window.__bubbleClearAll();
    ]=])
    browser:execute_js("__bubbleViewportSize(window.innerWidth, window.innerHeight);")
    pcall(applyVisualStyle, ini.settings.visual_style)
end

function getLocalPlayerId()
    local _, playerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    return tonumber(playerId)
end

function sampev.onCreate3DText(id, color, pos, dist, testLOS, attachedPlayer, attachedVeh, text)
    if attachedPlayer and attachedPlayer ~= 65535 and ini.settings.show3dtext == false then
        return false
    else
        return true
    end
end

function sampev.onServerMessage(color, text)
    if text:find(u8:decode('🤣')) then
        return u8:decode(text)
    end
end

function sampev.onSendChat(message)
    if ini.settings.enabled == false or ini.settings.local_bubbles == false then return true end

    local myID = getLocalPlayerId()
    if not myID then return true end
    local a, r, g, b = 255, 255, 255, 255
    if ini.settings.visual_style == 4 or ini.settings.visual_style == 5 then
        a,r,g = 0,0,0
    end
    query[myID] = {
        message = u8:encode(message),
        create_time = os.clock(),
        duration = 5,
        r = a, g = r, b = g, a = 255,
        textR = 255, textG = 255, textB = 255,
        playerId = myID
    }
    return true
end

function sampev.onPlayerChatBubble(playerId, color, distance, duration, message)
    if ini.settings.enabled == false then return true end

    if not query[playerId] then query[playerId] = {} end

    local a, r, g, b = explode_argb(color)
    local fgR, fgG, fgB = a, r, g
    if ini.settings.visual_style == 4 or ini.settings.visual_style == 5 then
        fgR, fgG, fgB = 0, 0, 0
    end
    query[playerId] = {
        message = u8:encode(message),
        create_time = os.clock(),
        duration = duration / 1000,
        r = fgR, g = fgG, b = fgB, a = 255,
        textR = a, textG = r, textB = g,
        playerId = playerId
    }
    return false
end

local sizeX, sizeY = getScreenResolution()

local STYLE_DEFAULTS = {
    [0] = [[
.bubble-message {
    background: rgba(0,0,0,0) !important;
    padding: 0.1px 10px !important;
    border-radius: 6px !important;
    border: none !important;
    font-size: 14px !important;
    font-weight: bold;
    text-shadow: -1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, 1px 1px 0 #000,
        -1px 0px 0 #000, 1px 0px 0 #000, 0px -1px 0 #000, 0px 1px 0 #000,
        -2px -2px 0 #000, 2px -2px 0 #000, -2px 2px 0 #000, 2px 2px 0 #000 !important;
}
]],
    [1] = [[
.bubble-message {
    background: transparent !important;
    padding: 0.1px 10px !important;
    border-radius: 0 !important;
    border: none !important;
    font-size: 14px !important;
    font-weight: bold;
    text-shadow: none !important;
}
]],
    [2] = [[
.bubble-message {
    background: rgba(0,0,0,0.8) !important;
    padding: 4px 12px !important;
    border-radius: 8px !important;
    border: none !important;
    font-size: 14px !important;
    font-weight: bold;
    text-shadow: none !important;
}
]],
    [3] = [[
.bubble-message {
    background: rgba(0,0,0,0.8) !important;
    padding: 6px 14px !important;
    border-radius: 10px !important;
    border: 2px solid rgba(255, 255, 255, 1) !important;
    font-size: 14px !important;
    font-weight: bold;
    text-shadow: none !important;
}
]],
    [4] = [[
.bubble-message {
    background: rgb(255, 255, 255) !important;
    padding: 4px 12px !important;
    border-radius: 8px !important;
    border: none !important;
    font-size: 14px !important;
    font-weight: bold;
    text-shadow: none !important;
}
]],
    [5] = [[
.bubble-message {
    background: rgb(255, 255, 255) !important;
    padding: 6px 14px !important;
    border-radius: 10px !important;
    border: 2px solid rgba(0, 0, 0, 1) !important;
    font-size: 14px !important;
    font-weight: bold;
    text-shadow: none !important;
}
]],
    [6] = [[
.bubble-message {
    padding: 4px 12px !important;
    border-radius: 8px !important;
    border: none !important;
    font-size: 14px !important;
    font-weight: bold;
    text-shadow: none !important;
}
]],
}

local STYLE_CSS = {}
for i = 0, 6 do
    local custom = loadCustomCss(i)
    if custom and #custom > 0 then
        STYLE_CSS[i] = custom
    else
        STYLE_CSS[i] = STYLE_DEFAULTS[i]
    end
end

function applyVisualStyle(styleIdx)
    if not browser then return end
    browser:execute_js("window.__bubbleClearAll && window.__bubbleClearAll()")
    local css = STYLE_CSS[styleIdx] or STYLE_CSS[0]
    local escaped = css:gsub("\\", "\\\\"):gsub("'", "\\'"):gsub("\n", "\\n"):gsub("\r", "\\r")
    browser:execute_js("var s=document.getElementById('__bubbleVisualStyle');if(!s){s=document.createElement('style');s.id='__bubbleVisualStyle';document.head.appendChild(s)}s.textContent='" .. escaped .. "'")
end

function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowWidth()/2-imgui.CalcTextSize(text).x/2)
    imgui.Text(text)
end

imgui.OnInitialize(function()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local path = getFolderPath(0x14) .. '\\arial.ttf'
    imgui.GetIO().Fonts:Clear()
    imgui.GetIO().Fonts:AddFontFromFileTTF(path, 18.0, nil, glyph_ranges)
    font_16 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 16.0, nil, glyph_ranges)
    font_17 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 16.0, nil, glyph_ranges)
    font_18 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 18.0, nil, glyph_ranges)
    font_21 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 21.0, nil, glyph_ranges)
    font_22 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 22.0, nil, glyph_ranges)
    font_23 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 24.0, nil, glyph_ranges)
    font_24 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 24.0, nil, glyph_ranges)
    font_25 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 25.0, nil, glyph_ranges)
    font_40 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 40.0, nil, glyph_ranges)
    SoftBlueTheme()
    theme[1].change()
    u32 = imgui.ColorConvertFloat4ToU32
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true

    ffi.copy(cssInput, STYLE_CSS[visualStyle[0]] or STYLE_CSS[0])

end)

imgui.OnFrame(function() return menuChatBubble[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(0, 0), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin('Настройки ChatBubbles', menuChatBubble, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse)

    local blue = imgui.ImVec4(0.29, 0.70, 1.0, 1.0)
    local gray = imgui.ImVec4(0.5, 0.5, 0.5, 1.0)

    imgui.PushStyleColor(imgui.Col.Text, blue)
    imgui.CenterText('Основное')
    imgui.PopStyleColor()
    imgui.Separator()
    imgui.Spacing()

    if imgui.Checkbox('Включить CEF чат-баблы', isEnabled) then
        ini.settings.enabled = isEnabled[0]
        inicfg.save(ini, IniFilename)
    end
    if imgui.IsItemHovered() then
        imgui.SetTooltip('Включает или отключает отображение CEF чат-баблов над игроками')
    end

    imgui.Text('Макс. дистанция')
    imgui.SameLine()
    imgui.PushItemWidth(200)
    if imgui.SliderInt('##maxDist', maxDist, 5, 200, '%d м') then
        ini.settings.max_distance = maxDist[0]
        inicfg.save(ini, IniFilename)
    end
    imgui.PopItemWidth()
    if imgui.IsItemHovered() then
        imgui.SetTooltip('Максимальное расстояние, с которого видны чат-баблы')
    end

    if imgui.Checkbox('Показывать свои сообщения', localBubbles) then
        ini.settings.local_bubbles = localBubbles[0]
        inicfg.save(ini, IniFilename)
    end
    if imgui.IsItemHovered() then
        imgui.SetTooltip('Отображать баблы над своим персонажем')
    end

    if localBubbles[0] then
        imgui.Indent(10)
        if imgui.RadioButtonIntPtr('Показывать только при отправке', localBubbleType, 0) then
            ini.settings.local_bubble_type = localBubbleType[0]
            inicfg.save(ini, IniFilename)
        end
        if imgui.RadioButtonIntPtr('Показывать при вводе текста', localBubbleType, 1) then
            ini.settings.local_bubble_type = localBubbleType[0]
            inicfg.save(ini, IniFilename)
        end
        imgui.Unindent(10)
    end
    
    if imgui.Checkbox('Показывать 3D Text над игроками', show3dtext) then
        ini.settings.show3dtext = show3dtext[0]
        inicfg.save(ini, IniFilename)
    end

    imgui.Spacing()
    if imgui.Button('Тестовый бабл (10 сек)', imgui.ImVec2(220, 0)) then
        local myID = getLocalPlayerId()
        if myID then
            freeSlot(myID)
            query[myID] = nil
            query[myID] = {
                message = '\u{1F923}',
                create_time = os.clock(),
                duration = 10,
                r = 255, g = 255, b = 255, a = 255,
                textR = 0, textG = 0, textB = 0,
                playerId = myID
            }
            if ini.settings.visual_style == 4 or ini.settings.visual_style == 5 then
                a, r, g = 0, 0, 0
            end
        end
    end
    if imgui.IsItemHovered() then
        imgui.SetTooltip('Показывает тестовый бабл над вашим персонажем на 10 секунд')
    end

    imgui.Spacing()
    imgui.Spacing()

    imgui.PushStyleColor(imgui.Col.Text, blue)
    imgui.CenterText('Оформление')
    imgui.PopStyleColor()
    imgui.Separator()
    imgui.Spacing()

    imgui.PushItemWidth(180)
    if imgui.Combo('Стиль баблов', visualStyle, stylePtrs, #bubbleStyles) then
        ini.settings.visual_style = visualStyle[0]
        inicfg.save(ini, IniFilename)
        for playerId in pairs(playerSlot) do freeSlot(playerId) end
        lastRenderedText = {}
        for i = 0, BUBBLE_SLOT_COUNT - 1 do slotDirty[i] = true end
        pcall(applyVisualStyle, visualStyle[0])
    end
    imgui.PopItemWidth()
    if imgui.IsItemHovered() then
        imgui.SetTooltip('Выберите стиль отображения чат-баблов:\n\nПо умолчанию - текст с обводкой(схож с Самповским)\nМинимальный - текст без обводки\nС фоном - текст на тёмном фоне\nС фоном 2 - текст на тёмном фоне(больше фон, белая обводка фона)\nС фоном 3 - текст на белом фоне\nС фоном 4 - текст на белом фоне(больше фон, черная обводка фона)\nДинамический фон - фон подстраивается под цвет текста')
    end

    imgui.Spacing()
    imgui.Spacing()

    imgui.PushStyleColor(imgui.Col.Text, blue)
    imgui.CenterText('Редактор CSS')
    imgui.PopStyleColor()
    imgui.Separator()
    imgui.Spacing()

    imgui.TextColored(gray, 'Редактируйте CSS стили баблов в реальном времени')
    imgui.Spacing()

    imgui.PushItemWidth(180)
    if imgui.Combo('Редактируемый стиль', cssStylePreview, stylePtrs, #bubbleStyles) then
        ffi.copy(cssInput, STYLE_CSS[cssStylePreview[0]] or STYLE_CSS[0])
    end
    imgui.PopItemWidth()
    if imgui.IsItemHovered() then
        imgui.SetTooltip('Выберите стиль для редактирования.\nМожно редактировать каждый стиль отдельно')
    end

    imgui.Spacing()

    imgui.InputTextMultiline('##cssEditor', cssInput, sizeof(cssInput), imgui.ImVec2(-1, 0))

    imgui.Spacing()

    imgui.TextColored(gray, 'Примечание: при добавлении color или background-color добавляйте !important,\nдабы lua не мог изменить цвет')

    imgui.Spacing()

    if imgui.Button('Применить CSS', imgui.ImVec2(170, 0)) then
        local raw = ffi.string(cssInput)
        local idx = cssStylePreview[0]
        STYLE_CSS[idx] = raw
        saveCustomCss(idx, raw)
        for playerId in pairs(playerSlot) do freeSlot(playerId) end
        lastRenderedText = {}
        for i = 0, BUBBLE_SLOT_COUNT - 1 do slotDirty[i] = true end
        pcall(applyVisualStyle, visualStyle[0])
    end
    imgui.SameLine()
    if imgui.Button('Сбросить CSS', imgui.ImVec2(170, 0)) then
        local idx = cssStylePreview[0]
        STYLE_CSS[idx] = STYLE_DEFAULTS[idx]
        deleteCustomCss(idx)
        ffi.copy(cssInput, STYLE_CSS[idx])
        for playerId in pairs(playerSlot) do freeSlot(playerId) end
        lastRenderedText = {}
        for i = 0, BUBBLE_SLOT_COUNT - 1 do slotDirty[i] = true end
        pcall(applyVisualStyle, visualStyle[0])
    end

    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()

    imgui.TextColored(gray, '/bubble - открыть/закрыть меню')
    imgui.TextColored(gray, 'Author - MSIshka')
    imgui.End()
end)

imgui.OnFrame(
    function() return true end,
    function(this)
        if not initDone then
            initDone = true

            local scaleX = sizeX / 1920
            local scaleY = sizeY / 1080

            local iniW = tonumber(ini.settings.slot_w) or 0
            local iniH = tonumber(ini.settings.slot_h) or 0

            if iniW > 0 and iniW ~= 600 then
                BUBBLE_SLOT_W = iniW
            else
                BUBBLE_SLOT_W = math.floor(600 * scaleX)
            end

            if iniH > 0 and iniH ~= 120 then
                BUBBLE_SLOT_H = iniH
            else
                BUBBLE_SLOT_H = math.floor(120 * scaleY)
            end

            BUBBLE_SLOT_GAP = math.max(2, math.floor(10 * scaleY))

            print("CEF ChatBubbles: viewport=" .. sizeX .. "x" .. sizeY ..
                " slot=" .. BUBBLE_SLOT_W .. "x" .. BUBBLE_SLOT_H ..
                " gap=" .. BUBBLE_SLOT_GAP)

            browser = webcore:create_fullscreen("file:///moonloader/cef/chatbubble/chatbubbles.html")
            pcall(function() browser:set_offscreen(true) end)
            pcall(function() browser:set_input(false) end)

            browser:set_create_cb(function(_)
                browser:add_function("__bubbleViewportSize", function(_, name, args)
                    if args and #args >= 2 then
                        sizeX = tonumber(args[1]) or sizeX
                        sizeY = tonumber(args[2]) or sizeY
                    end
                end)
            end)
            
            browser:set_loading_cb(function(_, status)
                if status == 0 then
                    print("CEF ChatBubbles: page loaded")
                    if lastAppliedStyle ~= ini.settings.visual_style then
                        lastAppliedStyle = ini.settings.visual_style
                        pcall(applyVisualStyle, lastAppliedStyle)
                    end
                    initBubbleCEF()
                    browser:set_active(true)
                end
            end)
        end

        if ini.settings.enabled == false then return end
        if not browser then return end


        local BGDL = imgui.GetBackgroundDrawList()
        local current_time = os.clock()
        local texRaw = browser:get_texture()
        local tex = texRaw and ffi.cast('void*', texRaw)
        this.HideCursor = true

        if not tex then return end

        local expired = {}
        for playerId, data in pairs(query) do
            if current_time - data.create_time > data.duration then
                table.insert(expired, playerId)
            end
        end
        for _, playerId in ipairs(expired) do
            freeSlot(playerId)
            query[playerId] = nil
        end

        local myID = pcall(getLocalPlayerId) and getLocalPlayerId()

        for playerId, data in pairs(query) do
            local elapsed = current_time - data.create_time
            local res, handle

            if myID and tonumber(playerId) == myID then
                handle = PLAYER_PED
            else
                res, handle = sampGetCharHandleBySampPlayerId(tonumber(playerId))
            end

            local shouldRender = false
            if handle and doesCharExist(handle) then
                if myID and tonumber(playerId) == myID then
                    shouldRender = true
                else
                    shouldRender = wallPlayer(handle, 50)
                end
            end
            if shouldRender then
                local x, y, z = getBodyPartCoordinates(8, handle)
                if isPointOnScreen(x, y, z, 0.2) then
                    local screenX, screenY = convert3DCoordsToScreen(x, y, z + 0.4)

                    if screenX and screenY then
                        screenX, screenY = tonumber(screenX), tonumber(screenY)
                        local fadeAlpha = calcFadeAlpha(elapsed, data.duration)
                        local bubbleAlpha = fadeAlpha * (data.a / 255)

                        local slotId = allocSlot(playerId)
                        if slotId ~= nil and slotDirty[slotId] then
                            local escaped = escapeText(data.message)
                            if lastRenderedText[slotId] ~= escaped then
                                lastRenderedText[slotId] = escaped
                                if ini.settings.visual_style == 6 and data.textR then
                                    local tr, tg, tb = getContrastColor(data.textR, data.textG, data.textB)
                                    browser:execute_js(string.format(
                                        "__bubbleUpdate(%d,'%s',%d,%d,%d,%d,%d,%d)",
                                        slotId, escaped, tr, tg, tb, data.textR, data.textG, data.textB
                                    ))
                                else
                                    browser:execute_js(string.format(
                                        "__bubbleUpdate(%d,'%s',%d,%d,%d)",
                                        slotId, escaped, data.r, data.g, data.b
                                    ))
                                end
                            end
                            slotDirty[slotId] = false
                        end

                        if slotId ~= nil then
                            local slotY = slotId * (BUBBLE_SLOT_H + BUBBLE_SLOT_GAP)
                            local uvY1 = slotY / sizeY
                            local uvY2 = (slotY + BUBBLE_SLOT_H) / sizeY

                            local posX = screenX - BUBBLE_SLOT_W / 2 + BUBBLE_OFFSET_X
                            local posY = screenY - BUBBLE_SLOT_H
                            local tint = imgui.GetColorU32Vec4(imgui.ImVec4(1, 1, 1, bubbleAlpha))

                            BGDL:AddImage(
                                tex,
                                imgui.ImVec2(posX, posY),
                                imgui.ImVec2(posX + sizeX, posY + BUBBLE_SLOT_H),
                                imgui.ImVec2(0, uvY1),
                                imgui.ImVec2(1.0, uvY2),
                                tint
                            )
                        end
                    end
                end
            end
        end
    end
)

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand('bubble', function()
        menuChatBubble[0] = not menuChatBubble[0]
    end)

    if not hasWebcore then
        print("CEF ChatBubbles: webcore not found")
        return
    end
    while not webcore.inited() do wait(100) end
    wait(0)

    while true do

        if not (ini.settings.local_bubbles and ini.settings.local_bubble_type == 1) then
            local myID = getLocalPlayerId()
            if myID and query[myID] and query[myID].duration == 9999 then
                freeSlot(myID)
                query[myID] = nil
            end
        end

        local myID = getLocalPlayerId()
        if not myID then return end

        if sampIsChatInputActive() then
            local text = sampGetChatInputText()
            local a, r, g, b = 255, 255, 255, 255
            if text and text ~= '' then
                if not query[myID] or query[myID].duration ~= 9999 then
                    if ini.settings.visual_style == 4 or ini.settings.visual_style == 5 then
                        a, r, g = 0, 0, 0
                    end
                    query[myID] = {
                        message = text,
                        create_time = os.clock(),
                        duration = 9999,
                        r = a, g = r, b = g, a = 255,
                        textR = 255, textG = 255, textB = 255,
                        playerId = myID
                    }
                elseif query[myID].message ~= u8:encode(text) then
                    query[myID].message = u8:encode(text)
                    if ini.settings.visual_style == 4 or ini.settings.visual_style == 5 then
                        query[myID].r, query[myID].g, query[myID].b = 0,0,0
                    else
                        query[myID].r, query[myID].g, query[myID].b = 255,255,255
                    end
                end
            elseif query[myID] and query[myID].duration == 9999 then
                freeSlot(myID)
                query[myID] = nil
            end
        elseif webcore:input_active() and ini.settings.local_bubble_type == 1 then
            local text = '• • •'
            local a, r, g, b = 255, 255, 255, 255
            if not query[myID] or query[myID].duration ~= 9999 then
                if ini.settings.visual_style == 4 or ini.settings.visual_style == 5 then
                    a, r, g = 0, 0, 0
                end
                query[myID] = {
                    message = text,
                    create_time = os.clock(),
                    duration = 9999,
                    r = a, g = r, b = g, a = 255,
                    textR = 255, textG = 255, textB = 255,
                    playerId = myID
                }
            elseif query[myID].message ~= text then
                query[myID].message = text
                if ini.settings.visual_style == 4 or ini.settings.visual_style == 5 then
                    query[myID].r, query[myID].g, query[myID].b = 0,0,0
                else
                    query[myID].r, query[myID].g, query[myID].b = 255,255,255
                end
            end
        elseif query[myID] and query[myID].duration == 9999 then
            freeSlot(myID)
            query[myID] = nil
        end

        wait(0)
    end
end

addEventHandler('onScriptTerminate', function(scr)
    if scr == script.this then
        if browser then
            webcore:close(browser)
            browser = nil
        end
    end
end)

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
