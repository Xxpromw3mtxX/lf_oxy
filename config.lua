Config = {}

--Language
Config.Locale = 'it'

--Wait ticktime
Config.TickTime = 100

--Cooldown time
Config.CooldownMinutes = 10 --minutes

--Cops required
Config.minCops = 2

--Starting Black money amount
Config.usebMoney = true
Config.mAccount = 'black_money'
Config.startAmount = 1500

--Start item
Config.startItem = 'suspicious_package'
Config.maxStartItem = 3

--Final item reward
Config.rewardItem = 'oxy'
Config.maxOxy = 5

--NPC Locations
Config.npcLocations = {
    {
        position = vector3(213.1, -3316.8, 4.8),
        heading = 184.06
    },
}

--Suspicious package delivery
Config.deliveryPoint = {
    pStart = vector3(-86.6, 74.9, 71.6),
    pHeading = 150.97,
    delPoint = vector3(212.7, -161.9, 56.8)
}

--Ped vehicle model, drive types and max speed
Config.vehicleModels = {
    'washington',
    'gauntlet',
    'glendale',
    'panto',
    'sultan',
}

Config.dType = 786603 --Rushed

Config.vehSpeed = 30.0

--Peds
Config.peds = {
    sellers = {
        {
            model = 'g_f_y_families_01',
            type = 5
        },
        {
            model = 'g_f_y_vagos_01',
            type = 5
        },
        {
            model = 'g_m_m_chicold_01',
            type = 4
        },
        {
            model = 'g_m_y_lost_01',
            type = 4
        }
    },

    buyers = {
        {
            model = 'a_f_y_business_02',
            type = 5
        },
        {
            model = 'a_f_y_tourist_01',
            type = 5
        },
        {
            model = 'a_m_m_socenlat_01',
            type = 4
        },
    }
}

--Distances
Config.interactDistance = 2