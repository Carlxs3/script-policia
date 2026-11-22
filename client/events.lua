-- =====================================================
--  Fixed by https://discord.gg/MJH5zX7NSg Reddev Development
--  Cleaned By Reddev Using Codex 5.5
--  Files Provided From Rip_Bytecode
-- =====================================================

local vehicleTypeConfig = {
    car = {
        menuTitle = "RequestVeh",
        menuText = "RequestVeh",
        icon = "fa-solid fa-car",
        keyType = "car",
        duplicateText = "ExistVehicleInSpawn",
        track = true
    },
    heli = {
        menuTitle = "Heliport",
        menuText = "TakeOutHeli",
        icon = "fa-solid fa-helicopter",
        keyType = "helicopter",
        duplicateText = "ExistHelicopterInSpawn"
    },
    boat = {
        menuTitle = "Pier",
        menuText = "TakeOutBoat",
        icon = "fa-solid fa-ship",
        keyType = "boat",
        duplicateText = "ExistBoatInSpawn"
    }
}

local function copyToClipboard(value)
    SendNUIMessage({
        action = "copy",
        value = value
    })
end

local function requestAnimDict(dict)
    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

local function requestModel(model)
    local modelHash = type(model) == "number" and model or GetHashKey(model)

    RequestModel(modelHash)

    while not HasModelLoaded(modelHash) do
        Wait(0)
    end

    return modelHash
end

local function getMarker(markerIndex, stationIndex)
    if not Tables or not Tables.Markers or not Tables.Markers[markerIndex] then
        return nil
    end

    return Tables.Markers[markerIndex][stationIndex]
end

local function getVehicleLabel(model)
    local modelHash = tonumber(model) or model
    local customLabel = Config.CustomCarLabels and Config.CustomCarLabels[modelHash]

    if customLabel then
        return customLabel
    end

    local label = GetLabelText(GetDisplayNameFromVehicleModel(modelHash))

    if not label or label == "NULL" then
        return "UNKNOWN"
    end

    return label
end

local function getGarageStatus(garage)
    if type(garage) ~= "string" then
        return Config.Translations.Unknown or "Unknown"
    end

    if garage:find("police_confiscate_veh") then
        return Config.Translations.Confiscated
    end

    if garage:find("police_") then
        return Config.Translations.PoliceFacilities
    end

    return garage
end

local function normalizeVehicleRecord(vehicle)
    if not vehicle then
        return
    end

    vehicle.label = getVehicleLabel(vehicle.hash)
    vehicle.status = getGarageStatus(vehicle.garage)
    vehicle.garage = nil
    vehicle.hash = nil
end

local function normalizeVehicleList(vehicles)
    for _, vehicle in pairs(vehicles or {}) do
        normalizeVehicleRecord(vehicle)
    end
end

local function giveExternalVehicleKeys(vehicle)
    TriggerEvent("vehiclekeys:client:SetOwner", GetVehiclePlate(vehicle))

    if GetResourceState("qs-vehiclekeys") == "started" then
        exports["qs-vehiclekeys"]:GiveKeys(
            GetVehiclePlate(vehicle),
            GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)),
            true
        )
    end
end

local function removeExternalVehicleKeys(vehicle)
    if GetResourceState("qs-vehiclekeys") == "started" then
        exports["qs-vehiclekeys"]:RemoveKeys(
            GetVehiclePlate(vehicle),
            GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        )
    end
end

local function isSpawnClear(spawnCoords)
    local closestVehicle = FW_GetClosestVehicle(spawnCoords)

    if not closestVehicle or closestVehicle == 0 then
        return true
    end

    return #(spawnCoords - GetEntityCoords(closestVehicle)) > 4.0
end

