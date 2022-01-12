ESX = nil

--PED info
local oxyPed
local deliveryPed

--local variables
local randomPed = 1
local randomDelivery = 1
local randomPedSeller = 1
local randomPedDelivery = 1
local hasStarted = false
local vehicle
local randomModel
local drive
local cooldown = 0

--items amounts
local suspicious
local maxRewardOxy

--blip
local oxyBlips


-- Delete PED on resource stop
AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
		DeletePed(oxyPed)
        SetPedAsNoLongerNeeded(oxyPed)

		DeletePed(deliveryPed)
        SetPedAsNoLongerNeeded(deliveryPed)

		DeleteVehicle(vehicle)
	end
end)

--esx thread
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

--functions
function createNPC(pType, pModel, location, heading, isNetwork, bScriptHostPed)
	RequestModel(GetHashKey(pModel))
	while not HasModelLoaded(GetHashKey(pModel)) do
		Citizen.Wait(1)
	end

    if not DoesEntityExist(oxyPed) then
		oxyPed = CreatePed(pType, pModel, location, heading, isNetwork, bScriptHostPed)
		FreezeEntityPosition(oxyPed, true)
		SetEntityInvincible(oxyPed, true)
		SetBlockingOfNonTemporaryEvents(oxyPed, true)
		TaskStartScenarioInPlace(oxyPed, "WORLD_HUMAN_COP_IDLES", 0, true)
	end
	SetModelAsNoLongerNeeded(pModel)
end

