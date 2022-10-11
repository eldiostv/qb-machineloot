
local QBCore = exports['qb-core']:GetCoreObject()
-------
local searched = {3423423424}
local canSearch = true
local dumpsters = {-654402915, 690372739, -1317235795, 992069095,  1114264700, 992069095, -1034034125}
local searchTime = 500000
local idle = 0
local dumpPos
local nearDumpster = false
local maxDistance = 2.5
local listening = false
local dumpster
local currentCoords = nil
local realDumpster

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    ShutdownLoadingScreenNui()
    LocalPlayer.state:set('isLoggedIn', true, false)
    SetCanAttackFriendly(PlayerPedId(), true, false)
    NetworkSetFriendlyFireOption(true)
end)

CreateThread(function()
	--Dumpster Third Eye
	exports['qb-target']:AddTargetModel(dumpsters, { options = { { event = "qb-machineloot:client:dumpsterdive", icon = "fas fa-dumpster", label = "Cerca oggetti da rubare", }, }, distance = 1.5 })
end)

--------
Citizen.CreateThread(function()
    local dist = 0
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local playerCoords, awayFromGarbage = GetEntityCoords(PlayerPedId()), true
        if not nearDumpster then
            for i = 1, #dumpsters do
                local distance
                dumpster = GetClosestObjectOfType(pos.x, pos.y, pos.z, 1.0, dumpsters[i], false, false, false)
                if dumpster ~= 0 then
                    realDumpster = dumpster 
                end
                dumpPos = GetEntityCoords(dumpster)
                local distance = #(pos - dumpPos)
                if distance < maxDistance then
                    currentCoords = dumpPos
                end
                if distance < maxDistance then
                    awayFromGarbage = false
                    nearDumpster = true
                end
            end
        end
        if currentCoords ~= nil and #(currentCoords - playerCoords) > maxDistance then
            nearDumpster = false
            listening = false
        end
        if awayFromGarbage then
            Citizen.Wait(1000)
        end
    end
end)


RegisterNetEvent("qb-machineloot:client:dumpsterdive", function()
    listening = true
    currentlySearching = false
    notifiedOfFailure = false
    Citizen.CreateThread(function()
        while listening do
            local dumpsterFound = false
            Citizen.Wait(10)
            for i = 1, #searched do
                if searched[i] == realDumpster then
                    dumpsterFound = true
                end
                if i == #searched and dumpsterFound and not notifiedOfFailure then
                    QBCore.Functions.Notify('luogo vuoto', 'error')
                    notifiedOfFailure = true
                    Citizen.Wait(1000)
                elseif i == #searched and not dumpsterFound and not currentlySearching then
                    currentlySearching = true
                    QBCore.Functions.Progressbar("dumpsters", "Rubando oggetti", 4500, false, false, {
                        disableMovement = false,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = false,
                    }, {
                        animDict = "amb@prop_human_bum_bin@base",
                        anim = "base",
                        flags = 49,
                    }, {}, {}, function()
                        TriggerServerEvent("qb-machineloot:server:giveDumpsterReward")
                        notifiedOfFailure = true
                        TriggerServerEvent('qb-machineloot:server:startDumpsterTimer', dumpster)
                        table.insert(searched, realDumpster)
                    end, function()
                        QBCore.Functions.Notify('Cancellata la ricerca', 'error')
                    end)
                end
            end
        end
    end)
end)