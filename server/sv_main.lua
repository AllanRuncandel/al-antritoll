print([[^1
     _   _  _ _____ ___   _____ ___  ___  _    _
    /_\ | \| |_   _|_ _| |_   _| _ \/ _ \| |  | |
   / _ \| .` | | |  | |    | | |   / (_) | |__| |__
  /_/ \_\_|\_| |_| |___|   |_| |_|_\\___/|____|____|
          ^8by Allan (github.com/AllanRuncandel)^0
^0---------------------[^2Tests^0]---------------------]])

local testsPassed = true

testPrint("Oxmysql is installed.", "Oxmysql is not installed!", tests.checkForOxmysql())
testPrint(Config.Framework .. " is installed.", Config.Framework .. " is not installed!", tests.checkForFramework())
testPrint("Config found.", "Config not found!", tests.checkForConfig())

if not (tests.checkForOxmysql() and tests.checkForFramework() and tests.checkForConfig()) then
    cPrint("^1One or more tests failed!^0", "error")
    return
end

cPrint("All tests passed!", "info")

createTableIfNotExist()

local commandString = getCommandString()
local commandRang = getCommandRang()

if Config.Framework == "ESX" then
    FrameworkObject.RegisterCommand(commandString, commandRang, function(xPlayer, args)
        local target = args.id
        if not target then
            cPrint("Player not found!", "error")
            return
        end
        ToggleTrollProtection(target)
        cPrint("Troll protection toggled for " .. target.name .. " for " .. Config.HowLong .. " min!", "info")
    end, true, { help = "Toggle Troll Protection", arguments = { { name = "id", help = "Player ID", type = "player" } } })
elseif Config.Framework == "QBCore" then
    FrameworkObject.Commands.Add(commandString, "Toggle Troll Protection", {}, false, function(source, args)
        local target = args[1] or source
        if not GetPlayerName(target) then
            cPrint("Player not found!", "error")
            return
        end
        ToggleTrollProtection(target)
        cPrint("Troll protection toggled for " .. target .. " for " .. Config.HowLong .. " min!", "info")
    end, commandRang)
end

function ToggleTrollProtection(target, toggleOverride, timeOverride)
    TriggerClientEvent("knxr-antitroll:toggle", target, toggleOverride or true, timeOverride or Config.HowLong)
end

RegisterNetEvent("knxr-antitroll:updateTime", function(time)
    local identifier = GetPlayerIdentifier(source)
    updateOrInsert(identifier, time)
end)

RegisterNetEvent("knxr-antitroll:onjoin", function()
    local source = source
    local identifier = GetPlayerIdentifier(source)
    local isNew = isNewPlayer(identifier)
    onJoin(source, identifier, isNew)
end)

function onJoin(source, identifier, isNew)
    if isNew then
        ToggleTrollProtection(source, true, Config.HowLong)
        return
    end
    local time = getTimeLeft(identifier)
    if time > 0 then
        TriggerClientEvent("knxr-antitroll:toggle", source, true, time)
        return
    end
    updateOrInsert(identifier, time)
end