MSK.Numpad = {}

local isNumpadOpen = false
local callback = nil

MSK.Numpad.Open = function(pin, show, cb)
    if isNumpadOpen then return end
    isNumpadOpen = true
    callback = cb
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openNumpad',
        code = tostring(pin),
        length = string.len(tostring(pin)),
        show = show,
        EnterCode = 'Enter Code',
        WrongCode = 'Incorrect',
    })

    if not callback then
        local p = promise.new()

        callback = function(response)
            p:resolve(response)
        end

        local result = Citizen.Await(p)
        return result
    end
end
exports('Numpad', MSK.Numpad.Open)

-- Support for old Scripts
setmetatable(MSK.Numpad, {
    __call = function(_, pin, show, cb)
        -- Ruft MSK.Numpad.Open auf, wenn MSK.Numpad() aufgerufen wird
        return MSK.Numpad.Open(pin, show, cb)
    end
})

MSK.Numpad.Close = function()
    isNumpadOpen = false
    callback = nil
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeNumpad'
    })
end
MSK.CloseNumpad = MSK.Numpad.Close
exports('CloseNumpad', MSK.Numpad.Close)
RegisterNetEvent('msk_core:closeNumpad', MSK.Numpad.Close)

MSK.Register('msk_core:numpad', function(source, pin, show)
    return MSK.Numpad.Open(pin, show)
end)

RegisterNUICallback('submitNumpad', function(data)
    callback(true)
    MSK.Numpad.Close()
end)

RegisterNUICallback('closeNumpad', function()
    MSK.Numpad.Close()
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    MSK.Numpad.Close()
end)
  