ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

-- Version Checker
PerformHttpRequest("https://raw.githubusercontent.com/xxpromw3mtxx/atlantis_oxy/main/.version", function(err, text, headers)
    Citizen.Wait(2000)
    local curVer = GetResourceMetadata(GetCurrentResourceName(), "version")

    if (text ~= nil) then
        if (text ~= curVer) then
            print '^1-----------------------------------------^0'
            print '^1      UPDATE AVAILABLE ATLANTIS_OXY      ^0'
            print '^1          GET IT ON GITHUB NOW           ^0'
            print '^1-----------------------------------------^0'
        else
            print("^2ATLANTIS_OXY is up to date!^0")
        end
    else
        print '^1----------------------------------------^0'
        print '^1      ERROR GETTING ONLINE VERSION      ^0'
        print '^1----------------------------------------^0'
    end 
end)