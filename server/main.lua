ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

RegisterServerEvent('atlantis_oxy:clearMoney')
AddEventHandler('atlantis_oxy:clearMoney', function(mAccount, mAmount)
    local xPlayer = ESX.GetPlayerFromId(source)

    local xAccount = xPlayer.getAccount(mAccount).money

    if xAccount >= mAmount then
        xPlayer.removeAccountMoney(mAccount, mAmount)
        TriggerClientEvent('atlantis_oxy:startOxy', source)
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = _U('not_enough_bmoney'), length = 2500})
    end
end)

RegisterServerEvent('atlantis_oxy:itemAdder')
AddEventHandler('atlantis_oxy:itemAdder', function(iName)
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.addInventoryItem(iName, 1)
end)

--[[
    @sPackage: package item name
    @dOxy: oxy item name
]]
RegisterServerEvent('atlantis_oxy:giveOxy')
AddEventHandler('atlantis_oxy:giveOxy', function(sPackage, dOxy)
    local xPlayer = ESX.GetPlayerFromId(source)

    local xPackage = xPlayer.getInventoryItem(sPackage).count
    local finalOxy = math.random(1, Config.maxOxy)

    if xPackage > 0 and xPackage ~= 1 then
        xPlayer.removeInventoryItem(sPackage, 1)
        xPlayer.addInventoryItem(dOxy, finalOxy)
        TriggerClientEvent('atlantis_oxy:driveAway', source)
        TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'inform', text = _U('another_buyer'), length = 2500})
        TriggerClientEvent('atlantis_oxy:waitTime', source)
    elseif xPackage == 1 then
        xPlayer.removeInventoryItem(sPackage, 1)
        xPlayer.addInventoryItem(dOxy, finalOxy)
        local clearedMoney = math.floor((Config.startAmount*15)/2.05)
        xPlayer.addAccountMoney('money', clearedMoney)
        TriggerClientEvent('atlantis_oxy:driveAway', source)
        TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'inform', text = _U('jComplted', clearedMoney), length = 2500})
        TriggerClientEvent('atlantis_oxy:resetFlag', source)
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = _U('no_packages'), length = 2500})
    end
end)

--[[
    @sPackage: package item name
    @mAccount: money account name
    @mAmount: money amount
    @mBack: money back
]]
RegisterServerEvent('atlantis_oxy:removeStash')
AddEventHandler('atlantis_oxy:removeStash', function(sPackage, mAccount, mAmount, mBack)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPackage = xPlayer.getInventoryItem(sPackage).count

    if mBack then
        xPlayer.removeInventoryItem(sPackage, xPackage)
        xPlayer.addAccountMoney(mAccount, mAmount)
    else
        xPlayer.removeInventoryItem(sPackage, xPackage)
    end
end)

-- Version Checker
PerformHttpRequest("https://raw.githubusercontent.com/xxpromw3mtxx/atlantis_oxy/main/.version", function(err, text, headers)
    Citizen.Wait(2000)
    local curVer = GetResourceMetadata(GetCurrentResourceName(), "version")

    if (text ~= nil) then
        if (text ~= curVer) then
            print '^1-----------------------------------------^0'
            print '^1      UPDATE AVAILABLE ATLANTIS_OXY      ^0'
            print '^1          GET IT ON GITHUB NOW           ^0'
            print '^1-----------------------------------------^0'
        else
            print("^2ATLANTIS_OXY is up to date!^0")
        end
    else
        print '^1----------------------------------------^0'
        print '^1      ERROR GETTING ONLINE VERSION      ^0'
        print '^1----------------------------------------^0'
    end 
end)