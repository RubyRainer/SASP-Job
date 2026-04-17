local function isSASP(src)
    local job = SASPFramework.getJob(src)
    return job and job.name == Config.Job.name
end

RegisterNetEvent('sasp:server:toggleDuty', function()
    local src = source
    if not isSASP(src) then
        TriggerClientEvent('sasp:client:notify', src, 'You are not in SASP.')
        return
    end

    local job = SASPFramework.getJob(src)
    local nowOnDuty = not job.onduty
    SASPFramework.setDuty(src, nowOnDuty)

    if nowOnDuty then
        SASP.dutyUnits[src] = SASP.dutyUnits[src] or {
            callsHandled = 0,
            arrests = 0,
            signOnTime = os.time(),
            unitCode = ('SASP-%s'):format(src)
        }
    else
        SASP.dutyUnits[src] = nil
    end

    TriggerClientEvent('sasp:client:dutyChanged', src, nowOnDuty)
    TriggerClientEvent('sasp:client:notify', src, nowOnDuty and 'You are now on duty.' or 'You are now off duty.')
end)

RegisterNetEvent('sasp:server:recordArrest', function(targetId, charges)
    local src = source
    if not isSASP(src) or not SASP.dutyUnits[src] then return end

    local arrestId = ('ARR-%s-%s'):format(os.date('%y%m%d'), math.random(1000, 9999))
    SASP.dutyUnits[src].arrests = SASP.dutyUnits[src].arrests + 1

    MySQL.insert('INSERT INTO sasp_arrests (arrest_id, officer_id, target_id, charges, created_at) VALUES (?, ?, ?, ?, NOW())', {
        arrestId,
        SASPFramework.getIdentifier(src),
        targetId,
        json.encode(charges or {})
    })

    TriggerClientEvent('sasp:client:notify', src, ('Arrest logged (%s).'):format(arrestId))
end)
