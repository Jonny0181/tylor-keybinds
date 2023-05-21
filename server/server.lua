local ESX = exports['es_extended']:getSharedObject()

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

RegisterServerEvent('tylor-keybinds:fastaction1', function(target, distance, cuffed)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    local job = player.getJob()

    if table.contains(Config.LEOJobs, job.name) then
        if distance > 2 then
            return exports['tylor-notification']:Alert(src, 'ALERT', 'There is nobody close enough to you!', 0, true)
        elseif cuffed then
            return exports['tylor-notification']:Alert(src, 'ALERT', 'You can\'t do that while cuffed!', 0, true)
        else
			TriggerClientEvent('tylor-keybinds:cuff', target)
        end
    end
end)

RegisterNetEvent('tylor-keybinds:fastaction2')
AddEventHandler('tylor-keybinds:fastaction2', function(target, distance, cuffed)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    local job = player.getJob()

    if table.contains(Config.LEOJobs, job.name) then
		if distance > 2 then
			return exports['tylor-notification']:Alert(src, 'ALERT', 'There is nobody close enough to you!', 0, true)
		elseif cuffed then
			return exports['tylor-notification']:Alert(src, 'ALERT', 'You can\'t do that while cuffed!', 0, true)
		else
			TriggerClientEvent('tylor-keybinds:drag', target, source)
		end
	end
end)

RegisterNetEvent('tylor-keybinds:fastaction3')
AddEventHandler('tylor-keybinds:fastaction3', function(target, cuffed)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    local job = player.getJob()

    if table.contains(Config.LEOJobs, job.name) then
		if cuffed then
			return exports['tylor-notification']:Alert(src, 'ALERT', 'You can\'t do that while cuffed!', 0, true)
		else
			TriggerClientEvent('tylor-keybinds:putInVehicle', target)
		end
	end
end)

RegisterNetEvent('tylor-keybinds:fastaction4')
AddEventHandler('tylor-keybinds:fastaction4', function(target, cuffed)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    local job = player.getJob()

    if table.contains(Config.LEOJobs, job.name) then
		if cuffed then
			return exports['tylor-notification']:Alert(src, 'ALERT', 'You can\'t do that while cuffed!', 0, true)
		else
			TriggerClientEvent('tylor-keybinds:OutVehicle', target)
		end
	end
end)