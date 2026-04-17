local function buildCallId()
    return ('CALL-%s-%s'):format(os.date('%H%M%S'), math.random(100, 999))
end

RegisterNetEvent('sasp:server:createCall', function(callType, coords, notes)
    local src = source
    local id = buildCallId()
    local call = {
        id = id,
        source = src,
        callType = callType or '10-99',
        coords = coords,
        notes = notes or 'No notes',
        status = 'open',
        openedAt = os.time(),
        responders = {}
    }

    table.insert(SASP.activeCalls, call)
    TriggerClientEvent('sasp:client:callCreated', -1, call)
end)

RegisterNetEvent('sasp:server:acceptCall', function(callId)
    local src = source
    for _, call in ipairs(SASP.activeCalls) do
        if call.id == callId and call.status == 'open' then
            call.responders[src] = true
            call.status = 'active'
            if SASP.dutyUnits[src] then
                SASP.dutyUnits[src].callsHandled = SASP.dutyUnits[src].callsHandled + 1
            end
            TriggerClientEvent('sasp:client:callUpdated', -1, call)
            return
        end
    end
end)

RegisterNetEvent('sasp:server:resolveCall', function(callId, result)
    for index, call in ipairs(SASP.activeCalls) do
        if call.id == callId then
            call.status = 'resolved'
            call.result = result
            call.closedAt = os.time()
            TriggerClientEvent('sasp:client:callUpdated', -1, call)

            if Config.Dispatch.autoDeleteResolved then
                table.remove(SASP.activeCalls, index)
            end
            return
        end
    end
end)

RegisterNetEvent('sasp:server:panic', function(coords)
    local src = source
    if not SASP.dutyUnits[src] then return end

    local unitCode = SASP.dutyUnits[src].unitCode
    TriggerClientEvent('sasp:client:panicTriggered', -1, {
        unitCode = unitCode,
        coords = coords,
        expiresAt = os.time() + Config.Dispatch.panicDurationSeconds
    })
end)
