tests = {}

function tests.checkForOxmysql()
    return exports.oxmysql ~= nil
end

function tests.checkForConfig()
    return Config ~= nil
end

function tests.checkForFramework()
    return GetFrameworkObject() ~= nil
end