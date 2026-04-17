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
    local items = lib.callback.await('sasp:server:getArmoryCatalog', false)
    if not items or #items == 0 then
        SASPUtils.notify('No armory access at your current rank/job.', 'error')
        return
    end

    local options = {}
    for _, item in ipairs(items) do
        options[#options + 1] = {
            title = item.label,
            description = ('Withdraw %s'):format(item.item),
            onSelect = function()
                TriggerServerEvent('sasp:server:armoryWithdraw', item.item)
            end
        }
    end

    lib.registerContext({
        id = 'sasp_armory_menu',
        title = 'SASP Armory',
        options = options
    })

    lib.showContext('sasp_armory_menu')
end, false)
