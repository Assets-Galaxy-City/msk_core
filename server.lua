MSK = {}

local Callbacks = {}
local Charset = {}
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

MSK.GetRandomLetter = function(length)
    Wait(0)
    if length > 0 then
        return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
    else
        return ''
    end
end

MSK.AddWebhook = function(webhook, botColor, botName, botAvatar, title, description, fields, footer, time)
    if footer then 
        if time then
            footer = {
                ["text"] = footer.text .. " • " .. os.date(time),
                ["icon_url"] = footer.link
            }
        else
            footer = {
                ["text"] = footer.text,
                ["icon_url"] = footer.link
            }
        end
    end

    local content = {{
        ["title"] = title,
        ["description"] = description,
        ["color"] = botColor,
        ["fields"] = fields,
        ["footer"] = footer
    }}

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        username = botName,
        embeds = content,
        avatar_url = botAvatar
    }), {
        ['Content-Type'] = 'application/json'
    })
end

MSK.RegisterCallback = function(name, cb)
    Callbacks[name] = cb
end

MSK.logging = function(code, msg, msg2, msg3)
    if code == 'error' then
        if msg3 then
			print('[^1ERROR^0]', msg, msg2, msg3)
        elseif msg2 and not msg3 then
            print('[^1ERROR^0]', msg, msg2)
        else
		    print('[^1ERROR^0]', msg)
        end
    elseif code == 'debug' then
		if msg3 then
			print('[^3DEBUG^0]', msg, msg2, msg3)
        elseif msg2 and not msg3 then
            print('[^3DEBUG^0]', msg, msg2)
        else
		    print('[^3DEBUG^0]', msg)
        end
	end
end

RegisterNetEvent('msk_core:triggerCallback')
AddEventHandler('msk_core:triggerCallback', function(name, requestId, ...)
    if Callbacks[name] then
        Callbacks[name](source, function(...)
            TriggerClientEvent("msk_core:responseCallback", source, requestId, ...)
        end, ...)
    end
end)

loadScript = function()
    GetCurrentVersion = function()
	    return GetResourceMetadata( GetCurrentResourceName(), "version" )
    end
    
    local CurrentVersion = GetCurrentVersion()
    local resourceName = "^4["..GetCurrentResourceName().."]^0"

    if Config.VersionChecker then
        PerformHttpRequest('https://raw.githubusercontent.com/MSK-Scripts/msk_core/main/VERSION', function(Error, NewestVersion, Header)
            print("###############################")
            if CurrentVersion == NewestVersion then
                print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
            elseif CurrentVersion ~= NewestVersion then
                print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
                print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here:^9 https://github.com/MSK-Scripts/msk_core ^0')
            end
            print("###############################")
        end)
    else
        print("###############################")
        print(resourceName .. '^2 ✓ Resource loaded^0')
        print("###############################")
    end
end
loadScript()

exports('getCoreObject', function()
    return MSK
end)