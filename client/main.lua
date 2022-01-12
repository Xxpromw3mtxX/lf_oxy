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
local vehicleHash
local randomModel
local drive
local randomVehModle
local driveType

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

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

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

function removeNPC()
	DeletePed(oxyPed)
    SetPedAsNoLongerNeeded(oxyPed)
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
	randomPedDelivery = math.random(1, #Config.pedModels)
	randomModel = math.random(1, #Config.vehicleModels)
	drive = math.random(1, #Config.vehicleDriveType)

	randomVehModle = Config.vehicleModels[randomModel]
	driveType = Config.vehicleDriveType[drive]

	--ped
	RequestModel(GetHashKey(Config.pedModels[randomPedDelivery].model))
	while not HasModelLoaded(GetHashKey(Config.pedModels[randomPedDelivery].model)) do
		Citizen.Wait(1)
	end
	
	if not DoesEntityExist(deliveryPed) then
		deliveryPed = CreatePed(Config.pedModels[randomPedDelivery].type, Config.pedModels[randomPedDelivery].model, -1297.291, -203.3148, 59.75965, 0.0, false, true)
		SetEntityInvincible(deliveryPed, true)
	end
	
	SetModelAsNoLongerNeeded(Config.pedModels[randomPedDelivery].model)
	--end ped section

	exports['qtarget']:AddTargetModel({Config.sellerPed[randomPedSeller].model}, {
		options = {
			{
				event = "atlantis_oxy:addPackage",
				icon = "fas fa-box",
				label = _U('recoverPacket'),
				num = 1
			}
		},
		distance = Config.interactDistances
	})
	
	setWaypoint(Config.deliveryPoints[randomDelivery], _U('exchange'))

	vehicleHash = GetHashKey(randomVehModle)
	RequestModel(vehicleHash)
	vehicle = CreateVehicle(vehicleHash, -1298.37, -204.0942, 59.95965, 0.0, true, true)

	SetEntityAsMissionEntity(vehicle, true, true)

	TaskEnterVehicle(deliveryPed, vehicle, 10000, -1, 50, 1, 0)

	TaskVehicleDriveToCoord(deliveryPed, vehicle, Config.deliveryPoints[randomDelivery], Config.pedVehiclemSpeed, 1.0, GetEntityModel(vehicle), driveType, 1.0, true)
end

RegisterNetEvent('atlantis_oxy:initOxy')
AddEventHandler('atlantis_oxy:initOxy', function()
	if Config.usebMoney then
		TriggerServerEvent('atlantis_oxy:clearMoney', Config.mAccount, Config.startAmount)
	else
		TriggerEvent('atlantis_oxy:startOxy')
	end
end)

RegisterNetEvent('atlantis_oxy:startOxy')
AddEventHandler('atlantis_oxy:startOxy', function()
	randomPed = math.random(1, #Config.npcLocations)
	randomPedSeller = math.random(1, #Config.sellerPed)
	randomDelivery = math.random(1, #Config.deliveryPoints)
	
	suspicious = math.random(1, Config.maxStartItem)
	maxRewardOxy = math.random(1, Config.maxOxy)

	hasStarted = not hasStarted

	TriggerEvent('mythic_notify:client:SendAlert', {type = 'inform', text = _U('oxyHasStarted'), length = 2500})

	setWaypoint(Config.npcLocations[randomPed].position, _U('oRecovery'))
	createNPC(Config.sellerPed[randomPedSeller].type, Config.sellerPed[randomPedSeller].model, Config.npcLocations[randomPed].position, Config.npcLocations[randomPed].heading, false, true)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.TickTime)

		local coords = GetEntityCoords(GetPlayerPed(-1))
		local pDistance = GetDistanceBetweenCoords(coords, Config.npcLocations[randomPed].position, false)
		
		if hasStarted and pDistance < 10 then
			RemoveBlip(oxyBlips)
		end

		if hasStarted and suspicious ~= 0 then
			exports['qtarget']:AddTargetModel({Config.sellerPed[randomPedSeller].model}, {
				options = {
					{
						event = "atlantis_oxy:addPackage",
						icon = "fas fa-box",
						label = _U('recoverPacket'),
						num = 1
					}
				},
				distance = Config.interactDistances
			})
		elseif hasStarted and suspicious == 0 then
			exports.qtarget:RemoveTargetModel({Config.sellerPed[randomPedSeller].model}, {
				_U('recoverPacket')
			})
			generateDelivery()
			Citizen.Wait(20000)
			removeNPC()
		end
	end
end)

AddEventHandler('atlantis_oxy:addPackage', function()
	suspicious = suspicious - 1

	TriggerServerEvent('atlantis_oxy:itemAdder', Config.startItem)
end)