# msk_core
Core functions for MSK Scripts

More function will be coming soon...

## Exports
clientside AND serverside
```lua
MSK = exports.msk_core:getCoreObject()
```

## Functions
### COMMON
* Debug and Error Logs
```lua
MSK.logging(code, msg, msg2, msg3)

-- example
MSK.logging('debug', 'Text 1', 'Text 2', 'Text 3')
MSK.logging('error', 'Text 1', 'Text 2', 'Text 3')
```
* Generate a Random String 
```lua
MSK.GetRandomLetter(length)

-- example
MSK.GetRandomLetter(3) -- abc
string.upper(MSK.GetRandomLetter(3)) -- ABC
```
### CLIENTSIDE
* Timeouts
```lua
timeout = MSK.AddTimeout(miliseconds, function()
    -- waits miliseconds time // asyncron
end)

MSK.DelTimeout(timeout)
```
* Trigger Syncron Server Callback
```lua
local data, data2 = MSK.TriggerCallback("Callback_Name", value1, value2, ...)
```
### SERVERSIDE
* Discord Webhook *[msk_webhook is required]*
```lua
-- example can be found here: https://github.com/MSK-Scripts/msk_webhook
MSK.AddWebhook(webhook, botColor, botName, botAvatar, title, description, fields, footer, time)
```
* Register Syncron Server Callback
```lua
MSK.RegisterCallback("Callback_Name", function(source, cb, value1, value2)
    cb(value1, value2)
end)
```

## Requirements
* oxmysql