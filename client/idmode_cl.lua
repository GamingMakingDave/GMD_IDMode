ESX = exports['es_extended']:getSharedObject()

local isPressed = false
local hasReceivedPlayerData = false
local playerData = nil
local playerMarkerData = {}
local groupName
local dcName

CreateThread(function()
    while true do
        Wait(1)

        if IsControlPressed(0, Config.TagHotkey) then
            isPressed = true
        else
            isPressed = false
        end

        if isPressed then
            DrawPlayerIdsInRadius()
        end
    end
end)

function DrawPlayerIdsInRadius()
    if not hasReceivedPlayerData then
        hasReceivedPlayerData = true
        ESX.TriggerServerCallback('GMD_IDMode:getAllPlayerInfos', function(data)
            playerMarkerData = data
        end, playerMarkerData or { })
    else
        Wait(Config.ShowTime * 1000)
        hasReceivedPlayerData = false
    end 
end

RegisterNetEvent('GMD_IDMode:receivediscordName')
AddEventHandler('GMD_IDMode:receivediscordName', function(discordName)
    dcName = discordName
end)


CreateThread(function()
    while true do
        if isPressed then
            if next(playerMarkerData) ~= nil then

    
                local coords = GetEntityCoords(PlayerPedId())
                local configGroup = Config.canTagUse[groupName]
                local playerIds = {}

                for k, v in pairs(GetAllPedsNearBy(configGroup.TagRange)) do

                    for f, data in ipairs(playerMarkerData) do

                        if tonumber(GetPlayerServerId(v)) == tonumber(data.id) then
                            local targetPed = GetPlayerPed(v)
                            local targetCoords = GetEntityCoords(targetPed)
                            local distance = #(coords - targetCoords)
                            local playerGroup = data.group
                            local playerNameFromData = data.name
                            local configGroup = Config.canTagUse[playerGroup]
                            local playerName = GetPlayerName(v)
                            table.insert(playerIds, data.id)
                            debugprint(GetEntityCoords(targetPed))
                            debugprint(data.name)
                            debugprint(data.group)
                            debugprint(ESX.DumpTable(configGroup))
                            debugprint(configGroup.TagRange)

                            if configGroup.CanSeePlayerGrop then
                                local uppercaseGroup = string.upper(data.group)
                                DrawCustomText(targetCoords.x, targetCoords.y, targetCoords.z + 1.45, " " .. uppercaseGroup .. " ", Config.FontGroupScale, Config.FontGroupText, Config.TagColors[playerGroup], true)
                            end

                            if configGroup.CanSeeId then
                                local idText = "~n~~n~[ ~g~ID:~w~ " .. data.id .. " ]"
                                local streamNameText = " [ ~g~Servername: ~w~" .. playerName .. " ]"
                                local inGameNameText = " [ ~g~Name: ~w~" .. data.name .. " ]~n~"

                                local totalText = idText

                                if configGroup.CanSeeServerName then
                                    totalText = totalText .. streamNameText
                                end

                                if configGroup.CanSeeIngameName then
                                    totalText = totalText .. inGameNameText
                                end

                                if configGroup.CanSeediscordName then
                                    if data.dcname then
                                        discordNameText = "~n~~n~~n~[~b~ Discord: ~w~" .. data.dcname .. " ]"
                                        DrawCustomText(targetCoords.x, targetCoords.y, targetCoords.z + 1.5, discordNameText, Config.FontDiscordScale, Config.FontDiscordText, {255, 255, 255, 215}, true)
                                    end
                                end

            

                                DrawCustomText(targetCoords.x, targetCoords.y, targetCoords.z + 1.5, totalText, Config.FontBasicScale, Config.FontBasicText, {255, 255, 255, 215}, true)
                            end
                        end
                    end
                end

                DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0, 0, 0, configGroup.TagRange, configGroup.TagRange, 1.00, 255, 0, 0, 200, false, false, 2, nil, nil, false)

            else
                Wait(500)
            end
        end
        Wait(1)
    end
end)

function GetAllPedsNearBy(distance)
    local allPlayers = ESX.Game.GetPlayers(Config.ShowOwnClientInfo)
    local basePlayer = GetEntityCoords(PlayerPedId())
    local returnPlayers = {}

        for k, v in pairs(allPlayers) do
            local targetPed = GetPlayerPed(v)
            local targetCoords = GetEntityCoords(targetPed)
            local dist = #(basePlayer - targetCoords)

            if dist < distance then
                table.insert(returnPlayers, v)
            end
        end

    return returnPlayers

end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded',function(xPlayer, isNew, skin)
 
    ESX.TriggerServerCallback('GMD_IDMode:hasPlayerGroup',function(group)
        local configGroup = Config.canTagUse[group]

        groupName = group

    end)

end)

function DrawCustomText(x, y, z, text, scale, font, color, outline)
    local onScreen, _x, _y , _z = World3dToScreen2d(x, y, z)

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(color[1], color[2], color[3], color[4])
        if outline then
            SetTextOutline()
        end
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y, _z)
    end
end