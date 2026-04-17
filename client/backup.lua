RegisterCommand('sasp_backup', function(_, args)
    local code = args[1] or '10-78'
    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('sasp:server:createCall', code, { x = coords.x, y = coords.y, z = coords.z }, 'Backup requested by field unit')
    SASPUtils.notify('Backup request sent.', 'success')
end, false)

RegisterCommand('sasp_accept', function(_, args)
    local callId = args[1]
    if not callId then
        SASPUtils.notify('Usage: /sasp_accept [CALL-ID]', 'error')
        return
    end

    TriggerServerEvent('sasp:server:acceptCall', callId)
end, false)

RegisterCommand('sasp_resolve', function(_, args)
    local callId = args[1]
    local result = table.concat(args, ' ', 2)

    if not callId then
        SASPUtils.notify('Usage: /sasp_resolve [CALL-ID] [result notes]', 'error')
        return
    end

    TriggerServerEvent('sasp:server:resolveCall', callId, result ~= '' and result or 'Resolved by officer')
end, false)

RegisterCommand('sasp_armory', function()
    local items = SASPFramework.triggerServerCallback('sasp:server:getArmoryCatalog')
    if not items or #items == 0 then
        SASPUtils.notify('No armory access at your current rank/job.', 'error')
        return
    end

    local formatted = {}
    for _, item in ipairs(items) do
        formatted[#formatted + 1] = item.item
    end

    SASPUtils.notify(('Armory items: %s'):format(table.concat(formatted, ', ')), 'inform')
    SASPUtils.notify('Use /sasp_armory_take [itemname] to withdraw.', 'inform')
end, false)

RegisterCommand('sasp_armory_take', function(_, args)
    local itemName = args[1]
    if not itemName then
        SASPUtils.notify('Usage: /sasp_armory_take [itemname]', 'error')
        return
    end

    TriggerServerEvent('sasp:server:armoryWithdraw', itemName)
end, false)
