CreateThread(function()
    while true do
        local waitMs = 1200
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for _, station in ipairs(Config.DutyStations) do
            local distance = #(pos - station.coords)
            if distance <= 20.0 then
                waitMs = 0
                DrawMarker(2, station.coords.x, station.coords.y, station.coords.z + 0.12, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.18, 0.18, 0.18, 32, 145, 255, 180, false, false, 2, false, nil, nil, false)

                if distance <= station.radius then
                    lib.showTextUI(('[E] Toggle Duty\n%s'):format(station.label))
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent('sasp:server:toggleDuty')
                        Wait(400)
                    end
                else
                    lib.hideTextUI()
                end
            end
        end

        Wait(waitMs)
    end
end)

RegisterCommand('sasp_loadout', function()
    TriggerServerEvent('sasp:server:requestLoadout')
end, false)