function setWaypoint(coords, bName)
	oxyBlips = AddBlipForCoord(coords)
	SetBlipSprite(oxyBlips, 1)
	SetBlipDisplay(oxyBlips, 4)
	SetBlipScale(oxyBlips, 1.0)
	SetBlipColour(oxyBlips, 5)
	SetBlipAsShortRange(oxyBlips, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(bName)
	EndTextCommandSetBlipName(oxyBlips)

	SetBlipRoute(oxyBlips, true)

	TriggerEvent('mythic_notify:client:SendAlert', {type = 'inform', text = _U('gpsSetted'), length = 2500})
end

function generateDelivery()
	randomDelivery = math.random(1, #Config.deliveryPoints)
	randomPedDelivery = math.random(1, #Config.peds.buyers)
	randomModel = math.random(1, #Config.vehicleModels)

	local ModelHash = GetHashKey(Config.vehicleModels[randomModel])
	local pedModel = Config.peds.buyers[randomPedDelivery].model

	--ped
	RequestModel(GetHashKey(pedModel))
	while not HasModelLoaded(GetHashKey(pedModel)) do
		Citizen.Wait(1)
	end
	if not DoesEntityExist(deliveryPed) then
		deliveryPed = CreatePed(Config.peds.buyers[randomPedDelivery].type, pedModel, 264.4, -188.3, 61.6, 159.18, false, true)
		SetEntityInvincible(deliveryPed, true)
	end
	SetModelAsNoLongerNeeded(pedModel)
	SetBlockingOfNonTemporaryEvents(deliveryPed, true)
	
	--setting the waypoint
	setWaypoint(Config.deliveryPoints[randomDelivery], _U('exchange'))

	--send noti
	TriggerEvent('mythic_notify:client:SendAlert', {type = 'inform', text = _U('bComing'), length = 2500})

	--set driver ability
	SetDriverAbility(deliveryPed, 1.0)

	--spawning the vehicle
	RequestModel(ModelHash)
	while not HasModelLoaded(ModelHash) do -- Waits for the model to load with a check so it does not get stuck in an infinite loop
		Citizen.Wait(10)
	end
	vehicle = CreateVehicle(ModelHash, 275.4, -194.2, 61.6, 341.7, false, true)
	SetModelAsNoLongerNeeded(ModelHash)
	SetEntityAsMissionEntity(vehicle, true, true)
	local randomPlate = (math.random(0,9)*10000000)+(math.random(0,9)*1000000)+(math.random(0,9)*100000)+(math.random(0,9)*10000)+(math.random(0,9)*1000)+(math.random(0,9)*100)+(math.random(0,9)*10)+(math.random(0,9))
	SetVehicleNumberPlateText(vehicle, randomPlate)

	--ped goes inside the vehicle
	TaskWarpPedIntoVehicle(deliveryPed, vehicle, -1)

	--ped drives to the position
	TaskVehicleDriveToCoord(deliveryPed, vehicle, Config.deliveryPoints[randomDelivery], Config.pedVehiclemSpeed, 1.0, GetEntityModel(vehicle), Config.dType, 1.0, true)
end

function cancelOxy(giveMoneyBack)
	RemoveBlip(oxyBlips)

	DeletePed(oxyPed)
    SetPedAsNoLongerNeeded(oxyPed)

	DeletePed(deliveryPed)
    SetPedAsNoLongerNeeded(deliveryPed)

	DeleteVehicle(vehicle)

	hasStarted = not hasStarted

	TriggerServerEvent('atlantis_oxy:removeStash', Config.startItem, Config.mAccount, Config.startAmount, giveMoneyBack)

	TriggerEvent('mythic_notify:client:SendAlert', {type = 'inform', text = _U('mission_cancelled'), length = 2500})
end

--events
RegisterNetEvent('atlantis_oxy:initOxy')
AddEventHandler('atlantis_oxy:initOxy', function()
	if cooldown <= 0 then
		if Config.usebMoney then
			TriggerServerEvent('atlantis_oxy:clearMoney', Config.mAccount, Config.startAmount)
		else
			TriggerEvent('atlantis_oxy:startOxy')
		end
	else
		TriggerEvent('mythic_notify:client:SendAlert', {type = 'inform', text = _U('cooldown', math.ceil(cooldown/1000)), length = 2500})
	end
end)

RegisterNetEvent('atlantis_oxy:startOxy')
AddEventHandler('atlantis_oxy:startOxy', function()
	randomPed = math.random(1, #Config.npcLocations)
	randomPedSeller = math.random(1, #Config.peds.sellers)
	
	suspicious = math.random(1, Config.maxStartItem)
	maxRewardOxy = math.random(1, Config.maxOxy)

	hasStarted = not hasStarted
	cooldown = Config.CooldownMinutes * 60000
	
	TriggerEvent('mythic_notify:client:SendAlert', {type = 'inform', text = _U('oxyHasStarted'), length = 2500})

	setWaypoint(Config.npcLocations[randomPed].position, _U('oRecovery'))
	createNPC(Config.peds.sellers[randomPedSeller].type, Config.peds.sellers[randomPedSeller].model, Config.npcLocations[randomPed].position, Config.npcLocations[randomPed].heading, false, true)
end)

AddEventHandler('atlantis_oxy:addPackage', function()
	suspicious = suspicious - 1

	TriggerServerEvent('atlantis_oxy:itemAdder', Config.startItem)

	if suspicious == 0 then
		TriggerEvent('atlantis_oxy:initPRecovery')
	end
end)

RegisterNetEvent('atlantis_oxy:initPRecovery')
AddEventHandler('atlantis_oxy:initPRecovery', function()
	generateDelivery()
end)

RegisterNetEvent('atlantis_oxy:driveAway')
AddEventHandler('atlantis_oxy:driveAway', function()
	TaskVehicleDriveToCoord(deliveryPed, vehicle, 489.8, -51.0, 89.4, Config.pedVehiclemSpeed, 1.0, GetEntityModel(vehicle), Config.dType, 1.0, true)

	Citizen.Wait(20000)

	DeletePed(deliveryPed)
    SetPedAsNoLongerNeeded(deliveryPed)

	DeleteVehicle(vehicle)
end)

AddEventHandler('atlantis_oxy:exchangePackage', function()
	--disable qtarget
	exports.qtarget:RemoveVehicle({
		_U('deliver_pack')
	})

	TriggerServerEvent('atlantis_oxy:giveOxy', Config.startItem, Config.rewardItem)
end)

RegisterNetEvent('atlantis_oxy:waitTime')
AddEventHandler('atlantis_oxy:waitTime', function()
	Citizen.Wait(20000)
	TriggerEvent('atlantis_oxy:initPRecovery')
end)

RegisterNetEvent('atlantis_oxy:resetFlag')
AddEventHandler('atlantis_oxy:resetFlag', function()
	hasStarted = not hasStarted
end)

AddEventHandler('atlantis_oxy:cancelOxy', function()
	cancelOxy(true)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.TickTime)

		if hasStarted and suspicious ~= 0 then
			exports['qtarget']:AddTargetModel({Config.peds.sellers[randomPedSeller].model}, {
				options = {
					{
						event = "atlantis_oxy:addPackage",
						icon = "fas fa-box",
						label = _U('recoverPacket'),
						num = 1
					},
					{
						event = "atlantis_oxy:cancelOxy",
						icon = "fas fa-times",
						label = _U('cancel'),
						num = 2
					}
				},
				distance = Config.interactDistance
			})
		elseif hasStarted and suspicious == 0 then
			exports.qtarget:RemoveTargetModel({Config.peds.sellers[randomPedSeller].model}, {
				_U('recoverPacket')
			})
			Citizen.Wait(20000)
			DeletePed(oxyPed)
    		SetPedAsNoLongerNeeded(oxyPed)
		end
		
		if hasStarted and DoesEntityExist(deliveryPed) then
			exports.qtarget:Vehicle({
				options = {
					{
						event = "atlantis_oxy:exchangePackage",
						icon = "fas fa-money-bill-wave",
						label = _U('deliver_pack'),
						num = 1
					}
				},
				distance = Config.interactDistance
			})
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.TickTime)

		--get player coords and pedID
		local coords = GetEntityCoords(GetPlayerPed(-1))

		--if the mission has started, the distance between the player and the first location is lower than 10 and the packages are different from 0, removed the current blip
		if hasStarted and GetDistanceBetweenCoords(coords, Config.npcLocations[randomPed].position, false) < 10 and suspicious ~= 0 then
			RemoveBlip(oxyBlips)
		end

		--remove blip if player coords and deliverypoint distance is lower than 10
		if hasStarted and GetDistanceBetweenCoords(coords, Config.deliveryPoints[randomDelivery], false) < 10 then
			RemoveBlip(oxyBlips)
		end

		--if player dies, mission is aborted and loses all the money and stash
		if hasStarted and IsEntityDead(GetPlayerPed(-1)) then
			cancelOxy(false)
		end
	end
end)