local function spawnPoliceVehicle(vehicleType, model, vehicleData, marker)
    local typeConfig = vehicleTypeConfig[vehicleType]

    if not marker or not marker.spawn then
        return
    end

    if not isSpawnClear(marker.spawn.xyz) then
        ShowNotification(Config.Translations[typeConfig.duplicateText])
        return
    end

    FW_SpawnVehicle(model, function(vehicle)
        if vehicleData.mods or vehicleData.colors then
            SetVehicleModKit(vehicle, 0)
        end

        for _, mod in pairs(vehicleData.mods or {}) do
            SetVehicleMod(vehicle, mod.modType, mod.modIndex, false)
        end

        local colors = vehicleData.colors
        if colors then
            SetVehicleColours(vehicle, colors.primary, colors.secondary)
            SetVehicleExtraColours(vehicle, colors.pearlescent, colors.wheel)
        end

        for _, extra in pairs(vehicleData.extras or {}) do
            local enabled = extra.enabled == true or extra.enabled == 1
            SetVehicleExtra(vehicle, extra.extraID, not enabled)
        end

        local randomPlate = tostring(math.random(1000, 9999))
        local policePlate = "POL " .. randomPlate

        SetVehicleNumberPlateText(vehicle, policePlate)
        SetVehicleFuel(vehicle, 100.0)
        SetEntityHeading(vehicle, marker.spawn.w)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        giveExternalVehicleKeys(vehicle)

        if typeConfig.track then
            TriggerServerEvent("origen_police:server:TrackVehicle", NetworkGetNetworkIdFromEntity(vehicle), getVehicleLabel(GetEntityModel(vehicle)))
        end

        GiveKeys(typeConfig.keyType, vehicle)
        AddVehicleExtras(typeConfig.keyType, vehicle, model)
    end, marker.spawn.xyz, true)
end

local function openVehicleMenu(vehicleType, markerIndex, stationIndex)
    local marker = getMarker(markerIndex, stationIndex)
    local typeConfig = vehicleTypeConfig[vehicleType]
    local playerData = FW_GetPlayerData()
    local jobName = playerData.job and playerData.job.name
    local gradeLevel = playerData.job and playerData.job.grade and playerData.job.grade.level or 0
    local menu = {
        {
            header = Config.Translations[typeConfig.menuTitle],
            isMenuHeader = true
        }
    }

    for model, vehicleData in pairs((Config.Vehicles[vehicleType] and Config.Vehicles[vehicleType][jobName]) or {}) do
        if gradeLevel >= (vehicleData.grade or 0) then
            menu[#menu + 1] = {
                header = vehicleData.label,
                txt = Config.Translations[typeConfig.menuText],
                icon = typeConfig.icon,
                params = {
                    isAction = true,
                    event = function()
                        spawnPoliceVehicle(vehicleType, model, vehicleData, marker)
                    end
                }
            }
        end
    end

    OpenMenu(menu)
end

RegisterNetEvent("origen_police:client:buyveh", function(markerIndex, stationIndex)
    openVehicleMenu("car", markerIndex, stationIndex)
end)

RegisterNetEvent("origen_police:client:helicop", function(markerIndex, stationIndex)
    openVehicleMenu("heli", markerIndex, stationIndex)
end)

RegisterNetEvent("origen_police:client:boat", function(markerIndex, stationIndex)
    openVehicleMenu("boat", markerIndex, stationIndex)
end)

RegisterNetEvent("origen_police:client:deletevehicle", function()
    local vehicle = GetVehicleInCamera()

    if vehicle == 0 then
        ShowNotification(Config.Translations.MustLook)
        return
    end

    if #(GetEntityCoords(vehicle) - GetEntityCoords(PlayerPedId())) >= 7.0 then
        return
    end

    removeExternalVehicleKeys(vehicle)
    TaskLeaveVehicle(PlayerPedId(), vehicle, 64)
    RemoveKeys(vehicle)
    Wait(2000)
    FW_DeleteVehicle(vehicle)
end)

RegisterNetEvent("origen_police:client:inventory", function(markerIndex, stationIndex)
    local marker = getMarker(markerIndex, stationIndex)

    OpenMenu({
        {
            header = Config.Translations.PoliceEquipment,
            isMenuHeader = true
        },
        {
            header = Config.Translations.Equipment,
            txt = Config.Translations.EquipmentDesc,
            icon = "fa-solid fa-gun",
            params = {
                isAction = true,
                event = OpenArmoury
            }
        },
        {
            header = Config.Translations.LeaveEquipment,
            txt = Config.Translations.LeaveEquipmentDesc,
            icon = "fa-solid fa-shield",
            params = {
                isAction = true,
                event = function()
                    LeavePoliceEquipment(marker)
                end
            }
        },
        {
            header = Config.Translations.PoliceInventory,
            txt = Config.Translations.PoliceInventoryDesc,
            icon = "fa-solid fa-box",
            params = {
                isAction = true,
                event = function()
                    PoliceInventory(marker)
                end
            }
        },
        {
            header = Config.Translations.EvidenceProof,
            txt = Config.Translations.EvidenceProofDesc,
            icon = "fa-solid fa-receipt",
            params = {
                isAction = true,
                event = function()
                    OpenEvidenceInventory(marker)
                end
            }
        }
    })
end)

