ESX                           = nil
local ESXLoaded = false

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

    ESXLoaded = true
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterNetEvent('esx_konttiryosto:setFrozen')
AddEventHandler('esx_konttiryosto:setFrozen', function(house, status)
    Config.Kontit[house].Ovi.Kiinni = status
    local door = GetClosestObjectOfType(Config.Kontit[house].Ovi.Koordinaatit, 2.0, GetHashKey(Config.Kontit[house].Ovi.Objekti), false, 0, 0)
    FreezeEntityPosition(door, status)
end)

Citizen.CreateThread(function()
    Wait(50)
    for i = 1, #Config.Kontit do
        ESX.TriggerServerCallback('esx_konttiryosto:getDoorFreezeStatus', function(frozen)
            print(frozen)
            Config.Kontit[i].Ovi.Kiinni = frozen
            local door = GetClosestObjectOfType(Config.Kontit[i].Ovi.Koordinaatit, 2.0, GetHashKey(Config.Kontit[i].Ovi.Objekti), false, 0, 0)
            FreezeEntityPosition(door, Config.Kontit[i].Ovi.Kiinni)
        end, i)
    end
    while true do
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        for i = 1, #Config.Kontit do
            Wait(0)
            local v = Config.Kontit[i]
            local d = v.Ovi
            local door = GetClosestObjectOfType(d.Koordinaatit, 2.0, GetHashKey(d.Objekti), false, 0, 0)
            if door ~= nil then
                FreezeEntityPosition(door, d.Kiinni)
                if d.Kiinni then
                    SetEntityHeading(door, d.Suunta)
                end
            end
            if GetDistanceBetweenCoords(coords, d.Koordinaatit, true) <= 2.0 and d.Kiinni and ESX.PlayerData.job.name == 'police' then
                if tiirikka then
                    ESX.ShowHelpNotification('Paina ~INPUT_CONTEXT~ murtaaksesi oven')
                    if IsControlPressed(0, 38) then
                        TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
					    Citizen.Wait(15000)
					    if IsPedUsingAnyScenario(PlayerPedId()) == false then
						    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
					    end
                        Citizen.Wait(15000)
					    if IsPedUsingAnyScenario(PlayerPedId()) then
                            ClearPedTasks(PlayerPedId())
                            ESX.ShowNotification('~g~Onnistuit murrossa!')
                            TriggerServerEvent('esx_konttiryosto:setDoorFreezeStatus', i, false)
                            TriggerServerEvent('esx_addons_gcphone:startCall', 'police', 'Konttimurto', coords, {
                                coords = { x = d.Koordinaatit.x, y = d.Koordinaatit.y, z = d.Koordinaatit.z },
                            })
                        end
                    end
                end
            elseif ESX.PlayerData.job.name ~= 'police' and not d.Kiinni and GetDistanceBetweenCoords(coords, d.Koordinaatit, true) <= 2.0 then
                ESX.ShowHelpNotification('Paina ~INPUT_CONTEXT~ korjataksesi oven')
                if IsControlPressed(0, 38) then
                    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
					Citizen.Wait(15000)
					if IsPedUsingAnyScenario(PlayerPedId()) == false then
						TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
					end
                    Citizen.Wait(15000)
					if IsPedUsingAnyScenario(PlayerPedId()) then
                        ClearPedTasks(PlayerPedId())
                        ESX.ShowNotification('~g~Onnistuit!')
                        TriggerServerEvent('esx_konttiryosto:setDoorFreezeStatus', i, true)
                    end
                end
            end
        end
        Wait(50)
    end
end)

Citizen.CreateThread(function()
    while true do
        for k, v in pairs(Config.Kontit) do
            for i = 1, #v.Kohdat do
                local player = PlayerPedId()
                local coords = GetEntityCoords(player)
                if GetDistanceBetweenCoords(coords, v.Kohdat[i].Paikka, true) <= 1.5 and not v.Ovi.Kiinni then
                    if not v.Kohdat[i].Otettu then
                        ESX.ShowHelpNotification('Paina ~INPUT_CONTEXT~ tutkiaksesi kaappia')
                        DrawMarker(23, v.Kohdat[i].Paikka.x, v.Kohdat[i].Paikka.y, v.Kohdat[i].Paikka.z-1.0, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 100, false, true, 2, nil, nil, false)
                        if IsControlPressed(0, 38) then
                            if GetDistanceBetweenCoords(GetEntityCoords(player), v.Kohdat[i].Paikka, true) <= 1.5 then
                                v.Kohdat[i].Otettu = true
                                TriggerServerEvent('esx_konttiryosto:loot', k, i)
                                SetEntityHeading(player, v.Kohdat[i].Suunta)
                                FreezeEntityPosition(player, true)
                                TaskStartScenarioInPlace(player, "PROP_HUMAN_BUM_BIN", 0, true)
                                Wait(5000)
                                ClearPedTasks(player)
                                Wait(2500)
                                FreezeEntityPosition(player, false)
                            end
                        end
                    end
                end
            end
        end
        Wait(0)
    end
end)

RegisterNetEvent('esx_konttiryosto:onkotiirikka')
AddEventHandler('esx_konttiryosto:onkotiirikka', function(onkovaiei)
	onkotiirikka = onkovaiei
end)