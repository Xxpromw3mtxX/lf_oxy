Config = {}

Config.resource = GetCurrentResourceName()

--Language
Config.Locale = 'it'

--Wait ticktime
Config.TickTime = 100

--Cooldown time
Config.CooldownMinutes = 10 --minutes

--Version checker
Config.vc = true

--Cops required
Config.minCops = 0

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

--Suspicious package delivery
Config.deliveryPoint = {
    vector3(212.7, -161.9, 56.8),
    vector3(-227.4, -1486.4, 30.79),
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

Config.vehSpeed = 10.0

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

--Ped
Config.ped = {
    model = "a_m_m_mlcrisis_01",
    position = vec3(-702.764832, -1143.916504, 9.812500),
    heading = 2.74,
    network = true
}