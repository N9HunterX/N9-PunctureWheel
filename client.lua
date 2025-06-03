local QBCore = exports['qb-core']:GetCoreObject()
local PUNCTURE_ITEM = "nail"

local boneIndexes = {
    { name = "wheel_lf", index = 0 },
    { name = "wheel_rf", index = 1 },
    { name = "wheel_lm", index = 2 },
    { name = "wheel_rm", index = 3 },
    { name = "wheel_lr", index = 4 },
    { name = "wheel_rr", index = 5 }
}

local currentTargets = {}

local function addWheelTargets(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return end

    local vehNetId = NetworkGetNetworkIdFromEntity(vehicle)
    if currentTargets[vehNetId] then return end

    currentTargets[vehNetId] = true

    for _, wheel in pairs(boneIndexes) do
        local bone = GetEntityBoneIndexByName(vehicle, wheel.name)
        if bone ~= -1 then
            exports['qb-target']:AddTargetBone(wheel.name, {
                options = {
                    {
                        icon = "fas fa-bolt",
                        label = "Puncture Wheel",
                        canInteract = function(entity, distance, data)
                            return entity == vehicle and not IsVehicleTyreBurst(vehicle, wheel.index, false)
                        end,
                        action = function(entity)
                            QBCore.Functions.TriggerCallback('n9-puncturewheel:hasItem', function(hasItem)
                                if hasItem then
                                    local playerPed = PlayerPedId()
                                    TaskTurnPedToFaceEntity(playerPed, entity, 1000)
                                    Wait(500)
                                    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)
                                    QBCore.Functions.Progressbar("puncture_wheel", "Puncturing Wheel...", 3000, false, true, {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    }, {}, {}, {}, function() -- Done
                                        ClearPedTasks(playerPed)
                                        local netId = NetworkGetNetworkIdFromEntity(entity)
                                        TriggerServerEvent("n9-puncturewheel:syncPuncture", netId, wheel.index)
                                        TriggerServerEvent("n9-puncturewheel:useItem")
                                    end, function() -- Cancel
                                        ClearPedTasks(playerPed)
                                    end)
                                else
                                    QBCore.Functions.Notify("You need a nail to do this!", "error")
                                end
                            end, PUNCTURE_ITEM)
                        end
                    }
                },
                distance = 2.0,
                entity = vehicle
            })
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local vehicle = GetClosestVehicle(coords, 5.0, 0, 70)

        if vehicle and DoesEntityExist(vehicle) then
            addWheelTargets(vehicle)
        else
            -- You can implement removing targets here if desired
        end

        Citizen.Wait(3000)
    end
end)

RegisterNetEvent("n9-puncturewheel:clientSyncPuncture")
AddEventHandler("n9-puncturewheel:clientSyncPuncture", function(netId, wheelIndex)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(vehicle) then
        SetVehicleTyreBurst(vehicle, wheelIndex, false, 1000.0)
    end
end)