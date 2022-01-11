ESX = nil

--PED info
local oxyPed

--local variables
local randomPed = 1
local randomDelivery = 1
local randomPedSeller = 1
local hasStarted = false

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
end

RegisterNetEvent('atlantis_oxy:initOxy')
AddEventHandler('atlantis_oxy:initOxy', function()
	randomPed = math.random(1, #Config.npcLocations)
    randomDelivery = math.random(1, #Config.deliveryPoints)
	randomPedSeller = math.random(1, #Config.sellerPed)

	suspicious = math.random(1, Config.maxStartItem)
	maxRewardOxy = math.random(1, Config.maxOxy)

	hasStarted = true

	createNPC(Config.sellerPed[randomPedSeller].type, Config.sellerPed[randomPedSeller].model, Config.npcLocations[randomPed].position, Config.npcLocations[randomPed].heading, false, true)
	setWaypoint(Config.npcLocations[randomPed].position, _U('oRecovery'))
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.TickTime)

		local coords = GetEntityCoords(GetPlayerPed(-1))
		
		if hasStarted and GetDistanceBetweenCoords(coords, Config.npcLocations[randomPed].position, false) < 10 then
			RemoveBlip(oxyBlips)
		end
	end
end)