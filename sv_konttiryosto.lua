ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function distancecheck(source)
    for k, v in pairs(Config.Kontit) do
        for i = 1, #v.Kohdat do
            local dist = #(GetEntityCoords(GetPlayerPed(source)) - v.Kohdat[i].Paikka)
            if dist <= 1.5 then
                return true
            end
        end
    end
    return false
end

ESX.RegisterServerCallback('esx_konttiryosto:getDoorFreezeStatus', function(source, cb, house)
    cb(Config.Kontit[house].Ovi.Kiinni)
end)

RegisterServerEvent('esx_konttiryosto:setDoorFreezeStatus')
AddEventHandler('esx_konttiryosto:setDoorFreezeStatus', function(house, status, position)
    if status == false then
        local src = source
        local cops = 0
        local xPlayers = ESX.GetPlayers()
        for i = 1, #xPlayers do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer.job.name == 'police' then
                cops = cops + 1
            end
        end
        if cops >= Config.Kontit[house].Poliisit then
            Config.Kontit[house].Ovi.Kiinni = status
            if Config.BlipIlmoitus == true then
                local xPlayers = ESX.GetPlayers()
                for i=1, #xPlayers, 1 do
                    local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
                    if xPlayer.job.name == 'police' then
                        TriggerClientEvent('esx:showNotification', xPlayers[i], 'Kontin murto käynnissä!')
                        TriggerClientEvent('esx_konttiryosto:setBlip', xPlayers[i], position)
                    end
                end
            end
        else
            TriggerClientEvent('esx:showNotification', src, 'Kaupungissa pitää olla vähintään ~b~'..Config.Kontit[house].Poliisit..' poliisia~s~!')
        end
    else
        Config.Kontit[house].Ovi.Kiinni = status
        if Config.BlipIlmoitus == true then
            local xPlayers = ESX.GetPlayers()
            for i=1, #xPlayers, 1 do
                local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
                if xPlayer.job.name == 'police' then
                    TriggerClientEvent('esx_konttiryosto:killBlip', xPlayers[i])
                end
            end
        end
    end
    TriggerClientEvent('esx_konttiryosto:setFrozen', -1, house, Config.Kontit[house].Ovi.Kiinni)
end)

RegisterServerEvent('esx_konttiryosto:loot')
AddEventHandler('esx_konttiryosto:loot', function(house, furniture)
    local src = source
    if not distancecheck(src) then TriggerClientEvent('esx:showNotification', src, 'lolz noobz') return end
    local cops = 0
    local xPlayers = ESX.GetPlayers()
    for i = 1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            cops = cops + 1
        end
    end
    if cops >= Config.Kontit[house].Poliisit then
        Wait(6500)
        local xPlayer = ESX.GetPlayerFromId(src)
        local randomItem = math.random(1, #Config.Tavarat)
        local randomAmount = math.random(1, 3)
        xPlayer.addInventoryItem(Config.Tavarat[randomItem].Database, randomAmount)
        TriggerClientEvent('esx:showNotification', src, 'Löysit x' .. randomAmount .. ' ' .. Config.Tavarat[randomItem].Nimi)
    else
        TriggerClientEvent('esx:showNotification', src, 'Kaupungissa pitää olla vähintään ~b~'..Config.Kontit[house].Poliisit..' poliisia~s~!')
    end
end)

function TiirikanMaaraMuutos(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	local tiirikka = xPlayer.getInventoryItem(Config.Murtoitemi).count
	if tiirikka > 0 then
		TriggerClientEvent('esx_konttiryosto:onkotiirikka', source, true)
	else
		TriggerClientEvent('esx_konttiryosto:onkotiirikka', source, false)
	end

end

AddEventHandler('esx:playerLoaded', function(source)
	TiirikanMaaraMuutos(source)
end)

AddEventHandler('esx:onAddInventoryItem', function(source, item, count)
	if item.name == Config.Murtoitemi then
		TiirikanMaaraMuutos(source)
	end
end)

AddEventHandler('esx:onRemoveInventoryItem', function(source, item, count)
	if item.name == Config.Murtoitemi then
		TiirikanMaaraMuutos(source)
	end
end)
