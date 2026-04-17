SASPFramework.registerServerCallback('sasp:server:getArmoryCatalog', function(src, cb)
    local job = SASPFramework.getJob(src)
    if not job or job.name ~= Config.Job.name then
        cb({})
        return
    end

    local grade = SASPFramework.getGradeLevel(src)
    local catalog = {
        { item = 'weapon_stungun', label = 'Taser', minGrade = 0 },
        { item = 'weapon_combatpistol', label = 'Service Pistol', minGrade = 1 },
        { item = 'weapon_pumpshotgun', label = 'Patrol Shotgun', minGrade = 2 },
        { item = 'weapon_carbinerifle', label = 'Patrol Rifle', minGrade = 3 },
        { item = 'body_armor', label = 'Body Armor', minGrade = 0 },
        { item = 'medkit', label = 'First Aid Kit', minGrade = 0 },
        { item = 'spike_strip', label = 'Spike Strip', minGrade = 1 }
    }

    local allowed = {}
    for _, v in ipairs(catalog) do
        if grade >= v.minGrade then
            allowed[#allowed + 1] = v
        end
    end

    cb(allowed)
end)

RegisterNetEvent('sasp:server:armoryWithdraw', function(itemName)
    local src = source
    local grade = SASPFramework.getGradeLevel(src)

    local rules = {
        weapon_stungun = 0,
        weapon_combatpistol = 1,
        weapon_pumpshotgun = 2,
        weapon_carbinerifle = 3,
        body_armor = 0,
        medkit = 0,
        spike_strip = 1
    }

    if not rules[itemName] then return end
    if grade < rules[itemName] then
        TriggerClientEvent('sasp:client:notify', src, 'Insufficient rank for this item.')
        return
    end

    SASPFramework.addItem(src, itemName, 1)
    TriggerClientEvent('sasp:client:notify', src, ('Withdrawn %s from armory.'):format(itemName))
end)