RegisterNetEvent("origen_police:client:vehicledata", function()
    local vehicle = GetVehicleInCamera()

    if vehicle == 0 then
        ShowNotification(Config.Translations.MustLook)
        return
    end

    if #(GetEntityCoords(vehicle) - GetEntityCoords(PlayerPedId())) >= Config.VehicleDataDist then
        return
    end

    local modelLabel = getVehicleLabel(GetEntityModel(vehicle))
    local plate = GetVehiclePlate(vehicle)

    FW_TriggerCallback("origen_police:callback:vehicledata", function(owner)
        OpenMenu({
            {
                header = Config.Translations.VehicleInformation,
                isMenuHeader = true
            },
            {
                header = Config.Translations.Model,
                txt = modelLabel,
                icon = "fa-solid fa-car",
                params = {
                    isAction = true,
                    event = function()
                        copyToClipboard(modelLabel)
                    end
                }
            },
            {
                header = Config.Translations.LicensePlate,
                txt = plate,
                icon = "fa-solid fa-id-card",
                params = {
                    isAction = true,
                    event = function()
                        copyToClipboard(plate)
                    end
                }
            },
            {
                header = Config.Translations.Owner,
                txt = owner,
                icon = "fa-solid fa-user",
                params = {
                    isAction = true,
                    event = function()
                        copyToClipboard(owner)
                    end
                }
            }
        })
    end, plate)
end)

RegisterNetEvent("origen_police:client:dvpolice", function()
    ConfiscateVeh()
end)

RegisterNetEvent("origen_police:client:openveh", function()
    local vehicle = GetVehicleInCamera()

    if vehicle == 0 then
        ShowNotification(Config.Translations.MustLook)
        return
    end

    if #(GetEntityCoords(vehicle) - GetEntityCoords(PlayerPedId())) >= 2.0 then
        return
    end

    local attempts = 0
    while not NetworkHasControlOfEntity(vehicle) and attempts < 100 and DoesEntityExist(vehicle) do
        Wait(100)
        NetworkRequestControlOfEntity(vehicle)
        attempts = attempts + 1
    end

    if not DoesEntityExist(vehicle) or not NetworkHasControlOfEntity(vehicle) then
        ShowNotification(Config.Translations.CouldntOpenLock)
        return
    end

    requestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    TaskPlayAnim(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 8.0, -8.0, -1, 1, 0, false, false, false)
    Wait(3000)
    ClearPedTasks(PlayerPedId())

    SetVehicleDoorsLocked(vehicle, 0)
    SetVehicleDoorsLockedForAllPlayers(vehicle, false)
    GiveVehicleKeys(vehicle)
end)

RegisterNetEvent("origen_police:client:vehevidences", function()
    local vehicle = GetVehicleInCamera()

    if vehicle == 0 then
        ShowNotification(Config.Translations.MustLook)
        return
    end

    if #(GetEntityCoords(vehicle) - GetEntityCoords(PlayerPedId())) < 2.0 then
        TriggerServerEvent("origen_police:server:GetEvidence", false, {
            type = "FinguerPrint",
            fkserie = GetVehiclePlate(vehicle)
        })
    end
end)

