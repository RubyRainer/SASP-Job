SASP = {
    dutyUnits = {},
    activeCalls = {},
    incidents = {},
    warrants = {}
}

local function ensureOfficerState(src)
    SASP.dutyUnits[src] = SASP.dutyUnits[src] or {
        callsHandled = 0,
        arrests = 0,
        signOnTime = os.time(),
        unitCode = ('SASP-%s'):format(src)
    }
    return SASP.dutyUnits[src]
end

local function isSASP(src)
    local job = SASPFramework.getJob(src)
    return job and job.name == Config.Job.name
end

SASPFramework.registerServerCallback('sasp:server:getStartupData', function(src, cb)
    local isOfficer = isSASP(src)
    if not isOfficer then
        cb({ authorized = false })
        return
    end

    local data = ensureOfficerState(src)
    local job = SASPFramework.getJob(src)

    cb({
        authorized = true,
        onduty = job.onduty,
        grade = SASPFramework.getGradeLevel(src),
        unitCode = data.unitCode,
        openCallCount = #SASP.activeCalls
    })
end)

RegisterNetEvent('sasp:server:requestLoadout', function()
    local src = source
    if not Config.Features.armory or not isSASP(src) then return end

    local grade = SASPFramework.getGradeLevel(src)
    local key = Config.RankLoadoutMap[grade] or 'cadet'
    local loadout = Config.Loadouts[key] or {}

    for _, item in ipairs(loadout) do
        SASPFramework.addItem(src, item.item, item.amount)
    end

    TriggerClientEvent('sasp:client:notify', src, ('Issued %s loadout.'):format(key))
end)

RegisterNetEvent('sasp:server:createIncident', function(payload)
    local src = source
    if not isSASP(src) then return end

    local incidentId = ('INC-%s-%s'):format(os.date('%y%m%d'), #SASP.incidents + 1)
    local officer = ensureOfficerState(src)
    local report = {
        id = incidentId,
        createdAt = os.time(),
        title = payload.title,
        category = payload.category,
        details = payload.details,
        suspects = payload.suspects or {},
        involvedUnits = payload.involvedUnits or { officer.unitCode },
        author = officer.unitCode
    }

    table.insert(SASP.incidents, report)
    MySQL.insert('INSERT INTO sasp_incidents (incident_id, title, category, details, author, payload, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())', {
        report.id,
        report.title,
        report.category,
        report.details,
        report.author,
        json.encode(report)
    })

    TriggerClientEvent('sasp:client:incidentCreated', src, report.id)
end)

RegisterNetEvent('sasp:server:issueFine', function(targetId, amount, reason)
    local src = source
    if not isSASP(src) then return end

    amount = tonumber(amount) or 0
    if amount <= 0 then return end

    if GetPlayerPing(targetId) <= 0 then
        TriggerClientEvent('sasp:client:notify', src, 'Target not online.')
        return
    end

    if SASPFramework.mode == 'qbcore' then
        local target = SASPFramework.getPlayer(targetId)
        if target then
            target.Functions.RemoveMoney('bank', amount, ('Fine: %s'):format(reason or 'SASP'))
        end
    end

    TriggerClientEvent('sasp:client:notify', src, ('Fine issued: $%s'):format(amount))
    TriggerClientEvent('sasp:client:notify', targetId, ('You were fined $%s. Reason: %s'):format(amount, reason or 'N/A'))
end)

CreateThread(function()
    while true do
        Wait(Config.Paycheck.intervalMinutes * 60000)

        for src, data in pairs(SASP.dutyUnits) do
            if GetPlayerPing(src) > 0 then
                local base = Config.Paycheck.grades[SASPFramework.getGradeLevel(src)] or Config.Paycheck.grades[0]
                local bonus = (data.callsHandled * Config.Paycheck.bonusPerCall) + (data.arrests * Config.Paycheck.bonusPerArrest)
                local total = base + bonus

                SASPFramework.addBankMoney(src, total)
                TriggerClientEvent('sasp:client:notify', src, ('Payroll deposited: $%s (base: $%s, bonus: $%s)'):format(total, base, bonus))

                data.callsHandled = 0
                data.arrests = 0
            end
        end
    end
end)

exports('SASPGetDutyUnits', function()
    return SASP.dutyUnits
end)
