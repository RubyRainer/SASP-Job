local SASPClient = {
    startup = nil,
    activeCalls = {},
    blips = {}
}

RegisterNetEvent('sasp:client:notify', function(message)
    SASPUtils.notify(message, 'inform')
end)

RegisterNetEvent('sasp:client:dutyChanged', function(state)
    if state then
        SASPUtils.notify('Duty systems online.', 'success')
    else
        SASPUtils.notify('Duty systems offline.', 'warning')
    end
end)

RegisterNetEvent('sasp:client:callCreated', function(call)
    SASPClient.activeCalls[call.id] = call
    local blip = AddBlipForCoord(call.coords.x, call.coords.y, call.coords.z)
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 3)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(('Dispatch %s'):format(call.callType))
    EndTextCommandSetBlipName(blip)
    SASPClient.blips[call.id] = blip

    SASPUtils.notify(('New dispatch call: %s'):format(call.callType), 'inform')
end)

RegisterNetEvent('sasp:client:callUpdated', function(call)
    SASPClient.activeCalls[call.id] = call
    if call.status == 'resolved' and SASPClient.blips[call.id] then
        RemoveBlip(SASPClient.blips[call.id])
        SASPClient.blips[call.id] = nil
    end
end)

RegisterNetEvent('sasp:client:panicTriggered', function(data)
    local blip = AddBlipForRadius(data.coords.x, data.coords.y, data.coords.z, 90.0)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 180)

    SASPUtils.notify(('PANIC BUTTON: %s needs backup now!'):format(data.unitCode), 'error')

    CreateThread(function()
        Wait(Config.Dispatch.panicDurationSeconds * 1000)
        RemoveBlip(blip)
    end)
end)

RegisterCommand('saspduty', function()
    TriggerServerEvent('sasp:server:toggleDuty')
end, false)

RegisterCommand('sasp_panic', function()
    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('sasp:server:panic', { x = coords.x, y = coords.y, z = coords.z })
end, false)

RegisterCommand('sasp_call', function(_, args)
    local code = args[1] or '10-38'
    local coords = GetEntityCoords(PlayerPedId())
    local street = SASPUtils.getStreetLabel(coords)

    TriggerServerEvent('sasp:server:createCall', code, {
        x = coords.x,
        y = coords.y,
        z = coords.z
    }, ('Officer generated call at %s'):format(street))
end, false)

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(500) end

    local startupData = SASPFramework.triggerServerCallback('sasp:server:getStartupData')
    SASPClient.startup = startupData

    if startupData and startupData.authorized then
        SASPUtils.notify('SASP tablet synced. Use /saspduty to clock in.', 'success')
    end
end)
