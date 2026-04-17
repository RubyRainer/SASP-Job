local radarEnabled = false

local function getVehicleInFront(maxDistance)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle == 0 then return nil end

    local from = GetEntityCoords(vehicle)
    local to = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, maxDistance, 0.0)
    local ray = StartShapeTestRay(from.x, from.y, from.z, to.x, to.y, to.z, 10, vehicle, 0)
    local _, hit, _, _, entity = GetShapeTestResult(ray)

    if hit == 1 and DoesEntityExist(entity) and IsEntityAVehicle(entity) then
        return entity
    end

    return nil
end

local function drawRadarText(text)
    SetTextFont(4)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 230)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.015, 0.8)
end

RegisterCommand('sasp_radar', function()
    radarEnabled = not radarEnabled
    SASPUtils.notify(radarEnabled and 'Front radar enabled.' or 'Front radar disabled.', radarEnabled and 'success' or 'warning')
end, false)

CreateThread(function()
    while true do
        if not radarEnabled then
            Wait(700)
        else
            Wait(0)
            local targetVehicle = getVehicleInFront(80.0)
            if targetVehicle then
                local speedMph = GetEntitySpeed(targetVehicle) * 2.236936
                local plate = GetVehicleNumberPlateText(targetVehicle)
                local model = GetDisplayNameFromVehicleModel(GetEntityModel(targetVehicle))
                drawRadarText(('Radar | %s | %s | %d MPH'):format(plate, model, math.floor(speedMph)))
            else
                drawRadarText('Radar | No target')
            end
        end
    end
end)
