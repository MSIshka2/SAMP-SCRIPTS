local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local memory = require 'memory'
local sampev = require 'lib.samp.events'
local ffi = require 'ffi'

local hasWebcore, webcore = pcall(require, 'webcore')
local browser = nil
local textdraws_to_hide = {2149, 2141, 2140, 2143, 2145, 2148, 2144, 0, 1, 2146, 2147, 2142, 58,59,60,61,63,66,65,74,754,73,70,71,72,57,56,55,68,62,69,67,75,64}
local textdrawR = false

local json = require 'cjson'
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

local serverIP = "46.174.54.127"

function random(min, max)
    kf = math.random(min, max)
    math.randomseed(os.time() * kf)
    rand = math.random(min, max)
    return tonumber(rand)
end

function isDriverSeat()
    if not isCharInAnyCar(PLAYER_PED) then return false end
    local vehicle = storeCarCharIsInNoSave(PLAYER_PED)
    local driver = getDriverOfCar(vehicle)
    return driver == PLAYER_PED
end

function getCarSpeed(vehicleTarget, kilometersBool)
    if not vehicleTarget or type(vehicleTarget) ~= 'number' then return false end
    if not doesVehicleExist(vehicleTarget) then return false end
    local x, y, z = getCarSpeedVector(vehicleTarget)
    if not x or not y or not z then x, y, z = 0, 0, 0 end
    local rawSpeed = math.sqrt(x*x + y*y + z*z)
    local speed = rawSpeed * 1.089
    local kmh = math.floor(speed * 3.6)
    local mph = math.floor(speed * 2.23694)
    if kilometersBool then return true, kmh else return true, mph end
end

local playerHealth = 100
local playerREP = 0
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

local TURN_SIGNAL_DELAY = 0.8
local BLINK_INTERVAL = 0.5

function onReceiveRpc(id, bs)
    local ip, port = sampGetCurrentServerAddress()
    if ip == serverIP then
        if id == 134 then
            local textdraw = read_bitstream(bs)
            if textdraw.id == 2180 then
                playerHealth = math.min(textdraw.health, 100)
                return false
            end
        end
    else
        return
    end
end

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

function formatREP(repString)
    local number = repString:gsub("P0*", "")
    if number == "" then return "0" end
    return number
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    memory.write(0x571784, 0x57C7FFF, 4, false)
    memory.write(0x57179C, 0x57C7FFF, 4, false)
    displayHud(false)
    while not isSampAvailable() do wait(100) end
    displayHud(false)
    if not hasWebcore then
        sampAddChatMessage('[HUD] WebCore не найден!', 0xFF0000)
        return
    end

    while not webcore.inited() do wait(100) end

    browser = webcore:create_fullscreen("file:///cef/hud/hud.html")

    browser:set_loading_cb(function(_, status)
    end)

    browser:set_create_cb(function()
    end)

    while true do
        displayHud(false)
        sampTextdrawCreate(ini.main.hp1, "", -9999, -9999)
        sampTextdrawCreate(ini.main.hp2, "", -9999, -9999)
        sampTextdrawCreate(ini.main.time, "", -9999, -9999)
        processTurnSignals()
        
        if browser and not browser:input_active() then
            local currentAmmo = getAmmoInCharWeapon(PLAYER_PED, getCurrentCharWeapon(PLAYER_PED))
            browser:execute_js(string.format('updateAmmo(%d)', currentAmmo))
            
            local ip, port = sampGetCurrentServerAddress()
            if ip == serverIP then
                local health = playerHealth
                browser:execute_js(string.format('updateHealth(%d)', health))
            else
                local health = getCharHealth(PLAYER_PED)
                browser:execute_js(string.format('updateHealth(%d)', health))
            end
            
            if isCharInWater(PLAYER_PED) then
                local oxygen = ("%.0f"):format(memory.getfloat(0xB7CDE0)/39.97000244)
                oxygen = math.min(tonumber(oxygen), 100)
                browser:execute_js(string.format('updateOxy(%d)', oxygen))
                
                local stamina = ("%.0f"):format(memory.getfloat(0xB7CDB4)/31.47000244)
                stamina = math.min(tonumber(stamina), 100)
                browser:execute_js(string.format('updateStam(%d)', stamina))
            else
                browser:execute_js('hideOxygenBar()')
                
                local stamina = ("%.0f"):format(memory.getfloat(0xB7CDB4)/31.47000244)
                stamina = math.min(tonumber(stamina), 100)
                browser:execute_js(string.format('updateStam(%d)', stamina))
            end
            
            local arm = getCharArmour(PLAYER_PED)
            browser:execute_js(string.format('updateArm(%d)', arm))
            
            local weapon = getCurrentCharWeapon(PLAYER_PED)
            if weapon then
                browser:execute_js(string.format('updateWeapon(%d)', weapon))
            end
            
            local money = memory.read(0xB7CE50, 4, true)
            browser:execute_js(string.format('updateMoney(%d)', money))
            
            local ip, port = sampGetCurrentServerAddress()
            if ip == serverIP then
                playerREP = sampTextdrawGetString(ini.main.rep)
                local repNum = formatREP(playerREP)
                browser:execute_js(string.format('updateREP(%s)', repNum))
                browser:execute_js("document.getElementById('prem').style.display = 'block'")
            else
                browser:execute_js([[
                    document.getElementById('server-header').style.visibility = 'hidden';
                    document.getElementById('rep_count').style.display = 'none';
                    document.getElementById('prem').style.display = 'none';
                ]])
            end

            if isCharInAnyCar(PLAYER_PED) then
                local car = storeCarCharIsInNoSave(PLAYER_PED)
                local result_speed, speed = getCarSpeed(car, true)
                speed = speed or 0
                
                local hp = getCarHealth(car) or 1000
                local engine = isCarEngineOn(car) and 1 or 0
                
                if engine == 1 and hp > 500 then
                    browser:execute_js([[
                        document.getElementById('veheng').querySelector('svg').style.fill = '#66cc00';
                    ]])
                elseif hp <= 500 and hp > 350 then
                    browser:execute_js([[
                        document.getElementById('veheng').querySelector('svg').style.fill = '#ffcd00';
                    ]])
                elseif hp <= 350 then
                    browser:execute_js([[
                        document.getElementById('veheng').querySelector('svg').style.fill = '#ff0000';
                    ]])
                else
                    browser:execute_js([[
                        document.getElementById('veheng').querySelector('svg').style.fill = 'rgba(255,255,255,0.5)';
                    ]])
                end
                
                local status = getCarDoorLockStatus(car) or 1
                if status == 2 then
                    browser:execute_js([[
                        document.getElementById('vehlock').querySelector('svg').style.fill = '#ff0000';
                    ]])
                elseif status == 0 then
                    browser:execute_js([[
                        document.getElementById('vehlock').querySelector('svg').style.fill = '#66cc00';
                    ]])
                end
                
                local fuel = 100
                local textdraw = sampTextdrawGetString(2122)
                if textdraw and ip == serverIP then
                    local fuelMatch = textdraw:match("%s*HEAL:%s*%d+~n~SPEED:%s*%d+~n~FUEL:%s*~g~(%d+)~n~~w~STATUS:%s*~.+~.+~n~~w~")
                    fuel = tonumber(fuelMatch) or 100
                end
                
                browser:execute_js(string.format('updateCar(%d, %d, %d, %d, %d)', 1, speed, fuel, hp, engine))
                
                if turn_signals.left.blinking then
                    if math.floor((os.clock() / BLINK_INTERVAL) % 2) == 0 then
                        browser:execute_js([[
                            document.getElementById('vehleft').querySelector('svg').style.fill = '#FF8000';
                        ]])
                    else
                        browser:execute_js([[
                            document.getElementById('vehleft').querySelector('svg').style.fill = 'rgba(255,255,255,0.5)';
                        ]])
                    end
                else
                    browser:execute_js([[
                        document.getElementById('vehleft').querySelector('svg').style.fill = 'rgba(255,255,255,0.5)';
                    ]])
                end
                
                if turn_signals.right.blinking then
                    if math.floor((os.clock() / BLINK_INTERVAL) % 2) == 0 then
                        browser:execute_js([[
                            document.getElementById('vehright').querySelector('svg').style.fill = '#FF8000';
                        ]])
                    else
                        browser:execute_js([[
                            document.getElementById('vehright').querySelector('svg').style.fill = 'rgba(255,255,255,0.5)';
                        ]])
                    end
                else
                    browser:execute_js([[
                        document.getElementById('vehright').querySelector('svg').style.fill = 'rgba(255,255,255,0.5)';
                    ]])
                end
            else
                browser:execute_js(string.format('updateCar(%d, %d, %d, %d, %d)', 0, 0, 0, 0, 0))
            end
        end
        wait(0)
    end
