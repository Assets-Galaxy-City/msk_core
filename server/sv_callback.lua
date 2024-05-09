local Callbacks = {}
local CallbackHandler = {}

local GenerateCallbackHandlerKey = function()
    local requestId = math.random(1, 999999999)

    if not CallbackHandler[requestId] then 
        return tostring(requestId)
    else
        GenerateCallbackHandlerKey()
    end
end

----------------------------------------------------------------
-- NEW Method for Server Callbacks
----------------------------------------------------------------
MSK.Register = function(eventName, cb)
    Callbacks[eventName] = cb
end
MSK.RegisterCallback = MSK.Register
MSK.RegisterServerCallback = MSK.Register
exports('Register', MSK.Register)
exports('RegisterCallback', MSK.Register)
exports('RegisterServerCallback', MSK.Register)

RegisterNetEvent('msk_core:server:triggerServerCallback', function(eventName, requestId, ...)
    local playerId = source

    if not Callbacks[eventName] then 
        TriggerClientEvent('msk_core:client:callbackNotFound', playerId, requestId)
        return
    end

    TriggerClientEvent("msk_core:client:callbackResponse", playerId, requestId, Callbacks[eventName](playerId, ...))
end)

----------------------------------------------------------------
-- NEW Method for Client Callbacks
----------------------------------------------------------------
MSK.Trigger = function(eventName, playerId, ...)
    local requestId = GenerateCallbackHandlerKey()
    local p = promise.new()
    CallbackHandler[requestId] = 'request'

    SetTimeout(5000, function()
        CallbackHandler[requestId] = nil
        p:reject(('Request Timed Out: [%s] [%s]'):format(eventName, requestId))
    end)

    TriggerClientEvent('msk_core:client:triggerClientCallback', playerId, playerId, eventName, requestId, ...)

    while CallbackHandler[requestId] == 'request' do Wait(0) end
    if not CallbackHandler[requestId] then return end

    p:resolve(CallbackHandler[requestId])
    CallbackHandler[requestId] = nil

    local result = Citizen.Await(p)
    return table.unpack(result)
end
MSK.TriggerCallback = MSK.Trigger
MSK.TriggerClientCallback = MSK.Trigger
exports('Trigger', MSK.Trigger)
exports('TriggerCallback', MSK.Trigger)
exports('TriggerClientCallback', MSK.Trigger)

RegisterNetEvent("msk_core:server:callbackResponse", function(requestId, ...)
	if not CallbackHandler[requestId] then return end
	CallbackHandler[requestId] = {...}
end)

RegisterNetEvent("msk_core:server:callbackNotFound", function(requestId)
	if not CallbackHandler[requestId] then return end
	CallbackHandler[requestId] = nil
end)

----------------------------------------------------------------
-- OLD Method for Server Callbacks [OUTDATED - Do not use this!]
----------------------------------------------------------------
RegisterNetEvent('msk_core:triggerCallback')
AddEventHandler('msk_core:triggerCallback', function(name, requestId, ...)
    local src = source
    if not Callbacks[name] then return end

    Callbacks[name](src, function(...)
        TriggerClientEvent("msk_core:responseCallback", src, requestId, ...)
    end, ...)
end)

----------------------------------------------------------------
-- Server Callbacks with New Method
----------------------------------------------------------------
MSK.Register('msk_core:hasItem', function(source, item)
    local src = source
    local xPlayer

    if Config.Framework:match('esx') then
        xPlayer = ESX.GetPlayerFromId(src)
    elseif Config.Framework:match('qbcore') then
        xPlayer = QBCore.Functions.GetPlayer(src)
    end

    return MSK.HasItem(xPlayer, item)
end)