RegisterNetEvent("origen_police:client:makereport", function()
    local evidences = {}
    local playerData = FW_GetPlayerData(true)

    for _, item in pairs(playerData.items or {}) do
        if #evidences >= 4 then
            break
        end

        if item.name and item.name:find("^evidence_") then
            evidences[#evidences + 1] = GetItemMetadata(item)
        end
    end

    if #evidences == 0 then
        ShowNotification(Config.Translations.NoEvidence)
        return
    end

    TriggerServerEvent("origen_police:client:removeevidences")
    FW_TriggerCallback("OsTime", function(date)
        SendNUIMessage({
            action = "AnalizeEvidences",
            list = evidences,
            date = date
        })
    end)
    SetNuiFocus(true, true)
end)

RegisterNUICallback("focus", function(_, cb)
    SetNuiFocus(false, false)
    ClearPedTasks(PlayerPedId())
    cb(true)
end)

RegisterNUICallback("savereportevidence", function(data, cb)
    TriggerServerEvent("origen_police:server:SaveReportEvidence", data)
    cb(true)
end)

RegisterNetEvent("origen_police:client:showbadge", function(badgeData)
    local playerData = FW_GetPlayerData()
    local isPolice = CanOpenTablet(playerData.job.name)[1]

    if Config.ShowBadgePreview then
        TriggerEvent("origen_police:client:viewbadge", badgeData)
    end

    if not isPolice and not Config.NotPoliceCanShowBadge then
        return
    end

    local closestPlayer, distance = FW_GetClosestPlayer()
    if closestPlayer == -1 or distance > 3.0 or distance <= 0 then
        ShowNotification(Config.Translations.NoPersonNear, "error")
        return
    end

    requestAnimDict("paper_1_rcm_alt1-8")

    local badgeConfig = GetBadgeConfig(nil, badgeData.type)
    local model = (badgeConfig and badgeConfig.model) or "prop_lspd_badge"
    local modelHash = requestModel(model)
    local coords = GetEntityCoords(PlayerPedId())
    local badgeObject = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, true)

    TaskPlayAnim(PlayerPedId(), "paper_1_rcm_alt1-8", "player_one_dual-8", 8.0, 8.0, -1, 50, 0, false, false, false)
    AttachEntityToEntity(
        badgeObject,
        PlayerPedId(),
        GetPedBoneIndex(PlayerPedId(), 28422),
        0.09,
        0.0,
        -0.05,
        -90.0,
        -180.0,
        70.9,
        true,
        true,
        false,
        true,
        1,
        true
    )

    TriggerServerEvent("origen_police:server:showbadge", GetPlayerServerId(closestPlayer), badgeData)

    Wait(5000)
    ClearPedTasks(PlayerPedId())
    DeleteObject(badgeObject)
end)

RegisterNetEvent("origen_police:client:viewbadge", function(badgeData)
    badgeData.action = "ViewBadge"
    SendNUIMessage(badgeData)

    CreateThread(function()
        while true do
            Wait(0)

            if IsControlJustPressed(0, 177) then
                SendNUIMessage({ action = "ViewBadge" })
                break
            end
        end
    end)
end)

RegisterNUICallback("LoadRadio", function(_, cb)
    local playerData = FW_GetPlayerData(false)

    local function openRadio()
        exports.origen_police:Toggle(true)
        cb({
            freclist = Config.Multifrec,
            myfrec = exports.origen_police:GetMultiFrec() or "none"
        })
    end

    if not Config.NeedRadioForDispatch then
        openRadio()
        return
    end

    for _, item in pairs(playerData.items or {}) do
        if item.name == "radio" then
            openRadio()
            return
        end
    end

    cb(false)
end)

RegisterNetEvent("origen_police:client:AddPlayerMultiFrec", function(id, frec, data)
    SendNUIMessage({
        radio = "AddPlayerMultiFrec",
        id = id,
        frec = frec,
        data = data,
        i = id == GetPlayerServerId(PlayerId())
    })
end)

RegisterNetEvent("origen_police:client:Disconnected", function()
    SendNUIMessage({ radio = "Disconnected" })
end)

RegisterNetEvent("origen_police:client:talking", function(target, value)
    SendNUIMessage({
        radio = "Talking",
        target = target,
        value = value
    })
end)

RegisterNetEvent("origen_police:client:RemovePlayerMultiFrec", function(id, frec)
    SendNUIMessage({
        radio = "RemovePlayerMultiFrec",
        id = id,
        frec = frec
    })
end)

RegisterNetEvent("origen_police:client:SetMuted", function(id, value)
    SendNUIMessage({
        radio = "SetMuted",
        id = id,
        value = value
    })
end)

RegisterNetEvent("origen_police:client:SetReady", function(id, value)
    SendNUIMessage({
        radio = "SetReady",
        id = id,
        value = value
    })
end)

RegisterNUICallback("TriggerCallback", function(data, cb)
    if type(data.name) ~= "string" or not data.name:find("^origen_police") then
        cb(false)
        return
    end

    FW_TriggerCallback(data.name, function(result)
        if data.name == "origen_police:police:GetCitizen" then
            normalizeVehicleList(result and result.vehicles)
        elseif data.name == "origen_police:police:SearchVehicle" then
            normalizeVehicleList(result)
        elseif data.name == "origen_police:police:GetVehicle" then
            normalizeVehicleRecord(result)
        elseif data.name == "origen_police:callback:GetStationsList" then
            for _, station in pairs(result or {}) do
                station.coords = station.coords or { 0, 0, 0 }
                station.street = GetStreetName(station.coords)
            end
        end

        cb(result)
    end, data)
end)

RegisterNetEvent("origen_police:client:SyncQuick", function(data)
    data.action = "SyncQuick"
    SendNUIMessage(data)
end)

