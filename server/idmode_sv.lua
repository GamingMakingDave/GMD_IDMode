ESX = exports['es_extended']:getSharedObject()

function GetdiscordID(PlayerID)
    local  discordID = ''

    for _, v in pairs(GetPlayerIdentifiers(PlayerID)) do
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            discordID = v
            break
        end
    end
    
    return discordID
end

function GetdiscordName(discordIDentifier)
    local _, _, userId = string.find(discordIDentifier, "discord:(%d+)")
    local Async = false
    local discordName = ''

    local url = ('https://discord.com/api/guilds/%s/members/%s'):format(Config.GuildId, userId)
    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            local discordData = json.decode(response)

            local filteredData = {
                user = {
                    global_name = discordData['user']['global_name'],
                    id = discordData['user']['id']
                }
            }

            discordName = filteredData.user.global_name
        else
            debugprint("Fehler beim Abrufen der Discord-Daten:", statusCode)
        end

        Async = true
    end, "GET", "", {["Authorization"] = "Bot " .. Config.DiscordBotToken})

    while not Async do 
        Wait(1)
    end

    return discordName
end

ESX.RegisterServerCallback('GMD_IDMode:getAllPlayerInfos', function(src, cb, data)
    local allPlayerInfo = {}
    
    for _, xPlayer in pairs(ESX.GetExtendedPlayers()) do
        local stopQuery = false

        for i,v in ipairs(data) do
            if xPlayer.source == v.id then 
                stopQuery = true
            end
        end

        if not stopQuery then
            local playerName = xPlayer.getName()
            local playerGroup = xPlayer.getGroup()
            local discordID = GetdiscordID(xPlayer.source)
            local discordName = GetdiscordName(discordID)

            while discordName == nil do 
                Wait(1)
            end

            local playerInfo = {
                id = xPlayer.source,
                name = playerName,
                group = playerGroup,
                dcname = discordName
            }

            table.insert(allPlayerInfo, playerInfo)
        end

        Wait(100)
    end

    for k,v in ipairs(allPlayerInfo) do
        table.insert(data, v)
    end 
      
    cb(data)
end)


ESX.RegisterServerCallback('GMD_IDMode:hasPlayerGroup', function(src, cb, data)
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        local playerGroup = xPlayer.getGroup()
        cb(playerGroup)
    end
end)