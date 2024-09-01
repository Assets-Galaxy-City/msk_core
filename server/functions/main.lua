local RegisteredCommands = {}

MSK.Notification = function(src, title, message, info, time)
    if not src or src == 0 then return end
    TriggerClientEvent('msk_core:notification', src, title, message, info, time)
end
MSK.Notify = MSK.Notification
exports('Notification', MSK.Notification)

MSK.HelpNotification = function(src, text)
    if not src or src == 0 then return end
    TriggerClientEvent('msk_core:helpNotification', src, text)
end
MSK.HelpNotify = MSK.HelpNotification
exports('HelpNotification', MSK.HelpNotification)

MSK.AdvancedNotification = function(src, text, title, subtitle, icon, flash, icontype)
    if not src or src == 0 then return end
    TriggerClientEvent('msk_core:advancedNotification', src, text, title, subtitle, icon, flash, icontype)
end
MSK.AdvancedNotify = MSK.AdvancedNotification
exports('AdvancedNotification', MSK.AdvancedNotification)

MSK.ScaleformAnnounce = function(src, header, text, typ, duration)
    if not src or src == 0 then return end
    TriggerClientEvent('msk_core:scaleformNotification', src, header, text, typ, duration)
end
MSK.Scaleform = MSK.ScaleformAnnounce
exports('ScaleformAnnounce', MSK.ScaleformAnnounce)

MSK.Subtitle = function(src, message, duration)
    if not src or src == 0 then return end
    TriggerClientEvent('msk_core:subtitle', src, message, duration)
end
exports('Subtitle', MSK.Subtitle)

MSK.Spinner = function(src, text, typ, duration)
    if not src or src == 0 then return end
    TriggerClientEvent('msk_core:spinner', src, text, typ, duration)
end
exports('Spinner', MSK.Spinner)

MSK.Draw3DText = function(src, coords, text, size, font)
    if not src or src == 0 then return end
    TriggerClientEvent('msk_core:draw3DText', src, coords, text, size, font)
end
exports('Draw3DText', MSK.Draw3DText)

MSK.DrawGenericText = function(src, text, outline, font, size, color, position)
    if not src or src == 0 then return end
    TriggerClientEvent('msk_core:drawGenericText', src, text, outline, font, size, color, position)
end
exports('DrawGenericText', MSK.DrawGenericText)

MSK.Progressbar = function(src, time, text, color)
    if not src or src == 0 then return end
    TriggerClientEvent('msk_core:progressbar', src, time, text, color)
end
exports('Progressbar', MSK.Progressbar)

MSK.ProgressStop = function(src)
    if not src or src == 0 then return end
    TriggerClientEvent('msk_core:progressbarStop', src)
end
exports('ProgressStop', MSK.ProgressStop)

MSK.Input = function(src, header, placeholder, field)
    return MSK.Trigger('msk_core:input', src, header, placeholder, field)
end
exports('Input', MSK.Input)

MSK.CloseInput = function(src)
    if not src or src == 0 then return end
    TriggerClientEvent('msk_core:closeInput', src)
end
exports('CloseInput', MSK.CloseInput)

MSK.Numpad = function(src, pin, show)
    return MSK.Trigger('msk_core:numpad', src, pin, show)
end
exports('Numpad', MSK.Numpad)

MSK.CloseNumpad = function(src)
    if not src or src == 0 then return end
    TriggerClientEvent('msk_core:closeNumpad', src)
end
exports('CloseNumpad', MSK.CloseNumpad)

MSK.IsSpawnPointClear = function(coords, maxDistance)
    if not coords then return end
    if not maxDistance then maxDistance = 5.0 end

    local nearbyVehicles = {}
    coords = vector3(coords.x, coords.y, coords.z)

    for k, vehicle in pairs(GetAllVehicles()) do
        local distance = #(coords - GetEntityCoords(vehicle))

        if distance <= maxDistance then
            nearbyVehicles[#nearbyVehicles + 1] = vehicle
        end
    end

    return #nearbyVehicles == 0
end
exports('IsSpawnPointClear', MSK.IsSpawnPointClear)

MSK.GetPedVehicleSeat = function(ped, vehicle)
    if not ped then return end
    if not vehicle then GetVehiclePedIsIn(ped, false) end
    
    for i = -1, 16 do
        if (GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -1
end
exports('GetPedVehicleSeat', MSK.GetPedVehicleSeat)

MSK.AddWebhook = function(webhook, botColor, botName, botAvatar, title, description, fields, footer, time)
    local content = {}

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

    if fields then
        content = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = botColor,
            ["fields"] = fields,
            ["footer"] = footer
        }}
    else
        content = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = botColor,
            ["footer"] = footer
        }}
    end

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        username = botName,
        embeds = content,
        avatar_url = botAvatar
    }), {
        ['Content-Type'] = 'application/json'
    })