RegisterNetEvent("origen_police:client:SetWantedLevel", function(level)
    SetWantedLevel(level)
end)

RegisterNetEvent("origen_police:client:clothing", function(_, _, markerType)
    OpenClothing(markerType)
end)

RegisterNetEvent("origen_police:client:CriminalClothes", function()
    local playerData = FW_GetPlayerData(true)
    local ped = PlayerPedId()
    local model = GetEntityModel(ped)
    local gender = false

    if model == `mp_m_freemode_01` then
        gender = "male"
    elseif model == `mp_f_freemode_01` then
        gender = "female"
    end

    SetCriminalClothes(gender, playerData)
end)

RegisterNetEvent("origen_police:client:pertenences", function(markerIndex)
    local marker = Public.Markers[markerIndex]
    TriggerServerEvent("origen_police:server:pertenences", marker and marker.station or 0)
end)

local function openExtrasMenu(vehicle)
    local menu = {
        {
            header = Config.Translations.VehicleMods,
            isMenuHeader = true
        }
    }

    for extraId, disabled in pairs(GetVehicleExtras(vehicle)) do
        menu[#menu + 1] = {
            header = "EXTRA " .. tostring(extraId),
            txt = disabled and Config.Translations.Enabled or Config.Translations.Disabled,
            icon = "fa-solid fa-gear",
            params = {
                isAction = true,
                event = function()
                    SetVehicleExtra(vehicle, extraId, disabled)
                end
            }
        }
    end

    menu[#menu + 1] = {
        header = Config.Translations.Back,
        icon = "fa-solid fa-arrow-left",
        params = {
            isAction = true,
            event = function()
                TriggerEvent("origen_police:client:modifyveh")
            end
        }
    }

    OpenMenu(menu)
end

local function openLiveryMenu(vehicle)
    local menu = {
        {
            header = Config.Translations.VehicleMods,
            isMenuHeader = true
        }
    }

    local modCount = GetNumVehicleMods(vehicle, 48)
    local liveryCount = GetVehicleLiveryCount(vehicle)

    if modCount and modCount > 0 then
        for livery = 0, modCount - 1 do
            menu[#menu + 1] = {
                header = "LIVERY " .. tostring(livery),
                icon = "fa-solid fa-paint-brush",
                params = {
                    isAction = true,
                    event = function()
                        SetVehicleLivery(vehicle, livery)
                        SetVehicleMod(vehicle, 48, livery)
                    end
                }
            }
        end
    elseif liveryCount and liveryCount > 0 then
        for livery = 0, liveryCount - 1 do
            menu[#menu + 1] = {
                header = "LIVERY " .. tostring(livery),
                icon = "fa-solid fa-paint-brush",
                params = {
                    isAction = true,
                    event = function()
                        SetVehicleLivery(vehicle, livery)
                        SetVehicleMod(vehicle, 48, livery)
                    end
                }
            }
        end
    end

    menu[#menu + 1] = {
        header = Config.Translations.Back,
        icon = "fa-solid fa-arrow-left",
        params = {
            isAction = true,
            event = function()
                TriggerEvent("origen_police:client:modifyveh")
            end
        }
    }

    OpenMenu(menu)
end

RegisterNetEvent("origen_police:client:modifyveh", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    if vehicle == 0 then
        ShowNotification(Config.Translations.VehicleCannotBeFound)
        return
    end

    if not IsVehicleValid("car", vehicle) then
        ShowNotification(Config.Translations.InvalidVeh)
        return
    end

    OpenMenu({
        {
            header = Config.Translations.VehicleMods,
            isMenuHeader = true
        },
        {
            header = "EXTRAS",
            icon = "fa-solid fa-gear",
            params = {
                isAction = true,
                event = function()
                    openExtrasMenu(vehicle)
                end
            }
        },
        {
            header = "LIVERIES",
            icon = "fa-solid fa-paint-brush",
            params = {
                isAction = true,
                event = function()
                    openLiveryMenu(vehicle)
                end
            }
        }
    })
end)

RegisterNUICallback("SetVolume", function(volume, cb)
    if type(volume) == "number" then
        volume = math.max(0, math.min(100, volume))
        SetRadioVolume(volume)
    end

    if cb then
        cb(true)
    end
end)

RegisterNetEvent("origen_police:client:GenerateMugshotBadge", function(citizenId, badgeType, transparent)
    local mugshot = GetMugShotBase64(PlayerPedId(), false, transparent)
    TriggerServerEvent("origen_police:server:SaveMugshot", mugshot, citizenId, badgeType)
end)
