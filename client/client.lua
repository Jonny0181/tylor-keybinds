local ESX = exports['es_extended']:getSharedObject()

local cuffed = false
local ped = PlayerPedId()
local changed = false
local prevMaleVariation = 0
local prevFemaleVariation = 0

local isDragged = false
local CopId = nil

-- CUFFING
RegisterNetEvent('tylor-keybinds:cuff')
AddEventHandler('tylor-keybinds:cuff', function()
    -- (re)set the ped variable, for some reason the one set previously doesn't always work.
    ped = PlayerPedId()
    RequestAnimDict("mp_arresting")

    -- If it's not loaded (yet), wait until it's done loading.
    while not HasAnimDictLoaded("mp_arresting") do
        Citizen.Wait(0)
    end

    -- If the player is cuffed, then we want to uncuff them.
    if cuffed then
        ClearPedTasks(ped)
        SetEnableHandcuffs(ped, false)
        UncuffPed(ped)

        if GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then
            SetPedComponentVariation(ped, 7, prevFemaleVariation, 0, 0)
        elseif GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
            SetPedComponentVariation(ped, 7, prevMaleVariation, 0, 0)
        end
    else
        if GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then -- mp female
            prevFemaleVariation = GetPedDrawableVariation(ped, 7)
            SetPedComponentVariation(ped, 7, 25, 0, 0)
        elseif GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then -- mp male
            prevMaleVariation = GetPedDrawableVariation(ped, 7)
            SetPedComponentVariation(ped, 7, 41, 0, 0)
        end
        SetEnableHandcuffs(ped, true)
        TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
    end

    cuffed = not cuffed
    if isDragged then
		isDragged = not isDragged
    end
    changed = true
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if not changed then
            ped = PlayerPedId()
            local IsCuffed = IsPedCuffed(ped)


            if IsCuffed and not IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "idle", 3) then
                Citizen.Wait(500)
                TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
            end
        else
            changed = false
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        ped = PlayerPedId()
        if cuffed then
            DisableControlAction(0, 69, true)  -- INPUT_VEH_ATTACK
            DisableControlAction(0, 92, true)  -- INPUT_VEH_PASSENGER_ATTACK
            DisableControlAction(0, 114, true) -- INPUT_VEH_FLY_ATTACK
            DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
            DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
            DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE
            DisableControlAction(0, 257, true) -- INPUT_ATTACK2
            DisableControlAction(0, 263, true) -- INPUT_MELEE_ATTACK1
            DisableControlAction(0, 264, true) -- INPUT_MELEE_ATTACK2
            DisableControlAction(0, 24, true)  -- INPUT_ATTACK
            DisableControlAction(0, 25, true)  -- INPUT_AIM
            SetPedDropsWeapon(ped)

            -- Get the vehicle the player is currently in and make then leave (if in any)
            local veh = GetVehiclePedIsIn(ped, false)
            if DoesEntityExist(veh) and not IsEntityDead(veh) and GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
                if IsPedSittingInAnyVehicle(ESX.PlayerData.ped) then
                    local vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
                    TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 64)
                end
            end
        end
    end
end)

-- DRAGGING
RegisterNetEvent('tylor-keybinds:drag')
AddEventHandler('tylor-keybinds:drag', function(copId)
	if cuffed then
		isDragged = not isDragged
		CopId = copId
	end
end)

CreateThread(function()
	local wasDragged

	while true do
        Wait(0)

		if cuffed and isDragged then
			local targetPed = GetPlayerPed(GetPlayerFromServerId(CopId))

			if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
				if not wasDragged then
					AttachEntityToEntity(ESX.PlayerData.ped, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
					wasDragged = true
				end
			else
				wasDragged = false
				isDragged = false
				DetachEntity(ESX.PlayerData.ped, true, false)
			end
		elseif wasDragged then
			wasDragged = false
			DetachEntity(ESX.PlayerData.ped, true, false)
		end
	end
end)

-- PUT IN VEHICLE
RegisterNetEvent('tylor-keybinds:putInVehicle')
AddEventHandler('tylor-keybinds:putInVehicle', function()
	if cuffed then
		local playerPed = PlayerPedId()
		local vehicle, distance = ESX.Game.GetClosestVehicle()

		if vehicle and distance < 5 then
			local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

			for i=maxSeats - 1, 0, -1 do
				if IsVehicleSeatFree(vehicle, i) then
					freeSeat = i
					break
				end
			end

			if freeSeat then
				TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
				isDragged = false
			end
		end
	end
end)

-- TAKE OUT OF VEHICLE
RegisterNetEvent('tylor-keybinds:OutVehicle')
AddEventHandler('tylor-keybinds:OutVehicle', function()
	local GetVehiclePedIsIn = GetVehiclePedIsIn
	local IsPedSittingInAnyVehicle = IsPedSittingInAnyVehicle
	local TaskLeaveVehicle = TaskLeaveVehicle
	if IsPedSittingInAnyVehicle(ESX.PlayerData.ped) then
		local vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
		TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 64)
	end
end)

-- KEYBINDS
RegisterCommand('+fastaction1', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
    local playerPed = GetPlayerPed(-1)

    if IsEntityDead(playerPed) then
        return
    else
        if closestPlayer ~= -1 then
            TriggerServerEvent('tylor-keybinds:fastaction1', GetPlayerServerId(closestPlayer), closestDistance, cuffed)
        end
    end
end, false)

RegisterCommand('+fastaction2', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
    local playerPed = GetPlayerPed(-1)

    if IsEntityDead(playerPed) then
        return
    else
        if closestPlayer ~= -1 then
            TriggerServerEvent('tylor-keybinds:fastaction2', GetPlayerServerId(closestPlayer), closestDistance, cuffed)
        end
    end
end, false)

RegisterCommand('+fastaction3', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
    local playerPed = GetPlayerPed(-1)

    if IsEntityDead(playerPed) then
        return
    else
        if closestPlayer ~= -1 then
            TriggerServerEvent('tylor-keybinds:fastaction3', GetPlayerServerId(closestPlayer), cuffed)
        end
    end
end, false)

RegisterCommand('+fastaction4', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
    local playerPed = GetPlayerPed(-1)

    if IsEntityDead(playerPed) then
        return
    else
        if closestPlayer ~= -1 then
            TriggerServerEvent('tylor-keybinds:fastaction4', GetPlayerServerId(closestPlayer), cuffed)
        end
    end
end, false)

RegisterKeyMapping('+fastaction1', 'Organization Fast Action 1', 'keyboard', 'z')
RegisterKeyMapping('+fastaction2', 'Organization Fast Action 2', 'keyboard', 'x')
RegisterKeyMapping('+fastaction3', 'Organization Fast Action 3', 'keyboard', 'c')
RegisterKeyMapping('+fastaction4', 'Organization Fast Action 4', 'keyboard', 'o')