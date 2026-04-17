SASPFramework = {
    mode = 'custom',
    QB = nil,
    customPlayers = {},
    callbacks = {}
}

local isServer = IsDuplicityVersion()

local function ensureQBCoreJob()
    if not isServer then return end
    if not Config.QBCoreJobBootstrap or not Config.QBCoreJobBootstrap.enabled then return end
    if not SASPFramework.QB or not SASPFramework.QB.Shared or not SASPFramework.QB.Shared.Jobs then return end

    local jobName = Config.Job.name
    if SASPFramework.QB.Shared.Jobs[jobName] then
        return
    end

    SASPFramework.QB.Shared.Jobs[jobName] = {
        label = Config.QBCoreJobBootstrap.label or 'SASP',
        type = 'leo',
        defaultDuty = Config.QBCoreJobBootstrap.defaultDuty == true,
        offDutyPay = Config.QBCoreJobBootstrap.offDutyPay == true,
        grades = Config.QBCoreJobBootstrap.grades or {}
    }

    print(('^2[SASP] Registered missing QBCore job "%s" from config bootstrap.^0'):format(jobName))
end

local function detectFramework()
    if Config.Framework.mode == 'qbcore' then
        return 'qbcore'
    end

    if Config.Framework.mode == 'custom' then
        return 'custom'
    end

    if GetResourceState(Config.Framework.qbCoreExport) == 'started' then
        return 'qbcore'
    end

    return 'custom'
end

CreateThread(function()
    SASPFramework.mode = detectFramework()

    if SASPFramework.mode == 'qbcore' then
        SASPFramework.QB = exports[Config.Framework.qbCoreExport]:GetCoreObject()
        ensureQBCoreJob()
        print('^2[SASP] Running in QBCore bridge mode.^0')
    else
        print('^3[SASP] Running in Custom standalone framework mode.^0')
    end
end)

if isServer then
    function SASPFramework.registerServerCallback(name, cb)
        SASPFramework.callbacks[name] = cb
    end

    RegisterNetEvent('sasp:server:callback', function(name, requestId, ...)
        local src = source
        local handler = SASPFramework.callbacks[name]
        if not handler then
            TriggerClientEvent('sasp:client:callbackResult', src, requestId, nil)
            return
        end

        handler(src, function(payload)
            TriggerClientEvent('sasp:client:callbackResult', src, requestId, payload)
        end, ...)
    end)
else
    local callbackIndex = 0
    local pending = {}

    function SASPFramework.triggerServerCallback(name, ...)
        callbackIndex = callbackIndex + 1
        local requestId = callbackIndex
        local p = promise.new()

        pending[requestId] = p
        TriggerServerEvent('sasp:server:callback', name, requestId, ...)

        return Citizen.Await(p)
    end

    RegisterNetEvent('sasp:client:callbackResult', function(requestId, payload)
        local p = pending[requestId]
        if not p then return end

        pending[requestId] = nil
        p:resolve(payload)
    end)
end

function SASPFramework.getIdentifier(src)
    if SASPFramework.mode == 'qbcore' then
        local player = SASPFramework.QB.Functions.GetPlayer(src)
        return player and player.PlayerData.citizenid or nil
    end

    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find('license:') then
            return id
        end
    end

    return GetPlayerIdentifierByType(src, 'fivem')
end

function SASPFramework.getPlayer(src)
    if SASPFramework.mode == 'qbcore' then
        return SASPFramework.QB.Functions.GetPlayer(src)
    end

    return SASPFramework.customPlayers[src]
end

function SASPFramework.initCustomPlayer(src)
    local identifier = SASPFramework.getIdentifier(src)
    SASPFramework.customPlayers[src] = {
        source = src,
        identifier = identifier,
        job = {
            name = Config.Job.name,
            grade = { level = 0, name = 'Cadet' },
            onduty = false
        },
        metadata = {
            callsHandled = 0,
            arrests = 0
        },
        accounts = {
            bank = 10000,
            cash = 2000
        },
        inventory = {}
    }

    return SASPFramework.customPlayers[src]
end

function SASPFramework.getJob(src)
    if SASPFramework.mode == 'qbcore' then
        local player = SASPFramework.getPlayer(src)
        return player and player.PlayerData.job or nil
    end

    local player = SASPFramework.customPlayers[src]
    return player and player.job or nil
end

function SASPFramework.setDuty(src, duty)
    if SASPFramework.mode == 'qbcore' then
        local player = SASPFramework.getPlayer(src)
        if not player then return false end

        player.Functions.SetJobDuty(duty)
        return true
    end

    local player = SASPFramework.customPlayers[src] or SASPFramework.initCustomPlayer(src)
    player.job.onduty = duty
    return true
end

function SASPFramework.addItem(src, itemName, amount)
    amount = amount or 1

    if SASPFramework.mode == 'qbcore' and Config.Framework.useQBInventory then
        local player = SASPFramework.getPlayer(src)
        if not player then return false end
        return player.Functions.AddItem(itemName, amount)
    end

    local player = SASPFramework.customPlayers[src] or SASPFramework.initCustomPlayer(src)
    player.inventory[itemName] = (player.inventory[itemName] or 0) + amount
    return true
end

function SASPFramework.addBankMoney(src, amount)
    if amount <= 0 then return end

    if SASPFramework.mode == 'qbcore' then
        local player = SASPFramework.getPlayer(src)
        if player then
            player.Functions.AddMoney('bank', amount, 'sasp-paycheck')
        end
        return
    end

    local player = SASPFramework.customPlayers[src] or SASPFramework.initCustomPlayer(src)
    player.accounts.bank = player.accounts.bank + amount
end

function SASPFramework.getGradeLevel(src)
    local job = SASPFramework.getJob(src)
    if not job then return 0 end

    if SASPFramework.mode == 'qbcore' then
        return job.grade.level or 0
    end

    return job.grade.level or 0
end

if isServer then
    AddEventHandler('playerJoining', function(_oldId)
        local src = source
        if SASPFramework.mode == 'custom' then
            SASPFramework.initCustomPlayer(src)
        end
    end)

    AddEventHandler('playerDropped', function()
        local src = source
        SASPFramework.customPlayers[src] = nil
    end)
end
