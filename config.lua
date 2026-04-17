Config = {}

Config.Framework = {
    mode = 'auto', -- auto | custom | qbcore
    qbCoreExport = 'qb-core',
    useQBInventory = true,
    useQBPhone = false,
    useQBTaxSystem = false
}

Config.Job = {
    name = 'sasp',
    minimumClockInRank = 0,
    offDutyName = 'off' -- optional off-duty label
}

Config.QBCoreJobBootstrap = {
    enabled = true, -- auto-create the SASP job in QBCore.Shared.Jobs if missing
    label = 'San Andreas State Police',
    defaultDuty = false,
    offDutyPay = false,
    grades = {
        ['0'] = { name = 'Cadet', payment = 450, isboss = false },
        ['1'] = { name = 'Trooper', payment = 600, isboss = false },
        ['2'] = { name = 'Senior Trooper', payment = 700, isboss = false },
        ['3'] = { name = 'Sergeant', payment = 875, isboss = true },
        ['4'] = { name = 'Lieutenant', payment = 1000, isboss = true }
    }
}

Config.DutyStations = {
    { label = 'Mission Row Locker Room', coords = vec3(459.52, -986.82, 30.69), radius = 1.8 },
    { label = 'Sandy Shores Substation', coords = vec3(1856.88, 3689.55, 34.27), radius = 1.8 },
    { label = 'Paleto Bay Office', coords = vec3(-448.12, 6012.35, 31.72), radius = 1.8 }
}

Config.VehicleSpawns = {
    garage = vec3(451.32, -1017.62, 28.49),
    heading = 90.0,
    models = {
        interceptor = 'police3',
        suv = 'fbi2',
        bike = 'policeb'
    }
}

Config.Loadouts = {
    cadet = {
        { item = 'weapon_stungun', amount = 1 },
        { item = 'weapon_flashlight', amount = 1 },
        { item = 'handcuffs', amount = 1 },
        { item = 'radio', amount = 1 }
    },
    trooper = {
        { item = 'weapon_combatpistol', amount = 1 },
        { item = 'pistol_ammo', amount = 6 },
        { item = 'weapon_stungun', amount = 1 },
        { item = 'weapon_nightstick', amount = 1 },
        { item = 'bodycam', amount = 1 },
        { item = 'spike_strip', amount = 1 },
        { item = 'radio', amount = 1 }
    },
    supervisor = {
        { item = 'weapon_carbinerifle', amount = 1 },
        { item = 'rifle_ammo', amount = 10 },
        { item = 'weapon_combatpistol', amount = 1 },
        { item = 'pistol_ammo', amount = 8 },
        { item = 'bodycam', amount = 1 },
        { item = 'radio', amount = 1 }
    }
}

Config.RankLoadoutMap = {
    [0] = 'cadet',
    [1] = 'trooper',
    [2] = 'trooper',
    [3] = 'supervisor',
    [4] = 'supervisor'
}

Config.Paycheck = {
    intervalMinutes = 20,
    grades = {
        [0] = 450,
        [1] = 600,
        [2] = 700,
        [3] = 875,
        [4] = 1000
    },
    bonusPerCall = 45,
    bonusPerArrest = 55
}

Config.Dispatch = {
    panicDurationSeconds = 60,
    callBlipDuration = 180,
    autoDeleteResolved = true
}

Config.Features = {
    armory = true,
    personalLocker = true,
    vehicleImpound = true,
    customMDT = true,
    incidentReports = true,
    finesAndArrests = true,
    panicButton = true,
    backupRequests = true,
    speedRadar = true,
    plateScanner = true,
    gunshotAlerts = true,
    cuffEscortSearch = true
}
