ESX = nil
local cooldown = 0
local anycops = 0

TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

--[[
    event that checks if the player has the money to start the mission
    @mAccount - money account name
    @mAmount - money amount
]]
RegisterServerEvent('atlantis_oxy:checkMoney')
AddEventHandler('atlantis_oxy:checkMoney', function(mAccount, mAmount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local moneyAmount = xPlayer.getAccount(mAccount).money

    if moneyAmount >= mAmount then
        xPlayer.removeAccountMoney(mAccount, mAmount)
        --update cooldown
	    cooldown = Config.CooldownMinutes * 60000
        TriggerClientEvent('atlantis_oxy:startOxy', source)
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = _U('not_enough_bmoney'), length = 2500})
    end
end)

--Check if cops are online
ESX.RegisterServerCallback('atlantis_oxy:copsOn',function(source, cb)
    local anycops = 0
    local playerList = ESX.GetPlayers()
    for i=1, #playerList, 1 do
        local _source = playerList[i]
        local xPlayer = ESX.GetPlayerFromId(_source)
        local playerjob = xPlayer.job.name
      
        if playerjob == 'police' then
            anycops = anycops + 1
        end
    end
    cb(anycops)
end)

--Cooldown callback event
ESX.RegisterServerCallback('atlantis_oxy:isCooled',function(source, cb)
    cb(cooldown)
end)

--[[
    event that add the item to the player stash,
    and starts the packages recovery
    @iName - item name
    @iQuantity - item quantity
]]
RegisterServerEvent('atlantis_oxy:invAdder')
AddEventHandler('atlantis_oxy:invAdder', function(iName, iQuantity)
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.addInventoryItem(iName, iQuantity)

    TriggerClientEvent('atlantis_oxy:packageRecovery', source)
end)

--[[
    event that checks exchange suspicious packages with a random amount of oxy
    @sPackage: package item name
    @dOxy: oxy item name
]]
RegisterServerEvent('atlantis_oxy:packageToOxy')
AddEventHandler('atlantis_oxy:packageToOxy', function(sPackage, dOxy)
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
        TriggerClientEvent('atlantis_oxy:driveAway', source)

        local clearedMoney = math.floor((Config.startAmount*15)/2.05)
        xPlayer.addAccountMoney('money', clearedMoney)
        
        TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'inform', text = _U('jComplted', clearedMoney), length = 2500})
        TriggerClientEvent('atlantis_oxy:resetFlag', source)
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, {type = 'error', text = _U('no_packages'), length = 2500})
    end
end)

--[[
    this event works only if the player drops the job or dies
    @sPackage: package item name
    @mAccount: money account name
    @mAmount: money amount
    @mBack: money back (boolean)
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

--Cooldown manager
AddEventHandler('onResourceStart', function(resource)
	while true do
		Citizen.Wait(5000)
		if cooldown > 0 then
			cooldown = cooldown - 5000
		end
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