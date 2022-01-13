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

--Cooldown manager
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		if cooldown > 0 then
			cooldown = cooldown - 5000
		end
	end
end)

--esx thread
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

--waypoint setter function
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

--mission abort function
function cancelOxy(giveMoneyBack)
	RemoveBlip(oxyBlips)

	if DoesEntityExist(oxyPed) then
		DeletePed(oxyPed)
		SetPedAsNoLongerNeeded(oxyPed)
	end

	if DoesEntityExist(oxyPed) then
		DeletePed(deliveryPed)
		SetPedAsNoLongerNeeded(deliveryPed)
	end

	if DoesEntityExist(vehicle) then
		DeleteVehicle(vehicle)
	end

	hasStarted = not hasStarted

	TriggerServerEvent('atlantis_oxy:removeStash', Config.startItem, Config.mAccount, Config.startAmount, giveMoneyBack)

	TriggerEvent('mythic_notify:client:SendAlert', {type = 'inform', text = _U('mission_cancelled'), length = 2500})
end

--initialization events
RegisterNetEvent('atlantis_oxy:initOxy')
AddEventHandler('atlantis_oxy:initOxy', function()
	if cooldown <= 0 then
		if Config.usebMoney then
			TriggerServerEvent('atlantis_oxy:checkMoney', Config.mAccount, Config.startAmount)
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

	RequestModel(GetHashKey(Config.peds.sellers[randomPedSeller].model))
	while not HasModelLoaded(GetHashKey(Config.peds.sellers[randomPedSeller].model)) do
		Citizen.Wait(1)
	end

    if not DoesEntityExist(oxyPed) then
		oxyPed = CreatePed(Config.peds.sellers[randomPedSeller].type, Config.peds.sellers[randomPedSeller].model, Config.npcLocations[randomPed].position, Config.npcLocations[randomPed].heading, false, false)
		FreezeEntityPosition(oxyPed, true)
		SetEntityInvincible(oxyPed, true)
		SetBlockingOfNonTemporaryEvents(oxyPed, true)
		TaskStartScenarioInPlace(oxyPed, "WORLD_HUMAN_COP_IDLES", 0, true)
	end
	SetModelAsNoLongerNeeded(Config.peds.sellers[randomPedSeller].model)
end)

--main event
RegisterNetEvent('atlantis_oxy:packageRecovery')
AddEventHandler('atlantis_oxy:packageRecovery', function()
	randomDelivery = math.random(1, #Config.deliveryPoints)
	randomPedDelivery = math.random(1, #Config.peds.buyers)
	randomModel = math.random(1, #Config.vehicleModels)

	--setting the waypoint
	setWaypoint(Config.deliveryPoints[randomDelivery], _U('exchange'))

	--generate ped
	local pedModel = Config.peds.buyers[randomPedDelivery].model
	local pedType = Config.peds.buyers[randomPedDelivery].type
	local pedHash = GetHashKey(Config.peds.buyers[randomPedDelivery].model)
	
	RequestModel(pedHash)
	while not HasModelLoaded(pedHash) do
		Citizen.Wait(10)
	end

	if not DoesEntityExist(deliveryPed) then
		deliveryPed = CreatePed(pedType, pedModel, 352.7, -142.4, 66.7, 339.2, false, false)
		SetEntityInvincible(deliveryPed, true)
		SetBlockingOfNonTemporaryEvents(deliveryPed, true)
		SetEntityAsMissionEntity(deliveryPed, true, true)
	end

	SetModelAsNoLongerNeeded(pedModel)

	--generate vehicle
	local vehicleModel = Config.vehicleModels[randomModel]
	local vehicleHash = GetHashKey(Config.vehicleModels[randomModel])

	RequestModel(vehicleHash)
	while not HasModelLoaded(vehicleHash) do
		Citizen.Wait(10)
	end

	if not DoesEntityExist(vehicle) then
		vehicle = CreateVehicle(vehicleHash, 351.6, -131.0, 66.2, 339.51, false, false)
		SetVehicleNumberPlateText(vehicle, _U('custom_plate'))
		SetEntityAsMissionEntity(vehicle, true, true)
	end

	SetModelAsNoLongerNeeded(vehicleModel)

	--ped enters the vehicle
	TaskWarpPedIntoVehicle(deliveryPed, vehicle, -1)

	--ped drives to the desired location
	TaskVehicleDriveToCoordLongrange(deliveryPed, vehicle, Config.deliveryPoints[randomDelivery], Config.vehSpeed, Config.dType, 1.0)
end)

RegisterNetEvent('atlantis_oxy:waitTime')
AddEventHandler('atlantis_oxy:waitTime', function()
	Citizen.Wait(20000)
	TriggerEvent('atlantis_oxy:packageRecovery')
end)

--main thread
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.TickTime)
		
		if hasStarted and DoesEntityExist(oxyPed) and suspicious ~= 0 then
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
				_U('recoverPacket'), _U('cancel')
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

--first thread related events
AddEventHandler('atlantis_oxy:addPackage', function()
	TriggerServerEvent('atlantis_oxy:invAdder', Config.startItem, suspicious)
	suspicious = 0
end)

AddEventHandler('atlantis_oxy:cancelOxy', function()
	cancelOxy(true)
end)

AddEventHandler('atlantis_oxy:exchangePackage', function()
	--disable qtarget
	exports.qtarget:RemoveVehicle({
		_U('deliver_pack')
	})
	
	TriggerServerEvent('atlantis_oxy:packageToOxy', Config.startItem, Config.rewardItem)
end)

--ped related events
RegisterNetEvent('atlantis_oxy:driveAway')
AddEventHandler('atlantis_oxy:driveAway', function()
	TaskVehicleDriveToCoordLongrange(deliveryPed, vehicle, 489.8, -51.0, 89.4, Config.vehSpeed, Config.dType, 1.0)

	Citizen.Wait(20000)

	DeletePed(deliveryPed)
    SetPedAsNoLongerNeeded(deliveryPed)

	DeleteVehicle(vehicle)
end)

--reset
RegisterNetEvent('atlantis_oxy:resetFlag')
AddEventHandler('atlantis_oxy:resetFlag', function()
	hasStarted = not hasStarted
	
	if DoesEntityExist(oxyPed) then
		DeletePed(oxyPed)
		SetPedAsNoLongerNeeded(oxyPed)
	end

	if DoesEntityExist(oxyPed) then
		DeletePed(deliveryPed)
		SetPedAsNoLongerNeeded(deliveryPed)
	end

	if DoesEntityExist(vehicle) then
		DeleteVehicle(vehicle)
	end
end)

--positions related thread
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