-- Types: info (default), error, warning
function cPrint(string, type)
    local colors = { info = "^2", error = "^1", warning = "^3" }
    print(("%s[%s%s^0] %s"):format("", colors[type or "info"], type or "info", string))
end

function testPrint(stringPass, stringFail, passed)
    local symbol = passed and "✔" or "✖"
    local color = passed and "^2" or "^1"
    print(("%s^0[%s%s^0] %s"):format("            ", color, symbol, passed and stringPass or stringFail))
end

function createTableIfNotExist()
    cPrint("Checking if table exists...", "info")
    MySQL.query("CREATE TABLE IF NOT EXISTS antitroll_time (identifier VARCHAR(255) NOT NULL, time_left INT DEFAULT 0 NOT NULL, PRIMARY KEY (identifier))", function(result)
        if result.warningStatus == 0 then
            cPrint("Table does not exist but was created!", "warning")
        else
            cPrint("Table exists!", "info")
        end
    end)
end

function getCommandString()
    return type(Config.AdminCommand) == "string" and string.lower(Config.AdminCommand) or "troll"
end

function getCommandRang()
    return type(Config.Rang) == "string" and Config.Rang or "admin"
end

-- MYSQL STUFF
local function query(sql, params, callback)
    MySQL.query.await(sql, params, callback)
end

function insert(identifier, time)
    query("INSERT IGNORE INTO antitroll_time (identifier, time_left) VALUES (?, ?)", { identifier, time })
end

function update(identifier, time)
    query("UPDATE antitroll_time SET time_left = ? WHERE identifier = ?", { time, identifier })
end

function doesUserExist(identifier)
    local result = query("SELECT * FROM antitroll_time WHERE identifier = ?", { identifier })
    return result[1] ~= nil
end

function isNewPlayer(identifier)
    return not doesUserExist(identifier)
end

function getTimeLeft(identifier)
    local result = query("SELECT * FROM antitroll_time WHERE identifier = ?", { identifier })
    return result[1] and result[1].time_left or 0
end

function updateOrInsert(identifier, time)
    if doesUserExist(identifier) then
        update(identifier, time)
    else
        insert(identifier, time)
    end
end