end
exports('AddWebhook', MSK.AddWebhook)

MSK.HasItem = function(playerId, item)
    if not playerId then 
        logging('error', 'Player on Function MSK.HasItem does not exist!') 
        return
    end

    if MSK.Bridge.Framework.Type ~= 'ESX' and MSK.Bridge.Framework.Type ~= 'QBCore' then 
        logging('error', ('Function %s can not used without Framework!'):format('^3MSK.HasItem^0'))
        return
    end

    local Player = MSK.GetPlayerFromId(playerId)
    
    return Player.HasItem(item)
end
exports('HasItem', MSK.HasItem)

MSK.RegisterCommand = function(name, group, cb, console, framework, suggestion)    
    if type(name) == 'table' then
        for k, v in ipairs(name) do 
            MSK.RegisterCommand(v, group, cb, console, framework, suggestion)
        end
        return
    end

    if RegisteredCommands[name] then
        logging('debug', ('Command ^3%s^0 is already registerd. Overriding Command...'):format(name))
    end
    
    local added = addChatSuggestions(name, suggestion)
    while not added do Wait(1) end
    
    RegisteredCommands[name] = {group = group, cb = cb, console = console, suggestion = suggestion}

    RegisterCommand(name, function(source, args, rawCommand)
        local source = source
        local Command, error = RegisteredCommands[name], nil

        if not Command.console and source == 0 then 
            logging('error', 'You can not run this Command in Server Console!')
        else
            if Command.suggestion and Command.suggestion.arguments then 
                local newArgs = {}

                for k, v in ipairs(Command.suggestion.arguments) do 
                    if v.action == 'number' then
                        if args[k] then
                            if tonumber(args[k]) then
                                newArgs[v.name] = args[k]
                            else
                                error = ('Argument %s is not a number!'):format(v.name)
                            end
                        end
                    elseif v.action == 'playerId' then
                        if args[k] then
                            local targetId = args[k]
                            if targetId == 'me' then targetId = source end

                            if tonumber(targetId) > 0 and doesPlayerIdExist(targetId) then
                                newArgs[v.name] = targetId
                            else
                                error = ('PlayerId %s does not exist!'):format(targetId)
                            end
                        end
                    else
                        newArgs[v.name] = args[k]
                    end

                    if not error and not newArgs[v.name] and v.val then 
                        error = ('Argument Mismatch with Argument %s'):format(v.name)
                    end
                    if error then break end
                end

                args = newArgs
            end

            if error then
                if source == 0 then
                    logging('error', error)
                else
                    MSK.Notification(source, error)
                end
            else
                if Config.Framework ~= 'Standalone' and framework then
                    local Player = MSK.GetPlayer({source = source})
                    cb(Player, args, rawCommand)
                else
                    cb(source, args, rawCommand)
                end
            end
        end
    end, true)

    if type(group) == 'table' then
        for k, v in ipairs(group) do
            ExecuteCommand(('add_ace group.%s command.%s allow'):format(v, name))
        end
    else
        ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name))
    end
end
exports('RegisterCommand', MSK.RegisterCommand)

doesPlayerIdExist = function(playerId)
    for k, id in pairs(GetPlayers()) do
        if id == playerId then
            return true
        end
    end
    return false
end

addChatSuggestions = function(name, suggestion)
    if RegisteredCommands[name] then
        if RegisteredCommands[name].suggestion then
            TriggerClientEvent('chat:removeSuggestion', -1, '/' .. name)
        end
    end

    if suggestion then
        if not suggestion.arguments then suggestion.arguments = {} end
        if not suggestion.help then suggestion.help = '' end
    
        TriggerClientEvent('chat:addSuggestion', -1, '/' .. name, suggestion.help, suggestion.arguments)
    end

    return true
end