end

function processTurnSignals()
    if not isCharInAnyCar(PLAYER_PED) or not isDriverSeat() then
        turn_signals.left.active = false
        turn_signals.right.active = false
        turn_signals.left.blinking = false
        turn_signals.right.blinking = false
        return
    end

    local current_time = os.clock()

    if isKeyDown(0x41) then
        if not turn_signals.left.active then
            turn_signals.left.active = true
            turn_signals.left.start_time = current_time
        elseif current_time - turn_signals.left.start_time >= TURN_SIGNAL_DELAY and not turn_signals.left.blinking then
            turn_signals.left.blinking = true
            turn_signals.right.blinking = false
            turn_signals.left.last_blink = current_time
        end
    else
        turn_signals.left.active = false
        if not isKeyDown(0x41) and not isKeyDown(0x44) then
            turn_signals.left.blinking = false
        end
    end

    if isKeyDown(0x44) then
        if not turn_signals.right.active then
            turn_signals.right.active = true
            turn_signals.right.start_time = current_time
        elseif current_time - turn_signals.right.start_time >= TURN_SIGNAL_DELAY and not turn_signals.right.blinking then
            turn_signals.right.blinking = true
            turn_signals.left.blinking = false
            turn_signals.right.last_blink = current_time
        end
    else
        turn_signals.right.active = false
        if not isKeyDown(0x41) and not isKeyDown(0x44) then
            turn_signals.right.blinking = false
        end
    end
end

function sampev.onShowTextDraw(id, data)
    local ip, port = sampGetCurrentServerAddress()
    if ip == serverIP then
        lua_thread.create(function()
            wait(2000)

            if data.text:find("rankTester") then
                table.insert(textdraws_to_hide, id)
            end

            if data.letterColor == -16776961 or data.letterColor == -1 and data.style == 4 and data.boxColor == -2139062144 and data.lineWidth == 7 and data.color == -1 then
                table.insert(textdraws_to_hide, id)
            end

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

            wait(2500)
            for _, tdid in ipairs(textdraws_to_hide) do
                if id == tdid then
                    sampTextdrawSetPos(id, -9999, -9999)
                    return false
                end
            end
        end)
    end
end

function onScriptTerminate(s, q)
    if s == thisScript() and browser then
        webcore:close(browser)
    end
end