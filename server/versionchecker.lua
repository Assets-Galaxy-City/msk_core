local AUTHOR    = "Musiker15"
local NAME      = "VERSIONS"
local FILE      = "Lib.json"

local RESOURCE_NAME     = "msk_core"
local NAME_COLORED      = "[^2"..GetCurrentResourceName().."^0]"
local GITHUB_URL        = "https://raw.githubusercontent.com/%s/%s/main/%s"
local DOWNLOAD_URL      = "https://github.com/MSK-Scripts/%s/releases/tag/v%s"

local RENAME_WARNING    = NAME_COLORED .. "^3 [WARNING] This resource should not be renamed! This can lead to errors. Please rename it to^0 %s"
local CHECK_FAILED		= NAME_COLORED .. "^1 [ERROR] Version Check failed! Http Error: %s^0 - ^3Please update to the latest version.^0"
local BETA_VERSION      = NAME_COLORED .. "^3 [WARNING] Beta version detected^0 - ^5Current Version:^0 %s - ^5Latest Version:^0 %s"
local UP_TO_DATE        = NAME_COLORED .. "^2 ✓ Resource is Up to Date^0 - ^5Current Version:^2 %s ^0"
local NEW_VERSION       = NAME_COLORED .. "^3 [Update Available] ^5Current Version:^0 %s - ^5Latest Version:^0 %s\n" .. NAME_COLORED .. "^5 Download:^4 %s ^0"

local CheckResourceName = function()
    if GetCurrentResourceName() ~= RESOURCE_NAME then
        while true do
            print(RENAME_WARNING:format(RESOURCE_NAME))
            Wait(5000)
        end
    end
end

local CheckVersionCallback = function(status, response, header)
    if status ~= 200 then
        print(CHECK_FAILED:format(status))
        return
    end

    local response = json.decode(response)
    local latestVersion = response[1].version
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version")
    
    if currentVersion == latestVersion then 
        if Config.VersionChecker then
            print(UP_TO_DATE:format(currentVersion))
        end
        return 
    end

    local current = MSK.Split(currentVersion, '.')
	local latest = MSK.Split(latestVersion, '.')

    for i = 1, #current do
        if current[i] > latest[i] then
            print(BETA_VERSION:format(currentVersion, latestVersion))
            break
        end

        if current[i] < latest[i] then
            print(NEW_VERSION:format(currentVersion, latestVersion, DOWNLOAD_URL:format(RESOURCE_NAME, latestVersion)))

            for i = 1, #response do 
                if response[i].version == currentVersion then break end
                print(("%s ^3[Changelogs v%s]^0"):format(NAME_COLORED, response[i].version))

                for k = 1, #response[i].changelogs do
                    print(response[i].changelogs[k])
                end
            end

            break
        end
    end
end

VersionChecker = function()
    CreateThread(function()
        CheckResourceName()
        PerformHttpRequest(GITHUB_URL:format(AUTHOR, NAME, FILE), CheckVersionCallback)
    end)
end
VersionChecker()