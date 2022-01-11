ESX = nil

--PED info
local oxyPed

--local variables
local randomPed = 1
local randomDelivery = 1
local randomPedSeller = 1
local randomPedDelivery = 1
local hasStarted = false

--items amounts
local suspicious
local recoveries
local maxRewardOxy

--blip
local oxyBlips


-- Delete PED on resource stop
AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
		DeletePed(oxyPed)
        SetPedAsNoLongerNeeded(oxyPed)
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
	randomDelivery = math.random(1, #Config.deliveryPoints)
	randomPedDelivery = math.random(1, #Config.pedModels)

	setWaypoint(Config.deliveryPoints[randomDelivery], _U('exchange'))
	
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
	
	suspicious = math.random(1, Config.maxStartItem)
	recoveries = suspicious
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
		end

		if hasStarted and suspicious == 0 then
			exports.qtarget:RemoveTargetModel({Config.sellerPed[randomPedSeller].model}, {
				_U('recoverPacket')
			})
			Citizen.Wait(60000)
			removeNPC()
		end

		if hasStarted and recoveries ~= 0 and suspicious == 0 then
			generateDelivery()
		end
	end
end)

AddEventHandler('atlantis_oxy:addPackage', function()
	suspicious = suspicious - 1

	TriggerServerEvent('atlantis_oxy:itemAdder', Config.startItem)
end)