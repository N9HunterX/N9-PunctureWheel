local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('n9-puncturewheel:hasItem', function(source, cb, itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    local item = Player.Functions.GetItemByName(itemName)
    cb(item ~= nil)
end)

RegisterServerEvent("n9-puncturewheel:useItem", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName("nail")
    if item then
        Player.Functions.RemoveItem("nail", 1)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["nail"], "remove")
    end
end)

RegisterServerEvent("n9-puncturewheel:syncPuncture")
AddEventHandler("n9-puncturewheel:syncPuncture", function(netId, wheelIndex)
    TriggerClientEvent("n9-puncturewheel:clientSyncPuncture", -1, netId, wheelIndex)
end)