local ESX = nil

Config = Config or {}
Config.Garages = Config.Garages or {}

local spawnedVehicles = {}

Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(0)
    end
end)

local function hexToRGB(hex)
    hex = hex:gsub("#","")
    local r = tonumber("0x"..hex:sub(1,2))
    local g = tonumber("0x"..hex:sub(3,4))
    local b = tonumber("0x"..hex:sub(5,6))
    return {r = r, g = g, b = b}
end

local function SpawnVehicle(model, coords, maxSpawn, colors, useCustomColors)
    if not spawnedVehicles[model] then
        spawnedVehicles[model] = 0
    end
    
    if spawnedVehicles[model] >= maxSpawn then
        ESX.ShowNotification('Hai raggiunto il limite massimo per questo veicolo!')
        return false
    end
    
    local hash = GetHashKey(model)
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end

    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, coords.w or 0.0, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    
    if useCustomColors and colors then
        if colors.primary then
            local primaryRGB = hexToRGB(colors.primary)
            SetVehicleCustomPrimaryColour(vehicle, primaryRGB.r, primaryRGB.g, primaryRGB.b)
        end
        if colors.secondary then
            local secondaryRGB = hexToRGB(colors.secondary)
            SetVehicleCustomSecondaryColour(vehicle, secondaryRGB.r, secondaryRGB.g, secondaryRGB.b)
        end
    end
    
    Entity(vehicle).state.fuel = 100.0
    
    SetModelAsNoLongerNeeded(hash)
    
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    
    if vehicle then
        spawnedVehicles[model] = spawnedVehicles[model] + 1
    end
    
    return vehicle
end

local function ParkVehicle()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if vehicle ~= 0 then
        local vehicleModel = GetEntityModel(vehicle)
        local modelName = GetDisplayNameFromVehicleModel(vehicleModel):lower()
        
        if spawnedVehicles[modelName] and spawnedVehicles[modelName] > 0 then
            spawnedVehicles[modelName] = spawnedVehicles[modelName] - 1
        end
        
        SetVehicleEngineOn(vehicle, false, false, true)
        SetVehicleForwardSpeed(vehicle, 0.0)
        
        TaskLeaveVehicle(playerPed, vehicle, 0)
        
        Citizen.Wait(1500)
        
        DeleteEntity(vehicle)
        ESX.ShowNotification('Veicolo parcheggiato!')
    end
end

local function openGarageMenu(garage)
    local options = {}
    
    for _, vehicle in ipairs(garage.vehicles) do
        if not spawnedVehicles[vehicle.model] then
            spawnedVehicles[vehicle.model] = 0
        end
        
        local available = vehicle.maxSpawn - (spawnedVehicles[vehicle.model] or 0)
        
        table.insert(options, {
            title = string.upper(vehicle.model),
            description = string.format('Disponibili: %d/%d', available, vehicle.maxSpawn),
            disabled = available <= 0,
            onSelect = function()
                local spawnPoint = vector4(
                    garage.coords.x + 3.0,
                    garage.coords.y + 3.0,
                    garage.coords.z,
                    90.0
                )
                
                local veh = SpawnVehicle(vehicle.model, spawnPoint, vehicle.maxSpawn, vehicle.colors, garage.useCustomColors)
                if veh then
                    ESX.ShowNotification('Veicolo spawnnato con successo!')
                end
            end
        })
    end

    lib.registerContext({
        id = 'garage_menu',
        title = garage.Name,
        options = options
    })

    lib.showContext('garage_menu')
end

Citizen.CreateThread(function()
    for _, garage in ipairs(Config.Garages) do
        local blip = AddBlipForCoord(garage.coords)
        SetBlipSprite(blip, 357)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Garage")
        EndTextCommandSetBlipName(blip)
    end

    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local isInVehicle = IsPedInAnyVehicle(playerPed, false)
        local closestGarage = nil
        local closestDistance = 10.0

        for _, garage in ipairs(Config.Garages) do
            local distance = #(playerCoords - garage.coords)
            if distance < closestDistance then
                closestGarage = garage
                closestDistance = distance
            end
        end

        if closestGarage then
            if isInVehicle then
                lib.showTextUI('[E] Parcheggia Veicolo')
                if IsControlJustReleased(0, 38) then
                    local playerJob = ESX.GetPlayerData().job.name
                    ESX.TriggerServerCallback('rk.garagejob:checkJob', function(hasJob)
                        if hasJob then
                            ParkVehicle()
                        else
                            ESX.ShowNotification('Non hai il lavoro richiesto per parcheggiare qui.')
                        end
                    end, closestGarage.job)
                end
            else
                lib.showTextUI('[E] Apri Garage')
                if IsControlJustReleased(0, 38) then
                    local playerJob = ESX.GetPlayerData().job.name
                    ESX.TriggerServerCallback('rk.garagejob:checkJob', function(hasJob)
                        if hasJob then
                            openGarageMenu(closestGarage)
                        else
                            ESX.ShowNotification('Non hai il lavoro richiesto per aprire questo garage.')
                        end
                    end, closestGarage.job)
                end
            end
        else
            lib.hideTextUI()
        end
    end
end)