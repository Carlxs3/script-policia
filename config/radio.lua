Config.Multifrec = {
    ["SOUTH UNITS"] = {
        "Comisaria",
        "Esperando asignacion",
        "Mando",
        "ADAM-10",
        "ADAM-20",
        "ADAM-30",
        "ADAM-40",
        "ADAM-50",
        "ADAM-60",
        "ADAM-70",
        "ADAM-80",
        "ADAM-90",
        "BRAVO-10",
        "BRAVO-20",
        "BRAVO-30",
        "MARY-10",
        "MARY-20",
        "MARY-30",
        "UNION-10",
        "UNION-20",
        "UNION-30",
        "UNION-40",
        "UNION-50",
        "UNION-60",
        "KING-10",
        "KING-20",
        "TOM-10",
        "TOM-20",
        "TOM-30",
        "WILLIAM-10",
        "WILLIAM-20",
        "AIRE-10",
        "AIRE-20",
        "DAVID-20",
        "DAVID-30",
        "DAVID-40",
        "DAVID-50",
    },
    ["SPECIAL UNITS"] = {
        "TAC-01",
        "TAC-02",
        "TAC-03",
        "TAC-04",
        "TAC-05",
        "TAC-06",
        "TAC-07",
        "TAC-08",
        "TAC-09",
        "EVENTOS-01",
        "EVENTOS-02",
        "JEFE FOSTER",
        "JEFATURA SAPD",
        "ALTOS MANDOS SAPD",
        "OFICIALES SAPD",
        "SUBOFICIALES SAPD",
        "CADETES/APRENDICES SAPD",
        "OF-IAD",
        "OF-DTV",
        "OF-SWAT",
        "OF-METRO",
        "OF-RTD",
        "OF-RRPP",
        "OF-RRSS",
        "OF-ASD",
        "OF-SAHP",
        "OF-HSIU",
        "OF-DOA",
        "OF-SAPA",
        "OF-K9",
        "OF-USM",
    },
}

Config.ButtonsMultiFreq = {
    -- ["BROADCAST SAFMD"] = {
    --     "EMS UNITS"
    -- },
    ["BROADCAST SAPD"] = {
        "SPECIAL UNITS", "SOUTH UNITS"
    }
}

Config.BindFreqs = {
    ["HABLAR-A-CENTRAL"] = {"mando"},
    ["ESPERANDO-ASIGNACION"] = {"esperando-asignacion"},
    ["HABLAR-A-COMISARIA"] = {"comisaria"},
    ["HABLAR-A-TACS"] = {"tac-01", "tac-02", "tac-03", "tac-04", "tac-05", "tac-06"},
    ["HABLAR-A-ADAMS"] = {"ADAM-10", "ADAM-20", "ADAM-30", "ADAM-40", "ADAM-50", "ADAM-60", "ADAM-70", "ADAM-80", "ADAM-90"},
    ["HABLAR-A-UNIDADES-ESPECIALES"] = {"SPECIAL UNITS"},
    ["HABLAR-A-UNIDADES-DEL-SUR"] = {"SOUTH UNITS"}
}

Config.MegaphoneVoiceDist = 75.0 -- The distance that the voice of the megaphone will be heared

exports("GetPoliceRadioBinds", function()
    return Config.BindFreqs
end)

exports("GetPoliceRadioChannels", function()
    return Config.Multifrec
end)

exports("GetPoliceRadioButtons", function()
    return Config.ButtonsMultiFreq
end)

Config.RequestsTime = 10 -- Minutos

-- DONT TOUCH THIS

function GetCategoryFreqs(category)
    local list = Config.Multifrec[category]
    if not list then
        print("Category not found: " .. category .. " in Config.Multifrec")
        return {}
    end
    local freqs = {}
    for _, v in pairs(list) do
        table.insert(freqs, v)
    end
    return freqs
end

local nextButtonMultiFreqUpdate = {}
for buttonName, categories in pairs(Config.ButtonsMultiFreq) do
    for _, category in pairs(categories) do
        for _, v in pairs(GetCategoryFreqs(category)) do
            if nextButtonMultiFreqUpdate[buttonName] == nil then
                nextButtonMultiFreqUpdate[buttonName] = {}
            end
            nextButtonMultiFreqUpdate[buttonName][#nextButtonMultiFreqUpdate[buttonName] + 1] = v
        end
    end
end

local newBindFreqs = {}
for button, freqs in pairs(Config.BindFreqs) do
    for _, freq in pairs(freqs) do
        if Config.Multifrec[freq] then
            for _, freq2 in pairs(Config.Multifrec[freq]) do
                newBindFreqs[button] = newBindFreqs[button] or {}
                table.insert(newBindFreqs[button], freq2:lower())
            end
        else
            newBindFreqs[button] = newBindFreqs[button] or {}
            table.insert(newBindFreqs[button], freq)
        end
    end
end

for button, freqs in pairs(newBindFreqs) do
    table.insert(Config.BindFreqs[button], freqs)
end

Config.ButtonsMultiFreq = nextButtonMultiFreqUpdate