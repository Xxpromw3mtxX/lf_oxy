ESX = nil
--PED info
local oxyPed
local deliveryPed
--local variables
local randomPed = 1
local randomPedSeller = 1											--Do i really need to explain this part to you?
local randomPedDelivery = 1											--Could we have less variables? Maybe... maybe....
local hasStarted = false											--Do you think i have the time and the will to do it?
local vehicle														--Absolutely not
local randomModel													--Enjoy my man <3 (lilfraae/Xxpromw3mtxX)
local drive															
--items amounts
local suspicious
local maxRewardOxy
--blip
local oxyBlips

--[[
	as i just said...
	i'm tired
	and yeah the comments are bottom-up KEK
]]
AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
		DeletePed(oxyPed)
        SetPedAsNoLongerNeeded(oxyPed)

		DeletePed(deliveryPed)
        SetPedAsNoLongerNeeded(deliveryPed)

		DeleteVehicle(vehicle)
	end
end)

--[[
	initializes ESX variable?
	never used tho?
	but who knows 
]]
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

--[[
	actually you know what?
	i'm tired to write comments, since these functions are autoexplicativo
]]
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

--[[
	come on...
	it's pretty clear what this function does.
]]
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

--[[
	initialization event.
	does pretty much nothing, just checks if the player have the money to be cleaned 
	and then the server says: <OKAYYYYYYY LES GO>, calling the underneath event.
]]
RegisterNetEvent('atlantis_oxy:initOxy')
AddEventHandler('atlantis_oxy:initOxy', function()
	ESX.TriggerServerCallback('atlantis_oxy:isCooled', function(cooldown)
		if cooldown <= 0 then
			ESX.TriggerServerCallback('atlantis_oxy:copsOn', function(anycops)
				if anycops >= Config.minCops then
					if Config.usebMoney then
						TriggerServerEvent('atlantis_oxy:checkMoney', Config.mAccount, Config.startAmount)
					else
						TriggerEvent('atlantis_oxy:startOxy')
					end
				else
					TriggerEvent('mythic_notify:client:SendAlert', {type = 'error', text = _U('not_enough_cops'), length = 2500})
				end
			end)
		else
			TriggerEvent('mythic_notify:client:SendAlert', {type = 'inform', text = _U('cooldown', math.ceil(cooldown/1000)), length = 2500})
		end
	end)
end)

RegisterNetEvent('atlantis_oxy:startOxy')
AddEventHandler('atlantis_oxy:startOxy', function()
	randomPed = math.random(1, #Config.npcLocations)
	randomPedSeller = math.random(1, #Config.peds.sellers)
	
	suspicious = math.random(1, Config.maxStartItem)
	maxRewardOxy = math.random(1, Config.maxOxy)

	hasStarted = not hasStarted
	
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

--[[
	package recovery event, where the magic happens!
	basically does all the remaining job.
	generates a random ped, between the ped.buyers array,
	a random vehicle model and then generates the ped and the vehicle.
	the ped goes into the vehicle and then he starts to drive to the
	desired location.
]]
RegisterNetEvent('atlantis_oxy:packageRecovery')
AddEventHandler('atlantis_oxy:packageRecovery', function()
	randomPedDelivery = math.random(1, #Config.peds.buyers)
	randomModel = math.random(1, #Config.vehicleModels)

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
		vehicle = CreateVehicle(vehicleHash, Config.deliveryPoint.pStart, Config.deliveryPoint.pHeading, false, false)
		SetVehicleNumberPlateText(vehicle, _U('custom_plate'))
		SetEntityAsMissionEntity(vehicle, true, true)
	end

	SetModelAsNoLongerNeeded(vehicleModel)

	--ped enters the vehicle
	SetPedIntoVehicle(deliveryPed, vehicle, -1)

	--setting driver ability
	SetDriverAbility(deliveryPed, 1.0)

	--ped drives to the desired location
	TaskVehicleDriveToCoordLongrange(deliveryPed, vehicle, Config.deliveryPoint.delPoint, Config.vehSpeed, Config.dType, 0.2)
end)

--[[
	this is just an event that adds a timer between a recovery and a other one.
]]
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
	--setting the waypoint
	setWaypoint(Config.deliveryPoint.delPoint, _U('exchange'))
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

--[[
	this event is need to make the ped drive away from the current delivery location.
	after 20 sec it goes into the void.
]]
RegisterNetEvent('atlantis_oxy:driveAway')
AddEventHandler('atlantis_oxy:driveAway', function()
	TaskVehicleDriveToCoordLongrange(deliveryPed, vehicle, 489.8, -51.0, 89.4, Config.vehSpeed, Config.dType, 1.0)

	Citizen.Wait(20000)

	DeletePed(deliveryPed)
    SetPedAsNoLongerNeeded(deliveryPed)

	DeleteVehicle(vehicle)
end)

--[[
	reset event.
	when the player has exchanged all his suspicious packages,
	this event gets called, and after 20 sec, clear all the remainings data structures/tables/ecc....
]]
RegisterNetEvent('atlantis_oxy:resetFlag')
AddEventHandler('atlantis_oxy:resetFlag', function()
	Citizen.Wait(20000)
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

--[[
	this thread jobs is to check if the player is near one of the delivery or recovery points, and if he's alive.
	the ifs are working only if the job has started. 
]]
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
		if hasStarted and GetDistanceBetweenCoords(coords, Config.deliveryPoint.delPoint, false) < 30 then
			RemoveBlip(oxyBlips)
		end

		--if player dies, mission is aborted and loses all the money and stash
		if hasStarted and IsEntityDead(GetPlayerPed(-1)) then
			cancelOxy(false)
		end
	end
end)