Config = {}

--Language
Config.Locale = 'it'

--Wait ticktime
Config.TickTime = 100

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
Config.deliveryPoints = {
    --[[vector3(969.77990, -1557.03700, 30.20764),
    vector3(-173.59390, -1975.40200, 27.14530),
    vector3(-777.35500, 373.81520, 87.35204),
    vector3(-939.38060, 309.26740, 70.67439),
    vector3(-227.40120, -1486.49900, 30.79996),]]
    vector3(217.7, -166.3, 56.6),
}

--Ped vehicle model, drive types and max speed
Config.vehicleModels = {
    'washington',
    'gauntlet',
    'glendale',
    'panto',
    'sultan',
}

Config.dType = 786603 --Normal

Config.pedVehiclemSpeed = 10.0

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