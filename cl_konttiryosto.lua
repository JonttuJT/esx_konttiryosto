ESX = nil
local ESXLoaded = false
local blipRobbery = nil

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

RegisterNetEvent('esx_konttiryosto:killBlip')
AddEventHandler('esx_konttiryosto:killBlip', function()
	RemoveBlip(blipRobbery)
end)

RegisterNetEvent('esx_konttiryosto:setBlip')
AddEventHandler('esx_konttiryosto:setBlip', function(position)
	blipRobbery = AddBlipForCoord(position.x, position.y, position.z)

	SetBlipSprite(blipRobbery, 161)
	SetBlipScale(blipRobbery, 2.0)
	SetBlipColour(blipRobbery, 3)

	PulseBlip(blipRobbery)
end)

Citizen.CreateThread(function()
    for i = 1, #Config.Kontit do
        ESX.TriggerServerCallback('esx_konttiryosto:getDoorFreezeStatus', function(frozen)
            --print(frozen)
            Config.Kontit[i].Ovi.Kiinni = frozen
            local door = GetClosestObjectOfType(Config.Kontit[i].Ovi.Koordinaatit, 2.0, GetHashKey(Config.Kontit[i].Ovi.Objekti), false, 0, 0)
            FreezeEntityPosition(door, Config.Kontit[i].Ovi.Kiinni)
        end, i)
    end
    while true do
        local sleep = 2000
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        for i = 1, #Config.Kontit do
            local v = Config.Kontit[i]
            local d = v.Ovi
            local door = GetClosestObjectOfType(d.Koordinaatit, 2.0, GetHashKey(d.Objekti), false, 0, 0)
            local dist = #(coords - d.Koordinaatit)

            if door then
                FreezeEntityPosition(door, d.Kiinni)
                if d.Kiinni then
                    SetEntityHeading(door, d.Suunta)
                end
            end
            if tiirikka or GetSelectedPedWeapon(player) == GetHashKey("WEAPON_CROWBAR") then
                if dist <= 10.0 then
                    sleep = 0
                end
                if dist <= 2.0 then
                    if d.Kiinni and ESX.PlayerData.job.name ~= 'police' then
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
                                TriggerServerEvent('esx_konttiryosto:setDoorFreezeStatus', i, false, d.Koordinaatit)
                                if Config.BlipIlmoitus == false then
                                    TriggerServerEvent('esx_addons_gcphone:startCall', 'police', 'Konttimurto', coords, {
                                        coords = { x = d.Koordinaatit.x, y = d.Koordinaatit.y, z = d.Koordinaatit.z },
                                    })
                                end
                            else 
                                ESX.ShowNotification('~r~Epäonnistuit murrossa!')
                            end
                        end
                    else
                        sleep = 2000
                    end
                elseif not d.Kiinni and ESX.PlayerData.job.name == 'police' then
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
                            TriggerServerEvent('esx_konttiryosto:setDoorFreezeStatus', i, true, d.Koordinaatit)
                        end
                    end
                end
            else
                sleep = 4000
            end
        end
        Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 2000
        for k, v in pairs(Config.Kontit) do
            for i = 1, #v.Kohdat do
                local player = PlayerPedId()
                local coords = GetEntityCoords(player)
                local dist = #(coords - v.Kohdat[i].Paikka)
                if dist <= 5 then
                    sleep = 0
                end
                if not v.Ovi.Kiinni then
                    if dist <= 0.5 then
                        if not v.Kohdat[i].Otettu then
                            ESX.ShowHelpNotification('Paina ~INPUT_CONTEXT~ tutkiaksesi kaappia')
                            DrawMarker(23, v.Kohdat[i].Paikka.x, v.Kohdat[i].Paikka.y, v.Kohdat[i].Paikka.z-1.0, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.5, 0.5, 0.5, 255, 0, 0, 100, false, true, 2, nil, nil, false)
                            if IsControlPressed(0, 38) then
                                if dist <= 0.5 then
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
                        else
                            sleep = 2000
                        end
                    end
                else
                    sleep = 2000
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('esx_konttiryosto:onkotiirikka')
AddEventHandler('esx_konttiryosto:onkotiirikka', function(onkovaiei)
	tiirikka = onkovaiei
end)
